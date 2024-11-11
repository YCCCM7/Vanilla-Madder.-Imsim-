//=============================================================================
// VMDSkillMapTalentGem
//=============================================================================
class VMDSkillMapTalentGem extends PersonaBorderButtonWindow;

//Window slaves
var VMDPersonaScreenSkills SkillScreen;
var VMDSkillAugmentManager SAM;

//Default data
var Texture SkillIcons[20], LevelBorders[4], LockedLevelBorders[4], HighlightLevelBorders[4], LevelLabels[4];
var string IconTypes[20];

var int SkillPosX, SkillPosY;
var Color ColWhite;

//Active set stuff.
var int LastState, LastBuyState;

var int PointsCost, HighestLevel;
var string TalentName, TalentID, TalentDesc, IconType;
var bool bOwned;

//Checks for both ends.
var int TalentPointsLeft[2], bSpecialized[2], RequiredLevels[2], CurSkillLevels[2];
var class<Skill> SkillRequirements[2];

var string SkillRequirementNames[2], SkillLevelRequirementNames[2], SkillTalentRequirementIDs[2], SkillTalentRequirementNames[2];

//Draw scale barf
var float DrawScale, ZoomRenderScale, MapOffX, MapOffY;
var int SkillIconIndex;

//Setup hover tip in advance.
var string HoverTip;
var bool bHoverAlert;

var localized string TipOwned, TipPointsCost, TipRequirements;

event DrawWindow(GC gc)
{
	local Texture TLabel, TBorder, TSkill;
	local int i, ScaleOffX, ScaleOffY;
	local float UnivScale;
	
	TSkill = SkillIcons[SkillIconIndex];
	
	switch(LastState)
	{
		case 0:
			TBorder = LockedLevelBorders[HighestLevel];
		break;
		case 1:
			TBorder = LevelBorders[HighestLevel];
		break;
		case 2:
			TBorder = HighlightLevelBorders[HighestLevel];
		break;
	}
	
	TLabel = LevelLabels[PointsCost];
	
	// Draw the textures
	//if (bTranslucent)
	//	gc.SetStyle(DSTY_Translucent);
	//else
		gc.SetStyle(DSTY_Masked);
	
	ScaleOffX = MapOffX;
	ScaleOffY = MapOffY;
	
	UnivScale = DrawScale * ZoomRenderScale;
	
	if (TBorder != None)
	{
		GC.SetTileColor(ColButtonFace);
		GC.DrawStretchedTexture(0+ScaleOffX, 0+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TBorder);
	}
	if (TSkill != None)
	{
		GC.SetTileColor(ColWhite);
		GC.DrawStretchedTexture((SkillPosX*UnivScale)+ScaleOffX, (SkillPosY*UnivScale)+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TSkill);
	}
	if (TLabel != None)
	{
		GC.SetTileColor(ColWhite);
		GC.DrawStretchedTexture(0+ScaleOffX, 0+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TLabel);
	}
}

function SetTalentData(string NewTalentID, string NewTalentIcon, VMDSkillAugmentManager NewSAM)
{
	TalentID = NewTalentID;
	IconType = NewTalentIcon;
	if (NewSAM != None)
	{
		SAM = NewSAM;
	}
	UpdateTalentData();
}

