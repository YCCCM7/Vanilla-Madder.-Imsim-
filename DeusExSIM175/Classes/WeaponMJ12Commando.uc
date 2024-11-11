//=============================================================================
// WeaponMJ12Commando.
//=============================================================================
class WeaponMJ12Commando extends WeaponNPCRanged;

// fire weapons out of alternating sides
function Fire(float Value)
{
	PlayerViewOffset.Y = -PlayerViewOffset.Y;
	Super.Fire(Value);
}

defaultproperties
{
     BulletHoleSize=0.150000
     PenetrationHitDamage=6
     RicochetHitDamage=2
     ItemName="Integral Machine Guns"
     
     ShotTime=0.200000
     reloadTime=1.000000
     HitDamage=8 //MADDERS: Down from 15. JFC, what overkill.
     BaseAccuracy=0.400000
     bHasMuzzleFlash=True
     AmmoName=Class'DeusEx.Ammo762mm'
     PickupAmmoCount=50
     bInstantHit=True
     FireSound=Sound'DeusExSounds.Robot.RobotFireGun'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
}
