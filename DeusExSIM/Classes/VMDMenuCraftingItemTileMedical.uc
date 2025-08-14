//=============================================================================
// VMDMenuCraftingItemTile
//=============================================================================
class VMDMenuCraftingItemTileMedical extends PersonaBorderButtonWindow;

var VMDStylizedWindow WinIcon;
var PersonaSkillTextWindow WinName, WinDesc;
var class<Inventory> CurItem;
var VMDBufferPlayer VMP;

var Texture DefaultTex[3], HighlightTex[3];
var localized string MsgQuantityOwned, MsgBotRequired, MsgSkillRequired, MsgAllRequirementsMet, SkillLevelNames[4];

var bool bHasMedbot;

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
	
	VMP = VMDBufferPlayer(Player);
	
	SetWidth(264);
	
	CreateControls();
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	winIcon = VMDStylizedWindow(NewChild(Class'VMDStylizedWindow'));
	winIcon.SetBackgroundStyle(DSTY_Masked);
	winIcon.SetPos(3, 3);
	winIcon.SetSize(42, 40);
	WinIcon.bMenuColors = true;
	WinIcon.bBlockTranslucency = true;
	
	winName = VMDMenuUISkillTextWindow(NewChild(Class'VMDMenuUISkillTextWindow'));
	winName.SetPos(52, 2);
	winName.SetSize(108, 40);
	winName.SetFont(Font'FontMenuHeaders');
	
	winDesc = VMDMenuUISkillTextWindow(NewChild(Class'VMDMenuUISkillTextWindow'));
	winDesc.SetPos(160, 2);
	winDesc.SetSize(108, 40);
	winDesc.SetFont(Font'FontMenuHeaders');
}

function SetItem(class<Inventory> NewItem)
{
	CurItem = NewItem;
	
	RefreshItemInfo();
}

function UpdateItem()
{
	winIcon.SetSize(42, 42);
}

function RefreshItemInfo()
{
	local int ComplexityNeeded, SkillLevel, SkillRequired, QuantityOwned;
	local string TStr;
	local VMDNonStaticCraftingFunctions CF;
	
	UpdateItem();
	
	CF = GetCF();
	if ((CurItem != None) && (CF != None) && (VMP != None) && (VMP.SkillSystem != None))
	{
		winIcon.SetBackground(CurItem.Default.Icon);
		QuantityOwned = CountNumThings(CurItem, VMDBufferPlayer(GetPlayerPawn()));
		
		TStr = Left(CurItem.Default.ItemName, 30);
		if (QuantityOwned > 0)
		{
			TStr = TStr$CR()$SprintF(MsgQuantityOwned, QuantityOwned);
		}
		winName.SetText(TStr);
		
		SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
		SkillRequired = CF.GetMedicalItemSkillReq(CurItem);
		ComplexityNeeded = CF.GetMedicalItemComplexity(CurItem, SkillLevel, VMP.HasSkillAugment('MedicineCrafting'));
		
		TStr = "";
		if (SkillRequired > SkillLevel)
		{
			WinIcon.bBlockReskin = false;
			TStr = SprintF(MsgSkillRequired, SkillLevelNames[SkillRequired]);
		}
		else if ((ComplexityNeeded > 1) && (!bHasMedbot))
		{
			WinIcon.bBlockReskin = false;
			TStr = MsgBotRequired;
		}
		else
		{
			WinIcon.bBlockReskin = true;
			TStr = MsgAllRequirementsMet;
		}
		WinIcon.StyleChanged();
		winDesc.SetText(TStr);
	}
}

function VMDNonStaticCraftingFunctions GetCF()
{
	if ((VMP != None) && (VMP.CraftingManager != None) && (VMP.CraftingManager.StatRef != None))
	{
		return VMP.CraftingManager.StatRef;
	}
	
	return None;
}

function int CountNumThings(class<Inventory> CheckClass, VMDBufferPlayer VMP)
{
	local Inventory TInv;
	local DeusExAmmo DXA;
	local DeusExWeapon DXW;
	local DeusExPickup DXP;
	
	if (VMP != None)
	{
		TInv = VMP.FindInventoryType(CheckClass);
		DXA = DeusExAmmo(TInv);
		DXP = DeusExPickup(TInv);
		DXW = DeusExWeapon(TInv);
		
		if (DXA != None)
		{
			return DXA.AmmoAmount;
		}
		if (DXP != None)
		{
			if (DXP.bCanHaveMultipleCopies)
			{
				return DXP.NumCopies;
			}
			else
			{
				return CountNumPickups(DXP.Class, VMP.Inventory);
			}
		}
		if (DXW != None)
		{
			if ((DXW.bHandToHand) && (DXW.AmmoType != None) && (AmmoNone(DXW.AmmoType) == None))
			{
				return DXW.AmmoType.AmmoAmount;
			}
			else
			{
				return CountNumWeapons(DXW.Class, VMP.Inventory);
			}
		}
	}
	
	return 0;
}

function int CountNumPickups(class<DeusExPickup> CheckClass, Inventory StartInv)
{
	local int Ret;
	local Inventory CurInv;
	
	for(CurInv = StartInv; CurInv != None; CurInv = CurInv.Inventory)
	{
		if (CurInv.Class == CheckClass)
		{
			Ret++;
		}
	}
	return Ret;
}

function int CountNumWeapons(class<DeusExWeapon> CheckClass, Inventory StartInv)
{
	local int Ret;
	local Inventory CurInv;
	
	for(CurInv = StartInv; CurInv != None; CurInv = CurInv.Inventory)
	{
		if (CurInv.Class == CheckClass)
		{
			Ret++;
		}
	}
	return Ret;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     MsgQuantityOwned="%d Owned"
     MsgBotRequired="Medical Bot Required"
     MsgSkillRequired="%d Skill Required"
     MsgAllRequirementsMet="" //Craftable
     SkillLevelNames(0)="Untrained"
     SkillLevelNames(1)="Trained"
     SkillLevelNames(2)="Advanced"
     SkillLevelNames(3)="Master"
     
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
