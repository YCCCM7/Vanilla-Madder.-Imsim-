//=============================================================================
// VMDMenuMEGHWeaponTile
//=============================================================================
class VMDMenuMEGHWeaponTile extends PersonaBorderButtonWindow;

var Window WinIcon;
var VMDMenuUISkillTextWindow WinName, WinDesc;
var DeusExWeapon CurItem;

var localized string MsgAmmo, MsgNoAmmo, MsgGrenadeWarning[2];

var Texture DefaultTex[3], HighlightTex[3];

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
	//bTranslucent = Player.GetHUDBackgroundTranslucency();
	//MADDERS, 9/5/22: Weapon tile says to get bent.
	bTranslucent = false;
	
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
  		Right_Textures[0].Tex = HighlightTex[2];
  		Right_Textures[1].Tex = HighlightTex[2];
  		Center_Textures[0].Tex = HighlightTex[1];
  		Center_Textures[1].Tex = HighlightTex[1];
 	}
 	else
 	{
  		Left_Textures[0].Tex = DefaultTex[0];
  		Left_Textures[1].Tex = DefaultTex[0];
  		Right_Textures[0].Tex = DefaultTex[2];
  		Right_Textures[1].Tex = DefaultTex[2];
  		Center_Textures[0].Tex = DefaultTex[1];
  		Center_Textures[1].Tex = DefaultTex[1];
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
 	return 42;
}

function int GetProperHeight()
{
 	return 42;
}

function SetItem(DeusExWeapon NewItem)
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
	local int LastAmmoLeft;
	
	UpdateItem();
	
	if (CurItem != None)
	{
		winIcon.SetBackground(CurItem.Icon);
		winName.SetText( Left(CurItem.ItemName, 30) );
		if (CurItem.AmmoType != None)
		{
			LastAmmoLeft = CurItem.AmmoType.AmmoAmount;
		}
		
		switch(CurItem.Class.Name)
		{
			case 'WeaponEMPGrenade':
			case 'WeaponGasGrenade':
			case 'WeaponLAM':
			case 'WeaponNanovirusGrenade':
			
			case 'WeaponHCEMPGrenade':
			case 'WeaponHCHCGasGrenade':
			case 'WeaponHCLAM':
			case 'WeaponHCNanoVirusGrenade':
				if (LastAmmoLeft > 0)
				{
					winName.SetText( Left( Left(CurItem.ItemName, 15)$CR()$SprintF(MsgAmmo, LastAmmoLeft), 33) );
				}
				else
				{
					WinDesc.SetText(Left(CurItem.ItemName, 10)$CR()$MsgNoAmmo);
				}
				winDesc.SetText(MsgGrenadeWarning[0]$CR()$MsgGrenadeWarning[1]);
			break;
			default:
				if (CurItem.bDroneGrenadeWeapon)
				{
					if (LastAmmoLeft > 0)
					{
						winName.SetText( Left( Left(CurItem.ItemName, 15)$CR()$SprintF(MsgAmmo, LastAmmoLeft), 33) );
					}
					else
					{
						WinDesc.SetText(Left(CurItem.ItemName, 10)$CR()$MsgNoAmmo);
					}
					winDesc.SetText(MsgGrenadeWarning[0]$CR()$MsgGrenadeWarning[1]);
				}
				else
				{
					if (LastAmmoLeft > 0)
					{
						winDesc.SetText(SprintF(MsgAmmo, LastAmmoLeft));
					}
					else
					{
						WinDesc.SetText(MsgNoAmmo);
					}
				}
			break;
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     MsgAmmo="%d rounds of ammo"
     MsgNoAmmo="No ammo"
     MsgGrenadeWarning(0)="Cannot throw, will"
     MsgGrenadeWarning(1)="use at point blank"
     
     Left_Textures(0)=(Tex=Texture'VMDHousingListTile0',Width=10)
     Left_Textures(1)=(Tex=Texture'VMDHousingListTile0',Width=10)
     Right_Textures(0)=(Tex=Texture'VMDHousingListTile2',Width=8)
     Right_Textures(1)=(Tex=Texture'VMDHousingListTile2',Width=8)
     Center_Textures(0)=(Tex=Texture'VMDHousingListTile1',Width=256)
     Center_Textures(1)=(Tex=Texture'VMDHousingListTile1',Width=256)
     
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
