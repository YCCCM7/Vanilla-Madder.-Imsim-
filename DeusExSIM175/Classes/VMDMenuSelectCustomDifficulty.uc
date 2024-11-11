//=============================================================================
// VMDMenuSelectCustomDifficulty
//=============================================================================
class VMDMenuSelectCustomDifficulty expands MenuUIScreenWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var bool bGavePlayerGuideTip, bDisarmed;
var int OverrideSliderWidth, SliderShiftX;

var localized string DamageSliderText, TimerSliderText, HPSliderText,
			PlayerGuideTipHeader, PlayerGuideTipText,
			PresetNames[8], TipHeaders[8], TipTexts[8],
			DamageEnumerations[7], TimerEnumerations[7], HPEnumerations[7],
			PresetsLabelText, PresetLabel;

//var MenuUIHelpWindow PresetsLabel;
var MenuUILabelWindow PresetsLabel;

var MenuUIListWindow lstItems;
var MenuUIScrollAreaWindow winScroll;
var LargeTextWindow winDescription;

var int selectedRowId, selectedRowIdBackup, row;
var Color colDesc;

var string varSetting[64];
var localized string strSetting[64], strDescription[64], OverrideLabelValues[64];
var int OverrideSettingCaps[64];

var MenuUIChoiceSlider DamageSlider, TimerSlider, HPSlider;
var VMDButtonPos DamageSliderPos, TimerSliderPos, HPSliderPos,
			WinScrollPos, WinScrollSize, WinDescriptionPos, WinDescriptionSize,
			PresetsLabelPos, PresetsLabelSize;

var int PresetButtonWidth;
var VMDButtonPos PresetButtonPos[8];
var MenuUIMenuButtonWindow PresetButtons[8];

// ----------------------------------------------------------------------
// MADDERS: 4/14/22: Vanilla function bullshit. Clustered together because it has minimal value.
// ----------------------------------------------------------------------

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

function bool CanStack()
{
	return false;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	if (Key == IK_Escape)
	{
		ReturnToTitle();
		//AddTimer(0.1, False,, 'ReturnToTitle');
		return true;
	}
	
	return false;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
	return false;
}

function TileWindow CreateTileWindow(Window parent)
{
	local TileWindow tileWindow;
	
	// Create Tile Window inside the scroll window
	tileWindow = TileWindow(parent.NewChild(Class'TileWindow'));
	tileWindow.SetFont( class'PersonaEditWindow'.Default.FontText );
	tileWindow.SetOrder(ORDER_Down);
	tileWindow.SetChildAlignments(HALIGN_Full, VALIGN_Top);
	tileWindow.MakeWidthsEqual(False);
	tileWindow.MakeHeightsEqual(False);
	
	return tileWindow;
}

function TileWindow CreateScrollTileWindow(int posX, int posY, int sizeX, int sizeY)
{
	local TileWindow tileWindow;
	local PersonaScrollAreaWindow winScroll;
	
	winScroll = VMDMenuUIScrollAreaWindow(winClient.NewChild(Class'VMDMenuUIScrollAreaWindow'));
	winScroll.SetPos(posX, posY);
	winScroll.SetSize(sizeX, sizeY);
	
	tileWindow = CreateTileWindow(winScroll.clipWindow);
	
	return tileWindow;
}

// ----------------------------------------------------------------------
// TECHNICAL SHIT END!
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	// Need to do this because of the edit control used for 
	// saving games.
	SetMouseFocusMode(MFOCUS_Click);
	
	Show();
	
	StyleChanged();
	
	CreateLabelWindow();
	CreateSliderWindow();
	CreatePresetButtons();
	CreateDescriptionWindow();
	CreateItemListWindow();
	PopulateItemList();
	
	LoadPreset(2);
	
	AddTimer(0.1, false,, 'GiveStartTip');
}

function CreateLabelWindow()
{
	PresetsLabel = CreateMenuLabel(PresetsLabelPos.X, PresetsLabelPos.Y, PresetsLabelText, winClient);
	
	/*PresetsLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	PresetsLabel.SetSize(PresetsLabelSize.X, PresetsLabelSize.Y);
	PresetsLabel.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	PresetsLabel.SetText(PresetsLabelText);
	PresetsLabel.SetPos(PresetsLabelPos.X, PresetsLabelPos.Y);*/
}

