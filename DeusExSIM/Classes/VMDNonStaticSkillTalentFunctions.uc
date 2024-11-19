//=============================================================================
// VMDStaticSkillTalentFunctions.
// Note: We exist only to reduce the amount of static class loads.
// Otherwise, this would be in GameInfo.
// --------------------------
// MADDERS, 5/16/22: No longer static. Oops.
//=============================================================================
class VMDNonStaticSkillTalentFunctions extends VMDFillerActors; // abstract

struct VMDButtonPos {
	var int X;
	var int Y;
};

var localized String SkillCoreDescs[11],
			SkillLevelDescsA[11], AltSkillLevelDescsA[11], SkillLevelDescsB[11], SkillLevelDescsC[11], SkillLevelDescsD[11],
			NoCraftingSkillLevelDescsA[11], AltNoCraftingSkillLevelDescsA[11], NoCraftingSkillLevelDescsB[11], NoCraftingSkillLevelDescsC[11], NoCraftingSkillLevelDescsD[11],
			NoTalentsSkillLevelDescsA[11], AltNoTalentsSkillLevelDescsA[11], NoTalentsSkillLevelDescsB[11], NoTalentsSkillLevelDescsC[11], NoTalentsSkillLevelDescsD[11];
var class<Skill> Skills[11], SkillMapSkillOrder[11];

var string SkillTalentIcons[100];
var name SkillTalentIDs[100];
var VMDButtonPos JumpGemJumpLoc[11], SkillGemPos[11], SkillTalentPos[100], NewGameSkillTalentPosMod;

var name MapBranchingTalent[100];
var Texture MapBranchingFoundationTexture[100], MapBranchingTexture[100];
var VMDButtonPos MapBranchingFoundationPos[100], MapBranchingFoundationSize[100],
			MapBranchingPos[100], MapBranchingSize[100];
var VMDBufferPlayer LastVMDBufferPlayer;

/*static*/ function string GetCoreDesc(class<Skill> InSkill)
{
	local int i;
	
	i = GetSkillIndex(InSkill);
	if (i > -1)
	{
		return SkillCoreDescs[i];
	}
	return "ERR CDESC";
}

/*static*/ function string GetLevelDesc(class<Skill> InSkill, int InLevel)
{
	local int i;
	
	i = GetSkillIndex(InSkill);
	if (i > -1)
	{
		switch(InLevel)
		{
			case 0:
				return BuildLevelString(InSkill, InLevel, SkillLevelDescsA[i], i);
			break;
			case 1:
				return BuildLevelString(InSkill, InLevel, SkillLevelDescsB[i], i);
			break;
			case 2:
				return BuildLevelString(InSkill, InLevel, SkillLevelDescsC[i], i);
			break;
			case 3:
				return BuildLevelString(InSkill, InLevel, SkillLevelDescsD[i], i);
			break;
		}
	}
	return "ERR CLEVEL"@InLevel;
}

