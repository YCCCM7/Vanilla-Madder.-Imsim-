//=============================================================================
// VMDMenuMEGHManagement
//=============================================================================
class VMDMenuMEGHManagement expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow DoneButton,  TurnOffButton;

var VMDMenuUIActionButtonWindow ReloadButton, UnloadButton, SwapButton, RepairButton, RechargeButton, SyringeButton;

var localized string DoneButtonText, TurnOffButtonText,
			ReloadButtonText, UnloadButtonText, SwapButtonText, EquipButtonText, UnequipButtonText, RepairButtonText, RechargeButtonText,
			StrHealthTitle, StrHealthDesc, StrEMPHealthTitle, StrEMPHealthDesc, StrScrap, StrCells,
			StrMagCount, StrAmmoLeft, StrNoWeapon, StrScrapLeft, StrCellsLeft,
			GiveSyringeButtonText, TakeSyringeButtonText, StrSyringesLeft;

var bool bCanRepair, bCanRecharge, bCanReload, bCanUnload, bCanSwap;
var int LastDroneHealth, LastDroneEMPHealth, LastCellCount, LastScrapCount, LastScrapCost,
			LastReloadCount, LastClipCount, LastCurrentAmmo, LastAmmoLeft;

var VMDBufferPlayer VMP;
var VMDMegh Megh;
var VMDNonStaticCraftingFunctions CF;

var class<DeusExWeapon> LastWeapon;

var MenuUIEditWindow CustomNameEntry;
var MenuUIHelpWindow WinInfoWeaponName, MagCountLabel, AmmoLeftLabel, ScrapLeftLabel, CellsLeftLabel, SyringesLeftLabel;
var VMDMenuUIInfoWindow WinInfoHealth, WinInfoEMPHealth;

var VMDButtonPos ReloadButtonPos, ReloadButtonSize, UnloadButtonPos, UnloadButtonSize, SwapButtonPos, SwapButtonSize,
			RepairButtonPos, RepairButtonSize, RechargeButtonPos, RechargeButtonSize,
			CustomNamePos, CustomNameSize, HealthPos, HealthSize, EMPHealthPos, EMPHealthSize,
			WeaponNamePos, WeaponNameSize,  MagCountPos, MagCountSize, AmmoLeftPos, AmmoLeftSize,
			ScrapIconPos, CellsIconPos, WeaponIconPos,
			ScrapLeftPos, ScrapLeftSize, CellsLeftPos, CellsLeftSize,
			MEGHIconPos, MEGHIconSize,
			SyringePatchPos, SyringePatchSize, SyringeIconPos, SyringeButtonPos, SyringeButtonSize, SyringesLeftPos, SyringesLeftSize;

var Window ScrapIcon, CellsIcon, WeaponIcon, MEGHIcon;
var VMDStylizedWindow SyringePatch, SyringeIcon;

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
	if ((VMP != None) && (VMDMegh(VMP.FrobTarget) != None))
	{
		Megh = VMDMegh(VMP.FrobTarget);
	}
	else
	{
		AddTimer(0.1, True,, 'DoPop');
		return;
	}
	
        DoneButton = WinButtonBar.AddButton(DoneButtonText, HALIGN_Right);
        TurnOffButton = WinButtonBar.AddButton(TurnOffButtonText, HALIGN_Left);
	
	CreateNameEditWindow();
	CreateInfoWindows();
	CreateIconWindows();
	CreateLabelWindows();
	CreateButtons();
	
	SetFocusWindow(DoneButton);
	
	AddTimer(0.2, True,, 'UpdateInfo');
}

function CreateNameEditWindow()
{
	CustomNameEntry = CreateMenuEditWindow(CustomNamePos.X, CustomNamePos.Y, CustomNameSize.X, 28, winClient);
	CustomNameEntry.SetSensitivity(True);
}

