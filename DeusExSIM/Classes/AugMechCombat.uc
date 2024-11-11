//=============================================================================
// AugMechCombat.
//=============================================================================
class AugMechCombat extends VMDBufferAugmentation;

state Active
{
Begin:
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
 	
 	if ((DXW.bHandToHand) && (TSkill == class'SkillWeaponLowTech'))
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
 	
 	if (DXW.bHandToHand)
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
 	
 	if ((DXW.bHandToHand) && (TSkill == class'SkillWeaponLowTech'))
 	{
  		return Sqrt(LevelValues[CurrentLevel]);
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
		if (i < 3)
		{
			Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 1.0) * 100) + 0.5), int(((Sqrt(LevelValues[i]) - 1.0) * 100) + 0.5));
		}
		else
		{
			Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 1.0) * 100) + 0.5), int(((LevelValues[i] - 1.0) * 100) + 0.5), int(((Sqrt(LevelValues[i]) - 1.0) * 100) + 0.5));
		}
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Enhanced arm prosthetsis that offers superior speed and strength."
     AdvancedDescLevels(0)="TECH ONE: Damage with melee weapons and thrown projectile velocities are increased by %d%%, and melee swing speed by %d%%."
     
     EnergyRate=20.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconCombat'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconCombat_Small'
     AugmentationName="Cybernetic Arm Prosthesis"
     LevelValues(0)=1.750000
     AugmentationLocation=LOC_Arm
}
