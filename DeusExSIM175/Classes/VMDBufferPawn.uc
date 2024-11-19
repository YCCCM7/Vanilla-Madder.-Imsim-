//=============================================================================
// VMDBufferPawn.
//=============================================================================
class VMDBufferPawn extends ScriptedPawn
	abstract;

//++++++++++++++++++++++++
//MADDERS ADDITIONS!
var(MADDERS) int AttackStateLaps;

var bool bSetupBuffedHealth, bAppliedSpecial, bAppliedSpecial2, bBuffedVision; //Already better health scaling than &%)*. God save us all
var float HealthScaleTimer, MedkitUseTimer;
var(MADDERS) float OverrideHeight; //For locking collision height on reskinned chars.
var bool bExplosive, bAerosolImmune, bEverNotFrobbed; //Watch me check for this super EZ.
var float LastHitSeconds; //Set and reset as needed.
var int SeedSet; //Binary sum.
var float TimeSinceEngaged, TimeSincePickpocket; //If < 0.15

//Silent kills yo.
var bool bDoScream, bScreamStart, bDamageGateInTact, bDamageGateBullshitFrame, bStunnedThisFrame; //Fast kills are now silent.
var float ScreamTimer;
var float ArmorStrength; //How much damage reduction for armor hits?

//Hacks? Sure, hacks section here.
var float LastTickDelta;

var bool bDoesntSniff;
var string SmellTypes[8];
var string LastSmellType;
var localized string FakeBarkSniffing;
var localized string MessagePickpocketingSuccess, MessagePickpocketingFailure, MessagePickpocketingSpotted;

//Used for drug FX.
var float StoredScaleGlow;
var byte StoredFatness;

//MADDERS: Don't do much for us. We don't matter.
var bool bInsignificant, bCorpseUnfrobbable;
var bool bDrawShieldEffect;

//MADDERS: Body armor and helmets.
var(MADDERS) bool bHasHelmet, bHasHeadArmor, bHasBodyArmor;
var(MADDERS) byte ArmorNoiseIndex[2];
var(MADDERS) bool bMilitantCower;
var(MADDERS) int CaptiveEscapeSteps;

var int StartingHealthValues[7]; //Head, Body, Left Arm, Right Arm, Left Leg, Right Leg... And lastly, Health itself.
var() texture OverhaulTex[8]; //MADDERS: Used for unique reskins per-char.

//MADDERS: Grenade looting related.
var bool bEverDrewGrenade;
var float GrenadeSkillAugmentCheckTime;

var byte bItemUnnatural[8]; //Are our items unnatural? Used by mayhem system.

//MADDERS: Stuck projectiles looting.
var class<Inventory> StuckProjectiles[4];
var byte StuckCount[4];

//MADDERS: Stun update.
var float StunLengthModifier, PoisonReactThreshold;

//MADDERS, 6/3/22: How good are we with pickups we wear?
//Also, how good are we with medkits?
var(MADDERSSKILLS) int EnviroSkillLevel, MedicineSkillLevel;

//MADDERS: Closed system hits, and armor hits.
var bool bClosedSystemHit, bLastArmorHit;
var Pawn LastInstigator;

var() float DrawShieldCooldown, SmellSniffCooldown;
var Pawn LastDamager; //Use this for not doing spam headshot calls. Yeet.

var bool bMayhemSuspect, bAntiMayhemSuspect; //Flag our corpse with this when it's placed. Also give us good boy points if we're alive after we're done.

var VMDBufferPlayer LastVMP;

//WCCC, 3/17/19: "Let me guess... Experimental?" "Very."
//Re-pasted 11/30/20 for VMD. This should be fun.
//-------------------
//When set to 0.0 (default), these don't run.
//When set to any other level, multiply effective height by the value in question.
//These apply to both sending footstep noise, and receiving noise in general.
//For optimization, it's recommended to keep these defaulted to 0.0.
//--------------------
//Both receive and send sound can be altered by setting ReceiveNoiseHeightTolerance and
//SendNoiseHeightTolerance. At 0 or less, the values do nothing. At 1.0, output is normal.
//Any value less than 1.0 will act as a divisor for how much height is accounted for.
//
//Example: If 1000 distance is present and 200 units of it is height, with a divisor of 0.5, let's
//do the math. 200 / 0.5 = 400. 1000 - 200 + 400 = 1200. Resulting in 83% output at said conditions.
//
//My honest to god advice: Play with the setting, and see what works. Use this math formula
//to sketch some examples in a ballpark fashion. 

var(VMDExperimental) float ReceiveNoiseHeightTolerance;
var(VMDExperimental) float SendNoiseHeightTolerance;

//Less experimental, but this is our footstep sending range.
//In vanilla, this defaults to 768 and 2048, respectively.
var() float FootstepProjectRadius;
var() float FootstepProjectMaxRadius;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//DXT additions.
var      Pawn     Burner;         // person who initiated Burned damage
var float LaserCheckTimer;
var() bool bNoGunQuestioning; 	// do I not care about a gun being pointed at me?
var() float dripRate;
var() float waterDripCounter;

var() bool bLookAtPlayer;			// Do we look at the player as they get near (10ft)?
var() bool bLookingReset;			// Have we been told to look forward?
var() float playerLastSeenTimer;	// When was the last time we saw the player?
var() float lookCheckTime;			// Internal, for performance
var() float lookingAtPlayerTime;	// How long have we been looking at the player?

var bool bClientHostileTowardsPlayers; // From HX, are pawns hostile to the player?
var bool bSuspiciousToPlayer; //Uuuuuh... Not sure WTF this dodes, but it's DXT stuff, so whatever.

var() bool bExtraSuspicious;		// Look around while patrolling?
var() float patrolLookTimer;

var() bool bRecognizeMovedObjects; // Notice objects that have been moved into sight.

var bool bJustTurned; //MADDERS, 11/29/21: Technically G-Flex, but whatever.

var DeusExPlayer localPlayer;

function bool VMDPawnIsChild()
{
	switch(Die)
	{
		case Sound'ChildDeath':
			return true;
		break;
	}
	
	return false;
}

function string VMDGetDisplayName(string InName)
{
	return InName;
}

function VMDTriggerDroneAggro(ScriptedPawn TAggro)
{
	local VMDBufferPlayer VMP;
	local VMDMegh TMegh, Meghs;
	
	ForEach AllActors(class'VMDMegh', Meghs)
	{
		if (Meghs.EMPHitPoints > 0)
		{
			TMegh = Meghs;
			break;
		}
	}
	
	if (TMegh == None || TMegh.GuardedOther != Self) return;
	
	ForEach AllActors(class'VMDBufferPlayer', VMP) break;
	
	if (VMP != None)
	{
		VMP.VMDTriggerDroneAggro(TAggro);	
	}
}

function ReceiveHealing(int HealingReceived)
{
	local int HealLeft, THeal;
	
	if (Robot(Self) != None) return;
	
	HealLeft = HealingReceived;
	if ((HealthArmLeft <= 0) && (HealLeft > 0))
	{
		THeal = Clamp(StartingHealthValues[2] - HealthArmLeft, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmLeft += THeal;
	}
	if ((HealthArmRight <= 0) && (HealLeft > 0))
	{
		THeal = Clamp(StartingHealthValues[3] - HealthArmRight, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmRight += THeal;
	}
	
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[0] - HealthHead, 0, HealLeft);
		HealLeft -= THeal;
		HealthHead += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[1] - HealthTorso, 0, HealLeft);
		HealLeft -= THeal;
		HealthTorso += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[2] - HealthArmLeft, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmLeft += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[3] - HealthArmRight, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmRight += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[4] - HealthLegLeft, 0, HealLeft);
		HealLeft -= THeal;
		HealthLegLeft += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[5] - HealthLegRight, 0, HealLeft);
		HealLeft -= THeal;
		HealthLegRight += THeal;
	}
	
	GenerateTotalHealth();
}

function ReceiveMedicalHealing(int HealingReceived)
{
	local ParticleGenerator Puff;
	
	if (Robot(Self) != None) return;
	
	ReceiveHealing(HealingReceived);
	
	if (PoisonCounter > 0)
	{
		StopPoison();
	}
	
	puff = spawn(class'ParticleGenerator',,,Location+Vector(Rotation),Rotator((Location+Vector(Rotation)) - Location));
	if (puff != None)
	{
		Puff.SetBase(Self);
		puff.particleTexture = FireTexture'Effects.Smoke.SmokePuff1';	
		puff.particleDrawScale = 0.25;
		puff.RiseRate = 2.500000;
		puff.ejectSpeed = 2.500000;
		puff.LifeSpan = 1.500000;
		puff.particleLifeSpan = 3.000000;
		puff.checkTime=0.150000;
		puff.bRandomEject = True;
		puff.RemoteRole = ROLE_None;
	}
}

// ----------------------------------------------------------------------
// state Conversation
//
// Just sit here until the conversation is over
// ----------------------------------------------------------------------

state Conversation
{
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if (VMDMuteFemaleVoice())
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
  	}

	event Tick(float deltaTime)
	{
		Super.Tick(DeltaTime);
		
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
	}

Begin:

	Acceleration = vect(0,0,0);

	DesiredRotation.Pitch = 0;
	if (!bSitting && !bDancing)
		PlayWaiting();

	// we are now idle
}


// ----------------------------------------------------------------------
// state FirstPersonConversation
//
// Just sit here until the conversation is over
// ----------------------------------------------------------------------

state FirstPersonConversation
{
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if (VMDMuteFemaleVoice())
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
  	}

	event Tick(float deltaTime)
	{
		Super.Tick(DeltaTime);
		
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
	}

Begin:

	Acceleration = vect(0,0,0);

	DesiredRotation.Pitch = 0;
	if (!bSitting && !bDancing)
		PlayWaiting();

	// we are now idle
}

function bool VMDMuteFemaleVoice()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (BindName ~= "JCDenton" || BindName ~= "JCDouble"))
	{
		if ((VMP.bAssignedFemale) && (!VMP.bAllowFemaleVoice || VMP.bDisableFemaleVoice))
		{
			return true;
		}
	}
	
	return false;
}

function GetPlayer() 
{
	local PlayerPawn playerPawn;
	
    	if (localPlayer != None)
		return;
    	playerPawn = GetPlayerPawn();
    	if (playerPawn != None)      
		localPlayer = DeusExPlayer(playerPawn);
}

function bool CheckLaserPresence(float deltaSeconds)
{
	local VMDBufferPlayer player;
	local LaserSpot    beamActor;	// Changed from beam to LaserSpot
	local bool         bReactToBeam;
	local float yaw, pitch, dist;
	local Rotator rot;	
	
	//MADDERS, 3/13/21: We don't do this here. Too counterintuitive.
	return false;
	
	if ((bReactPresence) && (bLookingForEnemy) && (LaserCheckTimer <= 0) && (LastRendered() < 5.0))
	{
		LaserCheckTimer = 1.0;
		player = GetLastVMP();
		if ((player != None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Player, "See Laser")))
		{
			bReactToBeam = false;
			if (IsValidEnemy(player))
			{
				foreach RadiusActors(Class'LaserSpot', beamActor, 1200)
				{
					// Spot > Emitter > Weapon > Player
					if ((beamActor.Owner != None) && (beamActor.Owner.Owner != None) && (beamActor.Owner.Owner.Owner != None) && 
					(beamActor.Owner.Owner.Owner == player) && (VSize(beamActor.Location - Location+vect(0,0,1)*BaseEyeHeight) < ((Human(player).combatDifficulty+6)*25)))
					{
						// figure out if we can see the dot
						rot = Rotator(beamActor.Location - Location+vect(0,0,1)*BaseEyeHeight);
						rot.Roll = 0;
						yaw = (Abs(Rotation.Yaw - rot.Yaw)) % 65536;
						pitch = (Abs(Rotation.Pitch - rot.Pitch)) % 65536;

						// center the angles around zero
						if (yaw > 32767)
							yaw -= 65536;
						if (pitch > 32767)
							pitch -= 65536;

						// if we are in the  FOV
						if ((Abs(yaw) < 4096) && (Abs(pitch) < 4096))
							bReactToBeam = true;
					}
					
					if (bReactToBeam)
						break;
				}
			}
			if (bReactToBeam)
				HandleSighting(player);
		}
	}
}

