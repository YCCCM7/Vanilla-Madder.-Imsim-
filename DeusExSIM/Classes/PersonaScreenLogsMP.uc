//=============================================================================
// PersonaScreenLogs
//=============================================================================

class PersonaScreenLogsMP extends PersonaScreenLogs;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super(PersonaScreenBaseWindow).InitWindow();

	PopulateLog();

	EnableButtons();
	
	winScroll.EnableScrolling(True, True); // Enable horizontal scrolling here.
}

function CreateNavBarWindow()
{
}

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
