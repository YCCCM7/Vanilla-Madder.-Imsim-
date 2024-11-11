//=============================================================================
// VMDBufferDeco.
//=============================================================================
class VMDBufferDeco extends DeusExDecoration
	abstract;

//++++++++++++++++++++++++
//MADDERS ADDITIONS!
var bool bDidSetup, bEverNotFrobbed, bDidItemDrop, bSwappedCollision;
var bool bAlwaysFlammable; //MADDERS: This allows us to light on fire, even if invincible. Mod support, bb.
var float FloatTimer;

//MADDERS: Used for sticking to movers better.
var Mover AttachedMover; //Hack!
var Rotator AttachRot, BaseRot;
var Vector AttachOff;

//G-Flex: we need to use contents/content2/content3 to represent items
//G-Flex: but we can't make those travel vars
var() travel string contentsBackup;
var() travel string content2Backup;
var() travel string content3Backup;

var() float dripRate;
var() float waterDripCounter;

var(Movement) vector origLocation;
var vector pendingLocation;
var bool bUpdateLoc, LastSeenState;
var() bool bMemorable;

var() bool bSuperOwned; //MADDERS, 12/23/23: Alert people nearby we're basically stealing.
var() travel int StoredSeed;

function string VMDGetItemName()
{
	return ItemName;
}

function bool VMDMuteFemaleVoice()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (BindName ~= "JCDenton"))
	{
		if ((VMP.bAssignedFemale) && (!VMP.bAllowFemaleVoice || VMP.bDisableFemaleVoice))
		{
			return true;
		}
	}
	
	return false;
}

function bool VMDPlausiblyDeniableNoise()
{
	local int i;
	local ScriptedPawn TPawn;
	
	forEach RadiusActors(class'ScriptedPawn', TPawn, 640, Location)
	{
		if ((Animal(TPawn) == None) && (Robot(TPawn) == None))
		{
			i++;
			if (i > 1) break;
		}
	}
	
	return (i > 1);
}

singular function DripWater(float deltaTime)
{
	local float  dripPeriod;
	local float  adjustedRate;
	local vector waterVector;
	local vector vel;
	local rotator SpawnRotation;
	local WaterDrop WaterSpawned;
	
	//Copied from ScriptedPawn::Tick()
	dripRate = FClamp(dripRate, 0.0, 15.0);
	if (dripRate > 0)
	{
		adjustedRate = 1;
		dripPeriod = adjustedRate / FClamp(VSize(Velocity)/512.0, 5, 10);
		waterDripCounter += deltaTime;
		while (waterDripCounter >= dripPeriod)
		{
			vel = 0.1*Velocity;
			vel.Z = 0;
			
			SpawnRotation = rot(0,0,0);
			SpawnRotation.Pitch = 49152;
			
			waterVector = VRand() * CollisionRadius;
			if (VSize(Velocity) > 16)
				WaterSpawned = spawn(Class'WaterDrop',Self,,waterVector+Location,rotator(Velocity-vel));
			else
				WaterSpawned = spawn(Class'WaterDrop',Self,,waterVector+Location, SpawnRotation);
			
			if (WaterSpawned != None)
				WaterSpawned.Velocity.Z = Velocity.Z;
			
			waterDripCounter -= dripPeriod;
		}
		dripRate -= deltaTime;
	}
	
	if (dripRate <= 0)
	{
		dripRate = 0;
		waterDripCounter = 0;
	}
}

