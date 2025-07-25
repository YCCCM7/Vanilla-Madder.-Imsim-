//=============================================================================
// AugCombat.
//=============================================================================
class AugCombat extends VMDBufferAugmentation;

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
	}
}

//------------------------------------------
//MADDERS: Allow for more dynamic configuration of aug bonuses. Yeet.
//------------------------------------------
function float VMDConfigureWepDamageMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	if (DXW.bHandToHand || (DXW.bInstantHit && !DXW.bPenetrating))
 	{
  		return LevelValues[CurrentLevel];
 	}
 	
 	return 1.0;
}

function float VMDConfigureWepVelocityMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	if (DXW.bHandToHand || (DXW.bInstantHit && !DXW.bPenetrating))
 	{
  		return LevelValues[CurrentLevel];
 	}
 	
 	return 1.0;
}

function float VMDConfigureWepSwingSpeedMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	if ((DXW.bHandToHand && TSkill == class'SkillWeaponLowTech') || (DXW.bInstantHit && !DXW.bPenetrating))
 	{
  		return Sqrt(LevelValues[CurrentLevel]);
 	}
 	return 1.0;
}

defaultproperties
{
     mpAugValue=2.000000
     mpEnergyDrain=20.000000
     EnergyRate=20.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconCombat'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconCombat_Small'
     AugmentationName="Combat Strength"
     Description="Sorting rotors accelerate calcium ion concentration in the sarcoplasmic reticulum, increasing an agent's muscle speed several-fold and multiplying the damage they inflict in melee combat.|n|nTECH ONE: Damage with melee weapons is increased by 25%, and swing speed by 12%.|n|nTECH TWO: Damage with melee weapons is increased by 50%, and swing speed by 22%.|n|nTECH THREE: Damage with  melee weapons is increased by 75%, and swing speed by 32%.|n|nTECH FOUR: Melee weapons are almost instantly lethal, at a level +100% of bonus damage, paired with 41% bonus swing speed."
     MPInfo="When active, you do double damage with melee weapons.  Energy Drain: Low"
     LevelValues(0)=1.250000
     LevelValues(1)=1.500000
     LevelValues(2)=1.750000
     LevelValues(3)=2.000000
     AugmentationLocation=LOC_Arm
     MPConflictSlot=1
}
