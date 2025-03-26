//=============================================================================
// VMDSkillMapTalentGem
//=============================================================================
class VMDSkillMapTalentGem extends PersonaBorderButtonWindow;

//Window slaves
var VMDPersonaScreenSkills SkillScreen;
var VMDSkillAugmentManager SAM;

//Default data
var Texture SkillIcons[21], LevelBorders[4], LockedLevelBorders[4], HighlightLevelBorders[4], LevelLabels[4],
		UntrainedPurchaseFrames[16], TrainedPurchaseFrames[16], AdvancedPurchaseFrames[16], MasterPurchaseFrames[16];
var string IconTypes[21];

var int SkillPosX, SkillPosY;
var Color ColWhite, ColGray, ColDarkGray, ColButtonFace2, ColButtonFace3;

//Active set stuff.
var int LastState, LastBuyState;

var int PointsCost, HighestLevel;
var float PurchaseProgress;
var string TalentName, TalentDesc, IconType;
var name TalentID;
var bool bOwned;

//Checks for both ends.
var int TalentPointsLeft[2], bSpecialized[2], RequiredLevels[2], CurSkillLevels[2];
var class<Skill> SkillRequirements[2];

var string SkillRequirementNames[2], SkillLevelRequirementNames[2], SkillTalentRequirementNames[2];
var name SkillTalentRequirementIDs[2];

//Draw scale barf
var float DrawScale, ZoomRenderScale, MapOffX, MapOffY;
var int SkillIconIndex;

//Setup hover tip in advance.
var string HoverTip;
var bool bHoverAlert;

var localized string TipOwned, TipPointsCost, TipRequirements;

event StyleChanged()
{
	Super.StyleChanged();
	
	ColButtonFace2.R = ColButtonFace.R * 0.85;
	ColButtonFace2.G = ColButtonFace.G * 0.85;
	ColButtonFace2.B = ColButtonFace.B * 0.85;
	
	ColButtonFace3.R = ColButtonFace.R * 0.35;
	ColButtonFace3.G = ColButtonFace.G * 0.35;
	ColButtonFace3.B = ColButtonFace.B * 0.35;
}

event DrawWindow(GC gc)
{
	local Texture TLabel, TBorder, TSkill;
	local int i, ScaleOffX, ScaleOffY, TFrame;
	local float UnivScale, HackModX, HackModY;
	
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
	if (LastState < 2)
	{
		gc.SetStyle(DSTY_Translucent);
		
		UnivScale = DrawScale * ZoomRenderScale;
		
		//ScaleOffX = MapOffX;
		//ScaleOffY = MapOffY;
		
		if (PurchaseProgress > 0)
		{
			TFrame = Clamp(int(PurchaseProgress * 16.0), 0, 15);
			if (HighestLevel == 0)
			{
				TBorder = UntrainedPurchaseFrames[TFrame];
			}
			else if (HighestLevel == 1)
			{
				TBorder = TrainedPurchaseFrames[TFrame];
			}
			else if (HighestLevel == 2)
			{
				TBorder = AdvancedPurchaseFrames[TFrame];
			}
			else if (HighestLevel == 3)
			{
				TBorder = MasterPurchaseFrames[TFrame];
			}
		}
		if (TBorder != None)
		{
			if (LastState == 0)
			{
				GC.SetTileColor(ColButtonFace3);
			}
			else
			{
				GC.SetTileColor(ColButtonFace2);
			}
			GC.DrawStretchedTexture(0+ScaleOffX, 0+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TBorder);
		}
		
		gc.SetStyle(DSTY_Masked);
		
		if (TSkill != None)
		{
			if (LastState == 0)
			{
				GC.SetTileColor(ColDarkGray);
			}
			else
			{
				GC.SetTileColor(ColGray);
			}
			GC.DrawStretchedTexture((SkillPosX*UnivScale)+ScaleOffX, (SkillPosY*UnivScale)+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TSkill);
		}
	}
	else
	{
		gc.SetStyle(DSTY_Masked);
		
		//ScaleOffX = MapOffX;
		//ScaleOffY = MapOffY;
		
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
	}
	
	if (TLabel != None)
	{
		HackModX = (UnivScale - DrawScale) * 32;
		HackModY = HackModX;
		
		GC.SetTileColor(ColWhite);
		GC.DrawStretchedTexture(0+ScaleOffX+HackModX, 0+ScaleOffY+HackModY, 32*DrawScale, 32*DrawScale, 0, 0, 32, 32, TLabel);
	}
}

