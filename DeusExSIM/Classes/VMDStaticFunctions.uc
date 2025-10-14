//=============================================================================
// VMDStaticFunctions.
// Note: We exist only to reduce the amount of static class loads.
// Otherwise, this would be in GameInfo.
//=============================================================================
class VMDStaticFunctions extends VMDFillerActors abstract;

//PART 1: SEED STUFF VARS!
var string SeedTypes[8], SeedGlossary[8], LongSeedTypes[32];

//PART 4: SKILL AUGMENT TREE SETUP VARS!
var int GemPosX[80], GemPosY[80];
var string TreeLoadIDs[32];
var int TreePosX[32], TreePosY[32];

var localized String TreeLabels[32], TreeGapLabels[16];
var class<Skill> TreeSkills[32];

//MADDERS, 4/29/25: For shutting functions the fuck up.
function NullFunction()
{
}

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
 	LevelOff = GetMapSuffixMod(A);
 	i = ((i + LevelOff + PlayMod) % Cap);
 	
 	return i;
}

static function int DeriveStableMayhemSeed(Actor A, optional Int Cap, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int i, LevelOff, DotIn, PlayMod;
 	local VMDBufferPlayer VMP;
 	
	if (A == None) return 0;
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerMayhemSeed;
 	
 	if (Cap <= 0) Cap = 10; //Wrap to 10 by default.
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = GetMapSuffixMod(A);
 	i = ((i + LevelOff + PlayMod) % Cap);
 	
 	return i;
}

static function int DeriveMayhemGrenadeSeed(Actor A, optional Int Cap, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int i, LevelOff, DotIn, PlayMod;
 	local VMDBufferPlayer VMP;
 	
	if (A == None) return 0;
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerSeed;
 	
 	if (Cap <= 0) Cap = 10; //Wrap to 10 by default.
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = VMP.PlayerMayhemSeed;
 	i = ((i + LevelOff + PlayMod) % Cap);
 	
 	return i;
}

