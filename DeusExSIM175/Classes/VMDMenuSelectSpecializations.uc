//=============================================================================
// VMDMenuSelectSpecializations
//=============================================================================
class VMDMenuSelectSpecializations expands MenuUIScreenWindow;

var string StoredCampaign;

struct VMDButtonPos {
	var int X;
	var int Y;
};

struct VMDSpecPreset {
	var int One;
	var int Two;
};

var MenuUILabelWindow ListLabels[2], FlipperLabel;
var VMDButtonPos LabelHeaderPos, LabelListPos[2];
var localized string ListLabelText[2], FlipperLabelText;

var VMDButtonPos SpecializationPos[2];
var Window SpecializationPreviews[2];
var Texture PreviewIcons[11];
var string PreviewNames[11];
var localized string SpecializationDescs[11], SpecializationTipText, SpecializationTipHeader;

var localized string PresetNames[32], PresetDescs[32];
var VMDSpecPreset Presets[32];

var VMDButtonPos FlipperPos, ArrowPos[2];
var MenuUIEditWindow PresetEntry;
var ButtonWindow ButtonPresetPrev, ButtonPresetNext;
var int CurPresetIndex, MaxPresetIndex;

var byte SelectedSpecializationIndices[2];
var MenuUIListWindow SpecializationLists[2];
var PersonaInfoWindow DescBoxes[2];
var VMDButtonPos SpecializationListsPos[2], DescBoxPos[2];

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
	
	CreateInfoWindows();
	CreatePreviewWindows();
	CreatePreviewLists();
	CreatePresetFlipper();
	CreateLabels();
	UpdatePreviewBackgrounds();
	
	EnableButtons();
	
	AddTimer(0.1, false,, 'GiveTip');
}

// ----------------------------------------------------------------------
// CreateInfoWindows()
// ----------------------------------------------------------------------

function CreateInfoWindows()
{
	local int i;
	
	for (i=0; i<2; i++)
	{
		DescBoxes[i] = PersonaInfoWindow(winClient.NewChild(Class'PersonaInfoWindow'));
		DescBoxes[i].SetPos(DescBoxPos[i].X, DescBoxPos[i].Y);
		DescBoxes[i].SetSize(256, 64);
		DescBoxes[i].SetText("---");
	}
}

function CreatePresetFlipper()
{
	PresetEntry = CreateMenuEditWindow(FlipperPos.X, FlipperPos.Y, 113, 32, winClient);
	PresetEntry.SetSensitivity(False);
	ButtonPresetPrev = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonPresetPrev.SetPos(FlipperPos.X+ArrowPos[0].X, FlipperPos.Y+ArrowPos[0].Y);
	ButtonPresetPrev.SetSize(14, 15);
	ButtonPresetPrev.SetButtonTextures(Texture'MenuLeftArrow_Normal', Texture'MenuLeftArrow_Pressed');
	ButtonPresetNext = ButtonWindow(winClient.NewChild(Class'ButtonWindow'));
	ButtonPresetNext.SetPos(FlipperPos.X+ArrowPos[1].X, FlipperPos.Y+ArrowPos[1].Y);
	ButtonPresetNext.SetSize(14, 15);
	ButtonPresetNext.SetButtonTextures(Texture'MenuRightArrow_Normal', Texture'MenuRightArrow_Pressed');
}

function CreatePreviewWindows()
{
	local int i;
	
	for (i=0; i<ArrayCount(SpecializationLists); i++)
	{
		SpecializationPreviews[i] = NewChild(class'Window');
		SpecializationPreviews[i].SetPos(SpecializationPos[i].X, SpecializationPos[i].Y);
		SelectedSpecializationIndices[i] = i;
	}
}

