//=============================================================================
// WeaponRocketMG. Because fuck logic.
//=============================================================================
class WeaponRocketMG extends WeaponNPCRanged;

// fire weapons out of alternating sides
function Fire(float Value)
{
	PlayerViewOffset.Y = -PlayerViewOffset.Y;
	Super.Fire(Value);
}

defaultproperties
{
     ItemName="Mounted Rocket Launchers"
     
     ShotTime=0.100000
     HitDamage=100
     AIMinRange=500.000000
     AIMaxRange=2000.000000
     AmmoName=Class'DeusEx.AmmoRocketRobot'
     PickupAmmoCount=2000
     ProjectileClass=Class'DeusEx.Rocket'
     PlayerViewOffset=(Y=-46.000000,Z=36.000000)
}
