//=============================================================================
// OutdoorThings.
//=============================================================================
class OutdoorThings extends VMDBufferDeco
	abstract;

function BeginPlay()
{
	Super.BeginPlay();
	
	bMemorable = False;
}

defaultproperties
{
     bInvincible=True
     bHighlight=False
     bPushable=False
     bStatic=True
     Physics=PHYS_None
     bAlwaysRelevant=True
}
