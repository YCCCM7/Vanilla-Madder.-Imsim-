//=============================================================================
// PlasmaBolt.
//=============================================================================
class PlasmaBolt extends DeusExProjectile;

var ParticleGenerator pGen1;
var ParticleGenerator pGen2;

var float mpDamage;
var float mpBlastRadius;

#exec OBJ LOAD FILE=Effects

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ParticleGenerator gen;

	// Don't do anything if we hit a FakeBackdrop
	if (!bHitFakeBackdrop)
		CheckIfHitFakeBackDrop();
	
	if (bHitFakeBackdrop)
		return;
	
	// create a particle generator shooting out plasma spheres
	gen = Spawn(class'ParticleGenerator',,, HitLocation, Rotator(HitNormal));
	if (gen != None)
	{
		gen.RemoteRole = ROLE_None;
		gen.particleDrawScale = 1.0;
		gen.checkTime = 0.10;
		gen.frequency = 1.0;
		gen.ejectSpeed = 200.0;
		gen.bGravity = True;
		gen.bRandomEject = True;
		gen.particleLifeSpan = 0.75;
		gen.particleTexture = Texture'Effects.Fire.Proj_PRifle';
		gen.LifeSpan = 1.3;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

   	if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer))
      		SpawnPlasmaEffects();
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	if (Level.Netmode != NM_Standalone)
	{
	 	Damage = mpDamage;
	 	blastRadius = mpBlastRadius;
	}
}

simulated function PostNetBeginPlay()
{
   	if (Role < ROLE_Authority)
      		SpawnPlasmaEffects();
}

// DEUS_EX AMSD Should not be called as server propagating to clients.
simulated function SpawnPlasmaEffects()
{
	local Rotator rot;
   	rot = Rotation;
	rot.Yaw -= 32768;

   	pGen2 = Spawn(class'ParticleGenerator', Self,, Location, rot);
	if (pGen2 != None)
	{
      		pGen2.RemoteRole = ROLE_None;
		pGen2.particleTexture = Texture'Effects.Fire.Proj_PRifle';
		pGen2.particleDrawScale = 0.1;
		pGen2.checkTime = 0.04;
		pGen2.riseRate = 0.0;
		pGen2.ejectSpeed = 100.0;
		pGen2.particleLifeSpan = 0.5;
		pGen2.bRandomEject = True;
		pGen2.SetBase(Self);
	}
   
}

simulated function Destroyed()
{
	if (pGen1 != None)
		pGen1.DelayedDestroy();
	if (pGen2 != None)
		pGen2.DelayedDestroy();

	Super.Destroyed();
}

// For hitting walls, draw fire on them
simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local PlasmaFire f;
	local int i;
	local vector loc;
	
	Super.SpawnEffects(HitLocation, HitNormal, Other);
	
	if (Level.NetMode != NM_Standalone)
		return;

	if (!bHitFakeBackdrop)
	{
		for (i=0; i<1; i++)
		{
			loc.X = 0.9*CollisionRadius * (1.0-2.0*FRand());
			loc.Y = 0.9*CollisionRadius * (1.0-2.0*FRand());
			loc.Z = 0.9*CollisionHeight * (1.0-2.0*FRand());
			loc += Location;
			f = Spawn(class'PlasmaFire', Other,, loc);
			if (f != None)
			{
				f.DrawScale = (FRand() + 1.0) * (DrawScale / 3.0) * 0.5; //MADDERs, 3/6/21: Hack for mini bolts.
				f.LifeSpan =  5 + Rand(6); // 5-10
					
				// turn off the sound and lights for all but the first one
				if (i > 0)
				{
					f.AmbientSound = None;
					f.LightType = LT_None;
				}
					
				// turn on/off extra fire and smoke
				if (FRand() < 0.9)
					f.smokeGen.Destroy();
				if (FRand() < 0.25)
					f.AddFire(1.5);
			}
		}
	}
}

// For impacting pawns/deco, draw fire on them
auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		local Fire f;
		local int i;
		local vector loc;
		
		// Don't do this for pawns, looks ugly when they get it stuck on everything
		if (Owner != None && ScriptedPawn(Owner) != None)
		{
			Super.ProcessTouch(Other, HitLocation);
			return;
		}
		
		if (Other != None && (ScriptedPawn(Other) == None || (ScriptedPawn(Other) != None && Robot(Other) == None && ScriptedPawn(Other).ShieldDamage(damageType) == 0)) && Decoration(Other) == None)
		{
			Super.ProcessTouch(Other, HitLocation);
			return;
		}
		
		if (Level.NetMode == NM_Standalone)
		{
			for (i=0; i<1; i++)
			{
				loc.X = 0.9*CollisionRadius * (1.0-2.0*FRand());
				loc.Y = 0.9*CollisionRadius * (1.0-2.0*FRand());
				loc.Z = 0.9*CollisionHeight * (1.0-2.0*FRand());
				loc += Location;
				
				f = Spawn(class'PlasmaFire', Other,, loc);
				if (f != None)
				{
					f.DrawScale = FRand() + 0.5;
					f.LifeSpan =  1 + Rand(2); // 1-2
						
					// turn off the sound and lights for all but the first one
					if (i > 0)
					{
						f.AmbientSound = None;
						f.LightType = LT_None;
					}
						
					// turn on/off extra fire and smoke
					if (FRand() < 0.9)
						f.smokeGen.Destroy();
					if (FRand() < 0.25)
						f.AddFire(1.5);
				}
			}
		}
		
		Super.ProcessTouch(Other, HitLocation);
	}
}

defaultproperties
{
     mpDamage=8.000000
     mpBlastRadius=300.000000
     bExplodes=True
     blastRadius=128.000000
     DamageType=Burned
     AccurateRange=14400
     maxRange=24000
     bIgnoresNanoDefense=True //MADDERS: Used to be true.
     ItemName="Plasma Bolt"
     ItemArticle="a"
     speed=1500.000000
     MaxSpeed=1500.000000
     Damage=32.000000 //MADDERS, 8/24/25: Nerfing plasma because it is a monster.
     MomentumTransfer=5000
     ImpactSound=Sound'DeusExSounds.Weapons.PlasmaRifleHit'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.PlasmaBolt'
     DrawScale=3.000000
     bUnlit=True
     // LightType=LT_Steady
     // LightEffect=LE_NonIncidence
     // LightBrightness=200
     // LightHue=80
     // LightSaturation=128
     // LightRadius=3
     LightType=LT_SubtlePulse // Transcended - Added
     LightEffect=LE_Disco
     LightBrightness=200
     LightHue=80
     LightSaturation=128
     LightRadius=15
     bFixedRotationDir=True
}
