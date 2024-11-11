//=============================================================================
// CrackMark.
//=============================================================================
class CrackMark extends DeusExDecal;

// overridden to NOT rotate decal
simulated event BeginPlay()
{
	if (!AttachDecal(16, vect(0.1,0.1,0)))
	{
		Destroy();
	}
}

defaultproperties
{
     Texture=Texture'DeusExItems.Skins.FlatFXTex7'
     DrawScale=0.100000
}
