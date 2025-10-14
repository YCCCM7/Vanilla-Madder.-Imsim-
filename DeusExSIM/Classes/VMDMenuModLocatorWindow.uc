//=============================================================================
// VMDMenuModLocatorWindow
// Let us select some foods.
//=============================================================================
class VMDMenuModLocatorWindow expands MenuUIWindow;

struct VMDButtonPos {
	var int X;
	var int Y;
};

var MenuUIActionButtonWindow ExitButton, LinksButton, OpenSelectButton, BackOutButton;
var localized string ExitButtonText, LinksButtonText, OpenButtonText, BackOutButtonText, SelectButtonText;

var localized string StrSelectAFile, StrAFile, StrCanOpenFolder, StrNoFileTitle, StrCurDirectory, StrFreeSpace, PopupHeader;

var TileWindow winTile;
var VMDMenuFileFinderTile SelectedTile;

var string CurDirectory;

var VMDBufferPlayer VMP;
var VMDMenuSelectCustomCampaign CampaignWindow;

var string KeyFolderNames[64];
var localized string KeyFolderDescs[64], ModInstalledPopupText[64], ModNotInstalledPopupText[64];

var VMDMenuUIInfoWindow WinInfoTitle, WinInfoBody, WinInfoCurDirectory, WinInfoFreeSpace;

var VMDButtonPos TileWindowPos, TileWindowSize, WinInfoPos[4], WinInfoSize[4];

// ----------------------------------------------------------------------
// MADDERS: 4/14/22: Vanilla function bullshit. Clustered together because it has minimal value.
// ----------------------------------------------------------------------

function bool CanPushScreen(Class <DeusExBaseWindow> newScreen)
{
	return false;
}

function bool CanStack()
{
	return false;
}

event bool VirtualKeyPressed(EInputKey key, bool bRepeat)
{
	return false;
}

event bool RawKeyPressed(EInputKey key, EInputState iState, bool bRepeat)
{
	return false;
}

function TileWindow CreateTileWindow(Window parent)
{
	local TileWindow tileWindow;
	
	// Create Tile Window inside the scroll window
	tileWindow = TileWindow(parent.NewChild(Class'TileWindow'));
	tileWindow.SetFont( class'PersonaEditWindow'.Default.FontText );
	tileWindow.SetOrder(ORDER_Down);
	tileWindow.SetChildAlignments(HALIGN_Full, VALIGN_Top);
	tileWindow.MakeWidthsEqual(False);
	tileWindow.MakeHeightsEqual(False);
	
	return tileWindow;
}

function TileWindow CreateScrollTileWindow(int posX, int posY, int sizeX, int sizeY)
{
	local TileWindow tileWindow;
	local PersonaScrollAreaWindow winScroll;
	
	winScroll = VMDMenuUIScrollAreaWindow(winClient.NewChild(Class'VMDMenuUIScrollAreaWindow'));
	winScroll.SetPos(posX, posY);
	winScroll.SetSize(sizeX, sizeY);
	
	tileWindow = CreateTileWindow(winScroll.clipWindow);
	
	return tileWindow;
}

event InitWindow()
{
	Super.InitWindow();
	
	CurDirectory = class'VMDNative.VMDFileFinder'.Static.GetFileLocation("..\\");
	
	ExitButton = WinButtonBar.AddButton(ExitButtonText, HALIGN_Left);
	LinksButton = WinButtonBar.AddButton(LinksButtonText, HALIGN_Left);
	BackOutButton = WinButtonBar.AddButton(BackOutButtonText, HALIGN_Right);
	OpenSelectButton = WinButtonBar.AddButton(OpenButtonText, HALIGN_Right);
	CreateInfoWindows();
	CreateItemTileWindow();
	
	AddTimer(0.2, True,, 'UpdateInfo');
}

