//=============================================================================
// VMDNGSkillMapInterfaceWindow
//=============================================================================
class VMDNGSkillMapInterfaceWindow extends VMDSkillMapInterfaceWindow;

//Only thing new.
var VMDMenuSelectSkillsV2 NGWinSkills;

// ----------------------------------------------------------------------
// VMDSetupInterfaceVars()
// ----------------------------------------------------------------------

function VMDNGSetupInterfaceVars(int NAW, int NAH, Texture NAT, VMDMenuSelectSkillsV2 NWS)
{
	SetSize(NAW, NAH);
	AssignedWidth = NAW;
	AssignedHeight = NAH;
	InterfaceTex = NAT;
	NGWinSkills = NWS;
}

// ----------------------------------------------------------------------
// StartButtonDrag()
// ----------------------------------------------------------------------

function StartButtonDrag()
{
	if (NGWinSkills != None)
	{
		NGWinSkills.StartButtonDrag(Self);
		if (NGWinSkills.CurDragInterface == Self)
		{
			bDragging  = True;
		}
	}
}

// ----------------------------------------------------------------------
// FinishButtonDrag()
// ----------------------------------------------------------------------

function FinishButtonDrag()
{
	bDragging  = False;
	
	if (NGWinSkills != None)
		NGWinSkills.FinishButtonDrag();
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;
	
	theme = player.ThemeManager.GetCurrentMenuColorTheme();
	
	colBackground = theme.GetColorFromName('MenuColor_Background');
	
	bBorderTranslucent     = player.GetMenuTranslucency();
	bBackgroundTranslucent = player.GetMenuTranslucency();
	bDrawBorder            = true;
}

defaultproperties
{
}
