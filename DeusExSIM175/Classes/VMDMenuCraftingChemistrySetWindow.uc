//=============================================================================
// VMDMenuChemistrySetWindow
//=============================================================================
class VMDMenuCraftingChemistrySetWindow expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow ExitButton, CraftButton, BreakdownButton;
var localized string ExitButtonText, CraftButtonText, BreakdownButtonText, NotAvailableButtonText;

var TileWindow winTile;
var int CurTileCount;
var VMDMenuCraftingItemTileMedical TileSet[64], SelectedTile;

var VMDBufferPlayer VMP;

var VMDMenuUIInfoWindow WinInfoTitle, WinInfoBody;
var VMDMenuCraftingChoiceCraftQuantity QuantitySlider;

var VMDButtonPos TileWindowPos, TileWindowSize, WinInfoPos[2], WinInfoSize[2], SliderTagSize, QuantitySliderPos, QuantitySliderSize,
			RequirementPos[5], RequirementIconOffset, RequirementTextOffset, RequirementTextOffset2, RequirementSize, RequirementIconSize, RequirementTextSize, RequirementTextExtensionSize;

var bool bHasMedbot, bHasCraft, bCanCraft, bHasBreakdown, bCanBreakdown;

var localized string MsgBotRequired, MsgSkillRequired, MsgAllRequirementsMet, SkillLevelNames[4],
			MsgCannotCraft, MsgCannotBreakdown,
			MsgCraftParamsA, MsgCraftParamsB,
			MsgCraftReqsA, MsgCraftReqsB,
			MsgBreakdownParamsA, MsgBreakdownParamsB,
			MsgXOwned, MsgXOutOfY, MsgBreakdownGain;

var VMDStylizedWindow RequirementBGs[5], RequirementPictures[5];
var MenuUIHelpWindow RequirementLabels[6];

var MedicalBot Medbot;
var VMDChemicals ChemCrammer;

function ImmobilizeMedbot();

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

function TileWindow CreateTileWindow(Window parent)
{
	local TileWindow tileWindow;
	
	// Create Tile Window inside the scroll window
	tileWindow = TileWindow(parent.NewChild(Class'TileWindow'));
	tileWindow.SetFont( class'PersonaEditWindow'.Default.FontText );
	tileWindow.SetOrder(ORDER_Down);
	tileWindow.SetChildAlignments(HALIGN_Full, VALIGN_Top);
	tileWindow.MakeWidthsEqual(False);
	tileWindow.MakeHeightsEqual(False);
	
	return tileWindow;
}

function TileWindow CreateScrollTileWindow(int posX, int posY, int sizeX, int sizeY)
{
	local TileWindow tileWindow;
	local PersonaScrollAreaWindow winScroll;
	
	winScroll = VMDMenuUIScrollAreaWindow(winClient.NewChild(Class'VMDMenuUIScrollAreaWindow'));
	winScroll.SetPos(posX, posY);
	winScroll.SetSize(sizeX, sizeY);
	
	tileWindow = CreateTileWindow(winScroll.clipWindow);
	
	return tileWindow;
}

event InitWindow()
{
	Super.InitWindow();
	
	VMP = VMDBufferPlayer(Player);
	if ((VMP != None) && (MedicalBot(VMP.FrobTarget) != None))
	{
		Medbot = MedicalBot(VMP.FrobTarget);
		bHasMedbot = true;
	}
	
        ExitButton = WinButtonBar.AddButton(ExitButtonText, HALIGN_Left);
        CraftButton = WinButtonBar.AddButton(CraftButtonText, HALIGN_Right);
        BreakdownButton = WinButtonBar.AddButton(BreakdownButtonText, HALIGN_Right);
	CreateInfoWindows();
	CreateSliderWindow();
	
	CreateItemTileWindow();
	PopulateItemsList();
	
	AddTimer(0.5, False,, 'ImmobilizeMedbot');
	AddTimer(0.2, True,, 'UpdateInfo');
}

