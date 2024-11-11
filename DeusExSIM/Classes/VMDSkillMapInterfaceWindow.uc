//=============================================================================
// VMDSkillMapInterfaceWindow
//=============================================================================
class VMDSkillMapInterfaceWindow extends ButtonWindow;

//----------------------
//Start with essentialy stuff.
var DeusExPlayer player;
var VMDPersonaScreenSkills winSkills;

var int AssignedWidth, AssignedHeight, SourceSizeX, SourceSizeY;
var float ZoomRenderScale;

var Texture InterfaceTex;

// Border and Background Translucency
var bool bBorderTranslucent;
var bool bBackgroundTranslucent;
var bool bDrawBorder;

// Default Colors
var Color ColBackground, ColWhite, ColGray, ColDarkGray;

//----------------------
//Barf child window stuff!

// Drag/Drop Stuff
var bool bDragging;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(AssignedWidth, AssignedHeight);
	
	CreateControls();
	
	// Get a pointer to the player
	player = DeusExPlayer(GetRootWindow().parentPawn);
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local float UnivScale;
	
	if (InterfaceTex != None)
	{
		// Draw the icon
		/*if (bIconTranslucent)
			gc.SetStyle(DSTY_Translucent);		
		else*/
		
		gc.SetStyle(DSTY_Masked);
		gc.SetTileColor(colBackground);
		
		UnivScale = ZoomRenderScale;
		gc.DrawStretchedTexture(0, 0, AssignedWidth*UnivScale, AssignedHeight*UnivScale, 0, 0, SourceSizeX, SourceSizeY, InterfaceTex);
	}
}

// ----------------------------------------------------------------------
// VirtualKeyPressed()
// ----------------------------------------------------------------------

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	return False;
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
}

// ----------------------------------------------------------------------
// VMDSetupInterfaceVars()
// ----------------------------------------------------------------------

function VMDSetupInterfaceVars(int NAW, int NAH, Texture NAT, VMDPersonaScreenSkills NWS)
{
	SetSize(NAW, NAH);
	AssignedWidth = NAW;
	AssignedHeight = NAH;
	SourceSizeX = NAW;
	SourceSizeY = NAH;
	InterfaceTex = NAT;
	WinSkills = NWS;
}

// ----------------------------------------------------------------------
// SelectButton()
// ----------------------------------------------------------------------

function SelectButton(Bool bNewSelected)
{
	// TODO: Replace with HUD sounds
	PlaySound(Sound'Menu_Press', 0.25); 
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	
	theme = player.ThemeManager.GetCurrentHUDColorTheme();
	
	colBackground = theme.GetColorFromName('HUDColor_Background');
	ColDarkGray.R = ((ColBackground.R*0.35) + (Default.ColDarkGray.R*0.65));
	ColDarkGray.G = ((ColBackground.G*0.35) + (Default.ColDarkGray.G*0.65));
	ColDarkGray.B = ((ColBackground.B*0.35) + (Default.ColDarkGray.B*0.65));
	
	bBorderTranslucent     = player.GetHUDBorderTranslucency();
	bBackgroundTranslucent = player.GetHUDBackgroundTranslucency();
	bDrawBorder            = player.GetHUDBordersVisible();
}

// ----------------------------------------------------------------------
// MouseButtonPressed()
//
// If the user presses the mouse button, initiate drag mode
// ----------------------------------------------------------------------

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button,
                              int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if (button == IK_LeftMouse)
	{
		StartButtonDrag();
		bResult = True;
	}
	return bResult;
}

// ----------------------------------------------------------------------
// MouseButtonReleased()
//
// If we were in drag mode, then release the mouse button.
// If the player is over a new (and valid) inventory location or 
// object belt location, drop the item here.
// ----------------------------------------------------------------------

event bool MouseButtonReleased(float pointX, float pointY, EInputKey button,
                               int numClicks)
{
	if (button == IK_LeftMouse)
	{
		FinishButtonDrag();
		return True;
	}
	else
	{
		return false;  // don't handle
	}
}

// ----------------------------------------------------------------------
// MouseMoved()
// ----------------------------------------------------------------------

event MouseMoved(float newX, float newY)
{
}

function UpdateZoomLevel()
{
	if ((WinSkills != None) && (WinSkills.ZoomInFactor > 0.0))
	{
		ZoomRenderScale = WinSkills.ZoomInFactor;
	}
}

// ----------------------------------------------------------------------
// StartButtonDrag()
// ----------------------------------------------------------------------

function StartButtonDrag()
{
	if (WinSkills != None)
	{
		WinSkills.StartButtonDrag(Self);
		if (WinSkills.CurDragInterface == Self)
		{
			bDragging  = True;
		}
	}
}

// ----------------------------------------------------------------------
// FinishButtonDrag()
// ----------------------------------------------------------------------

function FinishButtonDrag()
{
	bDragging  = False;
	
	if (WinSkills != None)
		WinSkills.FinishButtonDrag();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    SourceSizeX=64
    SourceSizeY=64
    ZoomRenderScale=1.000000
    ColBackground=(R=255,G=0,B=255)
    ColWhite=(R=255,G=255,B=255)
    ColGray=(R=128,G=128,B=128)
    ColDarkGray=(R=10,G=10,B=10)
}
