//=============================================================================
// VMDMenuSelectSkills
//=============================================================================
class VMDMenuSelectSkills extends MenuUIScreenWindow;

var MenuUIInfoButtonWindow   winNameBorder;
var MenuUIListWindow         lstSkills;
var MenuUISkillInfoWindow    winSkillInfo;
var MenuUIStaticInfoWindow   winSkillPoints;

var MenuUIActionButtonWindow btnUpgrade;
var MenuUIActionButtonWindow btnDowngrade;

var Skill   selectedSkill;
var int		selectedRowId;
var int     saveSkillPointsAvail;
var int     saveSkillPointsTotal;

var String filterString;

var localized string ButtonUpgradeLabel;
var localized string ButtonDowngradeLabel;
var localized string HeaderSkillsLabel;
var localized string HeaderSkillPointsLabel;
var localized string HeaderSkillLevelLabel;
var localized string HeaderPointsNeededLabel;

//MADDERS: Store this data for use during transfer.
var string StoredCampaign;

//And use this to simulate proper icon positions.
//var Window HackIcons[15];

var localized string AdvanceText[2];

//MADDERS, 3/24/21: Last minute tip for new Gallows Save Gate.
var localized string GallowsTipText, GallowsTipHeader;

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
	Super.CreateControls();
	
	CreateSkillButtons();
	CreateTextHeaders();
	CreateSkillsListWindow();
	CreateSkillInfoWindow();
	CreateSkillPointsButton();
	
	AddTimer(0.1, false,, 'GiveTip');
}

// ----------------------------------------------------------------------
// CreateSkillButtons()
// ----------------------------------------------------------------------

function CreateSkillButtons()
{
	btnUpgrade = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
	btnUpgrade.SetButtonText(ButtonUpgradeLabel);
	btnUpgrade.SetPos(164-144, 341);
	btnUpgrade.SetWidth(74);
	
	btnDowngrade = MenuUIActionButtonWindow(winClient.NewChild(Class'MenuUIActionButtonWindow'));
	btnDowngrade.SetButtonText(ButtonDowngradeLabel);
	btnDowngrade.SetPos(241-144, 341);
	btnDowngrade.SetWidth(90);
}

// ----------------------------------------------------------------------
// CreateTextHeaders()
// ----------------------------------------------------------------------

function CreateTextHeaders()
{
	local MenuUILabelWindow winLabel;
	
	CreateMenuLabel(172-144,  17, HeaderSkillsLabel,       winClient);
	
	winLabel = CreateMenuLabel(430-144,  18, HeaderSkillLevelLabel,   winClient);
	winLabel.SetFont(Font'FontMenuSmall');
	
	winLabel = CreateMenuLabel(505-144,  18, HeaderPointsNeededLabel, winClient);
	winLabel.SetFont(Font'FontMenuSmall');
	
	CreateMenuLabel(409-144, 344, HeaderSkillPointsLabel,  winClient); 
}

// ----------------------------------------------------------------------
// CreateSkillsListWindow()
// ----------------------------------------------------------------------

function CreateSkillsListWindow()
{
	lstSkills = MenuUIListWindow(winClient.NewChild(Class'MenuUIListWindow'));
	
	lstSkills.SetSize(397, 150+14); //MADDERS: EXPAND ME!
	lstSkills.SetPos(172-144,41);
	lstSkills.EnableMultiSelect(False);
	lstSkills.EnableAutoExpandColumns(False);
	lstSkills.SetNumColumns(3);
	
	lstSkills.SetColumnWidth(0, 262);
	lstSkills.SetColumnWidth(1,  66);
	lstSkills.SetColumnWidth(2,  60);
	lstSkills.SetColumnAlignment(2, HALIGN_Right);
	
	lstSkills.SetColumnFont(0, Font'FontMenuHeaders');
	lstSkills.SetSortColumn(0, False);
	lstSkills.EnableAutoSort(True);
}

// ----------------------------------------------------------------------
// CreateSkillInfoWindow()
// ----------------------------------------------------------------------

