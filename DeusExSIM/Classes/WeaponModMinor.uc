//=============================================================================
// WeaponModMinor
//
// Can be accuracy, range, recoil, clip, or reload.
//=============================================================================
class WeaponModMinor extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	Log("WARNING! APPLIED MINOR WEAPON MOD STANDALONE!");
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if ((W != None) && (!W.IsA('HatchetWeapon')))
	{
		if (W.VMDSpecialModCondition("Accuracy"))
		{
			if (W.VMDWeaponModAllowed("Accuracy")) return true;
		}
		else if (W.VMDSpecialModCondition("Range"))
		{
			if (W.VMDWeaponModAllowed("Range")) return true;
		}
		else if (W.VMDSpecialModCondition("Recoil"))
		{
			if (W.VMDWeaponModAllowed("Recoil")) return true;
		}
		else if (W.VMDSpecialModCondition("Reload"))
		{
			if (W.VMDWeaponModAllowed("Reload")) return true;
		}
		else if (W.VMDSpecialModCondition("Clip"))
		{
			if (W.VMDWeaponModAllowed("Clip")) return true;
		}
		else
		{
			if (W.bCanHaveModBaseAccuracy && !W.HasMaxAccuracyMod())
			{
				return true;
			}
			else if (W.bCanHaveModAccurateRange && !W.HasMaxRangeMod())
			{
				return true;
			}
			else if (W.bCanHaveModRecoilStrength && !W.HasMaxRecoilMod())
			{
				return true;
			}
			else if (W.bCanHaveModReloadTime && !W.HasMaxReloadMod())
			{
				return true;
			}
			else if (W.bCanHaveModReloadCount && !W.HasMaxClipMod())
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
     ItemName="Weapon Modification (Minor)"
     Icon=Texture'BeltIconWeaponModMinor'
     largeIcon=Texture'LargeIconWeaponModMinor'
     Description="An undifferentiated weapon modification. In its base form, its material and energy potential lets it fulfill the roll of an accuracy, range, recoil, reload, or capacity mod. Once removed, these mods are stuck in a differentiated state."
     beltDescription="MOD MINOR"
     Skin=Texture'WeaponModMinor'
}
