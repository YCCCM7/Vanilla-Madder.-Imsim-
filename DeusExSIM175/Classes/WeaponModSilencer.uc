//=============================================================================
// WeaponModSilencer
//
// Adds a Silencer sight to a weapon
//=============================================================================
class WeaponModSilencer extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.bHasSilencer = True;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Silencer");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Silencer"))
		{
			if (W.VMDWeaponModAllowed("Silencer")) return true;
		}
		else
			return ((W.bCanHaveSilencer) && (!W.bHasSilencer));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ItemName="Weapon Modification (Silencer)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModSilencer'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModSilencer'
     Description="A silencer will muffle the muzzle crack caused by rapidly expanding gases left in the wake of a bullet leaving the gun barrel.|n|n<UNATCO OPS FILE NOTE SC108-BLUE> Obviously, a silencer is only effective with firearms. -- Sam Carter <END NOTE>"
     beltDescription="MOD SLNCR"
     Skin=Texture'DeusExItems.Skins.WeaponModTex7'
}
