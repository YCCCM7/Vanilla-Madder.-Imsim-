//=============================================================================
// ClothesRack.
//=============================================================================
class ClothesRack extends HangingDecoration;

enum ESkinColor
{
	SC_Blue,
	SC_Yellow,
	SC_Green,
	SC_Black
};

var() ESkinColor SkinColor;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Blue:	Skin = Texture'ClothesRackTex1'; break;
		case SC_Yellow:	Skin = Texture'ClothesRackTex2'; break;
		case SC_Green:	Skin = Texture'ClothesRackTex3'; break;
		case SC_Black:	Skin = Texture'ClothesRackTex4'; break;
	}
}

function Frob(Actor Frobber, Inventory FrobWith)
{
	local Vector TNorm, TVect;
	
	if (VMDBufferPlayer(Frobber) != None)
	{
		//MADDERS, 5/28/25: Ugly hack fix for being too close to racks.
		TNorm = Normal(Frobber.Location - Location);
		TVect = TNorm * 80;
		TVect.Z = Frobber.Location.Z;
		
		Frobber.SetLocation(TVect);
		VMDBufferPlayer(Frobber).ModifyPlayerAppearance();
	}
	
	Super.Frob(Frobber, FrobWith);
}

defaultproperties
{
     bHighlight=True
     bFlammable=True
     FragType=Class'DeusEx.PaperFragment'
     ItemName="Hanging Clothes"
     Mesh=LodMesh'DeusExDeco.ClothesRack'
     PrePivot=(Z=24.750000)
     CollisionRadius=13.000000
     CollisionHeight=24.750000
     Mass=60.000000
     Buoyancy=70.000000
}