function CreateInfoWindows()
{
	if (WinClient != None)
	{
		WinInfoHealth = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoHealth.SetPos(HealthPos.X, HealthPos.Y);
		WinInfoHealth.SetSize(HealthSize.X, HealthSize.Y);
		WinInfoHealth.SetText("ERR B");
		
		WinInfoEMPHealth = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoEMPHealth.SetPos(EMPHealthPos.X, EMPHealthPos.Y);
		WinInfoEMPHealth.SetSize(EMPHealthSize.X, EMPHealthSize.Y);
		WinInfoEMPHealth.SetText("ERR C");
	}
}

function CreateLabelWindows()
{
	WinInfoWeaponName = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	WinInfoWeaponName.SetSize(WeaponNameSize.X, WeaponNameSize.Y);
	WinInfoWeaponName.SetTextAlignments(HALIGN_Left, VALIGN_Top);
	WinInfoWeaponName.SetText("ERR A");
	WinInfoWeaponName.SetPos(WeaponNamePos.X, WeaponNamePos.Y);
	
	MagCountLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	MagCountLabel.SetSize(MagCountSize.X, MagCountSize.Y);
	MagCountLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	MagCountLabel.SetText(SprintF(StrMagCount, LastCurrentAmmo, LastReloadCount));
	MagCountLabel.SetPos(MagCountPos.X, MagCountPos.Y);
	
	AmmoLeftLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	AmmoLeftLabel.SetSize(AmmoLeftSize.X, AmmoLeftSize.Y);
	AmmoLeftLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	AmmoLeftLabel.SetText(SprintF(StrAmmoLeft, LastAmmoLeft));
	AmmoLeftLabel.SetPos(AmmoLeftPos.X, AmmoLeftPos.Y);
	
	ScrapLeftLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	ScrapLeftLabel.SetSize(ScrapLeftSize.X, ScrapLeftSize.Y);
	ScrapLeftLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	ScrapLeftLabel.SetPos(ScrapLeftPos.X, ScrapLeftPos.Y);
	
	CellsLeftLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	CellsLeftLabel.SetSize(CellsLeftSize.X, CellsLeftSize.Y);
	CellsLeftLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	CellsLeftLabel.SetPos(CellsLeftPos.X, CellsLeftPos.Y);
	
	ScrapLeftLabel.SetText(SprintF(StrScrapLeft, LastScrapCount));
	CellsLeftLabel.SetText(SprintF(StrCellsLeft, LastCellCount));
	
	SyringesLeftLabel = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	SyringesLeftLabel.SetSize(SyringesLeftSize.X, SyringesLeftSize.Y);
	SyringesLeftLabel.SetTextAlignments(HALIGN_Center, VALIGN_Top);
	SyringesLeftLabel.SetPos(SyringesLeftPos.X+9999, SyringesLeftPos.Y);
}

function CreateIconWindows()
{
	SyringePatch = VMDStylizedWindow(WinClient.NewChild(class'VMDStylizedWindow'));
	SyringePatch.SetSize(SyringePatchSize.X, SyringePatchSize.Y);
	SyringePatch.SetBackground(Texture'PinkMaskTex');
	SyringePatch.SetBackgroundStyle(DSTY_Masked);
	SyringePatch.SetPos(SyringePatchPos.X, SyringePatchPos.Y);
	SyringePatch.bMenuColors = true;
	SyringePatch.bBlockReskin = false;
	SyringePatch.bBlockTranslucency = true;
	SyringePatch.StyleChanged();
	SyringePatch.OverrideColor = SyringePatch.ColBG;
	SyringePatch.StyleChanged();
	
	ScrapIcon = NewChild(class'Window');
	ScrapIcon.SetSize(42, 42);
	ScrapIcon.SetBackground(Texture'BeltIconVMDScrapMetal');
	ScrapIcon.SetBackgroundStyle(DSTY_Masked);
	ScrapIcon.SetPos(ScrapIconPos.X, ScrapIconPos.Y);
	
	CellsIcon = NewChild(class'Window');
	CellsIcon.SetSize(42, 42);
	CellsIcon.SetBackground(Texture'BeltIconBioCell');
	CellsIcon.SetBackgroundStyle(DSTY_Masked);
	CellsIcon.SetPos(CellsIconPos.X, CellsIconPos.Y);
	
	WeaponIcon = NewChild(class'Window');
	WeaponIcon.SetSize(42, 42);
	WeaponIcon.SetBackground(Texture'PinkMaskTex');
	WeaponIcon.SetBackgroundStyle(DSTY_Masked);
	WeaponIcon.SetPos(WeaponIconPos.X, WeaponIconPos.Y);
	
	MEGHIcon = NewChild(class'Window');
	MEGHIcon.SetSize(MEGHIconSize.X, MEGHIconSize.Y);
	MEGHIcon.SetBackground(Texture'PinkMaskTex');
	MEGHIcon.SetBackgroundStyle(DSTY_Masked);
	MEGHIcon.SetPos(MEGHIconPos.X, MEGHIconPos.Y);
	
	SyringeIcon = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
	SyringeIcon.SetSize(42, 42);
	SyringeIcon.SetBackground(Texture'PinkMaskTex');
	SyringeIcon.SetBackgroundStyle(DSTY_Masked);
	SyringeIcon.SetPos(SyringeIconPos.X+9999, SyringeIconPos.Y);
	SyringeIcon.bMenuColors = true;
	SyringeIcon.bBlockReskin = true;
	SyringeIcon.bBlockTranslucency = true;
	SyringeIcon.StyleChanged();
}

