//=============================================================================
// VMDMenuOptionsImproved
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

var string varSetting[128];
var localized string strSetting[128], strDescription[128];
var MenuUISliderButtonWindowMini MiniSliders[128], LastMiniSlider;

//MADDERS, 7/22/21: Only precache once.
var bool bEverCached;

//Additionally, also on 7/22/21, allow us to support more than simple bools. I hate it, but hey, here we are.
var localized string OverrideLabelValues[128], StrCycleBackwards, StrMultipleChoices;
var int OverrideSettingCaps[128];
var string RenderDeviceNames[64];
var int MaxRenderDevice, RenderDeviceFPSSupported[64], RenderDeviceVSyncSupported[64];

struct VMDButtonPos {
	var int X;
	var int Y;
};

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
	local int i, TIndex;
	local VMDBufferPlayer VMP;
	
	Super.CreateControls();
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		if (VMP.bHUDShowAllAugs) VMP.BarfAugDisplayVisibility = 0;
		else if (VMP.bAugDisplayVisible) VMP.BarfAugDisplayVisibility = 1;
		else VMP.BarfAugDisplayVisibility = 2;
		
		VMP.FOVLevelBarf = int((VMP.DefaultFOV - 75) * 0.2);
		VMP.BarfDodgeClickTime = round((VMP.DodgeClickTime - 0.1) / 0.025);
		if (VMP.BarfDodgeClickTime < 0) VMP.BarfDodgeClickTime = 0;
		
		VMP.BarfTacticalRollTime = round((VMP.TacticalRollTime - 0.1) / 0.025);
		if (VMP.BarfTacticalRollTime < 0) VMP.BarfTacticalRollTime = 2;
		
		VMP.BarfStartupFullscreen = bool(GetConfig("WinDrv.WindowsClient", "StartupFullscreen"));
		//VMP.BarfUseDirectInput = bool(GetConfig("WinDrv.WindowsClient", "UseDirectInput"));
		
		VMP.BarfUIScale = (VMP.CustomUIScale-1);
		for(i=0; i<ArrayCount(RenderDeviceNames); i++)
		{
			if (CAPS(RenderDeviceNames[i]) == "UNKNOWN")
			{
				MaxRenderDevice = i-1;
				break;
			}
		}
		
		VMDArmRenderDeviceBullshit();
	}
	
	CreateHeaderButtons();
	CreateItemListWindow();
	CreateDescriptionWindow();
}

function int Round(float In)
{
	local int Cast;
	
	Cast = int(In);
	if (float(Cast) == In) return int(In);
	
	if (In-Cast >= 0.5)
	{
		return int(In)+1;
	}
	else
	{
		return int(In);
	}
}

function VMDCycleRenderDevice(bool bBackwards)
{
	local class<Object> LoadDevice;
	local int DeviceIndex, i;
	local string TDevice;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (VMP == None) return;
	
	for (i=0; i<(MaxRenderDevice+1); i++)
	{
		if (bBackwards)
		{
			VMP.RenderDeviceBarf -= 1;
			if (VMP.RenderDeviceBarf < 0) VMP.RenderDeviceBarf = MaxRenderDevice;
		}
		else
		{
			VMP.RenderDeviceBarf += 1;
			if (VMP.RenderDeviceBarf > MaxRenderDevice) VMP.RenderDeviceBarf = 0;
		}
		
		TDevice = RenderDeviceNames[VMP.RenderDeviceBarf];
		LoadDevice = class<Object>(DynamicLoadObject(TDevice, class'Class', true));
		if (LoadDevice != None)
		{
			break;
		}
	}
	
	VMDArmRenderDeviceBullshit(true);
}

