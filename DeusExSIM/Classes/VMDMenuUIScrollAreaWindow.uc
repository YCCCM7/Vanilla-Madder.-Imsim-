//=============================================================================
// VMDMenuUIScrollAreaWindow
//=============================================================================
class VMDMenuUIScrollAreaWindow extends PersonaScrollAreaWindow;

event StyleChanged()
{
	local ColorTheme theme;
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	// Title colors
	colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
	
	upButton.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
                             colButtonFace, colButtonFace, colButtonFace);
	
	downButton.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
	                           colButtonFace, colButtonFace, colButtonFace);
	
	vScale.SetScaleColor(colButtonFace);
	vScale.SetThumbColor(colButtonFace);
	
	leftButton.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
                             colButtonFace, colButtonFace, colButtonFace);
	
	rightButton.SetButtonColors(colButtonFace, colButtonFace, colButtonFace,
	                           colButtonFace, colButtonFace, colButtonFace);
	
	hScale.SetScaleColor(colButtonFace);
	hScale.SetThumbColor(colButtonFace);
}

defaultproperties
{
}