function CreateSliderWindow()
{
	local int WidthChange, i;
	local MenuUISliderButtonWindow TSli;
	local MenuUIChoiceButton TAc;
	
	DamageSlider = VMDMiniMenuUIChoiceSlider(WinClient.NewChild(Class'VMDMiniMenuUIChoiceSlider'));
	TSli = DamageSlider.BtnSlider;
	TAc = DamageSlider.BtnAction;
	
	DamageSlider.SetPos(DamageSliderPos.X, DamageSliderPos.Y);
	DamageSlider.NumTicks = 7;
	DamageSlider.StartValue = 0;
	DamageSlider.EndValue = 6;
	DamageSlider.SetValue(2);
	if (TSli != None)
	{
		TSli.SetTicks(DamageSlider.NumTicks, DamageSlider.StartValue, DamageSlider.EndValue);
	}
	
	for (i=0; i<7; i++)
	{
		DamageSlider.SetEnumeration(i, DamageEnumerations[i]$"%");
	}
	if (TAc != None)
	{
		WidthChange = TAc.Width - OverrideSliderWidth;
		TAc.SetWidth(OverrideSliderWidth);
		TAc.SetButtonText(DamageSliderText);
	}
	
	TimerSlider = VMDMiniMenuUIChoiceSlider(WinClient.NewChild(Class'VMDMiniMenuUIChoiceSlider'));
	TSli = TimerSlider.BtnSlider;
	TAc = TimerSlider.BtnAction;
	
	TimerSlider.SetPos(TimerSliderPos.X, TimerSliderPos.Y);
	TimerSlider.NumTicks = 7;
	TimerSlider.StartValue = 0;
	TimerSlider.EndValue = 6;
	TimerSlider.SetValue(2);
	if (TSli != None)
	{
		TSli.SetTicks(TimerSlider.NumTicks, TimerSlider.StartValue, TimerSlider.EndValue);
	}
	for (i=0; i<7; i++)
	{
		TimerSlider.SetEnumeration(i, TimerEnumerations[i]$"%");
	}
	if (TAc != None)
	{
		WidthChange = TAc.Width - OverrideSliderWidth;
		TAc.SetWidth(OverrideSliderWidth);
		TAc.SetButtonText(TimerSliderText);
	}

	HPSlider = VMDMiniMenuUIChoiceSlider(WinClient.NewChild(Class'VMDMiniMenuUIChoiceSlider'));
	TSli = HPSlider.BtnSlider;
	TAc = HPSlider.BtnAction;
	
	HPSlider.SetPos(HPSliderPos.X, HPSliderPos.Y);
	HPSlider.NumTicks = 7;
	HPSlider.StartValue = 0;
	HPSlider.EndValue = 6;
	HPSlider.SetValue(1);
	if (TSli != None)
	{
		TSli.SetTicks(HPSlider.NumTicks, HPSlider.StartValue, HPSlider.EndValue);
	}
	for (i=0; i<7; i++)
	{
		HPSlider.SetEnumeration(i, HPEnumerations[i]$"%");
	}
	if (TAc != None)
	{
		WidthChange = TAc.Width - OverrideSliderWidth;
		TAc.SetWidth(OverrideSliderWidth);
		TAc.SetButtonText(HPSliderText);
	}
}

function CreatePresetButtons()
{
	local int i;
	
	for (i=0; i<ArrayCount(PresetButtons); i++)
	{
		PresetButtons[i] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
		
		PresetButtons[i].SetButtonText(PresetNames[i]);
		PresetButtons[i].SetPos(PresetButtonPos[i].X, PresetButtonPos[i].Y);
		PresetButtons[i].SetWidth(PresetButtonWidth);
	}
}

