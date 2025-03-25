//=============================================================================
// NSFMechBountyHunter.
//=============================================================================
class NSFMechBountyHunter extends VMDBountyHunter;

function InitializeBountyHunter(int HunterIndex, VMDBufferPlayer VMP, int MissionNumber)
{
	//Universals.
	local int i;
	
	//Clothing stuff.
	local int TClothing, TPants, TCoat, TShirt, TSkin, TFrames, TLenses, FaceIndices[3], PantsIndex;
	local Texture FaceTex;
	
	//Inventory stuff.
	local bool bHasCells;
	local int TMeleeDamage, THealingCount, TSupportCount, TUtilityCount;
	local class<DeusExWeapon> TPrimaryWeapon, TSecondaryWeapon, TMeleeWeapon, TExtraWeapon;
	local class<DeusExAmmo> TPrimaryAmmo, TSecondaryAmmo, TExtraAmmo;
	local class<DeusExPickup> THealingItem, TSupportItem, TUtilityItem, TProtectiveItem;
	
	//GOOFY: Run this up front to know our aug pick rates.
	TSupportItem = ObtainSupportItem(MissionNumber, TSupportCount);
	bHasCells = (TSupportItem == class'BioelectricCell');
	
	//GOOFY: Run this up front to know our face texture.
	//25% chance for a vision aug.
	if ((bHasCells) || (FRand() < 0.25))
	{
		DefaultAugs[1] = class'AugMechTarget';
		if (FRand() > 0.7)
		{
			DefaultAugs[1] = class'AugMechVision';
		}
	}
	
	//GOOFY: We run this in advance so we know what pants to wear.
	//45% chance for speed or sneaking aug, cells regardless.
	if (FRand() < 0.45)
	{
		DefaultAugs[6] = class'AugMechSpeed';
		if (FRand() < 0.65)
		{
			DefaultAugs[6] = class'AugMechStealth';
		}
	}
	
	//1111111111111111111111111111111111
	// Step 1: Decide our appearance.
	FaceIndices[0] = -1;
	FaceIndices[1] = -1;
	FaceIndices[2] = -1;
	TClothing = Rand(2);
	
	//Don't use facemasks when in trench coats. It looks awful.
	if (TClothing == 0)
	{
		TSkin = 5 + Rand(7);
	}
	else
	{
		TSkin = Rand(12);
	}
	TFrames = Rand(2);
	TLenses = Rand(4);
	switch(TClothing)
	{
		case 0: //Trenchcoat look.
			Mesh = LODMesh'TransGM_Trench';
			
			TCoat = Rand(4);
			switch(TCoat)
			{
				case 0: //Smuggler jacket.
					Multiskins[1] = Texture'SmugglerTex2'; //Coat base
					Multiskins[5] = Texture'SmugglerTex2'; //Long coat frills
				break;
				case 1: //Johnny jacket.
					Multiskins[1] = Texture'ThugMaleTex2'; //Coat base
					Multiskins[5] = Texture'PinkMaskTex'; //Long coat frills
				break;
				case 2: //Dowd jacket.
					Multiskins[1] = Texture'StantonDowdTex2'; //Coat base
					Multiskins[5] = Texture'PinkMaskTex'; //Long coat frills
				break;
				case 3: //Jock jacket.
					Multiskins[1] = Texture'JockTex2'; //Coat base
					Multiskins[5] = Texture'PinkMaskTex'; //Long coat frills
				break;
			}
			
			PantsIndex = 2;
			
			TShirt = Rand(6);
			switch(TShirt)
			{
				case 0: //Fairly plain and unassuming shirt.
					Multiskins[4] = Texture'VMDNSFBountyHunterShirt01';
				break;
				case 1: //Fancy shirt, possibly a form of armor.
					Multiskins[4] = Texture'VMDNSFBountyHunterShirt02';
				break;
				case 2: //Incredibly bland and forgettable shirt.
					Multiskins[4] = Texture'VMDNSFBountyHunterShirt03';
				break;
				case 3: //Another simple and unassuming shirt.
					Multiskins[4] = Texture'VMDNSFBountyHunterShirt04';
				break;
				case 4: //Jock's dark and edgy shirt.
					Multiskins[4] = Texture'VMDNSFBountyHunterShirt05';
				break;
				case 5: //Smuggler's sweater[?].
					Multiskins[4] = Texture'VMDNSFBountyHunterShirt06';
				break;
			}
			
			FaceIndices[0] = 0; //Face
			FaceIndices[1] = 3; //Fuck knows what, but uses face texture... Mouth?
			
			if (TSkin > 2)
			{
				switch(TFrames)
				{
					case 0:
						Multiskins[6] = Texture'FramesTex2'; //Frames
					break;
					case 1:
						Multiskins[6] = Texture'FramesTex5'; //Frames
					break;
				}
				switch(TLenses)
				{
					case 0:
						Multiskins[7] = Texture'LensesTex4'; //Lenses
					break;
					case 1:
						Multiskins[7] = Texture'LimeLenses'; //Lenses
					break;
					case 2:
						Multiskins[7] = Texture'PurpleLenses'; //Lenses
					break;
					case 3:
						Multiskins[7] = Texture'RedLenses'; //Lenses
					break;
				}
			}
			else
			{
				Multiskins[6] = Texture'GrayMaskTex'; //Frames
				Multiskins[7] = Texture'BlackMaskTex'; //Lenses
			}
		break;
		case 1: //Jumpsuit look.
			Mesh = LODMesh'MP_Jumpsuit';
			Multiskins[5] = Texture'GrayMaskTex'; //Frames?
			Multiskins[7] = Texture'PinkMaskTex'; //???
			
			PantsIndex = 1;
			
			switch(TSkin)
			{
				//I'm not good enough to make a rolled up sleeve for every skin tone, forgive me.
				//If it makes you feel any better, junkie male 2 tex 0 is out of the running for being too pale.
				case 1:
				case 2:
				case 4:
				case 5:
				case 11:
					TShirt = Rand(3);
				break;
				default:
					TShirt = Rand(5);
				break;
			}
			
			switch(TShirt)
			{
				case 0: //Red terrie armor.
					Multiskins[2] = Texture'VMDNSFBountyHunter2Shirt05';
				break;
				case 1: //All black terrie body armor.
					Multiskins[2] = Texture'VMDNSFBountyHunter2Shirt02';
				break;
				case 2: //Cyan full shirt.
					Multiskins[2] = Texture'VMDNSFBountyHunter2Shirt03';
				break;
				case 3: //Purple rolled up sleeves.
					Multiskins[2] = Texture'VMDNSFBountyHunter2Shirt04';
				break;
				case 4: //All black, rolled up sleeves.
					Multiskins[2] = Texture'VMDNSFBountyHunter2Shirt01';
				break;
			}
			
			FaceIndices[0] = 0; //Face
			FaceIndices[1] = 3; //Fuck knows what, but uses face  texture... Mouth?
			switch(TSkin)
			{
				case 0:
				case 1:
				case 2:
				case 3:
				case 11:
					FaceIndices[2] = 4; //Face mask texture. Thanks, ZP.
				break;
				default:
					Multiskins[4] = Texture'PinkMaskTex'; //Face mask texture. Thanks, ZP.
				break;
			}
			
			switch(TLenses)
			{
				case 0:
					Multiskins[6] = Texture'VMDGogglesTex2'; //Goggles
				break;
				case 1:
					Multiskins[6] = Texture'VMDGogglesTex3'; //Goggles
				break;
				case 2:
					Multiskins[6] = Texture'VMDGogglesTex4'; //Goggles
				break;
				case 3:
					Multiskins[6] = Texture'VMDGogglesTex5'; //Goggles
				break;
			}
		break;
	}
	
	if (DefaultAugs[5] != None)
	{
		TPants = Rand(2);
		switch(TPants)
		{
			case 0: //Lightly augmented legs?
				Multiskins[PantsIndex] = Texture'SamCarterTex2'; //Pants
			break;
			case 1: //Heavily augmented legs
				Multiskins[PantsIndex] = Texture'PantsTex9'; //Pants
			break;
		}
	}
	else
	{
		TPants = Rand(8);
		switch(TPants)
		{
			case 0: //Some casual jeans, two-tone.
				Multiskins[PantsIndex] = Texture'ChadTex2'; //Pants
			break;
			case 1: //Dark pants.
				Multiskins[PantsIndex] = Texture'JockTex3'; //Pants
			break;
			case 2: //JC's pants... But recolored?
				Multiskins[PantsIndex] = Texture'JCDentonTex3'; //Pants
			break;
			case 3: //Dark pants with some leather[?] bits.
				Multiskins[PantsIndex] = Texture'JoJoFineTex2'; //Pants
			break;
			case 4: //Terrie pants.
				Multiskins[PantsIndex] = Texture'JuanLebedevTex3'; //Pants
			break;
			case 5: //Cleaner jeans
				Multiskins[PantsIndex] = Texture'Male2Tex2'; //Pants
			break;
			case 6: //Brown jeans
				Multiskins[PantsIndex] = Texture'MichaelHamnerTex2'; //Pants
			break;
			case 7: //Dark pants wit chain. Badass.
				Multiskins[PantsIndex] = Texture'ThugMaleTex3'; //Pants
			break;
		}
	}
	switch(TSkin)
	{
		case 0: //Terrie mask, standard white dude.
			FaceTex = Texture'TerroristTex0';
		break;
		case 1: //Terrie mask, ethnically ambiguous.
			FaceTex = Texture'Terrorist4Tex0';
		break;
		case 2: //Terrie mask, distinctly person of color.
			FaceTex = Texture'Terrorist2Tex0';
		break;
		case 3: //Fairly generic brunette guy with mask.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDMiscTex6Augged';
			}
			else
			{
				FaceTex = Texture'MiscTex6';
			}
		break;
		case 4: //Eastern asian type appearance, but clean cut like a younger lad.
			//UPDATE: Instead, do one with a mask, because it looks cooler IDK.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDMiscTex7Augged';
			}
			else
			{
				FaceTex = Texture'MiscTex7';
			}
		break;
		case 5: //Gruffer, uncooth guy.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDJunkieMale2Tex0Augged';
			}
			else
			{
				FaceTex = Texture'JunkieMale2Tex0';
			}
		break;
		case 6: //Short haired black dude.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDBumMale9Tex0Augged';
			}
			else
			{
				FaceTex = Texture'BumMale9Tex0';
			}
		break;
		case 7: //Bald guy.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDMikeKaplanTex2Augged';
			}
			else
			{
				FaceTex = Texture'MikeKaplanTex2';
			}
		break;
		case 8: //Seasoned, similarly gruff kind of guy.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDSkinTex17Augged';
			}
			else
			{
				FaceTex = Texture'SkinTex17';
			}
		break;
		case 9: //Clean, professional looking dude.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDSkinTex23Augged';
			}
			else
			{
				FaceTex = Texture'SkinTex23';
			}
		break;
		case 10: //Similarly clean, but slicked blonde guy.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDSkinTex47Augged';
			}
			else
			{
				FaceTex = Texture'SkinTex47';
			}
		break;
		case 11: //Ethnically ambiguous, beanie, suave moustache. Leon looking mother fucker.
			if (DefaultAugs[1] != None)
			{
				FaceTex = Texture'VMDThugMale2Tex3Augged';
			}
			else
			{
				FaceTex = Texture'ThugMale2Tex3';
			}
		break;
	}
	if (FaceIndices[0] > -1) Multiskins[FaceIndices[0]] = FaceTex;
	if (FaceIndices[1] > -1) Multiskins[FaceIndices[1]] = FaceTex;
	if (FaceIndices[2] > -1) Multiskins[FaceIndices[2]] = FaceTex;
	
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
	TMeleeWeapon = ObtainMeleeWeapon(MissionNumber);
	TSecondaryWeapon = ObtainSecondaryWeapon(MissionNumber, TSecondaryAmmo);
	TPrimaryWeapon = ObtainPrimaryWeapon(MissionNumber, TPrimaryAmmo);
	TExtraWeapon = ObtainExtraWeapon(MissionNumber, TExtraAmmo);
	
	THealingItem = ObtainHealingItem(MissionNumber, THealingCount);
	TUtilityItem = ObtainUtilityItem(MissionNumber, TUtilityCount);
	TProtectiveItem = ObtainProtectiveItem(MissionNumber);
	
	if (TMeleeWeapon != None)
	{
		TMeleeDamage = TMeleeWeapon.Default.HitDamage; //Hacky, but augs might want to know this.
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
	bMechAugs = true;
	
	//Always give an arm aug. One is situational, one is passive.
	DefaultAugs[0] = class'AugMechCombat';
	if (TMeleeDamage < 5)
	{
		DefaultAugs[0] = class'AugMechMuscle';
	}
	
	//40% chance for a ballistic protection or cloaking.
	if ((bHasCells) || (FRand() < 0.4))
	{
		DefaultAugs[2] = class'AugMechDermal';
		if (FRand() > 0.75)
		{
			DefaultAugs[2] = class'AugMechCloak';
		}
	}
	
	//45% chance for a energy shield or enviro.
	if ((bHasCells) || (FRand() < 0.25))
	{
		DefaultAugs[3] = class'AugMechEnergy';
	}
	
	//55% chance of gas immunity. Almost did this one wrong.
	if ((bHasCells) || (Frand() < 0.30))
	{
		DefaultAugs[4] = class'AugMechEnviro';
	}
	
	//45% chance for EMP reduction, cells regardless.
	if (FRand() < 0.45)
	{
		DefaultAugs[5] = class'AugMechEMP';
	}
	
	VMDInitializeSubsystems();
	
	//BARF! TESTING!
	AssignedID = 2;
	//Bark bind name work.
	HunterBarkBindName = "NSFBountyHunter"$string(AssignedID+1);
	
	Super.InitializeBountyHunter(HunterIndex, VMP, MissionNumber);
}