function CreateItemTileWindow()
{
	local int i;
	
        winTile = CreateScrollTileWindow(TileWindowPos.X, TileWindowPos.Y, TileWindowSize.X, TileWindowSize.Y);
	winTile.SetMinorSpacing(0);
	winTile.SetMargins(0,0);
	winTile.SetOrder(ORDER_Down);
        winTile.SetSensitivity(TRUE);
	
	for (i=0; i<ArrayCount(RequirementBGs); i++)
	{
		RequirementBGs[i] = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		RequirementBGs[i].SetSize(RequirementSize.X, RequirementSize.Y);
		RequirementBGs[i].SetBackground(Texture'PinkMaskTex'); //Texture'VMDToolboxRequirementPortraitBG'
		RequirementBGs[i].SetPos(RequirementPos[i].X, RequirementPos[i].Y);
		RequirementBGs[i].bMenuColors = true;
		RequirementBGs[i].StyleChanged();
		
		RequirementPictures[i] = VMDStylizedWindow(NewChild(class'VMDStylizedWindow'));
		RequirementPictures[i].SetSize(RequirementIconSize.X, RequirementIconSize.Y);
		RequirementPictures[i].SetBackground(Texture'PinkMaskTex');
		RequirementPictures[i].SetBackgroundStyle(DSTY_Masked);
		RequirementPictures[i].SetPos(RequirementPos[i].X+RequirementIconOffset.X, RequirementPos[i].Y+RequirementIconOffset.Y);
		RequirementPictures[i].bBlockTranslucency = true;
		RequirementPictures[i].bMenuColors = true;
		RequirementPictures[i].StyleChanged();
		
		RequirementLabels[i] = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
		RequirementLabels[i].SetSize(RequirementTextSize.X, RequirementTextSize.Y);
		RequirementLabels[i].SetTextAlignments(HALIGN_Center, VALIGN_Top);
		RequirementLabels[i].SetText("");
		RequirementLabels[i].SetPos(RequirementPos[i].X+RequirementTextOffset.X, RequirementPos[i].Y+RequirementTextOffset.Y);
	}
	
	RequirementLabels[5] = MenuUIHelpWindow(NewChild(Class'MenuUIHelpWindow'));
	RequirementLabels[5].SetSize(RequirementTextExtensionSize.X, RequirementTextSize.Y);
	RequirementLabels[5].SetTextAlignments(HALIGN_Center, VALIGN_Top);
	RequirementLabels[5].SetText("");
	RequirementLabels[5].SetPos(RequirementPos[4].X+RequirementTextOffset.X+RequirementTextOffset2.X, RequirementPos[4].Y+RequirementTextOffset.Y+RequirementTextOffset2.Y);
}

function CreateSliderWindow()
{
	QuantitySlider = VMDMenuCraftingChoiceCraftQuantity(WinClient.NewChild(Class'VMDMenuCraftingChoiceCraftQuantity'));
	QuantitySlider.SetPos(QuantitySliderPos.X, QuantitySliderPos.Y);
	
	QuantitySlider.BtnSlider.SetSize(QuantitySliderSize.X+SliderTagSize.X, QuantitySliderSize.Y);
	QuantitySlider.SetSize(QuantitySliderSize.X+SliderTagSize.X, QuantitySliderSize.Y);
	
	QuantitySlider.BtnSlider.SetSelectability(False);
	QuantitySlider.BtnSlider.SetTicks(5, 1, 5);
	QuantitySlider.SetValue(0);
	
	QuantitySlider.SetEnumeration(0, "x1");
	QuantitySlider.SetEnumeration(1, "x2");
	QuantitySlider.SetEnumeration(2, "x3");
	QuantitySlider.SetEnumeration(3, "x4");
	QuantitySlider.SetEnumeration(4, "x5");
}

function CreateInfoWindows()
{
	if (WinClient != None)
	{
		WinInfoTitle = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoTitle.SetPos(WinInfoPos[0].X, WinInfoPos[0].Y);
		WinInfoTitle.SetSize(WinInfoSize[0].X, WinInfoSize[0].Y);
		WinInfoTitle.SetText("");
		
		WinInfoBody = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoBody.SetPos(WinInfoPos[1].X, WinInfoPos[1].Y);
		WinInfoBody.SetSize(WinInfoSize[1].X, WinInfoSize[1].Y);
		WinInfoBody.SetText("");
	}
}


// ----------------------------------------------------------------------
// VANILLA SHIT END!
// ----------------------------------------------------------------------

function SetMedbot(MedicalBot NewBot)
{
	local int i;
	
	if (NewBot == None) return;
	
	Medbot = NewBot;
	bHasMedbot = true;
	
	for (i=0; i<CurTileCount; i++)
	{
		TileSet[i].bHasMedbot = true;
		TileSet[i].RefreshItemInfo();
	}
}

function PopulateItemsList()
{
	local int i;
	local VMDMenuCraftingItemTileMedical TTile;
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TType;
	
	CF = GetCF();
	
	if (CF != None)
	{
		for (i=1; i<ArrayCount(CF.Default.MedicalItemsGlossary); i++)
		{
			TType = CF.GetMedicalItemGlossary(i);
			if (TType == None || !VMP.DiscoveredItem(TType))
			{
				continue;
			}
			TTile = VMDMenuCraftingItemTileMedical(WinTile.NewChild(class'VMDMenuCraftingItemTileMedical'));
			TTile.bHasMedbot = bHasMedbot;
			TTile.SetItem(TType);
			
			TileSet[CurTileCount] = TTile;
			CurTileCount++;
		}
		
		//MADDERS, 4/17/22: Oh right. We already null control in-function. Easy enough.
		SelectTile(TileSet[0]);
	}
	else
	{
		UpdateInfo();
	}
}

function SelectTile(VMDMenuCraftingItemTileMedical TarTile)
{
	if (TarTile == None || TarTile.CurItem == None)
	{
		return;
	}
	
	if ((SelectedTile != None) && (SelectedTile != TarTile))
	{
		SelectedTile.SetHighlight(False);
		QuantitySlider.SetValue(1);
	}
	
	TarTile.SetHighlight(True);
	
	SelectedTile = TarTile;
	UpdateInfo();
}

