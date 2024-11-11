
#include "VMDNative.h"

IMPLEMENT_CLASS(XKentiesUIFix);

//Get better HD Space, thank you.
/*void AVMDHDSpacefix :: execGetFreeHDSpace(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDHDSpacefix::execGetFreeHDSpace);
	P_FINISH;
	
	ULARGE_INTEGER p1, p2, p3;
	
	if (!GetDiskFreeSpaceExA(NULL, &p1, &p2, &p3))
	{
		*(INT*)Result = 0;
	}
	else
	{
		INT divLevel = 0x100000;
		if ((p3.QuadPart / divLevel) > 2147483647)
		{
			*(INT*)Result = 2147483647;
		}
		else
		{
			*(INT*)Result = (p3.QuadPart / divLevel);
		}
	}
	
	unguardexec;
};

IMPLEMENT_FUNCTION(AVMDHDSpacefix,2200,execGetFreeHDSpace);*/
