//=============================================================================
// MJ12Troop.
//=============================================================================
class MJ12Troop extends HumanMilitary;

function VMDRandomizeAppearance()
{
	local int TRand;
	local Texture TTex;
	
	TRand = Rand(9);
	switch(TRand)
	{
		case 1:
			TTex = Texture'SkinTex2';
		break;
		case 2:
			TTex = Texture'SkinTex3';
		break;
		case 3:
			TTex = Texture'SkinTex4';
		break;
		case 4:
			TTex = Texture'SkinTex6';
		break;
		case 5:
			TTex = Texture'SkinTex7';
		break;
		case 6:
			TTex = Texture'SkinTex8';
		break;
		case 7:
			TTex = Texture'SkinTex9';
		break;
		case 8:
			TTex = Texture'SkinTex10';
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

function bool AddToInitialInventory(class<Inventory> NewClass, int NewCount, optional bool bAllowDuplicates)
{
	if (NewClass == class'HazmatSuit')
	{
		Texture = Texture'DeusExCharacters.Skins.VisorTex1';
		MultiSkins[6] = Texture'VMDMJ12TroopTex4NoGoggles';
		StoredTexture = Texture;
		StoredMultiskins[6] = Multiskins[6];
		return true;
	}
	return Super.AddToInitialInventory(NewClass, NewCount, bAllowDuplicates);
}

//MADDERS: Make MJ12's have random armor skins! Going beyond the limits of other mods... >:) ~TT, 3/21/15
//Also give us cloaking, random inventory, and the grenadier class.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local Texture TChest;
 	local int Seed, Seed2, Seed3;
	local DeusExLevelInfo DXLI;
 	
	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
 	
 	//1111111111111
 	//MADDERS: Obtain a seed.
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 7);
	Seed2 = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 3);
	Seed3 = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
	
 	//MAKE US A GRENADIER! But only above M05.
	//1/9/21: Stop swapping for non-assault gun troops.
 	if ((InitialInventory[0].Inventory == class'WeaponAssaultGun') && (DXLI != None))
 	{
		if ((Seed == 3 || Seed == 5) && (DXLI.MissionNumber > 5))
		{
			if (Seed3 == 2 || Seed3 == 3)
			{
  				InitialInventory[0].Inventory = class'WeaponSawedOffShotgun';
  				InitialInventory[0].Count = 1;
			}
			else
			{
  				InitialInventory[0].Inventory = class'WeaponAssaultShotgun';
  				InitialInventory[0].Count = 1;
  			}
  			InitialInventory[1].Inventory = class'AmmoShell';
  			InitialInventory[1].Count = 5;
			
			if (Seed2 == 0)
			{
				AddToInitialInventory(class'WeaponLAM', 1);
			}
			else
			{
				AddToInitialInventory(class'WeaponEMPGrenade', 1);
			}
			
			Texture = Texture'DeusExCharacters.Skins.VisorTex1';
			MultiSkins[6] = Texture'VMDMJ12TroopTex4NoGoggles';
		}
		else if ((Seed == 6) && (DXLI.MissionNumber > 5))
		{
  			InitialInventory[0].Inventory = class'WeaponRifle';
  			InitialInventory[0].Count = 1;
  			
  			InitialInventory[1].Inventory = class'Ammo3006';
  			InitialInventory[1].Count = 5;
			
			AddToInitialInventory(class'TechGoggles', 1);
		}
 	}
	
 	//1b1b1b1b1b1b1b
 	//MADDERS: Obtain a seed.
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 14);
	
 	//Add ballistic armor, but only at M08 onwards.
 	if ((Seed == 0) && (DXLI != None) && (DXLI.MissionNumber >= 8))
 	{
		AddToInitialInventory(class'BallisticArmor', 1);
	}
 	//Add thermo camo, but only at M10 onwards.
 	else if ((Seed == 4) && (DXLI != None) && (DXLI.MissionNumber >= 10))
 	{
		AddToInitialInventory(class'AdaptiveArmor', 1);
	}
 	
 	//2222222222222
 	//MADDERS: Obtain a seed.
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
 	if ((Seed == 2) && (InitialInventory[3].Inventory == Default.InitialInventory[3].Inventory) && (!bAppliedSpecial))
 	{
  		IC = ObtainRandomGoodie();
  		
  		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

//Raise our health by 15%. Previously 50%.
function CheckHealthScaling()
{
 	if (!bSetupBuffedHealth)
 	{
  		HealthHead = int(float(HealthHead) * 1.1);
  		HealthTorso = int(float(HealthTorso) * 1.1);
  		HealthArmLeft = int(float(HealthArmLeft) * 1.1);
  		HealthArmRight = int(float(HealthArmRight) * 1.1);
  		HealthLegLeft = int(float(HealthLegLeft) * 1.1);
  		HealthLegRight = int(float(HealthLegRight) * 1.1);
  		Health *= 1.1;
  		//GenerateTotalHealth();
 	}
 	
 	Super.CheckHealthScaling();
}

defaultproperties
{
     MedicineSkillLevel=2
     EnviroSkillLevel=2
     
     CarcassType=Class'DeusEx.MJ12TroopCarcass'
     WalkingSpeed=0.296000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponAssaultGun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=12)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponCombatKnife')
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'TranscendedModels.TransGM_Jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
     MultiSkins(1)=Texture'MJ12TroopTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex1'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
     MultiSkins(6)=Texture'VMDMJ12TroopTex4' //MADDERS: Used to be 4. Show us a bit more color.
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="MJ12Troop"
     FamiliarName="MJ12 Trooper"
     UnfamiliarName="MJ12 Trooper"
     NameArticle=" an "
}
