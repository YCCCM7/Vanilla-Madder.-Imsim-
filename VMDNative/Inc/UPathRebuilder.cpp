
#include "VMDNative.h"

IMPLEMENT_CLASS(UPathRebuilder);

//Get better HD Space, thank you.
void UPathRebuilder :: execRebuildPaths(FFrame& Stack, RESULT_DECL)
{
	guard(UPathRebuilder::execRebuildPaths);
	P_FINISH;
	
	
	
	unguardexec;
};

IMPLEMENT_FUNCTION(UPathRebuilder,2201,execRebuildPaths);
