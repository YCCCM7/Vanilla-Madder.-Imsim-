//=============================================================================
// VMDPersonaScreenSkillAugments
//=============================================================================
class VMDPersonaScreenSkillAugments extends PersonaScreenBaseWindow;

enum EConfirmBoxModes
{
	CB_None,
	CB_BuyPrimary,
	CB_BuySecondary,
	CB_BuyCombo,
};
var EConfirmBoxModes ConfirmBoxMode;
var localized string MessageBoxTitles[4], MessageBoxBodies[4];

var PersonaActionButtonWindow btnBuy, btnBuyAlt, btnBuyCombo;

var localized String SkillAugmentsTitleText, SkillAugmentBuyText, SkillAugmentBuyAltText, SkillAugmentBuyComboText,
						FreeAugmentBuyText, FreeAugmentBuyAltText, SkillAugmentOwnedSnippet;
var localized string SkillAugmentPointsLeftLabel;

var localized String RequirementsLabel, RequirementsLabelPlural, CostLabel, CostLabelFree, MsgSelectAnAugment;

//MADDERS: All this junk.
var int PageNumber, MinPage, MaxPage;
var VMDSkillAugmentPageFlipper PageBack, PageForward;
var VMDBufferPlayer VMP;

var VMDSkillAugmentGem GemList[80], SelectedGem;

var VMDSkillAugmentTreeBranch TreeBits[32];
var int TreeOwners[32];

var PersonaTitleTextWindow PageLabel, TreeText[2], TreeGapText;
var PersonaInfoWindow winInfo;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	PersonaNavBarWindow(winNavBar).btnSkills.SetSensitivity(False);
	CreateTrees();
	
	EnableButtons();
}

// ----------------------------------------------------------------------
// CreateTrees()
// ----------------------------------------------------------------------

