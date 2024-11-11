//=============================================================================
// AugEnviro.
//=============================================================================
class AugEnviro extends VMDBufferAugmentation;

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
      		AugmentationLocation = LOC_Subdermal;
	}
}

function float VMDConfigureDamageMult(name DT)
{
 	switch(DT)
 	{
  		case 'TearGas':
  		case 'PoisonGas':
		case 'DrugDamage':
  		case 'Radiation':
  		case 'HalonGas':
  		case 'PoisonEffect':
  		case 'Poison':
   			return LevelValues[CurrentLevel];
  		break;
  		default:
   			return 1.0;
  		break;
 	}
 	return 1.0;
}

defaultproperties
{
     mpAugValue=0.100000
     mpEnergyDrain=20.000000
     EnergyRate=20.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconEnviro'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconEnviro_Small'
     AugmentationName="Environmental Resistance"
     Description="Induced keratin production strengthens all epithelial tissues and reduces the agent's vulnerability to radiation and other toxins.|n|nTECH ONE: Toxic damage is reduced by 25%.|n|nTECH TWO: Toxic damage is reduced by 50%.|n|nTECH THREE: Toxic damage is reduced by 75%.|n|nTECH FOUR: An agent is nearly invulnerable to damage from toxins, at 90% reduction."
     MPInfo="When active, you only take 10% damage from poison and gas, and poison and gas will not affect your vision.  Energy Drain: Low"
     LevelValues(0)=0.750000
     LevelValues(1)=0.500000
     LevelValues(2)=0.250000
     LevelValues(3)=0.100000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=3
}
