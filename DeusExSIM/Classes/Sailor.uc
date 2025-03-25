//=============================================================================
// Sailor.
//=============================================================================
class Sailor extends HumanCivilian;

function VMDRandomizeAppearance()
{
	local int TRand;
	local Texture TTex;
	
	TRand = Rand(7);
	switch(TRand)
	{
		case 1:
			TTex = Texture'Sailor2Tex0';
		break;
		case 2:
			TTex = Texture'Sailor3Tex0';
		break;
		case 3:
			TTex= Texture'Sailor4Tex0';
		break;
		case 4:
			TTex = Texture'Sailor5Tex0';
		break;
		case 5:
			TTex = Texture'Sailor6Tex0';
		break;
		case 6:
			TTex = Texture'Sailor7Tex0';
		break;
	}
	
	if (TTex != None)
	{
		Multiskins[0] = TTex;
		Multiskins[2] = TTex;
		StoredMultiskins[0] = Multiskins[0];
		StoredMultiskins[2] = Multiskins[2];
	}
}

defaultproperties
{
     bCanGrabWeapons=True
     CarcassType=Class'DeusEx.SailorCarcass'
     WalkingSpeed=0.213333
     walkAnimMult=0.750000
     GroundSpeed=180.000000
     Mesh=LodMesh'TranscendedModels.TransGM_Suit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.SailorTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.SailorTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.SailorTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.SailorTex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.SailorTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.BlackMaskTex'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.SailorTex3'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="Sailor"
     FamiliarName="Sailor"
     UnfamiliarName="Sailor"
}