function UpdateFire()
{
	// continually burn and do damage
	if (IsA('Robot'))
	{
		//HealthTorso -= 1;
		if (Burner != None)
			TakeDamage(1, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(1, None, Location, vect(0,0,0), 'Burned');
	}
	else if (IsA('AnnaNavarre'))
	{
		if (Burner != None)
			TakeDamage(2, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(2, None, Location, vect(0,0,0), 'Burned');
	}
	else
	{
		//HealthTorso -= 5;
		if (Burner != None)
			TakeDamage(3, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(3, None, Location, vect(0,0,0), 'Burned');
	}
	//GenerateTotalHealth();
	if (Health <= 0)
	{
		if (Burner != None)
			TakeDamage(10, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(10, None, Location, vect(0,0,0), 'Burned');
		ExtinguishFire();
	}
}

// ----------------------------------------------------------------------
// ExtinguishFire()
// ----------------------------------------------------------------------

function ExtinguishFire()
{
	Super.ExtinguishFire();
	Burner = None;
}
// ----------------------------------------------------------------------
// DripWater()
// ----------------------------------------------------------------------

singular function DripWater(float deltaTime)
{
	local float  dripPeriod;
	local float  adjustedRate;
	local vector waterVector;
	local vector vel;
	local rotator SpawnRotation;
	
	if (!DeusExGameInfo(Level.Game).SpawnEffects())
	{
		dripRate = 0;
		waterDripCounter = 0;
		return;
	}
	
	// Copied from ScriptedPawn::Tick()
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
			if (VSize(Velocity) > 8)
				spawn(Class'WaterDrop',Self,,waterVector+Location,rotator(Velocity-vel));
			else
				spawn(Class'WaterDrop',Self,,waterVector+Location, SpawnRotation);
			waterDripCounter -= dripPeriod;
		}
		dripRate -= deltaTime;
	}
	
	if (dripRate <= 0)
	{
		dripRate   		 = 0;
		waterDripCounter = 0;
	}
}

simulated function Tick(float deltaTime)
{	
	Super.Tick(deltaTime);

	VMDPawnTickHook(deltaTime);
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
			
	if (!HasAnim('HeadLeft'))
		bLookAtPlayer = False;
		
	GetPlayer();
		
	// if (TriadLumPath(Self) != None || TriadRedArrow(Self) != None || HKMilitary(Self) != None)
		// bReactToNanosword = True;
}

state Patrolling
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
		
		patrolLookTimer += deltaTime;
		
		if ((bCanTurnHead) && (bExtraSuspicious))
		{
			if (patrolLookTimer > 13.0)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				patrolLookTimer = 0;
			}
			else if (patrolLookTimer > 7.0)
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			else if (patrolLookTimer > 3.0)
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
		}
	}
}

event PreBeginPlay()
{
	Super.PreBeginPlay();
	//fake shrink to fix faked collision with floor problems - DEUS_EX CNN
	//UNDO
	if ((CollisionHeight > 9) && (InStr(String(Mesh), ".Trans") != -1))
	{
		//if (bIsFemale)
			//SetCollisionSize(CollisionRadius, CollisionHeight + 4.5);
		//else
			SetCollisionSize(CollisionRadius, CollisionHeight + 2.25);
			BaseEyeHeight -= 1.125;
	}
}

function float GetDefaultCollisionHeight()
{
	// return (Default.CollisionHeight-4.5);
	return (Default.CollisionHeight-2.25);
}




//
// lip synching support - DEUS_EX CNN
//
function LipSynchBarks(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.1;
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		if (nextPhoneme == "A")
			animseq = 'MouthA';
		else if (nextPhoneme == "E")
			animseq = 'MouthE';
		else if (nextPhoneme == "F")
			animseq = 'MouthF';
		else if (nextPhoneme == "M")
			animseq = 'MouthM';
		else if (nextPhoneme == "O")
			animseq = 'MouthO';
		else if (nextPhoneme == "T")
			animseq = 'MouthT';
		else if (nextPhoneme == "U")
			animseq = 'MouthU';
		else if (nextPhoneme == "X")
			animseq = 'MouthClosed';

		if (animseq != '' && HasAnim(animseq))
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if (HasAnim('MouthClosed'))
			TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if ((FRand() < 0.4  || IsInState('RubbingEyes')) && (HasAnim('Blink')))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}

	// LoopHeadConvoAnim();
	// LoopBaseConvoAnim();
}

//Typically implemented in subclass
function string KillMessage( name damageType, pawn Other )
{
	local string message;

	message = Level.Game.CreatureKillMessage(damageType, Other); // " was killed by"
	// return (message$namearticle$menuname);
	return (message $ namearticle $ FamiliarName);
}

function Vector GetShellOffset()
{	
	local vector offset, tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	offset = CollisionRadius * X + 0.3 * CollisionRadius * Y;
	// tempvec = 0.8 * CollisionHeight * Z;
	tempvec = 0.5 * CollisionHeight * Z;
	offset.Z += tempvec.Z;
	
	return offset;
}

function Vector GetShellVelocity()
{	
	local vector tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	
	tempvec = (FRand()*20+90) * Y + (10-FRand()*20) * X;
	
	return tempvec;
}

// ----------------------------------------------------------------------
// FootStepSound()
//
// Tries to figure out which footstep sound to use.
//
// Potential Additional Footstep Sounds:
//	* MoverSFX.StallDoorClose
//  * DeusExSounds.KarkianFootstep
//  * DeusExSounds.GreaselFootstep
//  * DeusExSounds.GrayFootstep
//
// Note:
//  * Maybe add FootSteps for Fragment.
// ----------------------------------------------------------------------

simulated function Sound FootStepSound( out float Volume, out float AIVolumeMul )
{
	local vector EndTrace, HitLocation, HitNormal;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local Texture      Tex;
	local Mover        Mover;
	local DeusExDecoration Decoration;
	local DeusExCarcass    Carcass;
	local float        Rnd;

	Volume	    = 1.0;
	AIVolumeMul = 1.0;

	// Handle Water
	if (Physics == PHYS_Swimming)
		return SwimmingStepSound(Volume, AIVolumeMul);
	if (FootRegion.Zone.bWaterZone)
		return WaterStepSound(Volume, AIVolumeMul);

	// Prefer WalkSound over any texture speficic sound.
	if (WalkSound != None)
		return WalkSound;

	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);
	
	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		// Vanilla behaviour for Level Geometry.
		if (target == Level)
			return TextureGroupStepSound(Volume, AIVolumeMul, Tex, TexGroup);

		// Choose Decoration FootStepSound based on FragType.
		Decoration = DeusExDecoration(target);
		if (Decoration != None)
			return DecorationStepSound(Volume, AIVolumeMul, Decoration);

		// Carcass.
		Carcass = DeusExCarcass(target);
		if (Carcass != None) 
			return CarcassStepSound(Volume, AIVolumeMul, Carcass);

		//Not yet supported.
		//Mover = Mover(target);
		//if (Mover != None)
			//;
	}
	return FallbackStepSound(Volume, AIVolumeMul);
}


// ----------------------------------------------------------------------
// TextureGroupStepSound()
//
// Used for Bsp based footsteps.
// ----------------------------------------------------------------------

simulated function Sound TextureGroupStepSound(out float Volume, out float AIVolumeMul, Texture Texture, Name TextureGroup)
{
	local float Rnd;
	local Human player;
	
	player = Human(GetPlayerPawn());

	// Set Volume and VolumeMul first.
	switch (TextureGroup)
	{
		case 'Metal':
		case 'Ladder':
			AIVolumeMul = 1.0;
			break;
		case 'Foliage':
		case 'Earth':
			AIVolumeMul = 0.6;
			break;
		default:
			AIVolumeMul = 0.7;
			break;
	}

	// Use Texture.FootstepSound if available.
	if ((Texture != None) && (Texture.FootstepSound != None))
		return Texture.FootstepSound;

	Rnd = FRand();
	switch (TextureGroup)
	{
		case 'Textile':
		case 'Paper':
			Volume *= 0.8;
			AIVolumeMul = 0.4;
			if (Rnd < 0.25) return Sound'CarpetStep1';
			if (Rnd < 0.5) return Sound'CarpetStep2';
			if (Rnd < 0.75) return Sound'CarpetStep3';
			else return Sound'CarpetStep4';
			break;
		case 'Plastic':
			AIVolumeMul = 0.4;
			if (Rnd < 0.25) return Sound'CarpetStep1';
			if (Rnd < 0.5) return Sound'CarpetStep2';
			if (Rnd < 0.75) return Sound'CarpetStep3';
			else return Sound'CarpetStep4';
			break;

		case 'Foliage':
			AIVolumeMul = 0.55;
			if (Rnd < 0.25) return Sound'GrassStep1';
			if (Rnd < 0.5) return Sound'GrassStep2';
			if (Rnd < 0.75) return Sound'GrassStep3';
			else return Sound'GrassStep4';
			break;
		case 'Earth':
			AIVolumeMul = 0.55;
			if (Rnd < 0.25) return Sound'GrassStep1';
			if (Rnd < 0.5) return Sound'GrassStep2';
			if (Rnd < 0.75) return Sound'GrassStep3';
			else return Sound'GrassStep4';
			break;

		case 'Metal':
		case 'Ladder':
			AIVolumeMul = 1.0;
			if (Rnd < 0.25) return Sound'MetalStep1';
			if (Rnd < 0.5) return Sound'MetalStep2';
			if (Rnd < 0.75) return Sound'MetalStep3';
			else return Sound'MetalStep4';
			break;

		case 'Ceramic':
		case 'Glass':
		case 'Tiles':
			AIVolumeMul = 0.7;
			if (Rnd < 0.25) return Sound'TileStep1';
			if (Rnd < 0.5) return Sound'TileStep2';
			if (Rnd < 0.75) return Sound'TileStep3';
			else return Sound'TileStep4';
			break;

		case 'Wood':			
			AIVolumeMul = 0.7;
			if (Rnd < 0.25) return Sound'WoodStep1';
			if (Rnd < 0.5) return Sound'WoodStep2';
			if (Rnd < 0.75) return Sound'WoodStep3';
			else return Sound'WoodStep4';
			break;

		case 'Brick':
		case 'Concrete':
		case 'Stone':
		case 'Stucco':
		default:
			AIVolumeMul = 0.7;
			if (Rnd < 0.25) return Sound'StoneStep1';
			if (Rnd < 0.5) return Sound'StoneStep2';
			if (Rnd < 0.75) return Sound'StoneStep3';
			else return Sound'StoneStep4';
			break;
	}
}

// ----------------------------------------------------------------------
// CarcassStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------

simulated function Sound CarcassStepSound(out float Volume, out float AIVolumeMul, Carcass Carcass)
{
	AIVolumeMul = 0.5;
	Volume = 0.5;
	return Sound'KarkianFootstep';
}

// ----------------------------------------------------------------------
// DecorationStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------

