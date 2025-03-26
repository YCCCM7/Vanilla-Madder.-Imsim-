//=============================================================================
// WeaponRetributorRocket.
//=============================================================================
class WeaponRetributorRocket extends DeusExWeapon;

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     
     MinSpreadAcc=0.075000
     BaseAccuracy=0.600000
     MaximumAccuracy=0.5500000
     
     OverrideNumProj=6
     bSemiautoTrigger=True
     bVolatile=True
     AimDecayMult=8.000000
     OverrideReloadAnimRate=1.350000
     
     bNameCaseSensitive=False
     LowAmmoWaterMark=1
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=2.000000
     reloadTime=2.000000
     HitDamage=25
     maxRange=24000
     AccurateRange=14400
     AmmoNames(0)=Class'DeusEx.AmmoRocket'
     AmmoNames(1)=Class'DeusEx.AmmoRocketWP'
     ProjectileNames(0)=Class'DeusEx.ObliteratorRocket'
     ProjectileNames(1)=Class'DeusEx.ObliteratorRocketWP'
     bHasMuzzleFlash=False
     recoilStrength=1.000000
     bUseWhileCrouched=False
     AmmoName=Class'DeusEx.AmmoRocket'
     ReloadCount=1
     PickupAmmoCount=1
     ProjectileClass=Class'DeusEx.ObliteratorRocket'
     shakemag=500.000000
     FireSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     CockingSound=Sound'DeusExSounds.Weapons.GEPGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.GEPGunSelect'
     InventoryGroup=17
     ItemName="Obliterator Rocket Launcher"
     PlayerViewMesh=LodMesh'DeusExItems.GEPGun'
     LeftPlayerViewMesh=LodMesh'GEPGunLeft'
     PickupViewMesh=LodMesh'DeusExItems.GEPGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.GEPGun3rd'
     LeftThirdPersonMesh=LodMesh'GEPGun3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconGEPGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconGEPGun'
     largeIconWidth=203
     largeIconHeight=77
     Mesh=LodMesh'DeusExItems.GEPGunPickup'
     CollisionRadius=27.000000
     CollisionHeight=6.600000
     AIMinRange=225 // Transcended - Added
}
