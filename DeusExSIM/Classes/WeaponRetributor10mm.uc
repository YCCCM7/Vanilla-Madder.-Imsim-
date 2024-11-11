//=============================================================================
// WeaponRetributor10mm.
//=============================================================================
class WeaponRetributor10mm extends DeusExWeapon;

function bool VMDTraceFireHook(float Accuracy)
{
	local float TMod;
	
	Super.VMDTraceFirehook(Accuracy);
	
	FireSound = Sound'PistolFire';
	PlayFiringSound();
	FireSound = None;
	
	return true;
}

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     BulletHoleSize=0.175000
     AimDecayMult=4.000000
     AimFocusMult=1.250000
     PenetrationHitDamage=5
     RicochetHitDamage=3
     GrimeRateMult=0.400000
     
     NPCOverrideAnimRate=1.000000 //1/5th the previous rate.
     OverrideAnimRate=1.200000 //Used to be 0.8
     bSemiAutoTrigger=False
     bBurstFire=True
     
     maxRange=4800
     AccurateRange=2400
     
     LowAmmoWaterMark=18
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     bAutomatic=True
     ShotTime=0.100000
     reloadTime=3.000000
     HitDamage=3
     BaseAccuracy=0.700000
     recoilStrength=0.750000
     MinWeaponAcc=0.200000
     AmmoName=Class'DeusEx.Ammo10mm'
     ReloadCount=18
     PickupAmmoCount=18
     bInstantHit=True
     shakemag=200.000000
     FireSound=None
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
     InventoryGroup=4
     bNameCaseSensitive=False
     ItemName="Ripper Autocarbine"
     PlayerViewMesh=LodMesh'DeusExItems.AssaultGun'
     LeftPlayerViewMesh=LodMesh'AssaultGunLeft'
     PickupViewMesh=LodMesh'DeusExItems.AssaultGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.AssaultGun3rd'
     LeftThirdPersonMesh=LodMesh'AssaultGun3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconAssaultGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultGun'
     largeIconWidth=94
     largeIconHeight=65
     Mesh=LodMesh'DeusExItems.AssaultGunPickup'
     CollisionRadius=15.000000
     CollisionHeight=1.100000
}
