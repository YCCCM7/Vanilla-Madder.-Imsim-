//=============================================================================
// MenuUISliderButtonWindowMini
//=============================================================================
class MenuUISliderButtonWindowMini extends Window;

var DeusExPlayer player;

var ScaleWindow winSlider;
var ScaleManagerWindow winScaleManager;
var MenuUIInfoButtonWindow winScaleText;

var Texture defaultScaleTexture;
var Texture defaultThumbTexture;

var int defaultWidth;
var int defaultHeight;
var int defaultScaleWidth;
var Bool bUseScaleText;

var int ArrayIndex;
var string ConfigSetting;
var Window ParentWindow;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(defaultWidth, defaultHeight);
	
	// Create the Scale Manager Window
	winScaleManager = ScaleManagerWindow(NewChild(Class'ScaleManagerWindow'));
	winScaleManager.SetSize(defaultScaleWidth, 12);
	winScaleManager.SetMarginSpacing(10);
	
	// Create the slider window 
	winSlider = ScaleWindow(winScaleManager.NewChild(Class'ScaleWindow'));
	winSlider.SetScaleOrientation(ORIENT_Horizontal);
	winSlider.SetThumbSpan(0);
	winSlider.SetScaleTexture(defaultScaleTexture, defaultScaleWidth, 12, 8, 8);
	winSlider.SetThumbTexture(defaultThumbTexture, 9, 10); //15
	winSlider.SetScaleSounds(Sound'Menu_Press', None, Sound'Menu_Slider');
	winSlider.SetSoundVolume(0.25);
	
	// Create the text window
	if (bUseScaleText)
	{
		winScaleText = MenuUIInfoButtonWindow(NewChild(Class'MenuUIInfoButtonWindow'));
		winScaleText.SetSelectability(False);
		winScaleText.SetWidth(60);
		winScaleText.SetPos(184, 1);
	}
	
	// Tell the Scale Manager wazzup.
	winScaleManager.SetScale(winSlider);
	
	// Get a pointer to the player
	player = DeusExPlayer(GetRootWindow().parentPawn);
	
	StyleChanged();
}

// ----------------------------------------------------------------------
// SetTicks()
// ----------------------------------------------------------------------

function SetTicks( int numTicks, int startValue, int endValue)
{
	winSlider.SetValueRange(startValue, endValue);
	winSlider.SetNumTicks(numTicks);
}

// ----------------------------------------------------------------------
// ScalePositionChanged() : Called when an ancestor scale window's
//                          position is moved
// ----------------------------------------------------------------------

event bool ScalePositionChanged(Window scale, int newTickPosition,
                                float newValue, bool bFinal)
{
	if (winScaleText != None)
	{
		winScaleText.SetButtonText(winSlider.GetValueString());
	}
	if (ConfigSetting != "")
	{
		Player.SetPropertyText(ConfigSetting, WinSlider.GetValueString());
	}
	if (ParentWindow != None)
	{
		ParentWindow.SetPropertyText("LastMiniSlider", String(Self));
		ParentWindow.AddTimer(0.01, false,, 'MiniSliderChanged');
	}
	
	return False;
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	local Color colButtonFace;
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	// Title colors
	colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
	
	winSlider.SetThumbColor(colButtonFace);
	winSlider.SetScaleColor(colButtonFace);
	winSlider.SetTickColor(colButtonFace);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     defaultScaleTexture=Texture'VMDMenuSliderBarMini'
     defaultThumbTexture=Texture'VMDMenuSliderMini'
     DefaultWidth=96
     defaultHeight=12
     defaultScaleWidth=96
     bUseScaleText=False
}
