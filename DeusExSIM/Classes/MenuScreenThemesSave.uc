//=============================================================================
// MenuScreenThemesSave
//=============================================================================
class MenuScreenThemesSave expands MenuScreenThemesLoad;

function SaveSettings()
{
	local ColorTheme theme;
	local String themeName;

	if (lstThemes.GetNumSelectedRows() == 1)
	{
		themeName = lstThemes.GetField(lstThemes.GetSelectedRow(), 0);

		if (winRGB != None)
			winRGB.SaveTheme();
	}

	root.PopWindow();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     LoadHelpText="Choose the color theme to save"
     actionButtons(1)=(Text="Save Theme",Key="SAVE")
     Title="Save Theme"
}
