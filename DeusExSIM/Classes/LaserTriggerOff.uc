//=============================================================================
// LaserTrigger.
//=============================================================================
class LaserTriggerOff extends LaserTrigger;

function TurnOn()
{
	if (emitter != None)
	{
		emitter.TurnOn();
		bIsOn = True;

		// turn off the sound if we should
		if (SoundVolume == 0)
			emitter.AmbientSound = None;
	}
	else
		bIsOn = False;
}

function BeginPlay()
{
	Super(Trigger).BeginPlay();

	LastHitActor = None;
}

defaultproperties
{
     bIsOn=False
     confusionDuration=10.000000
     HitPoints=50
     minDamageThreshold=50
     alarmTimeout=30
     TriggerType=TT_ClassProximity
     ClassProximityType=class'DeusExPlayer'
     bHidden=False
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'DeusExDeco.LaserEmitter'
     CollisionRadius=2.500000
     CollisionHeight=2.500000
}