function UpdateTalentData()
{
	local int i, TArray, SA, SA2, STA, STA2;
	local Skill TSkill, TSkill2;
	local DeusExPlayer DXP;
	local SkillManager SM;
	
	if (SAM != None)
	{
		DXP = SAM.Player;
		if (DXP != None)
		{
			SM = DXP.SkillSystem;
		}
		
		TArray = SAM.SkillAugmentArrayOf(TalentID);
		
		if (TArray > -1)
		{
			PointsCost = SAM.SkillAugmentLevel[TArray];
			TalentName = SAM.SkillAugmentNames[TArray];
			TalentDesc = SAM.SkillAugmentDescs[TArray];
			
			bOwned = SAM.HasSkillAugment(TalentID);
			
			SkillRequirements[0] = SAM.GetSkillAugmentSkillRequired(TArray);
			if (SkillRequirements[0] != None)
			{
				SA = SAM.SkillArrayOf(SkillRequirements[0]);
				if (SA > -1)
				{
					TalentPointsLeft[0] = SAM.SkillAugmentPointsLeft[SA] - SAM.SkillAugmentPointsSpent[SA];
				}
				bSpecialized[0] = int(SAM.IsSpecializedInSkill(SkillRequirements[0]));
				RequiredLevels[0] = SAM.SkillAugmentLevelRequired[TArray];
				
				if (SM != None)
				{
					TSkill = SM.GetSkillFromClass(SkillRequirements[0]);
					if (TSkill != None)
					{
						CurSkillLevels[0] = TSkill.CurrentLevel;
						SkillRequirementNames[0] = TSkill.SkillName;
						SkillLevelRequirementNames[0] = TSkill.SkillLevelStrings[RequiredLevels[0] - bSpecialized[0]];
					}
				}
				SkillTalentRequirementIDs[0] = SAM.SkillAugmentRequired[TArray];
				STA = SAM.SkillAugmentArrayOf(SkillTalentRequirementIDs[0]);
				SkillTalentRequirementNames[0] = SAM.SkillAugmentNames[STA];
			}
			SkillRequirements[1] = SAM.GetSecondarySkillAugmentSkillRequired(TArray);
			if (SkillRequirements[1] != None)
			{
				SA2 = SAM.SkillArrayOf(SkillRequirements[1]);
				if (SA2 > -1)
				{
					TalentPointsLeft[1] = SAM.SkillAugmentPointsLeft[SA2] - SAM.SkillAugmentPointsSpent[SA2];
				}
				bSpecialized[1] = int(SAM.IsSpecializedInSkill(SkillRequirements[1]));
				RequiredLevels[1] = SAM.SecondarySkillAugmentLevelRequired[TArray];
				
				if (SM != None)
				{
					TSkill2 = SM.GetSkillFromClass(SkillRequirements[1]);
					if (TSkill2 != None)
					{
						CurSkillLevels[1] = TSkill2.CurrentLevel;
						SkillRequirementNames[1] = TSkill2.SkillName;
						SkillLevelRequirementNames[1] = TSkill2.SkillLevelStrings[RequiredLevels[1] - bSpecialized[1]];
					}
				}
				SkillTalentRequirementIDs[1] = SAM.SecondarySkillAugmentRequired[TArray];
				STA2 = SAM.SkillAugmentArrayOf(SkillTalentRequirementIDs[1]);
				if (STA2 > -1)
				{
					SkillTalentRequirementNames[1] = SAM.SkillAugmentNames[STA2];
				}
			}
			HighestLevel = Max(RequiredLevels[0], RequiredLevels[1]);
		}
		
		DrawScale = 1.0 + (PointsCost/3.0);
		
		MapOffX = 16*(2.0 - DrawScale);
		MapOffY = 16*(2.0 - DrawScale);
		SetSize(64, 64);
		
		LastState = 0;
		if (bOwned)
		{
			LastState = 2;
		}
		else if (CanBeBought())
		{
			LastState = 1;
		}
		
		LastBuyState = 0;
		if (bOwned)
		{
			LastBuyState = 2;
		}
		else if (PathUnlocked())
		{
			LastBuyState = 1;
		}
		
		SkillIconIndex = GetIconIndex(IconType);
	}
	UpdateHoverTip();
}

function UpdateZoomLevel()
{
	if ((SkillScreen != None) && (SkillScreen.ZoomInFactor > 0.0))
	{
		ZoomRenderScale = SkillScreen.ZoomInFactor;
		
		MapOffX = 16*(2.0 - (DrawScale * ZoomRenderScale));
		MapOffY = 16*(2.0 - (DrawScale * ZoomRenderScale));
	}
}

