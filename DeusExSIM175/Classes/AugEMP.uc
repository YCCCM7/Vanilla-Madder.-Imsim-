//=============================================================================
// AugEMP.
//=============================================================================
class AugEMP extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

state Active
{
Begin:
}

function Deactivate()
{
	Super.Deactivate();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
	}
}

function float VMDConfigureDamageMult(name DT)
{
	//MADDERS: Shock is also now stopped by EMP shield because daddy plz
 	switch(DT)
	{
		case 'EMP':
		case 'Shocked':
			return LevelValues[CurrentLevel];
		break;
	}
 	return 1.0;
}

defaultproperties
{
     mpAugValue=0.050000
     mpEnergyDrain=5.000000
     EnergyRate=10.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconEMP'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconEMP_Small'
     AugmentationName="EMP Shield"
     Description="Nanoscale EMP shielding partially protects individual nanites and reduce bioelectrical drain by canceling incoming pulses, defending against both EMP and broader electrical attacks.|n|nTECH ONE: Damage from electrical attacks is reduced by 25%.|n|nTECH TWO: Damage from electrical attacks is reduced by 50%.|n|nTECH THREE: Damage from electrical attacks is reduced by 75%.|n|nTECH FOUR: An agent is completely invulnerable to damage from electrical attacks."
     MPInfo="When active, you only take 5% damage from EMP attacks.  Energy Drain: Very Low"
     LevelValues(0)=0.750000
     LevelValues(1)=0.500000
     LevelValues(2)=0.250000
     AugmentationLocation=LOC_Subdermal
     MPConflictSlot=3
}