simulated function Sound DecorationStepSound(out float Volume, out float VolumeMul, DeusExDecoration Decoration)
{
	if (Decoration.FragType == None)
	{
		Log( Decoration@"has empty FragType. Report this as a Bug." );
		return Sound'TouchTone11';	
	}
	switch (Decoration.FragType.Name) 
	{
		case 'GlassFragment':		return TextureGroupStepSound(Volume, VolumeMul, None, 'Glass');
		case 'MetalFragment':		return TextureGroupStepSound(Volume, VolumeMul, None, 'Metal');
		case 'PaperFragment':
			VolumeMul = 0.3;
			Volume = 1.2;
			return Sound'StallDoorClose';
		case 'PlasticFragment':	return TextureGroupStepSound(Volume, VolumeMul, None, 'Plastic');
		case 'WoodFragment':		return TextureGroupStepSound(Volume, VolumeMul, None, 'Wood');
		case 'Rockchip':				return TextureGroupStepSound(Volume, VolumeMul, None, 'Stone');
		case 'FleshFragment':
			VolumeMul = 0.5;
			Volume = 0.5;
			return Sound'KarkianFootstep';
		case 'GrassFragment': return TextureGroupStepSound(Volume, VolumeMul, None, 'Foliage');
		default:
			Log("Unhandled FragType="$Decoration.FragType.Name$" in GetFootStepGroup() Report this as a Bug.");
			return Sound'TouchTone5';
	}
}

// ----------------------------------------------------------------------
// FallbackStepSound()
// ----------------------------------------------------------------------

simulated function Sound FallbackStepSound(out float Volume, out float AIVolumeMul)
{
	return TextureGroupStepSound(Volume, AIVolumeMul, None, 'Brick');
}

// ----------------------------------------------------------------------
// SwimmingStepSound()
// ----------------------------------------------------------------------

simulated function Sound SwimmingStepSound(out float Volume, out float AIVolumeMul)
{
	AIVolumeMul = 0.5;
	if (FRand() < 0.5)
		return Sound'Swimming';
	else
		return Sound'Treading';
}

// ----------------------------------------------------------------------
// WaterStepSound()
// ----------------------------------------------------------------------

simulated function Sound WaterStepSound(out float Volume, out float AIVolumeMul)
{
	local float Rnd;
	AIVolumeMul = 1.0;
	Rnd = FRand();
	if (Rnd < 0.33)
		return Sound'WaterStep1';
	if (Rnd < 0.66) 
		return Sound'WaterStep2';
	else
		return Sound'WaterStep3';
}


// ----------------------------------------------------------------------
// ForcePlaySurpriseSound()
// ----------------------------------------------------------------------

function ForcePlaySurpriseSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(GetPlayerPawn());
	if ((dxPlayer != None) && (!HeadRegion.Zone.bWaterZone)) // Only talk if we can breathe underwater or we're not in water
		dxPlayer.StartAIBarkConversation(self, BM_Surprise);
}

// ----------------------------------------------------------------------
// HandleActorSighting()
// ----------------------------------------------------------------------

function HandleActorSighting(Actor actorSighted)
{
	SetSeekLocation(actorSighted, actorSighted.Location, SEEKTYPE_Sound);
	GotoState('Seeking');
}

function int EnemiesOrNeutralLeft()
{
	local ScriptedPawn SP;
	local int Ret;
	
	forEach AllActors(class'ScriptedPawn', SP)
	{
		if ((SP !=  None) && (SP.GetPawnAllianceType(Self) != ALLIANCE_Friendly))
		{
			Ret++;
		}
	}
	
	return Ret;
}

//WCCC, 3/17/19: Scale things based on the factor in question, and height differences between other and us.
function float ScaleSoundByHeight(float Factor, Pawn Other)
{
	local float RetVal;
	local Vector OLoc, SLoc;
	local float GetDist, ODist, HeightDist;
	
	if (Other == None || Factor <= 0) return 1.0;
	
	OLoc = Other.Location - (vect(0,0,1) * (Other.CollisionHeight/2));
	SLoc = Location - (vect(0,0,1) * (CollisionHeight/2));
	
	GetDist = VSize(OLoc - SLoc);
	HeightDist = Abs(OLoc.Z - SLoc.Z);
	ODist = GetDist - HeightDist;
	HeightDist /= Factor;
	ODist += HeightDist;
	
	//NOTES: The more height we're comprised of, the more we treat like there's distance between us and sender.
	//More factor also equates to easier desensitization.
	RetVal = GetDist / ODist;
	
	return RetVal;
}

// ----------------------------------------------------------------------
// LoudNoiseScore()
// ----------------------------------------------------------------------

function float LoudNoiseScore(actor receiver, actor sender, float score)
{
	local Pawn pawnSender;
	
	// Cull events received from friends
	pawnSender = Pawn(sender);
	if (pawnSender == None)
		pawnSender = sender.Instigator;
	if (pawnSender == None)
		score = 0;
	else if (!IsValidEnemy(pawnSender))
		score = 0;
	
	//WCCC, 3/17/19: Experimental noise reception, relative to height. Spicy.
	else if ((PawnSender != None) && (ReceiveNoiseHeightTolerance > 0))
	{
		Score *= ScaleSoundByHeight(ReceiveNoiseHeightTolerance, PawnSender);
	}
	
	return score;
}
// ----------------------------------------------------------------------
// DrawPickupShield()
// ----------------------------------------------------------------------

function DrawPickupShield()
{
	local EllipseEffectPickup shield;
	
	if (DrawShieldCooldown > 0) return;
	
	shield = Spawn(class'EllipseEffectPickup', Self,, Location, Rotation);
	if (shield != None)
		shield.SetBase(Self);
	
	//MADDERS: Just enough to stop spamming this on shotguns.
	DrawShieldCooldown = 0.05;
}

function bool VMDHitArmor(int Damage, vector HitLocation, name DamageType)
{
	local vector Offset;
	local float        headOffsetZ, headOffsetY, armOffset;
	local float	HelmetFront, HelmetBack, HelmetX;
	local bool bHitHelmet, bHitArmor;
	
	if (BypassesHelmet(damageType))
	{
		return false;
	}
	if (Robot(Self) != None) return true;
	
	if ((!bHasHelmet) && (!bHasBodyArmor) && (!bHasHeadArmor)) return false;
	
	// calculate our hit extents
	headOffsetZ = CollisionHeight * 0.7;
	headOffsetY = CollisionRadius * 0.3;
	armOffset   = CollisionRadius * 0.35;
	
	HelmetFront = CollisionHeight * 0.95;
	HelmetBack = CollisionHeight * 0.8625;
	HelmetX = CollisionRadius * 0.2;
	
	Offset = (HitLocation-Location) << Rotation;
	
	if ((bHasHelmet) && (Damage < 25))
	{
		if (Offset.X > HelmetX)
		{
			if (Offset.Z > HelmetFront) return True;
		}
		else
		{
			if (Offset.Z > HelmetBack) return True;
		}
	}
	if ((bHasHeadArmor) && (Damage < 25))
	{
		if (Offset.Z >= HeadOffsetZ)
		{
			return True;
		}
	}
	if ((bHasBodyArmor) && (Damage < 50))
	{			
		if ((Offset.Z >= 0.0) && (Offset.Z < HeadOffsetZ) && (Offset.Y > -ArmOffset) && (Offset.Y < ArmOffset))
		{
		 	return True;
		}
	}
	return False;
}

function AddStuckAmmoUnit(class<Inventory> AddType, float StickOdds, int AddAmount)
{
	local int i;
	
	//MADDERS: Add slight entropy to ammo returns.
	if (FRand() > StickOdds) return;
	
	for (i=0; i<ArrayCount(StuckCount); i++)
	{
		if (StuckProjectiles[i] == None || StuckProjectiles[i] == AddType)
		{
			StuckProjectiles[i] = AddType;
			StuckCount[i] += AddAmount;
			break;
		}
	}
}

function VMDPlayRicochetSound()
{
	local int R;
	
	R = Rand(4);
	
	//MADDERS: Old gag code. Now obsolete.
	//PlaySound(Sound'ArmorRicochet', SLOT_Misc, 48,, 512);
	
	switch(R)
	{
		case 0:
			PlaySound(Sound'Ricochet1', SLOT_Misc, 48,, 512);
		break;
		case 1:
			PlaySound(Sound'Ricochet2', SLOT_Misc, 48,, 512);
		break;
		case 2:
			PlaySound(Sound'Ricochet3', SLOT_Misc, 48,, 512);
		break;
		case 3:
			PlaySound(Sound'Ricochet4', SLOT_Misc, 48,, 512);
		break;
	}
}
//-----------------------------------------------------
//MADDERS: Configuring damage.
//Footnote: Always treat charged pickups like they're on.
//-----------------------------------------------------
function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
 	local DeusExPickup DXP;
	local DeusExWeapon DXW;
 	local Inventory Inv;
 	
 	if (bCheckOnly) return;
	
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		DXW = DeusExWeapon(Inv);
		
  		if (DXP != None)
		{
   			DXP.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
		}
		else if (DXW != None)
		{
			DXW.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
		}
 	}
}

function float VMDConfigurePickupDamageMult(name DT)
{
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		//MADDERS: Mind the junk pile. Tuning this a bit.
  		if (DXP != None)
   			Ret *= DXP.VMDConfigurePickupDamageMult(DT);
 	}
 	
 	return Ret;
}

function bool VMDConfigurePickupDamageFilter(name DT)
{
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
  		if (DXP != None)
		{
   			if (!DXP.VMDFilterDamageTaken(DT))
			{
				return false;
			}
		}
 	}
	
	return true;
}

function int VMDConfigureCloakThresholdMod()
{
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	local int Ret;
 	
 	Ret = 0;
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		//MADDERS: Mind the junk pile. Tuning this a bit.
  		if (DXP != None)
   			Ret += DXP.VMDConfigureCloakThresholdMod();
 	}
 	
 	return Ret;
}

