//=============================================================================
// WeaponModLaser
//
// Adds a laser sight to a weapon
//=============================================================================
class WeaponModWinning extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.bHasWinning = True;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Winning");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Winning"))
		{
			if (W.VMDWeaponModAllowed("Winning")) return true;
		}
		else
			return (!W.bHasWinning);
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ItemName="Weapon Modification (Winning)"
     Icon=Texture'BeltIconWeaponModWinning'
     largeIcon=Texture'LargeIconWeaponModWinning'
     Description="A mod that increases the power of your weapon so hard, you'll win the game swiftly after application."
     beltDescription="WIN THE MOD"
     Skin=Texture'WeaponModWinning'
}
