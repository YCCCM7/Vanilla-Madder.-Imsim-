//=============================================================================
// VMDMenuSelectCustomCampaign
//=============================================================================
class VMDMenuSelectCustomCampaign expands MenuUIScreenWindow config(VMDCustomMaps);

struct VMDButtonPos {
	var int X;
	var int Y;
};

struct VMDMissionNugget {
	var string StartingMapName;
	var string ListedName;
	var string InternalName;
	var string PlayerBindName;
	var string DatalinkID;
	var string MissionDesc;
	var string IconLoadID;
	var string IconLoadID2;
};

var globalconfig VMDMissionNugget KnownMissions[256];

var MenuUILabelWindow ListLabel;
var VMDButtonPos LabelHeaderPos, LabelListPos;
var localized string ListLabelText;

var bool bGavePlayerGuideTip;
var localized string PlayerGuideTipHeader, PlayerGuideTipText;

var VMDButtonPos CampaignIconPos[2];
var Window CampaignIcons[2];

var int CurPresetIndex, MaxPresetIndex;

var MenuUIListWindow CampaignList;
var MenuUIScrollAreaWindow winScroll;

var PersonaInfoWindow DescBox;
var VMDButtonPos CampaignListPos, DescBoxPos;

//MADDERS: Active campaign data.
var int SelectedIndex, TranslateIndices[256];
var float StoredDifficulty;
var string StoredCampaign, StoredStartMap, StoredBindName, StoredDatalinkID;

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
	
	AddTimer(0.1, false,, 'GiveStartTip');
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	Super.CreateControls();
	
	CreateInfoWindow();
	CreateCampaignIcon();
	CreateCampaignLists();
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
	DescBox.SetSize(288, 96);
	DescBox.SetText("---");
}

function CreateCampaignIcon()
{
	local int i;
	for (i=0; i<ArrayCount(CampaignIcons); i++)
	{
		CampaignIcons[i] = NewChild(class'Window');
		CampaignIcons[i].SetPos(CampaignIconPos[i].X, CampaignIconPos[i].Y);
	}
}

function CreateCampaignLists()
{
	local int i;
	local VMDMissionNugget BarfStruct;
	
	if (WinScroll == None)
	{
		winScroll = CreateScrollAreaWindow(winClient);
		winScroll.SetPos(CampaignListPos.X, CampaignListPos.Y);
		winScroll.SetSize(126, 331); //436
	}
	
	if (CampaignList == None)
	{
		CampaignList = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
		//CampaignList.SetPos(CampaignListPos.X, CampaignListPos.Y);
		CampaignList.EnableMultiSelect(False);
		CampaignList.EnableAutoExpandColumns(False);
		CampaignList.EnableHotKeys(False);
		//CampaignList.SetNumColumns(1);
		CampaignList.SetColumnWidth(0, 126);
		CampaignList.SetColumnType(0, COLTYPE_String);
	}
	
	// First erase the old list
	CampaignList.DeleteAllRows();
	
	//MADDERS, 12/11/24: Patch for change in player bind name for Zodiac AI mod. Sigh.
	for(i=0; i<ArrayCount(KnownMissions); i++)
	{
		if (GetCampaignStartingMapName(i) ~= "69_ZODIAC_INTRO")
		{
			BarfStruct.StartingMapName = GetCampaignStartingMapName(i);
			BarfStruct.ListedName = GetCampaignListedName(i);
			BarfStruct.InternalName = GetCampaignInternalName(i);
			BarfStruct.PlayerBindName = GetCampaignPlayerBindName(i);
			if (DynamicLoadObject("ZodiacAudioMission71.ConAudioMission71_0", class'Sound', true) != None)
			{
				BarfStruct.PlayerBindName = "";
			}
			BarfStruct.DatalinkID = GetCampaignDatalinkID(i);
			BarfStruct.MissionDesc = GetCampaignMissionDesc(i);
			BarfStruct.IconLoadID = GetCampaignIconLoadID(i);
			BarfStruct.IconLoadID2 = GetCampaignIconLoadID2(i);
			SetCampaignStructData(i, BarfStruct);
			break;
		}
	}
	
	//MADDERS: Force the first entry every time. Ugly, but that's how we're doing it.
	StoredCampaign = "VANILLA";
	StoredStartMap = "01_NYC_UNATCOIsland";
	StoredBindName = "";
	KnownMissions[0].StartingMapName = "01_NYC_UNATCOIsland";
	KnownMissions[0].ListedName = "Deus Ex";
	KnownMissions[0].InternalName = "Vanilla";
	KnownMissions[0].PlayerBindName = "";
	KnownMissions[0].MissionDesc = "Agent JC Denton starts his first day as an agent of the anti-terrorist organization UNATCO, and must uncover a web of conspiracies to save the world.";
	KnownMissions[0].IconLoadID = "VMDAssets.CustomCampaignPictureVanilla01";
	KnownMissions[0].IconLoadID2 = "VMDAssets.CustomCampaignPictureVanilla02";
	CampaignList.AddRow("Deus Ex");
	LoadUpCampaigns(CampaignList);
	
	CampaignList.SelectToRow(CampaignList.IndexToRowId(0));
	CampaignList.SetFocusRow(CampaignList.IndexToRowId(0));
}