//MADDERS: Add goodies for non-vanilla pawns. Neat.
function RunModInvChecks()
{
 	local class<Inventory> IC;
 	local int Seed, GIS, i;
 	local string S[5], MC;
 	local bool bPass;
 	
 	S[0] = "COP";
 	S[1] = "SOLDIER";
 	S[2] = "TROOP";
 	S[3] = "THUG";
 	S[4] = "TERRORIST";
 	
 	//MC = CAPS(String(Self.Class));
 	//GIS = InStr(MC, "DEUSEX.");
	
 	//Don't run this for vanilla mobs.
	if (VMDOtherIsName("DeusEx.")) return;
 	
 	for(i=0; i<5; i++)
 	{
  		GIS = InStr(MC, S[i]);
  		if (GIS > -1)
  		{
   			bPass = true;
   			break;
  		}
 	}
 	
 	if (!bPass) return;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5, false);
 	if (Seed == 4)
 	{
  		IC = ObtainRandomGoodie();
  		
		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

function class<Inventory> ObtainRandomGoodie()
{
 	local int R;
 	
 	R = Rand(4);
 	
 	//>TMW already writing better code than &%)*
 	switch(R)
 	{
  		case 0:
   			if ((Frand() < 0.07) && (!IsA('HumanMilitary'))) return class'VialCrack';
   			return class'CandyBar';
 		break;
  		case 1:
			//MADDERS, 5/24/20: Don't do this anymore. The easter egg has been workshopped into a final form.
   			//if (Frand() < 0.05) return class'WeaponModEvolution';
   			//return class'Lockpick';
			return class 'Sodacan';
  		break;
  		case 2:
   			return class'Credits';
  		break;
  		case 3:
   			if (Frand() < 0.35) return class'WeaponHideagun';
   			return class'Cigarettes'; //The best. Ever.
  		break;
 	}
 	
 	return class'CandyBar';
}

function bool AddToInitialInventory(class<Inventory> NewClass, int NewCount, optional bool bAllowDuplicates)
{
	local int i;
	
	for(i=0; i<ArrayCount(InitialInventory); i++)
	{
		if ((InitialInventory[i].Inventory == NewClass) && (!bAllowDuplicates))
		{	
			return false;
		}
		
		if (InitialInventory[i].Inventory == None)
		{
			InitialInventory[i].Inventory = NewClass;
			InitialInventory[i].Count = NewCount;
			bItemUnnatural[i] = 1;
			return true;
		}
	}
	
	return false;
}

function bool IsInCombatesqueState()
{
	if (IsInState('Seeking')) return true;
	if (IsInState('Attacking')) return true;
	if (IsInState('Fleeing')) return true;
	if (IsInState('Alerting')) return true;
	if (IsInState('Burning')) return true;
	if (IsInState('Stunned')) return true;
	if (IsInState('RubbingEyes')) return true;
	if (IsInState('HandlingEnemy')) return true;
	if (IsInState('AvoidingProjectiles')) return true;
	if (IsInState('TakingHit')) return true;
	
	if (IsInState('FallingState')) return true;
	if (IsInState('Swimming')) return true;
	if (IsInState('Dying')) return true;
	if (IsInState('OpeningDoor')) return true;
	if (IsInState('Leaving')) return true;
	//if (IsInState('Conversation')) return true;
	
	return false;
}

function SpoofBarkLine(DeusExPlayer DXP, string SpoofLine, optional float DisplayTime)
{
	local DeusExRootWindow Root;
	
	if (DXP == None) return;
	if (DisplayTime < 0 || DisplayTime ~= 0.0) DisplayTime = 3.5;
	
	DXP.InitRootWindow();
	Root = DeusExRootWindow(DXP.RootWindow);
	if ((Root != None) && (Root.HUD != None) && (Root.HUD.BarkDisplay != None))
	{
		Root.Hud.BarkDisplay.AddBark(SpoofLine, DisplayTime, Self);
	}
}

function HandleSmell(Name event, EAIEventState state, VMDBufferPlayer Player)
{
	//React
	local Actor bestActor;
	local Pawn  instigator;
	local DeusExRootWindow Root;
	
	if ((state == EAISTATE_Begin || state == EAISTATE_Pulse) && (!IsInCombatesqueState()))
	{
		if ((Player != None) && (!Player.IsInState('Dying')) && (EnemiesOrNeutralLeft() > 0))
		{
			//MADDERS: Being seen covered in blood 
			if (LastSmellType ~= "PlayerStrongBloodSmell")
			{
				Player.AISendEvent('MegaFutz', EAITYPE_Audio, 5.0, 384);
			}
			
			if ((SmellSniffCooldown <= 0) && (!Default.bImportant) && (!bInvincible) && (!bInsignificant) && (!bDoesntSniff))
			{
				//MADDERS: Always give sniff for hostile reactions, but give a short cooldown.
				//Rarely give a sniff for neutral reactions, and add a longer cooldown.
				//Never do this for allies, but still parse the blood doodad.
				switch (GetPawnAllianceType(Player))
				{
					case ALLIANCE_Hostile:
						SmellSniffCooldown = 5.0;
					break;
					case ALLIANCE_Neutral:
						SmellSniffCooldown = 30.0;
						if (FRand() < 0.65) return;
					break;
					case ALLIANCE_Friendly:
						return;
					break;
				}
				if (bIsFemale)
				{
					PlaySound(Sound'SmellSniffFemale', SLOT_None);
				}
				else
				{
					PlaySound(Sound'SmellSniff', SLOT_None);
				}
				
				//MADDERS: Visual feedback, too, please.
				SpoofBarkLine(Player, FakeBarkSniffing);
			}
			
			if (IsValidEnemy(Player))
			{
				//MADDERS, 11/30/20: Close smell = attack. Cheaty, but so is the player swoocing around with smell at point blank.
				if (VSize(Player.Location - Location) < CollisionRadius * 3)
				{
					Enemy = Player;
					GoToState('Attacking');
				}
				else
				{
					//Carcass? Guess?
					SetSeekLocation(Player, Player.Location, SEEKTYPE_None); //Guess
					HandleEnemy();
				}
			}
		}
	}
}

function int CountSelf()
{
 	local int Ret;
 	local Actor A;
 	
 	forEach AllActors(Self.Class, A)
 	{
 	 	if (A != None) Ret++;
 	}
 
 	return Ret;
}

function int NumOnlookers(Actor Frobber)
{
 	local ScriptedPawn SP;
 	local int Ret, RotDif;
 	local float GDist, GDM, RDM, VD, DarkMult;
	local DeusExPlayer DXP;
	local VMDBufferPlayer VMP;
	local AugmentationManager AM;
	local Pawn TTar;
 	
	DXP = DeusExPlayer(Frobber);
	VMP = VMDBufferPlayer(Frobber);
	if (DXP == None || DXP.bHidden) return 0;
	
	if (VMP != None)
	{
		if (VMP.VMDPlayerIsCloaked()) return 0;
	}
	else
	{
		AM = DXP.AugmentationSystem;
		if (AM == None || AM.GetAugLevelValue(class'AugCloak') != -1.0) return 0;
		if (DXP.Style == STY_Translucent) return 0;
	}
	
 	forEach RadiusActors(Class'ScriptedPawn', SP, 960)
 	{
		// && (FastTrace(SP.Location, Location))
  		if ((SP != None) && (SP != Self) && (SP.bInWorld) && (Animal(SP) == None) && (Robot(SP) == None) && (SP.GetPawnAllianceType(Self) < 2))
  		{
			if ((VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant) && (!SP.IsInState('Stunned')) && (!SP.IsInState('RubbingEyes')))
			{
				TTar = DXP;
				//TTar = Self;
				if (SP.AICanSee(TTar, SP.ComputeActorVisibility(TTar), false, true, true, true) > 0)
				{
					Ret++;
				}
				
   				/*VD = SP.SightRadius / 3.0;
   				GDist = VSize(SP.Location - Location);
   				GDM = (VD - GDist) / VD;
   				RotDif = SP.Rotation.Yaw - Rotator(Location - SP.Location).Yaw;
   				RDM = Abs(RotDif);
   				
   				//MADDERS: Calculate for darkness as well. Bit of a hack, but 0.15 is cap visibility, and 0.005 is zero visibility.
   				DarkMult = FMin(1.0, ((AIGETLIGHTLEVEL(Frobber.Location) - 0.005) / 0.01));
   				
   				if (RDM < 16384 * GDM * DarkMult)
   				{
    					Ret++;
				}*/
			}
  		}
 	}
 	
 	return Ret;
}

//-----------------------------
//Empty 1 item from pockets.
function bool ShouldDoSinglePickPocket(DeusExPlayer Frobbie)
{
	//MADDERS, 3/12/23: Premature hack for when we add player hands. Also, now block decos, too, dummy.
	if (Frobbie == None) return false;
	if ((Frobbie.InHand != None) && (!Frobbie.InHand.IsA('PlayerHands'))) return false;
	if (Frobbie.CarriedDecoration != None) return false;
	
 	//Don't steal from plot important folks.
 	if ((bImportant) && (Default.bImportant)) return False;
	if (bInvincible) return false;
	
	//MADDERS, 1/3/21: Don't allow pickpocketing of animals or robots.
	if (IsA('Animal') || IsA('Robot')) return False;
	
	//MADDERS: Skill augment required now.
	if ((VMDBufferPlayer(Frobbie) != None) && (!VMDBufferPlayer(Frobbie).HasSkillAugment("LockpickPickpocket")))
	{
		return False;
	}
	
	//MADDERS, 1/3/21: Don't allow pickpocketing on seats that are too big and clumsy. CouchLeather, I'm looking at you.
	if ((SeatActor != None) && (SeatActor.CollisionRadius > CollisionRadius * 1.625))
	{
		return False;
 	}
	
	if (IsInState('WaitForRespawn')) return True;
 	
 	if (IsInState('Attacking')) return false;
 	if (IsInState('Alerting')) return false;
 	if (IsInState('HandlingEnemy')) return false;
 	if (IsInState('AvoidingProjectiles')) return false;
 	if (IsInState('AvoidingPawn')) return false;
 	
	if (IsInState('Stunned')) return false;
 	if (IsInState('Burning')) return false;
 	if (IsInState('TakingHit')) return false;
 	if (IsInState('Dying')) return false;
 	if (IsInState('WaitForRespawn')) return false;
 	
 	if (IsInState('FallingState')) return false;
 	
	//MADDERS, 1/17/21: Tear gas lets us pickpocket while they're distracted. Nonlethal delight.
	//UPDATE, 2/6/21: We're blocking this off until further rebalancing occurs. This is very silly until further notice.
	//UPDATE, 12/11/21: We're re-enabling this, but with a twist. If we're rubbing eyes, snap out of it once pickpocketed.
 	if ((Enemy == Frobbie) && (!IsInState('RubbingEyes'))) return False;
 	
 	return True;
}

function bool IsSinglePickPocketing(Actor Frobber, out Actor HitActor)
{
 	local DeusExPlayer DXP;
 	local Vector Offset, HitLocation, HitNormal;
 	local Vector Start, End;
 	//local Actor HitActor;
 	
 	//Null control that also shrinks frob code some.
 	if (!ShouldDoSinglePickPocket(DeusExPlayer(Frobber))) return false;
	
	//MADDERS, 1/3/21: Don't allow pickpocketing while swimming or other nonsense... Unless sitting.
	//Also don't pickpocket if we're moving too fast.
 	if (((Physics != PHYS_Walking) && (SeatActor == None)) || VSize(Frobber.Velocity) > 150) return False;
 	
 	DXP = DeusExPlayer(Frobber);
 	
 	if (DXP == None) return False;
 	
 	if (DXP.bDuck == 0) return False; //Only steal when crouched!
 	
 	Start = DXP.Location + vect(0,0,1) * DXP.BaseEyeHeight;
 	End = Start + Vector(DXP.ViewRotation) * DXP.MaxFrobDistance;
 	
 	HitActor = DXP.Trace(HitLocation, HitNormal, End, Start, True);
 	
 	if ((HitActor != Self) && (SeatActor == None || HitActor != SeatActor)) return False;
 	
 	offset = (hitLocation - (Location-PrePivot)) << Rotation;
 	
 	//Anywhere on back half with at least 20% of "inwards" offset.
 	if ((Offset.X < CollisionRadius * 0.5) && (Abs(Offset.Y) < CollisionRadius * 0.8) && (Offset.Z < CollisionHeight * 0.6)) return True;
 	
 	return False;
}

function Frob(Actor Frobber, Inventory FrobWith)
{
 	local bool bPick;
	local Actor HitActor;
 	
 	//MADDERS: Do this if we're in the dark, as to identify us.
 	if ((bEverNotFrobbed) && (!(AIGETLIGHTLEVEL(Location) > 0.005)))
 	{
  		Frobber.AISendEvent('Player', EAITYPE_Audio, 8.0, 192);
  		Frobber.AISendEvent('LoudNoise', EAITYPE_Audio, 8.0, 192);
  		bEverNotFrobbed = false;
  		return;
 	}
 	bEverNotFrobbed = false;
 	
 	if ((IsSinglePickpocketing(Frobber, HitActor)) && (!IsA('Robot')))
 	{
  		DoSinglePickpocketDump(Frobber, HitActor);
  		return;
 	}
 	
 	Super.Frob(Frobber, Frobwith);
}

function bool IsInChunkyWeapon(DeusExAmmo DXA)
{
 	local DeusExWeapon DXW;
 	
 	//MADDERS: Extra null check.
 	if (DXA == None) return false;
 	
 	forEach AllActors(class'DeusExWeapon', DXW)
 	{
  		if ((DXW != None) && (DXW.AmmoType == DXA) && (DXW.VMDConfigureInvSlotsX(None) >= 90 || DXW.PickupViewMesh == LodMesh'DeusExItems.InvisibleWeapon'))
  		{
   			return true;
  		}
 	}
 	
 	return false;
}

function DoSinglePickpocketDump(Actor Frobber, Actor HitActor)
{
	local bool bHadWeapon, bShowWepIcon;
 	local int ListSize, DropID, KeyIndex, AmmoRet, MatchCount;
	local float SkillModTime;
 	local DeusExWeapon DXW, CDXW, ODXW, MatchDXW;
 	local DeusExAmmo DXA, ODXA;
 	local DeusExPickup DXP, MatchDXP;
 	local Inventory Inv, Next, List[16], ListNext[16], Dump;
	local VMDBufferPlayer Play;
 	
 	//MADDERS: Stop only in this part, so we don't interact on accident.
 	if (TimeSincePickpocket > 0.0) return;
 	
	Play = VMDBufferPlayer(Frobber);
	if (Play == None) return;
	
	if (Play.SkillSystem != None)
	{
		SkillModTime = 0.25 * Play.SkillSystem.GetSkillLevel(class'SkillLockpicking');
	}
	
 	Inv = Inventory;
 	TimeSincePickpocket = 1.0 - SkillModTime;
 	KeyIndex = -1;
 	
 	if (Inv != None)
 	{
  		do
  		{
			ODXA = None;
			ODXW = None;
			
   			Next = Inv.Inventory;
   			DXW = DeusExWeapon(Inv);
			if (DXW != None)
			{
				bHadWeapon = true;
				ODXA = DeusExAmmo(DXW.AmmoType);
			}
   			CDXW = DeusExWeapon(Weapon);
 			
 			DXA = DeusExAmmo(Inv);
			if (DXA != None)
			{
				ODXW = GetOwningWeapon(DXA);
			}
   			DXP = DeusExPickup(Inv);
   			if ((DXW != None) && (DXW != CDXW) && (DXW.VMDConfigureInvSlotsX(None) < 90) && (DXW.PickupViewMesh != LodMesh'DeusExItems.InvisibleWeapon'))
   			{
   				if (DXW != Weapon) //(!DXW.bHandToHand) && 
    				{
     					List[ListSize] = Inv;
     					ListNext[ListSize] = Next;
     					ListSize++;
    				}
   			}
   			else if ((DXA != None) && (DXA.AmmoAmount > 0) && (DXA.PickupViewMesh != LodMesh'DeusExItems.TestBox') && (!IsInChunkyWeapon(DXA)))
   			{
				if (ODXW == None || DXA.AmmoAmount > ODXW.ReloadCount - ODXW.ClipCount)
				{
    					//if ((CDXW == None) || (DXA != CDXW.AmmoType))
    					//{
     						List[ListSize] = Inv;
     						ListNext[ListSize] = Next;
     						ListSize++;
					//}
    				}
   			}
   			else if (DXP != None)
   			{
				if (ChargedPickup(DXP) == None || ChargedPickup(DXP).Charge >= DXP.Default.Charge)
				{
    					if (NanoKey(DXP) != None)
    					{
     						KeyIndex = ListSize;
    					}
    					List[ListSize] = Inv;
    					ListNext[ListSize] = Next;
    					ListSize++;
				}
   			}
   			Inv = Next;
  		}
  		until (Inv == None);
 	}
 	
 	if (ListSize > 0)
 	{
  		DropID = Rand(ListSize);
  		//NEW, 11/26/19: Prioritize nanokeys.
  		if (KeyIndex > -1) DropID = KeyIndex;
  		Dump = List[DropID];
		
		DXA = DeusExAmmo(Dump);
		DXW = DeusExWeapon(Dump);
		DXP = DeusExPickup(Dump);
		
		if (DXA != None)
		{
			//MADDERS, 11/29/21: Leave one mag in the weapon.
			ODXW = GetOwningWeapon(DXA);
			if (ODXW != None)
			{
				DXA.AmmoAmount = ODXW.ReloadCount - ODXW.ClipCount;
			}
			else
			{
				DXA.AmmoAmount = 0;
			}
			
			//Spawn a copy, dump the rest.
			Dump = Spawn(DXA.Class,,,DXA.Location, DXA.Rotation);
			DXA = DeusExAmmo(Dump);
		}
  		
  		//Repair our item chain.
  		if (Dump == Inventory) Inventory = ListNext[DropID];
  		
		PlaySound(Sound'BasketballSwoosh',,,,,1.35 + (FRand() * 0.3));
		
  		//MADDERS: Alert NPCs we're picking his pockets
  		Frobber.AISendEvent('Futz', EAITYPE_Visual);
  		
		if (HitActor == SeatActor)
		{
			Dump.DropFrom(HitActor.Location + ((vect(-1.15,0,0) * HitActor.CollisionRadius) >> Frobber.Rotation));
		}
		else
		{
  			Dump.DropFrom(HitActor.Location);
		}
		
  		if (DXA != None)
		{
			DXA.AmmoAmount = class'VMDStaticFunctions'.static.GWARRRand(1, 1, None, DXA, Play);
		}
		if (DXP != None)
		{
			MatchCount = DXP.NumCopies;
			MatchDXP = DeusExPickup(Play.FindInventoryType(DXP.Class));
		}
 		if (DXW != None)
		{
			MatchDXW = DeusExWeapon(Play.FindInventoryType(DXW.Class));
			DXW.PickupAmmoCount = class'VMDStaticFunctions'.Static.GWARRRand(1, 1, DXW, DeusExAmmo(DeusExWeapon(Dump).AmmoType), Play);
			DXW.bWeaponStay = False;
			if (DXW.AmmoName == None || DXW.AmmoName == class'AmmoNone' || Play.FindInventoryType(DXW.AmmoName) == None || MatchDXW != None)
			{
				if (DXW.AmmoName == None || DXW.AmmoName.Default.Icon != DXW.Icon) //(Play.FindInventoryType(DXW.Class) == None) && 
				{
					bShowWepIcon = true;
				}
			}
  		}
  		Dump.Instigator = Self;
  		Dump.Lifespan = 0;
  		Dump.Acceleration = (vect(0, 0, -0.5) + (Vector(Pawn(Frobber).Rotation + Rot(32768, 0, 0)) / 2)) * 256;
  		Dump.Velocity = Dump.Acceleration;
		
 		if (NumOnlookers(Frobber) > 0)
 		{
  			AgitatePickpocketFailure(Play);
			Play.ClientMessage(MessagePickpocketingSpotted);
 		}
		else
		{
			Play.FrobTarget = Dump;
			if (Play.HandleItemPickup(Dump))
			{
				if ((DXA == None) && (NanoKey(Dump) == None) && (Credits(Dump) == None))
				{
					if (MatchDXP != None)
					{
						class'VMDStaticFunctions'.Static.AddReceivedItem(Play, MatchDXP, MatchCount);
					}
					else if (DXP != None)
					{
						class'VMDStaticFunctions'.Static.AddReceivedItem(Play, DXP, MatchCount);
					}
					else
					{
						if ((DXW == None || bShowWepIcon) && (Dump != None))
						{
							if (MatchDXW != None) class'VMDStaticFunctions'.Static.AddReceivedItem(Play, MatchDXW, 1);
							else class'VMDStaticFunctions'.Static.AddReceivedItem(Play, Dump, 1);
						}
					}
				}
			}
			Play.ClientMessage(MessagePickpocketingSuccess);
		}
 	}
	else
	{
		Play.ClientMessage(MessagePickpocketingFailure);
	}
	
	//MADDERS, 1/3/21: Update pickup noises, please.
	PostPickpocketCheck(bHadWeapon);
	PostSpecialStatCheck();
}

function PostPickpocketCheck(bool bHadWeapon)
{
	local Inventory Inv;
	local DeusExWeapon DXW;
	
	//MADDERS, 12/11/21: If we're rubbing eyes, snap out of it once pickpocketed.
	if (IsInState('RubbingEyes'))
	{
		if (HasNextState())
			GotoNextState();
		else
			GotoState('Wandering');
	}
	
	//MADDERS, 2/6/21: Make us bitch out if stripped of our weapons.
	//However, MIB's and other elite foes are off the list of candidates.
	if ((bHadWeapon) && (StartingHealthValues[6] <= 100)) // && (!IsA('HumanMilitary'))
	{
		for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (DeusExWeapon(Inv) != None)
			{
				DXW = DeusExWeapon(Inv);
				break;
			}
		}
		if (DXW == None)
		{
			bCower = true;
			bMilitantCower = true;
		}
	}
}

