//=============================================================================
// VMDMenuUIClientWindow
//=============================================================================
class VMDMenuUIClientWindow extends MenuUIClientWindow;

var bool bBlockTranslucency, bBlockReskin;

event StyleChanged()
{
	local ColorTheme theme;
	
	backgroundDrawStyle = DSTY_Masked;
	
	// Translucency
	if ((player.GetMenuTranslucency()) && (!bBlockTranslucency))
	{
		backgroundDrawStyle = DSTY_Translucent;
	}
	else
	{
		backgroundDrawStyle = DSTY_Masked;
	}
	
	if (bBlockReskin)
	{
		theme = player.ThemeManager.FindTheme("Default");
	}
	else
	{
		theme = player.ThemeManager.GetCurrentMenuColorTheme();
	}
	
	colBackground = theme.GetColorFromName('MenuColor_Background');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