function SetTalentData(Name NewTalentID, string NewTalentIcon, VMDSkillAugmentManager NewSAM)
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
	local float TWidth, THeight;
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
				SkillTalentRequirementIDs[0] = SAM.GetSkillAugmentRequired(TArray);
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
				SkillTalentRequirementIDs[1] = SAM.GetSecondarySkillAugmentRequired(TArray);
				STA2 = SAM.SkillAugmentArrayOf(SkillTalentRequirementIDs[1]);
				if (STA2 > -1)
				{
					SkillTalentRequirementNames[1] = SAM.SkillAugmentNames[STA2];
				}
			}
			HighestLevel = Max(RequiredLevels[0], RequiredLevels[1]);
		}
		
		DrawScale = 1.0 + (PointsCost/3.0);
		
		MapOffX = GetMapOff();
		MapOffY = GetMapOff();
		
		SetSize(GetProperSize(), GetProperSize());
		
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
	local float TWidth, THeight;
	
	if ((SkillScreen != None) && (SkillScreen.ZoomInFactor > 0.0))
	{
		ZoomRenderScale = SkillScreen.ZoomInFactor;
		
		SetSize(GetProperSize(), GetProperSize());
		MapOffX = GetMapOff();
		MapOffY = GetMapOff();
	}
}

function int GetMapOff()
{
	local int Ret;
	
	Ret = 16*(3.0 - (DrawScale)) * ZoomRenderScale;
	
	return Ret;
}