function AgitatePickpocketFailure(VMDBufferPlayer Player)
{
 	local VMDTheftIndicator CI;
 	
 	CI = Player.Spawn(class'VMDTheftIndicator',Self,,Player.Location, Player.Rotation);
 	CI.Pawn = Self;
 	CI.Player = Player;
 	CI.InvokeCrime();
}

state TakingHit
{
	ignores seeplayer, hearnoise, bump, hitwall, reacttoinjury;
	
	function BeginState()
	{
		StandUp();
		LastPainTime = Level.TimeSeconds;
		LastPainAnim = AnimSequence;
		bInterruptState = false;
		BlockReactions();
		bCanConverse = False;
		bStasis = False;
		//SetDistress(true);
		TakeHitTimer = 2.0;
		EnemyReadiness = 1.0;
		ReactionLevel  = 1.0;
		bInTransientState = true;
		EnableCheckDestLoc(false);
	}
}

State Fleeing
{
	function BeginState()
	{
		StandUp();
		Disable('AnimEnd');
		//Disable('Bump');
		BlockReactions();
		if (!bCower)
			bCanConverse = False;
		bStasis = False;
		SetupWeapon(false, true);
		//SetDistress(true);
		EnemyReadiness = 1.0;
		//ReactionLevel  = 1.0;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}
}

State Attacking
{
     function BeginState()
     {
          StandUp();

          // hack
          if (MaxRange < MinRange+10)
               MaxRange = MinRange+10;
          bCanFire      = false;
          bFacingTarget = false;

          SwitchToBestWeapon();

          //EnemyLastSeen = 0;
          BlockReactions();
          bCanConverse = False;
          bAttacking = True;
          bStasis = False;
          //SetDistress(true);

          CrouchTimer = 0;
          EnableCheckDestLoc(false);
     }
}

function PlayDyingSound()
{
	SetDistressTimer();
	
	//Trash pawns always scream.
	if (bDoScream || Animal(Self) != None || Robot(Self) != None || bInsignificant)
	{
		if ((HeadRegion.Zone != None) && (HeadRegion.Zone.bWaterZone))
		{
			if ((Animal(Self) == None) && (Robot(Self) == None) && (UnderwaterTime > 0))
			{
				if (bIsFemale)
				{
					Die = Sound'FemaleWaterDeath';
				}
				else
				{
					Die = Sound'MaleWaterDeath';
				}
				PlaySound(Die, SLOT_Pain,,,, RandomPitch());
			}
			else
			{
				PlaySound(Die, SLOT_Pain,,,, RandomPitch()*0.85);
			}
		}
		else
		{
			PlaySound(Die, SLOT_Pain,,,, RandomPitch());
		}
		AISendEvent('LoudNoise', EAITYPE_Audio);
		if (bEmitDistress)
			AISendEvent('Distress', EAITYPE_Audio);
	}
	else
	{
		//MADDERS: Play a smaller death noise when we're killed off.
		AISendEvent('LoudNoise', EAITYPE_Audio,, 320);
	}
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

//	ClientMessage("PlayDying()");
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('WaterDeath')) PlayAnimPivot('WaterDeath',, 0.1);
	}
	else if (bSitting)  // if sitting, always fall forward
	{
		if (HasAnim('DeathFront')) PlayAnimPivot('DeathFront',, 0.1);
	}
	else
	{
		GetAxes(Rotation, X, Y, Z);
		dotp = (Location - HitLoc) dot X;

		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
		{
			if (HasAnim('DeathBack')) PlayAnimPivot('DeathBack',, 0.1);
		}
		else				// shot from the back, fall front
		{
			if (HasAnim('DeathFront')) PlayAnimPivot('DeathFront',, 0.1);
		}
	}

	// don't scream if we are stunned
	if (!bOnFire && (damageType == 'Stunned' || damageType == 'KnockedOut' || damageType == 'Poison' || damageType == 'PoisonEffect'))
	{
		bStunned = True;
		
		if (bIsFemale)
		{
			PlaySound(Sound'FemaleUnconscious', SLOT_Pain,,,, RandomPitch());
		}
		else
		{
			if (VMDPawnIsChild())
			{
				PlaySound(Sound'MaleUnconscious', SLOT_Pain,,,, RandomPitch()*1.55);
			}
			else
			{
				PlaySound(Sound'MaleUnconscious', SLOT_Pain,,,, RandomPitch());
			}
		}
	}
	else
	{
		//MADDERS, 1/12/21: Being witnessed or being killed as an ally to the player triggers aggro every time.
		//This makes instant kills only good when used tactically... And responsibily.
		//----------------
		//(NumOnlookers(Instigator) > 0) || ()
		if ((Instigator != None) && (GetPawnAllianceType(Instigator) == ALLIANCE_Friendly))
		{
			bDoScream = true;	
		}
		
		if (VMDBufferPlayer(Instigator) == None || !VMDBufferPlayer(Instigator).HasSkillAugment("MeleeAssassin"))
		{
			bDoScream = true;
		}
		
		if (bDoScream || Animal(Self) != None || Robot(Self) != None || bInsignificant)
		{
			bStunned = False;
			PlayDyingSound();
		}
	}
}

