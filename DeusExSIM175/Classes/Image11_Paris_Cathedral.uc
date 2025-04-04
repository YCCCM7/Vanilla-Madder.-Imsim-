//=============================================================================
// Image11_Paris_Cathedral
//=============================================================================
class Image11_Paris_Cathedral extends DataVaultImage;

function PostBeginPlay()
{
	local Texture TTex;
	
	Super.PostBeginPlay();
	
	TTex = Texture(DynamicLoadObject("VMDAssets.VMDImage11_Paris_Cathedral_1",  class'Texture'));
	
	if (TTex != None)
	{
		imageTextures[0] = TTex;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     imageTextures(0)=Texture'DeusExUI.UserInterface.Image11_Paris_Cathedral_1'
     imageTextures(1)=Texture'DeusExUI.UserInterface.Image11_Paris_Cathedral_2'
     imageTextures(2)=Texture'DeusExUI.UserInterface.Image11_Paris_Cathedral_3'
     imageTextures(3)=Texture'DeusExUI.UserInterface.Image11_Paris_Cathedral_4'
     imageDescription="Paris Cathedral"
     colNoteTextNormal=(R=50,G=50)
     colNoteTextFocus=(R=0,G=0)
     colNoteBackground=(R=32,G=32)
}
