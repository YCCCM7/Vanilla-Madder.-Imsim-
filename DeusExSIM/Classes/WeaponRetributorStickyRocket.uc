//=============================================================================
// WeaponRetributorStickyRocket.
//=============================================================================
class WeaponRetributorStickyRocket extends DeusExWeapon;

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     
     MinSpreadAcc=0.075000
     BaseAccuracy=0.300000
     MaximumAccuracy=0.5500000
     
     OverrideNumProj=6
     bSemiautoTrigger=True
     bVolatile=True
     AimDecayMult=8.000000
     OverrideReloadAnimRate=1.350000
     bCanTrack=True
     LockTime=0.250000
     LockedSound=Sound'DeusExSounds.Weapons.GEPGunLock'
     TrackingSound=Sound'DeusExSounds.Weapons.GEPGunTrack'
     
     bNameCaseSensitive=False
     LowAmmoWaterMark=1
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=2.000000
     reloadTime=2.000000
     HitDamage=150
     maxRange=24000
     AccurateRange=14400
     bHasMuzzleFlash=False
     recoilStrength=1.000000
     bUseWhileCrouched=False
     AmmoName=Class'DeusEx.AmmoLAM'
     ReloadCount=1
     PickupAmmoCount=1
     ProjectileClass=Class'DeusEx.SierraRocket'
     shakemag=500.000000
     FireSound=Sound'DeusExSounds.Weapons.LAWFire'
     SelectSound=Sound'DeusExSounds.Weapons.LAWSelect'
     InventoryGroup=17
     ItemName="Sierra Smart Rocket Launcher"
     PlayerViewMesh=LodMesh'DeusExItems.LAW'
     LeftPlayerViewMesh=LodMesh'LAWLeft'
     PickupViewMesh=LodMesh'DeusExItems.LAWPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.LAW3rd'
     LeftThirdPersonMesh=LodMesh'LAW3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconLAW'
     largeIcon=Texture'DeusExUI.Icons.LargeIconLAW'
     largeIconWidth=166
     largeIconHeight=47
     Mesh=LodMesh'DeusExItems.LAWPickup'
     CollisionRadius=25.000000
     CollisionHeight=6.800000
     AIMinRange=225 // Transcended - Added
}
