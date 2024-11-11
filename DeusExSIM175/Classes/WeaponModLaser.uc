//=============================================================================
// WeaponModLaser
//
// Adds a laser sight to a weapon
//=============================================================================
class WeaponModLaser extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.bHasLaser = True;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Laser");
		
		if ((Pawn(W.Owner) != None) && (Pawn(W.Owner).Weapon == W))
			w.LaserOn(); // Transcended - Automatically enable laser
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Laser"))
		{
			if (W.VMDWeaponModAllowed("Laser")) return true;
		}
		else
			return ((W.bCanHaveLaser) && (!W.bHasLaser) && (!W.IsA('HatchetWeapon')));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ItemName="Weapon Modification (Laser)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModLaser'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModLaser'
     Description="A laser targeting dot eliminates any inaccuracy resulting from the inability to visually guage a projectile's point of impact."
     beltDescription="MOD LASER"
     Skin=Texture'DeusExItems.Skins.WeaponModTex4'
}