function class<DeusExWeapon> ObtainMeleeWeapon(int MissionNumber)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(10);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
			Ret = class'WeaponCombatKnife';
		break;
		case 3:
		case 4:
		case 5:
		case 6:
		case 7:
		case 8:
			Ret = class'WeaponCrowbar';
		break;
		case 9:
			Ret = class'WeaponSword';
		break;
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainSecondaryWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(5);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
			Ret = class'WeaponPistol';
		break;
		case 3:
		case 4:
			Ret = class'WeaponHideagun';
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainPrimaryWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(20);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			Ret = class'WeaponRifle';
		break;
		case 4:
		case 5:
		case 6:
			if (MissionNumber < 5)
			{
				Ret = class'WeaponFlamethrower';
			}
			else
			{
				Ret = class'WeaponPlasmaRifle';
			}
		break;
		case 7:
		case 8:
		case 9:
			Ret = class'WeaponGEPGun';
		break;
		case 10:
		case 11:
			if (MissionNumber > 15)
			{
				Ret = class'WeaponPistol';
			}
		case 12:
		case 13:
		case 14:
			if (Ret == None)
			{
				Ret = class'WeaponAssaultGun';
			}
		break;
		case 15:
		case 16:
		case 17:
		case 18:
		case 19:
			if (MissionNumber < 3 || FRand() < 0.4)
			{
				Ret = class'WeaponSawedOffShotgun';
			}
			else
			{
				Ret = class'WeaponAssaultShotgun';
			}
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
		else if (Ret == class'WeaponGEPGun')
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
		else if (Ret == class'WeaponSawedOffShotgun' || Ret == class'WeaponAssaultShotgun')
		{
			R = Rand(2);
			
			switch(R)
			{
				case 0:
					if ((MissionNumber > 5) && (Ret == class'WeaponAssaultShotgun') && (FRand() < 0.5))
					{
						OutAmmo = class'AmmoDragonsBreath';
					}
					else if ((MissionNumber > 3) && (Ret == class'WeaponSawedOffShotgun') && (FRand() < 0.5))
					{
						OutAmmo = class'AmmoTaserSlug';
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

function class<DeusExWeapon> ObtainExtraWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(10);
	
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
		case 7:
		case 8:
			Ret = class'WeaponGEPGun';
		break;
		case 9:
			Ret = class'WeaponLAW';
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
		
		if (Ret == class'WeaponGEPGun')
		{
			R = Rand(2);
			if (MissionNumber < 10)
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
		else if (Ret == class'WeaponLAW')
		{
			OutAmmo = None;
		}
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
		break;
		case 1:
		case 2:
			ItemCount = 4;
			Ret = class'VMDMedigel';
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
			ItemCount = 1;
			Ret = class'VMDCombatStim';
		break;
		case 1:
		case 2:
			ItemCount = 3;
			Ret = class'BioelectricCell';
		break;
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainUtilityItem(int MissionNumber, out int ItemCount)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(10);
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			ItemCount = 50 * (Rand(5)+1);
			Ret = class'Credits';
		break;
		case 4:
		case 5:
		case 6:
			ItemCount = 1;
			Ret = class'FireExtinguisher';
		break;
		case 7:
		case 8:
			ItemCount = 1;
			Ret = class'TechGoggles';
		break;
		case 9:
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
     Energy=75 //Reduced bio energy vs a player because of outdated technology.
     EnergyMax=75
     bKeepWeaponDrawn=True
     MedkitHealthLevel=150
     MinHealth=40.000000
     WalkingSpeed=0.296000
     AvoidAccuracy=0.100000
     CrouchRate=0.250000
     SprintRate=0.250000
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Health=250
     HealthHead=250
     HealthTorso=250
     HealthLegLeft=250
     HealthLegRight=250
     HealthArmLeft=250
     HealthArmRight=250
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'TranscendedModels.TransGM_Jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.TerroristTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.TerroristTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.TerroristTex1'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.TerroristTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.TerroristTex0'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.GogglesTex1'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="NSFBountyHunter"
     FamiliarName="Bounty Hunter"
     UnfamiliarName="Bounty Hunter"
}
