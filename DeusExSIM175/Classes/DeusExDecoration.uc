//=============================================================================
// DeusExDecoration.
//=============================================================================
class DeusExDecoration extends Decoration
	abstract
	native;

#exec OBJ LOAD FILE=Effects

// for destroying them
var() travel int HitPoints;
var() int minDamageThreshold;
var() bool bInvincible;
var() class<Fragment> fragType;

// information for floating/bobbing decorations
var() bool bFloating;
var rotator origRot;

// lets us attach a decoration to a mover
var() name moverTag;

// object properties
var() bool bFlammable;				// can this object catch on fire?
var() float Flammability;			// how long does the object burn?
var() bool bExplosive;				// does this object explode when destroyed?
var() int explosionDamage;			// how much damage does the explosion cause?
var() float explosionRadius;		// how big is the explosion?

var() bool bHighlight;				// should this object not highlight when focused?

var() bool bCanBeBase;				// can an actor stand on this decoration?

var() bool bGenerateFlies;			// does this actor generate flies?

var int pushSoundId;				// used to stop playing the push sound

var int gradualHurtSteps;			// how many separate explosions for the staggered HurtRadius
var int gradualHurtCounter;			// which one are we currently doing

var name NextState;					// for queueing states
var name NextLabel;					// for queueing states

var FlyGenerator flyGen;			// fly generator

var localized string itemArticle;	
var localized string itemName;		// human readable name

native(2101) final function ConBindEvents();

//
// network replication
//
replication
{
	// Things the server should send to the client.
	reliable if( Role==ROLE_Authority )
		HitPoints, bInvincible, fragType, bFloating, origRot, moverTag;
/*
	// Things the client should send to the server
	reliable if ( Role<ROLE_Authority )
		WeaponPriority, Password;

	// Functions client can call.
	reliable if( Role<ROLE_Authority )
		Fire, AltFire, ServerRequestScores;

	// Functions server can call.
	reliable if( Role==ROLE_Authority )
		ClientAdjustGlow, ClientTravel, ClientSetMusic, SetDesiredFOV;
*/
}

// ----------------------------------------------------------------------
// PreBeginPlay()
// ----------------------------------------------------------------------

function PreBeginPlay()
{
	local DeusExLevelInfo info;
	
	Super.PreBeginPlay();
	
	// Bind any conversation events to this Decoration
//	ConBindEvents();
	
	forEach AllActors(class'DeusExLevelInfo', Info) break;
	if (info != None)
	{
		switch(Caps(info.MapName))
		{
			case "14_OCEANLAB_LAB":
			case "14_OCEANLAB_UC":
			case "15_AREA51_ENTRANCE":
			case "15_AREA51_FINAL":
			case "15_AREA51_PAGE":
				bGenerateFlies = false;
			break;
		}
	}
	if ((bGenerateFlies) && (FRand() < 0.1))
		flyGen = Spawn(Class'FlyGenerator', , , Location, Rotation);
	else
		flyGen = None;
}

// ----------------------------------------------------------------------
// PostPostBeginPlay()
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();

	// Bind any conversation events to this DeusExPlayer
	ConBindEvents();
}

// ----------------------------------------------------------------------
// BeginPlay()
//
// if we are already floating, then set our ref points
// ----------------------------------------------------------------------

function BeginPlay()
{
	local Mover M;

	Super.BeginPlay();

	if (bFloating)
		origRot = Rotation;

	// attach us to the mover that was tagged
	if (moverTag != '')
	{
		foreach AllActors(class'Mover', M, moverTag)
		{
			SetBase(M);
			SetPhysics(PHYS_None);
			bInvincible = True;
			bCollideWorld = False;
		}
	}
	if (fragType == class'GlassFragment')
		pushSound = sound'PushPlastic';
	else if (fragType == class'MetalFragment')
		pushSound = sound'PushMetal';
	else if (fragType == class'PaperFragment')
		pushSound = sound'PushPlastic';
	else if (fragType == class'PlasticFragment')
		pushSound = sound'PushPlastic';
	else if (fragType == class'WoodFragment')
		pushSound = sound'PushWood';
	else if (fragType == class'Rockchip')
		pushSound = sound'PushPlastic';
}

// ----------------------------------------------------------------------
// TravelPostAccept()
// ----------------------------------------------------------------------

function TravelPostAccept()
{
	Super.TravelPostAccept();
}

