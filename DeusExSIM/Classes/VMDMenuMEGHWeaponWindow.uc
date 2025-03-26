//=============================================================================
// VMDMenuHousingFoodWindow
// Let us select some foods.
//=============================================================================
class VMDMenuMEGHWeaponWindow expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow ExitButton, UnequipButton, UseButton;
var localized string ExitButtonText, UnequipButtonText, UseButtonText;

var TileWindow winTile;
var int CurTileCount;
var VMDMenuMEGHWeaponTile TileSet[16], SelectedTile;

var int TargetIndex;

var VMDMegh Megh;
var VMDBufferPlayer VMP;

var VMDMenuUIInfoWindow WinInfoTitle, WinInfoBody;

var VMDButtonPos TileWindowPos, TileWindowSize, WinInfoPos[2], WinInfoSize[2];

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
	
	winScroll = PersonaScrollAreaWindow(winClient.NewChild(Class'PersonaScrollAreaWindow'));
	winScroll.SetPos(posX, posY);
	winScroll.SetSize(sizeX, sizeY);
	
	tileWindow = CreateTileWindow(winScroll.clipWindow);
	
	return tileWindow;
}

event InitWindow()
{
	Super.InitWindow();
	
        ExitButton = WinButtonBar.AddButton(ExitButtonText, HALIGN_Left);
        UnequipButton = WinButtonBar.AddButton(UnequipButtonText, HALIGN_Left);
        UseButton = WinButtonBar.AddButton(UseButtonText, HALIGN_Right);
	CreateInfoWindows();
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

// ----------------------------------------------------------------------
// VANILLA SHIT END!
// ----------------------------------------------------------------------

function CreateList()
{
	local Inventory TInv;
	local DeusExWeapon DXW, FirstWeapon;
	local VMDMenuMEGHWeaponTile TTile;
	
	if ((VMP != None) && (VMP.Inventory != None) && (Megh != None))
	{
		FirstWeapon = Megh.FirstWeapon();
		
		for (TInv = VMP.Inventory; TInv != None; TInv = TInv.Inventory)
		{
			if ((FirstWeapon != None) && (FirstWeapon.Class == TInv.Class)) continue;
			
			DXW = DeusExWeapon(TInv);
			if (Megh.VMDDroneCanEquipWeapon(DXW))
			{
				TTile = VMDMenuMEGHWeaponTile(WinTile.NewChild(class'VMDMenuMEGHWeaponTile'));
				TTile.SetItem(DXW);
				TTile.WeaponWindow = Self;
				
				TileSet[CurTileCount] = TTile;
				CurTileCount++;
			}
		}
		
		if (CurTileCount > 0)
		{
			SelectTile(TileSet[0]);
		}
	}
	else
	{
		AddTimer(0.1, True,, 'DoPop');
	}
}

function SelectTile(VMDMenuMEGHWeaponTile TarTile)
{
	if (TarTile == None || TarTile.CurItem == None)
	{
		return;
	}
	
	if ((SelectedTile != None) && (SelectedTile != TarTile))
	{
		SelectedTile.SetHighlight(False);
	}
	
	TarTile.SetHighlight(True);
	
	SelectedTile = TarTile;
	UpdateInfo();
}

function UpdateInfo()
{
	local string BuildStr[2];
	local DeusExWeapon TarItem;
	local VMDMenuMEGHWeaponTile TarTile;
	
	TarTile = SelectedTile;
	
 	if (Megh == None || Megh.bDeleteMe || VMP == None)
 	{
		AddTimer(0.1, True,, 'DoPop');
		return;
 	}
	else
	{
		if ((TarTile != None) && (TarTile.CurItem != None))
		{
			TarItem = TarTile.CurItem;
			
			BuildStr[0] = Left(TarItem.ItemName, 27);
			WinInfoTitle.Clear();
			WinInfoTitle.SetTitle(BuildStr[0]);
			
			BuildStr[1] = TarItem.Description;
			WinInfoBody.Clear();
			WinInfoBody.SetText(BuildStr[1]);
		}
	}
	
	UseButton.SetSensitivity(True);
	UnequipButton.SetSensitivity(True);
	
	if (SelectedTile == None || SelectedTile.CurItem == None)
	{
		UseButton.SetSensitivity(False);
	}
	if (Megh.FirstWeapon() == None)
	{
		UnequipButton.SetSensitivity(False);
	}
}

function EquipCurrentItem()
{
	local DeusExWeapon OldDXW, DXW, DroppedWeapon;
	local DeusExAmmo OldDXA, DXA;
	local VMDMenuMEGHWeaponTile TarTile;
	
	TarTile = SelectedTile;
	
	if ((VMP != None) && (Megh != None) && (TarTile != None) && (TarTile.CurItem != None))
	{
		DroppedWeapon = Megh.FirstWeapon();
		if (Megh.VMDMeghCanDropWeapon())
		{
			if (Megh.VMDMeghDropWeapon())
			{
				//MADDERS, 8/7/23: Redundant because 
				//Player.PlaySound(Sound'VMDMeghDropWeapon', SLOT_None,,, 512, MEGH.RandomPitch());
			}
			else
			{
				//HOWEVER, we should make sure this actually works first.
				return;
			}
		}
		else if (Megh.FirstWeapon() != None)
		{
			return;
		}
		
		switch(TarTile.CurItem.Class.Name)
		{
			case 'WeaponEMPGrenade':
			case 'WeaponGasGrenade':
			case 'WeaponLAM':
			case 'WeaponNanoVirusGrenade':
			
			case 'WeaponHCEMPGrenade':
			case 'WeaponHCHCGasGrenade':
			case 'WeaponLAM':
			case 'WeaponHCNanoVirusGrenade':
				OldDXW = TarTile.CurItem;
				if ((OldDXW != None) && (class<DeusExAmmo>(OldDXW.Default.AmmoName) != None))
				{
					OldDXA = DeusExAmmo(VMP.FindInventoryType(OldDXW.Default.AmmoName));
					DXW = VMP.Spawn(OldDXW.Class,,, VMP.Location);
					
					if (DXW != None)
					{
						DXW.DropFrom(VMP.Location);
						DXW.PickupAmmoCount = 0;
						
						if ((OldDXA != None) && (OldDXA.AmmoAmount > 0) && (DXW != None))
						{
							DXA = DeusExAmmo(VMP.Spawn(DXW.Default.AmmoName,,, VMP.Location));
							if (DXA != None)
							{
								DXA.AmmoAmount = 1;
								OldDXA.AmmoAmount -= 1;
							}
							DXW.AmmoType = DXA;
							
							DXA.GiveTo(Megh);
							DXA.SetBase(Megh);
						}
						
						DXW.GiveTo(Megh);
						DXW.SetBase(Megh);
						
						VMP.UpdateBeltText(OldDXW);
					}
				}
			break;
			case 'WeaponBaton':
			case 'WeaponCombatKnife':
				DXW = TarTile.CurItem;
				if (DXW != None)
				{
					DXW.DropFrom(VMP.Location);
					DXW.PickupAmmoCount = 0;
					
					//DXW.InitialState = 'Idle2';
					DXW.GiveTo(Megh);
					DXW.SetBase(Megh);
				}
			break;
			default:
				DXW = TarTile.CurItem;
				if (DXW != None)
				{
					if (DXW.bDroneGrenadeWeapon)
					{
						OldDXW = TarTile.CurItem;
						if ((OldDXW != None) && (class<DeusExAmmo>(OldDXW.Default.AmmoName) != None))
						{
							OldDXA = DeusExAmmo(VMP.FindInventoryType(OldDXW.Default.AmmoName));
							DXW = VMP.Spawn(OldDXW.Class,,, VMP.Location);
							
							if (DXW != None)
							{
								DXW.DropFrom(VMP.Location);
								DXW.PickupAmmoCount = 0;
								
								if ((OldDXA != None) && (OldDXA.AmmoAmount > 0) && (DXW != None))
								{
									DXA = DeusExAmmo(VMP.Spawn(DXW.Default.AmmoName,,, VMP.Location));
									if (DXA != None)
									{
										DXA.AmmoAmount = 1;
										OldDXA.AmmoAmount -= 1;
									}
									DXW.AmmoType = DXA;
									
									DXA.GiveTo(Megh);
									DXA.SetBase(Megh);
								}
								
								DXW.GiveTo(Megh);
								DXW.SetBase(Megh);
								
								VMP.UpdateBeltText(OldDXW);
							}
						}
					}
					
					else if (class<DeusExAmmo>(DXW.Default.AmmoName) != None)
					{
						OldDXA = DeusExAmmo(VMP.FindInventoryType(DXW.Default.AmmoName));
						DXW.AmmoType = None;
						
						if (DXW.bLasing) DXW.LaserOff();
						if (DXW.bZoomed) DXW.ScopeOff();
						DXW.DropFrom(VMP.Location);
						DXW.PickupAmmoCount = 0;
						DXW.ClipCount = 0;
						
						DXA = DeusExAmmo(VMP.Spawn(DXW.Default.AmmoName,,, VMP.Location));
						if (DXA != None)
						{
							DXA.AmmoAmount = 0;
							if (OldDXA != None)
							{
								DXA.AmmoAmount = Min(DXW.ReloadCount - DXW.ClipCount, OldDXA.AmmoAmount);
								OldDXA.AmmoAmount -= DXA.AmmoAmount;
							}
							DXW.AmmoType = DXA;
							
							DXA.GiveTo(Megh);
							DXA.SetBase(Megh);
						}
						
						DXW.GiveTo(Megh);
						DXW.SetBase(Megh);
						DXW.ClipCount = 0;
						
						if (DXA != None)
						{
							DXW.LoadAmmoType(DXA);
						}
						DXW.ClipCount = 0;
					}
				}
			break;
		}
		
		if (DXW != None) DXW.VMDSignalPickupUpdate();
		Megh.bSaidOutOfAmmo = false;
		Megh.UpdateWeaponModel();
		
		if (DroppedWeapon != None)
		{
			VMP.FakeParseRightClick(DroppedWeapon);
		}
		if ((Megh.LastDroppedAmmo != None) && (Megh.LastDroppedAmmo.Owner == None))
		{
			VMP.FakeParseRightClick(Megh.LastDroppedAmmo);
		}
		
		AddTimer(0.1, True,, 'DoPop');
	}
}

function UnequipCurrentItem()
{
	if ((Megh != None) && (Megh.VMDMeghCanDropWeapon()))
	{
		if (Megh.VMDMeghDropWeapon())
		{
			Player.PlaySound(Sound'VMDMeghDropWeapon', SLOT_None,,, 512, MEGH.RandomPitch());
		}
		else
		{
			return;
		}
	}
	else
	{
		return;
	}
	
	AddTimer(0.1, True,, 'DoPop');
}

function DoPop()
{
	Root.PopWindow();
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	local VMDMenuMEGHWeaponTile TTile;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	switch(ButtonPressed)
	{
		case ExitButton:
			AddTimer(0.1, True,, 'DoPop');
			bHandled = True;
		break;
		case UnequipButton:
			UnequipCurrentItem();
			bHandled = True;
		break;
		case UseButton:
			EquipCurrentItem();
			bHandled = True;
		break;
		default:
			bHandled = False;
			TTile = VMDMenuMEGHWeaponTile(ButtonPressed);
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
     
     Title="Weapon Selector"
     ExitButtonText="|&Cancel"
     UnequipButtonText="|&Unequip"
     UseButtonText="|&Equip"
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
