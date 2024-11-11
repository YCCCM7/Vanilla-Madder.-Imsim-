//=============================================================================
// AugMuscle.
//=============================================================================
class AugMuscle extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

function Tick(float DT)
{
 	Super.Tick(DT);
 	
 	//if (!bIsActive) Activate();
}

state Active
{
Begin:
}

function Deactivate()
{
	Super.Deactivate();
	
	if (Player != None)
	{
		// check to see if the player is carrying something too heavy for him
		if (Player.CarriedDecoration != None)
		{
			if (!Player.CanBeLifted(Player.CarriedDecoration))
			{
				Player.DropDecoration();
			}
		}
		else if ((VMDPOVDeco(Player.InHand) != None) && (VMDBufferPlayer(Player) != None))
		{
			if (!VMDBufferPlayer(Player).CanPOVBeLifted(VMDPOVDeco(Player.InHand)))
			{
				Player.DropDecoration();
			}
		}
	}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
      		//Lift with your legs, not with your back.
      		AugmentationLocation = LOC_Leg;
	}
}

//MADDERS: Cost energy only when lifting!
simulated function float GetEnergyRate()
{
	local DeusExWeapon DXw;
	
	//MADDERS, 7/9/23: Just don't consume energy. We're buffing muscle aug this way by making it passive. Who will really cry?
	return 0.0;
	
	/*if (Player != None)
	{
		if ((Player.CarriedDecoration != None) && (Player.CarriedDecoration.Mass > 50))
		{
			return EnergyRate;
		}
		DXW = DeusExWeapon(Player.InHand);
		if ((DXW != None) && (DXW.Mass > 30))
		{
			return EnergyRate;
		}
	}
	
	//MADDERS, 1/9/21: List our energy usage transparently in the augs screen.
	if (((Level != None) && (Level.Pauser != "")) || ((Player != None) && (MedicalBot(Player.FrobTarget) != None)))
	{
		return EnergyRate;
	}
	
	return 0.0;*/
}


function float VMDConfigureDecoPushMult()
{
 	return LevelValues[CurrentLevel]*2;
}

function float VMDConfigureDecoThrowMult()
{
	return (CurrentLevel+2.0) / 2.0;
}

function float VMDConfigureDecoLiftMult()
{
	return LevelValues[CurrentLevel];
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 1.0) * 100) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     AdvancedDescription="Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects, as well as move more fluidly with heavy weapons."
     AdvancedDescLevels(0)="TECH ONE: Strength is increased slightly, at %d%% more lifting strength."
     AdvancedDescLevels(1)="TECH TWO: Strength is increased moderately, at %d%% more lifting strength."
     AdvancedDescLevels(2)="TECH THREE: Strength is increased significantly, at %d%% more lifting strength."
     AdvancedDescLevels(3)="TECH FOUR: An agent is inhumanly strong, at %d%% more lifting strength."
     
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     
     mpAugValue=2.000000
     mpEnergyDrain=20.000000
     EnergyRate=20.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconMuscle'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconMuscle_Small'
     AugmentationName="Microfibral Muscle"
     Description="Muscle strength is amplified with ionic polymeric gel myofibrils that allow the agent to push and lift extraordinarily heavy objects, including movement with heavy weapons.|n|nTECH ONE: Strength is increased slightly, at 50% more lifting strength.|n|nTECH TWO: Strength is increased moderately, at 100% more lifting strength.|n|nTECH THREE: Strength is increased significantly, at 150% more lifting strength.|n|nTECH FOUR: An agent is inhumanly strong, at 200% more lifting strength."
     MPInfo="When active, you can pick up large crates.  Energy Drain: Low"
     LevelValues(0)=1.500000
     LevelValues(1)=2.000000
     LevelValues(2)=2.500000
     LevelValues(3)=3.000000
     AugmentationLocation=LOC_Arm
     MPConflictSlot=8
}
