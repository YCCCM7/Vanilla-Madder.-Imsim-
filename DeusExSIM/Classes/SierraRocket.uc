//=============================================================================
// SierraRocket.
//=============================================================================
class SierraRocket extends DeusExProjectile;

var ParticleGenerator fireGen;
var ParticleGenerator smokeGen;

var float FuseTime, FuseLength, BeepTime;

simulated function VMDStickTo(Actor Other)
{
	if (Other == None || Other == Owner || !bSticky) return;
	
	Super.VMDStickTo(Other);
	
	if (smokeGen != None)
	{
		smokeGen.DelayedDestroy();
	}
	if (fireGen != None)
	{
		fireGen.DelayedDestroy();
	}
	
	PlaySound(Sound'DeusExSounds.Weapons.LAMSelect');
	AmbientSound = None;
}

function PlayBeepSound( float Range, float Pitch, float volume )
{
	PlaySound(sound'Beep4',SLOT_None,,, Range, Pitch);
}

simulated function Tick(float DeltaTime)
{
	local float BeepRate;
	local Rotator TRot;
	
 	Super.Tick(DeltaTime);
	
	if ((VSize(Velocity) < 20 || Target == None) && (!bStuckToWorld) && (!bStuckToActor))
	{
		Destroy();
	}
	
	if (bStuckToWorld || bStuckToActor)
	{
		FuseTime += DeltaTime;
		if (FuseTime < FuseLength)
		{
			BeepTime += DeltaTime;
			
			if (FuseLength - FuseTime <= 0.75)
			{
				BeepRate = 0.1;
			}
			else if (FuseLength - FuseTime <= FuseLength * 0.5)
			{
				BeepRate = 0.3;
			}
			else
			{
				BeepRate = 0.5;
			}
			
			if (BeepTime > BeepRate)
			{
				BeepTime = 0;
				PlayBeepSound(1280, 1.7*VMDGetMiscPitch2(), 0.5);
			}
		}
		else
		{
			bSticky = False;
			bStuckToWorld = False;
			bStuckToActor = False;
			StuckTo = None;
			FuseTime = -10000;
			Explode(Location, Vector(Rotation));
		}
	}
}

function ZoneChange(ZoneInfo NewZone)
{
 	if (NewZone.bWaterZone)
 	{
		PlaySound(sound'EMPZap', SLOT_None,,, (CollisionRadius+CollisionHeight)*8, 2.0);
  		RotationRate = Rot(0,0,0);
  		SetPhysics(PHYS_Falling);
  		Velocity.Z *= -1;
  		Velocity.Z *= 0.75;
		bStuckToWorld = False;
		bStuckToActor = False;
  		StuckTo = None;
  		StickOffset = vect(0,0,0);
  		StickRotation = rot(0,0,0);
 	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
   	SpawnRocketEffects();
}

simulated function SpawnRocketEffects()
{
	fireGen = Spawn(class'ParticleGenerator', Self);
	if (fireGen != None)
	{
      		fireGen.RemoteRole = ROLE_None;
		fireGen.particleTexture = Texture'Effects.Fire.Fireball1';
		fireGen.particleDrawScale = 0.1;
		fireGen.checkTime = 0.01;
		fireGen.riseRate = 0.0;
		fireGen.ejectSpeed = 0.0;
		fireGen.particleLifeSpan = 0.1;
		fireGen.bRandomEject = True;
		fireGen.SetBase(Self);
	}
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
      		smokeGen.RemoteRole = ROLE_None;
		smokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		smokeGen.particleDrawScale = 0.3;
		smokeGen.checkTime = 0.02;
		smokeGen.riseRate = 8.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 2.0;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
	}
}

simulated function Destroyed()
{
	if (smokeGen != None)
		smokeGen.DelayedDestroy();
	if (fireGen != None)
		fireGen.DelayedDestroy();

	Super.Destroyed();
}

defaultproperties
{
     bSticky=True
     Buoyancy=2.000000
     FuseLength=3.000000
     
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=288.000000
     DamageType=exploded
     AccurateRange=14400
     maxRange=24000
     bTracking=True
     ItemName="Sierra Rocket"
     ItemArticle="a"
     speed=400.000000
     MaxSpeed=600.000000
     Damage=400.000000
     MomentumTransfer=4000
     SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     ImpactSound=Sound'DeusExSounds.Generic.SmallExplosion1'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.Rocket'
     DrawScale=0.250000
     SoundRadius=16
     SoundVolume=224
     AmbientSound=Sound'DeusExSounds.Special.RocketLoop'
     RotationRate=(Pitch=32768,Yaw=32768)
}
