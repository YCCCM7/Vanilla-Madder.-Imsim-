//=============================================================================
// HUDMedBotNavBarWindow
//=============================================================================
class HUDMedBotNavBarWindow extends PersonaNavBarBaseWindow;

var PersonaNavButtonWindow btnHealth;
var PersonaNavButtonWindow btnAugs;

var localized String HealthButtonLabel;
var localized String AugsButtonLabel;

//5/19/22: MADDERS: Do some spicy crafting stuff.
var MedicalBot MedBot;
var VMDBufferPlayer VMP;
var PersonaNavButtonWindow BtnCrafting;
var localized string CraftingButtonLabel;

// ----------------------------------------------------------------------
// CreateButtons()
// ----------------------------------------------------------------------

function CreateButtons()
{
	VMP = VMDBufferPlayer(Player);
	
	if ((VMP != None) && (VMP.bCraftingSystemEnabled))
	{
		BtnCrafting = CreateNavButton(WinNavButtons, CraftingButtonLabel);
		if (!VMP.CanCraftMedical(True, True))
		{
			BtnCrafting.SetSensitivity(False);
		}
	}
	btnAugs = CreateNavButton(winNavButtons, AugsButtonLabel);
	btnHealth = CreateNavButton(winNavButtons, HealthButtonLabel);
	
	Super.CreateButtons();
}

// ----------------------------------------------------------------------
// CreateButtonWindow()
// ----------------------------------------------------------------------

function CreateButtonWindows()
{
	Super.CreateButtonWindows();

	winNavButtons.FillAllSpace(False);
}

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------

function bool ButtonActivated(Window buttonPressed)
{
	local bool bHandled;
	local HUDMedBotHealthScreen healthScreen;
	local HUDMedBotAddAugsScreen augScreen;
	local MedicalBot medBot;

	bHandled = True;

	switch(buttonPressed)
	{
		case btnHealth:
			// Need to be sure the MedBot variable is set in the 
			// Health Screen when we bring it up

			augScreen = HUDMedBotAddAugsScreen(GetParent());
			if (augScreen != None)
			{
				augScreen.SkipAnimation(True);
				medBot = augScreen.medBot;
			}

			// Invoke the health screen
			healthScreen = HUDMedBotHealthScreen(root.InvokeUIScreen(Class'HUDMedBotHealthScreen', True));

			// Now set the medBot if it's not none
			if (medBot != None)
				healthScreen.SetMedicalBot(medBot);

		break;
		case btnAugs:
			// Need to be sure the MedBot variable is set in the 
			// Health Screen when we bring it up
			
			healthScreen = HUDMedBotHealthScreen(GetParent());
			if (healthScreen != None)
			{
				healthScreen.SkipAnimation(True);
				medBot = healthScreen.medBot;
			}
			
			augScreen = HUDMedBotAddAugsScreen(root.InvokeUIScreen(Class'HUDMedBotAddAugsScreen', True));
			
			// Now set the medBot if it's not none
			if (medBot != None)
				augScreen.SetMedicalBot(medBot);

		break;
		case BtnCrafting:
			if (BtnCrafting != None)
			{
				VMDInvokeCraftingScreen();
			}
			else
			{
				bHandled = false;
			}
		break;
		default:
			bHandled = False;
		break;
	}

	if (bHandled)
		return bHandled;
	else
		return Super.ButtonActivated(buttonPressed);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function VMDInvokeCraftingScreen()
{
	local VMDMenuCraftingChemistrySetWindow CraftScreen;
	
	CraftScreen = VMDMenuCraftingChemistrySetWindow(root.InvokeUIScreen(Class'VMDMenuCraftingChemistrySetWindow', False));
	CraftScreen.SetMedbot(Medbot);
}

defaultproperties
{
     HealthButtonLabel=" |&Health   "
     AugsButtonLabel="   |&Augmentations   "
     CraftingButtonLabel=" |&Crafting   "
}
