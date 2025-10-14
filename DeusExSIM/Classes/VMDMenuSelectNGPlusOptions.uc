//=============================================================================
// MenuSelectNGPlusOptions
//=============================================================================
class VMDMenuSelectNGPlusOptions extends MenuUIScreenWindow;

var MapExit Reroute;

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

var localized string	strSetting[64], strDescription[64];
var string		varSetting[64];
var MenuUISliderButtonWindowMini MiniSliders[64], LastMiniSlider;

//Additionally, also on 7/22/21, allow us to support more than simple bools. I hate it, but hey, here we are.
var localized string OverrideLabelValues[64];
var int OverrideSettingCaps[64];

struct VMDButtonPos {
	var int X;
	var int Y;
};

var VMDButtonPos MiniSliderBarPos;

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local string CurMap;
	
	//MADDERS, 4/3/24: During implementation, we no longer have to worry about this being a once-only opportunity.
	//Let players close and reopen as they see fit.
	if (Key == IK_Escape)
	{
		if (Reroute != None)
		{
			Reroute.Level.Game.SendPlayer(Player, Reroute.DestMap);
			return false;
		}
		else
		{
			CurMap = class'VMDStaticFunctions'.Static.VMDGetMapName(Player);
			switch(CurMap)
			{
				case "99_ENDGAME1":
				case "99_ENDGAME2":
				case "99_ENDGAME3":
				case "99_ENDGAME4":
					if (Player != None)
					{
						Player.Level.Game.SendPlayer(Player, "dxonly");
						return false;
					}
				break;
				default:
				break;
			}
		}
	}
	
	return false;
}

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
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------
function CreateControls()
{
	local VMDBufferPlayer VMP;
	
	Super.CreateControls();
	
	//Barf. Force these values on when window opens.
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		VMP.bNGPlusKeepInventory = 3;
		VMP.bNGPlusKeepSkills = 4;
		VMP.bNGPlusKeepAugs = 1;
		VMP.bNGPlusKeepMoney = 1;
		VMP.bNGPlusKeepInfamy = true;
	}
	
	CreateHeaderButtons();
	CreateItemListWindow();
	CreateDescriptionWindow();
}

function CreateDescriptionWindow()
{
	winDescription = LargeTextWindow(winClient.NewChild(Class'LargeTextWindow'));
	winDescription.SetSize( 557, 121 );
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
	btnHeaderValue 	 	= CreateHeaderButton( 428, 17, 138, HeaderValueLabel,	  winClient );
}

function CreateItemListWindow()
{
	winScroll = CreateScrollAreaWindow(winClient);
	
	winScroll.SetPos(7, 38);
	winScroll.SetSize(557, 192);
	
	lstItems = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
	
	lstItems.EnableMultiSelect(False);
	lstItems.EnableAutoExpandColumns(False);
	lstItems.SetNumColumns(3);
	
	lstItems.SetColumnWidth(0, 426);
	lstItems.SetColumnWidth(1, 138);
	lstItems.SetColumnWidth(2, 0);
	lstItems.SetColumnAlignment(1, HALIGN_Left);
	
	lstItems.SetColumnFont(0, Font'FontMenuHeaders');
	lstItems.SetColumnFont(1, Font'FontMenuHeaders');
	
	SetFocusWindow(lstItems);
}

