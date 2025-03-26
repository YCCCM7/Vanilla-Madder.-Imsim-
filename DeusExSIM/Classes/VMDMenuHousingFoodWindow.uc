//=============================================================================
// VMDMenuHousingFoodWindow
// Let us select some foods.
//=============================================================================
class VMDMenuHousingFoodWindow expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow ExitButton, LinkButton;
var localized string ExitButtonText, LinkButtonText;

var TileWindow winTile;
var int CurTileCount;
var VMDMenuHousingFoodTile TileSet[64], SelectedTile;

var class<Inventory> OriginalSummonCode, CurSummonCode;
var string OriginalPropertyName, OriginalPropertyValue, CurPropertyName, CurPropertyValue;
var int TargetIndex;

var VMDFoodWarp TargetWarp;
var DeusExPlayer WindowPlayer;

var localized string StrItemNameVariety, StrCreditsCost, StrCreditsLeft, StrMaxUnits;

var VMDMenuUIInfoWindow WinInfoTitle, WinInfoBody;
var VMDMenuHousingChoiceFoodVariety VarietySlider;

var VMDButtonPos TileWindowPos, TileWindowSize, WinInfoPos[2], WinInfoSize[2], VarietySliderPos, VarietySliderSize;

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
	
        ExitButton = WinButtonBar.AddButton(ExitButtonText, HALIGN_Left);
        LinkButton = WinButtonBar.AddButton(LinkButtonText, HALIGN_Right);
	CreateInfoWindows();
	CreateSliderWindow();
	CreateItemTileWindow();
	
	AddTimer(0.2, True,, 'UpdateInfo');
}

function CreateItemTileWindow()
{
        winTile = CreateScrollTileWindow(TileWindowPos.X, TileWindowPos.Y, TileWindowSize.X, TileWindowSize.Y);
	winTile.SetMinorSpacing(0);
	winTile.SetMargins(0,0);
	winTile.SetOrder(ORDER_Down);
        winTile.SetSensitivity(TRUE);
}

function CreateSliderWindow()
{
	VarietySlider = VMDMenuHousingChoiceFoodVariety(WinClient.NewChild(Class'VMDMenuHousingChoiceFoodVariety'));
	VarietySlider.SetPos(VarietySliderPos.X+256, VarietySliderPos.Y);
	
	VarietySlider.BtnSlider.SetSize(VarietySliderSize.X, VarietySliderSize.Y);
	VarietySlider.SetSize(VarietySliderSize.X, VarietySliderSize.Y);
	
	VarietySlider.BtnSlider.SetSelectability(False);
	VarietySlider.BtnSlider.SetTicks(2, 0, 1);
	VarietySlider.SetValue(0);
}

