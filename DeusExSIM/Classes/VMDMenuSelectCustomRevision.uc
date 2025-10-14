//=============================================================================
// VMDMenuSelectCustomRevision
//=============================================================================
class VMDMenuSelectCustomRevision expands MenuUIScreenWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUILabelWindow ListLabel;
var VMDButtonPos LabelHeaderPos, LabelListPos;
var localized string ListLabelText;

var VMDButtonPos RegionIconPos;
var Window RegionIcon;

var MenuUIListWindow RegionList;
var MenuUIScrollAreaWindow winScroll;

var PersonaInfoWindow DescBox;
var VMDButtonPos RegionListPos, DescBoxPos;

var localized string RegionDescs[23];

var int MaxMapStyle;
var string StyleNames[3];
var Texture RegionTexturesVanilla[23], RegionTexturesRevision[23], RegionTexturesVMD[23];

//MADDERS: Active campaign data.
var int SelectedIndex;
var float StoredDifficulty;
var string StoredCampaign;

var int LastMiniSliderValue;
var MenuUISliderButtonWindowMini MiniSliders[128], LastMiniSlider;
var VMDButtonPos MiniSliderBarPos;

var bool bForceIndexZero;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
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
	
	CreateInfoWindow();
	CreateRegionIcon();
	CreateRegionList();
	CreateLabels();
	UpdateInfo();
	
	EnableButtons();
}

// ----------------------------------------------------------------------
// CreateInfoWindows()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
	DescBox = PersonaInfoWindow(winClient.NewChild(Class'PersonaInfoWindow'));
	DescBox.SetPos(DescBoxPos.X, DescBoxPos.Y);
	DescBox.SetSize(278, 96);
	DescBox.SetText("---");
}

function CreateRegionIcon()
{
	RegionIcon = NewChild(class'Window');
	RegionIcon.SetPos(RegionIconPos.X, RegionIconPos.Y);
}

function CreateRegionList()
{
	local int i;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	for (i=0; i<ArrayCount(VMP.MapStyle); i++)
	{
		VMP.MapStyle[i] = VMP.FavoriteMapStyle[i];
	}
	
	if (WinScroll == None)
	{
		winScroll = CreateScrollAreaWindow(winClient);
		winScroll.SetPos(RegionListPos.X, RegionListPos.Y);
		winScroll.SetSize(300, 331);
	}
	
	if (RegionList == None)
	{
		RegionList = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
		RegionList.EnableMultiSelect(False);
		RegionList.EnableAutoExpandColumns(False);
		RegionList.EnableHotKeys(False);
		RegionList.SetNumColumns(3);
		RegionList.SetColumnWidth(0, 200);
		RegionList.SetColumnWidth(1, 100);
		RegionList.SetColumnWidth(2, 0);
		RegionList.SetColumnAlignment(1, HALIGN_Left);
	}
	
	// First erase the old list
	RegionList.DeleteAllRows();
	
	for(i=0; i<ArrayCount(VMP.MapStylePlaceNames); i++)
	{
		RegionList.AddRow(VMP.MapStylePlaceNames[i] $ ";" $ StyleNames[VMP.MapStyle[i]] $ ";"$ i);
		
		MiniSliders[i] = MenuUISliderButtonWindowMini(RegionList.NewChild(class'MenuUISliderButtonWindowMini'));
		MiniSliders[i].SetTicks(MaxMapStyle+1, 0, MaxMapStyle);
		MiniSliders[i].WinSlider.SetValue(VMP.MapStyle[i]);
		MiniSliders[i].WinSlider.SetThumbStep(VMP.MapStyle[i]);
		MiniSliders[i].ConfigSetting = "";
		MiniSliders[i].ParentWindow = Self;
		MiniSliders[i].ArrayIndex = i;
		MiniSliders[i].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * i));
	}
	
	RegionList.SelectToRow(RegionList.IndexToRowId(0));
	RegionList.SetFocusRow(RegionList.IndexToRowId(0));
	SelectedIndex = 0;
	UpdateInfo();
}

function CreateLabels()
{
	ListLabel = CreateMenuLabel(RegionListPos.X+LabelListPos.X, RegionListPos.Y+LabelListPos.Y, ListLabelText, winClient);
}

