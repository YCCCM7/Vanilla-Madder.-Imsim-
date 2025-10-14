//=============================================================================
// HUDSecondaryAmmoDisplay
//=============================================================================
class HUDSecondaryAmmoDisplay expands HUDBaseWindow;

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
var localized String ClipsLabel, RoundsLabel, CopiesLabel, UnitsLabel, TGChargeLabel, TGUnitsLabel;

// Used by DrawWindow
var int clipsRemaining;
var int ammoRemaining;
var int ammoInClip;
var DeusExWeapon weapon;
		
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
		if ((DeusExWeapon(Player.Weapon) != None) && (DeusExWeapon(Player.Weapon).DualWieldPartner != None))
		{
			FlagHasItem = true;
		}
	}
	
	if ((FlagHasItem) && (bVisible))
	{
		Show();
	}
	else
	{
		Hide();
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local bool bLowAmmo, WeaponReloading;
	local int HalfMag;
	local float CrashPoint, TBarf;
	local ChargedPickup TG;
	local VMDBufferPlayer VMP;
	
	Super.DrawWindow(gc);
	
	// No need to draw anything if the player doesn't have
	// a weapon selected
	
	if (player != None)
	{
		VMP = VMDBufferPlayer(Player);
		weapon = DeusExWeapon(player.Weapon);
		if ((Weapon != None) && (Weapon.DualWieldPartner != None))
		{
			Weapon = Weapon.DualWieldPartner;
		}
		else
		{
			Weapon = None;	
		}
	}
	
	if (Weapon != None)
	{
		// Draw the weapon icon
		gc.SetStyle(DSTY_Masked);
		gc.SetTileColorRGB(255, 255, 255);
		gc.DrawTexture(22, 20, 40, 35, 0, 0, Weapon.icon);
		
		// Draw the ammo count
		gc.SetFont(Font'FontTiny');
		gc.SetAlignments(HALIGN_Center, VALIGN_Center);
		gc.EnableWordWrap(false);
		
		// how much ammo of this type do we have left?
		if (Weapon.AmmoType != None)
		{
			AmmoRemaining = Weapon.AmmoType.AmmoAmount;
		}
		else
		{
			AmmoRemaining = 0;
		}
		
		WeaponReloading = Weapon.IsInState('Reload');
		AmmoInClip = Weapon.AmmoLeftInClip();
		HalfMag = int( (float(Weapon.ReloadCount) * 0.5) + 0.99 );
		if (Weapon.ReloadCount == 1)
		{
			if (AmmoRemaining < Weapon.LowAmmoWaterMark)
			{
				gc.SetTextColor(colAmmoLowText);
			}
			else
			{
				gc.SetTextColor(colAmmoText);
			}
		}
		else
		{
			if (AmmoInClip <= HalfMag)
			{
				bLowAmmo = true;
				gc.SetTextColor(colAmmoLowText);
			}
			else
			{
				gc.SetTextColor(colAmmoText);
			}
		}
		
		// Ammo count drawn differently depending on user's setting
		if (Weapon.ReloadCount > 1)
		{
			//MADDERS: Break this up for single loaded and single shot!
			if (Weapon.Default.ReloadCount == 1 || Weapon.bSingleLoaded)
			{
			 	clipsRemaining = Max(0, Weapon.AmmoType.AmmoAmount - (Weapon.ReloadCount - Weapon.ClipCount));
			 	
			 	if ((WeaponReloading) && (!Weapon.bSingleLoaded))
				{
					gc.DrawText(infoX, 26, 20, 9, msgReloading);
				}
			 	else
				{
					gc.DrawText(infoX, 26, 20, 9, ammoInClip);
			 	}
				
			 	// if there are no clips (or a partial clip) remaining, color me red
			 	if (ClipsRemaining < Weapon.LowAmmoWaterMark)
				{
					gc.SetTextColor(colAmmoLowText);
				}
			 	else
				{
					gc.SetTextColor(colAmmoText);
			 	}
				
			 	if ((WeaponReloading) && (!Weapon.bSingleLoaded))
				{
					gc.DrawText(infoX, 38, 20, 9, msgReloading);
				}
			 	else
				{
					gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
				}
			}
			else
			{
			 	ClipsRemaining = Weapon.NumClips();
			 	
			 	if (WeaponReloading)
				{
					gc.DrawText(infoX, 26, 20, 9, msgReloading);
				}
			 	else
				{
					gc.DrawText(infoX, 26, 20, 9, ammoInClip);
				}
				
			 	// if there are no clips (or a partial clip) remaining, color me red
			 	if (ClipsRemaining == 0 || (ClipsRemaining == 1 && AmmoRemaining-AmmoInClip < Weapon.LowAmmoWaterMark))
				{
					gc.SetTextColor(colAmmoLowText);
				}
			 	else
				{
					gc.SetTextColor(colAmmoText);
				}
				
			 	if (WeaponReloading)
				{
					gc.DrawText(infoX, 38, 20, 9, msgReloading);
				}
			 	else
				{
					gc.DrawText(infoX, 38, 20, 9, clipsRemaining);
				}
			}
		}
		else
		{
			gc.DrawText(infoX, 38, 20, 9, NotAvailable);
			
			if (Weapon.ReloadCount == 0)
			{
				gc.DrawText(infoX, 26, 20, 9, NotAvailable);
			}
			else
			{
				if (Weapon.IsInState('Reload'))
				{
					gc.DrawText(infoX, 26, 20, 9, msgReloading);
				}
				else
				{
					gc.DrawText(infoX, 26, 20, 9, ammoRemaining);
				}
			}
		}
		
		// Now, let's draw the targetting information
		if (Weapon.bCanTrack)
		{
			if (Weapon.LockMode == LOCK_Locked)
			{
				gc.SetTextColor(colLockedText);
			}
			else if (Weapon.LockMode == LOCK_Acquire)
			{
				gc.SetTextColor(colTrackingText);
			}
			else
			{
				gc.SetTextColor(colNormalText);
			}
			gc.DrawText(25, 56, 65, 8, weapon.TargetMessage);
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
	local ChargedPickup TG;
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
		if ((Weapon != None) && (Weapon.DualWieldPartner != None))
		{
			Weapon = Weapon.DualWieldPartner;
		}
		else
		{
			Weapon = None;
		}
	}
	
	if (Weapon != None)
	{
		UseStr = ClipsLabel;
		
		gc.DrawText(66, 17, 21, 8, AmmoLabel);
		
	 	UseStr = Weapon.ClipsLabel;
	 	if (Weapon.bSingleLoaded || Weapon.Default.ReloadCount < 2) UseStr = RoundsLabel;
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
     TGChargeLabel="CHRG"
     TGUnitsLabel="UNTS"
     texBackground=Texture'DeusExUI.UserInterface.HUDAmmoDisplayBackground_1'
     texBorder=Texture'DeusExUI.UserInterface.HUDAmmoDisplayBorder_1'
}
