//=============================================================================
// RevMenuScreenItemRefusal
//
// Created for the mod Deus Ex: Revision, and may be used according to the project licence.
//=============================================================================
class MenuScreenItemRefusal extends MenuUIScreenWindow;

var MenuUIListWindow         lstItems;
var MenuUIScrollAreaWindow   winScroll;
var ButtonWindow             btnLeftArrow;
var ButtonWindow             btnRightArrow;
var LargeTextWindow			 winDescription;

var int selectedRowId;
var int selectedRowIdBackup;
var int row;

var localized String HeaderTypeLabel;
var localized String HeaderTitleLabel;
var localized String HeaderValueLabel;

var localized String strItemType[10];

var MenuUIInfoButtonWindow btnStat;

var MenuUIListHeaderButtonWindow	btnHeaderCategory;
var MenuUIListHeaderButtonWindow	btnHeaderItem;
var MenuUIListHeaderButtonWindow	btnHeaderValue;

//var bool bNumberSortOrder;
//var bool bTitleSortOrder;
//var bool bCompletedSortOrder;

var localized string 	strItemsRifle[4];
var string 				varItemsRifle[4];
var localized string 	strItemsPistol[4];
var string 				varItemsPistol[4];
var localized string 	strItemsHeavy[4];
var string 				varItemsHeavy[4];
var localized string 	strItemsDemo[4];
var string 				varItemsDemo[4];
var localized string 	strItemsLowTech[8];
var string 				varItemsLowTech[8];
var localized string 	strItemsEnviro[5];
var string 				varItemsEnviro[5];
var localized string 	strItemsTools[14];
var string 				varItemsTools[14];
var localized string	strItemsConsumables[9];
var string 				varItemsConsumables[9];

var localized string strItemsNihilum[4];
var string VarItemsNihilum[4];

var MenuUISliderButtonWindowMini MiniSliders[128], LastMiniSlider;

//MADDERS, 6/16/25: Upgrading this system a bit.
var localized string StrRefusalLevels[5];

struct VMDButtonPos {
	var int X;
	var int Y;
};

var bool bGP2;
var int TGP2[128];

var VMDButtonPos MiniSliderBarPos;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------
event InitWindow()
{
	Super.InitWindow();

	ResetToDefaults();

	// Need to do this because of the edit control used for
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);

	Show();
	//SetFocusWindow(editName);

	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------
function CreateControls()
{
	Super.CreateControls();
	
	if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bUseGunplayVersionTwo))
	{
		bGP2 = true;
	}
	
	CreateHeaderButtons();
	CreateItemListWindow();
}

// ----------------------------------------------------------------------
// CreateHeaderButtons()
// ----------------------------------------------------------------------
function CreateHeaderButtons()
{
	btnHeaderCategory 	= CreateHeaderButton( 7,   17, 99,  HeaderTypeLabel,      winClient );
	btnHeaderItem     	= CreateHeaderButton( 108, 17, 330, HeaderTitleLabel,     winClient );
	btnHeaderValue 	 	= CreateHeaderButton( 438, 17, 78, HeaderValueLabel,	  winClient );
}

function CreateItemListWindow()
{
	winScroll = CreateScrollAreaWindow(winClient);

	winScroll.SetPos(7, 40);
	winScroll.SetSize(507, 316);

	lstItems = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));

	lstItems.EnableMultiSelect(False);
	lstItems.EnableAutoExpandColumns(False);
	lstItems.SetNumColumns(5);

	lstItems.SetColumnWidth(0, 106);
	lstItems.SetColumnWidth(1, 330);
	lstItems.SetColumnWidth(2, 78);
	lstItems.SetColumnWidth(3, 0);
	lstItems.SetColumnWidth(4, 0);
	lstItems.SetColumnAlignment(1, HALIGN_Left);
	lstItems.SetColumnAlignment(2, HALIGN_Left);
	lstItems.SetColumnAlignment(3, HALIGN_Right);
	lstItems.SetColumnAlignment(4, HALIGN_Right);

	lstItems.SetColumnFont(0, Font'FontMenuHeaders');
	lstItems.SetColumnFont(1, Font'FontMenuHeaders');
	lstItems.SetColumnFont(2, Font'FontMenuHeaders');
	//lstItems.SetSortColumn(0, False);
	//lstItems.EnableAutoSort(True);

	SetFocusWindow(lstItems);
}

