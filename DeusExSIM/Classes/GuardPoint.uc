//=============================================================================
// PatrolPoint.
//=============================================================================
class GuardPoint extends NavigationPoint;

var()	float		PauseTime;		// How long to pause here
var		vector		lookdir;		// Direction to look while stopped
var		pawn		currentGuard;	// Who is currently using this point
var()	float		weightMultiplier; // Multiplier to weight, higher = more priority

function PreBeginPlay()
{
	lookdir = 200 * vector(Rotation);

	Super.PreBeginPlay();
}

defaultproperties
{
     PauseTime=60.000000
     weightMultiplier=1.000000
     bDirectional=True
     Texture=Texture'Engine.S_Patrol'
     SoundVolume=128
}
