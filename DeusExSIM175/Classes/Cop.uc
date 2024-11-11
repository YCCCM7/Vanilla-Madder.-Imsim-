//=============================================================================
// Cop.
//=============================================================================
class Cop extends HumanMilitary;

//MADDERS: Give us random loot now.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local int Seed;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
 	if (Seed == 4)
 	{
 	 	IC = ObtainRandomGoodie();
  		
		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

defaultproperties
{
     CarcassType=Class'DeusEx.CopCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.750000
     GroundSpeed=200.000000
     Mesh=LodMesh'DeusExCharacters.GM_DressShirt'
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
