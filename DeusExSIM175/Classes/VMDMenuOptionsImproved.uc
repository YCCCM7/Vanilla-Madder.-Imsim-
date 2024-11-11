//=============================================================================
// MenuTranscendedOptions
//=============================================================================
class VMDMenuOptionsImproved extends MenuUIScreenWindow;

var MenuUIListWindow         lstItems;
var MenuUIScrollAreaWindow   winScroll;
var LargeTextWindow			 winDescription;

var int selectedRowId;
var int selectedRowIdBackup;
var int row;

var localized String HeaderSettingLabel;
var localized String HeaderValueLabel;

var MenuUIListHeaderButtonWindow	btnHeaderSetting;
var MenuUIListHeaderButtonWindow	btnHeaderItem;
var MenuUIListHeaderButtonWindow	btnHeaderValue;

var bool bSettingSortOrder;
var bool bTitleSortOrder;
var bool bValueSortOrder;

var Color colDesc;

var localized string	strSetting[64];
var string				varSetting[64];
var localized string	strDescription[64];

//MADDERS, 7/22/21: Only precache once.
var bool bEverCached;

//Additionally, also on 7/22/21, allow us to support more than simple bools. I hate it, but hey, here we are.
var localized string OverrideLabelValues[64];
var int OverrideSettingCaps[64];

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
	
	if ((VMDBufferPlayer(GetPlayerPawn()) != None) && (VMDBufferPlayer(GetPlayerPawn()).bD3DPrecachingEnabled))
	{
		bEverCached = true;
	}
	
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
	CreateDescriptionWindow();
}

function CreateDescriptionWindow()
{
	winDescription = LargeTextWindow(winClient.NewChild(Class'LargeTextWindow'));
	winDescription.SetSize( 477, 121 );
	winDescription.SetPos( 7, 239 );
	winDescription.SetTextMargins(5, 5);
	winDescription.SetFont(Font'FontMenuHeaders');
	winDescription.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winDescription.SetTextColor(colDesc);
}

// ----------------------------------------------------------------------
// CreateHeaderButtons()
// ----------------------------------------------------------------------
function CreateHeaderButtons()
{
	// btnHeaderCategory 	= CreateHeaderButton( 7,   17, 99,  HeaderSettingLabel,      winClient );
	btnHeaderSetting 	= CreateHeaderButton( 7,   17, 419,  HeaderSettingLabel,      winClient );
	// btnHeaderItem     	= CreateHeaderButton( 108, 17, 320, HeaderTitleLabel,     winClient );
	btnHeaderValue 	 	= CreateHeaderButton( 428, 17, 58, HeaderValueLabel,	  winClient );
}

function CreateItemListWindow()
{
	winScroll = CreateScrollAreaWindow(winClient);
	
	winScroll.SetPos(7, 38);
	winScroll.SetSize(477, 192);
	
	lstItems = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
	
	lstItems.EnableMultiSelect(False);
	lstItems.EnableAutoExpandColumns(False);
	lstItems.SetNumColumns(3);
	
	lstItems.SetColumnWidth(0, 426);
	lstItems.SetColumnWidth(1, 58);
	lstItems.SetColumnWidth(2, 0);
	lstItems.SetColumnAlignment(1, HALIGN_Left);
	
	lstItems.SetColumnFont(0, Font'FontMenuHeaders');
	lstItems.SetColumnFont(1, Font'FontMenuHeaders');
	//lstItems.SetSortColumn(0, False);
	//lstItems.EnableAutoSort(True);
	
	SetFocusWindow(lstItems);
}

function populateItemList()
{
	local int rowIndex, i, maxEvents;
	
	lstItems.DeleteAllRows();
	
	for (i=0; i<arrayCount(strSetting); i++)
	{
		if (strSetting[i] != "")
			rowIndex = lstItems.AddRow(BuildItemString(i));
	}
	
	//lstItems.Sort();
	lstItems.SelectRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	lstItems.SetFocusRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	winDescription.SetText(strSetting[selectedRowIdBackup] $ "|n|n" $ strDescription[selectedRowIdBackup]);
	selectedRowId = selectedRowIdBackup;
}

function String BuildItemString(int num)
{
	local string Setting, LabelValue, VS, itemString;
	local bool GetValueB;
	local int GetValueI;
	
	Setting = strSetting[num];
	
	VS = varSetting[num];
	if (OverrideSettingCaps[num] > 2)
	{
		GetValueI = int(Player.GetPropertyText(VS));
		
		if (OverrideLabelValues[num] != "")
		{
			LabelValue = ExtractLabelValue(OverrideLabelValues[num], GetValueI);
		}
		else
		{
			LabelValue = string(GetValueI);
		}
	}
	else
	{
		GetValueB = bool(Player.GetPropertyText(VS));
		
		if (OverrideLabelValues[num] != "")
		{
			LabelValue = ExtractLabelValue(OverrideLabelValues[num], int(GetValueB));
		}
		else
		{
			if (GetValueB) LabelValue = "On";
			else LabelValue = "Off";
		}
	}
	
	itemString = Setting $ ";" $ LabelValue $ ";" $ num;
	
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
		case btnHeaderSetting:
			//bSettingSortOrder = !bSettingSortOrder;
			//lstItems.SetSortColumn( 0, bSettingSortOrder );
			//lstItems.Sort();
			break;

		case btnHeaderValue:
			//bValueSortOrder = !bValueSortOrder;
			//lstItems.SetSortColumn( 1, bValueSortOrder );
			//lstItems.Sort();
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
	local string i;
	
	row = focusRowId;
	
	i = lstItems.GetField(row, 2);
	
	winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)]);
	
	return True;
}