function CreateTrees()
{
	local int SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	PageBack = VMDSkillAugmentPageFlipper(winClient.NewChild(class'VMDSkillAugmentPageFlipper'));
	PageBack.SetPos(15, 174);
	PageBack.SetSkillPage(False, False, 0);
	PageForward = VMDSkillAugmentPageFlipper(winClient.NewChild(class'VMDSkillAugmentPageFlipper'));
	PageForward.SetPos(575, 174);
	PageForward.SetSkillPage(True, False, 0);
	
	PageLabel = PersonaTitleTextWindow(NewChild(class'PersonaTitleTextWindow'));
	PageLabel.SetPos(19, 70);
	
	TreeText[0] = PersonaTitleTextWindow(NewChild(class'PersonaTitleTextWindow'));
	TreeText[0].SetPos(48, 80);
	TreeText[1] = PersonaTitleTextWindow(NewChild(class'PersonaTitleTextWindow'));
	TreeText[1].SetPos(480, 80);
	
	TreeGapText = PersonaTitleTextWindow(NewChild(class'PersonaTitleTextWindow'));
	TreeGapText.SetPos(264, 112);
	
	//1. Pistols.
	class'VMDStaticFunctions'.Static.CreatePistolsTree(Self, 0, 0, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//2. Rifles.
	class'VMDStaticFunctions'.Static.CreateRiflesTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//1/2. Firing Systems.
	class'VMDStaticFunctions'.Static.CreateFiringSystemsTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	
	//3. Heavy.
	class'VMDStaticFunctions'.Static.CreateHeavyTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//4. Demolition.
	class'VMDStaticFunctions'.Static.CreateDemolitionTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	
	//5. Low Tech.
	class'VMDStaticFunctions'.Static.CreateLowTechTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//6. Lockpicking.
	class'VMDStaticFunctions'.Static.CreateLockpickingTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//5/6. Burglar.
	class'VMDStaticFunctions'.Static.CreateBurglarTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	
	//7. Tech.
	class'VMDStaticFunctions'.Static.CreateTechTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//8. Computer.
	class'VMDStaticFunctions'.Static.CreateComputerTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//7/8. Hacking.
	
	//9. Fitness.
	class'VMDStaticFunctions'.Static.CreateFitnessTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//10. Tactical Gear.
	class'VMDStaticFunctions'.Static.CreateTacticalGearTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	//9/10. Swimming.
	
        //11. Medicine.
	class'VMDStaticFunctions'.Static.CreateMedicineTree(Self, SetupCount, SetupTreeCount, SetupOutCount, SetupOutTreeCount, RelevantCampString());
	SetupCount = SetupOutCount;
	SetupTreeCount = SetupOutTreeCount;
	
	FixGemPositions(SetupCount);
	FixTreePositions(SetupTreecount);
	UpdateTreeVisibility();
}

function SetGemList(int TArray, VMDSkillAugmentGem TGem)
{
	GemList[TArray] = TGem;
}

function SetSkillData(int TArray, Name CurSkillAugment, string TSAN, string TSAD, int TSALR, int TSSALR, int TPage)
{
	GemList[TArray].SetSkillData(CurSkillAugment, TSAN, TSAD, TSALR, TSSALR, TPage);
}

function SetSkillData2(int TArray, class<Skill> TSASR, class<Skill> TSSASR, string TNSTS)
{
	GemList[TArray].SetSkillData2(TSASR, TSSASR, TNSTS);
}

// ----------------------------------------------------------------------
// Position fixer functions. Blanket style. Don't worry.
// ----------------------------------------------------------------------

function FixGemPositions(int Count)
{
	local int i, TX, TY;
	
	for (i=0; i<Count; i++)
	{
		if (GemList[i] != None)
		{
			TX = class'VMDStaticFunctions'.Static.GetGemPosX(i);
			TY = class'VMDStaticFunctions'.Static.GetGemPosY(i);
			GemList[i].SetPos(TX, TY);
		}
	}
}

function FixTreePositions(int Count)
{
	local int i, TX, TY;
	
	for (i=0; i<Count; i++)
	{
		if (TreeBits[i] != None)
		{
			TX = class'VMDStaticFunctions'.Static.GetTreePosX(i);
			TY = class'VMDStaticFunctions'.Static.GetTreePosY(i);
			TreeBits[i].SetPos(TX, TY);
		}
	}
}

// ----------------------------------------------------------------------
// UpdateTreeLabels()
//
// Label based on page
// ----------------------------------------------------------------------

function UpdateTreeLabels()
{
	local string LabelAdd, SpecAdd, SpecAdd2;
	local int LabelPoints, TArray;
	
	local class<Skill> TS1, TS2;
	local string TL1, TL2, TGL;
	
	TS1 = class'VMDStaticFunctions'.Static.GetTreeSkill(PageNumber*2);
	TS2 = class'VMDStaticFunctions'.Static.GetTreeSkill(PageNumber*2+1);
	TL1 = class'VMDStaticFunctions'.Static.GetTreeLabel(PageNumber*2);
	TL2 = class'VMDStaticFunctions'.Static.GetTreeLabel(PageNumber*2+1);
	TGL = class'VMDStaticFunctions'.Static.GetTreeGapLabel(PageNumber);
	if (VMP.IsSpecializedInSkill(TS1))
	{
		SpecAdd = "|n(Resonating)";
	}
	if (VMP.IsSpecializedInSkill(TS2))
	{
		SpecAdd2 = "|n(Resonating)";
	}
	
	TreeText[0].SetText("");
	TreeText[1].SetText("");
	if (TS1 != None)
	{
		TArray = VMP.SkillArrayOf(TS1);
		LabelPoints = VMP.SkillAugmentManager.SkillAugmentPointsLeft[TArray] - VMP.SkillAugmentManager.SkillAugmentPointsSpent[TArray];
		LabelAdd = SprintF(SkillAugmentPointsLeftLabel, LabelPoints);
		TreeText[0].SetText(TL1$"|n"$LabelAdd$SpecAdd);
	}
	if (TS2 != None)
	{
		TArray = VMP.SkillArrayOf(TS2);
		LabelPoints = VMP.SkillAugmentManager.SkillAugmentPointsLeft[TArray] - VMP.SkillAugmentManager.SkillAugmentPointsSpent[TArray];
		LabelAdd = SprintF(SkillAugmentPointsLeftLabel, LabelPoints);
		TreeText[1].SetText(TL2$"|n"$LabelAdd$SpecAdd2);
	}
	TreeGapText.SetText(TGL);
}

// ----------------------------------------------------------------------
// UpdateTreeVisibility()
//
// Hide/show appropriately
// ----------------------------------------------------------------------

function UpdateTreeVisibility()
{
	local int i, SkillAugmentArray;
	
	for (i=0; i<ArrayCount(GemList); i++)
	{
		if (GemList[i] != None)
		{
			SkillAugmentArray = VMP.SkillAugmentArrayOf(GemList[i].SkillAugmentID);
			
			if (SelectedGem == GemList[i])
			{
				GemList[i].UpdateSkillIcons(3);
			}
			else if (!VMP.CanBuySkillAugment(SkillAugmentArray,,,true))
			{
				GemList[i].UpdateSkillIcons(0);
			}
			else if (VMP.HasSkillAugment(GemList[i].SkillAugmentID))
			{
				GemList[i].UpdateSkillIcons(2);
			}
			else GemList[i].UpdateSkillIcons(1);
			
			GemList[i].UpdateCheckOverlay(VMP.HasSkillAugment(GemList[i].SkillAugmentID));
			GemList[i].Show(GemList[i].PageNumber == PageNumber);
		}
	}
	for (i=0; i<ArrayCount(TreeBits); i++)
	{
		if (TreeBits[i] != None)
		{
			//NASTY fucking hack for the freebie exception.
			if (TreeOwners[i] == -2)
			{
				if (VMP.HasSkillAugment(GemList[10].SkillAugmentID) || VMP.HasSkillAugment(GemList[11].SkillAugmentID)) TreeBits[i].UpdateTexture(true);
				else TreeBits[i].UpdateTexture(false);
			}
			else
			{
				if (VMP.HasSkillAugment(GemList[TreeOwners[i]].SkillAugmentID)) TreeBits[i].UpdateTexture(true);
				else TreeBits[i].UpdateTexture(false);
			}
			TreeBits[i].Show(TreeBits[i].PageNumber == PageNumber);
		}
	}
	UpdateTreeLabels();
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	if ( Super.ButtonActivated( buttonPressed ) )
		return True;
	
	bHandled = True;
	
	if (VMDSkillAugmentGem(buttonPressed) != None)
	{
		SelectedGem = VMDSkillAugmentGem(ButtonPressed);
		EnableButtons();
	}
	else
	{
		switch( buttonPressed )
		{
			case PageBack:
				if (PageNumber > MinPage)
				{
					SelectedGem = None;
					PageNumber--;
					EnableButtons();
				}
				else
				{
					SelectedGem = None;
					if (PersonaScreenBaseWindow(GetParent()) != None)
					{
						PersonaScreenBaseWindow(GetParent()).SaveSettings();
					}
					root.InvokeUIScreen(class'PersonaScreenSkills');
				}
			break;
			case PageForward:
				SelectedGem = None;
				PageNumber = Clamp(PageNumber+1, MinPage, MaxPage);
				EnableButtons();
			break;
			case btnBuy:
				if (SelectedGem != None)
				{
					ConfirmWithMessageBox(CB_BuyPrimary);
					//VMP.BuySkillAugment(SelectedGem.SkillAugmentID);
					EnableButtons();
				}
			break;
			case btnBuyAlt:
				if (SelectedGem != None)
				{
					ConfirmWithMessageBox(CB_BuySecondary);
					//VMP.BuySkillAugment(SelectedGem.SkillAugmentID, true);
					EnableButtons();
				}
			break;
			case btnBuyCombo:
				if (SelectedGem != None)
				{
					ConfirmWithMessageBox(CB_BuyCombo);
					//VMP.BuySkillAugment(SelectedGem.SkillAugmentID,, true);
					EnableButtons();
				}
			break;
			
			default:
				bHandled = False;
				break;
		}
	}
	
	return bHandled;
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	CreateTitleWindow(9, 5, SkillAugmentsTitleText);
	CreateInfoWindow();
	CreateButtons();
}

// ----------------------------------------------------------------------
// CreateInfoWindow()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
	winInfo = PersonaInfoWindow(winClient.NewChild(Class'PersonaInfoWindow'));
	winInfo.SetPos(32, 292);
	winInfo.SetSize(560, 128);
}

