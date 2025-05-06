//=============================================================================
// MedicalBot.
//=============================================================================
class MedicalBot extends Robot;

var int healAmount;
var int healRefreshTime;
var int mphealRefreshTime;
var Float lastHealTime;

//MADDERS: Limit recharges!
var int HealingLeft;
var(VMD) bool bHubBot; //Don't consume charges if true.
var localized string MsgMedbotDepleted, MsgRechargedBot, MsgMedbotEMPd,
			FrobMsgUnlimited, FrobMsgCooldown, FrobMsgEmpty, FrobMsgPointsLeft;

// ----------------------------------------------------------------------
// Network replication
// ----------------------------------------------------------------------
replication
{
	// MBCODE: Replicate the last time healed to the server
	reliable if ( Role < ROLE_Authority )
		lastHealTime, healRefreshTime;
}

function string VMDGetDisplayName(string InName)
{
	if (bHubBot)
	{
		if (LastHealTime > 0)
		{
			InName = SprintF(FrobMsgCooldown, InName, int(LastHealTime));
		}
		else
		{
			InName = SprintF(FrobMsgUnlimited, InName);
		}
	}
	else
	{
		if (HealingLeft <= 0)
		{
			InName = SprintF(FrobMsgEmpty, InName);
		}
		else if (LastHealTime > 0)
		{
			InName = SprintF(FrobMsgCooldown, InName, int(LastHealTime));
		}
		else
		{
			InName = SprintF(FrobMsgPointsLeft, InName, HealingLeft);
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
		if ((SP != None) && (SP.GetPawnAllianceType(TPlayer) == ALLIANCE_Hostile) && (VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant))
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
function ApplySpecialStats()
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
      		healRefreshTime = mpHealRefreshTime;
		bHubBot = true;
   	}
	
   	if (IsImmobile())
      		bAlwaysRelevant = True;
	
	lastHealTime = -healRefreshTime;
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
   	local DeusExPlayer player;
	local DeusExRootWindow root;
	local HUDMedBotAddAugsScreen winAug;
	local HUDMedBotHealthScreen  winHealth;
	local AugmentationCannister augCan;
	local VMDBufferPlayer VMP;
	
   	Super.Frob(Frobber, frobWith);
   	
   	player = DeusExPlayer(Frobber);
	VMP = VMDBufferPlayer(Frobber);
	
   	if (Player == None || Level == None)
      		return;
   	
	//MADDERS: Stop us from being used if EMP'd.
	if (EMPHitPoints <= 0)
	{
		//MADDERS, 11/29/21: Also, give a message now.
		Player.ClientMessage(MsgMedbotEMPd);
		return;
	}
	
	//MADDERS: Use this if you want to use mutators with medbots. Really weird, but hey. I've needed it before.
	Player.ConsoleCommand("Mutate MutFunc01A");
	
   	// DEUS_EX AMSD  In multiplayer, don't pop up the window, just use them
   	// In singleplayer, do the old thing.  
   	if (Level.NetMode == NM_Standalone)
   	{
      		root = DeusExRootWindow(player.rootWindow);
      		if (root != None)
      		{
        		// First check to see if the player has any augmentation cannisters.
        		// If so, then we'll pull up the Add Augmentations screen.  
        		// Otherwise pull up the Health screen first.
        		
        		augCan = AugmentationCannister(player.FindInventoryType(Class'AugmentationCannister'));
        		
        		if (augCan != None)
        		{
           			winAug = HUDMedBotAddAugsScreen(root.InvokeUIScreen(Class'HUDMedBotAddAugsScreen', True));
           			winAug.SetMedicalBot(Self, True);
        		}
        		else
        		{
           			winHealth = HUDMedBotHealthScreen(root.InvokeUIScreen(Class'HUDMedBotHealthScreen', True));
          			winHealth.SetMedicalBot(Self, True);
        		}
        		root.MaskBackground(True);
      		}
   	}
   	else
   	{
     		if (CanHeal())
      		{
			if (Level.NetMode != NM_Standalone)
			{
				PlaySound(sound'MedicalHiss', SLOT_None,,, 256);
				Player.StopPoison();
				Player.ExtinguishFire();
				Player.drugEffectTimer = 0;
			}
         		HealPlayer(Player);
      		}
      		else
      		{
			if (HealingLeft > 0)
			{
				Player.ClientMessage("Medbot still charging, "$int(healRefreshTime - (Level.TimeSeconds - lastHealTime))$" seconds to go.");
			}
			else
			{
				if ((VMP != None) && (VMP.CanCraftMedical(True, True)))
				{
					VMDInvokeCraftingScreen(DeusExRootWindow(VMP.RootWindow));
				}
				else if (VMP != None)
				{
					VMP.ClientMessage(MsgMedbotDepleted);
				}
			}
      		}
   	}   
}

// ----------------------------------------------------------------------
// HealPlayer()
// ----------------------------------------------------------------------

function int HealPlayer(DeusExPlayer player)
{
	local int healedPoints;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (player != None)
	{
		//MADDERS, 1/12/21: To stop bombing the health window message log.
		if (VMP != None) VMP.VMDRegisterFoodEaten(0, "Medbot");
		
		healedPoints = player.HealPlayer(Min(HealingLeft, healAmount));
		lastHealTime = HealRefreshTime; //Level.TimeSeconds;
		
		if (VMP != None)
		{
			VMP.VMDModPlayerStress(-1000,,,true);
			
			if (!bHubBot)
			{
				//MADDERS: The relevant augment reduces healing used.
				//Update, 7/9/20: These two augments are now merged, because they're too specialized.
				if (VMP.HasSkillAugment('MedicineWraparound')) HealingLeft -= HealedPoints;
				else HealingLeft -= HealAmount;
				
				//MADDERS: Turn off our ambient sound and movement if we're out of juice.
				if (HealingLeft < 0)
				{
					StandStill();
					AmbientSound = None;
				}
			}
		}
		else
		{
			HealingLeft -= HealAmount;
		}
		
		Player.StopPoison();
		Player.DrugEffectTimer = 0;
	}
	return healedPoints;
}


// ----------------------------------------------------------------------
// ChargeBot()
// ----------------------------------------------------------------------

function ChargeBot(DeusExPlayer Charger, int RechargePoints)
{
	if (RechargePoints > 0)
	{
		if (Charger != None) Charger.ClientMessage(SprintF(MsgRechargedBot, RechargePoints));
		HealingLeft += RechargePoints;
		if (AmbientSound == None)
		{
			AmbientSound = Sound'MedicalBotMove';
		}
	}
}

// ----------------------------------------------------------------------
// CanHeal()
// 
// Returns whether or not the bot can heal the player
// ----------------------------------------------------------------------

function bool CanHeal()
{
	//Level.TimeSeconds - lastHealTime > healRefreshTime
	return ((GetRefreshTimeRemaining() <= 0.0) && (HealingLeft > 0));
}

// ----------------------------------------------------------------------
// GetRefreshTimeRemaining()
// ----------------------------------------------------------------------

function Float GetRefreshTimeRemaining()
{
	return LastHealTime;
	//return healRefreshTime - (Level.TimeSeconds - lastHealTime);
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	//MADDERS, 5/29/22: This is now done in the player, fun fact. No "unrendered" time not counting.
	//if (LastHealTime > 0) LastHealTime -= DT;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function VMDInvokeCraftingScreen(DeusExRootWindow Root)
{
	local VMDMenuCraftingChemistrySetWindow CraftScreen;
	
	if (Root != None)
	{
		CraftScreen = VMDMenuCraftingChemistrySetWindow(Root.InvokeUIScreen(Class'VMDMenuCraftingChemistrySetWindow', True));
		CraftScreen.bHasMedbot = true;
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
     MsgMedbotEMPd="This medical bot has been fried, and is now useless."
     MsgMedbotDepleted="The medbot has fallen silent, its supplies now expended."
     MsgRechargedBot="%d points added to medbot's remaining healing."
     HealingLeft=600
     HitboxArchetype="Roller"
     bInsignificant=True
     
     healAmount=300
     healRefreshTime=60
     mphealRefreshTime=30
     WalkingSpeed=0.200000
     GroundSpeed=200.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=500.000000
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'TranscendedModels.TransMedicalBot'
     SoundRadius=16
     SoundVolume=128
     AmbientSound=Sound'DeusExSounds.Robot.MedicalBotMove'
     CollisionRadius=25.000000
     CollisionHeight=36.310001
     Buoyancy=97.000000
     BindName="MedicalBot"
     FamiliarName="Medical Bot"
     UnfamiliarName="Medical Bot"
}
