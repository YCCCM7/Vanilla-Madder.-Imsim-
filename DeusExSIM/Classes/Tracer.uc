//=============================================================================
// Tracer.
//=============================================================================
class Tracer extends DeusExProjectile;

var int TracePos;
var Vector TracerEndPoints[10];

function int Sign(float InVal)
{
	if (InVal >= 0)
	{
		return 1;
	}
	else
	{
		return -1;
	}
}

function int ComplexSign(Vector InVal)
{
	local int Ret;
	
	Ret = 111;
	if (InVal.X >= 0)
	{
		Ret += 1;
	}
	if (InVal.Y >= 0)
	{
		Ret += 10;
	}
	if (InVal.Z >= 0)
	{
		Ret += 100;
	}
	
	return Ret;
}

//
// update our flight path based on our ranges and tracking info
//
simulated function Tick(float deltaTime)
{
	local float dist, size, HeadingDiffDot;
	local Rotator dir, TRot;
   	local vector TargetLocation, vel, NormalHeading, NormalDesiredHeading, HackVect;
	local VMDBufferPlayer VMP;
	
	if (bStuck)
	{
		return;
	}
	
	Super.Tick(deltaTime);
	
	//MADDRES, 6/24/23: Projectiles = scary. True story.
	if (!bSpentStress)
	{
		if (bStuck || DeusExPlayer(Owner) != None)
		{
			bSpentStress = true;
		}
		else
		{
			VMP = GetLastVMP();
			if ((VMP != None) && (VSize(VMP.Location - Location) < 80))
			{
				bSpentStress = true;
				VMP.VMDModPlayerStress(5, true, 2, true);
			}
		}
	}
	
   	if (VSize(LastSeenLoc) < 1)
   	{
      		LastSeenLoc = Location + Normal(Vector(Rotation)) * 10000;
   	}
	
      	// make the rotation match the velocity direction
	SetRotation(Rotator(Velocity));
	
	dist = Abs(VSize(initLoc - Location));
	
	if (TracerOutline(Self) != None)
	{
		if (TracePos > 0)
		{
			Mesh = Default.Mesh;
		}
		else
		{
			Mesh = None;
		}
	}
	
	if (TracerEndPoints[0] != HackVect)
	{
		if (ComplexSign(Location - TracerEndPoints[TracePos]) == ComplexSign(Velocity))
		{
			TracePos += 1;
			if (TracePos >= ArrayCount(TracerEndPoints) || TracerEndPoints[TracePos] == HackVect)
			{
				if (!bDeleteMe)
				{
					Destroy();
				}
			}
			else
			{
				Velocity = Normal(TracerEndPoints[TracePos] - Location) * Speed * Sqrt(1.0 - (float(TracePos) / 10.0));
			}
		}
	}
	else
	{
		if ((dist > AccurateRange) && (!bDeleteMe))
		{
			Destroy();
			// start descent due to "gravity"
			//Acceleration = Region.Zone.ZoneGravity / 2;
		}
	}
   	if ((Role < ROLE_Authority) && (bAggressiveExploded))
      		Explode(Location, vect(0,0,1));
}

defaultproperties
{
     AccurateRange=16000
     maxRange=16000
     bIgnoresNanoDefense=True
     speed=4000.000000
     MaxSpeed=4000.000000
     Mesh=LodMesh'DeusExItems.Tracer'
     ScaleGlow=2.000000
     bUnlit=True
}
