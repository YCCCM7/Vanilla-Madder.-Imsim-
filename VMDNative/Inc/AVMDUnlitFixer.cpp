#include "VMDNative.h"

IMPLEMENT_CLASS(AVMDUnlitFixer);

//Whip it out in public. And by "it", I mean unlit flag.
void AVMDUnlitFixer::execPatchUnlitSurfaces(FFrame &Stack, void *Result)
{
    P_FINISH;

    for(TObjectIterator<UModel> M; M; ++M)
    {
        for(int I = 0; I < M->Surfs.Num(); I++)
        {
            FBspSurf &Surf = M->Surfs(I);

            if(Surf.PolyFlags & PF_Unlit) Surf.iLightMap = INDEX_NONE;
        }
    }
}

IMPLEMENT_FUNCTION(AVMDUnlitFixer,-1,execPatchUnlitSurfaces);