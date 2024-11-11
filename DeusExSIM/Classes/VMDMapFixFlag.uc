//=============================================================================
// VMDMapFixFlag.
// NOTE: We exist purely to mark when important fixes have occurred within mission triggers.
// Mission triggers are transient, and are thus incapable of storing variables to disc (saved world data)
// MapFixer can only be spawned once, so this is spawned past the initial setup of a map.
//=============================================================================
class VMDMapFixFlag extends VMDFillerActors;

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
