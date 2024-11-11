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
	SourceSizeX = NAW;
	SourceSizeY = NAH;
	InterfaceTex = NAT;
	NGWinSkills = NWS;
}

function UpdateZoomLevel()
{
	if ((NGWinSkills != None) && (NGWinSkills.ZoomInFactor > 0.0))
	{
		ZoomRenderScale = NGWinSkills.ZoomInFactor;
	}
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
	ColDarkGray.R = ((ColBackground.R*0.35) + (Default.ColDarkGray.R*0.65));
	ColDarkGray.G = ((ColBackground.G*0.35) + (Default.ColDarkGray.G*0.65));
	ColDarkGray.B = ((ColBackground.B*0.35) + (Default.ColDarkGray.B*0.65));
	
	bBorderTranslucent     = player.GetMenuTranslucency();
	bBackgroundTranslucent = player.GetMenuTranslucency();
	bDrawBorder            = true;
}

defaultproperties
{
}
