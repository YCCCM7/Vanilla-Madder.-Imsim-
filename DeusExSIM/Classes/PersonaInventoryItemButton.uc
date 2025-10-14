//=============================================================================
// PersonaInventoryItemButton
//=============================================================================
class PersonaInventoryItemButton extends PersonaItemButton;

var bool bEquipped;						// True if item Equipped

// Drag/Drop Stuff
var bool bDragStart;
var bool bDimIcon;	
var bool bAllowDragging;
var bool bDragging;
var bool bValidSlot;
var bool bDeleteMe;
var Int  clickX;
var Int  clickY;
var Int  dragPosX;
var Int  dragPosY;

var PersonaScreenInventory winInv;		// Pointer back to the window 

enum FillModes
{
	FM_WeaponModTrue,
	FM_WeaponModFalse,
	FM_Selected,
	FM_DropGood,
	FM_DropBad,
	FM_None
};

var FillModes fillMode;

var Color colDragGood;
var Color colDragBad;
var Color colWeaponModTrue;
var Color colWeaponModFalse;
var Color colDropGood;
var Color colDropBad;
var Color colNone;

// Texture and Color for background
var Color		fillColor;
var Texture		fillTexture;

var localized String CountLabel;
var localized String RoundLabel;
var localized String RoundsLabel;