function CreateSkillInfoWindow()
{
	winSkillInfo = MenuUISkillInfoWindow(winClient.NewChild(Class'MenuUISkillInfoWindow'));
	winSkillInfo.SetPos(165-144, 208);
}

// ----------------------------------------------------------------------
// CreateSkillPointsButton()
// ----------------------------------------------------------------------

function CreateSkillPointsButton()
{
	winSkillPoints = MenuUIStaticInfoWindow(winClient.NewChild(Class'MenuUIStaticInfoWindow'));
	
	winSkillPoints.SetPos(487-144, 341);
	winSkillPoints.SetWidth(83);
	winSkillPoints.SetSensitivity(False);
}

// ----------------------------------------------------------------------
// PopulateSkillsList()
// ----------------------------------------------------------------------

function PopulateSkillsList()
{
	local int skillIndex;
	local int rowIndex;
	local Skill S;
	
	//MADDERS:Use this junk data for positioning.
	//local int StartX, StartY, RowHeight;
	
	lstSkills.DeleteAllRows();
	skillIndex = 0;
	
	//MADDERS: This is now defunct, as there isn't room for icons.
	//Restore if mini icons are ever added. Don't bank on it.
	//StartX = 16;
	//StartY = 16;
	//RowHeight = 24;
	// Iterate through the skills, adding them to our list
	for (S = Player.SkillSystem.FirstSkill; S != None; S = S.Next)
	{
		//HackIcons[SkillIndex] = NewChild(Class'Window');
		//HackIcons[SkillIndex].SetPos(StartX, StartY+(SkillIndex*RowHeight));
		//HackIcons[SkillIndex].SetBackground(S.SkillIcon);
		
		rowIndex = lstSkills.AddRow(BuildSkillString(S));
		lstSkills.SetRowClientObject(rowIndex, S);
		skillIndex++;
	}
	lstSkills.Sort();
	lstSkills.SetRow(lstSkills.IndexToRowId(0), False);
}

// ----------------------------------------------------------------------
// BuildSkillsString()
// ----------------------------------------------------------------------

function String BuildSkillString( Skill aSkill )
{
	local String skillString;
	local String levelCost, AddStr;
	local VMDBufferPlayer VMP;
	
	if ( aSkill.GetCurrentLevel() == 3 ) 
		levelCost = "--";
	else
		levelCost = String(aSkill.GetCost());
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.IsSpecializedInSkill(aSkill.Class)))
	{
		AddStr = " (*)";
	}
	
	skillString = aSkill.skillName $ AddStr$ ";" $ 
				  aSkill.GetCurrentLevelString() $ ";" $ 
				  levelCost;
	
	return skillString;
}

// ----------------------------------------------------------------------
// UpdateSkillPoints()
// ----------------------------------------------------------------------

function UpdateSkillPoints()
{
	winSkillPoints.SetButtonText(String(player.SkillPointsAvail));
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
		case btnUpgrade:
			UpgradeSkill();
			break;
		
		case btnDowngrade:
			DowngradeSkill();
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
// ----------------------------------------------------------------------

event bool ListRowActivated(window list, int rowId)
{
	UpgradeSkill();
	return True;
}

// ----------------------------------------------------------------------
// ListSelectedChanged()
// ----------------------------------------------------------------------

event bool ListSelectionChanged(window list, int numSelections, int focusRowId)
{
	local Skill aSkill;
	
	selectedSkill = Skill(ListWindow(list).GetRowClientObject(focusRowId));
	selectedRowId = focusRowId;
	
	winSkillInfo.SetSkill(selectedSkill);
	
	EnableButtons();
	
	return True;
}

// ----------------------------------------------------------------------
// EnableButtons()
// ----------------------------------------------------------------------

function EnableButtons()
{
	local VMDBufferPlayer VMP;
	
	// Abort if a skill item isn't selected
	if ( selectedSkill == None )
	{
		btnUpgrade.SetSensitivity( False );
		btnDowngrade.SetSensitivity( False );
	}
	else
	{
		// Upgrade Skill only available if the skill is not at 
		// the maximum -and- the user has enough skill points
		// available to upgrade the skill

		btnUpgrade.EnableWindow(selectedSkill.CanAffordToUpgrade(player.SkillPointsAvail));
		btnDowngrade.EnableWindow(selectedSkill.GetCurrentLevel() > 0);
	}
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		if (VMP.bSkillAugmentsEnabled)
		{
			ActionButtons[1].Btn.SetButtonText(AdvanceText[0]);
		}
		else
		{
			ActionButtons[1].Btn.SetButtonText(AdvanceText[1]);
		}
	}
	EnableActionButton(AB_Other, True, "START");
}

