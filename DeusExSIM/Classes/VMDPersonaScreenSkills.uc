//=============================================================================
// VMDPersonaScreenSkills
//=============================================================================
class VMDPersonaScreenSkills extends PersonaScreenBaseWindow;

enum EConfirmBoxModes
{
	CB_None,
	CB_BuySkill,
	CB_BuyPrimary,
	CB_BuySecondary,
	CB_BuyCombo,
};

struct VMDButtonPos {
	var int X;
	var int Y;
};

var EConfirmBoxModes ConfirmBoxMode;
var localized string MessageBoxTitles[5], MessageBoxBodies[5];

//MADDERS: All this junk.
var VMDBufferPlayer VMP;
var SkillManager SM;
var VMDSkillAugmentManager SAM;

var VMDSkillMapInterfaceWindow CurDragInterface, DragInterfaces[6];
var VMDButtonPos InterfacePos[6], InterfaceSize[6];
var Texture InterfaceTex[6];

//Move everything along these coords. Good times.
var bool bDragging;
var float TimeSinceLastUpdate;

//---------------------
//CONTROL STUFF!
var int NavigatedX, NavigatedY, NavigateFloorX, NavigateCeilingX, NavigateFloorY, NavigateCeilingY;
var float DragPosX, DragPosY, ZoomInFactor, GlobalZoomRate, GlobalZoomFloor, GlobalZoomCap;
//---------------------
//LABEL STUFF!
var localized string SkillTalentsTitleText, SkillPointsLeftText;

var PersonaTitleTextWindow SkillPointsLeftLabel;
var VMDButtonPos SkillPointsLeftLabelPos;

//---------------------
//JUMP GEM STUFF!
var class<Skill> SkillTypes[11];
var VMDSkillMapJumpGem JumpGems[11];
var VMDButtonPos JumpGemStartPos, JumpGemOffset, JumpGemJumpLoc[11];

//---------------------
//SKILL GEMS
var VMDSkillMapSkillGem SkillGems[11], SelectedSkillGem;
var VMDButtonPos SkillGemPos[11];

var VMDSkillMapInterfaceWindow SkillGemBackdrops[33];
var VMDButtonPos SkillGemBackdropOffset[3];

var float SkillFlashUpdateTimer;

//---------------------
//TALENT GEMS
var string SkillTalentIcons[100];
var name SkillTalentIDs[100];
var VMDSkillMapTalentGem TalentGems[100], SelectedTalentGem;
var VMDButtonPos TalentGemPos[100];

//----------------------
//BRANCHING
var VMDSkillMapInterfaceWindow MapBranchingFoundation[40];
var VMDButtonPos MapBranchingFoundationPos[40], MapBranchingFoundationSize[40];
var Texture MapBranchingFoundationTexture[40];

var VMDSkillMapBranchInterfaceWindow MapBranching[100];
var VMDButtonPos MapBranchingPos[100], MapBranchingSize[100];
var Texture MapBranchingTexture[100];
var name MapBranchingTalent[100];

//---------------------
//HOVER TIP STUFF!
var VMDSkillMapHoverTip HoverTip, MouseTip;
var Window HoverTarget;
var VMDButtonPos HoverTipOff, MouseTipPos;
var int HoverTicks;

var localized string TipSpecialized, TipTalentPointsLeft, TipCanUpgradeFor,
			TipLevel, TipSkillPointCost, TipCurLevelDesc, TipNextLevelDesc,
			TipMapControls, TipSkillGemControls, TipTalentGemControlsTriple, TipTalentGemControlsDouble, TipTalentGemControlsSingle, TipJumpGemControls;

var VMDNonStaticSkillTalentFunctions LastRef;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	//MADDERS, 5/16/22: Patched in non-static support. Neato.
	UpdateStatRef();
	
	PersonaNavBarWindow(winNavBar).btnSkills.SetSensitivity(False);
	CreateInterfaces();
	CreateTrees();
	CreateJumpGems();
	CreateLabels();
	CreateHoverTip();
	
	UpdateMapZoom();
	UpdatePointsLeft();
	
	bTickEnabled = True;
	
	EnableButtons();
}

// ----------------------------------------------------------------------
// Create stuff.
// ----------------------------------------------------------------------

function CreateInterfaces()
{
	local int i;
	local Texture TTex;
	
	for (i=ArrayCount(DragInterfaces)-1; i>=0; i--)
	{
		DragInterfaces[i] = VMDSkillMapInterfaceWindow(winClient.NewChild(Class'VMDSkillMapInterfaceWindow'));
		DragInterfaces[i].SetPos(InterfacePos[i].X, InterfacePos[i].Y);
		DragInterfaces[i].VMDSetupInterfaceVars(InterfaceSize[i].X, InterfaceSize[i].Y, InterfaceTex[i], Self);
	}
}