//MADDERS: Establish hook functions.
function PostBeginPlay()
{
	Super.PostBeginPlay();
	VMDBeginPlayHook();
}

function VMDBeginPlayHook()
{
}

function VMDPawnTickHook(float DeltaTime)
{
	local Medkit TMedkit;
	local bool bWasLowHealth;
	
	LastTickDelta = DeltaTime;
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//DXT BEGIN!
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if (Role == ROLE_Authority)
	{
		bClientHostileTowardsPlayers = (GetAllianceType('Player') == ALLIANCE_Hostile);
	}
	
	if (Physics == PHYS_Swimming)
	{
		dripRate += deltaTime*2;
				
		if (dripRate >= 15)
			dripRate = 15.0;
	}
	else if (dripRate > 0)
		DripWater(deltaTime);
	
	if (localPlayer == None)
		GetPlayer();
	
	//+++++++++++++++++++++++++++++
	//MADDERS BEGIN!
	//+++++++++++++++++++++++++++++
	if ((bHasCloak || bCloakOn) || (VMDConfigureCloakThresholdMod() > 0))
	{
		if ((Health <= CloakThreshold + VMDConfigureCloakThresholdMod()) && (Health < StartingHealthValues[6]))
		{
			EnableCloak(true);
		}
		else if ((IsInState('Attacking')) && (VMDConfigureCloakThresholdMod() > 0))
		{
			EnableCloak(true);
		}
		else
		{
			EnableCloak(false);
		}
	}
	
	bStunnedThisFrame = bStunned;
	
	if (bDamageGateBullshitFrame)
	{
		bDamageGateBullshitFrame = false;
	}
	
	if ((MedkitUseTimer > 0) && (VMDIsInHealableState()))
	{
		MedkitUseTimer -= DeltaTime;
		if (MedkitUseTimer <= 0)
		{
			bWasLowHealth = ShouldFlee();
			
			TMedkit = Medkit(FindInventoryType(class'Medkit'));
			if ((TMedkit != None) && (!TMedkit.bDeleteMe) && (TMedkit.NumCopies > 0) && (!TMedkit.IsInState('Activated')))
			{
				TMedkit.Activate();
			}
			
			if ((Enemy != None) && (IsInState('Fleeing')) && (bWasLowHealth) && (!ShouldFlee()))
			{
				SetNextState('Attacking');
				GoToNextState();
			}
		}
	}
	
	if (SmellSniffCooldown > 0) SmellSniffCooldown -= DeltaTime;
	if (DrawShieldCooldown > 0) DrawShieldCooldown -= DeltaTime;
	
	if ((bLookAtPlayer) && (LocalPlayer != None))
	{
		playerLastSeenTimer += deltaTime;
		lookCheckTime += deltaTime;
		
		// Performance
		if (lookCheckTime > 0.25)
		{
			lookCheckTime = 0;
			
			// Only look at the player if we're not busy in a conversation or dealing with an enemy. 
			// Look at them if in fleeing or alerting state because then they're the enemy.
			// Look at them while attacking but not seeking, otherwise our head stays turned during attacks
			if ((ConversationActor == None) && (Enemy == None || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')) && (!IsInState('Burning')) && (!IsInState('TakingHit')) && (!IsInState('Dying')) && (!IsInState('RubbingEyes')) && (!IsInState('Stunned')))
			{
				// Can we see the player
				if (localPlayer != None && 
				(VSize(localPlayer.Location-Location) <= 320) && 
				AICanSee(localPlayer,, True, True, True, True) > 0 && 
				(GetPawnAllianceType(localPlayer) != ALLIANCE_Hostile || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')))
				{
					if (lookingAtPlayerTime < 3)
						LookAtActor(localPlayer, false, true, true, 0, 1);
					bLookingReset = False;
					playerLastSeenTimer = 0;
					lookingAtPlayerTime += deltaTime + 0.25; // Compensate for lookCheckTime
				}	
				
				if (lookingAtPlayerTime >= 3 && !bLookingReset) // Look at the player for three seconds, awkwardly look away for two seconds.			
				{
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					bLookingReset = True;
					if (lookingAtPlayerTime >= 5 + FRand())
						lookingAtPlayerTime = 0;
				}
				else if ((playerLastSeenTimer > FRand() + 0.5) && !bLookingReset) // Lost sight of the player, look forward after 0.5-1.5 seconds
				{
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					bLookingReset = True;
				}	
			}
		}
	}
	
	// Can we see the player
        /*if (localPlayer != None && (VSize(localPlayer.Location-Location) <= 320) && AICanSee(localPlayer,, True, True, True, True) > 0 && 
                (GetPawnAllianceType(localPlayer) != ALLIANCE_Hostile || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')))
        {
               	if (lookingAtPlayerTime < 3)
               		LookAtActor(localPlayer, false, true, true, 0, 1);
                bLookingReset = False;
                playerLastSeenTimer = 0;
                lookingAtPlayerTime += deltaTime + 0.25; // Compensate for lookCheckTime
                
                if (bSuspiciousToPlayer)
                	LookAtActor(localPlayer, true, true, true, 0, 1);
      	}*/
	
	//MADDERS: I ain't proud of this one, but it's 100% bomb-proof, and not a very intense check at all.
	if (!bEverDrewGrenade)
	{
		if (GrenadeSkillAugmentCheckTime > 0.0)
		{
			GrenadeSkillAugmentCheckTime -= deltaTime;
		}
		else
		{
			GrenadeSkillAugmentCheckTime = 2.0;
			if ((VMDBufferPlayer(GetPlayerPawn()) != None) && (VMDBufferPlayer(GetPlayerPawn()).HasSkillAugment("DemolitionLooting")))
			{
				bEverDrewGrenade = true;
			}
		}
	}
	
	//MADDERS: Only allow us to drop LAM's if we've drawn them before. Kinda a shitty nerf, but so be it.
	if ((DeusExWeapon(Weapon) != None) && (DeusExWeapon(Weapon).VMDIsWeaponName("LAM") || DeusExWeapon(Weapon).VMDIsWeaponName("EMP")) && (DeusExWeapon(Weapon).bHandToHand) && (!DeusExWeapon(Weapon).bInstantHit))
	{
		bEverDrewGrenade = true;
	}
	
	if (TimeSincePickpocket > 0.0)
	{
		TimeSincePickpocket -= DeltaTime;
	}
	
	//Having an enemy engages scream start. No enemy disengages it.
	if ((!bScreamStart) && (Enemy != None) && (Health > 0))
	{
	 	bScreamStart = true;
	}
	else if ((!bScreamStart) && (Health > 0) && (IsInState('Fleeing')))
	{
	 	bScreamStart = true;
	}
	else if ((bScreamStart) && (Enemy == None) && (Health > 0)) ResetScream();
	
	if ((bScreamStart) && (!bDoScream) && (!IsInState('Stunned')))
	{
	 	ScreamTimer += deltaTime;
	 	if (ScreamTimer > 0.6) bDoScream = true;
	}
	
	//NEW! Scream when running away after we've had time to process!
	if ((bDoScream || Animal(Self) != None || Robot(Self) != None || bInsignificant) && (!bDistressed))
	{
	 	SetDistress(True);
	}
}

function bool VMDIsInHealableState()
{
	if (Health <= 0)
	{
		return false;
	}
	
	if (IsInState('Dying') || IsInState('Burning') || IsInState('RubbingEyes') || IsInState('Stunned'))
	{
		return false;
	}
	
	if (IsInState('Attacking') || IsInState('Fleeing') || IsInState('Seeking') || IsInState('HandlingEnemy') || IsInState('Alerting')
		|| IsInState('AvoidingProjectiles') || IsInState('TakingHit'))
		// || IsInState('BackingOff') || IsInState('OpeningDoor')
	{
		return true;
	}
	
	if (Enemy != None)
	{
		return true;
	}
	
	return false;
}

function ResetScream()
{
 	bDoScream = false;
 	bScreamStart = false;
 	ScreamTimer = 0;
}

function bool HasSeedInSet(int In)
{
 	local int TBit;
 	
 	TBit = 2 ** In;
 	
 	if ((Seedset & TBit) == TBit) return True;
 	return False;
}

function string VMDGetMapName()
{
 	local string S, S2;
 	
 	S = GetURLMap();
 	S2 = Chr(92); //What the fuck. Can't type this anywhere!
	
 	//HACK TO FIX TRAVEL BUGS!
 	if (InStr(S, S2) > -1)
 	{
  		do
  		{
   			S = Right(S, Len(S) - InStr(S, S2) - 1);
  		}
  		until (InStr(S, S2) <= -1);

		if (InStr(S, ".") > -1)
		{
  			S = Left(S, Len(S) - 4);
		}
 	}
 	else
	{
		if (InStr(S, ".") > -1)
		{
			S = Left(S, Len(S)-3);
		}
 	}
	
 	return CAPS(S);
}

function TransferArmorHit( DeusExPlayer P)
{
 	local DeusExRootWindow DXRW;
 	
 	if (VMDBufferPlayer(P) == None) return;
 	if (Abs(LastHitSeconds - Level.TimeSeconds) < 0.1) return;
 	
 	//MADDERS: Only give hit indicators in potential line of sight.
 	if (!FastTrace(P.Location, Location)) return;
 	if (bInsignificant) return; //MADDERS: It will be SIGNIFICANT.
 	
 	DXRW = DeusExRootWindow(P.RootWindow);
 	if ((DXRW != None) && (AIGetLightLevel(Location) > 0.005))
 	{
  		DXRW.Hud.HitInd.SetIndicator(True, False, bLastArmorHit);
 	}
 	
	LastHitSeconds = Level.TimeSeconds;
}

//MADDERS FUNCTIONS!
function PlayPlayerHeadshotSound( DeusExPlayer P )
{
 	local DeusExRootWindow DXRW;
 	
 	if (VMDBufferPlayer(P) == None) return;
 	if (Abs(LastHitSeconds - Level.TimeSeconds) < 0.05) return;
 	
 	//MADDERS: Only give hit indicators in potential line of sight.
 	if (!FastTrace(P.Location, Location)) return;
 	if (bInsignificant) return; //MADDERS: It will be SIGNIFICANT.
 	
 	DXRW = DeusExRootWindow(P.RootWindow);
 	if ((DXRW != None) && (AIGetLightLevel(Location) > 0.005))
 	{
 		VMDBufferPlayer(P).ProjectHeadshotSound();
 		
  		DXRW.Hud.HitInd.SetIndicator(True, True, bLastArmorHit);
 	}
 	
	LastHitSeconds = Level.TimeSeconds;
}

function Explode(optional Vector HL)
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;
	
	if (HL == vect(0,0,0)) HL = Location;
	
	explosionDamage = 100;
	explosionRadius = 256;
	
	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HL);
	if (light != None)
		light.size = 4;
	
	Spawn(class'ExplosionSmall',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, HL + 2*VRand()*CollisionRadius);
	
	sphere = Spawn(class'SphereEffect',,, HL);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;
	
	// spawn a mark
	s = spawn(class'ScorchMark', Base,, HL-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}
	
	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,HL);
		else
			spawn(class'FleshFragment',,,HL);
	}
	
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, HL);
}

