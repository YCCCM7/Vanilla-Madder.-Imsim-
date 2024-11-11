//=============================================================================
// AugMechEnviro.
//=============================================================================
class AugMechEnviro extends VMDMechAugmentation;

state Active
{
Begin:
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	//MADDERS, 12/27/23: 
	if ((VMBP != None) && (DT == 'TearGas' || DT == 'HalonGas' || DT == 'OwnedHalonGas'))
	{
		return 0.0;
	}
	
 	switch(DT)
 	{
  		case 'TearGas':
  		case 'PoisonGas':
		case 'DrugDamage':
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
     AdvancedDescription="An implanted chest augmentation that filters out airborne toxins."
     AdvancedDescLevels(0)="TECH ONE: Toxic damage is reduced by %d%%."
     AdvancedDescLevels(1)="TECH TWO: Toxic damage is reduced by %d%%."
     MaxLevel=1
     
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     bSenselessBind=True
     
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconEnviro'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconEnviro_Small'
     AugmentationName="Implanted Rebreather"
     LevelValues(0)=0.750000
     LevelValues(1)=0.500000
     AugmentationLocation=LOC_Torso
}