function CreateTrees()
{
	local int i;
	local bool TSpecialized;
	local Skill TSkill;
	local Texture TTex;
	
	if (LastRef == None) return;
	
	for (i=0; i<ArrayCount(JumpGems); i++)
	{
		SkillTypes[i] = LastRef.GetSkillMapSkillOrder(i);
	}
	for (i=0; i<ArrayCount(SkillGems); i++)
	{
		SkillGemPos[i].X = LastRef.GetSkillMapPos(SkillTypes[i], 0);
		SkillGemPos[i].Y = LastRef.GetSkillMapPos(SkillTypes[i], 1);
	}
	
	for (i=0; i<ArrayCount(TalentGems); i++)
	{
		TalentGemPos[i].X = LastRef.GetSkillTalentPos(i, 0, Self);
		TalentGemPos[i].Y = LastRef.GetSkillTalentPos(i, 1, Self);
		SkillTalentIDs[i] = LastRef.GetSkillTalentIDs(i);
		SkillTalentIcons[i] = LastRef.GetSkillTalentIcons(i);
	}
	
	for (i=0; i<ArrayCount(MapBranchingFoundation); i++)
	{
		MapBranchingFoundationPos[i].X = LastRef.GetBFPos(i, 0, Self);
		MapBranchingFoundationPos[i].Y = LastRef.GetBFPos(i, 1, Self);
		MapBranchingFoundationSize[i].X = LastRef.GetBFSize(i, 0, Self);
		MapBranchingFoundationSize[i].Y = LastRef.GetBFSize(i, 1, Self);
		MapBranchingFoundationTexture[i] = LastRef.GetBFTexture(i);
	}
	
	for (i=0; i<ArrayCount(MapBranching); i++)
	{
		MapBranchingPos[i].X = LastRef.GetBPos(i, 0, Self);
		MapBranchingPos[i].Y = LastRef.GetBPos(i, 1, Self);
		MapBranchingSize[i].X = LastRef.GetBSize(i, 0, Self);
		MapBranchingSize[i].Y = LastRef.GetBSize(i, 1, Self);
		MapBranchingTexture[i] = LastRef.GetBTexture(i);
		MapBranchingTalent[i] = LastRef.GetBTalent(i);
	}
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (DragInterfaces[0] != None))
	{
		SM = VMP.SkillSystem;
		SAM = VMP.SkillAugmentManager;
		
		for (i=0; i<ArrayCount(SkillGemBackdrops); i++)
		{
			SkillGemBackdrops[i] = VMDSkillMapInterfaceWindow(DragInterfaces[0].NewChild(Class'VMDSkillMapInterfaceWindow'));
			
			if (i < 11)
			{
				TTex = Texture'SkillGemBackdropMaster';
				SkillGemBackdrops[i].VMDSetupInterfaceVars(128, 128, TTex, Self);
			}
			else if (i < 22)
			{
				TTex = Texture'SkillGemBackdropAdvanced';
				SkillGemBackdrops[i].VMDSetupInterfaceVars(128, 128, TTex, Self);
			}
			else
			{
				TTex = Texture'SkillGemBackdropTrained';
				SkillGemBackdrops[i].VMDSetupInterfaceVars(64, 64, TTex, Self);
			}
		}
		
		if (VMP.bSkillAugmentsEnabled)
		{
			for (i=0; i<ArrayCount(MapBranchingFoundation); i++)
			{
				if (MapBranchingFoundationTexture[i] != None)
				{
					MapBranchingFoundation[i] = VMDSkillMapInterfaceWindow(DragInterfaces[0].NewChild(Class'VMDSkillMapInterfaceWindow'));
					MapBranchingFoundation[i].VMDSetupInterfaceVars(MapBranchingFoundationSize[i].X, MapBranchingFoundationSize[i].Y, MapBranchingFoundationTexture[i], Self);
				}
			}
			for (i=0; i<ArrayCount(MapBranching); i++)
			{
				if (MapBranchingTexture[i] != None)
				{
					MapBranching[i] = VMDSkillMapBranchInterfaceWindow(DragInterfaces[0].NewChild(Class'VMDSkillMapBranchInterfaceWindow'));
				}
			}
		}
		
		for (i=0; i<ArrayCount(SkillGems); i++)
		{
			TSpecialized = VMP.IsSpecializedInSkill(SkillTypes[i]);
			TSkill = SM.GetSkillFromClass(SkillTypes[i]);
			
			SkillGems[i] = VMDSkillMapSkillGem(DragInterfaces[0].NewChild(Class'VMDSkillMapSkillGem'));
			SkillGems[i].SetSkillData(VMP.SkillPointsTotal-VMP.SkillPointsSpent, TSpecialized, TSkill, VMP.bSkillAugmentsEnabled);
			SkillGems[i].SkillScreen = Self;
		}
		if (VMP.bSkillAugmentsEnabled)
		{
			for (i=0; i<ArrayCount(TalentGems); i++)
			{
				if ((SkillTalentIDs[i] != '') && (ShouldSpawnTalentGem(SkillTalentIDs[i])))
				{
					TalentGems[i] = VMDSkillMapTalentGem(DragInterfaces[0].NewChild(Class'VMDSkillMapTalentGem'));
					TalentGems[i].SetTalentData(SkillTalentIDs[i], SkillTalentIcons[i], SAM);
					TalentGems[i].SkillScreen = Self;
				}
			}
			
			for (i=0; i<ArrayCount(MapBranching); i++)
			{
				if (MapBranching[i] != None)
				{
					MapBranching[i].VMDSetupBranchInterfaceVars(MapBranchingSize[i].X, MapBranchingSize[i].Y, FindTalentGem(MapBranchingTalent[i]), MapBranchingTexture[i], Self);
				}
			}
		}
	}
	
	UpdateTreePositions();
}