function populateItemList()
{
	local int rowIndex, i, maxEvents, allSection, j, GetVal;
	
	lstItems.DeleteAllRows();

	allSection++;
	for (i=0; i<arrayCount(strItemsRifle); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsRifle[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsRifle[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsPistol); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsPistol[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsPistol[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsHeavy); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsHeavy[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsHeavy[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsDemo); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsDemo[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsDemo[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsLowTech); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsLowTech[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsLowTech[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsEnviro); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsEnviro[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsEnviro[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsTools); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsTools[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[6] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsTools[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsConsumables); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsConsumables[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsConsumables[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsNihilum); i++)
	{
		GetVal = int(Player.GetPropertyText(VarItemsNihilum[i]));
		TGP2[j] = int(bGP2);
		if ((TGP2[j] == 0) && (GetVal == 2 || GetVal == 3))
		{
			TGP2[j] = 1;
		}
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		MiniSliders[j] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
		MiniSliders[j].SetTicks(3 + (TGP2[j] * 2), 0, 2 + (TGP2[j] * 2));
		if ((GetVal == 4) && (TGP2[j] == 0))
		{
			GetVal -= 2;
		}
		MiniSliders[j].WinSlider.SetValue(GetVal);
		MiniSliders[j].WinSlider.SetThumbStep(GetVal);
		MiniSliders[j].ConfigSetting = VarItemsNihilum[i];
		MiniSliders[j].ParentWindow = Self;
		MiniSliders[j].ArrayIndex = j;
		MiniSliders[j].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * j));
		j++;
	}
	
	//lstItems.Sort();
	lstItems.SelectRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	lstItems.SetFocusRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	selectedRowId = selectedRowIdBackup;
}

function String BuildItemString(int num, optional int allSection, optional int num2)
{
	local bool allowed;
	local String section, variable, itemString, itemName;
	//MADDERS, 6/16/25: New label logic.
	local int GetVal, DisplayVal, SnipeIndex;
	
	section = String(num2+1);
	if (Len(section) == 1)
	{
		section = (0 $ section);
	}
	
	switch(allSection)
	{
		case 1: // Rifle
			allowed = !bool(Player.GetPropertyText(varItemsRifle[num]));
			//variable = (varItemsRifle[num]);
			GetVal = int(Player.GetPropertyText(VarItemsRifle[num]));
			itemName = strItemsRifle[num];
			section = strItemType[allSection];
			break;
		case 2: // Pistol
			allowed = !bool(Player.GetPropertyText(varItemsPistol[num]));
			//variable = (varItemsPistol[num]);
			GetVal = int(Player.GetPropertyText(VarItemsPistol[num]));
			itemName = strItemsPistol[num];
			section = strItemType[allSection];
			break;
		case 3: // Heavy
			allowed = !bool(Player.GetPropertyText(varItemsHeavy[num]));
			//variable = (varItemsHeavy[num]);
			GetVal = int(Player.GetPropertyText(VarItemsHeavy[num]));
			itemName = strItemsHeavy[num];
			section = strItemType[allSection];
			break;
		case 4: // Demo
			allowed = !bool(Player.GetPropertyText(varItemsDemo[num]));
			//variable = (varItemsDemo[num]);
			GetVal = int(Player.GetPropertyText(VarItemsDemo[num]));
			itemName = strItemsDemo[num];
			section = strItemType[allSection];
			break;
		case 5: // Low Tech
			allowed = !bool(Player.GetPropertyText(varItemsLowTech[num]));
			//variable = (varItemsLowTech[num]);
			GetVal = int(Player.GetPropertyText(VarItemsLowTech[num]));
			itemName = strItemsLowTech[num];
			section = strItemType[allSection];
			break;
		case 6: // Charged Pickups
			allowed = !bool(Player.GetPropertyText(varItemsEnviro[num]));
			//variable = (varItemsEnviro[num]);
			GetVal = int(Player.GetPropertyText(VarItemsEnviro[num]));
			itemName = strItemsEnviro[num];
			section = strItemType[allSection];
			break;
		case 7: // Tools
			allowed = !bool(Player.GetPropertyText(varItemsTools[num]));
			//variable = (varItemsTools[num]);
			GetVal = int(Player.GetPropertyText(VarItemsTools[num]));
			itemName = strItemsTools[num];
			section = strItemType[allSection];
			break;
		case 8: // Consumables
			allowed = !bool(Player.GetPropertyText(varItemsConsumables[num]));
			//variable = (varItemsConsumables[num]);
			GetVal = int(Player.GetPropertyText(VarItemsConsumables[num]));
			itemName = strItemsConsumables[num];
			section = strItemType[allSection];
			break;
		case 9: // Nihilum
			allowed = !bool(Player.GetPropertyText(varItemsNihilum[num]));
			GetVal = int(Player.GetPropertyText(VarItemsNihilum[num]));
			itemName = strItemsNihilum[num];
			section = strItemType[allSection];
		break;
		Default:
			allowed = true;
			itemName = "?????";
			section = "??";
			break;
	}
	
	switch(AllSection)
	{
		case 1:
			SnipeIndex = Num;
		break;
		case 2:
			SnipeIndex = Num + GetCategoryThreshold("Pistols");
		break;
		case 3:
			SnipeIndex = Num + GetCategoryThreshold("Heavy");
		break;
		case 4:
			SnipeIndex = Num + GetCategoryThreshold("Demo");
		break;
		case 5:
			SnipeIndex = Num + GetCategoryThreshold("LowTech");
		break;
		case 6:
			SnipeIndex = Num + GetCategoryThreshold("Enviro");
		break;
		case 7:
			SnipeIndex = Num + GetCategoryThreshold("Tools");
		break;
		case 8:
			SnipeIndex = Num + GetCategoryThreshold("Consumables");
		break;
		case 9:
			SnipeIndex = Num + GetCategoryThreshold("Nihilum");
		break;
	}
	
	DisplayVal = GetVal;
	if ((TGP2[SnipeIndex] == 0) && (DisplayVal == 2))
	{
		DisplayVal = 4;
	}
	
	//MADDERS, 6/16/25: Just get from a prebuilt array.
	Variable = StrRefusalLevels[DisplayVal];
	
	//itemString = section $ ";" $ itemName $ ";" $ allowed $ ";" $ variable $ ";" $ num2;
	itemString = section $ ";" $ itemName $ ";" $ Variable $ ";" $ variable $ ";" $ num2;
	
	return itemString;
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
		/*case btnHeaderCategory:
			bNumberSortOrder = !bNumberSortOrder;
			lstItems.SetSortColumn( 0, bNumberSortOrder );
			lstItems.Sort();
			break;

		case btnHeaderItem:
			bTitleSortOrder = !bTitleSortOrder;
			lstItems.SetSortColumn( 1, bTitleSortOrder );
			lstItems.Sort();
			break;

		case btnHeaderValue:
			bCompletedSortOrder = !bCompletedSortOrder;
			lstItems.SetSortColumn( 2, bCompletedSortOrder );
			lstItems.Sort();
			break;*/

		default:
			bHandled = False;
			break;
	}

	if ( !bHandled )
		bHandled = Super.ButtonActivated(buttonPressed);

	return bHandled;
}

// ----------------------------------------------------------------------
// ListSelectedChanged()
// ----------------------------------------------------------------------
event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	local int i;

	row = focusRowId;

	// i = int(ListWindow(list).GetField(focusRowId, 4));
	// selectedRowId = i;

	return True;
}

event bool ListRowActivated(window list, int rowId)
{
	//SwitchVariable();
	return true;
}

function SwitchVariable()
{
	local string j, newValue;

	j = lstItems.GetField(row, 3);

	Player.SetPropertyText(j, String(!bool(Player.GetPropertyText(j))));
	Player.SaveConfig();

	newValue = lstItems.GetField(row, 0) $ ";" $
	lstItems.GetField(row, 1) $ ";" $
	!bool(lstItems.GetField(row, 2)) $ ";" $
	lstItems.GetField(row, 3) $ ";" $
	lstItems.GetField(row, 4);
	lstItems.ModifyRow(row, newValue);
}

// ----------------------------------------------------------------------
// ResetToDefaults()
//
// Meant to be called in derived class
// ----------------------------------------------------------------------
function ResetToDefaults()
{
	populateItemList();
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------
event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	// Destroy the msgbox!
	root.PopWindow();

	return True;
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
}

function SaveSettings()
{
}

// ----------------------------------------------------------------------
// ProcessAction()
//
// Meant to be called in derived class
// ----------------------------------------------------------------------
function ProcessAction(String actionKey)
{
	// SaveSettings();

	if (actionKey == "SWITCH")
		SwitchVariable();
	
	else if (actionKey == "ALLTRUE")
		SetAllTrue();
	
	else if (actionKey == "ALLFALSE")
		SetAllFalse();
}

function SetAllFalse()
{
	local string j, newValue;
	local int i;
	
	for (i=0; i<arrayCount(varItemsRifle); i++)
		Player.SetPropertyText(varItemsRifle[i], "True");
	
	for (i=0; i<arrayCount(varItemsPistol); i++)
		Player.SetPropertyText(varItemsPistol[i], "True");
	
	for (i=0; i<arrayCount(varItemsHeavy); i++)
		Player.SetPropertyText(varItemsHeavy[i], "True");
	
	for (i=0; i<arrayCount(varItemsDemo); i++)
		Player.SetPropertyText(varItemsDemo[i], "True");
	
	for (i=0; i<arrayCount(varItemsLowTech); i++)
		Player.SetPropertyText(varItemsLowTech[i], "True");
	
	for (i=0; i<arrayCount(varItemsEnviro); i++)
		Player.SetPropertyText(varItemsEnviro[i], "True");
	
	for (i=0; i<arrayCount(varItemsTools); i++)
		Player.SetPropertyText(varItemsTools[i], "True");
	
	for (i=0; i<arrayCount(varItemsConsumables); i++)
		Player.SetPropertyText(varItemsConsumables[i], "True");
	
	for (i=0; i<arrayCount(varItemsNihilum); i++)
		Player.SetPropertyText(varItemsNihilum[i], "True");
	
	Player.SaveConfig();
		
	populateItemList();
}

function SetAllTrue()
{
	local string j, newValue;
	local int i;
	
	for (i=0; i<arrayCount(varItemsRifle); i++)
		Player.SetPropertyText(varItemsRifle[i], "False");
	
	for (i=0; i<arrayCount(varItemsPistol); i++)
		Player.SetPropertyText(varItemsPistol[i], "False");
	
	for (i=0; i<arrayCount(varItemsHeavy); i++)
		Player.SetPropertyText(varItemsHeavy[i], "False");
	
	for (i=0; i<arrayCount(varItemsDemo); i++)
		Player.SetPropertyText(varItemsDemo[i], "False");
	
	for (i=0; i<arrayCount(varItemsLowTech); i++)
		Player.SetPropertyText(varItemsLowTech[i], "False");
	
	for (i=0; i<arrayCount(varItemsEnviro); i++)
		Player.SetPropertyText(varItemsEnviro[i], "False");
	
	for (i=0; i<arrayCount(varItemsTools); i++)
		Player.SetPropertyText(varItemsTools[i], "False");
	
	for (i=0; i<arrayCount(varItemsConsumables); i++)
		Player.SetPropertyText(varItemsConsumables[i], "False");

	for (i=0; i<arrayCount(varItemsNihilum); i++)
		Player.SetPropertyText(varItemsNihilum[i], "False");

	Player.SaveConfig();
		
	populateItemList();
}

function int GetCategoryThreshold(string Category)
{
	local int Ret;
	
	switch(Category)
	{
		case "Nihilum":
			Ret += ArrayCount(VarItemsConsumables);
		case "Consumables":
			Ret += ArrayCount(VarItemsTools);
		case "Tools":
			Ret += ArrayCount(VarItemsEnviro);
		case "Enviro":
			Ret += ArrayCount(VarItemsLowTech);
		case "LowTech":
			Ret += ArrayCount(VarItemsDemo);
		case "Demo":
			Ret += ArrayCount(VarItemsHeavy);
		case "Heavy":
			Ret += ArrayCount(VarItemsPistol);
		case "Pistol":
			Ret += ArrayCount(VarItemsRifle);
		break;
	}
	
	return ret;
}

function SetRowVariable(int UseRow, int NewVal)
{
	local int allSection, num, num2;
	local bool allowed;
	local String Section, variable, itemString, itemName;
	//MADDERS, 6/16/25: New label logic.
	local int GetVal, DisplayVal;
	
	Num2 = UseRow;
	if (UseRow < GetCategoryThreshold("Pistol"))
	{
		AllSection = 1;
		Num = UseRow;
	}
	else if (UseRow < GetCategoryThreshold("Heavy"))
	{
		AllSection = 2;
		Num = UseRow - GetCategoryThreshold("Pistol");
	}
	else if (UseRow < GetCategoryThreshold("Demo"))
	{
		AllSection = 3;
		Num = UseRow - GetCategoryThreshold("Heavy");
	}
	else if (UseRow < GetCategoryThreshold("LowTech"))
	{
		AllSection = 4;
		Num = UseRow - GetCategoryThreshold("Demo");
	}
	else if (UseRow < GetCategoryThreshold("Enviro"))
	{
		AllSection = 5;
		Num = UseRow - GetCategoryThreshold("LowTech");
	}
	else if (UseRow < GetCategoryThreshold("Tools"))
	{
		AllSection = 6;
		Num = UseRow - GetCategoryThreshold("Enviro");
	}
	else if (UseRow < GetCategoryThreshold("Consumables"))
	{
		AllSection = 7;
		Num = UseRow - GetCategoryThreshold("Tools");
	}
	else if (UseRow < GetCategoryThreshold("Nihilum"))
	{
		AllSection = 8;
		Num = UseRow - GetCategoryThreshold("Consumables");
	}
	else
	{
		AllSection = 9;
		Num = UseRow - GetCategoryThreshold("Nihilum");
	}
	
	//NOTE: We are only supposed to be used artificially.
	UseRow = LstItems.IndexToRowId(UseRow);
	
	switch(allSection)
	{
		case 1: // Rifle
			allowed = !bool(Player.GetPropertyText(varItemsRifle[num]));
			//variable = (varItemsRifle[num]);
			Player.SetPropertyText(VarItemsRifle[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsRifle[num]));
			itemName = strItemsRifle[num];
			section = strItemType[allSection];
			break;
		case 2: // Pistol
			allowed = !bool(Player.GetPropertyText(varItemsPistol[num]));
			//variable = (varItemsPistol[num]);
			Player.SetPropertyText(VarItemsPistol[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsPistol[num]));
			itemName = strItemsPistol[num];
			section = strItemType[allSection];
			break;
		case 3: // Heavy
			allowed = !bool(Player.GetPropertyText(varItemsHeavy[num]));
			//variable = (varItemsHeavy[num]);
			Player.SetPropertyText(VarItemsHeavy[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsHeavy[num]));
			itemName = strItemsHeavy[num];
			section = strItemType[allSection];
			break;
		case 4: // Demo
			allowed = !bool(Player.GetPropertyText(varItemsDemo[num]));
			//variable = (varItemsDemo[num]);
			Player.SetPropertyText(VarItemsDemo[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsDemo[num]));
			itemName = strItemsDemo[num];
			section = strItemType[allSection];
			break;
		case 5: // Low Tech
			allowed = !bool(Player.GetPropertyText(varItemsLowTech[num]));
			//variable = (varItemsLowTech[num]);
			Player.SetPropertyText(VarItemsLowTech[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsLowTech[num]));
			itemName = strItemsLowTech[num];
			section = strItemType[allSection];
			break;
		case 6: // Charged Pickups
			allowed = !bool(Player.GetPropertyText(varItemsEnviro[num]));
			//variable = (varItemsEnviro[num]);
			Player.SetPropertyText(VarItemsEnviro[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsEnviro[num]));
			itemName = strItemsEnviro[num];
			section = strItemType[allSection];
			break;
		case 7: // Tools
			allowed = !bool(Player.GetPropertyText(varItemsTools[num]));
			//variable = (varItemsTools[num]);
			Player.SetPropertyText(VarItemsTools[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsTools[num]));
			itemName = strItemsTools[num];
			section = strItemType[allSection];
			break;
		case 8: // Consumables
			allowed = !bool(Player.GetPropertyText(varItemsConsumables[num]));
			//variable = (varItemsConsumables[num]);
			Player.SetPropertyText(VarItemsConsumables[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsConsumables[num]));
			itemName = strItemsConsumables[num];
			section = strItemType[allSection];
			break;
		case 9: // Nihilum
			allowed = !bool(Player.GetPropertyText(varItemsNihilum[num]));
			Player.SetPropertyText(VarItemsNihilum[num], String(NewVal));
			GetVal = int(Player.GetPropertyText(VarItemsNihilum[num]));
			itemName = strItemsNihilum[num];
			section = strItemType[allSection];
		break;
		Default:
			allowed = true;
			itemName = "?????";
			section = "??";
			break;
	}
	
	DisplayVal = GetVal;
	if ((TGP2[Num2] == 0) && (DisplayVal == 2))
	{
		DisplayVal = 4;
	}
	
	//MADDERS, 6/16/25: Just get from a prebuilt array.
	Variable = StrRefusalLevels[DisplayVal];
	
	//itemString = section $ ";" $ itemName $ ";" $ allowed $ ";" $ variable $ ";" $ num2;
	itemString = section $ ";" $ itemName $ ";" $ Variable $ ";" $ variable $ ";" $ num2;
	lstItems.ModifyRow(UseRow, ItemString);
}

function MiniSliderChanged()
{
	local int UseRow, AllSection, GetVal;
	
	if (LastMiniSlider != None)
	{
		UseRow = LastMiniSlider.ArrayIndex;
		if (UseRow < GetCategoryThreshold("Pistol"))
		{
			AllSection = 1;
		}
		else if (UseRow < GetCategoryThreshold("Heavy"))
		{
			AllSection = 2;
		}
		else if (UseRow < GetCategoryThreshold("Demo"))
		{
			AllSection = 3;
		}
		else if (UseRow < GetCategoryThreshold("LowTech"))
		{
			AllSection = 4;
		}
		else if (UseRow < GetCategoryThreshold("Enviro"))
		{
			AllSection = 5;
		}
		else if (UseRow < GetCategoryThreshold("Tools"))
		{
			AllSection = 6;
		}
		else if (UseRow < GetCategoryThreshold("Consumables"))
		{
			AllSection = 7;
		}
		else if	(UseRow < GetCategoryThreshold("Nihilum"))
		{
			AllSection = 8;
		}
		else
		{
			AllSection = 9;
		}
		
		GetVal = int(Player.GetPropertyText(LastMiniSlider.ConfigSetting));
		if ((TGP2[AllSection] == 0) && (GetVal == 2))
		{
			Player.SetPropertyText(LastMiniSlider.ConfigSetting, "4");
		}
		SetRowVariable(LastMiniSlider.ArrayIndex, GetVal);
		
		LstItems.SelectToRow(LstItems.IndexToRowId(LastMiniSlider.ArrayIndex));
		LstItems.SetFocusRow(LstItems.IndexToRowId(LastMiniSlider.ArrayIndex));
		
		if ((TGP2[AllSection] == 0) && (GetVal == 2))
		{
			Player.SetPropertyText(LastMiniSlider.ConfigSetting, "4");
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     HeaderTypeLabel="Type"
     HeaderTitleLabel="Item"
     HeaderValueLabel="Allowed"
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     //actionButtons(1)=(Action=AB_Other,Text="|&Switch",Key="SWITCH")
	// actionButtons(2)=(Action=AB_Other,Text="All |&True",Key="ALLTRUE")
	// actionButtons(3)=(Action=AB_Other,Text="All |&False",Key="ALLFALSE")
     Title="Item Refusal"
     ClientWidth=519
     ClientHeight=402
     clientTextures(0)=Texture'VMDAssets.ItemRefusalBackground01'
     clientTextures(1)=Texture'VMDAssets.ItemRefusalBackground02'
     clientTextures(2)=Texture'VMDAssets.ItemRefusalBackground03'
     clientTextures(3)=Texture'VMDAssets.ItemRefusalBackground04'
     clientTextures(4)=Texture'VMDAssets.ItemRefusalBackground05'
     clientTextures(5)=Texture'VMDAssets.ItemRefusalBackground06'
     textureRows=2
     textureCols=3
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
     
     MiniSliderBarPos=(X=335,Y=12)
     
     strItemType(0)="???"
     strItemType(1)="Rifles"
     strItemType(2)="Pistols"
     strItemType(3)="Heavy"
     strItemType(4)="Demolitions"
     strItemType(5)="Low-Tech"
     strItemType(6)="Environmental"
     strItemType(7)="Tools"
     strItemType(8)="Consumable"
     strItemType(9)="Nihilum"

     strItemsRifle(0)="Assault Guns"
     strItemsRifle(1)="Assault Shotguns"
     strItemsRifle(2)="Sawed-off Shotguns"
     strItemsRifle(3)="Sniper Rifles"
     varItemsRifle(0)="bRefuseWeaponAssaultGun"
     varItemsRifle(1)="bRefuseWeaponAssaultShotgun"
     varItemsRifle(2)="bRefuseWeaponSawedOffShotgun"
     varItemsRifle(3)="bRefuseWeaponRifle"

     strItemsPistol(0)="Pistols"
     strItemsPistol(1)="Stealth Pistols"
     strItemsPistol(2)="Mini-Crossbows"
     strItemsPistol(3)="PS20s"
     varItemsPistol(0)="bRefuseWeaponPistol"
     varItemsPistol(1)="bRefuseWeaponStealthPistol"
     varItemsPistol(2)="bRefuseWeaponMiniCrossbow"
     varItemsPistol(3)="bRefuseWeaponHideAGun"

     strItemsHeavy(0)="GEP Guns"
     strItemsHeavy(1)="Flamethrowers"
     strItemsHeavy(2)="Plasma Rifles"
     strItemsHeavy(3)="Light Anti-tank Weapons (LAWs)"
     varItemsHeavy(0)="bRefuseWeaponGEPGun"
     varItemsHeavy(1)="bRefuseWeaponFlamethrower"
     varItemsHeavy(2)="bRefuseWeaponPlasmaRifle"
     varItemsHeavy(3)="bRefuseWeaponLAW"

     strItemsDemo(0)="Lightweight Attack Munitions (LAMs)"
     strItemsDemo(1)="Gas Grenades"
     strItemsDemo(2)="EMP Grenades"
     strItemsDemo(3)="Scramble Grenades"
     varItemsDemo(0)="bRefuseWeaponLAM"
     varItemsDemo(1)="bRefuseWeaponGasGrenade"
     varItemsDemo(2)="bRefuseWeaponEMPGrenade"
     varItemsDemo(3)="bRefuseWeaponNanoVirusGrenade"

     strItemsLowTech(0)="Batons"
     strItemsLowTech(1)="Knives"
     strItemsLowTech(2)="Crowbars"
     strItemsLowTech(3)="Swords"
     strItemsLowTech(4)="Nanoswords"
     strItemsLowTech(5)="Riot Prods"
     strItemsLowTech(6)="Pepper Guns"
     strItemsLowTech(7)="Throwing Knives"
     varItemsLowTech(0)="bRefuseWeaponBaton"
     varItemsLowTech(1)="bRefuseWeaponCombatKnife"
     varItemsLowTech(2)="bRefuseWeaponCrowbar"
     varItemsLowTech(3)="bRefuseWeaponSword"
     varItemsLowTech(4)="bRefuseWeaponNanoSword"
     varItemsLowTech(5)="bRefuseWeaponProd"
     varItemsLowTech(6)="bRefuseWeaponPepperGun"
     varItemsLowTech(7)="bRefuseWeaponShuriken"

     strItemsEnviro(0)="Thermoptic Camo"
     strItemsEnviro(1)="Ballistic Armor"
     strItemsEnviro(2)="HazMat Suit"
     strItemsEnviro(3)="Rebreather"
     strItemsEnviro(4)="Tech Goggles"
     varItemsEnviro(0)="bRefuseAdaptiveArmor"
     varItemsEnviro(1)="bRefuseBallisticArmor"
     varItemsEnviro(2)="bRefuseHazMatSuit"
     varItemsEnviro(3)="bRefuseRebreather"
     varItemsEnviro(4)="bRefuseTechGoggles"

     strItemsTools(0)="Multitools"
     strItemsTools(1)="Lockpicks"
     strItemsTools(2)="Weapon Mods"
     strItemsTools(3)="Fire Extinguishers"
     strItemsTools(4)="Flares"
     strItemsTools(5)="Medkits"
     strItemsTools(6)="BioCells"
     strItemsTools(7)="Augmentation Canisters"
     strItemsTools(8)="Augmentation Upgrade Canisters"
     strItemsTools(9)="Binoculars"
     strItemsTools(10)="Compound 23"
     strItemsTools(11)="Ritegel Medical Gel"
     strItemsTools(12)="Chemistry Set"
     strItemsTools(13)="Toolbox"
     varItemsTools(0)="bRefuseMultitool"
     varItemsTools(1)="bRefuseLockpick"
     varItemsTools(2)="bRefuseWeaponMod"
     varItemsTools(3)="bRefuseFireExtinguisher"
     varItemsTools(4)="bRefuseFlare"
     varItemsTools(5)="bRefuseMedKit"
     varItemsTools(6)="bRefuseBioelectricCell"
     varItemsTools(7)="bRefuseAugmentationCannister"
     varItemsTools(8)="bRefuseAugmentationUpgradeCannister"
     varItemsTools(9)="bRefuseBinoculars"
     varItemsTools(10)="bRefuseVMDCombatStim"
     varItemsTools(11)="bRefuseVMDMedigel"
     varItemsTools(12)="bRefuseVMDChemistrySet"
     varItemsTools(13)="bRefuseVMDToolbox"

     strItemsConsumables(0)="Candybars"
     strItemsConsumables(1)="Soda"
     strItemsConsumables(2)="Soy Food"
     strItemsConsumables(3)="Forties"
     strItemsConsumables(4)="Liquor"
     strItemsConsumables(5)="Wine"
     strItemsConsumables(6)="Cigarettes"
     strItemsConsumables(7)="Ambrosia"
     strItemsConsumables(8)="Zyme"
     varItemsConsumables(0)="bRefuseCandybar"
     varItemsConsumables(1)="bRefuseSodacan"
     varItemsConsumables(2)="bRefuseSoyFood"
     varItemsConsumables(3)="bRefuseLiquor40oz"
     varItemsConsumables(4)="bRefuseLiquorBottle"
     varItemsConsumables(5)="bRefuseWineBottle"
     varItemsConsumables(6)="bRefuseCigarettes"
     varItemsConsumables(7)="bRefuseVialAmbrosia"
     varItemsConsumables(8)="bRefuseVialCrack"
     
     StrItemsNihilum(0)="XVA Assault Rifle"
     VarItemsNihilum(0)="bRefuseWeaponAssault17"
     StrItemsNihilum(1)="DXN Pistol"
     VarItemsNihilum(1)="bRefuseWeaponBRGlock"
     StrItemsNihilum(2)="Paratrooper Rifle"
     VarItemsNihilum(2)="bRefuseWeaponM249DXN"
     StrItemsNihilum(3)="Modified Assault Rifle"
     VarItemsNihilum(3)="bRefuseWeaponTakaraGun"
     
     StrRefusalLevels(0)="Okay"
     StrRefusalLevels(1)="No Belt"
     StrRefusalLevels(2)="2 Copies"
     StrRefusalLevels(3)="1 Copy"
     StrRefusalLevels(4)="Refuse"
}
