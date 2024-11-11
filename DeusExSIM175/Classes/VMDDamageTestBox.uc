//=============================================================================
// VMDDamageTestBox.
//=============================================================================
class VMDDamageTestBox extends Containers;

var localized string MsgDamageTaken;

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		BroadcastMessage(SprintF(MsgDamageTaken, Damage));
	}
}

defaultproperties
{
     MsgDamageTaken="Damage taken by test box? %d"
     
     HitPoints=20000
     FragType=Class'DeusEx.PaperFragment'
     ItemName="Cardboard Box"
     bBlockSight=True
     Mesh=LodMesh'DeusExDeco.BoxLarge'
     CollisionRadius=42.000000
     CollisionHeight=50.000000
     Mass=80.000000
     Buoyancy=90.000000
}