function VMDSkillMapTalentGem FindTalentGem(Name SearchTalent)
{
	local int i;
	
	for (i=0; i<ArrayCount(TalentGems); i++)
	{
		if ((TalentGems[i] != None) && (SkillTalentIDs[i] != '') && (SkillTalentIDs[i] == SearchTalent))
		{
			return TalentGems[i];
		}
	}
	
	return None;
}

function CreateJumpGems()
{
	local bool TSpec;
	local int i, TPoints;
	local Skill TSkill;
	
	if (LastRef == None) return;
	
	for (i=0; i<ArrayCount(JumpGems); i++)
	{
		JumpGemJumpLoc[i].X = LastRef.GetSkillMapJumpPos(SkillTypes[i], 0);
		JumpGemJumpLoc[i].Y = LastRef.GetSkillMapJumpPos(SkillTypes[i], 1);
	}
	
	for (i=0; i<ArrayCount(JumpGems); i++)
	{
		JumpGems[i] = VMDSkillMapJumpGem(WinClient.NewChild(class'VMDSkillMapJumpGem'));
		JumpGems[i].SetPos(JumpGemStartPos.X+(JumpGemOffset.X*i), JumpGemStartPos.Y+(JumpGemOffset.Y*i));
		
		if ((SM != None) && (VMP != None))
		{
			TSkill = SM.GetSkillFromClass(SkillTypes[i]);
			TSpec = VMP.IsSpecializedInSkill(SkillTypes[i]);
			JumpGems[i].SetSkillData(TSkill, TSpec, JumpGemJumpLoc[i].X, JumpGemJumpLoc[i].Y, VMP.bSkillAugmentsEnabled);
			
			TPoints = VMP.GetSkillAugmentPointsFromSkill(SkillTypes[i]);
			JumpGems[i].UpdatePointsLeft(TSkill.CurrentLevel, VMP.SkillPointsTotal-VMP.SkillPointsSpent, TPoints);
		}
		
		JumpGems[i].SkillScreen = Self;
	}
}

function CreateLabels()
{
	SkillPointsLeftLabel = PersonaTitleTextWindow(NewChild(class'PersonaTitleTextWindow'));
	//SkillPointsLeftLabel.SetWindowAlignments(HALIGN_Right, VALIGN_Top);
	SkillPointsLeftLabel.SetPos(SkillPointsLeftLabelPos.X, SkillPointsLeftLabelPos.Y);
}

function CreateHoverTip()
{
	HoverTip = VMDSkillMapHoverTip(NewChild(Class'VMDSkillMapHoverTip'));
	HoverTip.SetWordWrap(True);
	HoverTip.SetWidth(256);
	MouseTip = VMDSkillMapHoverTip(NewChild(Class'VMDSkillMapHoverTip'));
}

function CreateControls()
{
	Super.CreateControls();
	
	CreateTitleWindow(9, 5, SkillTalentsTitleText);
	CreateInfoWindow();
	CreateButtons();
}

function CreateInfoWindow()
{
}

function CreateButtons()
{
}

// ----------------------------------------------------------------------
// Position fixer functions. Blanket style. Don't worry.
// ----------------------------------------------------------------------

function UpdatePointsLeft()
{
	local int i, TPoints;
	local Skill TSkill;
	
	for (i=0; i<ArrayCount(JumpGems); i++)
	{
		if ((JumpGems[i] != None) && (SM != None))
		{
			TSkill = SM.GetSkillFromClass(SkillTypes[i]);
			TPoints = VMP.GetSkillAugmentPointsFromSkill(SkillTypes[i]);
			JumpGems[i].UpdatePointsLeft(TSkill.CurrentLevel, VMP.SkillPointsTotal-VMP.SkillPointsSpent, TPoints);
		}
	}
	
	for (i=0; i<ArrayCount(SkillGems); i++)
	{
		if (SkillGems[i] != None)
		{
			SkillGems[i].UpdateSkillData();
		}
	}
	
	for (i=0; i<ArrayCount(TalentGems); i++)
	{
		if (TalentGems[i] != None)
		{
			TalentGems[i].UpdateTalentData();
		}
	}
	
	if (VMP != None)
	{
		if (SkillPointsLeftLabel != None)
		{
			SkillPointsLeftLabel.SetText(SprintF(SkillPointsLeftText, VMP.SkillPointsTotal-VMP.SkillPointsSpent));
		}
	}
}

