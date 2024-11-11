//=============================================================================
// PlasmaPlagueMold.
//=============================================================================
class PlasmaPlagueMold extends Projectile;

var Actor Moldee;
var int CurTicks;
var int TotalTicks;
var bool bWasPawn;
var bool bElectronic;

var class<Ammo> MoldeeAmmos[4];

var int MyIndex;
var int SkillLevel;
var Vector LocOffset;
var float ScaleGlowMult, BaseScaleGlow;

var ParticleGenerator PGen, PGen2;

#exec OBJ LOAD FILE=Effects

function DrawExplosionEffects(Vector Loc)
{
 	local ShockRing R1, R2, R3;
 	
	//MADDERS: *POP*!
	if (MyIndex == 0)
	{
		PlaySound(Sound'PlasmaRifleHit');
		
 		R1 = Spawn(class'ShockRing',,,Loc, Rot(0,-16384,0));
 		R1.Lifespan = 0.25;
 		R1.DrawScale = 1.125;
		
 		R2 = Spawn(class'ShockRing',,,Loc, Rot(-16384,0,0));
 		R2.Lifespan = 0.25;
 		R2.DrawScale = 1.125;
		
 		R3 = Spawn(class'ShockRing',,,Loc, Rot(0,0,0));
 		R3.Lifespan = 0.25;
 		R3.DrawScale = 1.125;
	}
}

function PostBeginPlay()
{
 	Super.PostBeginPlay();
 	
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).SkillSystem != None))
	{
 		SkillLevel = DeusExPlayer(Owner).SkillSystem.GetSkillFromClass(class'SkillWeaponHeavy').CurrentLevel;
	}
	
	SpawnPlasmaEffects();
}

// DEUS_EX AMSD Should not be called as server propagating to clients.
simulated function SpawnPlasmaEffects()
{
	local Rotator TRot;
	
   	TRot = Rotation;
	TRot.Pitch += 16384 - Rand(32678);
	TRot.Yaw -= Rand(65536);
	
   	PGen = Spawn(class'ParticleGenerator', Self,, Location, TRot);
	if (PGen != None)
	{
      		PGen.RemoteRole = ROLE_None;
		PGen.particleTexture = Texture'Effects.water.WaterDrop1';
		PGen.particleDrawScale = 0.04;
		PGen.checkTime = 0.04;
		PGen.riseRate = 0.0;
		PGen.ejectSpeed = 100.0;
		PGen.particleLifeSpan = 0.5;
		PGen.bRandomEject = True;
		PGen.SetBase(Self);
	}
	
   	TRot = Rotation;
	TRot.Pitch += 16384 - Rand(32678);
	TRot.Yaw -= Rand(65536);
	
   	PGen2 = Spawn(class'ParticleGenerator', Self,, Location, TRot);
	if (PGen2 != None)
	{
      		PGen2.RemoteRole = ROLE_None;
		PGen2.particleTexture = Texture'Effects.water.WaterDrop1';
		PGen2.particleDrawScale = 0.02;
		PGen2.checkTime = 0.04;
		PGen2.riseRate = 0.0;
		PGen2.ejectSpeed = 100.0;
		PGen2.particleLifeSpan = 0.5;
		PGen2.bRandomEject = True;
		PGen2.SetBase(Self);
	}
   
}

function SpawnAmmo()
{
 	local int i, Seed;
 	local Ammo Ammo;
 	local DeusExPickup DXP;
 	
	//MADDERS: Only run this for the source mold.
	if (MyIndex != 0 || bDeleteMe) return;
	if (!bElectronic)
	{
		//MADDERS: All I have to do is find a very large prime number and *MODULO*!
		Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 67);
		if (Moldee != None) Seed += class'VMDStaticFunctions'.Static.DeriveActorSeed(Moldee, 67, true);
		Seed = Seed % 67;
		
		if ((Seed != 17) && (Seed != 31) && (Seed != 43)) return;
	}
	
	PlaySound(sound'TurretSwitch', SLOT_Misc,,, 768);
	PlaySound(sound'Spark1', SLOT_None,,, 768);
 	if ((FRand() < 0.12) && (bElectronic))
 	{
  		DXP = Spawn(class'BioelectricCell',,,Location,Rotation);
 	}
	else if (bWasPawn)
	{
  		Spawn(class'AmmoPlasmaPlague',,,Location,Rotation);
	}
	for (i=0; i<4; i++)
	{
		if ((MoldeeAmmos[i] != None) && (FRand() < 0.25))
		{
			Ammo = Spawn(MoldeeAmmos[i],,,Location,Rotation);
		}
	}
}

