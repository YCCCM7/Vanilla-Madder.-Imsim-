//=============================================================================
// VMDMenuSelectCustomDifficulty
//=============================================================================
class VMDMenuSelectCustomDifficulty expands MenuUIScreenWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var bool bGavePlayerGuideTip, bDisarmed, bCustomizedDifficulty;
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
var localized string strSetting[64], strDescription[64], OverrideLabelValues[64], StrMultipleChoices, NGPlusMayhemBlurb;
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

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	if ((Key == IK_Escape) && (Class == class'VMDMenuSelectCustomDifficulty'))
	{
		ReturnToTitle();
		//AddTimer(0.1, False,, 'ReturnToTitle');
		return true;
	}
	
	return false;
}

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

function bool CanStack()
{
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
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	
	//All health and timers match (EDIT: Except condemned), but HP slider is always 1... Except for Condemned.
	DamageSlider.SetValue(Min(PresetIndex, 5));
	TimerSlider.SetValue(Min(PresetIndex, 5));
	HPSlider.SetValue(1);
	
	DisableAllModifiers();
	
	if (PresetIndex > 2)
	{
		SetRowVariable(VMDGetSettingIndex("Killswitch HP Scale"), 1); //On hard+ we turn on KS health tweaks.
	}
	
	switch(PresetIndex)
	{
		//Realistic
		case 4:
			SetRowVariable(VMDGetSettingIndex("Computer Visibility"), 1); //Enable computer visibility. It's at least realistic.
			SetRowVariable(VMDGetSettingIndex("Notice Bumping"), 1); //Turn on bumping alerting enemies while we're here.
			SetRowVariable(VMDGetSettingIndex("NPCs Projectile Fear"), 1); //Turn on avoidance of projectiles, too.
			SetRowVariable(VMDGetSettingIndex("Continuous Laser Alarms"), 1); //Turn on continuous laser alarms.
			
			//MADDERS, 8/11/23: Add some extra sensory stuff for phase 2.
			SetRowVariable(VMDGetSettingIndex("Enemy General Vision Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Shadow Vision Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Hearing Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Guessing Enhancement"), 1); //Do some mildly enhanced guessing.
			SetRowVariable(VMDGetSettingIndex("Enemy Reaction Speed Boost"), 1); //Do some mildly enhanced reflexes.
			SetRowVariable(VMDGetSettingIndex("Enemy Surprise Period Reduction"), 1); //Do some mildly enhanced surprise window.
		break;
		//Nightmare
		case 5:
			SetRowVariable(VMDGetSettingIndex("Infamy System"), 1); //Infamy system enabled.
			SetRowVariable(VMDGetSettingIndex("Loot Swapping"), 1); //Reduce loot.
			SetRowVariable(VMDGetSettingIndex("Naked Solution Reduction"), 1); //Reduce naked solutions by 25%.
			SetRowVariable(VMDGetSettingIndex("Naked Solution Reduction Duration"), 13); //All missions applicable.
			SetRowVariable(VMDGetSettingIndex("Enemy Damage Gate"), 1); //Enemy damage gate enabled.
			SetRowVariable(VMDGetSettingIndex("Advanced Limb Damage"), 1); //Advanced limb damage enabled.
			SetRowVariable(VMDGetSettingIndex("Computer Visibility"), 1); //Enable computer visibility. It's at least realistic.
			SetRowVariable(VMDGetSettingIndex("Notice Bumping"), 1); //Turn on bumping alerting enemies while we're here.
			SetRowVariable(VMDGetSettingIndex("Enemy Open Vision Extension"), 1); //Extend enemy vision lines.
			SetRowVariable(VMDGetSettingIndex("Enemy Search Extension"), 1); //Extend enemy search time.
			SetRowVariable(VMDGetSettingIndex("NPCs Projectile Fear"), 1); //Turn on avoidance of projectiles, too.
			SetRowVariable(VMDGetSettingIndex("Continuous Laser Alarms"), 1); //Turn on continuous laser alarms.
			
			//MADDERS, 8/11/23: Add some extra sensory stuff for phase 2.
			SetRowVariable(VMDGetSettingIndex("Enemy General Vision Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Shadow Vision Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Hearing Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Guessing Enhancement"), 1); //Do some mildly enhanced guessing.
			SetRowVariable(VMDGetSettingIndex("Enemy Reaction Speed Boost"), 1); //Do some mildly enhanced reflexes.
			SetRowVariable(VMDGetSettingIndex("Enemy Surprise Period Reduction"), 1); //Do some mildly enhanced surprise window.
		break;
		//Gallows
		case 6:
			SetRowVariable(VMDGetSettingIndex("Save Gate"), 1); //Save gate on, baby.
			SetRowVariable(VMDGetSettingIndex("Infamy System"), 1); //Infamy system enabled.
			SetRowVariable(VMDGetSettingIndex("Starting Infamy"), 1); //10 points of starting infamy, for fun.
			SetRowVariable(VMDGetSettingIndex("Infamy Forgiveness"), 1); //Infamy forgiveness 5 points, Gallows special.
			SetRowVariable(VMDGetSettingIndex("Infamy Mercenaries"), 1); //Bounty hunters enabled. Gallows and Condemned exclusive.
			SetRowVariable(VMDGetSettingIndex("Ammo Reduction"), 1); //Ammo reduction enabled.
			SetRowVariable(VMDGetSettingIndex("Loot Swapping"), 1); //Reduce loot.
			SetRowVariable(VMDGetSettingIndex("Loot Swap Severity"), 1); //Reduce to degree 2.
			SetRowVariable(VMDGetSettingIndex("Enemy Damage Gate"), 1); //Enemy damage gate enabled.
			SetRowVariable(VMDGetSettingIndex("Damage Gate Threshold"), 2); //-100 gate break threshold.
			SetRowVariable(VMDGetSettingIndex("Naked Solution Reduction"), 2); //Reduce naked solutions by 50%.
			SetRowVariable(VMDGetSettingIndex("Naked Solution Reduction Duration"), 13); //All missions applicable.
			SetRowVariable(VMDGetSettingIndex("Advanced Limb Damage"), 1); //Advanced limb damage enabled.
			SetRowVariable(VMDGetSettingIndex("Boss Deathmatch"), 1); //Boss deathmatch enabled.
			SetRowVariable(VMDGetSettingIndex("M04 Mortality"), 1); //Paul mortality enabled.
			SetRowVariable(VMDGetSettingIndex("Continuous Laser Alarms"), 1); //Turn on continuous laser alarms.
			SetRowVariable(VMDGetSettingIndex("Weak Grenade Climbing"), 1); //Turn on weak grenade climbing.
			
			//MADDERS, 8/11/23: Add more extra sensory stuff for phase 2.
			SetRowVariable(VMDGetSettingIndex("Enemy Search Extension"), 2); //Extend enemy search time.
			SetRowVariable(VMDGetSettingIndex("Enemy General Vision Boost"), 2);
			SetRowVariable(VMDGetSettingIndex("Enemy Shadow Vision Boost"), 2);
			SetRowVariable(VMDGetSettingIndex("Enemy Hearing Boost"), 2);
			SetRowVariable(VMDGetSettingIndex("Enemy Guessing Enhancement"), 1); //Do some mildly enhanced guessing, still. This stuff is potent.
			SetRowVariable(VMDGetSettingIndex("Enemy Reaction Speed Boost"), 1); //Do some mildly faster reflexes. Not too fast, now.
			SetRowVariable(VMDGetSettingIndex("Enemy Surprise Period Reduction"), 1); //Do some mildly enhanced surprise window still. Don't go too fast.
			
			//Also, boost our gunnery just a notch.
			SetRowVariable(VMDGetSettingIndex("Enemy Gunnery Boost"), 1);
			SetRowVariable(VMDGetSettingIndex("Enemy Weapon Speed Boost"), 1);
			
			EnableAllStealthModifiers();
			EnableAllCombatModifiers();
		break;
		//Condemned
		case 7:
			SetRowVariable(VMDGetSettingIndex("Save Gate"), 1); //Save gate on, baby.
			SetRowVariable(VMDGetSettingIndex("Save Gate Duration"), 4); //Save gate lasts forever. AKA, no saving whatsoever.
			SetRowVariable(VMDGetSettingIndex("Save Gate Combat Threshold"), 0); //Always save gated. Have fun.
			SetRowVariable(VMDGetSettingIndex("Infamy System"), 1); //Infamy system enabled.
			SetRowVariable(VMDGetSettingIndex("Infamy Forgiveness"), 0); //Infamy forgiveness 0 points. Good luck.
			SetRowVariable(VMDGetSettingIndex("Infamy Mercenaries"), 1); //Bounty hunters enabled. Gallows and Condemned exclusive.
			SetRowVariable(VMDGetSettingIndex("Infamy Mines"), 1); //Infamy places extra mines at various spots. Yikes.
			SetRowVariable(VMDGetSettingIndex("Ammo Reduction"), 1); //Ammo reduction enabled.
			SetRowVariable(VMDGetSettingIndex("Loot Swapping"), 2); //DELETE loot.
			SetRowVariable(VMDGetSettingIndex("Loot Swap Severity"), 1); //Reduce to degree 2.
			SetRowVariable(VMDGetSettingIndex("Enemy Damage Gate"), 1); //Enemy damage gate enabled.
			SetRowVariable(VMDGetSettingIndex("Damage Gate Threshold"), 2); //-100 gate break threshold.
			SetRowVariable(VMDGetSettingIndex("Naked Solution Reduction"), 3); //Reduce naked solutions by 75%.
			SetRowVariable(VMDGetSettingIndex("Naked Solution Reduction Duration"), 6); //M08 end duration, which is all missions until infamy grenades will probably set in.
			SetRowVariable(VMDGetSettingIndex("Advanced Limb Damage"), 1); //Advanced limb damage enabled.
			SetRowVariable(VMDGetSettingIndex("Boss Deathmatch"), 1); //Boss deathmatch enabled.
			SetRowVariable(VMDGetSettingIndex("M04 Mortality"), 1); //Paul mortality enabled.
			SetRowVariable(VMDGetSettingIndex("Continuous Laser Alarms"), 1); //Turn on continuous laser alarms.
			SetRowVariable(VMDGetSettingIndex("Weak Grenade Climbing"), 1); //Turn on weak grenade climbing.
			
			//MADDERS, 8/11/23: Add some seriously jacked senses for Phase 2.
			SetRowVariable(VMDGetSettingIndex("Enemy Search Extension"), 3); //Extend enemy search time.
			SetRowVariable(VMDGetSettingIndex("Enemy General Vision Boost"), 3);
			SetRowVariable(VMDGetSettingIndex("Enemy Shadow Vision Boost"), 3);
			SetRowVariable(VMDGetSettingIndex("Enemy Hearing Boost"), 3);
			SetRowVariable(VMDGetSettingIndex("Enemy Guessing Enhancement"), 3); //Do some moderately enhanced guessing. Shit doesn't fuck around, bruv. Don't do T3.
			SetRowVariable(VMDGetSettingIndex("Enemy Reaction Speed Boost"), 2); //Moderately faster reflexes on Condemned, for now.
			SetRowVariable(VMDGetSettingIndex("Enemy Surprise Period Reduction"), 2); //Do some moderately enhanced surprise window. Stuff is potent.
			
			//Also, boost our gunnery like hell.
			SetRowVariable(VMDGetSettingIndex("Enemy Gunnery Boost"), 2);
			SetRowVariable(VMDGetSettingIndex("Enemy Weapon Speed Boost"), 2);
			
			EnableAllStealthModifiers();
			EnableAllCombatModifiers();
			//MADDERS, 12/4/24: These are going down to gallows levels. Shocking, I know.
			//Mercs and energy shield damage type scaling is doing its job well, though.
			DamageSlider.SetValue(5);
			TimerSlider.SetValue(5);
			//MADDERS, 12/4/24: To my surprise after further testing, I honestly think this setting is no longer necessary at all.
			//HPSlider.SetValue(2); //Enemies have 1.25x health. Condemned special, baby.
		break;
	}
	
	if (VMP != None)
	{
		VMP.AssignedDifficulty = VMP.StrDifficultyNames[PresetIndex];
		VMP.AssignedSimpleDifficulty = VMP.AssignedDifficulty;
	}
	bCustomizedDifficulty = false;
	
	GiveTargetedTip(PresetIndex);
}

