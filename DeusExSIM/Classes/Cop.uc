//=============================================================================
// Cop.
//=============================================================================
class Cop extends HumanMilitary;

function VMDRandomizeAppearance()
{
	local int TRand;
	
	TRand = Rand(8);
	switch(TRand)
	{
		case 1:
			Multiskins[0] = Texture'Cop2Tex0';
			Multiskins[2] = Texture'Cop2Tex0';
			Multiskins[4] = Texture'Cop2Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
		case 2:
			Multiskins[0] = Texture'Cop3Tex0';
			Multiskins[2] = Texture'Cop3Tex0';
			Multiskins[4] = Texture'Cop3Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
		case 3:
			Multiskins[0] = Texture'Cop4Tex0';
			Multiskins[2] = Texture'Cop4Tex0';
			Multiskins[4] = Texture'Cop4Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
		case 4:
			Multiskins[0] = Texture'Cop5Tex0';
			Multiskins[2] = Texture'Cop5Tex0';
			Multiskins[4] = Texture'Cop5Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
		case 5:
			Multiskins[0] = Texture'Cop6Tex0';
			Multiskins[2] = Texture'Cop6Tex0';
			Multiskins[4] = Texture'Cop6Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
		case 6:
			Multiskins[0] = Texture'Cop7Tex0';
			Multiskins[2] = Texture'Cop7Tex0';
			Multiskins[4] = Texture'Cop7Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
		case 7:
			Multiskins[0] = Texture'Cop8Tex0';
			Multiskins[2] = Texture'Cop8Tex0';
			Multiskins[4] = Texture'Cop8Tex0';
			StoredMultiskins[0] = Multiskins[0];
			StoredMultiskins[2] = Multiskins[2];
			StoredMultiskins[4] = Multiskins[4];
		break;
	}
}

//MADDERS: Give us random loot now.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local int Seed;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
 	if ((Seed == 4) && (!bAppliedSpecial))
 	{
 	 	IC = ObtainRandomGoodie();
  		
		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

defaultproperties
{
     SmellTypes(6)=PlayerZymeSmell
     CarcassType=Class'DeusEx.CopCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.750000
     GroundSpeed=200.000000
     Mesh=LodMesh'TranscendedModels.TransGM_DressShirt'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.CopTex0'
     MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.CopTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.CopTex2'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.CopTex0'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.CopTex1'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex2'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex2'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="Cop"
     FamiliarName="Cop"
     UnfamiliarName="Cop"
}
