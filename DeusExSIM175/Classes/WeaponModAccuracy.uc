//=============================================================================
// WeaponModAccuracy
//
// Increases Weapon Accuracy
//=============================================================================
class WeaponModAccuracy extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.BaseAccuracy == 0.0)
			W.BaseAccuracy    -= WeaponModifier;
		else
			W.BaseAccuracy    -= (W.Default.BaseAccuracy * WeaponModifier);
		W.ModBaseAccuracy += WeaponModifier;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Accuracy");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Accuracy"))
		{
			if (W.VMDWeaponModAllowed("Accuracy")) return true;
		}
		else
			return ((W.bCanHaveModBaseAccuracy) && (!W.HasMaxAccuracyMod()) && (!W.IsA('HatchetWeapon')));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WeaponModifier=0.100000
     ItemName="Weapon Modification (Accuracy)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModAccuracy'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModAccuracy'
     Description="When clamped to the frame of most projectile weapons, a harmonic balancer will dampen the vertical motion produced by firing a projectile, resulting in increased accuracy.|n|n<UNATCO OPS FILE NOTE SC108-BLUE> Almost any weapon that has a significant amount of vibration can be modified with a balancer; I've even seen it work with the mini-crossbow and a prototype plasma gun. -- Sam Carter <END NOTE>"
     beltDescription="MOD ACCRY"
     Skin=Texture'DeusExItems.Skins.WeaponModTex2'
}