function CreateInfoWindows()
{
	if (WinClient != None)
	{
		WinInfoTitle = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoTitle.SetPos(WinInfoPos[0].X, WinInfoPos[0].Y);
		WinInfoTitle.SetSize(WinInfoSize[0].X, WinInfoSize[0].Y);
		WinInfoTitle.SetText("bahfuqhbbv");
		
		WinInfoBody = VMDMenuUIInfoWindow(winClient.NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoBody.SetPos(WinInfoPos[1].X, WinInfoPos[1].Y);
		WinInfoBody.SetSize(WinInfoSize[1].X, WinInfoSize[1].Y);
		WinInfoBody.SetText("???");
	}
}

event DestroyWindow()
{
	if ((TargetWarp != None) && (!TargetWarp.bDeleteMe))
	{
		TargetWarp.bHasWindow = false;
	}
}

// ----------------------------------------------------------------------
// VANILLA SHIT END!
// ----------------------------------------------------------------------

function class<Inventory> GetValidatedSummonFromIndex(int TarIndex)
{
	if (TargetWarp != None)
	{
		return TargetWarp.GetValidatedSummonFromIndex(TarIndex); //ValidatedSummonCodeList[TarIndex];
	}
}

function PopulateItemsList()
{
	local VMDMenuHousingFoodTile TTile;
	local int i;
	
	if ((TargetWarp != None) && (TargetWarp.NumSummonCodes > 0))
	{
		for (i=0; i<TargetWarp.NumSummonCodes; i++)
		{
			if (GetValidatedSummonFromIndex(i) == None)
			{
				Log("WARNING!"@TargetWarp@"attempted to stock items! Index"@i@"was BLANK!");
				continue;
			}
			TTile = VMDMenuHousingFoodTile(WinTile.NewChild(class'VMDMenuHousingFoodTile'));
			TTile.SetItem(GetValidatedSummonFromIndex(i));
			TTile.FoodWindow = Self;
			
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

function SelectTile(VMDMenuHousingFoodTile TarTile)
{
	if (TarTile == None || TarTile.CurItem == None)
	{
		return;
	}
	
	if ((SelectedTile != None) && (SelectedTile != TarTile))
	{
		SelectedTile.SetHighlight(False);
		VarietySlider.SetValue(0);
	}
	
	TarTile.SetHighlight(True);
	
	SelectedTile = TarTile;
	UpdateInfo();
}

function UpdateInfo()
{
	local string BuildStr[2];
	local Class<Inventory> TarItem;
	local VMDMenuHousingFoodTile TarTile;
	local int TVarieties, PriceNeeded, i;
	
	TarTile = SelectedTile;
	
 	if (TargetWarp == None || TargetWarp.bDeleteMe || !TargetWarp.bHasWindow)
 	{
  		Root.PopWindow();
		return;
 	}
	else
	{
		if ((TarTile != None) && (TarTile.CurItem != None))
		{
			TarItem = TarTile.CurItem;
			
			BuildStr[0] = SprintF(StrItemNameVariety, TarItem.Default.ItemName, DeriveItemVariety(TarItem.Name, VarietySlider.GetValue()));
			WinInfoTitle.Clear();
			WinInfoTitle.SetTitle(BuildStr[0]);
			
			if ((class<DeusExPickup>(TarItem) != None) && (class<DeusExPickup>(TarItem).Default.bCanHaveMultipleCopies))
			{
				BuildStr[1] = SprintF(StrMaxUnits, Max(1, class<DeusExPickup>(TarItem).Default.MaxCopies));
			}
			else
			{
				BuildStr[1] = SprintF(StrMaxUnits, 1);
			}
			BuildStr[1] = BuildStr[1]$CR()$SprintF(StrCreditsCost, class'VMDStaticHousingFunctions'.Static.GetFoodPrice(TarItem.Name));
			BuildStr[1] = BuildStr[1]$CR()$SprintF(StrCreditsLeft, WindowPlayer.Credits);
			
			BuildStr[1] = BuildStr[1]$CR()$CR()$TarItem.Default.Description;
			WinInfoBody.Clear();
			WinInfoBody.SetText(BuildStr[1]);
			
			TVarieties = class'VMDStaticHousingFunctions'.Static.GetFoodVarieties(TarTile.CurItem.Name);
			if (TVarieties < 2)
			{
				VarietySlider.SetPos(VarietySliderPos.X+256, VarietySliderPos.Y);
				VarietySlider.BtnSlider.SetSelectability(False);
				VarietySlider.BtnSlider.SetTicks(2, 0, 1);
			}
			else
			{
				VarietySlider.SetPos(VarietySliderPos.X, VarietySliderPos.Y);
				VarietySlider.BtnSlider.SetSelectability(True);
				VarietySlider.BtnSlider.SetTicks(TVarieties, 0, TVarieties-1);
				
				for(i=0; i<TVarieties; i++)
				{
					VarietySlider.SetEnumeration(i, DeriveItemVariety(TarItem.Name, i));
				}
			}
		}
	}
	
	LinkButton.SetSensitivity(True);
	
	if (SelectedTile == None || SelectedTile.CurItem == None)
	{
		LinkButton.SetSensitivity(False);
	}
	else
	{
		PriceNeeded = class'VMDStaticHousingFunctions'.Static.GetFoodPrice(SelectedTile.CurItem.Name);
		
		if (WindowPlayer.Credits < PriceNeeded || ((SelectedTile.CurItem == TargetWarp.CurSummonCode) && ((VarietySlider.GetValue()+1) == int(TargetWarp.CurPropertyValue))))
		{
			LinkButton.SetSensitivity(False);
		}
	}
}

function string DeriveItemVariety(Name CheckName, int SliderValue)
{
	local string TStr;
	
	switch(CheckName)
	{
		case 'SodaCan':
			if (SliderValue == 0)
			{
				TStr = "(Nuke)";
			}
			else if (SliderValue == 1)
			{
				TStr = "(Zap)";
			}
			else if (SliderValue == 2)
			{
				TStr = "(B[omb?])";
			}
			else if (SliderValue == 3)
			{
				TStr = "(Blast)";
			}
			else if (SliderValue == 4)
			{
				TStr = "(Flash)";
			}
		break;
		case 'CandyBar':
			if (SliderValue == 0)
			{
				TStr = "(Chunk-o-Honey)";
			}
			else if (SliderValue == 1)
			{
				TStr = "(Monty Bites)";
			}
		break;
		case 'Liquor40oz':
			if (SliderValue == 0)
			{
				TStr = "(Super 45)";
			}
			else if (SliderValue == 1)
			{
				TStr = "(Bull)";
			}
			else if (SliderValue == 2)
			{
				TStr = "(Smoked)";
			}
			else if (SliderValue == 3)
			{
				TStr = "(Chinese)";
			}
		break;
		default:
			TStr = "(Standard)";
		break;
	}
	
	return TStr;
}

function Texture DeriveItemTexture(Name CheckName, int SliderValue)
{
	local Texture TTex;
	
	switch(CheckName)
	{
		case 'SodaCan':
			if (SliderValue == 0)
			{
				TTex = Texture'SodaCanTex1';
			}
			else if (SliderValue == 1)
			{
				TTex = Texture'SodaCanTex2';
			}
			else if (SliderValue == 2)
			{
				TTex = Texture'SodaCanTex3';
			}
			else if (SliderValue == 3)
			{
				TTex = Texture'SodaCanTex4';
			}
			else if (SliderValue == 3)
			{
				TTex = Texture'VMDSodaCanTex5';
			}
		break;
		case 'CandyBar':
			if (SliderValue == 0)
			{
				TTex = Texture'CandyBarTex1';
			}
			else if (SliderValue == 1)
			{
				TTex = Texture'CandyBarTex2';
			}
		break;
		case 'Liquor40oz':
			if (SliderValue == 0)
			{
				TTex = Texture'Liquor40OzTex1';
			}
			else if (SliderValue == 1)
			{
				TTex = Texture'Liquor40OzTex2';
			}
			else if (SliderValue == 2)
			{
				TTex = Texture'Liquor40OzTex3';
			}
			else if (SliderValue == 3)
			{
				TTex = Texture'Liquor40OzTex4';
			}
		break;
		default:
			TTex = None;
		break;
	}
	
	return TTex;
}

function LinkCurrentItem()
{
	local class<Inventory> TarItem;
	local VMDMenuHousingFoodTile TarTile;
	local int PriceNeeded, TVarieties;
	
	local string TarProp, TarValue;
	local Texture TarSkin;
	
	TarTile = SelectedTile;
	
	if ((WindowPlayer != None) && (TargetWarp != None) && (TarTile != None) && (TarTile.CurItem != None))
	{
		TarItem = TarTile.CurItem;
		PriceNeeded = class'VMDStaticHousingFunctions'.Static.GetFoodPrice(TarItem.Name);
		TVarieties = class'VMDStaticHousingFunctions'.Static.GetFoodVarieties(TarItem.Name);
		
		if ((WindowPlayer.Credits >= PriceNeeded) && (TarItem != TargetWarp.CurSummonCode || ((VarietySlider.GetValue()+1) != int(TargetWarp.CurPropertyValue))))
		{
			if (TVarieties > 1)
			{
				TarProp = "SkinIndices";
				TarValue = string(VarietySlider.GetValue()+1);
				TarSkin = DeriveItemTexture(TarItem.Name, VarietySlider.GetValue());
			}
			
			WindowPlayer.Credits -= PriceNeeded;
			TargetWarp.ApplySummonCode(TarItem, TarProp, TarValue, TarSkin, True);
			
			Root.PopWindow();
		}
	}
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local VMDMenuHousingFoodTile TTile;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	switch(ButtonPressed)
	{
		case ExitButton:
			Root.PopWindow();
			bHandled = True;
		break;
		case LinkButton:
			LinkCurrentItem();
			bHandled = True;
		break;
		default:
			bHandled = False;
			TTile = VMDMenuHousingFoodTile(ButtonPressed);
		break;
	}
	
	if (TTile != None)
	{
		SelectTile(TTile);
		bHandled = True;
	}
	
	return bHandled;
}

defaultproperties
{
     TileWindowPos=(X=18,Y=2)
     TileWindowSize=(X=274,Y=240)
     
     WinInfoPos(0)=(X=325,Y=9)
     WinInfoSize(0)=(X=173,Y=40)
     WinInfoPos(1)=(X=325,Y=10)
     WinInfoSize(1)=(X=173,Y=244)
     
     VarietySliderPos=(X=323,Y=200)
     VarietySliderSize=(X=179,Y=40)
     
     StrItemNameVariety="%s, %s"
     StrCreditsCost="Cost: %d Credit(s)"
     StrCreditsLeft="You Have %d Credit(s)"
     StrMaxUnits="Max Capacity: %d Unit(s)"
     
     Title="Food Selector"
     ExitButtonText="Cancel"
     LinkButtonText="Link Item"
     ClientWidth=512
     ClientHeight=244
     
     clientTextures(0)=Texture'VMDHousingFoodListWindowBG01'
     clientTextures(1)=Texture'VMDHousingFoodListWindowBG02'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=1
     TextureCols=2
}
