//=============================================================================
// VMDNGSkillMapSkillGem
//=============================================================================
class VMDNGSkillMapSkillGem extends VMDSkillMapSkillGem;

//All that's changed.
var VMDMenuSelectSkillsV2 NGSkillScreen;

function UpdateSkillData()
{
	local int i, j;
	local VMDSkillAugmentManager SAM;
	
	if ((RelSkill != None) && (LastRef != None))
	{
		if ((NGSkillScreen != None) && (NGSkillScreen.VMP != None))
		{
			SkillPointsLeft = NGSkillScreen.VMP.SkillPointsTotal - NGSkillScreen.VMP.SkillPointsSpent;
			
			SAM = NGSkillScreen.VMP.SkillAugmentManager;
			if (SAM != None)
			{
				j = SAM.SkillArrayOf(RelSkill.Class);
				if (j > -1)
				{
					TalentPointsLeft = SAM.SkillAugmentPointsLeft[j] - SAM.SkillAugmentPointsSpent[j];
				}
			}
		}
		
		CurSkillLevel = RelSkill.CurrentLevel;
		NextLevelCost = RelSkill.GetCost();
		
		//DrawScale = 1+RelSkill.CurrentLevel;
		DrawScale = 1.5 + ( (Min(3, RelSkill.CurrentLevel+int(bSpecialized)))/2.0 );
		if (!bSetFirstDrawScale)
		{
			CurDrawScale = DrawScale;
			bSetFirstDrawScale = true;
		}
		else
		{
			TransitionTimer = AddTimer(0.035, true,, 'TransitionDrawScale');
		}
		
		MapOffX = GetMapOff();
		MapOffY = GetMapOff();
		SetSize(GetProperSize(), GetProperSize());
		
		SkillType = RelSkill.Class;
		SkillName = RelSkill.SkillName;
		SkillDesc = LastRef.GetCoreDesc(SkillType);
		for (i=0; i<ArrayCount(LevelDescs); i++)
		{
			LevelDescs[i] = LastRef.GetLevelDesc(SkillType, i);
		}
		
		SkillIconIndex = GetSkillIndex(string(SkillType));
	}
	UpdateHoverTip();
}

function TransitionDrawScale()
{
	if (DrawScale > CurDrawScale)
	{
		CurDrawScale += 0.05;
		SetSize(GetProperSize(), GetProperSize());
	}
	else if (DrawScale < CurDrawScale)
	{
		CurDrawScale -= 0.05;
		SetSize(GetProperSize(), GetProperSize());
	}
	
	MapOffX = GetMapOff();
	MapOffY = GetMapOff();
	
	if (Abs(DrawScale - CurDrawScale) <= 0.05)
	{
		CurDrawScale = DrawScale;
		RemoveTimer(TransitionTimer);
	}
	NGSkillScreen.UpdateTreePositions();
}

function UpdateZoomLevel()
{
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
