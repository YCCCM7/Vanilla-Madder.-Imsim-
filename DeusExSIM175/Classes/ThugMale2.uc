//=============================================================================
// ThugMale2.
//=============================================================================
class ThugMale2 extends HumanThug;

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
     CarcassType=Class'DeusEx.ThugMale2Carcass'
     WalkingSpeed=0.296000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponPistol')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=6)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCrowbar')
     walkAnimMult=0.800000
     GroundSpeed=200.000000
     Mesh=LodMesh'DeusExCharacters.GM_DressShirt'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.ThugMale2Tex0'
     MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(2)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.ThugMale2Tex2'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.ThugMale2Tex0'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.ThugMale2Tex1'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="Thug"
     FamiliarName="Thug"
     UnfamiliarName="Thug"
}
