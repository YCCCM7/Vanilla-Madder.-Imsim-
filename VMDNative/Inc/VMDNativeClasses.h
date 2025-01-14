/*===========================================================================
    C++ class definitions exported from UnrealScript.
    This is automatically generated by the tools.
    DO NOT modify this manually! Edit the corresponding .uc files instead!
===========================================================================*/
#if _MSC_VER
#pragma pack (push,4)
#endif

#ifndef VMDNATIVE_API
#define VMDNATIVE_API DLL_IMPORT
#endif

#ifndef NAMES_ONLY
#define AUTOGENERATE_NAME(name) extern VMDNATIVE_API FName VMDNATIVE_##name;
#define AUTOGENERATE_FUNCTION(cls,idx,name)
#endif


#ifndef NAMES_ONLY


class VMDNATIVE_API AVMDPathRebuilder : public AActor
{
public:
    DECLARE_FUNCTION(execRedefinePaths);
    DECLARE_FUNCTION(execScoutSetup);
    DECLARE_FUNCTION(execAllowScoutToSpawn);
    DECLARE_CLASS(AVMDPathRebuilder,AActor,0)
    NO_DEFAULT_CONSTRUCTOR(AVMDPathRebuilder)
};


class VMDNATIVE_API AVMDHDSpacefix : public AActor
{
public:
    DECLARE_FUNCTION(execGetFreeHDSpace);
    DECLARE_CLASS(AVMDHDSpacefix,AActor,0)
    NO_DEFAULT_CONSTRUCTOR(AVMDHDSpacefix)
};

class VMDNATIVE_API AVMDUnlitFixer : public AActor
{
public:
    DECLARE_FUNCTION(execPatchUnlitSurfaces);
    DECLARE_CLASS(AVMDUnlitFixer,AActor,0)
    NO_DEFAULT_CONSTRUCTOR(AVMDUnlitFixer)
};

class VMDNATIVE_API UKentiesUIFix : public UObject
{
public:
    DECLARE_FUNCTION(execApplyScaling);
    DECLARE_FUNCTION(execAssertHook);
    DECLARE_CLASS(UKentiesUIFix,UObject,0)
    NO_DEFAULT_CONSTRUCTOR(UKentiesUIFix)
};

#endif

AUTOGENERATE_FUNCTION(UKentiesUIFix,2203,execApplyScaling);
AUTOGENERATE_FUNCTION(UKentiesUIFix,2202,execAssertHook);
AUTOGENERATE_FUNCTION(AVMDUnlitFixer,2207,execPatchUnlitSurfaces);
AUTOGENERATE_FUNCTION(AVMDPathRebuilder,2206,execRedefinePaths);
AUTOGENERATE_FUNCTION(AVMDPathRebuilder,2205,execScoutSetup);
AUTOGENERATE_FUNCTION(AVMDPathRebuilder,2204,execAllowScoutToSpawn);
AUTOGENERATE_FUNCTION(AVMDHDSpacefix,2200,execGetFreeHDSpace);

#ifndef NAMES_ONLY
#undef AUTOGENERATE_NAME
#undef AUTOGENERATE_FUNCTION
#endif NAMES_ONLY

#if _MSC_VER
#pragma pack (pop)
#endif
