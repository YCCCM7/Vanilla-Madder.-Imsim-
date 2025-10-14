# Microsoft Developer Studio Project File - Name="VMDNative" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=VMDNative - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "VMDNative.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "VMDNative.mak" CFG="VMDNative - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "VMDNative - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "VMDNative - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "VMDNative - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VMDNATIVE_EXPORTS" /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VMDNATIVE_EXPORTS" /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /machine:I386

!ELSEIF  "$(CFG)" == "VMDNative - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Lib"
# PROP Intermediate_Dir "Lib"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /D "_USRDLL" /D "VMDNATIVE_EXPORTS" /YX /FD /GZ /c
# ADD CPP /nologo /Zp4 /MD /W4 /WX /vd0 /GX /O2 /I ".\Inc" /I "..\Headers\Core\Inc" /I "..\Headers\Engine\Inc" /I "..\Headers\Engine\Src" /I "..\Headers\Editor\Inc" /I "..\Headers\Editor\Src" /I "..\Headers\Extension\Inc" /I "..\Headers\DeusEx\Inc" /D "NDEBUG" /D ThisPackage=VMDNative /D "WIN32" /D "_WINDOWS" /D "UNICODE" /D "_UNICODE" /D VMDNATIVE_API=__declspec(dllexport) /FR /FD
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /dll /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ..\Core\Lib\Core.lib ..\Engine\Lib\Engine.lib ..\Editor\Lib\Editor.lib ..\Extension\Lib\Extension.lib ..\DeusEx\Lib\DeusEx.lib User32.lib Shell32.lib /nologo /dll /incremental:no /machine:I386 /out:"..\System\VMDNative.dll" /pdbtype:sept
# SUBTRACT LINK32 /pdb:none

!ENDIF 

# Begin Target

# Name "VMDNative - Win32 Release"
# Name "VMDNative - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat"
# Begin Source File

SOURCE=.\Inc\AVMDFileFinder.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDGenericNativeFunctions.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDHDSpaceFix.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDLightRebuilder.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDNihilumCleaner.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDPathRebuilder.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDTerrainReskinner.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\AVMDUnlitFixer.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\UGetNextMissionNumberFixer.cpp
# End Source File
# Begin Source File

SOURCE=.\Inc\UKentiesUIFix.cpp
# End Source File
# Begin Source File

SOURCE=.\Src\VMDNative.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl"
# Begin Source File

SOURCE=.\Inc\VMDNative.h
# End Source File
# Begin Source File

SOURCE=.\Inc\VMDNativeClasses.h
# End Source File
# Begin Source File

SOURCE=.\Inc\XRootWindowOverlay.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;rgs;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project
