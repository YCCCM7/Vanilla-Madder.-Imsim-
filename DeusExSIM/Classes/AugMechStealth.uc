//=============================================================================
// AugMechStealth.
//=============================================================================
class AugMechStealth extends VMDBufferAugmentation;

state Active
{
Begin:
}

function float VMDConfigureNoiseMult()
{
	return 0.0;
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
     AdvancedDescription="Artificial leg prosthesis that allows for silent running."
     AdvancedDescLevels(0)="TECH ONE: Silent movement costs %d units per minute."
     MaxLevel=0
     
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconRunSilent'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconRunSilent_Small'
     AugmentationName="Stealth Enhancement"
     LevelValues(0)=1.000000
     AugmentationLocation=LOC_Leg
}
