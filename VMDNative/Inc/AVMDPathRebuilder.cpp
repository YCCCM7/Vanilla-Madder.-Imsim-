
#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDPathRebuilder);

void AVMDPathRebuilder::execAllowScoutToSpawn(FFrame &Stack, RESULT_DECL)
{
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
	
    UFunction *FuckPreBeginPlay = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("VMDNative.VMDPathRebuilder.FuckPreBeginPlay")));
    
    UFunction *ScoutPreBeginPlay = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("Engine.Scout.PreBeginPlay")));
    
    ScoutPreBeginPlay->Script = FuckPreBeginPlay->Script;
}

void AVMDPathRebuilder::execScoutSetup(FFrame &Stack, RESULT_DECL)
{
    P_GET_OBJECT(APawn, Scout);
    P_FINISH;
	
    ULevel *CurrentLevel = GetLevel();
    
	Scout->bDetectable = 0; //4/29/25: Stop triggering triggers.
	Scout->bCanTeleport = 0; //4/29/25: Stop triggering teleporters.
    Scout->SetCollision(true, true, true);
    Scout->bCollideWorld = 1;
	
    CurrentLevel->SetActorZone(Scout, 1, 1);
}

void AVMDPathRebuilder::execRedefinePaths(FFrame &Stack, RESULT_DECL)
{
    P_FINISH;
    
    ULevel *CurrentLevel = GetLevel();
	
    FPathBuilder PathBuilder;
	
    PathBuilder.undefinePaths(CurrentLevel);
    PathBuilder.definePaths(CurrentLevel);
}

IMPLEMENT_FUNCTION(AVMDPathRebuilder,2204,execAllowScoutToSpawn);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,2205,execScoutSetup);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,2206,execRedefinePaths);
