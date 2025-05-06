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
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Relevant object was none!");
		*(FString*)Result = L"";
		return;
	}
	
	UProperty *PropType = FindObject<UProperty>( NULL, *StartProp );
	
	if(!PropType)
    {
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Prop type was none!");
		*(FString*)Result = L"";
		return;
	}

	if(!PropType)
    {
		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Prop type was none!");
		*(FString*)Result = L"";
		return;
	}

    if(ArrayIndex < 0 || ArrayIndex >= PropType->ArrayDim)
    {
 		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Array index was out of bounds!");
		*(FString*)Result = L"";
		return;
	}
	
    if(!RelevantObject->GetClass()->IsChildOf(PropType->GetOwnerClass()))
    {
 		GLog -> Logf(L"WARNING: VMDGenericNativeFunctions.SetArrayPropertyText: Relevant Object is not related to Property's owner class!");
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
	
    UFunction *OriginalFunction = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, *OriginalFunctionName));
    UFunction *SwapFunction = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, *NewFunctionName));
	if (OriginalFunction && SwapFunction)
	{
		OriginalFunction->Script = SwapFunction->Script;
		*(BOOL*)Result = true;
		return;
	}

	*(BOOL*)Result = false;
}



IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,2197,execGetArrayPropertyText);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,2196,execSetArrayPropertyText);
IMPLEMENT_FUNCTION(AVMDGenericNativeFunctions,2195,execSwapTargetScripts);