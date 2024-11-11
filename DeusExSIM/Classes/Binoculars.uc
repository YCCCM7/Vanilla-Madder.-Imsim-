//=============================================================================
// Binoculars.
//=============================================================================
class Binoculars extends DeusExPickup;

var float ZoomedInTime;

// ----------------------------------------------------------------------
// state Activated
// ----------------------------------------------------------------------

state Activated
{
	function Activate()
	{
		local DeusExPlayer player;

		Super.Activate();

		player = DeusExPlayer(Owner);
		if (player != None)
			player.DesiredFOV = player.Default.DesiredFOV;
	}

	function BeginState()
	{
		local DeusExPlayer player;
		
		ZoomedInTime = 0.0;
		
		Super.BeginState();

		player = DeusExPlayer(Owner);
		RefreshScopeDisplay(player, False);
	}
Begin:
}

// ----------------------------------------------------------------------
// state DeActivated
// ----------------------------------------------------------------------

state DeActivated
{
	function BeginState()
	{
		local DeusExPlayer player;
		
		Super.BeginState();
		
		ZoomedInTime = 0.0;

		player = DeusExPlayer(Owner);
		if (player != None)
		{
			// Hide the Scope View
			DeusExRootWindow(player.rootWindow).scopeView.DeactivateView();
		}
	}
}

function Tick(float DT)
{
	local DeusExPlayer player;
	local float TFOV;
	
	Super.Tick(DT);
	
	Player = DeusExPlayer(Owner);
	if (IsInState('Activated'))
	{
		if (ZoomedInTime < 2.0)
		{
			ZoomedInTime += DT;
		}
		if (ZoomedInTime > 1.25)
		{
			TFOV = class'VMDStaticFunctions'.Static.AdjustFOV(20, Player);
			if (Player.DesiredFOV != TFOV)
			{
				RefreshScopeDisplay(Player, true);
				//Player.DesiredFOV = 20;
			}
		}
	}
}

// ----------------------------------------------------------------------
// RefreshScopeDisplay()
// ----------------------------------------------------------------------

function RefreshScopeDisplay(DeusExPlayer player, optional bool bInstant)
{
	if ((bActive) && (player != None))
	{
		// Show the Scope View
		DeusExRootWindow(player.rootWindow).scopeView.ActivateView(20, True, bInstant);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     //M_Activated="You raise your %s adjust the zoom on accordingly"
     //M_Deactivated="You lower your %s away from your eyes"
     M_Activated=""
     M_Deactivated=""
     
     bActivatable=True
     ItemName="Binoculars"
     ItemArticle="some"
     PlayerViewOffset=(X=18.000000,Z=-6.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Binoculars'
     PickupViewMesh=LodMesh'DeusExItems.Binoculars'
     ThirdPersonMesh=LodMesh'DeusExItems.Binoculars'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconBinoculars'
     largeIcon=Texture'DeusExUI.Icons.LargeIconBinoculars'
     largeIconWidth=49
     largeIconHeight=34
     Description="A pair of military binoculars."
     beltDescription="BINOCS"
     Mesh=LodMesh'DeusExItems.Binoculars'
     CollisionRadius=7.000000
     CollisionHeight=2.060000
     Mass=2.500000
     Buoyancy=3.000000
}
