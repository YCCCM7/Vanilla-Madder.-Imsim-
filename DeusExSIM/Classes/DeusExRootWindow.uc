//=============================================================================
// DeusExRootWindow.
//=============================================================================
class DeusExRootWindow expands RootWindow;

// ----------------------------------------------------------------------
// Local Variables
// ----------------------------------------------------------------------

var DeusExHUD			hud;
var ActorDisplayWindow  actorDisplay;

var DeusExScopeView     scopeView;

// Window Stack
var int					MaxWinStack;

//MADDERS: Size expanded for new games, and because 6 is honestly sometimes not enough. Call me a bastard.
var DeusExBaseWindow WinStack[12];
//var DeusExBaseWindow	winStack[6];		// Array of Windows
var int					winCount;			// Number of Windows
var Bool				bIgnoreHotkeys;		// Ignore Hotkeys

struct S_ColorScheme
{
	var Color back;			// Background color
	var Color face;			// Button face color
	var Color text;			// Text color
	var Color titleText;	// Title bar text color
	var Color titleBar;		// Title bar background color
};

// Color Schemes
var S_ColorScheme       defaultMenuColorSchemes[10];
var S_ColorScheme       defaultHUDColorSchemes[10];

// Current color scheme in use
var S_ColorScheme       menuColorScheme;
var Bool                bMenuTranslucency;
var S_ColorScheme       HUDColorScheme;
var Bool                bHUDTranslucency;

// Used to draw a snapshot of the current game behind UI screens
var Color   colSnapshot;
var Texture Snapshot;
var Float   snapshotWidth;
var Float   snapshotHeight;
var Bool    bUIPaused;

struct S_DataVaultFunction
{
	var String function;
	var Class<DeusExBaseWindow> winClass;
};

var S_DataVaultFunction DataVaultFunctions[8];

var localized String QuickLoadTitle;
var localized String QuickLoadMessage;

//MADDERS, 8/8/23: Custom layers for rendering.
//They are generally as follows:
//0 - Blood splash overlay
//1 - Hunger overlays
//2 - Low modded overlays, I guess.
//3 - Zyme or Drunk effect tiers
//4 - Overdose or Overdose hints
//5 - High modded overlays, I guess.
var name VMDLayerNames[6];
var VMDHUDDisplayLayer VMDLayers[6];

var AugmentationDisplayWindow augDisplay;
var VMDHUDSkillNotifier SkillNotifier;


// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	local int i;
	
	class'KentiesUIFix'.Static.AssertHook();
	
	Super.InitWindow();
	
	// Initialize variables
	winCount = 0;
	
	actorDisplay = ActorDisplayWindow(NewChild(Class'ActorDisplayWindow'));
	actorDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	
	//MADDERS, 8/8/23: Neato. Extra render layers.
	for (i=0; i<ArrayCount(VMDLayers); i++)
	{
		VMDLayers[i] = VMDHUDDisplayLayer(NewChild(class'VMDHUDDisplayLayer'));
		VMDLayers[i].SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
	   	VMDLayers[i].SetBackgroundSmoothing(True);
	  	VMDLayers[i].SetBackgroundStretching(True);
		switch(i)
		{
			case 0:
				if ((GetPlayerPawn() != None) && (GetPlayerPawn().IsA('Trestkon')))
				{
					VMDLayers[i].InitTNMWarningLabel();
				}
			break;
			//Modded overlays are not to be displayed in weird ways. Use masking, I guess, but otherwise just set the normal layers.
			case 2:
			case 5:
	   			VMDLayers[i].SetBackgroundStyle(DSTY_Normal);
			break;
			default:
				VMDLayers[i].SetBackgroundStyle(DSTY_Modulated);
			break;
		}
	}
	
	//MADDERS, 8/16/23: Aug display for otherwise no-HUD players. You CHOSE to use these, I would think.
	AugDisplay = AugmentationDisplayWindow(NewChild(Class'AugmentationDisplayWindow'));
	AugDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);
	
	hud = DeusExHUD(NewChild(Class'DeusExHUD'));
	hud.UpdateSettings(DeusExPlayer(parentPawn));
	hud.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
	
	SkillNotifier = VMDHUDSkillNotifier(NewChild(class'VMDHUDSkillNotifier', False));
	
	scopeView = DeusExScopeView(NewChild(Class'DeusExScopeView', False));
	scopeView.SetWindowAlignments(HALIGN_Full, VALIGN_Full, 0, 0);
	
	SetDefaultCursor(Texture'DeusExCursor1', Texture'DeusExCursor1_Shadow');
	
	scopeView.Lower();
	
	ConditionalBindMultiplayerKeys();
}


