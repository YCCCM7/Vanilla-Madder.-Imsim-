//=============================================================================
// TimerDisplay.
//=============================================================================
class TimerDisplay extends Window;

var bool bCritical, bFlash, bIntegerDisplay;
var float time, flashTime;
var string message;
var Color colNormal, colCritical, colBlack;
var Texture timerBackground;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	bTickEnabled = True;
	SetBackgroundStyle(DSTY_Modulated);
	SetBackground(timerBackground);
	SetTileColorRGB(0, 0, 0);
	SetSize(80, 36);

	time = 0;
	flashTime = 0;
}

event Tick(float deltaTime)
{
	if (bFlash)
	{
		flashTime += deltaTime;
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local int mins;
	local float secs;
	local string str, SecString;
	
	Super.DrawWindow(gc);
	
	// Draw the timer
	gc.SetFont(Font'FontComputer8x20_B');
	gc.SetAlignments(HALIGN_Center, VALIGN_Bottom);
	gc.EnableWordWrap(False);
	
	if (bCritical)
	{
		gc.SetTextColor(colCritical);
	}
	else
	{
		gc.SetTextColor(colNormal);
	}
	
	// print the time nicely
	mins = time / 60;
	secs = time % 60;
	
	//MADDERS, 11/18/24: For use with mission scripts.
	if (bIntegerDisplay)
	{
		if (mins < 10)
		{
			str = "0";
		}
		str = str $ mins $ ":";
		if (secs < 10)
		{
			str = str $ "0";
		}
		str = str $ int(secs);
	}
	else
	{
		if (mins < 10)
		{
			str = "0";
		}
		str = str $ mins $ ":";
		if (secs < 10)
		{
			str = str $ "0";
		}
		SecString = string(Secs);
		if (Mins > 99)
		{
			SecString = Left(SecString, Len(SecString)-4);
		}
		else if (Mins > 9)
		{
			SecString = Left(SecString, Len(SecString)-2);
		}
		str = str $ SecString;
	}
	
	if ((bFlash) && (flashTime >= 0.75))
	{
		gc.SetTextColor(colBlack);
		if (flashTime >= 1.0)
		{
			flashTime = 0;
		}
	}
	
	gc.DrawText(0, 0, width, height, str);
	
	// draw title
	gc.SetFont(Font'TechSmall');
	gc.SetAlignments(HALIGN_Left, VALIGN_Top);
	gc.DrawText(2, 2, width-2, height-2, message);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     timerBackground=Texture'DeusExUI.UserInterface.ConWindowBackground'
     colNormal=(G=255)
     colCritical=(R=255)
}
