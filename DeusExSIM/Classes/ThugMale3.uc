//=============================================================================
// ThugMale3.
//=============================================================================
class ThugMale3 extends HumanThug;

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
     CarcassType=Class'DeusEx.ThugMale3Carcass'
     WalkingSpeed=0.350000
     walkAnimMult=0.750000
     GroundSpeed=210.000000
     Texture=Texture'DeusExItems.Skins.BlackMaskTex'
     Mesh=LodMesh'TranscendedModels.TransGM_DressShirt_B'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.ThugMale3Tex1'
     MultiSkins(1)=Texture'ThugMale3Tex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.ThugMale3Tex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.ThugMale3Tex0'
     MultiSkins(4)=Texture'ThugMale3Tex3'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.BlackMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="ThugMale3"
     FamiliarName="Thug"
     UnfamiliarName="Thug"
}