static function int DeriveStableNakedSolutionSeed(Actor A, optional Int Cap, optional bool bUsePlayerSeed)
{
 	local string S, Use;
 	local int i, LevelOff, DotIn, PlayMod;
 	local VMDBufferPlayer VMP;
 	
	if (A == None) return 0;
	
 	VMP = VMDBufferPlayer(A.GetPlayerPawn());
 	if ((bUsePlayerSeed) && (VMP != None)) PlayMod = VMP.PlayerNakedSolutionSeed;
 	
 	if (Cap <= 0) Cap = 10; //Wrap to 10 by default.
 	
 	Use = Right(VMDGetMapName(A), 1);
 	LevelOff = GetMapSuffixMod(A);
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
 	local string S, S2, S3;
 	
 	S = A.GetURLMap();
 	S2 = "\\";
	
	//MADDERS, 9/1/25: Weird dude appearing in map names now. Unclear why, but axe it.
	if (Right(S, 1) == " ")
	{
		S = Left(S, Len(S) - 1);
	}
	
	if (class'VMDStaticFunctions'.Static.GetConflictingMapURLStyle(A) == 1)
	{
		S3 = "..\\VMDRevision\\Maps\\";
		if (Left(S, Len(S3)) == S3)
		{
			S = Right(S, Len(S) - Len(S3));
		}
	}
	else
	{
		S3 = "\\VMDRevision\\";
		if (Mid(S, 2, Len(S3)) == S3)
		{
			S = Right(S, Len(S) - Len(S3) - 2);
		}
	}
	
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

//Funny enough, I was exploring using this for some tech a while back, but Sarge beat me to it for use with gunshots.
//I only really have interest in alarms to pull enemies from outside standard encounter range. Gunshots will pull from within standard encounter range.
static function EndStasisInAOE(Actor A, Vector StartLoc, float AwakeRadius)
{
	local Pawn TPawn;
	
	for(TPawn = A.Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		if (VSize(TPawn.Location - StartLoc) < AwakeRadius)
		{
			TPawn.bStasis = false;
			TPawn.LastRenderTime = A.Level.TimeSeconds;
		}
	}
}

//MADDERS, 8/26/23: Yoink texture group. Thank you.
static final function name RetrieveTextureGroup(Texture InTex, PlayerPawnExt TPlayer)
{
	local int InPos1, InPos2;
	local string StartStr, BuildStr;
	
	if (InTex == None || TPlayer == None || TPlayer.RootWindow == None) return '';
	
	StartStr = string(InTex);
	InPos1 = InStr(StartStr, ".");
	if (InPos1 > -1)
	{
		BuildStr = Right(StartStr, Len(StartStr) - InPos1 - 1);
		InPos2 = InStr(BuildStr, ".");
		if (InPos2 > -1)
		{
			BuildStr = Left(BuildStr, InPos2);
		}
		else
		{
			return '';
		}
	}
	else
	{
		return '';
	}
	
	return TPlayer.RootWindow.StringToName(BuildStr);
}

//MADDERS, 12/26/20: From BeyondUnreal's Unreal Wiki.
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
			case "REVISION":
			case "CUSTOM REVISION":
				VMP.ShowIntro(True);
			break;
			case "IWR":
			case "OMEGA":
			case "HIVEDAYS":
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
		if (!VMP.HasSkillAugment('SwimmingDrowningRate'))
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
		if (!VMP.HasSkillAugment('SwimmingBreathRegen'))
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
	
	if (TPlay.ConPlay != None && TPlay.ConPlay.ConWinThird != None && NanoKey(AddType) == None && (DeusExWeapon(AddType) == None || !DeusExWeapon(AddType).VMDHasJankyAmmo()))
	{
		TPlay.ConPlay.ConWinThird.ShowReceivedItem(AddType, Count);
	}
	else
	{
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

//MADDERS, 7/9/24: Used in very weird places.
static function bool DamageTypeIsLethal(name DType, bool bPlayer)
{
	switch(DType)
	{
		case 'Burned':
		case 'Drowned':
		case 'DrugDamage':
		case 'Exploded':
		case 'Fell':
		case 'Flamed':
		case 'Hunger':
		case 'Killswitch':
		case 'KnockedOut':
		case 'Overdose':
		case 'Poison':
		case 'PoisonEffect':
		case 'PoisonGas':
		case 'Radiation':
		case 'Shocked':
		case 'Shot':
		case 'Stunned':
			return true;
		break;
		case 'HalonGas':
			return !bPlayer;
		break;
		case 'TearGas':
			return bPlayer;
		break;
	}
	return false;
}

//MADDERS, 8/7/24: Used in death logic now
static function bool DamageTypeIsNonLethal(name DType)
{
	switch(DType)
	{
		case 'KnockedOut':
		case 'Poison':
		case 'PoisonEffect':
		case 'Stunned':
		case 'TearGas':
			return true;
		break;
	}
	return false;
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
	
	if ((ResultFloor < 1) && (DXW != None) && (DXW.bHandToHand) && (!DXW.bInstantHit) && (DXW.GoverningSkill == class'SkillDemolition'))
	{
		ResultFloor = 1;
	}
	
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
	if ((DXW != None) && (DXW.FiringSystemOperation == 2) && (VMP != None) && (VMP.HasSkillAugment('TagTeamOpenChamber')))
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
	if ((DXW != None) && (DXW.FiringSystemOperation == 2) && (VMP != None) && (VMP.HasSkillAugment('TagTeamOpenChamber')))
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

static function bool VMDIsWeaponSensitiveMap(Actor A, optional bool bMorallyGrey)
{
	local string TName;
	
	TName = VMDGetMapName(A);
	switch(TName)
	{
		//These locations are under tight watch. Drones shouldn't draw guns, and hunters shouldn't infiltrate.
		case "02_NYC_BAR":
		case "04_NYC_BAR":
		case "08_NYC_BAR":
		case "02_NYC_FREECLINIC":
		case "08_NYC_FREECLINIC":
		case "03_NYC_MOLEPEOPLE":
		case "06_HONGKONG_WANCHAI_STREET":
		case "06_HONGKONG_WANCHAI_MARKET":
		case "06_HONGKONG_WANCHAI_UNDERWORLD":
		case "06_HONGKONG_VERSALIFE":
		case "06_HONGKONG_MJ12LAB":
		case "06_HONGKONG_TONGBASE":
		//Revision specific M06.
		case "06_HONGKONG_WANCHAI_COMPOUND":
		//Revision specific M10.
		case "10_PARIS_CATACOMBS_METRO":
		case "10_PARIS_CLUB":
		case "11_PARIS_UNDERGROUND":
		case "12_VANDENBERG_COMPUTER":
		case "21_AQUABUSTERMINAL":
		case "21_KABUKICHO":
		case "21_OTEMACHIKU":
		case "21_TOKYO_BANK":
		case "21_INTRO1":
		case "21_INTRO2":
		case "22_KABUKICHO":
		case "22_TOKYO_AQUA":
		case "22_TOKYO_DISCO":
		case "60_HONGKONG_FORICHI":
		case "60_HONGKONG_GREASELPIT":
		case "73_ZODIAC_NEWMEXICO_PAGEBIO":
		case "CF_01_UNRC":
		case "GOTEM":
		case "GOTEM2":
			return true;
		break;
		//These locations are okay if you're okay with bending the rules.
		case "03_NYC_BROOKLYNBRIDGESTATION":
		case "10_PARIS_CHATEAU":
		case "10_PARIS_METRO":
		case "12_VANDENBERG_GAS":
		case "16_HOTELCARONE_HOTEL":
		case "21_HIBIYAPARK_TOWERS":
		case "71_ZODIAC_BUENOSAIRES":
			return !bMorallyGrey;
		break;
		//These locations don't like jackasses bending the rules.
		case "02_NYC_HOTEL":
		case "02_NYC_UNDERGROUND":
		case "02_NYC_SMUG":
		case "03_NYC_HANGAR":
		case "03_NYC_747":
		case "04_NYC_HOTEL":
		case "04_NYC_UNDERGROUND":
		case "04_NYC_SMUG":
		//04 Street here because of Revision's 04 street being inconsistent vs Vanilla's. Consistent bounty hunter spawn maps, please.
		case "04_NYC_STREET":
		//08 Hotel is allowed because the rentons are gone.
		case "08_NYC_UNDERGROUND":
		case "08_NYC_SMUG":
		case "10_PARIS_CATACOMBS_TUNNELS": //MADDERS, 8/15/25: Bad revision spawns, sometimes killing hostages. Aight. Don't fuck with it.
		case "11_PARIS_EVERETT":
		//Redsun maps.
		case "21_OTEMACHILAB_1":
		case "21_OTEMACHILAB_2":
		case "21_PASSAGEWAYS":
		case "21_SHINJUKU_SEWERS":
		case "21_SHUTTLE_BUS_VID":
		case "21_TMGCOMPLEX":
		case "21_YOKOTANIBANK_OFF":
		case "21_YOKOTANIBANK_ON":
		case "22_CAN_VID":
		case "22_CREDITS":
		case "22_EXTRO1":
		case "22_EXTRO1_2":
		case "22_EXTRO2":
		case "22_LOSTCITY": //We blow our way in. How are hunters getting in?
		case "22_TSPE": //Similar situation. How?
		//Zodiac maps.
		case "70_ZODIAC_HONGKONG_TONGBASE":
		case "70_ZODIAC_HONGKONG_WANCHAI_MARKET":
		case "71_ZODIAC_LANGLEY_CIAHQ":
		case "71_ZODIAC_LANGLEY_MJ12":
		case "75_ZODIAC_NEWMEXICO_HBUNKER":
		case "76_ZODIAC_EGYPT_REACTOR":
		case "77_ZODIAC_ENDGAME1":
		case "77_ZODIAC_ENDGAME2":
		//Hotel Carone maps.
		case "16_HOTELCARONE_HOUSE":
		case "16_HOTELCARONE_INTRO":
		//Nihilum maps.
		case "59_INTRO":
		case "60_HONGKONG_MPSHELIPAD":
		case "60_HONGKONG_MPSHQ":
		case "61_HONGKONG_FORICHI":
		case "61_HONGKONG_MPSHELIPAD":
		case "62_BERLIN_AIRBORNELAB":
		case "62_BERLIN_AIRPORT":
		case "62_BERLIN_XVAINTERIOR":
		case "63_NYC_STORAGE":
		case "64_WOODFIBRE_STAFFORD":
		case "64_WOODFIBRE_TUNNELS":
		case "65_WOODFIBRE_BEACHFRONT":
		case "66_WHITEHOUSE_ILLUMINATI":
		case "66_WHITEHOUSE_EXTERIOR":
			return bMorallyGrey;
		break;
		default:
			return false;
		break;
	}
}

static function string MutateDestinationByStyle(Actor A, string StartURL)
{
	local int i, RelIndex, InPos, CurStyle, NewStyle;
	local string Ret, Trim, Fat, CurMapName, TPath, MissionClone;
	local VMDBufferPlayer VMP;
	
	Ret = StartURL;
	VMP = VMDBufferPlayer(A.GetPlayerPawn());
	
	if (VMP == None)
	{
		return Ret;
	}
	
	switch(Left(Ret, 1))
	{
		case "0":
		case "1":
		case "2":
		case "3":
		case "4":
		case "5":
		case "6":
		case "7":
		case "8":
		case "9":
			//Do nothing, we're here to make numbers feel valid.
		break;
		default:
			return Ret; //Non-numerical, we'll be loading some crazy shit, abort instead.
		break;
	}
	
	MissionClone = Left(Ret, 2);
	CurMapName = VMDGetMapName(A);
	InPos = InStr(Ret, "#");
	if (InPos > -1)
	{
		Trim = Left(Ret, InPos);
	}
	else
	{
		Trim = Ret;
	}
	
	Fat = Right(StartURL, Len(StartURL) - Len(Trim));
	if (Right(Trim, 3) ~= ".dx")
	{
		Trim = Left(Trim, Len(Trim) - 3);
	}
	else if (Right(Trim, 4) ~= ".dx ")
	{
		Trim = Left(Trim, Len(Trim) - 4);
	}
	
	for(i=0; i<ArrayCount(VMP.RecordedMaps); i++)
	{
		if (VMP.RecordedMaps[i] ~= Trim)
		{
			VMP.Log("PRERECORDED MAP FOUND! RETURNING"@StartURL);
			return StartURL;
		}
	}
	
	CurStyle = GetIntendedMapStyle(A);
	NewStyle = GetIntendedMapStyleFromName(A, Trim);
	
	//MADDERS, 7/20/25: This... Isn't necessary?
	//But any time we flip-flop styles on a map that doesn't exist in all sets (And uses a custom destination as a result), force redirection in this block.
	if (NewStyle != CurStyle)
	{
		switch(Trim)
		{
			case "06_HONGKONG_ENTERINGSCENE":
				if (NewStyle != 1)
				{
					VMP.VMDRecordMap("06_HONGKONG_HELIBASE");
					return "06_HONGKONG_HELIBASE.DX";
				}
			break;
			case "06_HONGKONG_HELIBASE":
				if (NewStyle == 1)
				{
					VMP.VMDRecordMap("06_HONGKONG_ENTERINGSCENE");
					if (class'VMDStaticFunctions'.Static.GetConflictingMapURLStyle(A) == 1)
					{
						return "..\\VMDRevision\\Maps\\06_HONGKONG_ENTERINGSCENE.DX";
					}
					else
					{
						return "06\\VMDRevision\\06_HONGKONG_ENTERINGSCENE.DX";
					}
				}
			break;
			case "10_PARIS_ENTRANCE":
				if (NewStyle != 1)
				{
					VMP.VMDRecordMap("10_PARIS_CATACOMBS");
					return "10_PARIS_CATACOMBS.DX";
				}
			break;
			case "10_PARIS_CATACOMBS":
				if (NewStyle == 1)
				{
					VMP.VMDRecordMap("10_PARIS_ENTRANCE");
					if (class'VMDStaticFunctions'.Static.GetConflictingMapURLStyle(A) == 1)
					{
						return "..\\VMDRevision\\Maps\\10_PARIS_ENTRANCE.DX";
					}
					else
					{
						return "10\\VMDRevision\\10_PARIS_ENTRANCE.DX";
					}
				}
			break;
		}
	}
	else
	{
		VMP.VMDRecordMap(Trim);
	}
	
	switch(NewStyle)
	{
		case 0:
			Ret = StartURL;
		break;
		case 1:
			if (class'VMDStaticFunctions'.Static.GetConflictingMapURLStyle(A) == 1)
			{
				Ret = "..\\VMDRevision\\Maps\\"$Trim$".dx"$Fat;
			}
			else
			{
				Ret = MissionClone$"\\VMDRevision\\"$Trim$".dx"$Fat;
			}
			Log("MODIFYING URL! RETURNING "$Ret);
		break;
		case 2:
			Ret = StartURL;
		break;
	}
	
	return Ret;
}

static function int GetConflictingMapURLStyle(Actor A)
{
	// 0 = System path shitty method. Vanilla stable.
	// 1 = Alien directory method, much cleaner.
	return 1;
}

static function int GetIntendedMapStyle(Actor A, optional bool bDirectRip)
{
	local DeusExLevelInfo TInfo;
	local string TName;
	
	if (bDirectRip)
	{
		forEach A.AllActors(class'DeusExLevelInfo', TInfo)
		{
			TName = TInfo.MapName;
			Log("LADDER POINT ADDER[!] FAST MAP NAME YOINK! RESULT?"@TName);
			break;
		}
	}
	else
	{
		TName = VMDGetMapName(A);
	}
	return GetIntendedMapStyleFromName(A, TName);
}

static function int GetIntendedMapStyleFromName(Actor A, string TName)
{
	local int RelIndex;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(A.GetPlayerPawn());
	
	if (VMP == None) return 0;
	
	switch(TName)
	{
		case "DX":
		case "DXONLY":
		case "ENTRY":
		case "00_PLAYERHUB":
		case "00_CHARACTERSETUP":
		case "00_TRAINING":
		case "00_TRAININGCOMBAT":
		case "00_TRAININGFINAL":
			return 0;
		break;
		case "00_INTRO":
			RelIndex = 0;
		break;
		case "01_NYC_UNATCOISLAND":
		case "03_NYC_UNATCOISLAND":
		case "04_NYC_UNATCOISLAND":
		case "05_NYC_UNATCOISLAND":
			RelIndex = 1;
		break;
		case "01_NYC_UNATCOHQ":
		case "03_NYC_UNATCOHQ":
		case "04_NYC_UNATCOHQ":
		case "05_NYC_UNATCOHQ":
			RelIndex = 2;
		break;
		case "02_NYC_BATTERYPARK":
		case "03_NYC_BATTERYPARK":
		case "04_NYC_BATTERYPARK":
			RelIndex = 3;
		break;
		case "02_NYC_BAR":
		case "02_NYC_FREECLINIC":
		case "02_NYC_HOTEL":
		case "02_NYC_SMUG":
		case "02_NYC_STREET":
		case "02_NYC_UNDERGROUND":
		case "02_NYC_WAREHOUSE":
		case "04_NYC_BAR":
		case "04_NYC_HOTEL":
		case "04_NYC_NSFHQ":
		case "04_NYC_SMUG":
		case "04_NYC_STREET":
		case "04_NYC_UNDERGROUND":
		case "08_NYC_BAR":
		case "08_NYC_FREECLINIC":
		case "08_NYC_HOTEL":
		case "08_NYC_SMUG":
		case "08_NYC_STREET":
		case "08_NYC_UNDERGROUND":
			RelIndex = 4;
		break;
		case "03_NYC_BROOKLYNBRIDGESTATION":
		case "03_NYC_MOLEPEOPLE":
			RelIndex = 5;
		break;
		case "03_NYC_747":
		case "03_NYC_AIRFIELD":
		case "03_NYC_AIRFIELDHELIBASE":
		case "03_NYC_HANGAR":
			RelIndex = 6;
		break;
		case "05_NYC_UNATCOMJ12LAB":
			RelIndex = 7;
		break;
		//Unique map for revision.
		case "06_HONGKONG_ENTERINGSCENE":
		case "06_HONGKONG_HELIBASE":
		case "06_HONGKONG_TONGBASE":
		case "06_HONGKONG_WANCHAI_CANAL":
		case "06_HONGKONG_WANCHAI_GARAGE":
		case "06_HONGKONG_WANCHAI_MARKET":
		case "06_HONGKONG_WANCHAI_STREET":
		case "06_HONGKONG_WANCHAI_UNDERWORLD":
		//Unique Map for Revision
		case "06_HONGKONG_WANCHAI_COMPOUND":
			RelIndex = 8;
		break;
		case "06_HONGKONG_VERSALIFE":
		case "06_HONGKONG_MJ12LAB":
		case "06_HONGKONG_STORAGE":
			RelIndex = 9;
		break;
		case "09_NYC_DOCKYARD":
		case "09_NYC_SHIP":
		case "09_NYC_SHIPBELOW":
		case "09_NYC_SHIPFAN":
			RelIndex = 10;
		break;
		case "09_NYC_GRAVEYARD":
			RelIndex = 11;
		break;
		//Unique map for Revision
		case "10_PARIS_ENTRANCE":
		case "10_PARIS_CATACOMBS":
		//This one, too.
		case "10_PARIS_CATACOMBS_METRO":
		case "10_PARIS_CLUB":
		case "10_PARIS_METRO":
			RelIndex = 12;
		break;
		case "10_PARIS_CATACOMBS_TUNNELS":
			RelIndex = 13;
		break;
		case "10_PARIS_CHATEAU":
			RelIndex = 14;
		break;
		case "11_PARIS_CATHEDRAL":
		case "11_PARIS_UNDERGROUND":
			RelIndex = 15;
		break;
		case "11_PARIS_EVERETT":
			RelIndex = 16;
		break;
		case "12_VANDENBERG_CMD":
		case "12_VANDENBERG_COMPUTER":
		case "12_VANDENBERG_TUNNELS":
			RelIndex = 17;
		break;
		case "12_VANDENBERG_GAS":
			RelIndex = 18;
		break;
		case "14_OCEANLAB_LAB":
		case "14_OCEANLAB_UC":
		case "14_VANDENBERG_SUB":
			RelIndex = 19;
		break;
		case "14_OCEANLAB_SILO":
			RelIndex = 20;
		break;
		case "15_AREA51_BUNKER":
		case "15_AREA51_BUNKER":
		case "15_AREA51_ENTRANCE":
		case "15_AREA51_FINAL":
		case "15_AREA51_PAGE":
			RelIndex = 21;
		break;
		case "99_ENDGAME1":
		case "99_ENDGAME2":
		case "99_ENDGAME3":
		case "99_ENDGAME4":
			RelIndex = 22;
		break;
		case "NEWGAMEPLUSLIAISON":
			return 1;
		break;
	}
	
	return VMP.MapStyle[RelIndex];
}

static function bool VMDIsBountyHunterExceptionMap(Actor A, optional bool bMorallyGrey)
{
	local string TName;
	
	TName = VMDGetMapName(A);
	switch(TName)
	{
		//These locations are found to play badly, outright.
		case "06_HONGKONG_HELIBASE":
			return true;
		break;
		default:
			return false;
		break;
	}
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
    LongSeedTypes(10)="38;67;25;1;42;49;72;7;98;33;48;97;63;76;41;28;89;62;52;91;29;19;59;57;37;61;21;94;2;14;64;79;53;85;9;73;32;87;84;40;20;12;74;43;68;56;58;81;70;35;24;6;75;51;90;92;11;44;5;93;86;78;31;45;34;17;26;71;83;27;16;46;0;47;15;99;55;80;69;65;8;13;18;3;22;60;66;30;77;36;10;39;95;23;54;96;50;4;82;88"
    LongSeedTypes(11)="93;31;70;63;34;64;13;1;26;43;98;24;94;91;60;52;28;33;4;21;95;25;88;5;67;59;68;16;62;56;55;53;18;36;2;65;71;81;29;84;45;12;35;20;32;11;39;96;3;57;85;47;61;40;17;48;87;15;54;14;97;38;73;46;72;76;80;69;0;86;44;49;37;77;27;74;50;58;75;78;51;8;92;79;90;99;9;7;6;19;83;30;22;82;23;66;10;41;42;89"
    LongSeedTypes(12)="55;72;15;76;83;40;47;18;10;11;95;68;16;99;86;32;30;98;56;46;91;88;64;53;6;77;65;1;36;54;12;74;42;31;17;44;39;58;87;93;90;28;22;19;60;2;84;71;63;25;14;92;80;51;5;26;79;75;29;89;57;52;35;81;48;3;96;45;24;34;66;43;94;7;69;70;50;61;62;38;73;27;23;82;20;85;97;37;13;8;33;67;49;59;9;41;78;21;0;4"
    LongSeedTypes(13)="38;50;97;96;85;28;63;84;75;39;72;62;35;68;94;18;31;67;80;42;37;4;81;47;10;21;16;2;12;30;34;56;49;25;76;17;53;93;77;83;64;14;59;0;40;32;55;3;27;20;9;51;60;7;22;90;79;19;86;23;45;1;92;8;91;13;99;36;66;46;57;26;54;24;87;61;95;15;82;73;65;58;29;33;70;71;74;52;69;48;88;43;98;11;89;44;5;41;78;6"
    LongSeedTypes(14)="73;77;56;76;39;48;38;90;68;31;78;79;88;47;54;6;94;52;97;35;10;16;19;36;29;28;59;50;65;81;23;21;7;12;25;64;24;53;4;96;85;49;60;34;9;58;92;43;26;86;70;37;71;55;13;51;83;20;62;57;98;32;46;75;17;44;3;80;91;40;67;22;82;33;66;61;8;2;30;27;84;11;72;41;0;14;45;63;1;42;89;5;74;93;18;69;95;15;99;87"
    LongSeedTypes(15)="83;99;73;43;85;91;10;7;38;58;70;31;35;6;75;88;76;17;61;64;81;0;77;95;23;19;55;4;94;3;15;45;93;53;25;41;14;92;54;84;1;47;18;9;60;65;67;32;42;74;46;59;80;2;89;16;39;26;11;79;71;97;82;57;62;72;8;63;49;98;48;56;28;52;96;50;36;68;33;66;87;69;34;29;86;22;13;20;12;37;24;21;51;5;27;78;90;30;40;44"
    LongSeedTypes(16)="68;18;94;31;52;75;66;37;49;40;65;69;71;54;30;53;24;63;23;98;64;39;26;72;12;22;7;19;47;14;5;10;36;50;88;97;85;0;87;67;42;55;17;99;15;91;70;34;74;44;92;2;89;51;4;16;45;78;79;41;20;57;3;90;58;21;76;38;32;61;96;48;33;62;60;82;13;83;27;8;29;6;95;93;77;81;35;84;86;1;56;80;43;11;73;59;9;28;46;25"
    LongSeedTypes(17)="91;13;67;90;15;38;93;82;83;8;26;54;4;29;39;88;22;37;98;50;61;31;23;99;43;17;3;48;21;68;32;33;57;6;42;49;95;65;40;64;77;53;76;72;41;60;81;96;58;78;46;10;27;79;7;19;97;52;94;47;59;70;80;11;5;28;89;63;87;35;24;86;12;34;25;51;73;75;44;9;71;74;2;14;66;30;62;16;45;55;36;84;0;69;92;56;85;20;18;1"
    LongSeedTypes(18)="46;57;1;40;66;3;14;15;80;0;87;31;93;81;4;16;95;99;67;82;28;5;98;32;69;26;77;45;36;18;43;39;6;30;70;12;68;84;23;11;71;8;51;91;42;20;74;22;24;47;75;73;97;65;64;37;33;38;96;92;86;41;54;9;94;53;83;7;50;90;35;44;48;88;58;52;72;55;10;17;89;59;19;56;25;85;29;21;27;76;79;13;62;61;2;63;34;78;49;60"
    LongSeedTypes(19)="1;51;9;57;64;73;50;21;63;82;55;68;27;47;61;65;2;8;88;37;81;3;28;40;46;92;31;34;97;95;49;45;39;74;67;22;41;93;32;77;30;94;48;42;90;52;56;78;25;18;29;23;91;66;58;19;70;36;83;89;4;38;96;11;53;59;13;76;85;24;12;60;75;0;15;80;62;98;44;72;71;54;17;14;84;35;26;10;99;87;86;16;5;69;43;6;20;33;7;79"
    LongSeedTypes(20)="3;92;43;11;17;70;37;86;62;50;74;53;55;78;24;76;89;98;8;99;26;84;67;34;20;95;31;16;75;40;21;47;58;94;68;87;96;48;7;32;79;14;19;30;39;12;73;65;23;64;6;80;5;77;2;63;52;57;25;4;13;1;22;15;27;69;93;9;35;10;38;36;42;46;18;88;91;71;33;61;59;54;44;72;90;85;29;81;41;82;49;28;45;51;97;56;60;0;83;66"
    LongSeedTypes(21)="16;71;85;40;0;86;48;33;65;96;23;95;55;72;49;89;53;66;77;2;5;3;63;29;38;12;58;88;76;21;13;7;52;6;42;17;14;60;45;99;69;41;11;15;26;8;4;51;62;81;83;9;75;91;90;31;54;84;94;92;67;19;28;24;64;37;61;80;35;27;22;46;39;57;82;87;97;47;79;70;10;1;20;18;68;98;56;74;73;50;34;44;30;59;93;32;36;43;78;25"
    LongSeedTypes(22)="81;63;99;95;79;62;96;48;77;67;12;0;97;1;31;17;52;9;43;87;71;32;85;75;55;80;13;40;83;89;59;23;44;93;27;36;5;28;91;15;19;76;20;73;16;37;49;53;86;66;92;41;4;56;98;25;38;88;6;84;3;90;50;8;68;57;30;21;78;11;94;74;42;70;61;45;46;54;14;58;47;10;7;34;24;69;64;39;18;22;29;82;35;72;51;26;60;65;33;2"
    LongSeedTypes(23)="24;61;86;40;9;88;48;10;43;70;20;76;22;32;64;19;17;63;75;42;28;18;68;2;67;62;29;33;54;8;90;52;77;83;65;59;16;66;3;5;31;84;60;93;78;27;94;96;51;15;87;57;38;53;13;72;80;41;0;6;69;71;97;55;95;44;92;14;91;30;58;89;98;1;7;34;23;46;99;35;26;45;82;4;74;36;50;47;25;37;39;79;49;73;12;85;21;56;11;81"
    LongSeedTypes(24)="35;8;49;92;39;59;18;72;23;29;94;61;55;13;54;3;80;90;11;71;24;73;83;25;99;98;81;50;96;57;9;17;7;70;84;12;34;53;2;78;31;5;27;88;40;22;16;93;60;45;32;63;20;43;91;26;48;15;42;75;64;21;87;66;0;37;65;47;86;77;82;41;28;1;95;14;52;38;69;62;36;30;76;68;51;33;74;44;89;46;4;10;56;79;85;97;6;67;19;58"
    LongSeedTypes(25)="71;98;31;35;37;39;58;6;85;74;70;5;3;42;68;90;50;40;56;91;65;97;53;87;51;75;4;11;78;77;32;12;18;34;47;44;1;29;84;2;88;16;61;64;63;19;36;41;43;81;55;57;28;9;14;95;38;8;96;21;89;52;22;94;48;73;54;99;62;20;82;45;26;93;10;17;80;25;59;15;7;67;24;46;76;83;27;49;79;66;30;72;23;92;33;0;86;60;69;13"
    LongSeedTypes(26)="77;22;53;54;57;64;21;94;46;79;5;4;86;62;58;56;8;25;89;37;41;32;59;26;50;70;24;60;52;92;68;65;3;33;6;61;36;28;71;88;69;82;73;48;31;11;44;34;42;2;7;1;35;20;90;16;63;84;49;78;30;51;83;40;55;27;10;97;96;67;75;47;80;87;74;39;9;19;45;29;91;38;81;99;13;66;12;93;15;85;23;17;98;72;76;18;95;14;0;43"
    LongSeedTypes(27)="78;36;10;11;68;41;25;64;76;96;99;50;97;7;48;56;43;71;38;66;19;93;87;65;77;81;49;4;14;53;30;31;27;24;3;51;79;39;16;55;46;85;42;54;62;88;13;8;15;91;34;5;92;73;70;60;82;57;45;35;94;2;0;23;58;44;69;75;89;28;20;67;33;74;40;32;18;98;47;90;12;59;37;83;72;80;84;63;29;1;61;6;52;9;26;86;22;21;17;95"
    LongSeedTypes(28)="45;10;54;59;11;57;24;33;9;91;58;63;6;37;73;95;3;17;32;30;62;98;4;23;2;21;90;69;82;7;79;92;56;16;60;26;55;48;68;19;76;80;39;5;74;44;94;14;65;61;22;89;97;53;81;70;86;75;96;40;43;88;83;38;42;72;41;64;35;31;84;78;99;15;20;36;67;85;8;50;18;13;34;29;1;87;52;0;12;47;77;28;71;27;46;49;66;51;93;25"
    LongSeedTypes(29)="72;23;69;29;34;81;35;59;96;63;93;36;92;48;74;40;70;73;24;80;58;15;41;98;12;57;79;55;83;0;9;47;42;91;5;30;44;64;22;7;33;65;21;97;89;10;50;62;16;76;39;87;11;53;45;52;75;4;20;94;60;78;6;27;84;3;43;19;88;37;31;13;90;68;56;1;85;99;67;46;38;77;25;18;2;51;49;66;26;14;71;17;82;28;54;8;32;86;95;61"
    LongSeedTypes(30)="56;44;46;52;18;22;43;77;95;93;86;50;89;17;66;45;42;35;24;12;41;92;13;79;87;49;47;38;94;70;96;5;7;84;36;78;15;34;83;65;91;6;59;98;9;20;30;1;14;90;75;80;62;31;54;33;58;21;28;0;11;53;88;19;8;16;10;67;74;63;51;68;4;39;81;23;61;32;69;76;60;85;97;37;71;3;25;55;57;72;73;2;40;64;48;29;27;99;26;82"
    LongSeedTypes(31)="46;79;89;93;68;44;60;53;34;86;58;22;75;85;66;83;29;13;54;64;23;28;43;17;73;1;20;76;98;19;37;59;18;45;55;52;36;21;26;81;47;30;35;69;77;11;57;56;12;15;50;87;24;91;6;70;74;72;80;92;62;99;39;61;95;82;78;65;48;9;51;0;14;33;96;63;5;8;67;10;97;38;42;41;25;90;84;32;2;16;49;4;40;31;71;94;7;27;3;88"
    
    SeedGlossary(0)="Food Desc"
    SeedGlossary(1)="Addiction"
    SeedGlossary(2)="Picking 1"
    SeedGlossary(3)="Picking 2"
    SeedGlossary(4)="Hacking 1"
    SeedGlossary(5)="Hacking 2"
    SeedGlossary(6)="Ammo Looting"
}