// ----------------------------------------------------------------------
// Landed()
// 
// Called when we hit the ground
// ----------------------------------------------------------------------

function Landed(vector HitNormal)
{
	local Rotator rot;
	local sound hitSound;

	// make it lay flat on the ground
	bFixedRotationDir = False;
	rot = Rotation;
	rot.Pitch = 0;
	rot.Roll = 0;
	SetRotation(rot);

	// play a sound effect if it's falling fast enough
	if (Velocity.Z <= -200)
	{
		if (fragType == class'WoodFragment')
		{
			if (Mass <= 20)
				hitSound = sound'WoodHit1';
			else
				hitSound = sound'WoodHit2';
		}
		else if (fragType == class'MetalFragment')
		{
			if (Mass <= 20)
				hitSound = sound'MetalHit1';
			else
				hitSound = sound'MetalHit2';
		}
		else if (fragType == class'PlasticFragment')
		{
			if (Mass <= 20)
				hitSound = sound'PlasticHit1';
			else
				hitSound = sound'PlasticHit2';
		}
		else if (fragType == class'GlassFragment')
		{
			if (Mass <= 20)
				hitSound = sound'GlassHit1';
			else
				hitSound = sound'GlassHit2';
		}
		else	// paper sound
		{
			if (Mass <= 20)
				hitSound = sound'PaperHit1';
			else
				hitSound = sound'PaperHit2';
		}

		if (hitSound != None)
			PlaySound(hitSound, SLOT_None);

		// alert NPCs that I've landed
		AISendEvent('LoudNoise', EAITYPE_Audio);
	}

	bWasCarried = false;
	bBobbing    = false;

	// The crouch height is higher in multiplayer, so we need to be more forgiving on the drop velocity to explode
	if ( Level.NetMode != NM_Standalone )
	{
		if ((bExplosive && (VSize(Velocity) > 478)) || (!bExplosive && (Velocity.Z < -500)))
			TakeDamage((1-Velocity.Z/30), Instigator, Location, vect(0,0,0), 'fell');
	}
	else
	{
		if ((bExplosive && (VSize(Velocity) > 425)) || (!bExplosive && (Velocity.Z < -500)))
			TakeDamage((1-Velocity.Z/30), Instigator, Location, vect(0,0,0), 'fell');
	}
}

// ----------------------------------------------------------------------
// SupportActor()
//
// Called when somebody lands on us
// ----------------------------------------------------------------------

singular function SupportActor(Actor standingActor)
{
	local vector newVelocity;
	local float  angle;
	local float  zVelocity;
	local float  baseMass;
	local float  standingMass;
	
	zVelocity = standingActor.Velocity.Z;
	// We've been stomped!
	if (zVelocity < -500)
	{
		standingMass = FMax(1, standingActor.Mass);
		baseMass     = FMax(1, Mass);
		TakeDamage((1 - standingMass/baseMass * zVelocity/30),
		           standingActor.Instigator, standingActor.Location, 0.2*standingActor.Velocity, 'stomped');
	}
	
	if (!bCanBeBase)
	{
		angle = FRand()*Pi*2;
		newVelocity.X = cos(angle);
		newVelocity.Y = sin(angle);
		newVelocity.Z = 0;
		newVelocity *= FRand()*25 + 25;
		newVelocity += standingActor.Velocity;
		newVelocity.Z = 50;
		standingActor.Velocity = newVelocity;
		if (ThrownProjectile(StandingActor) == None)
		{
			standingActor.SetPhysics(PHYS_Falling);
		}
	}
	else
	{
		standingActor.SetBase(self);
	}
}


// ----------------------------------------------------------------------
// ResetScaleGlow()
//
// Reset the ScaleGlow to the default
// Decorations modify ScaleGlow using damage
// ----------------------------------------------------------------------

function ResetScaleGlow()
{
	if ((!bInvincible) && (!IsA('Van')))
		ScaleGlow = float(HitPoints) / float(Default.HitPoints) * 0.9 + 0.1;
}

// ----------------------------------------------------------------------
// BaseChange()
//
// Ripped out most of the code from the original BaseChange; the equivalent
// functionality has been moved to Landed() and SupportActor()
// ----------------------------------------------------------------------

