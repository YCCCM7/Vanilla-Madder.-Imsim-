//=============================================================================
// VMDSkillMapSkillGem
//=============================================================================
class VMDSkillMapSkillGem extends PersonaBorderButtonWindow;

//Window slaves
var VMDPersonaScreenSkills SkillScreen;
var bool bTalentsEnabled;

//Default data
var Texture SkillIcons[11], LevelBorders[4], LockedLevelBorders[4], HighlightLevelBorders[4], LevelLabels[4], PointsLeftLabels[8],
		UntrainedPurchaseFrames[16], TrainedPurchaseFrames[16], AdvancedPurchaseFrames[16], MasterPurchaseFrames[16];
var Color ColWhite, ColPoints;
var string SkillTypes[11];
var class<Skill> SkillType;
var int SkillPosX, SkillPosY;

//Active set stuff.
var Skill RelSkill;
var int CurSkillLevel, TalentPointsLeft;
var bool bSpecialized;

var int SkillPointsLeft, NextLevelCost;
var float PurchaseProgress;
var string SkillName, SkillDesc, LevelDescs[4];

//Draw scale barf
var float CurDrawScale, DrawScale, ZoomRenderScale, MapOffX, MapOffY;
var bool bSetFirstDrawScale;
var int TransitionTimer, SkillIconIndex;

//Setup hover tip in advance.
var string HoverTip;
var bool bHoverAlert;

var localized string TipSpecialized, TipLevel, TipSkillPointCost, TipCurLevelDesc, TipNextLevelDesc, TipTalentPointsLeft, TipTalentPointGained, TipTalentPointsGained, TipLevelNames[4];

//MADDERS, 5/16/22: Do non-static stuff instead.
var VMDNonStaticSkillTalentFunctions LastRef;

event DrawWindow(GC gc)
{
	local Texture TLabel, TBorder, TPurchaseBorder, TSkill, TPoints;
	local int ScaleOffX, ScaleOffY, TFrame;
	local float UnivScale, HackModX, HackModY;
	
	TSkill = SkillIcons[SkillIconIndex];
	
	TBorder = LevelBorders[CurSkillLevel];
	bHoverAlert = true;
	if (CurSkillLevel >= 3)
	{
		bHoverAlert = false;
		TBorder = HighlightLevelBorders[CurSkillLevel];
	}
	else if (SkillPointsLeft < NextLevelCost)
	{
		bHoverAlert = false;
		TBorder = LockedLevelBorders[CurSkillLevel];
	}
	
	//TLabel = LevelLabels[CurSkillLevel];
	TPoints = PointsLeftLabels[TalentPointsLeft];
	
	// Draw the textures
	//if (bTranslucent)
	//	gc.SetStyle(DSTY_Translucent);
	//else
		gc.SetStyle(DSTY_Masked);
	
	//ScaleOffX = MapOffX;
	//ScaleOffY = MapOffY;
	
	UnivScale = CurDrawScale*ZoomRenderScale;
	
	if (PurchaseProgress > 0)
	{
		TFrame = Clamp(int(PurchaseProgress * 16.0), 0, 15);
		if (CurSkillLevel == 0)
		{
			TBorder = UntrainedPurchaseFrames[TFrame];
		}
		else if (CurSkillLevel == 1)
		{
			TBorder = TrainedPurchaseFrames[TFrame];
		}
		else if (CurSkillLevel == 2)
		{
			TBorder = AdvancedPurchaseFrames[TFrame];
		}
		else if (CurSkillLevel == 3)
		{
			TBorder = MasterPurchaseFrames[TFrame];
		}
	}
	if (TBorder != None)
	{
		GC.SetTileColor(ColButtonFace);
		GC.DrawStretchedTexture(0+ScaleOffX, 0+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TBorder);
	}
	
	TPurchaseBorder = HighlightLevelBorders[CurSkillLevel];
	if ((TPurchaseBorder != None) && (PurchaseProgress > 0))
	{
		//GC.SetTileColor(ColButtonFace);
		//GC.DrawStretchedTexture(0+ScaleOffX, 0+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TPurchaseBorder);
	}
	
	if (TSkill != None)
	{
		GC.SetTileColor(ColWhite);
		GC.DrawStretchedTexture((SkillPosX*UnivScale)+ScaleOffX, (SkillPosY*UnivScale)+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TSkill);
	}
	/*if (TLabel != None)
	{
		GC.SetTileColor(ColWhite);
		GC.DrawStretchedTexture(0+ScaleOffX, 0+ScaleOffY, 32*UnivScale, 32*UnivScale, 0, 0, 32, 32, TLabel);
	}*/
	if ((TPoints != None) && (bTalentsEnabled))
	{
		HackModX = (UnivScale - CurDrawScale) * 32;
		HackModY = 0;
		
		GC.SetTileColor(ColPoints);
		GC.DrawStretchedTexture(0+ScaleOffX+HackModX, 0+ScaleOffY+HackModY, 32*CurDrawScale, 32*CurDrawScale, 0, 0, 32, 32, TPoints);
	}
}

