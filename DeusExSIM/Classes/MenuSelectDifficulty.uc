//=============================================================================
// MenuSelectDifficulty
//=============================================================================
class MenuSelectDifficulty extends MenuUIMenuWindow;

var bool bDisarmed, bGavePlayerGuideTip;
var float SavedDiff;

var localized string PlayerGuideTipHeader, PlayerGuideTipText, DifficultyDescHeader[7], DifficultyDescText[7];

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	AddTimer(0.1, false,, 'GiveStartTip');
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
			TeaseNewGameScreen(0);
		break;
		
		case "EASY":
			TeaseNewGameScreen(1);
		break;
		
		case "MEDIUM":
			TeaseNewGameScreen(2);
		break;
		
		case "HARD":
			TeaseNewGameScreen(3);
		break;
		
		case "REALISTIC":
			TeaseNewGameScreen(4);
		break;
		
		case "NIGHTMARE":
			TeaseNewGameScreen(5);
		break;
		
		case "GALLOWS":
			TeaseNewGameScreen(6);
		break;
		case "QUIT":
			bDisarmed = False;
			//Player.ConsoleCommand("Open DXOnly");
			Root.PopWindow();
		break;
	}
}

function TeaseNewGameScreen(int TarIndex)
{
	switch(TarIndex)
	{
		case 0:
			SavedDiff = 0.0;
		break;
		case 1:
			SavedDiff = 1.0;
		break;
		case 2:
			SavedDiff = 1.5;
		break;
		case 3:
			SavedDiff = 2.0;
		break;
		case 4:
			SavedDiff = 4.0;
		break;
		case 5:
			SavedDiff = 6.0;
		break;
		case 6:
			SavedDiff = 8.0;
		break;
	}
	
	GiveTip(TarIndex);
}

function GiveTip(int TType)
{
	root.MessageBox(DifficultyDescHeader[TType], DifficultyDescText[TType], 0, False, Self);
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
			if (!bGavePlayerGuideTip)
			{
				bGavePlayerGuideTip = true;
			}
			else
			{
				InvokeNewGameScreen(SavedDiff);
			}
		break;
		case 1:
			Root.PopWindow();
		break;
	}
	return true;
}

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen(float difficulty)
{
	local VMDMenuSelectCampaign newGame;
	local VMDBufferPlayer VMP;
	
	newGame = VMDMenuSelectCampaign(root.InvokeMenuScreen(Class'VMDMenuSelectCampaign'));
	
	//MADDERS: Call relevant reset data.
	if (VMDBufferPlayer(Player) != None)
	{
		VMDBufferPlayer(Player).VMDResetNewGameVars(1);
	}
	
	//MADDERS: We only call this from the main menu, NOT in game.
	//By this logic, setting it all on the fly is fine.
	Player.CombatDifficulty = Difficulty;
	if (newGame != None)
	{
		newGame.SetDifficulty(difficulty);
	}
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

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

event DestroyWindow()
{
	//MADDERS: Experimental.
	//if (!bDisarmed)
	//{
		Player.ConsoleCommand("Open DXOnly");
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
     
     PlayerGuideTipHeader="To New Players"
     PlayerGuideTipText="It is highly recommended that you check out the VMD Player Guide on youtube or moddb before beginning. For now it stands in place of a tutorial."
     DifficultyDescHeader(0)="About <Disabled>"
     DifficultyDescHeader(1)="About Easy"
     DifficultyDescHeader(2)="About Medium"
     DifficultyDescHeader(3)="About Hard"
     DifficultyDescHeader(4)="About Realistic"
     DifficultyDescHeader(5)="About Nightmare"
     DifficultyDescHeader(6)="About Gallows"
     DifficultyDescText(0)="I don't know how you even accessed this. You take no damage on this mode."
     DifficultyDescText(1)="Easy deals 100% damage and has 100% hunger/timer rate. Hong Kong is forgiving.   Proceed?"
     DifficultyDescText(2)="Medium deals 150% damage and has 122% hunger/timer rate. Hong Kong is forgiving.   Proceed?"
     DifficultyDescText(3)="Hard deals 200% damage and has 141% hunger/timer rate.   Proceed?"
     DifficultyDescText(4)="Realistic deals 400% damage and has 200% hunger/timer rate.   Proceed?"
     DifficultyDescText(5)="Nightmare deals 600% damage and has 245% hunger/timer rate. Infamy and enemy health gate are enabled.   Proceed?"
     DifficultyDescText(6)="Gallows deals 800% damage and has 283% hunger/timer rate. Extreme infamy, enemy health gate, loot reduction, and save limitations are enabled.   Proceed?"
}
