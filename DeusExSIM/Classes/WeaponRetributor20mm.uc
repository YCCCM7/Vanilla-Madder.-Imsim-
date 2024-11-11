//=============================================================================
// WeaponRetributor20mm.
//=============================================================================
class WeaponRetributor20mm extends DeusExWeapon;

function bool VMDProjectileFireHook(class<Projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	FireSound = Sound'AssaultGunFire20mm';
	PlayFiringSound();
	FireSound = None;
	
	return true;
}

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     
     NPCOverrideAnimRate=0.650000 //1/5th the previous rate.
     OverrideAnimRate=0.9100000 //Used to be 0.8
     bSemiAutoTrigger=False
     bBurstFire=True
     bAutomatic=True
     BaseAccuracy=0.250000
     
     bVolatile=True
     AimDecayMult=8.000000
     OverrideReloadAnimRate=1.350000
     
     LowAmmoWaterMark=3
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=0.100000
     reloadTime=2.000000
     HitDamage=150
     maxRange=24000
     AccurateRange=14400
     bHasMuzzleFlash=False
     recoilStrength=1.000000
     bUseWhileCrouched=False
     AmmoName=Class'DeusEx.Ammo20mm'
     ReloadCount=3
     PickupAmmoCount=3
     ProjectileClass=Class'DeusEx.HECannister20mm'
     shakemag=500.000000
     FireSound=None
     CockingSound=Sound'DeusExSounds.Weapons.GEPGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.GEPGunSelect'
     InventoryGroup=17
     ItemName="Slatewiper Grenade Launcher"
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
