//=============================================================================
// MenuMainForceQuit. A hack from outer space.
//=============================================================================
class MenuMainForceQuit extends MenuUIMenuWindow;

var string TitleForced;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	AddTimer(0.05, false,,'DoLoadMainMenu');
}

function DoLoadMainMenu()
{
	GetPlayerPawn().ConsoleCommand("Open DXOnly");
}

//MADDERS: Always, always, ALWAYS show our title at the start screen, regardless of localization.
function SetTitle(String newTitle)
{
	//winTitle.SetTitle(newTitle);
	winTitle.SetTitle(TitleForced);
}

/*function DestroyWindow()
{
	if (VMDBufferPlayer(GetPlayerPawn()) != None) VMDBufferPlayer(GetPlayerPawn()).VMDCloseMainMenuHook();
	
	Super.DestroyWindow();
}*/

defaultproperties
{
     ButtonNames(0)="Main Menu"
     ButtonNames(1)="Save Game"
     ButtonNames(2)="Load Game"
     ButtonNames(3)="Settings"
     ButtonNames(4)="Training"
     ButtonNames(5)="Play Intro"
     ButtonNames(6)="Credits"
     ButtonNames(7)="Back to Game"
     ButtonNames(8)="Multiplayer"
     ButtonNames(9)="Exit"
     buttonXPos=7
     buttonWidth=245
     buttonDefaults(0)=(Y=13,Action=MA_NewGame)
     buttonDefaults(1)=(Y=49,Action=MA_MenuScreen,Invoke=Class'DeusEx.MenuScreenSaveGame')
     buttonDefaults(2)=(Y=85,Action=MA_MenuScreen,Invoke=Class'DeusEx.MenuScreenLoadGame')
     buttonDefaults(3)=(Y=121,Invoke=Class'DeusEx.MenuSettings')
     buttonDefaults(4)=(Y=157,Action=MA_Training)
     buttonDefaults(5)=(Y=193,Action=MA_Intro)
     buttonDefaults(6)=(Y=229,Action=MA_MenuScreen,Invoke=Class'DeusEx.CreditsWindow')
     buttonDefaults(7)=(Y=265,Action=MA_Previous)
     buttonDefaults(8)=(Y=301,Action=MA_MenuScreen,Invoke=Class'DeusEx.menumpmain')
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
