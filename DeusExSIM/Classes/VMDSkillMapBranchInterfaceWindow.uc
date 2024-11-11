//=============================================================================
// VMDSkillMapBranchInterfaceWindow
//=============================================================================
class VMDSkillMapBranchInterfaceWindow extends VMDSkillMapInterfaceWindow;

//Gem is only thing new.
var VMDSkillMapTalentGem TG;

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local float UnivScale;
	
	if ((InterfaceTex != None) && (TG != None))
	{
		// Draw the icon
		/*if (bIconTranslucent)
			gc.SetStyle(DSTY_Translucent);		
		else*/
		
		if (TG.LastState < 2)
		{
			gc.SetStyle(DSTY_Translucent);
		}
		else
		{
			gc.SetStyle(DSTY_Masked);
		}	
		
		switch(TG.LastState)
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

function VMDSetupBranchInterfaceVars(int NAW, int NAH, VMDSkillMapTalentGem NTG, Texture NAT, VMDPersonaScreenSkills NWS)
{
	TG = NTG;
	
	VMDSetupInterfaceVars(NAW, NAH, NAT, NWS);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