function UpdateInfo()
{
	local bool bHasTalent;
	
	local int QuanReqA, QuanReqB, QuanReqC, ItemOwnedA, ItemOwnedB, ItemOwnedC, TarItemOwned,
			ChemicalsCost, ChemicalsGain, QuanMult, CraftQuan, BreakdownQuan, ComplexityNeeded, SkillNeeded, SkillLevel;
	
	local float CraftCostTweak, BreakdownGainTweak;
	local string BuildStr[3], BarfStr;
	local Class<Inventory> TarItem, ItemReqA, ItemReqB, ItemReqC;
	
	local VMDMenuCraftingItemTileMedical TarTile;
	local VMDNonStaticCraftingFunctions CF;
	
	TarTile = SelectedTile;
	
	UpdateCanCraft();
	UpdateCanBreakdown();
	
	CF = GetCF();
 	if (CF == None)
 	{
  		Root.PopWindow();
		return;
 	}
	else if ((VMP != None) && (VMP.SkillSystem != None))
	{
		if ((TarTile != None) && (TarTile.CurItem != None))
		{
			TarItem = TarTile.CurItem;
			TarItemOwned = CountNumThings(TarItem);
			
			QuanMult = QuantitySlider.GetValue();
			
			bHasTalent = VMP.HasSkillAugment("MedicineCrafting");
			SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
			if (bHasCraft)
			{
				SkillNeeded = CF.GetMedicalItemSkillReq(TarItem);
				ComplexityNeeded = CF.GetMedicalItemComplexity(TarItem, SkillLevel);
				
				ItemReqA = CF.GetMedicalItemItemReq(TarItem, 0);
				ItemReqB = CF.GetMedicalItemItemReq(TarItem, 1);
				ItemReqC = CF.GetMedicalItemItemReq(TarItem, 2);
				QuanReqA = CF.GetMedicalItemQuanReq(TarItem, 0);
				QuanReqB = CF.GetMedicalItemQuanReq(TarItem, 1);
				QuanReqC = CF.GetMedicalItemQuanReq(TarItem, 2);
				if (ItemReqA != None)
				{
					ItemOwnedA = CountNumThings(ItemReqA);
				}
				if (ItemReqB != None)
				{
					ItemOwnedB = CountNumThings(ItemReqB);
				}
				if (ItemReqC != None)
				{
					ItemOwnedC = CountNumThings(ItemReqC);
				}
				
				CraftCostTweak = CF.GetCraftSkillMult(SkillLevel, bHasTalent);
				ChemicalsCost = CF.GetMedicalItemPrice(TarItem) * CraftCostTweak;
				
				CraftQuan = CF.GetMedicalItemQuanMade(TarItem);
				
				if (ChemicalsCost > 0)
				{
					RequirementBGs[0].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
					RequirementPictures[0].SetBackground(class'VMDChemicals'.Default.Icon);
					RequirementLabels[0].SetText(SprintF(MsgXOutOfY, VMP.CurChemicals, ChemicalsCost*QuanMult));
					
					if (VMP.CurChemicals < ChemicalsCost*QuanMult)
					{
						RequirementPictures[0].bBlockReskin = false;
					}
					else
					{
						RequirementPictures[0].bBlockReskin = true;
					}
					RequirementPictures[0].StyleChanged();
				}
				else
				{
					RequirementBGs[0].SetBackground(Texture'PinkMaskTex');
					RequirementPictures[0].SetBackground(Texture'PinkMaskTex');
					RequirementLabels[0].SetText("");
				}
				
				if (ItemReqA != None)
				{
					RequirementBGs[1].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
					RequirementPictures[1].SetBackground(ItemReqA.Default.Icon);
					RequirementLabels[1].SetText(SprintF(MsgXOutOfY, ItemOwnedA, QuanReqA*QuanMult));
					
					if (ItemOwnedA < QuanReqA*QuanMult)
					{
						RequirementPictures[1].bBlockReskin = false;
					}
					else
					{
						RequirementPictures[1].bBlockReskin = true;
					}
					RequirementPictures[1].StyleChanged();
				}
				else
				{
					RequirementBGs[1].SetBackground(Texture'PinkMaskTex');
					RequirementPictures[1].SetBackground(Texture'PinkMaskTex');
					RequirementLabels[1].SetText("");
				}
				if (ItemReqB != None)
				{
					RequirementBGs[2].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
					RequirementPictures[2].SetBackground(ItemReqB.Default.Icon);
					RequirementLabels[2].SetText(SprintF(MsgXOutOfY, ItemOwnedB, QuanReqB*QuanMult));
					
					if (ItemOwnedB < QuanReqB*QuanMult)
					{
						RequirementPictures[2].bBlockReskin = false;
					}
					else
					{
						RequirementPictures[2].bBlockReskin = true;
					}
					RequirementPictures[2].StyleChanged();
				}
				else
				{
					RequirementBGs[2].SetBackground(Texture'PinkMaskTex');
					RequirementPictures[2].SetBackground(Texture'PinkMaskTex');
					RequirementLabels[2].SetText("");
				}
				if (ItemReqC != None)
				{
					RequirementBGs[3].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
					RequirementPictures[3].SetBackground(ItemReqC.Default.Icon);
					RequirementLabels[3].SetText(SprintF(MsgXOutOfY, ItemOwnedC, QuanReqC*QuanMult));
					
					if (ItemOwnedC < QuanReqC*QuanMult)
					{
						RequirementPictures[3].bBlockReskin = false;
					}
					else
					{
						RequirementPictures[3].bBlockReskin = true;
					}
					RequirementPictures[3].StyleChanged();
				}
				else
				{
					RequirementBGs[3].SetBackground(Texture'PinkMaskTex');
					RequirementPictures[3].SetBackground(Texture'PinkMaskTex');
					RequirementLabels[3].SetText("");
				}
			}
			else
			{
				//RequirementBGs[0].SetBackground(Texture'PinkMaskTex');
				//RequirementPictures[0].SetBackground(Texture'PinkMaskTex');
				RequirementBGs[0].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
				RequirementPictures[0].SetBackground(class'VMDChemicals'.Default.Icon);
				RequirementLabels[0].SetText(string(VMP.CurChemicals));
				
				RequirementBGs[1].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
				if (ItemReqA != None)
				{
					RequirementPictures[1].SetBackground(ItemReqA.Default.Icon);
				}
				RequirementBGs[1].SetBackground(Texture'PinkMaskTex');
				RequirementPictures[1].SetBackground(Texture'PinkMaskTex');
				RequirementBGs[2].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
				if (ItemReqB != None)
				{
					RequirementPictures[2].SetBackground(ItemReqB.Default.Icon);
				}
				RequirementBGs[2].SetBackground(Texture'PinkMaskTex');
				RequirementPictures[2].SetBackground(Texture'PinkMaskTex');
				RequirementBGs[3].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
				if (ItemReqC != None)
				{
					RequirementPictures[3].SetBackground(ItemReqC.Default.Icon);
				}
				RequirementBGs[3].SetBackground(Texture'PinkMaskTex');
				RequirementPictures[3].SetBackground(Texture'PinkMaskTex');
				
				//RequirementLabels[0].SetText("");
				RequirementLabels[1].SetText("");
				RequirementLabels[2].SetText("");
				RequirementLabels[3].SetText("");
			}
			if (bHasBreakdown)
			{
				BreakdownGainTweak = CF.GetBreakdownSkillMult(SkillLevel, bHasTalent);
				ChemicalsGain = CF.GetMedicalBreakdownPrice(TarItem) * BreakdownGainTweak;
				
				BreakdownQuan = CF.GetMedicalBreakdownQuanNeeded(TarItem);
				
				RequirementLabels[5].SetText(SprintF(MsgBreakdownGain, ChemicalsGain*QuanMult));
				RequirementBGs[4].SetSize(RequirementTextExtensionSize.X, RequirementSize.Y+RequirementTextExtensionSize.Y); 
			}
			else
			{
				RequirementLabels[5].SetText("");
				RequirementBGs[4].SetSize(RequirementSize.X, RequirementSize.Y);
			}
			
			RequirementBGs[4].SetBackground(Texture'VMDToolboxRequirementPortraitBG');
			RequirementPictures[4].SetBackground(TarItem.Default.Icon);
			
			if ((bHasBreakdown) && (TarItemOwned < BreakdownQuan))
			{
				RequirementPictures[4].bBlockReskin = false;
			}
			else
			{
				RequirementPictures[4].bBlockReskin = true;
			}
			RequirementPictures[4].StyleChanged();
			
			RequirementLabels[4].SetText(SprintF(MsgXOwned, TarItemOwned));
			
			BarfStr = CR()$CR();
			
			BuildStr[0] = TarItem.Default.ItemName;
			WinInfoTitle.Clear();
			WinInfoTitle.SetTitle(BuildStr[0]);
			
			if (SkillNeeded > SkillLevel)
			{
				BuildStr[1] = BuildStr[1]$SprintF(MsgSkillRequired, SkillLevelNames[SkillNeeded])$CR();
			}
			else
			{
				BuildStr[1] = BuildStr[1]$CR();
			}
			if (ComplexityNeeded > 1+int(bHasMedbot))
			{
				BuildStr[1] = BuildStr[1]$MsgBotRequired$CR();
			}
			else
			{
				BuildStr[1] = BuildStr[1]$CR();
			}
			
			if (BuildStr[1] == BarfStr)
			{
				BuildStr[1] = MsgAllRequirementsMet$BuildStr[1];
			}
			BuildStr[1] = BuildStr[1]$CR();
			
			if (bHasCraft)
			{
				if (QuanMult > 1)
				{
					BuildStr[2] = SprintF(MsgCraftParamsA, CraftQuan, ChemicalsCost)$SprintF(MsgCraftParamsB, QuanMult, CraftQuan*QuanMult, ChemicalsCost*QuanMult);
				}
				else
				{
					BuildStr[2] = SprintF(MsgCraftParamsA, CraftQuan, ChemicalsCost);
				}
				BuildStr[1] = BuildStr[1]$BuildStr[2]$CR();
				
				BuildStr[2] = "";
				if (ItemReqA != None)
				{
					BuildStr[2] = BuildStr[2]$SprintF(MsgCraftReqsA, ItemReqA.Default.ItemName, QuanReqA);
				}
				if (ItemReqB != None)
				{
					if (ItemReqA != None)
					{
						BuildStr[2] = BuildStr[2]$", ";
					}
					BuildStr[2] = BuildStr[2]$SprintF(MsgCraftReqsA, ItemReqB.Default.ItemName, QuanReqB);
				}
				if (ItemReqC != None)
				{
					if (ItemReqA != None || ItemReqB != None)
					{
						BuildStr[2] = BuildStr[2]$", ";
					}
					BuildStr[2] = BuildStr[2]$SprintF(MsgCraftReqsA, ItemReqC.Default.ItemName, QuanReqC);
				}
				BuildStr[1] = BuildStr[1]$BuildStr[2]$CR();
				
				if (QuanMult > 1)
				{
					BuildStr[2] = "";
					if (ItemReqA != None)
					{
						BuildStr[2] = BuildStr[2]$SprintF(MsgCraftReqsB, QuanMult)$SprintF(MsgCraftReqsA, ItemReqA.Default.ItemName, QuanReqA*QuanMult);
					}
					if (ItemReqB != None)
					{
						if (ItemReqA != None)
						{
							BuildStr[2] = BuildStr[2]$", ";
						}
						BuildStr[2] = BuildStr[2]$SprintF(MsgCraftReqsA, ItemReqB.Default.ItemName, QuanReqB*QuanMult);
					}
					if (ItemReqC != None)
					{
						if (ItemReqA != None || ItemReqB != None)
						{
							BuildStr[2] = BuildStr[2]$", ";
						}
						BuildStr[2] = BuildStr[2]$SprintF(MsgCraftReqsA, ItemReqC.Default.ItemName, QuanReqC*QuanMult);
					}
					BuildStr[1] = BuildStr[1]$BuildStr[2]$CR();
				}
				else
				{
					BuildStr[1] = BuildStr[1]$CR();
				}
			}
			else
			{
				BuildStr[1] = BuildStr[1]$MsgCannotCraft$CR()$CR()$CR();
			}
			BuildStr[1] = BuildStr[1]$CR();
			
			if (bHasBreakdown)
			{
				if (QuanMult > 1)
				{
					BuildStr[2] = SprintF(MsgBreakdownParamsA, BreakdownQuan, ChemicalsGain)$SprintF(MsgBreakdownParamsB, QuanMult, BreakdownQuan*QuanMult, ChemicalsGain*QuanMult);
				}
				else
				{
					BuildStr[2] = SprintF(MsgBreakdownParamsA, BreakdownQuan, ChemicalsGain);
				}
				BuildStr[1] = BuildStr[1]$BuildStr[2];
			}
			else
			{
				BuildStr[1] = BuildStr[1]$MsgCannotBreakDown;
			}
			BuildStr[1] = BuildStr[1]$CR();
			
			BuildStr[1] = BuildStr[1]$CR()$TarItem.Default.Description;
			WinInfoBody.Clear();
			WinInfoBody.SetText(BuildStr[1]);
		}
	}
	
	CraftButton.SetSensitivity(True);
	CraftButton.SetButtonText(CraftButtonText);
	if (!bHasCraft)
	{
		CraftButton.SetButtonText(NotAvailableButtonText);
	}
	if (!bCanCraft)
	{
		CraftButton.SetSensitivity(False);
	}
	
	BreakdownButton.SetSensitivity(True);
	BreakdownButton.SetButtonText(BreakdownButtonText);
	if (!bHasBreakdown)
	{
		BreakdownButton.SetButtonText(NotAvailableButtonText);
	}
	if (!bCanBreakdown)
	{
		BreakdownButton.SetSensitivity(False);
	}
}