// ----------------------------------------------------------------------
// ConditionalBindMultiplayerKeys()
// ----------------------------------------------------------------------

function ConditionalBindMultiplayerKeys()
{
	local String keyTalk, keyTeamTalk, keyBuySkills, keyKillDetail, keyScores, keyName, Alias;
	local int i;

	for ( i = 0; i < 255; i++ )
	{
		keyName = parentPawn.ConsoleCommand ( "KEYNAME "$i );
		if ( keyName != "" )
		{
			Alias = parentPawn.ConsoleCommand( "KEYBINDING "$keyName );

			// Bail out if any key has already been bound
			if (( Alias ~= "Talk" ) || ( Alias ~= "TeamTalk" ) || ( Alias ~= "BuySkills" ) || ( Alias ~= "KillerProfile" ) || ( Alias ~= "ShowScores" ))
				return;
		}
	}
	if ( !IsKeyAssigned( IK_T, "" ) )
		return;
	if ( !IsKeyAssigned( IK_Y, "" ) )
		return;
	if ( !IsKeyAssigned( IK_B, "" ) )
		return;
	if ( !IsKeyAssigned( IK_K, "" ) )
		return;
	if ( !IsKeyAssigned( IK_Equals, "" ) )
		return;

	// Go ahead and set them then
	parentPawn.ConsoleCommand("SET InputExt T Talk");
	parentPawn.ConsoleCommand("SET InputExt Y TeamTalk");
	parentPawn.ConsoleCommand("SET InputExt B BuySkills");
	parentPawn.ConsoleCommand("SET InputExt K KillerProfile");
	parentPawn.ConsoleCommand("SET InputExt Equals ShowScores");
}

// ----------------------------------------------------------------------
// VirtualKeyPressed()
//
// Called when a key is pressed; provides a virtual key value
// ----------------------------------------------------------------------

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local bool bKeyHandled;
	local DeusExPlayer Player;

	Player = DeusExPlayer(parentPawn);

	bKeyHandled = True;

	Super.VirtualKeyPressed(key, bRepeat);

	// Check for Ctrl-F9, which is a hard-coded key to take a screenshot
	if ( IsKeyDown( IK_Ctrl ) && ( key == IK_F9 ))
	{
		parentPawn.ConsoleCommand("SHOT");			
		return True;
	}
	
	if ((IsKeyDown(IK_Alt) && Key >= IK_A && Key <= IK_Z) || IsKeyDown(IK_Shift) || IsKeyDown(IK_Ctrl))
		return False;
	
	// When player dies in multiplayer...
	if ((Player != None) && (Player.Health <= 0) && (Player.Level.NetMode != NM_Standalone))
	{
		if (( MultiplayerMessageWin(GetTopWindow()) != None ) && ( key == IK_Escape ))
		{
			PopWindow();
			Player.ShowMainMenu();
		}
		return True;
	}

	// Check if this is a DataVault key
	if (!ProcessDataVaultSelection(key))
	{
		switch( key ) 
		{	
			// Hide the screen if the Escape key is pressed
			// Temp: Also if the Return key is pressed
			case IK_Escape:
				PopWindow();
				break;

			// We want Print Screen to work in UI screens
			case IK_PrintScrn:
				parentPawn.ConsoleCommand("SHOT");			
				break;

	//		case IK_GreyMinus:
	//			PushWindow(Class'MenuScreenRGB');
	//			break;

			default:
				bKeyHandled = False;
		}
	}

	return bKeyHandled;
}

// ----------------------------------------------------------------------
// ProcessDataVaultSelection()
//
// Checks to see if the key pressed is assigned to one of the 
// DataVault screens.  If so, control is passed to that screen. 
// This is done so the hot keys work inside another screen.
// ----------------------------------------------------------------------

