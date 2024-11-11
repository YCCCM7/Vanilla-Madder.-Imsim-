//=============================================================================
// AugMechEMP.
//=============================================================================
class AugMechEMP extends VMDMechAugmentation;

state Active
{
Begin:
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	//MADDERS: Shock is also now stopped by EMP shield because daddy plz
 	switch(DT)
	{
		case 'EMP':
		case 'Shocked':
		case 'NanoVirus':
			return LevelValues[CurrentLevel];
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
     AdvancedDescription="An extra layer of hardened armor allows for a higher innate resistance to EMP attacks."
     AdvancedDescLevels(0)="TECH ONE: %d%% of damage is converted to bio energy."
     MaxLevel=0
     
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     bSenselessBind=True //Why would you NOT want this?
     
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconEMP'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconEMP_Small'
     AugmentationName="EMP Shielding"
     LevelValues(0)=0.750000
     AugmentationLocation=LOC_Torso
}
