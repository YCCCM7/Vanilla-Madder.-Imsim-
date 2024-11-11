//=============================================================================
// WaterDrop.
//=============================================================================
class WaterDrop extends DeusExFragment;

//#exec OBJ LOAD FILE="../Sounds/TranscendedSounds.uax"

auto state Flying
{
	function HitWall(vector HitNormal, actor Wall)
	{
		local int WaterCount;
		local WaterPool pool, TPool;
		
		forEach RadiusActors(class'WaterPool', TPool, 6, Location)
		{
			WaterCount++;
		}
		
		if ((Region.Zone != None) && (!Region.Zone.bWaterZone) && (WaterCount < 3))
		{
			pool = spawn(class'WaterPool',,, Location, Rotator(HitNormal));
			if (pool != None)
				pool.maxDrawScale = 0.1 + (FRand() * 0.1);
		}
		Destroy();
	}
	function BeginState()
	{
		Velocity = VRand() * 1;
		if (Instigator != None)
		{
			Velocity += Instigator.Velocity / 2;
		}
		DrawScale = 0.75 + FRand();
		if ((Region.Zone != None) && (Region.Zone.bWaterZone))
			Destroy();
	}
	
	//--------------------
	//MADDERs, 11/6/22: Some changes made for new zone controlling BS.
	simulated singular function ZoneChange( ZoneInfo NewZone )
	{
		local float splashsize;
		local actor splash;
		local int RNGSound;
		local VMDWaterLevelActor TAct;
		local Vector TLoc;

		if ((NewZone != None) && (NewZone.bWaterZone))
		{
			if ((WaterZone(Region.Zone) != None) && (WaterZone(Region.Zone).OwningTrigger != None))
			{
				TAct = WaterZone(Region.Zone).OwningTrigger.WaterLevelActor;
			}
			
			Velocity = 0.2 * Velocity;
			splashSize = 0.0005 * (250 - 0.5 * Velocity.Z);
			if ( Level.NetMode != NM_DedicatedServer )
			{
				if ( NewZone.EntrySound != None )
				{
					RNGSound = Rand(3);
					
					/*if (RNGSound == 0)
						PlaySound(Sound'TranscendedSounds.Environment.waterdrop1', SLOT_Interact, splashSize);					
					else if (RNGSound == 1)
						PlaySound(Sound'TranscendedSounds.Environment.waterdrop2', SLOT_Interact, splashSize);					
					else
						PlaySound(Sound'TranscendedSounds.Environment.waterdrop3', SLOT_Interact, splashSize);*/
				}
				if ( NewZone.EntryActor != None )
				{
					TLoc = Location;
					if (TAct != None)
					{
						TLoc.Z = TAct.Location.Z;
					}
					
					splash = Spawn(NewZone.EntryActor,,, TLoc); 
					if ( splash != None )
					{
						splash.DrawScale = 0.1;
						if (WaterRing(splash) != None)
						{
							WaterRing(splash).bTinyRing = True;
							
							if (TAct != None)
							{
								Splash.SetBase(TAct);
							}
						}
					}
				}
			}
			if (bFirstHit) 
			{
				bFirstHit = False;
				bRotatetoDesired = True;
				bFixedRotationDir = False;
				DesiredRotation.Pitch = 0;	
				DesiredRotation.Yaw = FRand()*65536;
				DesiredRotation.roll = 0;
			}
			
			RotationRate = 0.2 * RotationRate;
			GotoState('Dying');
		}
		if ( (NewZone != None) && (NewZone.bPainZone) && (NewZone.DamagePerSec > 0) )
			Destroy();
	}
}

function Tick(float deltaTime)
{
	local int WaterCount;
	local WaterPool pool, TPool;
	
	if (Velocity == vect(0,0,0))
	{
		forEach RadiusActors(class'WaterPool', TPool, 6, Location)
		{
			WaterCount++;
		}
		
		if ((Region.Zone != None) && (!Region.Zone.bWaterZone) && (WaterCount < 2))
		{
			pool = spawn(class'WaterPool',,, Location, rot(16384,0,0));
			if (pool != None)
				pool.maxDrawScale = 0.1 + (FRand() * 0.1);
		}
		Destroy();
	}
	
	if ((Region.Zone != None) && (Region.Zone.bWaterZone))
		Destroy();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		ScaleGlow = 2.0;
		DrawScale *= 1.5;
		LifeSpan *= 2.0;
		bUnlit=True;
	}
}

defaultproperties
{
     ScaleGlow=0.600000
     DrawScale=0.600000
     Skin=Texture'Effects.Generated.WtrDrpSmall'
     Style=STY_Translucent
     Mesh=LodMesh'DeusExItems.BloodDrop'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBounce=False
     NetPriority=1.000000
     NetUpdateFrequency=5.000000
}
