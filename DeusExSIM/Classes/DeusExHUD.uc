//=============================================================================
// DeusExHUD.
//=============================================================================
class DeusExHUD extends Window;

var Crosshair						cross;
var TimerDisplay					timer;
var FrobDisplayWindow				frobDisplay;
var DamageHUDDisplay				damageDisplay;
var AugmentationDisplayWindow			augDisplay;

// NEW STUFF!

var HUDHitDisplay					hit;
var HUDCompassDisplay               compass;
var HUDAmmoDisplay					ammo;
var HUDObjectBelt					belt;
var HUDInformationDisplay           info;
var HUDInfoLinkDisplay				infolink;
var HUDLogDisplay					msgLog;
var HUDConWindowFirst				conWindow;
var HUDMissionStartTextDisplay      startDisplay;
var HUDActiveItemsDisplay			activeItems;
var HUDBarkDisplay					barkDisplay;
var HUDReceivedDisplay				receivedItems;

var HUDMultiSkills					hms;

//MADDERS ADDITIONS!
var VMDHUDDroneIndicator DroneInd;
var VMDHitIndicator HitInd;
var VMDHUDSmellIcons Smell;
var VMDHUDLightGem LightGem;

var bool bNihilumSetup;
var int TimesConfiguredThisFrame;

//DXRando stuff.
var float infolink_and_logs_min_width;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	local DeusExRootWindow root;
	local DeusExPlayer player;

	Super.InitWindow();

	// Get a pointer to the root window
	root = DeusExRootWindow(GetRootWindow());

	// Get a pointer to the player
	player = DeusExPlayer(root.parentPawn);

	SetFont(Font'TechMedium');
	SetSensitivity(false);

	ammo			= HUDAmmoDisplay(NewChild(Class'HUDAmmoDisplay'));
	hit				= HUDHitDisplay(NewChild(Class'HUDHitDisplay'));
	cross			= Crosshair(NewChild(Class'Crosshair'));
	belt			= HUDObjectBelt(NewChild(Class'HUDObjectBelt'));
	activeItems		= HUDActiveItemsDisplay(NewChild(Class'HUDActiveItemsDisplay'));
	damageDisplay	= DamageHUDDisplay(NewChild(Class'DamageHUDDisplay'));
	compass     	= HUDCompassDisplay(NewChild(Class'HUDCompassDisplay'));
	hms				= HUDMultiSkills(NewChild(Class'HUDMultiSkills'));
	//hvo				= HUDVocalize(NewChild(Class'HUDVocalize'));

	//MADDERS: Have a hit indicator now!
	HitInd = VMDHitIndicator(NewChild(Class'VMDHitIndicator'));
	HitInd.Show(False);
	//MADDERS: Add smell display
	Smell = VMDHUDSmellIcons(NewChild(Class'VMDHUDSmellIcons'));
	//Smell.Show(False);
	
	DroneInd = VMDHUDDroneIndicator(NewChild(class'VMDHUDDroneIndicator'));
	//DroneInd.SetVisibility(False);
	
	LightGem = VMDHUDLightGem(NewChild(class'VMDHUDLightGem'));
	
	// Create the InformationWindow
	info = HUDInformationDisplay(NewChild(Class'HUDInformationDisplay', False));

	// Create the log window
	msgLog	= HUDLogDisplay(NewChild(Class'HUDLogDisplay', False));
	msgLog.SetLogTimeout(player.GetLogTimeout());

	frobDisplay = FrobDisplayWindow(NewChild(Class'FrobDisplayWindow'));
	frobDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	//augDisplay	= AugmentationDisplayWindow(NewChild(Class'AugmentationDisplayWindow'));
	//augDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	startDisplay = HUDMissionStartTextDisplay(NewChild(Class'HUDMissionStartTextDisplay', False));
//	startDisplay.SetWindowAlignments(HALIGN_Full, VALIGN_Full);

	// Bark display
	barkDisplay = HUDBarkDisplay(NewChild(Class'HUDBarkDisplay', False));

	// Received Items Display
	receivedItems = HUDReceivedDisplay(NewChild(Class'HUDReceivedDisplay', False));
	
	AddTimer(0.01, True,, 'ClearConfiguring');
}

// ----------------------------------------------------------------------
// DescendantRemoved()
// ----------------------------------------------------------------------

