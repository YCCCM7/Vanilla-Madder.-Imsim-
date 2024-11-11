//=============================================================================
// VMDMenuHousingFoodTile
// Our job is to display buyable shit, I guess.
//=============================================================================
class VMDMenuHousingFoodTile extends PersonaBorderButtonWindow;

var Window WinIcon;
var PersonaSkillTextWindow WinName, WinDesc;
var class<Inventory> CurItem;

var Texture DefaultTex[3], HighlightTex[3];
var localized string MsgPrice;

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
	bTranslucent = Player.GetHUDBackgroundTranslucency();
	
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
	winIcon.SetPos(3, 3);
	winIcon.SetSize(42, 40);
	
	winName = VMDMenuUISkillTextWindow(NewChild(Class'VMDMenuUISkillTextWindow'));
	winName.SetPos(52, 2);
	winName.SetSize(108, 40);
	winName.SetFont(Font'FontMenuHeaders');
	
	winDesc = VMDMenuUISkillTextWindow(NewChild(Class'VMDMenuUISkillTextWindow'));
	winDesc.SetPos(160, 2);
	winDesc.SetSize(108, 40);
	winDesc.SetFont(Font'FontMenuHeaders');
}

function int GetProperWidth()
{
 	local int Ret;
	
 	if (CurItem == None) return 42;
 	
 	Ret = Min(42, CurItem.Default.LargeIconWidth);
 	
 	return Ret;
}

function int GetProperHeight()
{
 	local int Ret;
	
 	if (CurItem == None) return 42;
 	
 	Ret = Min(42, CurItem.Default.LargeIconHeight);
 	
 	return Ret;
}

function SetItem(class<Inventory> NewItem)
{
	CurItem = NewItem;
	
	RefreshItemInfo();
}

function UpdateItem()
{
	winIcon.SetSize(GetProperWidth(), GetProperHeight());
}

function RefreshItemInfo()
{
	UpdateItem();
	
	if (CurItem != None)
	{
		if (CurItem.Default.LargeIcon != None)
		{
			winIcon.SetBackground(CurItem.Default.LargeIcon);
		}
		else
		{
			winIcon.SetBackground(CurItem.Default.Icon);
		}
		
		winName.SetText( Left(CurItem.Default.ItemName, 30) );
		winDesc.SetText(SprintF(MsgPrice, class'VMDStaticHousingFunctions'.Static.GetFoodPrice(CurItem.Name)));
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     MsgPrice="Link Price: %d Credits"
     
     Left_Textures(0)=(Tex=Texture'VMDHousingListTile0',Width=10)
     Left_Textures(1)=(Tex=Texture'VMDHousingListTile0',Width=10)
     Right_Textures(0)=(Tex=Texture'VMDHousingListTile2',Width=8)
     Right_Textures(1)=(Tex=Texture'VMDHousingListTile2',Width=8)
     Center_Textures(0)=(Tex=Texture'VMDHousingListTile1',Width=256)
     Center_Textures(1)=(Tex=Texture'VMDHousingListTile1',Width=256)
     
     Left_Textures(0)=(Tex=Texture'VMDHousingListTile0',Width=10)
     Left_Textures(1)=(Tex=Texture'VMDHousingListTile0',Width=10)
     Center_Textures(0)=(Tex=Texture'VMDHousingListTile1',Width=256)
     Center_Textures(1)=(Tex=Texture'VMDHousingListTile1',Width=256)
     Right_Textures(0)=(Tex=Texture'VMDHousingListTile2',Width=8)
     Right_Textures(1)=(Tex=Texture'VMDHousingListTile2',Width=8)
     
     DefaultTex(0)=Texture'VMDHousingListTile0'
     DefaultTex(1)=Texture'VMDHousingListTile1'
     DefaultTex(2)=Texture'VMDHousingListTile2'
     HighlightTex(0)=Texture'VMDHousingListTile0Highlight'
     HighlightTex(1)=Texture'VMDHousingListTile1Highlight'
     HighlightTex(2)=Texture'VMDHousingListTile2Highlight'
     
     fontButtonText=Font'DeusExUI.FontMenuTitle'
     buttonHeight=40
     minimumButtonWidth=256
}
