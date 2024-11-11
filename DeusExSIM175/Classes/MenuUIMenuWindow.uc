//=============================================================================
// MenuUIMenuWindow
//
// Base class for the Menu windows, which consist of a list of selections
// (load game, save game, new game, options, etc.)
//=============================================================================

class MenuUIMenuWindow extends MenuUIWindow;

struct S_MenuButton
{
	var int y;
	var EMenuActions action;
	var class invoke;
	var string key;
};

// Array of buttons
var MenuUIMenuButtonWindow winButtons[10];   // Up to ten buttons

// Array of button text
var localized string ButtonNames[10];

// Defaults
var int buttonXPos;
var int buttonWidth;
var S_MenuButton buttonDefaults[10];

//MADDERS, 7/2/22: Localizable... Yay...
var localized string HackMainMenuText[8];

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	CreateMenuButtons();
	
	if (Class.Name == 'MyMainMenu' || Class.Name == 'TCPMenuMain')
	{
		AddTimer(0.033, false,, 'FakeUpdateButtonStatus');
	}
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local int  buttonIndex;

	bHandled = False;

	Super.ButtonActivated(buttonPressed);

	// Figure out which button was pressed
	for (buttonIndex=0; buttonIndex<arrayCount(winButtons); buttonIndex++)
	{
		if (buttonPressed == winButtons[buttonIndex])
		{
			// Check to see if there's somewhere to go
			ProcessMenuAction(buttonDefaults[buttonIndex].action, buttonDefaults[buttonIndex].invoke, buttonDefaults[buttonIndex].key);

			bHandled = True;
			break;
		}
	}

	return bHandled;
}

// ----------------------------------------------------------------------
// CreateMenuButtons()
//
// Loop through the buttonDefaults array and create any buttons
// that we need for the menu
// ----------------------------------------------------------------------

function CreateMenuButtons()
{
	local int buttonIndex;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	for(buttonIndex=0; buttonIndex<arrayCount(buttonDefaults); buttonIndex++)
	{
		if (ButtonNames[buttonIndex] != "")
		{
			if ((ButtonIndex == 0) && (Class.Name == 'MyMainMenu' || Class.Name == 'TCPMenuMain'))
			{
				ButtonNames[0] = HackMainMenuText[0];
				ButtonDefaults[0].Action = MA_MenuScreen;
				ButtonDefaults[0].Invoke = Class'MenuMainForceQuit';
			}
			if ((VMP != None) && (ButtonIndex == 1) && (class'VMDStaticFunctions'.Static.UseGallowsSaveGate(VMP)))
			{
				if (VMP.GallowsSaveGateTime > 1000)
				{
					if (Class.Name == 'MyMainMenu' || Class.Name == 'TCPMenuMain')
					{
						WinButtons[1].SetButtonText(SprintF(HackMainMenuText[1], int(VMP.GallowsSaveGateTimer+0.99)));
						WinButtons[1].SetSensitivity(False);
					}
				}
				else if (VMP.GallowsSaveGateTimer > 1.0)
				{
					if (Class.Name == 'MyMainMenu' || Class.Name == 'TCPMenuMain')
					{
						WinButtons[1].SetButtonText(SprintF(HackMainMenuText[1], int(VMP.GallowsSaveGateTimer+0.99)));
						WinButtons[1].SetSensitivity(False);
					}
				}
			}
			winButtons[buttonIndex] = MenuUIMenuButtonWindow(winClient.NewChild(Class'MenuUIMenuButtonWindow'));
			
			winButtons[buttonIndex].SetButtonText(ButtonNames[buttonIndex]);
			winButtons[buttonIndex].SetPos(buttonXPos, buttonDefaults[buttonIndex].y);
			winButtons[buttonIndex].SetWidth(buttonWidth);
		}
		else
		{
			break;
		}
	}
}

function FakeUpdateButtonStatus()
{
	local DeusExLevelInfo info;
	local VMDBufferPlayer VMP;
	
	info = player.GetLevelInfo();
	VMP = VMDBufferPlayer(Player);
	if (((info != None) && (info.MissionNumber < 0)) || ((player.IsInState('Dying')) || (player.IsInState('Paralyzed')) || (player.IsInState('Interpolating'))))
	{
      		if (Player.Level.NetMode == NM_Standalone)
      		{
         		winButtons[1].SetSensitivity(False);
         		winButtons[7].SetSensitivity(False);
      		} 
   	}
	else if ((VMP != None) && (class'VMDStaticFunctions'.Static.UseGallowsSaveGate(VMP)) && (VMP.GallowsSaveGateTimer > 1.0))
	{
		WinButtons[1].SetButtonText(SprintF(HackMainMenuText[1], int(VMP.GallowsSaveGateTimer+0.99)));
		WinButtons[1].SetSensitivity(False);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     textureRows=2
     textureCols=1
     bUsesHelpWindow=False
     ScreenType=ST_Menu
     
     HackMainMenuText(0)="Main Menu"
     HackMainMenuText(1)="Save Game (%ds)"
     HackMainMenuText(2)="CONDEMNED"
}