function bool ProcessDataVaultSelection(EInputKey key)
{
	local bool bKeyPressed, FlagPCWindow, FlagKeypadWindow;
	local int dvIndex;
	local string Alias;
	local Window TWindow;
	local class<DeusExBaseWindow> CheckClass;
	
	bKeyPressed = False;
	
	TWindow = GetTopWindow();
	if (TWindow != None)
	{
		if ((ClassIsChildOf(TWindow.Class, class'NetworkTerminal')) && (TWindow.Class.Name != 'NetworkTerminal') && (TWindow.Class.Name != 'NetworkTerminalPublic'))
		{
			FlagPCWindow = true;
		}
		else if (TWindow.IsA('HUDKeypadWindow'))
		{
			FlagKeypadWindow = true;
		}
	}
	
	// Loop through the functions
	for(dvIndex=0; dvIndex<arrayCount(DataVaultFunctions); dvIndex++)
	{
		// Get the key(s) bound to this function
		if (IsKeyAssigned(key, DataVaultFunctions[dvIndex].function))	
		{
			CheckClass = DataVaultFunctions[dvIndex].winClass;
			if ((FlagPCWindow || FlagKeypadWindow) && (CheckClass == class'PersonaScreenGoals'))
			{
				CheckClass = class'VMDPersonaScreenNotesLight';
			}
			
			// If the screen is already active, then cancel it. 
			// Otherwise invoke it.
			if ((TWindow != None) && (TWindow.Class == CheckClass))
			{
				PopWindow();
			}
			else if ((!FlagPCWindow && !FlagKeypadWindow) || CheckClass == class'VMDPersonaScreenNotesLight')
			{
				InvokeUIScreen(CheckClass);
			}
			bKeyPressed = True;
			break;
		}
	}

	return bKeyPressed;
}

// ----------------------------------------------------------------------
// IsKeyAssigned()
//
// Checks to see if the key passed in has a function assigned to it.
// ----------------------------------------------------------------------

function bool IsKeyAssigned(EInputKey key, String function)
{
	local int pos;
	local string InputKeyName;
	local string Alias;
	local DeusExPlayer player;

	player       = DeusExPlayer(parentPawn);
	InputKeyName = mid(string(GetEnum(enum'EInputKey',key)),3);

	Alias = player.ConsoleCommand("KEYBINDING " $ InputKeyName);

	return (Alias == function);
}

// ----------------------------------------------------------------------
// DescendantRemoved()
// ----------------------------------------------------------------------

event DescendantRemoved(Window descendant)
{
	local int i;
	
	if ( descendant == hud )
		hud = None;

	if ( descendant == scopeView )
		scopeView = None;
	
	for (i=0; i<ArrayCount(VMDLayers); i++)
	{
		if (Descendant == VMDLayers[i])
		{
			VMDLayers[i] = None;
		}
	}
	
	if (Descendant == AugDisplay)
	{
		AugDisplay = None;
	}
	else if (descendant == SkillNotifier)
	{
		SkillNotifier = None;
	}
}

// ----------------------------------------------------------------------
// ClientMessage()
// ----------------------------------------------------------------------

function bool ClientMessage(coerce string msg, optional Name type,
                           optional bool bBeep)
{
	local Color linecol;

	linecol.R = 255; linecol.G = 255; linecol.B = 255;

	// Add this to the player's list of log objects
	DeusExPlayer(parentPawn).AddLog(msg);

	if ( DeusExPlayer(parentPawn).Level.NetMode != NM_Standalone )
	{
		if ( type == 'Say' )
			PlaySound(Sound'Menu_Incoming', 0.5 );
		else if ( type == 'TeamSay' )
			PlaySound(Sound'Menu_IncomingFriend', 0.5 );

		if ( !hud.bIsVisible )
		{
			if ( parentPawn.Player.Console != None )
			{
				parentPawn.Player.Console.AddString( msg );
				return True;
			}
		}
	}
	if ((hud != None) && (hud.msgLog != None))
	{
		// Display in the HUD
		if ( DeusExPlayer(parentPawn).Level.NetMode != NM_Standalone )
		{
			switch( type )
			{
				case 'TeamSay':
					linecol.R = 0; linecol.G = 255; linecol.B = 0;
					break;
				case 'Say':
					linecol.R = 255; linecol.G = 255; linecol.B = 255;
					break;
				default:
					linecol.R = 200; linecol.G = 200; linecol.B = 200;
					break;
			}
			hud.msgLog.AddLog(msg, linecol);
		}
		else
			hud.msgLog.AddLog(msg, linecol);
		
		return True;
	}
	else
	{
		return False;
	}
}

// ----------------------------------------------------------------------
// ShowHud()
// ----------------------------------------------------------------------

function ShowHud(bool bShow)
{
	if (hud != None)
	{
		//MADDERS, 8/25/23: Hack for still disabling scopes at bad times, despite what we do next.
		if (bShow)
		{
			scopeView.ShowView();
		}
		else
		{
			scopeView.HideView();
		}
		
		//MADDERS, 8/25/23: Hide HUD overrides the setting from here. Precise, efficient, and effective.
		if ((bShow) && (VMDBufferPlayer(ParentPawn) != None) && (!VMDBufferPlayer(ParentPawn).bHUDVisible)) bShow = false;
		
		if (bShow)
		{
			hud.UpdateSettings(DeusExPlayer(parentPawn));
			hud.Show();
		}
		else
		{
			hud.Hide();
		}
	}
}

