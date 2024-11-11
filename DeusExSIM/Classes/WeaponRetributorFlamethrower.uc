//=============================================================================
// WeaponRetributorFlamethrower.
//=============================================================================
class WeaponRetributorFlamethrower extends DeusExWeapon;

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     
     RecoilStrength=0.000000
     AimDecayMult=0.000000 //Don't actually decay aim on this one during firing.
     OverrideNumProj=1
     NPCOverrideAnimRate=1.000000 //1/5th the previous rate.
     OverrideAnimRate=1.000000
     bVolatile=True
     AimDecayMult=20.000000
     BaseAccuracy=0.450000
     
     LowAmmoWaterMark=75
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     EnviroEffective=ENVEFF_Air
     bAutomatic=True
     ShotTime=0.010000
     reloadTime=5.500000
     HitDamage=2
     maxRange=640
     AccurateRange=640
     bHasMuzzleFlash=False
     AmmoName=Class'DeusEx.AmmoNapalm'
     ReloadCount=75
     PickupAmmoCount=75
     ProjectileClass=Class'DeusEx.TartarusFireball'
     shakemag=10.000000
     FireSound=Sound'DeusExSounds.Weapons.FlamethrowerFire'
     AltFireSound=Sound'DeusExSounds.Weapons.FlamethrowerReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.FlamethrowerReload'
     SelectSound=Sound'DeusExSounds.Weapons.FlamethrowerSelect'
     InventoryGroup=15
     bNameCaseSensitive=False
     ItemName="Tartarus Flamethrower"
     PlayerViewMesh=LodMesh'DeusExItems.Flamethrower'
     LeftPlayerViewMesh=LodMesh'FlamethrowerLeft'
     PickupViewMesh=LodMesh'DeusExItems.FlamethrowerPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Flamethrower3rd'
     LeftThirdPersonMesh=LodMesh'Flamethrower3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconFlamethrower'
     largeIcon=Texture'DeusExUI.Icons.LargeIconFlamethrower'
     largeIconWidth=203
     largeIconHeight=69
     Mesh=LodMesh'DeusExItems.FlamethrowerPickup'
     CollisionRadius=20.500000
     CollisionHeight=4.400000
}
