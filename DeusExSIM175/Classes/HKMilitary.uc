//=============================================================================
// HKMilitary.
//=============================================================================
class HKMilitary extends HumanMilitary;

//MADDERS: Give us random loot.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local int Seed;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
 	if (Seed == 3)
 	{
  		IC = ObtainRandomGoodie();
  		
  		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

defaultproperties
{
     MedicineSkillLevel=2
     EnviroSkillLevel=2
     
     CarcassType=Class'DeusEx.HKMilitaryCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex2'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.HKMilitaryTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.HKMilitaryTex1'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex2'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="HKMilitary"
     FamiliarName="Chinese Military"
     UnfamiliarName="Chinese Military"
     NameArticle=" the "
}
