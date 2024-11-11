//=============================================================================
// VMDNGSkillMapBranchInterfaceWindow
//=============================================================================
class VMDNGSkillMapBranchInterfaceWindow extends VMDNGSkillMapInterfaceWindow;

//Gem is only thing new.
var VMDNGSkillMapTalentGem NGTG;

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local float UnivScale;
	
	if ((InterfaceTex != None) && (NGTG != None))
	{
		// Draw the icon
		/*if (bIconTranslucent)
			gc.SetStyle(DSTY_Translucent);		
		else*/
		
		if (NGTG.LastState < 2)
		{
			gc.SetStyle(DSTY_Translucent);
		}
		else
		{
			gc.SetStyle(DSTY_Masked);
		}	
		
		switch(NGTG.LastState)
		{
			case 0:
				SetTileColor(ColDarkGray);
			break;
			case 1:
				SetTileColor(ColGray);
			break;
			case 2:
				SetTileColor(ColWhite);
			break;
		}
		
		UnivScale = ZoomRenderScale;
		gc.DrawStretchedTexture(0, 0, AssignedWidth*UnivScale, AssignedHeight*UnivScale, 0, 0, SourceSizeX, SourceSizeY, InterfaceTex);
	}
}

// ----------------------------------------------------------------------
// VMDSetupInterfaceVars()
// ----------------------------------------------------------------------

function VMDNGSetupBranchInterfaceVars(int NAW, int NAH, VMDNGSkillMapTalentGem NTG, Texture NAT, VMDMenuSelectSkillsV2 NWS)
{
	NGTG = NTG;
	
	VMDNGSetupInterfaceVars(NAW, NAH, NAT, NWS);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
