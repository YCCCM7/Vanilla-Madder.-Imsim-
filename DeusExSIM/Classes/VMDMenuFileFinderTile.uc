//=============================================================================
// VMDMenuFileFinderTile
//=============================================================================
class VMDMenuFileFinderTile extends PersonaBorderButtonWindow;

var Window WinIcon;
var PersonaSkillTextWindow WinName, WinDesc;
var VMDMenuModLocatorWindow FileWindow;

var int IconType;
var string FileName, ExtensionType;

var localized string StrFile, StrFolder, StrMod;

var Texture DefaultTex[3], HighlightTex[3], IconTypes[3];

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme Theme;
	
	Theme = Player.ThemeManager.GetCurrentMenuColorTheme();
	
	//MADDERS, 4/14/22: Highly debatable. Ugh.
	bTranslucent = Player.GetMenuTranslucency();
	
	ColButtonFace = Theme.GetColorFromName('MenuColor_ButtonFace');
	ColText[0] = Theme.GetColorFromName('MenuColor_ButtonTextNormal');
	ColText[1] = Theme.GetColorFromName('MenuColor_ButtonTextFocus');
	ColText[2] = ColText[1];
	ColText[3] = Theme.GetColorFromName('MenuColor_ButtonTextDisabled');
}

function SetHighlight(bool bHighlight)
{
 	if (bHighlight)
 	{
		Left_Textures[0].Tex = HighlightTex[0];
		Left_Textures[1].Tex = HighlightTex[0];
  		Center_Textures[0].Tex = HighlightTex[1];
  		Center_Textures[1].Tex = HighlightTex[1];
  		Right_Textures[0].Tex = HighlightTex[2];
  		Right_Textures[1].Tex = HighlightTex[2];
 	}
 	else
 	{
		Left_Textures[0].Tex = DefaultTex[0];
		Left_Textures[1].Tex = DefaultTex[0];
  		Center_Textures[0].Tex = DefaultTex[1];
  		Center_Textures[1].Tex = DefaultTex[1];
   		Right_Textures[0].Tex = DefaultTex[2];
  		Right_Textures[1].Tex = DefaultTex[2];
 	}
}

event InitWindow()
{
	Super.InitWindow();
	
	SetWidth(264);
	
	CreateControls();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	winIcon = NewChild(Class'Window');
	winIcon.SetBackgroundStyle(DSTY_Masked);
	winIcon.SetPos(1, -1);
	winIcon.SetSize(19, 19);
	
	winName = VMDMenuUISkillTextWindow(NewChild(Class'VMDMenuUISkillTextWindow'));
	winName.SetPos(31, 0);
	winName.SetSize(108, 20);
	winName.SetFont(Font'FontMenuHeaders');
	
	winDesc = VMDMenuUISkillTextWindow(NewChild(Class'VMDMenuUISkillTextWindow'));
	winDesc.SetPos(160, 0);
	winDesc.SetSize(108, 20);
	winDesc.SetFont(Font'FontMenuHeaders');
}

function SetFileData(string NewFileName, string NewExtension, int NewIcon)
{
	local string TClip;
	
	FileName = NewFileName;
	ExtensionType = NewExtension;
	
	if (NewIcon == 1)
	{
		ExtensionType = StrFolder;
	}
	else if (NewIcon == 2)
	{
		ExtensionType = StrMod;
	}
	else
	{
		ExtensionType = ExtensionType@StrFile;	
	}
	
	IconType = NewIcon;
	
	RefreshItemInfo();
}

function RefreshItemInfo()
{
	WinIcon.SetBackground(IconTypes[IconType]);
	
	winName.SetText(FileName);
	winDesc.SetText(ExtensionType);
}

// ----------------------------------------------------------------------
// MouseButtonPressed()
//
// Fast hotkey activation.
// ----------------------------------------------------------------------

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if (button == IK_LeftMouse)
	{
		if (FileWindow != None)
		{
			FileWindow.SelectTile(Self);
		}
		bResult = True;
	}
	return bResult;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     StrFile="File"
     StrFolder="(Folder)"
     StrMod="Supported Mod"
     Left_Textures(0)=(Tex=Texture'VMDFileFinderListTile0',Width=21)
     Left_Textures(1)=(Tex=Texture'VMDFileFinderListTile0',Width=21)
     Right_Textures(0)=(Tex=Texture'VMDFileFinderListTile2',Width=64)
     Right_Textures(1)=(Tex=Texture'VMDFileFinderListTile2',Width=64)
     Center_Textures(0)=(Tex=Texture'VMDFileFinderListTile1',Width=256)
     Center_Textures(1)=(Tex=Texture'VMDFileFinderListTile1',Width=256)
     
     IconTypes(0)=Texture'VMDFileFinderFileIcon'
     IconTypes(1)=Texture'VMDFileFinderFolderIcon'
     IconTypes(2)=Texture'VMDFileFinderKeyFolderIcon'
     DefaultTex(0)=Texture'VMDFileFinderListTile0'
     DefaultTex(1)=Texture'VMDFileFinderListTile1'
     DefaultTex(2)=Texture'VMDFileFinderListTile2'
     HighlightTex(0)=Texture'VMDFileFinderListTile0Highlight'
     HighlightTex(1)=Texture'VMDFileFinderListTile1Highlight'
     HighlightTex(2)=Texture'VMDFileFinderListTile2Highlight'
     
     fontButtonText=Font'DeusExUI.FontMenuTitle'
     buttonHeight=20
     minimumButtonWidth=256
}
