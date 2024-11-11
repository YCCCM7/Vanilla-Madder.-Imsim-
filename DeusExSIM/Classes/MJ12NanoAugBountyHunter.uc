//=============================================================================
// VMDNanoAugBountyHunter.
//=============================================================================
class MJ12NanoAugBountyHunter extends VMDBountyHunter;

function InitializeBountyHunter(int HunterIndex, VMDBufferPlayer VMP, int MissionNumber)
{
	//Universals.
	local int i;
	
	//Clothing stuff.
	local int TClothing, TCoat, TShirt, TSkin, TLenses, FaceIndices[2], PantsIndex;
	local Texture FaceTex;
	
	//Inventory stuff.
	local bool bHasCells;
	local int TMeleeRange, THealingCount, TSupportCount, TUtilityCount;
	local class<DeusExWeapon> TPrimaryWeapon, TSecondaryWeapon, TMeleeWeapon, TExtraWeapon;
	local class<DeusExAmmo> TPrimaryAmmo, TSecondaryAmmo, TMeleeAmmo, TExtraAmmo;
	local class<DeusExPickup> THealingItem, TSupportItem, TUtilityItem, TProtectiveItem;
	
	//1111111111111111111111111111111111
	// Step 1: Decide our appearance.
	FaceIndices[0] = -1;
	FaceIndices[1] = -1;
	FaceIndices[2] = -1;
	TClothing = Rand(2);
	TSkin = Rand(12);
	switch(TClothing)
	{
		case 0: //Trenchcoat look.
			Mesh = LODMesh'TransGM_Trench';
			
			TCoat = Rand(2);
			switch(TCoat)
			{
				case 0: //Smuggler jacket.
					Multiskins[1] = Texture'SmugglerTex2'; //Coat base
					Multiskins[5] = Texture'SmugglerTex2'; //Long coat frills
				break;
				case 1: //Jock jacket.
					Multiskins[1] = Texture'JosephManderleyTex2'; //Coat base
					Multiskins[5] = Texture'JosephManderleyTex2'; //Long coat frills
				break;
			}
			
			PantsIndex = 2;
			
			Multiskins[4] = Texture'WaltonSimonsTex1';
			
			FaceIndices[0] = 0; //Face
			FaceIndices[1] = 3; //Fuck knows what, but uses face texture... Mouth?
			
			Multiskins[6] = Texture'FramesTex2'; //Frames
			
			TLenses = Rand(3);
			switch(TLenses)
			{
				case 0:
					Multiskins[7] = Texture'LensesTex4'; //Lenses
				break;
				case 1:
					Multiskins[7] = Texture'PurpleLenses'; //Lenses
				break;
				case 2:
					Multiskins[7] = Texture'RedLenses'; //Lenses
				break;
			}
		break;
		case 1: //Jumpsuit look.
			Mesh = LODMesh'TransGM_Suit';
			
			PantsIndex = 1;
			
			TShirt = Rand(3);
			
			switch(TShirt)
			{
				case 0:
					Multiskins[3] = Texture'VMDRevenantSuitTex1';
					Multiskins[4] = Texture'VMDRevenantSuitTex1';
				break;
				case 1:
					Multiskins[3] = Texture'VMDRevenantSuitTex2';
					Multiskins[4] = Texture'VMDRevenantSuitTex2';
				break;
				case 2:
					Multiskins[3] = Texture'VMDRevenantSuitTex3';
					Multiskins[4] = Texture'VMDRevenantSuitTex3';
				break;
			}
			
			FaceIndices[0] = 0; //Face
			FaceIndices[1] = 2; //Fuck knows what, but uses face  texture... Mouth?
		break;
	}
	
	Multiskins[PantsIndex] = Texture'PantsTex5';
	
	switch(TSkin)
	{
		case 0:
			FaceTex = Texture'VMDRevenantFace01';
		break;
		case 1:
			FaceTex = Texture'VMDRevenantFace02';
		break;
		case 2:
			FaceTex = Texture'VMDRevenantFace03';
		break;
		case 3:
			FaceTex = Texture'VMDRevenantFace04';
		break;
		case 4:
			FaceTex = Texture'VMDRevenantFace05';
		break;
		case 5:
			FaceTex = Texture'VMDRevenantFace06';
		break;
		case 6:
			FaceTex = Texture'VMDRevenantFace07';
		break;
		case 7:
			FaceTex = Texture'VMDRevenantFace08';
		break;
		case 8:
			FaceTex = Texture'VMDRevenantFace09';
		break;
		case 9:
			FaceTex = Texture'VMDRevenantFace10';
		break;
		case 10:
			FaceTex = Texture'VMDRevenantFace11';
		break;
		case 11:
			FaceTex = Texture'VMDRevenantFace12';
		break;
	}
	
	if (FaceIndices[0] > -1) Multiskins[FaceIndices[0]] = FaceTex;
	if (FaceIndices[1] > -1) Multiskins[FaceIndices[1]] = FaceTex;
	
	StoredSkin = Skin;
	StoredTexture = Texture;
	StoredFatness = Fatness;
	StoredScaleGlow = ScaleGlow;
	for(i=0; i<ArrayCount(StoredMultiskins); i++)
	{
		StoredMultiskins[i] = Multiskins[i];
	}
	
	//2222222222222222222222222222222222
	// Step 2: Decide our weapons and equipment.
	TMeleeWeapon = ObtainMeleeWeapon(MissionNumber, TMeleeAmmo);
	TSecondaryWeapon = ObtainSecondaryWeapon(MissionNumber, TSecondaryAmmo);
	TPrimaryWeapon = ObtainPrimaryWeapon(MissionNumber, TPrimaryAmmo);
	TExtraWeapon = ObtainExtraWeapon(MissionNumber, TExtraAmmo);
	
	THealingItem = ObtainHealingItem(MissionNumber, THealingCount);
	TSupportItem = ObtainSupportItem(MissionNumber, TSupportCount);
	TUtilityItem = ObtainUtilityItem(MissionNumber, TUtilityCount);
	TProtectiveItem = ObtainProtectiveItem(MissionNumber);
	
	if (TMeleeWeapon != None)
	{
		if (TMeleeAmmo != None)
		{
			AddToInitialInventory(TMeleeAmmo, 2, true);
		}
		TMeleeRange = TMeleeWeapon.Default.MaxRange; //Hacky, but augs might want to know this.
		AddToInitialInventory(TMeleeWeapon, 1, false);
	}
	if (TSecondaryWeapon != None)
	{
		if (TSecondaryAmmo != None)
		{
			AddToInitialInventory(TSecondaryAmmo, 2, true);
		}
		AddToInitialInventory(TSecondaryWeapon, 1, false);
	}
	if (TPrimaryWeapon != None)
	{
		if (TPrimaryAmmo != None)
		{
			AddToInitialInventory(TPrimaryAmmo, 4, true);
		}
		AddToInitialInventory(TPrimaryWeapon, 1, false);
	}
	if (TExtraWeapon != None)
	{
		if (TExtraAmmo != None)
		{
			AddExactAmountToInitialInventory(TExtraAmmo, 1);
		}
		AddToInitialInventory(TExtraWeapon, 1, false);
	}
	
	if (THealingItem != None)
	{
		AddToInitialInventory(THealingItem, THealingCount, true);
	}
	if (TSupportItem != None)
	{
		AddToInitialInventory(TSupportItem, TSupportCount, true);
	}
	if (TUtilityItem != None)
	{
		AddToInitialInventory(TUtilityItem, TUtilityCount, true);
	}
	if (TProtectiveItem != None)
	{
		AddToInitialInventory(TProtectiveItem, 1, true);
	}
	
	SwitchToBestWeapon();
	
	//3333333333333333333333333333333333
	// Step 3: Decide our augs.
	bHasAugmentations = true;
	bMechAugs = false;
	
	//Always give an arm aug. One is situational, one is passive.
	DefaultAugs[0] = class'AugCombat';
	if (TMeleeRange > 96)
	{
		DefaultAugs[0] = class'AugMuscle';
	}
	
	//Always have ballistic aug. We are meta chasers.
	DefaultAugs[1] = class'AugBallistic';
	
	//60% chance of energy shield, 40% it's just cloak.
	if (FRand() < 0.6)
	{
		DefaultAugs[2] = class'AugShield';
	}
	else
	{
		DefaultAugs[2] = class'AugCloak';
	}
	
	//30% chance of ADS. This one's brutal.
	if (Frand() < 0.3)
	{
		DefaultAugs[3] = class'AugDefense';
	}
	
	//28% chance for EMP immunity. Otherwise, give us enviro for gas immunity.
	if (FRand() < 0.28)
	{
		DefaultAugs[4] = class'AugEMP';
	}
	else
	{
		DefaultAugs[5] = class'AugEnviro';
	}
	
	//75% chance for regen aug. Yes. I am a fucking bastard outright. Otherwise give us power recirc.
	if (FRand() < 0.75)
	{
		DefaultAugs[5] = class'AugHealing';
	}
	else
	{
		DefaultAugs[4] = class'AugPower';
	}
	
	//65% chance for targeting, otherwise give us vision aug.
	if (FRand() < 0.65)
	{
		DefaultAugs[6] = class'AugTarget';
	}
	else
	{
		DefaultAugs[6] = class'AugVision';
	}
	
	//60% chance of speed aug, otherwise give us run silent.
	if (FRand() < 0.6)
	{
		DefaultAugs[7] = class'AugSpeed';
	}
	else
	{
		DefaultAugs[7] = class'AugStealth';
	}
	
	VMDInitializeSubsystems();
	
	//Bark bind name work.
	HunterBarkBindName = "MJ12Revenant"$string(AssignedID+1);
	
	Super.InitializeBountyHunter(HunterIndex, VMP, MissionNumber);
}

