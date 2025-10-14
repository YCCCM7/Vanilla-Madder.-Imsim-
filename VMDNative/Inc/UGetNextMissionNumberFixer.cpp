    #include "VMDNative.h"
	
	typedef UINT_PTR DWORD_PTR;

	#define DXGE_BROWSE "?Browse@DDeusExGameEngine@@UAEHVFURL@@PBV?$TMap@VFString@@V1@@@AAVFString@@@Z"
	#define VMDN_GET_NEXT_MISSION_NUMBER "?MyGetNextMissionNumber@Hook@@QAEHAAVFString@@@Z"
	#define DEUS_EX_DLL "DeusEx.dll"
	#define VMDN_DLL "VMDNative.dll"

	class VMDNATIVE_API Hook
	{
	public:
		INT MyGetNextMissionNumber(FString &mapName)
		{
			if (mapName == TEXT(""))
			{
				return -1;
			}

			DDeusExGameEngine* TheGameEngine = NULL;
			for(TObjectIterator<DDeusExGameEngine> It; It; ++It)
			{
				TheGameEngine = *It;
				break;
			}

			FString LeftMost = mapName.Left(2);
			//INT Digit = LeftMost.GetCharArray()(1) - L'0';
			INT FrontDigit = LeftMost.GetCharArray()(0) - L'0';
			INT InPos = -1;
			switch(FrontDigit)
			{
				case 0:
				case 1:
				case 2:
				case 3:
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
				case 9:
					/*mapName = mapName.Left(2);
					debugf(TEXT("RETURNING INT VALUE! %s"), mapName);
					
					Digit += FrontDigit * 10;

					return Digit;*/

					if (TheGameEngine)
					{
						return TheGameEngine->GetNextMissionNumber(mapName);
					}
					else
					{
						return 999;
					}
				break;
				default:
					InPos = mapName.InStr(TEXT("\\"));
					if (InPos > -1)
					{
						while (InPos > -1)
						{
							mapName = mapName.Right(mapName.Len() - InPos - 1);
							InPos = mapName.InStr(TEXT("\\"));
						}
						
						debugf(TEXT("DOING ANOTHER LAP! %s"), mapName);
						return MyGetNextMissionNumber(mapName);
					}
					else
					{
						return -1;
					}
				break;
			}
		}
	};

	IMPLEMENT_CLASS(UGetNextMissionNumberFixer);


	void UGetNextMissionNumberFixer::execInstallHook(FFrame& Stack, RESULT_DECL)
	{
		guard(execInstallHook);

		P_FINISH;

		HMODULE hDeusEx = GetModuleHandleA(DEUS_EX_DLL);
		HMODULE hVmdn = GetModuleHandleA(VMDN_DLL);

		debugf(TEXT("hDeusEx=%p"), hDeusEx);
		debugf(TEXT("hVmdn=%p"), hVmdn);

		void* BrowsePtr = (void*)GetProcAddress(hDeusEx, DXGE_BROWSE);
		void* MyGetNextMissionNumberPtr = (void*)GetProcAddress(hVmdn, VMDN_GET_NEXT_MISSION_NUMBER);
		void* CavePtr = (void*)((BYTE*)BrowsePtr - 11);

		//check(*(BYTE*)CavePtr == 0x90);
		if (*(BYTE*)CavePtr != 0x90)
		{
			return;
		}

		debugf(TEXT("BrowsePtr=%p"), BrowsePtr);
		debugf(TEXT("MyGetNextMissionNumberPtr=%p"), MyGetNextMissionNumberPtr);
		debugf(TEXT("CavePtr=%p"), CavePtr);

		BYTE* BrowseCode = (BYTE*)BrowsePtr;

		check(*(BYTE*)(BrowseCode + 0xDA6) == 0xE8);

		BYTE* GetNextMissionNumberCallPtr = BrowseCode + 0xDA6;
		
		INT NewDisplacement = (BYTE*)CavePtr - (GetNextMissionNumberCallPtr + 5);

		debugf(TEXT("NewDisplacement=%p"), NewDisplacement);

		DWORD Flags;

		check(VirtualProtect(GetNextMissionNumberCallPtr, 5, PAGE_EXECUTE_READWRITE, &Flags));

		*(INT*)(GetNextMissionNumberCallPtr + 1) = NewDisplacement;

		check(VirtualProtect(CavePtr, 11, Flags, &Flags));

		BYTE CavePayload[] = {
			0x68, 0x00, 0x00, 0x00, 0x00, /* push [MyGetNextMissionNumberPtr] */
			0xC3                          /* ret                              */
		};

		*(DWORD*)(CavePayload + 1) = (DWORD)MyGetNextMissionNumberPtr;

		check(VirtualProtect(CavePtr, 6, PAGE_EXECUTE_READWRITE, &Flags));

		BYTE* CaveBytes = (BYTE*)CavePtr;

		for(INT I = 0; I < 6; I++)
		{
			debugf(TEXT("CavePayload[%d]=0x%02X"), I, CavePayload[I]);
			debugf(TEXT("CaveBytes[%d]=0x%02X ->"), I, CaveBytes[I]);
			CaveBytes[I] = CavePayload[I];
			debugf(TEXT("CaveBytes[%d]=0x%02X"), I, CaveBytes[I]);
		}

		check(VirtualProtect(CavePtr, 11, Flags, &Flags));

		unguard;
	}

IMPLEMENT_FUNCTION(UGetNextMissionNumberFixer,-1,execInstallHook);