// ----------------------------------------------------------------------
// UpdateHud()
// ----------------------------------------------------------------------

function UpdateHud()
{
	if (hud != None)
		hud.UpdateSettings(DeusExPlayer(parentPawn));
}

// ----------------------------------------------------------------------
// RefreshDisplay()
// DEUS_EX AMSD Used to keep displays up to date with replication from
// the server.  Calls current topwindow refreshwindow.
// ----------------------------------------------------------------------

function RefreshDisplay(float DeltaTime)
{
    if (GetTopWindow() != None)
        GetTopWindow().RefreshWindow(DeltaTime);
    if (hud != None)
        hud.belt.RefreshHUDDisplay(DeltaTime);
}

// ----------------------------------------------------------------------
// ActivateObjectInBelt()
//
// Returns False if there's nothing in that slot, True otherwise
// ----------------------------------------------------------------------

function bool ActivateObjectInBelt(int pos)
{
	local Inventory item;
	local DeusExPlayer player;
	local bool retval;

	retval = False;

	if (hud != None)
	{
		if (hud.belt != None)
		{
			item = hud.belt.GetObjectFromBelt(pos);
			player = DeusExPlayer(parentPawn);
			if (player != None)
			{
				// if the object is an ammo box, load the correct ammo into
				// the gun if it is the current weapon
				if ((item != None) && item.IsA('Ammo') && (player.Weapon != None))
				{
					DeusExWeapon(player.Weapon).LoadAmmoType(Ammo(item));
				}
				else
				{
					player.PutInHand(item);
					if (item != None)
						retval = True;
				}
			}
		}
	}

	return retval;
}

// ----------------------------------------------------------------------
// AddInventory()
//
// Adds an item to the object belt.  There are several types of 
// items that should *NOT* get added to the object belt, we'll 
// check for those here.
// ----------------------------------------------------------------------

function AddInventory(inventory item)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	if ((item != None) && !item.IsA('DataVaultImage'))
	{
		if (VMP == None || VMP.GetItemRefusalSetting(Item) < 1)
		{
			if (hud != None)
			{
				if (hud.belt != None)
				{
					hud.belt.AddObjectToBelt(item, -1, false);
				}
			}
		}
	}
}

// ----------------------------------------------------------------------
// DeleteInventory()
// ----------------------------------------------------------------------

function DeleteInventory(inventory item)
{
	if (item != None)
		if (hud != None)
			if (hud.belt != None)
				hud.belt.RemoveObjectFromBelt(item);

}

// ----------------------------------------------------------------------
// CanStartConversation()
//
// Returns True if it's okay to start a conversation from the DeusExRootWindow's 
// perspective.  We can only start a conversation if there are no 
// windows on the stack
// ----------------------------------------------------------------------

function bool CanStartConversation()
{
	local DeusExWeapon weapon;
	local bool         retval;

	retval = (WindowStackCount() == 0);

	if (retval)
	{
		weapon = None;
		if (GetRootWindow().parentPawn != None)
			weapon = DeusExWeapon(GetRootWindow().parentPawn.Weapon);

		if (weapon != None)
			if (weapon.bZoomed)
				retval = False;
	}

	return ( retval );
}

// ----------------------------------------------------------------------
// MessageBox()
//
// Displays a Message box
// ----------------------------------------------------------------------

function MenuUIMessageBoxWindow MessageBox
	( 
	String msgTitle,
	String msgText, 
	int msgBoxMode, 
	bool hideCurrentScreen,
	Window winParent
	)	
{
	local MenuUIMessageBoxWindow msgBox;

	msgBox = MenuUIMessageBoxWindow(PushWindow(Class'MenuUIMessageBoxWindow', hideCurrentScreen ));
	msgBox.SetTitle(msgTitle);
	msgBox.SetMessageText(msgText);
	msgBox.SetMode(msgBoxMode);
	msgBox.SetNotifyWindow(winParent);

	return msgBox;
}

// ----------------------------------------------------------------------
// ConfirmQuickLoad()
// ----------------------------------------------------------------------