function DisableAllModifiers()
{
	local int i;
	
	for(i=0; i<=ArrayCount(VarSetting); i++)
	{
		SetRowVariable(i, 0);
	}
	SetRowVariable(VMDGetSettingIndex("Save Gate Duration"), 1); //Save gate to 90 seconds, stock.
	SetRowVariable(VMDGetSettingIndex("Save Gate Combat Threshold"), 2); //Save gate upon 2 skills, stock.
	SetRowVariable(VMDGetSettingIndex("Infamy Forgiveness"), 3); //Mayhem forgiveness 25 points, stock.
	SetRowVariable(VMDGetSettingIndex("Mercenary Infamy Threshold"), 5); //Require 125 infamy for mercs to show up
	SetRowVariable(VMDGetSettingIndex("Damage Gate Threshold"), 1); //Gate break of -50 points, stock.
}

function EnableAllStealthModifiers()
{
	local bool bStart;
	local int i;
	
	//for(i=24; i<=31; i++)
	for (i = VMDGetSettingIndex("----Stealth AI Settings------------")+1; i<ArrayCount(VarSetting); i++)
	{
		if (Default.VarSetting[i] == "BARF")
		{
			break;
		}
		
		if (OverrideSettingCaps[i] == 0)
		{
			SetRowVariable(i, 1);
		}
	}
}

