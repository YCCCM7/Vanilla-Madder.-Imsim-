//=============================================================================
// HackableDevices.
//=============================================================================
class HackableDevices extends ElectronicDevices
	abstract;

var() bool				bHackable;				// can this device be hacked?
var() float 			hackStrength;			// "toughness" of the hack on this device - 0.0 is easy, 1.0 is hard
var() float          initialhackStrength; // for multiplayer hack resets, this is the initial value
var() name				UnTriggerEvent[4];		// event to UnTrigger when hacked

var bool				   bHacking;				// a multitool is currently being used
var float				hackValue;				// how much this multitool is currently hacking
var float				hackTime;				// how much time it takes to use a single multitool
var int					numHacks;				// how many times to reduce hack strength
var float            TicksSinceLastHack;   // num 0.1 second ticks done since last hackstrength update(includes partials)
var float            TicksPerHack;         // num 0.1 second ticks needed for a hackstrength update(includes partials)
var float			 LastTickTime;		   // time last tick occurred.

var DeusExPlayer		hackPlayer;				// the player that is hacking
var Multitool			curTool;				// the multitool that is being used

var float            TimeSinceReset;   // time since the hackstate was last reset.
var float            TimeToReset;      // how long between resets

var localized string	msgMultitoolSuccess;	// message when the device is hacked
var localized string	msgNotHacked;			// message when the device is not hacked
var localized string	msgHacking;				// message when the device is being hacked
var localized string	msgAlreadyHacked;		// message when the device is already hacked

//MADDERS Additions.
var bool bFirstHackSpent; //Used for multitools on freebies. Yeet.
var int TimesHacked;
var localized string RushMessage;

var bool bAltHacking; //NEW: Rush mechanic

// ---------------------------------------------------------------------------------------
// Networking Replication
// ---------------------------------------------------------------------------------------
replication
{
   	//server to client variables
   	reliable if (Role == ROLE_Authority)
      		bHackable, hackStrength, hackValue;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// keep this within limits
	hackStrength = FClamp(hackStrength, 0.0, 1.0);

	if (!bHackable)
		hackStrength = 1.0;

   	initialhackStrength = hackStrength;
   	TimeSinceReset = 0.0;
}

//
// HackAction() - called when the device is successfully hacked
//
function HackAction(Actor Hacker, bool bHacked)
{
	local Actor A;
	local int i;

	if (bHacked)
	{
		for (i=0; i<ArrayCount(UnTriggerEvent); i++)
			if (UnTriggerEvent[i] != '')
				foreach AllActors(class'Actor', A, UnTriggerEvent[i])
					A.UnTrigger(Hacker, Pawn(Hacker));   
   	}
}

//
// Called every 0.1 seconds while the multitool is actually hacking
//
function Timer()
{
	local float THackMath;
	
	if (bHacking)
	{
		curTool.PlayUseAnim();
		
	  	TicksSinceLastHack += LastTickTime * 10; //TicksSinceLastHack += (Level.TimeSeconds - LastTickTime) * 10;
	  	LastTickTime = 0; //LastTickTime = Level.TimeSeconds;
      		//TicksSinceLastHack = TicksSinceLastHack + 1;
      		while (TicksSinceLastHack > TicksPerHack && NumHacks > 0)
      		{
         		numHacks--;
			
			THackMath = CurTool.GetHackPotency(Self) * 0.01;
			if (bAltHacking)
			{
				if ((VMDBufferPlayer(HackPlayer) != None) && (VMDBufferPlayer(HackPlayer).HasSkillAugment("ElectronicsFailNoise")))
				{
					THackMath *= 4.0;
				}
				else
				{
					THackMath *= 3.0;
				}
			}
			
         		hackStrength -= THackMath;
         		TicksSinceLastHack = TicksSinceLastHack - TicksPerHack;
         		hackStrength = FClamp(hackStrength, 0.0, 1.0);
      		}
		
		// did we hack it?
		if (hackStrength < 0.01)
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
		{
			StopHacking();
		}
		
		// check to see if we've moved too far away from the device to continue
		else if (hackPlayer.frobTarget != Self)
		{
			StopHacking();
		}
		
		// check to see if we've put the multitool away
		else if (hackPlayer.inHand != curTool)
			StopHacking();
	}
}

//
// Called to deal with resetting the device
//
function Tick(float deltaTime)
{
	LastTickTime += deltaTime;
	
   	TimeSinceReset = TimeSinceReset + deltaTime;
   	//only reset in multiplayer, if we aren't hacking it, and if it has been completely hacked.
   	if ((!bHacking) && (Level.NetMode != NM_Standalone) && (hackStrength == 0.0))
   	{
      		if (TimeSinceReset > TimeToReset)
      		{
         		hackStrength = initialHackStrength;
         		TimeSinceReset = 0.0;
      		}
   	}
   	Super.Tick(deltaTime);
}

//
// Stops the current hack-in-progress
//
function StopHacking()
{
	// alert NPCs that I'm not messing with stuff anymore
	AIEndEvent('MegaFutz', EAITYPE_Visual);
	bHacking = False;
	if (curTool != None)
	{
		curTool.StopUseAnim();
		curTool.bBeingUsed = False;
		curTool.UseOnce();
	}
	curTool = None;
	SetTimer(0.1, False);
}