function LoadPreset(int PresetIndex)
{
	//All health and timers match, but HP slider is always 1... Except for Condemned.
	DamageSlider.SetValue(Min(PresetIndex, 6));
	TimerSlider.SetValue(Min(PresetIndex, 6));
	HPSlider.SetValue(1);
	
	DisableAllModifiers();
	
	if (PresetIndex > 2)
	{
		SetRowVariable(11, 1); //On hard+ we turn on KS health tweaks.
	}
	
	switch(PresetIndex)
	{
		//Realistic
		case 4:
			SetRowVariable(16, 1); //Enable computer visibility. It's at least realistic.
			SetRowVariable(19, 1); //Turn on bumping alerting enemies while we're here.
		break;
		//Nightmare
		case 5:
			SetRowVariable(4, 1); //Infamy system enabled.
			SetRowVariable(7, 1); //Reduce loot.
			SetRowVariable(9, 1); //Enemy damage gate enabled.
			SetRowVariable(12, 1); //Advanced limb damage enabled.
			SetRowVariable(16, 1); //Enable computer visibility. It's at least realistic.
			SetRowVariable(18, 1); //Extend enemy vision lines.
			SetRowVariable(19, 1); //Turn on bumping alerting enemies while we're here.
		break;
		//Gallows
		case 6:
			SetRowVariable(1, 1); //Save gate on, baby.
			SetRowVariable(4, 1); //Infamy system enabled.
			SetRowVariable(5, 1); //Infamy forgiveness 5 points, Gallows special.
			SetRowVariable(6, 1); //Ammo reduction enabled.
			SetRowVariable(7, 1); //Reduce loot.
			SetRowVariable(8, 2); //Reduce to degree 3.
			SetRowVariable(9, 1); //Enemy damage gate enabled.
			SetRowVariable(10, 2); //-100 gate break threshold.
			SetRowVariable(12, 1); //Advanced limb damage enabled.
			SetRowVariable(13, 1); //Boss deathmatch enabled.
			
			EnableAllStealthModifiers();
			EnableAllCombatModifiers();
		break;
		//Condemned
		case 7:
			SetRowVariable(1, 1); //Save gate on, baby.
			SetRowVariable(2, 3); //Save gate lasts forever. AKA, no saving whatsoever.
			SetRowVariable(3, 0); //Always save gated. Have fun.
			SetRowVariable(4, 1); //Infamy system enabled.
			SetRowVariable(5, 0); //Infamy forgiveness 0 points. Good luck.
			SetRowVariable(6, 1); //Ammo reduction enabled.
			SetRowVariable(7, 2); //DELETE loot.
			SetRowVariable(8, 2); //Reduce to degree 3.
			SetRowVariable(9, 1); //Enemy damage gate enabled.
			SetRowVariable(10, 2); //-100 gate break threshold.
			SetRowVariable(12, 1); //Advanced limb damage enabled.
			SetRowVariable(13, 1); //Boss deathmatch enabled.
			
			EnableAllStealthModifiers();
			EnableAllCombatModifiers();
			HPSlider.SetValue(4); //Enemies have 2x health. Condemned special, baby.
		break;
	}
	
	GiveTargetedTip(PresetIndex);
}

function DisableAllModifiers()
{
	local int i;
	
	for(i=0; i<30; i++)
	{
		SetRowVariable(i, 0);
	}
	SetRowVariable(2, 1); //Save gate to 90 seconds, stock.
	SetRowVariable(3, 2); //Save gate upon 2 skills, stock.
	SetRowVariable(5, 3); //Mayhem forgiveness 25 points, stock.
	SetRowVariable(10, 1); //Gate break of -50 points, stock.
}

function EnableAllStealthModifiers()
{
	local int i;
	
	for(i=16; i<22; i++)
	{
		SetRowVariable(i, 1);
	}
}

function EnableAllCombatModifiers()
{
	local int i;
	
	for(i=24; i<30; i++)
	{
		SetRowVariable(i, 1);
	}
}

function CreateDescriptionWindow()
{
	winDescription = LargeTextWindow(winClient.NewChild(Class'LargeTextWindow'));
	winDescription.SetSize( WinDescriptionSize.X, WinDescriptionSize.Y );
	winDescription.SetPos( WinDescriptionPos.X, WinDescriptionPos.Y );
	winDescription.SetTextMargins(5, 5);
	winDescription.SetFont(Font'FontMenuHeaders');
	winDescription.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	winDescription.SetTextColor(colDesc);
}

function CreateItemListWindow()
{
	winScroll = CreateScrollAreaWindow(winClient);
	
	winScroll.SetPos(WinScrollPos.X, WinScrollPos.Y);
	winScroll.SetSize(WinScrollSize.X, WinScrollSize.Y);
	
	lstItems = MenuUIListWindow(winScroll.clipWindow.NewChild(Class'MenuUIListWindow'));
	
	lstItems.EnableMultiSelect(False);
	lstItems.EnableAutoExpandColumns(False);
	lstItems.SetNumColumns(3);
	
	lstItems.SetColumnWidth(0, 426);
	lstItems.SetColumnWidth(1, 110);
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

event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	local string i;
	
	row = focusRowId;
	
	i = lstItems.GetField(row, 2);
	
	if (StrDescription[int(i)] != "")
	{
		winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)]);
	}
	
	return True;
}

