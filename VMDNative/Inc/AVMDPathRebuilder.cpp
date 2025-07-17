
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
    
	Scout->bHidden = 1; //We can be seen on some maps. Oops.
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

//HACKY DEBUGGING!
void AVMDPathRebuilder::execBeginShakedown(FFrame& Stack, RESULT_DECL)
{
    P_GET_OBJECT(UObject, TargetObj);
    P_FINISH;

    INT PropertiesSize = TargetObj->GetClass()->GetPropertiesSize();
    void* LastState = appMalloc(PropertiesSize, TEXT(""));

    appMemcpy(LastState, TargetObj, PropertiesSize);

    *(INT*)Result = (INT)LastState;
}

void AVMDPathRebuilder::execEndShakedown(FFrame& Stack, RESULT_DECL)
{
    P_GET_OBJECT(UObject, TargetObj);
    P_GET_INT(LastState);
    P_FINISH;

    TFieldIterator<UProperty> FieldIt(TargetObj->GetClass());

    while(FieldIt)
    {
        for(int ArrayIdx = 0; ArrayIdx < FieldIt->ArrayDim; ++ArrayIdx)
        {
            if(FieldIt->Matches(TargetObj, (BYTE*)LastState, ArrayIdx))
            {
                continue;
            }

            //TCHAR OldValue[1024];
            //TCHAR NewValue[1024];
			
			
			
            //BYTE* Defaults = &TargetObj->GetClass()->Defaults(0);

            //FieldIt->ExportText(ArrayIdx, OldValue, (BYTE*)LastState, NULL, 1);
            //FieldIt->ExportText(ArrayIdx, NewValue, (BYTE*)*FieldIt, NULL, 1);

            if(FieldIt->ArrayDim > 1)
            {
				//debugf(TEXT("%s[%i] changed from '%s' to '%s'"), FieldIt->GetName(), ArrayIdx, OldValue, NewValue);
 				debugf(TEXT("%s[%i] changed"), FieldIt->GetName(), ArrayIdx);
            }
            else
            {
                //debugf(TEXT("%s changed from '%s' to '%s'"), FieldIt->GetName(), OldValue, NewValue);
				debugf(TEXT("%s changed"), FieldIt->GetName());
            }
        }

        ++FieldIt;
    }

    appFree((BYTE*)LastState);
}

IMPLEMENT_FUNCTION(AVMDPathRebuilder,-1,execAllowScoutToSpawn);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,-1,execScoutSetup);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,-1,execRedefinePaths);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,-1,execBeginShakedown);
IMPLEMENT_FUNCTION(AVMDPathRebuilder,-1,execEndShakedown);
