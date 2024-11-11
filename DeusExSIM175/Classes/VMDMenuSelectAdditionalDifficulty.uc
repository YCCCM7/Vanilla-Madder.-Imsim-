//=============================================================================
// VMDMenuSelectAdditionalDifficulty
//=============================================================================
class VMDMenuSelectAdditionalDifficulty expands MenuUIMenuWindow;

var bool bDisarmed;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
}

// ----------------------------------------------------------------------
// WindowReady() 
// ----------------------------------------------------------------------

event WindowReady()
{
	// Set focus to the Medium button
	SetFocusWindow(winButtons[1]);
}

// ----------------------------------------------------------------------
// ProcessCustomMenuButton()
// ----------------------------------------------------------------------

function ProcessCustomMenuButton(string key)
{
	bDisarmed = True;
	switch(key)
	{
		//MADDERS difficulties.
		case "DISABLED":
			InvokeNewGameScreen(0.0);
		break;
		
		case "EASY":
			InvokeNewGameScreen(1.0);
		break;
		
		case "MEDIUM":
			InvokeNewGameScreen(1.5);
		break;
		
		case "HARD":
			InvokeNewGameScreen(2.0);
		break;
		
		case "REALISTIC":
			InvokeNewGameScreen(4.0);
		break;
			
		case "NIGHTMARE":
			InvokeNewGameScreen(6.0);
		break;
		
		case "GALLOWS":
			InvokeNewGameScreen(8.0);
		break;
		case "QUIT":
			bDisarmed = False;
			//Player.ConsoleCommand("Open DXOnly");
			Root.PopWindow();
		break;
	}
}

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen(float difficulty)
{
	local VMDMenuSelectAdditionalCampaign newGame;
	local VMDBufferPlayer VMP;
	
	newGame = VMDMenuSelectAdditionalCampaign(root.InvokeMenuScreen(Class'VMDMenuSelectAdditionalCampaign'));
	
	//MADDERS: Call relevant reset data.
	if (VMDBufferPlayer(Player) != None)
	{
		//VMDBufferPlayer(Player).VMDResetNewGameVars(1);
	}
	
	//MADDERS: We only call this from the main menu, NOT in game.
	//By this logic, setting it all on the fly is fine.
	Player.CombatDifficulty = Difficulty;
	if (newGame != None)
		newGame.SetCampaignData(difficulty);
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
	//MADDERS: Experimental.
	//if (!bDisarmed)
	//{
	//	Player.ConsoleCommand("Open DXOnly");
	//}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ButtonNames(0)="Easy"
     ButtonNames(1)="Medium"
     ButtonNames(2)="Hard"
     ButtonNames(3)="Realistic"
     ButtonNames(4)="Nightmare"
     ButtonNames(5)="Gallows"
     ButtonNames(6)="Main Menu"
     buttonXPos=7
     buttonWidth=245
     buttonDefaults(0)=(Y=13,Action=MA_Custom,Key="EASY")
     buttonDefaults(1)=(Y=49,Action=MA_Custom,Key="MEDIUM")
     buttonDefaults(2)=(Y=85,Action=MA_Custom,Key="HARD")
     buttonDefaults(3)=(Y=121,Action=MA_Custom,Key="REALISTIC")
     buttonDefaults(4)=(Y=157,Action=MA_Custom,Key="NIGHTMARE")
     buttonDefaults(5)=(Y=193,Action=MA_Custom,Key="GALLOWS")
     buttonDefaults(6)=(Y=251,Action=MA_Custom,Key="QUIT") //Action=MA_Previous
     Title="Select Combat Difficulty"
     ClientWidth=258
     ClientHeight=293
     clientTextures(0)=Texture'NewDifficultyBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuDifficultyBackground_2'
     clientTextures(2)=Texture'NewDifficultyBackground_3'
     clientTextures(3)=Texture'BlackMaskTex'
     textureRows=2
     textureCols=2
}
