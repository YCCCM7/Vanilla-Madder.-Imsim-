//=============================================================================
// VMDMenuSelectClass
//=============================================================================
class VMDMenuSelectClass expands MenuUIScreenWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

struct VMDSpecPreset {
	var int SpecOne;
	var int SpecTwo;
	var int FreePoints;
	var int MinMax;
	var int Combat;
	var int Stealth;
	var int Difficulty;
};

var string StoredCampaign;

var int StartingPointsDefault; //Use this for calculating percentages.

var MenuUILabelWindow ListLabel;
var VMDButtonPos LabelHeaderPos, LabelListPos;
var localized string ListLabelText;

var VMDButtonPos ClassPicsPos[2];
var Window ClassPreviews[2];
var Texture ClassIcons[11];
var localized string ClassTipText, ClassTipHeader;

var ProgressBarWindow BalanceBars[5];
var VMDButtonPos BalanceBarPos[5], BalanceTextPos[2];
var TextWindow BalanceBarIndicators[5];
var MenuUILabelWindow BalanceBarLabels[5];
var localized string BalanceBarText[5];

var localized string AdvanceText[2];

var localized string PresetNames[32], PresetDescs[32], PresetNamesNoCrafting[32], PresetDescsNoCrafting[32];
var VMDSpecPreset Presets[32], PresetsNoCrafting[32];

var int CurPresetIndex, MaxPresetIndex, MaxPresetIndexNoCrafting;

var MenuUIListWindow ClassList;
var PersonaInfoWindow DescBox;
var VMDButtonPos ClassListPos, DescBoxPos;

var VMDBufferPlayer VMP;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	// Get a pointer to the player
	VMP = VMDBufferPlayer(GetRootWindow().parentPawn);
	
	Super.InitWindow();
	
	// Need to do this because of the edit control used for 
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);
	
	Show();
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	CreateBalanceBars();
	CreateInfoWindow();
	CreatePreviewWindows();
	CreatePreviewLists();
	CreateLabels();
	UpdateInfo();
	
	EnableButtons();
	
	AddTimer(0.1, false,, 'GiveTip');
}

// ----------------------------------------------------------------------
// CreateInfoWindows()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
	DescBox = PersonaInfoWindow(winClient.NewChild(Class'PersonaInfoWindow'));
	DescBox.SetPos(DescBoxPos.X, DescBoxPos.Y);
	DescBox.SetSize(384, 144);
	DescBox.SetText("---");
}

function CreateBalanceBars()
{
	local int i;
	local Color ColBarBack;
	
	for (i=0; i<ArrayCount(BalanceBars); i++)
	{
		BalanceBars[i] = ProgressBarWindow(NewChild(Class'ProgressBarWindow'));
		BalanceBars[i].SetPos(BalanceBarPos[i].X, BalanceBarPos[i].Y);
		BalanceBars[i].SetSize(66, 11);
		BalanceBars[i].SetValues(0, 100);
		BalanceBars[i].SetVertical(False);
		BalanceBars[i].SetScaleColorModifier(0.5);
		BalanceBars[i].UseScaledColor(True);
		BalanceBars[i].SetDrawBackground(False);
		BalanceBars[i].SetBackColor(colBarBack);
		
		BalanceBarLabels[i] = CreateMenuLabel(BalanceBarPos[i].X + BalanceTextPos[0].X, BalanceBarPos[i].Y + BalanceTextPos[0].Y, BalanceBarText[i], winClient);
		
		BalanceBarIndicators[i] = TextWindow(NewChild(Class'TextWindow'));
		BalanceBarIndicators[i].SetPos(BalanceBarPos[i].X + BalanceTextPos[1].X, BalanceBarPos[i].Y + BalanceTextPos[1].Y);
		BalanceBarIndicators[i].SetSize(66, 11);
		BalanceBarIndicators[i].SetTextMargins(0, 0);
		BalanceBarIndicators[i].SetTextAlignments(HALIGN_Center, VALIGN_Center);
		BalanceBarIndicators[i].SetFont(Font'FontMenuSmall_DS');
		BalanceBarIndicators[i].SetTextColorRGB(255, 255, 255);
	}
	BalanceBars[4].bUseInverseColor = true;
}

function CreatePreviewWindows()
{
	local int i;
	
	for (i=0; i<ArrayCount(ClassPreviews); i++)
	{
		ClassPreviews[i] = NewChild(class'Window');
		ClassPreviews[i].SetPos(ClassPicsPos[i].X, ClassPicsPos[i].Y);
	}
	ClassPreviews[0].SetBackground(Texture'SpecializationsIconCustomLarge1');
	ClassPreviews[1].SetBackground(Texture'SpecializationsIconCustomLarge2');
}

function CreatePreviewLists()
{
	local int i;
	local Texture TTex;
	
	ClassList = MenuUIListWindow(NewChild(Class'MenuUIListWindow'));
	ClassList.SetPos(ClassListPos.X, ClassListPos.Y);
	ClassList.EnableMultiSelect(False);
	ClassList.EnableAutoExpandColumns(False);
	ClassList.EnableHotKeys(False);
	//ClassList.SetNumColumns(1);
	ClassList.SetColumnWidth(0, 90);
	ClassList.SetColumnType(0, COLTYPE_String);
	
	// First erase the old list
	ClassList.DeleteAllRows();
	
	if (VMP == None || !VMP.bCraftingSystemEnabled)
	{
		for(i=0; i<ArrayCount(PresetNamesNoCrafting); i++)
		{
			if (PresetNamesNoCrafting[i] ~= "") break;
			ClassList.AddRow(PresetNames[i]);
		}
	}
	else
	{
		TTex = ClientTextures[0];
		WinClient.SetClientTexture(0, Texture'ClassBackground_1CraftingEnabled');
		VMP.UnloadTexture(TTex);
		
		for(i=0; i<ArrayCount(PresetNames); i++)
		{
			if (PresetNames[i] ~= "") break;
			ClassList.AddRow(PresetNames[i]);
		}
	}
	ClassList.SelectToRow(ClassList.IndexToRowId(0));
	ClassList.SetFocusRow(ClassList.IndexToRowId(0));
}

function CreateLabels()
{
	ListLabel = CreateMenuLabel(ClassListPos.X+LabelListPos.X, ClassListPos.Y+LabelListPos.Y, ListLabelText, winClient);
}

