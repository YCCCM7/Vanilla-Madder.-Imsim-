//=============================================================================
// WeaponModClip
//
// Increases Clip Capacity
//=============================================================================
class WeaponModClip extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	local int diff;
	
	if (W != None)
	{
		diff = Float(W.Default.ReloadCount) * WeaponModifier;
		
		// make sure we add at least one
		if (diff < 1)
			diff = 1;
		
		W.ReloadCount += diff;
		W.ModReloadCount += WeaponModifier;
		W.ClipCount += Diff; //MADDERS: Require topping off to get the bonus.
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Clip");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Clip"))
		{
			if (W.VMDWeaponModAllowed("Clip")) return true;
		}
		else
			return (W.bCanHaveModReloadCount && !W.HasMaxClipMod() && !W.IsA('HatchetWeapon'));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WeaponModifier=0.100000
     ItemName="Weapon Modification (Capacity)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModClip'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModClip'
     Description="An extended magazine that increases clip or magazine capacity beyond the factory default."
     beltDescription="MOD CLIP"
     Skin=Texture'DeusExItems.Skins.WeaponModTex3'
}
