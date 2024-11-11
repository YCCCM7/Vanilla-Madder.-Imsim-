//=============================================================================
// VMDMenuAutoturretManagement
//=============================================================================
class VMDMenuAutoturretManagement expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow DoneButton,  TurnOffButton;

var VMDMenuUIActionButtonWindow LoadButton, EnhanceButton;

var localized string DoneButtonText, TurnOffButtonText,
			LoadButtonText, EnhanceButtonText,
			StrROFTitle, StrROFDesc, StrScrap,
			StrStockpile, StrAmmoLeft, StrScrapLeft;

var bool bCanEnhance, bCanLoad;
var int LastScrapCount, LastScrapCost,
			LastCurrentAmmo, LastAmmoLeft, LastROF;

var VMDBufferPlayer VMP;
var AutoTurret Turret;
var VMDNonStaticCraftingFunctions CF;

var class<DeusExWeapon> LastWeapon;

var MenuUIEditWindow NameEntry;
var MenuUIHelpWindow StockpileLabel, AmmoLeftLabel, ScrapLeftLabel;
var VMDMenuUIInfoWindow WinInfoROF;

var VMDButtonPos LoadButtonPos, LoadButtonSize,
			EnhanceButtonPos, EnhanceButtonSize,
			NamePos, NameSize, ROFPos, ROFSize,
			AmmoNameSize,  StockpilePos, StockpileSize, AmmoLeftPos, AmmoLeftSize,
			ScrapIconPos, AmmoIconPos,
			ScrapLeftPos, ScrapLeftSize,
			TurretIconPos, TurretIconSize;

var Window ScrapIcon, AmmoIcon, TurretIcon;

// ----------------------------------------------------------------------
// MADDERS: 4/14/22: Vanilla function bullshit. Clustered together because it has minimal value.
// ----------------------------------------------------------------------

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

function bool CanStack()
{
	return false;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	return false;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
	return false;
}

function CreateClientWindow()
{
	local int clientIndex;
	local int titleOffsetX, titleOffsetY;
	
	winClient = VMDMenuUIClientWindow(NewChild(class'VMDMenuUIClientWindow'));
	VMDMenuUIClientWindow(WinClient).bBlockReskin = false;
	VMDMenuUIClientWindow(WinClient).bBlockTranslucency = true;
	WinClient.StyleChanged();
	
	winTitle.GetOffsetWidths(titleOffsetX, titleOffsetY);
	
	winClient.SetSize(clientWidth, clientHeight);
	winClient.SetTextureLayout(textureCols, textureRows);
	
	// Set background textures
	for(clientIndex=0; clientIndex<arrayCount(clientTextures); clientIndex++)
	{
		winClient.SetClientTexture(clientIndex, clientTextures[clientIndex]);
	}
}

event InitWindow()
{
	Super.InitWindow();
	
	VMP = VMDBufferPlayer(Player);
	if ((VMP != None) && (AutoTurretGun(VMP.FrobTarget) != None) && (AutoTurret(AutoturretGun(VMP.FrobTarget).Owner) != None))
	{
		Turret = AutoTurret(AutoturretGun(VMP.FrobTarget).Owner);
	}
	else
	{
		AddTimer(0.1, True,, 'DoPop');
		return;
	}
	
        DoneButton = WinButtonBar.AddButton(DoneButtonText, HALIGN_Right);
	
	CreateNameWindow();
	CreateInfoWindows();
	CreateIconWindows();
	CreateLabelWindows();
	CreateButtons();
	
	SetFocusWindow(DoneButton);
	
	AddTimer(0.2, True,, 'UpdateInfo');
}

function CreateNameWindow()
{
	NameEntry = CreateMenuEditWindow(NamePos.X, NamePos.Y, NameSize.X, 28, winClient);
	NameEntry.SetSensitivity(False);
}

function CreateInfoWindows()
{
	if (WinClient != None)
	{
		WinInfoROF = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoROF.SetPos(ROFPos.X, ROFPos.Y);
		WinInfoROF.SetSize(ROFSize.X, ROFSize.Y);
		WinInfoROF.SetText("ERR B");
	}
}

