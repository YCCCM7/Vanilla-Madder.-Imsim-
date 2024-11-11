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
	//if (InterfaceTex != None)
	if ((InterfaceTex != None) && (NGTG != None))
	{
		// Draw the icon
		/*if (bIconTranslucent)
			gc.SetStyle(DSTY_Translucent);		
		else*/
		
		gc.SetStyle(DSTY_Masked);	
		
		switch(NGTG.LastBuyState)
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
		
		gc.DrawTexture(0, 0, AssignedWidth, AssignedHeight, 0, 0, InterfaceTex);
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
