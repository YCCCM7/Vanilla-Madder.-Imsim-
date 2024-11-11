//=============================================================================
// WeaponMilbotMachinegun.
//=============================================================================
class WeaponMilbotMachinegun extends WeaponNPCRanged;

//MADDERS, 1/14/21: We exist just to end stalemates with other milbots.
function name WeaponDamageType()
{
	return 'Sabot';
}

defaultproperties
{
     BulletHoleSize=0.150000
     PenetrationHitDamage=4
     RicochetHitDamage=2
     ItemName="Mounted Machine Gun"
     
     ShotTime=0.100000
     reloadTime=1.000000
     HitDamage=6
     BaseAccuracy=0.600000
     bHasMuzzleFlash=True
     AmmoName=Class'DeusEx.Ammo762mm'
     PickupAmmoCount=50
     bInstantHit=True
     FireSound=Sound'DeusExSounds.Robot.RobotFireGun'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
}
