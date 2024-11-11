//=============================================================================
// PersonaAugmentationBodyWindow
//=============================================================================
class PersonaAugmentationBodyWindow extends Window;

var Texture BodyTextures[2], BodyTexturesFemale[2];
var bool bFemale;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	local VMDBufferPlayer VMP;
	
	Super.InitWindow();

	SetSize(174, 359);
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.bAssignedFemale))
	{
		bFemale = true;
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{	
	// Draw window background
	gc.SetStyle(DSTY_Masked);
	
	if (bFemale)
	{
		gc.DrawTexture(0,   0, 174, 256, 0, 0, BodyTexturesFemale[0]);
		gc.DrawTexture(0, 256, 174, 103, 0, 0, BodyTexturesFemale[1]);
	}
	else
	{
		gc.DrawTexture(0,   0, 174, 256, 0, 0, BodyTextures[0]);
		gc.DrawTexture(0, 256, 174, 103, 0, 0, BodyTextures[1]);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     BodyTextures(0)=Texture'DeusExUI.UserInterface.AugmentationsBody_1'
     BodyTextures(1)=Texture'DeusExUI.UserInterface.AugmentationsBody_2'
     BodyTexturesFemale(0)=Texture'DeusExUI.UserInterface.AugmentationsBody_1Fem'
     BodyTexturesFemale(1)=Texture'DeusExUI.UserInterface.AugmentationsBody_2Fem'
}
