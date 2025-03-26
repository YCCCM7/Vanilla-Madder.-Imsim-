
#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDFileFinder);

//Look for a file at a location.
void AVMDFileFinder :: execFindFileAt(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execFindFileAt);
    P_GET_STR(FindDir);
	P_FINISH;
	
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind;
	
	hFind = FindFirstFileW(*FindDir, &FindFileData);
	
	if (hFind != INVALID_HANDLE_VALUE) 
	{
		*(BOOL*)Result = true;
	}
	else
	{
		*(BOOL*)Result = false;
	}
	
	unguardexec;
};

void AVMDFileFinder :: execGetLatestSaveDir(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execFindFileAt);
    P_GET_STR(FindDir);
	P_FINISH;
	
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind;
	INT counter = 1;
	
	FindDir = FindDir + FString(L"\\Save");
	
	*(INT*)Result = 1000;
	while(counter < 1000)
	{
		FString UseDir = FString(FindDir) + FString::Printf(TEXT("%04d"), counter);
		hFind = FindFirstFileW(*UseDir, &FindFileData);
		
		if (hFind == INVALID_HANDLE_VALUE) 
		{
			GLog -> Logf(*UseDir);
			
			*(INT*)Result = counter;
			break;
		}
		counter += 1;
	}
	
	unguardexec;
}

//Look for maps files, for giggles.
/*void AVMDFileFinder :: execFindMapFiles(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execFindMapFiles);
    P_GET_STR(FindDir);
	P_FINISH;
	
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind;
	
	hFind = FindFirstFileW(*FindDir, &FindFileData);
	FString FolderList = FString(L"Folders: ");
	FString FileList = FString(L"Files: ");
	
	if (hFind == INVALID_HANDLE_VALUE) 
	{
		GLog -> Logf(L"No files found");
	}
	else
	{
		do
		{
			if (FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
			{
				FolderList = FString(FolderList) + FString(L", ") + FString(FindFileData.cFileName);
				//GLog -> Logf(L"Found new folder");
				//GLog -> Logf(FindFileData.cFileName);
			}
			else
			{
				FileList = FString(FileList) + FString(L", ") + FString(FindFileData.cFileName);
				//GLog -> Logf(L"Found new file");
				//GLog -> Logf(FindFileData.cFileName);
			}
		}
		while (FindNextFileW(hFind, &FindFileData) != 0);
	}
	
	GLog -> Logf(*FolderList);
	GLog -> Logf(*FileList);
	
	unguardexec;
};*/

//Generate a list of all "mods" in a folder.
/*void AVMDFileFinder :: execGenerateModDirectories(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execGenerateModDirectories);
	P_FINISH;

	WIN32_FIND_DATA FindFileData, SubFindFileData;
	HANDLE HandleFind, SubHandleFind;
	
	FString StartStr = FString(L"..\\");
	FString SearchStr = StartStr + FString(L"*");
	HandleFind = FindFirstFileW(*SearchStr, &FindFileData);
	FString ModList = FString(L"Mods: ");
	FString DXSearchStr;
	bool FoundDXs = false;
	FString USearchStr;
	bool FoundUs = false;
	FString EXESearchStr;
	bool FoundEXEs = false;
	FString UAXSearchStr;
	bool FoundUAXs = false;
	FString UMXSearchStr;
	bool FoundUMXs = false;
	FString UTXSearchStr;
	bool FoundUTXs = false;
	
	GLog -> Logf(*StartStr);
	GLog -> Logf(*SearchStr);
	if (HandleFind == INVALID_HANDLE_VALUE) 
	{
		GLog -> Logf(L"No files found");
	}
	else
	{
		do
		{
			if (FindFileData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
			{
				FoundEXEs = false;
				EXESearchStr = StartStr + FString(FindFileData.cFileName) + FString(L"\\System\\*.exe");
				SubHandleFind = FindFirstFileW(*USearchStr, &SubFindFileData);
				if (SubHandleFind != INVALID_HANDLE_VALUE)
				{
					//FoundEXEs = true;
				}
				if (!FoundEXEs)
				{
					FoundDXs = false;
					DXSearchStr = StartStr + FString(FindFileData.cFileName) + FString(L"\\Maps\\*.dx");
					SubHandleFind = FindFirstFileW(*DXSearchStr, &SubFindFileData);
					if (SubHandleFind != INVALID_HANDLE_VALUE)
					{
						FoundDXs = true;
					}
					FoundUs = false;
					USearchStr = StartStr + FString(FindFileData.cFileName) + FString(L"\\System\\*.u");
					SubHandleFind = FindFirstFileW(*USearchStr, &SubFindFileData);
					if (SubHandleFind != INVALID_HANDLE_VALUE)
					{
						FoundUs = true;
					}
					FoundUAXs = false;
					UAXSearchStr = StartStr + FString(FindFileData.cFileName) + FString(L"\\Sounds\\*.uax");
					SubHandleFind = FindFirstFileW(*UAXSearchStr, &SubFindFileData);
					if (SubHandleFind != INVALID_HANDLE_VALUE)
					{
						FoundUAXs = true;
					}
					FoundUMXs = false;
					UMXSearchStr = StartStr + FString(FindFileData.cFileName) + FString(L"\\Music\\*.umx");
					SubHandleFind = FindFirstFileW(*UMXSearchStr, &SubFindFileData);
					if (SubHandleFind != INVALID_HANDLE_VALUE)
					{
						FoundUMXs = true;
					}
					FoundUTXs = false;
					UTXSearchStr = StartStr + FString(FindFileData.cFileName) + FString(L"\\Music\\*.utx");
					SubHandleFind = FindFirstFileW(*UTXSearchStr, &SubFindFileData);
					if (SubHandleFind != INVALID_HANDLE_VALUE)
					{
						FoundUTXs = true;
					}
					
					if (FoundDXs || FoundUs || FoundUAXs || FoundUMXs || FoundUTXs)
					{
						ModList = ModList + FString(L"|") + FString(FindFileData.cFileName) + FString(L" (");
						if (FoundDXs)
						{
							ModList = ModList + FString(L"Maps, ");
						}
						if (FoundUs)
						{
							ModList = ModList + FString(L"Code, ");
						}
						if (FoundUAXs)
						{
							ModList = ModList + FString(L"Sounds, ");
						}
						if (FoundUMXs)
						{
							ModList = ModList + FString(L"Music, ");
						}
						if (FoundUTXs)
						{
							ModList = ModList + FString(L"Textures, ");
						}
						ModList = ModList + FString(L")");
					}
				}
			}
		}
		while (FindNextFileW(HandleFind, &FindFileData) != 0);
	}
	
	GLog -> Logf(*ModList);
	
	unguardexec;
}*/

//IMPLEMENT_FUNCTION(AVMDFileFinder,2209,execFindMapFiles);
//IMPLEMENT_FUNCTION(AVMDFileFinder,2209,execGenerateModDirectories);
IMPLEMENT_FUNCTION(AVMDFileFinder,2209,execFindFileAt);
IMPLEMENT_FUNCTION(AVMDFileFinder,2198,execGetLatestSaveDir);