//MADDERS: Rotation code.
var bool bAttemptedRotation;

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{	
	local float TBarf, strWidth, strHeight;
	local String str;
	local DeusExWeapon weapon;
	local Inventory anItem;
	
	if (bDeleteMe || GetClientObject() == None)
		return;
	
	if ((!bDragging) || ((bDragging) && (bValidSlot)))
	{
		// Draw the background
		SetFillColor();
		gc.SetStyle(DSTY_Translucent);
		gc.SetTileColor(fillColor);
		gc.DrawPattern(1, 1, width - 2, height - 2, 0, 0, fillTexture);
	}
	
	if (!bDragging)
	{
		gc.SetStyle(DSTY_Masked);	
		gc.SetTileColor(colIcon);
		
		// Draw icon centered in button
		gc.DrawTexture(((width) / 2)  - (iconPosWidth / 2),
					   ((height) / 2) - (iconPosHeight / 2),
					   iconPosWidth, iconPosHeight, 
					   0, 0,
					   icon);
		
		anItem = Inventory(GetClientObject());
		
		// If this item is an inventory item *and* it's in the object 
		// belt, draw a small number in the 
		// upper-right corner designating it's position in the belt
		
		if ( anItem.bInObjectBelt )
		{
			gc.SetFont(Font'FontMenuSmall_DS');
			gc.SetAlignments(HALIGN_Right, VALIGN_Center);
			gc.SetTextColor(colHeaderText);		
			gc.GetTextExtent(0, strWidth, strHeight, anItem.beltPos);
			gc.DrawText(width - strWidth - 3, 3, strWidth, strHeight, anItem.beltPos);
		}
		
		// If this is an ammo or a LAM (or other thrown projectile),
		// display the number of rounds remaining
		//
		// If it's a weapon that takes ammo, then show the type of 
		// ammo loaded into it
		
		if (anItem.IsA('DeusExAmmo') || anItem.IsA('DeusExWeapon'))
		{
			weapon = DeusExWeapon(anItem);
			str = "";
			
			if ((weapon != None) && (weapon.bHandToHand) && (weapon.AmmoType != None) && (weapon.AmmoName != class'AmmoNone'))
			{
				if (DeusExAmmo(Weapon.AmmoType) != None)
				{
					str = Weapon.AmmoType.AmmoAmount $ "/" $ DeusExAmmo(Weapon.AmmoType).VMDConfigureMaxAmmo();
				}
				else
				{
					str = String(weapon.AmmoType.AmmoAmount);
					if (str == "1")
						str = Sprintf(RoundLabel, str);
					else
						str = Sprintf(RoundsLabel, str);
				}
			}
			else if (anItem.IsA('DeusExAmmo'))
			{
				str = String(DeusExAmmo(anItem).AmmoAmount);
				if (str == "1")
					str = Sprintf(RoundLabel, str);
				else
					str = Sprintf(RoundsLabel, str);
			}
			else if ((weapon != None) && (!weapon.bHandToHand))
			{
				if ((Weapon.AmmoType != None) && (Weapon.AmmoName != class'AmmoNone'))
				{
					str = string(Min(Weapon.ReloadCount - Weapon.ClipCount, Weapon.AmmoType.AmmoAmount)) $"/"$ Weapon.ReloadCount + int(Weapon.VMDHasOpenSystemMagBoost()) $ CR() $ weapon.AmmoType.beltDescription;
				}
				else
				{
					Str = weapon.AmmoType.beltDescription;
				}
			}
			
			if (str != "")
			{
				gc.SetFont(Font'FontMenuSmall_DS');
				gc.SetAlignments(HALIGN_Center, VALIGN_Center);
				gc.SetTextColor(colHeaderText);		
				gc.GetTextExtent(0, strWidth, strHeight, str);
				gc.DrawText(0, height - strHeight, width, strHeight, str);
			}
		}
		
		// Check to see if we need to print "x copies"
		if (anItem.IsA('DeusExPickup') && (!anItem.IsA('NanoKeyRing')))
		{
			if (ChargedPickup(AnItem) != None)
			{
				TBarf = float(ChargedPickup(AnItem).Charge) / float(ChargedPickup(AnItem).Default.Charge);
				TBarf = (TBarf * 100.0) + 0.5;
				Str = Max(1, TBarf)$"%";
			}
			
			if ((DeusExPickup(AnItem).bCanHaveMultipleCopies) && (DeusExPickup(AnItem).VMDConfigureMaxCopies() > 1))
			{
				if (Str != "") Str = Str$CR();
				
				str = Str$DeusExPickup(AnItem).NumCopies $ "/" $ DeusExPickup(AnItem).VMDConfigureMaxCopies();
			}
			
			if (str != "")
			{
				gc.SetFont(Font'FontMenuSmall_DS');
				gc.SetAlignments(HALIGN_Center, VALIGN_Center);
				gc.SetTextColor(colHeaderText);		
				gc.GetTextExtent(0, strWidth, strHeight, str);
				gc.DrawText(0, height - strHeight, width, strHeight, str);
			}
			
			/*if (DeusExPickup(anItem).NumCopies > 1)
			{
				str = Sprintf(CountLabel, DeusExPickup(anItem).NumCopies);
				
				gc.SetFont(Font'FontMenuSmall_DS');
				gc.SetAlignments(HALIGN_Center, VALIGN_Center);
				gc.SetTextColor(colHeaderText);		
				gc.GetTextExtent(0, strWidth, strHeight, str);
				gc.DrawText(0, height - strHeight, width, strHeight, str);
			}*/
		}
	}
	
	// Draw selection border width/height of button
	if (bSelected)
	{
		gc.SetTileColor(colSelectionBorder);
		gc.SetStyle(DSTY_Masked);
		gc.DrawBorders(0, 0, width, height, 0, 0, 0, 0, texBorders);
	}
}

// ----------------------------------------------------------------------
// SetInventoryWindow()
// ----------------------------------------------------------------------

function SetInventoryWindow(PersonaScreenInventory newWinInv)
{
	winInv = newWinInv;
}

// ----------------------------------------------------------------------
// SetEquipped()
// ----------------------------------------------------------------------

function SetEquipped(Bool bNewEquipped)
{
	bEquipped = bNewEquipped;
}

// ----------------------------------------------------------------------
// SetIconSize()
// ----------------------------------------------------------------------

function SetIconSize(int newWidth, int newHeight)
{
	iconPosWidth  = newWidth;
	iconPosHeight = newHeight;

	// Also draw borders at the same size
	borderWidth   = newWidth;
	borderHeight  = newHeight;
}

// ----------------------------------------------------------------------
// AllowDragging()
// ----------------------------------------------------------------------

function AllowDragging(bool bNewDragMode)
{
	bAllowDragging = bNewDragMode;
}

// ----------------------------------------------------------------------
// SelectButton()
// ----------------------------------------------------------------------

function SelectButton(Bool bNewSelected)
{
	bSelected = bNewSelected;

	if (bSelected) 
		fillMode = FM_Selected;
	else
		fillMode = FM_None;
}

