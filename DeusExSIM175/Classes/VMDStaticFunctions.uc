//=============================================================================
// VMDStaticFunctions.
// Note: We exist only to reduce the amount of static class loads.
// Otherwise, this would be in GameInfo.
//=============================================================================
class VMDStaticFunctions extends VMDFillerActors abstract;

//PART 1: SEED STUFF VARS!
var string SeedTypes[8], SeedGlossary[8], LongSeedTypes[10];

//PART 4: SKILL AUGMENT TREE SETUP VARS!
var int GemPosX[80], GemPosY[80];
var string TreeLoadIDs[32];
var int TreePosX[32], TreePosY[32];

var localized String TreeLabels[32], TreeGapLabels[16];
var class<Skill> TreeSkills[32];

//111111111111111111111111111111
//SEED STUFF
//111111111111111111111111111111

static function int StripBaseActorSeed(Actor A)
{
 	local string S;
 	local int i;
 	
 	S = string(A);
 	S = Right(S, VMDStringDigits(S));
 	i = int(S);
 	
 	return i;
}

static function int StripBaseTextureSeed(Texture T)
{
 	local string S;
 	local int i;
 	
 	S = string(T);
 	S = Right(S, VMDStringDigits(S));
 	i = int(S);
 	
 	return i;
}

static function string FindSeedType(string SeedName)
{
	local int i;
	local string TST, TSG;
	
	for(i=0; i<8; i++)
	{
		TST = class'VMDStaticFunctions'.Default.SeedTypes[i];
		TSG = class'VMDStaticFunctions'.Default.SeedGlossary[i];
		
		if (TSG ~= SeedName) return TST;
	}
	
	return class'VMDStaticFunctions'.Default.SeedTypes[0];
}

static function int RipSeedChunk(string SeedName, int Position)
{
	local int RipCount, GetPos, i;
	local string TS;
	local Actor A;
	
	TS = FindSeedType(SeedName);
	if (Position > 0)
	{
		for(i=0; i<=Position; i++)
		{
			GetPos = InStr(TS, ";");
			TS = Right(TS, Len(TS) - GetPos - 1);
		}
	}
	else
	{
		TS = Right(TS, Len(TS) - 1);
	}
	GetPos = InStr(TS, ";");
	if (GetPos > -1)
	{
		TS = Left(TS, GetPos);
	}
	
	return int(TS);
}

static function int RipLongSeedChunk(int LongSeedArray, int Position)
{
	local int RipCount, GetPos, i;
	local string TS;
	local Actor A;
	
	TS = Default.LongSeedTypes[LongSeedArray];
	if (Position > 0)
	{
		for(i=0; i<=Position; i++)
		{
			GetPos = InStr(TS, ";");
			TS = Right(TS, Len(TS) - GetPos - 1);
		}
	}
	else
	{
		TS = Right(TS, Len(TS) - 1);
	}
	GetPos = InStr(TS, ";");
	if (GetPos > -1)
	{
		TS = Left(TS, GetPos);
	}
	
	return int(TS);
}

static function int DeriveStableActorSeed(Actor A, optional Int Cap, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int i, LevelOff, DotIn, PlayMod;
 	local VMDBufferPlayer VMP;
 	
	if (A == None) return 0;
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerSeed;
 	
 	if (Cap <= 0) Cap = 10; //Wrap to 10 by default.
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = GetMapSuffixMod(A);		//AlphabetToInt(Use);
 	i = ((i + LevelOff + PlayMod) % Cap);
 	
 	return i;
}

static function int DeriveActorSeed(Actor A, optional Int Cap, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int i, LevelOff, DotIn, PlayMod;
 	local VMDBufferPlayer VMP;
 	
	if (A == None) return 0;
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerSeed;
 	
 	if (Cap <= 0) Cap = 10; //Wrap to 10 by default.
 	S = string(A);
 	S = Right(S, VMDStringDigits(S));
 	i = int(S);
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = GetMapSuffixMod(A);		//AlphabetToInt(Use);
 	i = ((i + LevelOff + PlayMod) % Cap);
 	
 	return i;
}

static function int DeriveAdvancedActorSeed(Actor A, optional Int Cap, optional int DesiredPosition, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int i, LevelOff, PlayMod, AMod;
 	local VMDBufferPlayer VMP;
	
	if (A == None) return 0;
 	
	if (DesiredPosition == 0) DesiredPosition = 1;
	AMod = GetActorNameMod(A, DesiredPosition);
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerSeed;
 	
 	if (Cap <= 0) Cap = 10; //Wrap to 10 by default.
 	S = string(A);
 	S = Right(S, VMDStringDigits(S));
 	i = int(S);
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = GetMapSuffixMod(A);		//AlphabetToInt(Use);
 	i = ((i + LevelOff + PlayMod +AMod) % Cap);
 	
 	return i;
}

static function int DeriveAdvancedActorSeedPreRand(int i, Actor A, optional Int Cap, optional int DesiredPosition, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int LevelOff, PlayMod;
 	local VMDBufferPlayer VMP;
	
	if (A == None) return 0;
 	
	if (DesiredPosition == 0) DesiredPosition = 1;
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerSeed;
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = GetMapSuffixMod(A);
 	i = ((i + LevelOff + PlayMod) % Cap);
 	
 	return i;
}

static function int GetActorNameMod(Actor A, int DesiredPosition)
{
	local string S;
	local int Ret, TA;
	
 	S = Caps(Mid(string(A.Class), DesiredPosition, 1));
 	TA = Asc(S);
 	
 	//A is 65, so 65 &  1 = 1. As A should be 0, invert this.
 	if ((TA & 1) == 0) Ret = 1;
 	return Ret;
}

static function int GetActorNameModFromClass(class<Actor> A, int DesiredPosition)
{
	local string S;
	local int Ret, TA;
	
 	S = Caps(Mid(A, DesiredPosition, 1));
 	TA = Asc(S);
 	
 	//A is 65, so 65 &  1 = 1. As A should be 0, invert this.
 	if ((TA & 1) == 0) Ret = 1;
 	return Ret;
}

static function int GetMapSuffixMod(Actor A)
{
 	local string Ex;
 	local int Ret, TA;
 	
 	Ex = Caps(Right(VMDGetMapName(A), 1));
 	TA = Asc(Ex);
 	
 	//A is 65, so 65 &  1 = 1. As A should be 0, invert this.
 	if ((TA & 1) == 0) Ret = 1;
 	return Ret;
}