function EnableAllCombatModifiers()
{
	local int i;
	
	//for(i=43; i<=49; i++)
	for (i = VMDGetSettingIndex("----Combat AI Settings------------")+1; i<ArrayCount(VarSetting); i++)
	{
		if (Default.VarSetting[i] == "BARF")
		{
			break;
		}
		if (OverrideSettingCaps[i] == 0)
		{
			SetRowVariable(i, 1);
		}
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
		if (OverrideSettingCaps[int(i)] > 2)
		{
			if ((VMDMenuSelectAdditionalDifficultyV2(Self) != None) && (Default.StrSetting[int(i)] ~= "Starting Infamy"))
			{
				//winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)] $ "|n|n" $ NGPlusMayhemBlurb $ "|n|n" $ StrMultipleChoices);
				winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)] $ "|n|n" $ NGPlusMayhemBlurb);
			}
			else
			{
				winDescription.SetText(strSetting[int(i)] $ "|n|n" $ strDescription[int(i)] $ "|n|n" $ StrMultipleChoices);
			}
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
	SwitchVariable(Row);
	return true;
}

function SwitchVariable(int UseRow)
{
	local bool GetValueB, SetValueB, bSub;
	local int IGF, GetValueI, SetValueI, i, TRow, AddRate;
	local string GF, VS, newValue, LabelValue;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	
	GF = lstItems.GetField(UseRow, 2);
	IGF = int(GF);
	VS = varSetting[IGF];
	
	if ((VMP != None) && (!bCustomizedDifficulty) && (VarSetting[IGF] != "BARF"))
	{
		VMP.AssignedDifficulty = VMP.StrCustomDifficulty@VMP.AssignedDifficulty;
		bCustomizedDifficulty = true;
	}
	
	AddRate = 1;
	if (Root != None)
	{
		if (Root.IsKeyDown(IK_Shift)) AddRate = 2;
		if (Root.IsKeyDown(IK_Ctrl)) bSub = true;
	}
	
	if (OverrideSettingCaps[IGF] > 2)
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
	
	newValue = lstItems.GetField(UseRow, 0)$";"$LabelValue$";"$lstItems.GetField(UseRow, 2);
	lstItems.ModifyRow(UseRow, newValue);
	
	//MADDERS, 9/24/22: Allow us to flip through an entire category at a time, because it makes sense in a weird way.
	//Also, it's useful for all but the first list.
	switch(CAPS(LstItems.GetField(UseRow, 0)))
	{
		case "----MAJOR SETTINGS-----------":
			for (i = VMDGetSettingIndex("----Major Settings-----------")+1; i<ArrayCount(VarSetting); i++)
			{
				if (Default.VarSetting[i] == "BARF")
				{
					break;
				}
				TRow = LstItems.IndexToRowId(i);
				SwitchVariable(TRow);
			}
		break;
		case "----INFAMY SETTINGS----------------":
			for (i = VMDGetSettingIndex("----Infamy Settings----------------")+1; i<ArrayCount(VarSetting); i++)
			{
				if (Default.VarSetting[i] == "BARF")
				{
					break;
				}
				TRow = LstItems.IndexToRowId(i);
				SwitchVariable(TRow);
			}
		break;
		case "----STEALTH AI SETTINGS------------":
			for (i = VMDGetSettingIndex("----Stealth AI Settings------------")+1; i<ArrayCount(VarSetting); i++)
			{
				if (Default.VarSetting[i] == "BARF")
				{
					break;
				}
				TRow = LstItems.IndexToRowId(i);
				SwitchVariable(TRow);
			}
		break;
		case "----AI SENSORY SETTINGS------------":
			for (i = VMDGetSettingIndex("----AI Sensory Settings------------")+1; i<ArrayCount(VarSetting); i++)
			{
				if (Default.VarSetting[i] == "BARF")
				{
					break;
				}
				TRow = LstItems.IndexToRowId(i);
				SwitchVariable(TRow);
			}
		break;
		case "----COMBAT AI SETTINGS------------":
			for (i = VMDGetSettingIndex("----Combat AI Settings------------")+1; i<ArrayCount(VarSetting); i++)
			{
				if (Default.VarSetting[i] == "BARF")
				{
					break;
				}
				TRow = LstItems.IndexToRowId(i);
				SwitchVariable(TRow);
			}
		break;
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
			if (Class == class'VMDMenuSelectCustomDifficulty')
			{
				ReturnToTitle();
			}
			else
			{
				Root.PopWindow();
			}
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
	local int TGet, TGet2, TRow, TMayhem, i;
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
			
			switch(CAPS(Default.StrSetting[i]))
			{
				case "SAVE GATE DURATION": //Save gate time
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
					else if (TGet == 3)
					{
						VMP.GallowsSaveGateTime = 720;
					}
					else
					{
						VMP.GallowsSaveGateTime = 9999;
					}
				break;
				case "SAVE GATE COMBAT THRESHOLD": //Combat skills should work out of the box, right? This is save gate skill threshold.
					VMP.SaveGateCombatThreshold = TGet;
				break;
				case "STARTING INFAMY": //Starting Mayhem
					if (TGet == 0)
					{
						TMayhem = 0;
					}
					else if (TGet == 1)
					{
						TMayhem = 10;
					}
					else if (TGet == 2)
					{
						TMayhem = 25;
					}
					else if (TGet == 3)
					{
						TMayhem = 50;
					}
					else if (TGet == 4)
					{
						TMayhem = 75;
					}
					else if (TGet == 5)
					{
						TMayhem = 100;
					}
					else
					{
						TMayhem = 125;
					}
					
					//MADDERS, 6/26/24: If we're not doing NG plus, or asked for our infamy to be flushed, or have asked for more infamy, change it.
					if (VMDMenuSelectAdditionalDifficultyV2(Self) == None || !VMP.bNGPlusKeepInfamy || TMayhem > VMP.MayhemFactor)
					{
						TGet2 = int(VMP.GetPropertyText(VarSetting[VMDGetSettingIndex("Infamy Forgiveness")]));
						switch(TGet2)
						{
							case 0:
								VMP.OwedMayhemFactor = 0;
							break;
							case 1:
								VMP.OwedMayhemFactor = 5;
							break;
							case 2:
								VMP.OwedMayhemFactor = 15;
							break;
							default:
								VMP.OwedMayhemFactor = 25;
							break;
						}
						VMP.MayhemFactor = TMayhem;
					}
				break;
				case "INFAMY FORGIVENESS": //Mayhem forgiveness
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
				case "MERCENARY INFAMY THRESHOLD":
					VMP.SavedHunterThreshold = 25 * TGet;
				break;
				
				case "LOOT SWAPPING": //Loot swap vs deletion vs disabled
					VMP.bLootSwapEnabled = (TGet == 1);
					VMP.bLootDeletionEnabled = (TGet == 2);
				break;
				case "LOOT SWAP SEVERITY": //Loot swap severity
					VMP.SavedLootSwapSeverity = TGet+1;
				break;
				case "DAMAGE GATE BREAK THRESHOLD": //Enemy damage gate break threshold
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
				
				//MADDERS, 8/11/23: Implement our vars here.
				case "ENEMY SEARCH EXTENSION": //Extra search steps
					//Should be automatic?
				break;
				case "ENEMY GENERAL VISION BOOST": //Vision range mult
					if (TGet == 0)
					{
						VMP.EnemyVisionRangeMult = 1.0;
					}
					else if (TGet == 1)
					{
						VMP.EnemyVisionRangeMult = 1.5;
					}
					else if (TGet == 2)
					{
						VMP.EnemyVisionRangeMult = 2.0;
					}
					else if (TGet == 3)
					{
						VMP.EnemyVisionRangeMult = 2.5;
					}
				break;
				case "ENEMY SHADOW VISION BOOST": //Vision strength mult
					if (TGet == 0)
					{
						VMP.EnemyVisionStrengthMult = 1.000;
					}
					else if (TGet == 1)
					{
						VMP.EnemyVisionStrengthMult = 0.880;
					}
					else if (TGet == 2)
					{
						VMP.EnemyVisionStrengthMult = 0.750;
					}
					else if (TGet == 3)
					{
						VMP.EnemyVisionStrengthMult = 0.625;
					}
				break;
				case "ENEMY HEARING BOOST": //Hearing range mult
					if (TGet == 0)
					{
						VMP.EnemyHearingRangeMult = 1.0;
					}
					else if (TGet == 1)
					{
						VMP.EnemyHearingRangeMult = 0.87;
					}
					else if (TGet == 2)
					{
						VMP.EnemyHearingRangeMult = 0.79;
					}
					else if (TGet == 3)
					{
						VMP.EnemyHearingRangeMult = 0.6;
					}
				break;
				case "ENEMY GUESSING ENHANCEMENT": //Guessing fudge factor
					if (TGet == 0)
					{
						VMP.EnemyGuessingFudge = 0.00;
					}
					else if (TGet == 1)
					{
						VMP.EnemyGuessingFudge = 0.35;
					}
					else if (TGet == 2)
					{
						VMP.EnemyGuessingFudge = 0.5;
					}
					else if (TGet == 3)
					{
						VMP.EnemyGuessingFudge = 0.65;
					}
				break;
				case "ENEMY REACTION SPEED BOOST": //Reaction speed multiplier
					if (TGet == 0)
					{
						VMP.EnemyReactionSpeedMult = 1.0;
					}
					else if (TGet == 1)
					{
						VMP.EnemyReactionSpeedMult = 1.5;
					}
					else if (TGet == 2)
					{
						VMP.EnemyReactionSpeedMult = 2.0;
					}
					else if (TGet == 3)
					{
						VMP.EnemyReactionSpeedMult = 3.0;
					}
				break;
				case "ENEMY SURPRISE PERIOD REDUCTION": //Suprise speed boost
					if (TGet == 0)
					{
						VMP.EnemySurprisePeriodMax = 2.00;
					}
					else if (TGet == 1)
					{
						VMP.EnemySurprisePeriodMax = 1.50;
					}
					else if (TGet == 2)
					{
						VMP.EnemySurprisePeriodMax = 1.00;
					}
					else if (TGet == 3)
					{
						VMP.EnemySurprisePeriodMax = 0.50;
					}
				break;
				case "ENEMY GUNNERY BOOST": //Accuracy boost (primarily)
					if (TGet == 0)
					{
						VMP.EnemyAccuracyMod = 0.000;
					}
					else if (TGet == 1)
					{
						VMP.EnemyAccuracyMod = -0.075;
					}
					else if (TGet == 2)
					{
						VMP.EnemyAccuracyMod = -0.215;
					}
					else if (TGet == 3)
					{
						VMP.EnemyAccuracyMod = -0.350;
					}
				break;
				case "ENEMY WEAPON SPEED BOOST": //Weapon speed boost
					if (TGet == 0)
					{
						VMP.EnemyROFWeight = 0.00;
					}
					else if (TGet == 1)
					{
						VMP.EnemyROFWeight = -0.05;
					}
					else if (TGet == 2)
					{
						VMP.EnemyROFWeight = -0.10;
					}
					else if (TGet == 3)
					{
						VMP.EnemyROFWeight = -0.15;
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

function int VMDGetSettingIndex(string FindSetting)
{
	local int i;
	
	FindSetting = CAPS(FindSetting);
	for(i=0; i<ArrayCount(StrSetting); i++)
	{
		if (CAPS(StrSetting[i]) == FindSetting)
		{
			return i;
		}
	}
	
	return -1;
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
     StrMultipleChoices="Hold ctrl to cycle backwards. Hold shift to cycle at 2x the rate."
     
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
     OverrideLabelValues(2)="45 Sec|90 Sec|180 Sec|720 Sec|Permanent"
     strDescription(2)="How long you will be delayed between saves. Far from consuming your save timer, autosaves will refresh your save timer. At max duration, all forms of saving are disabled permanently, except for one, specialized autosave slot used for taking a break. Taking damage or being detected by an enemy after the autosave is made will void its use."
     OverrideSettingCaps(3)=4
     strSetting(3)="Save Gate Combat Threshold"
     varSetting(3)="SaveGateCombatThreshold"
     OverrideLabelValues(3)="Always|1 Upgrade|2 Upgrades|3 Upgrades"
     strDescription(3)="How many times weapon skills must be upgraded for save gate to enable. This pool is shared between all weapon skills. IE: Trained Pistols + Trained Demolitions = 2 points."
     strSetting(4)="Ammo Reduction"
     varSetting(4)="bAmmoReductionEnabled"
     strDescription(4)="If enabled, ammo looted from defeated enemies will be reduced by 1 round, down to a minimum of 1."
     OverrideSettingCaps(5)=3
     strSetting(5)="Loot Swapping"
     varSetting(5)="BarfLootReduction"
     OverrideLabelValues(5)="None|Reduce|Delete"
     strDescription(5)="If enabled, loot sources will either be reduced (replaced with scrap or chemicals) or outright deleted. GEP gun rockets are reduced in ammo counts sometimes on either setting."
     OverrideSettingCaps(6)=3
     strSetting(6)="Loot Swap Severity"
     varSetting(6)="BarfLootSwapSeverity"
     OverrideLabelValues(6)="Tier 1|Tier 2|Tier 3"
     strDescription(6)="The frequency with which loot will be either reduced or deleted, according to loot swap rules. If loot swap is disabled, this does nothing."
     strSetting(7)="Enemy Damage Gate"
     varSetting(7)="bEnemyDamageGateEnabled"
     strDescription(7)="If enabled, enemies will have a damage gate of their own, stopping one shot kills. Sneak attacks and attacks that exceed the gate break threshold will bypass this gate."
     OverrideSettingCaps(8)=3
     strSetting(8)="Damage Gate Threshold"
     varSetting(8)="BarfGateBreakThreshold"
     OverrideLabelValues(8)="25|50|100"
     strDescription(8)="When enemy damage gate is enabled, this value is how many points of damage extra you must do to break through the enemy's damage gate."
     OverrideSettingCaps(9)=5
     strSetting(9)="Naked Solution Reduction"
     varSetting(9)="SavedNakedSolutionReductionRate"
     OverrideLabelValues(9)="None|25%|50%|75%|100%"
     strDescription(9)="The percentage of naked solutions to reduce in total. This will be applied at random, based on a seed."
     OverrideSettingCaps(10)=14
     strSetting(10)="Naked Solution Reduction Duration"
     varSetting(10)="SavedNakedSolutionMissionEnd"
     OverrideLabelValues(10)="M01|M02|M03|M04|M05|M06|M08|M09|M10|M11|M12|M14|M15|All"
     strDescription(10)="The last mission number that naked solution reduction will occur in. It always starts at M01."
     strSetting(11)="Killswitch HP Scale"
     varSetting(11)="bKillswitchHealthEnabled"
     strDescription(11)="This determines whether someone affected by a killswitch has their HP scale down as it progresses."
     strSetting(12)="Advanced Limb Damage"
     varSetting(12)="bAdvancedLimbDamageEnabled"
     strDescription(12)="If enabled, advanced limb damage is forced on. You can be disarmed, forced to limp, heal worse with no arms, and more. This setting dials up the realism just a tad."
     strSetting(13)="Boss Deathmatch"
     varSetting(13)="bBossDeathmatchEnabled"
     strDescription(13)="If enabled, all bosses will fight to the death. No retreat, no weapon dropping."
     strSetting(14)="M04 Mortality"
     varSetting(14)="bPaulMortalEnabled"
     strDescription(14)="If enabled, a key fight during M04 may require the player to more directly support someone, or else they will die."
     strSetting(15)="Continuous Laser Alarms"
     varSetting(15)="bEternalLaserAlarms"
     strDescription(15)="If enabled, leaving objects or beings inside the path of a red laser alarm will continue to trigger the alarm, instead of letting it forget."
     strSetting(16)="Weak Grenade Climbing"
     varSetting(16)="bWeakGrenadeClimbing"
     strDescription(16)="If enabled, emplaced grenade mines can still be climbed upon and support things, but after 1/4 second of support their adhesive will give out."
     
     OverrideSettingCaps(17)=1
     strSetting(17)=" "
     varSetting(17)="BARF"
     OverrideLabelValues(17)=" "
     strDescription(17)=""
     OverrideSettingCaps(18)=1
     strSetting(18)="----Infamy Settings----------------"
     varSetting(18)="BARF"
     OverrideLabelValues(18)="----"
     strDescription(18)=""
     
     strSetting(19)="Infamy System"
     varSetting(19)="bMayhemSystemEnabled"
     strDescription(19)="If enabled, the Infamy system will be active. The Infamy system responds to player aggression by increasing the quality and quantity of opposition dynamically."
     OverrideSettingCaps(20)=7
     strSetting(20)="Starting Infamy"
     varSetting(20)="BarfStartingMayhem"
     OverrideLabelValues(20)="None|10 points|25 points|50 points|75 points|100 points|125 points"
     strDescription(20)="How many infamy points you start with. Extra guard placements happen immediately upon gaining infamy. Other major events occur at 25, 35, 50, 65, 75, and 100 points."
     NGPlusMayhemBlurb="During NG+, picking a higher starting infamy or not keeping your infamy on the previous screen will make this number your new infamy score."
     OverrideSettingCaps(21)=4
     strSetting(21)="Infamy Forgiveness"
     varSetting(21)="BarfMayhemForgiveness"
     OverrideLabelValues(21)="None|5+ Points|15+ Points|25+ Points"
     strDescription(21)="At the end of every mission, your Infamy score will shift based on the difference of your owed Infamy score and Infamy forgiveness. Upon leaving an area, you gain 1 point on infamy for each knockout, 2 points for each kill, and 3 points for each dismemembered body. Every enemy left alive lowers infamy by 2 points, except when using the 'None' setting."
     strSetting(22)="Infamy Mercenaries"
     varSetting(22)="bBountyHuntersEnabled"
     strDescription(22)="If enabled, the Infamy system will allow elite hunters to spawn if the infamy cap has been reached. They will truly test your skill. While not the most canon friendly, you ARE playing something crazier than vanilla."
     OverrideSettingCaps(23)=6
     strSetting(23)="Mercenary Infamy Threshold"
     varSetting(23)="BarfHunterThreshold"
     OverrideLabelValues(23)="0 points|25 points|50 points|75 points|100 points|125 points"
     strDescription(23)="The minimum infamy score required to begin spawning mercenaries, if they are enabled."
     strSetting(24)="Infamy Mines"
     varSetting(24)="bMayhemGrenadesEnabled"
     strDescription(24)="If enabled, the Infamy system will begin placing various mines around as extra obstacles, in response to high Infamy score. One mine will appear per mission at 75 or more infamy, and a second at 100 or more infamy."
     
     OverrideSettingCaps(25)=1
     strSetting(25)=" "
     varSetting(25)="BARF"
     OverrideLabelValues(25)=" "
     strDescription(25)=""
     OverrideSettingCaps(26)=1
     strSetting(26)="----Stealth AI Settings------------"
     varSetting(26)="BARF"
     OverrideLabelValues(26)="----"
     strDescription(26)=""
     
     strSetting(27)="Computer Visibility"
     varSetting(27)="bComputerVisibilityEnabled"
     strDescription(27)="If enabled, the player will be able to be seen and shot while using a computer, since this makes more sense."
     strSetting(28)="Door Noise Projection"
     varSetting(28)="bDoorNoiseEnabled"
     strDescription(28)="If enabled, doors and such that make noise when moving will alert nearby enemies."
     strSetting(29)="Camera Destruction Alarm"
     varSetting(29)="bCameraKillAlarm"
     strDescription(29)="If enabled, destroyed cameras will trigger alarms on their network."
     strSetting(30)="Notice Bumping"
     varSetting(30)="bNoticeBumpingEnabled"
     strDescription(30)="If enabled, bumping into enemies mid-run will alert them to your position."
     strSetting(31)="Recognize Moved Objects"
     varSetting(31)="bRecognizeMovedObjectsEnabled"
     strDescription(31)="If enabled, enemies will find decorations having been moved as suspicious."
     strSetting(32)="Reload Noise Projection"
     varSetting(32)="bReloadNoiseEnabled"
     strDescription(32)="If enabled, the noise from reloading will alert nearby enemies."
     strSetting(33)="Unconscious Reactions"
     varSetting(33)="bEnemyReactKOdDudes"
     strDescription(33)="If enabled, enemies will react to unconscious bodies just as they would dead bodies."
     strSetting(34)="Enemy Open Vision Extension"
     varSetting(34)="bEnemyVisionExtensionEnabled"
     strDescription(34)="If enabled, enemies in larger, emptier spaces will have extended vision to match."
     OverrideSettingCaps(35)=4
     strSetting(35)="Enemy Search Extension"
     varSetting(35)="EnemyExtraSearchSteps"
     strDescription(35)="If enabled, the degree to which enemies will extend search periods."
     OverrideLabelValues(35)="Disabled|Tier 1|Tier 2|Tier 3"
     
     OverrideSettingCaps(36)=1
     strSetting(36)=" "
     varSetting(36)="BARF"
     OverrideLabelValues(36)=" "
     strDescription(36)=""
     OverrideSettingCaps(37)=1
     strSetting(37)="----AI Sensory Settings------------"
     varSetting(37)="BARF"
     OverrideLabelValues(37)="----"
     strDescription(37)=""
     
     OverrideSettingCaps(38)=4
     strSetting(38)="Enemy General Vision Boost"
     varSetting(38)="BarfVisionRangeMult"
     strDescription(38)="If enabled, enemies in general will have a degree of vision range extension, regardless of all factors. This stacks with other vision boosts."
     OverrideLabelValues(38)="Disabled|+50%|+100%|+150%"
     OverrideSettingCaps(39)=4
     strSetting(39)="Enemy Shadow Vision Boost"
     varSetting(39)="BarfVisionStrengthMult"
     strDescription(39)="If enabled, enemies will see through darkness more easily."
     OverrideLabelValues(39)="Disabled|+16%|+50%|+150%"
     OverrideSettingCaps(40)=4
     strSetting(40)="Enemy Hearing Boost"
     varSetting(40)="BarfHearingRangeMult"
     strDescription(40)="If enabled, enemies in general will have a better ability to hear noises."
     OverrideLabelValues(40)="Disabled|+15%|+27%|+66%"
     OverrideSettingCaps(41)=4
     strSetting(41)="Enemy Guessing Enhancement"
     varSetting(41)="BarfGuessingFudge"
     strDescription(41)="If enabled, enemies will pick better spots to go looking for the player during searches."
     OverrideLabelValues(41)="Disabled|Tier 1|Tier 2|Tier 3"
     OverrideSettingCaps(42)=4
     strSetting(42)="Enemy Reaction Speed Boost"
     varSetting(42)="BarfReactionSpeedMult"
     strDescription(42)="If enabled, enemies will react to the player's presence substantially faster."
     OverrideLabelValues(42)="Disabled|+50%|+100%|+200%"
     OverrideSettingCaps(43)=4
     strSetting(43)="Enemy Surprise Period Reduction"
     varSetting(43)="BarfSurprisePeriodMax"
     strDescription(43)="If enabled, enemies will recover from the player surprising them much faster. Additionally, they will perform less confused and more concise searches for the player."
     OverrideLabelValues(43)="Disabled|-25%|-50%|-75%"
     
     OverrideSettingCaps(44)=1
     strSetting(44)=" "
     varSetting(44)="BARF"
     OverrideLabelValues(44)=" "
     strDescription(44)=""
     OverrideSettingCaps(45)=1
     strSetting(45)="----Combat AI Settings------------"
     varSetting(45)="BARF"
     OverrideLabelValues(45)="----"
     strDescription(45)=""
     
     strSetting(46)="Dog Jump Attack"
     varSetting(46)="bDogJumpEnabled"
     strDescription(46)="If enabled, dogs will employ an extremely dangerous jump attack."
     //strSetting(47)="Enemy GEP Lock"
     //varSetting(47)="bEnemyGEPLockEnabled"
     //strDescription(47)="If enabled, enemies with GEP guns can lock onto targets."
     strSetting(48)="Enemies Disarm Explosives"
     varSetting(48)="bEnemyDisarmExplosivesEnabled"
     strDescription(48)="If enabled, during an ambush in M04, the AI will disarm explosives placed in the ambush area, to ensure a fair fight. This may be expanded in the future."
     strSetting(49)="Enemies Target Explosives"
     varSetting(49)="bShootExplosivesEnabled"
     strDescription(49)="If enabled, opportunistic enemies will open fire on explosives you're in range of."
     //strSetting(50)="Smart Enemy Melee"
     //varSetting(50)="bDrawMeleeEnabled"
     //strDescription(50)="If enabled, enemies will draw melee weapons instead of reloading, when it would benefit them."
     //strSetting(51)="Smart Enemy Weapon Swap"
     //varSetting(51)="bSmartEnemyWeaponSwapEnabled"
     //strDescription(51)="If enabled, enemies will switch weapons instead of reloading, when it would save them in a pinch."
     strSetting(52)="NPCs Projectile Fear"
     varSetting(52)="bEnemyAlwaysAvoidProj"
     strDescription(52)="If enabled, enemies will always fear projectiles, both in and out of combat... Poison gas, thrown grenades, etc."
     OverrideSettingCaps(53)=4
     strSetting(53)="Enemy Gunnery Boost"
     varSetting(53)="BarfAccuracyMod"
     strDescription(53)="If enabled, enemies will have improved accuracy with each level. At high values, enemies will reload and shoot faster."
     OverrideLabelValues(53)="Disabled|+3.75%|+10.75%|+17.5%"
     OverrideSettingCaps(54)=4
     strSetting(54)="Enemy Weapon Speed Boost"
     varSetting(54)="BarfROFWeight"
     strDescription(54)="If enabled, enemies will shoot and reload faster."
     OverrideLabelValues(54)="Disabled|+10%|+11%|+17%"
     
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
     TipTexts(5)="Nightmare is unlike most difficulties. While not as punishing as Gallows, it includes the Infamy system, light loot replacement, and light naked solution reduction."
     TipHeaders(6)="About Gallows"
     TipTexts(6)="Gallows is extremely punishing. It includes a 90 second save gate upon 2 weapon skill upgrades, high infamy, and naked solution reduction. Tread carefully."
     TipHeaders(7)="About Condemned"
     TipTexts(7)="Condemned difficulty is unforgiving in every aspect, including virtually zero ability to save. The question is not if you can win, but how far you can make it."
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