function UpdateHasCraft()
{
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TItem;
	
	bHasCraft = False;
	
	CF = GetCF();
	if ((SelectedTile != None) && (SelectedTile.CurItem != None) && (CF != None))
	{
		TItem = SelectedTile.CurItem;
		
		bHasCraft = (CF.GetMedicalItemArray(TItem) > -1);
	}
}

function UpdateHasBreakdown()
{
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TItem;
	
	bHasBreakdown = False;
	
	CF = GetCF();
	if ((SelectedTile != None) && (SelectedTile.CurItem != None) && (CF != None))
	{
		TItem = SelectedTile.CurItem;
		
		bHasBreakdown = (CF.GetMedicalBreakdownArray(TItem) > -1);
	}
}

function UpdateCanCraft()
{
	local bool bHasTalent;
	local int ChemicalsReq, QuanReqA, QuanReqB, QuanReqC, QuanMult, SkillLevel, SkillNeeded, ComplexityNeeded;
	local float CraftCostTweak;
	
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TItem, ReqA, ReqB, ReqC;
	
	UpdateHasCraft();
	
	bCanCraft = False;
	
	CF = GetCF();
	if ((bHasCraft) && (SelectedTile != None) && (SelectedTile.CurItem != None))
	{
		TItem = SelectedTile.CurItem;
		
		bHasTalent = VMP.HasSkillAugment("MedicineCrafting");
		SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
		
		SkillNeeded = CF.GetMedicalItemSkillReq(TItem);
		ComplexityNeeded = CF.GetMedicalItemComplexity(TItem, SkillLevel);
		
		CraftCostTweak = CF.GetCraftSkillMult(SkillLevel, bHasTalent);
		
		ReqA = CF.GetMedicalItemItemReq(TItem, 0);
		ReqB = CF.GetMedicalItemItemReq(TItem, 1);
		ReqC = CF.GetMedicalItemItemReq(TItem, 2);
		
		QuanMult = QuantitySlider.GetValue();
		
		ChemicalsReq = CF.GetMedicalItemPrice(TItem) * CraftCostTweak * QuanMult;
		QuanReqA = CF.GetMedicalItemQuanReq(TItem, 0) * QuanMult;
		QuanReqB = CF.GetMedicalItemQuanReq(TItem, 1) * QuanMult;
		QuanReqC = CF.GetMedicalItemQuanReq(TItem, 2) * QuanMult;
		
		if ((ComplexityNeeded < 2 || bHasMedbot) && (SkillLevel >= SkillNeeded) && (VMP.CurChemicals >= ChemicalsReq) && (ExpendResource(ReqA, QuanReqA, true)) && (ExpendResource(ReqB, QuanReqB, true)) && (ExpendResource(ReqC, QuanReqC, true)))
		{
			bCanCraft = true;
		}
	}
}