static function string VMDGetMapName(Actor A)
{
 	local string S, S2;
 	
 	S = A.GetURLMap();
 	S2 = Chr(92); //What the fuck. Can't type this anywhere!
	
 	//HACK TO FIX TRAVEL BUGS!
 	if (InStr(S, S2) > -1)
 	{
  		do
  		{
   			S = Right(S, Len(S) - InStr(S, S2) - 1);
  		}
  		until (InStr(S, S2) <= -1);

		if (InStr(S, ".") > -1)
		{
  			S = Left(S, Len(S) - 4);
		}
 	}
 	else
	{
		if (InStr(S, ".") > -1)
		{
			S = Left(S, Len(S)-3);
		}
 	}
	
 	return CAPS(S);
}

//MADDERS: Reverse R&D from map fixer. Yoink this shit.
static function int VMDStringDigits(String S)
{
	local int Ret, i, j, CompBlock;
	
	Ret = 1;
	for (i=1; i<5; i++)
	{
		j = int(Right(S, i));
		CompBlock = 10**(i-1);
		
		if (j >= CompBlock)
		{
		 	Ret = i;
		}
	}
	return Ret;
}

//222222222222222222222222222222
//OTHER STUFF
//222222222222222222222222222222

//MADDERs, 12/26/20: From BeyondUnreal's Unreal Wiki.
static final function string VMDLower(coerce string Text)
{
	local int IndexChar;
	
	for (IndexChar = 0; IndexChar < Len(Text); IndexChar++)
	{
		if ((Mid(Text, IndexChar, 1) >= "A") && (Mid(Text, IndexChar, 1) <= "Z"))
		{
			Text = Left(Text, IndexChar) $ Chr(Asc(Mid(Text, IndexChar, 1)) + 32) $ Mid(Text, IndexChar + 1);
		}
	}
	return Text;
}

static function StartCampaign(DeusExPlayer Player, string StoredCampaign)
{
	local VMDBufferPlayer VMP;
	
	//NOTE: Failing to be a VMDBufferPlayer = Play Vanilla again. Emergency "o fuk" switch.
	VMP = VMDBufferPlayer(Player);
	if (VMP == None)
	{
		Player.ShowIntro(True);
	}
	else
	{
		VMP.bGaveNewGameTips = true;
		VMP.SaveConfig();
		
		switch(Caps(StoredCampaign))
		{
			case "VANILLA":
				VMP.ShowIntro(True);
			break;
			case "IWR":
			case "OMEGA":
			case "OTHERZEROFOOD":
			case "OTHERNOINTRO":
			case "OTHERNOFOODNOINTRO":
			case "OTHERPAULNOFOODNOINTRO":
			case "OTHERZEROFOODNOINTRO":
			case "OTHERPAULZEROFOODNOINTRO":
			case "BLOODLIKEVENOM":
				VMP.StartNewGame(VMP.CampaignNewGameMap);
			break;
			default:
				VMP.ShowCustomIntro(VMP.CampaignNewGameMap);
			break;
		}
	}
}

static function float GetPlayerSwimDuration(DeusExPlayer DXP)
{
	local VMDBufferPlayer VMP;
	local float Ret;
	
	if (DXP == None) return 1.0;
	
	VMP = VMDBufferPlayer(DXP);
	Ret = DXP.UnderwaterTime;
	
	return Ret * GetPlayerSwimDurationMult(DXP);
}

static function float GetPlayerSwimDurationMult(DeusExPlayer DXP)
{
	local VMDBufferPlayer VMP;
	local float Mult;
	
	if (DXP == None || DXP.SkillSystem == None) return 1.0;
	
	VMP = VMDBufferPlayer(DXP);
	Mult = DXP.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
	
	//MADDERS, 1/20/21: Reduced scaling if we don't specialize in swimming.
	if (VMP != None)
	{
		if (!VMP.HasSkillAugment("SwimmingDrowningRate"))
		{
			Mult = ((1.0 + Mult) / 2);
		}
		else
		{
			Mult *= 1.25;
		}
	}
	return Mult;
}

static function float GetPlayerWaterSpeed(DeusExPlayer DXP)
{
	local VMDBufferPlayer VMP;
	local float Ret;
	
	if (DXP == None) return 1.0;
	
	VMP = VMDBufferPlayer(DXP);
	Ret = DXP.Default.WaterSpeed;
	
	return Ret * GetPlayerWaterSpeedMult(DXP);
}

static function float GetPlayerWaterSpeedMult(DeusExPlayer DXP)
{
	local VMDBufferPlayer VMP;
	local float Mult;
	
	if (DXP == None || DXP.SkillSystem == None) return 1.0;
	
	VMP = VMDBufferPlayer(DXP);
	Mult = DXP.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
	
	//MADDERS, 1/20/21: Reduced scaling if we don't specialize in swimming.
	if (VMP != None)
	{
		if (!VMP.HasSkillAugment("SwimmingBreathRegen"))
		{
			Mult = ((1.0 + Mult) / 2);
		}
		else
		{
			Mult *= 1.25;
		}
		
		if (VMP.ModWaterSpeedMultiplier >= 0.0)
		{
			Mult *= VMP.ModWaterSpeedMultiplier;
		}
	}
	return Mult;
}

static function AddReceivedItemSmart(DeusExPlayer TPlay, Inventory AddType, int Count)
{
	local DeusExWeapon DXW;
	
	if (TPlay == None|| AddType == None || Count <= 0) return;
	
	DXW = DeusExWeapon(AddType);
	if (DXW == None || DXW.AmmoName == None || DXW.AmmoName.Default.Icon != DXW.Icon || TPlay.FindInventoryType(DXW.AmmoName) == None)
	{
		AddReceivedItem(TPlay, AddType, Count);
	}
}