function VMDArmRenderDeviceBullshit(optional bool bKnowsDevice)
{
	local int i, Frame1, Frame2;
	local string TDevice;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (VMP == None) return;
	
	if (bKnowsDevice)
	{
		TDevice = RenderDeviceNames[VMP.RenderDeviceBarf];
		VMP.FPSCapBarf = 0;
		if ((VMP.RenderDeviceBarf <= MaxRenderDevice) && (RenderDeviceFPSSupported[VMP.RenderDeviceBarf] > 0))
		{
			Frame1 = int((float(GetConfig(TDevice, "FrameRateLimit")) - 20.0) / 20);
			Frame2 = int((float(GetConfig(TDevice, "FPSLimit")) - 20.0) / 20);
			VMP.FPSCapBarf = Max(Frame1, Frame2);
			if (VMP.FPSCapBarf < 0) VMP.FPSCapBarf = 0;
		}
		VMP.VSyncBarf = false;
		if ((VMP.RenderDeviceBarf <= MaxRenderDevice) && (RenderDeviceVSyncSupported[VMP.RenderDeviceBarf] > 0))
		{
			VMP.VSyncBarf = bool(GetConfig(TDevice, "VSync"));
		}
		SaveSettings();
	}
	else
	{
		TDevice = CAPS(GetConfig("Engine.Engine", "GameRenderDevice"));
		for (i=0; i<(MaxRenderDevice+1); i++)
		{
			if (i > MaxRenderDevice || TDevice == CAPS(RenderDeviceNames[i]))
			{
				VMP.RenderDeviceBarf = i;
				VMP.FPSCapBarf = 0;
				VMP.VSyncBarf = false;
				if (i <= MaxRenderDevice)
				{
					if (RenderDeviceFPSSupported[i] > 0)
					{
						VMP.FPSCapBarf = Max( int((float(GetConfig(TDevice, "FrameRateLimit")) - 20.0) / 20), int((float(GetConfig(TDevice, "FPSLimit")) - 20.0) / 20) );
						if (VMP.FPSCapBarf < 0) VMP.FPSCapBarf = 0;
					}
					if (RenderDeviceVSyncSupported[VMP.RenderDeviceBarf] > 0)
					{
						VMP.VSyncBarf = bool(GetConfig(TDevice, "VSync"));
					}
				}
				break;
			}
		}
	}
	
	if (LstItems != None)
	{
		SetRowVariable(VMDGetSettingIndex("Render Device (Backup)"), VMP.RenderDeviceBarf); //Finally, utilize this bad boy.
		SetRowVariable(VMDGetSettingIndex("FPS Cap"), VMP.FPSCapBarf); //Slap this bitch in, if already initialized.
		SetRowVariable(VMDGetSettingIndex("VSync"), int(VMP.VSyncBarf)); //Slap this bitch in, if already initialized.
	}
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
	//lstItems.SetSortColumn(0, False);
	//lstItems.EnableAutoSort(True);
	
	SetFocusWindow(lstItems);
}

function PopulateItemList()
{
	local int rowIndex, i, maxEvents, PopulatedCount;
	local MenuUISliderButtonWindowMini TSlider;
	
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
	
	//lstItems.Sort();
	lstItems.SelectRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	lstItems.SetFocusRow(lstItems.IndexToRowId(selectedRowIdBackup), True);
	if (StrDescription[selectedRowIdBackup] != "")
	{
		winDescription.SetText(strSetting[selectedRowIdBackup] $ "|n|n" $ strDescription[selectedRowIdBackup]);
	}
	
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
	
	if (StrDescription[int(i)] != "")
	{
		if (CAPS(VarSetting[int(i)]) == "RENDERDEVICEBARF")
		{
			winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)] $ "|n|n" $ StrCycleBackwards);	
		}
		else if (OverrideSettingCaps[int(i)] > 2)
		{
			winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)] $ "|n|n" $ StrMultipleChoices);	
		}
		else
		{
			winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)]);
		}
	}
	
	return True;
}

event bool ListRowActivated(window list, int rowId)
{
	SwitchVariable();
	return true;
}