singular function BaseChange()
{
	local VMDBufferPlayer VMP;
	
 	// DXRando: check if we're being carried
	/*VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.CarriedDecoration == self))
	{
		VMP.ForcePutCarriedDecorationInHand();
		return;
	}*/
	
	bBobbing = false;
	
	if( (base == None) && (bPushable || IsA('Carcass')) && (Physics == PHYS_None) )
		SetPhysics(PHYS_Falling);
	
	// make sure if a decoration is accidentally dropped,
	// we reset it's parameters correctly
	SetCollision(Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers);
	Style = Default.Style;
	bUnlit = Default.bUnlit;
	ResetScaleGlow();
}

// ----------------------------------------------------------------------
// Tick()
//
// Make the decoration act like it is floating
// ----------------------------------------------------------------------

simulated function Tick(float deltaTime)
{
	local float        ang;
	local rotator      rot;
	local DeusExPlayer player;
	
	//MADDERS related.
	local VMDBufferDeco VMD;
	local Rotator TRot;

	Super.Tick(deltaTime);
	
	if (bFloating)
	{
		ang = 2 * Pi * Level.TimeSeconds / 4.0;
		rot = origRot;
		rot.Pitch += Sin(ang) * 512;
		rot.Roll += Cos(ang) * 512;
		rot.Yaw += Sin(ang) * 256;
		SetRotation(rot);
	}

	// BOOGER!  This is a hack!
	// Ideally, we'd set the base of the fly generator to this decoration,
	// but unfortunately this prevents the player from picking up the
	// decoration... need to fix!

	if (flyGen != None)
	{
		if ((flyGen.Location != Location) || (flyGen.Rotation != Rotation))
		{
			flyGen.SetLocation(Location);
			flyGen.SetRotation(Rotation);
		}
	}

	// If we have any conversations, check to see if we're close enough
	// to the player to start one (and all the other checks that take place
	// when a valid conversation can be started);

	if (conListItems != None)
	{
		player = DeusExPlayer(GetPlayerPawn());
		if (player != None)
			player.StartConversation(Self, IM_Radius);
	}

   	if ((Level.Netmode != NM_Standalone) && (VSize(Velocity) > 0) && (VSize(Velocity) < 5))
   	{
      		Velocity *= 0;
  	}
	
	VMD = VMDBufferDeco(Self);
	if ((VMD != None) && (VMD.AttachedMover != None))
	{
	 	SetRotation(VMD.AttachedMover.Rotation + VMD.AttachRot);
	 	TRot = Rotation - VMD.BaseRot;
	 	SetLocation(VMD.AttachedMover.Location + (VMD.AttachOff >> TRot));
	}
	
	if ((VMDBufferDeco(Self) != None) && (!VMDBufferDeco(Self).bDidSetup))
	{
		VMDBufferDeco(Self).ApplySpecialStats();
		VMDBufferDeco(Self).bDidSetup = true;
	}
}

// ----------------------------------------------------------------------
// ZoneChange()
// this decoration will now float with cool bobbing if it is
// buoyant enough
// ----------------------------------------------------------------------

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	if (bFloating && !NewZone.bWaterZone)
	{
		bFloating = False;
		SetRotation(origRot);
		return;
	}

	if (NewZone.bWaterZone)
		ExtinguishFire();

	if ((NewZone.bWaterZone) && (!bFloating) && (Buoyancy > Mass))
	{
		bFloating = True;
		origRot = Rotation;
	}
}

// ----------------------------------------------------------------------
// Bump()
// copied from Engine\Classes\Decoration.uc
// modified so we can have strength modify what you can push
// ----------------------------------------------------------------------

