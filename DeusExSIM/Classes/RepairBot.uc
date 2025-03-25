//=============================================================================
// RepairBot.
//=============================================================================
class RepairBot extends Robot;

var int chargeAmount;
var int chargeRefreshTime;
var int mpChargeRefreshTime;
var int mpChargeAmount;
var Float lastchargeTime;

//MADDERS: Limit recharges!
var int RechargeLeft;
var(VMD) bool bHubBot; //Don't consume charges if true.
var localized string MsgRepairBotDepleted, MsgRepairBotKillswitch, MsgRepairBotEMPd,
			FrobMsgUnlimited, FrobMsgCooldown, FrobMsgEmpty, FrobMsgPointsLeft;

// ----------------------------------------------------------------------
// Network replication
// ----------------------------------------------------------------------
replication
{
	// MBCODE: Replicate the last time charged to the server
   	// DEUS_EX AMSD Changed to replicate to client.
	reliable if ( Role == ROLE_Authority )
		lastchargeTime, chargeRefreshTime;

}

function string VMDGetDisplayName(string InName)
{
	if (bHubBot)
	{
		if (LastChargeTime > 0)
		{
			InName = SprintF(FrobMsgCooldown, InName, int(LastChargeTime));
		}
		else
		{
			InName = SprintF(FrobMsgUnlimited, InName);
		}
	}
	else
	{
		if (RechargeLeft <= 0)
		{
			InName = SprintF(FrobMsgEmpty, InName);
		}
		else if (LastChargeTime > 0)
		{
			InName = SprintF(FrobMsgCooldown, InName, int(LastChargeTime));
		}
		else
		{
			InName = SprintF(FrobMsgPointsLeft, InName, RechargeLeft);
		}
	}
	return InName;
}

// ----------------------------------------------------------------------
// EnemiesLeft()
// Count these for relevance with hub worlds.
// ----------------------------------------------------------------------

function int EnemiesLeft( DeusExPlayer TPlayer )
{
	local int Ret;
	local Pawn TPawn;
	local ScriptedPawn SP;
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((SP !=  None) && (SP.GetPawnAllianceType(TPlayer) == ALLIANCE_Hostile) && (VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant))
		{
			Ret++;
		}
	}
	
	return Ret;
}

//MADDERS, 12/26/20: Shut up. You're dead to us now.
function VMDEMPHook()
{
	AmbientSound = None;
}

//MADDERS: Use some quick maths to 
function ApplySpecialStats2()
{
	local DeusExPlayer TPlayer;
	
	forEach AllActors(class'DeusExPlayer', TPlayer) break;
	
	if ((TPlayer != None) && (EnemiesLeft(TPlayer) < 3))
	{
		bHubBot = true;
	}
}

// ----------------------------------------------------------------------
// PostBeginPlay()
// ----------------------------------------------------------------------

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
   	if (Level.NetMode != NM_Standalone)
   	{
      		chargeRefreshTime = mpChargeRefreshTime;
      		chargeAmount = mpChargeAmount;
   	}
   	
   	if (IsImmobile())
      		bAlwaysRelevant = True;
	
   	lastChargeTime = -chargeRefreshTime;
}

// ----------------------------------------------------------------------
// StandStill()
// ----------------------------------------------------------------------

function StandStill()
{
	GotoState('Idle', 'Idle');
	Acceleration = Vect(0, 0, 0);
}

// ----------------------------------------------------------------------
// Frob()
//
// Invoke the Augmentation Upgrade 
// ----------------------------------------------------------------------
function Frob(Actor Frobber, Inventory frobWith)
{
	local VMDBufferPlayer VMP;
	local DeusExPlayer DXP;
	
	Super.Frob(Frobber, frobWith);
	
	DXP = DeusExPlayer(Frobber);
	VMP = VMDBufferPlayer(Frobber);
   	if (DXP == None)
	{
		return;
   	}
	
	//MADDERS: Stop us from being used if EMP'd.
	if (EMPHitPoints <= 0)
	{
		//MADDERS, 11/29/21: Also, give a message now.
		DXP.ClientMessage(MsgRepairbotEMPd);
		return;
	}
	
	//MADDERS: Use this if you want to use mutators with repair bots. Really weird, but hey. I've needed it before.
	DXP.ConsoleCommand("Mutate MutFunc01B");
   	
   	// DEUS_EX AMSD  In multiplayer, don't pop up the window, just use them
   	// In singleplayer, do the old thing.  
   	if (Level.NetMode == NM_Standalone)
   	{
		if ((VMP != None) && (VMP.bKillswitchEngaged) && (VMP.bImmersiveKillswitch))
		{
			if ((VMP.bCraftingSystemEnabled) && (VMP.SkillSystem != None) && (VMP.SkillSystem.GetSkillLevel(class'SkillTech') > 0))
			{
				VMDInvokeCraftingScreen(DeusExRootWindow(VMP.RootWindow));
			}
			else
			{
				DXP.ClientMessage(MsgRepairBotKillswitch);
			}
		}
		//MADDERS: Limit uses based on charges!
		else if (RechargeLeft > 0)
		{
      			ActivateRepairBotScreens(DXP);
		}
		else
		{
			if ((VMP != None) && (VMP.bCraftingSystemEnabled) && (VMP.SkillSystem != None) && (VMP.SkillSystem.GetSkillLevel(class'SkillTech') > 0))
			{
				VMDInvokeCraftingScreen(DeusExRootWindow(VMP.RootWindow));
			}
			else
			{
				DXP.ClientMessage(MsgRepairbotDepleted);
			}
		}
   	}
   	else
   	{
      		if (CanCharge())
      		{
			PlaySound(sound'PlasmaRifleReload', SLOT_None,,, 256);
         		ChargePlayer(DXP);
         		DXP.ClientMessage("Received Recharge");
      		}
      		else
      		{
         		DXP.ClientMessage("Repairbot still charging, "$int(chargeRefreshTime - (Level.TimeSeconds - lastChargetime))$" seconds to go.");
      		}
   	}
}

