//=============================================================================
// VMDDynamicBlocker
// Blocks all actors from passing.
// This is a variant for VMD that can be spawned as a plug for BSP holes.
// Small starting size, for gettin all those hard to reach spots.
//=============================================================================
class VMDDynamicBlocker extends Keypoint;

defaultproperties
{
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bStatic=False
     bCollideActors=True
     bBlockActors=True
     bBlockPlayers=True
}
