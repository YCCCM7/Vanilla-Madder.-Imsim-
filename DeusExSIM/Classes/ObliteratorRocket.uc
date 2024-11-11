//=============================================================================
// ObliteratorRocket.
//=============================================================================
class ObliteratorRocket extends DeusExProjectile;

var ParticleGenerator fireGen;
var ParticleGenerator smokeGen;

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
		fireGen.particleDrawScale = 0.05;
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
		smokeGen.particleDrawScale = 0.15;
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
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=96.000000
     DamageType=exploded
     AccurateRange=14400
     maxRange=24000
     bTracking=True
     ItemName="Obliterator Rocket"
     ItemArticle="an"
     speed=1000.000000
     MaxSpeed=1500.000000
     Damage=25.000000
     MomentumTransfer=1600
     SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     ImpactSound=Sound'DeusExSounds.Generic.SmallExplosion1'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.Rocket'
     DrawScale=0.125000
     SoundRadius=16
     SoundVolume=224
     AmbientSound=Sound'DeusExSounds.Special.RocketLoop'
     RotationRate=(Pitch=32768,Yaw=32768)
}
