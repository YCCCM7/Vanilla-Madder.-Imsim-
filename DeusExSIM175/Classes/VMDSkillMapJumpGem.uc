//=============================================================================
// VMDSkillMapJumpGem
//=============================================================================
class VMDSkillMapJumpGem extends PersonaBorderButtonWindow;

//Window slaves
var VMDStylizedWindow GemOverlays[3];

var VMDPersonaScreenSkills SkillScreen;
var bool bTalentsEnabled;

//Default data
var Texture SkillIcons[11], LevelLabels[4], SpecializationIcon;
var string SkillTypes[11];
var class<Skill> SkillType;
var int BorderX, BorderY;

//Active set stuff.
var Skill RelSkill;
var int CurSkillLevel, JumpX, JumpY;
var bool bSpecialized;

var int TalentPointsLeft, SkillPointsLeft, NextLevelCost;

//Setup hover tip in advance.
var string HoverTip;
var bool bHoverAlert;

var localized string TipSpecialized, TipTalentPointsLeft, TipCanUpgradeFor;

function SetSkillData(Skill NewSkill, bool NewbSpecialized, int NewJumpX, int NewJumpY, bool NewbTalentsEnabled)
{
	local int i, NewSkillLevel;
	local class<Skill> NewSkillType;
	
	NewSkillType = NewSkill.Class;
	NewSkillLevel = NewSkill.CurrentLevel;
	
	i = GetSkillIndex(string(NewSkillType));
	if (i > -1)
	{
		JumpX = NewJumpX;
		JumpY = NewJumpY;
		RelSkill = NewSkill;
		SkillType = NewSkillType;
		CurSkillLevel = NewSkillLevel;
		bSpecialized = NewbSpecialized;
		bTalentsEnabled = NewbTalentsEnabled;
		
		GemOverlays[0].SetBackground(SkillIcons[i]);
		GemOverlays[1].SetBackground(LevelLabels[NewSkillLevel]);
		
		if (bSpecialized)
		{
			GemOverlays[2].SetBackground(SpecializationIcon);
		}
		else
		{
			GemOverlays[2].SetBackground(None);
		}
	}
}

function UpdateLevelIcon()
{
	local int NewSkillLevel;
	
	if (RelSkill != None)
	{
		NewSkillLevel = RelSkill.CurrentLevel;
		GemOverlays[1].SetBackground(LevelLabels[NewSkillLevel]);
	}
}

function UpdatePointsLeft(int NewSkillLevel, int NewSkillPointsLeft, int NewTalentPointsLeft)
{
	local bool bAlert;
	local int i;
	
	CurSkillLevel = NewSkillLevel;
	SkillPointsLeft = NewSkillPointsLeft;
	TalentPointsLeft = NewTalentPointsLeft;
	
	NextLevelCost = 0;
	if (CurSkillLevel < 3)
	{
		NextLevelCost = RelSkill.GetCost();
	}
	
	bAlert = (((TalentPointsLeft > 0) && (bTalentsEnabled)) || ((SkillPointsLeft >= NextLevelCost) && (CurSkillLevel < 3)));
	
	for (i=0; i<ArrayCount(GemOverlays)-1; i++)
	{
		GemOverlays[i].bBlockReskin = bAlert;
		GemOverlays[i].StyleChanged();
	}
	UpdateLevelIcon();
	UpdateHoverTip();
}

function UpdateHoverTip()
{
	bHoverAlert = false;
	HoverTip = SkillType.Default.SkillName; //"";
	
	if (bSpecialized)
	{
		HoverTip = HoverTip@TipSpecialized;
	}
	if ((TalentPointsLeft > 0) && (bTalentsEnabled))
	{
		if (HoverTip != "") HoverTip = HoverTip$CR();
		HoverTip = HoverTip$SprintF(TipTalentPointsLeft, TalentPointsLeft);
		bHoverAlert = true;
	}
	if ((SkillPointsLeft >= NextLevelCost) && (CurSkillLevel < 3))
	{
		if (HoverTip != "") HoverTip = HoverTip$CR();
		HoverTip = HoverTip$SprintF(TipCanUpgradeFor, NextLevelCost);
		bHoverAlert = true;
	}
}