event bool ListRowActivated(window list, int rowId)
{
	SwitchVariable(Row);
	return true;
}

function SwitchVariable(int UseRow)
{
	local string GF, VS, newValue, LabelValue;
	local bool GetValueB, SetValueB;
	local int IGF, GetValueI, SetValueI, i, TStart, TEnd, TRow;
	
	GF = lstItems.GetField(UseRow, 2);
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
	
	newValue = lstItems.GetField(UseRow, 0)$";"$LabelValue$";"$lstItems.GetField(UseRow, 2);
	lstItems.ModifyRow(UseRow, newValue);
	
	//MADDERS, 9/24/22: Allow us to flip through an entire category at a time, because it makes sense in a weird way.
	//Also, it's useful for all but the first list.
	switch(LstItems.GetField(UseRow, 0))
	{
		case StrSetting[0]:
			TStart = 1;
			TEnd = 14;
		break;
		case StrSetting[15]:
			TStart = 16;
			TEnd = 22;
		break;
		case StrSetting[23]:
			TStart = 24;
			TEnd = 30;
		break;
	}
	
	if ((TStart > 0) && (TEnd > TStart))
	{
		for(i=TStart; i<TEnd; i++)
		{
			TRow = LstItems.IndexToRowId(i);
			SwitchVariable(TRow);
		}
	}
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

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	if (ButtonPressed != None)
	{
		switch(ButtonPressed)
		{
			case PresetButtons[0]:
				LoadPreset(0);
			break;
			case PresetButtons[1]:
				LoadPreset(1);
			break;
			case PresetButtons[2]:
				LoadPreset(2);
			break;
			case PresetButtons[3]:
				LoadPreset(3);
			break;
			case PresetButtons[4]:
				LoadPreset(4);
			break;
			case PresetButtons[5]:
				LoadPreset(5);
			break;
			case PresetButtons[6]:
				LoadPreset(6);
			break;
			case PresetButtons[7]:
				LoadPreset(7);
			break;
			default:
				bHandled = False;
			break;
		}
	}
	return bHandled;
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

function GiveTargetedTip(int TarArray)
{
	if (TipTexts[TarArray] != "")
	{
		root.MessageBox(TipHeaders[TarArray], TipTexts[TarArray], 1, False, Self);
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
			InvokeNewGameScreen();
		break;
		case "RETURN":
			ReturnToTitle();
			//AddTimer(0.1, False,, 'ReturnToTitle');
		break;
	}
}

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen()
{
	local VMDMenuSelectCustomCampaign newGame;
	
	//MADDERS: Call relevant reset data.
	if (VMDBufferPlayer(Player) != None)
	{
		VMDBufferPlayer(Player).VMDResetNewGameVars(1);
	}
	
	newGame = VMDMenuSelectCustomCampaign(root.InvokeMenuScreen(Class'VMDMenuSelectCustomCampaign'));
	
	if (newGame != None)
	{
		newGame.SetCampaignData(Player.CombatDifficulty);
	}
}

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	local bool TBGet;
	local int TGet, TRow, i;
	local VMDBufferPlayer VMP;
	
	Super.SaveSettings();
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		VMP.CombatDifficulty = float(DamageEnumerations[DamageSlider.GetValue()]) / 100.0;
		VMP.TimerDifficulty = float(DamageEnumerations[TimerSlider.GetValue()]) / 100.0; //Note: This is not a bug. Timer slider's values are not squared in their raw value.
		VMP.EnemyHPScale = float(HPEnumerations[HPSlider.GetValue()]) / 100.0;
		
		for(i=0; i<ArrayCount(StrSetting); i++)
		{
			TRow = LstItems.IndexToRowId(i);
			TGet = int(VMP.GetPropertyText(VarSetting[i]));
			
			switch(i)
			{
				case 2:
					if (TGet == 0)
					{
						VMP.GallowsSaveGateTime = 45;
					}
					else if (TGet == 1)
					{
						VMP.GallowsSaveGateTime = 90;
					}
					else if (TGet == 2)
					{
						VMP.GallowsSaveGateTime = 180;
					}
					else
					{
						VMP.GallowsSaveGateTime = 9999;
					}
				break;
				case 3: //Combat skills should work out of the box, right?
					VMP.SaveGateCombatThreshold = TGet;
				break;
				case 5:
					if (TGet == 0)
					{
						VMP.SavedMayhemForgiveness = 0;
					}
					else if (TGet == 1)
					{
						VMP.SavedMayhemForgiveness = -5;
					}
					else if (TGet == 2)
					{
						VMP.SavedMayhemForgiveness = -15;
					}
					else
					{
						VMP.SavedMayhemForgiveness = -25;
					}
				break;
				case 7:
					VMP.bLootSwapEnabled = (TGet == 1);
					VMP.bLootDeletionEnabled = (TGet == 2);
				break;
				case 8:
					VMP.SavedLootSwapSeverity = TGet+1;
				break;
				case 10:
					if (TGet == 0)
					{
						VMP.SavedGateBreakThreshold = -25;
					}
					else if (TGet == 1)
					{
						VMP.SavedGateBreakThreshold = -50;
					}
					else
					{
						VMP.SavedGateBreakThreshold = -100;
					}
				break;
				default:
					if (VarSetting[i] != "")
					{
						TBGet = Bool(VMP.GetPropertyText(VarSetting[i]));
						VMP.SetPropertyText(VarSetting[i], string(TBGet));
					}	
				break;
			}
		}
	}
}

