//=============================================================================
// CarBurned.
//=============================================================================
class CarBurned extends OutdoorThings;

enum ESkinColor
{
	SC_Yellow,
	SC_DarkBlue
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Yellow:		Skin = Texture'CarBurnedTex1'; break;
		case SC_DarkBlue:	Skin = Texture'CarBurnedTex2'; break;
	}
}

defaultproperties
{
     bBlockSight=True //MADDERS
     bCanBeBase=True
     Mesh=LodMesh'DeusExDeco.CarBurned'
     CollisionRadius=101.650002
     CollisionHeight=29.430000
     Mass=2000.000000
     Buoyancy=1500.000000
     FragType=Class'DeusEx.MetalFragment'
}