function UpdateTreePositions()
{
	local int i, TXOff, TYOff;
	
	for (i=0; i<ArrayCount(MapBranchingFoundation); i++)
	{
		if (MapBranchingFoundation[i] != None)
		{
			MapBranchingFoundation[i].SetPos((MapBranchingFoundationPos[i].X + NavigatedX)*ZoomInFactor, (MapBranchingFoundationPos[i].Y + NavigatedY)*ZoomInFactor);
		}
	}
	
	for (i=0; i<ArrayCount(MapBranching); i++)
	{
		if (MapBranching[i] != None)
		{
			MapBranching[i].SetPos((MapBranchingPos[i].X + NavigatedX)*ZoomInFactor, (MapBranchingPos[i].Y + NavigatedY)*ZoomInFactor);
		}
	}
	
	for (i=0; i<ArrayCount(SkillGemBackdrops); i++)
	{
		if (i < 11)
		{
			TXOff = SkillGemBackdropOffset[2].X;
			TYOff = SkillGemBackdropOffset[2].Y;
		}
		else if (i < 22)
		{
			TXOff = SkillGemBackdropOffset[1].X;
			TYOff = SkillGemBackdropOffset[1].Y;
		}
		else
		{
			TXOff = SkillGemBackdropOffset[0].X;
			TYOff = SkillGemBackdropOffset[0].Y;
		}
		
		if (SkillGemBackdrops[i] != None)
		{
			SkillGemBackdrops[i].SetPos((SkillGemPos[i%11].X + TXOff + NavigatedX)*ZoomInFactor, (SkillGemPos[i%11].Y + TYOff + NavigatedY)*ZoomInFactor);
		}
	}
	
	for (i=0; i<ArrayCount(SkillGems); i++)
	{
		if (SkillGems[i] != None)
		{
			SkillGems[i].SetPos((SkillGemPos[i].X + NavigatedX)*ZoomInFactor + SkillGems[i].GetMapOff(), (SkillGemPos[i].Y + NavigatedY)*ZoomInFactor + SkillGems[i].GetMapOff());
		}
	}
	for (i=0; i<ArrayCount(TalentGems); i++)
	{
		if (TalentGems[i] != None)
		{
			TalentGems[i].SetPos((TalentGemPos[i].X + NavigatedX)*ZoomInFactor-(16*ZoomInFactor) + TalentGems[i].GetMapOff(), (TalentGemPos[i].Y + NavigatedY)*ZoomInFactor-(16*ZoomInFactor) + TalentGems[i].GetMapOff());
		}
	}
	//UpdatePointsLeft();
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local VMDSkillMapSkillGem SG;
	local VMDSkillMapTalentGem TG;
	local VMDSkillMapJumpGem JG;
	
	if ( Super.ButtonActivated( buttonPressed ) )
		return True;
	
	bHandled = True;
	
	SG = VMDSkillMapSkillGem(ButtonPressed);
	TG = VMDSkillMapTalentGem(ButtonPressed);
	JG = VMDSkillMapJumpGem(ButtonPressed);
	if (SG != None)
	{
		if ((SG.CurSkillLevel < 3) && (VMP.SkillPointsTotal-VMP.SkillPointsSpent >= SG.NextLevelCost))
		{
			SelectedSkillGem = SG;
			ConfirmWithMessageBox(CB_BuySkill);
		}
		else
		{
			PlayRejectUpgradeSound();
		}
	}
	else if (TG != None)
	{
		if ((TG.TalentPointsLeft[0] >= TG.PointsCost) && (TG.LastState == 1) && (TG.SkillRequirements[0] != None))
		{
			SelectedTalentGem = TG;
			ConfirmWithMessageBox(CB_BuyPrimary);
		}
		else
		{
			PlayRejectUpgradeSound();
		}
	}
	else if (JG != None)
	{
		NavigatedX = JG.JumpX;
		NavigatedY = JG.JumpY;
		UpdateTreePositions();
	}
	else
	{
		switch( buttonPressed )
		{
			default:
				bHandled = False;
			break;
		}
	}
	
	return bHandled;
}

function AttemptAlternatePurchase(VMDSkillMapTalentGem TG)
{
	if ((TG.TalentPointsLeft[1] >= TG.PointsCost) && (TG.LastState == 1) && (TG.SkillRequirements[1] != None))
	{
		SelectedTalentGem = TG;
		ConfirmWithMessageBox(CB_BuySecondary);
	}
	else
	{
		PlayRejectUpgradeSound();
	}
}

function AttemptComboPurchase(VMDSkillMapTalentGem TG)
{
	if ((TG.TalentPointsLeft[0] >= 1) && (TG.TalentPointsLeft[1] >= 1) && (TG.LastState == 1) && (TG.SkillRequirements[0] != None) && (TG.SkillRequirements[1] != None) && (TG.PointsCost == 2))
	{
		SelectedTalentGem = TG;
		ConfirmWithMessageBox(CB_BuyCombo);
	}
	else
	{
		PlayRejectUpgradeSound();
	}
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	//Fail condition #1: No player or no UI. Yikes.
	if (VMP == None) return;
	
	UpdateInfo();
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

function UpdateInfo()
{
	StyleChanged();
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
 	return Super.VirtualKeyPressed(key, bRepeat);
}

// ----------------------------------------------------------------------
// Message Box.
// ----------------------------------------------------------------------

function ConfirmWithMessageBox(EConfirmBoxModes Avenue)
{
	local MenuUIMessageBoxWindow TBox;
	
	if ((SelectedSkillGem == None) && (SelectedTalentGem == None)) return;
	
	switch(Avenue)
	{
		case CB_None:
		break;
		case CB_BuySkill:
			if (SelectedSkillGem != None)
			{
				ConfirmBoxMode = Avenue;
				TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SelectedSkillGem.SkillName, SelectedSkillGem.NextLevelCost), 0, False, Self);
			}
		break;
		case CB_BuyPrimary:
			if (SelectedTalentGem != None)
			{
				ConfirmBoxMode = Avenue;
				TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SelectedTalentGem.SkillRequirementNames[0], SelectedTalentGem.PointsCost), 0, False, Self);
			}
		break;
		case CB_BuySecondary:
			if (SelectedTalentGem != None)
			{
				ConfirmBoxMode = Avenue;
				TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SelectedTalentGem.SkillRequirementNames[1], SelectedTalentGem.PointsCost), 0, False, Self);
			}
		break;
		case CB_BuyCombo:
			if (SelectedTalentGem != None)
			{
				ConfirmBoxMode = Avenue;
				TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SelectedTalentGem.SkillRequirementNames[0], SelectedTalentGem.SkillRequirementNames[1]), 0, False, Self);
			}
		break;
	}
	
	if (TBox != None)
	{
		ForceMessageBoxColors(TBox);
	}
}