function Bump(actor Other)
{
	local int augLevel;
	local float maxPush, velscale, GSpeed, augMult;
	local DeusExPlayer player;
	local Rotator rot;

	player = DeusExPlayer(Other);
	
	if ((!Region.Zone.bWaterZone) && (((bFlammable) && (!bInvincible)) || GetPropertyText("bAlwaysFlammable") ~= "True"))
	{
		// if we are bumped by a burning pawn, then set us on fire
		if ((Pawn(Other) != None) && (Pawn(Other).bOnFire) && (!Other.IsA('Robot')))
			GotoState('Burning');
		
		// if we are bumped by a burning decoration, then set us on fire
		if ((DeusExDecoration(Other) != None) && (DeusExDecoration(Other).IsInState('Burning')))
			GotoState('Burning');
		
		//MADDERS: Optimized, debugged, and now we're including flare bumping as well.
		if ((Flare(Other) != None) && (Flare(Other).LightType != LT_None) && (HitPoints > 1))
		{
			GoToState('Burning');
		}
	}
	
	// Check to see if the actor touched is the Player Character
	if (player != None)
	{
		//MADDERS: Don't allow climbing to push us!
		if (player.IsInState('Climbing') || player.IsInState('ClimbingAdvance'))
		{
		 return;
		}
		
		// if we are being carried, ignore Bump()
		if (player.CarriedDecoration == Self)
			return;

		// check for convos
		// NO convos on bump
//		if ( player.StartConversation(Self, IM_Bump) )
//			return;
	}

	if (bPushable && (PlayerPawn(Other)!=None) && (Other.Mass > 40))// && (Physics != PHYS_Falling))
	{	
		// A little bit of a hack...
		// Make sure this decoration isn't being bumped from above or below
		if (abs(Location.Z-Other.Location.Z) < (CollisionHeight+Other.CollisionHeight-1))
		{
			maxPush = 100;
			augMult = 1.0;
			if (player != None)
			{
				if (VMDBufferAugmentationManager(player.AugmentationSystem) != None)
				{
					//MADDERS: Use custom function for this vs drop strength
					AugMult = VMDBufferAugmentationManager(player.AugmentationSystem).VMDConfigureDecoPushMult();
					maxPush *= augMult;
				}
				else if (Player.AugmentationSystem != None)
				{
					augLevel = player.AugmentationSystem.GetClassLevel(class'AugMuscle');
					if (augLevel >= 0)
						augMult = augLevel+2;
				}
			}

			if (Mass <= maxPush)
			{
				// slow it down based on how heavy it is and what level my augmentation is
				velscale = FClamp((50.0 * augMult) / Mass, 0.0, 1.0);
				if (velscale < 0.25)
					velscale = 0;

				// apply more velocity than normal if we're floating
				if (bFloating)
					Velocity = Other.Velocity;
				else
					Velocity = Other.Velocity * velscale;

				if (Physics != PHYS_Falling)
					Velocity.Z = 0;

				if ((!bFloating) && (!bPushSoundPlaying) && (Mass > 15))
				{
					GSpeed = 1.0;	
					if ((Level != None) && (Level.Game != None)) GSpeed = Level.Game.GameSpeed;
					
					pushSoundId = PlaySound(PushSound, SLOT_Misc,,, 128, GSpeed);
					if (FragType == class'MetalFragment' || bInvincible)
					{
						AIStartEvent('LoudNoise', EAITYPE_Audio, , 320);
					}
					else
					{
						AIStartEvent('LoudNoise', EAITYPE_Audio, , 160);
					}
					bPushSoundPlaying = True;
				}

				if ((!bFloating) && (Physics != PHYS_Falling))
					SetPhysics(PHYS_Rolling);
				
				// Transcended - Fixes objects that are pushed while on fire not burning
				if (!IsInState('Burning'))
					SetTimer(0.2, False);
				Instigator = Pawn(Other);

				// Impart angular velocity (yaw only) based on where we are bumped from
				// NOTE: This is faked, but it looks cool
				rot = Rotator((Other.Location - Location) << Rotation);
				rot.Pitch = 0;
				rot.Roll = 0;

				// ignore which side we're pushing from
				if (rot.Yaw >= 24576)
					rot.Yaw -= 32768;
				else if (rot.Yaw >= 8192)
					rot.Yaw -= 16384;
				else if (rot.Yaw <= -24576)
					rot.Yaw += 32768;
				else if (rot.Yaw <= -8192)
					rot.Yaw += 16384;

				// scale it down based on mass and apply the new "rotational force"
				rot.Yaw *= velscale * 0.025;
				SetRotation(Rotation+rot);
			}
		}
	}
}

// ----------------------------------------------------------------------
// Timer() function for Bump
//
// shuts off the looping push sound
// ----------------------------------------------------------------------

function Timer()
{
	if (bPushSoundPlaying)
	{
		StopSound(pushSoundId);
		AIEndEvent('LoudNoise', EAITYPE_Audio);
		bPushSoundPlaying = False;
	}
}

// ----------------------------------------------------------------------
// DropThings()
// 
// drops everything that is based on this decoration
// ----------------------------------------------------------------------

function DropThings()
{
	local actor A;

	// drop everything that is on us
	foreach BasedActors(class'Actor', A)
		if (!A.IsA('ParticleGenerator'))
			A.SetPhysics(PHYS_Falling);
}


// ----------------------------------------------------------------------
// EnterConversationState()
// ----------------------------------------------------------------------