function CreatePreviewLists()
{
	local int i, j;
	
	for (i=0; i<ArrayCount(SpecializationLists); i++)
	{
		SpecializationLists[i] = MenuUIListWindow(NewChild(Class'MenuUIListWindow'));
		SpecializationLists[i].SetPos(SpecializationListsPos[i].X, SpecializationListsPos[i].Y);
		SpecializationLists[i].EnableMultiSelect(False);
		SpecializationLists[i].EnableAutoExpandColumns(False);
		SpecializationLists[i].EnableHotKeys(False);
		//SpecializationLists[i].SetNumColumns(1);
		SpecializationLists[i].SetColumnWidth(0, 90);
		SpecializationLists[i].SetColumnType(0, COLTYPE_String);
		
		// First erase the old list
		SpecializationLists[i].DeleteAllRows();
		
		for(j=0; j<ArrayCount(PreviewNames); j++)
		{
			SpecializationLists[i].AddRow(PreviewNames[j]);
		}
		ArtificiallySelectIndex(i, SelectedSpecializationIndices[i]);
		SpecializationLists[i].SelectToRow(SpecializationLists[i].IndexToRowId(SelectedSpecializationIndices[i]));
		SpecializationLists[i].SetFocusRow(SpecializationLists[i].IndexToRowId(SelectedSpecializationIndices[i]));
	}
}

function CreateLabels()
{
	local int i;
	
	for (i=0; i<ArrayCount(ListLabels); i++)
	{
		ListLabels[i] = CreateMenuLabel(SpecializationListsPos[i].X+LabelListPos[i].X, SpecializationListsPos[i].Y+LabelListPos[i].Y, ListLabelText[i], winClient);
	}
	FlipperLabel = CreateMenuLabel(FlipperPos.X+LabelHeaderPos.X, FlipperPos.Y+LabelHeaderPos.Y, FlipperLabelText, winClient);
}

function ArtificiallySelectIndex(int Side, int Index)
{
	//MADDERS: Hack for custom not resetting.
	if (Index == -1) return;
	SpecializationLists[Side].SelectToRow(SpecializationLists[Side].IndexToRowId(Index));
	SpecializationLists[Side].SetFocusRow(SpecializationLists[Side].IndexToRowId(Index));
	SelectedSpecializationIndices[Side] = Index;
}

