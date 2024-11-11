//=============================================================================
// VMDMenuUISkillTextWindow
//=============================================================================
class VMDMenuUISkillTextWindow extends PersonaSkillTextWindow;

event StyleChanged()
{
	local ColorTheme theme;
	local Color colText;

	theme = player.ThemeManager.GetCurrentMenuColorTheme();

	// Title colors
	if (bSelected)
		colText = theme.GetColorFromName('MenuColor_ButtonTextFocus');
	else
		colText = theme.GetColorFromName('MenuColor_ButtonTextNormal');

	SetTextColor(colText);
}

defaultproperties
{
}