function EnterConversationState(bool bFirstPerson, optional bool bAvoidState)
{
	// First check to see if we're already in a conversation state, 
	// in which case we'll abort immediately

	if ((GetStateName() == 'Conversation') || (GetStateName() == 'FirstPersonConversation'))
		return;

	NextState = GetStateName();

	// If bAvoidState is set, then we don't want to jump into the conversaton state
	// because bad things might happen otherwise.

	if (!bAvoidState)
	{
		if (bFirstPerson)
			GotoState('FirstPersonConversation');
		else
			GotoState('Conversation');
	}
}

// ----------------------------------------------------------------------
// EndConversation()
// ----------------------------------------------------------------------

function EndConversation()
{
	Super.EndConversation();

	Enable('Bump');

	GotoState(NextState);
}

// ----------------------------------------------------------------------
// state Conversation 
//
// Just sit here until the conversation is over
// ----------------------------------------------------------------------

state Conversation
{
	ignores bump, frob;
	
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if ((VMDBufferDeco(Self) != None) && (VMDBufferDeco(Self).VMDMuteFemaleVoice()))
		{
			TransientSoundVolume = 0;
		}
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if ((VMDBufferDeco(Self) != None) && (VMDBufferDeco(Self).VMDMuteFemaleVoice()))
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
  	}
	
	event Tick(float deltaTime)
	{
		local float Ang;
		local Rotator Rot;
		
		Super.Tick(DeltaTime);
		
		if (bFloating)
		{
			ang = 2 * Pi * Level.TimeSeconds / 4.0;
			rot = origRot;
			rot.Pitch += Sin(ang) * 512;
			rot.Roll += Cos(ang) * 512;
			rot.Yaw += Sin(ang) * 256;
			SetRotation(rot);
		}
		
		if ((VMDBufferDeco(Self) != None) && (VMDBufferDeco(Self).VMDMuteFemaleVoice()))
		{
			TransientSoundVolume = 0;
		}
	}

Idle:
	Sleep(1.0);
	goto('Idle');

Begin:

	// Make sure we're not on fire!
	ExtinguishFire();

	goto('Idle');
}


// ----------------------------------------------------------------------
// state FirstPersonConversation 
//
// Just sit here until the conversation is over
// ----------------------------------------------------------------------

state FirstPersonConversation
{
	ignores bump, frob;
	
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if ((VMDBufferDeco(Self) != None) && (VMDBufferDeco(Self).VMDMuteFemaleVoice()))
		{
			TransientSoundVolume = 0;
		}
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if ((VMDBufferDeco(Self) != None) && (VMDBufferDeco(Self).VMDMuteFemaleVoice()))
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
  	}
	
	event Tick(float deltaTime)
	{
		local float Ang;
		local Rotator Rot;
		
		Super.Tick(DeltaTime);
		
		if (bFloating)
		{
			ang = 2 * Pi * Level.TimeSeconds / 4.0;
			rot = origRot;
			rot.Pitch += Sin(ang) * 512;
			rot.Roll += Cos(ang) * 512;
			rot.Yaw += Sin(ang) * 256;
			SetRotation(rot);
		}
		
		if ((VMDBufferDeco(Self) != None) && (VMDBufferDeco(Self).VMDMuteFemaleVoice()))
		{
			TransientSoundVolume = 0;
		}
	}

Idle:
	Sleep(1.0);
	goto('Idle');

Begin:
	goto('Idle');
}

// ----------------------------------------------------------------------
// Explode()
// Blow it up real good!
// ----------------------------------------------------------------------
function Explode(vector HitLocation)
{
	local ShockRing ring;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;

	// make sure we wake up when taking damage
	bStasis = False;

	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius * 16);

	if (explosionRadius <= 128)
		PlaySound(Sound'SmallExplosion1', SLOT_None,,, explosionRadius*16);
	else
		PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	if (explosionRadius < 128)
	{
		Spawn(class'ExplosionSmall',,, HitLocation);
		light.size = 2;
	}
	else if (explosionRadius < 256)
	{
		Spawn(class'ExplosionMedium',,, HitLocation);
		light.size = 4;
	}
	else
	{
		Spawn(class'ExplosionLarge',,, HitLocation);
		light.size = 8;
	}

	// draw a pretty shock ring
	ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
	if (ring != None)
		ring.size = explosionRadius / 32.0;
	ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
	if (ring != None)
		ring.size = explosionRadius / 32.0;
	ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
	if (ring != None)
		ring.size = explosionRadius / 32.0;

	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}

	// spawn some rocks
	for (i=0; i<explosionDamage/30+1; i++)
		if (FRand() < 0.8)
			spawn(class'Rockchip',,,HitLocation);

	GotoState('Exploding');
}

