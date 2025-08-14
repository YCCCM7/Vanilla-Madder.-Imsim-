
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

//Iterator for flipping through functions in sequence.
void AVMDFileFinder :: execFindNextFileAt(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execFindNextFileAt);
	
	P_GET_STR(InPath);
	P_GET_STR_REF(OutPath);
	P_FINISH;
	
	WIN32_FIND_DATAW wfdFindData;
	HANDLE hFindFile = FindFirstFileW(*InPath, &wfdFindData);
	BOOL bFoundAFile = hFindFile != INVALID_HANDLE_VALUE;
	
	//Uggo 1: If we found these invalid fake files, skip past them. They suck.
	if (bFoundAFile && (FString(wfdFindData.cFileName) == FString(L".") || FString(wfdFindData.cFileName) == FString(L"..")))
	{
		INT i = 0;
		do
		{
			FindNextFileW(hFindFile, &wfdFindData);
			bFoundAFile = hFindFile != INVALID_HANDLE_VALUE;
			if (i > 2)
			{
				bFoundAFile = false;
				break;
			}
			i += 1;
		}
		while (FString(wfdFindData.cFileName) == FString(L".") || FString(wfdFindData.cFileName) == FString(L".."));
	}
	
	PRE_ITERATOR;
	
	//If File A stopped being found, we're done.
	if(!bFoundAFile)
	{
	    *OutPath = FString(L"");
		Stack.Code = &Stack.Node->Script(wEndOffset + 1);
		
	    break;
	}
	
	//Hack for identifying folders easier.
	if (wfdFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
	{
		*OutPath = FString(wfdFindData.cFileName) + FString(L".FOLDER");
	}
	else
	{
		*OutPath = FString(wfdFindData.cFileName);
	}
	bFoundAFile = FindNextFileW(hFindFile, &wfdFindData);
	
	POST_ITERATOR;
	
	unguardexec;
};

void AVMDFileFinder :: execCopyFileFrom(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execFindNextFileAt);
	
	P_GET_STR(CopyFrom);
	P_GET_STR(CopyTo);
	P_FINISH;
	
	WIN32_FIND_DATAW wfdFindData;
	HANDLE hFindFile = FindFirstFileW(*CopyFrom, &wfdFindData);
	BOOL bFoundAFile = hFindFile != INVALID_HANDLE_VALUE;
	BOOL bCopyWon = 0;

	if (bFoundAFile)
	{
		bCopyWon = CopyFileW(*CopyFrom, *CopyTo, false);
	}
	
	*(BOOL*)Result = bCopyWon;
	
	unguardexec;
}

void AVMDFileFinder :: execCreateFolderAt(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execFindNextFileAt);
	
	P_GET_STR(GenerateAt);
	P_FINISH;
	
	BOOL bCreateWon = CreateDirectoryW(*GenerateAt, NULL);
	
	*(BOOL*)Result = bCreateWon;
	
	unguardexec;
}

void AVMDFileFinder :: execGetFileLocation(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDFileFinder::execGetFileLocation);
	
	P_GET_STR(CheckFile);
	P_FINISH;
	
	TCHAR Buffer[4096] = TEXT("");
	TCHAR** LPPPart = {0};
	
	BOOL bFileFound = (GetFullPathNameW(*CheckFile, 4096, Buffer, LPPPart) > 0);
	
	if (bFileFound)
	{
		*(FString*)Result = FString(Buffer);
	}
	else
	{
		*(FString*)Result = FString(L"");
	}

	unguardexec;
}

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

//IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execFindMapFiles);
//IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execGenerateModDirectories);
IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execFindFileAt);
IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execFindNextFileAt);
IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execGetLatestSaveDir);
IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execCopyFileFrom);
IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execCreateFolderAt);
IMPLEMENT_FUNCTION(AVMDFileFinder,-1,execGetFileLocation);