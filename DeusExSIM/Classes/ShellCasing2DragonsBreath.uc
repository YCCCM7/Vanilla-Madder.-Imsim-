//=============================================================================
// ShellCasing2DragonsBreath.
//=============================================================================
class ShellCasing2DragonsBreath extends ShellCasing2;

var float SmokeTime;
var ParticleGenerator smokeGen;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
   	SpawnSmokeEffects();
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (SmokeTime > 0)
	{
		SmokeTime -= DT;
	}
	else if (SmokeGen != None)
	{
		SmokeGen.DelayedDestroy();
		SmokeGen = None;
	}
}

simulated function SpawnSmokeEffects()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
      		smokeGen.RemoteRole = ROLE_None;
		smokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		smokeGen.particleDrawScale = 0.03;
		smokeGen.checkTime = 0.024;
		smokeGen.riseRate = 12.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 1.2;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
	}
}

simulated function Destroyed()
{
	if (smokeGen != None)
		smokeGen.DelayedDestroy();
	
	Super.Destroyed();
}

defaultproperties
{
     SmokeTime=5.000000
     Lifespan=30.000000
     Skin=Texture'ShellCasing2Tex3'
}