static function AddReceivedItem(DeusExPlayer TPlay, Inventory AddType, int Count, optional bool bNoRemove)
{
	local DeusexRootWindow DXRW;
	local Inventory altAmmo;
	
	if (TPlay == None || AddType == None || Count <= 0) return;
	
	DXRW = DeusExRootWindow(TPlay.RootWindow);
	if (DXRW == None || DXRW.HUD == None || DXRW.HUD.ReceivedItems == None) return;
	
	//MADDERS, 2/9/21: Clear display per each item now.
        if (!bNoRemove)
	{
		DXRW.HUD.ReceivedItems.RemoveItems();
	}
	DXRW.HUD.ReceivedItems.AddItem(AddType, Count);
	
	// Make sure the object belt is updated
	if (AddType.IsA('Ammo'))
	{
		TPlay.UpdateAmmoBeltText(Ammo(AddType));
	}
	else
	{
		TPlay.UpdateBeltText(AddType);
	}
}

//MADDERS: Optimizing this and making it easier to edit via switch/case.
//Now with a static function version? Hell yeah.
static function bool DamageTypeBleeds(name DType)
{
	switch(DType)
	{
		case 'Stunned':
		case 'TearGas':
		case 'HalonGas':
		case 'PoisonGas':
		case 'DrugDamage':
		case 'Radiation':
		case 'EMP':
		case 'NanoVirus':
		case 'Drowned':
		case 'KnockedOut':
		//case 'Poison':
		case 'PoisonEffect':
		
		//MADDERS: Player specific ones, and also kick I guess.
		case 'OwnedHalonGas':
		case 'Kick':
		case 'Hunger':
		case 'Overdose':
			return false;
		break;
		default:
			return true;
		break;
	}
	return true;
}

static function bool VMDUseDifficultyModifier(Actor Other, string Context)
{
	local VMDBufferPlayer VMP;
	
	if (Other == None)
	{
		Log("WARNING! Failed to be given reference point for difficulty modifier:"@Context);
		return false;
	}
	
	VMP = VMDBufferPlayer(Other);
	if (VMP == None)
	{
		VMP = VMDBufferPlayer(Other.GetPlayerPawn());
	}
	
	if (VMP != None)
	{
		switch(CAPS(Context))
		{
			case "ADVANCED LIMB DAMAGE": return VMP.bAdvancedLimbDamageEnabled; break;
			case "AMMO REDUCTION": return VMP.bAmmoReductionEnabled; break;
			case "BOSS DEATHMATCH": return VMP.bBossDeathmatchEnabled; break;
			case "COMPUTER VISIBILITY": return VMP.bComputerVisibilityEnabled; break;
			case "DOG JUMP": return VMP.bDogJumpEnabled; break;
			case "DOOR NOISE": return VMP.bDoorNoiseEnabled; break;
			case "DRAW MELEE": return VMP.bDrawMeleeEnabled; break;
			case "ENEMY DAMAGE GATE": return VMP.bEnemyDamageGateEnabled; break;
			case "ENEMY DISARM EXPLOSIVES": return VMP.bEnemyDisarmExplosivesEnabled; break;
			case "ENEMY GEP LOCK": return VMP.bEnemyGEPLockEnabled; break;
			case "ENEMY VISION EXTENSION": return VMP.bEnemyVisionExtensionEnabled; break;
			case "KILLSWITCH HEALTH": return VMP.bKillswitchHealthEnabled; break;
			case "LOOT DELETION": return VMP.bLootDeletionEnabled; break;
			case "LOOT SWAP": return VMP.bLootSwapEnabled; break;
			case "MAYHEM": case "INFAMY": return VMP.bMayhemSystemEnabled; break;
			case "NOTICE BUMPING": return VMP.bNoticeBumpingEnabled; break;
			case "RECOGNIZE MOVED OBJECTS": return VMP.bRecognizeMovedObjectsEnabled; break;
			case "RELOAD NOISE": return VMP.bReloadNoiseEnabled; break;
			case "SAVE GATE": return VMP.bSaveGateEnabled; break;
			case "SHOOT EXPLOSIVES": return VMP.bShootExplosivesEnabled; break;
			case "SMART ENEMY WEAPON SWAP": return VMP.bSmartEnemyWeaponSwapEnabled; break;
			
			//case "SEE LASER": return VMP.bSeeLaserEnabled; break;
		}
	}
	return false;
}

//MADDERS, 3/23/21: More than 1 combat skill investment + Gallows = Save Gate.
static function bool UseGallowsSaveGate(Actor Other)
{
	local VMDBufferPlayer VMP;
	local Skill TSkill;
	local int CombatTotal;
	
	VMP = VMDBufferPlayer(Other.GetPlayerPawn());
	
	if ((VMP != None) && (VMP.SaveGateCombatThreshold > -1) && (VMDUseDifficultyModifier(VMP, "Save Gate")))
	{
		forEach Other.AllActors(class'Skill', TSkill)
		{
			if ((TSkill != None) && (TSkill.Player == VMP))
			{
				switch(TSkill.Class)
				{
					case class'SkillDemolition':
					case class'SkillWeaponHeavy':
					case class'SkillWeaponLowTech':
					case class'SkillWeaponPistol':
					case class'SkillWeaponRifle':
						CombatTotal += TSkill.CurrentLevel;
					break;
					default:
					break;
				}
			}
			if (CombatTotal >= VMP.SaveGateCombatThreshold)
			{
				return true;
			}
		}
	}
	return false;
}

static function float AdjustFOV(float InFOV, Actor InPlay)
{
	local float RetFOV;
	local DeusExPlayer Player;
	
	Player = DeusExPlayer(InPlay);
	if ((Player != None) && (Player.RootWindow != None))
	{
		//G-Flex: we want to correct for aspect ratio here
		//G-Flex: first, get the vFoV we'd have at 4:3
		RetFOV = (2 * atan(tan((InFOV * 0.0174533)/2.00) * (3.00/4.00)));
		//G-Flex: then, get the matching hFoV at current res, in degrees
		RetFOV = 57.2957795 * (2 * atan(tan(RetFOV/2.00) * (Player.rootWindow.width/Player.rootWindow.height)));
	}
	
	return RetFOV;
}

//333333333333333333333333333333
//AMMO RAND
//333333333333333333333333333333

//GetWeaponAmmoReturnRange()
static function int GWARR(DeusExWeapon DXW, DeusExAmmo DXA, VMDBufferPlayer VMP)
{
	if (DXA == None) return 0;
	if (AmmoNone(DXA) != None) return 0;
	
	if ((DXW != None) && (DXW.bHandToHand) && (!DXW.bInstantHit) && (DXW.GoverningSkill == class'SkillDemolition'))
	{
		return 1;
	}
	//MADDERS: Make ammo pickup not suck. Scales with ceiling. Lower ceilings as needed.
	return (DXA.VMDConfigureMaxAmmo() / 50) + 1;
}