function UpdateHoverTip()
{
	bHoverAlert = false;
	if (LastState == 1)
	{
		bHoverAlert = true;
	}
	
	HoverTip = TalentName;
	if (bOwned)
	{
		HoverTip = HoverTip@TipOwned;
	}
	else
	{
		HoverTip = HoverTip$CR()$SprintF(TipPointsCost, PointsCost);
	}
	
	HoverTip = HoverTip$CR()$CR()$TipRequirements;
	if (SkillRequirementNames[0] != "")
	{
		HoverTip = HoverTip$CR()$SkillRequirementNames[0]$":"@SkillLevelRequirementNames[0];
		if (SkillRequirementNames[1] != "")
		{
			HoverTip = HoverTip$","$CR()$SkillRequirementNames[1]$":"@SkillLevelRequirementNames[1];
		}
		
		if (SkillTalentRequirementNames[0] != "")
		{
			HoverTip = HoverTip$CR();
			
			HoverTip = HoverTip$SkillTalentRequirementNames[0];
			if (SkillTalentRequirementNames[1] != "")
			{
				HoverTip = HoverTip$", "$SkillTalentRequirementNames[1];
			}
		}
	}
	HoverTip = HoverTip$CR()$CR()$BreakUpHoverTip(TalentDesc);
}

function string BreakUpHoverTip(string S)
{
	local int NPos;
	local string LeftStr, RightStr;
	
	NPos = InStr(S, "|n");
	if (NPos > -1)
	{
		do
		{
			LeftStr = Left(S, NPos);
			RightStr = Right(S, Len(S)-NPos-2);
			S = LeftStr$CR()$RightStr;
			
			NPos = InStr(S, "|n");
		}
		until (NPos < 0);
	}
	
	return S;
}

function bool CanBeBought()
{
	local int AdjustedReqs[2], RequirementsMet[2], PointsTotal;
	local bool bMetPoints, bMetReqs, bMetTalents;
	
	if (bOwned) return false;
	
	AdjustedReqs[0] = RequiredLevels[0] - bSpecialized[0];
	AdjustedReqs[1] = RequiredLevels[1] - bSpecialized[1];
	
	PointsTotal = TalentPointsLeft[0] + TalentPointsLeft[1];
	
	if (PointsTotal >= PointsCost)
	{
		bMetPoints = true;
	}
	if ((AdjustedReqs[0] < 1 || CurSkillLevels[0] >= AdjustedReqs[0]) && (AdjustedReqs[1] < 1 || CurSkillLevels[1] >= AdjustedReqs[1]))
	{
		bMetReqs = true;
	}
	if ((SAM != None) && (SkillTalentRequirementIDs[0] == "" || SAM.HasSkillAugment(SkillTalentRequirementIDs[0]))
			&& (SkillTalentRequirementIDs[1] == "" || SAM.HasSkillAugment(SkillTalentRequirementIDs[1])))
	{
		bMetTalents = true;
	}
	
	return ((bMetReqs) && (bMetPoints) && (bMetTalents));
}

function bool PathUnlocked()
{
	local int AdjustedReqs[2], RequirementsMet[2], PointsTotal;
	local bool bMetReqs, bMetTalents;
	
	if (bOwned) return false;
	
	AdjustedReqs[0] = RequiredLevels[0] - bSpecialized[0];
	AdjustedReqs[1] = RequiredLevels[1] - bSpecialized[1];
	
	PointsTotal = TalentPointsLeft[0] + TalentPointsLeft[1];
	
	if ((AdjustedReqs[0] < 1 || CurSkillLevels[0] >= AdjustedReqs[0]) && (AdjustedReqs[1] < 1 || CurSkillLevels[1] >= AdjustedReqs[1]))
	{
		bMetReqs = true;
	}
	if ((SAM != None) && (SkillTalentRequirementIDs[0] == "" || SAM.HasSkillAugment(SkillTalentRequirementIDs[0]))
			&& (SkillTalentRequirementIDs[1] == "" || SAM.HasSkillAugment(SkillTalentRequirementIDs[1])))
	{
		bMetTalents = true;
	}
	
	return ((bMetReqs) && (bMetTalents));
}

