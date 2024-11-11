//=============================================================================
// AugStealth.
//=============================================================================
class AugStealth extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

state Active
{
Begin:
	//Player.RunSilentValue = Player.AugmentationSystem.GetAugLevelValue(class'AugStealth');
	//if ( Player.RunSilentValue == -1.0 )
		//Player.RunSilentValue = 1.0;
}

function Deactivate()
{
	//Player.RunSilentValue = 1.0;
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

function float VMDConfigureNoiseMult()
{
	//MADDERS, 4/23/22: New stealth aug, new rules. Always give silence, since that's what we want, but at differing costs.
	//Old values per level were (0.75, 0.5, 0.25, 0.0)
	return 0.0;
	
	//The necessary muscle movements for complete silence when walking or running are determined continuously with reactive kinematics equations produced by embedded nanocomputers.|n|nTECH ONE: Sound made while moving is reduced by 25%.|n|nTECH TWO: Sound made while moving is reduced by 50%.|n|nTECH THREE: Sound made while moving is reduced by 75%.|n|nTECH FOUR: An agent is completely silent, at 100% noise reduction."
	
 	//return LevelValues[CurrentLevel];
}

function float GetEnergyRate()
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
     AdvancedDescription="The necessary muscle movements for complete silence when walking or running are determined continuously with reactive kinematics equations produced by embedded nanocomputers."
     AdvancedDescLevels(0)="TECH ONE: Silent movement costs %d units per minute."
     AdvancedDescLevels(1)="TECH TWO: Silent movement costs %d units per minute."
     AdvancedDescLevels(2)="TECH THREE: Silent movement costs %d units per minute."
     AdvancedDescLevels(3)="TECH FOUR: Silent movement costs a mere %d units per minute."
     
     mpEnergyDrain=20.000000
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconRunSilent'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconRunSilent_Small'
     AugmentationName="Run Silent"
     Description="The necessary muscle movements for complete silence when walking or running are determined continuously with reactive kinematics equations produced by embedded nanocomputers.|n|nTECH ONE: Sound made while falling, walking, and running is eliminated, but at 120 energy units per minute.|n|nTECH TWO: Silent movement now costs 90 energy units per minute.|n|nTECH THREE: Silent movement now costs 60 energy units per minute.|n|nTECH FOUR: Silent movement now costs a mere 40 units per minute."
     MPInfo="When active, you do not make footstep sounds.  Energy Drain: Low"
     LevelValues(0)=3.000000
     LevelValues(1)=2.250000
     LevelValues(2)=1.500000
     LevelValues(3)=1.000000
     AugmentationLocation=LOC_Leg
     MPConflictSlot=8
}
