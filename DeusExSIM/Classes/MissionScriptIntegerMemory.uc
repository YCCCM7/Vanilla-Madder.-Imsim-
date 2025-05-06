//=============================================================================
// MissionScriptIntegerMemory.
// We save an initialized value, for later reference.
//=============================================================================
class MissionScriptIntegerMemory extends VMDFillerActors;

var int TrackedValue;

defaultproperties
{
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=12.000000
     CollisionHeight=15.000000
}
