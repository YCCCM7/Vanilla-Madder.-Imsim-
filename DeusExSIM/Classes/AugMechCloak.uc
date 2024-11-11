//=============================================================================
// AugMechCloak.
//=============================================================================
class AugMechCloak extends VMDMechAugmentation;

state Active
{
Begin:
}

simulated function float GetEnergyRate()
{
	return energyRate * LevelValues[CurrentLevel];
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int((EnergyRate * LevelValues[i]) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Induction wiring that bends light around the user."
     AdvancedDescLevels(0)="TECH ONE: Power drain is normal, at %d units per minute."
     AdvancedDescLevels(1)="TECH TWO: Power drain is reduced slightly, at %d units per minute."
     AdvancedDescLevels(2)="TECH THREE: Power drain is reduced moderately, at %d units per minute."
     MaxLevel=2
     
     EnergyRate=500.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconCloak'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconCloak_Small'
     AugmentationName="Glass-Shield Cloaking System"
     LevelValues(0)=1.000000
     LevelValues(1)=0.600000
     LevelValues(2)=0.400000
     AugmentationLocation=LOC_Subdermal
}
