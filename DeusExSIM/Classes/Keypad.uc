//=============================================================================
// Keypad.
//=============================================================================
class Keypad extends HackableDevices
	abstract;

var() string validCode;
var() sound successSound;
var() sound failureSound;
var() name FailEvent;
var() bool bToggleLock;		// if True, toggle the lock state instead of triggering

var HUDKeypadWindow keypadwindow;

//MADDERS: Keypad hacking in progress.
var string HackedValidCode;

// ----------------------------------------------------------------------
// Network Replication
// ----------------------------------------------------------------------

replication
{
   	//server to client variables
   	reliable if ( Role == ROLE_Authority )
      		bToggleLock, FailEvent, validCode;
}

// ----------------------------------------------------------------------
// HackAction()
// ----------------------------------------------------------------------

function HackAction(Actor Hacker, bool bHacked)
{
	local DeusExPlayer Player;

	// if we're already using this keypad, get out
	if (keypadwindow != None)
		return;

	Player = DeusExPlayer(Hacker);

	if (Player != None)
	{
      		// DEUS_EX AMSD if we are in multiplayer, just act based on bHacked
      		// if you want keypad windows to work in multiplayer, just get rid of this
      		// if statement.  I've already got the windows working, they're just disabled.
      		if (Level.NetMode != NM_Standalone)
      		{
      	   		if (bHacked)
         		{
            			ToggleLocks(Player);
            			RunEvents(Player,True);
            			RunUntriggers(Player);
         		}
         		return;
      		}
      		//DEUS_EX AMSD Must call in player for replication to work.
      		Player.ActivateKeypadWindow(Self, bHacked);
	}
}

// ----------------------------------------------------------------------
// ActivateKeypadWindow
// DEUS_EX AMSD Bounce back call from player so function rep works right.
// ----------------------------------------------------------------------
simulated function ActivateKeypadWindow(DeusExPlayer Hacker, bool bHacked)
{
	local DeusExRootWindow root;
	
   	root = DeusExRootWindow(Hacker.rootWindow);
   	if (root != None)
   	{
      		keypadwindow = HUDKeypadWindow(root.InvokeUIScreen(Class'HUDKeypadWindow', True));
      		root.MaskBackground(True);
      		
      		// copy the tag data to the actual class
      		if (keypadwindow != None)
      		{
         		keypadwindow.keypadOwner = Self;
         		keypadwindow.player = Hacker;
         		keypadwindow.bInstantSuccess = bHacked;
         		keypadwindow.InitData();
      		}
   	}
}

// ----------------------------------------------------------------------
// RunUntriggers()
// DEUS_EX AMSD Bounce back call from player so function rep works right.
// ----------------------------------------------------------------------
function RunUntriggers(DeusExPlayer Player)
{
	local Actor A;
	local int i;
	
	for (i=0; i<ArrayCount(UnTriggerEvent); i++)
	{
		if (UnTriggerEvent[i] != '')
		{
			foreach AllActors(class 'Actor', A, UnTriggerEvent[i])
			{
            			A.UnTrigger(Self, Player);
         		}
      		}
   	}
}

// ----------------------------------------------------------------------
// RunEvents()
// ----------------------------------------------------------------------
function RunEvents(DeusExPlayer Player, bool bSuccess)
{
   	local Actor A;
	
   	if ((bSuccess) && (Event != ''))
   	{
      		foreach AllActors(class 'Actor', A, Event)
         		A.Trigger(Self, Player);
   	}
   	else if ((!bSuccess) && (FailEvent != ''))
   	{
      		foreach AllActors(class 'Actor', A, FailEvent)
         		A.Trigger(Self, Player);
   	}
}

// ----------------------------------------------------------------------
// ToggleLocks()
// ----------------------------------------------------------------------
function ToggleLocks(DeusExPlayer Player)
{
   	local Actor A;
   	if (bToggleLock)
   	{
      		foreach AllActors(class 'Actor', A, Event)
         		if (A.IsA('DeusExMover'))
            			DeusExMover(A).bLocked = !DeusExMover(A).bLocked;
   	}
}

//
// Called every 0.1 seconds while the multitool is actually hacking
//
/*function Timer()
{
	local float HackPowMult;
	local VMDBufferPlayer VMP;
	
	if (bHacking)
	{
		curTool.PlayUseAnim();
		
	  	TicksSinceLastHack += LastTickTime * 10; //TicksSinceLastHack += (Level.TimeSeconds - LastTickTime) * 10;
	  	LastTickTime = 0; //LastTickTime = Level.TimeSeconds;
      		//TicksSinceLastHack = TicksSinceLastHack + 1;
      		while (TicksSinceLastHack > TicksPerHack)
      		{
         		numHacks--;
			if (!GetCodebreakerPreference() || bAltHacking)
			{
				VMP = VMDBufferPlayer(HackPlayer);
				HackPowMult = 1.0;
				if ((VMP != None) && (VMP.HasSkillAugment('ElectronicsKeypads')))
				{
					HackPowMult *= 1.40;
				}
	         		hackStrength -= CurTool.GetHackPotency() * HackPowMult;
			}
         		TicksSinceLastHack = TicksSinceLastHack - TicksPerHack;
         		hackStrength = FClamp(hackStrength, 0.0, 1.0);
      		}
		
		// did we hack it?
		if (hackStrength ~= 0.0)
		{
			hackStrength = 0.0;
			hackPlayer.ClientMessage(msgMultitoolSuccess);
         		// Start reset counter from the time you finish hacking it.
         		TimeSinceReset = 0;
			StopHacking();
			HackAction(hackPlayer, True);
		}
		
		// are we done with this tool?
		else if (numHacks <= 0)
			StopHacking();
		
		// check to see if we've moved too far away from the device to continue
		else if (hackPlayer.frobTarget != Self)
			StopHacking();
		
		// check to see if we've put the multitool away
		else if (hackPlayer.inHand != curTool)
			StopHacking();
	}
}*/

function bool GetCodebreakerPreference()
{
	local VMDBufferPlayer VMP;
	
	/*VMP = VMDBufferPlayer(GetPlayerPawn());
	
	if (VMP != None)
	{
		return VMP.bCodebreakerPreference;
	}*/
	return false;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     validCode="1234"
     successSound=Sound'DeusExSounds.Generic.Beep2'
     failureSound=Sound'DeusExSounds.Generic.Buzz1'
     bToggleLock=True
     ItemName="Security Keypad"
     Mass=10.000000
     Buoyancy=5.000000
}
