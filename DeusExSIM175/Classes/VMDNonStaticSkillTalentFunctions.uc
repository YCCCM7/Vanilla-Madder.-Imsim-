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
			SkillLevelDescsA[11], AltSkillLevelDescsA[11], SkillLevelDescsB[11], SkillLevelDescsC[11], SkillLevelDescsD[11];
var class<Skill> Skills[11], SkillMapSkillOrder[11];

var string SkillTalentIcons[100], SkillTalentIDs[100];
var VMDButtonPos JumpGemJumpLoc[11], SkillGemPos[11], SkillTalentPos[100], NewGameSkillTalentPosMod;

var string MapBranchingTalent[100];
var Texture MapBranchingFoundationTexture[100], MapBranchingTexture[100];
var VMDButtonPos MapBranchingFoundationPos[100], MapBranchingPos[100];
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
	local int TVars[4];
	local float GetVal;
	local Skill TSkill;
	local VMDBufferPlayer TPlayer;
	
	TPlayer = GetVMDBufferPlayer();
	if (InSkill == None || TPlayer == None || TPlayer.SkillSystem == None) return "ERR NO SKILL CLASS OR PLAYER";
	TSkill = TPlayer.SkillSystem.GetSkillFromClass(InSkill);
	if (TSkill == None) return "ERR NO SKILL";
	
	GetVal = TSkill.LevelValues[InLevel];
	switch(InSkill.Name)
	{
		case 'SkillWeaponHeavy':
		case 'SkillWeaponPistol':
		case 'SkillWeaponRifle':
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
			if ((InLevel == 0) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
			{
				DescStr = AltSkillLevelDescsA[SkillArray];
			}
			TVars[0] = int(((1.0 / Abs(GetVal)) - 1.0) * 100);
			TVars[1] = int(((1.0 / ((Abs(GetVal) + 1.0) / 2)) - 1.0) * 100);
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
			TVars[0] = int(Abs(GetVal) * 100);
		break;
		case 'SkillMedicine':
			TVars[0] = int(Abs(GetVal) * 30);
		break;
		case 'SkillSwimming':
			if ((InLevel == 0) && (Abs(GetVal) > 1.009 || Abs(GetVal) < 0.991))
			{
				DescStr = AltSkillLevelDescsA[SkillArray];
			}
			TVars[0] = int(Abs(GetVal - 1.0) * 50);
		break;
	}
	return SprintF(DescStr, TVars[0], TVars[1], TVars[2], TVars[3]);
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

/*static*/ function string GetSkillTalentIDs(int TArray)
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

/*static*/ function Texture GetBFTexture(int TArray)
{
	return MapBranchingFoundationTexture[TArray];
}

/*static*/ function Texture GetBTexture(int TArray)
{
	return MapBranchingTexture[TArray];
}

/*static*/ function string GetBTalent(int TArray)
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
    SkillTalentIDs(0)="SwimmingBreathRegen"
    SkillTalentIcons(0)="Swimming"
    SkillTalentPos(0)=(X=112,Y=162)
    SkillTalentIDs(1)="SwimmingDrowningRate"
    SkillTalentIcons(1)="Swimming"
    SkillTalentPos(1)=(X=96,Y=82)
    SkillTalentIDs(2)="SwimmingFallRoll"
    SkillTalentIcons(2)="Swimming"
    SkillTalentPos(2)=(X=402,Y=162)
    SkillTalentIDs(3)="SwimmingRoll"
    SkillTalentIcons(3)="Swimming"
    SkillTalentPos(3)=(X=416,Y=82)
    SkillTalentIDs(4)="SwimmingFitness"
    SkillTalentIcons(4)="Swimming"
    SkillTalentPos(4)=(X=256,Y=18)
    MapBranchingTexture(0)=Texture'SkillMapBranchSwimming01A'
    MapBranchingTalent(0)="SwimmingDrowningRate"
    MapBranchingPos(0)=(X=125,Y=138)
    MapBranchingTexture(1)=Texture'SkillMapBranchSwimming01B'
    MapBranchingTalent(1)="SwimmingBreathRegen"
    MapBranchingPos(1)=(X=163,Y=191)
    MapBranchingTexture(2)=Texture'SkillMapBranchSwimming01C'
    MapBranchingTalent(2)="SwimmingFitness"
    MapBranchingPos(2)=(X=284,Y=74)
    MapBranchingTexture(3)=Texture'SkillMapBranchSwimming02A'
    MapBranchingTalent(3)="SwimmingFallRoll"
    MapBranchingPos(3)=(X=317,Y=191)
    MapBranchingTexture(4)=Texture'SkillMapBranchSwimming02B'
    MapBranchingTalent(4)="SwimmingRoll"
    MapBranchingPos(4)=(X=430,Y=138)
    SkillTalentIDs(5)="EnviroDeactivate"
    SkillTalentIcons(5)="Enviro"
    SkillTalentPos(5)=(X=512,Y=162)
    SkillTalentIDs(6)="EnviroDurability"
    SkillTalentIcons(6)="Enviro"
    SkillTalentPos(6)=(X=496,Y=82)
    SkillTalentIDs(7)="EnviroCopies"
    SkillTalentIcons(7)="Enviro"
    SkillTalentPos(7)=(X=802,Y=162)
    SkillTalentIDs(8)="EnviroCopyStacks"
    SkillTalentIcons(8)="Enviro"
    SkillTalentPos(8)=(X=816,Y=82)
    SkillTalentIDs(9)="EnviroLooting"
    SkillTalentIcons(9)="Enviro"
    SkillTalentPos(9)=(X=656,Y=18)
    MapBranchingTexture(5)=Texture'SkillMapBranchEnviro01A'
    MapBranchingTalent(5)="EnviroDurability"
    MapBranchingPos(5)=(X=525,Y=138)
    MapBranchingTexture(6)=Texture'SkillMapBranchEnviro01B'
    MapBranchingTalent(6)="EnviroDeactivate"
    MapBranchingPos(6)=(X=563,Y=191)
    MapBranchingTexture(7)=Texture'SkillMapBranchEnviro02A'
    MapBranchingTalent(7)="EnviroCopies"
    MapBranchingPos(7)=(X=717,Y=191)
    MapBranchingTexture(8)=Texture'SkillMapBranchEnviro02B'
    MapBranchingTalent(8)="EnviroCopyStacks"
    MapBranchingPos(8)=(X=830,Y=138)
    MapBranchingTexture(9)=Texture'SkillMapBranchEnviro03A'
    MapBranchingTalent(9)="EnviroLooting"
    MapBranchingPos(9)=(X=684,Y=69)
    SkillTalentIDs(10)="MeleeBatonHeadshots"
    SkillTalentIcons(10)="WeaponLowTech"
    SkillTalentPos(10)=(X=112,Y=562)
    SkillTalentIDs(11)="MeleeStunDuration"
    SkillTalentIcons(11)="WeaponLowTech"
    SkillTalentPos(11)=(X=48,Y=498)
    SkillTalentIDs(12)="MeleeAssassin"
    SkillTalentIcons(12)="WeaponLowTech"
    SkillTalentPos(12)=(X=48,Y=626)
    SkillTalentIDs(13)="MeleeSwingSpeed"
    SkillTalentIcons(13)="WeaponLowTech"
    SkillTalentPos(13)=(X=256,Y=418)
    SkillTalentIDs(14)="MeleeProjectileLooting"
    SkillTalentIcons(14)="WeaponLowTech"
    SkillTalentPos(14)=(X=402,Y=562)
    SkillTalentIDs(15)="MeleeDoorCrackingWood"
    SkillTalentIcons(15)="WeaponLowTech"
    SkillTalentPos(15)=(X=256,Y=708)
    MapBranchingTexture(10)=Texture'SkillMapBranchWeaponLowTech01A'
    MapBranchingTalent(10)="MeleeStunDuration"
    MapBranchingPos(10)=(X=97,Y=547)
    MapBranchingTexture(11)=Texture'SkillMapBranchWeaponLowTech01B'
    MapBranchingTalent(11)="MeleeAssassin"
    MapBranchingPos(11)=(X=101,Y=609)
    MapBranchingTexture(12)=Texture'SkillMapBranchWeaponLowTech01C'
    MapBranchingTalent(12)="MeleeBatonHeadshots"
    MapBranchingPos(12)=(X=163,Y=591)
    MapBranchingTexture(13)=Texture'SkillMapBranchWeaponLowTech01D'
    MapBranchingTalent(13)="MeleeSwingSpeed"
    MapBranchingPos(13)=(X=284,Y=474)
    MapBranchingTexture(14)=Texture'SkillMapBranchWeaponLowTech01E'
    MapBranchingTalent(14)="MeleeProjectileLooting"
    MapBranchingPos(14)=(X=318,Y=591)
    MapBranchingTexture(15)=Texture'SkillMapBranchWeaponLowTech02A'
    MapBranchingTalent(15)="MeleeDoorCrackingWood"
    MapBranchingPos(15)=(X=285,Y=624)
    SkillTalentIDs(16)="PistolFocus"
    SkillTalentIcons(16)="WeaponPistol"
    SkillTalentPos(16)=(X=576,Y=496)
    SkillTalentIDs(17)="PistolAltAmmos"
    SkillTalentIcons(17)="WeaponPistol"
    SkillTalentPos(17)=(X=512,Y=435)
    SkillTalentIDs(18)="PistolModding"
    SkillTalentIcons(18)="WeaponPistol"
    SkillTalentPos(18)=(X=576,Y=630)
    SkillTalentIDs(19)="PistolScope"
    SkillTalentIcons(19)="WeaponPistol"
    SkillTalentPos(19)=(X=512,Y=691)
    SkillTalentIDs(20)="PistolReload"
    SkillTalentIcons(20)="WeaponPistol"
    SkillTalentPos(20)=(X=512,Y=563)
    MapBranchingTexture(16)=Texture'SkillMapBranchWeaponPistol01B'
    MapBranchingTalent(16)="PistolFocus"
    MapBranchingPos(16)=(X=625,Y=542)
    MapBranchingTexture(17)=Texture'SkillMapBranchWeaponPistol01A'
    MapBranchingTalent(17)="PistolAltAmmos"
    MapBranchingPos(17)=(X=565,Y=490)
    MapBranchingTexture(18)=Texture'SkillMapBranchWeaponPistol01D'
    MapBranchingTalent(18)="PistolModding"
    MapBranchingPos(18)=(X=623,Y=619)
    MapBranchingTexture(19)=Texture'SkillMapBranchWeaponPistol01E'
    MapBranchingTalent(19)="PistolScope"
    MapBranchingPos(19)=(X=565,Y=677)
    MapBranchingTexture(20)=Texture'SkillMapBranchWeaponPistol01C'
    MapBranchingTalent(20)="PistolReload"
    MapBranchingPos(20)=(X=563,Y=592)
    SkillTalentIDs(21)="TagTeamSmallWeapons"
    SkillTalentIcons(21)="Rogue"
    SkillTalentPos(21)=(X=656,Y=363)
    MapBranchingTexture(21)=Texture'SkillMapBranchRogue01A'
    MapBranchingTalent(21)="TagTeamSmallWeapons"
    MapBranchingPos(21)=(X=685,Y=224)
    MapBranchingTexture(22)=Texture'SkillMapBranchRogue01B'
    MapBranchingTalent(22)="TagTeamSmallWeapons"
    MapBranchingPos(22)=(X=685,Y=414)
    
    //1040, 546 base pos
    SkillTalentIDs(22)="RifleFocus"
    SkillTalentIcons(22)="WeaponRifle"
    SkillTalentPos(22)=(X=1138,Y=496)
    SkillTalentIDs(23)="RifleAltAmmos"
    SkillTalentIcons(23)="WeaponRifle"
    SkillTalentPos(23)=(X=1202,Y=435)
    SkillTalentIDs(24)="RifleOperation"
    SkillTalentIcons(24)="WeaponRifle"
    SkillTalentPos(24)=(X=1138,Y=630)
    SkillTalentIDs(25)="RifleReload"
    SkillTalentIcons(25)="WeaponRifle"
    SkillTalentPos(25)=(X=1202,Y=691)
    SkillTalentIDs(26)="RifleModding"
    SkillTalentIcons(26)="WeaponRifle"
    SkillTalentPos(26)=(X=1202,Y=563)
    MapBranchingTexture(23)=Texture'SkillMapBranchWeaponRifle01B'
    MapBranchingTalent(23)="RifleFocus"
    MapBranchingPos(23)=(X=1116,Y=542)
    MapBranchingTexture(24)=Texture'SkillMapBranchWeaponRifle01A'
    MapBranchingTalent(24)="RifleAltAmmos"
    MapBranchingPos(24)=(X=1185,Y=489)
    MapBranchingTexture(25)=Texture'SkillMapBranchWeaponRifle01D'
    MapBranchingTalent(25)="RifleOperation"
    MapBranchingPos(25)=(X=1114,Y=619)
    MapBranchingTexture(26)=Texture'SkillMapBranchWeaponRifle01E'
    MapBranchingTalent(26)="RifleReload"
    MapBranchingPos(26)=(X=1185,Y=677)
    MapBranchingTexture(27)=Texture'SkillMapBranchWeaponRifle01C'
    MapBranchingTalent(27)="RifleModding"
    MapBranchingPos(27)=(X=1118,Y=592)
    SkillTalentIDs(27)="TagTeamClosedWaterproof"
    SkillTalentIcons(27)="Intricate"
    SkillTalentPos(27)=(X=857,Y=519)
    SkillTalentIDs(28)="TagTeamClosedHeadshot"
    SkillTalentIcons(28)="Intricate"
    SkillTalentPos(28)=(X=857,Y=397)
    SkillTalentIDs(29)="TagTeamOpenDecayRate"
    SkillTalentIcons(29)="Robust"
    SkillTalentPos(29)=(X=857,Y=607)
    SkillTalentIDs(30)="TagTeamOpenChamber"
    SkillTalentIcons(30)="Robust"
    SkillTalentPos(30)=(X=857,Y=729)
    MapBranchingTexture(28)=Texture'SkillMapBranchIntricate01A'
    MapBranchingTalent(28)="TagTeamClosedWaterproof"
    MapBranchingPos(28)=(X=712,Y=565)
    MapBranchingTexture(29)=Texture'SkillMapBranchIntricate01B'
    MapBranchingTalent(29)="TagTeamClosedWaterproof"
    MapBranchingPos(29)=(X=904,Y=565)
    MapBranchingTexture(30)=Texture'SkillMapBranchIntricate02A'
    MapBranchingTalent(30)="TagTeamClosedHeadshot"
    MapBranchingPos(30)=(X=886,Y=448)
    MapBranchingTexture(31)=Texture'SkillMapBranchRobust01A'
    MapBranchingTalent(31)="TagTeamOpenDecayRate"
    MapBranchingPos(31)=(X=712,Y=619)
    MapBranchingTexture(32)=Texture'SkillMapBranchRobust01B'
    MapBranchingTalent(32)="TagTeamOpenDecayRate"
    MapBranchingPos(32)=(X=904,Y=619)
    MapBranchingTexture(33)=Texture'SkillMapBranchRobust02A'
    MapBranchingTalent(33)="TagTeamOpenChamber"
    MapBranchingPos(33)=(X=886,Y=658)
    SkillTalentIDs(31)="LockpickScoutNoise"
    SkillTalentIcons(31)="Lockpicking"
    SkillTalentPos(31)=(X=149,Y=1071)
    SkillTalentIDs(32)="LockpickPickpocket"
    SkillTalentIcons(32)="Lockpicking"
    SkillTalentPos(32)=(X=117,Y=914)
    SkillTalentIDs(33)="LockpickScent"
    SkillTalentIcons(33)="Lockpicking"
    SkillTalentPos(33)=(X=307,Y=1103)
    SkillTalentIDs(34)="LockpickStartStealth"
    SkillTalentIcons(34)="Lockpicking"
    SkillTalentPos(34)=(X=66,Y=1149)
    MapBranchingTexture(34)=Texture'SkillMapBranchLockpicking01B'
    MapBranchingTalent(34)="LockpickScoutNoise"
    MapBranchingPos(34)=(X=196,Y=1020)
    MapBranchingTexture(35)=Texture'SkillMapBranchLockpicking01A'
    MapBranchingTalent(35)="LockpickPickpocket"
    MapBranchingPos(35)=(X=168,Y=943)
    MapBranchingTexture(36)=Texture'SkillMapBranchLockpicking01D'
    MapBranchingTalent(36)="LockpickScent"
    MapBranchingPos(36)=(X=286,Y=1024)
    MapBranchingTexture(37)=Texture'SkillMapBranchLockpicking01C'
    MapBranchingTalent(37)="LockpickStartStealth"
    MapBranchingPos(37)=(X=120,Y=1118)
    SkillTalentIDs(35)="TagTeamDoorCrackingMetal"
    SkillTalentIcons(35)="Burglar"
    SkillTalentPos(35)=(X=256,Y=816)
    MapBranchingTexture(38)=Texture'SkillMapBranchBurglar01A'
    MapBranchingTalent(38)="TagTeamDoorCrackingMetal"
    MapBranchingPos(38)=(X=285,Y=759)
    
    //640, 946 base pos
    SkillTalentIDs(36)="ElectronicsSpeed"
    SkillTalentIcons(36)="Tech"
    SkillTalentPos(36)=(X=656,Y=807)
    SkillTalentIDs(37)="ElectronicsKeypads"
    SkillTalentIcons(37)="Tech"
    SkillTalentPos(37)=(X=469,Y=775)
    SkillTalentIDs(38)="ElectronicsFailNoise"
    SkillTalentIcons(38)="Tech"
    SkillTalentPos(38)=(X=501,Y=887)
    SkillTalentIDs(39)="ElectronicsCrafting"
    SkillTalentIcons(39)="Tech"
    SkillTalentPos(39)=(X=494,Y=1068)
    SkillTalentIDs(40)="ElectronicsTurrets"
    SkillTalentIcons(40)="Tech"
    SkillTalentPos(40)=(X=656,Y=1157)
    SkillTalentIDs(41)="ElectronicsDrones"
    SkillTalentIcons(41)="Tech"
    SkillTalentPos(41)=(X=736,Y=1058)
    SkillTalentIDs(42)="ElectronicsDroneArmor"
    SkillTalentIcons(42)="Tech"
    SkillTalentPos(42)=(X=800,Y=807)
    MapBranchingTexture(39)=Texture'SkillMapBranchElectronics01A'
    MapBranchingTalent(39)="ElectronicsSpeed"
    MapBranchingPos(39)=(X=686,Y=858)
    MapBranchingTexture(40)=Texture'SkillMapBranchElectronics02A'
    MapBranchingTalent(40)="ElectronicsKeypads"
    MapBranchingPos(40)=(X=522,Y=829)
    MapBranchingTexture(41)=Texture'SkillMapBranchElectronics01B'
    MapBranchingTalent(41)="ElectronicsFailNoise"
    MapBranchingPos(41)=(X=550,Y=933)
    MapBranchingTexture(64)=Texture'SkillMapBranchElectronics02B'
    MapBranchingTalent(64)="ElectronicsCrafting"
    MapBranchingPos(64)=(X=548,Y=1027)
    MapBranchingTexture(43)=Texture'SkillMapBranchElectronics02C'
    MapBranchingTalent(43)="ElectronicsTurrets"
    MapBranchingPos(43)=(X=684,Y=1031)
    MapBranchingTexture(44)=Texture'SkillMapBranchElectronics01C'
    MapBranchingTalent(44)="ElectronicsDrones"
    MapBranchingPos(44)=(X=714,Y=1020)
    MapBranchingTexture(45)=Texture'SkillMapBranchElectronics02D'
    MapBranchingTalent(45)="ElectronicsDroneArmor"
    MapBranchingPos(45)=(X=764,Y=835)
    SkillTalentIDs(43)="TagTeamMiniTurret"
    SkillTalentIcons(43)="Armorer"
    SkillTalentPos(43)=(X=656,Y=711)
    MapBranchingTexture(46)=Texture'SkillMapBranchArmorer01A'
    MapBranchingTalent(46)="TagTeamMiniTurret"
    MapBranchingPos(46)=(X=686,Y=624)
    MapBranchingTexture(47)=Texture'SkillMapBranchArmorer01B'
    MapBranchingTalent(47)="TagTeamMiniTurret"
    MapBranchingPos(47)=(X=710,Y=764)
    
    //640, 946 base pos.
    SkillTalentIDs(44)="TagTeamInvaderCapacity"
    SkillTalentIcons(44)="Invader"
    SkillTalentPos(44)=(X=456,Y=962) //-184, +16
    MapBranchingTexture(48)=Texture'SkillMapBranchInvader01A'
    MapBranchingTalent(48)="TagTeamInvaderCapacity"
    MapBranchingPos(48)=(X=318,Y=992) //-322, +46
    MapBranchingTexture(49)=Texture'SkillMapBranchInvader01B'
    MapBranchingTalent(49)="TagTeamInvaderCapacity"
    MapBranchingPos(49)=(X=574,Y=992) //-66, +46
    
    //1040, 946 base pos.
    SkillTalentIDs(45)="DemolitionMineHandling"
    SkillTalentIcons(45)="Demolition"
    SkillTalentPos(45)=(X=944,Y=850) //-96 X, -96 Y
    SkillTalentIDs(46)="DemolitionMines"
    SkillTalentIcons(46)="Demolition"
    SkillTalentPos(46)=(X=1170,Y=850) //+130 X, -96 Y
    SkillTalentIDs(47)="DemolitionGrenadeMaxAmmo"
    SkillTalentIcons(47)="Demolition"
    SkillTalentPos(47)=(X=1200,Y=962) //+160 X. +16 Y, to even it out?
    SkillTalentIDs(48)="DemolitionLooting"
    SkillTalentIcons(48)="Demolition"
    SkillTalentPos(48)=(X=1312,Y=962) //+ 112 X
    SkillTalentIDs(49)="DemolitionTearGas"
    SkillTalentIcons(49)="Demolition"
    SkillTalentPos(49)=(X=1170,Y=1076) //+130 Y
    SkillTalentIDs(50)="DemolitionEMP"
    SkillTalentIcons(50)="Demolition"
    SkillTalentPos(50)=(X=944,Y=1076)
    MapBranchingTexture(50)=Texture'SkillMapBranchDemolition01A'
    MapBranchingTalent(50)="DemolitionMineHandling"
    MapBranchingPos(50)=(X=991,Y=900)
    MapBranchingTexture(51)=Texture'SkillMapBranchDemolition01B'
    MapBranchingTalent(51)="DemolitionMines"
    MapBranchingPos(51)=(X=1114,Y=897)
    MapBranchingTexture(52)=Texture'SkillMapBranchDemolition01C'
    MapBranchingTalent(52)="DemolitionGrenadeMaxAmmo"
    MapBranchingPos(52)=(X=1118,Y=991)
    MapBranchingTexture(53)=Texture'SkillMapBranchDemolition01D'
    MapBranchingTalent(53)="DemolitionLooting"
    MapBranchingPos(53)=(X=1251,Y=990)
    MapBranchingTexture(54)=Texture'SkillMapBranchDemolition01E'
    MapBranchingTalent(54)="DemolitionTearGas"
    MapBranchingPos(54)=(X=1114,Y=1020)
    MapBranchingTexture(55)=Texture'SkillMapBranchDemolition01F'
    MapBranchingTalent(55)="DemolitionEMP"
    MapBranchingPos(55)=(X=991,Y=1020)
    
    //1040, 946 base pos.
    SkillTalentIDs(51)="TagTeamScrambler"
    SkillTalentIcons(51)="Arsonist"
    SkillTalentPos(51)=(X=856,Y=962) //-184, +16
    MapBranchingTexture(56)=Texture'SkillMapBranchArsonist01A'
    MapBranchingTalent(56)="TagTeamScrambler"
    MapBranchingPos(56)=(X=718,Y=992) //-322, +46
    MapBranchingTexture(57)=Texture'SkillMapBranchArsonist01B'
    MapBranchingTalent(57)="TagTeamScrambler"
    MapBranchingPos(57)=(X=882,Y=1018) //-167, -32
    
    //Base pos: 240, 1346
    //Pure left offset:  -128 X
    //Pure right offset: +162 X
    //Pure down offset:  +162 Y?
    SkillTalentIDs(52)="MedicineWraparound"
    SkillTalentIcons(52)="Medicine"
    SkillTalentPos(52)=(X=144,Y=1250) //-96, -96?
    SkillTalentIDs(53)="MedicineStress"
    SkillTalentIcons(53)="Medicine"
    SkillTalentPos(53)=(X=112,Y=1362)
    SkillTalentIDs(54)="MedicineRevive"
    SkillTalentIcons(54)="Medicine"
    SkillTalentPos(54)=(X=80,Y=1540)
    SkillTalentIDs(55)="MedicineCapacity"
    SkillTalentIcons(55)="Medicine"
    SkillTalentPos(55)=(X=256,Y=1508)
    SkillTalentIDs(56)="MedicineCrafting"
    SkillTalentIcons(56)="Medicine"
    SkillTalentPos(56)=(X=434,Y=1362)
    MapBranchingTexture(58)=Texture'SkillMapBranchMedicine01A'
    MapBranchingTalent(58)="MedicineWraparound"
    MapBranchingPos(58)=(X=191,Y=1297)
    MapBranchingTexture(59)=Texture'SkillMapBranchMedicine01B'
    MapBranchingTalent(59)="MedicineStress"
    MapBranchingPos(59)=(X=163,Y=1391)
    MapBranchingTexture(60)=Texture'SkillMapBranchMedicine03A'
    MapBranchingTalent(60)="MedicineRevive"
    MapBranchingPos(60)=(X=136,Y=1535)
    MapBranchingTexture(61)=Texture'SkillMapBranchMedicine02A'
    MapBranchingTalent(61)="MedicineCapacity"
    MapBranchingPos(61)=(X=284,Y=1431)
    MapBranchingTexture(62)=Texture'SkillMapBranchMedicine02B'
    MapBranchingTalent(62)="MedicineCrafting"
    MapBranchingPos(62)=(X=325,Y=1390)
    SkillTalentIDs(57)="TagTeamMedicalSyringe"
    SkillTalentIcons(57)="Biotech"
    SkillTalentPos(57)=(X=434,Y=1250) //+130 X, -96 Y
    MapBranchingTexture(63)=Texture'SkillMapBranchBiotech01A'
    MapBranchingTalent(63)="TagTeamMedicalSyringe"
    MapBranchingPos(63)=(X=323,Y=1302)
    MapBranchingTexture(42)=Texture'SkillMapBranchBiotech01B'
    MapBranchingTalent(42)="TagTeamMedicalSyringe"
    MapBranchingPos(42)=(X=486,Y=1018)
    
    SkillTalentIDs(71)="MedicineCombatDrugs"
    SkillTalentIcons(71)="Medicine"
    SkillTalentPos(71)=(X=256,Y=1207) //+16, -139
    MapBranchingTexture(80)=Texture'SkillMapBranchMedicine01C'
    MapBranchingTalent(80)="MedicineCombatDrugs"
    MapBranchingPos(80)=(X=286,Y=1258) //+46, -88
    
    //Base pos: 640, 1346
    //Upper Left: -139, -59
    //Lower Left: -146, +122
    //Bottom: +16, +162
    //Lower Right Part 1: +96, +112
    //Lower Right Part 2: +64 (use 80), +61 (Use 80)
    SkillTalentIDs(58)="ComputerSpecialOptions"
    SkillTalentIcons(58)="Computer"
    SkillTalentPos(58)=(X=501,Y=1287)
    SkillTalentIDs(59)="ComputerATMQuality"
    SkillTalentIcons(59)="Computer"
    SkillTalentPos(59)=(X=494,Y=1468)
    SkillTalentIDs(60)="ComputerTurrets"
    SkillTalentIcons(60)="Computer"
    SkillTalentPos(60)=(X=656,Y=1508)
    SkillTalentIDs(61)="ComputerScaling"
    SkillTalentIcons(61)="Computer"
    SkillTalentPos(61)=(X=736,Y=1458)
    SkillTalentIDs(62)="ComputerLockout"
    SkillTalentIcons(62)="Computer"
    SkillTalentPos(62)=(X=816,Y=1538)
    MapBranchingTexture(65)=Texture'SkillMapBranchComputer01A'
    MapBranchingTalent(65)="ComputerSpecialOptions"
    MapBranchingPos(65)=(X=550,Y=1333)
    MapBranchingTexture(66)=Texture'SkillMapBranchComputer01B'
    MapBranchingTalent(66)="ComputerATMQuality"
    MapBranchingPos(66)=(X=546,Y=1427)
    MapBranchingTexture(67)=Texture'SkillMapBranchComputer01C'
    MapBranchingTalent(67)="ComputerTurrets"
    MapBranchingPos(67)=(X=684,Y=1431)
    MapBranchingTexture(68)=Texture'SkillMapBranchComputer01D'
    MapBranchingTalent(68)="ComputerScaling"
    MapBranchingPos(68)=(X=714,Y=1420)
    MapBranchingTexture(69)=Texture'SkillMapBranchComputer01E'
    MapBranchingTalent(69)="ComputerLockout"
    MapBranchingPos(69)=(X=782,Y=1504)
    
    //Base pos? 640, 1346
    //X? 96 or 736 X. Add 80 for 2nd gem? 816 X for #2.
    //Y? -96, or 1250 Y.
    SkillTalentIDs(63)="TagTeamLiteHack"
    SkillTalentIcons(63)="Wares"
    SkillTalentPos(63)=(X=736,Y=1250)
    SkillTalentIDs(64)="TagTeamSkillware"
    SkillTalentIcons(64)="Wares"
    SkillTalentPos(64)=(X=816,Y=1250)
    MapBranchingTexture(70)=Texture'SkillMapBranchWares01A'
    MapBranchingTalent(70)="TagTeamLiteHack"
    MapBranchingPos(70)=(X=765,Y=1110)
    MapBranchingTexture(71)=Texture'SkillMapBranchWares01B'
    MapBranchingTalent(71)="TagTeamSkillware"
    MapBranchingPos(71)=(X=765,Y=1109)
    MapBranchingTexture(72)=Texture'SkillMapBranchWares01C'
    MapBranchingTalent(72)="TagTeamLitehack"
    MapBranchingPos(72)=(X=713,Y=1297)
    MapBranchingTexture(73)=Texture'SkillMapBranchWares01D'
    MapBranchingTalent(73)="TagTeamSkillware"
    MapBranchingPos(73)=(X=713,Y=1306)
    
    //1040, 1346 base pos.
    //Upper Right: +130, -96
    //Lower Right: +130, 130
    //Difference: 46 more when skipping past
    //Lower Right Part 2: +64 (use 80), +61
    //Upper Right Part 2: +64 (use 80), -61
    SkillTalentIDs(65)="HeavyFocus"
    SkillTalentIcons(65)="WeaponHeavy"
    SkillTalentPos(65)=(X=944,Y=1250) //-96 X, -96 Y
    SkillTalentIDs(66)="HeavyDropAndRoll"
    SkillTalentIcons(66)="WeaponHeavy"
    SkillTalentPos(66)=(X=944,Y=1476) //+130 X, -96 Y
    SkillTalentIDs(67)="HeavyProjectileSpeed"
    SkillTalentIcons(67)="WeaponHeavy"
    SkillTalentPos(67)=(X=1170,Y=1476) //+130 Y
    SkillTalentIDs(68)="HeavyPlasma"
    SkillTalentIcons(68)="WeaponHeavy"
    SkillTalentPos(68)=(X=1250,Y=1537)
    SkillTalentIDs(69)="HeavySpeed"
    SkillTalentIcons(69)="WeaponHeavy"
    SkillTalentPos(69)=(X=1170,Y=1250)
    SkillTalentIDs(70)="HeavySwapSpeed"
    SkillTalentIcons(70)="WeaponHeavy"
    SkillTalentPos(70)=(X=1250,Y=1189)
    
    MapBranchingTexture(74)=Texture'SkillMapBranchWeaponHeavy01A'
    MapBranchingTalent(74)="HeavyFocus"
    MapBranchingPos(74)=(X=991,Y=1297)
    MapBranchingTexture(75)=Texture'SkillMapBranchWeaponHeavy01B'
    MapBranchingTalent(75)="HeavyDropAndRoll"
    MapBranchingPos(75)=(X=991,Y=1420)
    MapBranchingTexture(76)=Texture'SkillMapBranchWeaponHeavy01C'
    MapBranchingTalent(76)="HeavyProjectileSpeed"
    MapBranchingPos(76)=(X=1114,Y=1420)
    MapBranchingTexture(77)=Texture'SkillMapBranchWeaponHeavy01D'
    MapBranchingTalent(77)="HeavyPlasma"
    MapBranchingPos(77)=(X=1217,Y=1523)
    MapBranchingTexture(78)=Texture'SkillMapBranchWeaponHeavy01E'
    MapBranchingTalent(78)="HeavySpeed"
    MapBranchingPos(78)=(X=1114,Y=1297)
    MapBranchingTexture(79)=Texture'SkillMapBranchWeaponHeavy01F'
    MapBranchingTalent(79)="HeavySwapSpeed"
    MapBranchingPos(79)=(X=1217,Y=1242)
    
    //ACTUAL LAST TALENT USED IS 71!
    //ACTUAL LAST BRANCH USED IS 80!
    
    SkillCoreDescs(0)="The covert manipulation of computers and security consoles. Actions taken during hacking will increase the risk of being detected."
    SkillLevelDescsA(0)="UNTRAINED: An agent can use terminals normally, but cannot hack."
    AltSkillLevelDescsA(0)="TRAINED: An agent can hack at a %d%% longer than standard." //HACK! Actually for trained!
    SkillLevelDescsB(0)="TRAINED: An agent can hack at a baseline level."
    SkillLevelDescsC(0)="ADVANCED: An agent can hack for %d%% longer than standard."
    SkillLevelDescsD(0)="MASTER: An agent can hack for %d%% longer than standard."
    
    SkillCoreDescs(1)="The use of thrown explosive devices, including LAMs, gas grenades, EMP grenades, and even electronic scramble grenades."
    SkillLevelDescsA(1)="UNTRAINED: An agent can throw, emplace, and attempt to disarm grenades."
    AltSkillLevelDescsA(1)="UNTRAINED: Grenade accuracy is increased by %d%%, time to disarm is standard, and damage output is increased by %d%%."
    SkillLevelDescsB(1)="TRAINED: Grenade accuracy is increased by %d%%, time to disarm is increased slightly, and damage output by %d%%."
    SkillLevelDescsC(1)="ADVANCED: Grenade accuracy is increased by %d%%, time to disarm is increased somewhat, and damage output by %d%%."
    SkillLevelDescsD(1)="MASTER: Grenade accuracy is increased by %d%%, time to disarm is increased heavily, and damage output by %d%%."
    
    SkillCoreDescs(2)="The use of goggles, hazmat suits, ballistic armor, thermoptic camo, and rebreathers."
    SkillLevelDescsA(2)="UNTRAINED: Equipment can be used at a standard level."
    AltSkillLevelDescsA(2)="UNTRAINED: Equipment can be used for %d%% longer, and defensive equipment offers %d%% more protection."
    SkillLevelDescsB(2)="TRAINED: Equipment can be used for %d%% longer, and defensive equipment offers %d%% more protection."
    SkillLevelDescsC(2)="ADVANCED: Equipment can be used for %d%% longer, and defensive equipment offers %d%% more protection."
    SkillLevelDescsD(2)="MASTER: Equipment can be used for %d%% longer, and defensive equipment offers %d%% more protection."
    
    SkillCoreDescs(3)="The effectiveness with which lockpicks can be handled. Talents often focus on enhancing stealth."
    SkillLevelDescsA(3)="UNTRAINED: Lockpicks can weaken locks by %d%% per unit."
    AltSkillLevelDescsA(3)="UNTRAINED: Lockpicks can weaken locks by %d%% per unit."
    SkillLevelDescsB(3)="TRAINED: Lockpicks can weaken locks by %d%% per unit."
    SkillLevelDescsC(3)="ADVANCED: Lockpicks can weaken locks by %d%% per unit."
    SkillLevelDescsD(3)="MASTER: Lockpicks can weaken locks by %d%% per unit."
    
    SkillCoreDescs(4)="The efficiency with which medkits can be activated, and medical crafting can occur."
    SkillLevelDescsA(4)="UNTRAINED: Medkits heal for %d units, and crafting cannot occur without a specialization."
    AltSkillLevelDescsA(4)="UNTRAINED: Medkits heal for %d units, and crafting cannot occur without a specialization."
    SkillLevelDescsB(4)="TRAINED: Medkits heal for %d units, and crafting occurs with 10%% more efficiency."
    SkillLevelDescsC(4)="ADVANCED: Medkits heal for %d units, and crafting occurs with 22%% more efficiency."
    SkillLevelDescsD(4)="MASTER: Medkits heal for %d units, and crafting occurs with 37%% more efficiency."
    
    SkillCoreDescs(5)="Underwater and other athletic operations require their own unique set of skills that must be developed by an agent with extreme physical dedication."
    SkillLevelDescsA(5)="UNTRAINED: An agent can swim at a standard pace, and moves 7.5%% slower than standard on land."
    AltSkillLevelDescsA(5)="UNTRAINED: An agent can swim %d%% faster and longer, and moves 7.5%% slower than standard on land."
    SkillLevelDescsB(5)="TRAINED: An agent can swim %d%% faster and longer, while moving at a standard pace on land."
    SkillLevelDescsC(5)="ADVANCED: An agent can swim %d%% faster and longer, in addition to a 7.5%% speed boost on land."
    SkillLevelDescsD(5)="MASTER: An agent can swim %d%% faster and longer, in addition to a 15%% speed boost on land."
    
    SkillCoreDescs(6)="The effectiveness with which multitools can be handled, and technical crafting can occur."
    SkillLevelDescsA(6)="UNTRAINED: Multitools can weaken devices by %d%% per unit, and crafting cannot occur without a specialization."
    AltSkillLevelDescsA(6)="UNTRAINED: Multitools can weaken devices by %d%% per unit, and crafting cannot occur without a specialization."
    SkillLevelDescsB(6)="TRAINED: Multitools can weaken devices by %d%% per unit, and crafting occurs with 10%% more efficiency."
    SkillLevelDescsC(6)="ADVANCED: Multitools can weaken devices by %d%% per unit, and crafting occurs with 22%% more efficiency."
    SkillLevelDescsD(6)="MASTER: Multitools can weaken devices by %d%% per unit, and crafting occurs with 37%% more efficiency."
    
    SkillCoreDescs(7)="The use of heavy weaponry, including flamethrowers, LAWs, and the experimental plasma and GEP guns."
    SkillLevelDescsA(7)="UNTRAINED: An agent can use heavy weapons with standard efficiency."
    AltSkillLevelDescsA(7)="UNTRAINED: Heavy accuracy and reload speed is increased by %d%%, while recoil is decreased by %d%% and damage is increased by %d%%."
    SkillLevelDescsB(7)="TRAINED: Heavy accuracy and reload speed is increased by %d%%, while recoil is decreased by %d%% and damage is increased by %d%%. Movement speed while using heavy weapons is increased by 16%%. Aim focus speeds are increased by 25%%."
    SkillLevelDescsC(7)="ADVANCED: Heavy accuracy and reload speed is increased by %d%% and %d%%, respectively, while recoil is decreased by %d%% and damage is increased by %d%. Movement speed while using heavy weapons is increased by 33%. Aim focus speeds are increased by 50%."
    SkillLevelDescsD(7)="MASTER: Heavy accuracy and reload speed is increased by %d%% and %d%%, respectively, while recoil is decreased by %d%% and damage is increased by %d%. Movement speed while using heavy weapons is increased by 50%. Aim focus speeds are increased by 75%."
    
    SkillCoreDescs(8)="The use of melee weapons such as batons, knives, throwing knives, swords, pepper guns, and prods."
    SkillLevelDescsA(8)="UNTRAINED: An agent can use low-tech weapons with standard efficiency."
    AltSkillLevelDescsA(8)="UNTRAINED: Low-tech accuracy and reload speed is increased by %d%%, while damage is increased by %d%%."
    SkillLevelDescsB(8)="TRAINED: Low-tech accuracy and reload speed is increased by %d%%, while damage is increased by %d%%."
    SkillLevelDescsC(8)="ADVANCED: Low-tech accuracy and reload speed is increased by %d%% and %d%%, respectively, while damage is increased by %d%%."
    SkillLevelDescsD(8)="MASTER: Low-tech accuracy and reload speed is increased by %d%% and %d%%, respectively, while damage is increased by %d%%."
    
    SkillCoreDescs(9)="The use of hand-held weapons, including the standard 10mm pistol, its stealth variant, the PS20, and the mini-crossbow."
    SkillLevelDescsA(9)="UNTRAINED: An agent can use pistols with standard efficiency."
    AltSkillLevelDescsA(9)="UNTRAINED: Pistol accuracy and reload speed is increased by %d%%, while recoil is decreased by %d%% and damage is increased by %d%%."
    SkillLevelDescsB(9)="TRAINED: Pistol accuracy and reload speed is increased by %d%%, while recoil is decreased by %d%% and damage is increased by %d%%. Aim focus speeds are increased by 25%%."
    SkillLevelDescsC(9)="ADVANCED: Pistol accuracy and reload speed is increased by %d%% and %d%%, respectively, while recoil is decreased by %d%% and damage is increased by %d%. Aim focus speeds are increased by 50%."
    SkillLevelDescsD(9)="MASTER: Pistol accuracy and reload speed is increased by %d%% and %d%%, respectively, while recoil is decreased by %d%% and damage is increased by %d%. Aim focus speeds are increased by 75%."
    
    SkillCoreDescs(10)="The use of rifles, including assault rifles, sniper rifles, and shotguns."
    SkillLevelDescsA(10)="UNTRAINED: An agent can use rifles with standard efficiency."
    AltSkillLevelDescsA(10)="UNTRAINED: Rifle accuracy and reload speed is increased by %d%%, while recoil is decreased by %d%% and damage is increased by %d%%."
    SkillLevelDescsB(10)="TRAINED: Rifle accuracy and reload speed is increased by %d%%, while recoil is decreased by %d%% and damage is increased by %d%%. Aim focus speeds are increased by 25%%."
    SkillLevelDescsC(10)="ADVANCED: Rifle accuracy and reload speed is increased by %d%% and %d%%, respectively, while recoil is decreased by %d%% and damage is increased by %d%. Aim focus speeds are increased by 50%."
    SkillLevelDescsD(10)="MASTER: Rifle accuracy and reload speed is increased by %d%% and %d%%, respectively, while recoil is decreased by %d%% and damage is increased by %d%. Aim focus speeds are increased by 75%."
}