//MADDERS: I'm casting magic to summon from the *OTHERPLACE*...
//Detect map names to exist. If so, add that shit to the list.
function LoadUpCampaigns(MenuUIListWindow CL)
{
	// List of files
	local GameDirectory mapDir;
	local int mapIndex;
	local String mapFileName, TName;
	
	local int i, j, KnownMax, LegitCount;
	local string ConfirmedEntries[256];
	
	MapDir = new(None) Class'GameDirectory';
	MapDir.SetDirType(mapDir.EGameDirectoryTypes.GD_Maps);
	MapDir.GetGameDirectory();
	
	//MADDERS: Slick hack for us to optimize how many times we're checking the array per each entry.
	//Icky, but damn if it isn't effective.
	for (i=0; i<ArrayCount(KnownMissions); i++)
	{
		if (KnownMissions[i].StartingMapName != "")
		{
			KnownMax = i+1;
		}
	}
	
	for( MapIndex=0; MapIndex<MapDir.GetDirCount(); MapIndex++)
	{
		MapFileName = MapDir.GetDirFilename(MapIndex);
		
		for(i=1; i<KnownMax; i++)
		{
			TName = KnownMissions[i].StartingMapName;
			if (TName ~= "") continue;
			
			TName = TName$".dx";
			if (TName ~= MapFileName)
			{
				ConfirmedEntries[i] = KnownMissions[i].ListedName;
				//CL.AddRow(KnownMissions[i].ListedName);
				break;
			}
		}
		
	}
	
	for (i=1; i<KnownMax; i++)
	{
		if (ConfirmedEntries[i] != "")
		{
			TranslateIndices[LegitCount+1] = i;
			LegitCount++;
			CL.AddRow(ConfirmedEntries[i]);
		}
	}
	
	CriticalDelete(MapDir);
	MapDir = None;
}

function CreateLabels()
{
	ListLabel = CreateMenuLabel(CampaignListPos.X+LabelListPos.X, CampaignListPos.Y+LabelListPos.Y, ListLabelText, winClient);
}

