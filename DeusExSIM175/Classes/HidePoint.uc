//=============================================================================
// HidePoint.
//=============================================================================
class HidePoint extends NavigationPoint;

var vector faceDirection;

function PreBeginPlay()
{
	Super.PreBeginPlay();

	faceDirection = 200 * vector(Rotation);
}

defaultproperties
{
     bDirectional=True
}
