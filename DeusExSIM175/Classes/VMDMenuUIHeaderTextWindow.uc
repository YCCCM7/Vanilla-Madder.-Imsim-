//=============================================================================
// VMDMenuUIHeaderTextWindow
//=============================================================================
class VMDMenuUIHeaderTextWindow extends PersonaHeaderTextWindow;

event StyleChanged()
{
	local ColorTheme theme;
	local Color colText;

	theme = player.ThemeManager.GetCurrentMenuColorTheme();

	// Title colors
	colText = theme.GetColorFromName('MenuColor_HelpText');

	SetTextColor(colText);
}

defaultproperties
{
}