function SetSkillData(int NewSkillPointsLeft, bool NewbSpecialized, Skill NewSkill, bool NewbTalentsEnabled)
{
	if (NewSkill != None)
	{
		RelSkill = NewSkill;
		SkillPointsLeft = NewSkillPointsLeft;
		bSpecialized = NewbSpecialized;
		bTalentsEnabled = NewbTalentsEnabled;
	}
	UpdateSkillData();
}

function UpdateSkillData()
{
	local int i, j;
	local float TWidth, THeight;
	local VMDSkillAugmentManager SAM;
	
	if ((RelSkill != None) && (LastRef != None))
	{
		if ((SkillScreen != None) && (SkillScreen.VMP != None))
		{
			SkillPointsLeft = SkillScreen.VMP.SkillPointsTotal - SkillScreen.VMP.SkillPointsSpent;
			
			SAM = SkillScreen.VMP.SkillAugmentManager;
			if (SAM != None)
			{
				j = SAM.SkillArrayOf(RelSkill.Class);
				if (j > -1)
				{
					TalentPointsLeft = SAM.SkillAugmentPointsLeft[j] - SAM.SkillAugmentPointsSpent[j];
				}
			}
		}
		
		CurSkillLevel = RelSkill.CurrentLevel;
		if (CurSkillLevel < 3)
		{
			NextLevelCost = RelSkill.GetCost();
		}
		else
		{
			NextLevelCost = 0;
		}
		
		//DrawScale = 1+RelSkill.CurrentLevel;
		DrawScale = 1.5 + ( (Min(3, RelSkill.CurrentLevel+int(bSpecialized)))/2.0 );
		if (!bSetFirstDrawScale)
		{
			CurDrawScale = DrawScale;
			bSetFirstDrawScale = true;
		}
		else
		{
			TransitionTimer = AddTimer(0.035, true,, 'TransitionDrawScale');
		}
		
		MapOffX = GetMapOff();
		MapOffY = GetMapOff();
		SetSize(GetProperSize(), GetProperSize());
		
		SkillType = RelSkill.Class;
		SkillName = RelSkill.SkillName;
		SkillDesc = LastRef.GetCoreDesc(SkillType);
		for (i=0; i<ArrayCount(LevelDescs); i++)
		{
			LevelDescs[i] = LastRef.GetLevelDesc(SkillType, i);
		}
		
		SkillIconIndex = GetSkillIndex(string(SkillType));
	}
	UpdateHoverTip();
}

