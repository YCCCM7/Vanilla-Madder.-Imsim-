//=============================================================================
// Tumbleweed.
//=============================================================================
class Tumbleweed extends Trash;

// ----------------------------------------------------------------------------
// Timer()
// Transcended - Overridden to prevent lifetime to be set causing tumbleweed to get deleted.
// ----------------------------------------------------------------------------

simulated function Timer()
{
	SetPhysics( PHYS_Falling );
}

defaultproperties
{
     bFlammable=True
     ItemName="Tumbleweed"
     Mesh=LodMesh'DeusExDeco.Tumbleweed'
     CollisionRadius=33.000000
     CollisionHeight=21.570000
     FragType=Class'DeusEx.GrassFragment'
     bInvincible=True
}
