//=============================================================================
// VMDSkillMapHoverTip
//=============================================================================
class VMDSkillMapHoverTip extends PersonaEditWindow;

var Color colEditTextNormal;
var Color colEditTextAlert;
var Color colEditTextHighlight;
var Color colEditHighlight;
var Color colBackground;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	local Color TCol;
	
	Super.InitWindow();
	
	SetTextMargins(2, 2);
	SetMaxSize(720); //MADDERS, 12/8/21: Upgraded from 200, then from 600.
	SetSelectedAreaTexture(Texture'Solid', colEditHighlight);
	SetSelectedAreaTextColor(colEditTextHighlight);
	
	SetBackgroundStyle(DSTY_Modulated);
	SetTileColor(colBackground);
	SetBackground(Texture'VMDNoteEditBackground');
}

// ----------------------------------------------------------------------
// SetNote()
// ----------------------------------------------------------------------

function SetNote(string NewNote, bool bAlert)
{
	SetText(NewNote);
	SetTextColor(ColEditTextNormal);
	if (bAlert)
	{
		SetTextColor(ColEditTextAlert);
	}
	SetInsertionPointTexture(None, colCursor);
}

// ----------------------------------------------------------------------
// SetTextColors()
// ----------------------------------------------------------------------

function SetTextColors(Color colTextNormal, Color colTextFocus, Color colBack)
{
	//colEditTextNormal    = colTextNormal;
	//colEditTextAlert     = colTextFocus;
	colEditTextHighlight = colBack;
	colEditHighlight     = colTextFocus;
	colBackground        = colBack;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     colEditTextNormal=(R=255,G=255,B=255)
     colEditTextAlert=(R=255,G=255,B=0)
     colEditHighlight=(R=255,G=255,B=255)
     colBackground=(R=32,G=32,B=32)
}
