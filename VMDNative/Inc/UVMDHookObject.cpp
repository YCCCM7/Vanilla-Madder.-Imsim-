
#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDHookObject);
	
/*static bool	FunctionsHooked = false;

void UVMDHookObject::execAssertHook( FFrame& Stack, RESULT_DECL )
{
	guard(UVMDNative::execAssertHook);
	P_FINISH;
	
	if (FunctionsHooked)
		return;
	
	FunctionsHooked=true;
	
	//DetourTransactionBegin();
	//DetourUpdateThread(GetCurrentThread());
	//DetourAttach(&(PVOID&)UAudioSubsystemHook::old_PlaySound,
			//(PVOID)(&(PVOID&)UAudioSubsystemHook::PlaySound));

	//LONG l = DetourTransactionCommit();
	
	unguardexec;
}

IMPLEMENT_FUNCTION(UVMDHookObject,2201,execAssertHook);
*/