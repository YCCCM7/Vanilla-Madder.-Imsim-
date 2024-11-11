//=============================================================================
// VMDNGSkillMapTalentGem
//=============================================================================
class VMDNGSkillMapTalentGem extends VMDSkillMapTalentGem;

//All that's changed.
var VMDMenuSelectSkillsV2 NGSkillScreen;

event MouseMoved(float newX, float newY)
{
	if ((NewX > MapOffX) && (NewX < 64-MapOffX) && (NewY > MapOffY) && (NewY < 64-MapOffY))
	{
		if (NGSkillScreen != None)
		{
			NGSkillScreen.HoverTarget = Self;
			NGSkillScreen.HoverTicks = 0;
		}
	}
}

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button,
                              int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if (button == IK_RightMouse)
	{
		if ((NGSkillScreen != None) && (TalentPointsLeft[1] >= PointsCost) && (LastState == 1) && (SkillRequirements[1] != None))
		{
			NGSkillScreen.AttemptAlternatePurchase(Self);
		}
		bResult = True;
	}
	if (button == IK_MiddleMouse)
	{
		if ((NGSkillScreen != None) && (TalentPointsLeft[0] >= 1) && (TalentPointsLeft[1] >= 1) && (LastState == 1) && (SkillRequirements[0] != None) && (SkillRequirements[1] != None) && (PointsCost == 2))
		{
			NGSkillScreen.AttemptComboPurchase(Self);
		}
		bResult = True;
	}
	return bResult;
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
