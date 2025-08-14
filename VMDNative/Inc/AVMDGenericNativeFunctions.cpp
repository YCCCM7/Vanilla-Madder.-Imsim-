#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDGenericNativeFunctions);

void AVMDGenericNativeFunctions::execGetArrayPropertyText(FFrame &Stack, void *Result)
{
    P_GET_OBJECT(UObject, RelevantObject);
 	//P_GET_OBJECT(UProperty, PropType);
	P_GET_STR(StartProp);
    P_GET_INT(ArrayIndex);
	P_FINISH;
	
    if(!RelevantObject)
    {
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.GetArrayPropertyText: Relevant object was none!");
		*(FString*)Result = L"";
		return;
	}
	
	UProperty *PropType = FindObject<UProperty>( NULL, *StartProp );
	
	if(!PropType)
    {
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.GetArrayPropertyText: Prop type was none!");
		*(FString*)Result = L"";
		return;
	}
	
    if(ArrayIndex < 0 || ArrayIndex >= PropType->ArrayDim)
    {
 		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.GetArrayPropertyText: Array index was out of bounds!");
		*(FString*)Result = L"";
		return;
	}
	
    if(!RelevantObject->GetClass()->IsChildOf(PropType->GetOwnerClass()))
    {
 		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.GetArrayPropertyText: Relevant Object is not related to Property's owner class!");
		*(FString*)Result = L"";
		return;
	}
	
	TCHAR ReceivedValues[4096];
	PropType->ExportText(ArrayIndex, ReceivedValues, (BYTE*)RelevantObject, NULL, CPF_Localized);

	*(FString*)Result = ReceivedValues;
}

void AVMDGenericNativeFunctions::execSetArrayPropertyText(FFrame &Stack, void *Result)
{
    P_GET_OBJECT(UObject, RelevantObject);
 	//P_GET_OBJECT(UProperty, PropType);
	P_GET_STR(StartProp);
    P_GET_INT(ArrayIndex);
    P_GET_STR(PropValue);
	P_FINISH;
	
    if(!RelevantObject)
    {
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Relevant object was none!");
		*(BOOL*)Result = false;
		return;
	}
	
	UProperty *PropType = FindObject<UProperty>( NULL, *StartProp );
	
	if(!PropType)
    {
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Prop type was none!");
		*(BOOL*)Result = false;
		return;
	}

    if(ArrayIndex < 0 || ArrayIndex >= PropType->ArrayDim)
    {
 		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Array index was out of bounds!");
		*(BOOL*)Result = false;
		return;
	}
	
    if(!RelevantObject->GetClass()->IsChildOf(PropType->GetOwnerClass()))
    {
 		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Relevant Object is not related to Property's owner class!");
		*(BOOL*)Result = false;
		return;
	}

	INT Offset = PropType->Offset + (PropType->ElementSize * ArrayIndex);

	if (PropValue.InStr(L".", 0))
	{
		UTexture *LoadTexture = FindObject<UTexture>(NULL, *PropValue);
		if (!LoadTexture)
		{
			UMesh *LoadMesh = FindObject<UMesh>(NULL, *PropValue);
			if (!LoadMesh)
			{
				USound *LoadSound = FindObject<USound>(NULL, *PropValue);
				if (!LoadSound)
				{
					UClass *LoadClass = FindObject<UClass>(NULL, *PropValue);
					if (!LoadClass)
					{
						//Do nothing? We won?
					}
					else
					{
						*(UClass**)((BYTE*)RelevantObject + Offset) = LoadClass;
						*(BOOL*)Result = true;
						return;
					}
				}
				else
				{
					*(USound**)((BYTE*)RelevantObject + Offset) = LoadSound;
					*(BOOL*)Result = true;
					return;
				}
			}
			else
			{
				*(UMesh**)((BYTE*)RelevantObject + Offset) = LoadMesh;
				*(BOOL*)Result = true;
				return;
			}
		}
		else
		{
			*(UTexture**)((BYTE*)RelevantObject + Offset) = LoadTexture;
			*(BOOL*)Result = true;
			return;
		}
	}

	//None of the other types mattered. Export it.
    PropType->ImportText(*PropValue, (BYTE*)this + Offset, PPF_Localized);

	*(BOOL*)Result = true;
}



void AVMDGenericNativeFunctions::execSwapTargetScripts(FFrame &Stack, void *Result)
{
	P_GET_STR(OriginalFunctionName);
    P_GET_STR(NewFunctionName);
	P_FINISH;
	
    UFunction *OriginalFunction = FindObject<UFunction>(ANY_PACKAGE, *OriginalFunctionName);
    UFunction *SwapFunction = FindObject<UFunction>(ANY_PACKAGE, *NewFunctionName);
	
	if (OriginalFunction && SwapFunction)
	{
		OriginalFunction->Script = SwapFunction->Script;
		*(BOOL*)Result = true;
		return;
	}
	
	*(BOOL*)Result = false;
}

