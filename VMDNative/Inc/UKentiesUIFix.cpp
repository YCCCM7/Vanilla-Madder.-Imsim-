
#include "VMDNative.h"

IMPLEMENT_CLASS(UKentiesUIFix);

static bool	FunctionsHooked = false;
static int LastScale = 0.0;
static int LastX = 0;
static int LastY = 0;

void UKentiesUIFix::execAssertHook( FFrame& Stack, RESULT_DECL )
{
	guard(UKentiesUIFix::execAssertHook);
	P_FINISH;
	
	if (FunctionsHooked)
		return;
	
	FunctionsHooked=true;
	
	//First, find our active root window (our client)
	XRootWindow *RootWindow = 0;
	for(TObjectIterator<XRootWindow> I; I; ++I)
	{
		//Legit, and not dead? Cool.
		if(I && !I->IsPendingKill())
		{
			RootWindow = reinterpret_cast<XRootWindow*>(*I);
			break;
		}
	}
	
	//Then, cast some shit so we can access private variables... While at it, get the player pawn that owns it.
	XRootWindowOverlay *HackWindow = reinterpret_cast<XRootWindowOverlay*>(RootWindow);
	APlayerPawnExt *GrabPlayer = HackWindow -> parentPawn;
	
	//If we have one, sniff around for a custom UI scale property
	if (GrabPlayer != 0)
	{
		UProperty *P = FindField<UProperty>(GrabPlayer -> GetClass(), TEXT("CustomUIScale"));
		//If we found it, we're a custom ui scale class, so hook into rendering to use it!
		if (P != 0)
		{
			GNatives[1050] = reinterpret_cast<Native>(&UKentiesUIFix::execApplyScaling);
		}
	}

	unguardexec;
}

void UKentiesUIFix::execApplyScaling( FFrame& Stack, RESULT_DECL )
{
	guard(UKentiesUIFix::execApplyScaling);
	P_GET_OBJECT(UCanvas, Canvas);
	P_FINISH;
	
	//First, find our active root window (our client)
	XRootWindow *RootWindow = 0;
	for(TObjectIterator<XRootWindow> I; I; ++I)
	{
		//Legit, and not dead? Cool.
		if(I && !I->IsPendingKill())
		{
			RootWindow = reinterpret_cast<XRootWindow*>(*I);
			break;
		}
	}
	
	//Then, cast some shit so we can access protected variables... While at it, get the player pawn that owns it.
	XRootWindowOverlay *HackWindow = reinterpret_cast<XRootWindowOverlay*>(RootWindow);
	APlayerPawnExt *GrabPlayer = HackWindow -> parentPawn;
	int TScale = 1;
	
	//If we have one, sniff around for a custom UI scale property
	if (GrabPlayer != 0)
	{
		UProperty *P = FindField<UProperty>(GrabPlayer -> GetClass(), TEXT("CustomUIScale"));
		//If we found it, we're a custom ui scale class, so hook into rendering to use it!
		if (P != 0)
		{
			P->CopyCompleteValue(&TScale, (BYTE*)GrabPlayer + P->Offset);
			TScale -= 1;
		}
	}
	
	//WCCC: Value of 0 is automatic, AKA vanilla behavior.
	if (TScale <= 0)
	{
		RootWindow -> ResizeRoot(Canvas);
	}
    //Checking the size fixes OTP scaling fix issue of UI popping into corner when e.g. resizing window from 2x to 1x scaling range
    else if (HackWindow -> hMultiplier != TScale || HackWindow -> vMultiplier != TScale || Canvas->X != LastX || LastY != Canvas->Y )
    {
		RootWindow -> ResizeRoot(Canvas);
		
		//Change our size; children will align themselves properly
		const float fScaleAmount = static_cast<float>(TScale);
		HackWindow -> width *= HackWindow -> hMultiplier/fScaleAmount;
		HackWindow -> height *= HackWindow -> vMultiplier/fScaleAmount;
		
		HackWindow -> clipRect.clipWidth = HackWindow -> width;
		HackWindow -> clipRect.clipHeight = HackWindow -> height;
		
		HackWindow -> winGC->SetClipRect(HackWindow -> clipRect); //Otherwise cursor is hidden
		
		//Prevent actual scaling
		HackWindow -> hMultiplier = LastScale;
		HackWindow -> vMultiplier = LastScale;
		
		//Apply changes
		for (XWindow *pChild = RootWindow -> GetBottomChild(); pChild != 0; pChild = pChild->GetHigherSibling())
		{
		        pChild->Hide();
		        pChild->Show();
		}
		
		LastScale = fScaleAmount;
		LastX = Canvas->X;
		LastY = Canvas->Y;
	}
	
	unguardexec;
}

IMPLEMENT_FUNCTION(UKentiesUIFix,-1,execAssertHook);
IMPLEMENT_FUNCTION(UKentiesUIFix,-1,execApplyScaling);