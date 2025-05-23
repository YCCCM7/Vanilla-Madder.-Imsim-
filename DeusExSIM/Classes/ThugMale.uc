//=============================================================================
// ThugMale.
//=============================================================================
class ThugMale extends HumanThug;

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
     CarcassType=Class'DeusEx.ThugMaleCarcass'
     WalkingSpeed=0.213333
     BaseAssHeight=-23.000000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponPistol')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=6)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCrowbar')
     GroundSpeed=180.000000
     Mesh=LodMesh'TranscendedModels.TransGM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.ThugMaleTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.ThugMaleTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.ThugMaleTex3'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.ThugMaleTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.ThugMaleTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="Thug"
     FamiliarName="Thug"
     UnfamiliarName="Thug"
}
