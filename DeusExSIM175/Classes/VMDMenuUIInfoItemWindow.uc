//=============================================================================
// VMDMenuUIInfoItemWindow
//=============================================================================
class VMDMenuUIInfoItemWindow extends PersonaInfoItemWindow;

event StyleChanged()
{
	local ColorTheme theme;

	theme = player.ThemeManager.GetCurrentMenuColorTheme();

	winLabel.SetTextColor(theme.GetColorFromName('MenuColor_ListText'));

	if (bHighlight)
		winText.SetTextColor(theme.GetColorFromName('MenuColor_HelpText'));
	else
		winText.SetTextColor(theme.GetColorFromName('MenuColor_ListText'));
}

defaultproperties
{
}
