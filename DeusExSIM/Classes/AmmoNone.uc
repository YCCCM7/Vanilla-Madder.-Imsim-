//=============================================================================
// AmmoNone.
//=============================================================================
class AmmoNone extends DeusExAmmo;

// special ammo type for hand to hand weapons

defaultproperties
{
     Mass=0.000000
     PickupViewMesh=LodMesh'DeusExItems.TestBox'
     Mesh=LodMesh'DeusExItems.TestBox'
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     bCollideActors=True
}