function ConfirmQuickLoad()
{
	local MenuUIMessageBoxWindow msgBox;

	msgBox = MessageBox(QuickLoadTitle, QuickLoadMessage, 0, False, Self);
	msgBox.SetDeferredKeyPress(True);
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------

event bool BoxOptionSelected(Window button, int buttonNumber)
{
	// Destroy the msgbox!  
	PopWindow();

	if (buttonNumber == 0) 
		DeusExPlayer(parentPawn).QuickLoadConfirmed();

	return true;
}

// ----------------------------------------------------------------------
// ToolMessageBox()
//
// Displays a Message box
// ----------------------------------------------------------------------

function ToolMessageBox
	( 
	String msgTitle,
	String msgText, 
	int msgBoxMode, 
	bool hideCurrentScreen,
	Window winParent
	)	
{
	local ToolMessageBoxWindow msgBox;

	msgBox = ToolMessageBoxWindow(PushWindow(Class'ToolMessageBoxWindow', hideCurrentScreen ));
	msgBox.SetTitle( msgTitle );
	msgBox.SetMessageText( msgText );
	msgBox.SetMode( msgBoxMode );
	msgBox.SetNotifyWindow( winParent );
}

// ----------------------------------------------------------------------
// InvokeUIScreen()
//
// Invokes a UI Screen, first checking to make sure a screen isn't
// already pushed on the top of the Window stack.  If so, the current
// screen is popped off so the new screen can replace it.
// ----------------------------------------------------------------------

function DeusExBaseWindow InvokeUIScreen(
	Class<DeusExBaseWindow> newScreen, 
	optional Bool bNoPause)
{
	local DeusExBaseWindow pushedWindow;
	
	// Determine if we can actually push a screen based on what's at the top
	// of the stack
	
	if ((GetTopWindow() != None) && (!GetTopWindow().CanPushScreen(newScreen)))
		return None;
	
	// Now check to see if we have a UI screen at the top 
	// of the stack.  If so, remove it.  
	
	//MADDERS, 12/25/23: Hack for shoving more shit on top in computer screens.
	if ((WindowStackCount() > 0) && (!GetTopWindow().CanStack()) && (NewScreen != class'VMDPersonaScreenNotesLight'))
		PopWindow(True);
	
	// Now push our UI Screen
	pushedWindow = PushWindow(newScreen, False, bNoPause);
	
	return pushedWindow;
}

// ----------------------------------------------------------------------
// InvokeMenuScreen()
//
// Invokes a menu Screen
// ----------------------------------------------------------------------

function DeusExBaseWindow InvokeMenuScreen(Class<DeusExBaseWindow> newScreen, optional bool bNoPause)
{
	local DeusExBaseWindow newWindow;
	
	if ((!bNoPause) && (ShouldNegatePause(NewScreen))) bNoPause = true;
	
	// Check to see if a menu is visible.  If so, hide it first.
	if (( MenuUIMenuWindow(GetTopWindow()) != None ) || ( MenuUIScreenWindow(GetTopWindow()) != None ))
		newWindow = PushWindow(newScreen, True, bNoPause);
	else
		newWindow = PushWindow(newScreen, False, bNoPause);

	// Pause the game
	if (!bNoPause)
		UIPauseGame();

	return newWindow;
}

// ----------------------------------------------------------------------
// UIPauseGame()
//
// Pauses the game, but checks to see if the Mission is -1 or -2, which means
// we're on the title screen and we don't want to pause the game here.
// ----------------------------------------------------------------------

function UIPauseGame()
{
	// Only do this once 
	if (!bUIPaused)
	{
		bUIPaused = True;

		if (!AtIntroMap())
		{
			ShowSnapshot();
			parentPawn.ShowMenu();
		}
		else
		{
			MaskBackground(True);
		}
	}
}

// ----------------------------------------------------------------------
// UnPauseGame()
// ----------------------------------------------------------------------

function UnPauseGame()
{
	bUIPaused = False;
	
	SetBackgroundStyle(DSTY_None);
	
	HideSnapshot();
	ShowHud(True);
	if (AugDisplay != None)
	{
		AugDisplay.Show();
	}
	
	parentPawn.bShowMenu = false;
	parentPawn.Player.Console.GotoState('');
	parentPawn.SetPause(False);
}

// ----------------------------------------------------------------------
// ShowSnapshot()
// ----------------------------------------------------------------------

function ShowSnapshot(optional bool bUseExistingSnapshot)
{
	local DeusExPlayer player;
	local int UIBackground;

	ShowHUD(False);
	if (AugDisplay != None)
	{
		AugDisplay.Hide();
	}

	player = DeusExPlayer(parentPawn);
	if (player != None)
		UIBackground = player.UIBackground;
	else
		UIBackground = 0;

	// Only do this if we're not at the intro screen
	if (!AtIntroMap())
	{
		if (UIBackground > 0)
		{
			SetSnapshotSize(snapshotWidth, snapshotHeight);

			if (UIBackground == 1)
			{
				if (!bUseExistingSnapshot)
				{
					snapshot = GenerateSnapshot();
				}
			}
			else
			{
				if (snapshot != None)
				{
					CriticalDelete(snapshot);	
					snapshot = None;
				}
			}

			SetBackgroundSmoothing(True);
			SetBackgroundStretching(True);
			SetRawBackground(snapshot, colSnapshot);
			SetRawBackgroundSize(snapshotWidth, snapshotHeight);
			StretchRawBackground(True);
			EnableRendering(False);
		}
		else
		{
			EnableRendering(True);
			MaskBackground(True);
		}
	}
	else
	{
		MaskBackground(True);
	}
}

// ----------------------------------------------------------------------
// HideSnapshot()
// ----------------------------------------------------------------------

function HideSnapshot()
{
	local DeusExPlayer player;

	EnableRendering(True);

	player = DeusExPlayer(parentPawn);
	if ((player != None) && (player.UIBackground == 0))
		MaskBackground(False);

}

// ----------------------------------------------------------------------
// MaskBackground()
// ----------------------------------------------------------------------

function MaskBackground(bool bMask)
{
	if (bMask)
	{
		SetBackground(Texture'MaskTexture');
		SetBackgroundStyle(DSTY_Modulated);
		ShowHud(False);
		if (AugDisplay != None)
		{
			AugDisplay.Hide();
		}
	}
	else
	{
		SetBackground(None);
		SetBackgroundStyle(DSTY_None);
		ShowHud(True);	
		if (AugDisplay != None)
		{
			AugDisplay.Show();
		}
	}
}

// ----------------------------------------------------------------------
// AtIntroMap()
// ----------------------------------------------------------------------

function bool AtIntroMap()
{
	local DeusExLevelInfo dxInfo;

	foreach parentPawn.AllActors(class'DeusExLevelInfo', dxInfo)
		break;

	if ((dxInfo == None) || ((dxInfo != None) && (dxInfo.missionNumber >= 0)))
		return False;
	else
		return True;
}

// ----------------------------------------------------------------------
// InvokeMenu()
//
// Pops a menu onscreen, hiding any current menu
// ----------------------------------------------------------------------

function InvokeMenu(Class<DeusExBaseWindow> newMenu)
{
	// If the top window is a menu, then we want to 
	// hide it first.

	if ( MenuUIMenuWindow(GetTopWindow()) == None )
		PushWindow(newMenu, False);
	else
		PushWindow(newMenu, True);

	// Pause the game
	if (!ShouldNegatePause(NewMenu))
	{
		UIPauseGame();
	}
}

// ----------------------------------------------------------------------
// InvokeLoadScreen()
//
// Invokes the Load Screen
// ----------------------------------------------------------------------

function InvokeLoadScreen()
{
	InvokeMenuScreen(Class'MenuScreenLoadGame');
}

// ----------------------------------------------------------------------
// InvokeSaveScreen()
//
// Invokes the Save Screen
// ----------------------------------------------------------------------

function InvokeSaveScreen()
{
	InvokeMenuScreen(Class'MenuScreenSaveGame');
}

// ----------------------------------------------------------------------
// PushWindow()
//
// Pushes a Window onto the stack.  First checks to make sure the stack
// won't overflow.  Then it checks to make sure we're not trying 
// trying to push the same type of object on the stack if an object 
// of that type is already at the top of the stack.  Then we create
// the window and show it.  
//
// Will optionally hide the current window so it's not visible underneath
// the new window.
//
// Returns the newly created window
// ----------------------------------------------------------------------

function DeusExBaseWindow PushWindow( 
	Class<DeusExBaseWindow> newWindowClass, 
	optional Bool hideCurrentWin, 
	optional Bool bNoPause)
{
	local DeusExBaseWindow newWindow;
	
	if ((!bNoPause) && (ShouldNegatePause(NewWindowClass))) bNoPause = true;
	
	newWindow = None;
	
	if ( winCount < MaxWinStack )
	{
		if ( winCount != 0 )
		{
			// As a precaution, make sure this window isn't already at the top 
			// of the stack
			if ( winStack[winCount-1].Class == newWindowClass ) 
				return None;

			// Check if we need to hide the current window
			if (( hideCurrentWin ) && (winCount > 0 ))
				winStack[winCount-1].Hide();
		}
		
		// Create the new window based on the type passed in
		newWindow = DeusExBaseWindow(NewChild(newWindowClass, True));			
		
		// Now push this new window on the stack
		winStack[winCount++] = newWindow;
		
		if ((VMDBufferPlayer(ParentPawn) != None) && (VMDBufferPlayer(ParentPawn).bDuck > 0) && (!VMDBufferPlayer(ParentPawn).bToggleCrouch))
		{
			VMDBufferPlayer(ParentPawn).UIForceDuckTimer = VMDBufferPlayer(ParentPawn).UIForceDuckTime;
		}
		
		// Pause the game
		if (!bNoPause)
			UIPauseGame();
	}

	return newWindow;
}

// ----------------------------------------------------------------------
// PopWindow()
//
// Returns the new current window, after the topmost window is 
// popped off the stack.  First checks to make sure there's at least
// one window on the stack.  Then it pops the topmost window off,
// destroys it, decrements the window count and then attempts to 
// Show() the new Topmost window if it's hidden.
//
// Returns the new Topmost window.
// ----------------------------------------------------------------------

function DeusExBaseWindow PopWindow(
	optional Bool bNoUnpause)
{
	local DeusExBaseWindow oldWindow;
	local DeusExBaseWindow newWindow;
	local DeusExPlayer Player;
	local bool bFromMain;

	Player = DeusExPlayer(parentPawn);
	bFromMain = ( MenuMain(GetTopWindow()) != None );
	
	newWindow = None;

	if ( winCount > 0 )
	{
		// First pop off the current window and destroy it.
		oldWindow = winStack[winCount-1];
		oldWindow.Destroy();
		winStack[winCount-1] = None;
		winCount--;

		if ( winCount > 0 )
		{
			newWindow = winStack[winCount-1];

			// Now show the topmost window if it's hidden
			if (!newWindow.IsVisible())
				newWindow.Show();
		}
	}

	if ((newWindow == None) && (!bNoUnpause))
		UnPauseGame();

	// When player is dead and is coming from the main menu
	if ((Player != None) && (Player.Health <= 0) && (Player.Level.NetMode != NM_Standalone))
	{
		if (bFromMain)
			Player.Fire(0);
	}

	return newWindow;
}

// ----------------------------------------------------------------------
// GetTopWindow()
//
// Returns the topmost window on the stack, or None if there 
// are no windows.
// ----------------------------------------------------------------------

function DeusExBaseWindow GetTopWindow()
{
	if ( winCount > 0 )
		return winStack[winCount-1];
	else
		return None;
}

// ----------------------------------------------------------------------
// ClearWindowStack()
//
// Runs through the window stack and destroys all the windows.
// ----------------------------------------------------------------------

function ClearWindowStack()
{
	while(winCount > 0)
	{
		if ( winStack[winCount-1] != None )
		{
			winStack[winCount-1].Destroy();
			winStack[winCount-1] = None;
			winCount--;
		}
	}

	UnPauseGame();
}

// ----------------------------------------------------------------------
// WindowStackCount()
//
// Returns the number of windows currently pushed on the stack
// ----------------------------------------------------------------------

function int WindowStackCount()
{
	return winCount;
}

// ----------------------------------------------------------------------
// ExitGame()
//
// Clears the window stack then exits the game
// ----------------------------------------------------------------------

function ExitGame()
{
	ClearWindowStack();
	parentPawn.ConsoleCommand("Exit");
}

// ----------------------------------------------------------------------
// ResetFlags()
//
// Removes all but the "SKTemp_" flags
// ----------------------------------------------------------------------

function ResetFlags()
{
	local name flagName;
	local name lastFlagName;
	local EFlagType flagType;
	local EFlagType lastFlagType;
	local String flagStringName;
	local int flagIterator;

	if (DeusExPlayer(parentPawn) != None)
	{
		flagIterator = DeusExPlayer(parentPawn).flagBase.CreateIterator();

		do 
		{
			DeusExPlayer(parentPawn).flagBase.GetNextFlag( flagIterator, flagName, flagType );

			// Delete the previous flag (this is gay)
			if (lastFlagName != '')
			{
				flagStringName = "" $ lastFlagName;

				// If "SKTemp_" can't be found, then delete the flag
				if (InStr(flagStringName, "SKTemp_") == -1)
					DeusExPlayer(parentPawn).flagBase.DeleteFlag(lastFlagName, lastFlagType);
			}
			
			lastFlagName = flagName;
 			lastFlagType = flagType;    // This is new

		} until(lastFlagName == '')

		DeusExPlayer(parentPawn).flagBase.DestroyIterator(flagIterator);
	}
}

// ======================================================================
// ======================================================================
// Color Scheme Functions
// ======================================================================
// ======================================================================

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function S_ColorScheme GetMenuColorScheme(int schemeIndex)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function S_ColorScheme GetHUDColorScheme(int schemeIndex)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function UseHUDColorScheme(int schemeIndex)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function UseMenuColorScheme(int schemeIndex)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool GetHUDTranslucency()
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function SetHUDTranslucency(bool bNewTranslucency)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool GetMenuTranslucency()
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function SetMenuTranslucency(bool bNewTranslucency)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function S_ColorScheme GetCurrentMenuColorScheme()
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function S_ColorScheme GetCurrentHUDColorScheme()
{
}


// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//MADDERS, 8/8/23: We now render this shit separately. Yay.
function VMDSetRenderLayer(name LayerName, Texture NewTexture)
{
	local int i;
	
	for (i=0; i<ArrayCount(VMDLayers); i++)
	{
		if (VMDLayerNames[i] == LayerName)
		{
			if (VMDLayers[i] != None)
			{
				VMDLayers[i].SetBackground(NewTexture);
			}
			break;
		}
	}
}

function Texture VMDGetRenderLayer(name LayerName)
{
	local int i;
	
	for (i=0; i<ArrayCount(VMDLayers); i++)
	{
		if (VMDLayerNames[i] == LayerName)
		{
			if (VMDLayers[i] != None)
			{
				return VMDLayers[i].Background;
			}
		}
	}
}

function bool ShouldNegatePause(class<Window> InvokeClass)
{
	local VMDBufferPlayer VMP;
	
	//MADDERS, 8/25/23: Gnarly hack. Keep crafting paused for these, because our robots like to run away from us.
	VMP = VMDBufferPlayer(ParentPawn);
	if ((VMP != None) && (VMP.bRealTimeUI))
	{
		switch(InvokeClass.Name)
		{
			case 'VMDMenuCraftingChemistrySetWindow':
				if (MedicalBot(VMP.FrobTarget) == None)
				{
					return true;
				}
			break;
			case 'VMDMenuCraftingToolboxWindow':
				if (RepairBot(VMP.FrobTarget) == None)
				{
					return true;
				}
			break;
			case 'MenuMain':
			case 'MenuMainInGame':
			case 'VMDMenuAugsSelector':
			case 'VMDMenuHealthSelector':
			case 'VMDMenuSelectNGPlusOptions': //MADERS, 4/3/24: Best not die doing NG plus.
			case 'MyMenuMain': //MADDERS, 3/25/24: Hello, Nihilum.
			case 'MyMainMenu':
			case 'DXRMenuMain':
			case 'DXRMenuMainInGame':
			break;
			default:
				return true;
			break;
		}
	}
	
	return false;
}

function RemoteStartNewGamePlus()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		VMP.StartNewGamePlus();
	}
}