function CreateLabelWindows()
{
	StockpileLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	StockpileLabel.SetSize(StockpileSize.X, StockpileSize.Y);
	StockpileLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	StockpileLabel.SetText(SprintF(StrStockpile, LastCurrentAmmo));
	StockpileLabel.SetPos(StockpilePos.X, StockpilePos.Y);
	
	AmmoLeftLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	AmmoLeftLabel.SetSize(AmmoLeftSize.X, AmmoLeftSize.Y);
	AmmoLeftLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	AmmoLeftLabel.SetText(SprintF(StrAmmoLeft, LastAmmoLeft));
	AmmoLeftLabel.SetPos(AmmoLeftPos.X, AmmoLeftPos.Y);
	
	ScrapLeftLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	ScrapLeftLabel.SetSize(ScrapLeftSize.X, ScrapLeftSize.Y);
	ScrapLeftLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	ScrapLeftLabel.SetPos(ScrapLeftPos.X, ScrapLeftPos.Y);
	
	ScrapLeftLabel.SetText(SprintF(StrScrapLeft, LastScrapCount));
}

function CreateIconWindows()
{
	ScrapIcon = NewChild(class'Window');
	ScrapIcon.SetSize(42, 42);
	ScrapIcon.SetBackground(Texture'BeltIconVMDScrapMetal');
	ScrapIcon.SetBackgroundStyle(DSTY_Masked);
	ScrapIcon.SetPos(ScrapIconPos.X, ScrapIconPos.Y);
	
	AmmoIcon = NewChild(class'Window');
	AmmoIcon.SetSize(42, 42);
	AmmoIcon.SetBackground(class'Ammo762mm'.Default.Icon);
	AmmoIcon.SetBackgroundStyle(DSTY_Masked);
	AmmoIcon.SetPos(AmmoIconPos.X, AmmoIconPos.Y);
	
	TurretIcon = NewChild(class'Window');
	TurretIcon.SetSize(TurretIconSize.X, TurretIconSize.Y);
	TurretIcon.SetBackground(Texture'PinkMaskTex');
	TurretIcon.SetBackgroundStyle(DSTY_Masked);
	TurretIcon.SetPos(TurretIconPos.X, TurretIconPos.Y);
}

function CreateButtons()
{
	LoadButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	LoadButton.SetButtonText(SprintF(LoadButtonText, 20));
	LoadButton.SetPos(LoadButtonPos.X, LoadButtonPos.Y);
	LoadButton.SetWidth(LoadButtonSize.X);
	
	EnhanceButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	EnhanceButton.SetButtonText(EnhanceButtonText);
	EnhanceButton.SetPos(EnhanceButtonPos.X, EnhanceButtonPos.Y);
	EnhanceButton.SetWidth(EnhanceButtonSize.X);
}

function DoPop()
{
	Root.PopWindow();
}

function UpdateInfo()
{
	local bool bHasTalent;
	local int SkillLevel, LastMaxAmmo, TMaxHealth, TRoll;
	local float CraftCostTweak;
	
	local Inventory TInv;
	local DeusExAmmo FindAmmo, TAmmo;
	local DeusExWeapon DXW;
	
	local class<DeusExAmmo> DXA;
	
	bCanEnhance = false;
	bCanLoad = false;
	
	if (Turret == None || Turret.bDeleteMe || Turret.HitPoints <= 0)
	{
		Turret = None;
		Root.PopWindow();
		return;
	}
	
	CF = GetCF();
	if ((CF != None) && (VMP != None) && (VMP.SkillSystem != None) && (Turret != None))
	{
		bHasTalent = VMP.HasSkillAugment('ElectronicsCrafting');
		
		LastScrapCount = VMP.CurScrap;
		
		SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillTech');
		CraftCostTweak = CF.GetCraftSkillMult(SkillLevel, bHasTalent);
		
		LastScrapCost = CF.GetMechanicalItemPrice(class'VMDSIDDPickup') * CraftCostTweak * 0.65;
		if (LastScrapCost < 1) LastScrapCost = 1;
		
		if (Turret.FireRate <= 0)
		{
			LastROF = 3600;
		}
		else
		{
			LastROF = Max(int(60.0 / Turret.FireRate), 1);
		}
		LastAmmoLeft = 0;
		LastCurrentAmmo = Turret.AmmoAmount;
		
		FindAmmo = DeusExAmmo(VMP.FindInventoryType(class'Ammo762mm'));
		if (FindAmmo != None)
		{
			LastAmmoLeft = FindAmmo.AmmoAmount;
		}
		
		LoadButton.SetButtonText(SprintF(LoadButtonText, Min(20, LastAmmoLeft)));
		
		WinInfoROF.Clear();
		WinInfoROF.SetTitle(SprintF(StrROFTitle, LastROF));
		WinInfoROF.SetText(SprintF(StrROFDesc, LastScrapCost));
		
		bCanEnhance = true;
		if (LastROF > 1800) bCanEnhance = false;
		else if (LastScrapCount < LastScrapCost) bCanEnhance = false;
		
		bCanLoad = true;
		if (LastAmmoLeft <= 0) bCanLoad = false;
	}
 	else
	{
  		AddTimer(0.1, True,, 'DoPop');
 	}
	
	ScrapLeftLabel.SetText(SprintF(StrScrapLeft, LastScrapCount));
	
	StockpileLabel.SetText(SprintF(StrStockpile, LastCurrentAmmo));
	AmmoLeftLabel.SetText(SprintF(StrAmmoLeft, LastAmmoLeft));
	
	EnhanceButton.SetSensitivity(bCanEnhance);
	LoadButton.SetSensitivity(bCanLoad);
	
	if (Turret != None)
	{
		if (Turret.Rotation.Roll != 0)
		{
			TRoll = int((Turret.Rotation.Roll / 16384.0) + 0.49) % 4;
		}
		else if (Turret.Rotation.Pitch != 0)
		{
			TRoll = int((Turret.Rotation.Pitch / 16384.0) + 0.49) % 4;
		}
		
		switch(TRoll)
		{
			case 0:
				TurretIcon.SetBackground(Texture'VMDManagementIconAutoturret0');
			break;
			case 1:
				TurretIcon.SetBackground(Texture'VMDManagementIconAutoturret1');
			break;
			case 2:
				TurretIcon.SetBackground(Texture'VMDManagementIconAutoturret2');
			break;
			case 3:
				TurretIcon.SetBackground(Texture'VMDManagementIconAutoturret3');
			break;
		}
	}
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	switch(ButtonPressed)
	{
		case DoneButton:
			AddTimer(0.1, True,, 'DoPop');
			bHandled = True;
		break;
		
		case LoadButton:
			AttemptLoad();
		break;
		case EnhanceButton:
			AttemptEnhance();
		break;
	}
	
	UpdateInfo();
	
	return bHandled;
}

