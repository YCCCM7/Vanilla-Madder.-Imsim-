//=============================================================================
// WeaponRobotRocket.
//=============================================================================
class WeaponRobotRocket extends WeaponNPCRanged;

// fire weapons out of alternating sides
function Fire(float Value)
{
	PlayerViewOffset.Y = -PlayerViewOffset.Y;
	Super.Fire(Value);
}

defaultproperties
{
     ItemName="Mounted Rocket Launchers"
     
     ShotTime=1.000000
     HitDamage=100
     AIMinRange=500.000000
     AIMaxRange=2000.000000
     AmmoName=Class'DeusEx.AmmoRocketRobot'
     PickupAmmoCount=20
     ProjectileClass=Class'DeusEx.RocketRobot'
     PlayerViewOffset=(Y=-46.000000,Z=12.000000)
}