function UpdateInfo()
{
	local Texture TTex;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (SelectedIndex >= 0)
	{
		switch(VMP.MapStyle[SelectedIndex])
		{
			case 0:
				TTex = RegionTexturesVanilla[SelectedIndex];
			break;
			case 1:
				TTex = RegionTexturesRevision[SelectedIndex];
			break;
			case 2:
				TTex = RegionTexturesVMD[SelectedIndex];
			break;
		}
		
		RegionIcon.SetBackground(TTex);
		
		DescBox.Clear();
		DescBox.SetTitle(VMP.MapStylePlaceNames[SelectedIndex]);
		DescBox.SetText(RegionDescs[SelectedIndex]);
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

event bool ListSelectionChanged(window List, int NumSelections, int RowID)
{
	local int TranslatedIndex;
	
	if (List == RegionList)
	{
		if (SelectedIndex != RegionList.RowIDToIndex(RowID))
		{
			SelectedIndex = RegionList.RowIDToIndex(RowID);
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

function SaveSettings()
{
	local int i;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		for (i=0; i<ArrayCount(VMP.FavoriteMapStyle); i++)
		{
			VMP.FavoriteMapStyle[i] = VMP.MapStyle[i];
		}
		VMP.SaveConfig();
	}
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	switch(CAPS(ActionKey))
	{
		case "RANDOMIZE":
			RandomizeAllRegions();
		break;
		case "START":
			SaveConfig();
			SaveSettings();
			InvokeNewGameScreen();
		break;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function InvokeNewGameScreen()
{
	local VMDMenuSelectAppearance NewGame;
	
	newGame = VMDMenuSelectAppearance(root.InvokeMenuScreen(Class'VMDMenuSelectAppearance'));
	newGame.SetCampaignData(StoredDifficulty, StoredCampaign);
}

function RandomizeAllRegions()
{
	local int i, TRand, RegionCount, NumVanilla, NumRevision, RevisionDiff, VanillaDiff;
	local VMDBufferPlayer VMP;
	
	bForceIndexZero = true;
	AddTimer(0.02, false,, 'StopForceRowZero');
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		for (i=0; i<ArrayCount(VMP.MapStyle); i++)
		{
			VMP.MapStyle[i] = Rand(2);
			UpdateRegionRow(i, VMP.MapStyle[i]);
			
			RegionCount += 1;
			if (VMP.MapStyle[i] == 0) NumVanilla += 1;
			else if (VMP.MapStyle[i] == 1) NumRevision += 1;
			
			MiniSliders[i].WinSlider.SetValue(VMP.MapStyle[i]);
			MiniSliders[i].WinSlider.SetThumbStep(VMP.MapStyle[i]);
		}
		
		//MADDERS, 9/1/25: If our counts are too different, it feels like bad randomization. Roll them back the other way.
		RevisionDiff = NumVanilla - NumRevision;
		VanillaDiff = NumRevision - NumVanilla;
		if (RevisionDiff > 3)
		{
			for (i=0; i<RevisionDiff - Rand(4); i++)
			{
				TRand = Rand(RegionCount);
				if (VMP.MapStyle[TRand] != 0)
				{
					i -= 1;
					continue;
				}
				
				VMP.MapStyle[TRand] = 1;
				UpdateRegionRow(TRand, VMP.MapStyle[TRand]);
				MiniSliders[TRand].WinSlider.SetValue(VMP.MapStyle[TRand]);
				MiniSliders[TRand].WinSlider.SetThumbStep(VMP.MapStyle[TRand]);
			}
		}
		else if (VanillaDiff > 3)
		{
			for (i=0; i<VanillaDiff - Rand(4); i++)
			{
				TRand = Rand(RegionCount);
				if (VMP.MapStyle[TRand] != 1)
				{
					i -= 1;
					continue;
				}
				
				VMP.MapStyle[TRand] = 0;
				UpdateRegionRow(TRand, VMP.MapStyle[TRand]);
				MiniSliders[TRand].WinSlider.SetValue(VMP.MapStyle[TRand]);
				MiniSliders[TRand].WinSlider.SetThumbStep(VMP.MapStyle[TRand]);
			}
		}
		
		UpdateInfo();
	}
	
	RegionList.SelectToRow(RegionList.IndexToRowId(0));
	RegionList.SetFocusRow(RegionList.IndexToRowId(0));
}

function StopForceRowZero()
{
	bForceIndexZero = False;
}

function SetCampaignData(float NewDiff, string NewCampaign)
{
	StoredDifficulty = NewDiff;
	StoredCampaign = NewCampaign;
}

function UpdateRegionRow(int TarRow, int NewValue)
{
	local string NewStr;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	VMP.MapStyle[TarRow] = NewValue;
	NewStr = VMP.MapStylePlaceNames[TarRow] $ ";" $ StyleNames[VMP.MapStyle[TarRow]] $ ";"$ TarRow;
	
	RegionList.ModifyRow(RegionList.IndexToRowId(TarRow), NewStr);
	
	UpdateInfo();
}

function MiniSliderChanged()
{
	if (LastMiniSlider != None)
	{
		UpdateRegionRow(LastMiniSlider.ArrayIndex, LastMiniSliderValue);
		if (bForceIndexZero)
		{
			RegionList.SelectToRow(RegionList.IndexToRowId(0));
			RegionList.SetFocusRow(RegionList.IndexToRowId(0));
		}
		else
		{
			RegionList.SelectToRow(RegionList.IndexToRowId(LastMiniSlider.ArrayIndex));
			RegionList.SetFocusRow(RegionList.IndexToRowId(LastMiniSlider.ArrayIndex));
		}
	}
}

defaultproperties
{
     MaxMapStyle=1 //MADDERS, 8/12/25: To be revisited in phase 3.
     StyleNames(0)="Vanilla"
     StyleNames(1)="Revision"
     StyleNames(2)="VMD"
     
     RegionTexturesVanilla(0)=Texture'RegionPicture00Vanilla'
     RegionTexturesVanilla(1)=Texture'RegionPicture01Vanilla'
     RegionTexturesVanilla(2)=Texture'RegionPicture02Vanilla'
     RegionTexturesVanilla(3)=Texture'RegionPicture03Vanilla'
     RegionTexturesVanilla(4)=Texture'RegionPicture04Vanilla'
     RegionTexturesVanilla(5)=Texture'RegionPicture05Vanilla'
     RegionTexturesVanilla(6)=Texture'RegionPicture06Vanilla'
     RegionTexturesVanilla(7)=Texture'RegionPicture07Vanilla'
     RegionTexturesVanilla(8)=Texture'RegionPicture08Vanilla'
     RegionTexturesVanilla(9)=Texture'RegionPicture09Vanilla'
     RegionTexturesVanilla(10)=Texture'RegionPicture10Vanilla'
     RegionTexturesVanilla(11)=Texture'RegionPicture11Vanilla'
     RegionTexturesVanilla(12)=Texture'RegionPicture12Vanilla'
     RegionTexturesVanilla(13)=Texture'RegionPicture13Vanilla'
     RegionTexturesVanilla(14)=Texture'RegionPicture14Vanilla'
     RegionTexturesVanilla(15)=Texture'RegionPicture15Vanilla'
     RegionTexturesVanilla(16)=Texture'RegionPicture16Vanilla'
     RegionTexturesVanilla(17)=Texture'RegionPicture17Vanilla'
     RegionTexturesVanilla(18)=Texture'RegionPicture18Vanilla'
     RegionTexturesVanilla(19)=Texture'RegionPicture19Vanilla'
     RegionTexturesVanilla(20)=Texture'RegionPicture20Vanilla'
     RegionTexturesVanilla(21)=Texture'RegionPicture21Vanilla'
     RegionTexturesVanilla(22)=Texture'RegionPicture22Vanilla'
     
     RegionTexturesRevision(0)=Texture'RegionPicture00Revision'
     RegionTexturesRevision(1)=Texture'RegionPicture01Revision'
     RegionTexturesRevision(2)=Texture'RegionPicture02Revision'
     RegionTexturesRevision(3)=Texture'RegionPicture03Revision'
     RegionTexturesRevision(4)=Texture'RegionPicture04Revision'
     RegionTexturesRevision(5)=Texture'RegionPicture05Revision'
     RegionTexturesRevision(6)=Texture'RegionPicture06Revision'
     RegionTexturesRevision(7)=Texture'RegionPicture07Revision'
     RegionTexturesRevision(8)=Texture'RegionPicture08Revision'
     RegionTexturesRevision(9)=Texture'RegionPicture09Revision'
     RegionTexturesRevision(10)=Texture'RegionPicture10Revision'
     RegionTexturesRevision(11)=Texture'RegionPicture11Revision'
     RegionTexturesRevision(12)=Texture'RegionPicture12Revision'
     RegionTexturesRevision(13)=Texture'RegionPicture13Revision'
     RegionTexturesRevision(14)=Texture'RegionPicture14Revision'
     RegionTexturesRevision(15)=Texture'RegionPicture15Revision'
     RegionTexturesRevision(16)=Texture'RegionPicture16Revision'
     RegionTexturesRevision(17)=Texture'RegionPicture17Revision'
     RegionTexturesRevision(18)=Texture'RegionPicture18Revision'
     RegionTexturesRevision(19)=Texture'RegionPicture19Revision'
     RegionTexturesRevision(20)=Texture'RegionPicture20Revision'
     RegionTexturesRevision(21)=Texture'RegionPicture21Revision'
     RegionTexturesRevision(22)=Texture'RegionPicture22Revision'
     
     RegionDescs(0)="The introduction sequence of the game, which features many regions seen later."
     RegionDescs(1)="The island UNATCO HQ is based on. Seen in missions 1, 3, 4, and 5."
     RegionDescs(2)="UNATCO HQ itself. Seen in missions 1, 3, 4, and 5."
     RegionDescs(3)="The famous park in New York. Seen in mission 2, 3, and 4."
     RegionDescs(4)="Hell's Kitchen, Underworld Tavern, Ton Hotel, sewers, Smuggler's, free clinic, and both warehouses. Covers missions 2, 4, and 8."
     RegionDescs(5)="Brooklyn Bridge Station, and the mole people tunnels, as seen in mission 3."
     RegionDescs(6)="The airfield, airfield helibase, hangar, and 747 jet, as seen in mission 3."
     RegionDescs(7)="The sublevel of UNATCO, as seen in mission 5."
     RegionDescs(8)="Wan Chai's market, helibase, canals, canal road, and Tonnochi road, as seen in mission 6."
     RegionDescs(9)="The Hong Kong Versalife facility and its adjacent laboratories, as seen in mission 6."
     RegionDescs(10)="The shipyard, PCRS wallcloud, and its interior levels, as seen in mission 9."
     RegionDescs(11)="The graveyard owned by an important figure, as seen in mission 9."
     RegionDescs(12)="The Paris Champs Elysees region, excluding its catacombs, as seen in mission 10."
     RegionDescs(13)="The Paris catacombs, as seen in mission 10."
     RegionDescs(14)="A mansion owned by an important family, as seen in mission 10."
     RegionDescs(15)="The paris cathedral, as seen in mission 11."
     RegionDescs(16)="The domain of an important figure, as seen in mission 11."
     RegionDescs(17)="The science facilities in California, its underground tunnels, and computer core, as seen in mission 12."
     RegionDescs(18)="The abandoned gas station in California, as seen in mission 12."
     RegionDescs(19)="The ocean labs in California, including its underwater section, as seen in mission 14."
     RegionDescs(20)="The missile silos in remote California, as seen in mission 14."
     RegionDescs(21)="The final endgame region, covering all 4 sections it is comprised of, as seen in mission 15."
     RegionDescs(22)="All 3 outro sequences of the game, which feature a variety of regions."
     
     MiniSliderBarPos=(X=99,Y=12)
     
     LabelListPos=(X=-2,Y=-39)
     LabelHeaderPos=(X=3,Y=-15)
     RegionIconPos=(X=371,Y=64)
     RegionListPos=(X=20,Y=40)
     DescBoxPos=(X=329,Y=304)
     
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Appearance",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Randomize",Key="RANDOMIZE")
     Title="Campaign Selection"
     ClientWidth=639
     ClientHeight=432
     textureRows=2
     textureCols=3
     clientTextures(0)=Texture'CustomRevisionBackground_1'
     clientTextures(1)=Texture'CustomRevisionBackground_2'
     clientTextures(2)=Texture'CustomRevisionBackground_3'
     clientTextures(3)=Texture'CustomRevisionBackground_4'
     clientTextures(4)=Texture'CustomRevisionBackground_5'
     clientTextures(5)=Texture'CustomRevisionBackground_6'
}