function UpdateCanBreakdown()
{
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TItem, ReqA;
	local int QuanReqA, QuanMult;
	
	UpdateHasBreakdown();
	
	bCanBreakdown = False;
	
	CF = GetCF();
	if ((bHasBreakdown) && (SelectedTile != None) && (SelectedTile.CurItem != None) && (CF != None) && (VMP != None))
	{
		TItem = SelectedTile.CurItem;
		
		ReqA = TItem;
		
		QuanMult = QuantitySlider.GetValue();
		
		QuanReqA = CF.GetMedicalBreakdownQuanNeeded(TItem) * QuanMult;
		
		if (ExpendResource(ReqA, QuanReqA, true))
		{
			bCanBreakdown = true;
		}
	}
}

function CraftCurrentItem()
{
	local bool bHasTalent;
	local int TarItemOwned, SkillLevel, SkillNeeded, ComplexityNeeded, QuanReqA, QuanReqB, QuanReqC, QuanMult, ChemicalsCost, CraftQuan, i;
	local float CraftCostTweak;
	
	local Inventory TItem;
	local VMDNonStaticCraftingFunctions CF;	
	local class<Inventory> TarItem, ItemReqA, ItemReqB, ItemReqC;
	
	UpdateCanCraft();
	
	CF = GetCF();
	if ((bCanCraft) && (CF != None) && (SelectedTile != None) && (SelectedTile.CurItem != None) && (VMP.SkillSystem != None))
	{
		TarItem = SelectedTile.CurItem;
		TarItemOwned = CountNumThings(TarItem);
		
		QuanMult = QuantitySlider.GetValue();
		
		bHasTalent = VMP.HasSkillAugment("MedicineCrafting");
		SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
		
		SkillNeeded = CF.GetMedicalItemSkillReq(TarItem);
		ComplexityNeeded = CF.GetMedicalItemComplexity(TarItem, SkillLevel);
		
		ItemReqA = CF.GetMedicalItemItemReq(TarItem, 0);
		ItemReqB = CF.GetMedicalItemItemReq(TarItem, 1);
		ItemReqC = CF.GetMedicalItemItemReq(TarItem, 2);
		QuanReqA = CF.GetMedicalItemQuanReq(TarItem, 0);
		QuanReqB = CF.GetMedicalItemQuanReq(TarItem, 1);
		QuanReqC = CF.GetMedicalItemQuanReq(TarItem, 2);
		
		CraftCostTweak = CF.GetCraftSkillMult(SkillLevel, bHasTalent);
		ChemicalsCost = CF.GetMedicalItemPrice(TarItem) * CraftCostTweak;
		
		CraftQuan = CF.GetMedicalItemQuanMade(TarItem);
		
		if (VMP.bUseInstantCrafting || bHasMedbot)
		{
			TItem = VMP.Spawn(TarItem);
			if (TItem != None)
			{
				ExpendResource(ItemReqA, QuanReqA*QuanMult, false);
				ExpendResource(ItemReqB, QuanReqB*QuanMult, false);
				ExpendResource(ItemReqC, QuanReqC*QuanMult, false);
				VMP.CurChemicals -= ChemicalsCost * QuanMult;
				
				if (DeusExPickup(TItem) != None)
				{
					if (DeusExPickup(TItem).bCanHaveMultipleCopies)
					{
						DeusExPickup(TItem).NumCopies = CraftQuan * QuanMult;
					}
				}
				else if (DeusExAmmo(TItem) != None)
				{
					DeusExAmmo(TItem).AmmoAmount = CraftQuan * QuanMult;
				}
				else if ((DeusExWeapon(TItem) != None) && (DeusExWeapon(TItem).AmmoType != class'AmmoNone'))
				{
					DeusExWeapon(TItem).PickupAmmoCount = CraftQuan * QuanMult;
				}
				
				if (CraftQuan*QuanMult > 1)
				{
					if ((DeusExWeapon(TItem) != None && DeusExWeapon(TItem).AmmoName == class'AmmoNone')  || (DeusExPickup(TItem) != None && !DeusExPickup(TItem).bCanHaveMultipleCopies))
					{
						for(i=1; i<CraftQuan*QuanMult; i++)
						{
							VMP.FrobTarget = TItem;
							VMP.ParseRightClick();
							
							TItem = VMP.Spawn(TarItem);
						}
					}
				}
				
				TItem.SetPropertyText("bItemRefusalOverride", "true");
				
				VMP.FrobTarget = TItem;
				VMP.ParseRightClick();
				
				RefreshItemTiles();
			}
		}
		else
		{
			VMP.VMDCraftingStartCrafting(TarItem, true, (ComplexityNeeded > 0), QuanMult);
			AddTimer(0.1, False,, 'DoPop');
		}
	}
}