function VMDModAddWeaponMods(DeusExWeapon DXW)
{
	//MADDERS, 6/25/24: AI doesn't use this, and often times we may not want to, either. Don't add crap.
	/*if ((DXW.bCanHaveScope) && (FRand() < 0.2))
	{
		DXW.bHasScope = true;
	}*/
	if ((DXW.bCanHaveLaser) && (FRand() < 0.25))
	{
		DXW.bHasLaser = true;
	}
	if ((DXW.bCanHaveSilencer) && (FRand() < 0.35))
	{
		DXW.bHasSilencer = true;
	}
	
	//MADDERS, 6/25/24: Don't do this. Too silly.
	/*if ((DXW.bCanHaveModEvolution) && (FRand() < 0.05))
	{
		DXW.bHasEvolution = true;
		DXW.VMDUpdateEvolution();
	}*/
	
	if ((DXW.bCanHaveModBaseAccuracy) && (FRand() < 0.75))
	{
		DXW.ModBaseAccuracy = float(Rand(5)) * 0.1;
	}
	if ((DXW.bCanHaveModReloadCount) && (FRand() < 0.85))
	{
		DXW.ModReloadCount = float(Rand(5)) * 0.1;
	}
	if ((DXW.bCanHaveModAccurateRange) && (FRand() < 0.65))
	{
		DXW.ModAccurateRange = float(Rand(4)) * 0.1;
	}
	if ((DXW.bCanHaveModReloadTime) && (FRand() < 0.6))
	{
		DXW.ModReloadTime = float(Rand(4)) * -0.1;
	}
	if ((DXW.bCanHaveModRecoilStrength) && (FRand() < 0.6))
	{
		DXW.ModRecoilStrength = float(Rand(4)) * -0.1;
	}
	
	DXW.VMDUpdateWeaponModStats();
}

