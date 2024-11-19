//=============================================================================
// DeusExScopeView.
//=============================================================================
class DeusExScopeView extends Window;

const ReferenceHeight = 300;

var bool bActive;		// is this view actually active?

var DeusExPlayer player;
var Color colLines;
var Bool  bBinocs;
var Bool  bViewVisible;
var int   desiredFOV;
var string msgLockRange, msgRangeUnit, msgRangeUnitMetres;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	// Get a pointer to the player
	player = DeusExPlayer(GetRootWindow().parentPawn);

	bTickEnabled = true;

	StyleChanged();
}

// ----------------------------------------------------------------------
// Tick()
// ----------------------------------------------------------------------

event Tick(float deltaSeconds)
{
	local Crosshair        cross;
	local DeusExRootWindow dxRoot;

	dxRoot = DeusExRootWindow(GetRootWindow());
	if (dxRoot != None)
	{
		cross = dxRoot.hud.cross;

		if ((bActive) && (bBinocs))
		{
			cross.SetCrosshair(false);
		}
		else
		{
			cross.SetCrosshair(player.bCrosshairVisible);
		}
	}
}

// ----------------------------------------------------------------------
// ActivateView()
// ----------------------------------------------------------------------

function ActivateView(int newFOV, bool bNewBinocs, bool bInstant)
{
	local float desiredVFOV;
	
	desiredFOV = newFOV;

	bBinocs = bNewBinocs;

	if (player != None)
	{
		//G-Flex: we want to correct for aspect ratio here
		//G-Flex: first, get the vFoV we'd have at 4:3
		/*desiredVFOV = (2 * atan(tan((newFOV * 0.0174533)/2.00) * (3.00/4.00)));
		//G-Flex: then, get the matching hFoV at current res, in degrees
		desiredFOV = 57.2957795 * (2 * atan(tan(desiredVFOV/2.00) * (player.rootWindow.width/player.rootWindow.height)));
		*/
		
		DesiredFOV = class'VMDStaticFunctions'.Static.AdjustFOV(NewFOV, Player);
		
		if (bInstant)
			player.SetFOVAngle(desiredFOV);
		else
			player.desiredFOV = desiredFOV;
		
		bViewVisible = True;
		bActive = True; // Transcended - Possibly missing before?
		Show();
	}
}

// ----------------------------------------------------------------------
// DeactivateView()
// ----------------------------------------------------------------------

function DeactivateView()
{
	if (player != None)
	{
		Player.DesiredFOV = Player.Default.DefaultFOV;
		bViewVisible = False;
		bActive = False; // Transcended - Possibly missing before?
		Hide();
	}
}

// ----------------------------------------------------------------------
// HideView()
// ----------------------------------------------------------------------

function HideView()
{
	if (bViewVisible)
	{
		Hide();
		Player.SetFOVAngle(Player.Default.DefaultFOV);
	}
}

// ----------------------------------------------------------------------
// ShowView()
// ----------------------------------------------------------------------

