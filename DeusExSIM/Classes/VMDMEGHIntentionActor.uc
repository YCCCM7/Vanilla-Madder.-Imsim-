//=============================================================================
// VMDMEGHIntentionActor.
//=============================================================================
class VMDMEGHIntentionActor extends VMDFillerActors;

var bool bWonBarfTimer;
var float BarfTimer;

var VMDBufferPlayer VMP;

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (!bWonBarfTimer)
	{
 		if (BarfTimer < 0.6)
		{
			BarfTimer += DT;
		} 
		else if (BarfTimer > -10)
 		{
			if (VMP.VMDUnpackDrones())
			{
 	 			BarfTimer = -30;
				bWonBarfTimer = true;
			}
			else
			{
				BarfTimer = -0.4;
			}
	 	}
	}
}

defaultproperties
{
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