state Fading
{
 	function BeginState()
 	{
		if ((Moldee == None) || (Moldee.bDeleteMe))
		{
			DrawExplosionEffects(Location);
		}
  		SpawnAmmo();
  		Style = STY_Translucent;
  		ScaleGlow = BaseScaleGlow * ScaleGlowMult;
 	}
	
 	function Tick(float DT)
 	{
  		Scaleglow -= DT;
  		
  		if (Scaleglow <= 0.000000)
  		{
   			Destroy();
  		}
 	}
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if ((Moldee != None) && (!Moldee.bDeleteMe))
	{
		AnimFrame = Moldee.AnimFrame+0.0;
		AnimSequence = Moldee.AnimSequence;
  		SetRotation(Moldee.Rotation);
 		SetLocation(Moldee.Location+(LocOffset>>Rotation)+(Moldee.Velocity / 60));
		
		if (PGen != None)
		{
			PGen.SetLocation(Location);
		}
		if (PGen2 != None)
		{
			PGen2.SetLocation(Location);
		}
	}
}

function Timer()
{
 	local Ammo A;
 	local int CurAmmo, RelDamage, i;
	local bool bLowHealth;
 	
 	if ((!bWasPawn) && (Pawn(Moldee) != None))
 	{
  		bWasPawn = True;
 	}
	
 	if ((Moldee != None) && (!Moldee.bDeleteMe) && (TotalTicks < 5))
 	{
		for (i=0; i<8; i++)
		{
			switch(Moldee.Multiskins[i])
			{
				case Texture'BlackMaskTex':
				case Texture'PinkMaskTex':
				case Texture'GrayMaskTex':
					//Multiskins[i] = Moldee.Multiskins[i];
					Multiskins[i] = Texture'BlackMaskTex';
				break;
				default:
				break;
			}
		}
		
		//MADDERS: Don't do this, since we'll be lootable.
  		/*if ((MoldeeAmmos[0] == None) && (Pawn(Moldee) != None))
  		{
   			forEach AllActors(class'Ammo', a)
   			{
    				if ((DeusExAmmo(a).bShowInfo) && (a.owner == Moldee) && (MoldeeAmmos[0] != a.class) && (MoldeeAmmos[1] != a.class) && (MoldeeAmmos[2] != a.class) && (MoldeeAmmos[3] != a.class))
    				{
     					MoldeeAmmos[CurAmmo] = a.class;
     					CurAmmo++;
    				}
   			}
  		}*/
		
  		if (AutoTurret(Moldee) != None || AutoTurretGun(Moldee) != None)
  		{
   			//Moldee.SetPropertyText("MinDamageThreshold", "0");
   			MoldeeAmmos[0] = Class'Ammo762mm';
  		}
  		if (HackableDevices(Moldee) != None)
  		{
   			//Moldee.SetPropertyText("MinDamageThreshold", "0");
   			bElectronic = True;
  		}
		
		ScaleGlow = Moldee.ScaleGlow * ScaleGlowMult;
  		//Mesh = Moldee.Mesh;
		Mesh = None;
  		DrawScale = Moldee.DrawScale;
 		
  		CurTicks++;
  		if (CurTicks >= 5)
  		{
   			TotalTicks++;
   			CurTicks = 0;
			RelDamage = 3 + SkillLevel; //MADDERS: Used to be 2, but live a little!
			if (!bWasPawn) bLowHealth = true;
			else if (Robot(Moldee) == None) bLowHealth = true;
			
			if (bElectronic) RelDamage *= 5;
			if (MyIndex == 0)
			{
   				if (bLowHealth) Moldee.TakeDamage(RelDamage, None, vect(0,0,0), vect(0,0,0), 'Exploded');
				else Moldee.TakeDamage(RelDamage, None, vect(0,0,0), vect(0,0,0), 'Flamed');
			}
  		}
 	}
 	else
 	{
  		GoToState('Fading');
 	}
}

simulated function Destroyed()
{
	if (PGen != None)
	{
		PGen.DelayedDestroy();
	}
	if (PGen2 != None)
	{
		PGen2.DelayedDestroy();
	}
	Super.Destroyed();
}

defaultproperties
{
     BaseScaleGlow=0.500000
     ScaleGlow=0.000000
     ScaleGlowMult=0.200000
     Style=STY_Translucent
     Multiskins(0)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(1)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(2)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(3)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(4)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(5)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(6)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Multiskins(7)=FireTexture'Effects.Electricity.Nano_SFX_A'
     Texture=FireTexture'Effects.Electricity.Nano_SFX_A'
}