function UpdateInfo()
{
	local int i, FCast[5];
	
	if (VMP == None || !VMP.bCraftingSystemEnabled)
	{
		if (CurPresetIndex >= 0)
		{
			i = PresetsNoCrafting[CurPresetIndex].SpecOne;
			if (i >= 0)
			{
				ClassPreviews[0].SetBackground(ClassIcons[i]);
			}
			i = PresetsNoCrafting[CurPresetIndex].SpecTwo;
			if (i >= 0)
			{
				ClassPreviews[1].SetBackground(ClassIcons[i]);
			}
		}
		DescBox.Clear();
		DescBox.SetTitle(PresetNamesNoCrafting[CurPresetIndex]);
		DescBox.SetText(PresetDescsNoCrafting[CurPresetIndex]);
		
		FCast[0] = Clamp(float(PresetsNoCrafting[CurPresetIndex].FreePoints) / float(StartingPointsDefault) * 100.0, 0, 100);
		BalanceBars[0].SetCurrentValue(FCast[0]);
		BalanceBarIndicators[0].SetText(FCast[0]$"%");
		
		if (CurPresetIndex == 0)
		{
			ClassPreviews[0].SetBackground(Texture'SpecializationsIconCustomLarge1');
			ClassPreviews[1].SetBackground(Texture'SpecializationsIconCustomLarge2');
			
			for (i=1; i<ArrayCount(BalanceBarIndicators); i++)
			{
				BalanceBars[i].SetCurrentValue(50);
				BalanceBarIndicators[i].SetText("???");
			}
		}
		else if (CurPresetIndex > 0)
		{
			FCast[1] = 100 - PresetsNoCrafting[CurPresetIndex].MinMax;
			FCast[2] = PresetsNoCrafting[CurPresetIndex].Combat;
			FCast[3] = PresetsNoCrafting[CurPresetIndex].Stealth;
			FCast[4] = PresetsNoCrafting[CurPresetIndex].Difficulty;
			for (i=1; i<ArrayCount(BalanceBarIndicators); i++)
			{
				BalanceBars[i].SetCurrentValue(FCast[i]);
				BalanceBarIndicators[i].SetText(FCast[i]$"%");
			}
		}
	}
	else
	{
		if (CurPresetIndex >= 0)
		{
			i = Presets[CurPresetIndex].SpecOne;
			if (i >= 0)
			{
				ClassPreviews[0].SetBackground(ClassIcons[i]);
			}
			i = Presets[CurPresetIndex].SpecTwo;
			if (i >= 0)
			{
				ClassPreviews[1].SetBackground(ClassIcons[i]);
			}
		}
		DescBox.Clear();
		DescBox.SetTitle(PresetNames[CurPresetIndex]);
		DescBox.SetText(PresetDescs[CurPresetIndex]);
		
		FCast[0] = Clamp(float(Presets[CurPresetIndex].FreePoints) / float(StartingPointsDefault) * 100.0, 0, 100);
		BalanceBars[0].SetCurrentValue(FCast[0]);
		BalanceBarIndicators[0].SetText(FCast[0]$"%");
		
		if (CurPresetIndex == 0)
		{	
			ClassPreviews[0].SetBackground(Texture'SpecializationsIconCustomLarge1');
			ClassPreviews[1].SetBackground(Texture'SpecializationsIconCustomLarge2');
			
			for (i=1; i<ArrayCount(BalanceBarIndicators); i++)
			{
				BalanceBars[i].SetCurrentValue(50);
				BalanceBarIndicators[i].SetText("???");
			}
		}
		else if (CurPresetIndex > 0)
		{
			FCast[1] = 100 - Presets[CurPresetIndex].MinMax;
			FCast[2] = Presets[CurPresetIndex].Combat;
			FCast[3] = Presets[CurPresetIndex].Stealth;
			FCast[4] = Presets[CurPresetIndex].Difficulty;
			for (i=1; i<ArrayCount(BalanceBarIndicators); i++)
			{
				BalanceBars[i].SetCurrentValue(FCast[i]);
				BalanceBarIndicators[i].SetText(FCast[i]$"%");
			}
		}
	}
	EnableButtons();
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	bHandled = True;
	
	switch( buttonPressed )
	{
		default:
			bHandled = False;
		break;
	}
	
	if ( !bHandled )
		bHandled = Super.ButtonActivated(buttonPressed);
	
	return bHandled;
}

// ----------------------------------------------------------------------
// ListRowActivated()
//
// User double-clicked on one of the rows, meaning he/she/it wants 
// to redefine one of the functions
// ----------------------------------------------------------------------

//event bool ListRowActivated(window list, int rowId)
event bool ListSelectionChanged(window List, int NumSelections, int RowID)
{
	if (List == ClassList)
	{
		if ((CurPresetIndex != ClassList.RowIDToIndex(RowID)) && (ClassList.RowIDToIndex(RowID) >= 0))
		{
			CurPresetIndex = ClassList.RowIDToIndex(RowID);
		}
	}
	
	UpdateInfo();
	return True;
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	if (CurPresetIndex == 0)
	{
		ActionButtons[1].Btn.SetButtonText(AdvanceText[0]);
	}
	else
	{
		ActionButtons[1].Btn.SetButtonText(AdvanceText[1]);
	}
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	local Color colButtonFace;
	
	Super.StyleChanged();
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	// Title colors
	colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
	
	UpdatePersonaInfoColors(DescBox);
}

