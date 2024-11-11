//=============================================================================
// VMDMEGHRenderWindow
//=============================================================================
class VMDMEGHRenderWindow extends Window;

var VMDBufferPlayer VMP;
var VMDMegh Megh;
var VMDMenuMEGHManagement ManagementWindow;

// Smoke39 - let us see what we look like
function PostDrawWindow(GC gc)
{
	local float DesScale, HackXScalar, HackYScalar, XPix, YPix, MagicXScalar, MagicYScalar;
	local int XScale, YScale, ResPos;
	local Vector TAdd, TAdd2, TLoc, OldLoc;
	local Rotator TRot, OldRot;
	local string GetRes, SearchStr;
	
	if (!bIsVisible)
		return;
	
	if (Megh == None || Megh.bDeleteMe || Megh.EMPHitPoints <= 0 || ManagementWindow == None)
	{
		return;
	}
	
	GetRes = VMP.ConsoleCommand("GetCurrentRes");
	SearchStr = "x";
	ResPos = InStr(GetRes, SearchStr);
	
	if (ResPos > -1)
	{
		//TRot = VMP.ViewRotation;
		//TRot.Pitch = 0;
		//TRot.Yaw += 32768;
		
		XPix = -119 - 581 + ManagementWindow.X;
		YPix = -51 - 280 + ManagementWindow.Y;
		XScale = int(Left(GetRes, ResPos));
		YScale = int(Right(GetRes, Len(GetRes)-ResPos-Len(SearchStr)));
		HackXScalar = 640 / XScale;
		HackYScalar = 480 / YScale;
		
		MagicXScalar = 0.105;
		MagicYScalar = 0.105;
		
		TAdd = vect(40,0,0) >> VMP.ViewRotation;
		TAdd2 = ((vect(0,1,0) * HackXScalar * XPix * MagicXScalar) + (vect(0,0,-1) * HackYScalar * YPix * MagicYScalar)) >> VMP.ViewRotation;
		TLoc = (VMP.Location + (vect(0,0,1) * VMP.BaseEyeHeight)) + TAdd + TAdd2;
		
		Megh.bHidden = true;
		Megh.bStasis = false;
		Megh.bForceStasis = false;
		
		TRot = Rotator(VMP.Location - TLoc);
		TRot.Pitch = 0;
		
		OldLoc = Megh.Location;
		OldRot = Megh.Rotation;
		Megh.SetRotation(TRot);
		Megh.SetLocation(TLoc);
		
		DesScale = 0.25;
		GC.DrawActor(Megh,,, false, DesScale, 1.0);
		
		Megh.SetLocation(OldLoc);
		Megh.SetRotation(OldRot);
	}
}
// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