// ----------------------------------------------------------------------
// ActivateRepairBotScreens()
// ----------------------------------------------------------------------

simulated function ActivateRepairBotScreens(DeusExPlayer PlayerToDisplay)
{
	local DeusExRootWindow root;
	local HUDRechargeWindow winCharge;
	
   	root = DeusExRootWindow(PlayerToDisplay.rootWindow);
   	if (root != None)
   	{
      		winCharge = HUDRechargeWindow(root.InvokeUIScreen(Class'HUDRechargeWindow', True));
      		root.MaskBackground( True );
      		winCharge.SetRepairBot( Self );
   	}
}

// ----------------------------------------------------------------------
// ChargePlayer()
// DEUS_EX AMSD Moved back over here 
// ----------------------------------------------------------------------
function int ChargePlayer(DeusExPlayer PlayerToCharge)
{
	local int chargedPoints;
	local VMDBufferPlayer VMP;
	
	if (CanCharge())
	{
		VMP = VMDBufferPlayer(PlayerToCharge);
		
		//MADDERS: Cure HUD EMP!
		if (VMP != None)
		{
			VMP.VMDRegisterFoodEaten(0, "Repair Bot");
		 	VMP.HUDEMPTimer = 0;
		}
		chargedPoints = PlayerToCharge.ChargePlayer( Min(chargeAmount, RechargeLeft) );
		lastChargeTime = ChargeRefreshTime; //Level.TimeSeconds
		
		if (!bHubBot)
		{
			RechargeLeft -= ChargedPoints;
			
			//MADDERS: Turn off our ambient sound and movement if we're out of juice.
			if (RechargeLeft < 0)
			{
				StandStill();
				AmbientSound = None;
			}
		}
	}
   	return chargedPoints;
}

// ----------------------------------------------------------------------
// CanCharge()
// 
// Returns whether or not the bot can charge the player
// ----------------------------------------------------------------------

simulated function bool CanCharge()
{
	// (Level.TimeSeconds - int(lastChargeTime)) > chargeRefreshTime
	return ((GetRefreshTimeRemaining() <= 0.0)  && (RechargeLeft > 0));
}

// ----------------------------------------------------------------------
// GetRefreshTimeRemaining()
// ----------------------------------------------------------------------

simulated function Float GetRefreshTimeRemaining()
{
	return LastChargeTime;
	//return chargeRefreshTime - (Level.TimeSeconds - lastChargeTime);
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	//MADDERS, 5/29/22: This is now done in the player, fun fact. No "unrendered" time not counting.
	//if (LastChargeTime > 0) LastChargeTime -= DT;
}

// ----------------------------------------------------------------------
// GetAvailableCharge()
// ----------------------------------------------------------------------

simulated function Int GetAvailableCharge()
{
	if (CanCharge())
		return chargeAmount; 
	else
		return 0;
}

// ----------------------------------------------------------------------

function VMDInvokeCraftingScreen(DeusExRootWindow Root)
{
	local VMDMenuCraftingToolboxWindow CraftScreen;
	
	if (Root != None)
	{
		CraftScreen = VMDMenuCraftingToolboxWindow(Root.InvokeUIScreen(Class'VMDMenuCraftingToolboxWindow', False));
		CraftScreen.bHasRepairBot = true;
	}
}

defaultproperties
{
     //MADDERS: Finally getting past this frob display growing pains.
     FrobMsgPointsLeft="%s (%d Left)"
     FrobMsgEmpty="%s (Depleted)"
     FrobMsgUnlimited="%s (Unlimited)"
     FrobMsgCooldown="%s (Cooldown: %d)"
     
     //MADDERS additions
     MsgRepairbotEMPd="This repair bot has been fried, and is now useless."
     MsgRepairbotDepleted="The repair bot has fallen silent, its supplies now expended"
     MsgRepairbotKillswitch="Despite your instincts, you know recharging your reserves so heavily would be suicide"
     RechargeLeft=150
     HitboxArchetype="Roller"
     bInsignificant=True
     
     chargeAmount=75
     chargeRefreshTime=60
     mpChargeRefreshTime=30
     mpChargeAmount=100
     GroundSpeed=100.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=100.000000
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'TranscendedModels.TransRepairBot'
     SoundRadius=16
     SoundVolume=128
     AmbientSound=Sound'DeusExSounds.Robot.RepairBotMove'
     CollisionRadius=34.000000
     CollisionHeight=47.470001
     Mass=150.000000
     Buoyancy=97.000000
     BindName="RepairBot"
     FamiliarName="Repair Bot"
     UnfamiliarName="Repair Bot"
}