function CreateButtons()
{
	ReloadButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	ReloadButton.SetButtonText(ReloadButtonText);
	ReloadButton.SetPos(ReloadButtonPos.X, ReloadButtonPos.Y);
	ReloadButton.SetWidth(ReloadButtonSize.X);
	
	UnloadButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	UnloadButton.SetButtonText(UnloadButtonText);
	UnloadButton.SetPos(UnloadButtonPos.X, UnloadButtonPos.Y);
	UnloadButton.SetWidth(UnloadButtonSize.X);
	
	SwapButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	SwapButton.SetButtonText(SwapButtonText);
	SwapButton.SetPos(SwapButtonPos.X, SwapButtonPos.Y);
	SwapButton.SetWidth(SwapButtonSize.X);
	
	RepairButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	RepairButton.SetButtonText(RepairButtonText);
	RepairButton.SetPos(RepairButtonPos.X, RepairButtonPos.Y);
	RepairButton.SetWidth(RepairButtonSize.X);
	
	RechargeButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	RechargeButton.SetButtonText(RechargeButtonText);
	RechargeButton.SetPos(RechargeButtonPos.X, RechargeButtonPos.Y);
	RechargeButton.SetWidth(ReloadButtonSize.X);
	
	SyringeButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	SyringeButton.SetButtonText("ERR SYR");
	SyringeButton.SetPos(SyringeButtonPos.X+9999, SyringeButtonPos.Y);
	SyringeButton.SetWidth(SyringeButtonSize.X);
}

function DoPop()
{
	Root.PopWindow();
}

