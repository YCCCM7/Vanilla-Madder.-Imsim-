//=============================================================================
// WeaponSpiderBotGas.
//=============================================================================
class WeaponSpiderBotGas extends WeaponNPCRanged;

// fire weapons out of alternating sides
function Fire(float Value)
{
	PlayerViewOffset.Y = -PlayerViewOffset.Y;
	Super.Fire(Value);
}

defaultproperties
{
     ItemName="Mounted Grenade Launchers"
     BaseAccuracy=0.150000
     
     ShotTime=1.000000
     HitDamage=0
     AIMinRange=500.000000
     AIMaxRange=2000.000000
     AmmoName=Class'DeusEx.AmmoRocketRobot'
     PickupAmmoCount=2
     ProjectileClass=Class'DeusEx.HECannister20mmGas'
     PlayerViewOffset=(Y=-46.000000,Z=12.000000)
}
