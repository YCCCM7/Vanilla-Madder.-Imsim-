//=============================================================================
// DeusExFragment.
//=============================================================================
class DeusExFragment extends Fragment;

var bool bSmoking;
var Vector lastHitLoc;
var float smokeTime;
var ParticleGenerator smokeGen;

//MADDERS ADDITIONS!
var int SoundHitsPlayed;
var bool bForceFade;

function bool ShouldDoFade()
{
 	local int i;
	
	//MADDERS, 12/26/20: Big, ugly things have no right to exist.
	if ((DrawScale > 2.0) && (FleshFragment(Self) == None))
	{
		return true;
	}
	if (bForceFade)
	{
		return true;
	}
	
 	switch(Class)
 	{
  		case class'MetalFragment':
   			return False;
  		break;
  		case class'FleshFragment':
  		case class'WoodFragment':
  		case class'GlassFragment':
   			i = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
   			
   			if ((i == 2) || (i == 5) || (i == 8)) return True;
   			return False;
  		break;
 	}
 	
 	return True;
}

//
// copied from Engine.Fragment
//
simulated function HitWall (vector HitNormal, actor HitWall)
{
	local Sound sound;
	local float volume, radius;

	// if we are stuck, stop moving
	if (lastHitLoc == Location)
		Velocity = vect(0,0,0);
	else
		Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);	
	if (bFirstHit && speed<400) 
	{
		bFirstHit=False;
		bRotatetoDesired=True;
		bFixedRotationDir=False;
		DesiredRotation.Pitch=0;	
		DesiredRotation.Yaw=FRand()*65536;
		DesiredRotation.roll=0;
	}
	RotationRate.Yaw = RotationRate.Yaw*0.75;
	RotationRate.Roll = RotationRate.Roll*0.75;
	RotationRate.Pitch = RotationRate.Pitch*0.75;
	if ( ( (speed < 60) && (HitNormal.Z > 0.7) ) || (speed == 0) )
	{
		SetPhysics(PHYS_none, HitWall);
		if ((Physics == PHYS_None) && (ShouldDoFade()))
		{
			bBounce = false;
			GoToState('Dying');
		}
	}

	volume = 0.5+FRand()*0.5;
	radius = 768;
	if (FRand() < 0.5)
		sound = ImpactSound;
	else
		sound = MiscSound;
	
	//MADDERS: Don't spam our noise if caught against something underwater. Yikes.
	if (SoundHitsPlayed > 5) Sound = None;
	else SoundHitsPlayed++;
	
	if (sound != None)
	{
		PlaySound(sound, SLOT_Misc, volume,, radius, (0.85+(FRand()*0.3))*VMDGetMiscPitch2());
		
		// lower AI sound radius for gameplay balancing
		AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius * 0.5);
	}
	lastHitLoc = Location;
}

state Dying
{
	simulated function HitWall (vector HitNormal, actor HitWall)
	{
		local Sound Sound;
		
		// if we are stuck, stop moving
		if (lastHitLoc == Location)
			Velocity = vect(0,0,0);
		else
			Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
		speed = VSize(Velocity);	
		if (bFirstHit && speed<400) 
		{
			bFirstHit=False;
			bRotatetoDesired=True;
			bFixedRotationDir=False;
			DesiredRotation.Pitch=0;	
			DesiredRotation.Yaw=FRand()*65536;
			DesiredRotation.roll=0;
		}
		RotationRate.Yaw = RotationRate.Yaw*0.75;
		RotationRate.Roll = RotationRate.Roll*0.75;
		RotationRate.Pitch = RotationRate.Pitch*0.75;
		if ( (Velocity.Z < 50) && (HitNormal.Z > 0.7) )
		{
			SetPhysics(PHYS_none, HitWall);
			if (Physics == PHYS_None)
				bBounce = false;
		}
		
		if (FRand() < 0.5)
			Sound = ImpactSound;
		else
			Sound = MiscSound;
		
		//MADDERS: Don't spam our noise if caught against something underwater. Yikes.
		if (SoundHitsPlayed > 5) Sound = None;
		else SoundHitsPlayed++;
		
		if (Sound != None)
		{
			PlaySound(Sound, SLOT_Misc, 0.5+FRand()*0.5,, 512, (0.85+(FRand()*0.3))*VMDGetMiscPitch2());
		}
		lastHitLoc = Location;
	}

	function BeginState()
	{
		Super.BeginState();
		
		//MADDERs, 1/9/21: This don't fade otherwise. Oops.
		if ((Lifespan ~= 0.0) && (ShouldDoFade()))
		{
			Lifespan = 10.000000;
		}
		if (smokeGen != None)
			smokeGen.DelayedDestroy();
	}
}

function Destroyed()
{
	if (smokeGen != None)
		smokeGen.DelayedDestroy();

	Super.Destroyed();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	//MADDERS: Hack so fragments can be split into permanent and temporary.
	if (ShouldDoFade())
	{
	 	//randomize the lifespan a bit so things don't all disappear at once
	 	Lifespan = 30; //MADDERS: Used to be 10
	 	LifeSpan += FRand()*2.0;
	}
}

simulated function AddSmoke()
{
	smokeGen = Spawn(class'ParticleGenerator', Self);
	if (smokeGen != None)
	{
		smokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
		smokeGen.particleDrawScale = 0.5;
		smokeGen.riseRate = 10.0;
		smokeGen.ejectSpeed = 0.0;
		smokeGen.particleLifeSpan = 1.0;
		smokeGen.bRandomEject = True;
		smokeGen.SetBase(Self);
	}
}

simulated function Tick(float deltaTime)
{
   	if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
      		return;

	if ((bSmoking) && (!IsInState('Dying')) && (smokeGen == None))
		AddSmoke();

	// fade out the object smoothly 2 seconds before it dies completely
	if ((LifeSpan <= 2) && (LifeSpan != 0))
	{
		if (Style != STY_Translucent)
			Style = STY_Translucent;

		ScaleGlow = LifeSpan / 2.0;
	}
}

function float VMDGetMiscPitch()
{
	local bool bUnderwater;
	local float GMult;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	if (Region.Zone.bWaterZone) bUnderwater = True;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return (1.05 - (Frand() * 0.1)) * 0.7 * GMult;
	}
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return (1.05 - (Frand() * 0.1)) * GMult;
}

//MADDERS: Do NOT factor in randomization. We're already randomized, ideally.
function float VMDGetMiscPitch2()
{
	local bool bUnderwater;
	local float GMult;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	if (Region.Zone.bWaterZone) bUnderwater = True;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return 0.7 * GMult;
	}
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return 1.0 * GMult;
}

defaultproperties
{
     LifeSpan=0.000000
}