function bool ShouldExplode()
{
 	local Projectile Proj;
 	local Inventory item, nextitem, lastitem;
 	local bool Ret, bDidFirst;
 	
 	if (Inventory != None)
 	{
  		bDidFirst = false;
 		item = Inventory;
  		
  		do
  		{
   			nextitem = Item.Inventory;
   			if ((DeusExWeapon(item) != None) && (DeusExWeapon(Item).bVolatile))
   			{
    				if ((DeusExWeapon(item).bHandToHand) && (!DeusExWeapon(item).bInstantHit))
    				{     
     					//NEW: Configure a proper radius, because so far this seems unreliable to a fault!
     					Proj = Spawn(DeusExWeapon(item).ProjectileClass, Self,, Location + ((vect(1,0,0) >> Rotation) * (CollisionRadius + 5)), RotRand(False));
					if (Proj != None)
					{
     						Proj.TakeDamage(100, Self, Proj.Location, vect(0,0,0), 'Exploded');
					}
     					if (!bDidFirst) Inventory = nextitem;
     					else lastItem.Inventory = NextItem;
     					
     					Item.Destroy();
    				}
    				else
    				{
     					if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
     					else lastItem.Inventory = nextitem;
     					Ret = True;
     					lastitem = item;
     					
     					Item.Destroy();
    				}
   			}
   			else if ((DeusExAmmo(item) != None) && (DeusExAmmo(Item).bVolatile))
   			{
    				if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
    				else lastItem.Inventory = nextitem;
    				Ret = True;
    				lastitem = item;
     				
    				Item.Destroy();
   			}
   			else
   			{
    				if (!bDidFirst) bDidFirst = True;
    				lastitem = item;
   			}
   			
   			item = nextitem;
  		}
  		until ((Nextitem == None) && (item == None));
 	}
 	
 	return Ret;
}

function bool VMDBlockDumpOfItem( Inventory I )
{
 	if (WeaponCombatKnife(I) != None) return true;
 	if ((DeusExWeapon(I) == None) && (I.InvSlotsX > 90)) return true;
 	if ((DeusExWeapon(I) != None) && (DeusExWeapon(I).VMDConfigureInvSlotsX(None) > 90)) return true;
 	if (I.Default.Mesh == LODMesh'TestBox') return true;
	if (ChargedPickup(I) != None) return true;
	
	//MADDERS: Destroy our inventory at random. Not a perfect retrieval rate, except for nanokeys.
	if (Nanokey(I) == None)
	{
		//MADDERS: Pickups survive more often, being less volatile.
		if (Pickup(I) != None)
		{
			if (class'VMDStaticFunctions'.Static.DeriveActorSeed(I, 3, true) == 0)
			{
		 		return true;
			}
		}
		else
		{
			if (class'VMDStaticFunctions'.Static.DeriveActorSeed(I, 3, true) != 2)
			{
				return true;
			}
		}
 	}
 	return false;
}

function DeusExWeapon GetOwningWeapon(DeusExAmmo A)
{
	local Inventory Inv;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if ((DeusExWeapon(Inv) != None) && (DeusExWeapon(Inv).AmmoType == A))
		{
			return DeusExWeapon(Inv);
		}
	}
	return None;
}

//MADDERS: Dump inventory items on gib!
function DumpItemInventory()
{
 	local Inventory item, NextItem, LastItem;
 	local float MassMult;
 	local Vector Offs, R;
 	local bool FlagNullItem;
	
	local int AmmoRet;
	local DeusExWeapon DXW, ODXW;
	local DeusExAmmo DXA, ODXA;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
 	
 	//NEW: Explode and shit if we should be doing so.
 	if (ShouldExplode())
 	{
  		Explode();
  		if (bExplosive)
  		{
   			return; //Only return when we were already gonna 'splode!
  		}
 	}
	
	//throw our shit everywhere.
	if (!IsA('Animal') && !IsA('Robot'))
	{
		if (Inventory != None)
		{
			do
			{
				item = Inventory;
				nextItem = item.Inventory;
				DeleteInventory(item);
				//experimental clause for the mystery flung shit.
				item.SetLocation(Self.Location);
				
				ODXA = None;
				ODXW = None;
				
				DXA = DeusExAmmo(Item);
				if (DXA != None)
				{
					ODXW = GetOwningWeapon(DXA);
				}
				DXW = DeusExWeapon(Item);
				if (DXW != None)
				{
					ODXA = DeusExAmmo(DXW.AmmoType);
				}
				
				FlagNullItem = False;
				if (DXA != None)
				{
					if (DXA.AmmoAmount == 0 || Item.Default.Mesh == LODMesh'TestBox') FlagNullItem = true;
				}
				if (DXW != None)
				{
					if (DXW.bNativeAttack || Item.Default.Mesh == LODMesh'TestBox') FlagNullItem = True;
				}
				
				if (Item.InvSlotsX > 90) FlagNullItem = True;
				
				if (FlagNullItem)
				{
				 	Item.Destroy();
				 	if (LastItem != None) LastItem.Inventory = NextItem;
				 	else Inventory = NextItem;
				}
				else
				{
					LastItem = Item;
				}
				MassMult = 1 + Min(3 / Max(item.Mass, 2.5), 2);
				Offs = Location;
				Offs.X += ((Rand(2) * 2) - 1) * CollisionRadius;
				Offs.Y += ((Rand(2) * 2) - 1) * CollisionRadius;
				Offs.Z += (FRand() + 0.5) * CollisionHeight;
				R = VRand() + vect(0,0,1);
				
				if (DXW != None)
				{
					AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(0, 0, DXW, ODXA, VMP);
					
				 	DXW.AIRating = DXW.Default.AIRating;
				 	DXW.bMuzzleFlash = 0;
				 	DXW.PickupAmmoCount = AmmoRet;
					DXW.EraseMuzzleFlashTexture();
				}
				if (DXA != None)
				{
					AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(1, 3, ODXW, DXA, VMP);
					
					DXA.AmmoAmount = AmmoRet;
					//DXA.AmmoAmount = Rand(Max(DXA.MaxAmmo / 50, 3))+1;
					
					//MADDERS, 1/13/21: Don't drop 0 ammo, thanks.
					if (AmmoRet <= 0) DXA.Destroy();
				}
				
				//MADDERS, 8/7/23: I'm lazy. Sue me.
				item.SetPropertyText("bCorpseUnclog", "True");
				
				item.SetPhysics(PHYS_Falling);
				item.RemoteRole = ROLE_DumbProxy;
				item.NetPriority = 2.5;
				item.BecomePickup();
				item.bCollideWorld = True;
				item.GoToState('PickUp', 'Dropped');
				item.Velocity = R * (Rand(50) + 100) * MassMult;
				item.Velocity = item.Velocity + Velocity; //Magic clause for relative velocity!
				item.bFixedRotationDir = True;
				item.RotationRate = RotRand(True);
				item.RespawnTime = 0;
				
				if (VMDBlockDumpOfItem(item)) item.Destroy();
				item = nextItem;
			}
			until (item == None);
		}
	}
}

//MADDERS: Fix bad anims being called!
//
// lip synching support - DEUS_EX CNN
//
function LipSynch(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.1;
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		if (nextPhoneme == "A")
			animseq = 'MouthA';
		else if (nextPhoneme == "E")
			animseq = 'MouthE';
		else if (nextPhoneme == "F")
			animseq = 'MouthF';
		else if (nextPhoneme == "M")
			animseq = 'MouthM';
		else if (nextPhoneme == "O")
			animseq = 'MouthO';
		else if (nextPhoneme == "T")
			animseq = 'MouthT';
		else if (nextPhoneme == "U")
			animseq = 'MouthU';
		else if (nextPhoneme == "X")
			animseq = 'MouthClosed';

		if (animseq != '')
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				if (HasAnim(animseq)) TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if (HasAnim('MouthClosed')) TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if (FRand() < 0.4 && HasAnim('Blink'))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}

	LoopHeadConvoAnim();
	LoopBaseConvoAnim();
}

//
// PlayTurnHead - DEUS_EX STM
//

function bool SimulatedSuperPlayTurnHead(ELookDirection dir, float rate, float tweentime)
{
	local name lookName;
	local bool bSuccess;

	if (dir == LOOK_Left)
		lookName = 'HeadLeft';
	else if (dir == LOOK_Right)
		lookName = 'HeadRight';
	else if (dir == LOOK_Up)
		lookName = 'HeadUp';
	else if (dir == LOOK_Down)
		lookName = 'HeadDown';
	else
		lookName = 'Still';

	bSuccess = false;
	if (BlendAnimSequence[3] != lookName)
	{
		if (animTimer[1] > 0.00)
		{
			animTimer[1] = 0;
			if (BlendAnimSequence[3] == '')
				BlendAnimSequence[3] = 'Still';
			if (HasAnim(lookName)) PlayBlendAnim(lookName, rate, tweentime, 3);
			bSuccess = true;
		}
	}

	return (bSuccess);
}

function VMDBufferPlayer GetLastVMP()
{
	if (LastVMP == None)
	{
		LastVMP = VMDBufferPlayer(GetPlayerPawn());
	}
	return LastVMP;
}

