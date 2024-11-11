//=============================================================================
// VMDNGSkillMapJumpGem
//=============================================================================
class VMDNGSkillMapJumpGem extends VMDSkillMapJumpGem;

//All that's changed.
var VMDMenuSelectSkillsV2 NGSkillScreen;

event MouseMoved(float newX, float newY)
{
	if (NGSkillScreen != None)
	{
		NGSkillScreen.HoverTarget = Self;
		NGSkillScreen.HoverTicks = 0;
	}
}

event InitWindow()
{
	local int i;
	
	Super.InitWindow();
	
	for (i=0; i<ArrayCount(GemOverlays); i++)
	{
		if (GemOverlays[i] != None)
		{
			GemOverlays[i].bMenuColors = true;
			GemOverlays[i].StyleChanged();
		}
	}
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	bTranslucent  = player.GetMenuTranslucency();
	
	colButtonFace = theme.GetColorFromName('MenuColor_ButtonFace');
	colText[0]    = theme.GetColorFromName('MenuColor_ButtonTextNormal');
	
	colText[1]    = theme.GetColorFromName('MenuColor_ButtonTextFocus');
	colText[2]    = colText[1];
	
	colText[3]    = theme.GetColorFromName('MenuColor_ButtonTextDisabled');
}

defaultproperties
{
}
