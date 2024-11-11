//=============================================================================
// PlasmaBoltPlague.
//=============================================================================
class PlasmaBoltPlague extends DeusExProjectile;

var ParticleGenerator pGen1;
var ParticleGenerator pGen2;

var float mpDamage;
var float mpBlastRadius;

#exec OBJ LOAD FILE=Effects

function DrawExplosionEffects(vector Loc, Vector Norm)
{
 	local ShockRing R1, R2, R3;
 	local PlasmaPlagueSplash Mark;
 	
 	R1 = Spawn(class'ShockRing',,,Loc, Rot(0,-16384,0));
 	R1.Lifespan = 0.25;
 	R1.DrawScale = 0.666666;
	
 	R2 = Spawn(class'ShockRing',,,Loc, Rot(-16384,0,0));
 	R2.Lifespan = 0.25;
 	R2.DrawScale = 0.666666;
	
 	R3 = Spawn(class'ShockRing',,,Loc, Rot(0,0,0));
 	R3.Lifespan = 0.25;
 	R3.DrawScale = 0.666666;
	
 	//Mark = Spawn(class'PlasmaPlagueSplash',,,Loc, Rot(0,0,0));
 	//Mark.DrawScale = 0.125;
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
		pGen2.particleTexture = Texture'Effects.water.WaterDrop1';
		pGen2.particleDrawScale = 0.04;
		pGen2.checkTime = 0.04;
		pGen2.riseRate = 0.0;
		pGen2.ejectSpeed = 100.0;
		pGen2.particleLifeSpan = 0.5;
		pGen2.bRandomEject = True;
		pGen2.SetBase(Self);
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

simulated function Destroyed()
{
	if (pGen1 != None)
		pGen1.DelayedDestroy();
	if (pGen2 != None)
		pGen2.DelayedDestroy();
	
	Super.Destroyed();
}

function SpawnPlagueMold(Actor Other)
{
	local PlasmaPlagueMold Mold;
	local int i;
	local Vector VOff[5];
	
 	if (Other.GetPropertyText("bInvincible") ~= "True")
 	{
  		return;
 	}
	VOff[0] = vect(0, 0, 0);
	VOff[1] = vect(2, 0, 0);
	VOff[2] = vect(-2, 0, 0);
	VOff[3] = vect(0, 2, 0);
	VOff[4] = vect(0, -2, 0);
	for (i=0; i<5; i++)
	{
 		Mold = Spawn(class'PlasmaPlagueMold',Owner,,Other.Location,Other.Rotation);
		if (Mold != None)
		{
			Mold.MyIndex = i;
 			Mold.Moldee = Other;
 			Mold.SetTimer(0.1, True);
			Mold.LocOffset = VOff[i];
		}
	}
}

auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if ((Other != Instigator) && (Other != Owner) && (PlasmaBoltPlague(Other) == None)) 
		{
			if ( Role == ROLE_Authority )
			{
                            	if (Other.IsA('Pawn') || Other.IsA('Decoration'))
                            	{
					Other.TakeDamage(damage, instigator,HitLocation,(MomentumTransfer * Normal(Velocity)), DamageType );
					SpawnPlagueMold(Other);
					
					PlaySound(ImpactSound, SLOT_Misc, 2.0);
			        	Destroy();
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
     blastRadius=48.000000
     DamageType=Exploded
     AccurateRange=14400
     maxRange=24000
     bIgnoresNanoDefense=False //MADDERS: Used to be true.
     ItemName="Plague Bolt"
     ItemArticle="a"
     speed=1500.000000
     MaxSpeed=1500.000000
     Damage=1.000000
     MomentumTransfer=5000
     ImpactSound=Sound'DeusExSounds.Weapons.PlasmaRifleHit'
     ExplosionDecal=Class'DeusEx.ScorchMark'
     Mesh=LodMesh'DeusExItems.PlasmaBolt'
     Texture=FireTexture'Effects.Electricity.Nano_SFX_A'
     Skin=FireTexture'Effects.Electricity.Nano_SFX_A'
     DrawScale=2.000000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=200
     LightHue=160
     LightSaturation=64
     LightRadius=3
     bFixedRotationDir=True
}
