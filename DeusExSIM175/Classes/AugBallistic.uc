//=============================================================================
// AugBallistic.
//=============================================================================
class AugBallistic extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

function Tick(float DT)
{
 	Super.Tick(DT);
 	
 	//if (!bIsActive) Activate();
}

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

//------------------------------------------
//MADDERS: Allow for more dynamic configuration of aug bonuses. Yeet.
//------------------------------------------
function float VMDConfigureDamageMult(name DT)
{
 	if ((DT == 'Shot') || (DT == 'Autoshot')) return LevelValues[CurrentLevel];
 	
 	return 1.0;
}

function VMDSignalDamageTaken(int Damage, name DamageType, Vector HitLocation, bool bCheckOnly)
{
	//MADDERS: Now charged pickups operate by damage taken, and we operate latently again.
 	/*if ((Damage/2 > 0) && ((DamageType == 'Shot') || (DamageType == 'Autoshot')))
 	{
  		Player.Energy -= Damage / 2;
 	}*/
}

defaultproperties
{
     mpAugValue=0.600000
     mpEnergyDrain=90.000000
     EnergyRate=60.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconBallistic'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconBallistic_Small'
     AugmentationName="Ballistic Protection"
     Description="Monomolecular plates reinforce the skin's epithelial membrane, reducing the damage an agent receives from projectiles and bladed weapons.|n|nTECH ONE: Damage from projectiles and bladed weapons is reduced by 20%.|n|nTECH TWO: Damage from projectiles and bladed weapons is reduced by 35%.|n|nTECH THREE: Damage from projectiles and bladed weapons is reduced by 50%.|n|nTECH FOUR: An agent is highly resistant to damage from projectiles and bladed weapons, at 65% reduction."
     MPInfo="When active, damage from projectiles and melee weapons is reduced by 40%.  Energy Drain: High"
     LevelValues(0)=0.800000
     LevelValues(1)=0.650000
     LevelValues(2)=0.500000
     LevelValues(3)=0.350000
     AugmentationLocation=LOC_Subdermal
     MPConflictSlot=4
}