function BreakdownCurrentItem()
{
	local bool bHasTalent;
	local int SkillLevel, SkillNeeded, QuanMult, ChemicalsGain, BreakdownQuan, AmountNotAdded;
	local float BreakdownGainTweak;
	
	local VMDNonStaticCraftingFunctions CF;	
	local class<Inventory> TarItem, ItemReqA, ItemReqB, ItemReqC;
	
	UpdateCanBreakdown();
	
	CF = GetCF();
	if ((bCanBreakdown) && (CF != None) && (SelectedTile != None) && (SelectedTile.CurItem != None) && (VMP.SkillSystem != None))
	{
		TarItem = SelectedTile.CurItem;
		
		QuanMult = QuantitySlider.GetValue();
		
		bHasTalent = VMP.HasSkillAugment("MedicineCrafting");
		SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
		
		BreakdownGainTweak = CF.GetBreakdownSkillMult(SkillLevel, bHasTalent);
		ChemicalsGain = CF.GetMedicalBreakdownPrice(TarItem) * BreakdownGainTweak;
		
		BreakdownQuan = CF.GetMedicalBreakdownQuanNeeded(TarItem);
		
		if (VMP.bUseInstantCrafting || bHasMedbot)
		{
			ExpendResource(TarItem, BreakdownQuan*QuanMult, false);
			
			AmountNotAdded = (ChemicalsGain*QuanMult) - (VMP.MaxChemicals - VMP.CurChemicals);
			if (AmountNotAdded > 0)
			{
				if (ChemCrammer != None)
				{
					ChemCrammer.NumCopies += AmountNotAdded;
					ChemCrammer.UpdateModel();
				}
				else
				{
					ChemCrammer = VMP.Spawn(class'VMDChemicals',,, VMP.Location, VMP.Rotation);
					if (ChemCrammer != None)
					{
						ChemCrammer.NumCopies = AmountNotAdded;
						ChemCrammer.UpdateModel();
					}
				}
			}
			VMP.AddChemicals(ChemicalsGain*QuanMult, false);
			RefreshItemTiles();
		}
		else
		{
			VMP.VMDCraftingStartBreakdown(TarItem, BreakdownQuan, ChemicalsGain, true, false, QuanMult);
			AddTimer(0.1, False,, 'DoPop');
		}
	}
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local VMDMenuCraftingItemTileMedical TTile;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	switch(ButtonPressed)
	{
		case ExitButton:
			Root.PopWindow();
			bHandled = True;
		break;
		case CraftButton:
			CraftCurrentItem();
			bHandled = True;
		break;
		case BreakdownButton:
			BreakdownCurrentItem();
			bHandled = True;
		break;
		default:
			bHandled = False;
			TTile = VMDMenuCraftingItemTileMedical(ButtonPressed);
		break;
	}
	
	if (TTile != None)
	{
		SelectTile(TTile);
		bHandled = True;
	}
	
	return bHandled;
}

