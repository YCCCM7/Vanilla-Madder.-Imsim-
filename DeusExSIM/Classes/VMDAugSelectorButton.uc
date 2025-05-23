//=============================================================================
// VMDAugSelectorButton
//=============================================================================
class VMDAugSelectorButton extends PersonaBorderButtonWindow;

//MADDERS, 8/26/23: I get really damn tired of having to define 2x as many default properties.
struct VMDButtonPos {
	var int X;
	var int Y;
};

var Color AugColor, ColorOff, ColorOn, ColorPassive, ColorPassiveDisabled;
var Texture AugIcon;
var VMDButtonPos SublayerOffset;

var Augmentation CurAug;
var VMDBufferAugmentation VAug;

function SetAugmentation(Augmentation NewAug)
{
	CurAug = NewAug;
	VAug = VMDBufferAugmentation(NewAug);
	
	if (CurAug != None)
	{
		AugIcon = CurAug.SmallIcon;
	}
	UpdateAugColor();
}

function UpdateAugColor()
{
	if ((VAug != None) && (VAug.bPassive))
	{
		if (VAug.bDisabled)
		{
			AugColor = ColorPassiveDisabled;
		}
		else
		{
			AugColor = ColorPassive;
		}
	}
	else if (CurAug != None)
	{
		if (CurAug.bIsActive)
		{
			AugColor = ColorOn;
		}
		else
		{
			AugColor = ColorOff;
		}
	}
}

event DrawWindow(GC gc)
{
	//GC.SetStyle(DSTY_Masked);
	GC.SetStyle(DSTY_Normal);
	
	if (CurAug != None)
	{
		GC.SetTileColor(AugColor);
		GC.DrawTexture(SublayerOffset.X, SublayerOffset.Y, 32, 32, 0, 0, AugIcon);
	}
	
	GC.SetTileColor(ColButtonFace);
	GC.DrawTexture(0, 0, 36, 36, 0, 0, Texture'VMDAugControllerAugCase');
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(36, 36);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ColorOff=(R=255,G=255,B=255)
     ColorOn=(R=255,G=255,B=0)
     ColorPassive=(R=192,G=255,B=96)
     ColorPassiveDisabled=(R=255,G=96,B=96)
     SublayerOffset=(X=2,Y=2)
     
     Left_Textures(0)=(Tex=None,Width=0)
     Left_Textures(1)=(Tex=None,Width=0)
     Right_Textures(0)=(Tex=Texture'VMDNextAugPageIcon',Width=36)
     Right_Textures(1)=(Tex=Texture'VMDNextAugPageIcon',Width=36)
     Center_Textures(0)=(Tex=None,Width=0)
     Center_Textures(1)=(Tex=None,Width=0)
     
     buttonHeight=36
     minimumButtonWidth=36
}
