//=============================================================================
// WeaponModScope
//
// Adds a scope sight to a weapon
//=============================================================================
class WeaponModScope extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.bHasScope = True;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Scope");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Scope"))
		{
			if (W.VMDWeaponModAllowed("Scope")) return true;
		}
		else
			return (W.bCanHaveScope && !W.bHasScope);
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ItemName="Weapon Modification (Scope)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModScope'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModScope'
     Description="A telescopic scope attachment provides zoom capability and increases accuracy against distant targets."
     beltDescription="MOD SCOPE"
     Skin=Texture'DeusExItems.Skins.WeaponModTex8'
}
