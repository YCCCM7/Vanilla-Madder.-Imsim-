//=============================================================================
// WeaponRetributor3006.
//=============================================================================
class WeaponRetributor3006 extends DeusExWeapon;

function bool VMDGetHasSilencer()
{
	if (Ammo3006HEAT(AmmoType) != None) return false;
	return bHasSilencer;
}

simulated function PlayFiringSound()
{
	local Sound OldFire;
	
	Super.PlayFiringSound();
	if (Ammo3006AP(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'MediumExplosion1';
     		FirePitchMin = 1.900000;
     		FirePitchMax = 2.100000;
		Super.PlayFiringSound();
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
		FireSound = OldFire;
	}
	else if ((Ammo3006Tranq(AmmoType) != None) && (!bHasSilencer))
	{
		OldFire = FireSound;
		FireSound = Sound'StealthPistolFire';
     		FirePitchMin = 0.700000;
     		FirePitchMax = 0.800000;
		Super.PlayFiringSound();
     		FirePitchMin = 1.200000;
     		FirePitchMax = 1.400000;
		FireSound = OldFire;
	}
	else if (Ammo3006HEAT(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'MediumExplosion1';
     		FirePitchMin = 1.600000;
     		FirePitchMax = 1.800000;
		Super.PlayFiringSound();
     		FirePitchMin = 0.700000;
     		FirePitchMax = 0.900000;
		FireSound = OldFire;
	}
}

//Update penetration effects accordingly.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	local float EvoMod;
	
	EvoMod = 1.0;
	if (bHasEvolution) EvoMod = 1.75;
	
	if (Ammo3006AP(AmmoType) != None)
	{
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
     		PenetrationHitDamage = 25 * EvoMod;
     		RicochetHitDamage = 10 * EvoMod;
		HitDamage = Default.HitDamage * EvoMod;
	}
	if (Ammo3006Tranq(AmmoType) != None)
	{
     		FirePitchMin = 1.200000;
     		FirePitchMax = 1.400000;
     		PenetrationHitDamage = 0 * EvoMod;
     		RicochetHitDamage = 0 * EvoMod;
		HitDamage = Default.HitDamage * EvoMod * 0.5;
	}
	else if (Ammo3006HEAT(AmmoType) != None)
	{
     		FirePitchMin = 0.700000;
     		FirePitchMax = 0.900000;
     		PenetrationHitDamage = 20 * EvoMod;
     		RicochetHitDamage = 0 * EvoMod;
		HitDamage = Default.HitDamage * EvoMod;
	}
	else
	{
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
     		PenetrationHitDamage = Default.PenetrationHitDamage * EvoMod;
     		RicochetHitDamage = Default.RicochetHitDamage * EvoMod;
		HitDamage = Default.HitDamage * EvoMod;
	}
	ShotTime = Default.ShotTime;
}

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     AmmoNames(0)=Class'DeusEx.Ammo3006'
     AmmoNames(1)=Class'DeusEx.Ammo3006Tranq'
     AmmoNames(2)=Class'DeusEx.Ammo3006HEAT'
     
     BulletHoleSize=0.225000
     bSemiautoTrigger=True
     OverrideAnimRate=1.600000
     AimDecayMult=12.500000
     PenetrationHitDamage=8
     RicochetHitDamage=2
     ClipsLabel="MAGS"
     
     LowAmmoWaterMark=20
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=0.500000
     reloadTime=2.000000
     HitDamage=11
     maxRange=48000
     AccurateRange=6400
     BaseAccuracy=0.500000
     recoilStrength=0.600000
     AmmoName=Class'DeusEx.Ammo3006'
     ReloadCount=20
     PickupAmmoCount=20
     bInstantHit=True
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.RifleFire'
     AltFireSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.RifleReload'
     SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
     InventoryGroup=2
     bNameCaseSensitive=False
     ItemName="Demolisher Autocarbine"
     PlayerViewMesh=LodMesh'DeusExItems.Glock'
     LeftPlayerViewMesh=LodMesh'GlockLeft'
     PickupViewMesh=LodMesh'DeusExItems.GlockPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Glock3rd'
     LeftThirdPersonMesh=LodMesh'Glock3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconPistol'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPistol'
     largeIconWidth=46
     largeIconHeight=28
     Mesh=LodMesh'DeusExItems.GlockPickup'
     CollisionRadius=7.000000
     CollisionHeight=1.000000
}
