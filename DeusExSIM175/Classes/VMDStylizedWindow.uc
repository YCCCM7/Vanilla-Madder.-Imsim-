//=============================================================================
// VMDStylizedWindow... For simple tasks that need recoloration.
//=============================================================================
class VMDStylizedWindow extends Window;

var bool bMenuColors, bTranslucent, bBlockReskin, bBlockTranslucency, bMouseHoverSnitch;
var Color colButtonFace, ColBG, ColTitleBG, OverrideColor, BlackColor;
var DeusExPlayer player;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	// Get a pointer to the player
	player = DeusExPlayer(GetPlayerPawn());
	StyleChanged();
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	// Draw the textures
	if (bTranslucent)
		gc.SetStyle(DSTY_Translucent);
	else
		gc.SetStyle(DSTY_Masked);
	
	if (OverrideColor != BlackColor)
	{
		GC.SetTileColor(OverrideColor);
	}
	else
	{
		gc.SetTileColor(colButtonFace);
	}
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
		
	if (bMenuColors)
	{
		theme = player.ThemeManager.GetCurrentMenuColorTheme();
		bTranslucent = player.GetMenuTranslucency();
	}
	else
	{
		theme = player.ThemeManager.GetCurrentHUDColorTheme();
		bTranslucent = player.GetHUDBackgroundTranslucency();
	}
	if (bBlockTranslucency) bTranslucent = false;
	
	if (bTranslucent)
		SetBackgroundStyle(DSTY_Translucent);
	else
		SetBackgroundStyle(DSTY_Masked);
	
	if (bMenuColors)
	{
		if (bBlockReskin)
		{
			ColButtonFace = Default.ColButtonFace;
			ColBG = Default.ColBG;
			ColTitleBG = Default.ColTitleBG;
		}
		else
		{
			ColButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
			ColBG = theme.GetColorFromName('MenuColor_Background');
			ColTitleBG = theme.GetColorFromName('MenuColor_TitleBackground');
		}
	}
	else
	{
		if (bBlockReskin)
		{
			ColButtonFace = Default.ColButtonFace;
			ColBG = Default.ColBG;
			ColTitleBG = Default.ColBG;
		}
		else
		{
			ColButtonFace = theme.GetColorFromName('HUDColor_ButtonFace');
			ColBG = theme.GetColorFromName('HUDColor_Background');
			ColTitleBG = theme.GetColorFromName('MenuColor_Background');
		}
	}
	
	if (OverrideColor != BlackColor)
	{
		SetTileColor(OverrideColor);
	}
	else
	{
		SetTileColor(ColButtonFace);
	}
}

event MouseMoved(float newX, float newY)
{
	local float ConX, ConY;
	
	if ((bMouseHoverSnitch) && (WinParent != None))
	{
		ConvertCoordinates(Self, newX, newY, WinParent, ConX, ConY);
		
		WinParent.MouseMoved(ConX, ConY);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ColBG=(R=200,G=200,B=200)
     ColTitleBG=(R=100,G=100,B=255)
     BlackColor=(R=0,G=0,B=0)
     OverrideColor=(R=0,G=0,B=0)
     colButtonFace=(R=255,G=255,B=255)
}
