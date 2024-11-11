
#include "VMDNative.h"

IMPLEMENT_CLASS(AKentiesUIFix);

static bool	FunctionsHooked = false;
static float LastScale = 0.0;
static int LastX = 0;
static int LastY = 0;

void AKentiesUIFix::execAssertHook( FFrame& Stack, RESULT_DECL )
{
	guard(UVMDNative::execAssertHook);
	P_FINISH;
	
	if (FunctionsHooked)
		return;
	
	FunctionsHooked=true;
	
	GNatives[1050] = reinterpret_cast<Native>(&AKentiesUIFix::execApplyScaling);
	
	unguardexec;
}

void AKentiesUIFix::execApplyScaling( FFrame& Stack, RESULT_DECL )
{
	guard(UVMDNative::execApplyScaling);
	P_GET_OBJECT(UCanvas, Canvas);
	P_FINISH;
	
	//const RootWindow = (APlayerPawnExt)AKentiesUIFix::GetPlayerPawn() -> RootWindow;
	const APlayerPawnExt TPlayer = reinterpret_cast<APlayerPawnExt>(this);
	
    //Checking the size fixes OTP scaling fix issue of UI popping into corner when e.g. resizing window from 2x to 1x scaling range
    /*if (RootWindow -> hMultiplier != LastScale || RootWindow -> vMultiplier != LastScale || Canvas->X != LastX || LastY != Canvas->Y )
    {
		ResizeRoot(Canvas);
		
        //Change our size; children will align themselves properly
        const float fScaleAmount = static_cast<float>(LastScale);
		width *= hMultiplier/fScaleAmount;
        height *= vMultiplier/fScaleAmount;
		
        clipRect.clipWidth = width;
        clipRect.clipHeight = height;
		
        winGC->SetClipRect(clipRect); //Otherwise cursor is hidden
		
        //Prevent actual scaling
        hMultiplier = LastScale;
        vMultiplier = LastScale;
		
        //Apply changes
        for (XWindow *pChild = GetBottomChild(); pChild != nullptr; pChild = pChild->GetHigherSibling())
        {
                pChild->Hide();
                pChild->Show();
        }
		
        LastX = Canvas->X;
        LastY = Canvas->Y;
	}*/
	
	unguardexec;
}

IMPLEMENT_FUNCTION(AKentiesUIFix,2202,execAssertHook);
IMPLEMENT_FUNCTION(AKentiesUIFix,2203,execApplyScaling);
