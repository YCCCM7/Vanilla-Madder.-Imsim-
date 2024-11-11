//=============================================================================
// Bushes3.
//=============================================================================
class Bushes3 extends OutdoorThings;

enum ESkinColor
{
	SC_Bushes1,
	SC_Bushes2,
	SC_Bushes3,
	SC_Bushes4
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	local int TSeed;

	Super.BeginPlay();

	TSeed = (class'VMDStaticFunctions'.Static.DeriveActorSeed(Self)*class'VMDStaticFunctions'.Static.DeriveActorSeed(Self)) % 4;
	
	//MADDERS: Enums suck for fluid operations such as this.
	switch (TSeed)
	{
		case 0:	Skin = Texture'Bushes3Tex1'; break;
		case 1:	Skin = Texture'Bushes3Tex2'; break;
		case 2:	Skin = Texture'Bushes3Tex3'; break;
		case 3:	Skin = Texture'Bushes3Tex4'; break;
	}
}

defaultproperties
{
     bStatic=False
     bPushable=False
     bInvincible=True
     bBlockSight=True //MADDERS
     Mesh=LodMesh'DeusExDeco.Bushes3'
     CollisionRadius=10.000000
     CollisionHeight=30.000000
     Mass=40.000000
     Buoyancy=20.000000
}