function Landed(vector HitNormal)
{
	local Rotator rot;
	local sound hitSound;

	//make it lay flat on the ground
	bFixedRotationDir = False;
	rot = Rotation;
	rot.Pitch = 0;
	rot.Roll = 0;
	
	//Would allow a deco to land on one of its sides instead of always upright, but overwrote by Tick()
	//If this is ever enabled it should only happen for square things (due to collision) without any missing polygons
    	//if (rot.Pitch % 16384 < 8192)
        	//rot.Pitch = rot.Pitch - rot.Pitch % 16384;
    	//else if (rot.Pitch % 5 != 0)
        	//rot.Pitch = rot.Pitch + (16384 - rot.Pitch % 16384);
		
	//if (rot.Roll % 16384 < 8192)
        	//rot.Roll = rot.Roll - rot.Roll % 16384;
    	//else if (rot.Roll % 5 != 0)
        	//rot.Roll = rot.Roll + (16384 - rot.Roll % 16384);
	
	SetRotation(rot);

	//play a sound effect if it's falling fast enough
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
		else	//paper sound
		{
			if (Mass <= 20)
				hitSound = sound'PaperHit1';
			else
				hitSound = sound'PaperHit2';
		}

		if (hitSound != None)
		{
			PlaySound(hitSound, SLOT_None,,,,VMDGetMiscPitch());
		}
		
		//alert NPCs that I've landed
		if (!IsA('InformationDevices'))
			AISendEvent('LoudNoise', EAITYPE_Audio);
	}

	bWasCarried = false;
	bBobbing = false;

	//The crouch height is higher in multiplayer, so we need to be more forgiving on the drop velocity to explode
	if (Level.NetMode != NM_Standalone)
	{
		if (((bExplosive) && (VSize(Velocity) > 478)) || ((!bExplosive) && (Velocity.Z < -500)))
			TakeDamage((1-Velocity.Z/30), Instigator, Location, vect(0,0,0), 'fell');
	}
	else
	{
		if (((bExplosive) && (VSize(Velocity) > 425)) || ((!bExplosive) && (Velocity.Z < -500)))
			TakeDamage((1-Velocity.Z/30), Instigator, Location, vect(0,0,0), 'fell');
	}
	
	if ((bExplosive) && (origLocation == Default.origLocation))
		origLocation = Location;
}

function Tick(float deltaTime)
{	
	// local vector Loc;

	if (Region.Zone != None && Region.Zone.bWaterZone)
	{
		dripRate += deltaTime*2;
				
		if (dripRate >= 15)
			dripRate = 15.0;
	}
	else if (dripRate > 0)
		DripWater(deltaTime);
	
	Super.Tick(deltaTime);
	
	if (bUpdateLoc)
	{
		origLocation = pendingLocation;
		bUpdateLoc = False;
	}
	
	// Rotate to our velocity
	// if (Physics == PHYS_Falling && VSize(Velocity) > 5 && !Region.Zone.bWaterZone)
		// SetRotation(Rotator(Velocity / Mass));
}

function UpdateLocation(vector newLoc)
{
	if (!bUpdateLoc)
	{
		bUpdateLoc = True;
		pendingLocation = newLoc;
	}
}

//MADDERS, 3/7/21: Fun fact. These are not actually seen in DXT, but are compartmentalizations of key processes.
//Let it be known I *hate* literal actor casting for special effects. Very mod un-friendly.
function bool DXTHasOtherPositionObject()
{
	return false;
}

function DXTUpdateSeenExtras()
{
}

// ----------------------------------------------------------------------
// BeginPlay()
//
// if we are already floating, then set our ref points
// ----------------------------------------------------------------------