// ----------------------------------------------------------------------
// HighlightWeapon()
// ----------------------------------------------------------------------

function HighlightWeapon(bool bNewToggle)
{
	if (bNewToggle)
		fillMode = FM_WeaponModTrue;
	else
		fillMode = FM_WeaponModFalse;
}

// ----------------------------------------------------------------------
// SetDropFill()
// ----------------------------------------------------------------------

function SetDropFill(bool bGoodDrop)
{
	if (bGoodDrop)
		fillMode = FM_DropGood;
	else
		fillMode = FM_DropBad;
}

// ----------------------------------------------------------------------
// ResetFill()
// ----------------------------------------------------------------------

function ResetFill()
{
	fillMode = FM_None;
}

// ----------------------------------------------------------------------
// SetFillColor()
// ----------------------------------------------------------------------

function SetFillColor()
{
	switch(fillMode)
	{
		case FM_WeaponModTrue:
			fillColor = colWeaponModTrue;
			break;
		case FM_WeaponModFalse:
			fillColor = colWeaponModFalse;
			break;
		case FM_Selected:
			fillColor = colFillSelected;
			break;
		case FM_DropBad:
			fillColor = colDropBad;
			break;
		case FM_DropGood:
			fillColor = colDropGood;
			break;
		case FM_None:
			fillColor = colNone;
			break;
	}
}

// ----------------------------------------------------------------------
// MouseButtonPressed()
//
// If the user presses the mouse button, initiate drag mode
// ----------------------------------------------------------------------

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if (button == IK_LeftMouse)
	{
		bDragStart = True;
		clickX = pointX;
		clickY = pointY;
		bResult = True;
	}
	else if (button == IK_RightMouse)
	{
		RemoteUseContents();
		bResult = True;
	}
	else if (button == IK_MiddleMouse)
	{
		RemoteDropContents();
		bResult = True;
	}
	return bResult;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	local int keyIndex;
	local bool bKeyHandled;
	
	bKeyHandled = True;
	
	if ( IsKeyDown( IK_Alt ) || IsKeyDown( IK_Shift ) || IsKeyDown( IK_Ctrl ))
		return False;
	
	switch( key ) 
	{
		case IK_R:
			//MADDERS: This bugs if we can't configure and double check, so uh... Fuck that.
			if ((bDragging) && (VMDBufferPlayer(GetPlayerPawn()) != None))
			{
				RotateContents();
			}
		break;
		default:
			bKeyHandled = False;
		break;
	}
}

function RemoteUseContents()
{
	if (WinInv != None)
	{
		WinInv.SelectInventory(Self);
		if (DeusExWeapon(GetClientObject()) != None || SkilledTool(GetClientObject()) != None || FireExtinguisher(GetClientObject()) != None)
		{
			WinInv.EquipSelectedItem();
		}
		else if (DeusExPickup(GetClientObject()) != None)
		{
			WinInv.UseSelectedItem();
		}
	}
}

function RemoteDropContents()
{
	if (WinInv != None)
	{
		WinInv.SelectInventory(Self);
		WinInv.DropSelectedItem();
	}
}

function RotateContents()
{
	local bool bFlipped;
	local DeusExWeapon DXW;
	local DeusExPickup DXP;
	
	local float HackX, HackY;
	
	DXW = DeusExWeapon(ClientObject);
	DXP = DeusExPickup(ClientObject);
	if ((DXW != None) && (DXW.bCanRotateInInventory))
	{
		bAttemptedRotation = !bAttemptedRotation;
		DXW.bRotatedInInventory = !DXW.bRotatedInInventory;
		SetIcon(DXW.VMDConfigureLargeIcon());
		SetIconSize(DXW.VMDConfigureLargeIconWidth(), DXW.VMDConfigureLargeIconHeight());
		bFlipped = true;
	}
	if ((DXP != None) && (DXP.bCanRotateInInventory))
	{
		bAttemptedRotation = !bAttemptedRotation;
		DXP.bRotatedInInventory = !DXP.bRotatedInInventory;
		SetIcon(DXP.VMDConfigureLargeIcon());
		SetIconSize(DXP.VMDConfigureLargeIconWidth(), DXP.VMDConfigureLargeIconHeight());
		bFlipped = true;
	}
	//MADDERS: Ugly, but it'll do.
	if ((bFlipped) && (WinInv != None) && (VMDBufferPlayer(WinInv.Player) != None))
	{
		SetSize(
		(WinInv.invButtonWidth  * VMDBufferPlayer(WinInv.Player).VMDConfigureInvSlotsX(Inventory(ClientObject))) + 1, 
		(WinInv.invButtonHeight * VMDBufferPlayer(WinInv.Player).VMDConfigureInvSlotsY(Inventory(ClientObject))) + 1);
		
		GetCursorPos(HackX, HackY);
		MouseMoved(HackX, HackY);
		
		WinInv.GetCursorPos(HackX, HackY);
		WinInv.UpdateDragMouse(HackX, HackY);
		ResetFill();
	}
}