event bool BoxOptionSelected(Window button, int buttonNumber)
{
	// Destroy the msgbox!  
	root.PopWindow();
	
	switch(ConfirmBoxMode)
	{
		case CB_None:
		break;
		
		case CB_BuySkill:
			if (ButtonNumber == 0)
			{
				if (SelectedSkillGem != None)
				{
					SelectedSkillGem.RelSkill.IncLevel();
					PlaySkillUpgradeSound();
				}
				SelectedSkillGem = None;
				UpdatePointsLeft();
			}
		break;
		
		case CB_BuyPrimary:
			if (ButtonNumber == 0)
			{
				if (SelectedTalentGem != None)
				{
					VMP.BuySkillAugment(SelectedTalentGem.TalentID);
					PlaySkillUpgradeSound();
				}
				SelectedTalentGem = None;
				UpdatePointsLeft();
			}
		break;
		case CB_BuySecondary:
			if (ButtonNumber == 0)
			{
				if (SelectedTalentGem != None)
				{
					VMP.BuySkillAugment(SelectedTalentGem.TalentID, true);
					PlaySkillUpgradeSound();
				}
				SelectedTalentGem = None;
				UpdatePointsLeft();
			}
		break;
		case CB_BuyCombo:
			if (ButtonNumber == 0)
			{
				if (SelectedTalentGem != None)
				{
					VMP.BuySkillAugment(SelectedTalentGem.TalentID,, true);
					PlaySkillUpgradeSound();
				}
				SelectedTalentGem = None;
				UpdatePointsLeft();
			}
		break;
	}
	
	ConfirmBoxMode = CB_None;
	return true;
}

function ForceMessageBoxColors(MenuUIMessageBoxWindow W)
{
	local ColorTheme theme;
	local Color ColCursor;
	
	if (W == None) return;
	if (Player == None) Player = DeusExPlayer(GetPlayerPawn());
	if (Player == None) return;
	
	Theme = player.ThemeManager.GetCurrentHUDColorTheme();
	
	colCursor = theme.GetColorFromName('HUDColor_Cursor');
	W.SetDefaultCursor(Texture'DeusExCursor2', Texture'DeusExCursor2_Shadow', 32, 32, colCursor);
	
	if (W.WinTitle != None)
	{
		W.WinTitle.ColTitle = theme.GetColorFromName('HUDColor_ButtonFace');
		W.WinTitle.ColTitleText = theme.GetColorFromName('HUDColor_TitleText');
		W.WinTitle.ColBubble = theme.GetColorFromName('HUDColor_Background');
	}
	if (W.WinClient != None)
	{
		W.WinClient.ColBackground = theme.GetColorFromName('HUDColor_Background');
	}
	
	if (W.BtnYes != None) ForceActionButtonColors(W.BtnYes);
	if (W.BtnNo != None) ForceActionButtonColors(W.BtnNo);
	if (W.BtnOK != None) ForceActionButtonColors(W.BtnOK);
	
	if (W.WinText != None) ForceHeaderWindowColors(W.WinText);
}

function ForceActionButtonColors(MenuUIActionButtonWindow W)
{
	local ColorTheme theme;
	
	if (W == None) return;
	if (Player == None) Player = DeusExPlayer(GetPlayerPawn());
	if (Player == None) return;
	
	Theme = player.ThemeManager.GetCurrentHUDColorTheme();
	
	W.colButtonFace = theme.GetColorFromName('HUDColor_ButtonFace');
	W.colText[0]    = theme.GetColorFromName('HUDColor_ButtonTextNormal');
	W.colText[1]    = theme.GetColorFromName('HUDColor_ButtonTextFocus');
	W.colText[2]    = W.colText[1];
	W.colText[3]    = theme.GetColorFromName('HUDColor_ButtonTextDisabled');
}

function ForceHeaderWindowColors(MenuUIHeaderWindow W)
{
	local ColorTheme theme;
	
	if (W == None) return;
	if (Player == None) Player = DeusExPlayer(GetPlayerPawn());
	if (Player == None) return;
	
	Theme = player.ThemeManager.GetCurrentHUDColorTheme();
	
	W.ColLabel = Theme.GetColorFromName('HUDColor_ListText');
	W.SetTextColor(W.ColLabel);
}

// ----------------------------------------------------------------------
// Latent updates.
// ----------------------------------------------------------------------