// ----------------------------------------------------------------------
// CreateButtons()
// ----------------------------------------------------------------------

function CreateButtons()
{
	local PersonaButtonBarWindow winActionButtons;
	
	winActionButtons = PersonaButtonBarWindow(winClient.NewChild(Class'PersonaButtonBarWindow'));
	winActionButtons.SetPos(10, 411);
	winActionButtons.SetWidth(526);
	
	btnBuyCombo = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnBuyCombo.SetButtonText("---");
	btnBuyAlt = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnBuyAlt.SetButtonText("---");
	btnBuy = PersonaActionButtonWindow(winActionButtons.NewChild(Class'PersonaActionButtonWindow'));
	btnBuy.SetButtonText("---");
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	local int SkillAugmentLevel, SkillAugmentArray, TCost;
	local class<Skill> SkillAugmentSkill, SecondarySkillAugmentSkill;
	local SkillManager SM;
	local string SkillName, SecondarySkillName;
	local Skill TSkill;
	local bool FlagBuyable;
	
	//Fail condition #1: No player or no UI. Yikes.
	if ((VMP == None) || (BtnBuy == None) || (BtnBuyAlt == None) || (BtnBuyCombo == None) || (PageLabel == None)) return;
	
	SM = VMP.SkillSystem;
	//Fail condition #2: Null SkillAugment or skill manager.
	if ((SM == None) || (SkillAugmentArray < 0) || (VMP.SkillAugmentManager == None)) return;
	
	//Run this twice, in case we get backed out early.
	btnBuy.SetButtonText("---");
	btnBuy.SetSensitivity(false);
	btnBuyAlt.SetButtonText("---");
	btnBuyAlt.SetSensitivity(false);
	btnBuyCombo.SetButtonText("---");
	btnBuyCombo.SetSensitivity(false);
	
	PageLabel.SetText("Page "$PageNumber+1);
	UpdateTreeVisibility();
	UpdateInfo();
	
	if (SelectedGem != None)
	{
		SkillAugmentArray = VMP.SkillAugmentArrayOf(SelectedGem.SkillAugmentID);
		
		SkillAugmentLevel = VMP.SkillAugmentManager.SkillAugmentLevel[SkillAugmentArray];
		SkillAugmentSkill = VMP.GetSkillAugmentSkillRequired(SkillAugmentArray);
		SecondarySkillAugmentSkill = VMP.GetSecondarySkillAugmentSkillRequired(SkillAugmentArray);
		
		TSkill = SM.GetSkillFromClass(SkillAugmentSkill);
		if (TSkill == None) return;
		SkillName = TSkill.SkillName;
		
		FlagBuyable = (VMP.CanBuySkillAugment(SkillAugmentArray));
		if ((!FlagBuyable) && (SecondarySkillAugmentSkill != None))
		{
			FlagBuyable = (VMP.CanBuySkillAugment(SkillAugmentArray, true) || VMP.CanBuySkillAugment(SkillAugmentArray,, true));
		}
		if ((FlagBuyable) && (VMP.HasSkillAugment(SelectedGem.SkillAugmentID))) FlagBuyable = false;
		
		//Fail condition #4: We can't afford it.
		if (!FlagBuyable) return;
		
		TCost = GetSkillAugmentCost(SelectedGem);
		if (TCost > 0) btnBuy.SetButtonText(SkillAugmentBuyText$SkillName);
		else btnBuy.SetButtonText(FreeAugmentBuyText);
		
		if (VMP.CanBuySkillAugment(SkillAugmentArray))
		{
			btnBuy.SetSensitivity(true);
		}
		if (SecondarySkillAugmentSkill != None)
		{
			TSkill = SM.GetSkillFromClass(SecondarySkillAugmentSkill);
			
			if (TSkill != None)
			{
				SecondarySkillName = TSkill.SkillName;
				
				if (TCost > 0) btnBuyAlt.SetButtonText(SkillAugmentBuyAltText$SecondarySkillName);
				else btnBuyAlt.SetButtonText(FreeAugmentBuyAltText);
				
				if (VMP.CanBuySkillAugment(SkillAugmentArray, true))
				{
					btnBuyAlt.SetSensitivity(true);
				}
				else
				{
						btnBuyAlt.SetSensitivity(false);
				}
				if ((SkillAugmentLevel == 2) && (VMP.CanBuySkillAugment(SkillAugmentArray,, true)))
				{
					btnBuyCombo.SetButtonText(SkillAugmentBuyComboText);
					btnBuyCombo.SetSensitivity(true);
				}
				else
				{
					btnBuyCombo.SetButtonText("---");
					btnBuyCombo.SetSensitivity(false);
				}
			}
		}
		else
		{
			btnBuyAlt.SetButtonText("---");
			btnBuyAlt.SetSensitivity(false);
			btnBuyCombo.SetButtonText("---");
			btnBuyCombo.SetSensitivity(false);
		}
	}
	else
	{
		btnBuyAlt.SetButtonText("---");
		btnBuyAlt.SetSensitivity(false);
		btnBuyCombo.SetSensitivity(false);
	}
	
	PageLabel.SetText("Page "$PageNumber+1);
	UpdateTreeVisibility();
	UpdateInfo();
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

function UpdateInfo()
{
	local string BuildStr[2];
	local string SprintBits[4];
	local int Cost;
	local bool bSpec, bSpec2;
	local string OwnedStr;
	
	winInfo.Clear();
	
	if (SelectedGem == None)
	{
		winInfo.SetTitle("---");
		winInfo.SetText(MsgSelectAnAugment);
	}
	else
	{
		if (FishSkill(SelectedGem) != None)
		{
			bSpec = VMP.IsSpecializedInSkill(SelectedGem.SkillType);
			SprintBits[0] = FishSkill(SelectedGem).SkillName;
			SprintBits[1] = FishSkill(SelectedGem).SkillLevelStrings[SelectedGem.SkillLevel - int(bSpec)];
			if (FishSkill(SelectedGem, true) != None)
			{
				if (SelectedGem.SecondarySkillType != None)
				{
					bSpec2 = VMP.IsSpecializedInSkill(SelectedGem.SecondarySkillType);
				}
				SprintBits[2] = FishSkill(SelectedGem, true).SkillName;
				SprintBits[3] = FishSkill(SelectedGem, true).SkillLevelStrings[SelectedGem.SecondarySkillLevel - int(bSpec2)];
				BuildStr[0] = SprintF(RequirementsLabelPlural, SprintBits[0], SprintBits[1], SprintBits[2], SprintBits[3]);
			}
			else
			{
				BuildStr[0] = SprintF(RequirementsLabel, SprintBits[0], SprintBits[1]);
			}
			Cost = GetSkillAugmentCost(SelectedGem);
			if (Cost == 0) BuildStr[1] = CostLabelFree;
			else BuildStr[1] = SprintF(CostLabel, Cost);
			
			BuildStr[0] = BuildStr[0]$BuildStr[1];
			BuildStr[0] = BuildStr[0]$SelectedGem.SkillAugmentDesc;
			
			if (VMP.HasSkillAugment(SelectedGem.SkillAugmentID)) OwnedStr = SkillAugmentOwnedSnippet;
			winInfo.SetTitle(SelectedGem.SkillAugmentName$OwnedStr);
			winInfo.SetText(BuildStr[0]);
		}
	}
	StyleChanged();
}

function Skill FishSkill(VMDSkillAugmentGem Gem, optional bool bSecondary)
{
	local Skill Ret;
	local class<Skill> S;
	local string Str;
	
	if (Gem == None) return None;
	
	S = Gem.SkillType;
	if (bSecondary) S = Gem.SecondarySkillType;
	
	if (S == None) return None;
	Ret = VMP.SkillSystem.GetSkillFromClass(S);
	
	return Ret;
}

function int GetSkillAugmentCost(VMDSkillAugmentGem Gem)
{
	local int Ret;
	
	Ret = Max(SelectedGem.SkillLevel, SelectedGem.SecondarySkillLevel);
	if ((Gem == GemList[10] || Gem == GemList[11]) && (!VMP.HasSkillAugment(GemList[10].SkillAugmentID)) && (!VMP.HasSkillAugment(GemList[11].SkillAugmentID)))
	{
		Ret = 0;
	}
	
	return Ret;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
 	if ((key == IK_1) && (BtnBuy.bIsSensitive))
	{
		ButtonActivated(BtnBuy);
		PlaySound(Sound'Menu_Press', 0.25);
	}
 	if ((key == IK_2) && (BtnBuyAlt.bIsSensitive))
	{
		ButtonActivated(BtnBuyAlt);
		PlaySound(Sound'Menu_Press', 0.25);
	}
 	if ((key == IK_3) && (BtnBuyCombo.bIsSensitive))
	{
		ButtonActivated(BtnBuyCombo);
		PlaySound(Sound'Menu_Press', 0.25);
	}
	
 	return Super.VirtualKeyPressed(key, bRepeat);
}

function ConfirmWithMessageBox(EConfirmBoxModes Avenue)
{
	local int SkillPrice;
	local string SkillNames[2];
	local MenuUIMessageBoxWindow TBox;
	
	if (SelectedGem == None) return;
	if (FishSkill(SelectedGem) == None) return;
	
	SkillNames[0] = FishSkill(SelectedGem).SkillName;
	if (FishSkill(SelectedGem, true) != None)
	{
		SkillNames[1] = FishSkill(SelectedGem, true).SkillName;
	}
	SkillPrice = GetSkillAugmentCost(SelectedGem);
	
	switch(Avenue)
	{
		case CB_None:
		break;
		case CB_BuyPrimary:
			ConfirmBoxMode = Avenue;
			TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SkillNames[0], SkillPrice), 0, False, Self);
		break;
		case CB_BuySecondary:
			ConfirmBoxMode = Avenue;
			TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SkillNames[1], SkillPrice), 0, False, Self);
		break;
		case CB_BuyCombo:
			ConfirmBoxMode = Avenue;
			TBox = Root.MessageBox(MessageBoxTitles[Avenue], SprintF(MessageBoxBodies[Avenue], SkillNames[0], SkillNames[1], SkillPrice), 0, False, Self);
		break;
	}
	
	if (TBox != None)
	{
		ForceMessageBoxColors(TBox);
	}
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