function BeginPlay()
{
	local Mover M;

	Super(Decoration).BeginPlay();

	if (bFloating)
		origRot = Rotation;

	// attach us to the mover that was tagged
	if (moverTag != '')
	{
		foreach AllActors(class'Mover', M, moverTag)
		{
			//MADDERS: Use this for sticking onto decos with maximum accuracy.
			AttachedMover = M;
			AttachRot = Rotation - M.Rotation;
			BaseRot = Rotation;
			AttachOff = Location - M.Location;
			
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
	
	if ((Mass > 10) && (!bStatic) && (!bHidden)) bMemorable = true;
}

// ----------------------------------------------------------------------
// TravelPostAccept()
// ----------------------------------------------------------------------

function TravelPostAccept()
{
	local class<inventory> tempClass;
	
	//G-Flex: recheck to set up a fly generator
	if ((bGenerateFlies) && (FRand() < 0.1))
	{
		if (flyGen == None)
			flyGen = Spawn(Class'FlyGenerator', , , Location, Rotation);
	}
	else
		flyGen = None;

	//G-Flex: restore contents from backed-up names
	if (contentsBackup != "")
	{
		tempClass = class<inventory>(DynamicLoadObject(contentsBackup, class'Class'));
		contents = tempClass;
		contentsBackup = "";
	}
	if (content2Backup != "")
	{
		tempClass = class<inventory>(DynamicLoadObject(content2Backup, class'Class'));
		content2 = tempClass;
		content2Backup = "";
	}
	if (content3Backup != "")
	{
		tempClass = class<inventory>(DynamicLoadObject(content3Backup, class'Class'));
		content3 = tempClass;
		content3Backup = "";
	}

	//== I don't know why we don't call Super here, but base DX overrides this so hey why not
}

// ----------------------------------------------------------------------
// GetLevelInfo()
// ----------------------------------------------------------------------

function DeusExLevelInfo GetLevelInfo()
{
	local DeusExLevelInfo info;

	foreach AllActors(class'DeusExLevelInfo', info)
		break;

	return info;
}

// ----------------------------------------------------------------------
// GetStackMass()
// 
// G-Flex: gets the mass of the decoration and all others using it as a base
// ----------------------------------------------------------------------

function float GetStackMass(actor baseThing)
{
	local actor standingThing;
	local float totalMass;
	local int          i;
	
	//G-Flex: only care about the weight of decorations, not weapons and pickups and stuff
	totalMass = 0;
	if (baseThing.IsA('DeusExDecoration'))
		totalMass = baseThing.Mass;
		
	//G-Flex: don't bother if we're not a base for anything
	if (StandingCount > 0)
		foreach baseThing.BasedActors(class'actor', standingThing)
			totalMass += GetStackMass(standingThing);
			
	if (Seat(Self) != None)
	{
		for (i=0; i<ArrayCount(Seat(Self).sittingActor); i++)
		{
			if (Seat(Self).sittingActor[i] != None)
			{
				if (((ScriptedPawn(Seat(Self).sittingActor[i]) != None) &&
					 ScriptedPawn(Seat(Self).sittingActor[i]).bSitting))
				{
					totalMass += ScriptedPawn(Seat(Self).sittingActor[i]).Mass;
				}
			}
		}
	}
	
	return totalMass;
}

function PreTravel()
{
	//G-Flex: back up the classes of the contents, including package
	if (contents != None)
		contentsBackup = string(contents);
	if (content2 != None)
		content2Backup = string(content2);
	if (content3 != None)
		content3Backup = string(content3);
}

function ScriptedPawn VMDGetObservingFrobber(optional float OverrideRadius)
{
	local ScriptedPawn SP;
	
	if (OverrideRadius <= 0.0) OverrideRadius = 400.0;
	forEach RadiusActors(Class'ScriptedPawn', SP, OverrideRadius)
	{
		if ((SP != None) && (SP.IsInState('Seeking')) && (FastTrace(SP.Location, Location)))
		{
			return SP;
		}
	}
}

function ScriptedPawn VMDGetSeekingFrobber()
{
	local ScriptedPawn SP;
	
	forEach RadiusActors(Class'ScriptedPawn', SP, 400)
	{
		if ((SP != None) && (IsPawnInRange(SP)))
		{
			return SP;
		}
	}
	
	return None;
}

function bool VMDTargetIsFacing(int Offset, int Tolerance, Actor Other)
{
	local int YawDiff;
	
	if (Other == None) return false;
	
	YawDiff = (Abs((Other.Rotation.Yaw - Rotation.Yaw) - Offset)%65536);
	if (YawDiff < Tolerance || YawDiff > 65536 - Tolerance) return true;
	return false;
}

function bool IsPawnInRange(ScriptedPawn SP)
{
	local bool bInRange;
	
	bInRange = false;
	if ((SP != None) && (!SP.bDeleteMe))
	{
		if ((VSize((SP.Location-Location)*vect(0.75,0.75,0)) < (CollisionRadius+SP.CollisionRadius+24))
			&& (Abs(SP.Location.Z-Location.Z) < (CollisionHeight+SP.CollisionHeight)))
				bInRange = true;
	}
	return (bInRange);
}


// ----------------------------------------------------------------------
// this is our normal, just sitting there state
// ----------------------------------------------------------------------
auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
		local float avg;

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
		
		if ((DamageType == 'Burned') || (DamageType == 'Flamed'))
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
			HitPoints -= Damage;
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
					PlaySound(sound'WoodBreakLarge', SLOT_Misc,,, 512, VMDGetMiscPitch());
				else
					PlaySound(sound'WoodBreakSmall', SLOT_Misc,,, 512, VMDGetMiscPitch());
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
				Frag(fragType, Momentum * explosionRadius / 4, FMin(avg/20.0, 50), avg/5 + 1);
				Explode(HitLocation);
			}
			else
			{
				Frag(fragType, Momentum / 10, FMin(avg/20.0, 50), avg/5 + 1);
			}
		}
	}
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
		PlaySound(Sound'SmallExplosion1', SLOT_None,,, explosionRadius*16, VMDGetMiscPitch());
	else
		PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16, VMDGetMiscPitch());

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