function int GetProperSize()
{
	local int Ret;
	
	Ret = int((32.0 * DrawScale * ZoomRenderScale) +0.99);
	//Ret += GetMapOff();
	
	return Ret;
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
	if ((SAM != None) && (SkillTalentRequirementIDs[0] == '' || SAM.HasSkillAugment(SkillTalentRequirementIDs[0]))
			&& (SkillTalentRequirementIDs[1] == '' || SAM.HasSkillAugment(SkillTalentRequirementIDs[1])))
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
	if ((SAM != None) && (SkillTalentRequirementIDs[0] == '' || SAM.HasSkillAugment(SkillTalentRequirementIDs[0]))
			&& (SkillTalentRequirementIDs[1] == '' || SAM.HasSkillAugment(SkillTalentRequirementIDs[1])))
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
	//MapOffX, MapOffY
	if ((NewX > 0) && (NewX < Width) && (NewY > 0) && (NewY < Height))
	{
		if (SkillScreen != None)
		{
			SkillScreen.HoverTarget = Self;
			SkillScreen.HoverTicks = 0;
		}
	}
}

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if ((SkillScreen != None) && (SkillScreen.VMP.bClassicSkillPurchasing))
	{
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
     ColGray=(R=170,G=170,B=170)
     ColDarkGray=(R=85,G=85,B=85)
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
     IconTypes(20)="Ninja"
     SkillIcons(0)=Texture'DeusExUI.UserInterface.SkillIconComputer'
     SkillIcons(1)=Texture'DeusExUI.UserInterface.SkillIconDemolition'
     SkillIcons(2)=Texture'DeusExUI.UserInterface.SkillIconEnviro'
     SkillIcons(3)=Texture'DeusExUI.UserInterface.SkillIconLockPicking'
     SkillIcons(4)=Texture'DeusExUI.UserInterface.SkillIconMedicine'
     SkillIcons(5)=Texture'DeusExUI.UserInterface.SkillIconSwimming'
     SkillIcons(6)=Texture'VMDAssets.SkillIconTechFixed'
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
     SkillIcons(20)=Texture'VMDAssets.SkillIconNinja'
     
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
     
     UntrainedPurchaseFrames(0)=Texture'SkillGemUntrainedLocked'
     UntrainedPurchaseFrames(1)=Texture'SkillGemUntrainedPurchase01'
     UntrainedPurchaseFrames(2)=Texture'SkillGemUntrainedPurchase02'
     UntrainedPurchaseFrames(3)=Texture'SkillGemUntrainedPurchase03'
     UntrainedPurchaseFrames(4)=Texture'SkillGemUntrainedPurchase04'
     UntrainedPurchaseFrames(5)=Texture'SkillGemUntrainedPurchase05'
     UntrainedPurchaseFrames(6)=Texture'SkillGemUntrainedPurchase06'
     UntrainedPurchaseFrames(7)=Texture'SkillGemUntrainedPurchase07'
     UntrainedPurchaseFrames(8)=Texture'SkillGemUntrainedPurchase08'
     UntrainedPurchaseFrames(9)=Texture'SkillGemUntrainedPurchase09'
     UntrainedPurchaseFrames(10)=Texture'SkillGemUntrainedPurchase10'
     UntrainedPurchaseFrames(11)=Texture'SkillGemUntrainedPurchase11'
     UntrainedPurchaseFrames(12)=Texture'SkillGemUntrainedPurchase12'
     UntrainedPurchaseFrames(13)=Texture'SkillGemUntrainedPurchase13'
     UntrainedPurchaseFrames(14)=Texture'SkillGemUntrainedPurchase14'
     UntrainedPurchaseFrames(15)=Texture'SkillGemUntrainedPurchase15'
     TrainedPurchaseFrames(0)=Texture'SkillGemTrainedLocked'
     TrainedPurchaseFrames(1)=Texture'SkillGemTrainedPurchase01'
     TrainedPurchaseFrames(2)=Texture'SkillGemTrainedPurchase02'
     TrainedPurchaseFrames(3)=Texture'SkillGemTrainedPurchase03'
     TrainedPurchaseFrames(4)=Texture'SkillGemTrainedPurchase04'
     TrainedPurchaseFrames(5)=Texture'SkillGemTrainedPurchase05'
     TrainedPurchaseFrames(6)=Texture'SkillGemTrainedPurchase06'
     TrainedPurchaseFrames(7)=Texture'SkillGemTrainedPurchase07'
     TrainedPurchaseFrames(8)=Texture'SkillGemTrainedPurchase08'
     TrainedPurchaseFrames(9)=Texture'SkillGemTrainedPurchase09'
     TrainedPurchaseFrames(10)=Texture'SkillGemTrainedPurchase10'
     TrainedPurchaseFrames(11)=Texture'SkillGemTrainedPurchase11'
     TrainedPurchaseFrames(12)=Texture'SkillGemTrainedPurchase12'
     TrainedPurchaseFrames(13)=Texture'SkillGemTrainedPurchase13'
     TrainedPurchaseFrames(14)=Texture'SkillGemTrainedPurchase14'
     TrainedPurchaseFrames(15)=Texture'SkillGemTrainedPurchase15'
     AdvancedPurchaseFrames(0)=Texture'SkillGemAdvancedLocked'
     AdvancedPurchaseFrames(1)=Texture'SkillGemAdvancedPurchase01'
     AdvancedPurchaseFrames(2)=Texture'SkillGemAdvancedPurchase02'
     AdvancedPurchaseFrames(3)=Texture'SkillGemAdvancedPurchase03'
     AdvancedPurchaseFrames(4)=Texture'SkillGemAdvancedPurchase04'
     AdvancedPurchaseFrames(5)=Texture'SkillGemAdvancedPurchase05'
     AdvancedPurchaseFrames(6)=Texture'SkillGemAdvancedPurchase06'
     AdvancedPurchaseFrames(7)=Texture'SkillGemAdvancedPurchase07'
     AdvancedPurchaseFrames(8)=Texture'SkillGemAdvancedPurchase08'
     AdvancedPurchaseFrames(9)=Texture'SkillGemAdvancedPurchase09'
     AdvancedPurchaseFrames(10)=Texture'SkillGemAdvancedPurchase10'
     AdvancedPurchaseFrames(11)=Texture'SkillGemAdvancedPurchase11'
     AdvancedPurchaseFrames(12)=Texture'SkillGemAdvancedPurchase12'
     AdvancedPurchaseFrames(13)=Texture'SkillGemAdvancedPurchase13'
     AdvancedPurchaseFrames(14)=Texture'SkillGemAdvancedPurchase14'
     AdvancedPurchaseFrames(15)=Texture'SkillGemAdvancedPurchase15'
     MasterPurchaseFrames(0)=Texture'SkillGemMasterPurchaseLocked'
     MasterPurchaseFrames(1)=Texture'SkillGemMasterPurchase01'
     MasterPurchaseFrames(2)=Texture'SkillGemMasterPurchase02'
     MasterPurchaseFrames(3)=Texture'SkillGemMasterPurchase03'
     MasterPurchaseFrames(4)=Texture'SkillGemMasterPurchase04'
     MasterPurchaseFrames(5)=Texture'SkillGemMasterPurchase05'
     MasterPurchaseFrames(6)=Texture'SkillGemMasterPurchase06'
     MasterPurchaseFrames(7)=Texture'SkillGemMasterPurchase07'
     MasterPurchaseFrames(8)=Texture'SkillGemMasterPurchase08'
     MasterPurchaseFrames(9)=Texture'SkillGemMasterPurchase09'
     MasterPurchaseFrames(10)=Texture'SkillGemMasterPurchase10'
     MasterPurchaseFrames(11)=Texture'SkillGemMasterPurchase11'
     MasterPurchaseFrames(12)=Texture'SkillGemMasterPurchase12'
     MasterPurchaseFrames(13)=Texture'SkillGemMasterPurchase13'
     MasterPurchaseFrames(14)=Texture'SkillGemMasterPurchase14'
     MasterPurchaseFrames(15)=Texture'SkillGemMasterPurchase15'
     
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
