//=============================================================================
// Paint Warp.
// Touch up your walls, my guy.
//=============================================================================
class VMDPaintWarp extends VMDSurrealDeco;

var() Vector PreviewLocation;
var() Rotator PreviewRotation;
var() VMDHousingScriptedTextureManager TargetManager;
var() int PaintPrice, MaterialPrice;
var() string SurfaceName;

var bool bBobDown;
var float SpinRate, BobRate, BobHeight, CurBobHeight, DefaultDrawScale;

var VMDBufferPlayer WindowPlayer;
var VMDPaintWarpTip MyTip;
var bool bHasWindow;

function ApplySpecialStats()
{
}

function Tick(float DT)
{
	local Rotator R;
	local Vector V;
	local float UseRate;
	local bool bFrobTargetConfirmed;
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(GetPlayerPawn());
	
	//----------------------------
	//MADDERS: Spin behavior!
	R.Yaw = SpinRate*DT;
	SetRotation(Rotation + R);
	
	//----------------------------
	//MADDERS: Bob behavior!
	UseRate = BobHeight*DT;
	if (BobHeight - CurBobHeight < BobHeight / 6 || CurBobHeight < BobHeight / 6) UseRate /= 1.75;
	if (BobHeight - CurBobHeight < BobHeight / 12 || CurBobHeight < BobHeight / 12) UseRate /= 1.75;
	if (BobHeight - CurBobHeight < BobHeight / 24 || CurBobHeight < BobHeight / 24) UseRate /= 1.75;
	
	if (!bBobDown)
	{
		if (CurBobHeight < BobHeight)
		{
			CurBobHeight += UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight > BobHeight)
			{
				V.Z -= (CurBobHeight - BobHeight);
				
				CurBobHeight = BobHeight;
				bBobDown = true;
			}
			SetLocation(Location + V);
 		}
 	}
	else
	{
		if (CurBobHeight > 0)
		{
			CurBobHeight -= UseRate;
			V = Vect(0,0,1) * UseRate;
			if (CurBobHeight < 0)
			{
				V.Z -= (CurBobHeight);
				
				CurBobHeight = 0;
				bBobDown = false;
			}
			SetLocation(Location - V);
		}
	}
	
	//----------------------------
	//MADDERS: Scale behavior!
	DrawScale = DefaultDrawScale * (0.65 + (FClamp(CurBobHeight / BobHeight, 0.0, 1.0) * 0.35));
	
	if (DXP != None)
	{
		if ((DXP.FrobTarget == Self) && (!bHasWindow))
		{
			V = (vect(-1,0,0) * CollisionRadius * 1.5) >> DXP.ViewRotation;
			
			if ((MyTip != None) && (!MyTip.bDeleteMe))
			{
				MyTip.ScaleGlow = 1.0;
				MyTip.IntendedScale = 1.0;
				MyTip.Style = STY_Normal;
				
				MyTip.bEngaged = true;
				MyTip.SetLocation(Location+V);
				MyTip.SetRotation(DXP.ViewRotation);
			}
			else
			{
				MyTip = Spawn(class'VMDPaintWarpTip',,, Location + V, DXP.ViewRotation);
				MyTip.bEngaged = true;
				
				MyTip.ScaleGlow = 1.0;
				MyTip.Style = STY_Normal;
				MyTip.IntendedScale = 1.0;
			}
		}
		else
		{
			if ((MyTip != None) && (!MyTip.bDeleteMe))
			{
				MyTip.bEngaged = false;
			}
		}
	}
	
	Super.Tick(DT);
}

function Frob(Actor Frobber, Inventory FrobWith)
{
	local Inventory TInv;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Frobber);
	
	if (VMP != None)
	{
		if (NanoKeyRing(FrobWith) != None)
		{
			WindowPlayer = VMP;
			InvokePurchaseWindow();
		}
	}
}

function InvokePurchaseWindow()
{
 	local DeusExRootWindow Root;
 	local VMDMenuHousingPaintWindow StartingWindow;
 	
	if (bHasWindow)
	{
		return;
	}
	
 	if (WindowPlayer != None)
 	{
		WindowPlayer.OverrideCameraLocation = PreviewLocation;
		WindowPlayer.OverrideCameraRotation = PreviewRotation;
		WindowPlayer.PutInHand(None);
		WindowPlayer.KillShadow();
		
  		Root = DeusExRootWindow(WindowPlayer.rootWindow);
  		
  		if (Root != None)
  		{
   			StartingWindow = VMDMenuHousingPaintWindow(Root.InvokeMenuScreen(Class'VMDMenuHousingPaintWindow', True));
   			
   			if (StartingWindow != None)
   			{
				StartingWindow.TargetWarp = Self;
				StartingWindow.TargetManager = TargetManager;
				StartingWindow.WindowPlayer = WindowPlayer;
    				bHasWindow = True;
				
				StartingWindow.LoadColorTextureData();
       			}
  		}
 	}
}

function string VMDGetItemName()
{
	return ItemName;
}

defaultproperties
{
     PaintPrice=100
     MaterialPrice=400
     bDirectional=True
     DefaultDrawScale=0.750000
     SpinRate=24576
     BobRate=18.000000
     BobHeight=3.000000
     
     bBlockPlayers=False
     DrawScale=1.000000
     Physics=PHYS_None
     bInvincible=True
     bCanBeBase=False
     bPushable=False
     bHighlight=False
     ItemName="???"
     Mesh=LodMesh'PaintWarpBrush'
     CollisionRadius=5.000000
     CollisionHeight=12.000000
     Mass=2.000000
     Buoyancy=3.000000
     ScaleGlow=1.000000
     Texture=Texture'PaintWarpOrange'
}