function Bump(actor Other)
{
	local int augLevel;
	local float maxPush, velscale, AugMult;
	local DeusExPlayer player;
	local Rotator rot;

	player = DeusExPlayer(Other);

	// if we are bumped by a burning pawn, then set us on fire
	if (Other.IsA('Pawn') && Pawn(Other).bOnFire && !Other.IsA('Robot') && !Region.Zone.bWaterZone && bFlammable)
		GotoState('Burning');

	// if we are bumped by a burning decoration, then set us on fire
	if (Other.IsA('DeusExDecoration') && DeusExDecoration(Other).IsInState('Burning') &&
		DeusExDecoration(Other).bFlammable && !Region.Zone.bWaterZone && bFlammable)
		GotoState('Burning');

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
	
	//MADDERS: Hack. Stop rolling pushing decos around.
	if ((bPushable) && (PlayerPawn(Other) != None) && (Other.Mass > 40) && (float(Other.GetPropertyText("RollTimer")) <= 0) && (float(Other.GetPropertyText("DodgeRollTimer")) <= 0))// && (Physics != PHYS_Falling))
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

				if (!bFloating && !bPushSoundPlaying && (Mass > 15))
				{
					pushSoundId = PlaySound(PushSound, SLOT_Misc,,, 128, VMDGetMiscPitch2());
					AIStartEvent('LoudNoise', EAITYPE_Audio, , 128);
					bPushSoundPlaying = True;
				}

				if (!bFloating && (Physics != PHYS_Falling))
					SetPhysics(PHYS_Rolling);

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

function bool VMDRejectPickup()
{
	//MADDERS: Do this if we're in the dark, as to identify us.
	if ((bEverNotFrobbed) && (AIGETLIGHTLEVEL(Location) <= 0.005))
	{
	 	bEverNotFrobbed = false;
	 	return true;
	}
	bEverNotFrobbed = false;
	return false;
}

//MADDERS FUNCTIONS!
function SimulateSuperDestroyed()
{
	local actor dropped, A;
	local class<actor> tempClass;
	
	if (bDidItemDrop) return;
	bDidItemDrop = true;
	
	if((Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self))
	{
		Pawn(Base).DropDecoration();
	}
	if((Contents != None) && (!Level.bStartup))
	{
		tempClass = Contents;
		if ((Content2 != None) && (FRand() < 0.3)) tempClass = Content2;
		if ((Content3 != None) && (FRand() < 0.3)) tempClass = Content3;
		dropped = Spawn(tempClass);
		dropped.RemoteRole = ROLE_DumbProxy;
		dropped.SetPhysics(PHYS_Falling);
		dropped.bCollideWorld = true;
		
		//MADDERS: Patch in new ammos
		if (DeusExAmmo(Dropped) != None)
		{
			DeusExAmmo(Dropped).bCrateSummoned = True;
			
			//MADDERS: Only swap out ammos based on the parent crate, and not their own seed.
			//This stops non-linear replacement locations from occuring.
			DeusExAmmo(Dropped).VMDAttemptCrateSwap(StoredSeed);
		}
		if (DeusExPickup(Dropped) != None)
		{
			//MADDERS: Only swap out pickups based on the parent crate, and not their own seed.
			//This stops non-linear replacement locations from occuring.
			DeusExPickup(Dropped).VMDAttemptCrateSwap(StoredSeed);
		}
		if (inventory(dropped) != None)
			inventory(dropped).GotoState('Pickup', 'Dropped');
	}
	
	if(Event != '')
		foreach AllActors( class 'Actor', A, Event )
			A.Trigger( Self, None );
	
	if (bPushSoundPlaying)
		PlaySound(EndPushSound, SLOT_Misc,0.0,,,VMDGetMiscPitch2());
	
	Super(Actor).Destroyed();
}

//MADDERS: Make all keypads 0451, except 0451, which is now 1337.
//------------
//MADDERS: I'm keeping this note because it's hilarious. Otherwise, however, this is obviously obsolete.
//This is what we did back when we were a shitpost mod. Never change, VMD. Never change.
function ApplySpecialStats()
{
	if (StoredSeed < 0)
	{
		StoredSeed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
	}
}

function float VMDGetMiscPitch()
{
	local bool bUnderwater;
	local float GMult;
	
	if (Region.Zone.bWaterZone) bUnderwater = True;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return (1.05 - (Frand() * 0.1)) * 0.7;
	}
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return (1.05 - (Frand() * 0.1)) * GMult;
}

//MADDERS: Do NOT factor in randomization. We're already randomized, ideally.
function float VMDGetMiscPitch2()
{
	local bool bUnderwater;
	local float GMult;
	
	if (Region.Zone.bWaterZone) bUnderwater = True;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return 0.7;
	}
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return 1.0 * GMult;
}

defaultproperties
{
     StoredSeed=-1
     bAlwaysFlammable=false
     bEverNotFrobbed=true
}