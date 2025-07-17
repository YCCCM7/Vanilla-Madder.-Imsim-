//=============================================================================
// VMDMenuSIDDManagement
//=============================================================================
class VMDMenuSIDDManagement expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow DoneButton,  TurnOffButton;

var VMDMenuUIActionButtonWindow ReloadButton, UnloadButton, RepairButton, RechargeButton;

var localized string DoneButtonText, TurnOffButtonText,
			ReloadButtonText, UnloadButtonText, RepairButtonText, RechargeButtonText,
			StrHealthTitle, StrHealthDesc, StrEMPHealthTitle, StrEMPHealthDesc, StrScrap, StrCells,
			StrMagCount, StrAmmoLeft, StrNoWeapon, StrScrapLeft, StrCellsLeft;

var bool bCanRepair, bCanRecharge, bCanReload, bCanUnload;
var int LastDroneHealth, LastDroneEMPHealth, LastCellCount, LastScrapCount, LastScrapCost,
			LastReloadCount, LastClipCount, LastCurrentAmmo, LastAmmoLeft;

var VMDBufferPlayer VMP;
var VMDSidd Sidd;
var VMDNonStaticCraftingFunctions CF;

var class<DeusExWeapon> LastWeapon;

var MenuUIEditWindow CustomNameEntry;
var MenuUIHelpWindow MagCountLabel, AmmoLeftLabel, ScrapLeftLabel, CellsLeftLabel;
var VMDMenuUIInfoWindow WinInfoHealth, WinInfoEMPHealth;

var VMDButtonPos ReloadButtonPos, ReloadButtonSize, UnloadButtonPos, UnloadButtonSize,
			RepairButtonPos, RepairButtonSize, RechargeButtonPos, RechargeButtonSize,
			CustomNamePos, CustomNameSize, HealthPos, HealthSize, EMPHealthPos, EMPHealthSize,
			AmmoNameSize,  MagCountPos, MagCountSize, AmmoLeftPos, AmmoLeftSize,
			ScrapIconPos, CellsIconPos, AmmoIconPos,
			ScrapLeftPos, ScrapLeftSize, CellsLeftPos, CellsLeftSize,
			SIDDIconPos, SIDDIconSize;

var Window ScrapIcon, CellsIcon, AmmoIcon, SIDDIcon;

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
	if ((VMP != None) && (VMDSIDD(VMP.FrobTarget) != None))
	{
		SIDD = VMDSIDD(VMP.FrobTarget);
	}
	else
	{
		AddTimer(0.1, False,, 'DoPop');
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
}

function CreateIconWindows()
{
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
	
	AmmoIcon = NewChild(class'Window');
	AmmoIcon.SetSize(42, 42);
	AmmoIcon.SetBackground(class'Ammo762mm'.Default.Icon);
	AmmoIcon.SetBackgroundStyle(DSTY_Masked);
	AmmoIcon.SetPos(AmmoIconPos.X, AmmoIconPos.Y);
	
	SIDDIcon = NewChild(class'Window');
	SIDDIcon.SetSize(SIDDIconSize.X, SIDDIconSize.Y);
	SIDDIcon.SetBackground(Texture'PinkMaskTex');
	SIDDIcon.SetBackgroundStyle(DSTY_Masked);
	SIDDIcon.SetPos(SIDDIconPos.X, SIDDIconPos.Y);
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
	
	RepairButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	RepairButton.SetButtonText(RepairButtonText);
	RepairButton.SetPos(RepairButtonPos.X, RepairButtonPos.Y);
	RepairButton.SetWidth(RepairButtonSize.X);
	
	RechargeButton = VMDMenuUIActionButtonWindow(WinClient.NewChild(Class'VMDMenuUIActionButtonWindow'));
	RechargeButton.SetButtonText(RechargeButtonText);
	RechargeButton.SetPos(RechargeButtonPos.X, RechargeButtonPos.Y);
	RechargeButton.SetWidth(ReloadButtonSize.X);
}