// ----------------------------------------------------------------------
// MouseButtonReleased()
//
// If we were in drag mode, then release the mouse button.
// If the player is over a new (and valid) inventory location or 
// object belt location, drop the item here.
// ----------------------------------------------------------------------

event bool MouseButtonReleased(float pointX, float pointY, EInputKey button, int numClicks)
{
	if (button == IK_LeftMouse)
	{
		//MADDERS, 10/3/25: Prospective fix for dragging out of inventory causing crashes.
		AddTimer(0.001, False,, 'FinishButtonDrag');
		return True;
	}
	else
	{
		return false;  // don't handle
	}
}

// ----------------------------------------------------------------------
// MouseMoved()
// ----------------------------------------------------------------------

event MouseMoved(float newX, float newY)
{
	local Float invX;
	local Float invY;
	
	if (bAllowDragging)
	{
		if (bDragStart)
		{
			// Only start a drag even if the cursor has moved more than, say,
			// two pixels.  This prevents problems if the user just wants to 
			// click on an item to select it but is a little sloppy.  :)
			if (( Abs(newX - clickX) > 2 ) || ( Abs(newY - clickY) > 2 ))
			{
				StartButtonDrag();
				SetCursorPos(width/2, height/2);
			}
		}
		
		if ((bDragging) && (WinInv != None))
		{
			// Call the PersonaScreenInventory::MouseMoved function, with translated
			// coordinates.
			ConvertCoordinates(Self, newX, newY, winInv, invX, invY);

			winInv.UpdateDragMouse(invX, invY);
		}
	}
}

// ----------------------------------------------------------------------
// CursorRequested()
//
// If we're dragging an inventory item, then set the cursor to that 
// icon.  Otherwise return None, meaning use the default cursor icon.
// ----------------------------------------------------------------------

event texture CursorRequested(window win, float pointX, float pointY, out float hotX, out float hotY, out color newColor, out Texture shadowTexture)
{
    	shadowTexture = None;
	
	hotX = iconPosWidth / 2;
	hotY = iconPosHeight / 2;
	
	if (bDragging)
	{
		if (bDimIcon)
		{
			newColor.R = 64;
			newColor.G = 64;
			newColor.B = 64;
		}
		return (icon);
	}
	else
	{
		return (None);
	}
}

// ----------------------------------------------------------------------
// StartButtonDrag()
// ----------------------------------------------------------------------

function StartButtonDrag()
{
	bDragStart = False;
	bDragging  = True;
	
	if (winInv != None)
		winInv.StartButtonDrag(Self);
}

// ----------------------------------------------------------------------
// FinishButtonDrag()
// ----------------------------------------------------------------------

function FinishButtonDrag()
{
	bDragStart = False;
	bDragging  = False;
	
	if (winInv != None)
		winInv.FinishButtonDrag();
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     bAllowDragging=True
     fillMode=FM_None
     colDragGood=(G=255)
     colDragBad=(R=255)
     colWeaponModTrue=(R=16,G=128,B=160)
     colWeaponModFalse=(R=160,G=80,B=16)
     colDropGood=(R=32,G=128,B=32)
     colDropBad=(R=128,G=32,B=32)
     fillTexture=Texture'Extension.Solid'
     CountLabel="Count: %d"
     RoundLabel="%d Rd"
     RoundsLabel="%d Rds"
}