function VMDNonStaticCraftingFunctions GetCF()
{
	if ((VMP != None) && (VMP.CraftingManager != None) && (VMP.CraftingManager.StatRef != None))
	{
		return VMP.CraftingManager.StatRef;
	}
	
	return None;
}

// ----------------------------------------------------------------------
// ExpendResource()
// ----------------------------------------------------------------------

function bool ExpendResource(class<Inventory> TarResource, int UseQuan, bool bFakeTest)
{
	local Inventory TFind, TInv;
	local DeusExAmmo DXA, TAmmo;
	local DeusExWeapon DXW;
	local DeusExPickup DXP;
	local int i;
	
	if ((VMP != None) && (TarResource != None))
	{
		TFind = VMP.FindInventoryType(TarResource);
		if (TFind == None) return false;
		
		DXA = DeusExAmmo(TFind);
		DXW = DeusExWeapon(TFind);
		DXP = DeusExPickup(TFind);
		if (UseQuan < 2 || DXP == None || DXP.bCanHaveMultipleCopies)
		{
			if (DXA != None)
			{
				if (DXA.AmmoAmount >= UseQuan)
				{
					if (!bFakeTest)
					{
						DXA.AmmoAmount -= UseQuan;
					}
					return true;
				}
				else
				{
					return false;
				}
			}
			if ((DXW != None) && (DeusExAmmo(DXW.AmmoType) != None))
			{
				TAmmo = DeusExAmmo(DXW.AmmoType);
				if (AmmoNone(TAmmo) != None || !DXW.bHandToHand)
				{
					if (CountNumWeapons(DXW.Class, VMP.Inventory) >= UseQuan)
					{
						if (!bFakeTest)
						{
							for (i=0; i<UseQuan; i++)
							{
								DXW = DeusExWeapon(VMP.FindInventoryType(TarResource));
								if (DXW != None)
								{
									DXW.Destroy();
								}
								else
								{
									Log("WARNING: Could not find promised number of weapon types:"@TarResource);
									return false;
								}
							}
						}
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					if ((TAmmo != None) && (TAmmo.AmmoAmount >= UseQuan))
					{
						if (!bFakeTest)
						{
							TAmmo.AmmoAmount -= UseQuan;
							if (TAmmo.AmmoAmount <= 0)
							{
								DXW.Destroy();
							}
							else
							{
								VMP.UpdateBeltText(DXW);
							}
						}
						return true;
					}
					else
					{
						return false;
					}
				}
			}
			if (DXP != None)
			{
				if (DXP.NumCopies >= UseQuan || UseQuan < 2)
				{
					if (!bFakeTest)
					{
						DXP.NumCopies -= UseQuan;
						if (DXP.NumCopies <= 0)
						{
							DXP.Destroy();
						}
						else
						{
							VMP.UpdateBeltText(DXP);
						}
					}
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		else
		{
			if (CountNumPickups(DXP.Class, VMP.Inventory) >= UseQuan)
			{
				if (!bFakeTest)
				{
					for (i=0; i<UseQuan; i++)
					{
						DXP = DeusExPickup(VMP.FindInventoryType(TarResource));
						if (DXP != None)
						{
							DXP.Destroy();
						}
						else
						{
							Log("WARNING: Could not find promised number of pickup types:"@TarResource);
							return false;
						}
					}
				}
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	return true;
}

function int CountNumThings(class<Inventory> CheckClass)
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

function RefreshItemTiles()
{
	local int i;
	
	for (i=0; i<ArrayCount(TileSet); i++)
	{
		if (TileSet[i] != None)
		{
			TileSet[i].RefreshItemInfo();
		}
	}
}

function DoPop()
{
	Root.PopWindow();
}

defaultproperties
{
     MsgBotRequired="Medical Bot Required"
     MsgSkillRequired="%d Skill Required"
     MsgAllRequirementsMet="Skill and workspace requirements ARE met"
     SkillLevelNames(0)="Untrained"
     SkillLevelNames(1)="Trained"
     SkillLevelNames(2)="Advanced"
     SkillLevelNames(3)="Master"
     MsgCannotCraft="This item cannot be crafted"
     MsgCannotBreakdown="This item cannot be broken down"
     MsgCraftParamsA="Crafting: (%d Count) -%d Chemicals"
     MsgCraftParamsB=", x%d = (%d Count) -%d Chemicals"
     MsgCraftReqsA="%s (%d)"
     MsgCraftReqsB="x%d = "
     MsgBreakdownParamsA="Break down: (%d Count) +%d Chemicals"
     MsgBreakdownParamsB=", x%d = (%d Count) +%d Chemicals"
     MsgXOwned="%d Owned"
     MsgXOutOfY="%d/%d"
     MsgBreakdownGain="+%d Return"
     
     TileWindowPos=(X=18,Y=2)
     TileWindowSize=(X=274,Y=444)
     
     WinInfoPos(0)=(X=325,Y=9)
     WinInfoSize(0)=(X=429,Y=40)
     WinInfoPos(1)=(X=325,Y=10)
     WinInfoSize(1)=(X=429,Y=196)
     
     SliderTagSize=(X=67,Y=0)
     QuantitySliderPos=(X=335,Y=231)
     QuantitySliderSize=(X=179,Y=40)
     
     RequirementPos(0)=(X=323,Y=325)
     RequirementPos(1)=(X=393,Y=325)
     RequirementPos(2)=(X=463,Y=325)
     RequirementPos(3)=(X=533,Y=325)
     RequirementPos(4)=(X=597,Y=256)
     RequirementIconOffset=(X=18,Y=2)
     RequirementTextOffset=(X=2,Y=50)
     RequirementTextOffset2=(X=0,Y=16)
     RequirementSize=(X=78,Y=62)
     RequirementIconSize=(X=42,Y=42)
     RequirementTextSize=(X=74,Y=12)
     RequirementTextExtensionSize=(X=78,Y=16)
     
     Title="Medical Crafting"
     ExitButtonText="|&Cancel"
     CraftButtonText="C|&raft"
     BreakdownButtonText="|&Break Down"
     NotAvailableButtonText="N/A"
     ClientWidth=768
     ClientHeight=448
     
     clientTextures(0)=Texture'VMDToolboxListWindowBG01'
     clientTextures(1)=Texture'VMDToolboxListWindowBG02'
     clientTextures(2)=Texture'VMDToolboxListWindowBG03'
     clientTextures(3)=Texture'VMDToolboxListWindowBG04'
     clientTextures(4)=Texture'VMDToolboxListWindowBG05'
     clientTextures(5)=Texture'VMDToolboxListWindowBG06'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=2
     TextureCols=3
}