event bool BoxOptionSelected(Window button, int buttonNumber)
{
	// Destroy the msgbox!  
	root.PopWindow();
	
	switch(ConfirmBoxMode)
	{
		case CB_None:
		break;
		
		case CB_BuyPrimary:
			if (buttonNumber == 0)
			{
				if (SelectedGem != None)
				{
					VMP.BuySkillAugment(SelectedGem.SkillAugmentID);
					EnableButtons();
				}
			}
		break;
		case CB_BuySecondary:
			if (buttonNumber == 0)
			{
				if (SelectedGem != None)
				{
					VMP.BuySkillAugment(SelectedGem.SkillAugmentID, true);
					EnableButtons();
				}
			}
		break;
		case CB_BuyCombo:
			if (buttonNumber == 0)
			{
				if (SelectedGem != None)
				{
					VMP.BuySkillAugment(SelectedGem.SkillAugmentID,, true);
					EnableButtons();
				}
			}
		break;
	}
	
	ConfirmBoxMode = CB_None;
	return true;
}

function string RelevantCampString()
{
	if (IsBurden()) return "Burden";
	else if (IsCassandra()) return "Cassandra";
	return "Other";
}

function bool IsBurden()
{
	if ((VMP != None) && (VMP.DatalinkID ~= "Burden" || VMP.IsA('BurdenPeterKent')))
	{
		return true;
	}
	return false;
}

