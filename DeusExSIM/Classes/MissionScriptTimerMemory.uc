//=============================================================================
// MissionScriptTimerMemory.
// We use this instead of Level.TimeSeconds for reliable use in MS.
//=============================================================================
class MissionScriptTimerMemory extends VMDFillerActors;

var float TrackedTime;

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
