#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDLightRebuilder);

//Rebuild lighting. Yay.
void AVMDLightRebuilder :: execRebuildLighting(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDLightRebuilder::execRebuildLighting);
	P_FINISH;
	
	// Find the game engine object
	UGameEngine* TheGameEngine = NULL;
	
	for(TObjectIterator<UGameEngine> It; It; ++It)
	{
	    TheGameEngine = *It;
	    break;
	}
	
	if(!TheGameEngine)
	{
	   appErrorf(L"CrackheadLighting: No game engine found!");
	}
	
	UEditorEngine* MyEditorEngine = new UEditorEngine();
	
	MyEditorEngine->Level = TheGameEngine->GLevel;
	MyEditorEngine->TempModel = new UModel(NULL);
	MyEditorEngine->Render = TheGameEngine->Render;
	
	// Client is needed to render the map when it changes
	MyEditorEngine->Client = TheGameEngine->Client;
	
	// This may or may not be needed?
	// Create the editor history history buffer
	MyEditorEngine->CreateTrans();
	
	//Rebuilding lighting, finally.
	MyEditorEngine->shadowIlluminateBsp(MyEditorEngine->Level, false);
	//MyEditorEngine->bspRefresh(MyEditorEngine->TempModel, false);
	//MyEditorEngine->bspOptGeom(MyEditorEngine->TempModel);

	unguardexec;
};

IMPLEMENT_FUNCTION(AVMDLightRebuilder,2199,execRebuildLighting);
