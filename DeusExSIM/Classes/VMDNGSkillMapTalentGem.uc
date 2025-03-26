//=============================================================================
// VMDNGSkillMapTalentGem
//=============================================================================
class VMDNGSkillMapTalentGem extends VMDSkillMapTalentGem;

//All that's changed.
var VMDMenuSelectSkillsV2 NGSkillScreen;

function UpdateZoomLevel()
{
	local float TWidth, THeight;
	
	if ((NGSkillScreen != None) && (NGSkillScreen.ZoomInFactor > 0.0))
	{
		ZoomRenderScale = NGSkillScreen.ZoomInFactor;
		
		SetSize(GetProperSize(), GetProperSize());
		MapOffX = GetMapOff();
		MapOffY = GetMapOff();
	}
}

event MouseMoved(float newX, float newY)
{
	if ((NewX > 0) && (NewX < Width) && (NewY > 0) && (NewY < Height))
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
	
	if ((NGSkillScreen != None) && (NGSkillScreen.VMP.bClassicSkillPurchasing))
	{
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
	
	ColButtonFace2.R = ColButtonFace.R * 0.85;
	ColButtonFace2.G = ColButtonFace.G * 0.85;
	ColButtonFace2.B = ColButtonFace.B * 0.85;
	
	ColButtonFace3.R = ColButtonFace.R * 0.35;
	ColButtonFace3.G = ColButtonFace.G * 0.35;
	ColButtonFace3.B = ColButtonFace.B * 0.35;
}

defaultproperties
{
}