function DoPop()
{
	Root.PopWindow();
}

function UpdateInfo()
{
	local bool bHasTalent;
	local int EMPMargin, SkillLevel, LastMaxAmmo, TMaxHealth;
	local float CraftCostTweak;
	
	local Inventory TInv;
	local BioelectricCell TCell;
	local DeusExAmmo FindAmmo, TAmmo;
	local DeusExWeapon DXW;
	
	local class<DeusExAmmo> DXA;
	
	bCanRepair = false;
	bCanRecharge = false;
	bCanReload = false;
	bCanUnload = false;
	
	if (SIDD == None || SIDD.bDeleteMe || SIDD.EMPHitPoints <= 0)
	{
		SIDD = None;
		Root.PopWindow();
		return;
	}
	
	CF = GetCF();
	if ((CF != None) && (VMP != None) && (VMP.SkillSystem != None) && (SIDD != None))
	{
		bHasTalent = VMP.HasSkillAugment("ElectronicsCrafting");
		
		EMPMargin = SIDD.VMDGetMaxEMPHitPoints();
		TMaxHealth = SIDD.VMDGetMaxHealth();
		
		LastDroneHealth = int(float(SIDD.Health)*100.0 / float(TMaxHealth));
		LastDroneEMPHealth = 100 - int(float(SIDD.EMPHitPoints)*100.0 / float(EMPMargin));
		
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
		
		LastScrapCost = CF.GetMechanicalItemPrice(class'VMDSIDDPickup') * CraftCostTweak;
		LastScrapCost *= (100.0 - float(LastDroneHealth)) / 100.0;
		if ((LastDroneHealth < 100) && (LastScrapCost < 1)) LastScrapCost = 1;
		
		LastAmmoLeft = 0;
		LastCurrentAmmo = 0;
		LastClipCount = 0;
		LastReloadCount = 0;
		
		DXW = SIDD.GetFirstWeapon();
		if (DXW != None)
		{
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
	}
 	else
	{
  		AddTimer(0.1, False,, 'DoPop');
 	}
	
	ScrapLeftLabel.SetText(SprintF(StrScrapLeft, LastScrapCount));
	CellsLeftLabel.SetText(SprintF(StrCellsLeft, LastCellCount));
	
	MagCountLabel.SetText(SprintF(StrMagCount, LastCurrentAmmo, LastReloadCount));
	AmmoLeftLabel.SetText(SprintF(StrAmmoLeft, LastAmmoLeft));
	
	RepairButton.SetSensitivity(bCanRepair);
	RechargeButton.SetSensitivity(bCanRecharge);
	ReloadButton.SetSensitivity(bCanReload);
	UnloadButton.SetSensitivity(bCanUnload);
	
	if (SIDD != None)
	{
		if ((CustomNameEntry != None) && (CustomNameEntry.GetText() != ""))
		{
			SIDD.CustomName = CustomNameEntry.GetText();
		}
		
		if (SIDD.Multiskins[1] == Texture'PinkMaskTex')
		{
			SIDDIcon.SetBackground(Texture'VMDManagementIconSIDDEmpty');
		}
		else
		{
			SIDDIcon.SetBackground(Texture'VMDManagementIconSIDD');
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
			AddTimer(0.1, False,, 'DoPop');
			bHandled = True;
		break;
		case TurnOffButton:
			SIDD.ReturnToItem();
			SIDD = None; //Clear the memory reference.
			AddTimer(0.1, False,, 'DoPop');
			bHandled = true;
		break;
		
		case ReloadButton:
			AttemptReload();
		break;
		case UnloadButton:
			AttemptUnload();
		break;
		
		case RepairButton:
			AttemptRepair();
		break;
		case RechargeButton:
			AttemptRecharge();
		break;
	}
	
	UpdateInfo();
	
	return bHandled;
}

function AttemptReload()
{
	local int TTake;
	local DeusExAmmo TAmmo, DXA;
	local DeusExWeapon DXW;
	local class<DeusExAmmo> TType;
	local ScriptedPawn MLA;
	
	if (VMP == None || SIDD == None)
	{
		return;
	}
	
	DXW = SIDD.GetFirstWeapon();
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
		SIDD.bSaidOutOfAmmo = false;
		
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
		
		SIDD.UpdateMagSkin();
		UpdateInfo();
		
		if (!SIDD.IsInState('Attacking'))
		{
			SIDD.SIDDIssueOrder('Standing', None);
		}
	}
}

function AttemptUnload()
{
	local int TGive;
	local DeusExAmmo TAmmo, DXA;
	local DeusExWeapon DXW;
	local class<DeusExAmmo> TType;
	
	if (VMP == None || SIDD == None)
	{
		return;
	}
	
	DXW = SIDD.GetFirstWeapon();
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
			DXA = SIDD.Spawn(TType,,, SIDD.Location + vect(0, 0, 15));
			VMP.FrobTarget = DXA;
			VMP.ParseRightClick();
		}
		else
		{
			DXA.AmmoAmount += TGive;
		}
		
		SIDD.UpdateMagSkin();
		UpdateInfo();
	}
}

