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
	
	// check to see if the player is carrying something too heavy for him
	if (Player.CarriedDecoration != None)
		if (!Player.CanBeLifted(Player.CarriedDecoration))
			Player.DropDecoration();
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
	
	if (Player != None)
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
	
	return 0.0;
}

function float VMDConfigurePushMult()
{
	return LevelValues[CurrentLevel]*2;
}

function float VMDConfigureDecoThrowMult()
{
	return (CurrentLevel+2.0);
}

function float VMDConfigureLiftMult()
{
	return LevelValues[CurrentLevel];
}

defaultproperties
{
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
