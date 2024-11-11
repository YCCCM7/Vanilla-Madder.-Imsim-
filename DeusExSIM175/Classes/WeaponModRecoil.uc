//=============================================================================
// WeaponModRecoil
//
// Decreases recoil amount
//=============================================================================
class WeaponModRecoil extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.recoilStrength += (W.Default.recoilStrength * WeaponModifier);
		if (W.recoilStrength < 0.0)
			W.recoilStrength = 0.0;
		W.ModRecoilStrength += WeaponModifier;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Recoil");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Recoil"))
		{
			if (W.VMDWeaponModAllowed("Recoil")) return true;
		}
		else		return ((W.bCanHaveModRecoilStrength) && (!W.HasMaxRecoilMod()) && (!W.IsA('HatchetWeapon')));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WeaponModifier=-0.100000
     ItemName="Weapon Modification (Recoil)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModRecoil'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModRecoil'
     Description="A stock cushioned with polycellular shock absorbing material will significantly reduce perceived recoil."
     beltDescription="MOD RECOIL"
     Skin=Texture'DeusExItems.Skins.WeaponModTex5'
}
