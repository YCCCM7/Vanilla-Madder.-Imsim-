//=============================================================================
// SpiderBot.
//=============================================================================
class SpiderBot extends Robot;

defaultproperties
{
     HitboxArchetype="Spiderbot"
     
     EMPHitPoints=100
     maxRange=1400.000000
     WalkingSpeed=1.000000
     bEmitDistress=True
     //InitialInventory(0)=(Inventory=Class'DeusEx.WeaponSpiderBot')
     //InitialInventory(1)=(Inventory=Class'DeusEx.AmmoBattery',Count=99)
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponSpiderBotTaserSlug',Count=1)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponSpiderBotGas',Count=1)
     WalkSound=Sound'DeusExSounds.Robot.SpiderBotWalk'
     GroundSpeed=80.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=500.000000
     Health=400
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'TranscendedModels.TransSpiderBot'
     CollisionRadius=111.930000
     CollisionHeight=50.790001
     Mass=1000.000000
     Buoyancy=100.000000
     BindName="SpiderBot"
     FamiliarName="SpiderBot"
     UnfamiliarName="SpiderBot"
}