event DescendantRemoved(Window descendant)
{
	if (descendant == ammo)
		ammo = None;
	else if (descendant == hit)
		hit = None;
	else if (descendant == cross)
		cross = None;
	else if (descendant == belt)
		belt = None;
	else if (descendant == activeItems)
		activeItems = None;
	else if (descendant == damageDisplay)
		damageDisplay = None;
	else if (descendant == infolink)
		infolink = None;
	else if (descendant == timer)
		timer = None;
	else if (descendant == msgLog)
		msgLog = None;
	else if (descendant == info)
		info = None;
	else if (descendant == conWindow)
		conWindow = None;
	else if (descendant == frobDisplay)
		frobDisplay = None;
	//else if (descendant == augDisplay)
	//	augDisplay = None;
	else if (descendant == compass)
		compass = None;
	else if (descendant == startDisplay)
		startDisplay = None;
	else if (descendant == barkDisplay)
		barkDisplay = None;
	else if (descendant == receivedItems)
		receivedItems = None;
	else if ( descendant == hms )
		hms = None;
	//else if ( descendant == hvo )
	//	hvo = None;
	//MADDERS: Clear these, too.
	else if (descendant == HitInd)
		HitInd = None;
	else if (descendant == DroneInd)
		DroneInd = None;
	else if (descendant == Smell)
		Smell = None;
	else if (descendant == LightGem)
		LightGem = None;
}

// ----------------------------------------------------------------------
// ConfigurationChanged()
// ----------------------------------------------------------------------

