//=============================================================================
// Seagull.
//=============================================================================
class Seagull extends Bird;

defaultproperties
{
     CarcassType=Class'DeusEx.SeagullCarcass'
     WalkingSpeed=0.666667
     GroundSpeed=24.000000
     WaterSpeed=8.000000
     AirSpeed=150.000000
     AccelRate=500.000000
     JumpZ=0.000000
     BaseEyeHeight=3.000000
     Health=10
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Fear
     HealthHead=10
     HealthTorso=10
     HealthLegLeft=10
     HealthLegRight=10
     HealthArmLeft=10
     HealthArmRight=10
     Alliance=Seagull
     DrawType=DT_Mesh
     Mesh=LodMesh'DeusExCharacters.Seagull'
     CollisionRadius=16.000000
     CollisionHeight=8.000000
     Mass=2.000000
     Buoyancy=2.500000
     RotationRate=(Pitch=8000)
     BindName="Seagull"
     FamiliarName="Seagull"
     UnfamiliarName="Seagull"
}