//=============================================================================
// Soldier.
//=============================================================================
class Soldier extends HumanMilitary;

function VMDRandomizeAppearance()
{
	local int TRand;
	local Texture TTex;
	
	TRand = Rand(8);
	switch(TRand)
	{
		case 2:
		case 3:
			TTex = Texture'Soldier2Tex0';
		break;
		case 4:
			TTex = Texture'Soldier3Tex0';
		break;
		case 5:
		case 6:
			TTex = Texture'Soldier4Tex0';
		break;
		case 7:
			TTex = Texture'Soldier5Tex0';
		break;
	}
	
	if (TTex != None)
	{
		Multiskins[0] = TTex;
		Multiskins[3] = TTex;
		StoredMultiskins[0] = Multiskins[0];
		StoredMultiskins[3] = Multiskins[3];
	}
}

//MADDERS: Give us random loot.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local int Seed;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
 	if ((Seed == 3) && (!bAppliedSpecial))
 	{
  		IC = ObtainRandomGoodie();
  		
  		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

defaultproperties
{
     MedicineSkillLevel=2
     EnviroSkillLevel=2
     
     CarcassType=Class'DeusEx.SoldierCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'TranscendedModels.TransGM_Jumpsuit'
     MultiSkins(0)=Texture'SoldierTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.SoldierTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.SoldierTex1'
     MultiSkins(3)=Texture'SoldierTex0'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.SoldierTex3'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="Soldier"
     FamiliarName="Soldier"
     UnfamiliarName="Soldier"
}
