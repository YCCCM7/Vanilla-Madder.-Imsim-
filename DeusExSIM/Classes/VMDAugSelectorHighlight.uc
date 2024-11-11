//=============================================================================
// VMDAugSelectorHighlight
//=============================================================================
class VMDAugSelectorHighlight extends PersonaBorderButtonWindow;

var Color ColorWhite;

event DrawWindow(GC gc)
{
	GC.SetStyle(DSTY_Masked);
	
	//GC.SetTileColor(ColButtonFace);
	GC.SetTileColor(ColorWhite);
	GC.DrawTexture(0, 0, 42, 42, 0, 0, Texture'VMDAugControllerAugHighlight');
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(42, 42);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ColorWhite=(R=255,G=255,B=255)
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'VMDNextAugPageIcon',Width=42)
     Right_Textures(1)=(Tex=Texture'VMDNextAugPageIcon',Width=42)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     buttonHeight=42
     minimumButtonWidth=42
}
