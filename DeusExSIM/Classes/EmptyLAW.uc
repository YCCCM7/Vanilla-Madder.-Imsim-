//=============================================================================
// EmptyLAW.
//=============================================================================
class EmptyLAW extends VMDBufferDeco;

var localized string MsgLAWSpent;

function Frob(Actor Frobber, Inventory frobWith)
{
	if (Pawn(Frobber) != None)
	{
		Pawn(Frobber).ClientMessage(MsgLAWSpent);
	}
}

defaultproperties
{
     bInvincible=True
     bFlammable=False
     ItemName="Spent LAW"
     bBlockSight=True
     Mesh=LodMesh'DeusExItems.LAWPickup'
     CollisionRadius=25.000000
     CollisionHeight=6.800000
     Mass=35.000000
     Buoyancy=30.000000
     
     MsgLAWSpent="This LAW has already been fired. It is now depleted"
     bPushable=False
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
}