function CreateItemTileWindow()
{
	winTile = CreateScrollTileWindow(TileWindowPos.X, TileWindowPos.Y, TileWindowSize.X, TileWindowSize.Y);
	winTile.SetMinorSpacing(0);
	winTile.SetMargins(0,0);
	winTile.SetOrder(ORDER_Down);
	winTile.SetSensitivity(TRUE);
}

function CreateInfoWindows()
{
	if (WinClient != None)
	{
		WinInfoTitle = VMDMenuUIInfoWindow(NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoTitle.SetPos(WinInfoPos[0].X, WinInfoPos[0].Y);
		WinInfoTitle.SetSize(WinInfoSize[0].X, WinInfoSize[0].Y);
		WinInfoTitle.SetText("");
		
		WinInfoBody = VMDMenuUIInfoWindow(NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoBody.SetPos(WinInfoPos[1].X, WinInfoPos[1].Y);
		WinInfoBody.SetSize(WinInfoSize[1].X, WinInfoSize[1].Y);
		WinInfoBody.SetText("");
		
		WinInfoCurDirectory = VMDMenuUIInfoWindow(NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoCurDirectory.SetPos(WinInfoPos[2].X, WinInfoPos[2].Y);
		WinInfoCurDirectory.SetSize(WinInfoSize[2].X, WinInfoSize[2].Y);
		WinInfoCurDirectory.SetText("");
		
		WinInfoFreeSpace = VMDMenuUIInfoWindow(NewChild(Class'VMDMenuUIInfoWindow'));
		WinInfoFreeSpace.SetPos(WinInfoPos[3].X, WinInfoPos[3].Y);
		WinInfoFreeSpace.SetSize(WinInfoSize[3].X, WinInfoSize[3].Y);
		WinInfoFreeSpace.SetText("");
	}
}

// ----------------------------------------------------------------------
// VANILLA SHIT END!
// ----------------------------------------------------------------------

function PopulateFileList()
{
	local bool bSkip;
	local int TIconType, i;
	local string GetName, TClip, TExtension, TName;
	local VMDMenuFileFinderTile TTile;
	
	SelectedTile = None;
	WinTile.DestroyAllChildren();
	
	forEach class'VMDNative.VMDFileFinder'.Static.FindNextFileAt(CurDirectory$"*", GetName)
	{
		if (GetName == "")
		{
			break;
		}
		
		bSkip = false;
		
		TClip = GetName;
		if (InStr(TClip, ".") > -1)
		{
			while (InStr(TClip, ".") > -1)
			{
				TClip = Right(TClip, Len(TClip) - InStr(TClip, ".") - 1);
			}
			
			TExtension = TClip;
			TName = Left(GetName, Len(GetName) - Len(TClip) - 1);
		}
		else
		{
			TName = GetName;
			TExtension = "Unknown";
		}
		
		switch(TExtension)
		{
			case "FOLDER":
				TIconType = 1;
				for(i=0; i<ArrayCount(KeyFolderNames); i++)
				{
					if (KeyFolderNames[i] ~= TName)
					{
						TIconType = 2;
						break;
					}
				}
			break;
			default:
				//MADDERS, 5/14/25: Skip past these files. They are useless and can clog things up for DXMP players... Cache files be CHUNKY.
				TIconType = 0;
				bSkip = true;
			break;
		}
		
		if (bSkip)
		{
			continue;
		}
		
		//Add tile here?
		TTile = VMDMenuFileFinderTile(WinTile.NewChild(class'VMDMenuFileFinderTile'));
		TTile.SetFileData(TName, TExtension, TIconType);
		TTile.FileWindow = Self;
	}
	
	UpdateInfo();
}

function SelectTile(VMDMenuFileFinderTile TarTile)
{
	if (TarTile == None)
	{
		return;
	}
	
	if ((SelectedTile != None) && (SelectedTile != TarTile))
	{
		SelectedTile.SetHighlight(False);
	}
	
	TarTile.SetHighlight(True);
	
	SelectedTile = TarTile;
	UpdateInfo();
}

function UpdateInfo()
{
	local bool bKeyFolder, bCanBackOut;
	local int i, TIndex;
	local string BuildStr[2], GetName, GetName2;
	local VMDMenuFileFinderTile TarTile;
	
	TarTile = SelectedTile;
	
 	if (TarTile != None)
 	{
		WinInfoTitle.SetTitle(TarTile.FileName);
		
		if (TarTile.IconType > 0)
		{
			TIndex = -1;
			for (i=0; i<ArrayCount(KeyFolderNames); i++)
			{
				if (KeyFolderNames[i] ~= TarTile.FileName)
				{
					TIndex = i;
					break;
				}
			}
			
			WinInfoBody.Clear();
			if (TIndex > -1)
			{
				bKeyFolder = true;
				WinInfoBody.SetText(KeyFolderDescs[TIndex]);
			}
			else
			{
				WinInfoBody.SetText(StrCanOpenFolder);
			}
			
			WinInfoTitle.Clear();
			if (TarTile.IconType > 0)
			{
				WinInfoTitle.SetText(TarTile.FileName);
			}
			else
			{
				WinInfoTitle.SetText(TarTile.FileName$"."$TarTile.ExtensionType);
			}
		}
		else
		{
			WinInfoBody.Clear();
			WinInfoBody.SetText(StrAFile);
		}
	}
	else
	{
		WinInfoTitle.Clear();
		WinInfoTitle.SetText(StrNoFileTitle);
		WinInfoBody.Clear();
		WinInfoBody.SetText(StrSelectAFile);
	}
	
	WinInfoCurDirectory.Clear();
	WinInfoCurDirectory.SetText(SprintF(StrCurDirectory, CurDirectory));
	
	WinInfoFreeSpace.Clear();
	WinInfoFreeSpace.SetText(GetFreeSpaceString());
	
	OpenSelectButton.SetSensitivity(False);
	OpenSelectButton.SetButtonText(OpenButtonText);
	
	BackOutButton.SetSensitivity(False);
	
	if ((TarTile != None) && (TarTile.IconType > 0))
	{
		if (bKeyFolder)
		{
			OpenSelectButton.SetButtonText(SelectButtonText);
			OpenSelectButton.SetSensitivity(HasRequiredSpace(TarTile.FileName));
		}
		else
		{
			OpenSelectButton.SetSensitivity(True);
		}
	}
	
	if (Len(CurDirectory) > 3)
	{
		bCanBackOut = true;
	}
	
	if (bCanBackOut)
	{
		BackOutButton.SetSensitivity(True);
	}
}

function string GetFreeSpaceString()
{
	local int FreeMB;
	local float FreeGB, FreeTB;
	local string Ret, TString;
	
	FreeMB = class'VMDNative.VMDHDSpacefix'.static.GetFreeHDSpace();
	FreeGB = float(FreeMB) / 1024.0;
	FreeTB = FreeGB / 1024.0;
	
	if (FreeTB > 1.0)
	{
		TString = Left(string(FreeTB), Len(string(FreeTB)) - 4)@"TB";
	}
	else if (FreeGB > 1.0)
	{
		TString = Left(string(FreeGB), Len(string(FreeGB)) - 4)@"GB";
	}
	else
	{
		TString = FreeMB@"MB";
	}
	
	Ret = SprintF(StrFreeSpace, TString);
	
	return Ret;
}

function bool HasRequiredSpace(string ModName)
{
	local int FreeMB;
	
	FreeMB = class'VMDNative.VMDHDSpacefix'.static.GetFreeHDSpace();
	
	switch(ModName)
	{
		case "CF":
			if (FreeMB < 17) return false;
		break;
		case "Fgrhk":
			if (FreeMB < 654) return false;
		break;
		case "Mutations":
			if (FreeMB < 69) return false;
		break;
		case "Redsun":
			if (FreeMB < 2048) return false;
		break;
		case "Revision":
			if (FreeMB < 3072) return false;
		break;
		case "TNM2":
			if (FreeMB < 2048) return false;
		break;
		case "ZodiacMaps":
			if (FreeMB < 71) return false;
		break;
		
		//MADDERS, 5/15/25: Hack so we can't install nothing.
		case "VMDSim":
		case "VMDMods":
		case "VMDRevision":
			return false;
		break;
	}
	
	return true;
}

function bool ButtonActivated( Window buttonPressed )
{
	local bool bHandled;
	
	bHandled = True;
	
	Super.ButtonActivated(ButtonPressed);
	
	switch(ButtonPressed)
	{
		case ExitButton:
			AddTimer(0.01, False,, 'DoPop');
		break;
		case LinksButton:
			VMP.ConsoleCommand("Open https://www.moddb.com/mods/vanilla-madder/news/supported-vmd-mods-w-links");
		break;
		case OpenSelectButton:
			if (SelectedTile != None)
			{
				if (SelectedTile.IconType == 2)
				{
					SelectKeyFolder();
				}
				else
				{
					OpenFolder();
				}
			}
			bHandled = True;
		break;
		case BackOutButton:
			BackOutOneDirectory();
			bHandled = True;
		break;
		default:
			bHandled = False;
		break;
	}
	
	return bHandled;
}

function DoPop()
{
	Root.PopWindow();
}

function SelectKeyFolder()
{
	local bool bFullWin;
	local int i, bWon[12], TarIndex;
	local string GetName;
	
	if ((SelectedTile != None) && (SelectedTile.IconType == 2) && (HasRequiredSpace(SelectedTile.FileName)))
	{
		for(i=0; i<ArrayCount(KeyFolderNames); i++)
		{
			if (KeyFolderNames[i] ~= SelectedTile.FileName)
			{
				TarIndex = i;
				break;
			}
		}
		
		bFullWin = true;
		for (i=0; i<ArrayCount(bWon); i++)
		{
			bWon[i] = -1;
		}
		
		switch(SelectedTile.FileName)
		{
			case "CF":
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods");
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Maps");
				bWon[0] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Maps\\", "..\\VMDMods\\Maps\\", "*.dx"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Music");
				bWon[1] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Music\\", "..\\VMDMods\\Music\\", "*.umx"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\System");
				bWon[2] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\System\\", "..\\VMDMods\\System\\", "*.u"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Textures");
				bWon[3] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Textures\\", "..\\VMDMods\\Textures\\", "*.utx"));
			break;
			case "Fgrhk":
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods");
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Maps");
				bWon[0] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Maps\\", "..\\VMDMods\\Maps\\", "*.dx"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Music");
				bWon[1] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Music\\", "..\\VMDMods\\Music\\", "*.ogg"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Sounds");
				bWon[2] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Sounds\\", "..\\VMDMods\\Sounds\\", "*.uax"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\System");
				bWon[3] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\System\\", "..\\VMDMods\\System\\", "*.u"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Textures");
				bWon[4] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Textures\\", "..\\VMDMods\\Textures\\", "*.utx"));
			break;
			case "Mutations":
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods");
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Maps");
				bWon[0] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Maps\\", "..\\VMDMods\\Maps\\", "*.dx"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\System");
				bWon[1] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\System\\", "..\\VMDMods\\System\\", "*.u"));
			break;
			case "Redsun":
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods");
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Maps");
				bWon[0] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Maps\\", "..\\VMDMods\\Maps\\", "*.dx"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Music");
				bWon[1] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Music\\", "..\\VMDMods\\Music\\", "*.umx"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Sounds");
				bWon[2] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Sounds\\", "..\\VMDMods\\Sounds\\", "*.uax"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\System");
				bWon[3] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\System\\", "..\\VMDMods\\System\\", "*.u"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Textures");
				bWon[4] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Textures\\", "..\\VMDMods\\Textures\\", "*.utx"));
			break;
			case "Revision":
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDRevision");
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods");
				
				if (class'VMDStaticFunctions'.Static.GetConflictingMapURLStyle(GetPlayerPawn()) == 1)
				{
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDRevision\\Maps");
					bWon[0] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Maps\\", "..\\VMDRevision\\Maps\\", "*.dx"));
				}
				else
				{
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("00");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("00\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("01");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("01\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("02");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("02\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("03");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("03\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("04");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("04\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("05");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("05\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("06");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("06\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("08");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("08\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("09");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("09\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("10");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("10\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("11");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("11\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("12");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("12\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("14");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("14\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("15");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("15\\VMDRevision");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("99");
					class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("99\\VMDRevision");
					bWon[0] = int(InstallAllRevisionMapFilesFrom(CurDirectory$SelectedTile.FileName$"\\Maps\\"));
				}
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Music");
				bWon[1] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Music\\", "..\\VMDMods\\Music\\", "*.ogg"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Sounds");
				bWon[2] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Sounds\\", "..\\VMDMods\\Sounds\\", "*.uax"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\System");
				bWon[3] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\System\\", "..\\VMDMods\\System\\", "*.u"));
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Textures");
				bWon[4] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\Textures\\", "..\\VMDMods\\Textures\\", "*.utx"));
			break;
			case "ZodiacMaps":
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods");
				
				class'VMDNative.VMDFileFinder'.Static.CreateFolderAt("..\\VMDMods\\Maps");
				bWon[0] = int(InstallAllFilesFrom(CurDirectory$SelectedTile.FileName$"\\", "..\\VMDMods\\Maps\\", "*.dx"));
			break;
		}
		
		for (i=0; i<ArrayCount(bWon); i++)
		{
			if (bWon[i] == 0)
			{
				bFullWin = false;
			}
		}
		
		if (bFullWin)
		{
			Root.MessageBox(PopUpHeader, ModInstalledPopUpText[TarIndex], 1, False, Self);
		}
		else
		{
			Root.MessageBox(PopUpHeader, ModNotInstalledPopUpText[TarIndex], 1, False, Self);
		}
		
		if (CampaignWindow != None)
		{
			CampaignWindow.CreateCampaignLists();
		}
		
		PopulateFileList();
	}
}

event bool BoxOptionSelected(Window msgBoxWindow, int buttonNumber)
{
	switch(ButtonNumber)
	{
		case 0:
			Root.PopWindow();
		break;
	}
	return true;
}

function bool InstallAllFilesFrom(string StartLoc, string EndLoc, string FileExtension)
{
	local bool bWon;
	local string GetName;
	
	forEach class'VMDNative.VMDFileFinder'.Static.FindNextFileAt(StartLoc$FileExtension, GetName)
	{
		//MADDERS, 7/18/25: Revision shit that we don't want. Unnecessary.
		if (Left(GetName, 4) ~= "DXMP")
		{
			bWon = true;
		}
		else if (Left(GetName, 11) ~= "97_Survival")
		{
			bWon = true;
		}
		else if (Left(GetName, 5) ~= "Arena")
		{
			bWon = true;
		}
		else if (Left(GetName, 9) ~= "Benchmark")
		{
			bWon = true;
		}
		else if (Left(GetName, 9) ~= "Challenge")
		{
			bWon = true;
		}
		else
		{
			switch(GetName)
			{
				case "DX.dx":
				case "DXOnly.dx":
				case "Entry.dx":
				case "InfoPortraits.utx":
				case "NewGamePlusLiaison.dx":
					//Do nothing. We're bad to copy.
					bWon = true;
				break;
				default:
					bWon = class'VMDNative.VMDFileFinder'.Static.CopyFileFrom(StartLoc$GetName, EndLoc$GetName);
				break;
			}
		}
		
		if (!bWon)
		{
			return false;
		}
	}
	
	//MADDERS, 5/15/25: Make sure we report failure upon not finding ANY files.
	if (!bWon)
	{
		return false;
	}
	
	return true;
}

function bool InstallAllRevisionMapFilesFrom(string StartLoc)
{
	local bool bWon;
	local string GetName, MissionClone;
	
	forEach class'VMDNative.VMDFileFinder'.Static.FindNextFileAt(StartLoc$"*.dx", GetName)
	{
		//MADDERS, 7/18/25: Revision shit that we don't want. Unnecessary.
		if (Left(GetName, 4) ~= "DXMP")
		{
			bWon = true;
		}
		else if (Left(GetName, 11) ~= "97_Survival")
		{
			bWon = true;
		}
		else if (Left(GetName, 5) ~= "Arena")
		{
			bWon = true;
		}
		else if (Left(GetName, 9) ~= "Benchmark")
		{
			bWon = true;
		}
		else if (Left(GetName, 9) ~= "Challenge")
		{
			bWon = true;
		}
		else
		{
			switch(GetName)
			{
				case "DX.dx":
				case "DXOgg.u":
				case "DXOnly.dx":
				case "Entry.dx":
				case "InfoPortraits.utx":
				case "NewGamePlusLiaison.dx":
					//Do nothing. We're bad to copy.
					bWon = true;
				break;
				default:
					MissionClone = Left(GetName, 2);
					bWon = class'VMDNative.VMDFileFinder'.Static.CopyFileFrom(StartLoc$GetName, MissionClone$"\\VMDRevision\\"$GetName);
				break;
			}
		}
		
		if (!bWon)
		{
			return false;
		}
	}
	
	//MADDERS, 5/15/25: Make sure we report failure upon not finding ANY files.
	if (!bWon)
	{
		return false;
	}
	
	return true;
}

function OpenFolder()
{
	if ((SelectedTile != None) && (SelectedTile.IconType == 1))
	{
		CurDirectory = CurDirectory$SelectedTile.FileName$"\\";
		PopulateFileList();
	}
}

function BackOutOneDirectory()
{
	local string TClip;
	
	if (Right(CurDirectory, 3) == "..\\")
	{
		CurDirectory = CurDirectory $ "..\\";
	}
	else
	{
		TClip = Left(CurDirectory, Len(CurDirectory) - 1);
		while(InStr(TClip, "\\") > -1)
		{
			TClip = Right(TClip, Len(TClip) - InStr(TClip, "\\") - 1);
		}
		
		CurDirectory = Left(CurDirectory, Len(CurDirectory) - Len(TClip) - 1);
	}
	PopulateFileList();
}

defaultproperties
{
     CurDirectory="..\\"
     StrSelectAFile="Please select a relevant folder."
     StrAFile="This is a single file. You need to locate a relevant folder."
     StrCanOpenFolder="While not a key mod folder, this may contain a mod folder from which to install things."
     StrNoFileTitle="No file or folder selected"
     StrCurDirectory="Browsing:|n%s"
     StrFreeSpace="Free Space: %s"
     PopupHeader="Notice"
     
     TileWindowPos=(X=18,Y=2)
     TileWindowSize=(X=274,Y=444)
     
     WinInfoPos(0)=(X=334,Y=12)
     WinInfoSize(0)=(X=173,Y=40)
     WinInfoPos(1)=(X=334,Y=31)
     WinInfoSize(1)=(X=173,Y=244)
     WinInfoPos(2)=(X=334,Y=123)
     WinInfoSize(2)=(X=173,Y=120)
     WinInfoPos(3)=(X=334,Y=183)
     WinInfoSize(3)=(X=173,Y=40)
     
     Title="Mod Locator"
     LinksButtonText="|&Links"
     ExitButtonText="|&Exit"
     OpenButtonText="|&Open"
     SelectButtonText="|&Install"
     BackOutButtonText="|&Back Out"
     ClientWidth=512
     ClientHeight=448
     
     clientTextures(0)=Texture'VMDModLocatorListWindowBG01'
     clientTextures(1)=Texture'VMDModLocatorListWindowBG02'
     clientTextures(2)=Texture'VMDModLocatorListWindowBG03'
     clientTextures(3)=Texture'VMDModLocatorListWindowBG04'
     
     bActionButtonBarActive=True
     bUsesHelpWindow=False
     ScreenType=ST_Persona
     TextureRows=2
     TextureCols=2
     
     KeyFolderNames(0)="CF"
     KeyFolderDescs(0)="These are the files for Counterfeit Demo, an incomplete total conversion mod.|n|nSpace Required: 17 MB"
     ModInstalledPopupText(0)="You have successfully installed Counterfeit Demo."
     ModNotInstalledPopupText(0)="There was an error installing Counterfeit Demo."
     KeyFolderNames(1)="Fgrhk"
     KeyFolderDescs(1)="These are the files for Deus Ex Nihilum, a rather large and involved mod.|n|nSpace Required: 654 MB"
     ModInstalledPopupText(1)="You have successfully installed Deus Ex: Nihilum."
     ModNotInstalledPopupText(1)="There was an error installing Deus Ex: Nihilum."
     //KeyFolderNames(2)="HotelCarone"
     //KeyFolderDescs(2)="These are the files for Hotel Carone, a total conversion hardly the size of a fan mission."
     //ModInstalledPopupText(2)="You have successfully installed Hotel Carone."
     //ModNotInstalledPopupText(2)="There was an error installing Hotel Carone."
     KeyFolderNames(3)="Mutations"
     KeyFolderDescs(3)="These are the files for Deus Ex Mutations, a maze-like, decent length total conversion.|n|nSpace Required: 69 MB"
     ModInstalledPopupText(3)="You have successfully installed Deus Ex Mutations."
     ModNotInstalledPopupText(3)="There was an error installing Deus Ex Mutations."
     KeyFolderNames(4)="Redsun"
     KeyFolderDescs(4)="These are the files for Redsun 2020, a semi-large size total conversion.|n|nSpace Required: 2 GB (W/ Revise Buffer)"
     ModInstalledPopupText(4)="You have successfully installed Redsun 2020."
     ModNotInstalledPopupText(4)="There was an error installing Redsun 2020."
     KeyFolderNames(5)="Revision"
     KeyFolderDescs(5)="These are the files for Deus Ex Revision, a map remix and gameplay changing mod.|n|nSpace Required: 3 GB (W/ Beta Buffer)"
     ModInstalledPopupText(5)="You have successfully installed Deus Ex Revision."
     ModNotInstalledPopupText(5)="There was an error installing Deus Ex Revision."
     //KeyFolderNames(6)="TNM2"
     //KeyFolderDescs(6)="These are the files for The Nameless Mod 2.0, perhaps the largest total conversion for Deus Ex.|n|nSpace Required: 2 GB"
     //ModInstalledPopupText(6)="You have successfully installed The Nameless Mod 2.0."
     //ModNotInstalledPopupText(6)="There was an error installing ThE Nameless Mod 2.0."
     KeyFolderNames(7)="VMDMods"
     KeyFolderDescs(7)="These are the files referenced for use with VMD's modded campaigns. You do not need to be concerned with them."
     KeyFolderNames(8)="VMDSim"
     KeyFolderDescs(8)="These are the files referenced for use with VMD. You do not need to be concerned with them."
     KeyFolderNames(9)="VMDRevision"
     KeyFolderDescs(9)="These are the files referenced for use with VMD's Revision map play feature. You do not need to be concerned with them."
     KeyFolderNames(10)="ZodiacMaps"
     KeyFolderDescs(10)="These are the files for Deus Ex: Zodiac, a medium sized total conversion.|n|nSpace Required: 71 MB"
     ModInstalledPopupText(10)="You have successfully installed Deus Ex: Zodiac"
     ModNotInstalledPopupText(10)="There was an error installing Deus Ex: Zodiac"
}
