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
function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
 	if ((DT == 'Shot') || (DT == 'Autoshot')) return LevelValues[CurrentLevel];
	if ((DT == 'Sabot') || (DT == 'KnockedOut')) return (LevelValues[CurrentLevel] + 1.0) / 2;
 	
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
     AdvancedDescription="Monomolecular plates reinforce the skin's epithelial membrane, reducing the damage an agent receives from projectiles and bladed weapons."
     AdvancedDescLevels(0)="TECH ONE: Damage from projectiles and bladed weapons is reduced by %d%%."
     AdvancedDescLevels(1)="TECH TWO: Damage from projectiles and bladed weapons is reduced by %d%%."
     AdvancedDescLevels(2)="TECH THREE: Damage from projectiles and bladed weapons is reduced by %d%%."
     AdvancedDescLevels(3)="TECH FOUR: An agent is highly resistant to damage from projectiles and bladed weapons, at %d%% reduction."
     
     mpAugValue=0.600000
     mpEnergyDrain=90.000000
     EnergyRate=60.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconBallistic'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconBallistic_Small'
     AugmentationName="Ballistic Protection"
     Description="Monomolecular plates reinforce the skin's epithelial membrane, reducing the damage an agent receives from projectiles and bladed weapons.|n|nTECH ONE: Damage from projectiles and bladed weapons is reduced by 20%.|n|nTECH TWO: Damage from projectiles and bladed weapons is reduced by 35%.|n|nTECH THREE: Damage from projectiles and bladed weapons is reduced by 50%.|n|nTECH FOUR: An agent is highly resistant to damage from projectiles and bladed weapons, at 65% reduction."
     MPInfo="When active, damage from projectiles and melee weapons is reduced by 40%.  Energy Drain: High"
     LevelValues(0)=0.600000
     LevelValues(1)=0.500000
     LevelValues(2)=0.400000
     LevelValues(3)=0.300000
     AugmentationLocation=LOC_Subdermal
     MPConflictSlot=4
}
