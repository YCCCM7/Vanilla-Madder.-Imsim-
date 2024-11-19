//=============================================================================
// PersonaInventoryInfoWindow
//=============================================================================
class PersonaInventoryInfoWindow extends PersonaInfoWindow;

var TileWindow winTileAmmo;
var localized String AmmoLabel;
var localized String AmmoRoundsLabel;
var localized String ShowAmmoDescriptionsLabel;

var PersonaAmmoDetailButton      selectedAmmoButton;
var PersonaInfoItemWindow        lastAmmoLoaded;
var PersonaInfoItemWindow	 lastAmmoTypes;
var PersonaNormalLargeTextWindow lastAmmoDescription;

//MADDERS, 5/6/22: New shiat.
var localized string LineFiller,
			StrItemName,
			StrScrapCostCraft, StrScrapGainBreakdown, StrDepleted, StrChemicalsCostCraft, StrChemicalsGainBreakdown,
			StrToolboxRequired, StrRepairBotRequired, StrChemistrySetRequired, StrMedicalBotRequired,
			StrInsufficientTechSkill, StrInsufficientMedicineSkill, StrSizeDesc, SkillLevelNames[4],
			CraftButtonLabel, CraftButtonLabelNull, BreakdownButtonLabel,
			ShowOnlyOwnedItemsLabel, ShowCraftingDescriptionsLabel;

// ----------------------------------------------------------------------
// AddAmmoInfoWindow()
// ----------------------------------------------------------------------

function AddAmmoInfoWindow(DeusExAmmo ammo, bool bShowDescriptions)
{
	local AlignWindow winAmmo;
	local PersonaNormalTextWindow winText;
	local Window winIcon;
	
	if (ammo != None)
	{
		winAmmo = AlignWindow(winTile.NewChild(Class'AlignWindow'));
		winAmmo.SetChildVAlignment(VALIGN_Top);
		winAmmo.SetChildSpacing(4);
		
		// Add icon
		winIcon = winAmmo.NewChild(Class'Window');
		winIcon.SetBackground(ammo.Icon);
		winIcon.SetBackgroundStyle(DSTY_Masked);
		winIcon.SetSize(42, 37);
		
		// Add description
		winText = PersonaNormalTextWindow(winAmmo.NewChild(Class'PersonaNormalTextWindow'));
		winText.SetWordWrap(True);
		winText.SetTextMargins(0, 0);
		winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
		
		winText.AppendText(Ammo.ItemName$CR()$SprintF(ammo.msgInfoRounds, Ammo.AmmoAmount$"/"$Ammo.VMDConfigureMaxAmmo()));
		if (bShowDescriptions)
		{
			winText.AppendText(CR()$""$ammo.description);
		}
	}
	
	AddLine();
}

// ----------------------------------------------------------------------
// AddAmmoCheckbox()
// ----------------------------------------------------------------------

function AddAmmoCheckbox(bool bChecked)
{
	local PersonaCheckboxWindow winCheck;

	winCheck = PersonaCheckboxWindow(winTile.NewChild(Class'PersonaCheckboxWindow'));
	winCheck.SetFont(Font'FontMenuSmall');
	winCheck.SetText(ShowAmmoDescriptionsLabel);
	winCheck.SetToggle(bChecked);
}

// ----------------------------------------------------------------------
// CreateAmmoTileWindow()
// ----------------------------------------------------------------------

function CreateAmmoTileWindow()
{
	local PersonaNormalTextWindow winText;

	if (winTileAmmo == None)
	{
		winTileAmmo = TileWindow(winTile.NewChild(Class'TileWindow'));
		winTileAmmo.SetOrder(ORDER_Right);
		winTileAmmo.SetChildAlignments(HALIGN_Left, VALIGN_Full);
		winTileAmmo.SetWindowAlignments(HALIGN_Full, VALIGN_Top);
		winTileAmmo.MakeWidthsEqual(False);
		winTileAmmo.MakeHeightsEqual(True);
		winTileAmmo.SetMargins(0, 0);
		winTileAmmo.SetMinorSpacing(4);

		winText = PersonaNormalTextWindow(winTileAmmo.NewChild(Class'PersonaNormalTextWindow'));
		winText.SetWidth(70);
		winText.SetTextMargins(0, 6);
		winText.SetTextAlignments(HALIGN_Right, VALIGN_Center);
		winText.SetText(AmmoLabel);
	}
}

