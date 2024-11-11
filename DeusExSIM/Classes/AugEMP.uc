//=============================================================================
// AugEMP.
//=============================================================================
class AugEMP extends VMDBufferAugmentation;

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
	}
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	//MADDERS: Shock is also now stopped by EMP shield because daddy plz
 	switch(DT)
	{
		case 'EMP':
		case 'Shocked':
		case 'Nanovirus':
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
     AdvancedDescription="Nanoscale EMP shielding partially protects individual nanites and converts incoming pulses, defending against EMP, radio scrambler, and electrical attacks while also producing bio energy."
     AdvancedDescLevels(0)="TECH ONE: %d%% of damage is converted to bio energy."
     AdvancedDescLevels(1)="TECH TWO: %d%% of damage is converted to bio energy."
     AdvancedDescLevels(2)="TECH THREE: %d%% of damage is converted to bio energy."
     AdvancedDescLevels(3)="TECH FOUR: An agent is completely immune to electrical attacks, with %d%% damage conversion."
     
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     bSenselessBind=True //Why would you NOT want this?
     
     mpAugValue=0.050000
     mpEnergyDrain=5.000000
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconEMP'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconEMP_Small'
     AugmentationName="EMP Shield"
     Description="Nanoscale EMP shielding partially protects individual nanites and converts incoming pulses, defending against EMP, radio scrambler, and electrical attacks while also producing bio energy.|n|nTECH ONE: 25% of damage is converted to bio energy.|n|nTECH TWO: 50% of damage is converted to bio energy.|n|nTECH THREE: 75% of damage is converted to bio energy.|n|nTECH FOUR: 100% of damage is converted to bio energy."
     MPInfo="When active, you only take 5% damage from EMP attacks.  Energy Drain: Very Low"
     LevelValues(0)=0.750000
     LevelValues(1)=0.500000
     LevelValues(2)=0.250000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=3
}
