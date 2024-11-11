//=============================================================================
// VMDSkillAugmentGem
//=============================================================================
class VMDSkillAugmentGem extends PersonaBorderButtonWindow;

var bool bNext, bSkillPage;
var int NextPage;

var Window GemBorder;
var VMDStylizedWindow GemOverlay;

var Texture LevelBorders[13], SkillIcons[32];
var string SkillTypes[32], SkillTypeStr;
var class<Skill> SkillType, SecondarySkillType;
var string SkillAugmentID, SkillAugmentName, SkillAugmentDesc;
var int SkillLevel, SecondarySkillLevel, PageNumber, BorderX, BorderY;

function SetSkillData(string NewSkillAugmentID, string NewSkillAugmentName, string NewSkillAugmentDesc, int NewSkillLevel, int NewSecondarySkillLevel, int NewPageNumber)
{
	SkillAugmentID = NewSkillAugmentID;
	SkillAugmentName = NewSkillAugmentName;
	SkillAugmentDesc = NewSkillAugmentDesc;
	PageNumber = NewPageNumber;
	SkillLevel = NewSkillLevel;
	SecondarySkillLevel = NewSecondarySkillLevel;
	Right_Textures[0].Tex = LevelBorders[(Max(SkillLevel, SecondarySkillLevel)-1)*3];
	Right_Textures[1].Tex = LevelBorders[(Max(SkillLevel, SecondarySkillLevel)-1)*3];
}

function SetSkillData2(class<Skill> NewSkillType, class<Skill> NewSecondarySkillType, string NewSkillTypeStr)
{
	local int i;
	
	i = GetSkillIndex(NewSkillTypeStr);
	
 	if (i > -1)
 	{		
		SkillType = NewSkillType;
		SecondarySkillType = NewSecondarySkillType;
		SkillTypeStr = NewSkillTypeStr;
		
  		GemBorder.SetBackground(SkillIcons[i]);
	}
}

function UpdateSkillIcons(int LockedBoughtHigh)
{
	local int UA;
	
	if (LockedBoughtHigh == 3)
	{
		UA = 12;
	}
	else
	{
		UA = (Max(SkillLevel, SecondarySkillLevel)-1)*4+LockedBoughtHigh;
	}
	
	Right_Textures[0].Tex = LevelBorders[UA];
	Right_Textures[1].Tex = LevelBorders[UA];
}

function UpdateCheckOverlay(bool bBought)
{
	GemOverlay.SetBackground(None);
	if (bBought) GemOverlay.SetBackground(Texture'SkillAugmentOverlayObtained');
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
	Super.InitWindow();
	
	GemBorder = NewChild(class'Window');
	GemBorder.SetBackground(SkillIcons[0]);
	GemBorder.SetBackgroundStyle(DSTY_Masked);
	GemBorder.SetPos(BorderX, BorderY);
	GemBorder.SetSize(32,32);
	
	GemOverlay = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
	GemOverlay.SetBackground(None);
	GemOverlay.SetBackgroundStyle(DSTY_Masked);
	GemOverlay.SetPos(BorderX, BorderY);
	GemOverlay.SetSize(32,32);
	
	SetWidth(32);
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
     SkillTypes(11)="FillerTextSystems"
     SkillTypes(12)="FillerTextBurglar"
     SkillTypes(13)="FillerTextHacking"
     SkillTypes(14)="FillerTextSwimmingGear"
     SkillTypes(15)=""
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
     SkillIcons(10)=Texture'DeusExUI.UserInterface.SkillIconWeaponRifle'
     SkillIcons(11)=Texture'SkillIconSystems'
     SkillIcons(12)=Texture'SkillIconBurglar'
     SkillIcons(13)=Texture'SkillIconHacking'
     SkillIcons(14)=Texture'SkillIconSwimmingGear'
     SkillIcons(15)=Texture''
     
     LevelBorders(0)=Texture'SkillAugmentGemBorderTrainedLocked'
     LevelBorders(1)=Texture'SkillAugmentGemBorderTrained'
     LevelBorders(2)=Texture'SkillAugmentGemBorderTrainedBought'
     LevelBorders(3)=Texture'SkillAugmentGemBorderTrainedHighlight'
     LevelBorders(4)=Texture'SkillAugmentGemBorderAdvancedLocked'
     LevelBorders(5)=Texture'SkillAugmentGemBorderAdvanced'
     LevelBorders(6)=Texture'SkillAugmentGemBorderAdvancedBought'
     LevelBorders(7)=Texture'SkillAugmentGemBorderAdvancedHighlight'
     LevelBorders(8)=Texture'SkillAugmentGemBorderMasterLocked'
     LevelBorders(9)=Texture'SkillAugmentGemBorderMaster'
     LevelBorders(10)=Texture'SkillAugmentGemBorderMasterBought'
     LevelBorders(11)=Texture'SkillAugmentGemBorderMasterHighlight'
     LevelBorders(12)=Texture'SkillAugmentGemBorderAllHighlight'
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'SkillAugmentPageBackward',Width=32)
     Right_Textures(1)=(Tex=Texture'SkillAugmentPageBackward',Width=32)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     fontButtonText=Font'DeusExUI.FontMenuTitle'
     buttonHeight=32
     minimumButtonWidth=32
}
