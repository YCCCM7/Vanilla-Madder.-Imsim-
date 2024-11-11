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

function Activate()
{
	Super.Activate();
	
	if ((VMBP != None) && (VMBP.IsInState('RubbingEyes')))
	{
		VMBP.GoToState('RubbingEyes', 'RubEnd');
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
      		AugmentationLocation = LOC_Subdermal;
	}
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	//MADDERS, 12/27/23: Stop cheesy stuns with this aug sometimes.
	if ((VMBP != None) && (DT == 'TearGas' || DT == 'HalonGas' || DT == 'OwnedHalonGas'))
	{
		return 0.0;
	}
	
 	switch(DT)
 	{
  		case 'TearGas':
  		case 'PoisonGas':
		case 'DrugDamage':
  		case 'Radiation':
  		case 'HalonGas':
		case 'OwnedHalonGas':
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

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((1.0 - LevelValues[i]) * 100) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     AdvancedDescription="Induced keratin production strengthens all epithelial tissues and reduces the agent's vulnerability to radiation and other toxins."
     AdvancedDescLevels(0)="TECH ONE: Toxic damage is reduced by %d%%."
     AdvancedDescLevels(1)="TECH TWO: Toxic damage is reduced by %d%%."
     AdvancedDescLevels(2)="TECH THREE: Toxic damage is reduced by %d%%."
     AdvancedDescLevels(3)="TECH FOUR: An agent is nearly invulnerable to damage from toxins, at %d%% reduction."
     
     mpAugValue=0.100000
     mpEnergyDrain=20.000000
     EnergyRate=20.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconEnviro'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconEnviro_Small'
     AugmentationName="Environmental Resistance"
     Description="Induced keratin production strengthens all epithelial tissues and reduces the agent's vulnerability to radiation and other toxins.|n|nTECH ONE: Toxic damage is reduced by 25%.|n|nTECH TWO: Toxic damage is reduced by 50%.|n|nTECH THREE: Toxic damage is reduced by 75%.|n|nTECH FOUR: An agent is nearly invulnerable to damage from toxins, at 90% reduction."
     MPInfo="When active, you only take 10% damage from poison and gas, and poison and gas will not affect your vision.  Energy Drain: Low"
     LevelValues(0)=0.60000
     LevelValues(1)=0.400000
     LevelValues(2)=0.200000
     LevelValues(3)=0.100000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=3
}
