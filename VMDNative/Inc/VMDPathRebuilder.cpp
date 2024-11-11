
#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDPathRebuilder);

void AVMDPathRebuilder::execAllowScoutToSpawn(FFrame &Stack, RESULT_DECL)
{
    P_GET_UBOOL(Flag);
    P_FINISH;

    // The engine asserts when trying to spawn the Scout in native code,
    // so it will be spawned from Unrealscript instead.
	
    // The Scout defines the PreBeginPlay event as the following:
	
    // function PreBeginPlay()
    // {
    //     Destroy();
    // }
	
    // This prevents it from being spawned from scripts, but ProcessEvent
    // will only call events that FUNC_DEFINED, so it's temporarily unset
    // while the paths are being rebuilt.
	
    UFunction *ScoutPreBeginPlay = Cast<UFunction>(UObject::StaticFindObject(
        UFunction::StaticClass(),
        ANY_PACKAGE,
        TEXT("Engine.Scout.PreBeginPlay")
    ));
	
    if(Flag)
        ScoutPreBeginPlay.FunctionFlags |= (1 << FUNC_DEFINED);
    else
        ScoutPreBeginPlay.FunctionFlags &= ~(1 << FUNC_DEFINED);
}

void AVMDPathRebuilder::execScoutSetup(FFrame &Stack, RESULT_DECL)
{
    P_GET_OBJECT(APawn, Scout);
    P_FINISH;
	
    ULevel *CurrentLevel = GetLevel();
    
    Scout->SetCollision(1, 1, 1);
    Scout->bCollideWorld = 1;
	
    CurrentLevel->SetActorZone(Scout, 1, 1);
}

void AVMDPathRebuilder::execRedefinePaths(FFrame &Stack, RESULT_DECL)
{
    P_FINISH;
    
    ULevel *CurrentLevel = GetLevel();
	
    FPathBuilder PathBuilder;
	
    PathBuilder.undefinePath(CurrentLevel);
    PathBuilder.definePaths(CurrentLevel);
}

IMPLEMENT_FUNCTION(AVMDPathRebuilder,2204,execAllowScoutToSpawn);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,2205,execScoutSetup);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,2206,execRedefinePaths);