// ----------------------------------------------------------------------
// UpgradeSkill()
// ----------------------------------------------------------------------

function UpgradeSkill()
{
	// First make sure we have a skill selected
	if ( selectedSkill == None )
		return;
	
	selectedSkill.IncLevel(player);
	lstSkills.ModifyRow(selectedRowId, BuildSkillString( selectedSkill ));
	
	UpdateSkillPoints();
	EnableButtons();
}

// ----------------------------------------------------------------------
// DowngradeSkill()
// ----------------------------------------------------------------------

function DowngradeSkill()
{
	// First make sure we have a skill selected
	if ( selectedSkill == None )
		return;
	
	selectedSkill.DecLevel(True, Player);
	lstSkills.ModifyRow(selectedRowId, BuildSkillString( selectedSkill ));
	
	UpdateSkillPoints();
	EnableButtons();
}

// ----------------------------------------------------------------------
// ResetToDefaults()
//
// Meant to be called in derived class
// ----------------------------------------------------------------------

function ResetToDefaults()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		VMP.VMDResetNewGameVars(5);
	}
	//player.SkillPointsAvail = player.Default.SkillPointsAvail;
	//player.SkillPointsTotal = player.Default.SkillPointsTotal;
	
	PopulateSkillsList();	
	UpdateSkillPoints();
	EnableButtons();
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	local VMDBufferPlayer VMP;
	
	if (actionKey ~= "START")
	{
		SaveSettings();
		
		VMP = VMDBufferPlayer(GetPlayerPawn());
		if (VMP != None)
		{
			if (VMP.bSkillAugmentsEnabled)
			{
				InvokeNewGameScreen(StoredCampaign);
			}
			else
			{
				class'VMDStaticFunctions'.Static.StartCampaign(DeusExPlayer(GetPlayerPawn()), StoredCampaign);
			}
		}
	}
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
		//MADDERS: Call relevant reset data.
		VMP.VMDResetNewGameVars(6);
	}
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
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function InvokeNewGameScreen(string Campaign)
{
	local VMDMenuSelectSkillAugments NewGame;
	
	newGame = VMDMenuSelectSkillAugments(root.InvokeMenuScreen(Class'VMDMenuSelectSkillAugments'));
	
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
	if ((Player != None) && (Player.CombatDifficulty >= 8.0))
	{
		root.MessageBox(GallowsTipHeader, GallowsTipText, 1, False, Self);
	}
}

defaultproperties
{
     AdvanceText(0)="|&Skill Talents"
     AdvanceText(1)="|&Start Game"
     
     GallowsTipText="You have selected 'Gallows' difficulty. Upgrading your weapon skills more than once ever will enact a 'save gate' of 90 seconds. Pick wisely."
     GallowsTipHeader="Words of Advice"
     MessageBoxMode=MB_JoinGameWarning
     
     ButtonUpgradeLabel="Upg|&rade"
     ButtonDowngradeLabel="|&Downgrade"
     HeaderSkillsLabel="Skills"
     HeaderSkillPointsLabel="Skill Points"
     HeaderSkillLevelLabel="Skill Level"
     HeaderPointsNeededLabel="Points Needed"
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Skill Talents",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Reset)
     Title="Skill Setup"
     ClientWidth=436
     ClientHeight=389
     clientTextures(0)=Texture'NewMenuSkillsBackground_1'
     clientTextures(1)=Texture'NewMenuSkillsBackground_2'
     clientTextures(2)=Texture'NewMenuSkillsBackground_3'
     clientTextures(3)=Texture'NewMenuSkillsBackground_4'
     bUsesHelpWindow=False
     bEscapeSavesSettings=False
     textureRows=2
     textureCols=2
}
