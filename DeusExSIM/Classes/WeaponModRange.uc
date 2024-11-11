//=============================================================================
// WeaponModRange
//
// Increases Accurate Range
//=============================================================================
class WeaponModRange extends WeaponMod;

// ----------------------------------------------------------------------
// ApplyMod()
// ----------------------------------------------------------------------

function ApplyMod(DeusExWeapon W)
{
	if (W != None)
	{
		W.RelativeRange	+= (W.Default.RelativeRange * WeaponModifier);
		W.AccurateRange    += (W.Default.AccurateRange * WeaponModifier);
		W.ModAccurateRange += WeaponModifier;
		
		//MADDERS: Signal this for potential, unique effects.
		W.VMDAlertModApplied("Range");
	}
}

// ----------------------------------------------------------------------
// CanUpgradeWeapon()
// ----------------------------------------------------------------------

simulated function bool CanUpgradeWeapon(DeusExWeapon W)
{
	if (W != None)
	{
		if (W.VMDSpecialModCondition("Range"))
		{
			if (W.VMDWeaponModAllowed("Range")) return true;
		}
		else
			return ((W.bCanHaveModAccurateRange) && (!W.HasMaxRangeMod()) && (!W.IsA('HatchetWeapon')));
	}
	else
		return False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WeaponModifier=0.100000
     ItemName="Weapon Modification (Range)"
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponModRange'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponModRange'
     Description="By lubricating the firing path with synthetic synovial fluid, the drag on fired projectiles is greatly reduced with a consequent increase in range, as well as a reduction in damage falloff during travel.|n|n<UNATCO OPS FILE NOTE SC111-BLUE> Coating the primary valve system of a flamethrower or plasma gun in synovial lubricant and then over-pressuring the delivery system will also result in an increase in range. Little trick I learned during field testing. -- Sam Carter <END NOTE>"
     beltDescription="MOD RANGE"
     Skin=Texture'DeusExItems.Skins.WeaponModTex1'
}
