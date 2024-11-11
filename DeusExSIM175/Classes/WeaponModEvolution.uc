//=============================================================================
// WeaponModEvolution
//
// Adds a laser sight to a weapon
//=============================================================================
class WeaponModEvolution extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.bHasEvolution = True;
		W.VMDUpdateEvolution();
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Evolution");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Evolution"))
		{
			if (W.VMDWeaponModAllowed("Evolution")) return true;
		}
		else
			return ((!W.bHasEvolution) && (W.bCanHaveModEvolution));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ItemName="Weapon Modification (Evolution)"
     Icon=Texture'BeltIconWeaponModEvolution'
     largeIcon=Texture'LargeIconWeaponModEvolution'
     Description="Some people think it'll buff your weapon in a cool, unique way... but it's just a theory. Mocap sold separately."
     beltDescription="Ultra Instinct"
     Skin=Texture'WeaponModEvolution'
}
