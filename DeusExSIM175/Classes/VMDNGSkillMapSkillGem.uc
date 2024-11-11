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
			SkillPointsLeft = NGSkillScreen.VMP.SkillPointsAvail;
			
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
		
		MapOffX = 16*(3.0 - CurDrawScale);
		MapOffY = 16*(3.0 - CurDrawScale);
		SetSize(96, 96);
		
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

event MouseMoved(float newX, float newY)
{
	if ((NewX > MapOffX) && (NewX < 96-MapOffX) && (NewY > MapOffY) && (NewY < 96-MapOffY))
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