function class<DeusExWeapon> ObtainMeleeWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(10);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
		case 4:
		case 5:
		case 6:
			Ret = class'WeaponNanosword';
		break;
		case 7:
		case 8:
		case 9:
			Ret = class'WeaponProd';
			OutAmmo = class'AmmoBattery';
		break;
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainSecondaryWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(11);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
			Ret = class'WeaponRifle';
		break;
		case 3:
		case 4:
			if (MissionNumber > 15)
			{
				Ret = class'WeaponStealthPistol';
			}
		case 5:
		case 6:
		case 7:
			if (Ret == None)
			{
				Ret = class'WeaponAssaultShotgun';
			}
		break;
		case 8:
		case 9:
		case 10:
			Ret = class'WeaponAssaultGun';
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
		
		if (Ret == class'WeaponRifle')
		{
			R = Rand(2) + int(MissionNumber > 3);
			switch(R)
			{
				case 0:
					OutAmmo = class'Ammo3006';
				break;
				case 1:
					OutAmmo = class'Ammo3006Tranq';
				break;
				case 2:
					OutAmmo = class'Ammo3006HEAT';
				break;
			}
		}
		else if (Ret == class'WeaponAssaultShotgun')
		{
			R = Rand(2);
			
			switch(R)
			{
				case 0:
					if (MissionNumber > 5)
					{
						OutAmmo = class'AmmoDragonsBreath';
					}
					else
					{
						OutAmmo = class'AmmoShell';
					}
				break;
				case 1:
					OutAmmo = class'AmmoSabot';
				break;
			}
		}
		else if (Ret == class'WeaponPistol' || Ret == class'WeaponStealthPistol')
		{
			R = 0;
			if (MissionNumber > 15)
			{
				R = 1;
			}
			
			switch(R)
			{
				case 0:
					OutAmmo = class'Ammo10mm';
				break;
				case 1:
					OutAmmo = class'Ammo10mmHEAT';
				break;
			}
		}
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainPrimaryWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(10);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
			Ret = class'WeaponFlamethrower';
		break;
		case 3:
		case 4:
		case 5:
		case 6:
			Ret = class'WeaponPlasmaRifle';
		break;
		case 7:
		case 8:
		case 9:
			Ret = class'WeaponGEPGun';
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
		
		if (Ret == class'WeaponGEPGun')
		{
			R = Rand(2);
			if (MissionNumber < 5)
			{
				R = 0;
			}
			
			switch(R)
			{
				case 0:
					OutAmmo = class'AmmoRocket';
				break;
				case 1:
					OutAmmo = class'AmmoRocketWP';
				break;
			}
		}
		else if (Ret == class'WeaponPlasmaRifle')
		{
			R = Rand(2);
			if (MissionNumber <= 15)
			{
				R = 0;
			}
			
			switch(R)
			{
				case 0:
					OutAmmo = class'AmmoPlasma';
				break;
				case 1:
					OutAmmo = class'AmmoPlasmaPlague';
				break;
			}
		}
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainExtraWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(7);
	
	switch(R)
	{
		case 0:
		case 1:
			Ret = class'WeaponEMPGrenade';
		break;
		case 2:
		case 3:
			Ret = class'WeaponLAM';
		break;
		case 4:
		case 5:
		case 6:
			Ret = class'WeaponMiniCrossbow';
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainHealingItem(int MissionNumber, out int ItemCount)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(3);
	switch(R)
	{
		case 0:
			ItemCount = 5;
			Ret = class'VMDMedigel';
		break;
		case 1:
		case 2:
			ItemCount = 6;
			Ret = class'Medkit';
		break;
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainSupportItem(int MissionNumber, out int ItemCount)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(3);
	switch(R)
	{
		case 0:
		case 1:
		case 2:
			ItemCount = 8;
			Ret = class'BioelectricCell';
		break;
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainUtilityItem(int MissionNumber, out int ItemCount)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(3);
	switch(R)
	{
		case 0:
		case 1:
			ItemCount = 1;
			Ret = class'FireExtinguisher';
		break;
		case 2:
			ItemCount = 1;
			Ret = class'AdaptiveArmor';
		break;
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainProtectiveItem(int MissionNumber)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(3);
	switch(R)
	{
		case 0:
			Ret = class'HazmatSuit';
		break;
		case 1:
		case 2:
			Ret = class'BallisticArmor';
		break;
	}
	
	return Ret;
}

defaultproperties
{
     Fatness=125 //We are sickly and unhealthy looking.
     MedkitHealthLevel=200
     Energy=75 //Reduced bioenergy because of improper nanoaug implementation.
     EnergyMax=75
     
     //MADDERS additions.
     bDrawShieldEffect=True
     ROFCounterweight=0.000000
     
     WalkingSpeed=0.333333
     bImportant=True
     CloseCombatMult=0.500000
     BaseAssHeight=-23.000000
     BurnPeriod=0.000000
     bHasCloak=False
     CloakThreshold=200 //Use cloak aggressively.
     walkAnimMult=1.400000
     GroundSpeed=240.000000
     Health=300
     HealthHead=300
     HealthTorso=300
     HealthLegLeft=300
     HealthLegRight=300
     HealthArmLeft=300
     HealthArmRight=300
     Mesh=LodMesh'TranscendedModels.TransGM_Suit'
     DrawScale=1.100000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MIBTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex5'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MIBTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MIBTex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.MIBTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.FramesTex2'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.LensesTex3'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionHeight=52.250000
     BindName="MJ12Revenant"
     FamiliarName="MJ12 Revenant"
     UnfamiliarName="MJ12 Revenant"
     NameArticle=" "
}