//GetWeaponAmmoReturnRangeRand
static function int GWARRRand(int ResultFloor, int RandFloor, DeusExWeapon DXW, DeusExAmmo DXA, VMDBufferPlayer VMP)
{
	local int Ret;
	
	if (DXA == None) return 0;
	if (AmmoNone(DXA) != None) return 0;
	
	Ret = GWARR(DXW, DXA, VMP);
	Ret = Max(RandFloor+1, Ret);
	if (Ret < 2)
	{
		Ret = 0;
	}
	else
	{
		Ret = Rand(Ret);
	}
	if (Ret < ResultFloor) Ret = ResultFloor;
	
	//MADDERS: Make ammo pickup not suck. Scales with ceiling. Lower ceilings as needed.
	if ((DXW != None) && (DXW.FiringSystemOperation == 2) && (VMP != None) && (VMP.HasSkillAugment("TagTeamOpenChamber")))
	{
		Ret += 1;
	}
	if (VMDUseDifficultyModifier(DXA, "Ammo Reduction"))
	{
		Ret = Max(1, Ret-1);
	}
	
	return Ret;
}

//GetWeaponAmmoReturnAdditive
static function int GWARAdd(DeusExWeapon DXW, VMDBufferPlayer VMP)
{
	local int Ret;
	
	Ret = 0;
	
	//MADDERS: Make ammo pickup not suck. Scales with ceiling. Lower ceilings as needed.
	if ((DXW != None) && (DXW.FiringSystemOperation == 2) && (VMP != None) && (VMP.HasSkillAugment("TagTeamOpenChamber")))
	{
		Ret++;
	}
	if (VMDUseDifficultyModifier(VMP, "Ammo Reduction"))
	{
		Ret--;
	}
	
	return Ret;
}

static function bool TargetIsMayhemable(Actor Other)
{
	if (ScriptedPawn(Other) == None) return false;
	
	if ((Animal(Other) == None) && (Robot(Other) == None)) return true;
	
	switch(Other.Class.Name)
	{
		case 'Doberman':
		case 'Mutt':
		case 'Karkian':
		case 'Greasel':
		case 'Gray':
			return true;
		break;
	}
	
	return false;
}

//444444444444444444444444444444
//SKILL AUGMENT TREE SETUP
//444444444444444444444444444444

//-----------------------------
//1. Pistols
//-----------------------------
static function CreatePistolsTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "PistolFocus";
	TSkillAugments[1] = "PistolModding";
	TSkillAugments[2] = "PistolReload";
	TSkillAugments[3] = "PistolAltAmmos";
	TSkillAugments[4] = "PistolScope";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 0);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 0);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 0, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 0, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//2. Rifles
//-----------------------------
static function CreateRiflesTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "RifleFocus";
	TSkillAugments[1] = "RifleModding";
	TSkillAugments[2] = "RifleOperation";
	TSkillAugments[3] = "RifleAltAmmos";
	TSkillAugments[4] = "RifleReload";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 0);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 0);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 0, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 0, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+2;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+2;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//1/2. Firing Systems
//-----------------------------
static function CreateFiringSystemsTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[4];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra" || RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "TagTeamClosedWaterproof";
	TSkillAugments[1] = "TagTeamOpenDecayRate";
	TSkillAugments[2] = "TagTeamClosedHeadshot";
	TSkillAugments[3] = "TagTeamOpenChamber";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 0);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), "FillerTextSystems");
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 0);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), "FillerTextSystems");
		}
		Count++;
	}
	
	TreeArrayCount = 3;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 0, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 0, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+2] = -2; //Horizontal
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+2] = -2; //Horizontal
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//3. Heavy
//-----------------------------
static function CreateHeavyTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[6];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "HeavyFocus";
	TSkillAugments[1] = "HeavySpeed";
	TSkillAugments[2] = "HeavyDropAndRoll";
	TSkillAugments[3] = "HeavySwapSpeed";
	TSkillAugments[4] = "HeavyProjectileSpeed";
	TSkillAugments[5] = "HeavyPlasma";
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 1, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 1, false);
		}
		TreeCount++;
	}
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 1);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 1);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+1;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+4;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+1;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+4;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//4. Demolition
//-----------------------------
static function CreateDemolitionTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[7];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra" || RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "DemolitionMines";
	TSkillAugments[1] = "DemolitionEMP";
	TSkillAugments[2] = "DemolitionTearGas";
	TSkillAugments[3] = "DemolitionLooting";
	TSkillAugments[4] = "DemolitionMineHandling";
	TSkillAugments[5] = "DemolitionScrambler";
	TSkillAugments[6] = "DemolitionGrenadeMaxAmmo";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 1);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 1);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 1, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 1, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+6;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+2] = Count-ArrayCount(TSkillAugments)+1;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+6;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+2] = Count-ArrayCount(TSkillAugments)+1;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//5. Low Tech
//-----------------------------
static function CreateLowTechTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "MeleeProjectileLooting";
	TSkillAugments[1] = "MeleeBatonHeadshots";
	TSkillAugments[2] = "MeleeSwingSpeed";
	//TSkillAugments[3] = "MeleeDoorScouting";
	TSkillAugments[3] = "MeleeStunDuration";
	TSkillAugments[4] = "MeleeAssassin";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 2);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 2);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 2, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 2, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+1;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+1;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//6. Lockpicking