event Tick(float DT)
{
	local float CurX, CurY;
	local bool bUpdateTreePos;
	
	if (Root.IsKeyDown(IK_A) || Root.IsKeydown(IK_Left))
	{
		NavigatedX = Clamp(NavigatedX + 8, GetNavigateFloorX(), GetNavigateCeilingX());
		bUpdateTreePos = true;
	}
	else if (Root.IsKeyDown(IK_D) || Root.IsKeydown(IK_Right))
	{
		NavigatedX = Clamp(NavigatedX - 8, GetNavigateFloorX(), GetNavigateCeilingX());
		bUpdateTreePos = true;
	}
	if (Root.IsKeyDown(IK_W) || Root.IsKeydown(IK_Up))
	{
		NavigatedY = Clamp(NavigatedY + 8, GetNavigateFloorY(), GetNavigateCeilingY());
		bUpdateTreePos = true;
	}
	else if (Root.IsKeyDown(IK_S) || Root.IsKeydown(IK_Down))
	{
		NavigatedY = Clamp(NavigatedY - 8, GetNavigateFloorY(), GetNavigateCeilingY());
		bUpdateTreePos = true;
	}
	
	//Update shit, if changed.
	if (bUpdateTreePos)
	{
		UpdateTreePositions();
	}
	
	TimeSinceLastUpdate += DT;
	if (TimeSinceLastUpdate >= 0.5)
	{
        	TimeSinceLastUpdate = 0;
		UpdateTreePositions();
	}
	
	UpdateHoverTip(HoverTarget);
	
	GetCursorPos(CurX, CurY);
	
	FalseMouseMoved(CurX, CurY);
	
	//Lol. No parent tick. Right.
	//Super.Tick(DT);
	
	if (SkillFlashUpdateTimer < 1.0)
	{
		SkillFlashUpdateTimer += DT;
	}
	else
	{
		ToggleSkillGemFlash();
		SkillFlashUpdateTimer = 0.0;
	}
}

//Floor acts as ceiling. Higher values limit us, lower values expand how far right we can look.
//Negative values.
function float GetNavigateFloorX()
{
	local int Ret, THack;
	
	THack = 0;
	Ret = (NavigateFloorX+THack)*ZoomInFactor;
	Ret -= THack / ZoomInFactor;
	
	return Ret;
}

//Floor acts as ceiling. Higher values limit us, lower values expand how far down we can look.
//Negative values.
function float GetNavigateFloorY()
{
	local int Ret, THack;
	
	THack = -128;
	Ret = (NavigateFloorY-THack)*ZoomInFactor;
	Ret += THack / ZoomInFactor;
	
	return Ret;
}

//Ceiling acts as floor. Lower values limit us, higher values expand how far left we can look.
//Positive values.
function float GetNavigateCeilingX()
{
	local int Ret, THack;
	
	THack = 0;
	Ret = (NavigateCeilingX-THack)*ZoomInFactor;
	Ret += THack / ZoomInFactor;
	
	return Ret;
}

//Ceiling acts as floor. Lower values limit us, higher values expand how far up we can look.
//Positive values.
function float GetNavigateCeilingY()
{
	local int Ret, THack;
	
	THack = 0;
	Ret = (NavigateCeilingY - THack)*ZoomInFactor;
	Ret += THack / ZoomInFactor;
	
	return Ret;
}

function ToggleSkillGemFlash()
{
	local int i;
	
	for (i=0; i<ArrayCount(SkillGems); i++)
	{
		if (SkillGems[i] != None)
		{
			SkillGems[i].TogglePointsLeftColor();
		}
	}
}

