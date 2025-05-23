//=============================================================================
// MenuMain
//=============================================================================
class MenuMain extends MenuUIMenuWindow;

var string TitleForced;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	UpdateButtonStatus();
	ShowVersionInfo();
}

// ----------------------------------------------------------------------
// UpdateButtonStatus()
// ----------------------------------------------------------------------

function UpdateButtonStatus()
{
	local DeusExLevelInfo info;
	
	info = player.GetLevelInfo();
	
	// Disable the "Save Game" and "Back to Game" menu choices
	// if the player's dead or we're on the logo map.
	//
	// Also don't allow the user to save if a DataLink is playing
	
   	// Don't disable in mp if dead.
	
	if (((info != None) && (info.MissionNumber < 0)) || ((player.IsInState('Dying')) || (player.IsInState('Paralyzed')) || (player.IsInState('Interpolating'))))
	{
      		if (Player.Level.NetMode == NM_Standalone)
      		{
         		winButtons[1].SetSensitivity(False);
         		//winButtons[8].SetSensitivity(False);
      		}
   	}
	
   	// Disable the "Save Game", "New Game", "Intro", "Training" and "Load Game" menu choices if in multiplayer
   	if (player.Level.Netmode != NM_Standalone)
   	{
      		winButtons[0].SetSensitivity(False);
      		winButtons[1].SetSensitivity(False);
      		winButtons[2].SetSensitivity(False);
      		winButtons[4].SetSensitivity(False);
      		winButtons[5].SetSensitivity(False);
   	}
	
	// Don't allow saving if a datalink is playing
	//----------------------
	// MADDERS: Allow saving during datalink.
	//Update, 10/26/24: But not during the small period where bad stuff happens.
	if ((Player.DataLinkPlay != None) && (Player.DataLinkPlay.bStartTransmission || (Player.DataLinkPlay.bEndTransmission && Player.DataLinkPlay.DataLinkQueue[0] != None)))
	{
		WinButtons[1].SetSensitivity(False);
	}
	
	// DEUS_EX_DEMO - Uncomment when building demo
	//
	// Disable the "Play Intro" button for the demo
//	winButtons[5].SetSensitivity(False);
}

// ----------------------------------------------------------------------
// ShowVersionInfo()
// ----------------------------------------------------------------------

function ShowVersionInfo()
{
	local TextWindow version;

	version = TextWindow(NewChild(Class'TextWindow'));
	// version.SetTextMargins(0, 0);
	version.SetTextMargins(57, 6);
	// version.SetWindowAlignments(HALIGN_Right, VALIGN_Bottom);
	version.SetWindowAlignments(HALIGN_Left, VALIGN_Bottom,, -8);
	version.SetTextColorRGB(255, 255, 255);
	// version.SetTextAlignments(HALIGN_Right, VALIGN_Bottom);
	version.SetTextAlignments(HALIGN_Left, VALIGN_Bottom);
	// version.SetText(player.GetDeusExVersion());
	version.SetText("Using DX:Transcended" @ Human(player).BuildVersionString());
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

//MADDERS: Always, always, ALWAYS show our title at the start screen, regardless of localization.
function SetTitle(String newTitle)
{
	//winTitle.SetTitle(newTitle);
	winTitle.SetTitle(TitleForced);
}

function DestroyWindow()
{
	if (VMDBufferPlayer(GetPlayerPawn()) != None) VMDBufferPlayer(GetPlayerPawn()).VMDCloseMainMenuHook();
	
	Super.DestroyWindow();
}

defaultproperties
{
     ButtonNames(0)="New Game"
     ButtonNames(1)="Save Game"
     ButtonNames(2)="Load Game"
     ButtonNames(3)="Settings"
     ButtonNames(4)="Training"
     ButtonNames(5)="VMD Training"
     ButtonNames(6)="Play Intro"
     ButtonNames(7)="Credits"
     ButtonNames(8)="Back to Game"
     ButtonNames(9)="Exit"
     buttonXPos=7
     buttonWidth=245
     buttonDefaults(0)=(Y=13,Action=MA_NewGame)
     buttonDefaults(1)=(Y=49,Action=MA_MenuScreen,Invoke=Class'DeusEx.MenuScreenSaveGame')
     buttonDefaults(2)=(Y=85,Action=MA_MenuScreen,Invoke=Class'DeusEx.MenuScreenLoadGame')
     buttonDefaults(3)=(Y=121,Invoke=Class'DeusEx.MenuSettings')
     buttonDefaults(4)=(Y=157,Action=MA_Training)
     buttonDefaults(5)=(Y=193,Action=MA_MenuScreen,Invoke=Class'DeusEx.VMDMenuTrainingSelection')
     buttonDefaults(6)=(Y=229,Action=MA_Intro)
     buttonDefaults(7)=(Y=265,Action=MA_MenuScreen,Invoke=Class'DeusEx.CreditsWindow')
     buttonDefaults(8)=(Y=301,Action=MA_Previous)
     buttonDefaults(9)=(Y=359,Action=MA_Quit)
     Title="Welcome to DEUS EX"
     TitleForced="Vanilla? Madder."
     ClientWidth=258
     ClientHeight=400
     verticalOffset=2
     clientTextures(0)=Texture'DeusExUI.UserInterface.MenuMainBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuMainBackground_2'
     clientTextures(2)=Texture'DeusExUI.UserInterface.MenuMainBackground_3'
     textureCols=2
}
