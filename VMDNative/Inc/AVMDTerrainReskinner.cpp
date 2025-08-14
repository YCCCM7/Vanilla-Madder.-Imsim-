#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDTerrainReskinner);

//Rebuild lighting. Yay.
void AVMDTerrainReskinner :: execLogSurfaceTextures(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDLightRebuilder::execLogSurfaceTextures);
	P_GET_OBJECT(ULevel, Level);
	P_FINISH;
	
	if (Level)
	{
		for(INT PolyIndex = 0; PolyIndex < Level->Model->Surfs.Num(); PolyIndex++)
		{
			if (Level->Model->Surfs(PolyIndex).Texture != 0)
			{
				const TCHAR* TName = (Level->Model->Surfs(PolyIndex).Texture->GetName());
				debugf(TEXT("POLY %i IS %s"), PolyIndex, TName);
			}
		}
	}
	
	unguardexec;
};

void AVMDTerrainReskinner :: execSetSurfaceTexture(FFrame& Stack, RESULT_DECL)
{
	guard(AVMDLightRebuilder::execLogSurfaceTextures);
	P_GET_OBJECT(ULevel, Level);
	P_GET_STR(TargetName);
	P_GET_OBJECT(UTexture, NewTexture);
	P_FINISH;
	
	if (Level)
	{
		for(INT PolyIndex = 0; PolyIndex < Level->Model->Surfs.Num(); PolyIndex++)
		{
			FBspSurf &Surf = Level->Model->Surfs(PolyIndex);
			if (Surf.Texture != 0)
			{
				const TCHAR* TName = (Surf.Texture->GetName());
				
				if (TName == *TargetName)
				{
					Surf.Texture = NewTexture;
				}
			}
			else if (TargetName.Len() <= 0)
			{
				Surf.Texture = NewTexture;
			}
		}
	}
	
	unguardexec;
}

IMPLEMENT_FUNCTION(AVMDTerrainReskinner,-1,execLogSurfaceTextures);
IMPLEMENT_FUNCTION(AVMDTerrainReskinner,-1,execSetSurfaceTexture);