// ----------------------------------------------------------------------
// AddAmmo()
// ----------------------------------------------------------------------

function AddAmmo(Class<Ammo> ammo, bool bHasIt, optional int newRounds)
{
	local PersonaAmmoDetailButton ammoButton;

	if (winTileAmmo == None)
		CreateAmmoTileWindow();

	ammoButton = PersonaAmmoDetailButton(winTileAmmo.NewChild(Class'PersonaAmmoDetailButton'));
	ammoButton.SetAmmo(ammo, bHasIt, newRounds);
}

// ----------------------------------------------------------------------
// AddAmmoLoadedItem()
// ----------------------------------------------------------------------

function AddAmmoLoadedItem(String newLabel, String newText)
{
	lastAmmoLoaded = AddInfoItem(newLabel, newText);
}

// ----------------------------------------------------------------------
// UpdateAmmoLoaded()
// ----------------------------------------------------------------------

function UpdateAmmoLoaded(String newText)
{
	if (lastAmmoLoaded != None)
		lastAmmoLoaded.SetItemText(newText);
}

// ----------------------------------------------------------------------
// AddAmmoTypesItem()
// ----------------------------------------------------------------------

function AddAmmoTypesItem(String newLabel, String newText)
{
	lastAmmoTypes = AddInfoItem(newLabel, newText);
}

// ----------------------------------------------------------------------
// UpdateAmmoTypes()
// ----------------------------------------------------------------------

function UpdateAmmoTypes(String newText)
{
	if (lastAmmoTypes != None)
		lastAmmoTypes.SetItemText(newText);
}

// ----------------------------------------------------------------------
// AddAmmoDescription()
// ----------------------------------------------------------------------

function AddAmmoDescription(String newDesc)
{
	lastAmmoDescription = SetText(newDesc);
}

// ----------------------------------------------------------------------
// UpdateAmmoDescription()
// ----------------------------------------------------------------------

function UpdateAmmoDescription(String newDesc)
{
	if (lastAmmoDescription != None)
		lastAmmoDescription.SetText(newDesc);
}

// ----------------------------------------------------------------------
// GetSelectedAmmo()
// ----------------------------------------------------------------------

function Class<Ammo> GetSelectedAmmo()
{
	local Window currentWindow;

	if (selectedAmmoButton != None)	
	{
		return selectedAmmoButton.GetAmmo();
	}
	else
	{
		currentWindow = winTileAmmo.GetTopChild();
		while(currentWindow != None)
		{
			if (PersonaAmmoDetailButton(currentWindow) != None)
			{
				if (PersonaAmmoDetailButton(currentWindow).IsLoaded())
				{
					return PersonaAmmoDetailButton(currentWindow).GetAmmo();
					break;
				}
			}
			currentWindow = currentWindow.GetLowerSibling();
		}
	}

	return None;
}

// ----------------------------------------------------------------------
// SetLoaded()
//
// Loops through all the ammo, setting the background color to green if
// the ammo is loaded, otherwise black.
// ----------------------------------------------------------------------

function SetLoaded(Class<Ammo> ammo)
{
	local Window currentWindow;

	currentWindow = winTileAmmo.GetTopChild();
	while(currentWindow != None)
	{
		if (PersonaAmmoDetailButton(currentWindow) != None)
		{
			PersonaAmmoDetailButton(currentWindow).SetLoaded(currentWindow.GetClientObject() == ammo);
			PersonaAmmoDetailButton(currentWindow).SelectButton(currentWindow.GetClientObject() == ammo);

			// Keep track of the selected button
			if (currentWindow.GetClientObject() == ammo) 
				selectedAmmoButton = PersonaAmmoDetailButton(currentWindow);
		}
		currentWindow = currentWindow.GetLowerSibling();
	}
}