// ----------------------------------------------------------------------
// Exploding state
// ----------------------------------------------------------------------

state Exploding
{
	ignores Explode;

	function Timer()
	{
		local Pawn apawn;
		local float damageRadius;
		local Vector dist;

		if ( Level.NetMode != NM_Standalone )
		{
			damageRadius = (explosionRadius / gradualHurtSteps) * gradualHurtCounter;

			for ( apawn = Level.PawnList; apawn != None; apawn = apawn.nextPawn )
			{
				if ( apawn.IsA('DeusExPlayer') )
				{
					dist = apawn.Location - Location;
					if ( VSize(dist) < damageRadius )
						DeusExPlayer(apawn).myProjKiller = Self;
				}
			}
		}
		HurtRadius
		(
			(2 * explosionDamage) / gradualHurtSteps,
			(explosionRadius / gradualHurtSteps) * gradualHurtCounter,
			'Exploded',
			(explosionDamage / gradualHurtSteps) * 100,
			Location
		);
		if (++gradualHurtCounter >= gradualHurtSteps)
			Destroy();
	}

Begin:
	// stagger the HurtRadius outward using Timer()
	// do five separate blast rings increasing in size
	gradualHurtCounter = 1;
	gradualHurtSteps = 5;
	bHidden = True;
	SetCollision(False, False, False);
	SetTimer(0.5/float(gradualHurtSteps), True);
}

// ----------------------------------------------------------------------
// this is our normal, just sitting there state
// ----------------------------------------------------------------------
auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		local float avg;
		local Vector tempVelocity;
		local Rotator rot;
		
		//G-Flex: don't take damage if pending deletion, to prevent double-fragging
		if (bDeleteMe)
			return;	
			
		if (bStatic)
			return;
			
		if ((IsA('Containers')) && (bInvincible) && (DamageType == 'Exploded'))
		{
			tempVelocity = (Momentum / ((0.1 * Mass) - 1));
			if (tempVelocity.X > 1000)
				tempVelocity.X = 1000;
			else if (tempVelocity.X < -1000)
				tempVelocity.X = -1000;
			if (tempVelocity.Y > 1000)
				tempVelocity.Y = 1000;
			else if (tempVelocity.Y < -1000)
				tempVelocity.Y = -1000;
			if (tempVelocity.Z > 1000)
				tempVelocity.Z = 1000;
			else if (tempVelocity.Z < -1000)
				tempVelocity.Z = -1000;
			Velocity = tempVelocity;
			rot = Rotator((HitLocation + Location) << Rotation);
			rot.Pitch = 0;
			rot.Roll = 0;
			if (rot.Yaw >= 24576)
				rot.Yaw -= 32768;
			else if (rot.Yaw >= 8192)
				rot.Yaw -= 16384;
			else if (rot.Yaw <= -24576)
				rot.Yaw += 32768;
			else if (rot.Yaw <= -8192)
				rot.Yaw += 16384;
			//rot.Yaw *= 0.025;
			SetRotation(Rotation+rot);
			if (Physics != PHYS_Falling)
				SetPhysics(PHYS_Falling);
		}

		if (bStatic || bInvincible)
			return;

		if ((DamageType == 'TearGas') || (DamageType == 'PoisonGas') || (DamageType == 'DrugDamage') || (DamageType == 'Radiation'))
			return;

		if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
			return;

		if (DamageType == 'HalonGas')
		{
			ExtinguishFire();
			return;
		}
		
		if (((DamageType == 'Burned') || (DamageType == 'Flamed')) && (Van(Self) == None))
		{
			if (bExplosive)		// blow up if we are hit by fire
				HitPoints = 0;
			else if ((bFlammable) && (!Region.Zone.bWaterZone))
			{
				GotoState('Burning');
				return;
			}
		}

		if (Damage >= minDamageThreshold)
		{
			HitPoints -= Damage;
		}
		else
		{
			// sabot damage at 50%
			// explosion damage at 25%
			if (damageType == 'Sabot')
				HitPoints -= Damage * 0.5;
			else if (damageType == 'Exploded')
				HitPoints -= Damage * 0.25;
		}

		if (HitPoints > 0)		// darken it to show damage (from 1.0 to 0.1 - don't go completely black)
		{
			ResetScaleGlow();
		}
		else	// destroy it!
		{
			DropThings();

			// clear the event to keep Destroyed() from triggering the event
			Event = '';
			avg = (CollisionRadius + CollisionHeight) / 2;
			Instigator = EventInstigator;
			if (Instigator != None)
				MakeNoise(1.0);

			if (fragType == class'WoodFragment')
			{
				if (avg > 20)
					PlaySound(sound'WoodBreakLarge', SLOT_Misc,,, 512);
				else
					PlaySound(sound'WoodBreakSmall', SLOT_Misc,,, 512);
				AISendEvent('LoudNoise', EAITYPE_Audio, , 512);
			}

			// if we have been blown up, then destroy our contents
			// CNN - don't destroy contents now
//			if (DamageType == 'Exploded')
//			{
//				Contents = None;
//				Content2 = None;
//				Content3 = None;
//			}

			if (bExplosive)
			{
				Frag(fragType, Momentum * explosionRadius / 4, avg/20.0, avg/5 + 1);
				Explode(HitLocation);
			}
			else
			{
				Frag(fragType, Momentum / 10, avg/20.0, avg/5 + 1);
			}
		}
	}
}