function UpdateInfo()
{
	local int i, TranslatedIndex, FCast[5];
	local Texture TTex;
	
	if (SelectedIndex >= 0)
	{
		TranslatedIndex = TranslateIndices[SelectedIndex];
		if (TranslatedIndex >= 0)
		{
			TTex = Texture(DynamicLoadObject(KnownMissions[TranslatedIndex].IconLoadID, class'Texture', true));
			if (TTex != None)
			{
				CampaignIcons[0].SetBackground(TTex);
			}
			else
			{
				TTex = Texture(DynamicLoadObject("VMDAssets.CustomCampaignPictureUnknown01", class'Texture', true));
				if (TTex != None)
				{
					CampaignIcons[0].SetBackground(TTex);
				}
			}
			
			TTex = Texture(DynamicLoadObject(KnownMissions[TranslatedIndex].IconLoadID2, class'Texture', true));
			if (TTex != None)
			{
				CampaignIcons[1].SetBackground(TTex);
			}
			else
			{
				TTex = Texture(DynamicLoadObject("VMDAssets.CustomCampaignPictureUnknown02", class'Texture', true));
				if (TTex != None)
				{
					CampaignIcons[1].SetBackground(TTex);
				}
			}
			
			DescBox.Clear();
			DescBox.SetTitle(KnownMissions[TranslatedIndex].ListedName);
			DescBox.SetText(KnownMissions[TranslatedIndex].MissionDesc);
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
	local int TranslatedIndex;
	
	if (List == CampaignList)
	{
		if (SelectedIndex != CampaignList.RowIDToIndex(RowID))
		{
			SelectedIndex = CampaignList.RowIDToIndex(RowID);
		}
	}
	
	if (SelectedIndex >= 0)
	{
		TranslatedIndex = TranslateIndices[SelectedIndex];
		
		if (TranslatedIndex >= 0)
		{
			StoredCampaign = KnownMissions[TranslatedIndex].InternalName;
			StoredStartMap = KnownMissions[TranslatedIndex].StartingMapName;
			StoredBindName = KnownMissions[TranslatedIndex].PlayerBindName;
			StoredDatalinkID = KnownMissions[TranslatedIndex].DatalinkID;
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
	//	ActionButtons[1].Btn.SetButtonText(AdvanceText[0]);
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
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	switch(CAPS(ActionKey))
	{
		case "FINDMODS":
			InvokeModLocatorWindow();
		break;
		case "HELP":
			root.MessageBox(PlayerGuideTipHeader, PlayerGuideTipText, 1, False, Self);
		break;
		case "START":
			SaveConfig();
			SaveSettings();
			InvokeNewGameScreen(StoredCampaign, StoredStartMap, StoredBindName, StoredDatalinkID);
		break;
	}
}

function GiveStartTip()
{
	if ((VMDBufferPlayer(Player) == None) || (!VMDBufferPlayer(Player).bGaveNewGameTips))
	{
		root.MessageBox(PlayerGuideTipHeader, PlayerGuideTipText, 1, False, Self);
	}
	else
	{
		bGavePlayerGuideTip = true;
	}
}

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

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function InvokeNewGameScreen(string Campaign, string StartMap, string BindName, string TDatalinkID)
{
	local VMDMenuSelectAppearance NewGame;
	local VMDBufferPlayer VMP;
	local Music TMusic;
	
	newGame = VMDMenuSelectAppearance(root.InvokeMenuScreen(Class'VMDMenuSelectAppearance'));
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		//MADDERS: Call relevant reset data.
		VMP.VMDResetNewGameVars(2);
		
		//MADDERS, 7/21/24: Be ready to reset aug types here.
		VMP.bMechAugs = false;
		
		VMP.DatalinkID = TDatalinkID;
		VMP.InvokedBindName = BindName;
		VMP.SelectedCampaign = Campaign;
		VMP.CampaignNewGameMap = StartMap;
		if (Campaign ~= "VANILLA")
		{
			if (bool(DynamicLoadObject("FemJC.FJCJump", class'Sound', True)))
			{
				VMP.bDisableFemaleVoice = False;
			}
			else
			{
				VMP.bDisableFemaleVoice = True;
			}
		}
		else
		{
			VMP.bDisableFemaleVoice = True;
		}
		
		if (VMP.bModdedCharacterSetupMusic)
		{
			switch(CAPS(Campaign))
			{
				case "IWR":
					SetupIWROGG();
				break;
				case "NIHILUM":
					SetupDXNOGG();
				break;
				case "REDSUN":
					ClearDXOgg();
					TMusic = LoadMusic("Redsun_Main_Menu");
					if ((VMP.ModSwappedMusic != TMusic) && (TMusic != None))
					{
						VMP.ModSwappedMusic = TMusic;
						VMP.UpdateDynamicMusic(0.016);
						VMP.ClientSetMusic(VMP.ModSwappedMusic, 0, 255, MTRAN_FastFade);
					}
				break;
				case "ZODIAC":
					ClearDXOgg();
					TMusic = LoadMusic("Zodiac_Splashmap");
					if ((VMP.ModSwappedMusic != TMusic) && (TMusic != None))
					{
						VMP.ModSwappedMusic = TMusic;
						VMP.UpdateDynamicMusic(0.016);
						VMP.ClientSetMusic(VMP.ModSwappedMusic, 0, 255, MTRAN_FastFade);
					}
				break;
				default:
					ClearDXOgg();
					if ((VMP.ModSwappedMusic != None) && (VMP.ModSwappedMusic != VMP.Level.Song))
					{
						VMP.ModSwappedMusic = None;
						VMP.UpdateDynamicMusic(0.016);
						VMP.ClientSetMusic(VMP.ModSwappedMusic, 4, 255, MTRAN_FastFade);
					}
				break;
			}
		}
	}
	if (newGame != None)
	{
		switch(CAPS(Campaign))
		{
			case "BURDEN":
			case "CASSANDRA":
				class'VMDStaticFunctions'.Static.StartCampaign(DeusExPlayer(GetPlayerPawn()), Campaign);
			break;
			default:
				newGame.SetCampaignData(StoredDifficulty, Campaign);
			break;
		}
	}
}

function InvokeModLocatorWindow()
{
	local VMDMenuModLocatorWindow StartingWindow;
	
  	if (Root != None)
  	{
   		StartingWindow = VMDMenuModLocatorWindow(Root.InvokeMenuScreen(Class'VMDMenuModLocatorWindow', True));
		
		if (StartingWindow != None)
		{
			Player.ConsoleCommand("Open https://www.moddb.com/mods/vanilla-madder/news/supported-vmd-mods-w-links");
			
			StartingWindow.VMP = VMDBufferPlayer(Player);
			StartingWindow.CampaignWindow = Self;
			StartingWindow.PopulateFileList();
		}
  	}
}

function Music LoadMusic(string LoadID)
{
	return Music(DynamicLoadObject(LoadID$"."$LoadID, class'Music', true));
}

function SetupDXNOGG()
{
	SetDXOGG("Menu.ogg");
}

function SetupIWROgg()
{
	SetDXOGG("ICanFeel.ogg");
}

function ClearDXOgg()
{
	SetDXOGG("Silence.ogg");
}

function SetDXOGG(string TMus)
{
	local VMDBufferPlayer VMP;
	local Actor DXO;
	local DeusExLevelInfo DXLI;
	local int OMN;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		forEach VMP.AllActors(class'Actor', DXO)
		{
			if ((DXO.IsA('DXOggMusicManager')) && (!DXO.bDeleteMe))
			{
				break;
			}
		}
		
		if (DXO != None)
		{
			DXO.SetPropertyText("AmbientIntroOGGFile", TMus);
			DXO.SetPropertyText("AmbientOGGFile", TMus);
			DXO.SetPropertyText("CombatIntroOGGFile", TMus);
			DXO.SetPropertyText("CombatOGGFile", TMus);
			DXO.SetPropertyText("ConversationIntroOGGFile", TMus);
			DXO.SetPropertyText("ConversationOGGFile", TMus);
			DXO.SetPropertyText("OutroOGGFile", TMus);
			DXO.SetPropertyText("DeathOGGFile", TMus);
			if ((TMus != "") && (CAPS(TMus) != "SILENCE.OGG"))
			{
				DXO.SetPropertyText("MusicMode", "MUS_Combat");
				VMP.ClientSetMusic(None, 5, 255, MTRAN_FastFade);
			}
			else
			{
				DXO.SetPropertyText("MusicMode", "MUS_Conversation");				
			}
		}
	}
}

function SetCampaignData(float NewDiff)
{
	StoredDifficulty = NewDiff;
	SelectedIndex = 0;
	UpdateInfo();
}

function string GetCampaignStartingMapName(int Index)
{
	return KnownMissions[Index].StartingMapName;
}

function string GetCampaignListedName(int Index)
{
	return KnownMissions[Index].ListedName;
}

function string GetCampaignInternalName(int Index)
{
	return KnownMissions[Index].InternalName;
}

function string GetCampaignPlayerBindName(int Index)
{
	return KnownMissions[Index].PlayerBindName;
}

function string GetCampaignDatalinkID(int Index)
{
	return KnownMissions[Index].DatalinkID;
}

function string GetCampaignMissionDesc(int Index)
{
	return KnownMissions[Index].MissionDesc;
}

function string GetCampaignIconLoadID(int Index)
{
	return KnownMissions[Index].IconLoadID;
}

function string GetCampaignIconLoadID2(int Index)
{
	return KnownMissions[Index].IconLoadID2;
}

function SetCampaignStructData(int Index, VMDMissionNugget NewNugget)
{
	KnownMissions[Index] = NewNugget;
}

defaultproperties
{
     KnownMissions(0)=(StartingMapName="01_NYC_UNATCOIsland",ListedName="Deus Ex",InternalName="VANILLA",PlayerBindName="",DatalinkID="",MissionDesc="Agent JC Denton starts his first day as an agent of the anti-terrorist organization UNATCO, and must uncover a web of conspiracies to save the world.",IconLoadID="VMDAssets.CustomCampaignPictureVanilla01",IconLoadID2="VMDAssets.CustomCampaignPictureVanilla02")
     KnownMissions(1)=(StartingMapName="21_Tokyo_Bank",ListedName="Redsun (Demo)",InternalName="REDSUN",PlayerBindName="",DatalinkID="RedsunDemo",MissionDesc="A demo map made but never actually featured in the mod Redsun2020",IconLoadID="VMDAssets.CustomCampaignPictureRedsunDemo01",IconLoadID2="VMDAssets.CustomCampaignPictureRedsunDemo02")
     KnownMissions(2)=(StartingMapName="21_Intro1",ListedName="Redsun 2020",InternalName="REDSUN",PlayerBindName="",DatalinkID="Redsun2020",MissionDesc="Agent Joseph wakes up in a foreign land, and must navigate its labyrinthian underworld to find his way home.",IconLoadID="VMDAssets.CustomCampaignPictureRedsun01",IconLoadID2="VMDAssets.CustomCampaignPictureRedsun02")
     KnownMissions(3)=(StartingMapName="69_Zodiac_Intro",ListedName="Deus Ex: Zodiac",InternalName="ZODIAC",PlayerBindName="PaulDenton",DatalinkID="Zodiac",MissionDesc="In this fan addon of Deus Ex's world, Paul Denton finds himself back in the agent business, and must unravel his own web of conspiracies, one whose heights are out of this world.",IconLoadID="VMDAssets.CustomCampaignPictureZodiac01",IconLoadID2="VMDAssets.CustomCampaignPictureZodiac02")
     KnownMissions(4)=(StartingMapName="16_HotelCarone_Intro",ListedName="Hotel Carone",InternalName="CARONE",PlayerBindName="",DatalinkID="Hotel Carone",MissionDesc="In an imagined alternate branch, JC Denton refuses to betray UNATCO, but must defend one of its secret facilities: Hotel Carone",IconLoadID="VMDAssets.CustomCampaignPictureHotelCarone01",IconLoadID2="VMDAssets.CustomCampaignPictureHotelCarone02")
     //Burden of 80 proof? More like Fuckin' 86 a doof... Us. Gottem.
     //KnownMissions(5)=(StartingMapName="80_Burden_Intro",ListedName="Burden of 80 Proof",InternalName="BURDEN",PlayerBindName="",DatalinkID="Burden",MissionDesc="Peter Kent attempts to balance the demands of his middle class job and his destiny to have a super rad weekend... Hopefully.",IconLoadID="VMDAssets.CustomCampaignPictureBurden01",IconLoadID2="VMDAssets.CustomCampaignPictureBurden02")
     //KnownMissions(5)=(StartingMapName="69_TCP_Intro",ListedName="The Cassandra Project",InternalName="CASSANDRA",PlayerBindName="",DatalinkID="Cassandra",MissionDesc="To quote its ModDB page: 'You are Charlotte Williams, a lower-middle-class English woman turned international Mercenary. With thirty inching ever closer, she becomes disillusioned with her work and is approached by one Nicholas Beckett. He offers her a new job: field agent for a mysterious organisation known as 'The Cassandra Project''... Roll credits..",IconLoadID="VMDAssets.CustomCampaignPictureTCP01",IconLoadID2="VMDAssets.CustomCampaignPictureTCP02")
     KnownMissions(5)=(StartingMapName="50_OmegaStart",ListedName="Omega",InternalName="OMEGA",PlayerBindName="",DatalinkID="Omega",MissionDesc="An unknown man must wander a dreamland turned nightmare, and shut down 3 major bases of opposition.",IconLoadID="VMDAssets.CustomCampaignPictureOmega01",IconLoadID2="VMDAssets.CustomCampaignPictureOmega02")
     KnownMissions(6)=(StartingMapName="59_Intro",ListedName="Deus Ex: Nihilum",InternalName="NIHILUM",PlayerBindName="MadIngram",DatalinkID="Nihilum",MissionDesc="Agent Mad Ingram begins an investigation into matters on foreign soil, and it rapidly risks boiling over to an international incident.",IconLoadID="VMDAssets.CustomCampaignPictureNihilum01",IconLoadID2="VMDAssets.CustomCampaignPictureNihilum02")
     KnownMissions(7)=(StartingMapName="911_NULL",ListedName="Fake Entry",InternalName="OMEGA",PlayerBindName="",DatalinkID="",MissionDesc="You shouldn't be reading this...",IconLoadID="",IconLoadID2="")
     KnownMissions(8)=(StartingMapName="44in",ListedName="ANT Agenda",InternalName="OTHERNOFOOD",PlayerBindName="",DatalinkID="ANT Agenda",MissionDesc="A top secret agent is sent to investigate a suspicious software company called CarevoSoft, and a possible, larger scheme they have at play.",IconLoadID="VMDAssets.CustomCampaignPictureAntAgenda01",IconLoadID2="VMDAssets.CustomCampaignPictureAntAgenda02")
     KnownMissions(9)=(StartingMapName="CF_00_Intro",ListedName="Counterfeit (Demo)",InternalName="COUNTERFEIT",PlayerBindName="",DatalinkID="Counterfeit",MissionDesc="Dominic Bishop is sent on a mission in russia to investigate a possible leak in classified information.",IconLoadID="VMDAssets.CustomCampaignPictureCounterfeit01",IconLoadID2="VMDAssets.CustomCampaignPictureCounterfeit02")
     KnownMissions(10)=(StartingMapName="69_MutationsIntro",ListedName="MUTATIONS",InternalName="MUTATIONS",PlayerBindName="",DatalinkID="Mutations",MissionDesc="JC Denton is called back by Gary Savage several years after the events of Deus Ex 1. He is sent to investigate an unethical science lab lurking deep within a scottish dungeon.",IconLoadID="VMDAssets.CustomCampaignPictureMutations01",IconLoadID2="VMDAssets.CustomCampaignPictureMutations02")
     
     //Fan mission start.
     KnownMissions(11)=(StartingMapName="16_HiveDays_ApartmentComplex",ListedName="Supercarbon: Hive Days",InternalName="HIVEDAYS",PlayerBindName="",DatalinkID="Hive Days",MissionDesc="It is the 32nd millenium. You take the role of an unassuming ex-convict named Jack.",IconLoadID="",IconLoadID2="")
     KnownMissions(12)=(StartingMapName="Gotem",ListedName="Malkavian Mod",InternalName="OTHERNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="If you don't know what this is, just shut up and push 'Play'",IconLoadID="VMDAssets.CustomCampaignPictureMalkavianMod01",IconLoadID2="VMDAssets.CustomCampaignPictureMalkavianMod02")
     KnownMissions(13)=(StartingMapName="01_Base",ListedName="Blood Like Venom",InternalName="BLOODLIKEVENOM",PlayerBindName="",DatalinkID="Blood Like Venom",MissionDesc="In this extra campy mission set, agent Venom sweeps into a religious extremist lab to disarm a nuclear stockpile before it's too late.",IconLoadID="VMDAssets.CustomCampaignPictureBLV01",IconLoadID2="VMDAssets.CustomCampaignPictureBLV02")
     KnownMissions(14)=(StartingMapName="01_ApartmentBuilding",ListedName="Techforce",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="Tech Force",MissionDesc="Agent JC, new to Techforce HQ, is sent to defuse a terrorist situation in downtown Miami.",IconLoadID="VMDAssets.CustomCampaignPictureTechForce01",IconLoadID2="VMDAssets.CustomCampaignPictureTechForce02")
     KnownMissions(15)=(StartingMapName="16_The_HQ",ListedName="Fatal Weapon",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="FatalWeapon",MissionDesc="JC Denton, fresh from defeating the NSF, is sent overseas to make a daring rescue and disarm a chemical weapons threat.",IconLoadID="VMDAssets.CustomCampaignPictureFatalWeapon01",IconLoadID2="VMDAssets.CustomCampaignPictureFatalWeapon02")
     KnownMissions(16)=(StartingMapName="JH1_Intro",ListedName="Double Cross P. 1",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="Double Cross",MissionDesc="After the defeat of MJ12, JC Denton is called in to disarm a new, secret MJ12 lab beneath Ritter Park",IconLoadID="VMDAssets.CustomCampaignPictureRhitterPark01",IconLoadID2="VMDAssets.CustomCampaignPictureRhitterPark02")
     KnownMissions(17)=(StartingMapName="Corruption_Intro",ListedName="Hints of Corruption",InternalName="OTHERPAULNOFOODNOINTRO",PlayerBindName="",DatalinkID="Hints Of Corruption",MissionDesc="Paul Denton is sent to assassinate one of the most powerful men in the world in a Los Angeles facility.",IconLoadID="VMDAssets.CustomCampaignPictureHintsOfCorruption01",IconLoadID2="VMDAssets.CustomCampaignPictureHintsOfCorruption02")
     KnownMissions(18)=(StartingMapName="Bedroom_Remake",ListedName="Break In (Remake)",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="BreakIn",MissionDesc="JC Denton likes pugs and has a suburban life. Now in higher quality.",IconLoadID="VMDAssets.CustomCampaignPictureBreakInRemake01",IconLoadID2="VMDAssets.CustomCampaignPictureBreakInRemake02")
     KnownMissions(19)=(StartingMapName="Bedroom",ListedName="Break In",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="Break In",MissionDesc="JC Denton likes pugs and has a suburban life.",IconLoadID="VMDAssets.CustomCampaignPictureBreakIn01",IconLoadID2="VMDAssets.CustomCampaignPictureBreakIn02")
     KnownMissions(20)=(StartingMapName="16_Castle_Court",ListedName="Castle Court",InternalName="OTHERZEROFOODNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="JC Denton goes to infiltrate a top secret MJ12 training facility after the organization's seeming defeat.",IconLoadID="",IconLoadID2="")
     KnownMissions(21)=(StartingMapName="17_RescueStart",ListedName="Rescue (Great Aroo)",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="Searching for his lost parents, JC Denton investigates a secret facility where they are rumored to be held captive. [This mission is known to have a conflict with another.]",IconLoadID="VMDAssets.CustomCampaignPictureRescueAroo01",IconLoadID2="VMDAssets.CustomCampaignPictureRescueAroo02")
     KnownMissions(22)=(StartingMapName="16_Rescue_Intro",ListedName="Rescue (Beast)",InternalName="OTHERZEROFOODNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="JC Denton is sent is sent on a rescue mission [This mission is known to have a conflict with another.]",IconLoadID="VMDAssets.CustomCampaignPictureRescue01",IconLoadID2="VMDAssets.CustomCampaignPictureRescue02")
     KnownMissions(23)=(StartingMapName="16_Flinschmap",ListedName="DXO: Prologue",InternalName="OTHERZEROFOOD",PlayerBindName="",DatalinkID="DXO",MissionDesc="Chief, I'm gonna be 100%. I don't speak german, but you're held prisoner in a mining camp or something.",IconLoadID="VMDAssets.CustomCampaignPictureDXO01",IconLoadID2="VMDAssets.CustomCampaignPictureDXO02")
     KnownMissions(24)=(StartingMapName="20_Disclosure_Intro",ListedName="Disclosure (Demo)",InternalName="DISCLOSURE",PlayerBindName="",DatalinkID="",MissionDesc="JC Searches for his long lost brother in an abandoned mining facility, but something is wrong.",IconLoadID="VMDAssets.CustomCampaignPictureDisclosure01",IconLoadID2="VMDAssets.CustomCampaignPictureDisclosure02")
     KnownMissions(25)=(StartingMapName="71_Whitehouse",ListedName="Presidential Emergency",InternalName="OTHERNOINTRO",PlayerBindName="",DatalinkID="Presidential Emergency",MissionDesc="Agent JC Denton is sent to rescue the president's daughter from a secret facility where she's being held.",IconLoadID="VMDAssets.CustomCampaignPicturePresidentialEmergency01",IconLoadID2="VMDAssets.CustomCampaignPicturePresidentialEmergency02")
     KnownMissions(26)=(StartingMapName="FluchtWeg",ListedName="Flucht Weg",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="You find your way... Uh... It's more german. I dunno.",IconLoadID="VMDAssets.CustomCampaignPictureFluchtWeg01",IconLoadID2="VMDAssets.CustomCampaignPictureFluchtWeg02")
     KnownMissions(27)=(StartingMapName="Underground_Lab_Intro",ListedName="Underground Lab",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="JC Denton is sent to investigate a genetics research project being carried out in an underground lab.",IconLoadID="VMDAssets.CustomCampaignPictureUndergroundLab01",IconLoadID2="VMDAssets.CustomCampaignPictureUndergroundLab02")
     KnownMissions(28)=(StartingMapName="Utopia_Intro",ListedName="Utopia",InternalName="OTHERNOFOODNOINTRO",PlayerBindName="",DatalinkID="",MissionDesc="JC Denton is sent to reinforce an island utopia that has come under siege from a terrorist organization.",IconLoadID="VMDAssets.CustomCampaignPictureUtopia01",IconLoadID2="VMDAssets.CustomCampaignPictureUtopia02")
     KnownMissions(29)=(StartingMapName="17_FlinschMap",ListedName="DXO: Prologue",InternalName="DXO",PlayerBindName="",DatalinkID="",MissionDesc="You are a prisoner escaping from a german labor camp. Mein Deutsche ist schlecht.",IconLoadID="VMDAssets.CustomCampaignPictureDXO01",IconLoadID2="VMDAssets.CustomCampaignPictureDXO02")
     //Once again, we're bringing nothing to this experience.
     //KnownMissions(30)=(StartingMapName="51_Gville_Downtown",ListedName="DX:IWR",InternalName="IWR",PlayerBindName="AlexDenton",DatalinkID="IWR",MissionDesc="IWR is a re-imagining of Deus Ex Invisible War. You play as the occasionally psychotic amnesiac Alex Denton as he struggles through the vast conspiracies he encounters during his dangerous career as a... delivery boy.",IconLoadID="VMDAssets.CustomCampaignPictureIWR01",IconLoadID2="VMDAssets.CustomCampaignPictureIWR02")
     
     LabelListPos=(X=-2,Y=-39)
     LabelHeaderPos=(X=3,Y=-15)
     CampaignIconPos(0)=(X=172,Y=64)
     CampaignIconPos(1)=(X=428,Y=64)
     CampaignListPos=(X=19,Y=64)
     DescBoxPos=(X=163,Y=304)
     
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Left,Action=AB_Other,Text="|&Help",Key="HELP")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Appearance",Key="START")
     actionButtons(3)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Find Mods",Key="FINDMODS")
     Title="Campaign Selection"
     ClientWidth=639
     ClientHeight=432
     textureRows=2
     textureCols=3
     clientTextures(0)=Texture'CustomCampaignBackground_1'
     clientTextures(1)=Texture'CustomCampaignBackground_2'
     clientTextures(2)=Texture'CustomCampaignBackground_3'
     clientTextures(3)=Texture'CustomCampaignBackground_4'
     clientTextures(4)=Texture'CustomCampaignBackground_5'
     clientTextures(5)=Texture'CustomCampaignBackground_6'
     
     PlayerGuideTipHeader="To New Players"
     PlayerGuideTipText="To play more campaigns, you can use VMD's in-game installer to find more mods you've downloaded."
}
