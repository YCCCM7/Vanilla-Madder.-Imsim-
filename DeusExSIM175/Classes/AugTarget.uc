//=============================================================================
// AugTarget.
//=============================================================================
class AugTarget extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

// ----------------------------------------------------------------------------
// Network Replication
// ----------------------------------------------------------------------------

replication
{
   	//Server to client function replication
   	reliable if (Role == ROLE_Authority)
      		SetTargetingAugStatus;
}

state Active
{
	Begin:
   		SetTargetingAugStatus(CurrentLevel,True);
}

function Deactivate()
{
	Super.Deactivate();
	
   	SetTargetingAugStatus(CurrentLevel,False);
}

// ----------------------------------------------------------------------
// SetTargetingAugStatus()
// ----------------------------------------------------------------------

simulated function SetTargetingAugStatus(int Level, bool IsActive)
{
	DeusExRootWindow(Player.rootWindow).hud.augDisplay.bTargetActive = IsActive;
	DeusExRootWindow(Player.rootWindow).hud.augDisplay.targetLevel = Level;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
      		AugmentationLocation = LOC_Subdermal;
	}
}


function float VMDConfigureWepDamageMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	if (!DXW.bHandToHand && (!DXW.bInstantHit || DXW.bPenetrating))
 	{
  		return 1.0-LevelValues[CurrentLevel];
 	}
 	
 	return 1.0;
}

function float VMDConfigureWepAccuracyMod(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 0.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 0.0;
 	
 	return LevelValues[CurrentLevel];
}

defaultproperties
{
     mpAugValue=-0.125000
     mpEnergyDrain=40.000000
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconTarget'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconTarget_Small'
     AugmentationName="Targeting"
     Description="Image-scaling and recognition provided by multiplexing the optic nerve with doped polyacetylene 'quantum wires' not only increases accuracy, but also delivers limited situational info about a target.|n|nTECH ONE: Slight increase in accuracy, +5% damage, and general target information.|n|nTECH TWO: Additional increase in accuracy, +10% damage, and more target information.|n|nTECH THREE: Additional increase in accuracy, +15% damage, and specific target information.|n|nTECH FOUR: Additional increase in accuracy, +20% damage, and telescopic vision."
     MPInfo="When active, all weapon skills are effectively increased by one level, and you can see an enemy's health.  The skill increases allow you to effectively surpass skill level 3.  Energy Drain: Moderate"
     LevelValues(0)=-0.050000
     LevelValues(1)=-0.100000
     LevelValues(2)=-0.150000
     LevelValues(3)=-0.200000
     AugmentationLocation=LOC_Eye
     MPConflictSlot=4
}