function AttemptLoad()
{
	local int TTake;
	local DeusExAmmo TAmmo, DXA;
	local ScriptedPawn MLA;
	
	if (VMP == None || Turret == None)
	{
		return;
	}
	
	DXA = DeusExAmmo(VMP.FindInventoryType(class'Ammo762mm'));
	if (DXA == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanLoad)
	{
		VMP.PlaySound(Sound'LAWSelect', SLOT_None,,, 1024, Turret.VMDGetMiscPitch() * 1.5);
		
		TTake = Min(DXA.AmmoAmount, 20);
		Turret.AmmoAmount += TTake;
		DXA.AmmoAmount -= TTake;
		
		UpdateInfo();
	}
}

function AttemptEnhance()
{
	if (VMP == None || Turret == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanEnhance)
	{
		VMP.PlaySound(Sound'MechanicalCraftingMini', SLOT_None,,, 1024, Turret.VMDGetMiscPitch());
		
		VMP.CurScrap -= LastScrapCost;
		Turret.FireRate /= 2.0;
		UpdateInfo();
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

defaultproperties
{
     StrROFTitle="%d rounds/minute"
     StrROFDesc="%d scrap to enhance"
     StrScrap="Scrap: %d"
     StrStockpile="Ammo: %d"
     StrAmmoLeft="%d owned"
     StrScrapLeft="%d"
     
     LoadButtonPos=(X=196,Y=43)
     LoadButtonSize=(X=61,Y=15)
     EnhanceButtonPos=(X=350,Y=157)
     EnhanceButtonSize=(X=61,Y=15)
     
     ROFPos=(X=290,Y=105)
     ROFSize=(X=117,Y=88)
     StockpilePos=(X=324,Y=67)
     StockpileSize=(X=101,Y=24)
     AmmoLeftPos=(X=324,Y=91)
     AmmoLeftSize=(X=81,Y=24)
     NamePos=(X=191,Y=16)
     NameSize=(X=188,Y=32)
     ScrapLeftPos=(X=133,Y=141)
     ScrapLeftSize=(X=260,Y=12)
     
     ScrapIconPos=(X=242,Y=155)
     AmmoIconPos=(X=272,Y=66)
     
     TurretIconSize=(X=148,Y=148)
     TurretIconPos=(X=31,Y=46)
     
     LoadButtonText="Load %d"
     EnhanceButtonText="Enhance"
     
     Title="AutoTurret Management"
     DoneButtonText="|&Done"
     ClientWidth=428
     ClientHeight=186
     
     clientTextures(0)=Texture'VMDAutoturretManagementBG01'
     clientTextures(1)=Texture'VMDAutoturretManagementBG02'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=2
     TextureCols=2
}