event bool ListRowActivated(window list, int rowId)
{
	SwitchVariable();
	return true;
}

function SwitchVariable()
{
	local string GF, VS, newValue, LabelValue;
	local bool GetValueB, SetValueB;
	local int IGF, GetValueI, SetValueI;
	
	GF = lstItems.GetField(row, 2);
	IGF = int(GF);
	VS = varSetting[IGF];
	
	if (OverrideSettingCaps[IGF] > 2)
	{
		GetValueI = int(Player.GetPropertyText(VS));
		SetValueI = (GetValueI+1) % OverrideSettingCaps[IGF];
		
		if (OverrideLabelValues[IGF] != "")
		{
			LabelValue = ExtractLabelValue(OverrideLabelValues[IGF], SetValueI);
		}
		else
		{
			LabelValue = string(SetValueI);
		}
		Player.SetPropertyText(VS, String(SetValueI));
	}
	else
	{
		GetValueB = bool(Player.GetPropertyText(VS));
		SetValueB = !GetValueB;
		
		if (OverrideLabelValues[IGF] != "")
		{
			LabelValue = ExtractLabelValue(OverrideLabelValues[IGF], int(SetValueB));
		}
		else
		{
			if (SetValueB) LabelValue = "On";
			else LabelValue = "Off";
		}
		Player.SetPropertyText(VS, String(SetValueB));
	}
	
	Player.SaveConfig();
	
	newValue = lstItems.GetField(row, 0)$";"$LabelValue$";"$lstItems.GetField(row, 2);
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
	
	else if (actionKey == "REFUSAL")
		root.InvokeMenuScreen(Class'MenuScreenItemRefusal');
	else if (actionKey == "COLORS")
		root.InvokeMenuScreen(Class'MenuScreenRGB');
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------
function SaveSettings()
{
	Super.SaveSettings();
	player.SaveConfig();
	
	// bEpilepsyReduction
	if (Human(player).bEpilepsyReduction)
	{
		Human(player).DisableFlashingLights();
	}
	
	if ((!bEverCached) && (VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bD3DPrecachingEnabled))
	{
		VMDBufferPlayer(Player).ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
		VMDBufferPlayer(Player).ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
		VMDBufferPlayer(Player).ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
		VMDBufferPlayer(Player).ConsoleCommand("FLUSH");
		VMDBufferPlayer(Player).ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
		VMDBufferPlayer(Player).ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
		VMDBufferPlayer(Player).ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
	}
	
	// bAltSpyDroneView
	/*if (DeusExRootWindow(Player.rootWindow).hud.augDisplay != None)
	{
		if (DeusExRootWindow(Player.rootWindow).hud.augDisplay.winDrone != None)
		{
			DeusExRootWindow(Player.rootWindow).hud.augDisplay.UpdateWinDrone();
		}
	}*/
}

function string ExtractLabelValue(string StartStr, int PosDes)
{
	local int InPos, BreakLen, i;
	local string CurStr, FindStr;
	
	CurStr = StartStr;
	FindStr = "|";
	BreakLen = Len(FindStr);
	
	if (PosDes <= 0)
	{
		InPos = InStr(CurStr, FindStr);
		if (InPos > -1)
		{
			CurStr = Left(CurStr, InPos);
		}
	}
	else
	{
		for (i=0; i<PosDes; i++)
		{
			InPos = InStr(CurStr, FindStr);
			if (InPos > -1)
			{
				CurStr = Right(CurStr, Len(CurStr)-InPos-BreakLen);
			}
		}
		
		InPos = InStr(CurStr, FindStr);
		if (InPos > -1)
		{
			CurStr = Left(CurStr, InPos);
		}
	}
	return CurStr;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     HeaderSettingLabel="Setting"
     HeaderValueLabel="Current"
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(1)=(Action=AB_Other,Text="|&Switch",Key="SWITCH")
     actionButtons(2)=(Action=AB_Other,Text="Item |&Refusal",Key="REFUSAL")	 
     actionButtons(3)=(Action=AB_Other,Text="Custom |&Colors",Key="COLORS")	 
     Title="VMD Settings"
     ClientWidth=489
     ClientHeight=402
     clientTextures(0)=Texture'VMDImprovedOptionsBackground'
     textureRows=2
     textureCols=2
     bUsesHelpWindow=True
     bEscapeSavesSettings=True
     colDesc=(R=200,G=200,B=200)
	 strSetting(0)="Epilepsy Reduction"
	 strSetting(1)="D3D10/11 Precaching"
	 strSetting(2)="Addiction System"
         OverrideLabelValues(2)="Off|Major|All"
         OverrideSettingCaps(2)=3
         
	 strSetting(3)="Hunger System"
	 strSetting(4)="Stress System"
	 strSetting(5)="Smell System"
	 strSetting(6)="Skill Talents System"
         strSetting(7)="Crafting System"
	 strSetting(8)="Immersive Killswitch"
	 strSetting(9)="Limb Damage Effects"
	 strSetting(10)="Automatic Saving"
         strSetting(11)="Dynamic Camera"
         strSetting(12)="Instant Crafting"
         strSetting(13)="Weapon Tilt Effects"
	 strSetting(14)="Hold Refire Semiauto"
	 strSetting(15)="Hit Indicator Icon"
	 strSetting(16)="Hit Indicator Sound"
	 strSetting(17)="Environmental Sounds"
	 strSetting(18)="Modded NG Music"
	 strSetting(19)="Allow Female JC"
	 
	 strDescription(0)="If enabled, flickering lights in levels will be made solid."
	 strDescription(1)="Toggle D3D10/11 precaching, for optimal performance with DDS texture enhancements. Caching will be loaded when enabled. Don't panic."
	 strDescription(2)="Set to what degree you can get addicted to substances: None, Major, or All. Minor is comprised of petty things such as sugar and caffeine."
	 strDescription(3)="Toggle whether you require food to sustain yourself. This system aims to be immersive and discourage save abuse on Gallows difficulty."
	 strDescription(4)="Toggle whether injuries and environmental factors can make your character get stressed. If enabled, good management gives benefit vs no stress system at all."
	 strDescription(5)="Toggle whether foods and blood can produce smell profiles. This system aims to be immersive and discourages excessive food storage and especially excessive murder."
	 strDescription(6)="Enable or disable the talents system on top of normal skill progression. These add functional upgrades. When disabled, 'essential' talents will be treated as if boughten."
	 strDescription(7)="Enable or disable a crafting system, incorporating both Medicine and Hardware skills. On Nightmare and higher difficulty, this will also replace some loot sources with chemicals and scrap."
	 strDescription(8)="Toggle whether any situations with the killswitch will apply debuffs. This system aims to add immersion and challenge."
	 strDescription(9)="If enabled, limb damage will feature expanded effects that impose more challenge in arguably gimmicky ways."
	 strDescription(10)="Toggle whether the game will save automatically when traveling between maps. This is recommended to be left on, and we all know why."
	 strDescription(11)="If enabled, the player's view will be offset forward slightly, much like one's eyeballs in their actual skull. In very rare cases, players may get motion sickness from this effect."
	 strDescription(12)="If enabled, Hardware-based and Medicine-based crafting occurs instantly, and will not close menus unnecessarily."
	 strDescription(13)="If enabled, most animations on weapons will slightly sway the screen."
	 strDescription(14)="If enabled, holding left mouse will make semiautomatic weapons continue to refire, for convenience sake."
	 strDescription(15)="If enabled, hits on enemies will be reflected with an indicator on your HUD. White shows a standard hit. Yellow shows an armor hit. Red shows a critical hit. Orange shows both."
	 strDescription(16)="If enabled, headshots are reinforced with a 'crunch' sound, for satisfying feedback when you perform well, as well as giving clearer feedback."
	 strDescription(17)="If enabled, select sounds will play in the environment, but for immersive purposes. This includes the heartbeat sound at high stress and crafting sounds."
	 strDescription(18)="If enabled, non-vanilla campaigns may change out the character setup music with their main theme. Ya' know. For fun factor."
	 strDescription(19)="Enable this if the Lay D Denton Project (or another parallel project) is installed."
	 
	 varSetting(0)="bEpilepsyReduction"
	 varSetting(1)="bD3DPrecachingEnabled"
	 varSetting(2)="bAddictionEnabled"
	 varSetting(3)="bHungerEnabled"
	 varSetting(4)="bStressEnabled"
	 varSetting(5)="bSmellsEnabled"
	 varSetting(6)="bSkillAugmentsEnabled"
	 varSetting(7)="bCraftingSystemEnabled"
	 varSetting(8)="bImmersiveKillswitch"
	 varSetting(9)="bAdvancedLimbDamage"
	 varSetting(10)="bAutosaveEnabled"
         varSetting(11)="bUseDynamicCamera"
	 varSetting(12)="bUseInstantCrafting"
	 varSetting(13)="bAllowTiltEffects"
	 varSetting(14)="bRefireSemiauto"
	 varSetting(15)="bHitIndicatorHasVisual"
	 varSetting(16)="bHitIndicatorHasAudio"
	 varSetting(17)="bEnvironmentalSoundsEnabled"
	 varSetting(18)="bModdedCharacterSetupMusic"
	 varSetting(19)="bAllowFemJC"
}
