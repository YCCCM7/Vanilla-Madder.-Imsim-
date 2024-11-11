//=============================================================================
// VMDMenuUINormalLargeTextWindow
//=============================================================================
class VMDMenuUINormalLargeTextWindow extends PersonaNormalLargeTextWindow;

event StyleChanged()
{
	local ColorTheme theme;
	local Color colText;

	theme = player.ThemeManager.GetCurrentMenuColorTheme();

	// Title colors
	colText = theme.GetColorFromName('MenuColor_ListText');

	SetTextColor(colText);
}

defaultproperties
{
}
