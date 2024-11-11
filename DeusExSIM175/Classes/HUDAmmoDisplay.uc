//=============================================================================
// HUDAmmoDisplay
//=============================================================================
class HUDAmmoDisplay expands HUDBaseWindow;

var Bool			bVisible;
var Color			colAmmoText;		// Ammo count text color
var Color			colAmmoLowText;		// Color when ammo low
var Color			colNormalText;		// color for normal weapon messages
var Color			colTrackingText;	// color when weapon is tracking
var Color			colLockedText;		// color when weapon is locked
var DeusExPlayer	player;
var int             infoX;

var localized String NotAvailable;
var localized String msgReloading;
var localized String AmmoLabel;
var localized String ClipsLabel, RoundsLabel, CopiesLabel, UnitsLabel;

// Used by DrawWindow
var int clipsRemaining;
var int ammoRemaining;
var int ammoInClip;
var DeusExWeapon weapon;
var DeusExPickup LastPickup;
		
// Defaults
var Texture texBackground;
var Texture texBorder;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();

	bTickEnabled = TRUE;

	Hide();

	player = DeusExPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);

	SetSize(95, 77);
}
 
// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------

event Tick(float deltaSeconds)
{
	local bool FlagHasItem;
	
	if (Player != None)
	{
		if (Player.Weapon != None) FlagHasItem = true;
		if (DeusExPickup(Player.InHand) != None) FlagHasItem = true;
		if (ChargedPickup(Player.InHand) != None || POVCorpse(Player.InHand) != None) FlagHasItem = false;
	}
	
	if ((FlagHasItem) && ( bVisible ))
		Show();
	else
		Hide();
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local bool bLowAmmo;
	
	Super.DrawWindow(gc);
	
	// No need to draw anything if the player doesn't have
	// a weapon selected
	
	if (player != None)
	{
		weapon = DeusExWeapon(player.Weapon);
		LastPickup = DeusExPickup(Player.InHand);
		
		//MADDERS, 1/16/21: Don't display POV corpse as a pickup, even if it is one.
		if (POVCorpse(LastPickup) != None)
		{
			LastPickup = None;
		}
	}
	
	if ( weapon != None )
	{
		// Draw the weapon icon
		gc.SetStyle(DSTY_Masked);
		gc.SetTileColorRGB(255, 255, 255);
		gc.DrawTexture(22, 20, 40, 35, 0, 0, weapon.icon);
		
		// Draw the ammo count
		gc.SetFont(Font'FontTiny');
		gc.SetAlignments(HALIGN_Center, VALIGN_Center);
		gc.EnableWordWrap(false);
		
		// how much ammo of this type do we have left?
		if (weapon.AmmoType != None)
			ammoRemaining = weapon.AmmoType.AmmoAmount;
		else
			ammoRemaining = 0;
		
		if ( ammoRemaining < weapon.LowAmmoWaterMark )
		{
			bLowAmmo = true;
			gc.SetTextColor(colAmmoLowText);
		}
		else
		{
			gc.SetTextColor(colAmmoText);
		}
		
		// Ammo count drawn differently depending on user's setting
		if (weapon.ReloadCount > 1 )
		{
			//MADDERS: Break this up for single loaded and single shot!
			if (Weapon.Default.ReloadCount == 1 || Weapon.bSingleLoaded)
			{
			 	// how much ammo is left in the current clip?
			 	ammoInClip = weapon.AmmoLeftInClip();
			 	clipsRemaining = Max(0, weapon.AmmoType.AmmoAmount - (Weapon.ReloadCount - Weapon.ClipCount));
			 	
			 	if ((weapon.IsInState('Reload')) && (!Weapon.bSingleLoaded))
					gc.DrawText(infoX, 26, 20, 9, msgReloading);
			 	else
					gc.DrawText(infoX, 26, 20, 9, ammoInClip);
			 
			 	// if there are no clips (or a partial clip) remaining, color me red
				if (bLowAmmo)
					gc.SetTextColor(colAmmoLowText);
			 	else if ((clipsRemaining < weapon.ReloadCount) && (ammoRemaining < 2 * weapon.ReloadCount))
					gc.SetTextColor(colAmmoLowText);
			 	else
					gc.SetTextColor(colAmmoText);
			 	
			 	if (weapon.IsInState('Reload') && !Weapon.bSingleLoaded)
					gc.DrawText(infoX, 38, 20, 9, msgReloading);
			 	else
					gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
			}
			else
			{
			 	// how much ammo is left in the current clip?
			 	ammoInClip = weapon.AmmoLeftInClip();
			 	clipsRemaining = weapon.NumClips();
			 	
			 	if (weapon.IsInState('Reload'))
					gc.DrawText(infoX, 26, 20, 9, msgReloading);
			 	else
					gc.DrawText(infoX, 26, 20, 9, ammoInClip);
				
			 	// if there are no clips (or a partial clip) remaining, color me red
				if (bLowAmmo)
					gc.SetTextColor(colAmmoLowText);
			 	else if ((clipsRemaining == 0) || (( clipsRemaining == 1) && ( ammoRemaining < 2 * weapon.ReloadCount )))
					gc.SetTextColor(colAmmoLowText);
			 	else
					gc.SetTextColor(colAmmoText);
				
			 	if (weapon.IsInState('Reload'))
					gc.DrawText(infoX, 38, 20, 9, msgReloading);
			 	else
					gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
			}
		}
		else
		{
			gc.DrawText(infoX, 38, 20, 9, NotAvailable);
			
			if (weapon.ReloadCount == 0)
			{
				gc.DrawText(infoX, 26, 20, 9, NotAvailable);
			}
			else
			{
				if (weapon.IsInState('Reload'))
					gc.DrawText(infoX, 26, 20, 9, msgReloading);
				else
					gc.DrawText(infoX, 26, 20, 9, ammoRemaining);
			}
		}
		
		// Now, let's draw the targetting information
		if (weapon.bCanTrack)
		{
			if (weapon.LockMode == LOCK_Locked)
				gc.SetTextColor(colLockedText);
			else if (weapon.LockMode == LOCK_Acquire)
				gc.SetTextColor(colTrackingText);
			else
				gc.SetTextColor(colNormalText);
			gc.DrawText(25, 56, 65, 8, weapon.TargetMessage);
		}
	}
	if (LastPickup != None)
	{
		// Draw the weapon icon
		gc.SetStyle(DSTY_Masked);
		gc.SetTileColorRGB(255, 255, 255);
		gc.DrawTexture(22, 20, 40, 35, 0, 0, LastPickup.icon);
		
		// Draw the ammo count
		gc.SetFont(Font'FontTiny');
		gc.SetAlignments(HALIGN_Center, VALIGN_Center);
		gc.EnableWordWrap(false);
		
		// how much ammo of this type do we have left?
		if (LastPickup.bCanHaveMultipleCopies)
		{
			AmmoRemaining = LastPickup.NumCopies;
			
			if ((AmmoRemaining < 3) && (LastPickup.VMDConfigureMaxCopies() > 3))
				gc.SetTextColor(colAmmoLowText);
			else
				gc.SetTextColor(colAmmoText);
			
			gc.DrawText(infoX, 26, 20, 9, AmmoRemaining);
			gc.DrawText(infoX, 38, 20, 9, NotAvailable);
		}
		else
		{
			AmmoRemaining = 0;
			gc.SetTextColor(colAmmoText);
			gc.DrawText(infoX, 26, 20, 9, NotAvailable);
			gc.DrawText(infoX, 38, 20, 9, NotAvailable);
		}
	}
	
	DrawHUDModes(GC);
}