function SwitchVariable()
{
	local bool GetValueB, SetValueB, bSub;
	local int IGF, GetValueI, SetValueI, AddRate;
	local string TDevice, GF, VS, newValue, LabelValue, CurVal;
	local VMDBufferPlayer VMP;
	
	GF = lstItems.GetField(row, 2);
	IGF = int(GF);
	VS = varSetting[IGF];
	CurVal = CAPS(Default.varSetting[IGF]);
	
	VMP = VMDBufferPlayer(Player);
	if (CurVal == "FPSCAPBARF")
	{
		if (RenderDeviceFPSSupported[VMP.RenderDeviceBarf] <= 0)
		{
			return;
		}
	}
	if (CurVal == "VSYNCBARF")
	{
		if (RenderDeviceVSyncSupported[VMP.RenderDeviceBarf] <= 0)
		{
			return;
		}
	}
	
	//MADDERS, 3/28/25: Don't let us manually fuck with slider settings.
	if (OverrideSettingCaps[IGF] > 2)
	{
		return;
	}
	
	AddRate = 1;
	if ((Root != None) && (Root.IsKeyDown(IK_Shift))) AddRate = 2;
	if ((Root != None) && (Root.IsKeyDown(IK_Ctrl))) bSub = true;
	
	if (CurVal == "RENDERDEVICEBARF")
	{
		VMDCycleRenderDevice(bSub);
		return;
	}
	else if (OverrideSettingCaps[IGF] > 2 || CurVal == "BARFUISCALE")
	{
		GetValueI = int(Player.GetPropertyText(VS));
		if (bSub)
		{
			SetValueI = (GetValueI-AddRate);
			if (SetValueI < 0) SetValueI = OverrideSettingCaps[IGF] - Abs(SetValueI);
		}
		else
		{
			SetValueI = (GetValueI+AddRate) % OverrideSettingCaps[IGF];
		}
		
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
	
	SaveSettings();
	
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
	local bool OldFullscreen;
	local string TDevice;
	local Engine TEngine;
	local VMDBufferPlayer VMP;
	
	Super.SaveSettings();
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		VMP.bHUDShowAllAugs = true;
		VMP.bAugDisplayVisible = true;
		if (VMP.BarfAugDisplayVisibility == 2)
		{
			VMP.bAugDisplayVisible = false;
		}
		if (VMP.BarfAugDisplayVisibility > 0)
		{
			VMP.bHUDShowAllAugs = false;
		}
		if (VMP.AugmentationSystem != None)
		{
			VMP.AugmentationSystem.RefreshAugDisplay();
		}
		
		VMP.CustomUIScale = (VMP.BarfUIScale+1);
		
		//MADDERS, 6/24/24: Wicked hack for updating fullscreen preference.
		OldFullscreen = bool(GetConfig("WinDrv.WindowsClient", "StartupFullscreen"));
		if (VMP.BarfStartupFullscreen)
		{
			if (!OldFullscreen)
			{
				VMP.ConsoleCommand("TOGGLEFULLSCREEN");	
			}
			VMP.ConsoleCommand("Set WinDrv.WindowsClient StartupFullscreen true");
		}
		else
		{
			if (OldFullscreen)
			{
				VMP.ConsoleCommand("TOGGLEFULLSCREEN");	
			}
			VMP.ConsoleCommand("Set WinDrv.WindowsClient StartupFullscreen false");
		}
		
		//VMP.ConsoleCommand("Set WinDrv.WindowsClient UseDirectInput"@string(VMP.BarfUseDirectInput));
		
		TDevice = RenderDeviceNames[VMP.RenderDeviceBarf];
		
		if (CAPS(TDevice) != "UNKNOWN")
		{
			class'VMDRenderFudger'.Static.SetNewRenderDevice(TDevice);
		}
		
		switch(CAPS(TDevice))
		{
			case "OPENGLDRV.OPENGLRENDERDEVICE":
			case "D3D9DRV.D3D9RENDERDEVICE":
				if (VMP.FPSCapBarf == 0)
				{
					VMP.ConsoleCommand("Set"@TDevice@"FrameRateLimit 0");
				}
				else
				{
					VMP.ConsoleCommand("Set"@TDevice@"FrameRateLimit"@((VMP.FPSCapBarf * 20) + 20));
				}
			break;
			case "D3D10DRV.D3D10RENDERDEVICE":
			case "D3D11DRV.D3D11RENDERDEVICE":
				if (VMP.FPSCapBarf == 0)
				{
					VMP.ConsoleCommand("Set"@TDevice@"FPSLimit 0");
				}
				else
				{
					VMP.ConsoleCommand("Set"@TDevice@"FPSLimit"@((VMP.FPSCapBarf * 20) + 20));
				}
				
				if (!VMP.VSyncBarf)
				{
					VMP.ConsoleCommand("Set"@TDevice@"VSync false");
				}
				else
				{
					VMP.ConsoleCommand("Set"@TDevice@"VSync true");
				}
			break;
			default:
				//Do nothing.
			break;
		}
		
		if (VMP.bEpilepsyReduction)
		{
			VMP.DisableFlashingLights();
		}
		
		if ((!VMP.bLogVisible) && (DeusExRootWindow(VMP.RootWindow) != None) && (DeusExRootWindow(VMP.RootWindow).HUD != None) && (DeusExRootWindow(VMP.RootWindow).HUD.MsgLog != None))
		{
			DeusExRootWindow(VMP.RootWindow).HUD.MsgLog.Hide();
		}
		
		VMP.ConsoleCommand("FOV"@string(75+(VMP.FOVLevelBarf*5)));
		VMP.DodgeClickTime = (VMP.BarfDodgeClickTime * 0.025) + 0.1;
		VMP.TacticalRollTime = (VMP.BarfTacticalRollTime * 0.025) + 0.1;
		
		if ((!bEverCached) && (VMP.bD3DPrecachingEnabled))
		{
			VMP.ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache True");
			VMP.ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache True");
			VMP.ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache True");
			VMP.ConsoleCommand("FLUSH");
			VMP.ConsoleCommand("Set D3D9Drv.D3D9RenderDevice UsePrecache False");
			VMP.ConsoleCommand("Set D3D10Drv.D3D10RenderDevice Precache False");
			VMP.ConsoleCommand("Set D3D11Drv.D3D11RenderDevice Precache False");
		}
	}
	
	player.SaveConfig();
	
	// bAltSpyDroneView
	/*if ((Player != None) && (DeusExRootWindow(Player.rootWindow)) && (DeusExRootWindow(Player.rootWindow).augDisplay != None))
	{
		if (DeusExRootWindow(Player.rootWindow).augDisplay.winDrone != None)
		{
			DeusExRootWindow(Player.rootWindow).augDisplay.UpdateWinDrone();
		}
	}*/
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

function int VMDGetSettingIndex(string FindSetting)
{
	local int i;
	
	FindSetting = CAPS(FindSetting);
	for(i=0; i<ArrayCount(StrSetting); i++)
	{
		if (CAPS(Default.StrSetting[i]) == FindSetting)
		{
			return i;
		}
	}
	
	return -1;
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
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(1)=(Action=AB_Other,Text="|&Switch",Key="SWITCH")
     actionButtons(2)=(Action=AB_Other,Text="Item |&Refusal",Key="REFUSAL")	 
     actionButtons(3)=(Action=AB_Other,Text="Custom |&Colors",Key="COLORS")	 
     Title="VMD Settings"
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
     
     StrCycleBackwards="" //"Hold control while cycling option to cycle backwards."
     StrMultipleChoices="" //"Hold control while cycling option to cycle backwards. Hold shift to cycle at 2x the rate."
     
     RenderDeviceNames(0)="GlideDrv.GlideRenderDevice"
     RenderDeviceFPSSupported(0)=0
     RenderDeviceVSyncSupported(0)=0
     RenderDeviceNames(1)="SoftDrv.SoftwareRenderDevice"
     RenderDeviceFPSSupported(1)=0
     RenderDeviceVSyncSupported(1)=0
     RenderDeviceNames(2)="OpenGLDrv.OpenGLRenderDevice"
     RenderDeviceFPSSupported(2)=0 //NOTE: This runs like turbo dogshit when you limit OpenGL's FPS. Don't allow this for sanity sake.
     RenderDeviceVSyncSupported(2)=0
     RenderDeviceNames(3)="D3DDrv.D3DRenderDevice"
     RenderDeviceFPSSupported(3)=0
     RenderDeviceVSyncSupported(3)=0
     RenderDeviceNames(4)="D3D9Drv.D3D9RenderDevice"
     RenderDeviceFPSSupported(4)=1
     RenderDeviceVSyncSupported(4)=0
     RenderDeviceNames(5)="D3D10Drv.D3D10RenderDevice"
     RenderDeviceFPSSupported(5)=1
     RenderDeviceVSyncSupported(5)=1
     RenderDeviceNames(6)="D3D11Drv.D3D11RenderDevice"
     RenderDeviceFPSSupported(6)=1
     RenderDeviceVSyncSupported(6)=1
     RenderDeviceNames(7)="Unknown"
     RenderDeviceFPSSupported(7)=0
     RenderDeviceVSyncSupported(7)=0
     
     MiniSliderBarPos=(X=325,Y=12)
     
     OverrideSettingCaps(0)=1
     strSetting(0)="----Accessibility-----------"
     varSetting(0)="BARF"
     OverrideLabelValues(0)="----"
     strDescription(0)=""
     
     strSetting(1)="Action Button To Holster"
     varSetting(1)="bFrobEmptyLowersWeapon"
     strDescription(1)="If enabled, using the action button on nothing will lower your current weapon or item, unless it is reloading."
     strSetting(2)="Automatic Saving"
     varSetting(2)="bAutosaveEnabled"
     strDescription(2)="Toggle whether the game will save automatically when traveling between maps. This is recommended to be left on, and we all know why."
     strSetting(3)="Appearance Auto-load"
     varSetting(3)="bAutoloadAppearanceSlots"	 
     strDescription(3)="If enabled, switching to a new slot in the appearance menu will automatically load it, discarding current changes. This is a retro option."
     strSetting(4)="Clearer Aug Noise"
     varSetting(4)="bBoostAugNoise"
     strDescription(4)="If enabled, augmentations will be louder when on, to better inform the player they are using energy."
     strSetting(5)="Display Uncraftable Items"
     varSetting(5)="bDisplayUncraftableItems"
     strDescription(5)="If enabled, chemistry set, toolbox, and bot crafting windows will skip displaying uncraftable items that you don't currently own."
     OverrideSettingCaps(6)=7
     strSetting(6)="Dodge Input Window"
     varSetting(6)="BarfDodgeClickTime"
     strDescription(6)="The time window allowed for double tap to dodge with the Untouchable talent. Increments by 0.025 seconds at base."
     OverrideLabelValues(6)="0.10s|0.125s|0.15s|0.175s|0.20s|0.225s|0.25s"
     strSetting(7)="Draw Keyring For Doors"
     varSetting(7)="bDoorFrobKeyRing"
     strDescription(7)="If enabled, trying to open a locked door that you have the key for will draw the keyring automatically."
     OverrideSettingCaps(8)=3
     strSetting(8)="Draw Lockpick/Crowbar For Doors"
     varSetting(8)="DoorFrobLockpick"
     strDescription(8)="If enabled, trying to open a locked door that can be lockpicked or cracked with a crowbar will draw the most effective implement automatically. If set to No Key, this will only happen when no key exists."
     OverrideLabelValues(8)="Disabled|No Key|Always"
     strSetting(9)="Draw Multitool For Electronics"
     varSetting(9)="bElectronicsDrawMultitool"
     strDescription(9)="If enabled, trying to use an electronic device that needs hacking will draw a multitool automatically."
     strSetting(10)="Epilepsy Reduction"
     varSetting(10)="bEpilepsyReduction"
     strDescription(10)="If enabled, flickering lights in levels will be made solid, and screen flashing will be disabled."
     OverrideSettingCaps(11)=8
     strSetting(11)="Field Of View (FOV)"
     varSetting(11)="FOVLevelBarf"
     strDescription(11)="This scales the visible area around the player up or down, 75-110. Increments by 5 units at base."
     OverrideLabelValues(11)="75|80|85|90|95|100|105|110"
     strSetting(12)="Hold Refire Semiauto"
     varSetting(12)="bRefireSemiauto"
     strDescription(12)="If enabled, holding left mouse will make semiautomatic weapons continue to refire, for convenience sake."
     strSetting(13)="Holster For Decorations"
     varSetting(13)="bDecorationFrobHolster"
     strDescription(13)="If enabled, trying to grab a decoration (such as a container or box) will holster your in-hand item if it would be obstructive."
     strSetting(14)="No Screen Flash"
     varSetting(14)="VMDbNoScreenFlash"
     strDescription(14)="If enabled, the screen will not use flashing, as seen in the original game prior to the multiplayer patch. This is also disabled by Epilepsy Reduction."
     OverrideSettingCaps(15)=7
     strSetting(15)="Roll Input Window"
     varSetting(15)="BarfTacticalRollTime"
     strDescription(15)="The time window allowed for pushing jump after ducking to use the Tactical Roll talent. Increments by 0.025 seconds at base."
     OverrideLabelValues(15)="0.10s|0.125s|0.15s|0.175s|0.20s|0.225s|0.25s"
     
     OverrideSettingCaps(16)=1
     strSetting(16)=" "
     varSetting(16)="BARF"
     OverrideLabelValues(16)=" "
     strDescription(16)=""
     OverrideSettingCaps(17)=1
     strSetting(17)="----Advanced Display Settings--"
     varSetting(17)="BARF"
     OverrideLabelValues(17)="----"
     strDescription(17)=""
     
     strSetting(18)="D3D10/11 Precaching"
     varSetting(18)="bD3DPrecachingEnabled"
     strDescription(18)="Toggle D3D10/11 precaching, for optimal performance with DDS texture enhancements. Caching will be loaded when enabled. Don't panic."
     OverrideSettingCaps(19)=11
     strSetting(19)="FPS Cap"
     varSetting(19)="FPSCapBarf"
     strDescription(19)="The target FPS to render the game at, Uncapped or 40-240. Increments by 20 units at base. Decreasing may improve performance consistency, but in most cases you should aim for 60 or above."
     OverrideLabelValues(19)="Uncapped|40|60|80|100|120|140|160|180|200|220|240"
     strSetting(20)="Start Game Fullscreen"
     varSetting(20)="BarfStartupFullscreen"
     strDescription(20)="Toggle whether the game starts in windowed or fullscreen mode automatically. Changing this will toggle your current fullscreen status for convenience."
     OverrideSettingCaps(21)=3
     strSetting(21)="UI Scaling"
     varSetting(21)="BarfUIScale"
     strDescription(21)="The scale with which to draw the user interface. Available in 1x and 2x, thanks to Kentie's hard work on DX1. Do note: 2x may be too large for some screens in VMD, depending on target resolution."
     OverrideLabelValues(21)="Auto|1x|2x"
     strSetting(22)="VSync"
     varSetting(22)="VSyncBarf"
     strDescription(22)="The whether or not to slow FPS down to at most 60, in order to eliminate screen tearing caused by rapid changes on the display."
     //OverrideSettingCaps(22)=7
     ///strSetting(22)="Render Device (Backup)"
     ///varSetting(22)="RenderDeviceBarf"
     ///strDescription(22)="If the render device window doesn't work for you, you may change it here. It will only cycle through valid, existing devices. Restart to apply."
     ///OverrideLabelValues(22)="3DFX Glide (Old)|Software (Old)|Open GL|DirectX 7 (Old)|DirectX 9|DirectX 10|DirectX 11|Unknown"
     
     OverrideSettingCaps(23)=1
     strSetting(23)=" "
     varSetting(23)="BARF"
     OverrideLabelValues(23)=" "
     strDescription(23)=""
     OverrideSettingCaps(24)=1
     strSetting(24)="----Camera Settings-----------"
     varSetting(24)="BARF"
     OverrideLabelValues(24)="----"
     strDescription(24)=""
     
     strSetting(25)="Dynamic Camera"
     varSetting(25)="bUseDynamicCamera"
     strDescription(25)="If enabled, the player's view will be offset forward slightly, much like one's eyeballs in their actual skull. In very rare cases, players may get motion sickness from this effect."
     strSetting(26)="Hand Tilt Effects"
     varSetting(26)="bAllowPlayerHandsTiltEffects"
     strDescription(26)="If enabled, immersive, empty player hands will sway the screen subtly in stride with their current action."
     strSetting(27)="Pickup Tilt Effects"
     varSetting(27)="bAllowPickupTiltEffects"
     strDescription(27)="If enabled, animations on the keyring, lockpick, and multitool will slightly sway the screen."
     strSetting(28)="Weapon Tilt Effects"
     varSetting(28)="bAllowTiltEffects"
     strDescription(28)="If enabled, most animations on weapons will slightly sway the screen."
     
     OverrideSettingCaps(29)=1
     strSetting(29)=" "
     varSetting(29)="BARF"
     OverrideLabelValues(29)=" "
     strDescription(29)=""
     OverrideSettingCaps(30)=1
     strSetting(30)="----HUD Settings------------"
     varSetting(30)="BARF"
     OverrideLabelValues(30)="----"
     strDescription(30)=""
     
     strSetting(31)="HUD Master Visibility"
     varSetting(31)="bHUDVisible"
     strDescription(31)="Whether or not to display the entirety of the HUD. Only augmentation HUD and visual effects will be drawn over the game view if it is disabled."
     strSetting(32)="Aim Focuser Visibility"
     varSetting(32)="bAimFocuserVisible"
     strDescription(32)="Whether or not to display how focused your aim is, which acts a sort of secondary crosshair."
     strSetting(33)="Ammo Display Visibility"
     varSetting(33)="bAmmoDisplayVisible"
     strDescription(33)="Whether or not to display a small portrait of your current item, along with its remaining resources."
     OverrideSettingCaps(34)=3
     strSetting(34)="Aug Display Visibility"
     varSetting(34)="BarfAugDisplayVisibility"
     strDescription(34)="The degree to which aug icons will be shown."
     OverrideLabelValues(34)="All|Active|None"
     strSetting(35)="Compass Visibility"
     varSetting(35)="bCompassVisible"
     strDescription(35)="Whether or not to display the compass, for knowing your directional bearing."
     strSetting(36)="Crosshair Visibility"
     varSetting(36)="bCrosshairVisible"
     strDescription(36)="Whether or not to display the crosshair and the hit indicator."
     strSetting(37)="Drone Alliance Visibility"
     varSetting(37)="bDroneAllianceVisible"
     strDescription(37)="Whether or not to display what your drones (if any) think of the target you're looking at."
     strSetting(38)="Health Portrait Visibility"
     varSetting(38)="bHitDisplayVisible"
     strDescription(38)="Whether or not the paper doll of your character's health is displayed, along with its various bars and a directional damage indicator."
     strSetting(39)="Hit Indicator Icon"
     varSetting(39)="bHitIndicatorHasVisual"
     strDescription(39)="If enabled, hits on enemies will be reflected with an indicator on your HUD. White shows a standard hit. Yellow shows an armor hit. Red shows a critical hit. Orange shows both."
     strSetting(40)="Hit Indicator Sound"
     varSetting(40)="bHitIndicatorHasAudio"
     strDescription(40)="If enabled, headshots are reinforced with a 'crunch' sound, for satisfying feedback when you perform well, as well as giving clearer feedback."
     strSetting(41)="Item Highlight Borders"
     varSetting(41)="bFrobDisplayBordersVisible"
     strDescription(41)="Whether or not to display a bounding box around objects within touching range."
     strSetting(42)="Light Gem Visibility"
     varSetting(42)="bLightGemVisible"
     strDescription(42)="Whether or not to display a light gem that recolors itself based on how exposed you are to enemy vision."
     strSetting(43)="Log Visibility"
     varSetting(43)="bLogVisible"
     strDescription(43)="Whether or not to display a text log with information and various flavor messages specific to VMD."
     strSetting(44)="Object Belt Visibility"
     varSetting(44)="bObjectBeltVisible"
     strDescription(44)="Whether or not the object belt is displayed."
     strSetting(45)="Object Name Visibility"
     varSetting(45)="bObjectNames"
     strDescription(45)="Whether or not to display item names for objects within touching range."
     strSetting(46)="Skill Notifier Visibility"
     varSetting(46)="bSkillNotifierVisible"
     strDescription(46)="Whether or not to display icons notifying you of new skill rank ups being possible."
     strSetting(47)="Smell Indicator Visibility"
     varSetting(47)="bSmellIndicatorVisible"
     strDescription(47)="Whether or not to display a set of icons related to active smells. They can always be checked in the status screen."
     strSetting(48)="Subtitles Visibility"
     varSetting(48)="bSubtitles"
     strDescription(48)="Whether or not to display subtitles during conversations."
     
     OverrideSettingCaps(49)=1
     strSetting(49)=" "
     varSetting(49)="BARF"
     OverrideLabelValues(49)=" "
     strDescription(49)=""
     OverrideSettingCaps(50)=1
     strSetting(50)="----Gameplay Systems------------"
     varSetting(50)="BARF"
     OverrideLabelValues(50)="----"
     strDescription(50)=""
     
     OverrideSettingCaps(51)=3
     strSetting(51)="Addiction System"
     varSetting(51)="bAddictionEnabled"
     strDescription(51)="Set to what degree you can get addicted to substances: None, Major, or All. Minor is comprised of petty things such as sugar and caffeine."
     OverrideLabelValues(51)="Off|Major|All"
     strSetting(52)="Classic Skill Purchasing"
     varSetting(52)="bClassicSkillPurchasing"
     strDescription(52)="If enabled, purchasing skills will bring up a prompt menu instead of relying on held inputs."
     strSetting(53)="Crafting System"
     varSetting(53)="bCraftingSystemEnabled"
     strDescription(53)="Enable or disable a crafting system, incorporating both Medicine and Hardware skills. On Nightmare and higher difficulty, this will also replace some loot sources with chemicals and scrap."
     strSetting(54)="Instant Crafting"
     varSetting(54)="bUseInstantCrafting"
     strDescription(54)="If enabled, Hardware-based and Medicine-based crafting occurs instantly, and will not close menus unnecessarily."
     strSetting(55)="Environmental Sounds"
     varSetting(55)="bEnvironmentalSoundsEnabled"
     strDescription(55)="If enabled, select sounds will play in the environment, but for immersive purposes. This includes the heartbeat sound at high stress and crafting sounds."
     strSetting(56)="Gunplay 2.0 (ALPHA)"
     varSetting(56)="bUseGunplayVersionTwo"
     strDescription(56)="When enabled, gunplay is radically overhauled to be more like that of a tactial shooter, versus Deus Ex's RPG-heavy RPG-shooter. While not game breaking, the balance and presentation is currently underbaked."
     strSetting(57)="Hunger System"
     varSetting(57)="bHungerEnabled"
     strDescription(57)="Toggle whether you require food to sustain yourself. This system aims to be immersive and discourage save abuse on Gallows difficulty."
     strSetting(58)="Hunger Bio Usage"
     varSetting(58)="bBioHungerEnabled"
     strDescription(58)="Toggle whether bio energy will be consumed instead of taking damage, if hunger runs out."
     strSetting(59)="Immersive Killswitch"
     varSetting(59)="bImmersiveKillswitch"
     strDescription(59)="Toggle whether any situations with the killswitch will apply debuffs. This system aims to add immersion and challenge."
     strSetting(60)="Smell System"
     varSetting(60)="bSmellsEnabled"
     strDescription(60)="Toggle whether foods and blood can produce smell profiles. This system aims to be immersive and discourages excessive food storage and especially excessive murder."
     strSetting(61)="Skill Talents System"
     varSetting(61)="bSkillAugmentsEnabled"
     strDescription(61)="Enable or disable the talents system on top of normal skill progression. These add functional upgrades. When disabled, 'essential' talents will be treated as if boughten."
     strSetting(62)="Stress System"
     varSetting(62)="bStressEnabled"
     strDescription(62)="Toggle whether injuries and environmental factors can make your character get stressed. If enabled, good management gives benefit vs no stress system at all."
     
     OverrideSettingCaps(63)=1
     strSetting(63)=" "
     varSetting(63)="BARF"
     OverrideLabelValues(63)=" "
     strDescription(63)=""
     OverrideSettingCaps(64)=1
     strSetting(64)="----Misc Settings------------"
     varSetting(64)="BARF"
     OverrideLabelValues(64)="----"
     strDescription(64)=""
     
     strSetting(65)="Allow Any NG Plus"
     varSetting(65)="bAllowAnyNGPlus"
     strDescription(65)="If enabled, female JCs are allowed to NG plus into campaigns with improper use of pronouns, which may otherwise harm immersion."
     strSetting(66)="Allow Female JC"
     varSetting(66)="bAllowFemJC"
     strDescription(66)="Enable this if the Lay D Denton Project (or another parallel project) is installed."
     strSetting(67)="Allow Vanilla Reskins"
     varSetting(67)="bVanillaReskinsEnabled"
     strDescription(67)="If enabled, non-critical NPCs throughout the vanilla campaign will have their skins updated. This setting is only applied during a map's first load."
     strSetting(68)="Controller Augs Display Points"
     varSetting(68)="bAugControllerShowEnergyPoints"
     strDescription(68)="If enabled, the controller aug menu will display raw energy points and not a percentage. Recommended for DX Rando."
     strSetting(69)="Damage Gate Break Noise"
     varSetting(69)="bDamageGateBreakNoise"
     strDescription(69)="If enabled, enemies on high difficulties will make a distinct feedback sound for having their damage gates broken."
     strSetting(70)="Immersive Player Hands"
     varSetting(70)="bPlayerHandsEnabled"
     strDescription(70)="If enabled, your empty hands will draw your actual hands on your screen, instead of nothing."
     strSetting(71)="Jump Duck Sound"
     varSetting(71)="bJumpDuckFeedbackNoise"
     strDescription(71)="If enabled, Fit as a Fiddle's jump duck will make a noise for more feedback."
     
     //strSetting(72)="Direct Mouse Input"
     //varSetting(72)="BarfUseDirectInput"
     //strDescription(72)="If enabled, direct mouse input will be used instead of standard mouse input. This may solve weird mouse movement for some users. Requires a game restart to take effect."
     
     strSetting(73)="MEGH Recon Ping"
     varSetting(73)="bMEGHRadarPing"
     strDescription(73)="If enabled, the MEGH drone will produce radar pings when spotting targets for the first time."
     strSetting(74)="Modded NG Music"
     varSetting(74)="bModdedCharacterSetupMusic"
     strDescription(74)="If enabled, non-vanilla campaigns may change out the character setup music with their main theme. Ya' know. For fun factor."
     OverrideSettingCaps(75)=4
     strSetting(75)="Realistic Roll Camera"
     varSetting(75)="bRealisticRollCamera"
     strDescription(75)="If enabled, using talents to roll around will move your camera like it would in real life. This can affect either the dodge roll, the fall/tactical roll, or both."
     OverrideLabelValues(75)="Off|Dodge|Fall|Both"
     strSetting(76)="Realtime Controller Augs"
     varSetting(76)="bRealtimeControllerAugs"
     strDescription(76)="If enabled, the controller-friendly aug menu will play in real time, instead of pausing the game. This is not affected by the above setting."
     strSetting(77)="Realtime UI"
     varSetting(77)="bRealtimeUI"
     strDescription(77)="If enabled, menus won't pause the game (except for certain crafting windows, the main menu, and the controller-friendly aug menu)"

     OverrideSettingCaps(78)=1
     strSetting(78)=" "
     varSetting(78)="BARF"
     OverrideLabelValues(78)=" "
     strDescription(78)=""
     OverrideSettingCaps(79)=1
     strSetting(79)="++++Revision Settings++++++++++++"
     varSetting(79)="BARF"
     OverrideLabelValues(79)="----"
     strDescription(79)=""
     
     strSetting(80)="Use Revision Soundtrack"
     varSetting(80)="bUseRevisionSoundtrack"
     strDescription(80)="If enabled, Revision maps will use the newer Revision soundtrack."
}