// ----------------------------------------------------------------------
// SelectAmmoButton()
// ----------------------------------------------------------------------

function SelectAmmoButton(PersonaAmmoDetailButton selectedButton)
{
	local Window currentWindow;

	currentWindow = winTileAmmo.GetTopChild();
	while(currentWindow != None)
	{
		if (PersonaAmmoDetailButton(currentWindow) != None)
		{
			PersonaAmmoDetailButton(currentWindow).SetLoaded(selectedButton == currentWindow);
			PersonaAmmoDetailButton(currentWindow).SelectButton(selectedButton == currentWindow);
		}
		currentWindow = currentWindow.GetLowerSibling();
	}

	// Keep track of the selected button
	selectedAmmoButton = selectedButton;
}

// ----------------------------------------------------------------------
// Clear()
// ----------------------------------------------------------------------

function Clear()
{
	Super.Clear();
	winTileAmmo = None;
}

// ----------------------------------------------------------------------
// AddMechanicalCraftingInfoWindow()
// ----------------------------------------------------------------------

function PersonaCheckboxWindow AddMechanicalCheckbox(bool bChecked)
{
	local PersonaCheckboxWindow winCheck;
	
	winCheck = PersonaCheckboxWindow(winTile.NewChild(Class'PersonaCheckboxWindow'));
	winCheck.SetFont(Font'FontMenuSmall');
	winCheck.SetText(ShowOnlyOwnedItemsLabel);
	winCheck.SetToggle(bChecked);
	
	return WinCheck;
}

