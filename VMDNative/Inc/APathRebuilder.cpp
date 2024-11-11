
#include "VMDNative.h"

IMPLEMENT_CLASS(APathRebuilder);

//Do some serious sorcery. Fuck around, and find out.
void APathRebuilder :: execRebuildPaths(FFrame& Stack, RESULT_DECL)
{
	guard(APathRebuilder::execRebuildPaths);
	P_GET_UBOOL(bInitializing);
	P_GET_OBJECT(AScout, TScout);
	P_FINISH;
	
	if (bInitializing)
	{
		UFunction *FuckPreBeginPlay = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("VMDNative.PathRebuilder.FuckPreBeginPlay")));
		
		UFunction *ScoutPreBeginPlay = Cast<UFunction>(UObject::StaticFindObject(UFunction::StaticClass(), ANY_PACKAGE, TEXT("Engine.Scout.PreBeginPlay")));
		
		ScoutPreBeginPlay->Script = FuckPreBeginPlay->Script;
	}
	else
	{
		ULevel *TLevel = 0;
		for(TObjectIterator<AActor> I; I; ++I)
		{
			//Legit, and not dead? Cool.
			if(I && !I->IsPendingKill())
			{;
				TLevel = I->GetLevel();
				break;
			}
		}
		
		if (TLevel != 0 && TScout != 0)
		{
			TLevel->SetActorZone(TScout, 1, 1);
			
			FPathBuilder Builder;
			
			GLog -> Logf(TEXT("HAS LEVEL!"));
			TLevel -> Modify();
			Builder.buildPaths(TLevel, 0);
		}
	}
	unguardexec;
};

IMPLEMENT_FUNCTION(APathRebuilder,2201,execRebuildPaths);