function int GetIconIndex(string CheckIconType)
{
	local int i;
	
	for (i=0; i<ArrayCount(IconTypes); i++)
	{
		if (IconTypes[i] ~= CheckIconType) return i;
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
	
	SetWidth(32);
}

event MouseMoved(float newX, float newY)
{
	if ((NewX > MapOffX) && (NewX < 64-MapOffX) && (NewY > MapOffY) && (NewY < 64-MapOffY))
	{
		if (SkillScreen != None)
		{
			SkillScreen.HoverTarget = Self;
			SkillScreen.HoverTicks = 0;
		}
	}
}

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button,
                              int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if (button == IK_RightMouse)
	{
		if ((SkillScreen != None) && (TalentPointsLeft[1] >= PointsCost) && (LastState == 1) && (SkillRequirements[1] != None))
		{
			SkillScreen.AttemptAlternatePurchase(Self);
		}
		bResult = True;
	}
	if (button == IK_MiddleMouse)
	{
		if ((SkillScreen != None) && (TalentPointsLeft[0] >= 1) && (TalentPointsLeft[1] >= 1) && (LastState == 1) && (SkillRequirements[0] != None) && (SkillRequirements[1] != None) && (PointsCost == 2))
		{
			SkillScreen.AttemptComboPurchase(Self);
		}
		bResult = True;
	}
	return bResult;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ZoomRenderScale=1.000000
     DrawScale=1.000000
     ColWhite=(R=255,G=255,B=255)
     SkillPosX=4
     SkillPosY=4
     IconTypes(0)="Computer"
     IconTypes(1)="Demolition"
     IconTypes(2)="Enviro"
     IconTypes(3)="Lockpicking"
     IconTypes(4)="Medicine"
     IconTypes(5)="Swimming"
     IconTypes(6)="Tech"
     IconTypes(7)="WeaponHeavy"
     IconTypes(8)="WeaponLowTech"
     IconTypes(9)="WeaponPistol"
     IconTypes(10)="WeaponRifle"
     IconTypes(11)="Armorer"
     IconTypes(12)="Arsonist"
     IconTypes(13)="Biotech"
     IconTypes(14)="Burglar"
     IconTypes(15)="Intricate"
     IconTypes(16)="Invader"
     IconTypes(17)="Robust"
     IconTypes(18)="Rogue"
     IconTypes(19)="Wares"
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
     SkillIcons(11)=Texture'VMDAssets.SkillIconArmorer'
     SkillIcons(12)=Texture'VMDAssets.SkillIconArsonist'
     SkillIcons(13)=Texture'VMDAssets.SkillIconBiotech'
     SkillIcons(14)=Texture'VMDAssets.SkillIconBurglar'
     SkillIcons(15)=Texture'VMDAssets.SkillIconIntricate'
     SkillIcons(16)=Texture'VMDAssets.SkillIconInvader'
     SkillIcons(17)=Texture'VMDAssets.SkillIconRobust'
     SkillIcons(18)=Texture'VMDAssets.SkillIconRogue'
     SkillIcons(19)=Texture'VMDAssets.SkillIconWares'
     
     LevelBorders(0)=Texture'SkillGemUntrained'
     LevelBorders(1)=Texture'SkillGemTrained'
     LevelBorders(2)=Texture'SkillGemAdvanced'
     LevelBorders(3)=Texture'SkillGemMaster'
     LockedLevelBorders(0)=Texture'SkillGemUntrainedLocked'
     LockedLevelBorders(1)=Texture'SkillGemTrainedLocked'
     LockedLevelBorders(2)=Texture'SkillGemAdvancedLocked'
     LockedLevelBorders(3)=Texture'SkillGemMasterLocked'
     HighlightLevelBorders(0)=Texture'SkillGemUntrainedHighlight'
     HighlightLevelBorders(1)=Texture'SkillGemTrainedHighlight'
     HighlightLevelBorders(2)=Texture'SkillGemAdvancedHighlight'
     HighlightLevelBorders(3)=Texture'SkillGemMasterHighlight'
     LevelLabels(0)=Texture'GemLevelLabel0'
     LevelLabels(1)=Texture'GemLevelLabel1'
     LevelLabels(2)=Texture'GemLevelLabel2'
     LevelLabels(3)=Texture'GemLevelLabel3'
     
     TipOwned="(Owned)"
     TipPointsCost="Cost: %d Talent Point(s)"
     TipRequirements="Requirements:"
     
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