function AttemptRepair()
{
	if (VMP == None || SIDD == None)
	{
		return;
	}
	
	UpdateInfo();
	if (bCanRepair)
	{
		VMP.PlaySound(Sound'MechanicalCraftingMini', SLOT_None,,, 1024, SIDD.RandomPitch());
		
		VMP.CurScrap -= LastScrapCost;
		SIDD.Health = SIDD.VMDGetMaxHealth();
		UpdateInfo();
	}
}

function AttemptRecharge()
{
	local int TEMPMax;
	local Inventory TInv;
	local BioelectricCell TCell;
	
	if (VMP == None || VMP.Inventory == None || SIDD == None)
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
		VMP.PlaySound(Sound'BioElectricHiss', SLOT_None,,, 1024, SIDD.RandomPitch());
		TCell.UseOnce();
		
		TEMPMax = SIDD.VMDGetMaxEMPHitPoints();
		SIDD.EMPHitPoints = Min(TEMPMax, SIDD.EMPHitPoints + int(float(TEMPMax)*0.5));
		if (SIDD.EMPHitPoints >= TEMPMax)
		{
			if (SIDD.SparkGen != None)
			{
				SIDD.SparkGen.DelayedDestroy();
				SIDD.SparkGen = None;
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
     StrEMPHealthDesc="50% reduction per cell"
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
     RepairButtonPos=(X=147,Y=259)
     RepairButtonSize=(X=53,Y=15)
     RechargeButtonPos=(X=352,Y=259)
     RechargeButtonSize=(X=53,Y=15)
     
     HealthPos=(X=83,Y=207)
     HealthSize=(X=117,Y=88)
     EMPHealthPos=(X=286,Y=207)
     EMPHealthSize=(X=117,Y=88)
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
     AmmoIconPos=(X=272,Y=101)
     
     SIDDIconSize=(X=148,Y=148)
     SIDDIconPos=(X=31,Y=46)
     
     ReloadButtonText="Reload"
     UnloadButtonText="Unload"
     RepairButtonText="Repair"
     RechargeButtonText="Charge"
     
     Title="S.I.D.D. Management"
     DoneButtonText="|&Done"
     TurnOffButtonText="|&Turn Off"
     ClientWidth=428
     ClientHeight=295
     
     clientTextures(0)=Texture'VMDSIDDManagementBG01'
     clientTextures(1)=Texture'VMDSIDDManagementBG02'
     clientTextures(2)=Texture'VMDSIDDManagementBG03'
     clientTextures(3)=Texture'VMDSIDDManagementBG04'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=2
     TextureCols=2
}