function UpdateHoverTip(Window HT)
{
	local VMDSkillMapSkillGem SG;
	local VMDSkillMapTalentGem TG;
	local VMDSkillMapJumpGem JG;
	local float CurX, CurY;
	local int MinWidth, MaxWidth, SugWidth;
	
	local string RenderString;
	local bool bAlert;
	
	GetCursorPos(CurX, CurY);
	if (DragInterfaces[0] != None)
	{
		HoverTip.SetPos(CurX+HoverTipOff.X, CurY+HoverTipOff.Y);
	}
	//MouseTip.SetPos(MouseTipPos.X+9999, MouseTipPos.Y);
	MouseTip.SetPos(MouseTipPos.X, MouseTipPos.Y);
	MouseTip.SetNote(TipMapControls, false);
	
	MinWidth = 256;
	MaxWidth = 256;
	SugWidth = 256;
	
	SG = VMDSkillMapSkillGem(HT);
	TG = VMDSkillMapTalentGem(HT);
	JG = VMDSkillMapJumpGem(HT);
	if (SG != None)
	{
		RenderString = SG.HoverTip;
		bAlert = SG.bHoverAlert;
		
		HoverTip.SetNote(RenderString, bAlert);
		if (RenderString != "")
		{
			MouseTip.SetPos(MouseTipPos.X, MouseTipPos.Y);
			MouseTip.SetNote(TipSkillGemControls, false);
		}
		
		MaxWidth = 248;
	}
	else if (TG != None)
	{
		RenderString = TG.HoverTip;
		bAlert = TG.bHoverAlert;
		
		HoverTip.SetNote(RenderString, bAlert);
		if (RenderString != "")
		{
			MouseTip.SetPos(MouseTipPos.X, MouseTipPos.Y);
			if (TG.SkillRequirements[1] != None)
			{
				if (TG.PointsCost == 2)
				{
					MouseTip.SetNote(TipTalentGemControlsTriple, false);
				}
				else
				{
					MouseTip.SetNote(TipTalentGemControlsDouble, false);
				}
			}
			else
			{
				MouseTip.SetNote(TipTalentGemControlsSingle, false);
			}
		}
		
		MaxWidth = 228;
	}
	else if (JG != None)
	{
		RenderString = RenderString$JG.HoverTip;
		
		bAlert = JG.bHoverAlert;
		
		HoverTip.SetNote(RenderString, bAlert);
		if (RenderString != "")
		{
			MouseTip.SetPos(MouseTipPos.X, MouseTipPos.Y);
			MouseTip.SetNote(TipJumpGemControls, false);
		}
		MaxWidth = 152;
	}
	
	if (RenderString == "")
	{
		HoverTip.SetPos(9999, 9999);
		HoverTip.SetNote("", false);
	}
	
	MinWidth = MaxWidth*0.5;
	SugWidth = Clamp(594-CurX, MinWidth, MaxWidth);
	HoverTip.SetWidth(SugWidth);
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

// ----------------------------------------------------------------------
// Drag Stuff.
// ----------------------------------------------------------------------

function UpdateDragMouse(float newX, float newY)
{
	NewX /= ZoomInFactor;
	NewY /= ZoomInFactor;
	NavigatedX = FClamp(NavigatedX + NewX, GetNavigateFloorX(), GetNavigateCeilingX());
	NavigatedY = FClamp(NavigatedY + NewY, GetNavigateFloorY(), GetNavigateCeilingY());
}

event FalseMouseMoved(float newX, float newY)
{
	local Float ModX, ModY, ModMax;
	
	if (NewX != DragPosX || NewY != DragPosY)
	{
		if (CurDragInterface != None)
		{
			ModX = NewX-DragPosX;
			ModY = NewY-DragPosY;
			ModMax = Max(Abs(ModX), Abs(ModY));
			
			UpdateDragMouse(ModX, ModY);
			if (TimeSinceLastUpdate < 0.4)
			{
				//TWEAK! Update between 3 and 25 times per second, based on how much movement we're getting.
				TimeSinceLastUpdate = 0.4 + FClamp(ModMax / 30, 0.01, 0.1);
			}
		}
		DragPosX = NewX;
		DragPosY = NewY;
		
		if (HoverTicks < 2)
		{
			HoverTicks++;
		}
		else
		{
			HoverTarget = None;
		}
	}
}

function StartButtonDrag(ButtonWindow newDragButton)
{
	local float CurX, CurY;
	
	if ((CurDragInterface == None) && (NewDragButton.IsA('VMDSkillMapInterfaceWindow')))
	{
		CurDragInterface = VMDSkillMapInterfaceWindow(NewDragButton);
		GetCursorPos(CurX, CurY);
		DragPosX = CurX;
		DragPosY = CurY;
		
		bDragging  = True;
	}
}

function FinishButtonDrag()
{
  	EndDragMode();
}

function EndDragMode()
{
	CurDragInterface = None;
}

event bool RawMouseButtonPressed(float pointX, float pointY, EInputKey button, EInputState iState)
{
	local bool bHandled;
	
	bHandled = True;
	
	switch(Button)
	{
		//MADDERS: Zoom the map with mousewheel.
		case IK_MouseWheelUp:
			if (IState == IST_Press) AttemptMapZoomIn();
		break;
		case IK_MouseWheelDown:
			if (IState == IST_Press) AttemptMapZoomOut();
		break;
		
		default:
			bHandled = False;
		break;
	}
	
	return bHandled;
}

function AttemptMapZoomIn()
{
	if (ZoomInFactor < GlobalZoomCap)
	{
		ZoomInFactor = FClamp(ZoomInFactor+GlobalZoomRate, GlobalZoomFloor, GlobalZoomCap);
		HoverTarget = None;
		HoverTicks = 0;
		UpdateMapZoom();
	}
}

function AttemptMapZoomOut()
{
	if (ZoomInFactor > GlobalZoomFloor)
	{
		ZoomInFactor = FClamp(ZoomInFactor-GlobalZoomRate, GlobalZoomFloor, GlobalZoomCap);
		HoverTarget = None;
		HoverTicks = 0;
		UpdateMapZoom();
	}
}

function UpdateMapZoom()
{
	local int i;
	
	for(i=0; i<ArrayCount(SkillGems); i++)
	{
		if (SkillGems[i] != None)
		{
			SkillGems[i].UpdateZoomLevel();
		}
	}
	for (i=0; i<ArrayCount(SkillGemBackdrops); i++)
	{
		if (SkillGemBackdrops[i] != None)
		{
			SkillGemBackdrops[i].UpdateZoomLevel();
		}
	}
	for (i=0; i<ArrayCount(TalentGems); i++)
	{
		if (TalentGems[i] != None)
		{
			TalentGems[i].UpdateZoomLevel();
		}
	}
	for (i=0; i<ArrayCount(MapBranchingFoundation); i++)
	{
		if (MapBranchingFoundation[i] != None)
		{
			MapBranchingFoundation[i].UpdateZoomLevel();
		}
	}
	for (i=0; i<ArrayCount(MapBranching); i++)
	{
		if (MapBranching[i] != None)
		{
			MapBranching[i].UpdateZoomLevel();
		}
	}
	UpdateDragMouse(0, 0);
	UpdateTreePositions();
}

// ----------------------------------------------------------------------
// Sound stuff.
// ----------------------------------------------------------------------

function PlaySkillUpgradeSound()
{
	if (VMP != None)
	{
		//VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 2.0);
		VMP.PlaySound(sound'Menu_BuySkills', SLOT_None,,, 256, 1.65);
	}
}

function PlayRejectUpgradeSound()
{
	if (VMP != None)
	{
		VMP.PlaySound(sound'Menu_Focus', SLOT_None,,, 256, 0.7);
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

function bool ShouldSpawnTalentGem(name CheckID)
{
	if (!VMP.bCraftingSystemEnabled)
	{
		switch(CheckID)
		{
			case 'MEDICINECRAFTING':
			case 'MEDICINECOMBATDRUGS':
			case 'ELECTRONICSCRAFTING':
			case 'ELECTRONICSDRONES':
			case 'ELECTRONICSDRONEARMOR':
			case 'TAGTEAMMINITURRET':
			case 'TAGTEAMSKILLWARE':
			case 'TAGTEAMLITEHACK':
			case 'TAGTEAMMELEESKILLWARE':
			case 'TAGTEAMMEDICALSYRINGE':
				return false;
			break;
		}
	}
	switch(VMP.SelectedCampaign)
	{
		case "CARONE":
		case "NIHILUM":
		case "REDSUN":
		case "ZODIAC":
			switch(CheckID)
			{
				case 'TAGTEAMLITEHACK':
					return true;
					//return false;
				break;
			}
		break;
	}
	
	return true;
}

defaultproperties
{
     ClientWidth=768
     ClientHeight=495
     clientOffsetX=0
     clientOffsetY=17
     clientTextures(0)=Texture'SkillAugmentsBackground_1'
     clientTextures(1)=Texture'SkillAugmentsBackground_2'
     clientTextures(2)=Texture'SkillAugmentsBackground_3'
     clientTextures(3)=Texture'SkillAugmentsBackground_4'
     clientTextures(4)=Texture'SkillAugmentsBackground_5'
     clientTextures(5)=Texture'SkillAugmentsBackground_6'
     clientTextureRows=2
     clientTextureCols=3
     clientBorderTextureRows=2
     clientBorderTextureCols=3
     
     SkillTalentsTitleText="Skills & Talents"
     SkillPointsLeftText="%d Skill Point(s) Remaining"
     SkillPointsLeftLabelPos=(X=439,Y=52)
     
     SkillGemBackdropOffset(0)=(X=19,Y=19)
     SkillGemBackdropOffset(1)=(X=11,Y=11)
     SkillGemBackdropOffset(2)=(X=6,Y=6)
     
     JumpGemStartPos=(X=12,Y=20)
     JumpGemOffset=(X=0,Y=32)
     
     MouseTipPos=(X=51,Y=442)
     HoverTipOff=(X=28,Y=0)
     TipSpecialized="(Resonating)"
     TipTalentPointsLeft="%d talent point(s) available"
     TipCanUpgradeFor="Can upgrade for %d point(s)"
     TipLevel="Level %d"
     TipSkillPointCost="(%d skill points)"
     TipCurLevelDesc="Current level:"
     TipNextLevelDesc="Next level:"
     TipSkillGemControls="LMB: Purchase"
     TipTalentGemControlsTriple="LMB: Unlock | RMB: Unlock With Secondary | MMB: Unlock With Both"
     TipTalentGemControlsDouble="LMB: Unlock | RMB: Unlock With Secondary"
     TipTalentGemControlsSingle="LMB: Unlock"
     TipJumpGemControls="LMB: Jump To"
     TipMapControls="WASD or Click & Drag: Navigate | Mouse Wheel: Zoom In/Out"
     
     MessageBoxTitles(0)="ERR"
     MessageBoxBodies(0)="Whoops. Report this as a bug, I guess."
     MessageBoxTitles(1)="Confirm"
     MessageBoxBodies(1)="Upgrade %s for %d skill point(s)?"
     MessageBoxTitles(2)="Confirm"
     MessageBoxBodies(2)="Buy with primary skill %s for %d point(s)?"
     MessageBoxTitles(3)="Confirm"
     MessageBoxBodies(3)="Buy with secondary skill %s for %d point(s)?"
     MessageBoxTitles(4)="Confirm"
     MessageBoxBodies(4)="Buy with both %s and %s for 1 point each?"
     
     ZoomInFactor=0.750000
     GlobalZoomRate=0.250000
     GlobalZoomFloor=0.500000
     GlobalZoomCap=1.000000
     NavigateFloorX=-1000
     NavigateCeilingX=0
     NavigateFloorY=-1700
     NavigateCeilingY=0
     InterfacePos(0)=(X=51,Y=20)
     InterfacePos(1)=(X=307,Y=20)
     InterfacePos(2)=(X=563,Y=20)
     InterfacePos(3)=(X=51,Y=276)
     InterfacePos(4)=(X=307,Y=276)
     InterfacePos(5)=(X=563,Y=276)
     InterfaceSize(0)=(X=576,Y=389) //HACK! Encapsulate everything.
     InterfaceSize(1)=(X=256,Y=256)
     InterfaceSize(2)=(X=64,Y=256)
     InterfaceSize(3)=(X=256,Y=133)
     InterfaceSize(4)=(X=256,Y=133)
     InterfaceSize(5)=(X=64,Y=133)
     InterfaceTex(0)=Texture'VMDAssets.SkillMapInterface_1'
     InterfaceTex(1)=Texture'VMDAssets.SkillMapInterface_1'
     InterfaceTex(2)=Texture'VMDAssets.SkillMapInterface_3'
     InterfaceTex(3)=Texture'VMDAssets.SkillMapInterface_4'
     InterfaceTex(4)=Texture'VMDAssets.SkillMapInterface_4'
     InterfaceTex(5)=Texture'VMDAssets.SkillMapInterface_6'
}
