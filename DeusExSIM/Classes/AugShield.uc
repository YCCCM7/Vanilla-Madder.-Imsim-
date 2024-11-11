//=============================================================================
// AugShield.
//=============================================================================
class AugShield extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

/*function Tick(float DT)
{
 	Super.Tick(DT);
 	
 	if (!bIsActive) Activate();
}*/

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
      		AugmentationLocation = LOC_Arm;
	}
}

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	//MADDERS, 12/27/23: Stop cheesy stuns with this aug sometimes.
	if ((VMBP != None) && (DT == 'Stunned' || DT == 'Flamed'))
	{
		return 0.0;
	}
	
 	switch(DT)
 	{
  		case 'Burned':
  		case 'Flamed':
  		case 'Exploded':
		
		//MADDERS, 6/2/23: Now energy shield reduces taser duration. Yay.
		case 'Stunned':
		
		//MADDERS: Shock damage has been moved to EMP shield, so it has more use.
		//We're still pretty damned good without it.
  		//case 'Shocked':
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
     AdvancedDescription="Polyanilene capacitors below the skin absorb heat and electricity, reducing the damage received from flame, taser, explosive, and plasma attacks."
     AdvancedDescLevels(0)="TECH ONE: Damage from energy attacks is reduced by %d%%."
     AdvancedDescLevels(1)="TECH TWO: Damage from energy attacks is reduced by %d%%."
     AdvancedDescLevels(2)="TECH THREE: Damage from energy attacks is reduced by %d%%."
     AdvancedDescLevels(3)="TECH FOUR: An agent is nearly invulnerable to damage from energy attacks, at an %d%% reduction."
     
     mpAugValue=0.500000
     mpEnergyDrain=25.000000
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconShield'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconShield_Small'
     AugmentationName="Energy Shield"
     Description="Polyanilene capacitors below the skin absorb heat and electricity, reducing the damage received from flame, taser, explosive, and plasma attacks.|n|nTECH ONE: Damage from energy attacks is reduced by 20%.|n|nTECH TWO: Damage from energy attacks is reduced by 40%.|n|nTECH THREE: Damage from energy attacks is reduced by 60%.|n|nTECH FOUR: An agent is nearly invulnerable to damage from energy attacks, at an 80% reduction."
     MPInfo="When active, you only take 50% damage from flame and plasma attacks.  Energy Drain: Low"
     LevelValues(0)=0.650000
     LevelValues(1)=0.500000
     LevelValues(2)=0.350000
     LevelValues(3)=0.200000
     AugmentationLocation=LOC_Subdermal
     MPConflictSlot=1
}