// ----------------------------------------------------------------------
// ExtinguishFire()
// ----------------------------------------------------------------------

function ExtinguishFire()
{
	local Fire f;

	if (IsInState('Burning'))
	{
		foreach BasedActors(class'Fire', f)
			f.Destroy();

		GotoState('Active');
	}
}

// ----------------------------------------------------------------------
// state Burning
//
// We are burning and slowly taking damage
// ----------------------------------------------------------------------

state Burning
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		local float avg;

		if ((DamageType == 'TearGas') || (DamageType == 'PoisonGas') || (DamageType == 'DrugDamage') || (DamageType == 'Radiation'))
			return;

		if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
			return;

		if (DamageType == 'HalonGas')
		{
			ExtinguishFire();
			return;
		}
		
		// if we are already burning, we can't take any more damage
		if ((DamageType == 'Burned') || (DamageType == 'Flamed'))
		{
			HitPoints -= Damage/2;
		}
		else
		{
			if (Damage >= minDamageThreshold)
				HitPoints -= Damage;
		}

		if (bExplosive)
			HitPoints = 0;

		if (HitPoints > 0)		// darken it to show damage (from 1.0 to 0.1 - don't go completely black)
		{
			ResetScaleGlow();
		}
		else	// destroy it!
		{
			DropThings();

			// clear the event to keep Destroyed() from triggering the event
			Event = '';
			avg = (CollisionRadius + CollisionHeight) / 2;
			Frag(fragType, Momentum / 10, avg/20.0, avg/5 + 1);
			Instigator = EventInstigator;
			if (Instigator != None)
				MakeNoise(1.0);

			// if we have been blown up, then destroy our contents
			if (bExplosive)
			{
				//Contents = None;
				//Content2 = None;
				//Content3 = None;
				Explode(HitLocation);
			}
		}
	}

	// continually burn and do damage
	function Timer()
	{
		if (bPushSoundPlaying)
		{
			StopSound(pushSoundId);
			AIEndEvent('LoudNoise', EAITYPE_Audio);
			bPushSoundPlaying = False;
		}
		TakeDamage(2, None, Location, vect(0,0,0), 'Burned');
	}

	function BeginState()
	{
		local Fire f;
		local int i, j;
		local vector loc;

		for (i=0; i<8; i++)
		{
			loc.X = 0.9*CollisionRadius * (1.0-2.0*FRand());
			loc.Y = 0.9*CollisionRadius * (1.0-2.0*FRand());
			loc.Z = 0.9*CollisionHeight * (1.0-2.0*FRand());
			loc += Location;
			f = Spawn(class'Fire', Self,, loc);
			if (f != None)
			{
				f.DrawScale = FRand() + 1.0;
				f.LifeSpan = Flammability;

				// turn off the sound and lights for all but the first one
				if (i > 0)
				{
					f.AmbientSound = None;
					f.LightType = LT_None;
				}

				// turn on/off extra fire and smoke
				if (FRand() < 0.5)
					f.smokeGen.Destroy();
				if (FRand() < 0.5)
					f.AddFire(1.5);
			}
		}
		
		// How about we don't sit on a burning chair.
		if (IsA('Seat'))
		{
			for (j=0; j<ArrayCount(Seat(Self).sittingActor); j++)
			{
				if (Seat(Self).sittingActor[j] != None)
				{
					if (((ScriptedPawn(Seat(Self).sittingActor[j]) != None) &&
						 ScriptedPawn(Seat(Self).sittingActor[j]).bSitting))
					{
						ScriptedPawn(Seat(Self).sittingActor[j]).GoToState('Wandering');
						break;
					}
				}
			}
		}
		
		// set the burn timer
		SetTimer(1.0, True);
	}
}