function bool IsCassandra()
{
	if ((VMP != None) && (VMP.DatalinkID ~= "Cassandra" || VMP.IsA('TCPPlayerCharolette')))
	{
		return true;
	}
	return false;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     MinPage=0
     MaxPage=5
     
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
     //clientBorderTextures(0)=Texture'DeusExUI.UserInterface.ConversationsBorder_1'
     //clientBorderTextures(1)=Texture'DeusExUI.UserInterface.ConversationsBorder_2'
     //clientBorderTextures(2)=Texture'DeusExUI.UserInterface.ConversationsBorder_3'
     //clientBorderTextures(3)=Texture'DeusExUI.UserInterface.ConversationsBorder_4'
     //clientBorderTextures(4)=Texture'DeusExUI.UserInterface.ConversationsBorder_5'
     //clientBorderTextures(5)=Texture'DeusExUI.UserInterface.ConversationsBorder_6'
     clientTextureRows=2
     clientTextureCols=3
     clientBorderTextureRows=2
     clientBorderTextureCols=3
     
     MessageBoxTitles(0)="ERR"
     MessageBoxBodies(0)="Whoops. Report this as a bug, I guess."
     MessageBoxTitles(1)="Confirm"
     MessageBoxBodies(1)="Buy with primary skill %s for %d point(s)?"
     MessageBoxTitles(2)="Confirm"
     MessageBoxBodies(2)="Buy with secondary skill %s for %d point(s)?"
     MessageBoxTitles(3)="Confirm"
     MessageBoxBodies(3)="Buy with both %s and %s for %d point(s) each?"
     
     SkillAugmentOwnedSnippet=" (OWNED)"
     SkillAugmentPointsLeftLabel="%d Point(s) Left"
     SkillAugmentBuyText="|&1. Buy W/ "
     SkillAugmentBuyAltText="|&2. Buy W/ "
     SkillAugmentBuyComboText="|&3. Buy W/ Both"
     FreeAugmentBuyText="|&1. (FREE)"
     FreeAugmentBuyAltText="|&2. (FREE)"
     SkillAugmentsTitleText="Talents"
     RequirementsLabel="Requirements:|n%s, %d|n"
     RequirementsLabelPlural="Requirements:|n%s, %d|n%s, %d|n"
     CostLabel="Cost: %s point(s)|n"
     CostLabelFree="Cost: FREE (pick one)|n"
     MsgSelectAnAugment="Please click on an augment to see its details."
}