function UpdatePreviewBackgrounds()
{
	local int i, j;
	
	for (i=0; i<ArrayCount(SpecializationPreviews); i++)
	{
		j = SelectedSpecializationIndices[i];
		if (j < Min(ArrayCount(PreviewNames), ArrayCount(SpecializationDescs)))
		{
			if (SpecializationPreviews[i] != None)
			{
				SpecializationPreviews[i].SetBackground(PreviewIcons[j]);
			}
			if (DescBoxes[i] != None)
			{
				DescBoxes[i].Clear();
				DescBoxes[i].SetTitle(PreviewNames[j]);
				DescBoxes[i].SetText(SpecializationDescs[j]);
			}
			
			if (SpecializationLists[i] != None)
			{
				if (CurPresetIndex == 0)
				{
					SpecializationLists[i].SetSensitivity(True);
					//SpecializationLists[i].Show(True);
				}
				else
				{
					SpecializationLists[i].SetSensitivity(False);
					//SpecializationLists[i].Show(False);
				}
			}
		}
	}
	if ((PresetEntry != None) && (CurPresetIndex < ArrayCount(PresetNames)))
	{
		PresetEntry.SetText(PresetNames[CurPresetIndex]);
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
		case ButtonPresetPrev:
			CurPresetIndex--;
			if (CurPresetIndex < 0) CurPresetIndex = MaxPresetIndex;
			SpecializationLists[0].SetSensitivity(True);
			SpecializationLists[1].SetSensitivity(True);
			ArtificiallySelectIndex(0, Presets[CurPresetIndex].One);
			ArtificiallySelectIndex(1, Presets[CurPresetIndex].Two);
			if (CurPresetIndex > 0)
			{
				SpecializationLists[0].SetSensitivity(False);
				SpecializationLists[1].SetSensitivity(False);
			}
			UpdatePreviewBackgrounds();
		break;
		case ButtonPresetNext:
			CurPresetIndex++;
			if (CurPresetIndex > MaxPresetIndex) CurPresetIndex = 0;
			SpecializationLists[0].SetSensitivity(True);
			SpecializationLists[1].SetSensitivity(True);
			ArtificiallySelectIndex(0, Presets[CurPresetIndex].One);
			ArtificiallySelectIndex(1, Presets[CurPresetIndex].Two);
			if (CurPresetIndex > 0)
			{
				SpecializationLists[0].SetSensitivity(False);
				SpecializationLists[1].SetSensitivity(False);
			}
			UpdatePreviewBackgrounds();
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
// ListRowActivated()
//
// User double-clicked on one of the rows, meaning he/she/it wants 
// to redefine one of the functions
// ----------------------------------------------------------------------

//event bool ListRowActivated(window list, int rowId)
event bool ListSelectionChanged(window List, int NumSelections, int RowID)
{
	local int i;
	
	for (i=0; i<2; i++)
	{
		if (List == SpecializationLists[i])
		{
			if (SelectedSpecializationIndices[i] != SpecializationLists[i].RowIDToIndex(RowID))
			{
				CurPresetIndex = 0;
				SelectedSpecializationIndices[i] = SpecializationLists[i].RowIDToIndex(RowId);
			}
		}
	}
	
	UpdatePreviewBackgrounds();
	return True;
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	if (PresetEntry != None)
	{
		//if (CurPresetIndex == 0) PresetEntry.SetSensitivity(True);
		//else 
		PresetEntry.SetSensitivity(False);
	}
	
	if (ActionButtons[1].btn != None)
	{
		ActionButtons[1].btn.SetSensitivity(!(SelectedSpecializationIndices[0] == SelectedSpecializationIndices[1]));
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
	
	if (ButtonPresetPrev != None)
	{
		ButtonPresetPrev.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	if (ButtonPresetNext != None)
	{
		ButtonPresetNext.SetButtonColors(colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace, colButtonFace);
	}
	UpdatePersonaInfoColors(DescBoxes[0]);
	UpdatePersonaInfoColors(DescBoxes[1]);
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
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		if (VMP.SkillAugmentManager != None)
		{
			VMP.SkillAugmentManager.SkillSpecializations[0] = TranslateIndex(SelectedSpecializationIndices[0])+1;
			VMP.SkillAugmentManager.SkillSpecializations[1] = TranslateIndex(SelectedSpecializationIndices[1])+1;
		}
		//MADDERS: Call relevant reset data.
		VMP.VMDResetNewGameVars(5);
	}
}

function int TranslateIndex(int in)
{
	switch(In)
	{
		//Pistols
		case 0:
			return 0;
		break;
		//Rifles
		case 1:
			return 1;
		break;
		//Heavy
		case 2:
			return 3;
		break;
		//Demolitions
		case 3:
			return 2;
		break;
		//Low Tech
		case 4:
			return 4;
		break;
		//Infiltration
		case 5:
			return 5;
		break;
		//Electronics
		case 6:
			return 6;
		break;
		//Computers
		case 7:
			return 10;
		break;
		//Fitness
		case 8:
			return 7;
		break;
		//Tactical Gear
		case 9:
			return 8;
		break;
		//Medicine
		case 10:
			return 9;
		break;
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
			root.MessageBox(SpecializationTipHeader, SpecializationTipText, 1, False, Self);
		break;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function InvokeNewGameScreen(string Campaign)
{
	local VMDMenuSelectSkillsV2 NewGame;
	
	newGame = VMDMenuSelectSkillsV2(root.InvokeMenuScreen(Class'VMDMenuSelectSkillsV2'));
	
	if (newGame != None)
	{
		newGame.SetCampaignData(Campaign);
	}
}

function SetCampaignData(string NewCampaign)
{
	StoredCampaign = NewCampaign;
}

function GiveTip()
{
	if ((VMDBufferPlayer(Player) == None) || (!VMDBufferPlayer(Player).bGaveNewGameTips))
	{
		root.MessageBox(SpecializationTipHeader, SpecializationTipText, 1, False, Self);
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
     PresetNames(0)="Custom"
     PresetDescs(0)=""
     Presets(0)=(One=-1,Two=-1)
     PresetNames(1)="Gunslinger"
     PresetDescs(1)="Shoot first, and shoot the best. While not exceptional with either wing of ballistic weapons, anything that fires a solid slug counts as a fighting chance in your hands."
     Presets(1)=(One=0,Two=1)
     PresetNames(2)="Explosives"
     PresetDescs(2)="Go in heavy, and go in hard. Sporting both support effects and raw firepower, you might not fight the longest, but you absolutely fight the hardest in terms of weaponry."
     Presets(2)=(One=2,Two=3)
     PresetNames(3)="Burglar"
     PresetDescs(3)="Lay low until the fatal blow is struck. Sporting the ability to infiltrate and assassinate, very few security systems are safe from your hands, and enemies had best watch their backs."
     Presets(3)=(One=4,Two=5)
     PresetNames(4)="Invader"
     PresetDescs(4)="There is no system you cannot break. Between electronic hardware and locks, almost no system cannot be exploited at its weakest point by your tools."
     Presets(4)=(One=5,Two=6)
     PresetNames(5)="Hacker"
     PresetDescs(5)="Welcome to the digital age. Most security systems can be hacked or bypassed, and if they can't, then they'd best count their blessings."
     Presets(5)=(One=6,Two=7)
     PresetNames(6)="Recon"
     PresetDescs(6)="Get in, and get out. You're fast on your feet, and just as fast behind a keyboard. Information is the least of your concerns as you skirt around combat zones, seldom seen coming."
     Presets(6)=(One=7,Two=8)
     PresetNames(7)="Renegade"
     PresetDescs(7)="They'll never take you alive. Fast on your feet, low profile, and durable in a pinch, you're one son-of-a-bitch to pin down. With okay potential at combat, but good forgiveness for stealth, you're ready for trouble."
     Presets(7)=(One=8,Two=9)
     PresetNames(8)="Survivor"
     PresetDescs(8)="Your life is all that matters. Able to sponge up damage in a pinch, think ahead, and fix up any beatings you DO take, you're one hard combatant to get rid of."
     Presets(8)=(One=9,Two=10)
     PresetNames(9)="Rogue"
     PresetDescs(9)="You're a bad trope that never dies. Fast and loose, you sting like bee, but float like a butterfly... You're the fastest gun in the west."
     Presets(9)=(One=0,Two=8)
     PresetNames(10)="Soldier"
     PresetDescs(10)="NATO and 'nades, that's all you need. Grenades are like WMDs in your hands, and you can deliver a precision pounding with your rifles. Intermediate grade is high grade in your hands."
     Presets(10)=(One=1,Two=3)
     PresetNames(11)="Hitman"
     PresetDescs(11)="You plan ahead, and hit hard when you go in. A pair of goggles, a flak jacket, and a silenced rifle comprise a doomsday arsenal in your hands. Always one step ahead, you're a force of hell that rains down onto the enemy."
     Presets(11)=(One=1,Two=9)
     PresetNames(12)="Pacifist"
     PresetDescs(12)="Run and patch yourself up. That's all you do. As if trying to speedrun your way through life, you look for naked solutions and cheeky ways to get through a place without fighting. If you DO get tagged, however, you can fix yourself up fast."
     Presets(12)=(One=8,Two=10)
     MaxPresetIndex=12
     
     ListLabelText(0)="Resonation A"
     ListLabelText(1)="Resonation B"
     FlipperLabelText="Preset Profile"
     
     FlipperPos=(X=266,Y=372)
     ArrowPos(0)=(X=-14,Y=0)
     ArrowPos(1)=(X=113,Y=0)
     LabelListPos(0)=(X=-2,Y=-39)
     LabelListPos(1)=(X=-22,Y=-39)
     LabelHeaderPos=(X=3,Y=-15)
     SpecializationPos(0)=(X=134,Y=64)
     SpecializationPos(1)=(X=330,Y=64)
     SpecializationListsPos(0)=(X=35,Y=64)
     SpecializationListsPos(1)=(X=529,Y=64)
     DescBoxPos(0)=(X=51,Y=272)
     DescBoxPos(1)=(X=333,Y=272)
     PreviewIcons(0)=Texture'SpecializationsIconWeaponPistolsLarge'
     PreviewIcons(1)=Texture'SpecializationsIconWeaponRiflesLarge'
     PreviewIcons(2)=Texture'SpecializationsIconWeaponHeavyLarge'
     PreviewIcons(3)=Texture'SpecializationsIconDemolitionLarge'
     PreviewIcons(4)=Texture'SpecializationsIconWeaponLowTechLarge'
     PreviewIcons(5)=Texture'SpecializationsIconInfiltrationLarge'
     PreviewIcons(6)=Texture'SpecializationsIconElectronicsLarge'
     PreviewIcons(7)=Texture'SpecializationsIconComputersLarge'
     PreviewIcons(8)=Texture'SpecializationsIconSwimmingLarge'
     PreviewIcons(9)=Texture'SpecializationsIconTacticalGearLarge'
     PreviewIcons(10)=Texture'SpecializationsIconMedicineLarge'
     PreviewNames(0)="Pistols"
     PreviewNames(1)="Rifles"
     PreviewNames(2)="Heavy Weapons"
     PreviewNames(3)="Demolition"
     PreviewNames(4)="Low Tech"
     PreviewNames(5)="Infiltration"
     PreviewNames(6)="Hardware"
     PreviewNames(7)="Software"
     PreviewNames(8)="Fitness"
     PreviewNames(9)="Tactical Gear"
     PreviewNames(10)="Medicine"
     SpecializationDescs(0)="The use and management of the pistol, stealth pistol, mini-crossbow, and PS20 weapons."
     SpecializationDescs(1)="The use and management of the assault gun, sniper rifle, sawed off shotgun, and assault shotgun weapons."
     SpecializationDescs(2)="The use and mobility factor of the gep gun, flamethrower, law, and plasma rifle weapons."
     SpecializationDescs(3)="The use and resistance to LAM's, EMP grenades, gas grenades, and scrambler grenades."
     SpecializationDescs(4)="The power and utility of batons, crowbars, knives, pepper spray, shurikens, and other low tech weapons."
     SpecializationDescs(5)="The ease with which an agent bypasses locks and subvert other problems."
     SpecializationDescs(6)="The ease with which an agent performs mechanical crafting and bypasses electronic hardware. This should not be confused with hacking computers."
     SpecializationDescs(7)="The degree to which an agent can infiltrate computer systems and otherwise manipulate software."
     SpecializationDescs(8)="The speed and complexity with which an agent can move across land and water."
     SpecializationDescs(9)="The effect and lifespan of tech goggles, thermoptic camo, ballistic vests, hazmat suits, and rebreathers."
     SpecializationDescs(10)="The potency and finesse with which medkits and medbots can be used, as well as the ease with which an agent performs medical crafting."
     
     SpecializationTipText="Pick 2 skills that resonate with your character. Their upgrade costs will be reduced, and they will gain talents more quickly."
     SpecializationTipHeader="About Resonation"
     MessageBoxMode=MB_JoinGameWarning
     
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="Edit |&Skills",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Help",Key="HELP")
     Title="Resonation Selection"
     ClientWidth=639
     ClientHeight=432
     textureRows=2
     textureCols=3
     clientTextures(0)=Texture'SpecializationsBackground_1'
     clientTextures(1)=Texture'SpecializationsBackground_2'
     clientTextures(2)=Texture'SpecializationsBackground_3'
     clientTextures(3)=Texture'SpecializationsBackground_4'
     clientTextures(4)=Texture'SpecializationsBackground_5'
     clientTextures(5)=Texture'SpecializationsBackground_6'
}