//
// The main logic function for control panels
//
function Frob(Actor Frobber, Inventory frobWith)
{
	local Pawn P;
	local DeusExPlayer Player;
	local bool bHackIt, bDone;
	local string msg;
	local Vector X, Y, Z;
	local float dotp;
	local float HackTweak2;
	local float TSkill;
	
	P = Pawn(Frobber);
	Player = DeusExPlayer(P);
	bHackIt = False;
	bDone = False;
	msg = msgNotHacked;
	
	// make sure someone is trying to hack the device
	if (P == None)
		return;
	
	// Let any non-player pawn hack the device for now
	if (Player == None)
	{
		bHackIt = True;
		msg = "";
		bDone = True;
	}
	
	// If we are already trying to hack it, print a message
	if (bHacking)
	{
		if ((FrobWith != None) && (!bAltHacking))
		{
			HackTweak2 = 3.0;
			if ((VMDBufferPlayer(Frobber) != None) && (VMDBufferPlayer(Frobber).HasSkillAugment("ElectronicsFailNoise")))
			{
				HackTweak2 = 4.0;
			}
			if ((Player != None) && (Player.SkillSystem != None))
			{
				TSkill = Player.SkillSystem.GetSkillLevelValue(class'SkillTech');
			}
			
			NumHacks = int((float(NumHacks) / HackTweak2) + 0.99);
			HackTime /= HackTweak2;
			bAltHacking = true;
			bDone = true;
			msg = RushMessage;
		}
		else
		{
			msg = msgHacking;
			bDone = True;
		}
	}
	
	if (!bDone)
	{
		// Get what's in the player's hand
		if (frobWith != None)
		{
			// check for the use of multitools
			if ((bHackable) && (frobWith.IsA('Multitool')) && (Player.SkillSystem != None))
			{
				if (hackStrength > 0.0)
				{
					// alert NPCs that I'm messing with stuff
					AIStartEvent('MegaFutz', EAITYPE_Visual);
					
					TimesHacked++;
					hackValue = Player.SkillSystem.GetSkillLevelValue(class'SkillTech');
					hackPlayer = Player;
					curTool = Multitool(frobWith);
					curTool.bBeingUsed = True;
					curTool.PlayUseAnim();
					CurTool.LastHackTarget = self;
					bHacking = True;
               				//Number of percentage points to remove
               				numHacks = VMDGenerateNumHacks();
					HackTime = VMDConfigureHackTime();
               				if (Level.Netmode != NM_Standalone)
					{
                  				hackTime = default.hackTime / (hackValue * hackValue);
					}
               				TicksPerHack = (hackTime * 10.0) / numHacks;
			   		LastTickTime = 0; //LastTickTime = Level.TimeSeconds;
               				TicksSinceLastHack = 0;
               				SetTimer(0.1, True);
					
					if (bAltHacking) msg = RushMessage;
					else msg = msgHacking;
				}
				else
				{
					bHackIt = True;
					msg = msgAlreadyHacked;
				}
			}
		}
		else if (hackStrength == 0.0)
		{
			// if it's open
			bHackIt = True;
			msg = "";
		}
	}
	
	// give the player a message
	if ((Player != None) && (msg != ""))
		Player.ClientMessage(msg);
	
	// if our hands are empty, call HackAction()
	if ((Player != None) && (frobWith == None))
		HackAction(Frobber, (hackStrength == 0.0));
	
	// trigger the device!
	if (bHackIt)
		Super.Frob(Frobber, frobWith);
}

function float VMDConfigureHackTime()
{
 	local float Ret;
 	local bool bSkillAugment;
	
	if ((VMDBufferPlayer(GetPlayerPawn()) != None) && (VMDBufferPlayer(GetPlayerPawn()).HasSkillAugment("ElectronicsSpeed")))
	{
		bSkillAugment = true;
	}
	
 	if ((Keypad(Self) != None) && (!Keypad(Self).bAltHacking) && (Keypad(Self).GetCodebreakerPreference()))
	{
		Ret = Default.HackTime * (Sqrt(Sqrt(HackValue)));
		if (bSkillAugment) Ret *= 1.25;
	}
 	else
	{
		Ret = Default.HackTime * (0.5 + Frand());
		//if (bSkillAugment) Ret *= 0.66;
 	}
	Ret *= 1.35;
	
 	return Ret;
}

function int VMDGenerateNumHacks()
{
	local int Ret, RandChunk, Seed;
	
	//Seed = (TimesHacked + class'VMDStaticFunctions'.Static.DeriveActorSeed(21, true)) % 21;
	//RandChunk = class'VMDStaticFunctions'.Static.RipSeedChunk("Hacking 1", Seed);
	
	//MADDERS: Messy history, but we've gradually steered closer to non-gameability, vs the original version.
	//------------
	//Ret = hackValue * (50 + Rand(102));
	//Ret = (50 + Rand(102));
	//Ret = (50 + (5 * RandChunk));
	
	Ret = 100;
	
	return Ret;
}

defaultproperties
{
     RushMessage="Rushing hack attempt..."
     
     bHackable=True
     hackStrength=0.200000
     HackTime=4.000000
     TimeToReset=28.000000
     msgMultitoolSuccess="You bypassed the device"
     msgNotHacked="It's secure"
     msgHacking="Bypassing the device..."
     msgAlreadyHacked="It's already bypassed"
     Physics=PHYS_None
     bCollideWorld=False
}
