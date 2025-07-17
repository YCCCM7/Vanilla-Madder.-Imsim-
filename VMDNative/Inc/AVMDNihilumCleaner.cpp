
#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDNihilumCleaner);

void AVMDNihilumCleaner::execSilenceNihilum(FFrame &Stack, RESULT_DECL)
{
    P_FINISH;
	
	//So, we have this stupid function writing to log every frame. Stop it from happening, thanks.
    UFunction *FuckDrawBorder = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("VMDNative.VMDNihilumCleaner.FuckDrawBorder")));
    UFunction *NihilumDrawBorder = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("FGRHK.TestHUDHitDisplay.DrawBorder")));
	if (NihilumDrawBorder && FuckDrawBorder)
	{
	   NihilumDrawBorder->Script = FuckDrawBorder->Script;
	}
	
	//Next, fix the main menu function being chunky as fuck and calling FLUSH.
    UFunction *NewMainMenu = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("DeusEx.VMDBufferPlayer.VMDNihilumDontFlushMainMenu")));
    UFunction *NihilumMainMenu = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("FGRHK.MadIngramPlayer.ShowMainMenu")));
	if (NihilumMainMenu && NewMainMenu)
	{
	    NihilumMainMenu->Script = NewMainMenu->Script;
	}
}

IMPLEMENT_FUNCTION(AVMDNihilumCleaner,-1,execSilenceNihilum);