function populateItemList()
{
	local int rowIndex, i, maxEvents, PopulatedCount;
	
	lstItems.DeleteAllRows();
	
	for (i=0; i<arrayCount(strSetting); i++)
	{
		if (strSetting[i] != "")
		{
			rowIndex = lstItems.AddRow(BuildItemString(i));
			if (OverrideSettingCaps[i] > 2)
			{
				MiniSliders[i] = MenuUISliderButtonWindowMini(LstItems.NewChild(class'MenuUISliderButtonWindowMini')); //ClipWindow.
				MiniSliders[i].SetTicks(OverrideSettingCaps[i], 0, OverrideSettingCaps[i]-1);
				MiniSliders[i].WinSlider.SetValue(int(Player.GetPropertyText(VarSetting[i])));
				MiniSliders[i].WinSlider.SetThumbStep(int(Player.GetPropertyText(VarSetting[i])));
				MiniSliders[i].ConfigSetting = VarSetting[i];
				MiniSliders[i].ParentWindow = Self;
				MiniSliders[i].ArrayIndex = PopulatedCount;
				MiniSliders[i].SetPos(MiniSliderBarPos.X, (MiniSliderBarPos.Y * PopulatedCount));
			}
			PopulatedCount += 1;
		}
	}
	
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
			break;

		case btnHeaderValue:
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
	
	//MADDERS, 8/26/25: Don't let us manually fuck with slider settings.
	if (OverrideSettingCaps[IGF] > 2)
	{
		return;
	}
	
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

function SetRowVariable(int UseRow, int NewVal)
{
	local string GF, VS, WriteValue, LabelValue;
	local bool GetValueB, SetValueB;
	local int IGF, GetValueI, SetValueI;
	
	//NOTE: We are only supposed to be used artificially.
	UseRow = LstItems.IndexToRowId(UseRow);
	
	GF = lstItems.GetField(UseRow, 2);
	IGF = int(GF);
	VS = varSetting[IGF];
	
	if (OverrideSettingCaps[IGF] > 2)
	{
		GetValueI = int(Player.GetPropertyText(VS));
		SetValueI = (GetValueI+1) % OverrideSettingCaps[IGF];
		
		if (OverrideLabelValues[IGF] != "")
		{
			LabelValue = ExtractLabelValue(OverrideLabelValues[IGF], NewVal);
		}
		else
		{
			LabelValue = string(NewVal);
		}
		Player.SetPropertyText(VS, String(NewVal));
	}
	else
	{
		if (OverrideLabelValues[IGF] != "")
		{
			LabelValue = ExtractLabelValue(OverrideLabelValues[IGF], NewVal);
		}
		else
		{
			if (NewVal > 0) LabelValue = "On";
			else LabelValue = "Off";
		}
		Player.SetPropertyText(VS, String(NewVal));
	}
	
	WriteValue = lstItems.GetField(UseRow, 0)$";"$LabelValue$";"$lstItems.GetField(UseRow, 2);
	lstItems.ModifyRow(UseRow, WriteValue);
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
	{
		SwitchVariable();
	}
	else if ((ActionKey == "NEXT") && (Root != None))
	{
		Root.InvokeMenuScreen(class'VMDMenuSelectAdditionalDifficultyV2', false);
	}
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------
function SaveSettings()
{
	Super.SaveSettings();
	player.SaveConfig();
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

function MiniSliderChanged()
{
	if (LastMiniSlider != None)
	{
		SetRowVariable(LastMiniSlider.ArrayIndex, int(Player.GetPropertyText(LastMiniSlider.ConfigSetting)));
		LstItems.SelectToRow(LstItems.IndexToRowId(LastMiniSlider.ArrayIndex));
		LstItems.SetFocusRow(LstItems.IndexToRowId(LastMiniSlider.ArrayIndex));
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     HeaderSettingLabel="Setting"
     HeaderValueLabel="Current"
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next",Key="NEXT")
     actionButtons(1)=(Action=AB_Other,Text="|&Switch",Key="SWITCH") 
     Title="New Game Plus Settings"
     ClientWidth=569
     ClientHeight=402
     clientTextures(0)=Texture'VMDAssets.VMDImprovedOptionsBackground01'
     clientTextures(1)=Texture'VMDAssets.VMDImprovedOptionsBackground02'
     clientTextures(2)=Texture'VMDAssets.VMDImprovedOptionsBackground03'
     clientTextures(3)=Texture'VMDAssets.VMDImprovedOptionsBackground04'
     clientTextures(4)=Texture'VMDAssets.VMDImprovedOptionsBackground05'
     clientTextures(5)=Texture'VMDAssets.VMDImprovedOptionsBackground06'
     textureRows=2
     textureCols=3
     bUsesHelpWindow=True
     bEscapeSavesSettings=True
     colDesc=(R=200,G=200,B=200)
     
     MiniSliderBarPos=(X=325,Y=12)
     
     OverrideSettingCaps(0)=5
     strSetting(0)="Keep Inventory"
     varSetting(0)="bNGPlusKeepInventory"
     strDescription(0)="What gear to keep when your new playthrough begins."
     OverrideLabelValues(0)="None|Only Keys|No Weapons|No Weapon Mods|Everything"
     OverrideSettingCaps(1)=5
     strSetting(1)="Keep Skills"
     varSetting(1)="bNGPlusKeepSkills"
     strDescription(1)="What percent of your skill points to keep on new game plus. At 100%, your skills will keep their current levels. At all settings, your talents will be respecced, and resonations cannot change."
     OverrideLabelValues(1)="0%|25%|50%|75%|100%"
     OverrideSettingCaps(2)=3
     strSetting(2)="Keep Augs"
     varSetting(2)="bNGPlusKeepAugs"
     strDescription(2)="How much of your current augmentation to be saved."
     OverrideLabelValues(2)="None|No Upgrades|All"
     OverrideSettingCaps(3)=5
     strSetting(3)="Keep Cash"
     varSetting(3)="bNGPlusKeepMoney"
     strDescription(3)="What percent of your money to keep on new game plus."
     OverrideLabelValues(3)="0%|25%|50%|75%|100%"
     strSetting(4)="Keep Infamy"
     varSetting(4)="bNGPlusKeepInfamy"
     strDescription(4)="If enabled, you will retain all existing infamy score. If infamy is not enabled on your new difficulty, you won't suffer from infamy anyways."     
}