function ConfigurationChanged()
{
	local float qWidth, qHeight;
	local float compassWidth, compassHeight;
	local float beltWidth, beltHeight;
	local float ammoWidth, ammoHeight;
	local float hitWidth, hitHeight;
	local float infoX, infoY, infoTop, infoBottom;
	local float infoWidth, infoHeight, maxInfoWidth, maxInfoHeight;
	local float itemsWidth, itemsHeight;
	local float damageWidth, damageHeight;
	local float conHeight;
	local float barkWidth, barkHeight;
	local float recWidth, recHeight, recPosY;
	local float logTop;
	
	local float LightWidth, LightHeight;
	local float NotifierWidth, NotifierHeight;
	
	//DXRando stuff.
	local float infolinkWidth;
	
	//MADDERS, 6/26/25: Doing some work here for better min size.
	local float UIScale;
	
	//MADDERS, 4/19/24: Weirdass fix for supposed runaway loop I got in Mutations.
	if (TimesConfiguredThisFrame > 199)
	{
		return;
	}
	TimesConfiguredThisFrame += 1;
	
	UIScale = float(GetPlayerPawn().GetPropertyText("CustomUIScale"));
	if (UIScale <= 1)
	{
		UIScale = 2.0; //Assume the worst.
	}
	else
	{
		UIScale -= 1.0;
	}
	infolink_and_logs_min_width = 475 * (UIScale);
	
	//MADDERS: Cram in our smell overlays and such if needed if we're in DXN.
	if ((string(Class) ~= "FGRHK.MyGameHUD") && (!bNihilumSetup))
	{
		bNihilumSetup = true;
		if (DroneInd == None)
		{
			//MADDERS, 2/24/25: Also have this now.
			DroneInd = VMDHUDDroneIndicator(NewChild(Class'VMDHUDDroneIndicator'));
			//DroneInd.SetVisibility(False);
		}
		if (HitInd == None)
		{
			//MADDERS: Have a hit indicator now!
			HitInd = VMDHitIndicator(NewChild(Class'VMDHitIndicator'));
			HitInd.Show(False);
		}
		if (Smell == None)
		{
			//MADDERS: Add smell display
			Smell = VMDHUDSmellIcons(NewChild(Class'VMDHUDSmellIcons'));
			//Smell.Show(False);
		}
		if (LightGem == None)
		{
			LightGem = VMDHUDLightGem(NewChild(class'VMDHUDLightGem'));
		}
		AddTimer(0.01, True,, 'ClearConfiguring');
		class'VMDNative.VMDNihilumCleaner'.Static.SilenceNihilum();
	}
	
	if (ammo != None)
	{
		if (ammo.IsVisible())
		{
			ammo.QueryPreferredSize(ammoWidth, ammoHeight);
			ammo.ConfigureChild(0, height-ammoHeight, ammoWidth, ammoHeight);
		}
		else
		{
			ammoWidth  = 0;
			ammoHeight = 0;
		}
	}
	
	if (hit != None)
	{
		if (hit.IsVisible())
		{
			hit.QueryPreferredSize(hitWidth, hitHeight);
			hit.ConfigureChild(0, 0, hitWidth, hitHeight);
		}
	}
	
	// Stick the Compass directly under the Hit display
	if (compass != None)
	{
		compass.QueryPreferredSize(compassWidth, compassHeight);
		compass.ConfigureChild(0, hitHeight + 4, compassWidth, compassHeight);

		if (hitWidth == 0)
			hitWidth = compassWidth;
	}
	
	if (cross != None)
	{
		cross.QueryPreferredSize(qWidth, qHeight);
		cross.ConfigureChild((width-qWidth)*0.5+0.5, (height-qHeight)*0.5+0.5, qWidth, qHeight);
	}
	
	//MADDERS: Configure our hit indicator size!
	if (HitInd != None)
	{
		HitInd.QueryPreferredSize(qWidth, qHeight);
		HitInd.ConfigureChild((width-qWidth)*0.5+0.5, (height-qHeight)*0.5+0.5, qWidth, qHeight);
	}
	
	if (DroneInd != None)
	{
		DroneInd.QueryPreferredSize(qWidth, qHeight);
		DroneInd.ConfigureChild((width-qWidth)*0.5 + 48, (Height-QHeight) * 0.5 - 48, qWidth, qHeight);
	}
	//MADDERS: Configure smells!
	/*if (Smell != None)
	{
		Smell.QueryPreferredSize(qWidth, qHeight);
		Smell.ConfigureChild((width-qWidth)*0.5+0.5, (height-qHeight)*0.5+0.5, qWidth, qHeight);
	}*/
	
	//MADDERS: Move our skill notifier!
	/*if (SkillNotifier != None)
	{
		SkillNotifier.QueryPreferredSize(NotifierWidth, NotifierHeight);
		SkillNotifier.ConfigureChild((width-qWidth)*0.5 - NotifierWidth*5, (height-qHeight)*0.5 - NotifierHeight*0.5, NotifierWidth, NotifierHeight);
	}*/
	
	if (belt != None)
	{
		belt.QueryPreferredSize(beltWidth, beltHeight);
		belt.ConfigureChild(width - beltWidth, height - beltHeight, beltWidth, beltHeight);

		infoBottom = height - beltHeight;
	}
	else
	{
		infoBottom = height;
	}
	
	//VMD: Light gem configuration spot brought to you by Markie from Vanilla Matters.
    	if (LightGem != None)
	{
		LightGem.QueryPreferredSize(LightWidth, LightHeight);
		LightGem.ConfigureChild(FMin((Width / 2) - (LightWidth / 2), Width - BeltWidth - LightWidth - 20), Height - LightHeight, LightWidth, LightHeight);
	}
	
	// Damage display
	//
	// Left side, under the compass

	if (damageDisplay != None)
	{
		// Doesn't check to see if it might bump into the Hit Display 
		damageDisplay.QueryPreferredSize(damageWidth, damageHeight);
		
		//MADDERS, 10/3/22: Offset our damage gem to not be underneath smells. Hacky +42.
		damageDisplay.ConfigureChild(0, hitHeight + compassHeight + 4 + 42, damageWidth, damageHeight);
	}

	// Active Items, includes Augmentations and various charged Items
	// 
	// Upper right corner

	if (activeItems != None)
	{
		itemsWidth = activeItems.QueryPreferredWidth(height - beltHeight);
		activeItems.ConfigureChild(width - itemsWidth, 0, itemsWidth, height - beltHeight);
	}
	
	// Display the infolink to the right of the hit display
	// and underneath the Log window if it's visible.
	
	if (infolink != None)
	{
		infolink.QueryPreferredSize(infolinkWidth, qHeight);
		
		//DXRando: old yucky vanilla layout
        	if ((msgLog != None) && (msgLog.IsVisible()) && (width < infolink_and_logs_min_width))
		{
			infolink.ConfigureChild(hitWidth + 20, msgLog.Height + 20, infolinkWidth, qHeight);
		}
		// DXRando: side-by-side infolink with logs
		else
		{
			infolink.ConfigureChild(hitWidth + 10, 0, infolinkWidth, qHeight);
		}
		
		if (infolink.IsVisible())
		{
			infoTop = max(infoTop, 10 + qHeight);
		}
	}
	
    	// Display the Log in the upper-left corner, to the right of
    	// the hit display.
	
	// DXRando: side by side infolink and logs
    	if ((msgLog != None) && (infolink != None) && (width >= infolink_and_logs_min_width))
    	{
        	qHeight = msgLog.QueryPreferredHeight(width - hitWidth - itemsWidth - 0 - infolinkWidth);
        	msgLog.ConfigureChild(hitWidth + 10 + infolinkWidth, 10, width - hitWidth - itemsWidth - 0 - infolinkWidth, qHeight);
    	}
    	else if (msgLog != None)
    	{
        	qHeight = msgLog.QueryPreferredHeight(width - hitWidth - itemsWidth - 40);
        	msgLog.ConfigureChild(hitWidth + 20, 10, width - hitWidth - itemsWidth - 40, qHeight);
    	}
	
	// First-person conversation window

	if (conWindow != None)
	{
		qWidth  = Min(width - 100, 800);
		conHeight = conWindow.QueryPreferredHeight(qWidth);

		// Stick it above the belt
		conWindow.ConfigureChild(
			(width / 2) - (qwidth / 2), (infoBottom - conHeight) - 20, 
			qWidth, conHeight);
	}

	// Bark Display.  Position where first-person convo window would
	// go, or above it if the first-person convo is visible
	if (barkDisplay != None)
	{
		qWidth = Min(width - 100, 800);
		barkHeight = barkDisplay.QueryPreferredHeight(qWidth);

		barkDisplay.ConfigureChild(
			(width / 2) - (qwidth / 2), (infoBottom - barkHeight - conHeight) - 20, 
			qWidth, barkHeight);
	}

	// Received Items display
	// 
	// Stick below the crosshair, but above any bark/convo windows that might 
	// be visible.

	if (receivedItems != None)
	{
		receivedItems.QueryPreferredSize(recWidth, recHeight);

		recPosY = (height / 2) + 20;

		if ((barkDisplay != None) && (barkDisplay.IsVisible()))
			recPosY -= barkHeight;
		if ((conWindow != None) && (conWindow.IsVisible()))
			recPosY -= conHeight;

		receivedItems.ConfigureChild(
			(width / 2) - (recWidth / 2), recPosY,
			recWidth, recHeight);
	}

	// Display the timer above the object belt if it's visible

	if (timer != None)
	{
		timer.QueryPreferredSize(qWidth, qHeight);

		if ((belt != None) && (belt.IsVisible()))
			timer.ConfigureChild(width-qWidth, height-qHeight-beltHeight-10, qWidth, qHeight);
		else
			timer.ConfigureChild(width-qWidth, height-qHeight, qWidth, qHeight);
	}

	// Mission Start Text
	if (startDisplay != None)
	{
		// Stick this baby right in the middle of the screen.
		startDisplay.QueryPreferredSize(qWidth, qHeight);
		startDisplay.ConfigureChild(
			(width / 2) - (qWidth / 2), (height / 2) - (qHeight / 2) - 75,
			qWidth, qHeight);
	}

	// Display the Info Window sandwiched between all the other windows.  :)

	if ((info != None) && (info.IsVisible(False)))
	{
		// Must redo these formulas
		maxInfoWidth  = Min(width - 170, 800);
		maxInfoHeight = (infoBottom - infoTop) - 20;

		info.QueryPreferredSize(infoWidth, infoHeight);

		if (infoWidth > maxInfoWidth)
		{
			infoHeight = info.QueryPreferredHeight(maxInfoWidth);
			infoWidth  = maxInfoWidth;
		}

		infoX = (width / 2) - (infoWidth / 2);
		infoY = infoTop + (((infoBottom - infoTop) / 2) - (infoHeight / 2)) + 10;

		info.ConfigureChild(infoX, infoY, infoWidth, infoHeight);
	}
}

