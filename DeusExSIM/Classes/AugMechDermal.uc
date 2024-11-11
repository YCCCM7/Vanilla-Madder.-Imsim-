//=============================================================================
// AugMechDermal.
//=============================================================================
class AugMechDermal extends VMDMechAugmentation;

state Active
{
Begin:
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	local float Ret;
	
	Ret = 1.0;
	switch(DT)
	{
		case 'Shot':
		case 'Autoshot':
		case 'KnockedOut':
		case 'Burned':
		case 'Exploded':
			Ret = LevelValues[CurrentLevel];
		break;
		
		case 'Sabot':
			Ret = (LevelValues[CurrentLevel] + 1.0) / 2;
		break;
		
		case 'Stunned':
		case 'Flamed':
			if (VMBP != None)
			{
				Ret = 0.0;
			}
			else
			{
				Ret = LevelValues[CurrentLevel];
			}
		break;
	}
	
 	return Ret;
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
     AdvancedDescription="Dermal armor placed beneath the epidermis of the body."
     AdvancedDescLevels(0)="TECH ONE: Damage from ballistic, melee, and energy-based sources is reduced by %d%%."
     AdvancedDescLevels(1)="TECH TWO: Damage from ballistic, melee, and energy-based sources is reduced by %d%%."
     AdvancedDescLevels(2)="TECH THREE: Damage from ballistic, melee, and energy-based sources is reduced by %d%%."
     MaxLevel=2
     
     EnergyRate=60.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconBallistic'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconBallistic_Small'
     AugmentationName="Dermal Armor"
     LevelValues(0)=0.850000
     LevelValues(1)=0.700000
     LevelValues(2)=0.550000
     AugmentationLocation=LOC_Subdermal
}