// ----------------------------------------------------------------------
// Frob()
//
// If we are frobbed, trigger our event
// ----------------------------------------------------------------------
function Frob(Actor Frobber, Inventory frobWith)
{
	local Actor A;
	local Pawn P;
	local DeusExPlayer Player;

	P = Pawn(Frobber);
	Player = DeusExPlayer(Frobber);
	
	Super.Frob(Frobber, frobWith);

	// First check to see if there's a conversation associated with this 
	// decoration.  If so, trigger the conversation instead of triggering
	// the event for this decoration

	if ( Player != None )
	{
		if ( player.StartConversation(Self, IM_Frob) )
			return;
	}

	// Trigger event if we aren't hackable
	if (!IsA('HackableDevices'))
		if (Event != '')
			foreach AllActors(class 'Actor', A, Event)
				A.Trigger(Self, P);
}

// ----------------------------------------------------------------------
// Frag()
//
// copied from Engine.Decoration
// modified so fragments will smoke	and use the skin of their parent object
// ----------------------------------------------------------------------

simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags) 
{
	local int i;
	local actor A, Toucher;
	local DeusExFragment s;

	if ( bOnlyTriggerable )
		return; 
	if (Event!='')
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Toucher, pawn(Toucher) );
	if ( Region.Zone.bDestructive )
	{
		Destroy();
		return;
	}
	for (i=0 ; i<NumFrags ; i++) 
	{
		s = DeusExFragment(Spawn(FragType, Owner));
		if (s != None)
		{
			s.Instigator = Instigator;
			s.CalcVelocity(Momentum,0);
			s.DrawScale = DSize*0.5+0.7*DSize*FRand();
			s.Skin = GetMeshTexture();
			if (bExplosive)
				s.bSmoking = True;
		}
	}

	if (!bExplosive)
		Destroy();
}

// ----------------------------------------------------------------------
// Destroyed()
// ----------------------------------------------------------------------

function Destroyed()
{
	local DeusExPlayer player;

	if (bPushSoundPlaying)
	{
		StopSound(pushSoundId);
		AIEndEvent('LoudNoise', EAITYPE_Audio);
		bPushSoundPlaying = False;
	}

	if (flyGen != None)
	{
		flyGen.Burst();
		flyGen.StopGenerator();
		flyGen = None;
	}

	// Pass a message to conPlay, if it exists in the player, that 
	// this object has been destroyed.  This is used to prevent 
	// bad things from happening in converseations.

	player = DeusExPlayer(GetPlayerPawn());

	if ((player != None) && (player.conPlay != None))
	{
		player.conPlay.ActorDestroyed(Self);
	}
	
	if (!IsA('Containers'))
	{
	 	if (VMDBufferDeco(Self) != None)
	 	{
	  		VMDBufferDeco(Self).SimulateSuperDestroyed();
	 	}
	 	else
	 	{
	  		Super.Destroyed();
	 	}
	}
}

// ----------------------------------------------------------------------
// Trigger()
//
// if we are triggered and explosive, then explode
// ----------------------------------------------------------------------

function Trigger(Actor Other, Pawn Instigator)
{
	if (bExplosive)
	{
		Explode(Location);
		Super.Trigger(Other, Instigator);
	}
}

defaultproperties
{
     HitPoints=20
     FragType=Class'DeusEx.MetalFragment'
     Flammability=30.000000
     explosionDamage=100
     explosionRadius=768.000000
     bHighlight=True
     ItemArticle="a"
     ItemName="DEFAULT DECORATION NAME - REPORT THIS AS A BUG"
     bPushable=True
     PushSound=Sound'DeusExSounds.Generic.PushMetal'
     bStatic=False
     bTravel=True
     Physics=PHYS_Falling
     DrawType=DT_Mesh
     bCollideActors=True
     bCollideWorld=True
     bBlockActors=True
     bBlockPlayers=True
}
