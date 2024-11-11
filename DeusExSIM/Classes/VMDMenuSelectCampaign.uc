//=============================================================================
// VMDMenuSelectCampaign
//=============================================================================
class VMDMenuSelectCampaign expands MenuUIMenuWindow;

var float StoredDifficulty;

function SetDifficulty(float NewDiff)
{
	StoredDifficulty = NewDiff;
}

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
	SetFocusWindow(winButtons[0]);
}

// ----------------------------------------------------------------------
// ProcessCustomMenuButton()
// ----------------------------------------------------------------------

function ProcessCustomMenuButton(string key)
{
	switch(key)
	{
		case "CUSTOM":
			//return;
			InvokeCustomNewGameScreen();
		break;
		default:
			//MADDERS: This may change some time later, so be ready.
			InvokeNewGameScreen(key);
		break;
	}
}

// ----------------------------------------------------------------------
// InvokeCustomNewGameScreen()
// ----------------------------------------------------------------------

function InvokeCustomNewGameScreen()
{
	local VMDMenuSelectCustomCampaign NewGame;
	
	newGame = VMDMenuSelectCustomCampaign(root.InvokeMenuScreen(Class'VMDMenuSelectCustomCampaign'));
	
	if (newGame != None)
	{
		newGame.SetCampaignData(StoredDifficulty);
	}
}

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen(string Campaign)
{
	local VMDMenuSelectAppearance NewGame;
	local VMDBufferPlayer VMP;
	
	newGame = VMDMenuSelectAppearance(root.InvokeMenuScreen(Class'VMDMenuSelectAppearance'));
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		//MADDERS: Call relevant reset data.
		VMP.VMDResetNewGameVars(2);
		
		VMP.InvokedBindName = "";
		VMP.SelectedCampaign = Campaign;
		switch(CAPS(Campaign))
		{
			case "VANILLA":
				//VMP.CampaignNewGameMap = "00_Intro";
				VMP.CampaignNewGameMap = "01_NYC_UNATCOIsland";
			break;
			case "REDSUN":
			case "REDSUN 2020":
				VMP.CampaignNewGameMap = "21_Intro1";
				//VMP.CampaignNewGameMap = "21_OtemachiLab_1";				
			break;
			case "ZODIAC":
				VMP.InvokedBindName = "PaulDenton";
				VMP.CampaignNewGameMap = "69_Zodiac_Intro";
				//VMP.CampaignNewGameMap = "70_Zodiac_HongKong_TongBase";
			break;
			case "CARONE":
			case "HOTEL CARONE":
				VMP.CampaignNewGameMap = "16_HotelCarone_Intro";
				//VMP.CampaignNewGameMap = "16_HotelCarone_House";
			break;
			case "TNM":
				VMP.CampaignNewGameMap = "";
			break;
			case "OMEGA":
				VMP.CampaignNewGameMap = "50_OmegaStart";
			break;
			case "NIHILUM":
				VMP.InvokedBindName = "MadIngram";
				VMP.CampaignNewGameMap = "59_Intro";
			break;
		}
	}
	if (newGame != None)
	{
		newGame.SetCampaignData(StoredDifficulty, Campaign);
	}
}

     //ButtonNames(1)="Redsun 2020"
     //ButtonNames(2)="Zodiac"
     //ButtonNames(3)="Hotel Carone"
     //ButtonNames(4)="Nihilum"
     //ButtonNames(5)="Omega"
     //buttonDefaults(1)=(Y=49,Action=MA_Custom,Key="REDSUN")
     //buttonDefaults(2)=(Y=85,Action=MA_Custom,Key="ZODIAC")
     //buttonDefaults(3)=(Y=121,Action=MA_Custom,Key="CARONE")
     //buttonDefaults(4)=(Y=157,Action=MA_Custom,Key="NIHILUM")
     //buttonDefaults(5)=(Y=193,Action=MA_Custom,Key="OMEGA")

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ButtonNames(0)="Vanilla"
     ButtonNames(1)="Custom"
     ButtonNames(2)="Previous Menu"
     buttonXPos=7
     buttonWidth=245
     buttonDefaults(0)=(Y=13,Action=MA_Custom,Key="VANILLA")
     buttonDefaults(1)=(Y=49,Action=MA_Custom,Key="CUSTOM")
     buttonDefaults(2)=(Y=107,Action=MA_Previous)
     //These butons refuse to stop spawning, so fuck it. Do this instead.
     buttonDefaults(3)=(Y=9999,Action=MA_Previous,Key="ERR")
     buttonDefaults(4)=(Y=9999,Action=MA_Previous,Key="ERR")
     buttonDefaults(5)=(Y=9999,Action=MA_Previous,Key="ERR")
     buttonDefaults(6)=(Y=9999,Action=MA_Previous,Key="ERR")
     Title="Select Campaign to Play"
     ClientWidth=258
     ClientHeight=149
     clientTextures(0)=Texture'MenuCampaignBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuDifficultyBackground_2'
     clientTextures(2)=Texture'BlackMaskTex'
     clientTextures(3)=Texture'BlackMaskTex'
     textureRows=2
     textureCols=2
}
