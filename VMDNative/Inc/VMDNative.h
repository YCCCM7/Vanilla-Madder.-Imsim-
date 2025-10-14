//Created by WCCC.

#ifndef _INC_VMDNATIVE
#define _INC_VMDNATIVE

#ifndef VMDNATIVE_API
#define VMDNATIVE_API DLL_IMPORT
#endif

//Core dependencies? Probably
#include "windows.h"	//Necessary for detours?
#include "stdio.h"
#include "string.h"
#include "Core.h"
#include "Engine.h"
#include "EditorPrivate.h"
#include "Editor.h"
#include "UnPath.h"
#include "Extension.h"
#include "DeusEx.h"
#include "DeusExGameEngine.h"

//What we ACTUALLY do...
#include "XRootWindowOverlay.h"
#include "VMDNativeClasses.h"

#endif