function UpdateInfo()
{
	local bool bHasTalent, bHasBuff;
	local int EMPMargin, SkillLevel, LastMaxAmmo, TMaxHealth, NumSyringes;
	local float CraftCostTweak;
	
	local Inventory TInv;
	local BioelectricCell TCell;
	local DeusExAmmo FindAmmo, TAmmo;
	local DeusExWeapon DXW;
	
	local class<DeusExAmmo> DXA;
	
	bCanSwap = false;
	bCanRepair = false;
	bCanRecharge = false;
	bCanReload = false;
	bCanUnload = false;
	
	if (Megh == None || Megh.bDeleteMe || Megh.EMPHitPoints <= 0)
	{
		Megh = None;
		Root.PopWindow();
		return;
	}
	
	CF = GetCF();
	if ((CF != None) && (VMP != None) && (VMP.SkillSystem != None) && (Megh != None))
	{
		bHasTalent = VMP.HasSkillAugment("ElectronicsCrafting");
		bHasBuff = VMP.HasSkillAugment("ElectronicsDroneArmor");
		
		EMPMargin = Megh.VMDGetMaxEMPHitPoints();
		TMaxHealth = Megh.VMDGetMaxHealth();
		
		LastDroneHealth = int(float(Megh.Health)*100.0 / float(TMaxHealth));
		LastDroneEMPHealth = 100 - int(float(Megh.EMPHitPoints)*100.0 / float(EMPMargin));
		
		if (VMP.Inventory != None)
		{
			for(TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
			{
				TCell = BioelectricCell(TInv);
				if (TCell != None)
				{
					LastCellCount = TCell.NumCopies;
					break;
				}
			}
		}
		LastScrapCount = VMP.CurScrap;
		
		SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillTech');
		CraftCostTweak = CF.GetCraftSkillMult(SkillLevel, bHasTalent);
		if (bHasBuff) CraftCostTweak *= 1.5;
		
		LastScrapCost = CF.GetMechanicalItemPrice(class'VMDMeghPickup') * CraftCostTweak;
		LastScrapCost *= (100.0 - float(LastDroneHealth)) / 100.0;
		if ((LastDroneHealth < 100) && (LastScrapCost < 1)) LastScrapCost = 1;
		
		LastAmmoLeft = 0;
		LastCurrentAmmo = 0;
		LastClipCount = 0;
		LastReloadCount = 0;
		
		bCanSwap = true;
		if (CountNumberValidWeapons() <= 0)
		{
			bCanSwap = false;
		}
		
		DXW = Megh.FirstWeapon();
		if (DXW != None)
		{
			WeaponIcon.SetBackground(DXW.Icon);
			WinInfoWeaponName.SetText(DXW.ItemName);
			
			LastReloadCount = DXW.ReloadCount;
			LastClipCount = DXW.ClipCount;
			
			TAmmo = DeusExAmmo(DXW.AmmoType);
			if (TAmmo != None)
			{
				LastCurrentAmmo = TAmmo.AmmoAmount;
			}
			DXA = class<DeusExAmmo>(DXW.AmmoName);
			
			LastAmmoLeft = 0;
			if (DXA != None)
			{
				FindAmmo = DeusExAmmo(VMP.FindInventoryType(DXA));
				if (FindAmmo != None)
				{	
					LastAmmoLeft = FindAmmo.AmmoAmount;
					LastMaxAmmo = FindAmmo.MaxAmmo;
				}
			}
		}
		else
		{
			WeaponIcon.SetBackground(Texture'PinkMaskTex');
			WinInfoWeaponName.SetText(StrNoWeapon);
		}
		
		WinInfoHealth.Clear();
		WinInfoHealth.SetTitle(SprintF(StrHealthTitle, LastDroneHealth));
		WinInfoHealth.SetText(SprintF(StrHealthDesc, LastScrapCost));
		WinInfoEMPHealth.Clear();
		WinInfoEMPHealth.SetTitle(SprintF(StrEMPHealthTitle, LastDroneEMPHealth));
		WinInfoEMPHealth.SetText(StrEMPHealthDesc);
		
		bCanRepair = true;
		if (LastDroneHealth >= 100) bCanRepair = false;
		else if (LastScrapCount < LastScrapCost) bCanRepair = false;
		
		bCanRecharge = true;
		if (LastDroneEMPHealth < 1) bCanRecharge = false;
		else if (LastCellCount < 1) bCanRecharge = false;
		
		bCanReload = true;
		if ((LastCurrentAmmo == LastReloadCount) && (LastClipCount < LastReloadCount)) bCanReload = false;
		else if (LastAmmoLeft <= 0) bCanReload = false;
		
		bCanUnload = true;
		if (LastCurrentAmmo <= 0) bCanUnload = false;
		else if ((LastAmmoLeft >= LastMaxAmmo) && (LastAmmoLeft > 0)) bCanUnload = false;
		
		if (Megh.DroneWeaponIsGrenade())
		{
			bCanUnload = false;
			bCanReload = false;
		}
	}
 	else
	{
  		AddTimer(0.1, True,, 'DoPop');
 	}
	
	if (Megh.bCanHeal)
	{
		SyringeIcon.SetPos(SyringeIconPos.X, SyringeIconPos.Y);
		SyringeButton.SetPos(SyringeButtonPos.X, SyringeButtonPos.Y);
		SyringesLeftLabel.SetPos(SyringesLeftPos.X, SyringesLeftPos.Y);
		
		NumSyringes = CountNumSyringes();
		SyringesLeftLabel.SetText(SprintF(StrSyringesLeft, NumSyringes));
		
		SyringeButton.SetSensitivity(False);
		if (!Megh.bHasHeal)
		{
			SyringeButton.SetButtonText(GiveSyringeButtonText);
			if (NumSyringes > 0)
			{
				SyringeButton.SetSensitivity(True);
			}
		}
		else
		{
			SyringeButton.SetButtonText(TakeSyringeButtonText);
			SyringeButton.SetSensitivity(True);
		}
		
		SyringePatch.SetBackground(Texture'VMDMeghManagementBG02Patch');
		SyringeIcon.SetBackground(Texture'BeltIconMedigel');
		if ((Megh.bHasHeal) && (!SyringeIcon.bBlockReskin))
		{
			SyringeIcon.bBlockReskin = true;
			SyringeIcon.StyleChanged();
		}
		else if ((!Megh.bHasHeal) && (SyringeIcon.bBlockReskin))
		{
			SyringeIcon.bBlockReskin = false;
			SyringeIcon.StyleChanged();
		}
	}
	
	if (Megh.bHealthBuffed)
	{
		MEGHIcon.SetBackground(Texture'VMDManagementIconMEGHHeavy');
		if (Megh.bCanHeal)
		{
			if (Megh.bHasHeal)
			{
				MEGHIcon.SetBackground(Texture'VMDManagementIconMEGHHeavyNeedle');
			}
			else
			{
				MEGHIcon.SetBackground(Texture'VMDManagementIconMEGHHeavyNoNeedle');
			}
		}
	}
	else
	{
		MEGHIcon.SetBackground(Texture'VMDManagementIconMEGH');
		if (Megh.bCanHeal)
		{
			if (Megh.bHasHeal)
			{
				MEGHIcon.SetBackground(Texture'VMDManagementIconMEGHNeedle');
			}
			else
			{
				MEGHIcon.SetBackground(Texture'VMDManagementIconMEGHNoNeedle');
			}
		}
	}
	
	ScrapLeftLabel.SetText(SprintF(StrScrapLeft, LastScrapCount));
	CellsLeftLabel.SetText(SprintF(StrCellsLeft, LastCellCount));
	
	MagCountLabel.SetText(SprintF(StrMagCount, LastCurrentAmmo, LastReloadCount));
	AmmoLeftLabel.SetText(SprintF(StrAmmoLeft, LastAmmoLeft));
	
	SwapButton.SetButtonText(SwapButtonText);
	if (Megh.FirstWeapon() == None)
	{
		SwapButton.SetButtonText(EquipButtonText);
	}
	else if ((!bCanSwap) && (Megh.FirstWeapon() != None))
	{
		SwapButton.SetButtonText(UnequipButtonText);
	}
	SwapButton.SetSensitivity(bCanSwap || Megh.FirstWeapon() != None);
	
	RepairButton.SetSensitivity(bCanRepair);
	RechargeButton.SetSensitivity(bCanRecharge);
	ReloadButton.SetSensitivity(bCanReload);
	UnloadButton.SetSensitivity(bCanUnload);
	
	if (Megh != None)
	{
		if ((CustomNameEntry != None) && (CustomNameEntry.GetText() != ""))
		{
			Megh.CustomName = CustomNameEntry.GetText();
		}
		//Megh.UpdateWeaponModel();
	}
}

function int CountNumSyringes()
{
	local Inventory TInv;
	
	if (VMP == None || Megh == None) return 0;
	
	for(TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
	{
		if (VMDMedigel(TInv) != None)
		{
			return VMDMedigel(TInv).NumCopies;
		}
	}
	
	return 0;
}

function int CountNumberValidWeapons()
{
	local int Ret;
	local Inventory TInv, FirstWeapon;
	
	if (VMP == None || VMP.Inventory == None || Megh == None) return 0;
	FirstWeapon = Megh.FirstWeapon();
	
	for(TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
	{
		if ((FirstWeapon != None) && (FirstWeapon.Class == TInv.Class)) continue;
		
		switch(TInv.Class.Name)
		{
			case 'WeaponPistol':
			case 'WeaponStealthPistol':
			case 'WeaponPeppergun':
			case 'WeaponCombatKnife':
			case 'WeaponBaton':
			case 'WeaponHideAGun':
			case 'WeaponMiniCrossbow':
			case 'WeaponSawedOffShotgun':
				Ret++;
			break;
			case 'WeaponEMPGrenade':
			case 'WeaponGasGrenade':
			case 'WeaponLAM':
			case 'WeaponNanoVirusGrenade':
			
			case 'WeaponHCEMPGrenade':
			case 'WeaponHCHCGasGrenade':
			case 'WeaponHCLAM':
			case 'WeaponHCNanoVirusGrenade':
				if ((DeusExWeapon(TInv).AmmoType != None) && (DeusExWeapon(TInv).AmmoType.AmmoAmount > 0))
				{
					Ret++;
				}
			break;
			default:
				if ((DeusExWeapon(TInv) != None) && (DeusExWeapon(TInv).bDroneCapableWeapon))
				{
					Ret++;
				}
			break;
		}
	}
	
	return Ret;
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
		case TurnOffButton:
			Megh.ReturnToItem();
			Megh = None; //Clear the memory reference.
			AddTimer(0.1, True,, 'DoPop');
			bHandled = true;
		break;
		
		case ReloadButton:
			AttemptReload();
		break;
		case UnloadButton:
			AttemptUnload();
		break;
		case SwapButton:
			if ((!bCanSwap) && (Megh.FirstWeapon() != None))
			{
				AttemptUnequip();
			}
			else
			{
				AttemptSwap();
			}
		break;
		
		case RepairButton:
			AttemptRepair();
		break;
		case RechargeButton:
			AttemptRecharge();
		break;
		
		case SyringeButton:
			if (!Megh.bHasHeal)
			{
				AttemptSyringeReload();
			}
			else
			{
				AttemptSyringeRefund();
			}
		break;
	}
	
	UpdateInfo();
	
	return bHandled;
}

function AttemptSyringeReload()
{
	local Inventory TInv;
	
	if (VMP == None || Megh == None) return;
	
	for(TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
	{
		if (VMDMedigel(TInv) != None)
		{
			VMP.PlaySound(Sound'MedicalBotRaiseArm', SLOT_None,,, 1024, MEGH.RandomPitch());
			
			VMDMedigel(TInv).UseOnce();
			Megh.bHasHeal = true;
			break;
		}
	}
}

function AttemptSyringeRefund()
{
	local VMDMedigel Gel;
	
	if (VMP == None || Megh == None) return;
	
	Gel = Megh.VMDMEGHDropSyringe();
	if (Gel != None)
	{
		VMP.PlaySound(Sound'MedicalBotLowerArm', SLOT_None,,, 1024, MEGH.RandomPitch());
		
		VMP.FrobTarget = Gel;
		VMP.ParseRightClick();
	}
}

function AttemptUnequip()
{
	if (Megh == None)
	{
		return;
	}
	
	Megh.VMDMeghDropWeapon();
}

function AttemptReload()
{
	local int TTake;
	local DeusExAmmo TAmmo, DXA;
	local DeusExWeapon DXW;
	local class<DeusExAmmo> TType;
	local ScriptedPawn MLA;
	
	if (VMP == None || Megh == None)
	{
		return;
	}
	
	DXW = Megh.FirstWeapon();
	if (DXW != None)
	{
		TAmmo = DeusExAmmo(DXW.AmmoType);
		TType = class<DeusExAmmo>(DXW.AmmoName);
		if (TType != None)
		{
			DXA = DeusExAmmo(VMP.FindInventoryType(TType));
		}
	}
	
	if (TType == None || DXA == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanReload)
	{
		Megh.bSaidOutOfAmmo = false;
		
		if (DXW.AltFireSound != None)
		{
			VMP.PlaySound(DXW.AltFireSound, SLOT_None,,, 1024, DXW.VMDGetMiscPitch());
		}
		else if (DXW.CockingSound != None)
		{
			VMP.PlaySound(DXW.CockingSound, SLOT_None,,, 1024, DXW.VMDGetMiscPitch());
		}
		
		TTake = Min(DXA.AmmoAmount, LastReloadCount - LastCurrentAmmo);
		DXW.ClipCount -= TTake;
		TAmmo.AmmoAmount += TTake;
		DXA.AmmoAmount -= TTake;
		UpdateInfo();
		
		MLA = Megh.MEGHLastEnemy;
		if ((TAmmo.AmmoAmount > 0) && (MLA != None) && (!MLA.bDeleteMe) && (!MLA.IsInState('Dying')) && (Megh.FastTrace(Megh.Location, MLA.Location)))
		{
			Megh.MEGHIssueOrder('Attacking', MLA);
		}
		else
		{
			Megh.MEGHLastEnemy = None;
		}
		
		Megh.SetupWeapon(!Megh.bReconMode, true);
	}
}

function AttemptUnload()
{
	local int TGive;
	local DeusExAmmo TAmmo, DXA;
	local DeusExWeapon DXW;
	local class<DeusExAmmo> TType;
	
	if (VMP == None || Megh == None)
	{
		return;
	}
	
	DXW = Megh.FirstWeapon();
	if (DXW != None)
	{
		TAmmo = DeusExAmmo(DXW.AmmoType);
		TType = class<DeusExAmmo>(DXW.AmmoName);
		if (TType != None)
		{
			DXA = DeusExAmmo(VMP.FindInventoryType(TType));
		}
	}
	
	if (TType == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanUnload)
	{
		if (DXW.CockingSound != None)
		{
			VMP.PlaySound(DXW.CockingSound, SLOT_None,,, 1024, DXW.VMDGetMiscPitch());
		}
		else if (DXW.AltFireSound != None)
		{
			VMP.PlaySound(DXW.AltFireSound, SLOT_None,,, 1024, DXW.VMDGetMiscPitch());
		}
		
		TGive = Min(TAmmo.AmmoAmount, LastReloadCount - LastClipCount);
		if (DXA != None)
		{
			TGive = Min(TGive, DXA.MaxAmmo - DXA.AmmoAmount);
		}
		if (TGive < 0) TGive = 0;
		
		DXW.ClipCount += TGive;
		TAmmo.AmmoAmount -= TGive;
		if (DXA == None)
		{
			DXA = Megh.Spawn(TType,,, Megh.Location);
			VMP.FrobTarget = DXA;
			VMP.ParseRightClick();
		}
		else
		{
			DXA.AmmoAmount += TGive;
		}
		UpdateInfo();
	}
}

function AttemptSwap()
{
	local VMDMenuMEGHWeaponWindow NewWep;
	
	if (VMP == None || Megh == None || Root == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanSwap)
	{
		NewWep = VMDMenuMEGHWeaponWindow(Root.InvokeMenuScreen(Class'VMDMenuMEGHWeaponWindow'));
		if (NewWep != None)
		{
			NewWep.VMP = VMP;
			NewWep.Megh = Megh;
			NewWep.CreateList();
		}
	}
}

function AttemptRepair()
{
	if (VMP == None || Megh == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanRepair)
	{
		VMP.PlaySound(Sound'MechanicalCraftingMini', SLOT_None,,, 1024, MEGH.RandomPitch());
		
		VMP.CurScrap -= LastScrapCost;
		Megh.Health = Megh.VMDGetMaxHealth();
		UpdateInfo();
	}
}

function AttemptRecharge()
{
	local int TEMPMax;
	local Inventory TInv;
	local BioelectricCell TCell;
	
	if (VMP == None || VMP.Inventory == None || Megh == None)
	{
		return;
	}
	
	if (VMP.Inventory != None)
	{
		for(TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
		{
			TCell = BioelectricCell(TInv);
			if (TCell != None)
			{
				break;
			}
		}
	}
	
	if (TCell == None) return;
	
	UpdateInfo();
	if (bCanRecharge)
	{
		VMP.PlaySound(Sound'BioElectricHiss', SLOT_None,,, 1024, MEGH.RandomPitch());
		TCell.UseOnce();
		
		TEMPMax = Megh.VMDGetMaxEMPHitPoints();
		Megh.EMPHitPoints = Min(TEMPMax, Megh.EMPHitPoints + int(float(TEMPMax)*0.25));
		if (Megh.EMPHitPoints >= TEMPMax)
		{
			if (Megh.SparkGen != None)
			{
				Megh.SparkGen.DelayedDestroy();
				Megh.SparkGen = None;
			}
		}
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
     StrHealthTitle="%d%% hull value left"
     StrHealthDesc="%d scrap to repair"
     StrEMPHealthTitle="%d%% EMP damage"
     StrEMPHealthDesc="25% reduction per cell"
     StrScrap="Scrap: %d"
     StrCells="Cells: %d"
     StrMagCount="Ammo: %d/%d"
     StrAmmoLeft="%d owned"
     StrScrapLeft="%d"
     StrCellsLeft="%dx"
     
     ReloadButtonPos=(X=199,Y=77)
     ReloadButtonSize=(X=53,Y=15)
     UnloadButtonPos=(X=199,Y=100)
     UnloadButtonSize=(X=53,Y=15)
     SwapButtonPos=(X=311,Y=123)
     SwapButtonSize=(X=53,Y=15)
     RepairButtonPos=(X=147,Y=259)
     RepairButtonSize=(X=53,Y=15)
     RechargeButtonPos=(X=352,Y=259)
     RechargeButtonSize=(X=53,Y=15)
     
     HealthPos=(X=83,Y=207)
     HealthSize=(X=117,Y=88)
     EMPHealthPos=(X=286,Y=207)
     EMPHealthSize=(X=117,Y=88)
     WeaponNamePos=(X=226,Y=77)
     WeaponNameSize=(X=124,Y=12)
     MagCountPos=(X=324,Y=102)
     MagCountSize=(X=101,Y=24)
     AmmoLeftPos=(X=324,Y=126)
     AmmoLeftSize=(X=81,Y=24)
     CustomNamePos=(X=191,Y=16)
     CustomNameSize=(X=188,Y=32)
     ScrapLeftPos=(X=32,Y=243)
     ScrapLeftSize=(X=49,Y=12)
     CellsLeftPos=(X=236,Y=243)
     CellsLeftSize=(X=49,Y=12)
     
     ScrapIconPos=(X=35,Y=257)
     CellsIconPos=(X=239,Y=257)
     WeaponIconPos=(X=272,Y=101)
     
     MEGHIconSize=(X=159,Y=128)
     MEGHIconPos=(X=31,Y=63)
     
     //SyringePatchPos=(X=271,Y=148)
     SyringePatchPos=(X=261,Y=125)
     SyringePatchSize=(X=153,Y=42)
     SyringesLeftPos=(X=309,Y=177)
     SyringesLeftSize=(X=116,Y=24)
     SyringeIconPos=(X=271,Y=148)
     SyringeButtonPos=(X=199,Y=151)
     SyringeButtonSize=(X=53,Y=15)
     
     ReloadButtonText="Reload"
     UnloadButtonText="Unload"
     EquipButtonText="Equip"
     SwapButtonText="Swap"
     UnequipButtonText="Unequip"
     RepairButtonText="Repair"
     RechargeButtonText="Charge"
     GiveSyringeButtonText="Give"
     TakeSyringeButtonText="Take"
     StrSyringesLeft="%d Syringe(s)"
     
     StrNoWeapon="No weapon"
     
     Title="M.E.G.H. Management"
     DoneButtonText="|&Done"
     TurnOffButtonText="|&Turn Off"
     ClientWidth=428
     ClientHeight=295
     
     clientTextures(0)=Texture'VMDMEGHManagementBG01'
     clientTextures(1)=Texture'VMDMEGHManagementBG02'
     clientTextures(2)=Texture'VMDMEGHManagementBG03'
     clientTextures(3)=Texture'VMDMEGHManagementBG04'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=2
     TextureCols=2
}