function string BuildLevelString(class<Skill> InSkill, int InLevel, String DescStr, int SkillArray)
{
	local bool bCrafting, bTalents;
	local int TVars[4];
	local float GetVal, TMath, TFVars[4];
	local string TString, TSVars[4];
	local Skill TSkill;
	local VMDBufferPlayer TPlayer;
	
	TPlayer = GetVMDBufferPlayer();
	if (InSkill == None || TPlayer == None || TPlayer.SkillSystem == None) return "ERR NO SKILL CLASS OR PLAYER";
	TSkill = TPlayer.SkillSystem.GetSkillFromClass(InSkill);
	if (TSkill == None) return "ERR NO SKILL";
	
	bCrafting = TPlayer.bCraftingSystemEnabled;
	bTalents = TPlayer.bSkillAugmentsEnabled;
	GetVal = TSkill.LevelValues[InLevel];
	switch(InSkill.Name)
	{
		case 'SkillWeaponHeavy':
		case 'SkillWeaponPistol':
		case 'SkillWeaponRifle':
			if (bTalents)
			{
				if ((InLevel == 0) && (Abs(GetVal) > 0.009))
				{
					DescStr = AltSkillLevelDescsA[SkillArray];
					TVars[0] = int(GetVal * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -200);
				}
				else if (InLevel == 1)
				{
					TVars[0] = int(GetVal * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -200);
				}
				else if (InLevel == 2)
				{
					TVars[0] = int((GetVal+0.05) * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -100);
					TVars[3] = int(GetVal * -200);
				}
				else
				{
					TVars[0] = int((GetVal+0.1) * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -100);
					TVars[3] = int(GetVal * -200);
				}
			}
			else
			{
				if ((InLevel == 0) && (Abs(GetVal) > 0.009))
				{
					DescStr = AltNoTalentsSkillLevelDescsA[SkillArray];
					TVars[0] = int(GetVal * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -200);
				}
				else if (InLevel == 0)
				{
					DescStr = NoTalentsSkillLevelDescsA[SkillArray];
				}
				else if (InLevel == 1)
				{
					DescStr = NoTalentsSkillLevelDescsB[SkillArray];
					TVars[0] = int(GetVal * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -200);
				}
				else if (InLevel == 2)
				{
					DescStr = NoTalentsSkillLevelDescsC[SkillArray];
					TVars[0] = int((GetVal+0.05) * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -100);
					TVars[3] = int(GetVal * -200);
				}
				else
				{
					DescStr = NoTalentsSkillLevelDescsD[SkillArray];
					TVars[0] = int((GetVal+0.1) * -100);
					TVars[1] = int(GetVal * -100);
					TVars[2] = int(GetVal * -100);
					TVars[3] = int(GetVal * -200);
				}
			}
		break;
		case 'SkillWeaponLowTech':
			if ((InLevel == 0) && (Abs(GetVal) > 0.009))
			{
				DescStr = AltSkillLevelDescsA[SkillArray];
				TVars[0] = int(GetVal * -100);
				TVars[1] = int(GetVal * -200);
			}
			else if (InLevel == 1)
			{
				TVars[0] = int(GetVal * -100);
				TVars[1] = int(GetVal * -200);
			}
			else if (InLevel == 2)
			{
				TVars[0] = int(GetVal * -100);
				TVars[1] = int((GetVal+0.05) * -100);
				TVars[2] = int(GetVal * -200);
			}
			else
			{
				TVars[0] = int(GetVal * -100);
				TVars[1] = int((GetVal+0.1) * -100);
				TVars[2] = int(GetVal * -200);
			}
		break;
		case 'SkillDemolition':
			if ((InLevel == 0) && (Abs(GetVal) > 0.009))
			{
				DescStr = AltSkillLevelDescsA[SkillArray];
				TVars[0] = int(GetVal * -100);
				TVars[1] = int(GetVal * -200);
			}
			else if (InLevel == 1)
			{
				TVars[0] = int(GetVal * -100);
				TVars[1] = int(GetVal * -200);
			}
			else if (InLevel == 2)
			{
				TVars[0] = int((GetVal+0.05) * -100);
				TVars[1] = int(GetVal * -200);
			}
			else
			{
				TVars[0] = int((GetVal+0.1) * -100);
				TVars[1] = int(GetVal * -200);
			}
		break;
		case 'SkillEnviro':
			if (bTalents)
			{
				if ((InLevel == 0) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
				{
					DescStr = AltSkillLevelDescsA[SkillArray];
				}
				TVars[0] = int(((1.0 / Abs(GetVal)) - 1.0) * 100);
				TVars[1] = int(((1.0 / ((Abs(GetVal) + 0.75) / 2)) - 1.0) * 100);
			}
			else
			{
				if ((InLevel == 0) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
				{
					DescStr = AltNoTalentsSkillLevelDescsA[SkillArray];
				}
				else
				{
					switch(InLevel)
					{
						case 0:
							DescStr = NoTalentsSkillLevelDescsA[SkillArray];
						break;
						case 1:
							DescStr = NoTalentsSkillLevelDescsB[SkillArray];
						break;
						case 2:
							DescStr = NoTalentsSkillLevelDescsC[SkillArray];
						break;
						case 3:
							DescStr = NoTalentsSkillLevelDescsD[SkillArray];
						break;
					}
				}
				TVars[0] = int(((1.0 / Abs(GetVal)) - 1.0) * 100);
				TVars[1] = int(((1.0 / ((Abs(GetVal) + 0.75) / 2)) - 1.0) * 100);
			}
		break;
		case 'SkillComputer':
			if ((InLevel == 1) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
			{
				DescStr = AltSkillLevelDescsA[SkillArray];
				TVars[0] = int((Abs(GetVal) - 1.0) * 100);
			}
			else if (InLevel > 0)
			{
				TVars[0] = int((Abs(GetVal) - 1.0) * 100);
			}
		break;
		case 'SkillLockpicking':
		case 'SkillTech':
			//Pick/hack strength.
			TMath = Abs(GetVal) * 100.0;
			
			//MADDERS, 11/15/24: Wave surfer and data analyst are stock without talents enabled.
			if ((InSkill.Name == 'SkillTech') && (!bTalents))
			{
				TMath *= 1.5;
			}
			
			TString = String(TMath);
			TSVars[0] = Left( TString, InStr(TString, ".")+2);
			
			//Rushed attempt noise generation.
			if (InSkill.Name == 'SkillLockpicking')
			{
				TMath = ( 1.0 - ((Abs(GetVal) - 0.1) / 0.9) );
			}
			else
			{
				if (!bCrafting)
				{
					switch(InLevel)
					{
						case 0:
							DescStr = NoCraftingSkillLevelDescsA[SkillArray];
						break;
						case 1:
							DescStr = NoCraftingSkillLevelDescsB[SkillArray];
						break;
						case 2:
							DescStr = NoCraftingSkillLevelDescsC[SkillArray];
						break;
						case 3:
							DescStr = NoCraftingSkillLevelDescsD[SkillArray];
						break;
					}
				}
				TMath = Sqrt( 1.0 - ((Abs(GetVal) - 0.1) / 0.9) );
			}
			
			TMath = TMath * 100.0;
			TString = String(TMath);
			TSVars[1] = Left( TString, InStr(TString, ".")+2);
		break;
		case 'SkillMedicine':
			TVars[0] = int(Abs(GetVal) * 30);
			
			//MADDERS, 11/15/24: Assume +15 from trained professional without talents.
			if (!bTalents)
			{
				TVars[0] += 15;
			}
			
			if (!bCrafting)
			{
				switch(InLevel)
				{
					case 0:
						DescStr = NoCraftingSkillLevelDescsA[SkillArray];
					break;
					case 1:
						DescStr = NoCraftingSkillLevelDescsB[SkillArray];
					break;
					case 2:
						DescStr = NoCraftingSkillLevelDescsC[SkillArray];
					break;
					case 3:
						DescStr = NoCraftingSkillLevelDescsD[SkillArray];
					break;
				}
			}
		break;
		case 'SkillSwimming':
			if (bTalents)
			{
				if ((InLevel == 0) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
				{
					DescStr = AltSkillLevelDescsA[SkillArray];
				}
				TVars[0] = int(Abs(GetVal - 1.0) * 50);
			}
			else
			{
				if ((InLevel == 0) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
				{
					DescStr = AltNoTalentsSkillLevelDescsA[SkillArray];
				}
				else
				{
					switch(InLevel)
					{
						case 0:
							DescStr = NoTalentsSkillLevelDescsA[SkillArray];
						break;
						case 1:
							DescStr = NoTalentsSkillLevelDescsB[SkillArray];
						break;
						case 2:
							DescStr = NoTalentsSkillLevelDescsC[SkillArray];
						break;
						case 3:
							DescStr = NoTalentsSkillLevelDescsD[SkillArray];
						break;
					}
				}
				TVars[0] = int(Abs(GetVal - 1.0) * 125);
				TVars[1] = int(Abs(GetVal - 1.0) * 50);
			}
		break;
	}
	
	if (InSkill == class'SkillLockpicking' || InSkill == class'SkillTech')
	{
		return SprintF(DescStr, TSVars[0], TSVars[1], TSVars[2], TSVars[3]);
	}
	else
	{
		return SprintF(DescStr, TVars[0], TVars[1], TVars[2], TVars[3]);
	}
}

/*static*/ function int GetSkillIndex(class<Skill> InSkill)
{
	local int i;
	
	for (i=0; i<11; i++)
	{
		if (Skills[i] == InSkill)
		{
			return i;
		}
	}
	return -1;
}

/*static*/ function class<Skill> GetSkillFromIndex(int TArray)
{
	return Skills[TArray];
}

/*static*/ function int GetSkillTalentPos(int TArray, int Component, Window InWindow)
{
	local int Ret;
	
	if (InWindow == None) return 0;
	
	if (!InWindow.IsA('VMDPersonaScreenSkills'))
	{
		if (Component == 0) Ret += NewGameSkillTalentPosMod.X;
		if (Component == 1) Ret += NewGameSkillTalentPosMod.Y;
	}
	
	if (Component == 0) Ret += SkillTalentPos[TArray].X;
	if (Component == 1) Ret += SkillTalentPos[TArray].Y;
	
	return Ret;
}

/*static*/ function name GetSkillTalentIDs(int TArray)
{
	return SkillTalentIDs[TArray];
}

/*static*/ function string GetSkillTalentIcons(int TArray)
{
	return SkillTalentIcons[TArray];
}

/*static*/ function int GetBFPos(int TArray, int Component, Window InWindow)
{
	local int Ret;
	
	if (InWindow == None) return 0;
	
	if (!InWindow.IsA('VMDPersonaScreenSkills'))
	{
		if (Component == 0) Ret += NewGameSkillTalentPosMod.X;
		if (Component == 1) Ret += NewGameSkillTalentPosMod.Y;
	}
	
	if (Component == 0) Ret += MapBranchingFoundationPos[TArray].X;
	if (Component == 1) Ret += MapBranchingFoundationPos[TArray].Y;
	
	return Ret;
}

/*static*/ function int GetBFSize(int TArray, int Component, Window InWindow)
{
	local int Ret;
	
	if (InWindow == None) return 0;
	
	if (Component == 0) Ret += MapBranchingFoundationSize[TArray].X;
	if (Component == 1) Ret += MapBranchingFoundationSize[TArray].Y;
	
	return Ret;
}

/*static*/ function int GetBPos(int TArray, int Component, Window InWindow)
{
	local int Ret;
	
	if (InWindow == None) return 0;
	
	if (!InWindow.IsA('VMDPersonaScreenSkills'))
	{
		if (Component == 0) Ret += NewGameSkillTalentPosMod.X;
		if (Component == 1) Ret += NewGameSkillTalentPosMod.Y;
	}
	
	if (Component == 0) Ret += MapBranchingPos[TArray].X;
	if (Component == 1) Ret += MapBranchingPos[TArray].Y;
	
	return Ret;
}

/*static*/ function int GetBSize(int TArray, int Component, Window InWindow)
{
	local int Ret;
	
	if (InWindow == None) return 0;
	
	if (Component == 0) Ret += MapBranchingSize[TArray].X;
	if (Component == 1) Ret += MapBranchingSize[TArray].Y;
	
	return Ret;
}

/*static*/ function Texture GetBFTexture(int TArray)
{
	return MapBranchingFoundationTexture[TArray];
}

/*static*/ function Texture GetBTexture(int TArray)
{
	return MapBranchingTexture[TArray];
}

/*static*/ function name GetBTalent(int TArray)
{
	return MapBranchingTalent[TArray];
}

/*static*/ function class<Skill> GetSkillMapSkillOrder(int TArray)
{
	return SkillMapSkillOrder[TArray];
}

/*static*/ function int GetSkillMapJumpPos(class<Skill> TSkill, int Component)
{
	local int TArray;
	
	TArray = GetSkillIndex(TSkill);
	
	if (Component == 0) return JumpGemJumpLoc[TArray].X;
	return JumpGemJumpLoc[TArray].Y;
}

/*static*/ function int GetSkillMapPos(class<Skill> TSkill, int Component)
{
	local int TArray;
	
	TArray = GetSkillIndex(TSkill);
	
	if (Component == 0) return SkillGemPos[TArray].X;
	return SkillGemPos[TArray].Y;
}

function VMDBufferPlayer GetVMDBufferPlayer()
{
	if (LastVMDBufferPlayer == None)
	{
		LastVMDBufferPlayer = VMDBufferPlayer(GetPlayerPawn());
	}
	return LastVMDBufferPlayer;
}

defaultproperties
{
    Skills(0)=class'SkillComputer'
    Skills(1)=class'SkillDemolition'
    Skills(2)=class'SkillEnviro'
    Skills(3)=class'SkillLockpicking'
    Skills(4)=class'SkillMedicine'
    Skills(5)=class'SkillSwimming'
    Skills(6)=class'SkillTech'
    Skills(7)=class'SkillWeaponHeavy'
    Skills(8)=class'SkillWeaponLowTech'
    Skills(9)=class'SkillWeaponPistol'
    Skills(10)=class'SkillWeaponRifle'
    
    JumpGemJumpLoc(0)=(X=-400,Y=-1200)
    JumpGemJumpLoc(1)=(X=-800,Y=-800)
    JumpGemJumpLoc(2)=(X=-400,Y=0)
    JumpGemJumpLoc(3)=(X=0,Y=-800)
    JumpGemJumpLoc(4)=(X=0,Y=-1200)
    JumpGemJumpLoc(5)=(X=0,Y=0)
    JumpGemJumpLoc(6)=(X=-400,Y=-800)
    JumpGemJumpLoc(7)=(X=-800,Y=-1200)
    JumpGemJumpLoc(8)=(X=0,Y=-400)
    JumpGemJumpLoc(9)=(X=-400,Y=-400)
    JumpGemJumpLoc(10)=(X=-800,Y=-400)
    
    SkillGemPos(0)=(X=640,Y=1346)
    SkillGemPos(1)=(X=1040,Y=946)
    SkillGemPos(2)=(X=640,Y=146)
    SkillGemPos(3)=(X=240,Y=946)
    SkillGemPos(4)=(X=240,Y=1346)
    SkillGemPos(5)=(X=240,Y=146)
    SkillGemPos(6)=(X=640,Y=946)
    SkillGemPos(7)=(X=1040,Y=1346)
    SkillGemPos(8)=(X=240,Y=546)
    SkillGemPos(9)=(X=640,Y=546)
    SkillGemPos(10)=(X=1040,Y=546)
    
    //This order is "logical", but does nothing for navigating the map quickly.
    //SkillMapSkillOrder(0)=class'SkillComputer' //Computer
    //SkillMapSkillOrder(1)=class'SkillTech' //Electronics
    //SkillMapSkillOrder(2)=class'SkillLockpicking' //Infiltration
    //SkillMapSkillOrder(3)=class'SkillSwimming' //Fitness
    //SkillMapSkillOrder(4)=class'SkillMedicine' //Medicine
    //SkillMapSkillOrder(5)=class'SkillEnviro' //Tactical Gear
    //SkillMapSkillOrder(6)=class'SkillDemolition' //Weapons: Demolition
    //SkillMapSkillOrder(7)=class'SkillWeaponHeavy' //Weapons: Heavy
    //SkillMapSkillOrder(8)=class'SkillWeaponLowTech' //Weapons: Low Tech
    //SkillMapSkillOrder(9)=class'SkillWeaponPistol' //Weapons: Pistol
    //SkillMapSkillOrder(10)=class'SkillWeaponRifle' //Weapons: Rifle
    
    //Use THIS order for left > right, top > down navigation order.
    SkillMapSkillOrder(0)=class'SkillSwimming' //Fitness
    SkillMapSkillOrder(1)=class'SkillEnviro' //Tactical Gear
    SkillMapSkillOrder(2)=class'SkillWeaponLowTech' //Weapons: Low Tech
    SkillMapSkillOrder(3)=class'SkillWeaponPistol' //Weapons: Pistol
    SkillMapSkillOrder(4)=class'SkillWeaponRifle' //Weapons: Rifle
    SkillMapSkillOrder(5)=class'SkillLockpicking' //Infiltration
    SkillMapSkillOrder(6)=class'SkillTech' //Electronics
    SkillMapSkillOrder(7)=class'SkillDemolition' //Weapons: Demolition
    SkillMapSkillOrder(8)=class'SkillMedicine' //Medicine
    SkillMapSkillOrder(9)=class'SkillComputer' //Computer
    SkillMapSkillOrder(10)=class'SkillWeaponHeavy' //Weapons: Heavy
    
    //Base pos: 240, 146
    SkillTalentIDs(0)=SwimmingBreathRegen
    SkillTalentIcons(0)="Swimming"
    SkillTalentPos(0)=(X=112,Y=162)
    SkillTalentIDs(1)=SwimmingDrowningRate
    SkillTalentIcons(1)="Swimming"
    SkillTalentPos(1)=(X=96,Y=82)
    SkillTalentIDs(2)=SwimmingFallRoll
    SkillTalentIcons(2)="Swimming"
    SkillTalentPos(2)=(X=402,Y=162)
    SkillTalentIDs(3)=SwimmingRoll
    SkillTalentIcons(3)="Swimming"
    SkillTalentPos(3)=(X=416,Y=82)
    SkillTalentIDs(4)=SwimmingFitness
    SkillTalentIcons(4)="Swimming"
    SkillTalentPos(4)=(X=256,Y=18)
    MapBranchingTexture(0)=Texture'SkillMapBranchSwimming01A'
    MapBranchingTalent(0)=SwimmingDrowningRate
    MapBranchingPos(0)=(X=125,Y=138)
    MapBranchingSize(0)=(X=32,Y=64)
    MapBranchingTexture(1)=Texture'SkillMapBranchSwimming01B'
    MapBranchingTalent(1)=SwimmingBreathRegen
    MapBranchingPos(1)=(X=163,Y=191)
    MapBranchingSize(1)=(X=128,Y=8)
    MapBranchingTexture(2)=Texture'SkillMapBranchSwimming01C'
    MapBranchingTalent(2)=SwimmingFitness
    MapBranchingPos(2)=(X=284,Y=74)
    MapBranchingSize(2)=(X=8,Y=128)
    MapBranchingTexture(3)=Texture'SkillMapBranchSwimming02A'
    MapBranchingTalent(3)=SwimmingFallRoll
    MapBranchingPos(3)=(X=317,Y=191)
    MapBranchingSize(3)=(X=128,Y=8)
    MapBranchingTexture(4)=Texture'SkillMapBranchSwimming02B'
    MapBranchingTalent(4)=SwimmingRoll
    MapBranchingPos(4)=(X=430,Y=138)
    MapBranchingSize(4)=(X=32,Y=64)
    SkillTalentIDs(5)=EnviroDeactivate
    SkillTalentIcons(5)="Enviro"
    SkillTalentPos(5)=(X=512,Y=162)
    SkillTalentIDs(6)=EnviroDurability
    SkillTalentIcons(6)="Enviro"
    SkillTalentPos(6)=(X=496,Y=82)
    SkillTalentIDs(7)=EnviroCopies
    SkillTalentIcons(7)="Enviro"
    SkillTalentPos(7)=(X=802,Y=162)
    SkillTalentIDs(8)=EnviroCopyStacks
    SkillTalentIcons(8)="Enviro"
    SkillTalentPos(8)=(X=816,Y=82)
    SkillTalentIDs(9)=EnviroLooting
    SkillTalentIcons(9)="Enviro"
    SkillTalentPos(9)=(X=656,Y=18)
    MapBranchingTexture(5)=Texture'SkillMapBranchEnviro01A'
    MapBranchingTalent(5)=EnviroDurability
    MapBranchingPos(5)=(X=525,Y=138)
    MapBranchingSize(5)=(X=32,Y=64)
    MapBranchingTexture(6)=Texture'SkillMapBranchEnviro01B'
    MapBranchingTalent(6)=EnviroDeactivate
    MapBranchingPos(6)=(X=563,Y=191)
    MapBranchingSize(6)=(X=128,Y=8)
    MapBranchingTexture(7)=Texture'SkillMapBranchEnviro02A'
    MapBranchingTalent(7)=EnviroCopies
    MapBranchingPos(7)=(X=717,Y=191)
    MapBranchingSize(7)=(X=128,Y=8)
    MapBranchingTexture(8)=Texture'SkillMapBranchEnviro02B'
    MapBranchingTalent(8)=EnviroCopyStacks
    MapBranchingPos(8)=(X=830,Y=138)
    MapBranchingSize(8)=(X=32,Y=64)
    MapBranchingTexture(9)=Texture'SkillMapBranchEnviro03A'
    MapBranchingTalent(9)=EnviroLooting
    MapBranchingPos(9)=(X=684,Y=69)
    MapBranchingSize(9)=(X=8,Y=128)
    SkillTalentIDs(10)=MeleeBatonHeadshots
    SkillTalentIcons(10)="WeaponLowTech"
    SkillTalentPos(10)=(X=112,Y=562)
    SkillTalentIDs(11)=MeleeStunDuration
    SkillTalentIcons(11)="WeaponLowTech"
    SkillTalentPos(11)=(X=48,Y=498)
    SkillTalentIDs(12)=MeleeAssassin
    SkillTalentIcons(12)="WeaponLowTech"
    SkillTalentPos(12)=(X=48,Y=626)
    SkillTalentIDs(13)=MeleeSwingSpeed
    SkillTalentIcons(13)="WeaponLowTech"
    SkillTalentPos(13)=(X=397,Y=425)
    SkillTalentIDs(14)=MeleeProjectileLooting
    SkillTalentIcons(14)="WeaponLowTech"
    SkillTalentPos(14)=(X=402,Y=562)
    SkillTalentIDs(15)=MeleeDoorCrackingWood
    SkillTalentIcons(15)="WeaponLowTech"
    SkillTalentPos(15)=(X=256,Y=708)
    MapBranchingTexture(10)=Texture'SkillMapBranchWeaponLowTech01A'
    MapBranchingTalent(10)=MeleeStunDuration
    MapBranchingPos(10)=(X=97,Y=547)
    MapBranchingSize(10)=(X=32,Y=32)
    MapBranchingTexture(11)=Texture'SkillMapBranchWeaponLowTech01B'
    MapBranchingTalent(11)=MeleeAssassin
    MapBranchingPos(11)=(X=101,Y=609)
    MapBranchingSize(11)=(X=32,Y=32)
    MapBranchingTexture(12)=Texture'SkillMapBranchWeaponLowTech01C'
    MapBranchingTalent(12)=MeleeBatonHeadshots
    MapBranchingPos(12)=(X=163,Y=591)
    MapBranchingSize(12)=(X=128,Y=8)
    MapBranchingTexture(13)=Texture'SkillMapBranchWeaponLowTech01D'
    MapBranchingTalent(13)=MeleeSwingSpeed
    MapBranchingPos(13)=(X=321,Y=477)
    MapBranchingSize(13)=(X=128,Y=128)
    MapBranchingTexture(14)=Texture'SkillMapBranchWeaponLowTech01E'
    MapBranchingTalent(14)=MeleeProjectileLooting
    MapBranchingPos(14)=(X=318,Y=591)
    MapBranchingSize(14)=(X=128,Y=8)
    MapBranchingTexture(15)=Texture'SkillMapBranchWeaponLowTech02A'
    MapBranchingTalent(15)=MeleeDoorCrackingWood
    MapBranchingPos(15)=(X=285,Y=624)
    MapBranchingSize(15)=(X=8,Y=128)
    SkillTalentIDs(16)=PistolFocus
    SkillTalentIcons(16)="WeaponPistol"
    SkillTalentPos(16)=(X=576,Y=496)
    SkillTalentIDs(17)=PistolAltAmmos
    SkillTalentIcons(17)="WeaponPistol"
    SkillTalentPos(17)=(X=512,Y=435)
    SkillTalentIDs(18)=PistolModding
    SkillTalentIcons(18)="WeaponPistol"
    SkillTalentPos(18)=(X=576,Y=630)
    SkillTalentIDs(19)=PistolScope
    SkillTalentIcons(19)="WeaponPistol"
    SkillTalentPos(19)=(X=512,Y=691)
    SkillTalentIDs(20)=PistolReload
    SkillTalentIcons(20)="WeaponPistol"
    SkillTalentPos(20)=(X=512,Y=563)
    MapBranchingTexture(16)=Texture'SkillMapBranchWeaponPistol01B'
    MapBranchingTalent(16)=PistolFocus
    MapBranchingPos(16)=(X=625,Y=542)
    MapBranchingSize(16)=(X=64,Y=32)
    MapBranchingTexture(17)=Texture'SkillMapBranchWeaponPistol01A'
    MapBranchingTalent(17)=PistolAltAmmos
    MapBranchingPos(17)=(X=565,Y=490)
    MapBranchingSize(17)=(X=32,Y=32)
    MapBranchingTexture(18)=Texture'SkillMapBranchWeaponPistol01D'
    MapBranchingTalent(18)=PistolModding
    MapBranchingPos(18)=(X=623,Y=619)
    MapBranchingSize(18)=(X=64,Y=32)
    MapBranchingTexture(19)=Texture'SkillMapBranchWeaponPistol01E'
    MapBranchingTalent(19)=PistolScope
    MapBranchingPos(19)=(X=565,Y=677)
    MapBranchingSize(19)=(X=32,Y=32)
    MapBranchingTexture(20)=Texture'SkillMapBranchWeaponPistol01C'
    MapBranchingTalent(20)=PistolReload
    MapBranchingPos(20)=(X=563,Y=592)
    MapBranchingSize(20)=(X=128,Y=8)
    SkillTalentIDs(21)=TagTeamSmallWeapons
    SkillTalentIcons(21)="Rogue"
    SkillTalentPos(21)=(X=656,Y=363)
    MapBranchingTexture(21)=Texture'SkillMapBranchRogue01A'
    MapBranchingTalent(21)=TagTeamSmallWeapons
    MapBranchingPos(21)=(X=685,Y=224)
    MapBranchingSize(21)=(X=8,Y=256)
    MapBranchingTexture(22)=Texture'SkillMapBranchRogue01B'
    MapBranchingTalent(22)=TagTeamSmallWeapons
    MapBranchingPos(22)=(X=685,Y=414)
    MapBranchingSize(22)=(X=8,Y=256)
    
    //1040, 546 base pos
    SkillTalentIDs(22)=RifleFocus
    SkillTalentIcons(22)="WeaponRifle"
    SkillTalentPos(22)=(X=1138,Y=496)
    SkillTalentIDs(23)=RifleAltAmmos
    SkillTalentIcons(23)="WeaponRifle"
    SkillTalentPos(23)=(X=1202,Y=435)
    SkillTalentIDs(24)=RifleOperation
    SkillTalentIcons(24)="WeaponRifle"
    SkillTalentPos(24)=(X=1138,Y=630)
    SkillTalentIDs(25)=RifleReload
    SkillTalentIcons(25)="WeaponRifle"
    SkillTalentPos(25)=(X=1202,Y=691)
    SkillTalentIDs(26)=RifleModding
    SkillTalentIcons(26)="WeaponRifle"
    SkillTalentPos(26)=(X=1202,Y=563)
    MapBranchingTexture(23)=Texture'SkillMapBranchWeaponRifle01B'
    MapBranchingTalent(23)=RifleFocus
    MapBranchingPos(23)=(X=1116,Y=542)
    MapBranchingSize(23)=(X=64,Y=32)
    MapBranchingTexture(24)=Texture'SkillMapBranchWeaponRifle01A'
    MapBranchingTalent(24)=RifleAltAmmos
    MapBranchingPos(24)=(X=1185,Y=489)
    MapBranchingSize(24)=(X=32,Y=32)
    MapBranchingTexture(25)=Texture'SkillMapBranchWeaponRifle01D'
    MapBranchingTalent(25)=RifleOperation
    MapBranchingPos(25)=(X=1114,Y=619)
    MapBranchingSize(25)=(X=64,Y=32)
    MapBranchingTexture(26)=Texture'SkillMapBranchWeaponRifle01E'
    MapBranchingTalent(26)=RifleReload
    MapBranchingPos(26)=(X=1185,Y=677)
    MapBranchingSize(26)=(X=32,Y=32)
    MapBranchingTexture(27)=Texture'SkillMapBranchWeaponRifle01C'
    MapBranchingTalent(27)=RifleModding
    MapBranchingPos(27)=(X=1118,Y=592)
    MapBranchingSize(27)=(X=128,Y=8)
    SkillTalentIDs(27)=TagTeamClosedWaterproof
    SkillTalentIcons(27)="Intricate"
    SkillTalentPos(27)=(X=857,Y=519)
    SkillTalentIDs(28)=TagTeamClosedHeadshot
    SkillTalentIcons(28)="Intricate"
    SkillTalentPos(28)=(X=857,Y=397)
    SkillTalentIDs(29)=TagTeamOpenDecayRate
    SkillTalentIcons(29)="Robust"
    SkillTalentPos(29)=(X=857,Y=607)
    SkillTalentIDs(30)=TagTeamOpenChamber
    SkillTalentIcons(30)="Robust"
    SkillTalentPos(30)=(X=857,Y=729)
    MapBranchingTexture(28)=Texture'SkillMapBranchIntricate01A'
    MapBranchingTalent(28)=TagTeamClosedWaterproof
    MapBranchingPos(28)=(X=712,Y=565)
    MapBranchingSize(28)=(X=256,Y=8)
    MapBranchingTexture(29)=Texture'SkillMapBranchIntricate01B'
    MapBranchingTalent(29)=TagTeamClosedWaterproof
    MapBranchingPos(29)=(X=904,Y=565)
    MapBranchingSize(29)=(X=256,Y=8)
    MapBranchingTexture(30)=Texture'SkillMapBranchIntricate02A'
    MapBranchingTalent(30)=TagTeamClosedHeadshot
    MapBranchingPos(30)=(X=886,Y=448)
    MapBranchingSize(30)=(X=8,Y=128)
    MapBranchingTexture(31)=Texture'SkillMapBranchRobust01A'
    MapBranchingTalent(31)=TagTeamOpenDecayRate
    MapBranchingPos(31)=(X=712,Y=619)
    MapBranchingSize(31)=(X=256,Y=8)
    MapBranchingTexture(32)=Texture'SkillMapBranchRobust01B'
    MapBranchingTalent(32)=TagTeamOpenDecayRate
    MapBranchingPos(32)=(X=904,Y=619)
    MapBranchingSize(32)=(X=256,Y=8)
    MapBranchingTexture(33)=Texture'SkillMapBranchRobust02A'
    MapBranchingTalent(33)=TagTeamOpenChamber
    MapBranchingPos(33)=(X=886,Y=658)
    MapBranchingSize(33)=(X=8,Y=128)
    SkillTalentIDs(31)=LockpickStealthBar
    SkillTalentIcons(31)="Lockpicking"
    SkillTalentPos(31)=(X=74,Y=962)
    SkillTalentIDs(32)=LockpickPickpocket
    SkillTalentIcons(32)="Lockpicking"
    SkillTalentPos(32)=(X=146,Y=863)
    SkillTalentIDs(33)=LockpickScent
    SkillTalentIcons(33)="Lockpicking"
    SkillTalentPos(33)=(X=293,Y=1075)
    SkillTalentIDs(34)=LockpickStartStealth
    SkillTalentIcons(34)="Lockpicking"
    SkillTalentPos(34)=(X=145,Y=1074)
    MapBranchingTexture(34)=Texture'SkillMapBranchLockpicking01B'
    MapBranchingTalent(34)=LockpickStealthBar
    MapBranchingPos(34)=(X=125,Y=991)
    MapBranchingSize(34)=(X=256,Y=8)
    MapBranchingTexture(35)=Texture'SkillMapBranchLockpicking01A'
    MapBranchingTalent(35)=LockpickPickpocket
    MapBranchingPos(35)=(X=194,Y=910)
    MapBranchingSize(35)=(X=128,Y=64)
    MapBranchingTexture(36)=Texture'SkillMapBranchLockpicking01D'
    MapBranchingTalent(36)=LockpickScent
    MapBranchingPos(36)=(X=286,Y=1024)
    MapBranchingSize(36)=(X=64,Y=64)
    MapBranchingTexture(37)=Texture'SkillMapBranchLockpicking01C'
    MapBranchingTalent(37)=LockpickStartStealth
    MapBranchingPos(37)=(X=198,Y=1028)
    MapBranchingSize(37)=(X=64,Y=64)
    SkillTalentIDs(35)=TagTeamDoorCrackingMetal
    SkillTalentIcons(35)="Burglar"
    SkillTalentPos(35)=(X=256,Y=816)
    MapBranchingTexture(38)=Texture'SkillMapBranchBurglar01A'
    MapBranchingTalent(38)=TagTeamDoorCrackingMetal
    MapBranchingPos(38)=(X=285,Y=759)
    MapBranchingSize(38)=(X=8,Y=256)
    
    //640, 946 base pos
    SkillTalentIDs(36)=ElectronicsSpeed
    SkillTalentIcons(36)="Tech"
    SkillTalentPos(36)=(X=656,Y=807)
    SkillTalentIDs(37)=ElectronicsHackingPotency1
    SkillTalentIcons(37)="Tech"
    SkillTalentPos(37)=(X=571,Y=849)
    SkillTalentIDs(38)=ElectronicsHackingPotency2
    SkillTalentIcons(38)="Tech"
    SkillTalentPos(38)=(X=501,Y=779)
    SkillTalentIDs(39)=None
    SkillTalentIcons(39)=""
    SkillTalentPos(39)=(X=501,Y=887)
    SkillTalentIDs(40)=ElectronicsCrafting
    SkillTalentIcons(40)="Tech"
    SkillTalentPos(40)=(X=494,Y=1068)
    SkillTalentIDs(41)=ElectronicsTurrets
    SkillTalentIcons(41)="Tech"
    SkillTalentPos(41)=(X=656,Y=1152)
    SkillTalentIDs(42)=ElectronicsDrones
    SkillTalentIcons(42)="Tech"
    SkillTalentPos(42)=(X=736,Y=1058)
    SkillTalentIDs(43)=ElectronicsDroneArmor
    SkillTalentIcons(43)="Tech"
    SkillTalentPos(43)=(X=800,Y=807)
    MapBranchingTexture(39)=Texture'SkillMapBranchElectronics01A'
    MapBranchingTalent(39)=ElectronicsSpeed
    MapBranchingPos(39)=(X=685,Y=863)
    MapBranchingSize(39)=(X=8,Y=128)
    MapBranchingTexture(40)=Texture'SkillMapBranchElectronics02A'
    MapBranchingTalent(40)=ElectronicsHackingPotency1
    MapBranchingPos(40)=(X=620,Y=896)
    MapBranchingSize(40)=(X=256,Y=256)
    MapBranchingTexture(41)=Texture'SkillMapBranchElectronics02A2'
    MapBranchingTalent(41)=ElectronicsHackingPotency2
    MapBranchingPos(41)=(X=550,Y=826)
    MapBranchingSize(41)=(X=256,Y=256)
    MapBranchingTexture(42)=Texture'SkillMapBranchElectronics01B'
    MapBranchingTalent(42)=ElectronicsFailNoise
    MapBranchingPos(42)=(X=550,Y=933)
    MapBranchingSize(42)=(X=128,Y=64)
    MapBranchingTexture(66)=Texture'SkillMapBranchElectronics02B'
    MapBranchingTalent(66)=ElectronicsCrafting
    MapBranchingPos(66)=(X=548,Y=1027)
    MapBranchingSize(66)=(X=128,Y=64)
    MapBranchingTexture(44)=Texture'SkillMapBranchElectronics02C'
    MapBranchingTalent(44)=ElectronicsTurrets
    MapBranchingPos(44)=(X=684,Y=1031)
    MapBranchingSize(44)=(X=8,Y=128)
    MapBranchingTexture(45)=Texture'SkillMapBranchElectronics01C'
    MapBranchingTalent(45)=ElectronicsDrones
    MapBranchingPos(45)=(X=714,Y=1020)
    MapBranchingSize(45)=(X=64,Y=64)
    MapBranchingTexture(46)=Texture'SkillMapBranchElectronics02D'
    MapBranchingTalent(46)=ElectronicsDroneArmor
    MapBranchingPos(46)=(X=764,Y=835)
    MapBranchingSize(46)=(X=64,Y=256)
    SkillTalentIDs(44)=TagTeamMiniTurret
    SkillTalentIcons(44)="Armorer"
    SkillTalentPos(44)=(X=656,Y=711)
    MapBranchingTexture(47)=Texture'SkillMapBranchArmorer01A'
    MapBranchingTalent(47)=TagTeamMiniTurret
    MapBranchingPos(47)=(X=686,Y=624)
    MapBranchingSize(47)=(X=8,Y=128)
    MapBranchingTexture(48)=Texture'SkillMapBranchArmorer01B'
    MapBranchingTalent(48)=TagTeamMiniTurret
    MapBranchingPos(48)=(X=710,Y=764)
    MapBranchingSize(48)=(X=64,Y=128)
    MapBranchingTexture(49)=Texture'SkillMapBranchArmorer01C'
    MapBranchingTalent(49)=TagTeamMiniTurret
    MapBranchingPos(49)=(X=764,Y=835)
    MapBranchingSize(49)=(X=64,Y=256)
    
    //640, 946 base pos.
    SkillTalentIDs(45)=TagTeamInvaderCapacity
    SkillTalentIcons(45)="Invader"
    SkillTalentPos(45)=(X=456,Y=962) //-184, +16
    MapBranchingTexture(50)=Texture'SkillMapBranchInvader01A'
    MapBranchingTalent(50)=TagTeamInvaderCapacity
    MapBranchingPos(50)=(X=318,Y=992) //-322, +46
    MapBranchingSize(50)=(X=256,Y=8)
    MapBranchingTexture(51)=Texture'SkillMapBranchInvader01B'
    MapBranchingTalent(51)=TagTeamInvaderCapacity
    MapBranchingPos(51)=(X=574,Y=992) //-66, +46
    MapBranchingSize(51)=(X=128,Y=8)
    
    //1040, 946 base pos.
    SkillTalentIDs(46)=DemolitionMineHandling
    SkillTalentIcons(46)="Demolition"
    SkillTalentPos(46)=(X=944,Y=850) //-96 X, -96 Y
    SkillTalentIDs(47)=DemolitionMines
    SkillTalentIcons(47)="Demolition"
    SkillTalentPos(47)=(X=1170,Y=850) //+130 X, -96 Y
    SkillTalentIDs(48)=DemolitionGrenadeMaxAmmo
    SkillTalentIcons(48)="Demolition"
    SkillTalentPos(48)=(X=1200,Y=962) //+160 X. +16 Y, to even it out?
    SkillTalentIDs(49)=DemolitionLooting
    SkillTalentIcons(49)="Demolition"
    SkillTalentPos(49)=(X=1312,Y=962) //+ 112 X
    SkillTalentIDs(50)=DemolitionTearGas
    SkillTalentIcons(50)="Demolition"
    SkillTalentPos(50)=(X=1170,Y=1076) //+130 Y
    SkillTalentIDs(51)=DemolitionEMP
    SkillTalentIcons(51)="Demolition"
    SkillTalentPos(51)=(X=944,Y=1076)
    MapBranchingTexture(52)=Texture'SkillMapBranchDemolition01A'
    MapBranchingTalent(52)=DemolitionMineHandling
    MapBranchingPos(52)=(X=991,Y=900)
    MapBranchingSize(52)=(X=128,Y=128)
    MapBranchingTexture(53)=Texture'SkillMapBranchDemolition01B'
    MapBranchingTalent(53)=DemolitionMines
    MapBranchingPos(53)=(X=1114,Y=897)
    MapBranchingSize(53)=(X=128,Y=128)
    MapBranchingTexture(54)=Texture'SkillMapBranchDemolition01C'
    MapBranchingTalent(54)=DemolitionGrenadeMaxAmmo
    MapBranchingPos(54)=(X=1118,Y=991)
    MapBranchingSize(54)=(X=128,Y=8)
    MapBranchingTexture(55)=Texture'SkillMapBranchDemolition01D'
    MapBranchingTalent(55)=DemolitionLooting
    MapBranchingPos(55)=(X=1251,Y=990)
    MapBranchingSize(55)=(X=128,Y=8)
    MapBranchingTexture(56)=Texture'SkillMapBranchDemolition01E'
    MapBranchingTalent(56)=DemolitionTearGas
    MapBranchingPos(56)=(X=1114,Y=1020)
    MapBranchingSize(56)=(X=128,Y=128)
    MapBranchingTexture(57)=Texture'SkillMapBranchDemolition01F'
    MapBranchingTalent(57)=DemolitionEMP
    MapBranchingPos(57)=(X=991,Y=1020)
    MapBranchingSize(57)=(X=128,Y=128)
    
    //1040, 946 base pos.
    SkillTalentIDs(52)=TagTeamScrambler
    SkillTalentIcons(52)="Arsonist"
    SkillTalentPos(52)=(X=856,Y=962) //-184, +16
    MapBranchingTexture(58)=Texture'SkillMapBranchArsonist01A'
    MapBranchingTalent(58)=TagTeamScrambler
    MapBranchingPos(58)=(X=718,Y=992) //-322, +46
    MapBranchingSize(58)=(X=256,Y=8)
    MapBranchingTexture(59)=Texture'SkillMapBranchArsonist01B'
    MapBranchingTalent(59)=TagTeamScrambler
    MapBranchingPos(59)=(X=882,Y=1018) //-167, -32
    MapBranchingSize(59)=(X=128,Y=128)
    
    //Base pos: 240, 1346
    //Pure left offset:  -128 X
    //Pure right offset: +162 X
    //Pure down offset:  +162 Y?
    SkillTalentIDs(53)=MedicineWraparound
    SkillTalentIcons(53)="Medicine"
    SkillTalentPos(53)=(X=144,Y=1250) //-96, -96?
    SkillTalentIDs(54)=MedicineStress
    SkillTalentIcons(54)="Medicine"
    SkillTalentPos(54)=(X=112,Y=1362)
    SkillTalentIDs(55)=MedicineRevive
    SkillTalentIcons(55)="Medicine"
    SkillTalentPos(55)=(X=80,Y=1540)
    SkillTalentIDs(56)=MedicineCapacity
    SkillTalentIcons(56)="Medicine"
    SkillTalentPos(56)=(X=256,Y=1508)
    SkillTalentIDs(57)=MedicineCrafting
    SkillTalentIcons(57)="Medicine"
    SkillTalentPos(57)=(X=434,Y=1362)
    MapBranchingTexture(60)=Texture'SkillMapBranchMedicine01A'
    MapBranchingTalent(60)=MedicineWraparound
    MapBranchingPos(60)=(X=198,Y=1304)
    MapBranchingSize(60)=(X=64,Y=64)
    MapBranchingTexture(61)=Texture'SkillMapBranchMedicine01B'
    MapBranchingTalent(61)=MedicineStress
    MapBranchingPos(61)=(X=163,Y=1391)
    MapBranchingSize(61)=(X=128,Y=8)
    MapBranchingTexture(62)=Texture'SkillMapBranchMedicine03A'
    MapBranchingTalent(62)=MedicineRevive
    MapBranchingPos(62)=(X=131,Y=1535)
    MapBranchingSize(62)=(X=256,Y=64)
    MapBranchingTexture(63)=Texture'SkillMapBranchMedicine02A'
    MapBranchingTalent(63)=MedicineCapacity
    MapBranchingPos(63)=(X=284,Y=1431)
    MapBranchingSize(63)=(X=8,Y=128)
    MapBranchingTexture(64)=Texture'SkillMapBranchMedicine02B'
    MapBranchingTalent(64)=MedicineCrafting
    MapBranchingPos(64)=(X=325,Y=1390)
    MapBranchingSize(64)=(X=128,Y=8)
    SkillTalentIDs(58)=TagTeamMedicalSyringe
    SkillTalentIcons(58)="Biotech"
    SkillTalentPos(58)=(X=434,Y=1250) //+130 X, -96 Y
    MapBranchingTexture(65)=Texture'SkillMapBranchBiotech01A'
    MapBranchingTalent(65)=TagTeamMedicalSyringe
    MapBranchingPos(65)=(X=313,Y=1297)
    MapBranchingSize(65)=(X=256,Y=128)
    MapBranchingTexture(43)=Texture'SkillMapBranchBiotech01B'
    MapBranchingTalent(43)=TagTeamMedicalSyringe
    MapBranchingPos(43)=(X=481,Y=1020)
    MapBranchingSize(43)=(X=256,Y=256)
    
    SkillTalentIDs(72)=MedicineCombatDrugs
    SkillTalentIcons(72)="Medicine"
    SkillTalentPos(72)=(X=256,Y=1207) //+16, -139
    MapBranchingTexture(82)=Texture'SkillMapBranchMedicine01C'
    MapBranchingTalent(82)=MedicineCombatDrugs
    MapBranchingPos(82)=(X=286,Y=1258) //+46, -88
    MapBranchingSize(82)=(X=8,Y=128)
    
    //Base pos: 640, 1346
    //Upper Left: -139, -59
    //Lower Left: -146, +122
    //Bottom: +16, +162
    //Lower Right Part 1: +96, +112
    //Lower Right Part 2: +64 (use 80), +61 (Use 80)
    SkillTalentIDs(59)=ComputerSpecialOptions
    SkillTalentIcons(59)="Computer"
    SkillTalentPos(59)=(X=501,Y=1287)
    SkillTalentIDs(60)=ComputerATMQuality
    SkillTalentIcons(60)="Computer"
    SkillTalentPos(60)=(X=494,Y=1468)
    SkillTalentIDs(61)=ComputerTurrets
    SkillTalentIcons(61)="Computer"
    SkillTalentPos(61)=(X=656,Y=1508)
    SkillTalentIDs(62)=ComputerScaling
    SkillTalentIcons(62)="Computer"
    SkillTalentPos(62)=(X=736,Y=1458)
    SkillTalentIDs(63)=ComputerLockout
    SkillTalentIcons(63)="Computer"
    SkillTalentPos(63)=(X=816,Y=1538)
    MapBranchingTexture(67)=Texture'SkillMapBranchComputer01A'
    MapBranchingTalent(67)=ComputerSpecialOptions
    MapBranchingPos(67)=(X=550,Y=1333)
    MapBranchingSize(67)=(X=128,Y=64)
    MapBranchingTexture(68)=Texture'SkillMapBranchComputer01B'
    MapBranchingTalent(68)=ComputerATMQuality
    MapBranchingPos(68)=(X=546,Y=1427)
    MapBranchingSize(68)=(X=128,Y=64)
    MapBranchingTexture(69)=Texture'SkillMapBranchComputer01C'
    MapBranchingTalent(69)=ComputerTurrets
    MapBranchingPos(69)=(X=684,Y=1431)
    MapBranchingSize(69)=(X=8,Y=128)
    MapBranchingTexture(70)=Texture'SkillMapBranchComputer01D'
    MapBranchingTalent(70)=ComputerScaling
    MapBranchingPos(70)=(X=714,Y=1420)
    MapBranchingSize(70)=(X=64,Y=64)
    MapBranchingTexture(71)=Texture'SkillMapBranchComputer01E'
    MapBranchingTalent(71)=ComputerLockout
    MapBranchingPos(71)=(X=782,Y=1504)
    MapBranchingSize(71)=(X=64,Y=64)
    
    //Base pos? 640, 1346
    //X? 96 or 736 X. Add 80 for 2nd gem? 816 X for #2.
    //Y? -96, or 1250 Y.
    SkillTalentIDs(64)=TagTeamLiteHack
    SkillTalentIcons(64)="Wares"
    SkillTalentPos(64)=(X=736,Y=1250)
    SkillTalentIDs(65)=TagTeamSkillware
    SkillTalentIcons(65)="Wares"
    SkillTalentPos(65)=(X=804,Y=1250)
    MapBranchingTexture(72)=Texture'SkillMapBranchWares01A'
    MapBranchingTalent(72)=TagTeamLiteHack
    MapBranchingPos(72)=(X=765,Y=1110)
    MapBranchingSize(72)=(X=8,Y=256)
    MapBranchingTexture(73)=Texture'SkillMapBranchWares01B'
    MapBranchingTalent(73)=TagTeamSkillware
    MapBranchingPos(73)=(X=765,Y=1109)
    MapBranchingSize(73)=(X=128,Y=256)
    MapBranchingTexture(74)=Texture'SkillMapBranchWares01C'
    MapBranchingTalent(74)=TagTeamLiteHack
    MapBranchingPos(74)=(X=713,Y=1297)
    MapBranchingSize(74)=(X=64,Y=128)
    MapBranchingTexture(75)=Texture'SkillMapBranchWares01D'
    MapBranchingTalent(75)=TagTeamSkillware
    MapBranchingPos(75)=(X=714,Y=1306)
    MapBranchingSize(75)=(X=256,Y=64)
    
    SkillTalentIDs(73)=TagTeamMeleeSkillware
    SkillTalentIcons(73)="Wares"
    SkillTalentPos(73)=(X=872,Y=1250)
    MapBranchingTexture(83)=Texture'SkillMapBranchWares01E'
    MapBranchingTalent(83)=TagTeamMeleeSkillware
    MapBranchingPos(83)=(X=765,Y=1110)
    MapBranchingSize(83)=(X=256,Y=256)
    MapBranchingTexture(84)=Texture'SkillMapBranchWares01F'
    MapBranchingTalent(84)=TagTeamMeleeSkillware
    MapBranchingPos(84)=(X=713,Y=1301)
    MapBranchingSize(84)=(X=256,Y=128)
    
    //1040, 1346 base pos.
    //Upper Right: +130, -96
    //Lower Right: +130, 130
    //Difference: 46 more when skipping past
    //Lower Right Part 2: +64 (use 80), +61
    //Upper Right Part 2: +64 (use 80), -61
    SkillTalentIDs(66)=HeavyFocus
    SkillTalentIcons(66)="WeaponHeavy"
    SkillTalentPos(66)=(X=944,Y=1250) //-96 X, -96 Y
    SkillTalentIDs(67)=HeavyDropAndRoll
    SkillTalentIcons(67)="WeaponHeavy"
    SkillTalentPos(67)=(X=944,Y=1476) //+130 X, -96 Y
    SkillTalentIDs(68)=HeavyProjectileSpeed
    SkillTalentIcons(68)="WeaponHeavy"
    SkillTalentPos(68)=(X=1170,Y=1476) //+130 Y
    SkillTalentIDs(69)=HeavyPlasma
    SkillTalentIcons(69)="WeaponHeavy"
    SkillTalentPos(69)=(X=1250,Y=1537)
    SkillTalentIDs(70)=HeavySpeed
    SkillTalentIcons(70)="WeaponHeavy"
    SkillTalentPos(70)=(X=1170,Y=1250)
    SkillTalentIDs(71)=HeavySwapSpeed
    SkillTalentIcons(71)="WeaponHeavy"
    SkillTalentPos(71)=(X=1250,Y=1189)
    
    MapBranchingTexture(76)=Texture'SkillMapBranchWeaponHeavy01A'
    MapBranchingTalent(76)=HeavyFocus
    MapBranchingPos(76)=(X=991,Y=1297)
    MapBranchingSize(76)=(X=128,Y=128)
    MapBranchingTexture(77)=Texture'SkillMapBranchWeaponHeavy01B'
    MapBranchingTalent(77)=HeavyDropAndRoll
    MapBranchingPos(77)=(X=991,Y=1420)
    MapBranchingSize(77)=(X=128,Y=128)
    MapBranchingTexture(78)=Texture'SkillMapBranchWeaponHeavy01C'
    MapBranchingTalent(78)=HeavyProjectileSpeed
    MapBranchingPos(78)=(X=1114,Y=1420)
    MapBranchingSize(78)=(X=128,Y=128)
    MapBranchingTexture(79)=Texture'SkillMapBranchWeaponHeavy01D'
    MapBranchingTalent(79)=HeavyPlasma
    MapBranchingPos(79)=(X=1217,Y=1523)
    MapBranchingSize(79)=(X=64,Y=32)
    MapBranchingTexture(80)=Texture'SkillMapBranchWeaponHeavy01E'
    MapBranchingTalent(80)=HeavySpeed
    MapBranchingPos(80)=(X=1114,Y=1297)
    MapBranchingSize(80)=(X=128,Y=128)
    MapBranchingTexture(81)=Texture'SkillMapBranchWeaponHeavy01F'
    MapBranchingTalent(81)=HeavySwapSpeed
    MapBranchingPos(81)=(X=1217,Y=1242)
    MapBranchingSize(81)=(X=64,Y=32)
    
    SkillTalentIDs(74)=HeavyFireSpread
    SkillTalentIcons(74)="WeaponHeavy"
    SkillTalentPos(74)=(X=1024,Y=1537)
    MapBranchingTexture(85)=Texture'SkillMapBranchWeaponHeavy01G'
    MapBranchingTalent(85)=HeavyFireSpread
    MapBranchingPos(85)=(X=991,Y=1523)
    MapBranchingSize(85)=(X=64,Y=32)
    
    SkillTalentIDs(75)=TagTeamDodgeRoll
    SkillTalentIcons(75)="Ninja"
    SkillTalentPos(75)=(X=256,Y=364)
    MapBranchingTexture(86)=Texture'SkillMapBranchNinja01A'
    MapBranchingTalent(86)=TagTeamDodgeRoll
    MapBranchingPos(86)=(X=284,Y=224)
    MapBranchingSize(86)=(X=8,Y=256)
    MapBranchingTexture(87)=Texture'SkillMapBranchNinja01B'
    MapBranchingTalent(87)=TagTeamDodgeRoll
    MapBranchingPos(87)=(X=284,Y=420)
    MapBranchingSize(87)=(X=8,Y=256)
    
    //ACTUAL LAST TALENT USED IS 75!
    //ACTUAL LAST BRANCH USED IS 86!
    
    SkillCoreDescs(0)="The covert manipulation of computers, ATMS, security consoles. Actions taken during hacking will increase the risk of being detected."
    SkillLevelDescsA(0)="|n~An agent can use terminals normally, but cannot hack without resonating with Software.|n*If they are resonating, they may hack for 33%% less time and 50%% less cash rewards than standard."
    AltSkillLevelDescsA(0)="|n~An agent can hack %d%% longer than standard.|n*Cash rewards are still a standard 100%%." //HACK! Actually for trained!
    SkillLevelDescsB(0)="|n~An agent can hack at a baseline level.|n~100%% cash rewards from hacked ATMs."
    SkillLevelDescsC(0)="|n~An agent can hack for %d%% longer than standard.|n~200%% cash rewards from hacked ATMs."
    SkillLevelDescsD(0)="|n~An agent can hack for %d%% longer than standard.|n~300%% cash rewards from hacked ATMs."
    
    SkillCoreDescs(1)="The use of thrown explosive devices, including LAMs, gas grenades, EMP grenades, and even electronic scrambler grenades."
    SkillLevelDescsA(1)="|n~An agent can throw, emplace, and attempt to disarm grenades."
    AltSkillLevelDescsA(1)="|n~Grenade accuracy is increased by %d%%.|n~Time to disarm is standard.|n~Grenade damage output is increased by %d%%."
    SkillLevelDescsB(1)="|n~Grenade accuracy is increased by %d%%.|n~Time to disarm is increased slightly.|n~Grenade damage output is increased by %d%%."
    SkillLevelDescsC(1)="|n~Grenade accuracy is increased by %d%%.|n~Time to disarm is increased somewhat.|n~Grenade damage output is increased by %d%%."
    SkillLevelDescsD(1)="|n~Grenade accuracy is increased by %d%%.|n~Time to disarm is increased heavily.|n~Grenade damage output is increased by %d%%."
    
    SkillCoreDescs(2)="The use of goggles, hazmat suits, ballistic armor, thermoptic camo, and rebreathers."
    SkillLevelDescsA(2)="|n~Equipment can be used at a standard level.|n~Tactical gear cannot be looted from enemies."
    AltSkillLevelDescsA(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear cannot be looted from enemies."
    SkillLevelDescsB(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear is looted from enemies at 16%% efficiency."
    SkillLevelDescsC(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear is looted from enemies at 33%% efficiency."
    SkillLevelDescsD(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear is looted from enemies at 50%% efficiency."
    NoTalentsSkillLevelDescsA(2)="|n~Equipment can be used at a standard level.|n~Tactical gear cannot be looted from enemies."
    AltNoTalentsSkillLevelDescsA(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear cannot be looted from enemies."
    NoTalentsSkillLevelDescsB(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear is looted from enemies at 33%% efficiency."
    NoTalentsSkillLevelDescsC(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear is looted from enemies at 66%% efficiency."
    NoTalentsSkillLevelDescsD(2)="|n~Equipment can be used for %d%% longer.|n~Defensive equipment offers %d%% more protection.|n~Tactical gear is looted from enemies at 100%% efficiency."
    
    SkillCoreDescs(3)="The effectiveness with which lockpicks can be handled. Talents often focus on enhancing stealth."
    SkillLevelDescsA(3)="|n~Lockpicks can weaken locks by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    AltSkillLevelDescsA(3)="|n~Lockpicks can weaken locks by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    SkillLevelDescsB(3)="|n~Lockpicks can weaken locks by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    SkillLevelDescsC(3)="|n~Lockpicks can weaken locks by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    SkillLevelDescsD(3)="|n~Lockpicks can weaken locks by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    
    SkillCoreDescs(4)="The efficiency with which medkits can be activated, and medical crafting can occur."
    SkillLevelDescsA(4)="|n~Medkits heal for %d units.|n*Crafting cannot occur without a specialization."
    AltSkillLevelDescsA(4)="|n~Medkits heal for %d units.|n*Crafting cannot occur without a specialization."
    SkillLevelDescsB(4)="|n~Medkits heal for %d units.|n~Crafting occurs with 10%% more efficiency.|n~Crafting occurs up to 124%% faster."
    SkillLevelDescsC(4)="|n~Medkits heal for %d units.|n~Crafting occurs with 22%% more efficiency.|n~Crafting occurs up to 192%% faster."
    SkillLevelDescsD(4)="|n~Medkits heal for %d units.|n~Crafting occurs with 37%% more efficiency.|n~Crafting occurs up to 235%% faster."
    NoCraftingSkillLevelDescsA(4)="|n~Medkits heal for %d units."
    AltNoCraftingSkillLevelDescsA(4)="|n~Medkits heal for %d units."
    NoCraftingSkillLevelDescsB(4)="|n~Medkits heal for %d units."
    NoCraftingSkillLevelDescsC(4)="|n~Medkits heal for %d units."
    NoCraftingSkillLevelDescsD(4)="|n~Medkits heal for %d units."
    
    SkillCoreDescs(5)="Underwater and other athletic operations require their own unique set of skills that must be developed by an agent with extreme physical dedication."
    SkillLevelDescsA(5)="|n~An agent can swim at a standard pace.|n~An agent moves 7.5%% slower than standard on land."
    AltSkillLevelDescsA(5)="|n~An agent can swim %d%% faster and longer.|n~An agent moves 7.5%% slower than standard on land."
    SkillLevelDescsB(5)="|n~An agent can swim %d%% faster and longer.|n~An agent moves at a standard pace on land."
    SkillLevelDescsC(5)="|n~An agent can swim %d%% faster and longer.|n~An agent moves 7.5%% faster than standard on land."
    SkillLevelDescsD(5)="|n~An agent can swim %d%% faster and longer.|n~An agent moves 15%% faster than standard on land."
    NoTalentsSkillLevelDescsA(5)="|n~An agent can swim at a standard pace.|n~An agent moves 7.5%% slower than standard on land."
    AltNoTalentsSkillLevelDescsA(5)="|n~An agent can swim %d%% faster.|n~An agent can swim %d%% longer.|n~An agent moves 7.5%% slower than standard on land."
    NoTalentsSkillLevelDescsB(5)="|n~An agent can swim %d%% faster.|n~An agent can swim %d%% longer.|n~An agent moves at a standard pace on land."
    NoTalentsSkillLevelDescsC(5)="|n~An agent can swim %d%% faster.|n~An agent can swim %d%% longer.|n~An agent moves 7.5%% faster than standard on land."
    NoTalentsSkillLevelDescsD(5)="|n~An agent can swim %d%% faster.|n~An agent can swim %d%% longer.|n~An agent moves 15%% faster than standard on land."
    
    SkillCoreDescs(6)="The effectiveness with which multitools can be handled, and mechanical crafting can occur."
    SkillLevelDescsA(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise.|n*Crafting cannot occur without a specialization."
    AltSkillLevelDescsA(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise.|n*Crafting cannot occur without a specialization."
    SkillLevelDescsB(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise.|n~Crafting occurs with 10%% more efficiency.|n~Crafting occurs up to 124%% faster."
    SkillLevelDescsC(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise.|n~Crafting occurs with 22%% more efficiency.|n~Crafting occurs up to 192%% faster."
    SkillLevelDescsD(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise.|n~Crafting occurs with 37%% more efficiency.|n~Crafting occurs up to 235%% faster."
    NoCraftingSkillLevelDescsA(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    AltNoCraftingSkillLevelDescsA(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    NoCraftingSkillLevelDescsB(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    NoCraftingSkillLevelDescsC(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    NoCraftingSkillLevelDescsD(6)="|n~Multitools can weaken devices by %d%% per unit.|n~Failed rush attempts generate %d%% noise."
    
    SkillCoreDescs(7)="The use of heavy weaponry, including flamethrowers, LAWs, and the experimental plasma and GEP guns."
    SkillLevelDescsA(7)="|n~An agent can use heavy weapons with standard efficiency."
    AltSkillLevelDescsA(7)="|n~Heavy accuracy and reload speed are increased by %d%%.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%%."
    SkillLevelDescsB(7)="|n~Heavy accuracy and reload speed are increased by %d%%.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%%.|n~Heavy movement speed is increased by 16%%.|n~Heavy aim focus speeds are increased by 25%%."
    SkillLevelDescsC(7)="|n~Heavy accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%.|n~Heavy movement speed is increased by 33%.|n~Heavy aim focus speeds are increased by 50%."
    SkillLevelDescsD(7)="|n~Heavy accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%.|n~Heavy movement speed  is increased by 50%.|n~Heavy aim focus speeds are increased by 75%."
    NoTalentsSkillLevelDescsA(7)="|n~An agent can use heavy weapons with standard efficiency."
    AltNoTalentsSkillLevelDescsA(7)="|n~Heavy accuracy and reload speed are increased by %d%%.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%%."
    NoTalentsSkillLevelDescsB(7)="|n~Heavy accuracy and reload speed are increased by %d%%.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%%.|n~Heavy movement speed is increased by 33%.|n~Heavy aim focus speeds are increased by 50%."
    NoTalentsSkillLevelDescsC(7)="|n~Heavy accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%.|n~Heavy movement speed is increased by 66%.|n~Heavy aim focus speeds are increased by 100%."
    NoTalentsSkillLevelDescsD(7)="|n~Heavy accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Heavy recoil is decreased by %d%%.|n~Heavy damage is increased by %d%.|n~Heavy movement speed  is increased by 100%.|n~Heavy aim focus speeds are increased by 150%."
    
    SkillCoreDescs(8)="The use of melee weapons such as batons, knives, throwing knives, swords, pepper guns, and prods."
    SkillLevelDescsA(8)="|n~An agent can use low-tech weapons with standard efficiency."
    AltSkillLevelDescsA(8)="|n~Low-tech accuracy and reload speed are increased by %d%%.|n~Low-tech damage is increased by %d%%."
    SkillLevelDescsB(8)="|n~Low-tech accuracy and reload speed are increased by %d%%.|n~Low-tech damage is increased by %d%%."
    SkillLevelDescsC(8)="|n~Low-tech accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Low-tech damage is increased by %d%%."
    SkillLevelDescsD(8)="|n~Low-tech accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Low-tech damage is increased by %d%%."
    
    SkillCoreDescs(9)="The use of hand-held weapons, including the standard 10mm pistol, its stealth variant, the PS20, and the mini-crossbow."
    SkillLevelDescsA(9)="|n~An agent can use pistols with standard efficiency."
    AltSkillLevelDescsA(9)="|n~Pistol accuracy and reload speed are increased by %d%%.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%%."
    SkillLevelDescsB(9)="|n~Pistol accuracy and reload speed are increased by %d%%.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%%.|n~Pistol aim focus speeds are increased by 25%%."
    SkillLevelDescsC(9)="|n~Pistol accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%.|n~Pistol aim focus speeds are increased by 50%."
    SkillLevelDescsD(9)="|n~Pistol accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%.|n~Pistol aim focus speeds are increased by 75%."
    NoTalentsSkillLevelDescsA(9)="|n~An agent can use pistols with standard efficiency."
    AltNoTalentsSkillLevelDescsA(9)="|n~Pistol accuracy and reload speed are increased by %d%%.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%%."
    NoTalentsSkillLevelDescsB(9)="|n~Pistol accuracy and reload speed are increased by %d%%.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%%.|n~Pistol aim focus speeds are increased by 50%%."
    NoTalentsSkillLevelDescsC(9)="|n~Pistol accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%.|n~Pistol aim focus speeds are increased by 100%."
    NoTalentsSkillLevelDescsD(9)="|n~Pistol accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Pistol recoil is decreased by %d%%.|n~Pistol damage is increased by %d%.|n~Pistol aim focus speeds are increased by 150%."
    
    SkillCoreDescs(10)="The use of rifles, including assault rifles, sniper rifles, and shotguns."
    SkillLevelDescsA(10)="|n~An agent can use rifles with standard efficiency."
    AltSkillLevelDescsA(10)="|n~Rifle accuracy and reload speed are increased by %d%%|n~Rifle recoil is decreased by %d%% and damage is increased by %d%%."
    SkillLevelDescsB(10)="|n~Rifle accuracy and reload speed are increased by %d%%.|n~Rifle recoil is decreased by %d%%.|n~Rifle damage is increased by %d%%.|n~Rifle aim focus speeds are increased by 25%%."
    SkillLevelDescsC(10)="|n~Rifle accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Rifle recoil is decreased by %d%%.|n~Rifle damage is increased by %d%.|n~Rifle aim focus speeds are increased by 50%."
    SkillLevelDescsD(10)="|n~Rifle accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Rifle recoil is decreased by %d%%.|n~Rifle damage is increased by %d%.|n~Rifle aim focus speeds are increased by 75%."
    NoTalentsSkillLevelDescsA(10)="|n~An agent can use rifles with standard efficiency."
    AltNoTalentsSkillLevelDescsA(10)="|n~Rifle accuracy and reload speed are increased by %d%%|n~Rifle recoil is decreased by %d%% and damage is increased by %d%%."
    NoTalentsSkillLevelDescsB(10)="|n~Rifle accuracy and reload speed are increased by %d%%.|n~Rifle recoil is decreased by %d%%.|n~Rifle damage is increased by %d%%.|n~Rifle aim focus speeds are increased by 50%%."
    NoTalentsSkillLevelDescsC(10)="|n~Rifle accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Rifle recoil is decreased by %d%%.|n~Rifle damage is increased by %d%.|n~Rifle aim focus speeds are increased by 100%."
    NoTalentsSkillLevelDescsD(10)="|n~Rifle accuracy and reload speed are increased by %d%% and %d%%, respectively.|n~Rifle recoil is decreased by %d%%.|n~Rifle damage is increased by %d%.|n~Rifle aim focus speeds are increased by 150%."
}