function int GetSkillIndex(string CheckSkillType)
{
	local int i;
	
	for (i=0; i<ArrayCount(SkillTypes); i++)
	{
		if (SkillTypes[i] ~= CheckSkillType) return i;
	}
	
	return -1;
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	local int i;
	
	Super.InitWindow();
	
	for (i=0; i<ArrayCount(GemOverlays); i++)
	{
		GemOverlays[i] = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		GemOverlays[i].SetBackground(None);
		GemOverlays[i].SetPos(0, 0);
		GemOverlays[i].SetSize(32,32);
		GemOverlays[i].bBlockTranslucency = True;
		GemOverlays[i].bMouseHoverSnitch = True;
	}
	
	GemOverlays[0].SetPos(BorderX, BorderY);
	GemOverlays[2].bBlockReskin = true;
	GemOverlays[2].StyleChanged();
	
	SetWidth(32);
}

event MouseMoved(float newX, float newY)
{
	if (SkillScreen != None)
	{
		SkillScreen.HoverTarget = Self;
		SkillScreen.HoverTicks = 0;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     BorderX=4
     BorderY=4
     SkillTypes(0)="DeusEx.SkillComputer"
     SkillTypes(1)="DeusEx.SkillDemolition"
     SkillTypes(2)="DeusEx.SkillEnviro"
     SkillTypes(3)="DeusEx.SkillLockpicking"
     SkillTypes(4)="DeusEx.SkillMedicine"
     SkillTypes(5)="DeusEx.SkillSwimming"
     SkillTypes(6)="DeusEx.SkillTech"
     SkillTypes(7)="DeusEx.SkillWeaponHeavy"
     SkillTypes(8)="DeusEx.SkillWeaponLowTech"
     SkillTypes(9)="DeusEx.SkillWeaponPistol"
     SkillTypes(10)="DeusEx.SkillWeaponRifle"
     SkillIcons(0)=Texture'DeusExUI.UserInterface.SkillIconComputer'
     SkillIcons(1)=Texture'DeusExUI.UserInterface.SkillIconDemolition'
     SkillIcons(2)=Texture'DeusExUI.UserInterface.SkillIconEnviro'
     SkillIcons(3)=Texture'DeusExUI.UserInterface.SkillIconLockPicking'
     SkillIcons(4)=Texture'DeusExUI.UserInterface.SkillIconMedicine'
     SkillIcons(5)=Texture'DeusExUI.UserInterface.SkillIconSwimming'
     SkillIcons(6)=Texture'DeusExUI.UserInterface.SkillIconTech'
     SkillIcons(7)=Texture'DeusExUI.UserInterface.SkillIconWeaponHeavy'
     SkillIcons(8)=Texture'DeusExUI.UserInterface.SkillIconWeaponLowTech'
     SkillIcons(9)=Texture'DeusExUI.UserInterface.SkillIconWeaponPistol'
     SkillIcons(10)=Texture'VMDAssets.SkillIconWeaponRifleFixed'
     
     LevelLabels(0)=Texture'GemLevelLabel0'
     LevelLabels(1)=Texture'GemLevelLabel1'
     LevelLabels(2)=Texture'GemLevelLabel2'
     LevelLabels(3)=Texture'GemLevelLabel3'
     SpecializationIcon=Texture'GemSpecializationLabel'
     
     TipSpecialized="(Resonating)"
     TipTalentPointsLeft="%d talent point(s) available"
     TipCanUpgradeFor="Can upgrade for %d point(s)"
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'SkillGemTrained',Width=32)
     Right_Textures(1)=(Tex=Texture'SkillGemTrained',Width=32)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     fontButtonText=Font'DeusExUI.FontMenuTitle'
     buttonHeight=32
     minimumButtonWidth=32
}
