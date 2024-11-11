//=============================================================================
// AugMechEnergy.
//=============================================================================
class AugMechEnergy extends VMDMechAugmentation;

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
		case 'Burned':
		case 'Exploded':
			Ret = LevelValues[CurrentLevel];
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
     AdvancedDescription="A tempered layer in addition to the user's dermal armor that increases resistance to energy attacks greatly."
     AdvancedDescLevels(0)="TECH ONE: Damage from energy-based sources is reduced by %d%%."
     MaxLevel=0
     
     EnergyRate=60.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconBallistic'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconBallistic_Small'
     AugmentationName="Dermal Tempering"
     LevelValues(0)=0.250000
     AugmentationLocation=LOC_Subdermal
}