// ----------------------------------------------------------------------
// ChildRequestedReconfiguration()
// ----------------------------------------------------------------------

function bool ChildRequestedReconfiguration(window child)
{
	ConfigurationChanged();

	return TRUE;
}

// ----------------------------------------------------------------------
// ChildRequestedVisibilityChange()
// ----------------------------------------------------------------------

function ChildRequestedVisibilityChange(window child, bool bNewVisibility)
{
	child.SetChildVisibility(bNewVisibility);

	ConfigurationChanged();
}

// ----------------------------------------------------------------------
// CreateInfoLinkWindow()
//
// Creates the InfoLink window used to display messages.  If a 
// InfoLink window already exists, then return None.  If the Log window
// is visible, it hides it.
// ----------------------------------------------------------------------

function HUDInfoLinkDisplay CreateInfoLinkWindow()
{
	if ( infolink != None )
		return None;

	infolink = HUDInfoLinkDisplay(NewChild(Class'HUDInfoLinkDisplay'));

    	// Hide Log window DXRando: or don't
    	if ((msgLog != None) && (width < infolink_and_logs_min_width))
	{
		msgLog.Hide();
	}
	
	infolink.AskParentForReconfigure();

	return infolink;
}

// ----------------------------------------------------------------------
// DestroyInfoLinkWindow()
// ----------------------------------------------------------------------