function ShowView()
{
	if (bViewVisible)
	{
		Player.SetFOVAngle(desiredFOV);
		Show();
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local float			fromX, toX;
	local float			fromY, toY;
	local float			scopeWidth, scopeHeight;
	local float ScopeScale;
	local float ScaledFromX, ScaledToX;
	local float ScaledFromY, ScaledToY;
	local float ScaledScopeWidth, ScaledScopeHeight;
	local Texture TempTexture;
	local Actor traceActor;
	local vector AimLocation;
	local float TargetRange;
	local string TargetName;
	local string PathsString;
	local float w, h;
	local string textStr;
	
	Super.DrawWindow(gc);
	
	if (GetRootWindow().parentPawn != None)
	{
		if (player.IsInState('Dying'))
			return;
	}
	
	// Figure out where to put everything
	if (bBinocs)
		scopeWidth  = 512;
	else
		scopeWidth  = 256;
	
	scopeHeight = 256;
	
	// HX_HAN
	// Figure out scale ( Use ReferenceHeight as base height ),
	// but don't draw it smaller on lower res.
	ScopeScale = Height / ReferenceHeight;
	if ( ScopeScale < 1.0 )
		ScopeScale = 1.0;
	else if ( Width < ScopeScale*ScopeWidth || Height < ScopeScale*ScopeHeight )
 		ScopeScale = FMin( ScopeScale, FMin( Width/ScopeWidth, Height/ScopeHeight ) );
	
	ScaledScopeWidth  = ScopeScale*(ScopeWidth +0.75);
	ScaledScopeHeight = ScopeScale*(ScopeHeight+0.75);
	
	ScaledFromX = (Width-ScaledScopeWidth)/2;
	ScaledFromY = (Height-ScaledScopeHeight)/2;
	ScaledToX   = ScaledFromX + ScaledScopeWidth;
	ScaledToY   = ScaledFromY + ScaledScopeHeight;
	
	fromX = (width-scopeWidth)/2;
	fromY = (height-scopeHeight)/2;
	toX   = fromX + scopeWidth;
	toY   = fromY + scopeHeight;
	
	// Draw the black borders
	gc.SetTileColorRGB(0, 0, 0);
	gc.SetStyle(DSTY_Normal);
	if ( Player.Level.NetMode == NM_Standalone )	// Only block out screen real estate in single player
	{
		//needs to be in int, otherwise we get weird lines. Also padd some of these by a pixel since casting to int truncates it.
		gc.DrawPattern(0,           	0,          		int(Width+16*ScopeScale)+1,    	int(ScaledFromY)+1,                		0, 0, Texture'Solid'); //Top
		gc.DrawPattern(0,           	int(ScaledToY)-1, 	int(Width+16*ScopeScale)+1,    	int(ScaledFromY+8*ScopeScale)+1,       	0, 0, Texture'Solid'); //Bottom
		gc.DrawPattern(0,           	int(ScaledFromY),	int(ScaledFromX)+1,            	int(ScaledScopeHeight)+1,          		0, 0, Texture'Solid'); //Left
		gc.DrawPattern(int(ScaledToX)-1,int(ScaledFromY),	int(ScaledFromX+8*ScopeScale)+1,int(ScaledScopeHeight+8*ScopeScale)+1, 	0, 0, Texture'Solid'); //Right
	}
	// Draw the center scope bitmap
	// Use the Header Text color 
	
	if (bBinocs)
	{
		gc.SetStyle( DSTY_Modulated );
		TempTexture = Texture'VMDHUDBinocularView';
		gc.DrawStretchedTexture( ScaledFromX, ScaledFromY, ScaledScopeWidth, ScaledScopeHeight, 0, 0, TempTexture.USize, TempTexture.VSize, TempTexture );
		
		gc.SetTileColor( colLines );
		gc.SetStyle( DSTY_Masked );
		TempTexture = Texture'VMDHUDBinocularCrosshair';
		gc.DrawStretchedTexture( ScaledFromX, ScaledFromY, ScaledScopeWidth, ScaledScopeHeight, 0, 0, TempTexture.USize, TempTexture.VSize, TempTexture );
	}
	else
	{
		// Crosshairs - Use new scope in multiplayer, keep the old in single player
		if ( Player.Level.NetMode == NM_Standalone )
		{
			gc.SetStyle( DSTY_Modulated );
			TempTexture = Texture'VMDHUDScopeView';
			gc.DrawStretchedTexture( ScaledFromX, ScaledFromY, ScaledScopeWidth, ScaledScopeHeight, 0, 0, TempTexture.USize, TempTexture.VSize, TempTexture );
			
			gc.SetTileColor( colLines );
			gc.SetStyle( DSTY_Masked );
			TempTexture = Texture'VMDHUDScopeCrosshair';
			gc.DrawStretchedTexture( ScaledFromX, ScaledFromY, ScaledScopeWidth, ScaledScopeHeight, 0, 0, TempTexture.USize, TempTexture.VSize, TempTexture );
		}
		else
		{
			if ( WeaponRifle(Player.inHand) != None )
			{
				gc.SetStyle(DSTY_Modulated);
				gc.DrawTexture(fromX, fromY, scopeWidth, scopeHeight, 0, 0, Texture'HUDScopeView3');
			}
			else
			{
				gc.SetStyle(DSTY_Modulated);
				gc.DrawTexture(fromX, fromY, scopeWidth, scopeHeight, 0, 0, Texture'HUDScopeView2');
			}
		}
	}
	
	if ((bBinocs) && (Player != None))
	{
		traceActor = TraceLOS(50000,AimLocation);
		if (traceActor != None)
		{
			TargetRange = Abs(VSize(traceActor.Location - player.Location));
			TargetName = player.GetDisplayName(traceActor);
			gc.SetFont(Font'DeusExUI.FontConversation');
			if (TargetName != "")
			{
				textStr = Caps(TargetName);
				gc.GetTextExtent(0, w, h, textStr);
				gc.DrawText(226, 256, w, h, textStr);
				
				textStr = msgLockRange $ ":" @ Int(TargetRange/16) @ msgRangeUnit @ "(" $ Int(TargetRange/52.4934) @ msgRangeUnitMetres $ ")";
				gc.GetTextExtent(0, w, h, textStr);
				gc.DrawText(226, 271, w, h, textStr);
			}
			else if (Inventory(traceActor) != None)
			{
				textStr = Caps(Inventory(traceActor).ItemName);
				gc.GetTextExtent(0, w, h, textStr);
				gc.DrawText(226, 256, w, h, textStr);
				
				textStr = msgLockRange $ ":" @ Int(TargetRange/16) @ msgRangeUnit @ "(" $ Int(TargetRange/52.4934) @ msgRangeUnitMetres $ ")";
				gc.GetTextExtent(0, w, h, textStr);
				gc.DrawText(226, 271, w, h, textStr);
			}
		}
	}
	else if ((Player != None) && (DeusExWeapon(Player.InHand) != None) && (DeusExWeapon(Player.InHand).bZoomed) && (DeusExWeapon(Player.InHand).bLasing))
	{
		traceActor = TraceLOS(50000,AimLocation);
		if (traceActor != None)
		{
			TargetRange = Abs(VSize(traceActor.Location - player.Location));
			TargetName = player.GetDisplayName(traceActor);
			gc.SetFont(Font'DeusExUI.FontConversation');
			if (TargetName != "")
			{
				textStr = Caps("");
				gc.GetTextExtent(0, w, h, textStr);
				gc.DrawText(226, 256, w, h, textStr);
				
				textStr = msgLockRange $ ":" @ Int(TargetRange/16) @ msgRangeUnit @ "(" $ Int(TargetRange/52.4934) @ msgRangeUnitMetres $ ")";
				gc.GetTextExtent(0, w, h, textStr);
				gc.DrawText(226, 271, w, h, textStr);
			}
		}
	}
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;

	theme = player.ThemeManager.GetCurrentHUDColorTheme();

	colLines = theme.GetColorFromName('HUDColor_HeaderText');
}

function Actor TraceLOS(float checkDist, out vector HitLocation)
{
	local Actor target;
	local Vector HitLoc, HitNormal, StartTrace, EndTrace;

	target = None;

	// figure out how far ahead we should trace
	StartTrace = Player.Location;
	EndTrace = Player.Location + (Vector(Player.ViewRotation) * checkDist);

	// adjust for the eye height
	StartTrace.Z += Player.BaseEyeHeight;
	EndTrace.Z += Player.BaseEyeHeight;

	// find the object that we are looking at
	// make sure we don't select the object that we're carrying
	foreach Player.TraceActors(class'Actor', target, HitLoc, HitNormal, EndTrace, StartTrace)
	{
		//G-Flex: allow remote viewing of corpses too
		//G-Flex: don't allow viewing of trash
		//Bjorn: View pickups that are projectile targets.
		if (target.IsA('Pawn') || target.IsA('DeusExCarcass') || (target.IsA('DeusExDecoration') && !target.IsA('Trash')) || target.IsA('ThrownProjectile') ||
			(target.IsA('DeusExMover') && DeusExMover(target).bBreakable) || (target.IsA('Inventory') && Inventory(target).bProjTarget))
		{
			//== Y|y: don't find hidden objects
			if (target.bHidden)
				target = None;
			else if (target != Player.CarriedDecoration)
			{
				if ( (Player.Level.NetMode != NM_Standalone) && target.IsA('DeusExPlayer') )
				{
					if ( DeusExPlayer(target).AdjustHitLocation( HitLoc, EndTrace - StartTrace ) )
						break;
					else
						target = None;
				}
				//G-Flex: disallow viewing of invincible, no-highlight decorations like trees
				else if (target.IsA('DeusExDecoration'))
				{
					if (!DeusExDecoration(target).bInvincible || DeusExDecoration(target).bHighlight)
						break;
				}
				else
					break;
			}
		}
	}

	HitLocation = HitLoc;

	return target;
}

defaultproperties
{
     msgLockRange="RANGE"
     msgRangeUnit="FT"
     msgRangeUnitMetres="M"
}