function AddMechanicalCraftingInfoWindow(class<Inventory> TItem, bool bShowDescriptions, bool bCanBreakdown, bool bCanCraft, bool bMetSkill, bool bMetComplexity, int NeededComplexity)
{
	local AlignWindow TAlign;
	local PersonaNormalTextWindow winText;
	local Window winIcon;
	
	local Texture TTex;
	local int TXSize, TYSize, CPrice, BPrice, CraftPrice, BreakdownGain, GetHeight, TSkill, LineTrack, QuanNeeded, SkillNeeded, FudgeFactor, QuantityOwned, RelevantQuantity;
	local bool bHasTalent;
	
	local VMDNonStaticCraftingFunctions CF;
	local Class<DeusExWeapon> DXW;
	local Class<DeusExPickup> DXP;
	local Class<DeusExAmmo> DXA;
	
	local AlignWindow CraftAlign;
	local VMDCraftingPersonaActionButtonWindowMechanical CraftButton;
	local VMDCraftingPersonaActionButtonWindowMechanicalBreakdown BreakdownButton;
	
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((TItem != None) && (VMP != None) && (VMP.SkillSystem != None) && (VMP.CraftingManager != None) && (VMP.CraftingManager.StatRef != None))
	{
		TAlign = AlignWindow(winTile.NewChild(Class'AlignWindow'));
		TAlign.SetChildVAlignment(VALIGN_Top);
		TAlign.SetChildSpacing(4);
		
		CF = VMP.CraftingManager.StatRef;
		DXA = Class<DeusExAmmo>(TItem);
		DXP = Class<DeusExPickup>(TItem);
		DXW = Class<DeusExWeapon>(TItem);
		TXSize = 42;
		TYSize = 37;
		
		TSkill = VMP.SkillSystem.GetSkillLevel(class'SkillTech');
		bHasTalent = VMP.HasSkillAugment('ElectronicsCrafting');
		
		CPrice = CF.GetMechanicalItemPrice(TItem);
		if ((TItem == class'VMDMEGHPickup') && (VMP.HasSkillAugment('ElectronicsDroneArmor')))
		{
			CPrice *= 1.5;
		}
		
		BPrice = CF.GetMechanicalBreakdownPrice(VMP, TItem);
		CraftPrice = CPrice * CF.GetCraftSkillMult(TSkill, bHasTalent);
		BreakdownGain = BPrice * CF.GetBreakdownSkillMult(TSkill, bHasTalent);
		SkillNeeded = CF.GetMechanicalItemSkillReq(TItem);
		QuantityOwned = CountNumThings(TItem, VMP);
		RelevantQuantity = Max(CF.GetMechanicalItemQuanMade(TItem), CF.GetMechanicalBreakdownQuanNeeded(TItem));
		
		TTex = TItem.Default.Icon;
		
		// Add icon
		winIcon = TAlign.NewChild(Class'Window');
		winIcon.SetBackground(TTex);
		winIcon.SetBackgroundStyle(DSTY_Masked);
		winIcon.SetSize(TXSize, TYSize);
		
		// Add description
		winText = PersonaNormalTextWindow(TAlign.NewChild(Class'PersonaNormalTextWindow'));
		winText.SetWordWrap(True);
		winText.SetTextMargins(0, 0);
		winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
		
		if (DXA == None)
		{
			WinText.AppendText(SprintF(StrItemName, Left(TItem.Default.ItemName, 28), QuantityOwned, RelevantQuantity)$CR()$SprintF(StrSizeDesc, TItem.Default.InvSlotsX, TItem.Default.InvSlotsY)$CR());
			LineTrack = 11;
		}
		else
		{
			WinText.AppendText(SprintF(StrItemName, Left(TItem.Default.ItemName, 28), QuantityOwned, RelevantQuantity)$CR());
		}
		
		VMDInjectLine(WinText, 0, 13+LineTrack, 128);
		WinText.AppendText(CR());
		
		LineTrack += 11;
		if (bCanCraft)
		{
			winText.AppendText(SprintF(StrScrapCostCraft, CraftPrice)$CR());
			LineTrack += 11;
		}
		if (bCanBreakdown)
		{
			if (VMP.LastMechanicalBreakdown ~= string(TItem))
			{
				WinText.AppendText(SprintF(StrScrapGainBreakdown, BreakdownGain)@StrDepleted$CR());	
				LineTrack += 11;
			}
			else
			{
				WinText.AppendText(SprintF(StrScrapGainBreakdown, BreakdownGain)$CR());
			}
			LineTrack += 11;
		}
		
		VMDInjectLine(WinText, 0, 13+LineTrack, 128);
		
		if ((bCanCraft) && (!bMetComplexity || !bMetSkill))
		{
			if (!bMetSkill)
			{
				WinText.AppendText(CR()$SprintF(StrInsufficientTechSkill, SkillLevelNames[SkillNeeded]));
			}
			if (!bMetComplexity)
			{
				if (NeededComplexity == 1)
				{
					WinText.AppendText(CR()$StrToolboxRequired);
				}
				else
				{
					WinText.AppendText(CR()$StrRepairBotRequired);
				}
			}
		}
		else if (bShowDescriptions)
		{
			winText.AppendText(CR()$TItem.Default.Description);
		}
		
		WinText.AppendText(CR()$CR());
		
		FudgeFactor = 42 - TXSize;
		if (bCanCraft)
		{
			CraftButton = VMDCraftingPersonaActionButtonWindowMechanical(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMechanical'));
			CraftButton.SetButtonText(CraftButtonLabel);
			CraftButton.CraftClass = TItem;
			CraftButton.ScrapCost = CraftPrice;
			CraftButton.bMetComplexity = bMetComplexity;
			
			CraftButton.SetPos(FudgeFactor + 0, WinText.Height - 20);
		}
		else
		{
			CraftButton = VMDCraftingPersonaActionButtonWindowMechanical(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMechanical'));
			CraftButton.SetButtonText(CraftButtonLabelNull);
			CraftButton.CraftClass = TItem;
			CraftButton.ScrapCost = 9999;
			CraftButton.bMetComplexity = False;
			
			CraftButton.SetPos(FudgeFactor + 0, WinText.Height - 20);
		}
		
		if (bCanBreakdown)
		{
			BreakdownButton = VMDCraftingPersonaActionButtonWindowMechanicalBreakdown(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMechanicalBreakdown'));
			BreakdownButton.SetButtonText(BreakdownButtonLabel);
			BreakdownButton.BreakdownClass = TItem;
			
			QuanNeeded = CF.GetMechanicalBreakdownQuanNeeded(TItem);
			BreakdownButton.QuantityNeeded = QuanNeeded;
			BreakdownButton.ScrapGain = BreakdownGain;
			
			BreakdownButton.SetPos(FudgeFactor + 80, WinText.Height - 20);
		}
		else
		{
			BreakdownButton = VMDCraftingPersonaActionButtonWindowMechanicalBreakdown(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMechanicalBreakdown'));
			BreakdownButton.SetButtonText(CraftButtonLabelNull);
			BreakdownButton.BreakdownClass = TItem;
			BreakdownButton.QuantityNeeded = 1;
			BreakdownButton.ScrapGain = 9999;
			
			BreakdownButton.SetPos(FudgeFactor + 80, WinText.Height - 20);
		}
	}
	
	AddLine();
}

// ----------------------------------------------------------------------
// AddMedicalCraftingInfoWindow()
// ----------------------------------------------------------------------

function PersonaCheckboxWindow AddMedicalCheckbox(bool bChecked)
{
	local PersonaCheckboxWindow winCheck;
	
	winCheck = PersonaCheckboxWindow(winTile.NewChild(Class'PersonaCheckboxWindow'));
	winCheck.SetFont(Font'FontMenuSmall');
	winCheck.SetText(ShowOnlyOwnedItemsLabel);
	winCheck.SetToggle(bChecked);
	
	return WinCheck;
}

function AddMedicalCraftingInfoWindow(class<Inventory> TItem, bool bShowDescriptions, bool bCanBreakdown, bool bCanCraft, bool bMetSkill, bool bMetComplexity, int NeededComplexity)
{
	local AlignWindow TAlign;
	local PersonaNormalTextWindow winText;
	local Window winIcon;
	
	local Texture TTex;
	local int TXSize, TYSize, CPrice, BPrice, CraftPrice, BreakdownGain, GetHeight, TSkill, LineTrack, QuanNeeded, SkillNeeded, FudgeFactor, QuantityOwned, RelevantQuantity;
	local bool bHasTalent;
	local string DepletionStr;
	
	local VMDNonStaticCraftingFunctions CF;
	local Class<DeusExWeapon> DXW;
	local Class<DeusExPickup> DXP;
	local Class<DeusExAmmo> DXA;
	
	local AlignWindow CraftAlign;
	local VMDCraftingPersonaActionButtonWindowMedical CraftButton;
	local VMDCraftingPersonaActionButtonWindowMedicalBreakdown BreakdownButton;
	
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((TItem != None) && (VMP != None) && (VMP.SkillSystem != None) && (VMP.CraftingManager != None) && (VMP.CraftingManager.StatRef != None))
	{
		TAlign = AlignWindow(winTile.NewChild(Class'AlignWindow'));
		TAlign.SetChildVAlignment(VALIGN_Top);
		TAlign.SetChildSpacing(4);
		
		CF = VMP.CraftingManager.StatRef;
		DXA = Class<DeusExAmmo>(TItem);
		DXP = Class<DeusExPickup>(TItem);
		DXW = Class<DeusExWeapon>(TItem);
		TXSize = 42;
		TYSize = 37;
		
		TSkill = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
		bHasTalent = VMP.HasSkillAugment('MedicineCrafting');
		
		CPrice = CF.GetMedicalItemPrice(TItem);
		BPrice = CF.GetMedicalBreakdownPrice(VMP, TItem);
		CraftPrice = CPrice * CF.GetCraftSkillMult(TSkill, bHasTalent);
		BreakdownGain = BPrice * CF.GetBreakdownSkillMult(TSkill, bHasTalent);
		SkillNeeded = CF.GetMedicalItemSkillReq(TItem);
		QuantityOwned = CountNumThings(TItem, VMP);
		RelevantQuantity = Max(CF.GetMedicalItemQuanMade(TItem), CF.GetMedicalBreakdownQuanNeeded(TItem));
		
		TTex = TItem.Default.Icon;
		
		// Add icon
		winIcon = TAlign.NewChild(Class'Window');
		winIcon.SetBackground(TTex);
		winIcon.SetBackgroundStyle(DSTY_Masked);
		winIcon.SetSize(TXSize, TYSize);
		
		// Add description
		winText = PersonaNormalTextWindow(TAlign.NewChild(Class'PersonaNormalTextWindow'));
		winText.SetWordWrap(True);
		winText.SetTextMargins(0, 0);
		winText.SetTextAlignments(HALIGN_Left, VALIGN_Top);
		
		if (DXA == None)
		{
			WinText.AppendText(SprintF(StrItemName, Left(TItem.Default.ItemName, 28), QuantityOwned, RelevantQuantity)$CR()$SprintF(StrSizeDesc, TItem.Default.InvSlotsX, TItem.Default.InvSlotsY)$CR());
			LineTrack = 11;
		}
		else
		{
			WinText.AppendText(SprintF(StrItemName, Left(TItem.Default.ItemName, 28), QuantityOwned, RelevantQuantity)$CR());
		}
		
		VMDInjectLine(WinText, 0, 13+LineTrack, 128);
		WinText.AppendText(CR());
		
		LineTrack += 11;
		if (bCanCraft)
		{
			winText.AppendText(SprintF(StrChemicalsCostCraft, CraftPrice)$CR());
			LineTrack += 11;
		}
		if (bCanBreakdown)
		{
			if (VMP.LastMedicalBreakdown ~= string(TItem))
			{
				WinText.AppendText(SprintF(StrChemicalsGainBreakdown, BreakdownGain)@StrDepleted$CR());
				LineTrack += 11;
			}
			else
			{
				WinText.AppendText(SprintF(StrChemicalsGainBreakdown, BreakdownGain)$CR());
			}
			LineTrack += 11;
		}
		
		VMDInjectLine(WinText, 0, 13+LineTrack, 128);
		
		if ((bCanCraft) && (!bMetComplexity || !bMetSkill))
		{
			if (!bMetSkill)
			{
				WinText.AppendText(CR()$SprintF(StrInsufficientMedicineSkill, SkillLevelNames[SkillNeeded]));
			}
			if (!bMetComplexity)
			{
				if (NeededComplexity == 1)
				{
					WinText.AppendText(CR()$StrChemistrySetRequired);
				}
				else
				{
					WinText.AppendText(CR()$StrMedicalBotRequired);
				}
			}
		}
		else if (bShowDescriptions)
		{
			winText.AppendText(CR()$TItem.Default.Description);
		}
		
		WinText.AppendText(CR()$CR());
		
		FudgeFactor = 42 - TXSize;
		if (bCanCraft)
		{
			CraftButton = VMDCraftingPersonaActionButtonWindowMedical(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMedical'));
			CraftButton.SetButtonText(CraftButtonLabel);
			CraftButton.CraftClass = TItem;
			CraftButton.ChemicalsCost = CraftPrice;
			CraftButton.bMetComplexity = bMetComplexity;
			
			CraftButton.SetPos(FudgeFactor + 0, WinText.Height - 20);
		}
		else
		{
			CraftButton = VMDCraftingPersonaActionButtonWindowMedical(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMedical'));
			CraftButton.SetButtonText(CraftButtonLabelNull);
			CraftButton.CraftClass = TItem;
			CraftButton.ChemicalsCost = 9999;
			CraftButton.bMetComplexity = False;
			
			CraftButton.SetPos(FudgeFactor + 0, WinText.Height - 20);
		}
		
		if (bCanBreakdown)
		{
			BreakdownButton = VMDCraftingPersonaActionButtonWindowMedicalBreakdown(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMedicalBreakdown'));
			BreakdownButton.SetButtonText(BreakdownButtonLabel);
			BreakdownButton.BreakdownClass = TItem;
			
			QuanNeeded = CF.GetMedicalBreakdownQuanNeeded(TItem);
			BreakdownButton.QuantityNeeded = QuanNeeded;
			BreakdownButton.ChemicalsGain = BreakdownGain;
			
			BreakdownButton.SetPos(FudgeFactor + 80, WinText.Height - 20);
		}
		else
		{
			BreakdownButton = VMDCraftingPersonaActionButtonWindowMedicalBreakdown(WinText.NewChild(Class'VMDCraftingPersonaActionButtonWindowMedicalBreakdown'));
			BreakdownButton.SetButtonText(CraftButtonLabelNull);
			BreakdownButton.BreakdownClass = TItem;
			BreakdownButton.QuantityNeeded = 1;
			BreakdownButton.ChemicalsGain = 9999;
			
			BreakdownButton.SetPos(FudgeFactor + 80, WinText.Height - 20);
		}
	}
	
	AddLine();
}

// ----------------------------------------------------------------------
// VMDInjectLine()
// ----------------------------------------------------------------------

function VMDInjectLine(Window TarWindow, int PlaceX, int PlaceY, int PlaceWidth)
{
	local PersonaInfoLineWindow TLine;
	
	if (TarWindow != None)
	{
		TLine = PersonaInfoLineWindow(TarWindow.NewChild(class'PersonaInfoLineWindow'));
		TLine.SetPos(PlaceX, PlaceY);
		TLine.SetWidth(PlaceWidth);
	}
}

// ----------------------------------------------------------------------
// AddCraftingDescCheckbox()
// ----------------------------------------------------------------------

function AddCraftingDescCheckbox(bool bChecked)
{
	local PersonaCheckboxWindow winCheck;

	winCheck = PersonaCheckboxWindow(winTile.NewChild(Class'PersonaCheckboxWindow'));
	winCheck.SetFont(Font'FontMenuSmall');
	winCheck.SetText(ShowCraftingDescriptionsLabel);
	winCheck.SetToggle(bChecked);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

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

defaultproperties
{
     AmmoLabel="Ammo:"
     AmmoRoundsLabel="Rounds:"
     ShowAmmoDescriptionsLabel="Show Ammo Descriptions"
     
     ShowOnlyOwnedItemsLabel="Only show owned items"
     ShowCraftingDescriptionsLabel="Show Item Descriptions"
     SkillLevelNames(0)="Untrained"
     SkillLevelNames(1)="Trained"
     SkillLevelNames(2)="Advanced"
     SkillLevelNames(3)="Master"
     StrItemName="%s (%d/%d)"
     StrInsufficientTechSkill="Requires %d Hardware skill"
     StrInsufficientMedicineSkill="Requires %d Medicine skill"
     StrScrapCostCraft="Can craft for %d Scrap"
     StrScrapGainBreakdown="Breaks down for %d Scrap"
     StrToolboxRequired="Requires use of toolbox or repair bot"
     StrRepairBotRequired="Requires use of repair bot"
     StrChemicalsCostCraft="Can craft for %d Chemicals"
     StrChemicalsGainBreakdown="Breaks down for %d Chemicals"
     StrChemistrySetRequired="Requires use of chemistry set or medical bot"
     StrMedicalBotRequired="Requires use of medical bot"
     StrDepleted="(Fatigued: -50% gain)"
     StrSizeDesc="Size: (%dx%d)"
     CraftButtonLabel="Craft"
     CraftButtonLabelNull="N/A"
     BreakdownButtonLabel="Breakdown"
}
