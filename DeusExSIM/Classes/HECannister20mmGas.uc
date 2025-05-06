//=============================================================================
// HECannister20mmGas.
//=============================================================================
class HECannister20mmGas extends DeusExProjectile;

var ParticleGenerator smokeGen;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
   	if (Level.NetMode == NM_DedicatedServer)
      		return;
   	
   	SpawnSmokeEffects();
}

simulated function PostNetBeginPlay()
{
   	Super.PostNetBeginPlay();
   	
   	if (Role != ROLE_Authority)
      		SpawnSmokeEffects();
}

simulated function SpawnSmokeEffects()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
		smokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		smokeGen.particleDrawScale = 0.3;
		smokeGen.checkTime = 0.02;
		smokeGen.riseRate = 8.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 2.0;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
		smokeGen.RemoteRole = ROLE_None;
	}
}

simulated function Destroyed()
{
	if (smokeGen != None)
		smokeGen.DelayedDestroy();

	Super.Destroyed();
}

auto simulated state Flying
{
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		Super.Explode(HitLocation, HitNormal);
		
		SpawnTearGas();
	}
}

//
// SpawnTearGas needs to happen on the server so the clouds are insync and damage is dealt out of them
//
function SpawnTearGas()
{
	local Vector loc;
	local TearGas gas;
	local int i;

	if ( Role < ROLE_Authority )
		return;

	for (i=0; i<blastRadius/36; i++)
	{
		if (FRand() < 0.9)
		{
			loc = Location;
			loc.X += FRand() * blastRadius - blastRadius * 0.5;
			loc.Y += FRand() * blastRadius - blastRadius * 0.5;
			loc.Z += 32;
			gas = spawn(class'TearGas', None,, loc);
			if (gas != None)
			{
				gas.Velocity = vect(0,0,0);
				gas.Acceleration = vect(0,0,0);
				gas.DrawScale = FRand() * 0.5 + 2.0;
				gas.LifeSpan = FRand() * 10 + 30;
				if ( Level.NetMode != NM_Standalone )
					gas.bFloating = False;
				else
					gas.bFloating = True;
				gas.Instigator = Instigator;
			}
		}
	}
}

defaultproperties
{
     bExplodes=True
     bBlood=True
     bDebris=True
     blastRadius=384.000000
     DamageType=TearGas
     AccurateRange=600
     maxRange=1200
     ItemName="HE 20mm Shell"
     ItemArticle="a"
     speed=1500.000000
     MaxSpeed=1000.000000
     Damage=1.000000
     MomentumTransfer=40000
     SpawnSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     ImpactSound=Sound'DeusExSounds.Generic.MediumExplosion2'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.HECannister20mm'
}
