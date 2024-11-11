//=============================================================================
// AugMechSpeed.
//=============================================================================
class AugMechSpeed extends VMDMechAugmentation;

state Active
{
Begin:
}

function float VMDConfigureSpeedMult(bool bWater)
{
 	if (!bWater) return LevelValues[CurrentLevel];
 	return 1.0;
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 1.0) * 100) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Artificial leg prosthesis that allows the user to run at incredible speeds."
     AdvancedDescLevels(0)="TECH ONE: Speed and jumping are increased by %d%%, while falling damage is reduced."
     MaxLevel=0
     
     EnergyRate=80.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconSpeedJump'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconSpeedJump_Small'
     AugmentationName="Sprint Enhancement"
     LevelValues(0)=1.750000
     AugmentationLocation=LOC_Leg
}