function UpdateHoverTip()
{
	local string TalentGain;
	
	HoverTip = SkillName;
	if (bSpecialized)
	{
		HoverTip = HoverTip@TipSpecialized;
	}
	
	HoverTip = HoverTip$CR()$SprintF(TipLevel, CurSkillLevel);
	if ((TalentPointsLeft > 0) && (bTalentsEnabled))
	{
		HoverTip = HoverTip@SprintF(TipTalentPointsLeft, TalentPointsLeft);
	}
	
	if (CurSkillLevel == 0)
	{
		HoverTip = HoverTip$CR()$CR()$BreakUpHoverTip(SkillDesc);
	}
	
	HoverTip = HoverTip$CR()$CR()$TipCurLevelDesc@TipLevelNames[CurSkillLevel]$BreakUpHoverTip(LevelDescs[CurSkillLevel]);
	if (CurSkillLevel < 3)
	{
		switch(CurSkillLevel)
		{
			case 0:
				TalentGain = SprintF(TipTalentPointGained, 1);
			break;
			case 1:
				TalentGain = SprintF(TipTalentPointsGained, 2);
			break;
			case 2:
				if (bSpecialized)
				{
					TalentGain = SprintF(TipTalentPointsGained, 2);
				}
				else
				{
					TalentGain = SprintF(TipTalentPointsGained, 3);
				}
			break;
		}
		HoverTip = HoverTip$CR()$CR()$TipNextLevelDesc@TipLevelNames[CurSkillLevel+1]@SprintF(TipSkillPointCost, NextLevelCost)$BreakUpHoverTip(LevelDescs[CurSkillLevel+1]$CR()$TalentGain);
	}
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

function TransitionDrawScale()
{
	if (DrawScale > CurDrawScale)
	{
		CurDrawScale += 0.05;
		SetSize(GetProperSize(), GetProperSize());
	}
	else if (DrawScale < CurDrawScale)
	{
		CurDrawScale -= 0.05;
		SetSize(GetProperSize(), GetProperSize());
	}
	
	MapOffX = GetMapOff();
	MapOffY = GetMapOff();
	
	if (Abs(DrawScale - CurDrawScale) <= 0.05)
	{
		CurDrawScale = DrawScale;
		RemoveTimer(TransitionTimer);
	}
	SkillScreen.UpdateTreePositions();
}

function UpdateZoomLevel()
{
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
	
	Ret = 16*(3.0 - (CurDrawScale)) * ZoomRenderScale;
	
	return Ret;
}

function int GetProperSize()
{
	local int Ret;
	
	Ret = int((32.0 * CurDrawScale * ZoomRenderScale) +0.99);
	//Ret += GetMapOff();
	
	return Ret;
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

function TogglePointsLeftColor()
{
	if (TalentPointsLeft > 0)
	{
		if (ColPoints == ColWhite)
		{
			ColPoints = ColButtonFace;
		}
		else
		{
			ColPoints = ColWhite;
		}
	}
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
	
	UpdateStatRef();
	
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

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//+++++++++++++++++++++++++++++++
//MADDERS, 5/16/22: No more static, thank you very much.
function UpdateStatRef()
{
	local VMDNonStaticSkillTalentFunctions TStat;
	
	if (LastRef != None)
	{
		TStat = LastRef;
	}
	else if (Player != None)
	{
		forEach Player.AllActors(class'VMDNonStaticSkillTalentFunctions', TStat)
		{
			break;
		}
		if (TStat == None)
		{
			TStat = Player.Spawn(class'VMDNonStaticSkillTalentFunctions');
		}
	}
	
	LastRef = TStat;
}


defaultproperties
{
     ZoomRenderScale=1.000000
     CurDrawScale=1.000000
     DrawScale=1.000000
     ColWhite=(R=255,G=255,B=255)
     ColPoints=(R=255,G=255,B=255)
     SkillPosX=4
     SkillPosY=4
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
     SkillIcons(6)=Texture'VMDAssets.SkillIconTechFixed'
     SkillIcons(7)=Texture'DeusExUI.UserInterface.SkillIconWeaponHeavy'
     SkillIcons(8)=Texture'DeusExUI.UserInterface.SkillIconWeaponLowTech'
     SkillIcons(9)=Texture'DeusExUI.UserInterface.SkillIconWeaponPistol'
     SkillIcons(10)=Texture'VMDAssets.SkillIconWeaponRifleFixed'
     
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
     PointsLeftLabels(0)=Texture'GemPointsLabel0'
     PointsLeftLabels(1)=Texture'GemPointsLabel1'
     PointsLeftLabels(2)=Texture'GemPointsLabel2'
     PointsLeftLabels(3)=Texture'GemPointsLabel3'
     PointsLeftLabels(4)=Texture'GemPointsLabel4'
     PointsLeftLabels(5)=Texture'GemPointsLabel5'
     PointsLeftLabels(6)=Texture'GemPointsLabel6'
     PointsLeftLabels(7)=Texture'GemPointsLabel7'
     
     TipSpecialized="(Resonating)"
     TipLevel="Level %d"
     TipSkillPointCost="(%d skill points)"
     TipCurLevelDesc="Current level:"
     TipTalentPointsLeft="(%d Talent Point(s) Left)"
     TipNextLevelDesc="Next level:"
     TipTalentPointGained="+%d Talent Point"
     TipTalentPointsGained="+%d Talent Points"
     TipLevelNames(0)="UNTRAINED"
     TipLevelNames(1)="TRAINED"
     TipLevelNames(2)="ADVANCED"
     TipLevelNames(3)="MASTER"
     
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