//-----------------------------
static function CreateLockpickingTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra" || RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "LockpickScoutNoise";
	TSkillAugments[1] = "LockpickPickpocket";
	TSkillAugments[2] = "LockpickScent";
	TSkillAugments[3] = "LockpickCapacity";
	TSkillAugments[4] = "LockpickStartStealth"; //Swapping 3 and 4 for ordering sake.
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 2);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 2);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 1;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 2, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 2, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//5/6. Burglar
//-----------------------------
static function CreateBurglarTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[2];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra" || RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "TagTeamDoorCrackingWood";
	TSkillAugments[1] = "TagTeamDoorCrackingMetal";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 2);
			
			if (i == 0) PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
			else PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), "FillerTextBurglar");
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 2);
			
			if (i == 0) MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
			else MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), "FillerTextBurglar");
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 2, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 2, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//7. Tech, AKA Electronics
//-----------------------------
static function CreateTechTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[6];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra" || RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "ElectronicsFailNoise";
	TSkillAugments[1] = "ElectronicsSpeed";
	TSkillAugments[2] = "ElectronicsKeypads";
	TSkillAugments[3] = "ElectronicsAlarms";
	TSkillAugments[4] = "ElectronicsCapacity";
	TSkillAugments[5] = "ElectronicsTurrets";
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 3, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 3, false);
		}
		TreeCount++;
	}
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 3);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 3);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+3;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+3;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+3;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+3;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//8. Computer(s)
//-----------------------------
static function CreateComputerTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "ComputerScaling";
	TSkillAugments[1] = "ComputerTurrets";
	TSkillAugments[2] = "ComputerSpecialOptions";
	TSkillAugments[3] = "ComputerATMQuality";
	TSkillAugments[4] = "ComputerLockout";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 3);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 3);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 3, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 3, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+1;
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+1;
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//7/8. Hacking
//-----------------------------
static function CreateHackingTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
}

//-----------------------------
//9. Fitness (AKA Swimming)
//-----------------------------
static function CreateFitnessTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra" || RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "SwimmingBreathRegen";
	TSkillAugments[1] = "SwimmingFallRoll";
	TSkillAugments[2] = "SwimmingRoll";
	TSkillAugments[3] = "SwimmingDrowningRate";
	TSkillAugments[4] = "SwimmingFitness";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 4);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 4);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 2;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 4, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 4, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments)+1;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//10. Tactical Gear (AKA Enviro)
//-----------------------------
static function CreateTacticalGearTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Cassandra") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "EnviroDeactivate";
	TSkillAugments[1] = "EnviroCopies";
	TSkillAugments[2] = "EnviroCopyStacks";
	TSkillAugments[3] = "EnviroSmallWeapons";
	TSkillAugments[4] = "EnviroDurability";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 4);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 4);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	
	TreeArrayCount = 3;
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 4, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 4, false);
		}
		TreeCount++;
	}
	
	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+2] = Count-ArrayCount(TSkillAugments);
		PerWin.TreeOwners[TreeCount-TreeArrayCount+3] = Count-ArrayCount(TSkillAugments)+1;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+1] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+2] = Count-ArrayCount(TSkillAugments);
		MenWin.TreeOwners[TreeCount-TreeArrayCount+3] = Count-ArrayCount(TSkillAugments)+1;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

//-----------------------------
//9/10. Swimmming (Gear)
//-----------------------------
static function CreateSwimmingTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
}

//-----------------------------
//11. Medicine
//-----------------------------
static function CreateMedicineTree(Window InWin, int Count, int TreeCount, out int OutCount, out int OutTreeCount, string RelString)
{
	local string CurSkillAugment, CurLoadID, TSkillAugments[5];
	local int i, SkillAugmentPos, TreeArrayCount;
	
	local VMDPersonaScreenSkillAugments PerWin;
	local VMDMenuSelectSkillAugments MenWin;
	local bool bPer;
	local VMDBufferPlayer VMP;
	local VMDSkillAugmentManager VMSA;
	local VMDSkillAugmentGem TGem;
	local class<VMDSkillAugmentGem> UseClass;
	
	UseClass = class'VMDSkillAugmentGem';
	if (RelString ~= "Burden") UseClass = class'VMDSkillAugmentGemInvisible';
	
	PerWin = VMDPersonaScreenSkillAugments(InWin);
	MenWin = VMDMenuSelectSkillAugments(InWin);
	
	if ((PerWin == None) && (MenWin == None)) return;
	
	if (PerWin != None)
	{
		VMP = PerWin.VMP;
		bPer = true;
	}
	else
	{
		VMP = MenWin.VMP;
	}
	if (VMP == None) return;
	
	VMSA = VMP.SkillAugmentManager;
	if (VMSA == None) return;
	
	TSkillAugments[0] = "MedicineStress";
	TSkillAugments[1] = "MedicineWraparound";
	TSkillAugments[2] = "MedicineMedbotRecharge";
	TSkillAugments[3] = "MedicineCapacity";
	TSkillAugments[4] = "MedicineRevive";
	
	for (i=0; i<ArrayCount(TSkillAugments); i++)
	{
		CurSkillAugment = TSkillAugments[i];
		SkillAugmentPos = VMP.SkillAugmentArrayOf(CurSkillAugment);
		if (bPer)
		{
			PerWin.SetGemList(Count, VMDSkillAugmentGem(PerWin.NewChild(UseClass)));
			PerWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 5);
			PerWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		else
		{
			MenWin.SetGemList(Count, VMDSkillAugmentGem(MenWin.NewChild(UseClass)));
			MenWin.SetSkillData(Count, CurSkillAugment, VMSA.SkillAugmentNames[SkillAugmentPos], VMSA.SkillAugmentDescs[SkillAugmentPos], VMSA.SkillAugmentLevelRequired[SkillAugmentPos], VMSA.SecondarySkillAugmentLevelRequired[SkillAugmentPos], 5);
			MenWin.SetSkillData2(Count, VMP.GetSkillAugmentSkillRequired(SkillAugmentPos), VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentPos), string(VMP.GetSkillAugmentSkillRequired(SkillAugmentPos)));
		}
		Count++;
	}
	TreeArrayCount = 1;
	
	for (i=0; i<TreeArrayCount; i++)
	{
		CurLoadID = Default.TreeLoadIDs[TreeCount];
		if (bPer)
		{
			PerWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(PerWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			PerWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 5, false);
		}
		else
		{
			MenWin.TreeBits[TreeCount] = VMDSkillAugmentTreeBranch(MenWin.NewChild(class'VMDSkillAugmentTreeBranch'));
			MenWin.TreeBits[TreeCount].SetTreeData(CurLoadID, 5, false);
		}
		TreeCount++;
	}

	//Manually set tree branch owners.
	if (bPer)
	{
		PerWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+4;
	}
	else
	{
		MenWin.TreeOwners[TreeCount-TreeArrayCount] = Count-ArrayCount(TSkillAugments)+4;
	}
	
	OutCount = Count;
	OutTreeCount = TreeCount;
}

