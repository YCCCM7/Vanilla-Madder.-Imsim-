//=============================================================================
// WeaponModReload
//
// Decreases reload time
//=============================================================================
class WeaponModReload extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.ReloadTime += (W.Default.ReloadTime * WeaponModifier);
		if (W.ReloadTime < 0.0)
			W.ReloadTime = 0.0;
		W.ModReloadTime += WeaponModifier;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Reload");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Reload"))
		{
			if (W.VMDWeaponModAllowed("Reload")) return true;
		}
		else
			return ((W.bCanHaveModReloadTime) && (!W.HasMaxReloadMod()) && (!W.IsA('HatchetWeapon')));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WeaponModifier=-0.100000
     ItemName="Weapon Modification (Reload)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModReload'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModReload'
     Description="A speed loader greatly decreases the time required to reload a weapon."
     beltDescription="MOD RELOAD"
     Skin=Texture'DeusExItems.Skins.WeaponModTex6'
}