/*event DestroyWindow()
{
	if (!bDisarmed)
	{
		Player.ConsoleCommand("Open DXOnly");
	}
}*/

function ReturnToTitle()
{
	Player.ConsoleCommand("Open DXOnly");
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
     OverrideSettingCaps(0)=1
     strSetting(0)="----Major Settings-----------"
     varSetting(0)="BARF"
     OverrideLabelValues(0)="----"
     strDescription(0)=""
     
     strSetting(1)="Save Gate"
     varSetting(1)="bSaveGateEnabled"
     strDescription(1)="If enabled, saving will be limited to occur less often. If set to max duration, all forms of saving will be disabled permanently."
     OverrideSettingCaps(2)=4
     strSetting(2)="Save Gate Duration"
     varSetting(2)="BarfSaveGateTime"
     OverrideLabelValues(2)="45 Sec|90 Sec|180 Sec|Permanent"
     strDescription(2)="How long you will be delayed between saves. Far from consuming your save timer, autosaves will refresh your save timer. At max duration, all forms of saving are disabled permanently."
     OverrideSettingCaps(3)=4
     strSetting(3)="Save Gate Combat Threshold"
     varSetting(3)="SaveGateCombatThreshold"
     OverrideLabelValues(3)="Always|1 Upgrade|2 Upgrades|3 Upgrades"
     strDescription(3)="How many times weapon skills must be upgraded for save gate to enable. This pool is shared between all weapon skills. IE: Trained Pistols + Trained Demolitions = 2 points."
     strSetting(4)="Infamy System"
     varSetting(4)="bMayhemSystemEnabled"
     strDescription(4)="If enabled, the Infamy system will be active. The Infamy system responds to player aggression by increasing the quality and quantity of opposition dynamically."
     OverrideSettingCaps(5)=4
     strSetting(5)="Infamy Forgiveness"
     varSetting(5)="BarfMayhemForgiveness"
     OverrideLabelValues(5)="None|5+ Points|15+ Points|25+ Points"
     strDescription(5)="At the end of every mission, your Infamy score will shift based on the difference of your owed Infamy score and Infamy forgiveness. Upon leaving an area, you gain 1 point on infamy for each knockout, 2 points for each kill, and 3 points for each dismemembered body. Every enemy left alive lowers infamy by 2 points, except when using the 'None' setting."
     strSetting(6)="Ammo Reduction"
     varSetting(6)="bAmmoReductionEnabled"
     strDescription(6)="If enabled, ammo looted from defeated enemies will be reduced by 1 round, down to a minimum of 1."
     OverrideSettingCaps(7)=3
     strSetting(7)="Loot Swapping"
     varSetting(7)="BarfLootReduction"
     OverrideLabelValues(7)="None|Reduce|Delete"
     strDescription(7)="If enabled, loot sources will either be reduced (replaced with scrap or chemicals) or outright deleted."
     OverrideSettingCaps(8)=3
     strSetting(8)="Loot Swap Severity"
     varSetting(8)="BarfLootSwapSeverity"
     OverrideLabelValues(8)="Tier 1|Tier 2|Tier 3"
     strDescription(8)="The frequency with which loot will be either reduced or deleted, according to loot swap rules. If loot swap is disabled, this does nothing."
     strSetting(9)="Enemy Damage Gate"
     varSetting(9)="bEnemyDamageGateEnabled"
     strDescription(9)="If enabled, enemies will have a damage gate of their own, stopping one shot kills. Sneak attacks and attacks that exceed the gate break threshold will bypass this gate."
     OverrideSettingCaps(10)=3
     strSetting(10)="Damage Gate Threshold"
     varSetting(10)="BarfGateBreakThreshold"
     OverrideLabelValues(10)="25|50|100"
     strDescription(10)="When enemy damage gate is enabled, this value is how many points of damage extra you must do to break through the enemy's damage gate."
     strSetting(11)="Killswitch HP Scale"
     varSetting(11)="bKillswitchHealthEnabled"
     strDescription(11)="This determines whether someone affected by a killswitch has their HP scale down as it progresses."
     strSetting(12)="Advanced Limb Damage"
     varSetting(12)="bAdvancedLimbDamageEnabled"
     strDescription(12)="If enabled, advanced limb damage is forced on. You can be disarmed, forced to limp, heal worse with no arms, and more. This setting dials up the realism just a tad."
     strSetting(13)="Boss Deathmatch"
     varSetting(13)="bBossDeathmatchEnabled"
     strDescription(13)="If enabled, all bosses will fight to the death. No retreat, no weapon dropping."
     
     OverrideSettingCaps(14)=1
     strSetting(14)=" "
     varSetting(14)="BARF"
     OverrideLabelValues(14)=" "
     strDescription(14)=""
     OverrideSettingCaps(15)=1
     strSetting(15)="----Stealth AI Settings------------"
     varSetting(15)="BARF"
     OverrideLabelValues(15)="----"
     strDescription(15)=""
     
     strSetting(16)="Computer Visibility"
     varSetting(16)="bComputerVisibilityEnabled"
     strDescription(16)="If enabled, the player will be able to be seen and shot while using a computer, since this makes more sense."
     strSetting(17)="Door Noise Projection"
     varSetting(17)="bDoorNoiseEnabled"
     strDescription(17)="If enabled, doors and such that make noise when moving will alert nearby enemies."
     strSetting(18)="Enemy Vision Extension"
     varSetting(18)="bEnemyVisionExtensionEnabled"
     strDescription(18)="If enabled, enemies in larger, emptier spaces will have extended vision to match."
     strSetting(19)="Notice Bumping"
     varSetting(19)="bNoticeBumpingEnabled"
     strDescription(19)="If enabled, bumping into enemies mid-run will alert them to your position."
     strSetting(20)="Recognize Moved Objects"
     varSetting(20)="bRecognizeMovedObjectsEnabled"
     strDescription(20)="If enabled, enemies will find decorations having been moved as suspicious."
     strSetting(21)="Reload Noise Projection"
     varSetting(21)="bReloadNoiseEnabled"
     strDescription(21)="If enabled, the noise from reloading will alert nearby enemies."
     
     OverrideSettingCaps(22)=1
     strSetting(22)=" "
     varSetting(22)="BARF"
     OverrideLabelValues(22)=" "
     OverrideSettingCaps(23)=1
     strSetting(23)="----Combat AI Settings------------"
     varSetting(23)="BARF"
     OverrideLabelValues(23)="----"
     
     strSetting(24)="Dog Jump Attack"
     varSetting(24)="bDogJumpEnabled"
     strDescription(24)="If enabled, dogs will employ an extremely dangerous jump attack."
     strSetting(25)="Enemy GEP Lock"
     varSetting(25)="bEnemyGEPLockEnabled"
     strDescription(25)="If enabled, enemies with GEP guns can lock onto targets."
     strSetting(26)="Enemies Disarm Explosives"
     varSetting(26)="bEnemyDisarmExplosivesEnabled"
     strDescription(26)="If enabled, during an ambush in M04, the AI will disarm explosives placed in the ambush area, to ensure a fair fight. This may be expanded in the future."
     strSetting(27)="Enemies Target Explosives"
     varSetting(27)="bShootExplosivesEnabled"
     strDescription(27)="If enabled, opportunistic enemies will open fire on explosives you're in range of."
     strSetting(28)="Smart Enemy Melee"
     varSetting(28)="bDrawMeleeEnabled"
     strDescription(28)="If enabled, enemies will draw melee weapons instead of reloading, when it would benefit them."
     strSetting(29)="Smart Enemy Weapon Swap"
     varSetting(29)="bSmartEnemyWeaponSwapEnabled"
     strDescription(29)="If enabled, enemies will switch weapons instead of reloading, when it would save them in a pinch."
     
     PlayerGuideTipHeader="To New Players"
     PlayerGuideTipText="VMD has no tutorial. Check the PDF guide bundled, or the youtube or Moddb player guides for VMD."
     
     PresetNames(0)="Cakewalk"
     PresetNames(1)="Easy"
     PresetNames(2)="Medium"
     PresetNames(3)="Hard"
     PresetNames(4)="Realistic"
     PresetNames(5)="Nightmare"
     PresetNames(6)="Gallows"
     PresetNames(7)="CONDEMNED"
     PresetButtonPos(0)=(X=5,Y=50)
     PresetButtonPos(1)=(X=5,Y=86)
     PresetButtonPos(2)=(X=5,Y=122)
     PresetButtonPos(3)=(X=5,Y=158)
     PresetButtonPos(4)=(X=5,Y=194)
     PresetButtonPos(5)=(X=5,Y=230)
     PresetButtonPos(6)=(X=5,Y=266)
     PresetButtonPos(7)=(X=5,Y=302)
     PresetButtonWidth=211
     
     TipHeaders(0)="About Cakewalk"
     TipTexts(0)="Cakewalk is exceedingly easy, and is recommended only for those who continue to struggle with normal difficulty. Make sure this is you."
     TipHeaders(5)="About Nightmare"
     TipTexts(5)="Nightmare is unlike most difficulties. While not as punishing as Gallows, it includes the Infamy system and low grade loot replacement."
     TipHeaders(6)="About Gallows"
     TipTexts(6)="Gallows is extremely punishing. It includes a 90 second save gate upon 2 weapon skill upgrades, and almost no forgiveness for its infamy system. Tread carefully."
     TipHeaders(7)="About Condemned"
     TipTexts(7)="Condemned difficulty is unforgiving in every aspect, including a complete inability to save. The question is not if you can win, but how far you can make it."
     PresetsLabelText="Presets:"
     
     DamageEnumerations(0)="50"
     DamageEnumerations(1)="100"
     DamageEnumerations(2)="150"
     DamageEnumerations(3)="200"
     DamageEnumerations(4)="400"
     DamageEnumerations(5)="600"
     DamageEnumerations(6)="800"
     TimerEnumerations(0)="75"
     TimerEnumerations(1)="100"
     TimerEnumerations(2)="122"
     TimerEnumerations(3)="141"
     TimerEnumerations(4)="200"
     TimerEnumerations(5)="245"
     TimerEnumerations(6)="283"
     HPEnumerations(0)="75"
     HPEnumerations(1)="100"
     HPEnumerations(2)="125"
     HPEnumerations(3)="150"
     HPEnumerations(4)="200"
     HPEnumerations(5)="300"
     HPEnumerations(6)="400"
     
     SliderShiftX=24
     OverrideSliderWidth=112
     DamageSliderText="Damage Taken"
     TimerSliderText="Time Pressure"
     HPSliderText="Enemy Health"
     WinScrollPos=(X=222,Y=51)
     WinScrollSize=(X=530,Y=250)
     WinDescriptionSize=(X=469,Y=113)
     WinDescriptionPos=(X=227,Y=314)
     DamageSliderPos=(X=221,Y=4)
     TimerSliderPos=(X=402,Y=4)
     HPSliderPos=(X=583,Y=4)
     PresetsLabelPos=(X=84,Y=28)
     PresetsLabelSize=(X=64,Y=24)
     
     colDesc=(R=200,G=200,B=200)
     //actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Other,Text="|&Cancel",Key="RETURN")
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="C|&ampaign",Key="START")
     Title="Difficulty Selection"
     ClientWidth=768
     ClientHeight=437
     TextureRows=2
     TextureCols=3
     clientTextures(0)=Texture'VMDCustomDifficultyWindowBG01'
     clientTextures(1)=Texture'VMDCustomDifficultyWindowBG02'
     clientTextures(2)=Texture'VMDCustomDifficultyWindowBG03'
     clientTextures(3)=Texture'VMDCustomDifficultyWindowBG04'
     clientTextures(4)=Texture'VMDCustomDifficultyWindowBG05'
     clientTextures(5)=Texture'VMDCustomDifficultyWindowBG06'
}
