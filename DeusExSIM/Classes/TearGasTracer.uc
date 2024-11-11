//=============================================================================
// TearGasTracer.
//=============================================================================
class TearGasTracer extends DeusExProjectile;

var ProjectileGenerator Gen, Gen2;

//MADDERS: Halon tracers just spray gas everywhere they go. Quick and dirty(tm)

function Destroyed()
{
	Gen.Destroy();
	Gen2.Destroy();
	
	Super.Destroyed();	
}

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);
	
	// If the fireball enters water, extingish it
	if (NewZone.bWaterZone)
	{
		Destroy();
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if ((Region.Zone != None) && (Region.Zone.bWaterZone))
	{
		Destroy();
	}
	else
	{
		gen = Spawn(class'ProjectileGenerator', None,, Location, Rotation+Rot(32768, 0, 0));
		if (gen != None)
		{
			gen.ProjectileClass = class'GrenadeTearGas';
			gen.SetBase(Self);
			gen.ejectSpeed = 300;
			gen.Lifespan = 0.5; //MADDERS: Limit our flight time.
			gen.projectileLifeSpan = 1.5;
			gen.frequency = 0.30; //0.9
			gen.checkTime = 0.05; //0.1
			gen.bAmbientSound = True;
			gen.AmbientSound = sound'SteamVent2';
			gen.SoundVolume = 192;
			gen.SoundPitch = 32;
		}
		gen2 = Spawn(class'ProjectileGenerator', None,, Location, Rotation);
		if (gen2 != None)
		{
			gen2.ProjectileClass = class'GrenadeTearGas';
			gen2.SetBase(Self);
			gen2.ejectSpeed = 300;
			gen2.Lifespan = 0.5; //MADDERS: Limit our flight time.
			gen2.projectileLifeSpan = 1.5;
			gen2.frequency = 0.30; //0.9
			gen2.checkTime = 0.05; //0.1
			gen2.bAmbientSound = True;
			gen2.AmbientSound = sound'SteamVent2';
			gen2.SoundVolume = 192;
			gen2.SoundPitch = 32;
		}
	}
}

defaultproperties
{
     AccurateRange=16000
     maxRange=16000
     bIgnoresNanoDefense=True
     speed=1500.000000
     MaxSpeed=1500.000000
     Mesh=LodMesh'DeusExItems.Tracer'
     ScaleGlow=2.000000
     bUnlit=True
}