function DestroyInfoLinkWindow()
{
	if ( infoLink != None )
	{
		infoLink.Destroy();

		// If the msgLog window was visible, show it again
		if (( msgLog != None ) && ( msgLog.MessagesWaiting() ))
		{
			msgLog.Show();
		}
        	if ((msgLog != None) && (msgLog.IsVisible())) // DXRando: reconfigure the window so the logs can be the proper width again
		{
        		msgLog.AskParentForReconfigure();
        	}
	}
}

// ----------------------------------------------------------------------
// CreateConWindowFirst()
// ----------------------------------------------------------------------

function HUDConWindowFirst CreateConWindowFirst()
{
	local DeusExRootWindow root;
	
	// Get a pointer to the root window
	root = DeusExRootWindow(GetRootWindow());

	conWindow = HUDConWindowFirst(NewChild(Class'HUDConWindowFirst', False));
	conWindow.AskParentForReconfigure();

	return conWindow;
}

// ----------------------------------------------------------------------
// VisibilityChanged()
//
// Used to display Log messages that were received while the HUD
// wasn't visible
// ----------------------------------------------------------------------

event VisibilityChanged(bool bNewVisibility)
{
	Super.VisibilityChanged( bNewVisibility );

	if (( msgLog != None ) && ( bNewVisibility ))
	{
		if (( infoLink == None ) && ( msgLog.MessagesWaiting() ))
			msgLog.Show();
	}
}

// ----------------------------------------------------------------------
// CreateTimerWindow()
//
// Creates the Timer window used to display countdowns.  If a 
// Timer window already exists, then return None.
// ----------------------------------------------------------------------

function TimerDisplay CreateTimerWindow()
{
	if ( timer != None )
		return None;

	timer = TimerDisplay(NewChild(Class'TimerDisplay'));
	timer.AskParentForReconfigure();

	return timer;
}

// ----------------------------------------------------------------------
// ShowInfoWindow()
// ----------------------------------------------------------------------

function HUDInformationDisplay ShowInfoWindow()
{
	if (info != None)
		info.Show();

	return info;
}

// ----------------------------------------------------------------------
// UpdateSettings()
//
// Show/Hide these items as dictated by settings in DeusExPlayer (until 
// DeusExHUD can be serialized)
// ----------------------------------------------------------------------

function UpdateSettings( DeusExPlayer player )
{
	local VMDBufferPlayer VMP;
	
	belt.SetVisibility(player.bObjectBeltVisible);
	hit.SetVisibility(player.bHitDisplayVisible);
	ammo.SetVisibility(player.bAmmoDisplayVisible);
	activeItems.SetVisibility(player.bAugDisplayVisible);
	damageDisplay.SetVisibility(player.bHitDisplayVisible);
	compass.SetVisibility(player.bCompassVisible);
	
	//MADDERS, 8/29/22: Include hit indicator in whether crosshair is shown.
	cross.SetCrosshair(player.bCrosshairVisible);
	HitInd.SetVisibility(Player.bCrosshairVisible);
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		//DroneInd.SetVisibility(Player.bDroneAllianceVisible);
		Smell.SetVisibility(VMP.bSmellIndicatorVisible);
		LightGem.SetVisibility(VMP.bLightGemVisible);
	}
	else
	{
		//DroneInd.SetVisibility(false);
		Smell.SetVisibility(false);
		LightGem.SetVisibility(false);
	}
	
	if ((Player != None) && (InformationDevices(Player.FrobTarget) != None) && (InformationDevices(Player.FrobTarget).AReader == Player))
	{
		InformationDevices(Player.FrobTarget).DestroyWindow();
		InformationDevices(Player.FrobTarget).AReader = Player;
		InformationDevices(Player.FrobTarget).CreateInfoWindow();
	}
}

function ClearConfiguring()
{
	TimesConfiguredThisFrame = 0;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
