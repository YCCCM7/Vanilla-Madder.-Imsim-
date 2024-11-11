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

var bool bNumberSortOrder;
var bool bTitleSortOrder;
var bool bCompletedSortOrder;

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
var localized string 	strItemsTools[10];
var string 				varItemsTools[10];
var localized string	strItemsConsumables[9];
var string 				varItemsConsumables[9];

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

	CreateHeaderButtons();
	CreateItemListWindow();
}

// ----------------------------------------------------------------------
// CreateHeaderButtons()
// ----------------------------------------------------------------------
function CreateHeaderButtons()
{
	btnHeaderCategory 	= CreateHeaderButton( 7,   17, 99,  HeaderTypeLabel,      winClient );
	btnHeaderItem     	= CreateHeaderButton( 108, 17, 320, HeaderTitleLabel,     winClient );
	btnHeaderValue 	 	= CreateHeaderButton( 428, 17, 58, HeaderValueLabel,	  winClient );
}

function CreateItemListWindow()
{
	winScroll = CreateScrollAreaWindow(winClient);

	winScroll.SetPos(7, 40);
	winScroll.SetSize(477, 316);

	lstItems = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));

	lstItems.EnableMultiSelect(False);
	lstItems.EnableAutoExpandColumns(False);
	lstItems.SetNumColumns(5);

	lstItems.SetColumnWidth(0, 106);
	lstItems.SetColumnWidth(1, 320);
	lstItems.SetColumnWidth(2, 58);
	lstItems.SetColumnWidth(3, 0);
	lstItems.SetColumnWidth(4, 0);
	lstItems.SetColumnAlignment(1, HALIGN_Left);
	lstItems.SetColumnAlignment(2, HALIGN_Left);
	lstItems.SetColumnAlignment(3, HALIGN_Right);
	lstItems.SetColumnAlignment(4, HALIGN_Right);

	lstItems.SetColumnFont(0, Font'FontMenuHeaders');
	lstItems.SetColumnFont(1, Font'FontMenuHeaders');
	lstItems.SetColumnFont(2, Font'FontMenuHeaders');
	lstItems.SetSortColumn(0, False);
	lstItems.EnableAutoSort(True);

	SetFocusWindow(lstItems);
}

function populateItemList()
{
	local int rowIndex, i, maxEvents, allSection, j;
	
	lstItems.DeleteAllRows();

	allSection++;
	for (i=0; i<arrayCount(strItemsRifle); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsPistol); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsHeavy); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsDemo); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsLowTech); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsEnviro); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsTools); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}
	allSection++;
	for (i=0; i<arrayCount(strItemsConsumables); i++)
	{
		rowIndex = lstItems.AddRow(BuildItemString(i, allSection, j));
		j++;
	}

	lstItems.Sort();
	lstItems.SelectRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	lstItems.SetFocusRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	selectedRowId = selectedRowIdBackup;
}

function String BuildItemString(int num, optional int allSection, optional int num2)
{
	local String section;
	local bool allowed;
	local String variable;
	local String itemString;
	local String itemName;

	section = String(num2+1);
	if (Len(section) == 1)
		section = (0 $ section);

	switch(allSection)
	{
		case 1: // Rifle
			allowed = !bool(Player.GetPropertyText(varItemsRifle[num]));
			variable = (varItemsRifle[num]);
			itemName = strItemsRifle[num];
			section = strItemType[allSection];
			break;
		case 2: // Pistol
			allowed = !bool(Player.GetPropertyText(varItemsPistol[num]));
			variable = (varItemsPistol[num]);
			itemName = strItemsPistol[num];
			section = strItemType[allSection];
			break;
		case 3: // Heavy
			allowed = !bool(Player.GetPropertyText(varItemsHeavy[num]));
			variable = (varItemsHeavy[num]);
			itemName = strItemsHeavy[num];
			section = strItemType[allSection];
			break;
		case 4: // Demo
			allowed = !bool(Player.GetPropertyText(varItemsDemo[num]));
			variable = (varItemsDemo[num]);
			itemName = strItemsDemo[num];
			section = strItemType[allSection];
			break;
		case 5: // Low Tech
			allowed = !bool(Player.GetPropertyText(varItemsLowTech[num]));
			variable = (varItemsLowTech[num]);
			itemName = strItemsLowTech[num];
			section = strItemType[allSection];
			break;
		case 6: // Charged Pickups
			allowed = !bool(Player.GetPropertyText(varItemsEnviro[num]));
			variable = (varItemsEnviro[num]);
			itemName = strItemsEnviro[num];
			section = strItemType[allSection];
			break;
		case 7: // Tools
			allowed = !bool(Player.GetPropertyText(varItemsTools[num]));
			variable = (varItemsTools[num]);
			itemName = strItemsTools[num];
			section = strItemType[allSection];
			break;
		case 8: // Consumables
			allowed = !bool(Player.GetPropertyText(varItemsConsumables[num]));
			variable = (varItemsConsumables[num]);
			itemName = strItemsConsumables[num];
			section = strItemType[allSection];
			break;
		Default:
			allowed = true;
			itemName = "?????";
			section = "??";
			break;
	}

	itemString = section $ ";" $ itemName $ ";" $ allowed $ ";" $ variable $ ";" $ num2;

	return itemString;
}

function String BuildElapsedTimeString(float seconds)
{
	local int mins;
	local float secs;
	local string str;

	mins = seconds / 60;
	secs = seconds % 60;

	if (mins < 10)
		str = "0";
	str = str $ mins $ ":";
	if (secs < 10)
		str = str $ "0";
	str = str $ secs;

	return Left(str, InStr(str, ":")) $ Mid(str, InStr(str, ":"), 7); // Draw as many minutes as required, then two seconds, then three milliseconds.
}

// ----------------------------------------------------------------------
// TwoDigits()
// ----------------------------------------------------------------------
function String TwoDigits(int number)
{
	if ( number < 10 )
		return "0" $ number;
	else
		return String(number);
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
		case btnHeaderCategory:
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
			break;

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
	SwitchVariable();
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
	Player.SaveConfig();
		
	populateItemList();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     HeaderTypeLabel="Type"
     HeaderTitleLabel="Item"
     HeaderValueLabel="Allowed"
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(1)=(Action=AB_Other,Text="|&Switch",Key="SWITCH")
	 actionButtons(2)=(Action=AB_Other,Text="All |&True",Key="ALLTRUE")
	 actionButtons(3)=(Action=AB_Other,Text="All |&False",Key="ALLFALSE")
     Title="Item Refusal"
     ClientWidth=489
     ClientHeight=402
     clientTextures(0)=Texture'VMDAssets.ItemRefusalBackground'
     textureRows=2
     textureCols=2
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
     strItemType(0)="???"
     strItemType(1)="Rifles"
     strItemType(2)="Pistols"
     strItemType(3)="Heavy"
     strItemType(4)="Demolitions"
     strItemType(5)="Low-Tech"
     strItemType(6)="Environmental"
     strItemType(7)="Tools"
     strItemType(8)="Consumable"

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
}
