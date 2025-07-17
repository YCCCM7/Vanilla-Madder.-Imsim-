//=============================================================================
// WeaponModMajor
//
// Can be accuracy, range, recoil, clip, or reload.
//=============================================================================
class WeaponModMajor extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	Log("WARNING! APPLIED MAJOR WEAPON MOD STANDALONE!");
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if ((W != None) && (!W.IsA('HatchetWeapon')))
	{
		if (W.VMDSpecialModCondition("Silencer"))
		{
			if (W.VMDWeaponModAllowed("Silencer")) return true;
		}
		else if (W.VMDSpecialModCondition("Laser"))
		{
			if (W.VMDWeaponModAllowed("Laser")) return true;
		}
		else if (W.VMDSpecialModCondition("Scope"))
		{
			if (W.VMDWeaponModAllowed("Scope")) return true;
		}
		else
		{
			if (W.bCanHaveSilencer && !W.bHasSilencer)
			{
				return true;
			}
			else if (W.bCanHaveLaser && !W.bHasLaser)
			{
				return true;
			}
			else if (W.bCanHaveScope && !W.bHasScope)
			{
				return true;
			}
		}
	}
	else
	{
		return false;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     MaxCopies=10
     ItemName="Weapon Modification (Major)"
     Icon=Texture'BeltIconWeaponModMajor'
     largeIcon=Texture'LargeIconWeaponModMajor'
     Description="An undifferentiated weapon modification of serious grade. In its base form, its material and energy potential lets it fulfill the roll of a muzzle, underbarrel, or optical mod. Once removed, these mods are stuck in a differentiated state."
     beltDescription="MOD MAJOR"
     Skin=Texture'WeaponModMajor'
}