//Check all our health bullshit.
function CheckHealthScaling()
{
	local VMDBufferPlayer VMP;
	
	VMP = GetLastVMP();
 	if ((VMP != None) && (!bSetupBuffedHealth))
 	{
		if (VMP.bRecognizeMovedObjectsEnabled)
		{
			bRecognizeMovedObjects = true;
		}
		
  		HealthHead *= VMP.EnemyHPScale;
  		HealthTorso *= VMP.EnemyHPScale;
  		HealthArmLeft *= VMP.EnemyHPScale;
  		HealthArmRight *= VMP.EnemyHPScale;
  		HealthLegLeft *= VMP.EnemyHPScale;
  		HealthLegRight *= VMP.EnemyHPScale;
		Health *= VMP.EnemyHPScale;
  		CloakThreshold *= VMP.EnemyHPScale;
		if (Robot(Self) != None)
		{
			Robot(Self).EMPHitPoints *= (1.0 + VMP.EnemyHPScale) / 2;
			Robot(Self).StartingEMPHitPoints = Robot(Self).EMPHitPoints;
		}
  		
  		bSetupBuffedHealth = True;
 	}
	
	if ((MinHealth > 1) && (Robot(Self) == None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Enemy Damage Gate")))
	{
		bDamageGateInTact = true;
	}
	
	StartingHealthValues[0] = HealthHead;
	StartingHealthValues[1] = HealthTorso;
	StartingHealthValues[2] = HealthArmLeft;
	StartingHealthValues[3] = HealthArmRight;
	StartingHealthValues[4] = HealthLegLeft;
	StartingHealthValues[5] = HealthLegRight;
	StartingHealthValues[6] = Health;
  	GenerateTotalHealth();
}

function VMDExtendVision()
{
	local int i;
	local float VisionRadiusBonus;
	local Vector TLocs[8];
	
	if (bBuffedVision) return;
	
	bBuffedVision = true;
	if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "ENEMY VISION EXTENSION")) return;
	
	TLocs[0] = Location + Vect(1000, 0, 0);
	TLocs[1] = Location + Vect(2000, 0, 0);
	TLocs[2] = Location + Vect(-1000, 0, 0);
	TLocs[3] = Location + Vect(-2000, 0, 0);
	TLocs[4] = Location + Vect(0, 1000, 0);
	TLocs[5] = Location + Vect(0, 2000, 0);
	TLocs[6] = Location + Vect(0, -1000, 0);
	TLocs[7] = Location + Vect(0, -2000, 0);
	
	VisionRadiusBonus = 1.0;
	for (i=0; i<ArrayCount(TLocs); i++)
	{
		if (FastTrace(Location, TLocs[i]))
		{
			VisionRadiusBonus += 0.1024;
		}
	}
	SightRadius *= VisionRadiusBonus;
}

//MADDERS: FILLER!
function ApplySpecialStats();
function ApplySpecialStats2();

//MADDERS, 5/24/20: Give ambient sounds to pawns with ballistic/hazmat on them, as to give some audio feedback.
function PostSpecialStatCheck()
{
	local Inventory Inv;
	
	//MADDERS, 12/20/20: Don't do this to civvies.
	if ((HumanMilitary(Self) == None) && (HumanThug(Self) == None)) return; 
	
	AmbientSound = None;
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (BallisticArmor(Inv) != None || HazmatSuit(Inv) != None)
		{
			AmbientSound = ChargedPickup(Inv).LoopSound;
			SoundVolume = 128;
			break;
		}
	}
	
	VMDExtendVision();
}

function VMDResetSkinHook()
{
	local int i, TarIndex[3];
	
	TarIndex[0] = -1;
	TarIndex[1] = -1;
	TarIndex[2] = -1;
	
	switch(Mesh.Name)
	{
		case 'GFM_TShirtPants':
		case 'TransGFM_TShirtPants':
			TarIndex[0] = 3;
			TarIndex[1] = 4;
		break;
		case 'GM_Jumpsuit':
		case 'Trans_GM_Jumpsuit':
			TarIndex[0] = 5;
		break;
		case 'GM_Suit':
		case 'TransGM_Suit':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
		break;
		case 'GM_DressShirt':
		case 'TransGM_DressShirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_DressShirt_B':
		case 'TransGM_DressShirt_B':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
			TarIndex[2] = 7;
		break;
		case 'GFM_SuitSkirt':
		case 'TransGFM_SuitSkirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_Trench':
		case 'TransGM_Trench':
		case 'GM_Trench_F':
		case 'TransGM_Trench_F':
		case 'GFM_Trench':
		case 'TransGFM_Trench':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
	}
	
	for (i=0; i<ArrayCount(TarIndex); i++)
	{
		if (TarIndex[i] != -1)
		{
			Multiskins[TarIndex[i]] = Default.Multiskins[TarIndex[i]];
		}
	}
}

function VMDEnableCloakHook(bool bEnable)
{
	local int i, TarIndex[4];
	
	TarIndex[0] = -1;
	TarIndex[1] = -1;
	TarIndex[2] = -1;
	TarIndex[3] = -1;
	
	switch(Mesh.Name)
	{
		case 'GFM_TShirtPants':
		case 'TransGFM_TShirtPants':
			TarIndex[0] = 3;
			TarIndex[1] = 4;
		break;
		case 'GM_Jumpsuit':
		case 'Trans_GM_Jumpsuit':
			TarIndex[0] = 5;
		break;
		case 'GM_Suit':
		case 'TransGM_Suit':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
		break;
		case 'GM_DressShirt':
		case 'TransGM_DressShirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_DressShirt_B':
		case 'TransGM_DressShirt_B':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
			TarIndex[2] = 7;
		break;
		case 'GFM_SuitSkirt':
		case 'TransGFM_SuitSkirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_Trench':
		case 'TransGM_Trench':
		case 'GM_Trench_F':
		case 'TransGM_Trench_F':
		case 'GFM_Trench':
		case 'TransGFM_Trench':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
	}
	
	for (i=0; i<ArrayCount(TarIndex); i++)
	{
		if (TarIndex[i] != -1)
		{
			if (bEnable)
			{
				Multiskins[TarIndex[i]] = Texture'BlackMaskTex';
			}
			else
			{
				Multiskins[TarIndex[i]] = Default.Multiskins[TarIndex[i]];
			}
		}
	}
}

//MADDERS: For robots, as far as anyone can tell.
function VMDEMPHook()
{
}

//MADDERS: Use this for checking classes. Pretty hacky.
function bool VMDOtherIsName(string S, optional Actor Other)
{
	if (Other == None) Other = Self;
	
 	if (InStr(CAPS(String(Other.Class)), CAPS(S)) > -1) return true;
 	return false;
}

//MADDERS: This shit's just too easy.
function CheckForHelmets()
{
 	/*if (VMDOtherIsName("MIB", Self) || VMDOtherIsName("WIB", Self))
 	{
     		ArmorNoiseIndex[0] = 0;
     		ArmorNoiseIndex[1] = 0;
  		bHasBodyArmor = True;
 	}*/
	
	if (VMDOtherIsName("Gunther", Self))
	{
     		ArmorNoiseIndex[0] = 1;
     		ArmorNoiseIndex[1] = 1;
  		bHasHelmet = False;
		bHasHeadArmor = True;
  		bHasBodyArmor = True;
	}

	if (VMDOtherIsName("Navarre", Self))
	{
     		ArmorNoiseIndex[0] = 1;
     		ArmorNoiseIndex[1] = 0;
  		bHasHelmet = False;
		bHasHeadArmor = False;
  		bHasBodyArmor = True;
	}
	
 	if (VMDOtherIsName("Commando", Self))
 	{
     		ArmorNoiseIndex[0] = 1;
     		ArmorNoiseIndex[1] = 1;
  		bHasHelmet = False;
		bHasHeadArmor = True;
  		bHasBodyArmor = True;
 	}
 	
 	if (Mesh != LODMesh'GM_Jumpsuit') return;
 	
 	//Goggles is the only real exception here, tbh.
 	switch(Multiskins[6])
 	{
  		case Texture'PinkMaskTex':
  		case Texture'GogglesTex1':
   			bHasHelmet = False;
  		break;
  		default:
   			bHasHelmet = True;
  		break;
 	}
}

function bool BypassesHelmet( name DT )
{
 	switch(DT)
 	{
  		case 'Shot':
  		case 'Poison':
  		case 'KnockedOut':
   			return False;
  		break;
  		default:
   			return True;
  		break;
 	}
 	
 	return False;
}

function DeflectHelmetProjectile(int D, vector HL, vector Off, name DT, optional bool bHelmet)
{
 	local Vector DAngle, OAngle, HAngle, TPos;
 	local HelmetProjectile HP;
 	local float TSize, TMult;
 	local Rotator TRot;
 	
 	if (ArmorNoiseIndex[int(bHelmet)] > 0)
 	{
  		VMDPlayRicochetSound();
 	}
 	
 	//Step 1: Derive original hit normal.
 	/*OAngle = Off >> Rotator(HL - Location);
 	TPos = Location; //While we're at it, derive our spawn loc.
 	TPos.Z = HL.Z;
 	
 	//Step 2: Deflect this shit in offset.
 	DAngle = Normal(OAngle);
 	if (Frand() < 0.9) DAngle.X *= -1;
 	if (Frand() > 0.1) DAngle.Y *= -1;
 	DAngle.Z = 0;
 	
 	TRot = RotRand(False);
 	TRot = TRot / 16;
 	TRot = TRot - Rot(0, -8192, 0);
 	
 	DAngle = Vector((Rotator(DAngle) + TRot));
 	DAngle.Z = 0.05 - (Frand() * 0.1);
 	
 	//Step 3: Fire that shit and match DT and D.
 	PlaySound(Sound'ArmorRicochet', SLOT_Misc, 48,, 512);
 	HP = Spawn(Class'HelmetProjectile',Self,, TPos + (DAngle * (5 + CollisionRadius)), Rotator(DAngle));
 	if (HP != None)
 	{
  		HP.Damage = D;
  		HP.DamageType = DT;
 	}*/
}

//MADDERS, 1/25/23: So far only used in ford, but fuck it, have at it.
function VMDConvoBindHook();

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function AdjustJump();
function MoveFallingBody();
function Vector FocusDirection();
function FindBackupPoint();
function bool DoorEncroaches();
function bool PickDestination();
function EDestinationType PickDestinationAttacking(); //BARF! Thanks Ion.
function float DistanceToTarget();
function AlarmUnit FindTarget();
function bool GetNextAlarmPoint(AlarmUnit alarm);
function vector FindAlarmPosition(Actor alarm);
function bool IsAlarmInRange(AlarmUnit alarm);
function TriggerAlarm();
function bool IsAlarmReady(Actor actorAlarm);
function EndCrouch();
function StartCrouch();
function bool ShouldCrouch();
function bool ReadyForWeapon();
function bool IsHandToHand();
function CheckAttack(bool bPlaySound);
function bool FireIfClearShot();
function bool InSeat(out vector newLoc);
function FinishFleeing();
function NavigationPoint GetOvershootDestination(float randomness, optional float focus);
function bool GetNextLocation(out vector nextLoc);
function PatrolPoint PickStartPoint();
function bool GoHome();
function FollowSeatFallbackOrders();
function FindBestSeat();
function int FindBestSlot(Seat seatActor, out float slotDist);
function bool IsIntersectingSeat();
function vector GetDestinationPosition(Seat seatActor, optional float extraDist);
function Vector SitPosition(Seat seatActor, int slot);

defaultproperties
{
     EnviroSkillLevel=1
     PoisonReactThreshold=0.700000
     bDoesntSniff=False
     ArmorNoiseIndex(0)=0
     ArmorNoiseIndex(1)=1
     SmellTypes(0)="PlayerSmell"
     SmellTypes(1)="StrongPlayerFoodSmell"
     FakeBarkSniffing="(Sniffing)"
     MessagePickpocketingSuccess="No prying eyes witness your expert pickpocketing"
     MessagePickpocketingFailure="Your target's pockets hold nothing worth while"
     MessagePickpocketingSpotted="While succesful, your pickpocketing is seen by a nearby witness"
     bReactLoudNoise=True
     
     ArmorStrength=0.650000
     bEverNotFrobbed=true
     //MADDERS: New stuff!
     OverrideHeight=-2.000000
     bExplosive=False
     bHasBodyArmor=False
     bHasHeadArmor=False
     bHasHelmet=False
     
     //Audio.
     FootstepProjectRadius=768.000000
     FootstepProjectMaxRadius=2048.00000
     ReceiveNoiseHeightTolerance=0.650000
     SendNoiseHeightTolerance=0.650000
}