//MADDERS: Draw our fire mode icons!
function DrawHUDModes(GC gc)
{
	local Texture T;
	local DeusExWeapon DXW;
	
	DXW = Weapon;
	if ((DXW != None) && (!DXW.bCanTrack))
	{
		//Hack for crossplay.
		if (DXW.IsA('HatchetWeapon'))
		{
			if (int(DXW.GetPropertyText("NumModes")) < 2)
			{
				if (bool(DXW.GetPropertyText("bPumpAction"))) T = Texture'HUDIconPumpLocked';
				else if (bool(DXW.GetPropertyText("bSemiAuto"))) T = Texture'HUDIconSemiLocked';
				else if (bool(DXW.GetPropertyText("bBurstFire"))) T = Texture'HUDIconBurstLocked';
				else if (bool(DXW.GetPropertyText("bFullAuto")) || DXW.bAutomatic) T = Texture'HUDIconAutoLocked';
				else T = Texture'HUDIconSemiLocked';
			}
			else
			{
				if (bool(DXW.GetPropertyText("bPumpAction"))) T = Texture'HUDIconPumpFree';
				else if (bool(DXW.GetPropertyText("bSemiAuto"))) T = Texture'HUDIconSemiFree';
				else if (bool(DXW.GetPropertyText("bBurstFire"))) T = Texture'HUDIconBurstFree';
				else if (bool(DXW.GetPropertyText("bFullAuto")) || DXW.bAutomatic) T = Texture'HUDIconAutoFree';
				else T = Texture'HUDIconSemiFree';
			}
		}
		else
		{
			if (DXW.NumFiringModes < 2)
			{
			 	if (DXW.bSemiautoTrigger) T = Texture'HUDIconSemiLocked';
			 	else if ((DXW.bPumpAction) || (DXW.bBoltAction)) T = Texture'HUDIconPumpLocked';
			 	else if (DXW.bBurstFire) T = Texture'HUDIconBurstLocked';
			 	else T = Texture'HUDIconAutoLocked';
			}
			else
			{
			 	switch(DXW.FiringModes[DXW.CurFiringMode])
			 	{
			  		case "Single Fire":
			   			T = Texture'HUDIconSingleFree';
			  		break;
			  		case "Double Fire":
			  		case "Double Fire ":
			   			T = Texture'HUDIconDoubleFree';
			  		break;
			  		case "Semi Auto":
			   			if ((DXW.bPumpAction) || (DXW.bBoltAction)) T = Texture'HUDIconPumpFree';
			   			T = Texture'HUDIconSemiFree';
			  		break;
			  		case "Burst Fire":
			   			T = Texture'HUDIconBurstFree';
			  		break;
			  		case "Full Auto":
			  		case "Full Auto ":
			   			T = Texture'HUDIconAutoFree';
			  		break;
			  		default:
			   			if ((DXW.bPumpAction) || (DXW.bBoltAction)) T = Texture'HUDIconPumpFree';
			   			else if (DXW.bBurstFire) T = Texture'HUDIconBurstFree';
			   			else if (DXW.bSemiautoTrigger) T = Texture'HUDIconSemiFree';
			   			else T = Texture'HUDIconAutoFree';
			  		break;
			 	}
			}
		}
		if (T != None)
		{
		 	gc.SetStyle(DSTY_Masked);
		 	gc.SetTileColorRGB(255, 255, 255);
		 	gc.DrawTexture(20, 56, 16, 16, 0, 0, T);
		}
	}
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
	local string UseStr;
	local DeusExWeapon Weapon;
	
	gc.SetStyle(backgroundDrawStyle);
	gc.SetTileColor(colBackground);
	gc.DrawTexture(13, 13, 80, 54, 0, 0, texBackground);
	
	// Draw the Ammo and Clips text labels
	gc.SetFont(Font'FontTiny');
	gc.SetTextColor(colText);
	gc.SetAlignments(HALIGN_Center, VALIGN_Top);
	
	if (player != None)
	{
		weapon = DeusExWeapon(player.Weapon);
		LastPickup = None;
		if (ChargedPickup(Player.InHand) == None)
		{
			LastPickup = DeusExPickup(Player.InHand);
		}
	}
	
	if (Weapon != None)
	{
		UseStr = ClipsLabel;
		
		gc.DrawText(66, 17, 21, 8, AmmoLabel);
		
	 	UseStr = Weapon.ClipsLabel;
	 	if (Weapon.bSingleLoaded || Weapon.Default.ReloadCount < 2) UseStr = RoundsLabel;
	}
	
	if (LastPickup != None)
	{
		gc.DrawText(66, 17, 21, 8, CopiesLabel);
		
		UseStr = UnitsLabel;
	}
	
	gc.DrawText(66, 48, 21, 8, UseStr);
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

function DrawBorder(GC gc)
{
	if (bDrawBorder)
	{
		gc.SetStyle(borderDrawStyle);
		gc.SetTileColor(colBorder);
		gc.DrawTexture(0, 0, 95, 77, 0, 0, texBorder);
	}
}

// ----------------------------------------------------------------------
// SetVisibility()
// ----------------------------------------------------------------------

function SetVisibility( bool bNewVisibility )
{
	bVisible = bNewVisibility;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     colAmmoText=(G=255)
     colAmmoLowText=(R=255)
     colNormalText=(G=255)
     colTrackingText=(R=255,G=255)
     colLockedText=(R=255)
     infoX=66
     NotAvailable="N/A"
     msgReloading="---"
     AmmoLabel="AMMO"
     ClipsLabel="CLIPS"
     RoundsLabel="RNDS"
     UnitsLabel=""
     CopiesLabel="UNTS"
     texBackground=Texture'DeusExUI.UserInterface.HUDAmmoDisplayBackground_1'
     texBorder=Texture'DeusExUI.UserInterface.HUDAmmoDisplayBorder_1'
}