function VMDInvokeAutoSave()
{
	UnpauseGame();
	if (VMDBufferPlayer(ParentPawn) != None)
	{
		VMDBufferPlayer(ParentPawn).VMDAutoSave();
	}
}

defaultproperties
{
     VMDLayerNames(0)=Blood
     VMDLayerNames(1)=Hunger
     VMDLayerNames(2)=LowModOverlay
     VMDLayerNames(3)=ZymeDrunk
     VMDLayerNames(4)=Overdose
     VMDLayerNames(5)=HighModOverlay
     
     MaxWinStack=12 //MADDERS: Use to be 6.
     colSnapshot=(R=128,G=128,B=128)
     snapshotWidth=256.000000
     snapshotHeight=192.000000
     DataVaultFunctions(0)=(Function="ShowInventoryWindow",winClass=Class'DeusEx.PersonaScreenInventory')
     DataVaultFunctions(1)=(Function="ShowHealthWindow",winClass=Class'DeusEx.PersonaScreenHealth')
     DataVaultFunctions(2)=(Function="ShowAugmentationsWindow",winClass=Class'DeusEx.PersonaScreenAugmentations')
     DataVaultFunctions(3)=(Function="ShowSkillsWindow",winClass=Class'DeusEx.VMDPersonaScreenSkills')
     DataVaultFunctions(4)=(Function="ShowGoalsWindow",winClass=Class'DeusEx.PersonaScreenGoals')
     DataVaultFunctions(5)=(Function="ShowConversationsWindow",winClass=Class'DeusEx.PersonaScreenConversations')
     DataVaultFunctions(6)=(Function="ShowImagesWindow",winClass=Class'DeusEx.PersonaScreenImages')
     DataVaultFunctions(7)=(Function="ShowLogsWindow",winClass=Class'DeusEx.PersonaScreenLogs')
     QuickLoadTitle="Quick Load?"
     QuickLoadMessage="You will lose your current game in progress, are you sure you wish to Quick Load?"
}