void AVMDGenericNativeFunctions::execTargetScriptsAreEqual(FFrame &Stack, void *Result)
{
	P_GET_STR(FirstTargetFunction);
	P_GET_STR(SecondTargetFunction);
	P_FINISH;
	
    UFunction *OriginalFunction = FindObject<UFunction>(ANY_PACKAGE, *FirstTargetFunction);
    UFunction *CheckFunction = FindObject<UFunction>(ANY_PACKAGE, *SecondTargetFunction);
	
	*(BOOL*)Result = false;
	if (OriginalFunction && CheckFunction)
	{
		*(BOOL*)Result = true;
		
		if (OriginalFunction->Script.Num() != CheckFunction->Script.Num())
		{
			*(BOOL*)Result = false;
		}
		else
		{
			for(INT RowIdx = 0; RowIdx < OriginalFunction->Script.Num(); RowIdx++)
			{
				if (OriginalFunction->Script(RowIdx) != CheckFunction->Script(RowIdx))
				{
					*(BOOL*)Result = false;
					break;
				}
			}
		}
	}
}

void AVMDGenericNativeFunctions::execHexDumpScript(FFrame &Stack, void *Result)
{
    P_GET_STR(InName);
    P_FINISH;
    
    UFunction *Function = FindObject<UFunction>(ANY_PACKAGE, *InName);

    TCHAR Line[33];

    if(Function)
    {
        INT ScriptSize = Function->Script.Num();
        INT NumRows = ScriptSize / 16;

        /* Split the dump into blocks of 16 bytes */

        for(INT RowIdx = 0; RowIdx < NumRows; RowIdx++)
        {
            for(INT ColIdx = 0; ColIdx < 16; ColIdx++)
            {
                INT ScriptIdx = RowIdx * 16 + ColIdx;

                appSprintf(&Line[ColIdx * 2], TEXT("%02x"), Function->Script(ScriptIdx));
            }

            debugf(Line);
        }

        INT RemainingNum = ScriptSize % 16;

        if(RemainingNum)
        {
            for(INT RemainingIdx = 0; RemainingIdx < RemainingNum; RemainingIdx++)
            {
                INT ScriptIdx = NumRows * 16 + RemainingIdx;

                appSprintf(&Line[RemainingIdx * 2], TEXT("%02x"), Function->Script(ScriptIdx));
            }

            debugf(Line);
        }
    }
}

/*void AVMDGenericNativeFunctions::execClonePawn(FFrame &Stack, void *Result)
{
	P_GET_OBJECT(APawn, OriginalPawn);
	P_GET_OBJECT(APawn, DuplicatePawn);
	P_FINISH;
	
	UClass *ScriptedPawn = FindObject<UClass>(ANY_PACKAGE, TEXT("DeusEx.ScriptedPawn"));
	
	if (!OriginalPawn || !OriginalPawn->GetClass()->IsChildOf(ScriptedPawn) || !DuplicatePawn || !DuplicatePawn->GetClass()->IsChildOf(ScriptedPawn))
	{
		GLog->Logf(TEXT("NO INPUT PAWNS!"));
		return;
	}
	
	// Step 1: Clone all properties owned by the pawn, except for the bad ones.
	TArray<UProperty*> BadProps;
	
	BadProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.Instigator")));
	BadProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Pawn.NextPawn")));
	BadProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.LevelInfo.PawnList")));

	TArray<UProperty*> LegitProps;
	
	LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.Tag")));
	LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.Location")));
	LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.OldLocation")));
	LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.ColLocation")));
	//LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.Rotation")));
	LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("Engine.Actor.BindName")));
	//LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("DeusEx.ScriptedPawn.Orders")));
	//LegitProps.AddItem(FindObject<UProperty>(ANY_PACKAGE, TEXT("DeusEx.ScriptedPawn.OrderTag")));
	
	UClass *ObjectRef = FindObject<UClass>(ANY_PACKAGE, TEXT("Core.Object"));
	
	//INT Offset = 0;
    TFieldIterator<UProperty> PropIt(DuplicatePawn->GetClass());
	
    while(PropIt)
    {
		UProperty* Prop = *PropIt;
		
		const TCHAR *StartLetter = Prop->GetName();
		//debugf(TEXT("%s"), StartLetter);
		FString HackLetter = FString(StartLetter).Left(1);
		if (LegitProps.FindItemIndex(Prop) == INDEX_NONE)
		{
			//if (HackLetter != FString(L"B"))
			//{
				++PropIt;
				continue;
			//}
		}
		//GLog->Logf(*HackLetter);

		if (BadProps.FindItemIndex(Prop) == INDEX_NONE && Prop->GetOwnerClass() != ObjectRef)
		{
			Prop->CopyCompleteValue((BYTE*)DuplicatePawn + Prop->Offset, (BYTE*)OriginalPawn + Prop->Offset);
			debugf(TEXT("CHANGED PROP %s!"), Prop->GetName());
		}
		++PropIt;
	}
}*/

void AVMDGenericNativeFunctions::execSwapGNative(FFrame &Stack, void *Result)
{
	P_GET_INT(TarNative);
	P_GET_STR(ParameterTypes);
	P_FINISH;
	
	if (ParameterTypes == TEXT(""))
	{
		GLog -> Logf(TEXT("SWAPPING GNATIVE FOR BLANK!"));
		GNatives[TarNative] = reinterpret_cast<Native>(&AVMDGenericNativeFunctions::execGNativeSwap0);
	}
}

void AVMDGenericNativeFunctions::execGNativeSwap0(FFrame &Stack, void *Result)
{
	P_FINISH;
}

IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execGetArrayPropertyText);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execSetArrayPropertyText);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execSwapTargetScripts);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execTargetScriptsAreEqual);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execHexDumpScript);
//IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execForceConBindEvents);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execSwapGNative);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,-1,execGNativeSwap0);