function UpdatePersonaInfoColors(PersonaInfoWindow W)
{
	local ColorTheme theme;
	
	if (W == None) return;	
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	W.ColBackground = Theme.GetColorFromName('MenuColor_Background');
	W.ColBorder = Theme.GetColorFromName('MenuColor_Background'); //Borders
	W.ColText = Theme.GetColorFromName('MenuColor_ListText');
	W.ColHeaderText = Theme.GetColorFromName('MenuColor_TitleText');
	W.SetTextColor(W.ColText);
	
	W.WinTitle.SetTextColor(W.ColHeaderText);
	W.WinText.SetTextColor(W.ColText);
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	if (VMP != None)
	{
		//MADDERS: Call relevant reset data.
		VMP.VMDResetNewGameVars(4);
		VMP.AssignedClass = PresetNames[CurPresetIndex];
	}
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	switch(CAPS(ActionKey))
	{
		case "START":
			SaveSettings();
			InvokeNewGameScreen(StoredCampaign);
		break;
		case "HELP":
			root.MessageBox(ClassTipHeader, ClassTipText, 1, False, Self);
		break;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function InvokeNewGameScreen(string Campaign)
{
	local VMDMenuSelectSpecializations NewGame;
	
	if (CurPresetIndex < 1)
	{
		newGame = VMDMenuSelectSpecializations(root.InvokeMenuScreen(Class'VMDMenuSelectSpecializations'));
		
		if (newGame != None)
		{
			newGame.SetCampaignData(Campaign);
		}
	}
	else
	{
		StartCampaignWith(CurPresetIndex);
	}
}

function StartCampaignWith(int WithIndex)
{
	local VMDSkillAugmentManager SAM;
	local Skill S;
	
	if (VMP == None) return;
	
	SAM = VMP.SkillAugmentManager;
	if (SAM == None) return;
	
	//MADDERS, 11/30/20: For custom skill balances. Yikes, but also a slick hack.
	//VMP.SkillPointsAvail -= (StartingPointsDefault - Presets[WithIndex].FreePoints);
	VMP.SkillPointsSpent += (StartingPointsDefault - Presets[WithIndex].FreePoints);
	
	if (VMP.bCraftingSystemEnabled)
	{
		switch(CAPS(PresetNames[WithIndex]))
		{
			case "GUNSLINGER":
				ForceSkillSpecialization(0, class'SkillWeaponPistol');
				ForceSkillSpecialization(1, class'SkillWeaponRifle');
				ForceSkill(class'SkillWeaponPistol', 1, 2, 2);
				ForceSkill(class'SkillWeaponRifle', 1, 2, 2);
				ForceSkill(class'SkillSwimming', 1, 1, 0);
				ForceSkill(class'SkillMedicine', 1, 1, 0);
				SAM.UnlockSkillAugment('PistolFocus');
				SAM.UnlockSkillAugment('PistolModding');
				SAM.UnlockSkillAugment('RifleFocus');
				SAM.UnlockSkillAugment('RifleModding');
			break;
			case "EXPLOSIVES":
				ForceSkillSpecialization(0, class'SkillWeaponHeavy');
				ForceSkillSpecialization(1, class'SkillDemolition');
				ForceSkill(class'SkillWeaponHeavy', 1, 2, 2);
				ForceSkill(class'SkillDemolition', 2, 4, 4);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				ForceSkill(class'SkillMedicine', 1, 1, 0);
				SAM.UnlockSkillAugment('HeavySpeed');
				SAM.UnlockSkillAugment('HeavyDropAndRoll');
				SAM.UnlockSkillAugment('DemolitionMines');
				SAM.UnlockSkillAugment('DemolitionGrenadeMaxAmmo');
				SAM.UnlockSkillAugment('DemolitionLooting');
			break;
			case "BURGLAR":
				ForceSkillSpecialization(0, class'SkillWeaponLowTech');
				ForceSkillSpecialization(1, class'SkillLockpicking');
				ForceSkill(class'SkillWeaponLowTech', 1, 2, 2);
				ForceSkill(class'SkillLockpicking', 2, 4, 4);
				SAM.UnlockSkillAugment('MeleeBatonHeadshots');
				SAM.UnlockSkillAugment('MeleeDoorCrackingWood');
				SAM.UnlockSkillAugment('LockpickScent');
				SAM.UnlockSkillAugment('LockpickStealthBar');
				SAM.UnlockSkillAugment('LockpickPickpocket');
				SAM.UnlockSkillAugment('TagTeamDoorCrackingMetal');
			break;
			case "INVADER":
				ForceSkillSpecialization(0, class'SkillLockpicking');
				ForceSkillSpecialization(1, class'SkillTech');
				ForceSkill(class'SkillLockpicking', 2, 4, 4);
				ForceSkill(class'SkillTech', 1, 2, 2);
				ForceSkill(class'SkillComputer', 1, 1, 0);
				SAM.UnlockSkillAugment('LockpickStealthBar');
				SAM.UnlockSkillAugment('LockpickStartStealth');
				SAM.UnlockSkillAugment('LockpickPickpocket');
				SAM.UnlockSkillAugment('ElectronicsHackingPotency1');
				SAM.UnlockSkillAugment('TagTeamInvaderCapacity');
			break;
			case "HACKER":
				ForceSkillSpecialization(0, class'SkillTech');
				ForceSkillSpecialization(1, class'SkillComputer');
				ForceSkill(class'SkillTech', 1, 2, 2);
				ForceSkill(class'SkillComputer', 2, 4, 4);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				SAM.UnlockSkillAugment('ElectronicsHackingPotency1');
				SAM.UnlockSkillAugment('ElectronicsHackingPotency2');
				SAM.UnlockSkillAugment('ComputerScaling');
				SAM.UnlockSkillAugment('ComputerSpecialOptions');
				SAM.UnlockSkillAugment('ComputerTurrets');
			break;
			case "RECON":
				ForceSkillSpecialization(0, class'SkillComputer');
				ForceSkillSpecialization(1, class'SkillSwimming');
				ForceSkill(class'SkillComputer', 2, 4, 4);
				ForceSkill(class'SkillSwimming', 2, 4, 4);
				ForceSkill(class'SkillLockpicking', 1, 1, 0);
				SAM.UnlockSkillAugment('ComputerScaling');
				SAM.UnlockSkillAugment('ComputerSpecialOptions');
				SAM.UnlockSkillAugment('ComputerTurrets');
				SAM.UnlockSkillAugment('SwimmingFallRoll');
				SAM.UnlockSkillAugment('SwimmingFitness');
				SAM.UnlockSkillAugment('SwimmingBreathRegen');
			break;
			case "RENEGADE":
				ForceSkillSpecialization(0, class'SkillSwimming');
				ForceSkillSpecialization(1, class'SkillEnviro');
				ForceSkill(class'SkillSwimming', 1, 2, 2);
				ForceSkill(class'SkillEnviro', 2, 4, 4);
				ForceSkill(class'SkillTech', 1, 1, 0);
				ForceSkill(class'SkillLockpicking', 1, 1, 0);
				SAM.UnlockSkillAugment('SwimmingFitness');
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('EnviroCopies');
				SAM.UnlockSkillAugment('EnviroLooting');
			break;
			case "SURVIVOR":
				ForceSkillSpecialization(0, class'SkillEnviro');
				ForceSkillSpecialization(1, class'SkillMedicine');
				ForceSkill(class'SkillEnviro', 2, 4, 4);
				ForceSkill(class'SkillMedicine', 2, 4, 3);
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('EnviroCopies');
				SAM.UnlockSkillAugment('EnviroDurability');
				SAM.UnlockSkillAugment('MedicineStress');
				SAM.UnlockSkillAugment('MedicineWraparound');
			break;
			case "ROGUE":
				ForceSkillSpecialization(0, class'SkillWeaponPistol');
				ForceSkillSpecialization(1, class'SkillSwimming');
				ForceSkill(class'SkillWeaponPistol', 1, 2, 2);
				ForceSkill(class'SkillSwimming', 2, 4, 4);
				ForceSkill(class'SkillWeaponLowTech', 1, 1, 0);
				ForceSkill(class'SkillLockpicking', 1, 1, 0);
				SAM.UnlockSkillAugment('PistolReload');
				SAM.UnlockSkillAugment('PistolModding');
				SAM.UnlockSkillAugment('SwimmingFallRoll');
				SAM.UnlockSkillAugment('SwimmingRoll');
				SAM.UnlockSkillAugment('SwimmingBreathRegen');
			break;
			case "SOLDIER":
				ForceSkillSpecialization(0, class'SkillWeaponRifle');
				ForceSkillSpecialization(1, class'SkillDemolition');
				ForceSkill(class'SkillWeaponRifle', 1, 2, 2);
				ForceSkill(class'SkillDemolition', 2, 4, 4);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				ForceSkill(class'SkillMedicine', 1, 1, 0);
				SAM.UnlockSkillAugment('RifleFocus');
				SAM.UnlockSkillAugment('RifleOperation');
				SAM.UnlockSkillAugment('DemolitionMineHandling');
				SAM.UnlockSkillAugment('DemolitionGrenadeMaxAmmo');
				SAM.UnlockSkillAugment('DemolitionLooting');
			break;
			case "HITMAN":
				ForceSkillSpecialization(0, class'SkillWeaponRifle');
				ForceSkillSpecialization(1, class'SkillEnviro');
				ForceSkill(class'SkillWeaponRifle', 1, 2, 2);
				ForceSkill(class'SkillEnviro', 2, 4, 4);
				ForceSkill(class'SkillWeaponLowTech', 1, 1, 0);
				SAM.UnlockSkillAugment('RifleModding');
				SAM.UnlockSkillAugment('RifleOperation');
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('EnviroLooting');
				SAM.UnlockSkillAugment('EnviroCopies');
			break;
			case "PACIFIST":
				ForceSkillSpecialization(0, class'SkillSwimming');
				ForceSkillSpecialization(1, class'SkillMedicine');
				ForceSkill(class'SkillSwimming', 3, 6, 6);
				ForceSkill(class'SkillMedicine', 1, 2, 2);
				ForceSkill(class'SkillComputer', 1, 1, 0);
				SAM.UnlockSkillAugment('SwimmingFallRoll');
				SAM.UnlockSkillAugment('SwimmingRoll');
				SAM.UnlockSkillAugment('SwimmingDrowningRate');
				SAM.UnlockSkillAugment('SwimmingBreathRegen');
				SAM.UnlockSkillAugment('MedicineWraparound');
			break;
			case "SURGEON":
				ForceSkillSpecialization(0, class'SkillTech');
				ForceSkillSpecialization(1, class'SkillMedicine');
				ForceSkill(class'SkillTech', 1, 2, 2);
				ForceSkill(class'SkillMedicine', 2, 4, 4);
				ForceSkill(class'SkillWeaponLowTech', 1, 1, 0);
				SAM.UnlockSkillAugment('MeleeBatonHeadshots');
				SAM.UnlockSkillAugment('MedicineStress');
				SAM.UnlockSkillAugment('MedicineCombatDrugs');
				SAM.UnlockSkillAugment('MedicineCrafting');
				SAM.UnlockSkillAugment('TagTeamMedicalSyringe');
				SAM.UnlockSkillAugment('ElectronicsHackingPotency1');
			break;
			case "SHADOW":
				ForceSkillSpecialization(0, class'SkillLockpicking');
				ForceSkillSpecialization(1, class'SkillEnviro');
				ForceSkill(class'SkillLockpicking', 2, 4, 4);
				ForceSkill(class'SkillEnviro', 1, 2, 2);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				SAM.UnlockSkillAugment('LockpickStealthBar');
				SAM.UnlockSkillAugment('LockpickScent');
				SAM.UnlockSkillAugment('LockpickStartStealth');
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('TagTeamSmallWeapons');
			break;
			case "ENGINEER":
				ForceSkillSpecialization(0, class'SkillTech');
				ForceSkillSpecialization(1, class'SkillComputer');
				ForceSkill(class'SkillTech', 2, 4, 4);
				ForceSkill(class'SkillComputer', 1, 2, 2);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 1);
				SAM.UnlockSkillAugment('ElectronicsDrones');
				SAM.UnlockSkillAugment('ElectronicsDroneArmor');
				SAM.UnlockSkillAugment('TagTeamMiniTurret');
				SAM.UnlockSkillAugment('TagTeamLitehack');
				SAM.UnlockSkillAugment('TagTeamSkillware');
			break;
		}
	}
	else
	{
		switch(CAPS(PresetNames[WithIndex]))
		{
			case "GUNSLINGER":
				ForceSkillSpecialization(0, class'SkillWeaponPistol');
				ForceSkillSpecialization(1, class'SkillWeaponRifle');
				ForceSkill(class'SkillWeaponPistol', 1, 2, 2);
				ForceSkill(class'SkillWeaponRifle', 1, 2, 2);
				ForceSkill(class'SkillSwimming', 1, 1, 0);
				ForceSkill(class'SkillMedicine', 1, 1, 0);
				SAM.UnlockSkillAugment('PistolFocus');
				SAM.UnlockSkillAugment('PistolModding');
				SAM.UnlockSkillAugment('RifleFocus');
				SAM.UnlockSkillAugment('RifleModding');
			break;
			case "EXPLOSIVES":
				ForceSkillSpecialization(0, class'SkillWeaponHeavy');
				ForceSkillSpecialization(1, class'SkillDemolition');
				ForceSkill(class'SkillWeaponHeavy', 1, 2, 2);
				ForceSkill(class'SkillDemolition', 2, 4, 4);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				ForceSkill(class'SkillMedicine', 1, 1, 0);
				SAM.UnlockSkillAugment('HeavySpeed');
				SAM.UnlockSkillAugment('HeavyDropAndRoll');
				SAM.UnlockSkillAugment('DemolitionMines');
				SAM.UnlockSkillAugment('DemolitionGrenadeMaxAmmo');
				SAM.UnlockSkillAugment('DemolitionLooting');
			break;
			case "BURGLAR":
				ForceSkillSpecialization(0, class'SkillWeaponLowTech');
				ForceSkillSpecialization(1, class'SkillLockpicking');
				ForceSkill(class'SkillWeaponLowTech', 1, 2, 2);
				ForceSkill(class'SkillLockpicking', 2, 4, 4);
				SAM.UnlockSkillAugment('MeleeBatonHeadshots');
				SAM.UnlockSkillAugment('MeleeDoorCrackingWood');
				SAM.UnlockSkillAugment('LockpickScent');
				SAM.UnlockSkillAugment('LockpickStealthBar');
				SAM.UnlockSkillAugment('LockpickPickpocket');
				SAM.UnlockSkillAugment('TagTeamDoorCrackingMetal');
			break;
			case "INVADER":
				ForceSkillSpecialization(0, class'SkillLockpicking');
				ForceSkillSpecialization(1, class'SkillTech');
				ForceSkill(class'SkillLockpicking', 2, 4, 4);
				ForceSkill(class'SkillTech', 1, 2, 2);
				ForceSkill(class'SkillComputer', 1, 1, 0);
				SAM.UnlockSkillAugment('LockpickStealthBar');
				SAM.UnlockSkillAugment('LockpickStartStealth');
				SAM.UnlockSkillAugment('LockpickPickpocket');
				SAM.UnlockSkillAugment('ElectronicsHackingPotency1');
				SAM.UnlockSkillAugment('TagTeamInvaderCapacity');
			break;
			case "HACKER":
				ForceSkillSpecialization(0, class'SkillTech');
				ForceSkillSpecialization(1, class'SkillComputer');
				ForceSkill(class'SkillTech', 1, 2, 2);
				ForceSkill(class'SkillComputer', 2, 4, 4);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				SAM.UnlockSkillAugment('ElectronicsHackingPotency1');
				SAM.UnlockSkillAugment('ElectronicsHackingPotency2');
				SAM.UnlockSkillAugment('ComputerScaling');
				SAM.UnlockSkillAugment('ComputerSpecialOptions');
				SAM.UnlockSkillAugment('ComputerTurrets');
			break;
			case "RECON":
				ForceSkillSpecialization(0, class'SkillComputer');
				ForceSkillSpecialization(1, class'SkillSwimming');
				ForceSkill(class'SkillComputer', 2, 4, 4);
				ForceSkill(class'SkillSwimming', 2, 4, 4);
				ForceSkill(class'SkillLockpicking', 1, 1, 0);
				SAM.UnlockSkillAugment('ComputerScaling');
				SAM.UnlockSkillAugment('ComputerSpecialOptions');
				SAM.UnlockSkillAugment('ComputerTurrets');
				SAM.UnlockSkillAugment('SwimmingFallRoll');
				SAM.UnlockSkillAugment('SwimmingFitness');
				SAM.UnlockSkillAugment('SwimmingBreathRegen');
			break;
			case "RENEGADE":
				ForceSkillSpecialization(0, class'SkillSwimming');
				ForceSkillSpecialization(1, class'SkillEnviro');
				ForceSkill(class'SkillSwimming', 1, 2, 2);
				ForceSkill(class'SkillEnviro', 2, 4, 4);
				ForceSkill(class'SkillTech', 1, 1, 0);
				ForceSkill(class'SkillLockpicking', 1, 1, 0);
				SAM.UnlockSkillAugment('SwimmingFitness');
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('EnviroCopies');
				SAM.UnlockSkillAugment('EnviroLooting');
			break;
			case "SURVIVOR":
				ForceSkillSpecialization(0, class'SkillEnviro');
				ForceSkillSpecialization(1, class'SkillMedicine');
				ForceSkill(class'SkillEnviro', 2, 4, 4);
				ForceSkill(class'SkillMedicine', 2, 4, 3);
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('EnviroCopies');
				SAM.UnlockSkillAugment('EnviroDurability');
				SAM.UnlockSkillAugment('MedicineStress');
				SAM.UnlockSkillAugment('MedicineWraparound');
			break;
			case "ROGUE":
				ForceSkillSpecialization(0, class'SkillWeaponPistol');
				ForceSkillSpecialization(1, class'SkillSwimming');
				ForceSkill(class'SkillWeaponPistol', 1, 2, 2);
				ForceSkill(class'SkillSwimming', 2, 4, 4);
				ForceSkill(class'SkillWeaponLowTech', 1, 1, 0);
				ForceSkill(class'SkillLockpicking', 1, 1, 0);
				SAM.UnlockSkillAugment('PistolReload');
				SAM.UnlockSkillAugment('PistolModding');
				SAM.UnlockSkillAugment('SwimmingFallRoll');
				SAM.UnlockSkillAugment('SwimmingRoll');
				SAM.UnlockSkillAugment('SwimmingBreathRegen');
			break;
			case "SOLDIER":
				ForceSkillSpecialization(0, class'SkillWeaponRifle');
				ForceSkillSpecialization(1, class'SkillDemolition');
				ForceSkill(class'SkillWeaponRifle', 1, 2, 2);
				ForceSkill(class'SkillDemolition', 2, 4, 4);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				ForceSkill(class'SkillMedicine', 1, 1, 0);
				SAM.UnlockSkillAugment('RifleFocus');
				SAM.UnlockSkillAugment('RifleOperation');
				SAM.UnlockSkillAugment('DemolitionMineHandling');
				SAM.UnlockSkillAugment('DemolitionGrenadeMaxAmmo');
				SAM.UnlockSkillAugment('DemolitionLooting');
			break;
			case "HITMAN":
				ForceSkillSpecialization(0, class'SkillWeaponRifle');
				ForceSkillSpecialization(1, class'SkillEnviro');
				ForceSkill(class'SkillWeaponRifle', 1, 2, 2);
				ForceSkill(class'SkillEnviro', 2, 4, 4);
				ForceSkill(class'SkillWeaponLowTech', 1, 1, 0);
				SAM.UnlockSkillAugment('RifleModding');
				SAM.UnlockSkillAugment('RifleOperation');
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('EnviroLooting');
				SAM.UnlockSkillAugment('EnviroCopies');
			break;
			case "PACIFIST":
				ForceSkillSpecialization(0, class'SkillSwimming');
				ForceSkillSpecialization(1, class'SkillMedicine');
				ForceSkill(class'SkillSwimming', 3, 6, 6);
				ForceSkill(class'SkillMedicine', 1, 2, 2);
				ForceSkill(class'SkillComputer', 1, 1, 0);
				SAM.UnlockSkillAugment('SwimmingFallRoll');
				SAM.UnlockSkillAugment('SwimmingRoll');
				SAM.UnlockSkillAugment('SwimmingDrowningRate');
				SAM.UnlockSkillAugment('SwimmingBreathRegen');
				SAM.UnlockSkillAugment('MedicineWraparound');
			break;
			case "SURGEON":
				ForceSkillSpecialization(0, class'SkillWeaponLowTech');
				ForceSkillSpecialization(1, class'SkillMedicine');
				ForceSkill(class'SkillWeaponLowTech', 1, 2, 2);
				ForceSkill(class'SkillMedicine', 2, 4, 4);
				ForceSkill(class'SkillTech', 1, 1, 0);
				ForceSkill(class'SkillComputer', 1, 1, 0);
				SAM.UnlockSkillAugment('MeleeProjectileLooting');
				SAM.UnlockSkillAugment('MeleeBatonHeadshots');
				SAM.UnlockSkillAugment('MedicineStress');
				SAM.UnlockSkillAugment('MedicineCapacity');
				SAM.UnlockSkillAugment('MedicineWraparound');
			break;
			case "SHADOW":
				ForceSkillSpecialization(0, class'SkillLockpicking');
				ForceSkillSpecialization(1, class'SkillEnviro');
				ForceSkill(class'SkillLockpicking', 2, 4, 4);
				ForceSkill(class'SkillEnviro', 1, 2, 2);
				ForceSkill(class'SkillWeaponPistol', 1, 1, 0);
				SAM.UnlockSkillAugment('LockpickStealthBar');
				SAM.UnlockSkillAugment('LockpickScent');
				SAM.UnlockSkillAugment('LockpickStartStealth');
				SAM.UnlockSkillAugment('EnviroDeactivate');
				SAM.UnlockSkillAugment('TagTeamSmallWeapons');
			break;
		}
	}
	
	class'VMDStaticFunctions'.Static.StartCampaign(DeusExPlayer(GetPlayerPawn()), StoredCampaign);
}

function ForceSkillSpecialization(int Index, class<Skill> SkillType)
{
	local VMDSkillAugmentManager SAM;
	
	if (VMP == None) return;
	
	SAM = VMP.SkillAugmentManager;
	if (SAM == None) return;
	
	SAM.SkillSpecializations[Index] = TranslateIndex(SkillType)+1;
}

function int TranslateIndex(class<Skill> SkillType)
{
	switch(SkillType)
	{
		//Pistols
		case class'SkillWeaponPistol':
			return 0;
		break;
		//Rifles
		case class'SkillWeaponRifle':
			return 1;
		break;
		//Heavy
		case class'SkillWeaponHeavy':
			return 3;
		break;
		//Demolitions
		case class'SkillDemolition':
			return 2;
		break;
		//Low Tech
		case class'SkillWeaponLowTech':
			return 4;
		break;
		//Infiltration
		case class'SkillLockpicking':
			return 5;
		break;
		//Electronics
		case class'SkillTech':
			return 6;
		break;
		//Computers
		case class'SkillComputer':
			return 10;
		break;
		//Fitness
		case class'SkillSwimming':
			return 7;
		break;
		//Tactical Gear
		case class'SkillEnviro':
			return 8;
		break;
		//Medicine
		case class'SkillMedicine':
			return 9;
		break;
	}
	
	return 0;
}

function ForceSkill(class<Skill> SkillType, int Level, int PointsLeft, int PointsSpent)
{
	local VMDSkillAugmentManager SAM;
	local SkillManager SM;
	local Skill S;
	local int SAPI;
	
	if (VMP == None) return;
	
	SAM = VMP.SkillAugmentManager;
	SM = VMP.SkillSystem;
	if (SM == None || SAM == None) return;
	
	S = SM.GetSkillFromClass(SkillType);
	if (S == None) return;
	
	S.CurrentLevel = Level;
	
	SAPI = SAM.SkillArrayOf(SkillType);
	
	SAM.SkillAugmentPointsLeft[SAPI] = PointsLeft;
	SAM.SkillAugmentPointsSpent[SAPI] = PointsSpent;
}

function SetCampaignData(string NewCampaign)
{
	StoredCampaign = NewCampaign;
}

function GiveTip()
{
	if ((VMP == None) || (!VMP.bGaveNewGameTips))
	{
		root.MessageBox(ClassTipHeader, ClassTipText, 1, False, Self);
	}
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	switch(ButtonNumber)
	{
		case 0:
			Root.PopWindow();
		break;
	}
	return true;
}

defaultproperties
{
     StartingPointsDefault=6575
     PresetNames(0)="Custom"
     PresetDescs(0)="You will define your own resonations, skills, and talents in the menus to come."
     Presets(0)=(SpecOne=-1,SpecTwo=-1,FreePoints=6575, MinMax=0,Combat=-1,Stealth=-1,Difficulty=-1)
     PresetNamesNoCrafting(0)="Custom"
     PresetDescsNoCrafting(0)="You will define your own resonations, skills, and talents in the menus to come."
     PresetsNoCrafting(0)=(SpecOne=-1,SpecTwo=-1,FreePoints=6575, MinMax=0,Combat=-1,Stealth=-1,Difficulty=-1)
     
     PresetNames(1)="Gunslinger"
     PresetDescs(1)="Weapon handling and customization come easy, at least in the form of pistols and rifles. However, you lean towards rifles and the standard issue 10mm. You know enough medicine to patch yourself up, and you're fit enough to traverse bodies of water.|n|nSkills: Weapons: Pistol(1), Weapons: Rifle(1), Medicine(1), Fitness(1)|nTalents: Pistol Focus, Pistol Modularity, Rifle Focus, Rifle Modularity"
     Presets(1)=(SpecOne=0,SpecTwo=1,FreePoints=1700,MinMax=65,Combat=90,Stealth=10,Difficulty=35)
     PresetNamesNoCrafting(1)="Gunslinger"
     PresetDescsNoCrafting(1)="Weapon handling and customization come easy, at least in the form of pistols and rifles. However, you lean towards rifles and the standard issue 10mm. You know enough medicine to patch yourself up, and you're fit enough to traverse bodies of water.|n|nSkills: Weapons: Pistol(1), Weapons: Rifle(1), Medicine(1), Fitness(1)|nTalents: Pistol Focus, Pistol Modularity, Rifle Focus, Rifle Modularity"
     PresetsNoCrafting(1)=(SpecOne=0,SpecTwo=1,FreePoints=1825,MinMax=65,Combat=90,Stealth=10,Difficulty=35)
     
     PresetNames(2)="Explosives"
     PresetDescs(2)="Emplaced mines gives you the ability to plan for the 'later', and your proficiency with heavy weapons gives you the ability to plan for the 'now'. You're very resiliant against fire and tear gas, and can patch yourself up with medkits.|n|nSkills: Weapons: Weapons: Demolition(2), Heavy(1), Medicine(1), Weapon: Pistols(1)|nTalents: Heavy Posture, Stop, Drop..., Fumble No More, Grenade Pouch, Carrion"
     Presets(2)=(SpecOne=2,SpecTwo=3,FreePoints=200,MinMax=65,Combat=100,Stealth=0,Difficulty=65)
     PresetNamesNoCrafting(2)="Explosives"
     PresetDescsNoCrafting(2)="Emplaced mines gives you the ability to plan for the 'later', and your proficiency with heavy weapons gives you the ability to plan for the 'now'. You're very resiliant against fire and tear gas, and can patch yourself up with medkits.|n|nSkills: Weapons: Demolition(2), Weapons: Heavy(1), Medicine(1), Weapon: Pistols(1)|nTalents: Heavy Posture, Stop, Drop..., Fumble No More, Grenade Pouch, Carrion"
     PresetsNoCrafting(2)=(SpecOne=2,SpecTwo=3,FreePoints=325,MinMax=65,Combat=100,Stealth=0,Difficulty=65)
     
     PresetNames(3)="Burglar"
     PresetDescs(3)="Doors absolutely hate you. Handy with a crowbar, and half as handy with a lockpick, you keep a low presence, with the potential to kill off the occassional straggler. You aren't built for robust combat, but that won't matter long term.|n|nSkills: Weapons: Low Tech(1), Infiltration(2)|nTalents: Silent Takedown, Soft Spot, Brute Force, Coverup, Keen Instincts, Pickpocket"
     Presets(3)=(SpecOne=4,SpecTwo=5,FreePoints=1725,MinMax=75,Combat=40,Stealth=60,Difficulty=70)
     PresetNamesNoCrafting(3)="Burglar"
     PresetDescsNoCrafting(3)="Doors absolutely hate you. Handy with a crowbar, and half as handy with a lockpick, you keep a low presence, with the potential to kill off the occassional straggler. You aren't built for robust combat, but that won't matter long term.|n|nSkills: Weapons: Low Tech(1), Infiltration(2)|nTalents: Silent Takedown, Soft Spot, Brute Force, Coverup, Keen Instincts, Pickpocket"
     PresetsNoCrafting(3)=(SpecOne=4,SpecTwo=5,FreePoints=1725,MinMax=75,Combat=40,Stealth=60,Difficulty=70)
     
     PresetNames(4)="Invader"
     PresetDescs(4)="Infiltration, hardware, and software... What more need be said? You can also pickpocket, and your ability to bypass obstacles often goes unnoticed.|n|nSkills: Infiltration(2), Hardware(1), Software(1)|nTalents: Keen Instincts, Sleight of Hand, Silent Mode, Invader's Kit"
     Presets(4)=(SpecOne=5,SpecTwo=6,FreePoints=675,MinMax=75,Combat=0,Stealth=100,Difficulty=80)
     PresetNamesNoCrafting(4)="Invader"
     PresetDescsNoCrafting(4)="Infiltration, hardware, and software... What more need be said? You can also pickpocket, and your ability to bypass obstacles often goes unnoticed.|n|nSkills: Infiltration(2), Hardware(1), Software(1)|nTalents: Keen Instincts, Sleight of Hand, Silent Mode, Invader's Kit"
     PresetsNoCrafting(4)=(SpecOne=5,SpecTwo=6,FreePoints=675,MinMax=75,Combat=0,Stealth=100,Difficulty=80)
     
     PresetNames(5)="Hacker"
     PresetDescs(5)="The digital realm has always spoken to you. While okay enough with a multitool, you really shine behind a keyboard, with a suite of software ready to go. You can bypass alarm units and keypads quite well, to your credit, and aren't half bad with a magnum.|n|nSkills: Hardware(1), Software(2), Weapons: Pistol(1)|nTalents: Data Analyst, Wave Surfer, Deep Fake, Wiz Kid, IFF Programming"
     Presets(5)=(SpecOne=6,SpecTwo=7,FreePoints=1375,MinMax=30,Combat=20,Stealth=80,Difficulty=40)
     PresetNamesNoCrafting(5)="Hacker"
     PresetDescsNoCrafting(5)="The digital realm has always spoken to you. While okay enough with a multitool, you really shine behind a keyboard, with a suite of software ready to go. You can bypass alarm units and keypads quite well, to your credit, and aren't half bad with a magnum.|n|nSkills: Hardware(1), Software(2), Weapons: Pistol(1)|nTalents: Data Analyst, Wave Surfer, Wiz Kid, IFF Programming"
     PresetsNoCrafting(5)=(SpecOne=6,SpecTwo=7,FreePoints=1375,MinMax=30,Combat=20,Stealth=80,Difficulty=40)
     
     PresetNames(6)="Recon"
     PresetDescs(6)="Your job isn't to fling lead or pick a lock. Your job is to swoop in, turn systems against your enemies, and slip out unnoticed. You're agile to an absurd degree, being hard to catch, but you're well armed for a broad battery of digital warfare, too.|n|nSkills: Fitness(2), Software(2), Infiltration(1)|nTalents: Aquadynamic, Fit As a Fiddle, Fall Roll, Deep Fake, Wiz Kid, IFF Programming"
     Presets(6)=(SpecOne=7,SpecTwo=8,FreePoints=675,MinMax=20,Combat=0,Stealth=100,Difficulty=100)
     PresetNamesNoCrafting(6)="Recon"
     PresetDescsNoCrafting(6)="Your job isn't to fling lead or pick a lock. Your job is to swoop in, turn systems against your enemies, and slip out unnoticed. You're agile to an absurd degree, being hard to catch, but you're well armed for a broad battery of digital warfare, too.|n|nSkills: Fitness(2), Software(2), Infiltration(1)|nTalents: Aquadynamic, Fit As a Fiddle, Fall Roll, Deep Fake, Wiz Kid, IFF Programming"
     PresetsNoCrafting(6)=(SpecOne=7,SpecTwo=8,FreePoints=675,MinMax=20,Combat=0,Stealth=100,Difficulty=100)
     
     PresetNames(7)="Renegade"
     PresetDescs(7)="You're good at bypassing obstacles on foot, but are prepared to take a couple hits with a flak jacket. You're respectable with a lockpick and multitool, too, so you can tackle all forms of obstacles that come your way.|n|nSkills: Fitness(1), Tactical Gear(2), Infiltration(1), Hardware(1)|nTalents: Fit As a Fiddle, Off Switch, Gentle Touch, Insulation"
     Presets(7)=(SpecOne=8,SpecTwo=9,FreePoints=625,MinMax=60,Combat=15,Stealth=85,Difficulty=85)
     PresetNamesNoCrafting(7)="Renegade"
     PresetDescsNoCrafting(7)="You're good at bypassing obstacles on foot, but are prepared to take a couple hits with a flak jacket. You're respectable with a lockpick and multitool, too, so you can tackle all forms of obstacles that come your way.|n|nSkills: Fitness(1), Tactical Gear(2), Infiltration(1), Hardware(1)|nTalents: Fit As a Fiddle, Off Switch, Gentle Touch, Insulation"
     PresetsNoCrafting(7)=(SpecOne=8,SpecTwo=9,FreePoints=625,MinMax=60,Combat=15,Stealth=85,Difficulty=85)
     
     PresetNames(8)="Survivor"
     PresetDescs(8)="You can reduce damage coming your way, and patch up any hits you DO end up taking. While certainly durable for good periods of time, your handgun is the only thing you pack to fight back, at least to start off with.|n|nSkills: Tactical Gear(2), Medicine(2)|nTalents: Off Switch, Fasten Up, Insulation, Trained Professional, Pharmacist"
     Presets(8)=(SpecOne=9,SpecTwo=10,FreePoints=1350,MinMax=60,Combat=70,Stealth=30,Difficulty=35)
     PresetNamesNoCrafting(8)="Survivor"
     PresetDescsNoCrafting(8)="You can reduce damage coming your way, and patch up any hits you DO end up taking. While certainly durable for good periods of time, your handgun is the only thing you pack to fight back, at least to start off with.|n|nSkills: Tactical Gear(2), Medicine(2)|nTalents: Off Switch, Fasten Up, Insulation, Trained Professional, Pharmacist"
     PresetsNoCrafting(8)=(SpecOne=9,SpecTwo=10,FreePoints=1775,MinMax=60,Combat=70,Stealth=30,Difficulty=35)
     
     PresetNames(9)="Rogue"
     PresetDescs(9)="You move fast first, but shoot second. Rolling about the battlefield, and tuning your guns to peak condition, you're swift, and you're effective. On the side, you can use melee weapons and pick locks at a basic level.|n|nSkills: Fitness(2), Weapons: Pistol(1), Weapons: Low Tech(1), Infiltration(1)|nTalents: Aquadynamic, Fall Roll, Tactical Roll, Gunslinger, Pistol Modularity"
     Presets(9)=(SpecOne=0,SpecTwo=8,FreePoints=275,MinMax=25,Combat=75,Stealth=25,Difficulty=20)
     PresetNamesNoCrafting(9)="Rogue"
     PresetDescsNoCrafting(9)="You move fast first, but shoot second. Rolling about the battlefield, and tuning your guns to peak condition, you're swift, and you're effective. On the side, you can use melee weapons and pick locks at a basic level.|n|nSkills: Fitness(2), Weapons: Pistol(1), Weapons: Low Tech(1), Infiltration(1)|nTalents: Aquadynamic, Fall Roll, Tactical Roll, Gunslinger, Pistol Modularity"
     PresetsNoCrafting(9)=(SpecOne=0,SpecTwo=8,FreePoints=275,MinMax=25,Combat=75,Stealth=25,Difficulty=20)
     
     PresetNames(10)="Soldier"
     PresetDescs(10)="You know a bit of everything relevant to the art of distributing death. Pistols, rifles especially, a hefty load of demolitions, and a hint of medicine to mend the wounds you gather.|n|nSkills: Weapons: Rifle(1), Weapons: Demolition(2), Weapons: Pistol(1), Medicine(1)|nTalents: Rifle Modularity, Followup Shot, Fumble No More, Grenade Pouch, Carrion"
     Presets(10)=(SpecOne=1,SpecTwo=3,FreePoints=0,MinMax=45,Combat=100,Stealth=0,Difficulty=15)
     PresetNamesNoCrafting(10)="Soldier"
     PresetDescsNoCrafting(10)="You know a bit of everything relevant to the art of distributing death. Pistols, rifles especially, a hefty load of demolitions, and a hint of medicine to mend the wounds you gather.|n|nSkills: Weapons: Rifle(1), Weapons: Demolition(2), Weapons: Pistol(1), Medicine(1)|nTalents: Rifle Modularity, Followup Shot, Fumble No More, Grenade Pouch, Carrion"
     PresetsNoCrafting(10)=(SpecOne=1,SpecTwo=3,FreePoints=125,MinMax=45,Combat=100,Stealth=0,Difficulty=15)
     
     PresetNames(11)="Hitman"
     PresetDescs(11)="Your use of a rifle is respectable, but focuses on finesse instead of raw ease. You're quite used to wearing a vest to work, and you're alright around a blade as well. Where you go, death follows.|n|nSkills: Tactical Gear(2), Weapons: Rifle(1), Weapons: Low Tech(1)|nTalents: Rifle Modularity, Followup Shot, Off Switch, Gentle Touch, Insulation"
     Presets(11)=(SpecOne=1,SpecTwo=9,FreePoints=1375,MinMax=35,Combat=95,Stealth=5,Difficulty=80)
     PresetNamesNoCrafting(11)="Hitman"
     PresetDescsNoCrafting(11)="Your use of a rifle is respectable, but focuses on finesse instead of raw ease. You're quite used to wearing a vest to work, and you're alright around a blade as well. Where you go, death follows.|n|nSkills: Tactical Gear(2), Weapons: Rifle(1), Weapons: Low Tech(1)|nTalents: Rifle Modularity, Followup Shot, Off Switch, Gentle Touch, Insulation"
     PresetsNoCrafting(11)=(SpecOne=1,SpecTwo=9,FreePoints=1375,MinMax=35,Combat=95,Stealth=5,Difficulty=80)
     
     PresetNames(12)="Pacifist"
     PresetDescs(12)="You're not here to fight. You trust in your ingenuity too much to focus on bypassing things. However, you're still the most agile there's ever been, you can patch up the ocassional hit you take, and you can hack a computer in a pinch.|n|nSkills: Fitness(3), Medicine(1), Software(1)|nTalents: Aquadynamic, Deep, Steady, Tactical Roll, Fall Roll, Trained Professional"
     Presets(12)=(SpecOne=8,SpecTwo=10,FreePoints=200,MinMax=90,Combat=0,Stealth=100,Difficulty=100)
     PresetNamesNoCrafting(12)="Pacifist"
     PresetDescsNoCrafting(12)="You're not here to fight. You trust in your ingenuity too much to focus on bypassing things. However, you're still the most agile there's ever been, you can patch up the ocassional hit you take, and you can hack a computer in a pinch.|n|nSkills: Fitness(3), Medicine(1), Software(1)|nTalents: Aquadynamic, Deep, Steady, Tactical Roll, Fall Roll, Trained Professional"
     PresetsNoCrafting(12)=(SpecOne=8,SpecTwo=10,FreePoints=325,MinMax=90,Combat=0,Stealth=100,Difficulty=100)
     
     PresetNames(13)="Surgeon"
     PresetDescs(13)="You're not here to fight, per se. You'd prefer not to take lives if you can help it. You are, however, quite good at mending wounds and cooking up your own supplies... Including a nasty little something called 'compound 23'... But that's for when shit hits the fan.|n|nSkills: Weapons: Hardware(1), Medicine(2), Low Tech(1)|nTalents: Data Analyst, Medigel Treatment, Pharmacist, PHD In Chemistry, Compound 23, Silent Takedown"
     Presets(13)=(SpecOne=6,SpecTwo=10,FreePoints=1150,MinMax=35,Combat=50,Stealth=50,Difficulty=50)
     PresetNamesNoCrafting(13)="Surgeon"
     PresetDescsNoCrafting(13)="You're not here to fight, per se. You'd prefer not to take lives if you can help it, being handy with a baton in particular, but know how to retrieve darts from a victim, too. In particular, you know how to get maximum mileage from medkits and medbots.|n|nSkills: Weapons: Low Tech(1), Medicine(2), Hardware(1), Software(1)|nTalents: Trained Professional, Walking Closet, Silent Takedown, Dislodge"
     PresetsNoCrafting(13)=(SpecOne=4,SpecTwo=10,FreePoints=525,MinMax=35,Combat=50,Stealth=50,Difficulty=50)
     
     PresetNames(14)="Shadow"
     PresetDescs(14)="They won't smell you, they won't notice you picking a lock, and they might not even notice you palming a weapon. You're dead silent, often hiding in plain sight. Should your plans fail, though, you'll likely have a vest on underneath.|n|nSkills: Tactical Gear(1), Infiltration(2), Weapons: Pistol(1)|nTalents: Off Switch, Low Profile, Keen Instincts, Sleight of Hand, Coverup"
     Presets(14)=(SpecOne=5,SpecTwo=9,FreePoints=475,MinMax=30,Combat=25,Stealth=75,Difficulty=75)
     PresetNamesNoCrafting(14)="Shadow"
     PresetDescsNoCrafting(14)="They won't smell you, they won't notice you picking a lock, and they might not even notice you palming a weapon. You're dead silent, often hiding in plain sight. Should your plans fail, though, you'll likely have a vest on underneath.|n|nSkills: Tactical Gear(1), Infiltration(2), Weapons: Pistol(1)|nTalents: Off Switch, Low Profile, Keen Instincts, Sleight of Hand, Coverup"
     PresetsNoCrafting(14)=(SpecOne=5,SpecTwo=9,FreePoints=475,MinMax=30,Combat=25,Stealth=75,Difficulty=75)
     
     PresetNames(15)="Engineer"
     PresetDescs(15)="STEM is fused into your very essence. While most agents might operate alone, or with another human, you find camaraderie in pure steel. You only skimmed the manuals on handguns and hacking, but your focus is building masterwork drones and miniature turrets.|n|nSkills: Hardware[2], Software[1], Weapons: Pistol[1]|nTalents: M.E.G.H, Reinforced Plating, Illegal Modules, Experimental Skillware, S.I.D.D."
     Presets(15)=(SpecOne=6,SpecTwo=7,FreePoints=475,MinMax=55,Combat=40,Stealth=60,Difficulty=65)
     
     MaxPresetIndex=15
     MaxPresetIndexNoCrafting=15
     
     AdvanceText(0)="|&Resonations"
     AdvanceText(1)="|&Start Game"
     BalanceBarText(0)="Spare Points"
     BalanceBarText(1)="Balance"
     BalanceBarText(2)="Combat Power"
     BalanceBarText(3)="Stealth Power"
     BalanceBarText(4)="Difficulty"
     
     LabelListPos=(X=-2,Y=-39)
     LabelHeaderPos=(X=3,Y=-15)
     ClassPicsPos(0)=(X=135,Y=64)
     ClassPicsPos(1)=(X=331,Y=64)
     ClassListPos=(X=35,Y=64)
     DescBoxPos=(X=51,Y=272)
     BalanceBarPos(0)=(X=466,Y=290)
     BalanceBarPos(1)=(X=466,Y=317)
     BalanceBarPos(2)=(X=466,Y=344)
     BalanceBarPos(3)=(X=466,Y=371)
     BalanceBarPos(4)=(X=466,Y=398)
     BalanceTextPos(0)=(X=-16,Y=-35)
     BalanceTextPos(1)=(X=48,Y=0)
     
     ClassIcons(0)=Texture'SpecializationsIconWeaponPistolsLarge'
     ClassIcons(1)=Texture'SpecializationsIconWeaponRiflesLarge'
     ClassIcons(2)=Texture'SpecializationsIconWeaponHeavyLarge'
     ClassIcons(3)=Texture'SpecializationsIconDemolitionLarge'
     ClassIcons(4)=Texture'SpecializationsIconWeaponLowTechLarge'
     ClassIcons(5)=Texture'SpecializationsIconInfiltrationLarge'
     ClassIcons(6)=Texture'SpecializationsIconElectronicsLarge'
     ClassIcons(7)=Texture'SpecializationsIconComputersLarge'
     ClassIcons(8)=Texture'SpecializationsIconSwimmingLarge'
     ClassIcons(9)=Texture'SpecializationsIconTacticalGearLarge'
     ClassIcons(10)=Texture'SpecializationsIconMedicineLarge'
     
     ClassTipText="If you get overwhelmed with the number of setup steps for character setup, you can pick a preset class here. Otherwise, pick 'custom'."
     ClassTipHeader="About Classes"
     MessageBoxMode=MB_JoinGameWarning
     
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Resonations",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Help",Key="HELP")
     Title="Class Selection"
     ClientWidth=639
     ClientHeight=432
     textureRows=2
     textureCols=3
     clientTextures(0)=Texture'ClassBackground_1'
     clientTextures(1)=Texture'ClassBackground_2'
     clientTextures(2)=Texture'ClassBackground_3'
     clientTextures(3)=Texture'ClassBackground_4'
     clientTextures(4)=Texture'ClassBackground_5'
     clientTextures(5)=Texture'ClassBackground_6'
}