static function int GetGemPosX(int i)
{
	return Default.GemPosX[i];
}
static function int GetGemPosY(int i)
{
	return Default.GemPosY[i];
}
static function int GetTreePosX(int i)
{
	return Default.TreePosX[i];
}
static function int GetTreePosY(int i)
{
	return Default.TreePosY[i];
}

static function string GetTreeLabel(int i)
{
	return Default.TreeLabels[i];
}
static function string GetTreeGapLabel(int i)
{
	return Default.TreeGapLabels[i];
}
static function class<Skill> GetTreeSkill(int i)
{
	return Default.TreeSkills[i];
}

defaultproperties
{
    SeedTypes(0)=";1;7;5;13;4;19;20;18;0;2;9;11;15;8;14;17;3;6;10;12;16"
    SeedTypes(1)=";1;7;5;13;4;19;20;18;0;2;9;11;15;8;14;17;3;6;10;12;16"
    SeedTypes(2)=";0;5;12;7;8;9;19;17;15;11;4;18;3;13;2;14;20;1;6;16;10;20"
    SeedTypes(3)=";1;13;4;10;9;5;18;19;14;11;0;8;15;20;3;2;12;6;17;16;7;20"
    SeedTypes(4)=";1;13;4;10;9;5;18;19;14;11;0;8;15;20;3;2;12;6;17;16;7;20"
    SeedTypes(5)=";0;5;12;7;8;9;19;17;15;11;4;18;3;13;2;14;20;1;6;16;10;20"
    SeedTypes(6)=";0;5;12;7;8;9;19;17;15;11;4;18;3;13;2;14;20;1;6;16;10;20;1;13;4;10;9;5;18;19;14;11;0;8;15;20;3;2;12;6;17;16;7;20"
    LongSeedTypes(0)="41;33;42;9;90;36;39;12;91;67;55;43;25;3;98;48;0;54;65;19;29;30;66;82;89;50;15;61;8;95;58;69;45;72;44;4;75;22;68;13;96;93;7;70;23;85;63;71;28;24;73;16;77;37;83;49;78;26;17;2;86;18;51;80;40;46;79;38;53;97;52;57;94;76;62;10;88;56;31;1;20;81;99;21;92;34;32;47;5;6;64;59;27;87;84;11;35;60;74;14"
    LongSeedTypes(1)="76;27;53;12;42;86;67;88;31;18;59;46;71;63;65;26;35;81;24;64;94;54;49;8;92;69;51;15;98;1;45;74;82;58;28;25;6;0;50;83;78;33;96;48;19;37;3;30;41;43;29;47;70;93;68;44;85;17;66;13;16;21;95;2;34;32;97;84;99;62;5;52;36;61;55;75;77;23;38;89;7;20;90;11;22;10;57;39;87;79;91;80;56;60;14;9;72;73;40;4"
    LongSeedTypes(2)="1;46;63;26;76;51;59;56;21;49;9;62;52;92;96;94;95;70;90;2;89;88;19;60;68;78;55;10;85;28;25;34;12;64;72;29;97;7;53;31;47;23;0;73;16;77;69;80;50;54;91;37;32;5;57;24;74;39;81;13;75;33;65;83;99;93;61;86;40;15;38;82;58;79;22;17;20;11;36;30;42;44;3;43;66;45;48;6;87;67;71;84;18;4;27;98;8;41;14;35"
    LongSeedTypes(3)="17;7;9;38;57;95;68;12;45;16;13;22;42;19;41;94;37;6;54;60;32;27;79;20;78;23;24;39;36;56;21;26;5;53;89;25;11;83;66;69;72;4;61;59;31;51;63;93;70;74;10;2;96;80;90;92;55;91;14;35;49;48;15;86;73;75;0;97;87;64;84;44;85;34;46;18;28;65;1;50;52;43;29;8;99;71;47;98;30;76;40;81;62;67;82;58;3;33;88;77"
    LongSeedTypes(4)="78;18;73;27;83;39;99;37;7;53;34;25;90;91;66;56;13;28;40;58;59;97;43;64;4;0;49;17;51;26;71;32;63;30;11;87;70;38;10;22;29;88;36;84;45;41;60;89;69;94;75;31;35;48;8;61;55;9;68;14;65;74;44;96;77;15;6;85;72;16;47;57;19;62;2;21;52;20;92;5;42;86;98;79;95;93;82;24;54;23;3;1;46;81;33;76;80;67;50;12"
    LongSeedTypes(5)="98;72;46;74;59;16;79;55;82;22;42;27;88;48;13;69;12;64;21;8;60;77;89;52;29;54;53;38;83;31;39;87;43;65;41;9;26;80;0;86;6;10;51;61;20;36;71;76;33;24;37;67;78;17;66;50;70;57;85;7;4;56;96;47;94;90;97;14;11;25;45;15;84;1;2;75;30;32;23;73;3;58;92;68;63;35;44;93;18;28;99;49;81;34;95;40;91;5;62;19"
    LongSeedTypes(6)="21;93;15;92;29;74;62;95;11;81;89;48;25;4;49;96;46;28;91;69;3;45;35;32;84;19;98;40;97;38;70;44;88;90;43;9;31;23;10;30;42;87;12;68;53;83;47;57;2;64;27;77;26;86;56;41;66;78;50;75;51;34;20;52;65;79;58;16;61;22;8;54;33;82;85;17;18;80;39;1;36;73;6;13;5;71;67;76;37;59;0;72;24;55;99;60;94;14;63;7"
    LongSeedTypes(7)="92;72;40;33;24;15;5;69;27;78;90;44;17;67;47;77;22;18;63;1;83;54;8;57;34;23;7;32;11;56;52;84;28;96;43;12;70;60;51;3;19;36;35;53;81;30;0;58;16;31;73;26;25;9;74;87;75;94;41;85;14;89;13;48;64;45;82;21;4;86;95;46;42;55;65;10;93;99;71;38;88;68;80;62;37;39;91;97;79;61;49;98;50;29;76;59;6;66;2;20"
    LongSeedTypes(8)="72;76;67;73;13;32;52;20;16;44;80;71;15;92;22;40;83;48;95;36;75;35;24;1;26;28;43;0;98;57;38;18;96;64;61;42;66;74;6;8;46;37;49;70;7;99;10;62;39;77;91;97;60;14;82;59;68;47;2;21;65;33;93;50;25;85;23;45;81;89;56;5;88;87;53;17;3;9;29;41;84;4;34;12;51;30;55;63;27;79;78;90;11;31;58;94;69;54;86;19"
    LongSeedTypes(9)="60;29;62;25;13;21;14;49;97;64;48;79;87;36;61;55;65;45;52;12;59;50;38;5;7;1;47;93;41;82;42;40;11;85;83;44;81;8;53;71;43;73;95;24;34;94;84;4;17;91;80;33;66;18;3;78;10;46;77;72;88;70;30;2;76;37;58;0;99;31;27;6;74;23;32;28;19;96;90;86;68;54;9;22;35;63;51;56;67;15;69;26;75;16;39;20;57;89;92;98"
    
    SeedGlossary(0)="Food Desc"
    SeedGlossary(1)="Addiction"
    SeedGlossary(2)="Picking 1"
    SeedGlossary(3)="Picking 2"
    SeedGlossary(4)="Hacking 1"
    SeedGlossary(5)="Hacking 2"
    SeedGlossary(6)="Ammo Looting"
    
    //---------------------
    //TREE STUFF!
    //=====================
     //Page 1.
     TreeLabels(0)="Pistols"
     TreeSkills(0)=class'SkillWeaponPistol'
     TreeGapLabels(0)="Ballistic Specialist"
     TreeLabels(1)="Rifles"
     TreeSkills(1)=class'SkillWeaponRifle'
     
     //Page 2.
     TreeLabels(2)="Heavy"
     TreeSkills(2)=class'SkillWeaponHeavy'
     TreeGapLabels(1)=""
     TreeLabels(3)="Demolition"
     TreeSkills(3)=class'SkillDemolition'
     
     //Page 3.
     TreeLabels(4)="Low Tech"
     TreeSkills(4)=class'SkillWeaponLowTech'
     TreeGapLabels(2)="Burglary"
     TreeLabels(5)="Infiltration"
     TreeSkills(5)=class'SkillLockpicking'
     
     //Page 4.
     TreeLabels(6)="Electronics"
     TreeSkills(6)=class'SkillTech'
     TreeGapLabels(3)="" //Hacking
     TreeLabels(7)="Computers"
     TreeSkills(7)=class'SkillComputer'
     
     //Page 5.
     TreeLabels(8)="Fitness"
     TreeSkills(8)=class'SkillSwimming'
     TreeGapLabels(4)="" //Swimming Gear
     TreeLabels(9)="Tactical Gear"
     TreeSkills(9)=class'SkillEnviro'
     
     //Page 6.
     TreeLabels(10)="Medicine"
     TreeSkills(10)=class'SkillMedicine'
     TreeGapLabels(5)=""
     
     //---------------
     //GEM POSITIONS
     //---------------
     //1. Pistols
     GemPosX(0)=42
     GemPosY(0)=128
     GemPosX(1)=106
     GemPosY(1)=128
     GemPosX(2)=170
     GemPosY(2)=128
     GemPosX(3)=42
     GemPosY(3)=192
     GemPosX(4)=106
     GemPosY(4)=192
     
     TreeLoadIDs(0)="SkillAugmentTreeBranchVertical"
     TreePosX(0)=42
     TreePosY(0)=160
     TreeLoadIDs(1)="SkillAugmentTreeBranchVertical"
     TreePosX(1)=106
     TreePosY(1)=160
     
     //---------------
     //2. Rifles
     GemPosX(5)=406
     GemPosY(5)=128
     GemPosX(6)=470
     GemPosY(6)=128
     GemPosX(7)=534
     GemPosY(7)=128
     GemPosX(8)=406
     GemPosY(8)=192
     GemPosX(9)=534
     GemPosY(9)=192
     
     TreeLoadIDs(2)="SkillAugmentTreeBranchVertical"
     TreePosX(2)=406
     TreePosY(2)=160
     TreeLoadIDs(3)="SkillAugmentTreeBranchVertical"
     TreePosX(3)=534
     TreePosY(3)=160
     
     //---------------
     //1/2. Firing Systems
     GemPosX(10)=254
     GemPosY(10)=160
     GemPosX(11)=320
     GemPosY(11)=160
     GemPosX(12)=254
     GemPosY(12)=224
     GemPosX(13)=320
     GemPosY(13)=224
     
     TreeLoadIDs(4)="SkillAugmentTreeBranchVertical"
     TreePosX(4)=254
     TreePosY(4)=192
     TreeLoadIDs(5)="SkillAugmentTreeBranchVertical"
     TreePosX(5)=320
     TreePosY(5)=192
     TreeLoadIDs(6)="SkillAugmentTreeBranchHorizontalHighlight" //Wicked hack. Disappears when one is bought.
     TreePosX(6)=287
     TreePosY(6)=160
     
     //---------------
     //3. Heavy
     GemPosX(14)=42 //Heavy Focus
     GemPosY(14)=128
     GemPosX(15)=90 //Heavy Posture
     GemPosY(15)=128
     GemPosX(16)=138 //Stop, Drop...
     GemPosY(16)=128
     GemPosX(17)=90 //Heavy Swap Speed
     GemPosY(17)=192
     GemPosX(18)=186 //Heavy Projectile Speed
     GemPosY(18)=128
     GemPosX(19)=186 //Danger close
     GemPosY(19)=192
     
     TreeLoadIDs(7)="SkillAugmentTreeBranchVertical"
     TreePosX(7)=90
     TreePosY(7)=160
     TreeLoadIDs(8)="SkillAugmentTreeBranchVertical"
     TreePosX(8)=186
     TreePosY(8)=160
     
     //---------------
     //4. Demolition
     //NOTE: Sorting is jumbled, for ease of access.
     GemPosX(20)=390 //I'm actually for placing mines
     GemPosY(20)=128
     GemPosX(21)=438 //EMP is the same
     GemPosY(21)=128
     GemPosX(22)=486 //And I'm actually for tear gas
     GemPosY(22)=128
     GemPosX(23)=534 //And I'm actually for looting
     GemPosY(23)=192
     GemPosX(24)=342 //I'm actually for frequencies
     GemPosY(24)=128
     GemPosX(25)=438 //Scrambler is 1.5x spaced, vertically.
     GemPosY(25)=192
     GemPosX(26)=534 //Grenade max ammo.
     GemPosY(26)=128
     
     TreeLoadIDs(9)="SkillAugmentTreeBranchVertical"
     TreePosX(9)=534
     TreePosY(9)=160
     TreeLoadIDs(10)="SkillAugmentTreeBranchVertical"
     TreePosX(10)=438
     TreePosY(10)=160
     
     //---------------
     //5. Low Tech
     GemPosX(27)=42 //Retreive projectiles
     GemPosY(27)=128
     GemPosX(28)=90 //Baton noise
     GemPosY(28)=128
     GemPosX(29)=170 //Swing Speed. Switcheroo.
     GemPosY(29)=192
     //GemPosX(30)=186 //Door scouting. Switcheroo.
     //GemPosY(30)=128
     GemPosX(30)=58 //Stun duration
     GemPosY(30)=192
     GemPosX(31)=122 //Kill noise. Yay.
     GemPosY(31)=192
     
     TreeLoadIDs(11)="SkillAugmentTreeBranchVertical"
     TreePosX(11)=90
     TreePosY(11)=160
     TreeLoadIDs(12)="SkillAugmentTreeBranchHorizontalTUp"
     TreePosX(12)=90
     TreePosY(12)=192
     
     //---------------
     //6. Lockpicking
     GemPosX(32)=438
     GemPosY(32)=128
     GemPosX(33)=486
     GemPosY(33)=128
     GemPosX(34)=534
     GemPosY(34)=128
     GemPosX(35)=390 //Actually lockpick capacity
     GemPosY(35)=192
     GemPosX(36)=438 //And I'm actually starting picking stealth
     GemPosY(36)=192
     
     TreeLoadIDs(13)="SkillAugmentTreeBranchVertical"
     TreePosX(13)=438
     TreePosY(13)=160
     
     //---------------
     //5/6. Burglar
     GemPosX(37)=220
     GemPosY(37)=128
     GemPosX(38)=282
     GemPosY(38)=156
     //GemPosX(37)=248
     //GemPosY(37)=220
     
     TreeLoadIDs(14)="SkillAugmentTreeBranchHorizontalBranchDown"
     TreePosX(14)=251
     TreePosY(14)=142
     TreeLoadIDs(15)="BLACKMASKTEX"
     TreePosX(15)=232
     TreePosY(15)=188
     
     //---------------
     //7. Tech, AKA Electronics
     GemPosX(39)=42
     GemPosY(39)=128
     GemPosX(40)=90
     GemPosY(40)=128
     GemPosX(41)=138 //Keypad hack strength
     GemPosY(41)=176
     GemPosX(42)=186 
     GemPosY(42)=128
     GemPosX(43)=234 
     GemPosY(43)=176
     GemPosX(44)=186 //Turret hacking
     GemPosY(44)=176
     
     TreeLoadIDs(16)="SkillAugmentTreeBranchVerticalMini"
     TreePosX(16)=186
     TreePosY(16)=160
     TreeLoadIDs(17)="BLACKMASKTEX"
     TreePosX(17)=186
     TreePosY(17)=192
     
     //---------------
     //8. Computer(s)
     GemPosX(45)=486 //Scaling
     GemPosY(45)=128
     GemPosX(46)=438 //Turrets
     GemPosY(46)=176
     GemPosX(47)=534 //Special options
     GemPosY(47)=128
     GemPosX(48)=390 //ATM quality
     GemPosY(48)=176
     GemPosX(49)=486 //Lockout
     GemPosY(49)=224
     
     TreeLoadIDs(18)="SkillAugmentTreeBranchVertical"
     TreePosX(18)=486
     TreePosY(18)=160
     TreeLoadIDs(19)="SkillAugmentTreeBranchVertical"
     TreePosX(19)=486
     TreePosY(19)=192
     
     //---------------
     //9. Fitness AKA Swimming
     GemPosX(50)=42 //Breath regen
     GemPosY(50)=128
     GemPosX(51)=100 //Fall roll
     GemPosY(51)=128
     GemPosX(52)=100 //Tac Roll
     GemPosY(52)=192
     GemPosX(53)=42 //Drowning
     GemPosY(53)=192
     GemPosX(54)=158 //Fitness
     GemPosY(54)=192
     
     TreeLoadIDs(20)="SkillAugmentTreeBranchVertical" //Breath offshoot
     TreePosX(20)=42
     TreePosY(20)=160
     TreeLoadIDs(21)="SkillAugmentTreeBranchVertical" //Fall Roll offshoots
     TreePosX(21)=100
     TreePosY(21)=160
     
     //---------------
     //10. Tactical Gear AKA Enviro
     GemPosX(55)=438 //Deactivate
     GemPosY(55)=128
     GemPosX(56)=486 //Multiple copies
     GemPosY(56)=128
     GemPosX(57)=486 //Stacked pickups (level 2)
     GemPosY(57)=192
     GemPosX(58)=534 //Hide small weapons
     GemPosY(58)=192
     GemPosX(59)=438 //Pickup durability (level 2)
     GemPosY(59)=192
     
     TreeLoadIDs(22)="SkillAugmentTreeBranchVertical" //Deactivate offshoots
     TreePosX(22)=438
     TreePosY(22)=160
     TreeLoadIDs(23)="BLACKMASKTEX" //Wander in to setting up the swimming gear tree. //SkillAugmentTreeBranchVerticalBranchLeft
     TreePosX(23)=414
     TreePosY(23)=160
     TreeLoadIDs(24)="SkillAugmentTreeBranchVertical" //Multiple copies offshoot
     TreePosX(24)=486
     TreePosY(24)=160
     
     //---------------
     //9/10. Swimming (Gear)
     //GemPosX(58)=400
     //GemPosY(58)=192
     
     //---------------
     //11. Medicine
     GemPosX(60)=42 //Stress releief
     GemPosY(60)=128
     GemPosX(61)=90 //Medkit wraparound
     GemPosY(61)=128
     GemPosX(62)=138 //Can recharge medbots (Tier 2)
     GemPosY(62)=192
     GemPosX(63)=176 //More medkit capacity (Tier 2)
     GemPosY(63)=192
     GemPosX(64)=176 //Medkits for death negation (Tier 3)
     GemPosY(64)=256
     
     TreeLoadIDs(25)="SkillAugmentTreeBranchVertical" //Medkit copies offshoot
     TreePosX(25)=176
     TreePosY(25)=224
}
