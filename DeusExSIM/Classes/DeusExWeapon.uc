//=============================================================================
// DeusExWeapon.
//=============================================================================
class DeusExWeapon extends Weapon
	abstract;

#exec OBJ LOAD FILE=VMDEffects

//
// enums for weapons (duh)
//
enum EEnemyEffective
{
	ENMEFF_All,
	ENMEFF_Organic,
	ENMEFF_Robot
};

enum EEnviroEffective
{
	ENVEFF_All,
	ENVEFF_Air,
	ENVEFF_Water,
	ENVEFF_Vacuum,
	ENVEFF_AirWater,
	ENVEFF_AirVacuum,
	ENVEFF_WaterVacuum
};

enum EConcealability
{
	CONC_None,
	CONC_Visual,
	CONC_Metal,
	CONC_All
};

enum EAreaType
{
	AOE_Point,
	AOE_Cone,
	AOE_Sphere
};

enum ELockMode
{
	LOCK_None,
	LOCK_Invalid,
	LOCK_Range,
	LOCK_Acquire,
	LOCK_Locked
};

var bool				bReadyToFire;			// true if our bullets are loaded, etc.
var() travel int				LowAmmoWaterMark;		// critical low ammo count
var travel int			ClipCount;				// number of bullets remaining in current clip

var() class<Skill>		GoverningSkill;			// skill that affects this weapon
var() travel float		NoiseLevel;				// amount of noise that weapon makes when fired
var() EEnemyEffective	EnemyEffective;			// type of enemies that weapon is effective against
var() EEnviroEffective	EnviroEffective;		// type of environment that weapon is effective in
var() EConcealability	Concealability;			// concealability of weapon
var() travel bool		bAutomatic;				// is this an automatic weapon?
var() travel float		ShotTime;				// number of seconds between shots
var() travel float		ReloadTime;				// number of seconds needed to reload the clip
var() travel int			HitDamage;				// damage done by a single shot (or for shotguns, a single slug)
var() int				MaxRange;				// absolute maximum range in world units (feet * 16)
var() travel int		AccurateRange;			// maximum accurate range in world units (feet * 16)
var() travel float		BaseAccuracy;			// base accuracy (0.0 is dead on, 1.0 is far off)

var bool				bCanHaveScope;			// can this weapon have a scope?
var() travel bool		bHasScope;				// does this weapon have a scope?
var() int				ScopeFOV;				// FOV while using scope
var bool				bZoomed;				// are we currently zoomed?
var bool				bWasZoomed;				// were we zoomed? (used during reloading)

var bool				bCanHaveLaser;			// can this weapon have a laser sight?
var() travel bool		bHasLaser;				// does this weapon have a laser sight?
var bool				bLasing;				// is the laser sight currently on?
var LaserEmitter		Emitter;				// actual laser emitter - valid only when bLasing == True

var bool				bCanHaveSilencer;		// can this weapon have a silencer?
var() travel bool		bHasSilencer;			// does this weapon have a silencer?

var() bool				bCanTrack;				// can this weapon lock on to a target?
var() float				LockTime;				// how long the target must stay targetted to lock
var float				LockTimer;				// used for lock checking
var float            MaintainLockTimer;   // Used for maintaining a lock even after moving off target.
var Actor            LockTarget;          // Used for maintaining a lock even after moving off target.
var Actor				Target;					// actor currently targetted
var ELockMode			LockMode;				// is this target locked?
var string				TargetMessage;			// message to print during targetting
var float				TargetRange;			// range to current target
var() Sound				LockedSound;			// sound to play when locked
var() Sound				TrackingSound;			// sound to play while tracking a target
var float				SoundTimer;				// to time the sounds correctly

var() class<Ammo>		AmmoNames[3];			// three possible types of ammo per weapon
var() class<Projectile> ProjectileNames[3];		// projectile classes for different ammo
var() EAreaType			AreaOfEffect;			// area of effect of the weapon
var() bool				bPenetrating;			// shot will penetrate and cause blood
var() float				StunDuration;			// how long the shot stuns the target
var() bool				bHasMuzzleFlash;		// does this weapon have a flash when fired?
var() bool				bHandToHand;			// is this weapon hand to hand (no ammo)?
var globalconfig vector SwingOffset;     // offsets for this weapon swing.
var() travel float		recoilStrength;			// amount that the weapon kicks back after firing (0.0 is none, 1.0 is large)
var bool				bFiring;				// True while firing, used for recoil
var bool				bOwnerWillNotify;		// True if firing hand-to-hand weapons is dependent on the owner's animations
var bool				bFallbackWeapon;		// If True, only use if no other weapons are available
var bool				bNativeAttack;			// True if weapon represents a native attack
var bool				bEmitWeaponDrawn;		// True if drawing this weapon should make NPCs react
var bool				bUseWhileCrouched;		// True if NPCs should crouch while using this weapon
var bool				bUseAsDrawnWeapon;		// True if this weapon should be carried by NPCs as a drawn weapon
var bool				bWasInFiring;

var bool bNearWall;								// used for prox. mine placement
var Vector placeLocation;						// used for prox. mine placement
var Rotator placeNormal;						// used for prox. mine placement //DXT: Was Vector
var Mover placeMover;							// used for prox. mine placement

var float ShakeTimer;
var float ShakeYaw;
var float ShakePitch;

var float AIMinRange;							// minimum "best" range for AI; 0=default min range
var float AIMaxRange;							// maximum "best" range for AI; 0=default max range
var float AITimeLimit;							// maximum amount of time an NPC should hold the weapon; 0=no time limit
var float AIFireDelay;							// Once fired, use as fallback weapon until the timeout expires; 0=no time limit

var float standingTimer;						// how long we've been standing still (to increase accuracy)
var float currentAccuracy;						// what the currently calculated accuracy is (updated every tick)

var MuzzleFlash flash;							// muzzle flash actor

var float MinSpreadAcc;        // Minimum accuracy for multiple slug weapons (shotgun).  Affects only multiplayer,
                               // keeps shots from all going in same place (ruining shotgun effect)
var float MinProjSpreadAcc;
var float MinWeaponAcc;        // Minimum accuracy for a weapon at all.  Affects only multiplayer.
var bool bNeedToSetMPPickupAmmo;

var travel bool	bDestroyOnFinish;

var float	mpReloadTime;			
var int		mpHitDamage;
var float	mpBaseAccuracy;
var int		mpAccurateRange;
var int		mpMaxRange;
var int		mpReloadCount;
var int		mpPickupAmmoCount;

// Used to track weapon mods accurately.
var bool bCanHaveModBaseAccuracy;
var travel bool bCanHaveModReloadCount;
var bool bCanHaveModAccurateRange;
var bool bCanHaveModReloadTime;
var bool bCanHaveModRecoilStrength;
var travel float ModBaseAccuracy;
var travel float ModReloadCount;
var travel float ModAccurateRange;
var travel float ModReloadTime;
var travel float ModRecoilStrength;

var localized String msgCannotBeReloaded;
var localized String msgOutOf;
var localized String msgNowHas;
var localized String msgAlreadyHas;
var localized String msgNone;
var localized String msgLockInvalid;
var localized String msgLockRange;
var localized String msgLockAcquire;
var localized String msgLockLocked;
var localized String msgRangeUnit;
var localized String msgTimeUnit;
var localized String msgMassUnit;
var localized String msgNotWorking;

//
// strings for info display
//
var localized String msgInfoAmmoLoaded;
var localized String msgInfoAmmo;
var localized String msgInfoDamage;
var localized String msgInfoClip;
var localized String msgInfoROF;
var localized String msgInfoReload;
var localized String msgInfoRecoil;
var localized String msgInfoAccuracy;
var localized String msgInfoAccRange;
var localized String msgInfoMaxRange;
var localized String msgInfoMass;
var localized String msgInfoLaser;
var localized String msgInfoScope;
var localized String msgInfoSilencer;
var localized String msgInfoNA;
var localized String msgInfoYes;
var localized String msgInfoNo;
var localized String msgInfoAuto;
var localized String msgInfoSingle;
var localized String msgInfoRounds;
var localized String msgInfoRoundsPerSec;
var localized String msgInfoSkill;
var localized String msgInfoWeaponStats;

var bool		bClientReadyToFire, bClientReady, bInProcess, bFlameOn, bLooping;
var int		SimClipCount, flameShotCount, SimAmmoAmount;
var float	TimeLockSet;

//+++++++++++++++++++++++++++++++++
//MADDERS CONTENT ADDITIONS.
//+++++++++++++++++++++++++++++++++
var travel bool bHasEvolution;
var travel bool bSemiautoTrigger, bBurstFire, bPocketReload, bSingleLoaded, bPumpAction; //Fire modes!
var travel byte CurFiringMode, NumFiringModes, OverrideNumProj;
var travel float OverrideAnimRate, NPCOverrideAnimRate, OverrideReloadAnimRate, MeleeAnimRates[3],
			FalloffStartRange, RelativeRange, LastDamageMult, MoverDamageMult;
var int SecondaryScopeFOV, ZoomInCount; //MADDERS, 11/29/21: Use this for second zoom functionality.

//MADDERS, 7/2/22: Hacky bullshit for the assault 17 in nihilum.
var bool VMDHackbOffsetFireMode, VMDHackbReceivedIconBlock;

//NOTE: Max acc is for shotguns not being *too* inaccurate.
var travel float MaximumAccuracy;

//Rotation code. It ain't even hard, homes.
var travel bool bRotatedInInventory;
var bool bCanRotateInInventory;
var Texture RotatedIcon;

var localized string ClipsLabel;
var bool bVolatile, bForceHeavyWeapon, bNameCaseSensitive; //9/24/21: For modded weapons to be heavy regardless of raw mass.
var byte PumpPurpose; //0 = Shoot and Reload, 1 = Shoot, 2 = Reload
var float PumpStart, LastFireTime, FirePitchMin, FirePitchMax; //Start frame for pumping
var string FiringModes[4];
var localized string ModeNames[4], MessageChangedMode, FiringModesLabel, MsgInfoBurst; //Now localized.

var sound SemiautoFireSound, SingleLoadSound; //Because science.
var sound SilencedFireSound, SemiautoSilencedFireSound;
var bool bForceSoundGeneration; //MADDERS, 4/11/21: For greasel spit, and possibly other exceptions. 

//Firing system.
var byte FiringSystemOperation; //0 = None, 1 = Closed, 2 = Open
var travel float AmmoDamageMultiplier, GunModDamageMultiplier, ExtraFloatDamage; //MADDERS, 4/28/25: Let us do fractional damage at base.
var localized string MessageTooDirty, MessageTooWet, msgNoAmmo,
			OpenSystemDesc, ClosedSystemDesc, GrimeLevelDesc[3], PenetrationDesc, RicochetDesc,
			FiringSystemLabel, GrimeLevelLabel, PenetrationLabel, RicochetLabel, msgInfoMoverDamageMult,
			MsgGainedMod, MsgMergedMods[2], ModNames[9];

//How much damage do we do on impact, if secondary?
var travel int PenetrationHitDamage, RicochetHitDamage;
var float BulletholeSize, MinimumTracerDist;
var name LastHitTextureGroup;

//Bolt function
var bool bBoltAction;
var float BoltActionRate, BoltActionDelay, FireCutoffFrame;
var name BoltStartSeq, BoltDelaySeq, BoltEndSeq;
var sound BoltStartSound, BoltEndSound;

//Evolution function
var localized string EvolvedName, EvolvedBelt;
var bool bCanHaveModEvolution;

var travel int Last20mmCount;

//Render overlay effects.
//MADDERS: These is always being adjusted. Var it, for fuck's sake.
var float BloodRenderMult, GrimeRenderMult, WaterRenderMult;
var travel float GrimeLevel, WaterLogLevel, GrimeRateMult;
var travel byte HandSkinIndex[2], SkinSwapException[8], MuzzleFlashIndex;
var bool bLastShotJammed;
var travel bool bReloadFromEmpty, bReloadWasntEmpty;

var float ZoomedInTime;

//MADDERS, 12/23/23: Alert people nearby we're basically stealing.
var() bool bSuperOwned;

//Kind of overlay related.
var() Mesh LeftPlayerViewMesh, LeftThirdPersonMesh;

//MADDERS, 10/10/22: We have a whitelist for vanilla, but list any drone stuff here.
var bool bDroneCapableWeapon, bDroneGrenadeWeapon;
var float DroneMinRange, DroneMaxRange;

//-----GP2----GP2----GP2-----
//Experimental tactical weapon code
//-----GP2----GP2----GP2-----
var(GP2Experimental) rotator CurrentAimOffset, MinAimOffset, MaxAimOffset;
var(GP2Experimental) float SwayProgress, SwayExcitement, SwayDistance, SwayDistanceTimer, DistanceVelocity;

//Aim packets
var(GP2Experimental) rotator CurrentAimPackets[8];
var(GP2Experimental) float AimPacketProgress[8], AimPacketRate[8];

//Swerve and Bob
var(GP2Experimental) float BobPacketProgress, PrimaryBobFactors[4], SecondaryBobFactors[4];
var(GP2Experimental) rotator CurBobPacket;
var(GP2Experimental) vector LastMoveNormal;

var(GP2Experimental) float SwerveRecoveryFactors[4], SwervePitchMomentum, SwerveYawMomentum;
var(GP2Experimental) rotator CurSwervePacket, LastViewRotation;

//Anim set. Purely a power saver.
var(GP2Experimental) name CurAnimSet;

//Universals. Should be set globally and tweaked globally.
var(GP2Experimental) float ExcitementRateThresholds[5], ExcitementTargetScalars[5], ExcitementRateScalars[3];
var(GP2Experimental) float SkillAccuracyFactors[4], AccuracyFactorScalar;
var(GP2Experimental) float AimFocusMults[7], AimFocusRanges[2];
var(GP2Experimental) float RecoilDecayMult, RecoilRecoveryFactors[4];
var(GP2Experimental) float SwayDistanceCooldown, SwayDistanceRate, SwayExcitementScalar;

//---------------------------------------------
//DXT IMPORTS! (Not all made by DXT, disclaimer)
//---------------------------------------------
//G-Flex: for better and more consisting shakiness
var float ShakeMagnitude;
var float ShakeMagnitudeAdjust;
var float ShakeAngle;
var float ShakeAngleAccel;
var float ShakeMagnitudeToward;

var localized String msgInfoPerSec;

// If frobbed set this, if set allow it to be picked up even when refused.
var bool bItemRefusalOverride;

//DXT Band-aid. Ugh.
var bool bFireFudge;

//VMD Band-aid. Ugh.
var bool bLoadAmmoFudge;

//MADDERS, 8/7/23: Corpse drop hack for not blocking pawns.
var bool bCorpseUnclog;

//------------------------------------
//TILT EFFECT ORGY! Mess galore.
//------------------------------------

//Recoil path.
//---------------
var(RecoilIndices) int CurRecoilIndex, NumRecoilIndices;
var(RecoilIndices) float RecoilResetTimer;
var(RecoilIndices) vector RecoilIndices[8];

var globalconfig float UnivScopeRecoilMult, UnivScopeSwayMult; //MADDERS: Adding these for QOL reasons.
var float AimDecayMult, AimFocusMult, RecoilDecayRate; //How fast does recoil decay?

//Motion path.
//---------------
var (TiltSequences) bool bDebugTilt;
var (TiltSequences) int ForceMeleeSeq;
var float TiltAddTime;

var(TiltSequences) vector ReloadBeginTilt[8], ReloadEndTilt[8],
	    ReloadBeginEmptyTilt[8], ReloadEndEmptyTilt[8],
	     ReloadTilt[8], ReloadEmptyTilt[8],
              MeleeSwing1Tilt[8], MeleeSwing2Tilt[8], MeleeSwing3Tilt[8],
	       SelectTilt[8], SelectEmptyTilt[8], DownTilt[8], DownEmptyTilt[8], PumpTilt[8],
	        SightInTilt[8], SightOutTilt[8], ShootTilt[8], ZoomInTilt, ZoomOutTilt, ToggleTilt, Toggle2Tilt;

//Nasty hack. 0 = Current. 1 = Cap.
var(TiltSequences) float ReloadBeginTiltTimer[8], ReloadEndTiltTimer[8],
	   ReloadBeginEmptyTiltTimer[8], ReloadEndEmptyTiltTimer[8],
	    ReloadTiltTimer[8], ReloadEmptyTiltTimer[8],
             MeleeSwing1TiltTimer[8], MeleeSwing2TiltTimer[8], MeleeSwing3TiltTimer[8],
	     SelectTiltTimer[8], SelectEmptyTiltTimer[8], DownTiltTimer[8], DownEmptyTiltTimer[8],
	      SightInTiltTimer[8], SightOutTiltTimer[8], ShootTiltTimer[8];

//Number of indices we actually fucking use. Don't overdo it.
var(TiltSequences) int ReloadBeginTiltIndices, ReloadEndTiltIndices,
	 ReloadBeginEmptyTiltIndices, ReloadEndEmptyTiltIndices,
	  ReloadTiltIndices, ReloadEmptyTiltIndices,
           MeleeSwing1TiltIndices, MeleeSwing2TiltIndices, MeleeSwing3TiltIndices,
	    SelectTiltIndices, SelectEmptyTiltIndices, DownTiltIndices, DownEmptyTiltIndices,
             SightInTiltIndices, SightOutTiltIndices, ShootTiltIndices;

//MADDERS, 5/10/25: More about not interfering with weapon modding 2.
//This function super duper sucks. It can't pull precise information from ammos and rando scaling our damage...
//What it CAN do however is figure out what direction ammos and rando are pulling our damage, and shove our float damage in that direction as well.
//This seems to work, according to 1 1/2 hours of crunching math, but it cannot be as precise as it needs to be, just because of the loss of information in transit.
function float GetWM2FloatDamage()
{
	local float DamageVals[3], Ret;
	
	DamageVals[0] = (float(Default.HitDamage) + Default.ExtraFloatDamage) * GunModDamageMultiplier;
	DamageVals[1] = (float(HitDamage) + ExtraFloatDamage);
	DamageVals[2] = DamageVals[1] / DamageVals[0];
	
	Ret = DamageVals[2] * ExtraFloatDamage;
	
	return Ret;
}

function float FactorWM2DrawSpeedMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function float FactorWM2HolsterSpeedMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function float FactorWM2AccModifier()
{
	if (!ShouldUseWM2())
	{
		return 0.0;
	}
	return 0.0;
}

function float FactorWM2RecoilRecoveryMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function float FactorWM2ADSMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function float FactorWM2FocusMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function float FactorWM2SwayMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function float FactorWM2UniversalFocusMultiplier()
{
	if (!ShouldUseWM2())
	{
		return 1.0;
	}
	return 1.0;
}

function InvokeWM2Window(DeusExPlayer Player, DeusExWeapon DXW)
{
}

function bool ShouldUseWM2()
{
	return false;
}

function bool ShouldUseGP2()
{
	if (VMDIsMeleeWeapon())
	{
		return false;
	}
	
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).bUseGunplayVersionTwo))
	{
		return true;
	}
	
	return false;
}

function float GP2GetSwayRateMult()
{
	local float Ret;
	
	Ret = 0.2;
	
	switch(CurAnimSet)
	{
		case 'Idle':
			Ret *= 1.0;
		break;
		case 'Reloading':
			Ret *= 0.33;
		break;
		case 'Attacking':
			Ret *= 1.5;
		break;
	}
	
	Ret *= SwayExcitement;
	
	return Ret;
}

function name GP2GetAnimSet()
{
	switch(AnimSequence)
	{
		case 'Attack':
		case 'Attack2':
		case 'Attack3':
		case 'Shoot':
			return 'Attacking';
		break;
		case 'ReloadBegin':
		case 'Reload':
		case 'ReloadEnd':
			return 'Reloading';
		break;
		default:
			return 'Idle';
		break;
	}
}

function GP2AddAimPacket(Rotator NewPacket, float NewRate, optional float StartFrame)
{
	local int i;
	
	for(i=ArrayCount(CurrentAimPackets)-1; i>=1; i--)
	{
		CurrentAimPackets[i] = CurrentAimPackets[i-1];
		AimPacketRate[i] = AimPacketRate[i-1];
		AimPacketProgress[i] = AimPacketProgress[i-1];
	}
	
	CurrentAimPackets[0] = NewPacket;
	AimPacketRate[0] = NewRate;
	AimPacketProgress[0] = StartFrame;
}

function GP2RemoveAimPacket(int TargetIndex)
{
	local int i;
	
	CurrentAimPackets[TargetIndex] = Rot(0,0,0);
	AimPacketRate[TargetIndex] = 0.0;
	AimPacketProgress[TargetIndex] = 0.0;
	
	for(i=TargetIndex; i<ArrayCount(CurrentAimPackets)-1; i++)
	{
		CurrentAimPackets[i] = CurrentAimPackets[i+1];
		AimPacketRate[i] = AimPacketRate[i+1];
		AimPacketProgress[i] = AimPacketProgress[i+1];
	}
}

function GP2AddRecoilPacket()
{
	local int SkillLevel;
	local float Recoil, FactoredRecoil, UseRecoilX, UseRecoilY;
	local Rotator TRot;
	
	SkillLevel = DeusExPlayer(Owner).SkillSystem.GetSkillLevel(GoverningSkill);
	Recoil = RecoilStrength + (VMDGetWeaponSkill("RECOIL") * RecoilStrength);
	FactoredRecoil = FMax(0.0, Recoil - (Recoil * (RecoilResetTimer / ShotTime) * RecoilDecayRate));
	UseRecoilX = (6144) * FactoredRecoil * VMDGetRecoilMultX() * 0.01;
	UseRecoilY = (6144) * FactoredRecoil * VMDGetRecoilMultY() * 0.01;
	
	TRot.Yaw = UseRecoilX * 0.06125;
	TRot.Pitch = UseRecoilY * 0.06125;
	
	if (!bZoomed)
	{
		GP2AddAimPacket(TRot, 1.0 / (ShotTime * 1.25 + (FRand() * RecoilRecoveryFactors[SkillLevel] * FactorWM2RecoilRecoveryMultiplier())), 0.0);
	}
	SwayExcitement += RecoilStrength * 0.33;
}

function GP2AimTick(float DT)
{
	local bool bSkillFocus;
	local int i, SkillLevel, OldSign, NewDir;
	local float TMult, TVel, TMath, TarExcitement, TarRate, TarStanding, TarDecayStanding, FocusMult, PlayerFocusMod, AccFactor, ScopeMod, Recoil, FactoredRecoil, SwerveFactor, BobFactors[2];
	local Rotator TRot, RollRot, DiffRot, ViewRot;
	local Vector TAimOff, TMove;
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(Owner);
	if (DXP != None)
	{
		if (DXP.InHand == Self)
		{
			//WCCC, 5/2/25: Start by fetching some things for reference.
			CurAnimSet = GP2GetAnimSet();
			SkillLevel = DXP.SkillSystem.GetSkillLevel(GoverningSkill);
			if (VMDBufferPlayer(Owner) != None)
			{
				PlayerFocusMod = VMDBufferPlayer(Owner).ConfigureVMDAimSpeed();
				TVel = VSize(Owner.Velocity) / VMDBufferPlayer(Owner).VMDConfigureGroundSpeed();
			}
			else
			{
				TVel = VSize(Owner.Velocity);
			}
			
			//WCCC, 5/2/25: Then, check our movement speed, to find what excitement rate fits best.
			//One should note, each movement speed has its own equilibrium point for aim.
			//That is to say, movement is not all-or-nothing now, you can move and shoot to a degree.
			if (CurAnimSet == 'Reloading')
			{
				TarExcitement = ExcitementTargetScalars[3];
				TarRate = ExcitementRateScalars[0];
			}
			else
			{
				if (TVel >= ExcitementRateThresholds[4])
				{
					TarExcitement = ExcitementTargetScalars[4];
					TarRate = ExcitementRateScalars[0];
				}
				else if (TVel >= ExcitementRateThresholds[3])
				{
					TarExcitement = ExcitementTargetScalars[3];
					TarRate = ExcitementRateScalars[0];
				}
				else if (TVel >= ExcitementRateThresholds[2])
				{
					TarExcitement = ExcitementTargetScalars[2];
					if (SwayExcitement > TarExcitement)
					{
						TarRate = ExcitementRateScalars[2];
					}
					else
					{
						TarRate = ExcitementRateScalars[1];
					}
				}
				else if (TVel >= ExcitementRateThresholds[1])
				{
					TarExcitement = ExcitementTargetScalars[1];
					if (SwayExcitement > TarExcitement)
					{
						TarRate = ExcitementRateScalars[1];
					}
					else
					{
						TarRate = ExcitementRateScalars[2];
					}
				}
				else
				{
					TarExcitement = ExcitementTargetScalars[0];
					TarRate = ExcitementRateScalars[0];
				}
			}
			
			SwayExcitement += TarRate * DT * Sign(TarExcitement - SwayExcitement);
			
			//WCCC, 5/2/25: Then, fetch how much we should be scaling our distance in/out from center.
			//Higher skill levels have less margin of error in holding, up to 60% less, in fact.
			//Scopes also improve this factor even further, just like in older VMD code.
			AccFactor = AccuracyFactorScalar;
			if (bZoomed)
			{
				ScopeMod = 3.0;
				switch(GoverningSkill)
				{
					case class'SkillWeaponPistol':
						if ((!VMDHasSkillAugment('PistolModding')) && (!Default.bHasScope))
						{
							ScopeMod = 1.75;
						}
						else if (VMDHasSkillAugment('PistolScope'))
						{
							ScopeMod *= 1.5;
						}
					break;
				}
				AccFactor /= ScopeMod;
			}
			
			//WCCC, 5/2/25: Focus mults are now much more complex, but we still receive a bonus from these talents.
			//These are various divisions of the bonuses of squares of higher numbers.
			//The benefit to rate is significantly reduced vs old VMD code at base.
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
					bSkillFocus = (VMDHasSkillAugment('PistolFocus'));
				break;
				case class'SkillWeaponRifle':
					bSkillFocus = (VMDHasSkillAugment('RifleFocus'));
				break;
				case class'SkillWeaponHeavy':
					bSkillFocus = (VMDHasSkillAugment('HeavyFocus'));
				break;
				default:
					bSkillFocus = True;
				break;
			}
			FocusMult = AimFocusMults[SkillLevel * (1 + int(bSkillFocus))] * FactorWM2FocusMultiplier() * FactorWM2UniversalFocusMultiplier();
			
			//WCCC, 5/2/25: Recoil works like Phase 2 recoil, of not being constant.
			//However, the twist is this is also scaling how crosshair blooms outwards.
			//Sway excitement also offsets this, since it scales aim return rate, and we want to do more than break even.
			Recoil = RecoilStrength + (VMDGetWeaponSkill("RECOIL") * RecoilStrength);
			FactoredRecoil = FMax(0.0, Recoil - (Recoil * (RecoilResetTimer / ShotTime) * RecoilDecayRate));
			if (CurAnimSet == 'Attacking')
			{
				StandingTimer = FMax(StandingTimer - (DT * FactoredRecoil * RecoilDecayMult * SwayExcitement * FocusMult), AimFocusRanges[0]);
			}
			
			//WCCC, 5/2/25: Move towards our target standing at the intended focus mult.
			//The lower our excitement, the higher our equilibrium point for aim.
			if (CurAnimSet == 'Reloading')
			{
				TarStanding = AimFocusRanges[0];
			}
			else
			{
				TarStanding = AimFocusRanges[1] - ((TarExcitement-1) * 3.0);
			}
			TarDecayStanding = FMax(0.0, TarStanding - 3.0);
			
			if (StandingTimer > TarStanding)
			{
				StandingTimer = FMax(TarStanding, StandingTimer - DT * SwayExcitement * FocusMult);
			}
			else if (StandingTimer < TarStanding)
			{
				StandingTimer = FMin(TarStanding, StandingTimer + DT * SwayExcitement * FocusMult);
			}
			
			//WCCC, 5/2/25: Easy stuff, just move us around in a circle, rate dependent on sway rate mult.
			//The distance out from the circle is shoved around by distance velocity.
			//Distance velocity is random, but only updated so often as to not be too jittery.
			//Trust me, this effect gets uncanny fast, so use a cooldown.
			SwayProgress = (SwayProgress + GP2GetSwayRateMult() * (1.0 + (VMDGetWoundAccuracyPenalty() * 6.0)) / PlayerFocusMod * FactorWM2SwayMultiplier() * DT) % 1.0;
			if (SwayDistanceTimer > 0)
			{
				SwayDistanceTimer -= DT;
			}
			else
			{
				//MADDERS, 6/3/25: Doing some fucky math. We can be aimed pretty far in or pretty far out, but on average we wander back to 0.35.
				//Fun twist: We can flip, and reverse pointing, but will still be weighted to come back to -0.35.
				SwayDistanceTimer = SwayDistanceCooldown;
				NewDir = 1 - (Rand(2) * 2);
				
				//Weight this movement to be reduced slightly
				if ((NewDir != Sign(DistanceVelocity)) == (Abs(SwayDistance) < 0.35) || (NewDir == Sign(DistanceVelocity)) == (Abs(SwayDistance) > 0.7))
				{
					TMath = FClamp(Abs(DistanceVelocity), 0.25, 0.75);
					DistanceVelocity += SwayDistanceRate / PlayerFocusMod * DT / (SwayExcitement * SwayExcitementScalar) * (TMath * ((1.0 + TMath) * 0.5)) * NewDir;
				}
				//Weight this movement to be increased slightly
				else
				{
					TMath = FClamp(Abs(DistanceVelocity), 0.25, 1.0);
					DistanceVelocity += SwayDistanceRate / PlayerFocusMod * DT / (SwayExcitement * SwayExcitementScalar) * Sqrt(TMath) * NewDir;
				}
				
				//And don't let us get too much momentum. Shit goes crazy.
				DistanceVelocity = FClamp(DistanceVelocity, -0.005, 0.005);
			}
			SwayDistance = FClamp(SwayDistance + DistanceVelocity, -1.0, 1.0);
			RollRot.Roll = 65536.0 * SwayProgress;
			
			//WCCC, 5/2/25: Final leg of work: Construct a pointer, using Z as our distance from center.
			//Then, spin it around according to our point in sway rotation we do on and off.
			//When it's all said and done, convert to a rotator as our base aim offset vs our owner's view point.
			TAimOff.X = 1.0;
			TAimOff.Z = CurrentAccuracy * SwayDistance * AccFactor;
			TAimOff = TAimOff >> RollRot;
			TRot = Rotator(TAimOff);
			
			//WCCC, 5/2/25: For recoil (and other possible packets?), add these up as they occur.
			//When rapid fired, we should have an elevation offset equilibrium that players can learn.
			//These are unique to each gun, like our recoil patterns themselves, adding a fun bit of skill.
			for (i=0; i<ArrayCount(CurrentAimPackets); i++)
			{
				if (AimPacketRate[i] > 0)
				{
					AimPacketProgress[i] += AimPacketRate[i] * DT;
					if (AimPacketProgress[i] >= 2.0)
					{
						GP2RemoveAimPacket(i);
					}
				}
				TMult = 1.0 - Abs(1.0 - AimPacketProgress[i]);
				TRot += CurrentAimPackets[i] * TMult;
			}
			
			ViewRot = DXP.ViewRotation;
			ViewRot.Roll = 0;
			if (ViewRot.Pitch <= 18000)
			{
				ViewRot.Pitch += 65536;
			}
			
			if (!bZoomed)
			{
				//WCCC, 5/23/25: Make our aim drag a bit, as per "swerve".
				//This tightens up we hit higher skill levels, occurring less, and recovering faster.
				//Things that lower sway tighten this up further. Things that raise sway expand this further.
				if (LastViewRotation != Rot(0,0,0))
				{
					DiffRot = (ViewRot - LastViewRotation) / DT;
					
					SwerveFactor = SwerveRecoveryFactors[SkillLevel] / Sqrt(Mass);
					if (Abs(DiffRot.Yaw) > SwerveFactor*0.104 || Abs(DiffRot.Pitch) > SwerveFactor*0.104)
					{
						StandingTimer = FMax(FMin(StandingTimer, TarDecayStanding), StandingTimer - Sqrt(Abs(DiffRot.Yaw) + Abs(DiffRot.Pitch)) * 0.035 * DT);
						CurSwervePacket -= (DiffRot * GP2GetSwayRateMult() / PlayerFocusMod * FactorWM2SwayMultiplier() * DT);
						SwerveYawMomentum = SwerveFactor * 0.5;
						SwervePitchMomentum = SwerveFactor * 0.5;
					}
					else
					{
						SwerveYawMomentum += SwerveFactor * DT * 2.5;
						SwervePitchMomentum += SwerveFactor * DT * 2.5;
					}
					
					OldSign = Sign(CurSwervePacket.Yaw);
					CurSwervePacket.Yaw = OldSign * (Abs(CurSwervePacket.Yaw) - SwerveYawMomentum * DT);
					if (Sign(CurSwervePacket.Yaw) != OldSign)
					{
						CurSwervePacket.Yaw = 0;
					}
					else if (Abs(CurSwervePacket.Yaw) > 3072)
					{
						CurSwervePacket.Yaw = OldSign * 3072;
					}
					
					OldSign = Sign(CurSwervePacket.Pitch);
					CurSwervePacket.Pitch = OldSign * (Abs(CurSwervePacket.Pitch) - SwervePitchMomentum * DT);
					if (Sign(CurSwervePacket.Pitch) != OldSign)
					{
						CurSwervePacket.Pitch = 0;
					}
					else if (Abs(CurSwervePacket.Pitch) > 3072)
					{
						CurSwervePacket.Pitch = OldSign * 3072;
					}
				}
				TRot += CurSwervePacket;
				
				//WCCC, 5/23/25: Make our aim bob a bit as we move. Direction changes everything.
				//As skill increases, dampen this down, first on its secondary axis, then on its primary axis.
				TMove = Normal(DXP.Velocity << DXP.Rotation);
				if (BobPacketProgress <= 0.0)
				{
					//Scale bob by our targeted excitement, so slower footsteps fuck things up less.
					//At 0.33 * 4.0 at most, that's 133% bob at full sprint.
					BobFactors[0] = PrimaryBobFactors[SkillLevel] * 0.33 * TarExcitement;
					BobFactors[1] = SecondaryBobFactors[SkillLevel] * 0.33 * TarExcitement;
					
					//MADDERS, 5/23/25: Crouch walk is very slow, and abnormally disruptive for a pro-aiming state.
					//As a result, nerf the shit out of bob when crouched.
					if (DXP.AnimSequence == 'CrouchWalk')
					{
						BobFactors[0] *= 0.33;
						BobFactors[1] *= 0.33;
					}
					
					//On 50/50 split (Sqrt of 0.5), let X win out.
					if (TMove.X > 0.706)
					{
						CurBobPacket.Pitch += BobFactors[0];
						CurBobPacket.Yaw += ((Rand(2) * 2) - 1) * BobFactors[1];
					}
					else if (TMove.X < -0.706)
					{
						CurBobPacket.Pitch -= BobFactors[0];
						CurBobPacket.Yaw -= ((Rand(2) * 2) - 1) * BobFactors[1];
					}
					
					if (TMove.Y > 0.708)
					{
						CurBobPacket.Yaw -= BobFactors[0] * 2;
						CurBobPacket.Pitch -= ((Rand(2) * 2) - 1) * BobFactors[1] * 0.5;
					}
					else if (TMove.Y < -0.708)
					{
						CurBobPacket.Yaw += BobFactors[0] * 2;
						CurBobPacket.Pitch += ((Rand(2) * 2) - 1) * BobFactors[1] * 0.5;
					}
				}
				
				switch(DXP.AnimSequence)
				{
					case 'Run':
					case 'Run2h':
						BobPacketProgress += DXP.AnimRate * DT * 2.0 * (18.0 / 10.0);
					break;
					case 'Walk':
					case 'Walk2h':
						BobPacketProgress += DXP.AnimRate * DT * 2.0 * (10.0 / 10.0);
					break;
					case 'CrouchWalk':
						BobPacketProgress += DXP.AnimRate * DT * 2.0 * (5.0 / 9.0);
					break;
					default:
						BobPacketProgress += 1.0 * DT * 4.0;
					break;
				}
				
				if (BobPacketProgress >= 2.0)
				{
					BobPacketProgress = 0.0;
					CurBobPacket = Rot(0,0,0);
				}
				TMult = 1.0 - Abs(1.0 - BobPacketProgress);
				TRot += CurBobPacket * TMult;
			}
			
			//WCCC, 5/2/25: At long last, we won.
			CurrentAimOffset = TRot;
		}
		//WCCC, 5/2/25: If not in hand, reset our aim to be super shitty to start.
		//However, our high excitement means the first part of aim closes much quicker.
		//Also, reset distance velocity because it can get fucky if ran too long.
		else
		{
			StandingTimer = AimFocusRanges[0];
			SwayExcitement = ExcitementTargetScalars[ArrayCount(ExcitementTargetScalars)-1];
			SwayDistance = 0.5;
			DistanceVelocity = 0.0;
		}
		
		LastViewRotation = ViewRot;
		if (VSize(DXP.Velocity) > 3)
		{
			LastMoveNormal = Normal(DXP.Velocity << DXP.Rotation);
		}
		else
		{
			LastMoveNormal = Vect(0,0,0);
		}
	}
	else
	{
		LastViewRotation = Rot(0,0,0);
		CurBobPacket = Rot(0,0,0);
		BobPacketProgress = 0.0;
	}
}

function bool VMDHasAugOwner()
{
	local DeusExPlayer DXP;
	local VMDBufferPawn VMBP;
	
	DXP = DeusExPlayer(Owner);
	if ((DXP != None) && (VMDBufferAugmentationManager(DXP.AugmentationSystem) != None))
	{
		return true;
	}
	
	VMBP = VMDBufferPawn(Owner);
	if ((VMBP != None) && (VMBP.AugmentationSystem != None))
	{
		return true;
	}
	
	return false;
}

//MADDERS, 8/29/23: Sometimes our allies don't understand what's going on very well. Use this to send some shit out.
function VMDUseAIEventSender(Pawn NewInstigator, Name NewName, EAIEventType NewType, float NewVolume, float NewRadius)
{
	local VMDAIEventSender TSend;
	
	if (NewInstigator == None) return;
	
	if ((ScriptedPawn(Owner) != None) && (ScriptedPawn(Owner).GetAllianceType('Player') > 1))
	{
		TSend = Spawn(class'VMDAIEventSender');
		if (TSend != None)
		{
			TSend.LoadEvent(NewInstigator, NewName, NewType, NewVolume, NewRadius);
			TSend.SendEvent();
		}
	}
}

//MADDERS, 8/8/23: Drop objection framework. For when you have stuff you don't want to be yeeted at bad times.
function bool VMDHasDropObjection()
{
	return false;
}

// MADDERS, 8/7/23: Turn off bBlockActors because it results in item clogging. Setting this in DeusExCarcass isn't nice, and also doesn't stop player exploits.
function BecomePickup()
{
	Super.BecomePickup();
	
	if (bCorpseUnclog)
	{
		SetCollision(True, False, False);
	}
}

function BecomeItem()
{
	Super.BecomeItem();
	
	bOwned = false;
	bSuperOwned = false;
	bCorpseUnclog = false;
}

function int GetHandType(optional int OverrideHand)
{
	local int Ret;
	local DeusExPlayer DXP;
	local VMDBufferPlayer VMP;
	
	DXP = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Owner);
	
	Ret = -1;
	if (OverrideHand != 0) Ret = OverrideHand;
	
	if (DXP != None)
	{
		if (OverrideHand == 0)
		{
			Ret = DXP.Handedness;
		}
		if ((Ret == 1) && (LeftPlayerViewMesh == None))
		{
			Ret = -1;
		}
		
		if (VMP != None)
		{
			if ((LeftPlayerViewMesh != None) && (Ret == -1) && (VMP.HealthArmRight < 1) && (VMP.HealthArmLeft > 0) && (VMP.VMDDoAdvancedLimbDamage()))
			{
				Ret = 1;
			}
			else if ((PlayerViewMesh != None) && (Ret == 1) && (VMP.HealthArmLeft < 1) && (VMP.HealthArmRight > 0) && (VMP.VMDDoAdvancedLimbDamage()))
			{
				Ret = -1;
			}
		}
	}
	
	return Ret;
}

// set which hand is holding weapon
simulated function setHand( float Hand )
{
	local int THand;
	
	if (VMDBufferPlayer(Owner) != None) VMDBufferPlayer(Owner).GetHandednessPlayerMesh(THand);
	THand = GetHandType(THand);
	Hand = THand;
	
	if ( Hand == 2 )
	{
		PlayerViewOffset.Y = 0;
		FireOffset.Y = 0;
		bHideWeapon = true;
		return;
	}
	else
		bHideWeapon = false;
	
	if ( Hand == 0 )
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X * 0.88;
		PlayerViewOffset.Y = -0.2 * Default.PlayerViewOffset.Y;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z * 1.12;
	}
	else
	{
		PlayerViewOffset.X = Default.PlayerViewOffset.X;
		PlayerViewOffset.Y = Default.PlayerViewOffset.Y * Hand;
		PlayerViewOffset.Z = Default.PlayerViewOffset.Z;
	}
	PlayerViewOffset *= 100; //scale since network passes vector components as ints
	FireOffset.Y = Default.FireOffset.Y * Hand;
}

function bool VMDFakeSuperHandlePickupQuery( inventory Item )
{
	local int OldAmmo;
	local Pawn P;

	if (Item.Class == Class)
	{
		if ((Weapon(item).bWeaponStay) && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut))
		{
			return true;
		}
		P = Pawn(Owner);
		if (Level.Game.LocalLog != None)
		{
			Level.Game.LocalLog.LogPickup(Item, Pawn(Owner));
		}
		if (Level.Game.WorldLog != None)
		{
			Level.Game.WorldLog.LogPickup(Item, Pawn(Owner));
		}
		if (Item.PickupMessageClass == None)
		{
			// DEUS_EX CNN - use the itemArticle and itemName
			if (bNameCaseSensitive)
			{
				P.ClientMessage(Item.PickupMessage @ Item.ItemArticle @ Item.ItemName, 'Pickup');
			}
			else
			{
				P.ClientMessage(Item.PickupMessage @ Item.ItemArticle @ class'VMDStaticFunctions'.Static.VMDLower(Item.ItemName), 'Pickup');
			}
		}
		else
		{
			P.ReceiveLocalizedMessage( Item.PickupMessageClass, 0, None, None, item.Class );
		}
		Item.PlaySound(Item.PickupSound);
		Item.SetRespawn();
		return true;
	}
	if (Inventory == None)
	{
		return false;
	}
	
	return Inventory.HandlePickupQuery(Item);
}

function Frob(Actor Other, Inventory FrobWith)
{
	Super.Frob(Other, FrobWith);	
}

auto state Pickup
{
	function BeginState()
	{
		// alert NPCs that I'm putting away my gun
		AIEndEvent('WeaponDrawn', EAITYPE_Visual);
		
		Super.BeginState();
	}
	
	// changed from Touch to Frob - DEUS_EX CNN
	function Frob(Actor Other, Inventory frobWith)
	{
		if (bDeleteMe) return;
		
		// If touched by a player pawn, let him pick this up.
		if(ValidTouch(Other))
		{
			if (Level.Game.LocalLog != None)
			{
				Level.Game.LocalLog.LogPickup(Self, Pawn(Other));
			}
			if (Level.Game.WorldLog != None)
			{
				Level.Game.WorldLog.LogPickup(Self, Pawn(Other));
			}
			SpawnCopy(Pawn(Other));
			if (PickupMessageClass == None)
			{
				// DEUS_EX CNN - use the itemArticle and itemName
				if (bNameCaseSensitive)
				{
					Pawn(Other).ClientMessage(PickupMessage @ itemArticle @ itemName, 'Pickup');
				}
				else
				{
					Pawn(Other).ClientMessage(PickupMessage @ itemArticle @ class'VMDStaticFunctions'.Static.VMDLower(itemName), 'Pickup');
				}
			}
			else
			{
				Pawn(Other).ReceiveLocalizedMessage(PickupMessageClass, 0, None, None, Self.Class);
			}
			PlaySound (PickupSound);		
			if (Level.Game.Difficulty > 1)
			{
				Other.MakeNoise(0.1 * Level.Game.Difficulty);
			}
			if (Pawn(Other).MoveTarget == self)
			{
				Pawn(Other).MoveTimer = -1.0;
			}
		}
		else if ((bTossedOut) && (Other.Class == Class) && (Inventory(Other).bTossedOut))
		{
			Destroy();
		}
		
		//MADDERS, 10/26/22: Post-engine stuff.
		SetPhysics(PHYS_Interpolating);
		Velocity = vect(0,0,0);	// Prevent items with momentum from falling out of world.
	}
	
	// Landed on ground.
	function Landed(Vector HitNormal)
	{
		local Vector HN, HL, TS, TE, Size;
		local Actor O;
		local name TG;
		
		//MADDERS: Make us gain dirt from being dropped.
		TS = Location;
		TE = Location + (vect(0,0,2) * CollisionHeight);
		Size = vect(0,0,2) * CollisionHeight;
		Size = Size + (vect(2,2,0) * CollisionRadius);
		O = Trace(HL, HN, TE, TS, false, Size);
		TG = GetWallMaterial(HL, HN);
		switch(TG)
		{
			case 'Earth':
			case 'Foliage':
				VMDIncreaseGrimeLevel(150);
			break;
			default:
				VMDIncreaseGrimeLevel(50);				
			break;
		}
		
		Super.Landed(HitNormal);
	}
}

function bool VMDGetSilencer()
{
	local bool Ret;
	
	Ret = bHasSilencer;
	if (AmmoType != None)
	{
		switch(AmmoType.Class.Name)
		{
			//These ammos negate silencers.
			case 'Ammo10mmHEAT':
			case 'Ammo3006AP':
			case 'Ammo3006HEAT':
				Ret = false;
			break;
			default:
			break;
		}
	}
	
	return Ret;
}

function string VMDGetItemName()
{
	if ((!VMDIsMeleeWeapon()) && (PickupAmmoCount > 0) && (Pawn(Owner) == None))
	{
		return ItemName@"("$PickupAmmoCount$")";
	}
	else
	{
		return ItemName;
	}
}

function bool VMDDropFrom(vector StartLocation, optional bool bTest)
{
	if (!SetLocation(StartLocation))
	{
		return false;
	}
	
	if (!bTest)
	{
		DropFrom(StartLocation);
	}
	return true;
}

//MADDERS, 6/10/22: For pre travel stuff on inv items. Yucky.
function VMDPreTravel();

function VMDPlayTranqFailNoise()
{
	if (Pawn(Owner) != None)
	{
		Pawn(Owner).PlaySound(Sound'BatonHitHard', SLOT_Interface, 1.0,,, 0.7);
		Pawn(Owner).PlaySound(Sound'BatonHitHard', SLOT_Interact, 1.0,,, 0.7);
	}
}

function bool VMDHasJankyAmmo()
{
	if (ReloadCount == 0) return true;
	if ((bHandToHand) && (AmmoName != None)) return true;
	if (Default.AmmoName != None)
	{
		if (Default.AmmoName.Default.Mesh == LODMesh'TestBox' || Default.AmmoName.Default.PickupViewMesh == LODMesh'TestBox') return true;
		if (Default.AmmoName.Default.ItemName ~= "DEFAULT AMMO NAME - REPORT THIS AS A BUG") return true;
	}
	
	return false;
}

function bool VMDIsTwoHandedWeapon()
{
	if (Mass >= 30)
	{
		return true;
	}
	return false;
}

function VMDDebugTilt(float DT)
{
 	local DeusExPlayer Player;
 	local HUDMissionStartTextDisplay HUD;
 	local string Message;
 	
 	if (!bDebugTilt) return;
	
	Player = DeusExPlayer(Owner);
 	if (Player == None || Player.InHand != Self) return; 
 	TiltAddTime += DT;
 	
 	if (TiltAddTime % 0.10 > 0.025) return;
 	Message = Mid(String(AnimFrame), 2+int(AnimFrame<0), 3);
 	
  	if ((DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
  	{
    		HUD = DeusExRootWindow(Player.RootWindow).HUD.startDisplay;
  	}
  	if (HUD != None)
  	{
    		HUD.shadowDist = 0;
    		HUD.Message = "";
    		HUD.charIndex = 0;
    		HUD.winText.SetText("");
    		HUD.winTextShadow.SetText("");
    		HUD.displayTime = 3.00;
    		HUD.perCharDelay = 0.00;
    		HUD.AddMessage(Message);
    		HUD.StartMessage();
  	}
}

//Update our tilts!
simulated function VMDUpdateTiltEffects(float DT)
{
	local float TAF, UVM, UVM2, TXChunk, TYChunk;
	local int UseIndex, NumIndices, i;
	local vector UseVec, UseVec2;
	local int TPitch;
 	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	
 	if (VMP == None || !VMP.bAllowTiltEffects) return;
	
 	if (Level.Netmode == NM_Standalone) VMDDebugTilt(DT);
 	
 	UVM = 0.10;
 	UVM2 = 0.05;
 	
 	UseIndex = -1;
 	switch(AnimSequence)
 	{
  		//010101010101010101010101010101
  		//RELOAD TILT!
  		//010101010101010101010101010101
  		case 'ReloadBegin':
   			NumIndices = ReloadBeginTiltIndices;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > ReloadBeginTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = ReloadBeginTilt[UseIndex];
  		break;
  		case 'ReloadBeginEmpty':
   			NumIndices = ReloadBeginEmptyTiltIndices;
   			if (NumIndices < 1)
   			{
    				NumIndices = ReloadBeginTiltIndices;
    				if (NumIndices < 1) return;
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > ReloadBeginTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = ReloadBeginTilt[UseIndex];
   			}
   			else
   			{
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > ReloadBeginEmptyTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = ReloadBeginEmptyTilt[UseIndex];
   			}
  		break;
  		case 'Reload':
   			NumIndices = ReloadTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > ReloadTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = ReloadTilt[UseIndex];
  		break;
  		case 'ReloadEmpty':
   			NumIndices = ReloadEmptyTiltIndices;
   			if (NumIndices < 1)
   			{
    				NumIndices = ReloadTiltIndices;
    				if (NumIndices < 1) return;
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > ReloadTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = ReloadTilt[UseIndex];
   			}
   			else
   			{
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > ReloadEmptyTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = ReloadEmptyTilt[UseIndex];
   			}
  		break;
  		case 'ReloadEnd':
   			NumIndices = ReloadEndTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > ReloadEndTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = ReloadEndTilt[UseIndex];
  		break;
  		case 'ReloadEndEmpty':
   			NumIndices = ReloadEndEmptyTiltIndices;
   			if (NumIndices < 1)
   			{
    				NumIndices = ReloadEndTiltIndices;
    				if (NumIndices < 1) return;
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > ReloadEndTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = ReloadEndTilt[UseIndex];
   			}
   			else
   			{
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > ReloadEndEmptyTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = ReloadEndEmptyTilt[UseIndex];
   			}
  		break;
  		//020202020202020202020202020202
  		//SELECT/DOWN TILT!
  		//020202020202020202020202020202
  		case 'Select':
   			NumIndices = SelectTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > SelectTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = SelectTilt[UseIndex];
  		break;
  		case 'SelectEmpty':
   			NumIndices = SelectEmptyTiltIndices;
   			if (NumIndices < 1)
   			{
    				NumIndices = SelectTiltIndices;
    				if (NumIndices < 1) return;
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > SelectTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = SelectTilt[UseIndex];
   			}
   			else
   			{
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > SelectEmptyTiltTimer[i])
     					{
     						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = SelectEmptyTilt[UseIndex];
   			}
  		break;
  		case 'Down':
   			NumIndices = DownTiltIndices;
   			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > DownTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = DownTilt[UseIndex];
  		break;
  		case 'DownEmpty':
   			NumIndices = DownEmptyTiltIndices;
   			if (NumIndices < 1)
   			{
    				NumIndices = DownTiltIndices;
    				if (NumIndices < 1) return;
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > DownTiltTimer[i])
     					{
     						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = DownTilt[UseIndex];
   			}
   			else
   			{
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > DownEmptyTiltTimer[i])
     					{
      						UseIndex = i;
     					}
    				}
    				if (UseIndex > -1) UseVec = DownEmptyTilt[UseIndex];
   			}
  		break;
  		//030303030303030303030303030303
  		//SHOOT TILT! Use only on pump action guns, as it stands.
  		//030303030303030303030303030303
  		case 'Shoot':
  		case 'ShootEmpty':
			//MADDERS, 6/2/25: Don't use tilt sequences during shooting in GP2.0. It feels weird.
			if (!ShouldUseGP2() || bZoomed)
			{
 	  			NumIndices = ShootTiltIndices;
 	  			if (NumIndices < 1) return;
 	  			for (i=0; i<NumIndices; i++)
   				{
   	 				if (AnimFrame > ShootTiltTimer[i])
    				{
   	  					UseIndex = i;
   	 				}
   				}
   				if (UseIndex > -1) UseVec = ShootTilt[UseIndex];
			}
  		break;
  		//040404040404040404040404040404
  		//MELEE TILT!
  		//040404040404040404040404040404
  		case 'Attack':
   			NumIndices = MeleeSwing1TiltIndices;
  			if (NumIndices < 1) return;
   			for (i=0; i<NumIndices; i++)
   			{
    				if (AnimFrame > MeleeSwing1TiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec = MeleeSwing1Tilt[UseIndex];
  		break;
  		case 'Attack2':
   			NumIndices = MeleeSwing2TiltIndices;
			if (NumIndices < 1)
			{
				NumIndices = MeleeSwing1TiltIndices;
   				if (NumIndices < 1) return;
				
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > MeleeSwing1TiltTimer[i])
     					{
     						UseIndex = i;
     					}
    				}
	   			if (UseIndex > -1) UseVec = MeleeSwing1Tilt[UseIndex];
			}
			else
			{
   				for (i=0; i<NumIndices; i++)
   				{
    					if (AnimFrame > MeleeSwing2TiltTimer[i])
    					{
     						UseIndex = i;
    					}
   				}
	   			if (UseIndex > -1) UseVec = MeleeSwing2Tilt[UseIndex];
			}
  		break;
  		case 'Attack3':
   			NumIndices = MeleeSwing3TiltIndices;
			if (NumIndices < 1)
			{
				NumIndices = MeleeSwing1TiltIndices;
   				if (NumIndices < 1) return;
				
    				for (i=0; i<NumIndices; i++)
    				{
     					if (AnimFrame > MeleeSwing1TiltTimer[i])
     					{
     						UseIndex = i;
     					}
    				}
	   			if (UseIndex > -1) UseVec = MeleeSwing1Tilt[UseIndex];
			}
			else
			{
   				for (i=0; i<NumIndices; i++)
   				{
    					if (AnimFrame > MeleeSwing3TiltTimer[i])
    					{
     						UseIndex = i;
    					}
   				}
	   			if (UseIndex > -1) UseVec = MeleeSwing3Tilt[UseIndex];
			}
  		break;
	}
	//050505050505050505050505050505
 	//ADS TILT!
 	//050505050505050505050505050505
	/*
 	if (ADSTimer > 0.0)
 	{
  		if (bADS)
  		{
   			NumIndices = SightInTiltIndices;
   			if (NumIndices < 1) return; 
   			for (i=0; i<NumIndices; i++)
   			{
    				if ((ADSTime - ADSTimer) > SightInTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec2 = SightInTilt[UseIndex];
  		}
  		else
  		{
   			NumIndices = SightOutTiltIndices;
   			if (NumIndices < 1) return; 
   			for (i=0; i<NumIndices; i++)
   			{
    				if ((ADSTime - ADSTimer) > SightOutTiltTimer[i])
    				{
     					UseIndex = i;
    				}
   			}
   			if (UseIndex > -1) UseVec2 = SightOutTilt[UseIndex];
  		}
 	}*/
 	
 	if (UseIndex == -1) return;
 	
 	if (UseVec != vect(0,0,0))
 	{
		UseVec.X *= -1 * GetHandType();
		
  		TAF = AnimRate * DT;
  		UseVec = UseVec * TAF * UVM;
  		
		TXChunk = UseVec.X * 6144 * 0.01;
		TXChunk += VMP.TiltEffectYawFloat;
		VMP.TiltEffectYawFloat = TXChunk % 1.0;
		
  		VMP.ViewRotation.Yaw += int(TXChunk);
		
		TYChunk = UseVec.Y * 6144 * 0.01;
		TYChunk += VMP.TiltEffectPitchFloat;
		VMP.TiltEffectPitchFloat = TYChunk % 1.0;
		
  		TPitch = VMP.ViewRotation.Pitch + int(TYChunk);
  		if ((TPitch > 18000) && (TPitch < 32768)) TPitch = 18000;
		else if ((TPitch >= 32768) && (TPitch < 49152)) TPitch = 49152;
  		VMP.ViewRotation.Pitch = TPitch;
 	}
	
 	//NOTE: Do not use else. ADS and anims can co-exist, so stack it!
 	/*if (UseVec2 != vect(0,0,0))
 	{
  		TAF = DT / ADSTime;
  		UseVec2 = UseVec2 * TAF * UVM2;
  		
  		VMP.ViewRotation.Yaw += UseVec2.X * 6144 * 0.01;
  		
  		TPitch = VMP.ViewRotation.Pitch + UseVec2.Y * 6144 * 0.01;
  		if ((TPitch > 18000) && (TPitch < 32768)) TPitch = 18000;
		else if ((TPitch >= 32768) && (TPitch < 49152)) TPitch = 49152;
  		VMP.ViewRotation.Pitch = TPitch;
 	}*/
}

function int Sign(coerce float InValue)
{
	if (InValue > 0) return 1;
	else if (InValue < 0) return -1;
	
	return 0;
}

simulated function VMDScopeJump(int Situation)
{
	local Vector UseVec;
	local float UVM, TPitch;
	local PlayerPawn POwner;
	
	POwner = PlayerPawn(Owner);
	if (POwner == None) return;
	
	//0 = Zoom in
        //1 = Zoom more
        //2 = Zoom out
	
	if (Situation < 2)
	{
	 	UseVec = ZoomInTilt;
	 	if (Situation == 1) UseVec *= 0.256;
	}
	else
	{
	 	UseVec = ZoomOutTilt;
	}
	
	if (UseVec != Vect(0,0,0))
	{
		UseVec.X *= -1 * GetHandType();
		
	 	POwner.ViewRotation.Yaw += UseVec.X * (6144 * CurrentAccuracy) * 0.01;
	 	TPitch = POwner.ViewRotation.Pitch + (UseVec.Y * (6144 * CurrentAccuracy) * 0.01);
		
		if ((POwner.ViewRotation.Pitch > 18000) && (POwner.ViewRotation.Pitch < 32768))
		{
			TPitch = 18000;
		}
		else if ((TPitch >= 32768) && (TPitch < 49152))
		{
			TPitch = 49152;
		}
		POwner.ViewRotation.Pitch = TPitch;
	}
}

simulated function VMDToggleJump(int Situation)
{
	local Vector UseVec;
	local float UVM, TPitch;
	local PlayerPawn POwner;
	
	POwner = PlayerPawn(Owner);
	if (POwner == None) return;
	
	if (Situation == 0)
	{
		UseVec = Toggle2Tilt;
	}
	else
	{
	 	UseVec = ToggleTilt;
	}
	
	if (UseVec != Vect(0,0,0))
	{
		UseVec.X *= -1 * GetHandType();
		
	 	POwner.ViewRotation.Yaw += UseVec.X * (Rand(4096) + 4096) * 0.01;
	 	TPitch = POwner.ViewRotation.Pitch + UseVec.Y * (Rand(4096) + 4096) * 0.0;
		
		if ((POwner.ViewRotation.Pitch > 18000) && (POwner.ViewRotation.Pitch < 32768))
		{
			TPitch = 18000;
		}
		else if ((TPitch >= 32768) && (TPitch < 49152))
		{
			TPitch = 49152;
		}
		POwner.ViewRotation.Pitch = TPitch;
	}
}

function VMDIncreaseRecoilIndex()
{
	CurRecoilIndex++;
	
	if (CurRecoilIndex > (NumRecoilIndices-1)) CurRecoilIndex = 0;
	RecoilResetTimer = 0.0;
}

simulated function float VMDGetRecoilMultX()
{
 	local float ExtraMult, Ret;
 	
	if (CurRecoilIndex < 0) return 1.0;
	
 	ExtraMult = 1.0;
 	if (bZoomed) ExtraMult = UnivScopeRecoilMult;
 	Ret = RecoilIndices[CurRecoilIndex].X * ExtraMult;
	Ret *= -1 * GetHandType();
 	
 	return Ret;
}

simulated function float VMDGetRecoilMultY()
{
 	local float ExtraMult, Ret;
	
	if (CurRecoilIndex < 0) return 1.0;
	
 	ExtraMult = 1.0;
 	if (bZoomed) ExtraMult = UnivScopeRecoilMult;
 	Ret = RecoilIndices[CurRecoilIndex].Y * ExtraMult;
	
 	return Ret;
}

function SubstituteOnBelt()
{
	local DeusExRootWindow root;
	local int i;
	local Actor ThisWeaponClass;
	local Inventory ValidItem;
	
	if (DeusExPlayer(Owner) != None)
	{
		root = DeusExRootWindow(DeusExPlayer(Owner).rootWindow);
		
		if (root != None && bInObjectBelt && beltPos > 0)
		{
			foreach AllActors(Class, ThisWeaponClass)
			{
				if (ThisWeaponClass != Self && ThisWeaponClass.Owner == Owner && !Inventory(ThisWeaponClass).bInObjectBelt)
				{
					ValidItem = Inventory(ThisWeaponClass);
					
					if (ValidItem != None)
					{
						root.hud.belt.AddObjectToBelt(ValidItem, beltPos, False);
						break;
					}
				}
			}
		}
	}
}

function VMDDropEmptyMagazine(int THand);

function VMDScopeInFurther()
{
	if ((bHasScope) && (bZoomed) && (ZoomInCount == 0) && (Owner != None) && (Owner.IsA('DeusExPlayer')))
	{
		VMDScopeJump(1);
		ZoomInCount = 1;
		RefreshScopeDisplay(DeusExPlayer(Owner), False, bZoomed);
	}
}

function VMDWeaponPostBeginPlayHook()
{
	local int i;
	
	if (AmmoDamageMultiplier <= 0)
	{
		AmmoDamageMultiplier = 1.0;
	}
	if (GunModDamageMultiplier <= 0)
	{
		GunModDamageMultiplier = 1.0;
	}
	
	//MADDERS, 4/12/21: Nice try, Zodiac. You're not my real dad.
	if (IsA('WeaponC4'))
	{
		HandSkinIndex[0] = 255;
		HandSkinIndex[1] = 255;
		LeftPlayerViewMesh = None;
	}
	//MADDERS, 4/14/21: Next up: Rotating joshua with non-fucked ricochet/penetration interference
	else if (IsA('WeaponJoshua'))
	{
		bCanRotateInInventory = true;
		RotatedIcon = Texture'LargeIconJoshuaRotated';
		PenetrationHitDamage = 0;
		RicochetHitDamage = 0;
	}
	//MADDERS, 4/15/21: Next up: Rotating HC Laser
	else if (IsA('WeaponHCLaser'))
	{
		bCanRotateInInventory = true;
		RotatedIcon = Texture'LargeIconHCLaserRotated';
	}
	//This gun needs more reason to be used, at 4x2 in size.
	else if (IsA('WeaponA17') || IsA('WeaponAssault17'))
	{
		SemiautoFireSound = Sound'AssaultGunSemi';
		SilencedFireSound = Sound'AssaultGunFireSilenced';
		NumFiringModes = 2;
		FiringModes[0] = "Full Auto";
		FiringModes[1] = "Semi Auto";
		ModeNames[0] = "Full Auto";
		ModeNames[1] = "Semi Auto";
		PenetrationHitDamage = HitDamage;
		RicochetHitDamage = HitDamage;
		
		//MADDERS, 7/21/21: This gun blows so much ass we're gonna buff it with these stat tweaks.
		//2x the size? 2x the benefit of the assault gun in these fields.
     		AimDecayMult = 3.000000;
     		AimFocusMult = 1.500000;
		
		bCanRotateInInventory = true;
		RotatedIcon = Texture'LargeSGAssaultIconRotated';
		FiringSystemOperation = 1;
	}
	//M249 got nerfed into a wet noodle that takes up a garbage truck's space.
	else if (IsA('WeaponM249DXN') || IsA('WeaponPara17'))
	{
		ShotTime = 0.150000;
		NPCOverrideAnimRate = 0.65;
		OverrideAnimRate = 4.0;
		PenetrationHitDamage = HitDamage * 0.75;
		RicochetHitDamage = HitDamage * 0.35;
		bCanRotateInInventory = true;
		RotatedIcon = Texture'LargeSGParaIconRotated';
		FiringSystemOperation = 2;
	}
	//Pistol can't talk alt ammos or be used by drones. Fix that.
	else if (IsA('WeaponWaltherDXN') || IsA('WeaponBRGlock'))
	{
		bDroneCapableWeapon = true;
 		AmmoNames[0] = Class'Ammo10mm';
		AmmoNames[1] = Class'Ammo10mmGasCap';
		AmmoNames[2] = Class'Ammo10mmHEAT';
		if (Ammo10mmHEAT(AmmoType) != None)
		{
			HitDamage = Default.HitDamage;
	     		PenetrationHitDamage = HitDamage * 0.8;
	     		RicochetHitDamage = HitDamage * 0.0;
		}
		else if (Ammo10mmGasCap(AmmoType) != None)
		{
			HitDamage = Default.HitDamage * 0.75;
	     		PenetrationHitDamage = HitDamage * 0.0;
     			RicochetHitDamage = HitDamage * 1.0;
		}
		else
		{
			HitDamage = Default.HitDamage;
	     		PenetrationHitDamage = HitDamage * 0.6;
	     		RicochetHitDamage = HitDamage * 0.3;
		}
	}
	//8 damage assault gun? Are you on crack? How is this still unnerfed?
	else if (IsA('WeaponTakaraGun'))
	{
		AmmoNames[0] = class'Ammo762mm';
		NumFiringModes = 2;
		FiringModes[0] = "Full Auto";
		FiringModes[1] = "Semi Auto";
		ModeNames[0] = "Full Auto";
		ModeNames[1] = "Semi Auto";
		NPCOverrideAnimRate = 0.66;
		OverrideAnimRate = 1.75;
		
		BulletHoleSize = 0.175;
		SemiautoFireSound = Sound'AssaultGunSemi';
		SilencedFireSound = Sound'AssaultGunFireSilenced';
		maxRange = 9600;
		AccurateRange = 2400;
		AimDecayMult = 4.0;
		AimFocusMult = 1.25;
    		FiringSystemOperation = 1;
		HitDamage = 5;
    		PenetrationHitDamage = HitDamage * 0.8;
    		RicochetHitDamage = HitDamage * 0.4;
		
		BoltStartSound = Sound'SawedOffShotgunReload';
		BoltEndSound = Sound'RifleReloadEnd';
		BoltActionDelay = 1.200000;
		BoltStartSeq = 'ReloadBegin';
		BoltDelaySeq = 'Reload';
		BoltEndSeq = 'ReloadEnd';
		BoltActionRate = 1.250000;
	}
}

function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly);

//MADDERS: Configure our damage reduction!
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	return 1.0;
}

//MADDERS, 1/14/21: Update stats from scratch, which is much needed in some regards.
function VMDUpdateWeaponModStats()
{
	local int IDiff;
	local float FDiff;
	
	//1111111111111111111111111
	//ACCURACY
	if (ModBaseAccuracy > 0.0)
	{
		FDiff = (Default.BaseAccuracy * ModBaseAccuracy);
		BaseAccuracy = Default.BaseAccuracy - FDiff;
	}
	
	//2222222222222222222222222
	//RELOAD COUNT
	if (ModReloadCount > 0.0)
	{
		IDiff = Float(Default.ReloadCount) * 0.1;
		if (IDiff < 1) IDiff = 1;
		
		ReloadCount = Default.ReloadCount + (IDiff * (ModReloadCount / 0.1));
	}
	
	//3333333333333333333333333
	//RANGE
	if (ModAccurateRange > 0.0)
	{		
		FDiff = (Default.RelativeRange * ModAccurateRange);
		RelativeRange = Default.RelativeRange + FDiff;
		
		FDiff = (Default.AccurateRange * ModAccurateRange);
		AccurateRange = Default.AccurateRange + FDiff;
		
		FDiff = (Default.FalloffStartRange * ModAccurateRange);
		FalloffStartRange = Default.FalloffStartRange + FDiff;
	}
	
	//4444444444444444444444444
	//RELOAD
	if (ModReloadTime < 0)
	{
		ReloadTime = Default.ReloadTime + (Default.ReloadTime * ModReloadTime);
	}
	
	//5555555555555555555555555
	//RECOIL
	if (ModRecoilStrength < 0)
	{
		RecoilStrength = Default.RecoilStrength + (Default.RecoilStrength * ModRecoilStrength);
	}
}

//MADDERS, 1/10/21: For use in the LAW, primarily.
function VMDDestroyOnFinishHook()
{
	LaserOff();
	if (bZoomed) ScopeOff();
}

function bool VMDCanSwapSkinIndex(string Context, int Index)
{
	local bool FlagHandIndex, FlagCloakExIndex;
	
	if (SkinSwapException[Index] > 0) return false;
	if (Index == MuzzleFlashIndex) return false;
	
	Context = CAPS(Context);
	FlagCloakExIndex = (VMDIndexIsCloakException(Index));
	FlagHandIndex = (Index == HandSkinIndex[0] || Index == HandSkinIndex[1]);
	
	switch(Context)
	{
		case "MASKING":
			if (!FlagHandIndex) return true;
		break;
		case "CLOAK":
			if (!FlagCloakExIndex) return true;
		break;
		case "HAND":
		case "BLOOD":
			if (FlagHandIndex) return true;
		break;
		case "WATER":
			if (!FlagCloakExIndex) return true;
		break;
		case "GRIME":
			if ((!FlagCloakExIndex) && (!FlagHandIndex)) return true;
		break;
	}
		
	return false;
}

//MADDERS, 7/20/21: Check for nulls here first.
function bool VMDIsQuickswapAmmoFA(Ammo TestAmmo)
{
	if (TestAmmo == None) return false;
	
	return (VMDIsQuickswapAmmo(TestAmmo.Class));
}

//MADDERS, 7/20/21: Is this ammo quick swappable? Let us know.
function bool VMDIsQuickswapAmmo(class<Ammo> TestType)
{
	if (TestType == None) return false;
	
	switch(TestType.Name)
	{
		case 'Ammo20mm':
		case 'Ammo20mmEMP':
			if (IsA('WeaponAssault17') || IsA('WeaponA17'))
			{
				return false;
			}
			else
			{
				return true;
			}
		break;
		default:
			return false;
		break;
	}
}

//MADDERS: This function is garbage, but even in vanilla it should arguably have been a fucking return function. Blech.
function bool VMDShouldMakeTracers(bool bSecondaryStyle)
{
	local int NumSlugs;
	
	//MADDERS, 4/14/21: Exceptions time, bby.
	if (IsA('WeaponJoshua')) return false;
	
	if (VMDShouldForceTracer()) return true;
	
	//Copy/Pasted from TraceFire
	if (AreaOfEffect == AOE_Cone)
		numSlugs = 5;
	else
		numSlugs = 1;
	
	NumSlugs = VMDGetCorrectNumProj(NumSlugs);
	
	if ((!bHandToHand) && (bInstantHit) && (bPenetrating) && (VMDIsBallisticDamageType()))
	{
		if ((Level != None) && (Level.NetMode != NM_Standalone))
		{
			if ((Role == ROLE_Authority) && (NumSlugs == 1))
			{
				return true;
			}
		}
		else
		{
			return true;
			
			/*if (bSecondaryStyle)	
			{
				return true;
			}
			if ((numSlugs == 1) && (FRand() < 0.5))
			{
				return true;
			}*/
		}
	}
	
	return false;
}

function bool VMDIsBallisticDamageType(optional name DT)
{
	if (DT == '' || DT == 'None') DT = WeaponDamageType();
	
	if (DT == 'Shot' || DT == 'Sabot' || DT == 'Exploded' || DT == 'KnockedOut')
	{
		return true;
	}
	return false;
}

//MADDERS: In case of weird shit you want to do when do big shooty.
//Return false to stop the function from operating.
function bool VMDProjectileFireHook(class<Projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	return true;
}

function bool VMDTraceFireHook(float Accuracy)
{
	return true;
}

//Hatchet port: Fix the stuck up glitches around acquiring the same inv group twice.
function VMDFixInvGrouping()
{
	local Weapon W;
	local int k, NumRuns;
	
	local bool bOverdosed;
	
	if (Owner == None) return;
	if (!Owner.IsA('DeusExPlayer')) return;
	
	do
	{
		forEach AllActors(class'Weapon', W)
		{
			if (W == None) continue;
			if (W == Self || W.Owner == None) continue;
			if ((W != Self) && (DeusExPlayer(W.Owner) != None))
			{
				if (W.InventoryGroup == k)
				{
					k++;
					NumRuns = 0;
					
					if (k > 255) bOverdosed = True;
				}
			}
		}
		NumRuns++;
	}
	until (NumRuns == 2 || bOverdosed)
	
	InventoryGroup = k;
}

function GiveTo(Pawn Other)
{
	local actor A;
	
	foreach BasedActors(class'Actor', A)
	{
		if (A.Base == Self)
			A.SetBase(None);
	}
	
	Super.GiveTo(Other);
	
	//MADDERS, 12/29/20: Apply religiously.
	VMDFixInvGrouping();
	
	// Make the object follow us, for AmbientSound mainly
	if ((Owner != None) && (Level.NetMode == NM_Standalone))
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
	}
}

function bool VMDCustomModeHook()
{
	return false;
}

function bool VMDShouldForceTracer()
{
	if (Ammo10mmGasCap(AmmoType) != None) return true;
	
	return false;
}

//MADDERS: To configure your way out of gascaps, I guess. Why not?
function class<DeusExProjectile> VMDConfigureTracerClass(int RicNum, int PenNum)
{
	local int RicCap, PenCap;
	
	PenCap = 1;
	RicCap = VMDGetNumRicochets();
	
	if ((PenNum == PenCap) && (PenNum > 0) && (PenCap > 0))
	{
		return class'Tracer';
	}
	else if ((RicNum == RicCap) && (RicNum > 0) && (RicCap > 0))
	{
		if (Ammo10mmGasCap(AmmoType) != None) return class'TearGasTracer';
		return class'Tracer';
	}
	else if ((RicNum >= 0) && (PenNum >= 0))
	{
		return class'SniperTracer';
	}
	
	return class'SniperTracer';
}

function class<DeusExProjectile> VMDGetTracerEquivalent(Name TType, string Context)
{
	if (ScriptedPawn(Owner) != None)
	{
		return None;
	}
	
	Context = CAPS(Context);
	switch(Context)
	{
		case "OUTLINE":
			if (TType == 'Tracer' || TType == 'TracerSilver') return class'TracerOutline';
			if (TType == 'SniperTracer' || TType == 'SniperTracerSilver') return class'SniperTracerOutline';
		break;
		case "SILVER":
			if (TType == 'Tracer' || TType == 'TracerOutline') return class'TracerSilver';
			if (TType == 'SniperTracer' || TType == 'SniperTracerOutline') return class'SniperTracerSilver';
		break;
	}
	
	return None;
}

//MADDERS: So we know when we've been grabbed. Mod support. Yay.
function VMDSignalPickupUpdate()
{
}

//MADDERS: For mod support stuff. This saves us more state rewriting.
function VMDReloadCompleteHook()
{
}

//Grenade launcher related, and also for mod support.
function bool VMDHandleParallelAmmoFeed(class<Ammo> RelAmmoType, Ammo NewAmmo, int AmmoIndex)
{
	//Special case: Give hotswap to Takara's gun in Nihilum.
	if (IsA('WeaponTakaraGun'))
	{
		if ((ClipCount >= 0) && (VMDIsQuickSwapAmmo(RelAmmoType)))
		{
			//MADDERS: Hack for 20mm preservation.
			Last20mmCount = NewAmmo.AmmoAmount;
			ClipCount -= NewAmmo.AmmoAmount;
		}
		else if ((RelAmmoType == class'Ammo762mm') && (VMDIsQuickSwapAmmoFA(AmmoType)))
		{
			//MADDERS: Hack for denying cycle ammo during firing.
			if (VMDShotTimeProgression() < 1.0) return False;
			
			ClipCount += AmmoType.AmmoAmount;
		}
		
		return true;
	}
	
	//MADDERS: This shouldn't be called normally. See WeaponAssaultGun for examples.
	return false;
}

function bool VMDHasSelectiveFiringObjection()
{
	if (VMDIsQuickSwapAmmoFA(AmmoType)) return true;
	
	return false;
}

function bool VMDHasParallelAmmoFeed()
{
	//MADDERS, 3/1/25: Allow hot swap for nihilum.
	if (IsA('WeaponTakaraGun'))
	{
		return true;
	}
	
	//MADDERS: This shouldn't be called normally. See WeaponAssaultGun for examples.
	//20mm function overhaul is in there, so we're not fucking with that ick factor here.
	
	return false;
}

function bool VMDOwnerNotDead()
{
	if ((Owner != None) && (Owner.IsInState('Dying')))
	{
		return false;
	}
	return true;
}

function int VMDRoundOff(int In, int RoundTo)
{
	return In - (In%RoundTo);
}

function int VMDRoundUp(int In, float Mult)
{
	return int((float(In)+0.9999) * Mult);
}

function bool VMDIndexIsCloakException(int TestIndex)
{
	if (TestIndex == MuzzleFlashIndex) return true;
	return false;
}

function bool VMDOwnerIsCloaked()
{
	if (Owner == None) return false;
	if (VMDBufferPlayer(Owner) != None)
	{
		return VMDBufferPlayer(Owner).VMDPlayerIsCloaked();
	}
	else
	{
		if (Owner.Style == STY_Translucent) return true;
	}
	return false;
}

function bool VMDOwnerIsRadarTrans()
{
	if (VMDBufferPlayer(Owner) != None)
	{
		return VMDBufferPlayer(Owner).VMDPlayerIsRadarTrans();
	}
	
	return false;
}

function bool VMDHasOpenSystemMagBoost()
{
	if (FiringSystemOperation != 2) return false;
	
	if (VMDHasSkillAugment('TagTeamOpenChamber'))
	{
		return true;
	}
	
	return false;
}

function bool VMDCanPlaceMine()
{
	//MADDERS, 1/28/21: This now affects parameters of mine placement, not just mine placement in general.
	
	/*local DeusExLevelInfo DXLI;
	
	if (VMDBufferPlayer(Owner) == None) return true;
	if (VMDIsWeaponName("WeaponC4")) return true;
	
	//MADDERS: Limit mine placement without training.
	if (!VMDHasSkillAugment('DemolitionMines'))
	{
		//Don't fuck up training, either.
		forEach AllActors(class'DeusExLevelInfo', DXLI) break;
		if (DXLI == None || DXLI.MissionNumber > 0)
		{
			return false;
		}
	}*/
	return true;
}

function float VMDGetWeaponSkill(string SkillCat)
{
	local VMDBufferPawn VMBP;
	local VMDBufferPlayer player;
	local float Ret;
	local int GetLevel;
	local VMDBufferAugmentationManager VAM;
	local VMDNPCAugmentationManager NPCVAM;
	
	Ret = 1.0;
	if (Owner != None)
	{
		player = VMDBufferPlayer(Owner);
		VMBP = VMDBufferPawn(Owner);
		if (player != None)
		{
			VAM = (VMDBufferAugmentationManager(player.AugmentationSystem));
			if ((VAM != None) && (player.SkillSystem != None))
			{
				GetLevel = player.SkillSystem.GetSkillLevel(GoverningSkill);
				
				switch(CAPS(SkillCat))
				{
					case "DAMAGE":
						Ret = VAM.VMDConfigureWepDamageMult(Self);
						Ret -= player.SkillSystem.GetSkillLevelValue(GoverningSkill)*2;
					break;
					case "VELOCITY":
						Ret = VAM.VMDConfigureWepVelocityMult(Self);
						//Ret -= player.SkillSystem.GetSkillLevelValue(GoverningSkill);
					break;
					//MADDERS: Consult with augs, but nerf our values for accuracy.
					case "ACCURACY":
						Ret = VAM.VMDConfigureWepAccuracyMod(Self);
						Ret += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
						//MADDERS: Progression from acc went from:
						//0.1 > 0.25 > 0.5
						//to
						//0.1 > 0.2 > 0.4
						if (GetLevel == 2) Ret += 0.05;
						else if (GetLevel == 3) Ret += 0.1;
					break;
					//MADDERS: Neither consult with augs, nor nerf values for reload speed.
					case "RELOAD":
						Ret += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
					break;
					//MADDERS: Consult with augs, but don't nerf our values for recoil.
					case "RECOIL":
						Ret = VAM.VMDConfigureWepAccuracyMod(Self);
						Ret += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
					break;
				}
			}
			else if (Player.SkillSystem != None)
			{
				GetLevel = player.SkillSystem.GetSkillLevel(GoverningSkill);
				
				switch(CAPS(SkillCat))
				{
					case "DAMAGE":
						Ret -= player.SkillSystem.GetSkillLevelValue(GoverningSkill)*2;
					break;
					case "VELOCITY":
						Ret -= player.SkillSystem.GetSkillLevelValue(GoverningSkill);
					break;
					//MADDERS: Nerf the fuck out of added accuracy. We add focus rate, too, now.
					case "ACCURACY":
						Ret = player.SkillSystem.GetSkillLevelValue(GoverningSkill);
						//MADDERS: Progression from acc went from:
						//0.1 > 0.25 > 0.5
						//to
						//0.1 > 0.2 > 0.35
						if (GetLevel == 2) Ret += 0.05;
						else if (GetLevel == 3) Ret += 0.1;
					break;
					//MADDERS: Don't nerf values for reload speed.
					case "RELOAD":
						Ret += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
					break;
					//MADDERS: Don't nerf recoil, either.
					case "RECOIL":
						Ret += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
					break;
				}
			}
		}
		else if (VMBP != None)
		{
			NPCVAM = VMBP.AugmentationSystem;
			if (NPCVAM != None)
			{
				switch(CAPS(SkillCat))
				{
					case "DAMAGE":
						Ret = NPCVAM.VMDConfigureWepDamageMult(Self);
					break;
					case "VELOCITY":
						Ret = NPCVAM.VMDConfigureWepVelocityMult(Self);
					break;
					//MADDERS: Consult with augs, but nerf our values for accuracy.
					case "ACCURACY":
						Ret = NPCVAM.VMDConfigureWepAccuracyMod(Self);
					break;
					//MADDERS: Consult with augs, but don't nerf our values for recoil.
					case "RECOIL":
						Ret = NPCVAM.VMDConfigureWepAccuracyMod(Self);
					break;
				}
			}
		}
	}
	return Ret;
}

function bool VMDHasSkillAugment(Name S)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None)
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
	}
	if (VMP == None)
	{
		return class'VMDSkillAugmentManager'.Static.StaticSkillAugmentAssumed(S);
	}
	return VMP.HasSkillAugment(S);
}

function string VMDGetPlayerCampaign()
{
	if (VMDBufferPlayer(Owner) == None)
	{
		return "";
	}
	else
	{
		return VMDBufferPlayer(Owner).DatalinkID;
	}
}

function float VMDGetBruteForceThresh()
{
	local VMDBufferPlayer VMP;
	local int GetLevel;
	local float Ret;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None) return 0.0;
	
	if (!VMDHasSkillAugment('TagTeamDoorCrackingMetal')) return 0.0;
	
	if (VMP.SkillSystem != None)
	{
		GetLevel = Max(VMP.SkillSystem.GetSkillLevel(class'SkillWeaponLowTech'), VMP.SkillSystem.GetSkillLevel(class'SkillLockpicking'));
		Ret = 0.05 * (GetLevel+1);
	}
	
	//MADDERS, 4/12/21: Totally OP, even though it DOES require a specialization.
	//With specialization cost adjustments, this is no longer necessary as incentive.
	//if (VMDIsSpecializedInSkill(GoverningSkill)) Ret += 0.05;
	
	return Ret;
}

function bool VMDIsSpecializedInSkill(class<Skill> TestSkill)
{
	if (VMDBufferPlayer(Owner) == None) return false;
	return VMDBufferPlayer(Owner).IsSpecializedInSkill(TestSkill);
}

function bool VMDIsBulletWeapon()
{
	return ((!bHandToHand) && (bInstantHit) && (bPenetrating));
}

function bool VMDIsMeleeWeapon()
{
	return ((bHandToHand) && (bInstantHit));
}

function bool VMDIsGrenadeWeapon()
{
	return ((bHandToHand) && (!bInstantHit) && (class<ThrownProjectile>(ProjectileClass) != None) && (class<ThrownProjectile>(ProjectileClass).Default.bExplodes));
}

function VMDFireHook(optional float Value)
{
	local bool bAmmoEmpty;
	local int AddGrime;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	
	//MADDERS, 7/24/21: Set fire fudge here, so we know it's OK to sub ammo on projectile fire.
	bFireFudge = true;
	
	if (AmmoType == None) bAmmoEmpty = true;
	else if (AmmoType.AmmoAmount <= 0 || ClipCount >= ReloadCount) bAmmoEmpty = true;
	//MADDERS: Don't allow melee to give stress for being swung.
	if ((bAmmoEmpty) && (bHandToHand)) bAmmoEmpty = false;
	
	//MADDERS: Click, click!
	if ((bAmmoEmpty) && (VMP != None) && (VMP.bStressEnabled) && (VMP.musicMode == MUS_Combat))
	{
		VMP.VMDModPlayerStress(12, true, 4);	
	}
	
	if (!bAmmoEmpty)
	{
		AddGrime = 3.5;
		if (FiringSystemOperation > 0)
		{
			AddGrime += 3.5;
			//Check for assault gun firing on semi. Take it easy on 'em.
			if ((bSemiautoTrigger) && (Default.bAutomatic || Default.bBurstFire))
			{
				AddGrime -= 2.4;
			}
		}
		VMDIncreaseGrimeLevel(AddGrime);
	}
}

function bool VMDHasGrimeLevel()
{
	//MADDERS, 2/5/21: Grime is gone-zo. Bye-bye.
	return false;
	
	//MADDERS, 1/10/21: Stop doing this with non-players, although I doubt it's relevant.
	if (DeusExPlayer(Owner) == None) return false;
	
	if (FiringSystemOperation == 0) return false;
	if (bHandToHand) return false;
	if ((!bPenetrating) && (bInstantHit)) return false;
	//MADDERS: Our anims blow ass. Don't make PS20 gain grime.
	if (VMDIsWeaponName("HideaGun")) return false;
	
	return true;
}

//MADDERS: Tweaking of various gunk that builds up on our tools.
function VMDIncreaseGrimeLevel(float Add)
{
	if (!VMDHasGrimeLevel()) return;
	
	//Only allow decreasing of this crap if our setting is disabled.
	if ((VMDBufferPlayer(Owner) != None) && (!VMDBufferPlayer(Owner).bGrimeEnabled) && (Add > 0)) return;
	
	//MADDERS, 1/12/21: Scale grime addition rates when adding grime, not to be confused with all alterations to grime.
	if (Add > 0) Add *= GrimeRateMult;
	
	GrimeLevel = FClamp(GrimeLevel + Add, 0.0, 500.0);
}

function VMDIncreaseWaterLogLevel(float Add)
{	
	//MADDERS: Don't do a negative negative.
	if (Add > 0)
	{
		VMDIncreaseGrimeLevel(-30*Add);
	}
	
	//Only allow decreasing of this crap if our setting is disabled.
	if ((VMDBufferPlayer(Owner) != None) && (!VMDBufferPlayer(Owner).bGrimeEnabled) && (Add > 0)) return;
	
	WaterLogLevel = FClamp(WaterLogLevel + Add, 0.0, 15.0);
}

function int VMDGetGrimeLevel()
{
	local int Ret;
	
	//Only allow decreasing of this crap if our setting is disabled.
	if ((VMDBufferPlayer(Owner) != None) && (!VMDBufferPlayer(Owner).bGrimeEnabled)) return 0;
	
	if (GrimeLevel > 150) Ret = 1;
	if (GrimeLevel > 300) Ret = 2;
	
	return Ret;
}

function int VMDGetWaterLogLevel()
{
	local int Ret;
	
	//Only allow decreasing of this crap if our setting is disabled.
	if ((VMDBufferPlayer(Owner) != None) && (!VMDBufferPlayer(Owner).bGrimeEnabled)) return 0;
	
	//MADDERS: This looks like ass on melee weapons. JFC.
	if (bHandToHand) return 0;
	
	if (WaterLogLevel > 5) Ret = 1;
	if (WaterLogLevel > 10) Ret = 2;
	
	return Ret;
}

function VMDDecipherHandIndex()
{
	local bool FlagMeshMet;
	local int i, j;
	local Texture TTex;
	
	if (HandSkinIndex[0] < 255) return;
	
	HandSkinIndex[0] = 254;
	HandSkinIndex[1] = 254;
	if ((PlayerViewMesh != None) && (Mesh == PlayerViewMesh)) FlagMeshMet = true;
	if ((LeftPlayerViewMesh != None) && (Mesh == LeftPlayerViewMesh)) FlagMeshMet = true;
	
	if (FlagMeshMet)
	{
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
			TTex = GetMeshTexture(i);
			if (TTex == Texture'WeaponHandsTex' || TTex == Texture'MinicrossbowTex1')
			{
				if (j == 0) HandSkinIndex[0] = i;
				else if (j == 1) HandSkinIndex[1] = i;
				j++;
			}
		}
	}
}

//MADDERS: Scrub our grime off.
state CleanWeapon
{
	ignores Altfire;
	
	function ReloadAmmo();
	function CycleAmmo();
	
	function Fire( float F )
	{
		GoToState('CleanWeapon', 'ForceEnd');
	}
	
Begin:
	bLastShotJammed = false;
	//MADDERS: PS20 is janky AF for anims. Just do this.
	if (VMDIsWeaponName("HideAGun"))
	{
		PlayAnim('Shoot');
		FinishAnim();
		Owner.PlaySound(Sound'DeusExSounds.Weapons.StealthPistolReloadEnd', SLOT_None,,, 1024, VMDGetMiscPitch()*2);
		GrimeLevel = 0;
	}
	else
	{
		TweenAnim('Still', 0.1);
		if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
		{
			PlayAnim('ReloadBegin', 0.5, 0.1);
		}
		else
		{
			PlayAnim('ReloadBegin', 0.75, 0.1);
		}
		Owner.PlaySound(CockingSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// CockingSound is reloadbegin
		FinishAnim();
		do
		{
			if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
			{
				PlayAnim('Reload', 1.0, 0.1);
			}
			else
			{
				PlayAnim('Reload', 1.5, 0.1);
			}
			Owner.PlaySound(Sound'StealthPistolReloadEnd', SLOT_None,,, 1024, VMDGetMiscPitch()*1.5);
			FinishAnim();
			
			//MADDERS: Scale cleaning speed like you would with damage.
			GrimeLevel -= 40 * VMDGetWeaponSkill("Damage");
		}
		until (GrimeLevel <= 0);
		
		if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
		{
			PlayAnim('ReloadEnd', 0.84, 0.1);
		}
		else
		{
			PlayAnim('ReloadEnd', 1.25, 0.1);
		}
		Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
		FinishAnim();
	}
End:	
	TweenAnim('Still', 0.1);
	GoToState('Idle');

ForceEnd:
	if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
	{
		PlayAnim('ReloadEnd', 0.84, 0.1);
	}
	else
	{
		PlayAnim('ReloadEnd', 1.25, 0.1);
	}
	Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
	FinishAnim();
	TweenAnim('Still', 0.1);
	GoToState('Idle');
}

function int VMDOpenSpaceLevel(optional bool bPlayerRelevant)
{
	local Vector TStart, TEnds[14], HL, HN;
	local int Ret, i;
	
	if ((bPlayerRelevant) && (PlayerPawn(Owner) == None)) return 1;
	if (Owner == None) return 1;
	if (VMDGetSilencer() || bHandToHand || !bPenetrating) return -1;
	
	Ret = 1;
	TStart = Owner.Location;
	
	//COORD BARF: Cardinal directions.
	TEnds[0] = TStart + vect(3,0,0) * 64;
	TEnds[1] = TStart + vect(6,0,0) * 64;
	TEnds[2] = TStart - vect(3,0,0) * 64;
	TEnds[3] = TStart - vect(6,0,0) * 64;
	TEnds[4] = TStart + vect(0,3,0) * 64;
	TEnds[5] = TStart + vect(0,6,0) * 64;
	TEnds[6] = TStart - vect(0,3,0) * 64;
	TEnds[7] = TStart - vect(0,6,0) * 64;
	
	//Diagonal, and then vertical because fuck it. Why not?
	TEnds[8] = TStart + vect(6,6,0) * 64;
	TEnds[9] = TStart + vect(-6,6,0) * 64;
	TEnds[10] = TStart - vect(-6,-6,0) * 64;
	TEnds[11] = TStart - vect(6,-6,0) * 64;
	TEnds[12] = TStart + vect(0,0,2) * 64;
	TEnds[13] = TStart + vect(0,0,-2) * 64;
	
	for (i=0; i<14; i++)
	{
		if (FastTrace(TStart, TEnds[i])) Ret++;
	}
	
	return Ret;
}

function int VMDClosedSpaceLevel(optional bool bPlayerRelevant)
{
	if (VMDGetSilencer() || bHandToHand || !bPenetrating) return -1;
	
	return Clamp(18 - VMDOpenSpaceLevel(bPlayerRelevant), 1, 16);
}

function float VMDOpenSpaceRadiusMult()
{
	return FMax(1.0, Sqrt(Max(1, VMDOpenSpaceLevel())) / 2);
}

function VMDPlayRicochetSound(Vector HitLocation)
{
	Spawn(Class'VMDRicochetSoundMaker',,, HitLocation);
}

function int VMDGetNumRicochets()
{
 	local float Ret;
 	
 	if (!VMDIsBulletWeapon() || VMDGetRicochetDamage(None) <= 0) return 0;
	if (AmmoNone(AmmoType) != None) return 0;
	if (!VMDIsBallisticDamageType()) return 0;
	
  	Ret = VMDGetRicochetDamage(None) / 8.0;
  	Ret = int(Ret+1.0);
  	
  	if (Ammo10mmGasCap(AmmoType) != None)
  	{
   		Ret = 1;
  	}
	
 	return Ret;
}

function bool VMDAngleMeansRicochet(Vector HitLocation, Vector A, Vector B, name TexGroup, Actor Other)
{
	local int DomA, DomB; //X, Y, Z, 0-2;
	
	if (Other == None) return false;
	if (!VMDIsBulletWeapon()) return false;
	if (AmmoSabot(AmmoType) != None || Ammo3006AP(AmmoType) != None || Ammo3006HEAT(AmmoType) != None || Ammo10mmHEAT(AmmoType) != None) return false;
	if (VMDGetRicochetDamage(Other) <= 0 || VMDGetNumRicochets() == 0) return false;
	
	if (((DeusExDecoration(Other) != None) && (DeusExDecoration(Other).bInvincible)) || VMDOtherIsName(Other, "Camera") || VMDOtherIsName(Other, "Turret"))
	{
		return true;
	}
	
	//MADDERS note: This makes shots ricochet into the target a second time, due to the angle.
	//Don't do this as a result, as it does literally nothing.
	/*if ((VMDBufferPawn(Other) != None) && (VMDBufferPawn(Other).VMDHitArmor(int(VMDGetCorrectHitDamage(HitDamage), HitLocation, WeaponDamageType())))
	{
		return true;
	}*/
	if (Ammo10mmGasCap(AmmoType) != None)
	{
		return true;
	}
	//Always penetrate soft mats.
	switch(TexGroup)
	{
		case 'Wood':
		case 'Earth':
		case 'Foliage':
		case 'Paper':
			return false;
		break;
		//MADDERS, 1/15/21: Bullets bounce off of bulletproof glass.
		//MADDERS, 2/20/25: Removing this, since it confuses AI in some edge cases, making them waste all their ammo.
		case 'Glass':
			//if (Other == Level) return true;
			return false;
		break;
	}
	
	DomA = VMDDominantAxisOf(A);
	DomB = VMDDominantAxisOf(B);
	
	if (DomA == DomB) return false;
	return true;
}

function int VMDDominantAxisOf(Vector A)
{
	local int Ret;
	
	if ((Abs(A.X) >= Abs(A.Y)) && (Abs(A.X) >= Abs(A.Z))) Ret = 0;
	else if ((Abs(A.Y) >= Abs(A.X)) && (Abs(A.Y) >= Abs(A.Z))) Ret = 1;
	else if ((Abs(A.Z) >= Abs(A.X)) && (Abs(A.Z) >= Abs(A.Y))) Ret = 2;
	
	return Ret;
}

function vector VMDBastardizeNormal(Vector A, Vector B)
{
	//local int DomA, DomB; //X, Y, Z, 0-2;
	
	//MADDERS: Turns out some brave bastard already did this for me.
	//Holy shit, I'm so glad I don't have to rewrite trig all over again.
	return MirrorVectorByNormal(A, B);
	
	/*DomA = VMDDominantAxisOf(A);
	DomB = VMDDominantAxisOf(A);
	
	if (DomA == DomB) return false;
	return true;*/
}

//MADDERS: Ripped from animal shamelessly.
function bool VMDIsValidFood(Actor FoodActor)
{
	if (FoodActor == None)
		return false;
	else if (FoodActor.bDeleteMe)
		return false;
	else if (FoodActor.Region.Zone.bWaterZone)
		return false;
	else if ((FoodActor.Physics == PHYS_Swimming) || (FoodActor.Physics == PHYS_Falling))
		return false;
	else
		return true;
}

//MADDERS: Rotate items in inventory with this one weird trick
function Texture VMDConfigureLargeIcon()
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return RotatedIcon;
	}
	return LargeIcon;
}

function int VMDConfigureLargeIconWidth()
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return LargeIconHeight;
	}
 	return LargeIconWidth;
}

function int VMDConfigureLargeIconHeight()
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return LargeIconWidth;
	}
 	return LargeIconHeight;
}

//MADDERS: Setting up for scaleable inventory size. Yeet.
function int VMDConfigureInvSlotsX(Pawn Other)
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return InvSlotsY;
	}
 	return InvSlotsX;
}

function int VMDConfigureInvSlotsY(Pawn Other)
{
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return InvSlotsX;
	}
 	return InvSlotsY;
}

function bool VMDOtherIsName(Actor Other, string S)
{
	if (Other == None) return false;
	
 	if (InStr(CAPS(String(Other.Class)), CAPS(S)) > -1) return true;
 	return false;
}

function bool VMDIsWeaponName(string S)
{
 	if (InStr(CAPS(String(Class)), CAPS(S)) > -1) return true;
 	return false;
}

function float VMDGetRicochetDamage(Actor TTarget)
{
	local float Ret;
	
	Ret = RicochetHitDamage;
	if ((Ammo10mmGasCap(AmmoType) != None) && (GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolAltAmmos')))
	{
		Ret *= 2;
	}
	
	return Ret;
}

function float VMDGetMaterialPenetration(Actor TTarget)
{
 	local float Ret;
 	
 	if (!VMDIsBulletWeapon() || PenetrationHitDamage <= 0) return 0;
	if (AmmoNone(AmmoType) != None) return 0;
	if (!VMDIsBallisticDamageType()) return 0;
	
 	Ret = VMDGetCorrectHitDamage(float(HitDamage) + (GetWM2FloatDamage())) / 1.5;
	
	//MADDERS, 1/29/21: Cap off material penetration, as it can get quite silly at times.
	if (Ret > 10)
	{
		switch(AmmoType.Class)
		{
			//case class'Ammo10mmHeat':
			//case class'Ammo3006HEAT':
			//case class'AmmoSabot':
			//case class'Ammo3006AP':
			//break;
			default:
				Ret = 10;
			break;
		}
	}
	
 	if (Ammo10mmHeat(AmmoType) != None || Ammo3006HEAT(AmmoType) != None) Ret *= 1.5;
 	if (AmmoSabot(AmmoType) != None) Ret *= 1.5;
 	if (Ammo3006AP(AmmoType) != None)
	{
		Ret *= 2.0;
		if (Pawn(TTarget) != None) Ret *= 1.5;
	}
	
	//MADDERS, 6/9/22: Dumb talent tweak. Not using this anymore.
	/*if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolScope')))
	{
		Ret *= 1.5;
	}*/
	if ((Pawn(TTarget) != None) && (Ammo3006AP(AmmoType) != None) && (GoverningSkill == class'SkillWeaponRifle') && (VMDHasSkillAugment('RifleAltAmmos')))
	{
		Ret *= 2.0;
	}
	
 	return Ret;
}

function int VMDGetCorrectNumProj( int In )
{
 	if (OverrideNumProj < 1) return In;
 	return OverrideNumProj;
}

function float VMDGetCorrectHitDamage( float In )
{
	//MADDERS, 7/21/21: Scope mode adds 1 damage. On par with assault gun. I'm being cautious here.
	//UPDATE: 2 damage is sad and pathetic, and 3 ain't much better. Add 1 more at all times. Fuck it. This gun needs jesus.
	if (IsA('WeaponA17') || IsA('WeaponAssault17'))
	{
		In += 1.0;
		if (bZoomed)
		{
			In += 1.0;
		}
	}
	//MADDERS, 4/16/24: Un-nerf this a bit, since the Paratrooper rifle has become immensely fucking useless in modern nihilum.
	else if (IsA('WeaponM249DXN') || IsA('WeaponPara17'))
	{
		In += 2.0;
	}
	
	//MADDERS, 7/24/21: List proper LAM damage on mutations.
	else if ((IsA('WeaponLAM')) && (VMDGetPlayerCampaign() ~= "Mutations" || VMDGetPlayerCampaign() ~= "Hotel Carone"))
	{
		In *= (500.0 / HitDamage);
	}
	
	//MADDERS, 10/23/22: Upped from 0.5 to 0.6, so we do 3 damage instead of 2.
	if ((VMDMEGH(Owner) != None) && (VMDIsMeleeWeapon()))
	{
		if (!VMDMegh(Owner).bMeleeBuff)
		{
			In *= 0.8;
		}
		else
		{
			In *= 1.2;
		}
	}
	
	//MADDERS, 3/19/23: 
	if (Ammo20mm(AmmoType) != None)
	{
		In = ProjectileClass.Default.Damage;
	}
	
 	//MADDERS: Hack for returning at least 1, so long as we deal damage. Weird thought, but hey.
	return In;
 	//return Max(int(Default.HitDamage > 0), In);
}

//MADDERS, 1/13/21: Simplify this call as well as round up for things such as WeaponRifle.
function float VMDGetScaledDamage( float In, optional Float CustomMult )
{
	local float Ret, TDam;
	local DeusExPlayer DXP;
	
	TDam = VMDGetCorrectHitDamage(In);
	
	DXP = DeusExPlayer(Owner);
	if (CustomMult == 0.0)
	{
		CustomMult = VMDGetWeaponSkill("DAMAGE");
	}
	
	Ret = TDam * CustomMult;
	
	return Ret;
}

function float VMDGetCorrectReloadRate( float In )
{
 	local float Ret;
 	local bool bReloadSpeedTweak;
	
 	if (OverrideReloadAnimRate <= 0) Ret = In;
 	else Ret = OverrideReloadAnimRate;
 	
	//MADDERS: Don't apply reload augments underwater, since it'd be a straight nerf.
	if (!VMDIsWaterZone() || VMDNegateWaterSlow())
	{
		switch(GoverningSkill)
		{
			case class'SkillWeaponPistol':
				bReloadSpeedTweak = VMDHasSkillAugment('PistolReload');
			break;
			case class'SkillWeaponRifle':
				bReloadSpeedTweak = VMDHasSkillAugment('RifleReload');
			break;
		}
	}
	
 	//MADDERS: Reload mod tweak.
 	if ((bReloadSpeedTweak) && (ReloadTime > 0.0) && (Default.ReloadTime > 0.0))
 	{
  		Ret *= (Default.ReloadTime / ReloadTime) * 1.33;
 	}
 	
 	return Ret;
}

function float VMDGetCorrectReloadRateSingleLoaded( float In )
{
 	local float Ret;
	local bool bReloadSpeedTweak;
 	
 	if (OverrideReloadAnimRate <= 0) Ret = In;
 	else Ret = OverrideReloadAnimRate;
 	
	//MADDERS: Don't apply reload augments underwater, since it'd be a straight nerf.
	if (!VMDIsWaterZone() || VMDNegateWaterSlow())
	{
		switch(GoverningSkill)
		{
			case class'SkillWeaponPistol':
				bReloadSpeedTweak = VMDHasSkillAugment('PistolReload');
			break;
			case class'SkillWeaponRifle':
				bReloadSpeedTweak = VMDHasSkillAugment('RifleReload');
			break;
		}
	}
	
 	//MADDERS: Reload mod tweak.
 	if ((ReloadTime > 0.0) && (Default.ReloadTime > 0.0))
 	{
  		Ret *= (Default.ReloadTime / ReloadTime);
		if (bReloadSpeedTweak) Ret *= 1.33;
 	}
 	if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
 	{
  		Ret *= 0.57; //1 / 1.75
 	}
 	
 	return Ret;
}

function float VMDGetCorrectPumpRate( float In )
{
	local float Ret;
	
	Ret = In;
	if (GoverningSkill == class'SkillWeaponRifle')
	{
		if (VMDHasSkillAugment('RifleOperation'))
		{
			Ret *= 1.65;
		}
	}
	
	return Ret;
}

function float VMDGetCorrectAnimRate( float In, bool bNPC )
{
 	local float Ret;
 	
 	if ((OverrideAnimRate <= 0) && (!bNPC || NPCOverrideAnimRate <= 0)) Ret = In;
	else if (In < 0.05) Ret = 1.0;
	else Ret = In;
	
 	if ((bNPC) && (NPCOverrideAnimRate > 0)) Ret *= NPCOverrideAnimRate;
 	else if (OverrideAnimRate > 0) Ret *= OverrideAnimRate;
 	
 	if ((bSemiautoTrigger) && (!Default.bSemiautoTrigger) && (Default.bAutomatic || Default.bBurstFire) && (!bBoltAction)) Ret *= 3; //HACK! Speed up semi auto ROF.
 	if ((bPumpAction) && (PumpPurpose == 2)) Ret = VMDGetCorrectPumpRate(Ret);
	
	if (bHandToHand)
	{
		if (VMDHasSkillAugment('MeleeSwingSpeed'))
		{
			if (VMDIsWeaponName("NanoSword"))
			{
				Ret *= 1.3;
			}
			else
			{
				Ret *= 1.4;
			}
		}
		
		if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).VMDHasBuffType(class'CombatStimAura')))
		{
			Ret *= 1.65;
		}
		//MADDERS, 6/22/24: Normal humans don't benefit from combat stim as much in melee, either.
		//They fare better than they do in ground speed, though.
		else if ((VMDBufferPawn(Owner) != None) && (VMDBufferPawn(Owner).VMDHasBuffType(Class'CombatStimAura')))
		{
			Ret *= 1.5;
		}
	}
	
 	return Ret;
}

function Sound VMDGetIntendedFireSound(Ammo NewAmmo)
{
	if ( Ammo20mm(newAmmo) != None || NewAmmo.Class.Name == 'Ammo20mmEMP')
	{
		return Sound'AssaultGunFire20mm';
	}
	else if ( AmmoRocketWP(newAmmo) != None )
	{
		return Sound'GEPGunFireWP';
	}
	else if ( AmmoRocket(newAmmo) != None || AmmoRocketEMP(NewAmmo) != None)
	{
		return Sound'GEPGunFire';
	}
	
	return Default.FireSound;
}

//MADDERS: This is a thing because this call is often extremely relevant.
function bool VMDIsWaterZone()
{
	if (Owner != None)
        {
		if (Pawn(Owner) != None)
		{
			if ((Pawn(Owner).HeadRegion.Zone != None) && (Pawn(Owner).HeadRegion.Zone.bWaterZone))
			{
				return true;
			}
		}
		else
		{
         		if (Owner.Region.Zone.bWaterZone)
			{
				return true;
			}
		}
        }
        else if (Region.Zone.bWaterZone) return true;
	
	return false;
}

function bool VMDNegateWaterSlow()
{
	if (VMDHasSkillAugment('SwimmingDrowningRate'))
	{
		return true;
	}
	return false;
}

function float VMDGetFirePitch()
{
	local bool bUnderwater;
	local float TRate, Mult, GMult;
	
	bUnderwater = VMDIsWaterZone();
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	//MADDERS: For meleee weapons, scale with our swing speed.
	if (bHandToHand) TRate = VMDGetCorrectAnimRate(1.0, (ScriptedPawn(Owner) != None));
	else TRate = 1.0;
	
	//MADDERS: Nerf for many melee weapons, except knife, to give it some love.
	//Additionally, nerf for swinging underwater, unless a knife, but only stab.
	if (bHandToHand)
	{
		mult = 1.0;
		if (bHandToHand)
		{
			if (DeusExPlayer(Owner) != None)
			{
				if (VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem) != None)
				{
					mult = VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem).VMDConfigureWepSwingSpeedMult(Self);
				}
				else
				{
					mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
				}
			}
			else if ((VMDBufferPawn(Owner) != None) && (VMDBufferPawn(Owner).AugmentationSystem != None))
			{
				mult = VMDBufferPawn(Owner).AugmentationSystem.VMDConfigureWepSwingSpeedMult(Self);
			}
			
			if (mult == 0.0)
			{
				mult = 1.0;
			}
		}
		
		TRate *= Mult;
		if (VMDIsWeaponName("Nanosword"))
		{
			if (bUnderwater) TRate *= 0.7;
			TRate *= 0.7;
		}
		else if (!VMDIsWeaponName("Knife"))
		{
			if (bUnderwater) TRate *= 0.7;
			TRate *= 0.85;
		}
	}
	
	//Make splash noises.
	if (bUnderwater)
	{
		return (FirePitchMin + (Frand() * (FirePitchMax - FirePitchMin))) * 0.7 * TRate * GMult;
	}
	
	return (FirePitchMin + (Frand() * (FirePitchMax - FirePitchMin))) * TRate * GMult;
}

function float VMDGetMiscPitch()
{
	local bool bUnderwater;
	local float GMult;
	
	bUnderwater = VMDIsWaterZone();
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
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
	
	bUnderwater = VMDIsWaterZone();
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return 0.7 * GMult;
	}
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return 1.0 * GMult;
}

//MADDERS: Don't run manual action weapons while we're tased.
function bool VMDHasRackObjection()
{
	if ((!bPumpAction) && (!bBoltAction)) return false;
	
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).TaseDuration > 0))
		return true;
	
	return false;
}

function bool VMDHasFireObjection()
{
	local float FR;
	local int WL, GL, SGL;
	local VMDBufferPlayer VMBP;
	local bool bAmmoEmpty;
	
	if (AmmoType == None) bAmmoEmpty = true;
	else if (AmmoType.AmmoAmount <= 0 || ClipCount >= ReloadCount) bAmmoEmpty = true;
	//MADDERS: Don't allow melee to give stress for being swung.
	if ((bAmmoEmpty) && (bHandToHand)) bAmmoEmpty = false;
	
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).TaseDuration > 0) && (bHandToHand))
		return true;
	
	bLastShotJammed = false;
	
	VMBP = VMDBufferPlayer(Owner);
	if ((VMBP != None) && (!bAmmoEmpty))
	{
		FR = FRand();
		WL = VMDGetWaterlogLevel();
		GL = VMDGetGrimeLevel();
		SGL = GrimeLevel;
		if (VMDIsWaterZone()) WL = 3;
		
		if (FiringSystemOperation > 0)
		{
			//Problem #1: We're waterlogged.
			if ((WL > 0) && (FiringSystemOperation != 1 || !VMDHasSkillAugment('TagTeamClosedWaterproof')))
			{
				if ((0.34 * WL > FR) && ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum)))
				{
					//Give a different message for each condition on this one.
					if (VMDIsWaterZone()) VMBP.ClientMessage(MsgNotWorking);
					else VMBP.ClientMessage(MessageTooWet);
					
					VMBP.PlaySound(Misc1Sound, SLOT_None,,,, VMDGetMiscPitch());
					
					//MADDERS, 7/12/20: Return to standard state, since this bugs the fuck out.
					EraseMuzzleFlashTexture();
					TweenAnim('Still', 0.1);
					GoToState('Idle');
					return true;
				}
			}
			//Problem #2: We're gunked up.
			if ((GL > 1) && (FiringSystemOperation != 2 || !VMDHasSkillAugment('TagTeamOpenGrimeproof')))
			{
				//Note: 1000 shots = 100% chance.
				if (0.001 * SGL > FR)
				{
					bLastShotJammed = true;
					VMBP.ClientMessage(MessageTooDirty);
					VMBP.PlaySound(Misc1Sound, SLOT_None,,,, VMDGetMiscPitch());
					
					//MADDERS, 7/12/20: Return to standard state, since this bugs the fuck out.
					EraseMuzzleFlashTexture();
					TweenAnim('Still', 0.1);
					GoToState('Idle');
					return true;
				}
			}
		}
	}
	return false;
}

function bool VMDHasReloadObjection()
{
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).TaseDuration > 0))
		return true;
	
	//MADDERS, 1/27/21: Exploitable for shotguns, to say the least.
	if ((IsInState('NormalFire')) && (bSingleLoaded) && (ClipCount < ReloadCount))
		return true;
	
	//Nihilum, more consistent hot swapping.
	if (IsA('WeaponTakaraGun'))
	{
		//MADDERS: Cockblock 20mm reloads.
		if (VMDIsQuickSwapAmmoFA(AmmoType))
			return true;
	}
	
	if ((VMDIsQuickSwapAmmoFA(AmmoType)) && (ClipCount < ReloadCount))
		return true;
	
	return false;
}

//MADDERS: Use these 2 functions to simulate replication accurately, while still singling out melee sounds.
simulated function VMDShellSelectiveSpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other, float Damage)
{
	local DeusExPlayer fxOwner;
	local Pawn aPawn;
	
	// The normal path before there was multiplayer
	if (Level.NetMode == NM_Standalone)
	{
		SpawnEffects(HitLocation, HitNormal, Other, Damage);
		return;
	}
	
	fxOwner = DeusExPlayer(Owner);
	if (Role == ROLE_Authority)
	{
		SpawnEffectSounds(HitLocation, HitNormal, Other, Damage);
	}
	if (fxOwner == DeusExPlayer(GetPlayerPawn()))
	{
		SpawnEffectSounds(HitLocation, HitNormal, Other, Damage);
	}
}

simulated function VMDShellProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local bool bValidEffectHit;
	local float mult, value;
	local name damageType;
	local DeusExPlayer dxPlayer, DXP;
	local DeusExRootWindow DXRW;
	
	mult = 1.0;
	if (Other != None)
	{
		if (Other == Level || Mover(Other) != None)
		{
			bValidEffectHit = true;
		}
		else if (DeusExDecoration(Other) != None && DeusExDecoration(Other).MinDamageThreshold > 10 && DeusExDecoration(Other).FragType == class'MetalFragment')
		{
			bValidEffectHit = true;
		}
		else if (VMDBufferPawn(Other) != None && VMDBufferPawn(Other).VMDHitArmor(HitDamage, HitLocation, WeaponDamageType()))
		{
			bValidEffectHit = true;
		}
		
		if (bValidEffectHit)
		{
			VMDShellSelectiveSpawnEffects(HitLocation, HitNormal, Other, HitDamage * mult);
		}
		else if ((Other != self) && (Other != Owner))
		{
			if (bHandToHand)
			{
				VMDShellSelectiveSpawnEffects(HitLocation, HitNormal, Other, HitDamage * mult);
			}
		}
	}
}

function float VMDShotTimeProgression()
{
 	//MADDERS: Don't run this in MP.
 	if (Level.Netmode != NM_Standalone) return 999.0;
 	if ((LastFireTime == 0.0) || (LastFireTime > Level.TimeSeconds)) return 999.0;
 	
 	return (Level.TimeSeconds - LastFireTime);
}

//=======================================
//Use these for weapon mod calls!
//=======================================

function bool VMDSpecialModCondition(string WeaponMod)
{
	//MADDERS: This is now no longer the case.
	//Now the effect of the mod is scaled instead.
	/*switch(CAPS(WeaponMod))
	{
		case "LASER":
		case "SCOPE":
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
				case class'SkillWeaponRifle':
					return true;
				break;
			}
		break;
	}*/
 	return false;
}

function bool VMDWeaponModAllowed(string WeaponMod)
{
	//MADDERS: This is now no longer the case.
	//Now the effect of the mod is scaled instead.
	/*switch(CAPS(WeaponMod))
	{
		case "LASER":
		case "SCOPE":
			if ((!bCanHaveLaser || bHasLaser) && (WeaponMod ~= "Laser")) return false;
			else if ((!bCanHaveScope || bHasScope) && (WeaponMod ~= "Scope")) return false;
			
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
					return VMDHasSkillAugment('PistolModding');
				break;
				case class'SkillWeaponRifle':
					return VMDHasSkillAugment('RifleModding');
				break;
			}
		break;
	}*/
 	return true;
}

function VMDAlertModApplied(String WeaponMod)
{
 	switch(CAPS(WeaponMod))
 	{
  		case "ACCURACY":
  		break;
  		case "CLIP":
  		break;
  		case "EVOLUTION":
  		break;
  		case "LASER":
  		break;
  		case "RANGE":
  		break;
  		case "RECOIL":
  		break;
  		case "RELOAD":
  		break;
  		case "SCOPE":
  		break;
  		case "SILENCER":
  		break;
  		default:
			Log("WARNING: Unknown mod type applied! Type?"@WeaponMod);
   			BroadcastMessage("WARNING: Unknown mod type applied! Type?"@WeaponMod);
  		break;
 	}
}

//Called when loading ammos. Let's unfuck our shit more formally here.
function VMDAlertAmmoLoad( bool bInstant )
{ 
 	//MADDERS ADDINS!
 	if (bInstant || !Default.bInstantHit)
 	{
  		CurFiringMode = 0;
  		OverrideNumProj = Default.OverrideNumProj;
  		bSemiautoTrigger = Default.bSemiautoTrigger;
  		bBurstFire = Default.bBurstFire;
  		bAutomatic = Default.bAutomatic;
  		ShotTime = Default.ShotTime;
		if (IsA('WeaponM249DXN') || IsA('WeaponPara17'))
		{
			ShotTime = 0.150000;
		}
 	}
 	else
 	{
  		//MADDERS ADDINS!
  		bSemiautoTrigger = True;
  		bBurstFire = False;
  		
 		bAutomatic = False;
  		ShotTime = 1.0;
		if (IsA('WeaponM249DXN') || IsA('WeaponPara17'))
		{
			ShotTime = 0.150000;
		}
	}
}

function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (IsA('WeaponWaltherDXN') || IsA('WeaponBRGlock'))
	{
		if (Ammo10mmHEAT(AmmoType) != None)
		{
			HitDamage = Default.HitDamage;
	     		PenetrationHitDamage = HitDamage * 0.8;
	     		RicochetHitDamage = HitDamage * 0.0;
		}
		else if (Ammo10mmGasCap(AmmoType) != None)
		{
			HitDamage = Default.HitDamage * 0.75;
	     		PenetrationHitDamage = HitDamage * 0.0;
     			RicochetHitDamage = HitDamage * 1.0;
		}
		else
		{
			HitDamage = Default.HitDamage;
	     		PenetrationHitDamage = HitDamage * 0.6;
	     		RicochetHitDamage = HitDamage * 0.3;
		}
	}
	
	//Grenade launcher behavior for nihilum.
	if (IsA('WeaponTakaraGun'))
	{
		//MADDERS: Change our fire sound, operation type, and low ammo water mark.
		if (Ammo762mm(AmmoType) != None)
		{
			SilencedFireSound = Default.SilencedFireSound;
			bAutomatic = (FiringModes[CurFiringMode] ~= "Full Auto");
			bBoltAction = false;
     			LowAmmoWaterMark = 30;
		}
		else
		{
			//MADDERS: Hack for silenced GL handling.
 			SilencedFireSound = Sound'AssaultGunFire20mm';
			bAutomatic = false;
			bBoltAction = true;
    			LowAmmoWaterMark = 4;
		}
		ShotTime = Default.ShotTime;
	}
}

simulated state DelayedReload
{
 Begin:
	PlayOwnedSound(FireSound,,,,,VMDGetFirePitch());
	
	Sleep(ShotTime);
	
	ReloadAmmo();
}

function bool VMDIsShooting()
{
 	if (IsInState('Reload')) return False;
 	
	if (VMDShotTimeProgression() > ShotTime / 4)
	{
 		if (AnimRate < 0.01) return False;
	}
 	if (AnimSequence == 'Shoot') return True;
 	if (AnimSequence == 'Attack') return True;
 	if (AnimSequence == 'Attack2') return True;
 	if (AnimSequence == 'Attack3') return True;
	
	return False;
}

simulated function VMDDrawExplosionEffects(vector HitLocation, vector HitNormal, float TRadius)
{
	local ShockRing ring;
   	local SphereEffect sphere;
	local ExplosionLight light;
   	local AnimatedSprite expeffect;
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
   	if (light != None)
      		light.RemoteRole = ROLE_None;
	
	expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
	light.size = 2;
	
	TRadius /= 32;
	
   	if (expeffect != None)
      		expeffect.RemoteRole = ROLE_None;
	
	// draw a pretty shock ring
   	// For nano defense we are doing something else.
      	ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
      	if (ring != None)
      	{
         	ring.RemoteRole = ROLE_None;
         	ring.size = TRadius;
      	}
      	ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
      	if (ring != None)
      	{
         	ring.RemoteRole = ROLE_None;
         	ring.size = TRadius;
      	}
      	ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
      	if (ring != None)
      	{
         	ring.RemoteRole = ROLE_None;
         	ring.size = TRadius;
      	}
}

function VMDHandlePrimaryAmmoEffects(Actor Other, Vector L, Vector N)
{
	local float TDamage;
	local float DecalMult, BlastMult, TRadius;
	local class<DeusExDecal> DecalType;
	local DeusExDecal Decal;
	
	TDamage = VMDGetScaledDamage(float(HitDamage) + (GetWM2FloatDamage()));
	if ((Ammo10mmHEAT(AmmoType) != None || Ammo3006HEAT(AmmoType) != None) && (Other != None))
	{
		BlastMult = 1.0;
		if ((GoverningSkill == class'SkillWeaponRifle') && (VMDHasSkillAugment('RifleAltAmmos')))
		{
			BlastMult = 1.5;
		}
		else if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolAltAmmos')))
		{
			BlastMult = 1.5;
		}
		
		TRadius = 50;
		
		DecalMult = 0.0009 * TRadius * BlastMult / 22.0;
		DecalType = class'ScorchMark';
		
		//20x total damage = noise creation radius.
		AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, TDamage * 20);
		VMDUseAIEventSender(GetPlayerPawn(), 'LoudNoise', EAITYPE_Audio, TransientSoundVolume, TDamage * 20);
		
		VMDDrawExplosionEffects(L, N, TRadius * BlastMult);
		
		//MADDERS, 6/2/22: Ah yes. The old "scripted pawn makes scripted pawn take damage" crash. Unfixable and cryptic as ever.
		//Instead, just do direct damage at these ranges.
		if (ScriptedPawn(Owner) == None || VSize(L - Owner.Location) > TRadius*BlastMult*2)
		{
			HurtRadius(int(TDamage * 2), TRadius * BlastMult, 'Exploded', 1, L);
		}
		else
		{
			if (VMDBufferPawn(Other) != None)
			{
				VMDBufferPawn(Other).LastWeaponDamageSkillMult = TDamage / VMDGetCorrectHitDamage(HitDamage);
				Other.TakeDamage(VMDGetCorrectHitDamage(HitDamage)*2, Pawn(Owner), L, vect(0,0,0), 'Exploded');
			}
			else if (VMDBufferPlayer(Other) != None)
			{
				VMDBufferPlayer(Other).LastWeaponDamageSkillMult = TDamage / VMDGetCorrectHitDamage(HitDamage);
				Other.TakeDamage(VMDGetCorrectHitDamage(HitDamage)*2, Pawn(Owner), L, vect(0,0,0), 'Exploded');
			}
			else if (Brush(Other) != None)
			{
				Other.TakeDamage(int(TDamage*2 * MoverDamageMult), Pawn(Owner), L, Vect(0,0,0), 'Exploded');
			}
			else
			{
				Other.TakeDamage(int(TDamage*2), Pawn(Owner), L, vect(0,0,0), 'Exploded');
			}
		}
		
		if ((DecalType != None) && (Other == Level || Other.IsA('Mover')))
		{
			Decal = Spawn(DecalType,Other,,L,Rotator(N));
			if (Decal != None)
			{
				Decal.DrawScale = DecalMult * 1000;
				Decal.ReattachDecal();
			}
		}
	}
	else if (AmmoDragonsBreath(AmmoType) != None)
	{
		VMDHandleDragonsBreath(Other, L, N);
	}
}

function VMDHandleDragonsBreath(Actor Other, Vector L, Vector N);

function VMDHandleAmmoEffects(Actor Other, Vector L, Vector N)
{
}

function float VMDGetCorrectReloadTime( float InTime )
{
	local float Ret;
	
	if (HasReloadMod())
		Ret = InTime * (1.0+ModReloadTime);
	else
		Ret = InTime;
	
	return Ret;
}

//MADDERS: Pull a wicked hack to keep our ammo owned, for debug reasons.
function GiveAmmo( Pawn Other )
{
	local int AmmoGrabbed;
	local Vector TLoc;
	local DeusExPlayer DXP;
	local DeusExAmmo DXA, TAmmo;
	
	DXP = DeusExPlayer(Other);
	
	if ( AmmoName == None )
		return;
	
	AmmoType = Ammo(Other.FindInventoryType(AmmoName));
	
	if ( AmmoType != None )
	{
		//MADDERS, 02/04/21: Show icons for our ammo here.
		DXA = DeusExAmmo(AmmoType);
		
		//MADDERS, 8/7/23: Drop excess ammo we can't use.
		if (DXA != None)
		{
			AmmoGrabbed = Min(PickupAmmoCount, DXA.VMDConfigureMaxAmmo() - DXA.AmmoAmount);
			if ((!VMDHackbReceivedIconBlock) && (PickupAmmoCount > 0) && (DXA.AmmoAmount < DXA.VMDConfigureMaxAmmo()))
			{
				class'VMDStaticFunctions'.Static.AddReceivedItem(DXP, DXA, AmmoGrabbed, true);
			}
			
			//MADDERS, 8/19/23: Don't spawn grenades, shurikens, etc if we somehow had max ammo then picked up the weapon.
			if ((AmmoGrabbed < PickupAmmoCount) && (!VMDHasJankyAmmo()))
			{
				TLoc = Location - (Vect(0,0,1) * CollisionHeight) + (Vect(0,0,1) * AmmoName.Default.CollisionHeight);
				
				TAmmo = DeusExAmmo(Spawn(AmmoName,,, TLoc));
				if (TAmmo != None)
				{
					TAmmo.AmmoAmount = PickupAmmoCount - AmmoGrabbed;
				}
			}
			AmmoType.AddAmmo(AmmoGrabbed);
		}
		else
		{
			AmmoType.AddAmmo(PickUpAmmoCount);
		}
	}
	else
	{
		//MADDERS: Quick bait and switch.
		//See Pawn.AddInventory for why and how we're dodging this accessed none.
		//See Ammo10mm, AmmoPlasma, AmmoRocket, and Ammo3006.
		//These are why it's either owned or bCrateSummoned at any moment in time.
		AmmoType = Spawn(AmmoName, Self);			// Create ammo type required
		
		//MADDERS, 02/04/21: Show icons for our ammo here.
		DXA = DeusExAmmo(AmmoType);
		if (DXA != None)
		{
			if ((!VMDHackbReceivedIconBlock) && (PickupAmmoCount > 0) && (DXA.AmmoAmount < DXA.VMDConfigureMaxAmmo()))
			{
				class'VMDStaticFunctions'.Static.AddReceivedItem(DXP, DXA, PickupAmmoCount, true);
			}
			DXA.bCrateSummoned = true;
		}
		
		if (AmmoType != None)
		{
			AmmoType.SetOwner(None);
			
			Other.AddInventory(AmmoType);		// and add to player's inventory
			AmmoType.BecomeItem();
			AmmoType.AmmoAmount = PickUpAmmoCount; 
			AmmoType.GotoState('Idle2');
		}
	}
	
	VMDHackbReceivedIconBlock = false;
}

//Shitty function, but it'll do.
function VMDModifyAmmoCap(class<DeusExAmmo> AT, float CM)
{
 	local DeusExAmmo DA;
 	
 	if (DeusExPlayer(Owner) == None) return;
 	
 	DA = DeusExAmmo(DeusExPlayer(Owner).FindInventoryType(AT));
 	
 	if (DA != None)
 	{
  		DA.MaxAmmo = DA.Default.MaxAmmo * CM;
 	}
}

function VMDUpdateEvolution()
{
 	local float AddChunk;
 	local int Iterations;
 	
 	if (!bHasEvolution) return;
 	
 	AddChunk = Max(1, ReloadCount * 0.1);
 	Iterations = ModReloadCount / 0.1;
 	ReloadCount = Default.ReloadCount + (AddChunk * Iterations);
 	
	switch(Class)
	{
		//SAWED OFF: Enable double fire, and speed up reload a bit.
		case class'WeaponSawedOffShotgun':
			ShootTiltIndices = 0; //MADDERs, 4/23/23: Fix for jump at end of shoot animation.
			FireCutoffFrame = 0.250000;
			bSemiautoTrigger = true;
			bPumpAction = false;
			VMDModifyAmmoCap(class'AmmoSabot', 2.0);
			NumFiringModes = 2;
			OverrideReloadAnimRate = 1.75;
			bCanHaveModReloadCount = False;
			ModReloadCount = 0;
			ReloadCount = 2;
		break;
		//ASSAULT SHOTTY: Enable semi fire, and reload by the drum.
		case class'WeaponAssaultShotgun':
		  	VMDModifyAmmoCap(class'AmmoShell', 4.0);
		  	NumFiringModes = 2;
		  	OverrideReloadAnimRate = 1.25;
			OverrideAnimRate = 3.666666;
			ShotTime = 0.2;
		  	ReloadCount += 10;
		break;
		//PISTOL: Permanent "silencer", smaller mag, longer reload!
		case class'WeaponPistol':
		  	VMDModifyAmmoCap(class'Ammo10mm', 0.35);
		  	bSingleLoaded = True;
		  	ReloadCount = 6;
		  	OverrideReloadAnimRate = 0.75;
		  	bCanHaveModReloadCount = False;
		  	ModReloadCount = 0;
		  	ReloadTime = VMDGetCorrectReloadTime(Default.ReloadTime + 1.0);
			//MADDERS: Revolver has enhanced damage.
			VMDAlertPostAmmoLoad(bInstantHit);
		break;
		//STEALTH PISTOL: Faster reload, more daka!
		case class'WeaponStealthPistol':
		  	VMDModifyAmmoCap(class'Ammo10mmHEAT', 3.0);
		  	VMDModifyAmmoCap(class'Ammo10mmGasCap', 3.0);
		  	bAutomatic = True;
			bSemiautoTrigger = False;
		  	OverrideAnimRate = 3.0;
		  	ShotTime = 0.2;
		  	OverrideReloadAnimRate = 1.25;
		  	ReloadTime = VMDGetCorrectReloadTime(3.0);
		break;
		//RIFLE: Faster fire rate, more capacity!
		case class'WeaponRifle':
		  	bSemiautoTrigger = False;
			bBoltAction = False;
		  	OverrideAnimRate = 5;
		  	ReloadCount += 9;
		  	ShotTime = 0.1;
		  	OverrideReloadAnimRate = 0.5;
			//MADDERS: Anti-matter rifle has enhanced damage.
			VMDAlertPostAmmoLoad(bInstantHit);
		break;
		//ASSAULT GUN: Full auto, and more base damage!
		case class'WeaponAssaultGun':
		  	NumFiringModes = 3;
			//MADDERS: Now obsolete.
		  	//OverrideAnimRate = 0.6;
		  	HitDamage = 7;
		break;
		//HIDEAGUN: Faster reload, 2 shot spread, pocket reload attribute!
		case class'WeaponHideagun':
		  	bPocketReload = True;
		  	ReloadTime = VMDGetCorrectReloadTime(Default.ReloadTime - 1.3);
		  	CurFiringMode = 1;
		  	OverrideNumProj = 2;
		break;
		//CROSSBOW: Reload per-shot, +4 capacity.
		case class'WeaponMiniCrossbow':
		  	bSingleLoaded = True;
		  	bPocketReload = True;
		  	ReloadCount += 4;
		  	OverrideAnimRate = 3;
		  	ShotTime = 0.20;
		break;
		//DTS: Insane fucking range because you know why
		case class'WeaponNanosword':
		  	MaxRange = Default.MaxRange * 12;
			AccurateRange = Default.AccurateRange * 12;
		break;
		//GEP GUN: Burst fire. +5 capacity.
		case class'WeaponGEPGun':
		  	VMDModifyAmmoCap(class'AmmoRocket', 5.0);
		  	VMDModifyAmmoCap(class'AmmoRocketWP', 5.0);
		  	bAutomatic = True;
		  	bBurstFire = True;
                  	bSemiautoTrigger = False;
		  	CurFiringMode = 1;
		  	ReloadCount += 8;
		  	OverrideAnimRate = 1.000000;
		  	ShotTime = 0.1;
			ClipsLabel = "SALVOS";
		break;
		//PLASMA RIFLE: +2 projectiles.
		case class'WeaponPlasmaRifle':
		  	OverrideNumProj = 5;
		break;
		//FLAMETHROWER: Semiauto mode unlocked, forced double projectiles.
		case class'WeaponFlamethrower':
			ProjectileClass = class'FireballExploded';
		  	OverrideNumProj = 2;
		  	NumFiringModes = 2;
		break;
		//PEPPER GUN: Now sprays halon gas, slower ROF.
		case class'WeaponPeppergun':
			OverrideNumProj = 3;
		  	ProjectileClass = class'HalonGas';
		  	ShotTime = 0.15;
		break;
	}
 	
 	VMDUpdateEvoName();
}

function VMDUpdateEvoName()
{
 	if (!bHasEvolution) return;
 	
 	ItemName = EvolvedName;
 	BeltDescription = EvolvedBelt;
}

function VMDChangeFiringMode()
{
 	if (NumFiringModes < 2 || (VMDBufferPlayer(Owner) != None && VMDBufferPlayer(Owner).TaseDuration > 0)) return;
 	if ((!bInstantHit) && (Default.bInstantHit)) return; //No 20mm, please.
 	
	if (IsA('WeaponA17') || IsA('WeaponAssault17'))
	{
		if ((CurFiringMode == 1) && (bZoomed))
		{
			return;
		}
	}
	
 	VMDToggleJump(CurFiringMode);
	if (CurFiringMode == 0)
	{
		Owner.PlaySound(Sound'FireModeChangeA', SLOT_None,,,, VMDGetMiscPitch());
	}
 	else
	{
		Owner.PlaySound(Sound'FireModeChangeB', SLOT_None,,,, VMDGetMiscPitch());
 	}
	
	if (VMDCustomModeHook())
	{
		return;
	}
	
 	CurFiringMode++;
 	if (CurFiringMode >= NumFiringModes) CurFiringMode = 0;
 	switch(CAPS(FiringModes[CurFiringMode]))
 	{
  		case "FULL AUTO":
   			bAutomatic = True;
   			bSemiautoTrigger = False;
   			bBurstFire = False;
  		break;
  		case "FULL AUTO ": //Hack for using without true auto.
   			bAutomatic = False;
   			bSemiautoTrigger = False;
   			bBurstFire = False;
  		break;
  		case "SEMI AUTO":
   			bAutomatic = False;
   			bSemiautoTrigger = True;
   			bBurstFire = False;
  		break;
  		case "BURST FIRE":
   			bAutomatic = True;
   			bSemiautoTrigger = False;
   			bBurstFire = True;
  		break;
  		
  		case "SINGLE FIRE":
   			OverrideNumProj = Default.OverrideNumProj;
  		break;
  		case "DOUBLE FIRE":
   			OverrideNumProj = Default.OverrideNumProj * 2;
  		break;
  		case "DOUBLE FIRE ": //Hack for pellet spreads from hell.
   			OverrideNumProj = Default.OverrideNumProj * 2;
  		break;
 	}
 	
 	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).InHand == Self) && (MessageChangedMode != "") && (ModeNames[CurFiringMode] != ""))
	{
		Pawn(Owner).ClientMessage(SprintF(MessageChangedMode, ModeNames[CurFiringMode]));
	}
}

function VMDRenderBlock( Canvas Canvas )
{
	local rotator NewRot;
	local bool bPlayerOwner;
	local int THand;
	local PlayerPawn PlayerOwner;
	
	if ( bHideWeapon || (Owner == None) )
		return;
	
	PlayerOwner = PlayerPawn(Owner);
	
	if (PlayerOwner != None)
	{
		if (PlayerOwner.DesiredFOV != PlayerOwner.DefaultFOV)
		{
		 	if (VMDBufferPlayer(Owner) == None || VMDBufferPlayer(Owner).DrugEffectTimer > 10 || (VMDBufferPlayer(Owner).AddictionStates[4] > 0 && VMDBufferPlayer(Owner).AddictionTimers[4] >= 300))
			{
				//MADDERS, 5/2/25: GP2.0, adjust our rotation here so we stop shitting the bed when our owner gets tear gassed.
				if (ShouldUseGP2())
				{
					NewRot = Pawn(Owner).ViewRotation;
					
					//3/23/22: Patched in a lean fix. Yeah, really.
					if (THand == 0)
					{
						newRot.Roll += -2 * Default.Rotation.Roll;
					}
					else
					{
						newRot.Roll += Default.Rotation.Roll * THand;
					}
					
					if (VMDBufferPlayer(Owner) != None)
					{
						NewRot += VMDBufferPlayer(Owner).VMDRollModifier;
					}
					
					//MADDERS, 5/2/25: Adjust our facing to be accurate with our point of aim. Neato.
					if (ShouldUseGP2())
					{
						NewRot += CurrentAimOffset;
					}
					
					setRotation(newRot);
				}
				return;
			}
		}
		bPlayerOwner = true;
		THand = GetHandType();
		
		if ((Level.NetMode == NM_Client) && (THand == 2))
		{
			bHideWeapon = true;
			return;
		}
	}
	
	if (!bPlayerOwner || PlayerOwner.Player == None)
	{
		Pawn(Owner).WalkBob = vect(0,0,0);
	}
	
	if ((bMuzzleFlash > 0) && (bDrawMuzzleFlash) && (Level.bHighDetailMode) && (MFTexture != None))
	{
		MuzzleScale = Default.MuzzleScale * Canvas.ClipX/640.0;
		if (!bSetFlashTime)
		{
			bSetFlashTime = true;
			FlashTime = Level.TimeSeconds + FlashLength;
		}
		else if (FlashTime < Level.TimeSeconds)
		{
			bMuzzleFlash = 0;
		}
		
		if (bMuzzleFlash > 0)
		{
			if (THand == 0)
				Canvas.SetPos(Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (-0.2 * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * (FlashY + FlashC));
			else
				Canvas.SetPos(Canvas.ClipX/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipX * (THand * Default.FireOffset.Y * FlashO), Canvas.ClipY/2 - 0.5 * MuzzleScale * FlashS + Canvas.ClipY * FlashY);
			
			Canvas.Style = 3;
			Canvas.DrawIcon(MFTexture, MuzzleScale);
			Canvas.Style = 1;
		}
	}
	else
	{
		bSetFlashTime = false;
	}
	
	SetLocation(Owner.Location + CalcDrawOffset());
	NewRot = Pawn(Owner).ViewRotation;
	
	//3/23/22: Patched in a lean fix. Yeah, really.
	if (THand == 0)
	{
		newRot.Roll += -2 * Default.Rotation.Roll;
	}
	else
	{
		newRot.Roll += Default.Rotation.Roll * THand;
	}
	
	if (VMDBufferPlayer(Owner) != None)
	{
		NewRot += VMDBufferPlayer(Owner).VMDRollModifier;
	}
	
	//MADDERS, 5/2/25: Adjust our facing to be accurate with our point of aim. Neato.
	if (ShouldUseGP2())
	{
		NewRot += CurrentAimOffset;
	}
	
	setRotation(newRot);
	
	Canvas.DrawActor(self, false);
}

//MADDERS: Use render of overlays to show JC hands. Easy, :) Ded 4/1/07
simulated event RenderOverlays( Canvas Can )
{
	local bool bFemale;
	local byte OldFatness;
	local int i, BL;
	local float OldSG, RM;
	local ERenderStyle OldStyle;
  	local Texture TTex, OldTex[8], CloakTex[9], OldTexture;
	local VMDBufferPlayer VMBP;
	
	CloakTex[0] = Texture'VMDCloakFX01';
	CloakTex[1] = Texture'VMDCloakFX02';
	CloakTex[2] = Texture'VMDCloakFX03';
	CloakTex[3] = Texture'VMDCloakFX04';
	CloakTex[4] = Texture'VMDCloakFX05';
	CloakTex[5] = Texture'VMDCloakFX06';
	CloakTex[6] = Texture'VMDCloakFX07';
	CloakTex[7] = Texture'VMDCloakFX08';
	CloakTex[8] = Texture'VMDCloakFX09';
	
 	//Object load annoying. Do this instead.
	VMBP = VMDBufferPlayer(Owner);
	if (VMBP != None)
 	{
		bFemale = VMBP.bAssignedFemale;
		
		//Backup our old skins.
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
			if (i != MuzzleFlashIndex) OldTex[i] = Multiskins[i];
		}
		OldTexture = Texture;
		OldStyle = Style;
  		OldSG = ScaleGlow;
		OldFatness = Fatness;
		
		if (VMDOwnerIsRadarTrans())
		{
			Fatness = Rand(4) + 126;
		}
		
		if (WeaponMiniCrossbow(Self) == None)
		{
			//Then swap out for our hand and draw us.
  			switch (VMBP.PlayerSkin)
  			{
   				case 0: //White
					if (bFemale)
					{
						TTex = Texture'NewHand01Female';
					}
					else
					{
    						TTex = Texture'NewHand01';
					}
   				break;
   				case 1: //Black
					if (bFemale)
					{
						TTex = Texture'NewHand02Female';
					}
					else
					{
    						TTex = Texture'NewHand02';
					}
   				break;
   				case 2: //Brown
					if (bFemale)
					{
						TTex = Texture'NewHand03Female';
					}
					else
					{
    						TTex = Texture'NewHand03';
					}
   				break;
   				case 3: //Redhead
					if (bFemale)
					{
						TTex = Texture'NewHand04Female';
					}
					else
					{
    						TTex = Texture'NewHand04';
					}
   				break;
   				case 4: //Pale
					if (bFemale)
					{
						TTex = Texture'NewHand05Female';
					}
					else
					{
    						TTex = Texture'NewHand05';
					}
   				break;
  			}
  		}
		else
		{
			//Then swap out for our hand and draw us.
  			switch (VMBP.PlayerSkin)
  			{
   				case 0: //White
					if (bFemale)
					{
  						TTex = Texture'NewCrossbowHand01Female';
					}
					else
					{
    						TTex = Texture'NewCrossbowHand01';
					}
   				break;
   				case 1: //Black
					if (bFemale)
					{
  						TTex = Texture'NewCrossbowHand02Female';
					}
					else
					{
    						TTex = Texture'NewCrossbowHand02';
					}
   				break;
   				case 2: //Brown
					if (bFemale)
					{
  						TTex = Texture'NewCrossbowHand03Female';
					}
					else
					{
    						TTex = Texture'NewCrossbowHand03';
					}
   				break;
   				case 3: //Redhead
					if (bFemale)
					{
  						TTex = Texture'NewCrossbowHand04Female';
					}
					else
					{
    						TTex = Texture'NewCrossbowHand04';
					}
   				break;
   				case 4: //Pale
					if (bFemale)
					{
  						TTex = Texture'NewCrossbowHand05Female';
					}
					else
					{
    						TTex = Texture'NewCrossbowHand05';
					}
   				break;
  			}
		}
		
		if (VMDOwnerIsCloaked())
		{
			for (i=0; i<ArrayCount(Multiskins); i++)
			{
				if (VMDCanSwapSkinIndex("Cloak", i))
				{
					Multiskins[i] = CloakTex[i+1]; //Texture'WhiteStatic';
				}
			}
			
			ScaleGlow *= 0.1;
			Style = STY_Translucent;
			Texture = CloakTex[8];
			VMDRenderBlock(Can);
		}
		else
		{
			//#ByteProblems ~MADDERS
  			if (HandSkinIndex[0] < ArrayCount(Multiskins)) MultiSkins[HandSkinIndex[0]] = TTex;
			if (HandSkinIndex[1] < ArrayCount(Multiskins)) Multiskins[HandSkinIndex[1]] = TTex;
  			VMDRenderBlock(Can); //MADDERS: Hack for FOV fix.
			
			BL = VMBP.VMDGetBloodLevel();
			
			//THEN render a blood splash on our hands as an additional indicator.
			if (BL > 0)
			{
				RM = 1.0;
				switch (BL)
				{
					case 1:
  						TTex = Texture'WeaponBloodOverlayLight';
					break;
					case 2:
  						TTex = Texture'WeaponBloodOverlayHeavy';
 					break;
				}
				ScaleGlow = OldSG * BloodRenderMult * RM; //Looks like shit at full alpha.
				Style = STY_Translucent;
				
				for (i=0; i<ArrayCount(Multiskins); i++)
				{
					if (VMDCanSwapSkinIndex("Blood", i))
					{
						Multiskins[i] = TTex;
					}
					else if (VMDCanSwapSkinIndex("Backdrop", i))
					{
						Multiskins[i] = Texture'BlackMaskTex';
					}
				}
				
  				VMDRenderBlock(Can);
			}
			//Next, render grime on our gun for info sake.
			if (VMDGetGrimeLevel() > 0)
			{
				RM = 1.0;
				switch (VMDGetGrimeLevel())
				{
					case 1:
						RM = 0.8;
  						TTex = Texture'WeaponGrimeOverlayLight';
					break;
					case 2:
  						TTex = Texture'WeaponGrimeOverlayHeavy';
 					break;
				}
				ScaleGlow = OldSG * GrimeRenderMult * RM; //Looks like shit at full alpha.
				Style = STY_Translucent;
				for (i=0; i<ArrayCount(Multiskins); i++)
				{
					if (VMDCanSwapSkinIndex("Grime", i))
					{
						Multiskins[i] = TTex;
					}
					else if (VMDCanSwapSkinIndex("Backdrop", i))
					{
						Multiskins[i] = Texture'BlackMaskTex';
					}
				}
  				VMDRenderBlock(Can);
			}
			//Finally, render any water on the surface.
			if ((VMDGetWaterLogLevel() > 0) && (!VMDIsWaterZone()))
			{
				RM = 1.0;
				switch (VMDGetWaterLogLevel())
				{
					case 1:
						RM = 0.75;
  						TTex = Texture'WeaponWaterOverlayLight';
					break;
					case 2:
  						TTex = Texture'WeaponWaterOverlayHeavy';
 					break;
				}
				ScaleGlow = OldSG * WaterRenderMult * RM; //Looks like shit at full alpha.
				Style = STY_Translucent;
				for (i=0; i<ArrayCount(Multiskins); i++)
				{
					if (VMDCanSwapSkinIndex("Water", i))
					{
						Multiskins[i] = TTex;
					}
					else if (VMDCanSwapSkinIndex("Backdrop", i))
					{
						Multiskins[i] = Texture'BlackMaskTex';
					}
				}
  				VMDRenderBlock(Can);
			}
		}
		
		//Restore old skins.
		for (i=0; i<ArrayCount(Multiskins); i++)
		{
  			if (i != MuzzleFlashIndex) MultiSkins[i] = OldTex[i];
		}
		Scaleglow = OldSG;
 		Style = OldStyle;
		Texture = OldTexture;
		Fatness = OldFatness;
 	}
 	else
 	{
  		Super.RenderOverlays(Can);
 	}
}

//
// network replication
//
replication
{
    // server to client
    reliable if ((Role == ROLE_Authority) && (bNetOwner))
        ClipCount, bZoomed, bHasSilencer, bHasLaser, ModBaseAccuracy, ModReloadCount, ModAccurateRange, ModReloadTime, ModRecoilStrength;

	// Things the client should send to the server
	//reliable if ( (Role<ROLE_Authority) )
		//LockTimer, Target, LockMode, TargetMessage, TargetRange, bCanTrack, LockTarget;

    // Functions client calls on server
    reliable if ( Role < ROLE_Authority )
        ReloadAmmo, LoadAmmo, CycleAmmo, LaserOn, LaserOff, LaserToggle, ScopeOn, ScopeOff, ScopeToggle, PropagateLockState, ServerForceFire, 
		  ServerGenerateBullet, ServerGotoFinishFire, ServerHandleNotify, StartFlame, StopFlame, ServerDoneReloading, DestroyOnFinish;

    // Functions Server calls in client
    reliable if ( Role == ROLE_Authority )
      RefreshScopeDisplay, ReadyClientToFire, SetClientAmmoParams, ClientDownWeapon, ClientActive, ClientReload;
}


// ---------------------------------------------------------------------
// PropagateLockState()
// ---------------------------------------------------------------------
simulated function PropagateLockState(ELockMode NewMode, Actor NewTarget)
{
   	LockMode = NewMode;
   	LockTarget = NewTarget;
}

// ---------------------------------------------------------------------
// SetLockMode()
// ---------------------------------------------------------------------
simulated function SetLockMode(ELockMode NewMode)
{
   	if ((LockMode != NewMode) && (Role != ROLE_Authority))
   	{
      		if (NewMode != LOCK_Locked)
        		PropagateLockState(NewMode, None);
      		else
         		PropagateLockState(NewMode, Target);
   	}
	TimeLockSet = Level.Timeseconds;
   	LockMode = NewMode;
}

// ---------------------------------------------------------------------
// PlayLockSound()
// Because playing a sound from a simulated function doesn't play it 
// server side.
// ---------------------------------------------------------------------
function PlayLockSound()
{
	local float TPitch;
	
	if ((ScriptedPawn(Owner) != None) && (ScriptedPawn(Owner).Enemy == None) && (DeusExPlayer(Target) == None))
	{
		return;
	}
	
	TPitch = 1.0;
	if (Owner != None)
	{
		if (VMDIsWaterZone()) TPitch = 0.7;
   		Owner.PlaySound(LockedSound, SLOT_None,,,, TPitch);
	}
}

//
// install the correct projectile info if needed
//
function TravelPostAccept()
{
	local int i;
	
	Super.TravelPostAccept();
	
	//MADDERS, 12/29/20: Apply religiously.
	VMDFixInvGrouping();
	VMDUpdateEvoName();
	
	// make sure the AmmoName matches the currently loaded AmmoType
	if (AmmoType != None)
		AmmoName = AmmoType.Class;
	
	if (!bInstantHit)
	{
		if (ProjectileClass != None)
			ProjectileSpeed = ProjectileClass.Default.speed;

		// make sure the projectile info matches the actual AmmoType
		// since we can't "var travel class" (AmmoName and ProjectileClass)
		if (AmmoType != None)
		{
			//FireSound = None;
			for (i=0; i<ArrayCount(AmmoNames); i++)
			{
				if (AmmoNames[i] == AmmoName)
				{
					ProjectileClass = ProjectileNames[i];
					break;
				}
			}
		}
	}
	
	//MADDERS: Update our evolution!
	VMDUpdateEvolution();
	//MADDERS, 5/8/25: Also update our weapon mods. For future stuff.
	VMDUpdateWeaponModStats();
	
	//MADDERS: Fix for busted fire sounds.
	VMDAlertPostAmmoLoad(bInstantHit);
	FireSound = VMDGetIntendedFireSound(AmmoType);
	
	//DXT: This stuff.
	// Make the object follow us, for AmbientSound mainly
	if ((Owner != None) && (Level.NetMode == NM_Standalone))
	{
		AttachTag = Owner.Name;
		SetPhysics(PHYS_Trailer);
	}
	if ( bDestroyOnFinish )
	{
		// if ReloadCount is 0 and we're not hand to hand, then this is a
		// single-use weapon so destroy it after firing once
		/*if ((ReloadCount == 0) && (!bHandToHand))
		{
			SubstituteOnBelt(); // Transcended - If this item is on the belt, find another copy in the inventory and place it on the belt, if it isn't already on it.
			
			if (DeusExPlayer(Owner) != None)
				DeusExPlayer(Owner).RemoveItemFromSlot(Self);   // remove it from the inventory grid
		}*/
		
		Log("MADDERS DEBUG! WEAPON"@Self@"DELETING SELF BECAUSE WE WERE DESTROY ON FINISH ON TRAVEL POST ACCEPT!");
		
		bWasZoomed = False;
		if (bZoomed)
		{
			ScopeOff();
		}
		LaserOff();
		if (DeusExPlayer(Owner) != None)
		{
			DeusExPlayer(Owner).DeleteInventory(Self);
		}
		Destroy();
	}
}


//
// PreBeginPlay
//

function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Default.mpPickupAmmoCount == 0 )
	{
		Default.mpPickupAmmoCount = Default.PickupAmmoCount;
	}
}

//
// PostBeginPlay
//

function PostBeginPlay()
{
	Super.PostBeginPlay();
   	if (Level.NetMode != NM_Standalone)
   	{
      		bWeaponStay = True;
      		if (bNeedToSetMPPickupAmmo)
      		{
         		PickupAmmoCount = PickupAmmoCount * 3;
         		bNeedToSetMPPickupAmmo = False;
      		}
   	}
	
	VMDWeaponPostBeginPlayHook();
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	//MADDERS, 4/16/24: Apply this stuff more often.
	VMDWeaponPostBeginPlayHook();
}

singular function BaseChange()
{
	Super.BaseChange();

	// Make sure we fall if we don't have a base
	if ((base == None) && (Owner == None))
		SetPhysics(PHYS_Falling);
}

function VMDTransferWeaponMods(DeusExWeapon WFrom, DeusExWeapon WTo)
{
	local int NewWeaponModCount;
	local float SkillAugmentMod, OldWeaponModCount;
	local Pawn TPawn;
	
	if (WFrom == None || WTo == None || Pawn(WTo.Owner) == None || WFrom.Class != WTo.Class)
	{
		return;
	}
	TPawn = Pawn(WTo.Owner);
	
	SkillAugmentMod = 0.0;
	switch(WTo.GoverningSkill)
	{
		case class'SkillWeaponPistol':
			SkillAugmentMod = 0.2 * int(!WTo.VMDHasSkillAugment('PistolModding'));
		break;
		case class'SkillWeaponRifle':
			SkillAugmentMod = 0.2 * int(!WTo.VMDHasSkillAugment('RifleModding'));
		break;
	}
	
	//1111111111111111111111111
	//ACCURACY
	if (WFrom.ModBaseAccuracy > 0.0)
	{
		OldWeaponModCount = WTo.ModBaseAccuracy;
		WTo.ModBaseAccuracy = FClamp(WFrom.ModBaseAccuracy + WTo.ModBaseAccuracy, 0.0, 0.5 - SkillAugmentMod);
		NewWeaponModCount = int((WTo.ModBaseAccuracy - OldWeaponModCount) / 0.1);
		if (NewWeaponModCount > 1)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[1], ItemName, NewWeaponModCount, ModNames[0]));
		}
		else if (NewWeaponModCount > 0)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[0], ItemName, NewWeaponModCount, ModNames[0]));
		}
	}
	
	//2222222222222222222222222
	//RELOAD COUNT
	if (WFrom.ModReloadCount > 0.0)
	{
		OldWeaponModCount = WTo.ModReloadCount;
		WTo.ModReloadCount = FClamp(WFrom.ModReloadCount + WTo.ModReloadCount, 0.0, 0.5 - SkillAugmentMod);
		NewWeaponModCount = int((WTo.ModReloadCount - OldWeaponModCount) / 0.1);
		if (NewWeaponModCount > 1)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[1], ItemName, NewWeaponModCount, ModNames[1]));
		}
		else if (NewWeaponModCount > 0)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[0], ItemName, NewWeaponModCount, ModNames[1]));
		}
	}
	
	//3333333333333333333333333
	//RANGE
	if (WFrom.ModAccurateRange > 0.0)
	{
		OldWeaponModCount = WTo.ModAccurateRange;
		WTo.ModAccurateRange = FClamp(WFrom.ModAccurateRange + WTo.ModAccurateRange, 0.0, 0.5 - SkillAugmentMod);
		NewWeaponModCount = int((WTo.ModAccurateRange - OldWeaponModCount) / 0.1);
		if (NewWeaponModCount > 1)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[1], ItemName, NewWeaponModCount, ModNames[4]));
		}
		else if (NewWeaponModCount > 0)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[0], ItemName, NewWeaponModCount, ModNames[4]));
		}
	}
	
	//4444444444444444444444444
	//RELOAD
	if (WFrom.ModReloadTime < 0)
	{
		OldWeaponModCount = WTo.ModReloadTime;
		WTo.ModReloadTime = FClamp(WFrom.ModReloadTime + WTo.ModReloadTime, -0.5 + SkillAugmentMod, 0.0);
		NewWeaponModCount = int((WTo.ModReloadTime - OldWeaponModCount) / -0.1);
		if (NewWeaponModCount > 1)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[1], ItemName, NewWeaponModCount, ModNames[6]));
		}
		else if (NewWeaponModCount > 0)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[0], ItemName, NewWeaponModCount, ModNames[6]));
		}
	}
	
	//5555555555555555555555555
	//RECOIL
	if (WFrom.ModRecoilStrength < 0)
	{
		OldWeaponModCount = WTo.ModRecoilStrength;
		WTo.ModRecoilStrength = FClamp(WFrom.ModRecoilStrength + WTo.ModRecoilStrength, -0.5 + SkillAugmentMod, 0.0);
		NewWeaponModCount = int((WTo.ModRecoilStrength - OldWeaponModCount) / -0.1);
		if (NewWeaponModCount > 1)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[1], ItemName, NewWeaponModCount, ModNames[5]));
		}
		else if (NewWeaponModCount > 0)
		{
			TPawn.ClientMessage(SprintF(MsgMergedMods[0], ItemName, NewWeaponModCount, ModNames[5]));
		}
	}
	
	//MADDERS: Don't let porting over of illegitimate mods.
	if ((WFrom.bHasLaser) && (WTo.bCanHaveLaser) && (!WTo.bHasLaser))
	{
		WTo.bHasLaser = True;
		TPawn.ClientMessage(SprintF(WTo.MsgGainedMod, WTo.ItemName, WTo.ModNames[3]));
	}
	if ((WFrom.bHasSilencer) && (WTo.bCanHaveSilencer) && (!WTo.bHasSilencer))
	{
		WTo.bHasSilencer = True;
		TPawn.ClientMessage(SprintF(WTo.MsgGainedMod, WTo.ItemName, WTo.ModNames[8]));
	}
	if ((WFrom.bHasScope) && (WTo.bCanHaveScope) && (!WTo.bHasScope))
	{
		WTo.bHasScope = True;
		TPawn.ClientMessage(SprintF(WTo.MsgGainedMod, WTo.ItemName, WTo.ModNames[7]));
	}
	if ((WFrom.bHasEvolution) && (bCanHaveModEvolution) && (!bHasEvolution))
	{
		WTo.bHasEvolution = True;
		TPawn.ClientMessage(SprintF(WTo.MsgGainedMod, WTo.ItemName, WTo.ModNames[2]));
		WTo.VMDUpdateEvolution();
	}
	
	// copy the actual stats as well
	//if ((WFrom.ReloadCount > WTo.ReloadCount) && (!WTo.bHasEvolution))
	//	WTo.ReloadCount = WFrom.ReloadCount;
	
	//if (WFrom.AccurateRange > WTo.AccurateRange)
	//	WTo.AccurateRange = WFrom.AccurateRange;
	
	// these are negative
	//if (WFrom.BaseAccuracy < WTo.BaseAccuracy)
	//	WTo.BaseAccuracy = WFrom.BaseAccuracy;
	//if ((WFrom.ReloadTime < WTo.ReloadTime) && (!WTo.bHasEvolution))
	//	WTo.ReloadTime = WFrom.ReloadTime;
	//if (WFrom.RecoilStrength < WTo.RecoilStrength)
	//	WTo.RecoilStrength = WFrom.RecoilStrength;
	
	VMDUpdateWeaponModStats();
}

function bool HandlePickupQuery(Inventory Item)
{
	local DeusExWeapon W;
	local DeusExPlayer player;
	local bool bResult;
	local class<Ammo> defAmmoClass;
	local Ammo defAmmo;
	
	local DeusExAmmo DXA;
	local DeusExRootWindow DXRW;
	
	// make sure that if you pick up a modded weapon that you
	// already have, you get the mods
	W = DeusExWeapon(Item);
	if ((W != None) && (W.Class == Class))
	{
		VMDTransferWeaponMods(W, Self);
	}
	
	player = DeusExPlayer(Owner);
	if (Player != None)
	{
		DXRW = DeusExRootWindow(Player.RootWindow);
	}
	
	if (Item.Class == Class)
	{
      		if (!((Weapon(item).bWeaponStay) && (Level.NetMode == NM_Standalone) && (!Weapon(item).bHeldItem || Weapon(item).bTossedOut)))
		{
			// Only add ammo of the default type
			// There was an easy way to get 32 20mm shells, buy picking up another assault rifle with 20mm ammo selected
			if ( AmmoType != None )
			{
				//MADDERS, 4/27/25: Let us loot what the gat has in it.
				if (W.AmmoName != None)
				{
					DefAmmoClass = W.AmmoName;
				}
				// Add to default ammo only
				else if ( AmmoNames[0] == None )
				{
					defAmmoClass = AmmoName;
				}
				else
				{
					defAmmoClass = AmmoNames[0];
				}
				
				defAmmo = Ammo(player.FindInventoryType(defAmmoClass));
				
				DXA = DeusExAmmo(DefAmmo);
				if ((!DeusExWeapon(Item).VMDHackbReceivedIconBlock) && (DXA != None) && (DXRW != None) && (DXRW.HUD != None) && (DXRW.HUD.ReceivedItems != None))
				{
					if ((Weapon(Item).PickupAmmoCount > 0) && (DXA.AmmoAmount < DXA.VMDConfigureMaxAmmo()))
					{
						DXRW.Hud.ReceivedItems.AddItem(DXA, Weapon(Item).PickupAmmoCount);
					}
				}
				DeusExWeapon(Item).VMDHackbReceivedIconBlock = false;
				
				defAmmo.AddAmmo( Weapon(Item).PickupAmmoCount );
				
				if ( Level.NetMode != NM_Standalone )
				{
					if (( player != None ) && ( player.InHand != None ))
					{
						if ( DeusExWeapon(item).class == DeusExWeapon(player.InHand).class )
							ReadyToFire();
					}
				}
			}
		}
	}
	
	bResult = VMDFakeSuperHandlePickupQuery(Item);
	
	// Notify the object belt of the new ammo
	if (player != None)
		player.UpdateBeltText(Self);
	
	return bResult;
}

function BringUp()
{
	if ( Level.NetMode != NM_Standalone )
		ReadyClientToFire( False );
	
	// alert NPCs that I'm whipping it out
	if (!bNativeAttack && bEmitWeaponDrawn)
		AIStartEvent('WeaponDrawn', EAITYPE_Visual);

	// reset the standing still accuracy bonus
	if (!ShouldUseGP2())
	{
		standingTimer = 0;
	}
	
	//MADDERS, 12/29/20: Apply religiously.
	VMDFixInvGrouping();
	
	//MADDERS: Activate automatically!
	if ((bHasLaser) && (!bLasing)) LaserOn();

	ResetShake();

	Super.BringUp();
}

function bool PutDown()
{
	if ( Level.NetMode != NM_Standalone )
		ReadyClientToFire( False );

	// alert NPCs that I'm putting away my gun
	AIEndEvent('WeaponDrawn', EAITYPE_Visual);

	// reset the standing still accuracy bonus
	standingTimer = 0;

	return Super.PutDown();
}

function ReloadAmmo()
{
	local bool bDoesCleaning, bMagFull;
	
	// single use or hand to hand weapon if ReloadCount == 0
	if (ReloadCount == 0)
	{
		Pawn(Owner).ClientMessage(msgCannotBeReloaded);
		return;
	}
	
	if (VMDHasReloadObjection()) return;
	
	/*bDoesCleaning = true;
	if (VMDGetGrimeLevel() <= 0) bDoesCleaning = false;
	if ((FiringSystemOperation == 2) && (VMDHasSkillAugment('TagTeamOpenGrimeproof'))) bDoesCleaning = false;*/
	
	//MADDERS: Save effort real quick here.
	bMagFull = (ClipCount <= 0 - int(VMDHasOpenSystemMagBoost()) || (ReloadCount-ClipCount) >= AmmoType.AmmoAmount);
	
	if ((bMagFull) && (bDoesCleaning))
	{
		if (VMDGetGrimeLevel() > 0)
			GoToState('CleanWeapon');
	}
	else if ((bLastShotJammed) && (bDoesCleaning))
	{
		if (VMDGetGrimeLevel() > 0)
			GoToState('CleanWeapon');
	}
	else if (!IsInState('Reload'))
	{
		//MADDERS: Inspired by Nihilum's broken-ass still animation on its Walther, AKA WeaponBeretta... Sigh.
		if (bMagFull) return;
		
		//MADDERS: HACK for PS20!
		if (HasAnim('Reload')) TweenAnim('Still', 0.1);
		
		GotoState('Reload');
	}
}

//
// Note we need to control what's calling this...but I'll get rid of the access nones for now
//
simulated function float GetWeaponSkill()
{
	local DeusExPlayer player;
	local float value;
	
	value = 0;
	
	if (Owner != None)
	{
		player = DeusExPlayer(Owner);
		if (player != None)
		{
			if ((player.AugmentationSystem != None ) && (player.SkillSystem != None))
			{
				// get the target augmentation
				value = player.AugmentationSystem.GetAugLevelValue(class'AugTarget');
				if (value < 0)
				{
					value = 0;
				}
				
				// get the skill
				value += player.SkillSystem.GetSkillLevelValue(GoverningSkill);
			}
		}
	}
	return value;
}

// calculate the accuracy for this weapon and the owner's damage
simulated function float CalculateAccuracy()
{
	local bool bCheckIt;
	local int THand, SkillLevel;
	local float Accuracy, TAcc, TDiv, TSkill;
	
	local DeusExPlayer player;
	local ScriptedPawn SP;
	local VMDBufferPlayer VMP;
	local float LasMod, SingleHanderPenalty;
	
	Accuracy = BaseAccuracy; // start with the weapon's base accuracy
   	TSkill = VMDGetWeaponSkill("ACCURACY");
	
	Player = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Owner);
	SP = ScriptedPawn(Owner);
	
	if (VMP != None)
	{
	 	Accuracy += VMP.VMDConfigureAimModifier();
	}
	
	Accuracy += FactorWM2AccModifier();
	
	if (Player != None)
	{
		// check the player's skill
		// 0.0 = dead on, 1.0 = way off
		//MADDERS, 5/2/25: Let accuracy be more organic in GP2.0. We affect aim margin differently.
		if (!ShouldUseGP2())
		{
			Accuracy += TSkill;
		}
		else
		{
			//MADDERS, 5/3/25: Balancing cludge for assault gun not getting buffed yet.
			if (WeaponAssaultGun(Self) != None)
			{
				Accuracy -= 0.15;
			}
		}
		
		bCheckIt = True;
	}
	else if (SP != None)
	{
		// update the weapon's accuracy with the ScriptedPawn's BaseAccuracy
		// (BaseAccuracy uses higher values for less accuracy, hence we add)
		Accuracy += SP.BaseAccuracy;
		
		bCheckIt = True;
		
		if ((VMDIsBulletWeapon()) && (WeaponRifle(Self) == None) && (VMDMEGH(SP.Enemy) != None || VMDSIDD(SP.Enemy) != None))
		{
			if (VMDBountyHunter(Owner) != None)
			{
				Accuracy += 0.2;
			}
			else
			{
				Accuracy -= 0.1 + (FMax(-0.1, SP.BaseAccuracy));
			}
		}
		
		if (VMDIsWeaponName("HideAGun"))
		{
			Accuracy = 0.3;
		}
	}
	else
	{
		bCheckIt = False;
	}
	
	// Disabled accuracy mods based on health in multiplayer
	if (Level == None || Level.NetMode != NM_Standalone || (ProjectileClass == None && !VMDIsBulletWeapon()))
	{
		bCheckIt = False;
	}
	
	if (bCheckIt)
	{
		Accuracy += VMDGetWoundAccuracyPenalty();
		
		//MADDERS: Alt ammos can change accuracy one way or the other.
		//NOTE: We uniquely give exactly 0 fucks if the skill augments setting is off.
		if ((VMP != None) && (VMP.ShouldUseSkillAugments()) && (AmmoType != None) && (AmmoNames[0] != None) && (AmmoType.Class != AmmoNames[0]))
		{
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
					if (VMDOtherIsName(Self, "Crossbow"))
					{
						if (VMDHasSkillAugment('PistolAltAmmos')) Accuracy -= 0.3;
						else Accuracy += 0.15;
					}
				break;
				case class'SkillWeaponRifle':
					if (AmmoSabot(AmmoType) != None || AmmoTaserSlug(AmmoType) != None)
					{
						if (VMDHasSkillAugment('RifleAltAmmos')) Accuracy -= 0.15;
						else Accuracy += 0.15;
					}
					if (Ammo3006Tranq(AmmoType) != None)
					{
						if (VMDHasSkillAugment('RifleAltAmmos')) Accuracy += 0.15;
						else Accuracy += 0.45;
					}
				break;
			}
		}
	}
	
	// increase accuracy (decrease value) if we haven't been moving for awhile
	// this only works for the player, because NPCs don't need any more aiming help!
	if (Player != None)
	{
		TAcc = Accuracy;
		if (StandingTimer > 0)
		{
			//MADDERS, 5/2/25: For GP2.0, go much finer.
			if (ShouldUseGP2())
			{
				//GP2.0: We don't give a shit about skill anymore.
				TDiv = FMax(15.0, 0.0);
				Accuracy -= FClamp(StandingTimer/TDiv, 0.0, 0.6);
				
				// don't go too low
				if ((Accuracy < 0.05 * (1.0 - ModBaseAccuracy)) && (TAcc > 0.05 * (1.0 - ModBaseAccuracy)))
				{
					Accuracy = 0.05 * (1.0 - ModBaseAccuracy);
				}
			}
			else
			{
				// higher skill makes standing bonus greater
				TDiv = FMax(15.0 + 29.0 * TSkill, 0.0);
				Accuracy -= FClamp(StandingTimer/TDiv, 0.0, 0.6);
				
				// don't go too low
				if ((Accuracy < 0.1) && (TAcc > 0.1))
				{
					Accuracy = 0.1;
				}
			}
		}
	}
	
	if (ShouldUseGP2())
	{
		SkillLevel = Player.SkillSystem.GetSkillLevel(GoverningSkill);
		Accuracy *= SkillAccuracyFactors[SkillLevel];
	}
	
	// make sure we don't go negative
	if (Accuracy < 0.0)
	{
		Accuracy = 0.0;
	}
   	if (Level.NetMode != NM_Standalone)
	{
		if (Accuracy < MinWeaponAcc)
		{
			Accuracy = MinWeaponAcc;
		}
	}
	
	//MADDERS: Apply buffs/nerfs for other things.
	if (bLasing)
	{
		//MADDERS, 5/2/25: For GP2.0, heavily reduce the bonus. The laser tells all at base, and that's plenty.
		if (ShouldUseGP2())
		{
			LasMod = 1.5;
			
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
					if (!VMDHasSkillAugment('PistolModding')) LasMod = 1.25;
				break;
				case class'SkillWeaponRifle':
					if (!VMDHasSkillAugment('RifleModding')) LasMod = 1.25;
				break;
			}
		}
		else
		{
			LasMod = 3.0;
			
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
					if (!VMDHasSkillAugment('PistolModding')) LasMod /= 2;
				break;
				case class'SkillWeaponRifle':
					if (!VMDHasSkillAugment('RifleModding')) LasMod /= 2;
				break;
			}
		}
		
		Accuracy /= LasMod;
	}
	
	//MADDERS, 4/2/21: Relocated from TraceFire/ProjectileFire.
	//----------
	// if there is a scope, but the player isn't using it, decrease the accuracy
	// so there is an advantage to using the scope
	//----------
	//MADDERS, 3/22/23: Removed penalty for Nihilum LMG though.
	if ((SP == None) && (bHasScope) && (!bZoomed) && (WeaponLAW(Self) == None) && (!IsA('WeaponM249DXN') || !IsA('WeaponPara17')))
	{
		if (GoverningSkill != class'SkillWeaponPistol' || !VMDHasSkillAugment('PistolScope')) 
		{
			Accuracy += 0.2;
		}
	}
	
	return Accuracy;
}

function float VMDGetWoundAccuracyPenalty()
{
	local bool bLeftHanded, bWrongArm;
	local int THand, HealthArmLeft, HealthArmRight, HealthHead, BestArmLeft, BestArmRight, BestHead;
	local float HMult, ModMult, Ret, SingleHanderPenalty;
	local DeusExPlayer Player;
	local VMDBufferPlayer VMP;
	local ScriptedPawn SP;
	
	//MADDERS, 3/27/25: Dying goons should not laser us. Make them spray wildly.
	if ((Owner != None) && (Owner.IsInState('Dying')))
	{
		return 2.0;
	}
	
	Player = DeusExPlayer(Owner);
	VMP = VMDBufferPlayer(Owner);
	SP = ScriptedPawn(Owner);
	
	HMult = 1.0;
	ModMult = 1.0;
	if (VMP != None)
	{
		if (VMP.KSHealthMult > 0)
		{
			HMult *= VMP.KSHealthMult;
		}
		if (VMP.ModHealthMultiplier > 0)
		{
			HMult *= VMP.ModHealthMultiplier;
		}
		
		THand = GetHandType();
		if (VMP.Handedness == 1)
		{
			if (THand == -1)
			{
				bLeftHanded = false;
				bWrongArm = true;
			}
			else
			{
				bLeftHanded = true;
			}
		}
		else if (VMP.Handedness == -1)
		{
			if (THand == 1)
			{
				bLeftHanded = true;
				bWrongArm = true;
			}
			else
			{
				bLeftHanded = false;
			}
		}
	}
	
	SingleHanderPenalty = 1.0;
	if (Player != None)
	{
		if ((VMP != None) && (VMP.bUseSharedHealth))
		{
			ModMult *= 0.35;
		}
		
		//MADDERS, 6/2/25: Halve effect of wounds on raw accuracy for GP2.0.
		if (ShouldUseGP2())
		{
			ModMult *= 0.35;
		}
		
		// get the health values for the player
		HealthArmRight = Player.HealthArmRight;
		
		//MADDERS, 12/14/21: One hander? Only one hand matters.
		if (VMDIsTwoHandedWeapon())
		{
			HealthArmLeft = Player.HealthArmLeft;
		}
		else
		{
			SingleHanderPenalty = 2.0;
			if (bLeftHanded)
			{
				HealthArmLeft = Player.HealthArmLeft;
				HealthArmRight = 100;
			}
			else
			{
				HealthArmLeft = 100;
				HealthArmRight = Player.HealthArmRight;
			}
		}
		HealthHead = Player.HealthHead;
		BestArmRight = Player.Default.HealthArmRight;
		BestArmLeft = Player.Default.HealthArmLeft;
		BestHead = Player.Default.HealthHead;
	}
	else if (SP != None)
	{
		// get the health values for the NPC
		HealthArmRight = SP.HealthArmRight;
		HealthArmLeft = SP.HealthArmLeft;
		HealthHead = SP.HealthHead;
		BestArmRight = SP.Default.HealthArmRight;
		BestArmLeft = SP.Default.HealthArmLeft;
		BestHead = SP.Default.HealthHead;
	}
	
	if (bLeftHanded)
	{
		if (HealthArmRight < 1)
		{
			Ret += 0.5 * ModMult;
		}
		else if (HealthArmRight < BestArmRight * 0.34 * HMult)
		{
			Ret += 0.2 * ModMult;
		}
		else if (HealthArmRight < BestArmRight * 0.67 * HMult)
		{
			Ret += 0.1 * ModMult;
		}
		
		if (HealthArmLeft < 1)
		{
			Ret += 0.5 * SingleHanderPenalty * ModMult;
		}
		else if (HealthArmLeft < BestArmLeft * 0.34 * HMult)
		{
			Ret += 0.2 * SingleHanderPenalty * ModMult;
		}
		else if (HealthArmLeft < BestArmLeft * 0.67 * HMult)
		{
			Ret += 0.1 * SingleHanderPenalty * ModMult;
		}
	}
	else
	{
		if (HealthArmRight < 1)
		{
			Ret += 0.5 * SingleHanderPenalty * ModMult;
		}
		else if (HealthArmRight < BestArmRight * 0.34 * HMult)
		{
			Ret += 0.2 * SingleHanderPenalty * ModMult;
		}
		else if (HealthArmRight < BestArmRight * 0.67 * HMult)
		{
			Ret += 0.1 * SingleHanderPenalty * ModMult;
		}
		
		if (HealthArmLeft < 1)
		{
			Ret += 0.5 * ModMult;
		}
		else if (HealthArmLeft < BestArmLeft * 0.34 * HMult)
		{
			Ret += 0.2 * ModMult;
		}
		else if (HealthArmLeft < BestArmLeft * 0.67 * HMult)
		{
			Ret += 0.1 * ModMult;
		}
	}
	
	if (HealthHead < BestHead * 0.67 * HMult)
	{
		Ret += 0.1 * ModMult;
	}
	
	//MADDERS, 5/29/23: Wrong hand? Yeah, we aren't ambidextrous.
	if (bWrongArm)
	{
		Ret += 0.1 * SingleHanderPenalty;
	}
	
	return Ret;
}

//
// functions to change ammo types
//
function bool LoadAmmo(int ammoNum)
{
	local class<Ammo> newAmmoClass;
	local Ammo newAmmo;
	local Pawn P;
	
	if (ammoNum < 0 || ammoNum > 2 || (VMDBufferPlayer(Owner) != None && VMDBufferPlayer(Owner).TaseDuration > 0))
		return False;
	
	//MADDERS, 7/24/21: We were witnessed as having been ran as god intended.
	bLoadAmmoFudge = true;
	
	P = Pawn(Owner);
	
	// sorry, only pawns can have weapons
	if (P == None)
		return False;
	
	newAmmoClass = AmmoNames[ammoNum];
	
	if (newAmmoClass != None)
	{
		if (newAmmoClass != AmmoName)
		{
			newAmmo = Ammo(P.FindInventoryType(newAmmoClass));
			if (newAmmo == None)
			{
				//MADDERS: Don't reveal unknown ammo types.
				//P.ClientMessage(Sprintf(msgOutOf, newAmmoClass.Default.ItemName));
				return False;
			}
			if ((NewAmmo.AmmoAmount <= 0) && (NewAmmo != AmmoNames[0]))
			{
				//MADDERS: However, DO give feedback if we're truly out of ammo. 2 for 1 special, bby.
				P.ClientMessage(Sprintf(msgOutOf, newAmmoClass.Default.ItemName));
				return False;
			}
			
			//MADDERS: Fix our check for max mag size borking up ammo changes!
			if (VMDHasParallelAmmoFeed())
			{
				if (!VMDHandleParallelAmmoFeed(AmmoNames[AmmoNum], NewAmmo, AmmoNum))
				{
					return false;
				}
			 	
				//MADDERS: Don't let spamming ammo swap glitch out animations.
				PlayAnim('Still');
				EraseMuzzleFlashTexture();
			}
			else
			{
				if (ScriptedPawn(Owner) == None)
				{
					//MADDERS, 6/28/24: Hack for repeated cycling of ammos not dropping mags, conservative hack it may be.
					bReloadWasntEmpty = (ClipCount < ReloadCount || bReloadWasntEmpty);
					ClipCount = ReloadCount;
				}
			}
			
			//MADDERS: Update our stats!
			VMDAlertAmmoLoad( (ProjectileNames[AmmoNum] == None) );
			
			// if we don't have a projectile for this ammo type, then set instant hit
			if (ProjectileNames[ammoNum] == None)
			{
				bInstantHit = True;
				
				if ( Level.NetMode != NM_Standalone )
				{
					if (HasReloadMod())
						ReloadTime = mpReloadTime * (1.0+ModReloadTime);
					else
						ReloadTime = mpReloadTime;
				}
				else
				{
					ReloadTime = VMDGetCorrectReloadTime(Default.ReloadTime);
					/*if (HasReloadMod())
						ReloadTime = Default.ReloadTime * (1.0+ModReloadTime);
					else
						ReloadTime = Default.ReloadTime;*/
				}
				//FireSound = Default.FireSound;
				ProjectileClass = None;
			}
			else
			{
				// otherwise, set us to fire projectiles
				bInstantHit = False;
				
				//MADDERS: MAKE OUR DEFAULT STATS APPLY CONSISTENTLY! Thank you!
				if (AmmoNum != 0)
				{
					ReloadTime = VMDGetCorrectReloadTime(Default.ReloadTime);
				 	//FireSound = None;		// handled by the projectile
				}
				ProjectileClass = ProjectileNames[ammoNum];
				ProjectileSpeed = ProjectileClass.Default.Speed;
			}

			AmmoName = newAmmoClass;
			AmmoType = newAmmo;
			
			//MADDERS: Let us know we were loaded with a new type!
			VMDAlertPostAmmoLoad( (ProjectileNames[AmmoNum] == None) );
			
			//MADDERS: Fix for GEP evolved form.
			VMDUpdateEvolution();
			VMDUpdateWeaponModStats();
			
			// AlexB had a new sound for 20mm but there's no mechanism for playing alternate sounds per ammo type
			// Same for WP rocket
			//if ( Ammo20mm(newAmmo) != None )
			//	FireSound = Sound'AssaultGunFire20mm';
			//else if ( AmmoRocketWP(newAmmo) != None )
			//	FireSound = Sound'GEPGunFireWP';
			//else if ( AmmoRocket(newAmmo) != None )
			//	FireSound = Sound'GEPGunFire';
			FireSound = VMDGetIntendedFireSound(newAmmo);
			
			if ( Level.NetMode != NM_Standalone )
				SetClientAmmoParams( bInstantHit, bAutomatic, ShotTime, FireSound, ProjectileClass, ProjectileSpeed );
			
			// Notify the object belt of the new ammo
			if (DeusExPlayer(P) != None)
				DeusExPlayer(P).UpdateBeltText(Self);
			
			//MADDERS: Don't do this for the assault gun.
			if ((!VMDHasParallelAmmoFeed()) && (ScriptedPawn(Owner) == None))
			{
				bReloadFromEmpty = True;
			 	ReloadAmmo();
			}
			else
			{
			 	GoToState('Idle');
			}
			
			P.ClientMessage(Sprintf(msgNowHas, ItemName, newAmmoClass.Default.ItemName));
			
			return True;
		}
		else
		{
			P.ClientMessage(Sprintf(MsgAlreadyHas, ItemName, newAmmoClass.Default.ItemName));
		}
	}

	return False;
}

// ----------------------------------------------------------------------
//
// ----------------------------------------------------------------------

simulated function SetClientAmmoParams( bool bInstant, bool bAuto, float sTime, Sound FireSnd, class<projectile> pClass, float pSpeed )
{
	bInstantHit = bInstant;
	bAutomatic = bAuto;
	ShotTime = sTime;
	FireSound = FireSnd;
	ProjectileClass = pClass;
	ProjectileSpeed = pSpeed;
}

// ----------------------------------------------------------------------
// CanLoadAmmoType()
//
// Returns True if this ammo type can be used with this weapon
// ----------------------------------------------------------------------

simulated function bool CanLoadAmmoType(Ammo ammo)
{
	local int  ammoIndex;
	local bool bCanLoad;

	bCanLoad = False;

	if (ammo != None)
	{
		// First check "AmmoName"

		if (AmmoName == ammo.Class)
		{
			bCanLoad = True;
		}
		else
		{
			for (ammoIndex=0; ammoIndex<3; ammoIndex++)
			{
				if (AmmoNames[ammoIndex] == ammo.Class)
				{
					bCanLoad = True;
					break;
				}
			}
		}
	}

	return bCanLoad;
}

// ----------------------------------------------------------------------
// LoadAmmoType()
// 
// Load this ammo type given the actual object
// ----------------------------------------------------------------------

function LoadAmmoType(Ammo ammo)
{
	local int i;

	if (ammo != None)
	{
		for (i=0; i<3; i++)
		{
			if (AmmoNames[i] == ammo.Class)
			{
				//MADDERS, 7/24/21: Check that LoadAmmo was ran as god intended.
				bLoadAmmoFudge = false;
				if (LoadAmmo(i))
				{
					//If not? Load this shit from empty. We ain't gots no businesses here.
					if (!bLoadAmmoFudge)
					{
						bReloadFromEmpty = True;
						if (ScriptedPawn(Owner) == None)
						{
							ClipCount = ReloadCount;
						}
			 			ReloadAmmo();
					}
				}
			}
		}
	}
}

// ----------------------------------------------------------------------
// LoadAmmoClass()
// 
// Load this ammo type given the class
// ----------------------------------------------------------------------

function LoadAmmoClass(Class<Ammo> ammoClass)
{
	local int i;

	if (ammoClass != None)
	{
		for (i=0; i<3; i++)
		{
			if (AmmoNames[i] == ammoClass)
			{
				bLoadAmmoFudge = false;
				if (LoadAmmo(i))
				{
					//If not? Load this shit from empty. We ain't gots no businesses here.
					if (!bLoadAmmoFudge)
					{
						bReloadFromEmpty = True;
						if (ScriptedPawn(Owner) == None)
						{
							ClipCount = ReloadCount;
						}
			 			ReloadAmmo();
					}
				}
			}
		}
	}
}

// ----------------------------------------------------------------------
// CycleAmmo()
// ----------------------------------------------------------------------

function CycleAmmo()
{
	local int i, last;
	
	if (NumAmmoTypesAvailable() < 2 || (VMDBufferPlayer(Owner) != None && VMDBufferPlayer(Owner).TaseDuration > 0))
		return;

	for (i=0; i<ArrayCount(AmmoNames); i++)
		if (AmmoNames[i] == AmmoName)
			break;

	last = i;

	do
	{
		if (++i >= 3)
			i = 0;
		
		bLoadAmmoFudge = false;
		if (LoadAmmo(i))
		{
			//If not? Load this shit from empty. We ain't gots no businesses here.
			if (!bLoadAmmoFudge)
			{
				bReloadFromEmpty = True;
				if (ScriptedPawn(Owner) == None)
				{
					ClipCount = ReloadCount;
				}
				ReloadAmmo();
			}
			break;
		}
	} until (last == i);
}

simulated function bool CanReload()
{
	if ((ClipCount > 0) && (ReloadCount != 0) && (AmmoType != None) && (AmmoType.AmmoAmount > 0) && (AmmoType.AmmoAmount > (ReloadCount-ClipCount)))
		return true;
	else
		return false;
}

simulated function bool MustReload()
{
	if ((AmmoLeftInClip() == 0) && (AmmoType != None) && (AmmoType.AmmoAmount > 0))
		return true;
	else
		return false;
}

simulated function int AmmoLeftInClip()
{
	if (ReloadCount == 0)	// if this weapon is not reloadable
	{
		return 1;
	}
	else if (AmmoType == None || AmmoType.AmmoAmount == 0) // if we are out of ammo
	{
		return 0;
	}
	else
	{
		return Min(AmmoType.AmmoAmount, ReloadCount-ClipCount); // if we have no clips left
	}
}

simulated function int NumClips()
{
	if (ReloadCount == 0)  // if this weapon is not reloadable
		return 0;
	else if (AmmoType == None)
		return 0;
	else if (AmmoType.AmmoAmount == 0)	// if we are out of ammo
		return 0;
	else  // compute remaining clips
		return ((AmmoType.AmmoAmount-AmmoLeftInClip()) + (ReloadCount-1)) / ReloadCount;
}

simulated function int AmmoAvailable(int ammoNum)
{
	local class<Ammo> newAmmoClass;
	local Ammo newAmmo;
	local Pawn P;

	P = Pawn(Owner);

	// sorry, only pawns can have weapons
	if (P == None)
		return 0;

	newAmmoClass = AmmoNames[ammoNum];

	if (newAmmoClass == None)
		return 0;

	newAmmo = Ammo(P.FindInventoryType(newAmmoClass));

	if (newAmmo == None)
		return 0;

	return newAmmo.AmmoAmount;
}

simulated function int NumAmmoTypesAvailable()
{
	local int i;
	local DeusExPlayer P;
	
	for (i=0; i<ArrayCount(AmmoNames); i++)
	{
		if (AmmoNames[i] == None)
		{
			break;
		}
	}
	
	P = DeusExPlayer(Owner);
	//MADDERS: Don't read out "already has X loaded" if we only know of one ammo type.
	if ((i > 1) && (P != None))
	{
		if ((AmmoNames[1] != None) && (P.FindInventoryType(AmmoNames[1]) == None))
		{
			i--;
		}
		if ((AmmoNames[2] != None) && (P.FindInventoryType(AmmoNames[2]) == None))
		{
			i--;
		}
	}
	
	// to make Al fucking happy
	if (i == 0)
	{
		i = 1;
	}
	
	return i;
}

function name WeaponDamageType()
{
	local name                    damageType;
	local Class<DeusExProjectile> projClass;

	projClass = Class<DeusExProjectile>(ProjectileClass);
	if (bInstantHit)
	{
		if (StunDuration > 0)
			damageType = 'Stunned';
		else
			damageType = 'Shot';
		
		//MADDERS: Overhauled for consulting with our ammo types.
		if (DeusExAmmo(AmmoType) != None)
		{
			switch(DeusExAmmo(AmmoType).VMDGetSpecialDamageType())
			{
				case '':
				case 'None':
					//MADDERS: Don't both with non-special cases.
				break;
				default:
					DamageType = DeusExAmmo(AmmoType).VMDGetSpecialDamageType();
				break;
			}
			
			//MADDERS: We have more vs armor ammos, and now we have gascaps, to crown it off.
			/*if (AmmoType.IsA('AmmoSabot') || AmmoType.IsA('Ammo3006AP') || AmmoType.IsA('Ammo3006HEAT') || AmmoType.IsA('Ammo10mmHEAT'))
				damageType = 'Sabot';
			else if (AmmoType.IsA('Ammo10mmGasCap'))
				damageType = 'KnockedOut';*/
		}
	}
	else if (projClass != None)
		damageType = projClass.Default.damageType;
	else
		damageType = 'None';

	return (damageType);
}


//
// target tracking info
//
simulated function Actor AcquireTarget()
{
	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor hit, retval;
	local Pawn p;

	p = Pawn(Owner);
	if (p == None)
		return None;

	StartTrace = p.Location;
	if (PlayerPawn(p) != None)
		EndTrace = p.Location + (10000 * Vector(p.ViewRotation));
	else
		EndTrace = p.Location + (10000 * Vector(p.Rotation));

	// adjust for eye height
	StartTrace.Z += p.BaseEyeHeight;
	EndTrace.Z += p.BaseEyeHeight;

	foreach TraceActors(class'Actor', hit, HitLocation, HitNormal, EndTrace, StartTrace)
		if (!hit.bHidden && (hit.IsA('Decoration') || hit.IsA('Pawn')))
			return hit;

	return None;
}

//
// Used to determine if we are near (and facing) a wall for placing LAMs, etc.
//
simulated function bool NearWallCheck()
{
	local Vector StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor HitActor;
	
	//MADDERS: Don't run this on non-had items.
	if (Pawn(Owner) == None) return false;
	
	// Scripted pawns can't place LAMs
	if (ScriptedPawn(Owner) != None)
		return False;
	
	// Don't let players place grenades when they have something highlighted
	if ( Level.NetMode != NM_Standalone )
	{
		if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).frobTarget != None))
		{
			if (DeusExPlayer(Owner).IsFrobbable( DeusExPlayer(Owner).frobTarget ))
				return False;
		}
	}
	
	// trace out one foot in front of the pawn
	StartTrace = Owner.Location + (vect(0,0,1) * Pawn(Owner).BaseEyeHeight);
	
	//MADDERS, 1/28/21: Allow placement on floors with this slight upgrade in range.
	//We also optimized eyeheight checks slightly.
	EndTrace = StartTrace + Vector(Pawn(Owner).ViewRotation) * 40;
	
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace);
	
	//MADDERS, 1/28/21: Don't allow placing on ceilings unless we have the A-Okay.
	if (!VMDHasSkillAugment('DemolitionMines'))
	{
		if (Abs(HitNormal.Z) > 0.4) return False;
	}
	
	if ((HitActor == Level) || ((HitActor != None) && (HitActor.IsA('Mover'))))
	{
		placeLocation = HitLocation;
		placeNormal = Rotator(HitNormal);
		// If on a flat surface, rotate to the player's view.
		if ((placeNormal.Pitch > 14000 && placeNormal.Pitch < 18000) || (placeNormal.Pitch < -14000 && placeNormal.Pitch > -18000))
		{
			placeNormal.Yaw = Owner.Rotation.Yaw;
			placeNormal.Roll = 32768;
		}
		placeMover = Mover(HitActor);
		if ((HitActor == Level) && (VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).LastMoverFrobTarget != None))
		{
			PlaceMover = VMDBufferPlayer(Owner).LastMoverFrobTarget;
		}
		return True;
	}
	
	return False;
}

//
// used to place a grenade on the wall
//
function PlaceGrenade()
{
	local ThrownProjectile Gren;
	local float dmgX, value;

	Gren = ThrownProjectile(Spawn(ProjectileClass, Owner,, PlaceLocation, PlaceNormal));
	if (Gren != None)
	{
		AmmoType.UseAmmo(1);
		if (AmmoType.AmmoAmount <= 0)
		{
			bDestroyOnFinish = True;
		}
		
		if (Gren.HasAnim('Open'))
		{
			Gren.PlayAnim('Open');
		}
		Gren.PlaySound(Gren.MiscSound, SLOT_None, 0.5+FRand()*0.5,, 512, (0.85+(FRand()*0.3)) * VMDGetMiscPitch2());
		Gren.SetPhysics(PHYS_None);
		Gren.bBounce = False;
		Gren.bProximityTriggered = True;
		Gren.bStuck = True;
		
		if (PlaceMover != None)
		{
			Gren.SetBase(PlaceMover);
		}
		
		// up the damage based on the skill
		// returned value from GetWeaponSkill is negative, so negate it to make it positive
		// dmgX value ranges from 1.0 to 2.4 (max demo skill and max target aug)
		dmgx = VMDGetWeaponSkill("DAMAGE");
		Gren.Damage = int((Gren.Damage+0.00) * dmgX);
		
		// Update ammo count on object belt
		if (DeusExPlayer(Owner) != None)
		{
			DeusExPlayer(Owner).UpdateBeltText(Self);
		}
	}
}

//
// scope, laser, and targetting updates are done here
//
simulated function Tick(float deltaTime)
{
	local vector loc;
	local rotator rot;
	local float beepspeed, recoil;
	local DeusExPlayer player;
   	local Actor RealTarget;
	local Pawn pawn;
	
	//MADDERS additions.
	local bool bDragged, bSkillFocus;
	local int i, texFlags, accunit, THand; //Multiplier to apply to the accuracy to get our effective spread
	local float TMult, TMult2, TRate, TFOV, FactoredRecoil, UseRecoilX, UseRecoilY, velMagnitude, TPitch; //G-Flex: so we don't have to use VSize() as much
	local name texName, texGroup;
	local Mesh TMesh;
	local vector StartTrace, EndTrace, HitLocation, HitNormal, Reflection;
	local actor target;
	local VMDBufferPlayer VPlayer;
	
	player = DeusExPlayer(Owner);
	VPlayer = VMDBufferPlayer(Owner);
	pawn = Pawn(Owner);
	
	if (Owner != None)
	{
		velMagnitude = VSize(Owner.Velocity);
	}
	
	Super.Tick(deltaTime);
	
	//MADDERS: Fix for assault gun ammo pickups, and their ability to break clipcount.
	if (VMDIsQuickSwapAmmoFA(AmmoType))
	{
		if (AmmoType.AmmoAmount > Last20mmCount)
		{
			ClipCount -= (AmmoType.AmmoAmount - Last20mmCount);
		}
		if (AmmoType.AmmoAmount != Last20mmCount)
		{
			Last20mmCount = AmmoType.AmmoAmount;
		}
	}
	
	if (VPlayer != None)
	{
		//MADDERS: This augment lets us hide small weapons from view. Fuckin' devious.
		if ((Concealability == CONC_Visual) && (VMDHasSkillAugment('TagTeamSmallWeapons')))
		{
			Concealability = CONC_ALL;
		}
		
		if ((VPlayer.InHand == Self) && (Mesh == PlayerViewMesh || Mesh == LeftPlayerViewMesh))
		{
			TMesh = VPlayer.GetHandednessPlayerMesh(THand);
			THand = GetHandType(THand);
			
			if ((Mesh == PlayerViewMesh) && (LeftPlayerViewMesh != None) && (THand == 1))
			{
				Mesh = LeftPlayerViewMesh;
			}
			else if ((Mesh == LeftPlayerViewMesh) && (PlayerViewMesh != None) && (THand != 1))
			{
				Mesh = PlayerViewMesh;
			}
			if ((Mesh == Default.ThirdPersonMesh) && (LeftThirdPersonMesh != None) && (THand == 1))
			{
				ThirdPersonMesh = LeftThirdPersonMesh;
			}
			else if ((Mesh == LeftThirdPersonMesh) && (Default.ThirdPersonMesh != None) && (THand != 1))
			{
				ThirdPersonMesh = Default.ThirdPersonMesh;
			}
			SetHand(THand);
			
			if ((VPlayer.Mesh != TMesh) && (TMesh != None))
			{
				VPlayer.Mesh = TMesh;
				VPlayer.LastMeshHandedness = THand;
			}
			VMDDecipherHandIndex();
		}
		
		if (VMDIsWaterZone())
		{
			VMDIncreaseWaterLogLevel(deltaTime);
		}
		//MADDERS: Dragging our gun along the floor adds grime, if in grass and dirt.
		else
		{
			VMDIncreaseWaterLogLevel(-deltaTime);
			if (VPlayer.InHand == Self)
			{
				if ((VPlayer.bDuck == 1 || VPlayer.bForceDuck) && (VPlayer.ViewRotation.Pitch < -8192) && (VSize(VPlayer.Velocity) > 20))
				{
					switch(VPlayer.FloorMaterial)
					{
						case 'Earth':
						case 'Foliage':
							VMDIncreaseGrimeLevel(deltaTime);
						break;
					}
				}
				
				if ((!bHandToHand) && (VMDBufferPlayer(Owner).TaseDuration > 0) && (!IsInState('NormalFire')) && (!IsInState('ClientFiring')) && (FRand() < 0.05))
				{
					ForceFire();
				}
			}
		}
	}
	
	if ((bHandToHand) && (!bInstantHit) && (AmmoType != None))
	{
		//MADDERS: Fix for zodiac C4.
		//1/15/21: Fix for non-player weapon usage.
		if ((AmmoType.AmmoAmount <= 0) && (GoverningSkill != None))
		{
			if (IsInState('Idle'))
			{
				VMDDestroyOnFinishHook();
				Destroy();
			}
			else if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).InHand != Self))
			{	
				VMDDestroyOnFinishHook();
				Destroy();
			}
		}
	}
	
	// don't do any of this if this weapon isn't currently in use
	if (pawn == None)
   	{
      		LockMode = LOCK_None;
      		MaintainLockTimer = 0;
      		LockTarget = None;
      		LockTimer = 0;
		return;
   	}
	if (pawn.Weapon != self)
   	{
		if (ShouldUseGP2())
		{
			GP2AimTick(DeltaTime);
		}
      		LockMode = LOCK_None;
      		MaintainLockTimer = 0;
      		LockTarget = None;
      		LockTimer = 0;
		return;
   	}
	if ((VMDIsShooting()) && (FireCutoffFrame > 0.0) && (AnimFrame > FireCutoffFrame) && (AnimFrame < 0.94))
	{
		AnimRate = 100;
	}
	// all this should only happen IF you have ammo loaded
	if (ClipCount < ReloadCount)
	{
		//MADDERS, 1/28/21: Just for show, but reinforce the *feeling* of being fast.
		TRate = 1.0;
		if (VMDHasSkillAugment('DemolitionMines')) TRate = 2.0;
		
		// check for LAM or other placed mine placement
		if ((bHandToHand) && (ProjectileClass != None) && (!Self.IsA('WeaponShuriken')))
		{
			if ((NearWallCheck()) && (VMDCanPlaceMine()))
			{
				if (( Level.NetMode == NM_Standalone ) || !IsAnimating() || (AnimSequence != 'Select'))
				{
					if (!bNearWall || (AnimSequence == 'Select'))
					{
						PlayAnim('PlaceBegin', TRate, 0.1);
						bNearWall = True;
					}
				}
			}
			else
			{
				if (bNearWall)
				{
					PlayAnim('PlaceEnd', TRate, 0.1);
					bNearWall = False;
				}
			}
		}
		
      		SoundTimer += deltaTime;
		
      		if ((Level.Netmode == NM_Standalone) || ((Player != None) && (Player.PlayerIsClient())))
      		{
         		if (bCanTrack)
         		{
           			Target = AcquireTarget();
            			RealTarget = Target;
            			
            			// calculate the range
            			if (Target != None)
				{
               				TargetRange = Abs(VSize(Target.Location - Location));
            			}
				
            			// update our timers
            			//SoundTimer += deltaTime;
            			MaintainLockTimer -= deltaTime;
            			
            			// check target and range info to see what our mode is
            			if ((Target == None) || IsInState('Reload'))
            			{
               				if (MaintainLockTimer <= 0)
               				{				
                  				SetLockMode(LOCK_None);
                  				MaintainLockTimer = 0;
                  				LockTarget = None;
               				}
               				else if (LockMode == LOCK_Locked)
               				{
                  				Target = LockTarget;
               				}
            			}
            			else if ((Target != LockTarget) && (Pawn(Target) != None) && (LockMode == LOCK_Locked))
            			{
               				SetLockMode(LOCK_None);
               				LockTarget = None;
            			}
            			else if (Pawn(Target) == None)
            			{
               				if (MaintainLockTimer <=0 )
               				{
                  				SetLockMode(LOCK_Invalid);
               				}
            			}
            			else if ((DeusExPlayer(Target) != None) && (Target.Style == STY_Translucent) )
            			{
               				//DEUS_EX AMSD Don't allow locks on cloaked targets.
               				SetLockMode(LOCK_Invalid);
            			}
            			else if ((DeusExPlayer(Target) != None) && (Player != None) && (Player.DXGame.IsA('TeamDMGame')) && (TeamDMGame(Player.DXGame).ArePlayersAllied(Player, DeusExPlayer(Target))))
            			{
               				//DEUS_EX AMSD Don't allow locks on allies.
               				SetLockMode(LOCK_Invalid);
            			}
            			else
            			{
               				if (TargetRange > MaxRange)
               				{
                  				SetLockMode(LOCK_Range);
               				}
               				else
               				{
                  				// change LockTime based on skill
                  				// -0.7 = max skill
                  				// DEUS_EX AMSD Only do weaponskill check here when first checking.
                  				if (LockTimer == 0)
                  				{
                     					LockTime = FMax(Default.LockTime + (1.5 * VMDGetWeaponSkill("DAMAGE")), 0.0);
                     					if ((Level.Netmode != NM_Standalone) && (LockTime < 0.25))
                        					LockTime = 0.25;
                  				}
                  				
						if (bZoomed)
						{
                  					LockTimer += DeltaTime*2;
						}
						else
						{
							LockTimer += DeltaTime;
						}
						
		  				if (LockTimer >= LockTime)
                  				{
                     					SetLockMode(LOCK_Locked);
                  				}
                  				else
                  				{
                     					SetLockMode(LOCK_Acquire);
                  				}
               				}
            			}
            			
            			// act on the lock mode
            			switch (LockMode)
            			{
            				case LOCK_None:
               					TargetMessage = msgNone;
               					LockTimer -= deltaTime;
               				break;
            				case LOCK_Invalid:
               					TargetMessage = msgLockInvalid;
               					LockTimer -= deltaTime;
               				break;
            				case LOCK_Range:
               					TargetMessage = msgLockRange @ Int(TargetRange/16) @ msgRangeUnit;
               					LockTimer -= deltaTime;
               				break;
            				case LOCK_Acquire:
               					TargetMessage = msgLockAcquire @ Left(String(LockTime-LockTimer), 4) @ msgTimeUnit;
               					beepspeed = FClamp((LockTime - LockTimer) / Default.LockTime, 0.2, 1.0);
               					if ((SoundTimer > beepspeed) && (ScriptedPawn(Owner) == None || ScriptedPawn(Owner).Enemy != None || DeusExPlayer(RealTarget) != None))
               					{
                  					Owner.PlaySound(TrackingSound, SLOT_None,,,, VMDGetMiscPitch2());
                  					SoundTimer = 0;
               					}
               				break;
            				case LOCK_Locked:
               					// If maintaining a lock, or getting a new one, increment maintainlocktimer
               					if ((RealTarget != None) && ((RealTarget == LockTarget) || (LockTarget == None)))
               					{
                  					if (Level.NetMode != NM_Standalone)
                     						MaintainLockTimer = default.MaintainLockTimer;
                  					else
                     						MaintainLockTimer = 0;
                  					LockTarget = Target;
               					}
               					TargetMessage = msgLockLocked @ Int(TargetRange/16) @ msgRangeUnit;
               				break;
            			}
         		}
         		else
         		{
            			LockMode = LOCK_None;
            			TargetMessage = msgNone;
            			LockTimer = 0;
            			MaintainLockTimer = 0;
            			LockTarget = None;
         		}
         		
         		if (LockTimer < 0)
            			LockTimer = 0;
      		}
   	}
   	else
   	{
      		LockMode = LOCK_None;
	  	TargetMessage = msgNoAmmo;
      		MaintainLockTimer = 0;
      		LockTarget = None;
      		LockTimer = 0;
   	}
	
   	if ((LockMode == LOCK_Locked) && (SoundTimer > 0.1) && (Role == ROLE_Authority))
   	{
      		PlayLockSound();
     		SoundTimer = 0;
   	}
	
	currentAccuracy = CalculateAccuracy();
	
	if (player != None)
	{
		//MADDERS, 11/30/21: Tilt camera according to anim sequences.
		VMDUpdateTiltEffects(DeltaTime);
		
		if (CurRecoilIndex > -1)
		{
			RecoilResetTimer += deltaTime;
			if (RecoilResetTimer > FMax(ShotTime * 1.75, 0.65))
			{
				CurRecoilIndex = -1;
			}
		}
		
		//MADDERS: Turn off laser sights here, if we're dead.
		if (Player.IsInState('Dying'))
		{
			LaserOff();
		}
		
		//MADDERS, 5/2/25: GP2.0, we do recoil totally differently, except when using a scope.
		if (!ShouldUseGP2() || bZoomed)
		{
			// reduce the recoil based on skill
			recoil = recoilStrength + (VMDGetWeaponSkill("RECOIL") * recoilStrength);
			
			//The assault gun gives half recoil on semi. Weird tweak.
			//MADDERS, 12/1/21: Yeah, we're revising this, due to semi having genuinely zero aim bloom on untrained.
			//if ((!Default.bSemiAutoTrigger) && (bSemiAutoTrigger)) Recoil /= 2;
			
			//Yeah don't do negative recoil, thanks.
			if (recoil < 0.0)
			{
				recoil = 0.0;
			}
			
			// simulate recoil while firing
			if (!IsInState('NormalFire') && (bFiring) && (!VMDIsShooting())) bFiring = false;
			if ((AnimSequence == 'Shoot') && (AnimFrame > FireCutoffFrame) && (FireCutoffFrame > 0.0)) bFiring = false;
			if ((bFiring) && (AnimFrame > FireCutoffFrame) && (PumpPurpose == 2)) bFiring = false; //MADDERS: Special fix for sawed off kicking like a mule on the last shot chambered.
			
			//MADDERS, 11/30/21: Spicy shit. Have recoil decay now, and have it scale along both X and Y.
			FactoredRecoil = FMax(0.0, Recoil - (Recoil * (RecoilResetTimer / ShotTime) * RecoilDecayRate));
			
			UseRecoilX = DeltaTime * (6144) * FactoredRecoil * VMDGetRecoilMultX() * 0.01; //(Rand(4096) + 4096)
			UseRecoilY = DeltaTime * (6144) * FactoredRecoil * VMDGetRecoilMultY() * 0.01; //(Rand(4096) + 4096)
			
			if ((bFiring) && (VMDIsShooting()) && (FactoredRecoil > 0.0))
			{
				/*player.ViewRotation.Yaw += deltaTime * (Rand(4096) - 2048) * recoil;
				player.ViewRotation.Pitch += (deltaTime * (Rand(4096) + 4096) * recoil);*/
				
				Player.ViewRotation.Yaw += UseRecoilX;
		 		TPitch = Player.ViewRotation.Pitch + UseRecoilY;
				
				if ((TPitch > 18000) && (TPitch < 32768))
				{
					TPitch = 18000;
				}
				else if ((TPitch >= 32768) && (TPitch < 49152))
				{
					TPitch = 49152;
				}
				Player.ViewRotation.Pitch = TPitch;
			}
		}
		
		//MADDERS, 5/2/25: GP2.0, slap in our tick function here.
		if (ShouldUseGP2())
		{
			GP2AimTick(DeltaTime);
		}
	}
	
	TMult = 1.0;
	if (VPlayer != None)
	{
	 	TMult *= VPlayer.ConfigureVMDAimSpeed();
		
		//MADDERS: First check for relevant augments, then apply the math rates.
		switch(GoverningSkill)
		{
			case class'SkillWeaponPistol':
				bSkillFocus = (VMDHasSkillAugment('PistolFocus'));
			break;
			case class'SkillWeaponRifle':
				bSkillFocus = (VMDHasSkillAugment('RifleFocus'));
			break;
			case class'SkillWeaponHeavy':
				bSkillFocus = (VMDHasSkillAugment('HeavyFocus'));
			break;
			default:
				bSkillFocus = True;
			break;
		}
		//Half the effect for QOL without augments, the full deal WITH augments.
		if (bSkillFocus)
		{
	 		TMult *= 1 + (0.5 * VPlayer.SkillSystem.GetSkillLevel(GoverningSkill));
		}
		else
		{
	 		TMult *= 1 + ((0.5 * VPlayer.SkillSystem.GetSkillLevel(GoverningSkill)) / 2);
		}
		TMult *= AimFocusMult;
		TMult *= FactorWM2UniversalFocusMultiplier();
		TMult /= FactorWM2SwayMultiplier();
	}
	
	// if were standing still, increase the timer
	if (!ShouldUseGP2())
	{
		if ((VSize(Owner.Velocity) < 10) && (!IsInState('Reload')))
		{
			standingTimer += deltaTime * TMult; //MADDERS: Buff aim focus rates!
		}
		else	// otherwise, decrease it slowly based on velocity
		{
			standingTimer = FMax(0, standingTimer - 0.02*deltaTime*VSize(Owner.Velocity));
		}
		
		//MADDERS: Make recoil degrade accuracy.
		if ((bFiring) && (VMDIsShooting()) && (IsAnimating()) && (AnimSequence == 'Shoot') && (recoil > 0.0))
		{
		 	TMult2 = 1.0;
		 	if (VMDBufferPlayer(Owner) != None)
		 	{
		  		TMult2 *= VMDBufferPlayer(Owner).ConfigureVMDAimSpeed();
		  		TMult2 *= 1 + (0.5 * VMDBufferPlayer(Owner).SkillSystem.GetSkillLevel(GoverningSkill));
		 	}
			
			//MADDERS, 2/5/21: New skill augment, bby. Bye, grime.
			if ((VMDHasSkillAugment('TagTeamOpenDecayRate')) && (FiringSystemOperation == 2))
			{
				TMult *= 0.75;
			}
		 	
	 		StandingTimer -= deltaTime * AimDecayMult * Recoil * TMult2;
		}
		standingTimer = FClamp(StandingTimer, 0.0, 10.0);
	}
	
	if (bLasing || bZoomed)
	{
		//== Though it uses the same code, the laser shake is different than the zoom shake
		if(bZoomed)
		{
			accunit = 2048;
		}
		else if (bLasing)
		{
			//G-Flex: this value is used to match the edge of the firing cone,
			//G-Flex: so don't change it unless you know what you're doing
			//G-Flex: ACCURACY TESTING
			//accunit = 1536;
			accunit = 1920;
		}
		
		// shake our view to simulate poor aiming
		if (ShakeTimer > 0.25)
		{
			/*ShakeYaw = currentAccuracy * (Rand(4096) - 2048);
			ShakePitch = currentAccuracy * (Rand(4096) - 2048);
			ShakeTimer -= 0.25;*/
			
			//G-Flex: Old method below, results in anomalies similar to
			//G-Flex: the old square bullet spread, also fixed
			//ShakeYaw = currentAccuracy * (Rand(accunit * 2) - accunit);
			//ShakePitch = currentAccuracy * (Rand(accunit * 2) - accunit);
			if (bZoomed)
			{
				//G-Flex: just use the old method
				ShakeYaw = currentAccuracy * (Rand(accunit * 2) - accunit);
				ShakePitch = currentAccuracy * (Rand(accunit * 2) - accunit);
				//ShakeTimer -= 0.25;
				//G-Flex: randomize this a bit to make change of shake direction less predictable
				//G-Flex: now is between 0.20 and 0.40 seconds, randomly
				ShakeTimer -= 0.20 + (Rand(21) / 100.00);
			}
		}
		ShakeTimer += deltaTime;
		
		if ((bLasing) && (Emitter != None))
		{
			loc = Owner.Location;
			loc.Z += Pawn(Owner).BaseEyeHeight;
			
			//MADDERS, 5/2/25: GP2.0, just make our laser dead accurate, basically.
			if (ShouldUseGP2())
			{
				rot = Rotation;
			}
			else
			{
				if (ScriptedPawn(Owner) != None)
				{
					rot = Pawn(Owner).Rotation;
				}
				else
				{
					rot = Pawn(Owner).ViewRotation;
				}
			}
			
			// add a little random jitter - looks cool!
			rot.Yaw += Rand(5) - 2;
			rot.Pitch += Rand(5) - 2;
			
			Emitter.SetLocation(loc);
			Emitter.SetRotation(rot);
		}
		if ((player != None) && (bZoomed))
		{
			if (IsA('WeaponA17') || IsA('WeaponAssault17'))
			{
				if (CurFiringMode < 1)
				{
					VMDHackbOffsetFireMode = true;
					VMDChangeFiringMode();
				}
			}
			
			if (ZoomedInTime < 2.0) ZoomedInTime += DeltaTime;
			if (ZoomedInTime > 0.10)
			{
				TFOV = class'VMDStaticFunctions'.Static.AdjustFOV(ScopeFOV, Player);
				if (ZoomInCount == 1)
				{
					TFOV = class'VMDStaticFunctions'.Static.AdjustFOV(SecondaryScopeFOV, Player);
				}
				
				if (Player.DesiredFOV != TFOV)
				{
					//RefreshScopeDisplay(Player, true, true);
					Player.DesiredFOV = TFOV;
				}
			}
			
			//MADDERS: This scope sway is harsh, and we aren't dead accurate anymore.
			ShakeYaw *= UnivScopeSwayMult;
			ShakePitch *= UnivScopeSwayMult;
			
			//For the unskilled, ducking will steady the scope holding a fair amount.
			if ((bool(Player.bDuck)) && (!Player.bForceDuck))
			{
				ShakeYaw *= 0.65;
				ShakePitch *= 0.65;
			}
			
			player.ViewRotation.Yaw += deltaTime * ShakeYaw;
	 		TPitch = Player.ViewRotation.Pitch + (DeltaTime * ShakePitch);
			
			if ((TPitch > 18000) && (TPitch < 32768))
			{
				TPitch = 18000;
			}
			else if ((TPitch >= 32768) && (TPitch < 49152))
			{
				TPitch = 49152;
			}
			Player.ViewRotation.Pitch = TPitch;
		}
	}
	if (!bZoomed)
	{
		if (IsA('WeaponA17') || IsA('WeaponAssault17'))
		{
			if (VMDHackbOffsetFireMode) //if (CurFiringMode > 0)
			{
				VMDHackbOffsetFireMode = false;
				VMDChangeFiringMode();
			}
		}
	}
}

//
// scope functions for weapons which have them
//

function ScopeOn()
{
	if ((bHasScope) && (!bZoomed) && (Owner != None) && (Owner.IsA('DeusExPlayer')) && (!DeusExPlayer(Owner).IsInState('Conversation')) && (!DeusExPlayer(Owner).RestrictInput()))
	{
		//MADDERS, 1/10/21: Hack for FOV nonsense.
		ZoomedInTime = 0;
		
		VMDScopeJump(0);
		
		// Show the Scope View
		bZoomed = True;
		RefreshScopeDisplay(DeusExPlayer(Owner), False, bZoomed);
	}
}

function ScopeOff()
{
	if ((bHasScope) && (bZoomed) && (DeusExPlayer(Owner) != None))
	{
		//MADDERS, 1/10/21: Hack for FOV nonsense.
		ZoomedInTime = 0;
		//ZoomInCount = 0; //MADDERS, 11/29/21: Nah, we're gonna maintain this for the time being. Set this in ScopeToggle.
		
		VMDScopeJump(2);
		
		bZoomed = False;
		// Hide the Scope View
      		RefreshScopeDisplay(DeusExPlayer(Owner), False, bZoomed);
		//DeusExRootWindow(DeusExPlayer(Owner).rootWindow).scopeView.DeactivateView();
	}
}

simulated function ScopeToggle()
{
	if (VMDBufferPlayer(Owner) != None && VMDBufferPlayer(Owner).TaseDuration > 0) return;
	
	if (IsInState('Idle') || WeaponLAW(Self) != None)
	{
		if ((bHasScope) && (DeusExPlayer(Owner) != None))
		{
			if (bZoomed)
			{
				if (ZoomInCount > 0 || SecondaryScopeFOV < 1)
				{
					ScopeOff();
					ZoomInCount = 0;
				}
				else
				{
					VMDScopeInFurther();
				}
			}
			else
			{
				ScopeOn();
			}
		}
		//MADDERS, 12/1/21: Don't do this now. We have our own key for this, finally.
		/*else if ((!bHasScope) && (!bCanHaveScope))
		{
			VMDChangeFiringMode();
		}*/
	}
}

// ----------------------------------------------------------------------
// RefreshScopeDisplay()
// ----------------------------------------------------------------------

simulated function RefreshScopeDisplay(DeusExPlayer player, bool bInstant, bool bScopeOn)
{
	if ((bScopeOn) && (player != None))
	{
		// Show the Scope View
		if (ZoomInCount == 1)
		{
			DeusExRootWindow(player.rootWindow).scopeView.ActivateView(SecondaryScopeFOV, False, bInstant);
		}
		else
		{
			DeusExRootWindow(player.rootWindow).scopeView.ActivateView(ScopeFOV, False, bInstant);
		}
		ResetShake();
	}
   	else if (!bScopeOn)
   	{
      		DeusExrootWindow(player.rootWindow).scopeView.DeactivateView();
		ResetShake();
   	}
}

//
// laser functions for weapons which have them
//

function LaserOn()
{
	if ((bHasLaser) && (!bLasing))
	{
		// if we don't have an emitter, then spawn one
		// otherwise, just turn it on
		if (Emitter == None)
		{
			Emitter = Spawn(class'LaserEmitter', Self, , Location, Pawn(Owner).ViewRotation);
			if (Emitter != None)
			{
				Emitter.SetHiddenBeam(True);
				Emitter.AmbientSound = None;
				Emitter.OverrideSpotScale = 0.055; //MADDERS, 6/5/25: Buff for baseline laser.
				Emitter.TurnOn();
			}
		}
		else
		{
			Emitter.TurnOn();
		}
		
		bLasing = True;
	}
}

function LaserOff()
{
	if ((bHasLaser) && (bLasing))
	{
		if (Emitter != None)
			Emitter.TurnOff();
		
		bLasing = False;
	}
}

function LaserToggle()
{
	if (VMDBufferPlayer(Owner) != None && VMDBufferPlayer(Owner).TaseDuration > 0) return;
	
	if (IsInState('Idle'))
	{
		if (bHasLaser)
		{
			if (bLasing)
				LaserOff();
			else
				LaserOn();
		}
		//MADDERS, 12/1/21: Don't do this now. We have our own key for this, finally.
		/*else if ((!bHasLaser) && (!bCanHaveLaser))
		{
			VMDChangeFiringMode();
		}*/
	}
}

simulated function SawedOffCockSound()
{
	if ((AmmoType.AmmoAmount > 0) && (VMDIsWeaponName("SawedOffShotgun")))
	{
		if ((DeusExAmmo(AmmoType) != None) && (!IsInState('ReloadToIdle')) && (!IsInState('Reload')) && (bPumpAction) && (PumpPurpose == 2))
		{
			DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
		}
		Owner.PlaySound(SelectSound, SLOT_None,,, 1024, VMDGetMiscPitch());
	}
}

//
// called from the MESH NOTIFY
//
simulated function SwapMuzzleFlashTexture()
{
   	if (!bHasMuzzleFlash)
      		return;
	if (FRand() < 0.5)
		MultiSkins[MuzzleFlashIndex] = Texture'FlatFXTex34';
	else
		MultiSkins[MuzzleFlashIndex] = Texture'FlatFXTex37';
	
	MuzzleFlashLight();
	SetTimer(0.1, False);
}

simulated function EraseMuzzleFlashTexture()
{
	MultiSkins[MuzzleFlashIndex] = None;
}

simulated function Timer()
{
	EraseMuzzleFlashTexture();
}

simulated function MuzzleFlashLight()
{
	local Vector offset, X, Y, Z;
	
	if (Pawn(Owner) == None)
		return;
	
 	if (!bHasMuzzleFlash)
		return;
	
	if ((flash != None) && (!flash.bDeleteMe))
		flash.LifeSpan = flash.Default.LifeSpan;
	else
	{
		GetAxes(Pawn(Owner).ViewRotation,X,Y,Z);
		offset = Owner.Location;
		offset += X * Owner.CollisionRadius * 2;
		flash = spawn(class'MuzzleFlash',,, offset);
		if (flash != None)
			flash.SetBase(Owner);
	}
}

function ServerHandleNotify( bool bInstantHit, class<projectile> ProjClass, float ProjSpeed, bool bWarn )
{
	if (bInstantHit)
		TraceFire(0.0);
	else
		ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
}

//
// HandToHandAttack
// called by the MESH NOTIFY for the H2H weapons
//
simulated function HandToHandAttack()
{
	local bool bOwnerIsPlayerPawn;
	
	if (bOwnerWillNotify)
	{
		return;
	}
	
	//MADDERS, 3/27/25: Okay, so I feel like I just smoked down an entire crack rock explaining this, but according to debug, here's a problem:
	//When travel initiates, sometimes anim notifies can call themselves falsely, multiple times, in fact
	//Thus, handtohandattack, if the game is feeling vindictive, can trigger multiple times on grenades and instantly deplete all their ammo...
	//In fact, according to my log, I lost a stack of 4 LAMS in paris catacombs, and it HandToHandAttacked with 1 or less ammo TWICE in the same frame.
	//The only way to stop this is to add a player traveling blocker here. It's a rare bug, so time will tell if it happens again.
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).FlagBase != None) && (DeusExPlayer(Owner).FlagBase.GetBool('PlayerTraveling')))
	{
		return;
	}
	
	// The controlling animator should be the one to do the tracefire and projfire
	if ((Level.NetMode != NM_Standalone) && (ScriptedPawn(Owner) == None))
	{
		bOwnerIsPlayerPawn = (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn()));

		if (( Role < ROLE_Authority ) && (bOwnerIsPlayerPawn || ScriptedPawn(Owner) != None))
		{
			ServerHandleNotify( bInstantHit, ProjectileClass, ProjectileSpeed, bWarnTarget );
		}
		else if ( !bOwnerIsPlayerPawn )
		{
			return;
		}
	}
	
	if (ScriptedPawn(Owner) != None)
	{
		ScriptedPawn(Owner).SetAttackAngle();
	}
	
	if (bInstantHit)
	{
		TraceFire(0.0);
	}
	else
	{
		if (ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget) != None)
		{
			if (bFireFudge)
			{
				SimAmmoAmount = AmmoType.AmmoAmount - 1;
				if (ReloadCount > 0)
				{
					AmmoType.UseAmmo(1);
				}
			}
			bFireFudge = false;
			
			if (DeusExPlayer(Owner) != None)
				DeusExPlayer(Owner).UpdateBeltText(Self);
		}
	}
	
	// if we are a thrown weapon and we run out of ammo, destroy the weapon
	if (bHandToHand && (ReloadCount > 0 || VMDIsWeaponName("WeaponC4")) && SimAmmoAmount <= 0)
	{
		Log("MADDERS DEBUG: OUT OF AMMO HANDTOHANDATTACK! MARKING SELF FOR DELETION! TRUE AMMO LEFT?"@AmmoType.AmmoAmount);
		DestroyOnFinish();
		if ( Role < ROLE_Authority )
		{
			ServerGotoFinishFire();
			GotoState('SimQuickFinish');
		}
	}
}

//
// OwnerHandToHandAttack
// called by the MESH NOTIFY for this weapon's owner
//
simulated function OwnerHandToHandAttack()
{
	local bool bOwnerIsPlayerPawn;
	
	if (!bOwnerWillNotify)
		return;
	
	// The controlling animator should be the one to do the tracefire and projfire
	if ((Level.NetMode != NM_Standalone) && (ScriptedPawn(Owner) == None))
	{
		bOwnerIsPlayerPawn = (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn()));

		if ((Role < ROLE_Authority) && (bOwnerIsPlayerPawn))
			ServerHandleNotify(bInstantHit, ProjectileClass, ProjectileSpeed, bWarnTarget);
		else if (!bOwnerIsPlayerPawn)
			return;
	}
	
	if (ScriptedPawn(Owner) != None)
		ScriptedPawn(Owner).SetAttackAngle();
	
	if (bInstantHit)
	{
		TraceFire(0.0);
	}
	else
	{
		if (ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget) != None)
		{
			if ((ReloadCount > 0) && (bFireFudge))
			{
				AmmoType.UseAmmo(1);
			}
			
			if (DeusExPlayer(Owner) != None)
				DeusExPlayer(Owner).UpdateBeltText(Self);
		}
	}
}

function ForceFire()
{
	Fire(0);
}

function ForceAltFire()
{
	AltFire(0);
}

//
// ReadyClientToFire is called by the server telling the client it's ok to fire now
//

simulated function ReadyClientToFire( bool bReady )
{
	bClientReadyToFire = bReady;
}

//
// ClientReFire is called when the client is holding down the fire button, loop firing
//

simulated function ClientReFire( float value )
{
	bClientReadyToFire = True;
	bLooping = True;
	bInProcess = False;
	ClientFire(0);
}

function StartFlame()
{
	flameShotCount = 0;
	bFlameOn = True;
	GotoState('FlameThrowerOn');
}

function StopFlame()
{
	bFlameOn = False;
}

//
// ServerForceFire is called from the client when loop firing
//
function ServerForceFire()
{
	bClientReady = True;
	Fire(0);
}

//----------------------
//MADDERS: Add pitch as an option. Yeet.
//7/1/20: Whoops. Previously I pulled a shifter and broke mod compatibility
//by changing the params on the original. Fuckin' rookie mistake, me.
simulated function int VMDPlaySimSound( Sound snd, ESoundSlot Slot, float Volume, float Radius, optional float Pitch )
{
	if (Pitch == 0.0) Pitch = 1.0;
	
	if (Owner != None)
	{
		if (Level.NetMode == NM_Standalone)
		{
			return (Owner.PlaySound(snd, Slot, Volume,, Radius, Pitch));
		}
		else
		{
			Owner.PlayOwnedSound(snd, Slot, Volume,, Radius, Pitch);
			return 1;
		}
	}
	return 0;
}

simulated function int PlaySimSound( Sound snd, ESoundSlot Slot, float Volume, float Radius)
{
	if (Owner != None)
	{
		if (Level.NetMode == NM_Standalone)
		{
			return (Owner.PlaySound(snd, Slot, Volume,, Radius));
		}
		else
		{
			Owner.PlayOwnedSound(snd, Slot, Volume,, Radius);
			return 1;
		}
	}
	return 0;
}

//
// ClientFire - Attempts to play the firing anim, sounds, and trace fire hits for instant weapons immediately
//				on the client.  The server may have a different interpretation of what actually happen, but this at least
//				cuts down on preceived lag.
//
simulated function bool ClientFire( float value )
{
	local bool bWaitOnAnim;
	local vector shake;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	// check for surrounding environment
	if ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum))
	{
		if ((VMDIsWaterZone()) && (VMP != None) && (FiringSystemOperation != 1 || !VMDHasSkillAugment('TagTeamClosedWaterproof')))
		{
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNotWorking);
				if (!bHandToHand)
					VMDPlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024, VMDGetMiscPitch() );
				
				//MADDERS, 7/12/20: Return to standard state, since this bugs the fuck out.
				EraseMuzzleFlashTexture();
				TweenAnim('Still', 0.1);
				GoToState('Idle');
			}
			return false;
		}
	}
	
	VMDFireHook(Value);
	
	if (!bLooping) // Wait on animations when not looping
	{
		bWaitOnAnim = (IsAnimating() && ((AnimSequence == 'Select') || (AnimSequence == 'Shoot') || (AnimSequence == 'ReloadBegin') || (AnimSequence == 'Reload') || (AnimSequence == 'ReloadEnd') || (AnimSequence == 'Down')));
	}
	else
	{
		bWaitOnAnim = False;
		bLooping = False;
	}

	if ( (Owner.IsA('DeusExPlayer') && (DeusExPlayer(Owner).NintendoImmunityTimeLeft > 0.01)) ||
		  (!bClientReadyToFire) || bInProcess || bWaitOnAnim )
	{
		DeusExPlayer(Owner).bJustFired = False;
		bPointing = False;
		bFiring = False;
		return false;
	}

	if ( !Self.IsA('WeaponFlamethrower') )
		ServerForceFire();

	if (bHandToHand)
	{
		SimAmmoAmount = AmmoType.AmmoAmount - 1;

		bClientReadyToFire = False;
		bInProcess = True;
		GotoState('ClientFiring');
		bPointing = True;
		if ( PlayerPawn(Owner) != None )
			PlayerPawn(Owner).PlayFiring();
		PlaySelectiveFiring();
		PlayFiringSound();
	}
	else if ((ClipCount < ReloadCount) || (ReloadCount == 0))
	{
		if ((ReloadCount == 0) || (AmmoType.AmmoAmount > 0))
		{
			SimClipCount = ClipCount + 1;
			
			if (AmmoType != None)
			{
				AmmoType.SimUseAmmo();
			}
			
			bFiring = True;
			bPointing = True;
			bClientReadyToFire = False;
			bInProcess = True;
			GotoState('ClientFiring');
			if (PlayerPawn(Owner) != None)
			{
				shake.X = 0.0;
				shake.Y = 100.0 * (ShakeTime*0.5);
				shake.Z = 100.0 * -(currentAccuracy * ShakeVert);
				PlayerPawn(Owner).ClientShake( shake );
				PlayerPawn(Owner).PlayFiring();
			}
			// Don't play firing anim for 20mm
			if (!VMDHasSelectiveFiringObjection())
				PlaySelectiveFiring();
			
			PlayFiringSound();
			
			//MADDERS, 11/30/21: Increment recoil accordingly.
			VMDIncreaseRecoilIndex();
			
			//MADDERS, 12/27/20: Redundant?
			if (bInstantHit)  //&& (Ammo20mm(AmmoType) == None)
			{
				TraceFire(currentAccuracy);
			}
			else
			{
				if ((!bFlameOn) && (Self.IsA('WeaponFlamethrower')))
				{
					bFlameOn = True;
					StartFlame();
				}
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
			}
		}
		else
		{
			if ((Owner.IsA('DeusExPlayer')) && (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun")))
			{
				if ((MustReload()) && (CanReload()))
				{
					bClientReadyToFire = False;
					bInProcess = False;
					if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();

					ReloadAmmo();
				}
			}
			VMDPlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );		// play dry fire sound
		}
	}
	else
	{
		if ((!Owner.IsA('DeusExPlayer')) || (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun")))
		{
			if ((MustReload()) && (CanReload()))
			{
				bClientReadyToFire = False;
				bInProcess = False;
				if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
					CycleAmmo();
				ReloadAmmo();
			}
		}
		VMDPlaySimSound( Misc1Sound, SLOT_None, TransientSoundVolume * 2.0, 1024 );		// play dry fire sound
	}
	return true;
}

//
// from Weapon.uc - modified so we can have the accuracy in TraceFire
//
function Fire(float Value)
{
	local float sndVolume;
	local bool bListenClient;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	bListenClient = ((Owner.IsA('DeusExPlayer')) && (DeusExPlayer(Owner).PlayerIsListenClient()));
	
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).RejectWeaponFire())) return;
	
	sndVolume = TransientSoundVolume;
	
	if (Level.NetMode != NM_Standalone)  // Turn up the sounds a bit in mulitplayer
	{
		sndVolume = TransientSoundVolume * 2.0;
		if (((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).NintendoImmunityTimeLeft > 0.01)) || ((!bClientReady) && (!bListenClient)))
		{
			if (DeusExPlayer(Owner) != None)
			{
				DeusExPlayer(Owner).bJustFired = False;
			}
			bReadyToFire = True;
			bPointing = False;
			bFiring = False;
			return;
		}
	}
	// check for surrounding environment
	if ((EnviroEffective == ENVEFF_Air) || (EnviroEffective == ENVEFF_Vacuum) || (EnviroEffective == ENVEFF_AirVacuum))
	{
		if ((VMDIsWaterZone()) && (VMP != None) && (FiringSystemOperation != 1 || !VMDHasSkillAugment('TagTeamClosedWaterproof')))
		{
			if (Pawn(Owner) != None)
			{
				Pawn(Owner).ClientMessage(msgNotWorking);
				if (!bHandToHand)
				{
					VMDPlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024, VMDGetMiscPitch() );		// play dry fire sound
				}
			}
			GotoState('Idle');
			return;
		}
	}
	
	VMDFireHook(Value);
	
	if (bHandToHand)
	{
		if ((Level.NetMode != NM_Standalone) && (!bListenClient))
		{
			//MADDERS: Stop us throwing into walls if we can't place mines.
			if (ReloadCount > 0)
			{
				if (VMDCanPlaceMine() || !NearWallCheck())
				{
					AmmoType.UseAmmo(1);
				}
				else return;
			}
		}
		if ((Level.NetMode != NM_Standalone) && (!bListenClient))
			bClientReady = False;
		bReadyToFire = False;
		GotoState('NormalFire');
		bPointing=True;
		if (Owner.IsA('PlayerPawn'))
			PlayerPawn(Owner).PlayFiring();
		PlaySelectiveFiring();
		PlayFiringSound();
	}
	// if we are a single-use weapon, then our ReloadCount is 0 and we don't use ammo
	else if ((ClipCount < ReloadCount) || (ReloadCount == 0))
	{
		if ((ReloadCount == 0) || AmmoType.UseAmmo(1))
		{
			if ((Level.NetMode != NM_Standalone) && (!bListenClient))
				bClientReady = False;
			
			ClipCount++;
			bFiring = True;
			bReadyToFire = False;
			GotoState('NormalFire');
			if ((Level.NetMode == NM_Standalone) || ((Owner.IsA('DeusExPlayer')) && (DeusExPlayer(Owner).PlayerIsListenClient())))
			{
				if ((PlayerPawn(Owner) != None) && (!ShouldUseGP2()))		// shake us based on accuracy
				{
					PlayerPawn(Owner).ShakeView(ShakeTime, currentAccuracy * ShakeMag + ShakeMag, currentAccuracy * ShakeVert);
				}
			}
			bPointing = True;

			//MADDERS, 11/30/21: Increment recoil accordingly.
			VMDIncreaseRecoilIndex();
			
			if (bInstantHit)
			{
				LastFireTime = Level.TimeSeconds;
				TraceFire(currentAccuracy);
			}
			else
			{
				LastFireTime = Level.TimeSeconds;
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);
			}
			if (Owner.IsA('PlayerPawn'))
				PlayerPawn(Owner).PlayFiring();
			
			// Don't play firing anim for 20mm
			if (!VMDHasSelectiveFiringObjection())
				PlaySelectiveFiring();
			
			PlayFiringSound();
			if ((Owner.bHidden) && (Level.Netmode != NM_Standalone))
				CheckVisibility();
		}
		else
		{
			VMDPlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
		}
	}
	else
	{
		//MADDERS: Make sure we reload on dryfire, if we're an NPC.
		if (ScriptedPawn(Owner) != None) ReloadAmmo();
		VMDPlaySimSound( Misc1Sound, SLOT_None, sndVolume, 1024 );		// play dry fire sound
	}

	// Update ammo count on object belt
	if (DeusExPlayer(Owner) != None)
		DeusExPlayer(Owner).UpdateBeltText(Self);
}

function ReadyToFire()
{
	if (!bReadyToFire)
	{
		// BOOGER!
		//if (ScriptedPawn(Owner) != None)
		//	ScriptedPawn(Owner).ReadyToFire();
		bReadyToFire = True;
		if ( Level.NetMode != NM_Standalone )
			ReadyClientToFire( True );
	}
}

function PlayPostSelect()
{
	// let's not zero the ammo count anymore - you must always reload
//	ClipCount = 0;		
}

simulated function PlaySelectiveFiring()
{
	local bool bUnderwater; //MADDERS: Related to fancy effects.
	local int SkillLevel;
	local float rnd, Mult, TRate; //MADDERS: Change fire rates out dynamically!
	local Name anim;
	local Pawn aPawn;
	
	anim = 'Shoot';
	
	if (bHandToHand)
	{
		switch(ForceMeleeSeq)
		{
			case 0:
				rnd = FRand();
				if (rnd < 0.33)
				{
					anim = 'Attack';
				}
				else if (rnd < 0.66)
				{
					anim = 'Attack2';
				}
				else
				{
					anim = 'Attack3';
				}
			break;
			case 1:
				anim = 'Attack';
			break;
			case 2:
				anim = 'Attack2';
			break;
			case 3:
				anim = 'Attack3';
			break;
		}
	}
	
	TRate = VMDGetCorrectAnimRate(1.0, (ScriptedPawn(Owner) != None));
	
	if ((DeusExPlayer(Owner) != None) && (DeusExPlayer(Owner).SkillSystem != None))
	{
		SkillLevel = DeusExPlayer(Owner).SkillSystem.GetSkillLevel(GoverningSkill);
	}
	
	mult = 1.0;
	if (bHandToHand)
	{
		if (DeusExPlayer(Owner) != None)
		{
			if (VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem) != None)
			{
				mult = VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem).VMDConfigureWepSwingSpeedMult(Self);
			}
			else
			{
				mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			}
		}
		else if ((VMDBufferPawn(Owner) != None) && (VMDBufferPawn(Owner).AugmentationSystem != None))
		{
			mult = VMDBufferPawn(Owner).AugmentationSystem.VMDConfigureWepSwingSpeedMult(Self);
		}
		
		if (mult <= 0.0)
		{
			mult = 1.0;
		}
	}
	
	if (VMDIsWaterZone()) bUnderwater = True;
	TRate *= Mult;
	
	//MADDERS: Nerf for many melee weapons, except knife, to give it some love.
	//Additionally, nerf for swinging underwater, unless a knife, but only stab.
	if (bHandToHand)
	{
		if (VMDIsWeaponName("Nanosword"))
		{
			if ((bUnderwater) && (!VMDNegateWaterSlow())) TRate *= 0.7;
			TRate *= 0.7;
		}
		else if (!VMDIsWeaponName("Knife"))
		{
			if ((bUnderwater) && (!VMDNegateWaterSlow())) TRate *= 0.7;
			TRate *= 0.85;
		}
		//MADDERS: Only stab underwater.
		else
		{
			if (bUnderwater) Anim = 'Attack3';
		}
	}
	
	//MADDERS: Normalize inconsistent melee swing speeds
	if (bHandToHand)
	{
		switch(Anim)
		{
			case 'Attack1':
				TRate *= MeleeAnimRates[0];
			break;
			case 'Attack2':
				TRate *= MeleeAnimRates[1];
			break;
			case 'Attack3':
				TRate *= MeleeAnimRates[2];
			break;
		}
		
		//MADDERS, 5/28/23: HOLY HACK BATMAN! Make grenades and knives go faster.
		if ((AmmoNone(AmmoType) == None) && (ReloadCount == 1) && (VMDHasSkillAugment('MeleeProjectileLooting')))
		{
			switch(SkillLevel)
			{
				case 0: TRate *= 1.05; break;
				case 1: TRate *= 1.15; break;
				case 2: TRate *= 1.30; break;
				case 3: TRate *= 1.50; break;
			}
		}
	}
	
	//MADDERS: Make splash noises.
	if (bUnderwater)
	{
		VMDPlaySimSound( Sound'SplashSmall', SLOT_None, TransientSoundVolume, 2048, TRate*0.7 );
	}
	
	if (( Level.NetMode == NM_Standalone ) || ( DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())) )
	{
		if (bAutomatic)
		{
			LoopAnim(anim, TRate, 0.1);
		}
		else
		{
			PlayAnim(anim, TRate, 0.1);
		}
	}
	else if ( Role == ROLE_Authority )
	{
		for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
		{
			if ((aPawn.IsA('DeusExPlayer')) && ((DeusExPlayer(Owner) != DeusExPlayer(aPawn))))
			{
				// If they can't see the weapon, don't bother
				if (DeusExPlayer(aPawn).FastTrace( DeusExPlayer(aPawn).Location, Location))
					DeusExPlayer(aPawn).ClientPlayAnimation(Self, anim, 0.1, bAutomatic);
			}
		}
	}
}

simulated function PlayFiringSound()
{
	local sound TSound;
	local float PitchUsed, TempSoundVolume, TSpace, EchoPitch;
	
	PitchUsed = VMDGetFirePitch();
	
	TempSoundVolume = TransientSoundVolume;
	if (VMDGetSilencer())
	{
		TSound = SilencedFireSound;
		//VMD: HACK! Don't do this to assault gun GL.
		if ((bSemiautoTrigger) && (!Default.bSemiAutoTrigger) && (SemiautoFireSound != None) && (bInstantHit == Default.bInstantHit)) TSound = SemiautoSilencedFireSound;
		
		VMDPlaySimSound( TSound, SLOT_None, TransientSoundVolume, 2048, PitchUsed );
	}
	else
	{
		TSpace = Max(1, VMDClosedSpaceLevel(true));
		
		TSound = FireSound;
		//VMD: HACK! Don't do this to assault gun GL.
		if ((bSemiautoTrigger) && (!Default.bSemiAutoTrigger) && (SemiautoFireSound != None) && (bInstantHit == Default.bInstantHit)) TSound = SemiautoFireSound;
		
		// The sniper rifle sound is heard to it's range in multiplayer
		if ((Level.NetMode != NM_Standalone ) &&  (Self.IsA('WeaponRifle')))
		{
			VMDPlaySimSound( TSound, SLOT_None, TempSoundVolume, class'WeaponRifle'.Default.mpMaxRange, PitchUsed );
		}
		else
		{
			VMDPlaySimSound( TSound, SLOT_None, TempSoundVolume, 2048, PitchUsed );
		}
		
		if (TSpace > 2.25)
		{
			//MADDERS: If I were formally trained, I'd produce something far less vomit than this.
			//Still, 2 layers of sqrt is too little trim, and 3 is too much. Use an average'ing to trim it lightly.
			EchoPitch = (Sqrt(Sqrt(TSpace)) + 0.85) / 1.7;
			VMDPlaySimSound( TSound, SLOT_Misc, TempSoundVolume / 1.65, 2048, PitchUsed * EchoPitch );
		}
	}
}

simulated function PlayIdleAnim()
{
	local float rnd;

	if (bZoomed || bNearWall)
		return;

	rnd = FRand();

	if (rnd < 0.1)
	{
		if (HasAnim('Idle1'))
			PlayAnim('Idle1',,0.1);
	}
	else if (rnd < 0.2)
	{
		if (HasAnim('Idle2'))
			PlayAnim('Idle2',,0.1);
	}
	else if (rnd < 0.3)
	{
		if (HasAnim('Idle3'))
			PlayAnim('Idle3',,0.1);
	}
}

//
// SpawnBlood
//

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
   	if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      		return;
	
   	spawn(class'BloodSpurt',,,HitLocation+HitNormal);
	//MADDERS: Mark owner so we can add blood levels to our player!
	spawn(class'BloodDrop',Owner,,HitLocation+HitNormal);
	spawn(class'BloodDrop',,,HitLocation+HitNormal);
	if (FRand() < 0.5)
		spawn(class'BloodDrop',,,HitLocation+HitNormal);
}

//
// SelectiveSpawnEffects - Continues the simulated chain for the owner, and spawns the effects for other players that can see them
//			No actually spawning occurs on the server itself.
//
simulated function SelectiveSpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other, float Damage)
{
	local DeusExPlayer fxOwner;
	local Pawn aPawn;
		
	// The normal path before there was multiplayer
	if (Level.NetMode == NM_Standalone)
	{
		//SpawnEffects(HitLocation, HitNormal, Other, Damage);
		return;
	}
	
	fxOwner = DeusExPlayer(Owner);
	
	if (Role == ROLE_Authority)
	{
		//SpawnEffectSounds(HitLocation, HitNormal, Other, Damage );
		
		for (aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn)
		{
			if ((aPawn.IsA('DeusExPlayer')) && (DeusExPlayer(aPawn) != fxOwner))
			{
				if (DeusExPlayer(aPawn).FastTrace(DeusExPlayer(aPawn).Location, HitLocation))
					DeusExPlayer(aPawn).ClientSpawnHits( bPenetrating, bHandToHand, HitLocation, HitNormal, Other, Damage);
			}
		}
	}
	if (fxOwner == DeusExPlayer(GetPlayerPawn()))
	{
		fxOwner.ClientSpawnHits(bPenetrating, bHandToHand, HitLocation, HitNormal, Other, Damage);
		//SpawnEffectSounds(HitLocation, HitNormal, Other, Damage);
	}
}


//
//	 SpawnEffectSounds - Plays the sound for the effect owner immediately, the server will play them for the other players
//	
simulated function SpawnEffectSounds( Vector HitLocation, Vector HitNormal, Actor Other, float Damage )
{
	if (bHandToHand)
	{
		// if we are hand to hand, play an appropriate sound
		if (Other.IsA('DeusExDecoration'))
			Owner.PlayOwnedSound(Misc3Sound, SLOT_None,,, 1024, VMDGetMiscPitch());
		else if (Other.IsA('Pawn'))
			Owner.PlayOwnedSound(Misc1Sound, SLOT_None,,, 1024, VMDGetMiscPitch());
		else if (Other.IsA('BreakableGlass'))
			Owner.PlayOwnedSound(sound'GlassHit1', SLOT_None,,, 1024, VMDGetMiscPitch());
		else if (GetWallMaterial(HitLocation, HitNormal) == 'Glass')
			Owner.PlayOwnedSound(sound'BulletProofHit', SLOT_None,,, 1024, VMDGetMiscPitch());
		else
			Owner.PlayOwnedSound(Misc2Sound, SLOT_None,,, 1024, VMDGetMiscPitch());
	}
}

//
//	SpawnEffects - Spawns the effects like it did in single player
//
function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other, float Damage)
{
   	local TraceHitSpawner hitspawner;
	local Name damageType;
	
	//MADDERS, 4/14/21: Exceptions time, bby.
	if (IsA('WeaponJoshua')) return;
	
	damageType = WeaponDamageType();
	
   	if (bPenetrating)
   	{
      		if (bHandToHand)
      		{
         		hitspawner = Spawn(class'TraceHitHandSpawner',Other,,HitLocation,Rotator(HitNormal));
      		}
      		else
      		{
        		hitspawner = Spawn(class'TraceHitSpawner',Other,,HitLocation,Rotator(HitNormal));
      		}
   	}
   	else
   	{
      		if (bHandToHand)
      		{
         		hitspawner = Spawn(class'TraceHitHandNonPenSpawner',Other,,HitLocation,Rotator(HitNormal));
      		}
      		else
      		{
        		hitspawner = Spawn(class'TraceHitNonPenSpawner',Other,,HitLocation,Rotator(HitNormal));
      		}
   	}
   	if (hitSpawner != None)
	{
      		hitspawner.HitDamage = Damage;
		hitSpawner.damageType = damageType;
		if (VMDIsBulletWeapon())
		{
			HitSpawner.ImpactedMaterial = LastHitTextureGroup;
			hitSpawner.BulletHoleSize = BulletHoleSize;
			HitSpawner.VMDAlertDamageChange();
		}
	}
	if (bHandToHand)
	{
		// if we are hand to hand, play an appropriate sound
		if (Other.IsA('DeusExDecoration') || Other.IsA('DeusExCarcass'))
		{
			Owner.PlaySound(Misc3Sound, SLOT_None,,, 1024, VMDGetMiscPitch());
		}
		else if (Other.IsA('Pawn'))
		{
			Owner.PlaySound(Misc1Sound, SLOT_None,,, 1024, VMDGetMiscPitch());
		}
		else if (Other.IsA('BreakableGlass'))
		{
			Owner.PlaySound(sound'GlassHit1', SLOT_None,,, 1024, VMDGetMiscPitch());
		}
		else if (GetWallMaterial(HitLocation, HitNormal) == 'Glass')
		{
			Owner.PlaySound(sound'BulletProofHit', SLOT_None,,, 1024, VMDGetMiscPitch());
		}
		else
		{
			Owner.PlaySound(Misc2Sound, SLOT_None,,, 1024, VMDGetMiscPitch());
		}
	}
}

function name GetWallMaterial(vector HitLocation, vector HitNormal)
{
	local vector EndTrace, StartTrace;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	local VMDHousingScriptedTexture STex;
	
	StartTrace = HitLocation + HitNormal*16;		// make sure we start far enough out
	EndTrace = HitLocation - HitNormal;
	
	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, StartTrace, HitNormal, EndTrace)
	{
		if ((target == Level) || target.IsA('Mover'))
		{
			break;
		}
	}
	
	if (TexName != '')
	{
		forEach AllObjects(class'VMDHousingScriptedTexture', STex)
		{
			if (STex.Name == TexName)
			{
				if (STex.LastTexGroup != '')
				{
					TexGroup = STex.LastTexGroup;
				}
				break;
			}
		}
	}
	
	return texGroup;
}

simulated function SimGenerateBullet()
{
	if (Role < ROLE_Authority)
	{
		if ((ClipCount < ReloadCount) && (ReloadCount != 0))
		{
			if ( AmmoType != None )
				AmmoType.SimUseAmmo();
			
			//MADDERS, 11/30/21: Increment recoil accordingly.
			VMDIncreaseRecoilIndex();
			
			if ( bInstantHit )
				TraceFire(currentAccuracy);
			else
				ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);

			SimClipCount++;

			if ( !Self.IsA('WeaponFlamethrower') )
				ServerGenerateBullet();
		}
		else
			GotoState('SimFinishFire');
	}
}

function DestroyOnFinish()
{
	bDestroyOnFinish = True;
}

function ServerGotoFinishFire()
{
	GotoState('FinishFire');
}

function ServerDoneReloading()
{
	ClipCount = 0;
}

function ServerGenerateBullet()
{
	if ( ClipCount < ReloadCount )
		GenerateBullet();
}

function GenerateBullet()
{
	if (AmmoType.UseAmmo(1))
	{
		//MADDERS, 11/30/21: Increment recoil accordingly.
		VMDIncreaseRecoilIndex();
		
		if ( bInstantHit )
			TraceFire(currentAccuracy);
		else
			ProjectileFire(ProjectileClass, ProjectileSpeed, bWarnTarget);

		ClipCount++;
	}
	else
		GotoState('FinishFire');
}

function PlayLandingSound()
{
	if (LandSound != None)
	{
		if (Velocity.Z <= -200)
		{
			PlaySound(LandSound, SLOT_None, TransientSoundVolume,, 768, VMDGetMiscPitch());
			if (ScriptedPawn(Instigator) == None) AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 768);
		}
	}
}

function GetWeaponRanges(out float wMinRange,
                         out float wMaxAccurateRange,
                         out float wMaxRange)
{
	local Class<DeusExProjectile> dxProjectileClass;

	dxProjectileClass = Class<DeusExProjectile>(ProjectileClass);
	if (dxProjectileClass != None)
	{
		wMinRange         = dxProjectileClass.Default.blastRadius;
		wMaxAccurateRange = dxProjectileClass.Default.AccurateRange;
		wMaxRange         = dxProjectileClass.Default.MaxRange;
	}
	else
	{
		wMinRange         = 0;
		wMaxAccurateRange = AccurateRange;
		wMaxRange         = MaxRange;
	}
}

//
// computes the start position of a projectile/trace
//
simulated function Vector ComputeProjectileStart(Vector X, Vector Y, Vector Z)
{
	local Vector Start, TOffset;
	
	if (Owner == None) return vect(0,0,0);
	
	TOffset = FireOffset;
	
	// if we are instant-hit, non-projectile, then don't offset our starting point by PlayerViewOffset
	if (bInstantHit)
		Start = Owner.Location + Pawn(Owner).BaseEyeHeight * vect(0,0,1);// - Vector(Pawn(Owner).ViewRotation)*(0.9*Pawn(Owner).CollisionRadius);
	else
		Start = Owner.Location + CalcDrawOffset() + TOffset.X * X + TOffset.Y * Y + TOffset.Z * Z;
	
	return Start;
}

//
// Modified to work better with scripted pawns
//
simulated function vector CalcDrawOffset()
{
	local float AddGap;
	local Vector DrawOffset, WeaponBob, TOffset, AddVect;
	local Rotator TRot;
	local ScriptedPawn SPOwner;
	local Pawn PawnOwner;
	local VMDBufferPlayer VMP;
	
	TOffset = PlayerViewOffset;
	
	PawnOwner = Pawn(Owner);
	VMP = VMDBufferPlayer(Owner);
	SPOwner = ScriptedPawn(Owner);
	if (SPOwner != None)
	{
		DrawOffset = ((0.9/SPOwner.FOVAngle * TOffset) >> SPOwner.ViewRotation);
		DrawOffset += (SPOwner.BaseEyeHeight * vect(0,0,1));
	}
	else if (PawnOwner != None)
	{
		if (VMP != None)
		{
			TRot = VMP.VMDRollModifier;
		}
		
		// copied from Engine.Inventory to not be FOVAngle dependent
		DrawOffset = ((0.9/PawnOwner.Default.FOVAngle * TOffset) >> (PawnOwner.ViewRotation+TRot));
		
		DrawOffset += (PawnOwner.EyeHeight * vect(0,0,1));
		WeaponBob = BobDamping * PawnOwner.WalkBob;
		WeaponBob.Z = (0.45 + 0.55 * BobDamping) * PawnOwner.WalkBob.Z;
		DrawOffset += WeaponBob;
		
		if ((VMP != None) && (VMP.bUseDynamicCamera))
		{
			AddGap = 5;
			AddGap *= (VMP.CollisionRadius / VMP.Default.CollisionRadius);
			
			AddVect = Vector(VMP.ViewRotation) * AddGap;
			AddVect.Z = 0;
			
			DrawOffset += AddVect;
		}
	}
	
	return DrawOffset;
}

function GetAIVolume(out float volume, out float radius)
{
	volume = 0;
	radius = 0;
	
	if (!bHandToHand || bForceSoundGeneration)
	{
		volume = NoiseLevel*Pawn(Owner).SoundDampening;
		radius = volume * 800.0;
	}
	//MADDERS: Some of these bois are extra loud.
	if (Ammo10mmHEAT(AmmoType) != None || Ammo3006AP(AmmoType) != None || Ammo3006HEAT(AmmoType) != None)
	{
		volume *= 2.5 * NoiseLevel*Pawn(Owner).SoundDampening;
		radius = volume * 800.0;
	}
	//MADDERS, 11/28/21: Slight quiet-ness for 3006 Tranq.
	if (Ammo3006Tranq(AmmoType) != None)
	{
		volume = 0.75*NoiseLevel*Pawn(Owner).SoundDampening;
		radius = volume * 800.0;
	}
	
	if (VMDGetSilencer())
	{
		Volume *= 0;
		Radius *= 0;
	}
}

//
// copied from Weapon.uc
//
simulated function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local int i, numProj;
	local float mult, RangeMult, volume, radius, TAccuracy;
	local Rotator FirstAdjustedAim;
	local Vector Start, X, Y, Z;
	local DeusExProjectile proj;
	local Pawn aPawn;
	
	//MADDERS, 6/9/22: Accurate range mult.
	local int TAmmo;
	local float ScopeMod, ARM;
	
	if (!VMDProjectileFireHook(ProjClass, ProjSpeed, bWarn)) return None;
	
	//MADDERS, 5/2/25: GP2.0, add some recoil.
	if (ShouldUseGP2())
	{
		GP2AddRecoilPacket();
	}
	
	ARM = 1.0;
	if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolScope')))
	{
		ARM = 1.35;
	}
	
	//MADDERS, 5/27/23: Cut taser slugs the same deal as crossbow darts.
	if ((ProjClass == class'TaserSlug') && (VMDHasSkillAugment('RifleAltAmmos')))
	{
		ARM = 1.35;
	}
	
	if ((DeusExAmmo(AmmoType) != None) && (!bPumpAction) && (!bBoltAction)) DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
	
	//MADDERS: Define this as a default.
	ProjSpeed = 1.0;
	
	// AugCombat increases our speed (distance) if hand to hand
	if (bHandToHand)
	{
		if (VMDHasAugOwner())
		{
			//MADDERS: Remove this feature entirely for non-melee.
			mult = VMDGetWeaponSkill("VELOCITY");
			if (mult == 0.0)
			{
				mult = 1.0;
			}
			ProjSpeed *= mult;
		}
	}
	
	//MADDERS: Skill augment for heavy weapons having proj speed boosting.
	if ((GoverningSkill == class'SkillWeaponHeavy') && (VMDHasSkillAugment('HeavyProjectileSpeed')))
	{
		ProjSpeed *= 1.25;
	}
	
	//MADDERS: Range mods actually doing something? Say what?
	RangeMult = (1 + (ModAccurateRange * 0.5)) * ARM;
	ProjSpeed *= RangeMult;
	
	// skill also affects our damage
	// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
	mult = 1.0;
	mult += (VMDGetWeaponSkill("DAMAGE") - 1.0);
	
	if (AmmoDamageMultiplier > 0)
	{
		Mult *= AmmoDamageMultiplier;
	}
	if (GunModDamageMultiplier > 0)
	{
		Mult *= GunModDamageMultiplier;
	}
	
	// make noise if we are not silenced
	if ((!VMDGetSilencer()) && (!bHandToHand) && (Owner != None))
	{
		GetAIVolume(volume, radius);
		Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
		
		VMDUseAIEventSender(GetPlayerPawn(), 'LoudNoise', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
		Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
		
		if (!Owner.IsA('PlayerPawn'))
			Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
	}
	
	// should we shoot multiple projectiles in a spread?
	if (AreaOfEffect == AOE_Cone)
		numProj = 3;
	else
		numProj = 1;
	
	//Sloppy, but functional. ~MADDERS
	NumProj = VMDGetCorrectNumProj(NumProj);
	
	//Don't fire 2 shots if only one's loaded!
	if ((FiringModes[CurFiringMode] ~= "Double Fire" || FiringModes[CurFiringMode] ~= "Double Fire ") && (AmmoType != None))
	{
	 	TAmmo = Min(AmmoType.AmmoAmount, ReloadCount - ClipCount);
	 	
	 	//HACK! Fix dangerous projectile counts on double shot!
	 	if (FiringModes[CurFiringMode] ~= "Double Fire ")
	 	{
	  		NumProj = Default.OverrideNumProj * 2;
	 	}
	 	
	 	if (TAmmo >= 1)//Adjustment for shot already being fired!
	 	{
	  		//Use some ammo!
	  		AmmoType.AmmoAmount--;
	  		ClipCount++;
	 	}
	 	else
	 	{
	  		//We only have one shot loaded.
	  		NumProj = Default.OverrideNumProj*1;
	 	}
	}
	
	//MADDERS, 5/2/25: GP2.0: Use our rotation, not our owner's aim.
	if (ShouldUseGP2())
	{
		if (Pawn(Owner) != None) GetAxes(Rotation,X,Y,Z);
	}
	else
	{
		if (Pawn(Owner) != None) GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
	}
	Start = ComputeProjectileStart(X, Y, Z);
	
	for (i=0; i<numProj; i++)
	{
      		// If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
      		if ((i > 0) && (Level.NetMode != NM_Standalone))
		{
         		if (currentAccuracy < MinProjSpreadAcc)
			{
            			currentAccuracy = MinProjSpreadAcc;
         		}
		}
		
		//MADDERS, 5/2/25: GP2.0. No particular gripe except wasted math routines.
		if (!ShouldUseGP2())
		{
			//MADDERS: Laser sight is now ran in CalculateAccuracy().
			if (bZoomed)
			{
				ScopeMod = 3.0;
				switch(GoverningSkill)
				{
					case class'SkillWeaponPistol':
						if ((!VMDHasSkillAugment('PistolModding')) && (!Default.bHasScope))
						{
							ScopeMod = 1.75;
						}
						else if (VMDHasSkillAugment('PistolScope'))
						{
							ScopeMod *= 1.5;
						}
					break;
					//MADDERS: Not listed in the description, so keep it as-is.
					/*case class'SkillWeaponRifle':
						if ((!VMDHasSkillAugment('RifleModding')) && (!Default.bHasScope))
						{
							ScopeMod = 1.0;
						}
					break;*/
				}
				CurrentAccuracy /= ScopeMod;
			}
			
			//MADDERS, 1/9/21: Cap off maximum inaccuracy here.
			if (CurrentAccuracy > MaximumAccuracy) CurrentAccuracy = MaximumAccuracy;
		}
		
		if (i == 0)
		{
			//MADDERS, 5/2/25: GP2.0, only our rotation has error. Use it instead.
			if (ShouldUseGP2())
			{
				TAccuracy = 0.0;
				AdjustedAim = Rotation;
			}
			else
			{
				TAccuracy = CurrentAccuracy;
				if (Pawn(Owner) != None)
				{
					AdjustedAim = pawn(owner).AdjustAim(ProjSpeed, Start, AimError, True, bWarn);
				}
			}
			
			if (ScriptedPawn(Owner) == None || !VMDIsGrenadeWeapon())
			{
				AdjustedAim.Yaw += TAccuracy * (Rand(2048) - 1024); //(Rand(1024) - 512);
				AdjustedAim.Pitch += TAccuracy * (Rand(2048) - 1024); //(Rand(1024) - 512);
			}
			FirstAdjustedAim = AdjustedAim;
		}
		else
		{
			TAccuracy = MinSpreadAcc;
				
			AdjustedAim = FirstAdjustedAim;
			AdjustedAim.Yaw += TAccuracy * (Rand(2048) - 1024);
			AdjustedAim.Pitch += TAccuracy * (Rand(2048) - 1024);
		}
		
		if (Level.NetMode == NM_Standalone || (DeusExPlayer(Owner) != None && DeusExPlayer(Owner).PlayerIsListenClient()))
		{
			proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
			if (proj != None)
			{
				//MADDERS: Fix noise caused by multiple projectiles.
				if (i > 0)
				{
					proj.ImpactSound = None;
					proj.SpawnSound = None;
					proj.AmbientSound = None;
					if (proj.StartSoundSnap > -1) StopSound(Proj.StartSoundSnap);
				}
				
				//MADDERS: Tag this as an open systems shot if it was one. Headshot bonus, bby.
				if ((FiringSystemOperation == 1) && (Proj != None) && (VMDBufferPlayer(Owner) != None))
				{
					Proj.bClosedSystemHit = true;
				}
				
				if ((Proj.Class.Name == 'Dart') && (VMDHasSkillAugment('PistolAltAmmos')))
				{
					Proj.DamageType = 'Sabot';
				}
				else if ((DartFlare(Proj) != None) && (VMDHasSkillAugment('PistolAltAmmos')))
				{
					Proj.DamageType = 'Flamed';
				}
				
				//MADDERS, 6/7/25: Pass on this key bit of info as well.
				Proj.MoverDamageMult = MoverDamageMult;
				
				// AugCombat increases our damage as well
				proj.Damage *= mult;
				Proj.LastWeaponDamageSkillMult = Mult;
				
				//MADDERS: Apply speed, which seems unused for some reason.
				Proj.VMDApplySpeedMult(ProjSpeed);
				
				//MADDERS: Apply this goodness here.
				Proj.MaxRange *= RangeMult;
				Proj.AccurateRange *= RangeMult;
				
				// send the targetting information to the projectile
				if ((bCanTrack) && (LockTarget != None) && (LockMode == LOCK_Locked))
				{
					proj.Target = LockTarget;
					proj.bTracking = True;
				}
			}
		}
		else
		{
			if ((Role == ROLE_Authority ) || (DeusExPlayer(Owner) == DeusExPlayer(GetPlayerPawn())))
			{
				// Do it the old fashioned way if it can track, or if we are a projectile that we could pick up again
				if (bCanTrack || Self.IsA('WeaponShuriken') || Self.IsA('WeaponMiniCrossbow') || Self.IsA('WeaponLAM') || Self.IsA('WeaponEMPGrenade') || Self.IsA('WeaponGasGrenade'))
				{
					if ( Role == ROLE_Authority )
					{
						proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
						if (proj != None)
						{
							//MADDERS: Fix noise caused by multiple projectiles.
							if (i > 0)
							{
								proj.ImpactSound = None;
								proj.SpawnSound = None;
								proj.AmbientSound = None;
								if (proj.StartSoundSnap > -1) StopSound(Proj.StartSoundSnap);
							}
							
							//MADDERS: Tag this as an open systems shot if it was one. Headshot bonus, bby.
							if ((FiringSystemOperation == 1) && (Proj != None) && (VMDBufferPlayer(Owner) != None))
							{
								Proj.bClosedSystemHit = true;
							}
							
							// AugCombat increases our damage as well
							proj.Damage *= mult;
							Proj.LastWeaponDamageSkillMult = Mult;
							
							//MADDERS: Apply speed, which seems unused for some reason.
							Proj.VMDApplySpeedMult(ProjSpeed);
							
							//MADDERS: Apply this goodness here.
							Proj.MaxRange *= RangeMult;
							Proj.AccurateRange *= RangeMult;
							
							// send the targetting information to the projectile
							if (bCanTrack && (LockTarget != None) && (LockMode == LOCK_Locked))
							{
								proj.Target = LockTarget;
								proj.bTracking = True;
							}
						}
					}
				}
				else
				{
					proj = DeusExProjectile(Spawn(ProjClass, Owner,, Start, AdjustedAim));
					if (proj != None)
					{
						//MADDERS: Fix noise caused by multiple projectiles.
						if (i > 0)
						{
							proj.ImpactSound = None;
							proj.SpawnSound = None;
							proj.AmbientSound = None;
							if (proj.StartSoundSnap > -1) StopSound(Proj.StartSoundSnap);
						}
						
						//MADDERS: Tag this as an open systems shot if it was one. Headshot bonus, bby.
						if ((FiringSystemOperation == 1) && (Proj != None) && (VMDBufferPlayer(Owner) != None))
						{
							Proj.bClosedSystemHit = true;
						}
						
						if ((Proj.Class.Name == 'Dart') && (VMDHasSkillAugment('PistolAltAmmos')))
						{
							Proj.DamageType = 'Sabot';
						}
						else if ((DartFlare(Proj) != None) && (VMDHasSkillAugment('PistolAltAmmos')))
						{
							Proj.DamageType = 'Flamed';
						}
						
						//MADDERS, 6/7/25: Pass on this key bit of info as well.
						Proj.MoverDamageMult = MoverDamageMult;
						
						proj.RemoteRole = ROLE_None;
						// AugCombat increases our damage as well
						if ( Role == ROLE_Authority )
						{
							proj.Damage *= mult;
							Proj.LastWeaponDamageSkillMult = Mult;
						}
						else
						{
							proj.Damage = 0;
							Proj.LastWeaponDamageSkillMult = 0;
						}
						
						//MADDERS: Apply speed, which seems unused for some reason.
						Proj.VMDApplySpeedMult(ProjSpeed);
						
						//MADDERS: Apply this goodness here.
						Proj.MaxRange *= RangeMult;
						Proj.AccurateRange *= RangeMult;
					}
					if ( Role == ROLE_Authority )
					{
						for ( aPawn = Level.PawnList; aPawn != None; aPawn = aPawn.nextPawn )
						{
							if ( aPawn.IsA('DeusExPlayer') && ( DeusExPlayer(aPawn) != DeusExPlayer(Owner) ))
								DeusExPlayer(aPawn).ClientSpawnProjectile( ProjClass, Owner, Start, AdjustedAim );
						}
					}
				}
			}
		}

	}
	return proj;
}

//
// copied from Weapon.uc so we can add range information
//
simulated function TraceFire( float Accuracy )
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z, FirstEndTrace;
	local Rotator rot;
	local actor Other;
	local float dist, alpha, degrade;
	local int i, numSlugs, NumMeleeHits;
	local float volume, radius, ScopeMod;
	local int TAmmo;
	
	//Trace back into wall with these
	local Vector BackLocation;
	local Actor BackOther;
	local Vector BackHitLocation, BackHitNormal, BackStartTrace, BackEndTrace;
	local float TestPenetration, Penetration;
	
	//Trace into new actor with these.
	local Actor TexOther;
	local int TexFlags;
	local name TexName, TexGroup;
	local Vector TexHitLocation, TexHitNormal;
	
	//Trace into the void with fake parabola.
	local bool bSimulatedDrop;
	local float TProg, TRange;
	local Vector ModdedStartLoc, ModdedEndLoc, RangeEndPoint, BulletDir, TracerEndPoints[10];
	local DeusExProjectile TTracer, TTracer2;
	local Tracer CastTracer, CastTracer2;
	
	//Trace into new actor with these.
	local Vector NewLocation, NewNormal;
	local Actor NewOther;
	local Vector NewHitLocation, NewHitNormal, NewStartTrace, NewEndTrace;
	
	//Ricochet vars.
	local int j, k, OldDamage;
	local vector BastardNormal;
	
	//MADDERS, 6/9/22: Skill based accurate range tweaks?
	local float ARM;
	
	local VMDHousingScriptedTexture STex;
	
	OldDamage = HitDamage;
	
	if (Pawn(Owner) == None) return;
	
	if (!VMDTraceFireHook(Accuracy)) return;
	
	if (ShouldUseGP2())
	{
		GP2AddRecoilPacket();
	}
	
	ARM = 1.0;
	if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolScope')))
	{
		ARM = 1.35;
	}
	
	if ((DeusExAmmo(AmmoType) != None) && (!bPumpAction) && (!bBoltAction)) DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
	
	// make noise if we are not silenced
	if ((!VMDGetSilencer()) && (!bHandToHand))
	{
		GetAIVolume(volume, radius);
		Owner.AISendEvent('WeaponFire', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
		
		VMDUseAIEventSender(GetPlayerPawn(), 'LoudNoise', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
		Owner.AISendEvent('LoudNoise', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
		
		if (!Owner.IsA('PlayerPawn'))
			Owner.AISendEvent('Distress', EAITYPE_Audio, volume, radius*VMDOpenSpaceRadiusMult());
	}
	
	if (ShouldUseGP2())
	{
		GetAxes(Rotation,X,Y,Z);
		StartTrace = ComputeProjectileStart(X, Y, Z);
		AdjustedAim = Rotation;
	}
	else
	{
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		StartTrace = ComputeProjectileStart(X, Y, Z);
		AdjustedAim = pawn(owner).AdjustAim(1000000, StartTrace, 2.75*AimError, False, False);
	}
	
	// check to see if we are a shotgun-type weapon
	if (AreaOfEffect == AOE_Cone)
		numSlugs = 5;
	else
		numSlugs = 1;
	
	//Sloppy, but functional. ~MADDERS
	NumSlugs = VMDGetCorrectNumProj(NumSlugs);
	
	//Don't fire 2 shots if only one's loaded!
	if (FiringModes[CurFiringMode] ~= "Double Fire" || FiringModes[CurFiringMode] ~= "Double Fire ")
	{
		if (AmmoType != None)
		{
	 		TAmmo = Min(AmmoType.AmmoAmount, ReloadCount - ClipCount);
	 		
	 		if (TAmmo >= 1)//Adjustment for shot already being fired!
	 		{
	  			//Use some ammo!
	  			AmmoType.AmmoAmount--;
	  			ClipCount++;
	 		}
	 		else
	 		{
	  			//We only have one shot loaded.
	  			NumSlugs = Default.OverrideNumProj * 1;
			}
	 	}
	}
	
	//MADDERS, 5/2/25: Use purely rotator aim for GP2.0.
	if (ShouldUseGP2())
	{
		Accuracy = 0.0;
	}
	else
	{
		// if the laser sight is on, make this shot dead on
		// also, if the scope is on, zero the accuracy so the shake makes the shot inaccurate
		//MADDERS: Laser is now ran in CalculateAccuracy().
		if (bZoomed)
		{
			ScopeMod = 3.0;
			switch(GoverningSkill)
			{
				case class'SkillWeaponPistol':
					if ((!VMDHasSkillAugment('PistolModding')) && (!Default.bHasScope))
					{
						ScopeMod = 1.75;
					}
					else if (VMDHasSkillAugment('PistolScope'))
					{
						ScopeMod *= 1.5;
					}
				break;
				//MADDERS: Not listed in the description, so keep it as-is.
				/*case class'SkillWeaponRifle':
					if ((!VMDHasSkillAugment('RifleModding')) && (!Default.bHasScope))
					{
						ScopeMod = 1.0;
					}
				break;*/
			}
			Accuracy /= ScopeMod;
		}
		
		//MADDERS, 1/9/21: Cap off maximum inaccuracy here.
		if (Accuracy > MaximumAccuracy) Accuracy = MaximumAccuracy;
	}
	
	TRange = AccurateRange;
	if (VMDIsBulletWeapon())
	{
		if (VMDIsWaterZone())
		{
			TRange *= 0.35;
		}
		Accuracy *= TRange / RelativeRange;
	}
	
	for (i=0; i<numSlugs; i++)
	{
		bSimulatedDrop = false;
		for (j=0; j<ArrayCount(TracerEndPoints); j++)
		{
			TracerEndPoints[j] = Vect(0,0,0);
		}
		
      		// If we have multiple slugs, then lower our accuracy a bit after the first slug so the slugs DON'T all go to the same place
      		/*if ((i > 0) && (Level.NetMode != NM_Standalone) && !(bHandToHand))
         		if (Accuracy < MinSpreadAcc)
            			Accuracy = MinSpreadAcc;*/
		if (i > 0)
		{
			Accuracy = MinSpreadAcc;
			Accuracy *= TRange / RelativeRange;
			if (FiringModes[CurFiringMode] ~= "Double Fire ")
			{
				Accuracy *= 1.41;
			}
		}
		
      		// Let handtohand weapons have a better swing
      		if ((bHandToHand) && (NumSlugs > 1) && (Level.NetMode != NM_Standalone))
      		{
         		StartTrace = ComputeProjectileStart(X,Y,Z);
         		StartTrace = StartTrace + (numSlugs/2 - i) * SwingOffset;
      		}
		
		if (i == 0)
		{
      			EndTrace = StartTrace + Accuracy * (FRand()-0.5)*Y*1000 + Accuracy * (FRand()-0.5)*Z*1000;
      			EndTrace += (TRange * vector(AdjustedAim));
		}
		else
		{
			//MADDERS: No, I don't trust PEMDAS alone. Bad experiences.
			//Anyways, use our end point and hamfist the end values to have spread.
			EndTrace = FirstEndTrace + (Accuracy * (Frand()-0.5)*Y*1000) + (Accuracy * (Frand()-0.5)*Z*1000);
		}
      		Other = Pawn(Owner).TraceShot(HitLocation,HitNormal,EndTrace,StartTrace);
		if ((Other == None) && (MaxRange > TRange) && (VMDIsBulletWeapon()))
		{
			bSimulatedDrop = true;
			TracerEndPoints[0] = EndTrace;
			RangeEndPoint = EndTrace;
			ModdedStartLoc = RangeEndPoint;
			for (TProg = 1; TProg < ArrayCount(TracerEndPoints); TProg += 1)
			{
				BulletDir = Normal(RangeEndPoint - StartTrace);
				if (Region.Zone != None)
				{
					ModdedEndLoc = ModdedStartLoc + (BulletDir * (MaxRange-AccurateRange) * 0.1818 * (1.0 - (TProg * 0.1))) + (Normal(Region.Zone.ZoneGravity) * (MaxRange-AccurateRange) * 0.016 * (TProg * 0.1));
				}
				else
				{
					ModdedEndLoc = ModdedStartLoc + (BulletDir * (MaxRange-AccurateRange) * 0.1818 * (1.0 - (TProg * 0.1))) + (Vect(0,0,-1) * (MaxRange-AccurateRange) * 0.016 * (TProg * 0.1));
				}
				
				Other = Pawn(Owner).TraceShot(HitLocation, HitNormal, ModdedEndLoc, ModdedStartLoc);
				if (Other != None)
				{
					EndTrace = ModdedEndLoc;
					TracerEndPoints[int(TProg)] = ModdedEndLoc;
					break;
				}
				else
				{
					ModdedStartLoc = ModdedEndLoc;
					TracerEndPoints[int(TProg)] = ModdedEndLoc;
				}
			}
		}
		
		//MADDERS: Store this for shotgun spreads.
		if (i == 0)
		{
			if (bSimulatedDrop)
			{
				FirstEndTrace = RangeEndPoint;
			}
			else
			{
				FirstEndTrace = EndTrace;
			}
		}
		
		//MADDERS, 4/13/21: Don't apply multiple heat blast rings, thank you.
		VMDHandlePrimaryAmmoEffects(Other, HitLocation, HitNormal);
		
		foreach TraceTexture(class'Actor', TexOther, TexName, TexGroup, TexFlags, TexHitLocation, TexHitNormal, EndTrace, StartTrace)
		{
			if ((TexOther == Level) || TexOther.IsA('Mover'))
				break;
		}
		if (TexName != '')
		{
			forEach AllObjects(class'VMDHousingScriptedTexture', STex)
			{
				if (STex.Name == TexName)
				{
					if (STex.LastTexGroup != '')
					{
						TexGroup = STex.LastTexGroup;
					}
					break;
				}
			}
		}
		
		LastHitTextureGroup = TexGroup;
		
		// randomly draw a tracer for relevant ammo types
		// don't draw tracers if we're zoomed in with a scope - looks stupid
      		// DEUS_EX AMSD In multiplayer, draw tracers all the time.
		if (VMDShouldMakeTracers(false))
		{
			//if ((AmmoName == Class'Ammo10mm') || (AmmoName == Class'Ammo3006') ||
			//	(AmmoName == Class'Ammo762mm'))
			//{
				if (VSize(HitLocation - StartTrace) > MinimumTracerDist)
				{
					if (bSimulatedDrop)
					{
						rot = Rotator(RangeEndPoint - StartTrace);
					}
					else
					{
						rot = Rotator(EndTrace - StartTrace);
					}
					
					//MADDERS: Use only sniper tracers for ricochet depiction.
               				if ((Level.NetMode != NM_Standalone) && (WeaponRifle(Self) != None))
					{
                  				TTracer = Spawn(VMDConfigureTracerClass(0, 0), Owner,, StartTrace + 96 * Vector(rot), rot);
					}
               				else if ((Level.NetMode == NM_Standalone) && ((TexFlags & 0x00000080) == 0) && (VMDAngleMeansRicochet(HitLocation, Normal(HitLocation - StartTrace), HitNormal, TexGroup, Other)) && (!bSimulatedDrop))
					{
                  				TTracer = Spawn(VMDConfigureTracerClass(0, 0), Owner,, StartTrace + 96 * Vector(rot), rot);
					}
               				else
					{
                  				TTracer = Spawn(VMDConfigureTracerClass(-1, -1), Owner,, StartTrace + 96 * Vector(rot), rot);
					}
					
					if (TTracer != None)
					{
						if (bSimulatedDrop)
						{
                 					TTracer2 = Spawn(VMDGetTracerEquivalent(TTracer.Class.Name, "Outline"), Owner,, StartTrace + 96 * Vector(rot), rot);
							CastTracer2 = Tracer(TTracer2);
						}
						
						//MADDERS, 9/9/24: Ugly fudgy shit. Make shotgun spreads less overwhelming, but also puff up non-scope tracers so we can see our drop.
						//I hate the mismatched size based on zoom, but it's there for assistance.
						TTracer.DrawScale /= Sqrt(NumSlugs);
						if (!bZoomed) TTracer.DrawScale *= 2.0;
						
						CastTracer = Tracer(TTracer);
						if ((CastTracer != None) && (bSimulatedDrop))
						{
							for(j=0; j<ArrayCount(TracerEndPoints); j++)
							{
								CastTracer.TracerEndPoints[j] = TracerEndPoints[j];
							}
						}
						
						if (TTracer2 != None)
						{
							TTracer2.DrawScale /= Sqrt(NumSlugs);
							if (!bZoomed) TTracer2.DrawScale *= 4.0;
							
							if ((CastTracer2 != None) && (bSimulatedDrop))
							{
								for(j=0; j<ArrayCount(TracerEndPoints); j++)
								{
									CastTracer2.TracerEndPoints[j] = TracerEndPoints[j];
								}
							}
						}
					}
				}
			//}
		}
		
		//MADDERS: Quick fix for melee being shit.
		if ((bHandToHand) && (Other == Level) && (DeusExPlayer(Owner) != None) && (DeusExMover(DeusExPlayer(Owner).FrobTarget) != None))
		{
			Other = DeusExMover(DeusExPlayer(Owner).FrobTarget);
		}
		else if ((bHandToHand) && (Other == Level) && (VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).LastMoverFrobTarget != None))
		{
			Other = VMDBufferPlayer(Owner).LastMoverFrobTarget;
		}
		
		// check our range
		//dist = Abs(VSize(HitLocation - Owner.Location));
		//if (dist <= TRange * ARM)
		//{
			// we hit just fine
			ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
			
			//MADDERS: Don't spam hit sounds.
			if ((NumMeleeHits == 0 || !bHandToHand) && (TexFlags & 0x00000080) == 0)
			{
				if (Other != None) NumMeleeHits++;
				VMDShellProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
			}
		//}
		//MADDERS, 9/2/24: We have something better in mind, thank you.
		/*else if (dist <= MaxRange)
		{
			// simulate gravity by lowering the bullet's hit point
			// based on the owner's distance from the ground
			alpha = (dist - TRange) / (MaxRange - TRange * ARM);
			
			//MADDERS: This use of square horribly fucks up the arc, causing massive "gaps" in viable hit angles.
			//Yeah, I tested it for real. Fall in a linear fashion, because while it's unrealistic, it IS at least consistent.
			//degrade = 0.5 * Square(alpha);
			degrade = Alpha;
			HitLocation.Z += degrade * (Owner.Location.Z - Owner.CollisionHeight);
			ProcessTraceHit(Other, HitLocation, HitNormal, vector(AdjustedAim),Y,Z);
		}*/
		
		//111111111111111111111111111111111
		//VMD Bullet Block Part A: Calculation, and penetration.
		//---------------------------------
		//If superior axis = our superior axis, then penetrate.
		//Otherwise, ricochet.
		//---------------------------------
		//MADDERS, 4/17/22: Don't ricochet or penetrate on fake backdrop. Bad.
		if (((TexFlags & 0x00000080) == 0) && (!bSimulatedDrop))
		{
			if (!VMDAngleMeansRicochet(HitLocation, Normal(HitLocation - StartTrace), HitNormal, TexGroup, Other))
			{
				if ((Other != None) && (VMDGetMaterialPenetration(Other) > 0.0))
				{
	  				//Same basic law, except we use
	  				//previous assumption as start.
	  				if ( Other.IsA('Pawn') )
	  				{
						//MADDERS: Don't penetrate if we don't reach far enough. Thanks.
						if (VMDGetMaterialPenetration(Other) < Other.CollisionRadius*2) return;
						
	  					TestPenetration = FMin(VMDGetMaterialPenetration(Other), Other.CollisionRadius*2);
	  				}
	  				else
	  				{
	  					TestPenetration = VMDGetMaterialPenetration(Other)*2;
	  				}
	  				
	  				//Do a second trace inbetween to get the actual distance between entry A and exit B
	  				if (Other != None)
	   					BackOther = Trace(BackHitLocation, BackHitNormal, HitLocation, HitLocation + HitNormal + TestPenetration * X, Other.IsA('Pawn'));
	  				
	  				//Also do a bit of a hack to produce bullet holes on
	  				//the other side of the wall or door we went through
	  				if (Mover(BackOther) != None || BackOther == Level)
					{
						HitDamage = PenetrationHitDamage;
						ProcessTraceHit(BackOther, BackHitLocation, BackHitNormal, X,Y,Z);
						
						//MADDERS: Spawn effects here.
						if (!bHandToHand) VMDShellProcessTraceHit(BackOther, BackHitLocation, BackHitNormal, X,Y,Z); //Vector(AdjustedAim)
						
						HitDamage = OldDamage;
	  				}
	  				//add an assumed error margin of about 4 UU's.
	  				//I'd be surprised if this wasn't necessary
	  				//Penetration = VSize(HitLocation - BackHitLocation) + 4;
	  				
	  				//NewStartTrace = HitLocation + HitNormal + Penetration * X;
	  				//NewEndTrace = NewStartTrace + Accuracy * (FRand() - 0.50) * Y * 1000 + Accuracy * (FRand() - 0.50) * Z * 1000;
	  				//NewEndTrace += TRange * X * ARM;
					NewStartTrace = BackHitLocation;
					NewEndTrace = NewStartTrace + (TRange * X * ARM);
					//MADDERS: Fling a tracer out of our impact spot.
                	  		TTracer = Spawn(VMDConfigureTracerClass(0, 1), Owner,, NewStartTrace + 24 * Normal(NewEndTrace - NewStartTrace), Rotator(NewEndTrace - NewStartTrace));
	  				NewOther = Pawn(Owner).TraceShot(NewHitLocation, NewHitNormal, NewEndTrace, NewStartTrace);
	  				
					HitDamage = PenetrationHitDamage;
	  				ProcessTraceHit(NewOther, NewHitLocation, NewHitNormal, X, Y, Z);
					
					//MADDERS: Spawn effects here.
					if (!bHandToHand) VMDShellProcessTraceHit(NewOther, NewHitLocation, NewHitNormal, vector(AdjustedAim),Y,Z);
					HitDamage = OldDamage;
				}
			}
			//222222222222222222222222222222222
			//VMD Bullet Block Part B: Ricochet that shit, yo.
			//Only ricochet off of terrain.
			else if (Mover(Other) != None || Other == Level)
			{
				if (VMDGetNumRicochets() > 0)
				{
					//MADDERS: Play a ricochet sound at the first hit location.
					if (k == 0) VMDPlayRicochetSound(HitLocation);
						
					NewStartTrace = HitLocation;
					NewHitNormal = HitNormal;
					BastardNormal = VMDBastardizeNormal(Normal(HitLocation - StartTrace), NewHitNormal);
					for (j=0; j<VMDGetNumRicochets(); j++)
					{
						NewEndTrace = NewStartTrace + (BastardNormal * TRange * ARM);				
		  				NewOther = Pawn(Owner).TraceShot(NewHitLocation, NewHitNormal, NewEndTrace, NewStartTrace);
						
						rot = Rotator(EndTrace - StartTrace);
						//MADDERS: Slower ricochets for the true bullet exit.
               					if (j == (VMDGetNumRicochets()-1))
						{
							TTracer = Spawn(VMDConfigureTracerClass(j+1, 0), Owner,, NewStartTrace + 16 * Normal(NewEndTrace - NewStartTrace), Rotator(NewEndTrace - NewStartTrace));
 						}
               					else
						{
							//MADDERS: Play a ricochet sound at the hit location.
							if (k == 0) VMDPlayRicochetSound(HitLocation);
                 					TTracer = Spawn(VMDConfigureTracerClass(j+1, 0), Owner,, NewStartTrace + 16 * Normal(NewEndTrace - NewStartTrace), Rotator(NewEndTrace - NewStartTrace));
						}
						HitDamage = VMDGetRicochetDamage(Other);
	  					ProcessTraceHit(NewOther, NewHitLocation, NewHitNormal, X, Y, Z);
						
						//MADDERS: Spawn effects here.
						if (!bHandToHand) VMDShellProcessTraceHit(NewOther, NewHitLocation, NewHitNormal, vector(AdjustedAim),Y,Z);
						HitDamage = OldDamage;
						
						BastardNormal = VMDBastardizeNormal(Normal(NewHitLocation - NewStartTrace), NewHitNormal);
						NewStartTrace = NewHitLocation;
					}
					k++;
				}
			}
		}
	}
	// otherwise we don't hit the target at all
}

simulated function ProcessTraceHit(Actor Other, Vector HitLocation, Vector HitNormal, Vector X, Vector Y, Vector Z)
{
	local float        mult, value;
	local name         damageType;
	local DeusExPlayer dxPlayer, DXP;
	local DeusExRootWindow DXRW;
	local DeusExMover DXM;
	
	local bool bWasFood, bShowIndicator, bQueueTranqFailNoise;
	local int SeedMath;
	local float FOM, ARM, Size, CrowbarThresh; //Falloff Mult
	local vector Loc;
	local FleshFragment Chunk;
	
	//Trash for HC movers.
	local float OldScoutThresh, UsePitch;
	
	if (Other != None)
	{		
		if ((VMDBufferDeco(Other) != None) && (DeusExPlayer(Owner) != None))
		{
			VMDBufferDeco(Other).bEverNotFrobbed = false;
		}
		if ((bHandToHand) && (VMDBufferPawn(Other) != None) && (DeusExPlayer(Owner) != None))
		{
			VMDBufferPawn(Other).bEverNotFrobbed = false;
		}
		
		//MADDERS: Falsely update our hit indicator. Fuck hit indicators in general.
		//Update: Don't do it falsely. We found a way to make it convey meaningful information, AND be optional.
		DXP = DeusExPlayer(Owner);
		if ((DXP != None) && (Other != Level))
		{
			bShowIndicator = true;
			if ((VMDBufferPawn(Other) != None) && (VMDBufferPawn(Other).bInsignificant)) bShowIndicator = false;
			if (Mover(Other) != None) bShowIndicator = false;
			if ((DeusExMover(Other) != None) && (!DeusExMover(Other).bBreakable)) bShowIndicator = false;
			if (Other.AIGetLightLevel(Other.Location) <= 0.005) bShowIndicator = false;
			
			//MADDERS, 8/29/22: this one is axed because headshots still show, and it has useful information still.
			//if (bHandToHand) bShowIndicator = false;
			
			//MADDERS, 1/17/21: Require a clean trace so we don't metagame.
			if (!FastTrace(DXP.Location+vect(0,0,1)*DXP.BaseEyeHeight, HitLocation)) bShowIndicator = false;
			
			if (bShowIndicator)
			{
		 		DXRW = DeusExRootWindow(DXP.RootWindow);
		 		if (DXRW != None)
		 		{
		 	 		DXRW.Hud.HitInd.SetIndicator(True);
		 		}
			}
		}
		
		// AugCombat increases our damage if hand to hand
		mult = 1.0;
		/*if ((bHandToHand) && (DeusExPlayer(Owner) != None) && (VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem) != None))
		{
			//MADDERS: Remove this feature entirely.
			mult = DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
			if (mult == -1.0)
			{
				mult = 1.0;
			}
			
			Mult = VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem).VMDConfigureWepDamageMult(Self);
			if (mult == 0.0)
			{
				mult = 1.0;
			}
		}*/
		
		// skill also affects our damage
		// GetWeaponSkill returns 0.0 to -0.7 (max skill/aug)
		mult += (VMDGetWeaponSkill("DAMAGE") - 1.0);
		
		if (!VMDIsMeleeWeapon())
		{
			ARM = 1.0;
			if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolScope')))
			{
				ARM *= 1.35;
			}
			
			if (FalloffStartRange < 1)
			{
				FOM = FClamp(1.15 - (VSize(HitLocation - Location) / (AccurateRange * ARM)) * 0.5, 0.25, 1.0);
			}
			else
			{
				FOM = FClamp(1.15 - (VSize(HitLocation - Location) / (FalloffStartRange * ARM)) * 0.5, 0.25, 1.0);
			}
			mult *= FOM;
		}
		
		if ((WeaponPistol(Self) != None) && (bHasEvolution))
		{
		 	if (bHasEvolution) Mult *= 2; //Neat.
		}
		
		// Determine damage type
		damageType = WeaponDamageType();
		
		//MADDERS, 12/31/23: When shooting people who resist explosions better than sabot, give them sabot instead.
		if ((VMDBufferPawn(Other) != None) && (VMDBufferPawn(Other).bHasAugmentations) && (Ammo3006HEAT(AmmoType) != None || Ammo10mmHEAT(AmmoType) != None))
		{
			DamageType = 'Sabot';
		}
		
		if ((Other != None) && (Owner != None) && (Ammo3006Tranq(AmmoType) != None) && (VSize(Other.Location - Owner.Location) < 320))
		{
			DamageType = 'Shot';
			if (Pawn(Other) != None)
			{
				bQueueTranqFailNoise = true;
			}
		}
		
		if (Other != None)
		{
			dxPlayer = DeusExPlayer(Owner);
			if (Other.bOwned)
			{
				if (dxPlayer != None)
					dxPlayer.AISendEvent('Futz', EAITYPE_Visual);
			}
			//MADDERS: Eat dead animals for food. Yikes. Combat knife only.
			if ((VMDIsWeaponName("Knife")) && (VMDBufferPlayer(Owner) != None))
			{
				if ((DeusExCarcass(Other) != None) && (VMDIsValidFood(Other)) && (DeusExCarcass(Other).bAnimalCarcass) && (!DeusExCarcass(Other).bInvincible))
				{
					if (!VMDOtherIsName(Other, "Gray"))
					{
						VMDBufferPlayer(Owner).VMDRegisterFoodEaten(3, "Dead Animal");
						
						//MADDERS: Sometimes deal poison damage, non-gameable.
						SeedMath = class'VMDStaticFunctions'.Static.DeriveActorSeed(Other, 7, True);
						SeedMath = (SeedMath + DeusExCarcass(Other).TimesMunched) % 7;
						DeusExCarcass(Other).TimesMunched++;
					}
					else
					{
						VMDBufferPlayer(Owner).VMDRegisterFoodEaten(3, "Dead Gray");
					}
					
					Other.TakeDamage(45, Pawn(Owner), HitLocation, 1000.0*X, damageType);
					bWasFood = True;
				}
				//Fish is the best food of all.
				else if (Fishes(Other) != None)
				{
					VMDBufferPlayer(Owner).VMDRegisterFoodEaten(2, "Fish");
				}
				Size = (Other.CollisionRadius + Other.CollisionHeight) / 2;
				if ((bWasFood) && (Size > 10.0))
				{
					Loc.X = (1-2*FRand()) * 10;
					Loc.Y = (1-2*FRand()) * 10;
					Loc.Z = (1-2*FRand()) * 5;
					Loc += HitLocation;
					Chunk = spawn(class'FleshFragment', None,, Loc);
					if (Chunk != None)
					{
						Chunk.DrawScale = Size / 25;
						Chunk.SetCollisionSize(Chunk.CollisionRadius / Chunk.DrawScale, Chunk.CollisionHeight / Chunk.DrawScale);
						Chunk.bFixedRotationDir = True;
						Chunk.RotationRate = RotRand(False);
					}
				}
			}
			if ((Other == Level) || (Other.IsA('Mover')))
			{
				//MADDERS, 4/15/21: Not ideal, but reveal this mover with 3rd party means.
				if (Other.IsA('CBreakableGlass'))
				{
					Other.bIsSecretGoal = true;
					if (Other.BlendTweenRate[0] == 0.0) Other.BlendTweenRate[0] = float(Other.GetPropertyText("DoorStrength"));
					OldScoutThresh = Other.BlendTweenRate[1];
					/*if (!VMDHasSkillAugment('LockpickScoutNoise'))
					{
						Other.BlendTweenRate[1] = Clamp(int(VMDGetCorrectHitDamage(HitDamage)), Other.BlendTweenRate[1], int(Other.GetPropertyText("MinDamageThreshold")));
					}
					else
					{*/
						//MADDERS, 12/5/23: This is now standard functionality again.
						Other.BlendTweenRate[1] = Clamp(int(VMDGetCorrectHitDamage(HitDamage))+Other.BlendTweenRate[1], Other.BlendTweenRate[1], int(Other.GetPropertyText("MinDamageThreshold")));
					//}
					
					if ((OldScoutThresh < Other.BlendTweenRate[1]) && (bHandToHand))
					{
						UsePitch = (1.45 + (Frand() * 0.3)) / 2;
						if (Other.GetPropertyText("FragmentClass") ~= "DeusEx.WoodFragment")
						{
							PlaySound(sound'BatonHitHard',SLOT_Misc,10,,,UsePitch);
						}
						else
						{
							PlaySound(sound'BulletproofHit',SLOT_Misc,10,,,UsePitch);
							PlaySound(sound'BulletproofHit',SLOT_Interact,10,,,UsePitch);
						}
					}
				}
				
				DXM = DeusExMover(Other);
				//MADDERS: Set highlight to true as we have scouted this wall.
				if ((DXM != None) && (bHandToHand))
				{
					DXM.bHighlight = true;
					if (VMDIsWeaponName("Crowbar"))
					{
						CrowbarThresh = VMDGetBruteForceThresh();
						if (DXM.VMDIsSoftDoor()) CrowbarThresh = FMax(0.15, CrowbarThresh);
						
						if ((DXM.bLocked) && (DXM.bFrobbable) && (DXM.bPickable) && (DXM.LockStrength <= CrowbarThresh+0.005))
						{
							if (DXM.VMDIsSoftDoor())
							{
								if (VMDHasSkillAugment('MeleeDoorCrackingWood'))
								{
									DXM.bLockRevealed = true;
									//DXM.LockStrength -= (FRand() * (CrowbarThresh*2)); //With augments on the scene, average out to a one shot.
									DXM.LockStrength -= CrowbarThresh;
									if (DXM.LockStrength <= 0)
									{
										VMDPlaySimSound( Sound'WoodBreakSmall', SLOT_Misc, TransientSoundVolume, 2048, VMDGetMiscPitch());
										DXM.bLocked = false;
									}
								}
							}
							//MADDERS, 4/6/20: Augments are on the scene. Doubling this threshold. Using wood's old rate, too.
							else
							{
								if (VMDHasSkillAugment('TagTeamDoorCrackingMetal'))
								{
									DXM.bLockRevealed = true;
									DXM.LockStrength -= (FRand() * (CrowbarThresh*0.4)); //0.02
									if (DXM.LockStrength <= 0)
									{
										VMDPlaySimSound( Sound'MetalBounce1', SLOT_Misc, TransientSoundVolume, 2048, VMDGetMiscPitch());
										DXM.bLocked = false;
									}
								}
							}
						}
					}
				}
				if ( Role == ROLE_Authority )
				{
					if (VMDBufferPawn(Other) != None)
					{
						VMDBufferPawn(Other).LastWeaponDamageSkillMult = VMDGetScaledDamage(float(HitDamage) + (GetWM2FloatDamage()), Mult) / VMDGetCorrectHitDamage(float(HitDamage));
						Other.TakeDamage(VMDGetCorrectHitDamage(HitDamage), Pawn(Owner), HitLocation, 1000.0*X, damageType);
					}
					else if (VMDBufferPlayer(Other) != None)
					{
						VMDBufferPlayer(Other).LastWeaponDamageSkillMult = VMDGetScaledDamage(float(HitDamage) + (GetWM2FloatDamage()), Mult) / VMDGetCorrectHitDamage(float(HitDamage));
						Other.TakeDamage(VMDGetCorrectHitDamage(HitDamage), Pawn(Owner), HitLocation, 1000.0*X, damageType);
					}
					else if (Brush(Other) != None)
					{
						Other.TakeDamage(Max(1, VMDGetScaledDamage(HitDamage, Mult * MoverDamageMult)), Pawn(Owner), HitLocation, Vect(0,0,0), 'Exploded');
					}
					else
					{
						Other.TakeDamage(Max(1, VMDGetScaledDamage(HitDamage, Mult)), Pawn(Owner), HitLocation, 1000.0*X, damageType);
					}
				}
				SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);
			}
			else if ((Other != self) && (Other != Owner))
			{
				if ((VMDBufferPawn(Other) != None) && (FiringSystemOperation == 1) && (VMDBufferPlayer(Owner) != None))
				{
					VMDBufferPawn(Other).bClosedSystemHit = true;
				}	
				if ( Role == ROLE_Authority )
				{
					if (VMDBufferPawn(Other) != None)
					{
						VMDBufferPawn(Other).LastWeaponDamageSkillMult = VMDGetScaledDamage(float(HitDamage) + (GetWM2FloatDamage()), Mult) / VMDGetCorrectHitDamage(float(HitDamage));
						Other.TakeDamage(VMDGetCorrectHitDamage(HitDamage), Pawn(Owner), HitLocation, 1000.0*X, damageType);
					}
					else if (VMDBufferPlayer(Other) != None)
					{
						VMDBufferPlayer(Other).LastWeaponDamageSkillMult = VMDGetScaledDamage(float(HitDamage) + (GetWM2FloatDamage()), Mult) / VMDGetCorrectHitDamage(float(HitDamage));
						Other.TakeDamage(VMDGetCorrectHitDamage(HitDamage), Pawn(Owner), HitLocation, 1000.0*X, damageType);
					}
					else if (Brush(Other) != None)
					{
						Other.TakeDamage(Max(1, VMDGetScaledDamage(HitDamage, Mult * MoverDamageMult)), Pawn(Owner), HitLocation, Vect(0,0,0), 'Exploded');
					}
					else
					{
						Other.TakeDamage(Max(1, VMDGetScaledDamage(HitDamage, mult)), Pawn(Owner), HitLocation, 1000.0*X, damageType);
					}
				}
				if (bHandToHand)
					SelectiveSpawnEffects( HitLocation, HitNormal, Other, HitDamage * mult);
				
				if ((bPenetrating) && (Other.IsA('ScriptedPawn')) && (ScriptedPawn(Other).bCanBleed) && (!Other.IsA('Robot')))
					SpawnBlood(HitLocation, HitNormal);
			}
		}
		VMDHandleAmmoEffects(Other, HitLocation, HitNormal);
	}
   	if (DeusExMPGame(Level.Game) != None)
   	{
      		if (DeusExPlayer(Other) != None)
         		DeusExMPGame(Level.Game).TrackWeapon(self, HitDamage * mult);
		else if (ScriptedPawn(Other) != None)
			DeusExGameInfo(Level.Game).TrackWeapon(self,HitDamage * mult);
      		else
         		DeusExMPGame(Level.Game).TrackWeapon(self,0);
   	}
	
	if (bQueueTranqFailNoise)
	{
		VMDPlayTranqFailNoise();
	}
}

simulated function IdleFunction()
{
	PlayIdleAnim();
	bInProcess = False;
	if ( bFlameOn )
	{
		StopFlame();
		bFlameOn = False;
	}
}

simulated function SimFinish()
{
	local bool bRefireSemiauto;
	
	ServerGotoFinishFire();
	
	bInProcess = False;
	bFiring = False;
	
	if (bFlameOn)
	{
		StopFlame();
		bFlameOn = False;
	}
	
	if (bHasMuzzleFlash)
		EraseMuzzleFlashTexture();
	
	if ((Owner.IsA('DeusExPlayer')) && (DeusExPlayer(Owner).bAutoReload|| VMDIsWeaponName("Hideagun")))
	{
		if ((SimClipCount >= ReloadCount) && (CanReload()))
		{
			SimClipCount = 0;
			bClientReadyToFire = False;
			bInProcess = False;
			if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
				CycleAmmo();
			ReloadAmmo();
		}
	}
	
	if (Pawn(Owner) == None)
	{
		GotoState('SimIdle');
		return;
	}
	if (PlayerPawn(Owner) == None)
	{
		if ((Pawn(Owner).bFire != 0) && (FRand() < RefireRate))
			ClientReFire(0);
		else
			GotoState('SimIdle');
		return;
	}
	
	//MADDERS: Config preference for refiring.
	if (VMDBufferPlayer(Owner) != None)
	{
		bRefireSemiauto = VMDBufferPlayer(Owner).bRefireSemiauto;
	}
	
	if ((Pawn(Owner).bFire != 0) && (((!bSemiautoTrigger) && (!bBurstFire) ) || bRefireSemiAuto))
	{
		ClientReFire(0);
	}
	else
	{
		GotoState('SimIdle');
	}
}

// Finish a firing sequence (ripped off and modified from Engine\Weapon.uc)
function Finish()
{
	local bool bRefireSemiauto, bHandToHandObjection;
	
	if (Level.NetMode != NM_Standalone)
		ReadyClientToFire(True);
	
	if (bHasMuzzleFlash)
		EraseMuzzleFlashTexture();
	
	if (bChangeWeapon)
	{
		GotoState('DownWeapon');
		return;
	}
	
	if ((Level.NetMode != NM_Standalone) && IsInState('Active'))
	{
		GotoState('Idle');
		return;
	}
	
	if (Pawn(Owner) == None)
	{
		GotoState('Idle');
		return;
	}
	if ( PlayerPawn(Owner) == None )
	{
		//bFireMem = false;
		//bAltFireMem = false;
		if (((AmmoType == None) || (AmmoType.AmmoAmount <= 0)) && (ReloadCount != 0))
		{
			Pawn(Owner).StopFiring();
			Pawn(Owner).SwitchToBestWeapon();
		}
		else if ((Pawn(Owner).bFire != 0) && (FRand() < RefireRate))
			Global.Fire(0);
		else if ((Pawn(Owner).bAltFire != 0) && (FRand() < AltRefireRate))
			Global.AltFire(0);	
		else 
		{
			Pawn(Owner).StopFiring();
			GotoState('Idle');
		}
		return;
	}
	
	if (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && (Owner.IsA('DeusExPlayer')) && (!DeusExPlayer(Owner).PlayerIsListenClient())))
	{
		GotoState('Idle');
		return;
	}
	
	//MADDERS: Config preference for refiring.
	if (VMDBufferPlayer(Owner) != None)
	{
		bRefireSemiauto = VMDBufferPlayer(Owner).bRefireSemiauto;
	}
	bHandToHandObjection = (!(!bHandToHand || !bInstantHit || !bRefireSemiauto));
	
	if (((AmmoType == None) || (ClipCount >= ReloadCount) || ((AmmoType.AmmoAmount <= 0) && (!bHandToHandObjection))) || (Pawn(Owner).Weapon != self))
		GotoState('Idle');
	else if ((Pawn(Owner).bFire != 0) && (((!bSemiautoTrigger) && (!bBurstFire)) || bRefireSemiauto)) // /*bFireMem ||*/ 
		Global.Fire(0);
	else if (Pawn(Owner).bAltFire != 0)  // /*bAltFireMem ||*/ 
		Global.AltFire(0);
	else 
		GotoState('Idle');
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInventoryInfoWindow winInfo;
	local string str;
	local int i, TReloadCount;
	local float mod, ARM, dmg;
	local bool bHasAmmo;
	local bool bAmmoAvailable;
	local class<DeusExAmmo> ammoClass;
	local Pawn P;
	local Ammo weaponAmmo;
	local int ammoAmount, TNumProj;
	
	//MADDERS: Redundant, but I'm lazy and thus playing it safe.
	local Ammo TAmmo;
	local bool FlagHasAmmo;
	local int TEff, TMetric;

	P = Pawn(Owner);
	if (P == None)
		return False;

	winInfo = PersonaInventoryInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.SetTitle(itemName);
	winInfo.SetText(msgInfoWeaponStats);
	winInfo.AddLine();

	// Create the ammo buttons.  Start with the AmmoNames[] array,
	// which is used for weapons that can use more than one 
	// type of ammo.

	if (AmmoNames[0] != None)
	{
		for (i=0; i<ArrayCount(AmmoNames); i++)
		{
			if (AmmoNames[i] != None) 
			{
				// Check to make sure the player has this ammo type
				// *and* that the ammo isn't empty
				weaponAmmo = Ammo(P.FindInventoryType(AmmoNames[i]));

				if (weaponAmmo != None)
				{
					ammoAmount = weaponAmmo.AmmoAmount;
					bHasAmmo = (weaponAmmo.AmmoAmount > 0);
				}
				else
				{
					ammoAmount = 0;
					bHasAmmo = False;
					
					//MADDERS: Skip labeling ammos we don't have. Exploration, ahoy!
					continue;
				}
				
				winInfo.AddAmmo(AmmoNames[i], bHasAmmo, ammoAmount);
				bAmmoAvailable = True;
				
				if (AmmoNames[i] == AmmoName)
				{
					winInfo.SetLoaded(AmmoName);
					ammoClass = class<DeusExAmmo>(AmmoName);
				}
			}
		}
	}
	else
	{
		// Now peer at the AmmoName variable, but only if the AmmoNames[] 
		// array is empty
		if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
		{	
			weaponAmmo = Ammo(P.FindInventoryType(AmmoName));
			
			if (weaponAmmo != None)
			{
				ammoAmount = weaponAmmo.AmmoAmount;
				bHasAmmo = (weaponAmmo.AmmoAmount > 0);
			}
			else
			{
				ammoAmount = 0;
				bHasAmmo = False;
			}
			
			winInfo.AddAmmo(AmmoName, bHasAmmo, ammoAmount);
			winInfo.SetLoaded(AmmoName);
			ammoClass = class<DeusExAmmo>(AmmoName);
			bAmmoAvailable = True;
		}
	}

	// Only draw another line if we actually displayed ammo.
	if (bAmmoAvailable)
		winInfo.AddLine();	

	// Ammo loaded
	if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
		winInfo.AddAmmoLoadedItem(msgInfoAmmoLoaded, AmmoType.itemName);

	// ammo info
	if ((AmmoName == class'AmmoNone') || bHandToHand || (ReloadCount == 0))
		str = msgInfoNA;
	else
		str = AmmoName.Default.ItemName;
	
	for (i=0; i<ArrayCount(AmmoNames); i++)
	{
		//MADDERS: Only list ammos we have, similar to above. Spoilers, bruh.
		if ((AmmoNames[i] != None) && (AmmoNames[i] != AmmoName))
		{
			TAmmo = Ammo(P.FindInventoryType(AmmoNames[i]));
			FlagHasAmmo = (TAmmo != None);
			
			if (FlagHasAmmo || i == 0)
			{
				str = str $ "|n" $ AmmoNames[i].Default.ItemName;
			}
		}
	}
	
	winInfo.AddAmmoTypesItem(msgInfoAmmo, str);
	
	// base damage
	//--------------------
	//MADDERS: Read this out separately now.
	/*if (AreaOfEffect == AOE_Cone)
	{
		if (bInstantHit)
		{
			if (Level.NetMode != NM_Standalone)
				dmg = Default.mpHitDamage * 5;
			else
				dmg = Default.HitDamage * 5;
		}
		else
		{
			if (Level.NetMode != NM_Standalone)
				dmg = Default.mpHitDamage * 3;
			else
				dmg = Default.HitDamage * 3;
		}
	}*/
	//else
	//{
		if (Level.NetMode != NM_Standalone)
			dmg = VMDGetCorrectHitDamage(Default.MPHitDamage);
		else
			dmg = VMDGetCorrectHitDamage(float(HitDamage) + (GetWM2FloatDamage()));
	//}
	TNumProj = 1;
	if (AreaOfEffect == AOE_Cone)
	{
		if (bInstantHit) TNumProj = 5;
		else TNumProj = 3;
	}
	TNumProj = VMDGetCorrectNumProj(TNumProj);
	
	//str = String(dmg*2);
	str = VMDFormatFloatString(dmg*2, 0.1, "Damage Mod");
	mod = VMDGetWeaponSkill("DAMAGE"); //1.0 - GetWeaponSkill();
	if (mod != 1.0)
	{
		str = str @ BuildPercentString(mod - 1.0);
		str = str @ "=" @ VMDFormatFloatString(VMDGetScaledDamage(dmg)*2, 0.1, "Damage Mod")@"x"@TNumProj;
	}
	else
	{
		str = str@"x"@TNumProj;
	}
	
	winInfo.AddInfoItem(msgInfoDamage, str, (mod != 1.0));
	
	str = VMDFormatFloatString(MoverDamageMult * 100.0, 0.1, "Damage Mod")$"%";
	WinInfo.AddInfoItem(msgInfoMoverDamageMult, str, false);
	
	//-------------------------
	//MADDERS additions:
	if ((VMDIsBulletWeapon()) && (HitDamage > 0))
	{
		TMetric = int(VMDGetMaterialPenetration(Level) * 0.75);
		TEff = int((float(PenetrationHitDamage) / dmg)*100);
		WinInfo.AddInfoItem(PenetrationLabel, SprintF(PenetrationDesc, TMetric, TEff), false);
		
		TMetric = VMDGetNumRicochets();
		TEff = int((VMDGetRicochetDamage(None) / dmg)*100);
		WinInfo.AddInfoItem(RicochetLabel, SprintF(RicochetDesc, TMetric, TEff), false);
	}

	// clip size
	if ((Default.ReloadCount == 0) || bHandToHand)
	{
		str = msgInfoNA;
	}
	else
	{
		if ( Level.NetMode != NM_Standalone )
		{
			str = Default.mpReloadCount @ msgInfoRounds;
		}
		else
		{
			str = Default.ReloadCount @ msgInfoRounds;
		}
	}
	
	if (HasClipMod())
	{
		str = str @ BuildPercentString(ModReloadCount + (float(VMDHasOpenSystemMagBoost()) / float(Default.ReloadCount)));
		str = str @ "=" @ (ReloadCount + int(VMDHasOpenSystemMagBoost())) @ msgInfoRounds;
	}
	
	winInfo.AddInfoItem(msgInfoClip, str, HasClipMod());
	
	// reload time
	if ((Default.ReloadCount == 0) || bHandToHand)
		str = msgInfoNA;
	else
	{
		if (Level.NetMode != NM_Standalone )
			str = VMDFormatFloatString(Default.mpReloadTime, 0.01, "Reload Time SP") @ msgTimeUnit;
		else
			str = VMDFormatFloatString(Default.ReloadTime, 0.01, "Reload Time SP") @ msgTimeUnit;
	}
	
	if (HasReloadMod())
	{
		str = str @ BuildPercentString(ModReloadTime);
		str = str @ "=" @ VMDFormatFloatString(ReloadTime, 0.01, "Reload Mod") @ msgTimeUnit;
	}
	
	winInfo.AddInfoItem(msgInfoReload, str, HasReloadMod());

	// rate of fire
	if ((Default.ReloadCount == 0) || bHandToHand)
	{
		str = msgInfoNA;
	}
	else
	{
		if (bBurstFire)
			str = MsgInfoBurst;
		else if (bAutomatic)
			str = msgInfoAuto;
		else
			str = msgInfoSingle;

		if ((AmmoType != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
			str = str $ "," @ VMDFormatFloatString(1.0/Default.ShotTime, 0.1, "ROF Gun") @ msgInfoRounds$msgInfoPerSec;
		else
			str = str $ "," @ VMDFormatFloatString(1.0/Default.ShotTime, 0.1, "ROF Melee") @ msgInfoRoundsPerSec;
	}
	winInfo.AddInfoItem(msgInfoROF, str);
	
	if (NumFiringModes > 1)
	{
		for (i=0; i<NumFiringModes; i++)
		{
			if (i == 0)
			{
				Str = ModeNames[i];
			}
			else
			{
				Str = Str$","@ModeNames[i];
			}
		}
	}
	winInfo.AddInfoItem(FiringModesLabel, str);
	
	// base accuracy (2.0 = 0%, 0.0 = 100%)
	if ( Level.NetMode != NM_Standalone )
	{
		str = Int((2.0 - Default.mpBaseAccuracy)*50.0) $ "%";
		mod = (Default.mpBaseAccuracy - (BaseAccuracy + VMDGetWeaponSkill("ACCURACY"))) * 0.5;
		if (mod != 0.0)
		{
			str = str @ BuildPercentString(mod);
			str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.mpBaseAccuracy)*50.0)) $ "%";
		}
	}
	else
	{
		str = Int((2.0 - Default.BaseAccuracy)*50.0) $ "%";
		mod = (Default.BaseAccuracy - (BaseAccuracy + VMDGetWeaponSkill("ACCURACY"))) * 0.5;
		if (mod != 0.0)
		{
			str = str @ BuildPercentString(mod);
			str = str @ "=" @ Min(100, Int(100.0*mod+(2.0 - Default.BaseAccuracy)*50.0)) $ "%";
		}
	}
	winInfo.AddInfoItem(msgInfoAccuracy, str, (mod != 0.0));
	
	// recoil
	str = VMDFormatFloatString(Default.recoilStrength, 0.01, "Recoil");
	if (HasRecoilMod())
	{
		str = str @ BuildPercentString(ModRecoilStrength);
		str = str @ "=" @ VMDFormatFloatString(recoilStrength, 0.01, "Recoil Mod");
	}
	
	winInfo.AddInfoItem(msgInfoRecoil, str, HasRecoilMod());

	// accurate range
	if (bHandToHand)
	{
		str = msgInfoNA;
	}
	else
	{
		if ( Level.NetMode != NM_Standalone )
			str = VMDFormatFloatString(Default.mpAccurateRange/16.0, 1.0, "Acc Range MP") @ msgRangeUnit;
		else
			str = VMDFormatFloatString(Default.AccurateRange/16.0, 1.0, "Acc Range SP") @ msgRangeUnit;
	}
	
	ARM = 1.0;
	if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolScope')))
	{
		ARM = 1.35;
	}
	
	if (HasRangeMod())
	{
		str = str @ BuildPercentString(((1.0 + ModAccurateRange)*ARM)-1.0);
		str = str @ "=" @ VMDFormatFloatString((AccurateRange*ARM)/16.0, 1.0, "Acc Range Mod") @ msgRangeUnit;
	}
	winInfo.AddInfoItem(msgInfoAccRange, str, HasRangeMod());
	
	// max range
	if (bHandToHand)
		str = msgInfoNA;
	else
	{
		if ( Level.NetMode != NM_Standalone )
			str = VMDFormatFloatString(Default.mpMaxRange/16.0, 1.0, "Max Range MP") @ msgRangeUnit;
		else
			str = VMDFormatFloatString(Default.MaxRange/16.0, 1.0, "Max Range SP") @ msgRangeUnit;
	}
	winInfo.AddInfoItem(msgInfoMaxRange, str);

	if (FiringSystemOperation == 1) winInfo.AddInfoItem(FiringSystemLabel, ClosedSystemDesc, false);
	else if (FiringSystemOperation == 2) winInfo.AddInfoItem(FiringSystemLabel, OpenSystemDesc, false);
	
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).bGrimeEnabled) && (VMDHasGrimeLevel()))
	{
		WinInfo.AddInfoItem(GrimeLevelLabel, GrimeLevelDesc[VMDGetGrimeLevel()], false);
	}	

	// mass
	winInfo.AddInfoItem(msgInfoMass, VMDFormatFloatString(Default.Mass, 1.0, "Mass") @ msgMassUnit);

	// laser mod
	if (bCanHaveLaser)
	{
		if (bHasLaser)
			str = msgInfoYes;
		else
			str = msgInfoNo;
	}
	else
	{
		str = msgInfoNA;
	}
	winInfo.AddInfoItem(msgInfoLaser, str, bCanHaveLaser && bHasLaser && (Default.bHasLaser != bHasLaser));

	// scope mod
	if (bCanHaveScope)
	{
		if (bHasScope)
			str = msgInfoYes;
		else
			str = msgInfoNo;
	}
	else
	{
		str = msgInfoNA;
	}
	winInfo.AddInfoItem(msgInfoScope, str, bCanHaveScope && bHasScope && (Default.bHasScope != bHasScope));

	// silencer mod
	if (bCanHaveSilencer)
	{
		if (bHasSilencer)
			str = msgInfoYes;
		else
			str = msgInfoNo;
	}
	else
	{
		str = msgInfoNA;
	}
	winInfo.AddInfoItem(msgInfoSilencer, str, bCanHaveSilencer && bHasSilencer && (Default.bHasSilencer != bHasSilencer));

	// Governing Skill
	if (GoverningSkill != None)
	{
		winInfo.AddInfoItem(msgInfoSkill, GoverningSkill.default.SkillName);
	}
	
	winInfo.AddLine();
	winInfo.SetText(Description);

	// If this weapon has ammo info, display it here
	if (ammoClass != None)
	{
		winInfo.AddLine();
		winInfo.AddAmmoDescription(ammoClass.Default.ItemName $ "|n" $ ammoClass.Default.description);
	}

	return True;
}

// ----------------------------------------------------------------------
// UpdateAmmoInfo()
// ----------------------------------------------------------------------

simulated function UpdateAmmoInfo(Object winObject, Class<DeusExAmmo> ammoClass)
{
	local PersonaInventoryInfoWindow winInfo;
	local string str;
	local int i;
	local bool FlagHasAmmo;
	local Ammo TAmmo;
	local DeusExPlayer P;

	winInfo = PersonaInventoryInfoWindow(winObject);
	if (winInfo == None)
		return;

	// Ammo loaded
	if ((AmmoName != class'AmmoNone') && (!bHandToHand) && (ReloadCount != 0))
		winInfo.UpdateAmmoLoaded(AmmoType.itemName);

	// ammo info
	if ((AmmoName == class'AmmoNone') || bHandToHand || (ReloadCount == 0))
		str = msgInfoNA;
	else
		str = AmmoName.Default.ItemName;
	
	P = DeusExPlayer(Owner);
	for (i=0; i<ArrayCount(AmmoNames); i++)
	{
		if ((AmmoNames[i] != None) && (AmmoNames[i] != AmmoName) && (P != None))
		{
			TAmmo = Ammo(P.FindInventoryType(AmmoNames[i]));
			FlagHasAmmo = (TAmmo != None);
			
			if (FlagHasAmmo || i == 0)
			{
				str = str $ "|n" $ AmmoNames[i].Default.ItemName;
			}
		}
	}

	winInfo.UpdateAmmoTypes(str);

	// If this weapon has ammo info, display it here
	if (ammoClass != None)
		winInfo.UpdateAmmoDescription(ammoClass.Default.ItemName $ "|n" $ ammoClass.Default.description);
}

// ----------------------------------------------------------------------
// BuildPercentString()
// ----------------------------------------------------------------------

simulated final function String BuildPercentString(Float value)
{
	local string str;

	str = String(Int(Abs(value * 100.0)));
	if (value < 0.0)
		str = "-" $ str;
	else
		str = "+" $ str;

	return ("(" $ str $ "%)");
}

// ----------------------------------------------------------------------
// FormatFloatString()
// ----------------------------------------------------------------------

simulated function String FormatFloatString(float value, float precision)
{
	local string str;
	
	if (precision == 0.0)
		return "ERR";
	
	// build integer part
	str = String(Int(value));
	
	// build decimal part
	if (precision < 1.0)
	{
		value -= Int(value);
		str = str $ "." $ String(Int((0.5 * precision) + value * (1.0 / precision)));
	}
	
	return Str;
}

simulated function String VMDFormatFloatString(float InVal, float Prec, optional string Context)
{
	local float Rem, TVal;
	local string TStr, Ret;
	
	//MADDERS, 9/19/22: I suck at understanding why the old logic fails in various edge cases.
	//So instead, here's what I'd personally do to not fuck this up:
	Rem = InVal % Prec;
	
	if (Abs(Rem - Prec) < Prec / 10)
	{
		Rem = 0;
	}
	else if (Rem >= Prec/2)
	{
		Rem -= Prec;
	}
	
	TVal = InVal - Rem;
	if (Prec >= 1.0)
	{
		Ret = String(Int(TVal+0.99));
	}
	else if (Prec >= 0.1)
	{
		TStr = String(TVal);
		Ret = Left(TStr, Len(TStr) - 5);
	}
	else
	{
		TStr = String(TVal);
		Ret = Left(TStr, Len(TStr) - 4);
	}
	
	return Ret;
}

// ----------------------------------------------------------------------
// CR()
// ----------------------------------------------------------------------

simulated function String CR()
{
	return Chr(13) $ Chr(10);
}

// ----------------------------------------------------------------------
// HasReloadMod()
// ----------------------------------------------------------------------

simulated function bool HasReloadMod()
{
	return (ModReloadTime != 0.0);
}

// ----------------------------------------------------------------------
// HasMaxReloadMod()
// ----------------------------------------------------------------------

simulated function bool HasMaxReloadMod()
{
	local float SkillAugmentMod;
	
	switch(GoverningSkill)
	{
		case class'SkillWeaponPistol':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('PistolModding'));
		break;
		case class'SkillWeaponRifle':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('RifleModding'));
		break;
	}
	
	return (ModReloadTime <= (-0.5 + SkillAugmentMod));
}

// ----------------------------------------------------------------------
// HasClipMod()
// ----------------------------------------------------------------------

simulated function bool HasClipMod()
{
	return (ModReloadCount != 0.0 || VMDHasOpenSystemMagBoost());
}

// ----------------------------------------------------------------------
// HasMaxClipMod()
// ----------------------------------------------------------------------

simulated function bool HasMaxClipMod()
{
	local float SkillAugmentMod;
	
	switch(GoverningSkill)
	{
		case class'SkillWeaponPistol':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('PistolModding'));
		break;
		case class'SkillWeaponRifle':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('RifleModding'));
		break;
	}
	
	return (ModReloadCount >= (0.5 - SkillAugmentMod));
}

// ----------------------------------------------------------------------
// HasRangeMod()
// ----------------------------------------------------------------------

simulated function bool HasRangeMod()
{
	local float ARM;
	
	ARM = 1.0;
	if ((GoverningSkill == class'SkillWeaponPistol') && (VMDHasSkillAugment('PistolScope')))
	{
		ARM = 1.35;
	}
	
	return (ModAccurateRange != 0.0 || ARM != 1.0);
}

// ----------------------------------------------------------------------
// HasMaxRangeMod()
// ----------------------------------------------------------------------

simulated function bool HasMaxRangeMod()
{
	local float SkillAugmentMod;
	
	switch(GoverningSkill)
	{
		case class'SkillWeaponPistol':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('PistolModding'));
		break;
		case class'SkillWeaponRifle':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('RifleModding'));
		break;
	}
	
	return (ModAccurateRange >= (0.5 - SkillAugmentMod));
}

// ----------------------------------------------------------------------
// HasAccuracyMod()
// ----------------------------------------------------------------------

simulated function bool HasAccuracyMod()
{
	return (ModBaseAccuracy != 0.0);
}

// ----------------------------------------------------------------------
// HasMaxAccuracyMod()
// ----------------------------------------------------------------------

simulated function bool HasMaxAccuracyMod()
{
	local float SkillAugmentMod;
	
	switch(GoverningSkill)
	{
		case class'SkillWeaponPistol':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('PistolModding'));
		break;
		case class'SkillWeaponRifle':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('RifleModding'));
		break;
	}
	
	return (ModBaseAccuracy >= (0.5 - SkillAugmentMod));
}

// ----------------------------------------------------------------------
// HasRecoilMod()
// ----------------------------------------------------------------------

simulated function bool HasRecoilMod()
{
	return (ModRecoilStrength != 0.0);
}

// ----------------------------------------------------------------------
// HasMaxRecoilMod()
// ----------------------------------------------------------------------

simulated function bool HasMaxRecoilMod()
{
	local VMDBufferPlayer VMP;
	local float SkillAugmentMod;
	
	switch(GoverningSkill)
	{
		case class'SkillWeaponPistol':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('PistolModding'));
		break;
		case class'SkillWeaponRifle':
			SkillAugmentMod = 0.2 * int(!VMDHasSkillAugment('RifleModding'));
		break;
	}
	
	return (ModRecoilStrength <= (-0.5 + SkillAugmentMod));
}

// ----------------------------------------------------------------------
// ClientDownWeapon()
// ----------------------------------------------------------------------

simulated function ClientDownWeapon()
{
	bWasInFiring = IsInState('ClientFiring') || IsInState('SimFinishFire');
	bClientReadyToFire = False;
	GotoState('SimDownWeapon');
}

simulated function ClientActive()
{
	bWasInFiring = IsInState('ClientFiring') || IsInState('SimFinishFire');
	bClientReadyToFire = False;
	GotoState('SimActive');
}

simulated function ClientReload()
{
	bWasInFiring = IsInState('ClientFiring') || IsInState('SimFinishFire');
	bClientReadyToFire = False;
	GotoState('SimReload');
}

//
// weapon states
//

state NormalFire
{
	function AnimEnd()
	{
		local bool FlagCanRefire;
		
		// Transcended - Keep firing if melee
		if (bAutomatic || ((AmmoType != None) && (AmmoType.IsA('AmmoNone')) && (bHandToHand)))
		{
			FlagCanRefire = true;
			if (Pawn(Owner) == None || Pawn(Owner).bFire == 0) FlagCanRefire = false;
			if ((AmmoType.AmmoAmount <= 0) && (AmmoNone(AmmoType) == None)) FlagCanRefire = false;
			if (bBurstFire) FlagCanRefire = false;
			
			if (FlagCanRefire)
			{
				if (PlayerPawn(Owner) != None)
					Global.Fire(0);
				else 
					GotoState('FinishFire');
			}
			else 
				GotoState('FinishFire');
		}
		else
		{
			// if we are a thrown weapon and we run out of ammo, destroy the weapon
			if ((bHandToHand) && (ReloadCount > 0) && (AmmoType != None) && (AmmoType.AmmoAmount <= 0))
			{
				if(bZoomed)
					ScopeOff();
				if(bHasLaser)
					LaserOff();
				
				VMDDestroyOnFinishHook();
				Destroy();
			}
		}
	}
	function float GetShotTime()
	{
		local float mult, sTime, AccMod;
		
		if (ScriptedPawn(Owner) != None)
		{
			//MADDERS, 9/1/22: Less killbot, please. Slow and steady.
			if (VMDMegh(Owner) != None)
			{
				return ShotTime * 2;
			}
			else
			{
				Mult = 1.0;
				if ((VMDBufferPawn(Owner) != None) && (VMDBufferPawn(Owner).AugmentationSystem != None))
				{
					Mult = 1.0 / VMDBufferPawn(Owner).AugmentationSystem.VMDConfigureWepSwingSpeedMult(Self);
				}
				
				if (mult <= 0.0)
				{
					mult = 1.0;
				}
				
				//MADDERS, 6/3/23: Holy fucking shit. Minigunner glitch confirmed?
				//6/9/23: Alright, instead of removing accuracy mod, only remove it for automatics.
				//Then, reduce fire rate for assault shotgun and plasma rifle.
				if (bAutomatic)
				{
					return ShotTime * 2 * Mult;
				}
				else if ((VMDGetCorrectNumProj(1) > 1) && (ReloadCount > 6))
				{
					AccMod = ScriptedPawn(Owner).BaseAccuracy;
					if (VMDBufferPawn(Owner) != None)
					{
						AccMod += FMin(Abs(AccMod), VMDBufferPawn(Owner).ROFCounterweight) + VMDBufferPawn(Owner).DifficultyROFWeight;
					}
					//MADDERS, 8/11/23: Nerf for pistol being so damn spammable.
					if (IsA('WeaponPistol'))
					{
						AccMod += 0.25;
					}
					return ShotTime * (AccMod*1+1) * Mult;
				}
				else
				{
					AccMod = ScriptedPawn(Owner).BaseAccuracy;
					if (VMDBufferPawn(Owner) != None)
					{
						AccMod += FMin(Abs(AccMod), VMDBufferPawn(Owner).ROFCounterweight) + VMDBufferPawn(Owner).DifficultyROFWeight;
					}
					//MADDERS, 8/11/23: Nerf for pistol being so damn spammable.
					if (IsA('WeaponPistol'))
					{
						AccMod += 0.25;
					}
					return ShotTime * (AccMod*2+1) * Mult;
				}
			}
		}
		else
		{
			// AugCombat decreases shot time
			mult = 1.0;
			if (bHandToHand)
			{
				if (DeusExPlayer(Owner) != None)
				{
					if (VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem) != None)
					{
						Mult = 1.0 / VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem).VMDConfigureWepSwingSpeedMult(Self);
					}
					else
					{
						mult = 1.0 / DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
					}
				}
				
				if (mult <= 0.0)
				{
					mult = 1.0;
				}
			}
			sTime = ShotTime * mult;
			return (sTime);
		}
	}
	function EndState()
	{
	 	Super.EndState();
	 	
		//MADDERS: Swooce on in with that reload, and make ps20's smooth to operate.
		if ((WeaponHideaGun(Self) != None) && (Owner != None))
			ReloadAmmo();
	 	else if (DeusExPlayer(Owner) != None)
	  		if ((ClipCount >= ReloadCount) && (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun")) && (ReloadCount > 0)) ReloadAmmo();
	 	else if (ScriptedPawn(Owner) != None)
	  		if ((ClipCount >= ReloadCount) && (ReloadCount > 0)) ReloadAmmo();
	}
	function SubstituteOnBelt()
	{
		local DeusExRootWindow root;
		local int i;
		local Actor ThisWeaponClass;
		local Inventory ValidItem;
		
		if (Owner.IsA('DeusExPlayer'))
		{
			root = DeusExRootWindow(DeusExPlayer(Owner).rootWindow);
			
			if (root != None && bInObjectBelt && beltPos > 0)
			{
				foreach AllActors(Class, ThisWeaponClass)
				{
					if (ThisWeaponClass != Self && ThisWeaponClass.Owner == Owner && !Inventory(ThisWeaponClass).bInObjectBelt)
					{
						ValidItem = Inventory(ThisWeaponClass);
						
						if (ValidItem != None)
						{
							root.hud.belt.AddObjectToBelt(ValidItem, beltPos, False);
							break;
						}
					}
				}
			}
		}
	}

Begin:
	if ((ClipCount >= ReloadCount) && (ReloadCount != 0))
	{
		if ((bSemiautoTrigger || bBurstFire) && (VMDIsShooting())) FinishAnim();
		
		//MADDERS: Part of the war on recoil.
		/*if (!bAutomatic)
		{
			bFiring = False;
			FinishAnim();
		}*/
		
		if (Owner != None)
		{
			if (Owner.IsA('DeusExPlayer'))
			{
				bFiring = False;

				// should we autoreload?
				if (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun"))
				{
					//Hack for not negating recoil early via autoreload.
					if (VMDIsShooting())
					{
					 	//FinishAnim();
						if (FireCutoffFrame > 0.0)
						{
							do
							{
								Sleep(0.02);
							}
							until (AnimFrame > FireCutoffFrame || !VMDIsShooting());
							
							TweenAnim('Still', 0.1);
						}
						else
						{
							FinishAnim();
						}
					}
					
					// auto switch ammo if we're out of ammo and
					// we're not using the primary ammo
					if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();
					ReloadAmmo();
				}
				else
				{
					if (VMDIsShooting())
					{
					 	//FinishAnim();
						if (FireCutoffFrame > 0.0)
						{
							do
							{
								Sleep(0.02);
							}
							until (AnimFrame > FireCutoffFrame || !VMDIsShooting());
							
							TweenAnim('Still', 0.1);
						}
						else
						{
							FinishAnim();
						}
					}
					if (bHasMuzzleFlash)
						EraseMuzzleFlashTexture();
					GotoState('Idle');
				}
			}
			else if (Owner.IsA('ScriptedPawn'))
			{
				bFiring = False;
				ReloadAmmo();
			}
		}
		else
		{
			if (bHasMuzzleFlash)
				EraseMuzzleFlashTexture();
			GotoState('Idle');
		}
	}
	if ((bAutomatic) && (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && (!DeusExPlayer(Owner).PlayerIsListenClient()))))
		GotoState('Idle');
	
	Sleep(GetShotTime());
	if (bAutomatic)
	{
		GenerateBullet();	// In multiplayer bullets are generated by the client which will let the server know when
		Goto('Begin');
	}
	bFiring = False;
	if (VMDIsShooting())
	{
		if (FireCutoffFrame > 0.0)
		{
			do
			{
				Sleep(0.02);
			}
			until (AnimFrame > FireCutoffFrame || !VMDIsShooting());
		}
		else
		{
			FinishAnim();
		}
	}
	// if ReloadCount is 0 and we're not hand to hand, then this is a
	// single-use weapon so destroy it after firing once
	if ((ReloadCount == 0) && (!bHandToHand))
	{
		if (DeusExPlayer(Owner) != None)
			DeusExPlayer(Owner).RemoveItemFromSlot(Self);   // remove it from the inventory grid
		
		VMDDestroyOnFinishHook();
		Destroy();
	}
	ReadyToFire();
	
	if (bBoltAction || bPumpAction) GoTo('RunBolt');
	if (bSemiautoTrigger || bBurstFire) GoTo('Done');

RunBolt:
	if (VMDHasRackObjection())
	{
	 	Do
	 	{
	  		Sleep(0.25);
	 	}
	 	Until (!VMDHasRackObjection());
	}
	
	bWasZoomed = bZoomed;
	if (bWasZoomed)
		ScopeOff();
	
	//MADDERS: For use in the plus bow.
	if ((bPumpAction) && (PumpPurpose != 2))
	{
	 	PlayAnim('ReloadBegin', VMDGetCorrectAnimRate(VMDGetCorrectPumpRate(1.0), False), 0.1);
	 	AnimFrame = PumpStart;
	 	FinishAnim();
		
		if (DeusExAmmo(AmmoType) != None) DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
		
	 	Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
	 	PlayAnim('ReloadEnd', VMDGetCorrectAnimRate(VMDGetCorrectPumpRate(1.0), False));
	 	AnimFrame = PumpStart;
	 	FinishAnim();
	}
	if (bBoltAction)
	{
	 	Owner.PlaySound(BoltStartSound, SLOT_None,,, 1024, VMDGetMiscPitch());
	 	PlayAnim(BoltStartSeq, VMDGetCorrectAnimRate(VMDGetCorrectPumpRate(BoltActionRate), False), 0.1);
	 	AnimFrame = 0.0;
	 	FinishAnim();
		
		if (DeusExAmmo(AmmoType) != None) DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
		
	 	if (BoltActionDelay > 0.0)
	 	{
	  		LoopAnim(BoltDelaySeq, 0.1, VMDGetCorrectPumpRate(1.0));
	  		Sleep(BoltActionDelay / VMDGetCorrectPumpRate(1.0));
	 	}
	 	Owner.PlaySound(BoltEndSound, SLOT_None,,, 1024, VMDGetMiscPitch());
	 	PlayAnim(BoltEndSeq, VMDGetCorrectAnimRate(VMDGetCorrectPumpRate(BoltActionRate), False), 0.1);
	 	AnimFrame = 0.0;
	 	FinishAnim();
	}
	if (bWasZoomed)
		ScopeOn();
	
	GoTo('Done');
	
Done:
	bFiring = False;
	Finish();
}

state FinishFire
{
Begin:
	bFiring = False;
	if ( bDestroyOnFinish )
	{
		if(bZoomed)
			ScopeOff();
		if(bHasLaser)
			LaserOff();
		
		VMDDestroyOnFinishHook();
		Destroy();
	}
	else
	{
		Finish();
	}
}

state ReloadToIdle
{
	ignores Altfire, Fire;

Begin:
	PlayAnim('ReloadEnd', VMDGetCorrectReloadRateSingleLoaded(1.0), 0.1);
 	Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
 	if (AnimSequence == 'ReloadEnd') FinishAnim();
	
 	//MADDERS: For use in the sawed off.
 	if ((bPumpAction) && (PumpPurpose != 1) && (bReloadFromEmpty))
 	{
  		SawedOffCockSound();
  		PlayAnim('Shoot', VMDGetCorrectPumpRate(1.0), 0.1); // VMDGetCorrectAnimRate(1.0, False)
  		AnimFrame = PumpStart;
  		FinishAnim();
 	}
	
	//MADDERS, 6/22/24: Weird inverse logic. If we now have ammo, set this to false, so we know to re-check it on our next reload.
	//Alternatively, if we don't have ammo, we didn't actually do any reloading, so don't drop another mag.
	bReloadWasntEmpty = !(ClipCount < ReloadCount);
	GoToState('Idle');
}

state Reload
{
	ignores AltFire;
	
	function Fire( float F )
	{
		if ((bSingleLoaded) && (ClipCount < ReloadCount))
		{
		 	GoToState('ReloadToIdle', 'Begin');
		}
	}
	
	function float GetReloadTime()
	{
		local float val, AccMod;
 		local bool bReloadSpeedTweak;
		
		val = ReloadTime;
		
		if (ScriptedPawn(Owner) != None)
		{
			AccMod = ScriptedPawn(Owner).BaseAccuracy;
			if (VMDBufferPawn(Owner) != None) AccMod += FMin(Abs(ScriptedPawn(Owner).BaseAccuracy), VMDBufferPawn(Owner).ROFCounterweight) + VMDBufferPawn(Owner).DifficultyROFWeight;
			val = ReloadTime * (AccMod*2+1);
		}
		else if (DeusExPlayer(Owner) != None)
		{
			// check for skill use if we are the player
			val = VMDGetWeaponSkill("RELOAD");
			val = ReloadTime + (val*ReloadTime);
			
			//MADDERS: Don't apply reload augments underwater, since it'd be a straight nerf.
			if (!VMDIsWaterZone() || VMDNegateWaterSlow())
			{
				switch(GoverningSkill)
				{
					case class'SkillWeaponPistol':
						bReloadSpeedTweak = VMDHasSkillAugment('PistolReload');
					break;
					case class'SkillWeaponRifle':
						bReloadSpeedTweak = VMDHasSkillAugment('RifleReload');
					break;
				}
			}
			if (bReloadSpeedTweak) Val /= 1.33;
			
			if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
			{
				val *= 1.75;
			}
			
			//MADDERS: Not sure why the ever living fuck this value returns 150 to 200% reload time in vanilla. As if anim times weren't bad enough.
			val /= 2;
		}
		
		return val;
	}
	
	function NotifyOwner(bool bStart)
	{
		local DeusExPlayer player;
		local ScriptedPawn pawn;

		player = DeusExPlayer(Owner);
		pawn   = ScriptedPawn(Owner);

		if (player != None)
		{
			if (bStart)
				player.Reloading(self, GetReloadTime()+(1.0/AnimRate));
			else
			{
				player.DoneReloading(self);
			}
		}
		else if (pawn != None)
		{
			if (bStart)
				pawn.Reloading(self, GetReloadTime()+(1.0/AnimRate));
			else
				pawn.DoneReloading(self);
		}
	}
	
Begin:
	FinishAnim();
	
	// only reload if we have ammo left
	if ((AmmoType.AmmoAmount > ReloadCount - ClipCount) && (ClipCount > 0 - int(VMDHasOpenSystemMagBoost())))
	{
		bReloadFromEmpty = (ClipCount >= ReloadCount);
		
		if (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient()))
		{
			ClientReload();
			Sleep(GetReloadTime());
			ReadyClientToFire( True );
		}
		else
		{
			//MADDERS: Allow for single shell loading!
			if (!bSingleLoaded)
			{
				bWasZoomed = bZoomed;
				if (bWasZoomed)
				{
					ScopeOff();
				}
				
				if ((CockingSound != None) && (VMDOwnerNotDead()))
				{
					Owner.PlaySound(CockingSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// CockingSound is reloadbegin
					
					//MADDERS: Spook nearby baddies.
					//3/25/21: Only do so on higher difficulty.
					if ((VMDBufferPlayer(Owner) != None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMDBufferPlayer(Owner), "Reload Noise")))
					{
						AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 240);
					}
				}
				if (HasAnim('ReloadBegin')) PlayAnim('ReloadBegin', VMDGetCorrectReloadRate(1.0) );
				//MADDERS: Skip past anim BS, since we already played reload before our last holstering.
				else if ((WeaponHideAgun(Self) != None) && (AnimSequence != 'Shoot'))
				{
					ClipCount = 0;
					GoTo('SkipHack');
				}
				NotifyOwner(True);
				FinishAnim();
				
				if (ClipCount < ReloadCount)
				{
					bReloadWasntEmpty = true;
				}
				
				if ((!bReloadWasntEmpty) && (Pawn(Owner) != None) && (Pawn(Owner).Health > 0) && (!Pawn(Owner).IsInState('Dying')))
				{
					VMDDropEmptyMagazine(GetHandType());
				}
				bReloadWasntEmpty = true;
				ClipCount = ReloadCount;
				
				if (HasAnim('Reload')) LoopAnim('Reload', VMDGetCorrectReloadRate(1.0) );
				Sleep(GetReloadTime());
				Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
				if (HasAnim('ReloadEnd')) PlayAnim('ReloadEnd', VMDGetCorrectReloadRate(1.0) );
				FinishAnim();
				NotifyOwner(False);
				
				//MADDERS: For use in the sawed off.
				if ((bPumpAction) && (PumpPurpose != 1))
				{
				 	SawedOffCockSound();
				 	PlayAnim('Shoot', VMDGetCorrectPumpRate(1.0), 0.1);
				 	AnimFrame = PumpStart;
				 	FinishAnim();
				}
				
				if (bWasZoomed)
				{
					ScopeOn();
				}
				
				//Set our mag size to not exceed what ammo we have on hand.
				//Load those exra rounds by hand, dammit!
				ClipCount = Max(0, ReloadCount - AmmoType.AmmoAmount) - int(VMDHasOpenSystemMagBoost());
				
				VMDReloadCompleteHook();
			}
			else
			{
				bWasZoomed = bZoomed;
				if (bWasZoomed)
					ScopeOff();
				
				Owner.PlaySound(CockingSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// CockingSound is reloadbegin
				if (HasAnim('ReloadBegin')) PlayAnim('ReloadBegin', VMDGetCorrectReloadRate(1.0) );
				NotifyOwner(True);
				FinishAnim();
				
				if (ClipCount < ReloadCount)
				{
					bReloadWasntEmpty = true;
				}
				
				if ((!bReloadWasntEmpty) && (Pawn(Owner) != None) && (Pawn(Owner).Health > 0) && (!Pawn(Owner).IsInState('Dying')))
				{
					VMDDropEmptyMagazine(GetHandType());
				}
				bReloadWasntEmpty = true;
				
				do
				{
				 	if ((SingleLoadSound != None) && (VMDOwnerNotDead()))
				 	{
				 		VMDPlaySimSound( SingleLoadSound, SLOT_None, TransientSoundVolume, 2048, VMDGetMiscPitch());
						
						//MADDERS: Spook nearby baddies.
						//3/25/21: Only do so on higher difficulty.
						if ((VMDBufferPlayer(Owner) != None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMDBufferPlayer(Owner), "Reload Noise")))
						{
							AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 240);
						}
					}
				 	ClipCount--;
				 	if (HasAnim('Reload')) PlayAnim('Reload', VMDGetCorrectReloadRateSingleLoaded(1.0), 0.1);
				 	FinishAnim();
					 //Sleep(GetReloadTime());
				}
				until (ClipCount <= Max(0 - int(VMDHasOpenSystemMagBoost()), ReloadCount - AmmoType.AmmoAmount));
				
				if (VMDOwnerNotDead())
				{
					Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
				}
				if (HasAnim('ReloadEnd')) PlayAnim('ReloadEnd', VMDGetCorrectReloadRate(1.0) );
				FinishAnim();
				NotifyOwner(False);
				
				//MADDERS: For use in the sawed off.
				if ((bPumpAction) && (PumpPurpose != 1) && (bReloadFromEmpty))
				{
					if (VMDOwnerNotDead())
					{
				 		SawedOffCockSound();
				 		Owner.PlaySound(CockingSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// CockingSound is reloadbegin
					}
				 	PlayAnim('Shoot', VMDGetCorrectPumpRate(1.0), 0.1); //VMDGetCorrectAnimRate(1.0, False)
				 	AnimFrame = PumpStart;
				 	FinishAnim();
				}	
				
				if (bWasZoomed)
					ScopeOn();
				
				VMDReloadCompleteHook();
			}
		}
	}
	
	//MADDERS, 6/22/24: Weird inverse logic. If we now have ammo, set this to false, so we know to re-check it on our next reload.
	//Alternatively, if we don't have ammo, we didn't actually do any reloading, so don't drop another mag.
	bReloadWasntEmpty = !(ClipCount < ReloadCount);
	GotoState('Idle');

SkipHack:
	if (Owner == None)
	{
		GoToState('Pickup');
	}
	else
	{
		//MADDERS, 6/22/24: Weird inverse logic. If we now have ammo, set this to false, so we know to re-check it on our next reload.
		//Alternatively, if we don't have ammo, we didn't actually do any reloading, so don't drop another mag.
		bReloadWasntEmpty = !(ClipCount < ReloadCount);
		GoToState('Idle');
	}
}

simulated state ClientFiring
{
	simulated function AnimEnd()
	{
		local bool FlagCanRefire;
		
		bInProcess = False;

		if (bAutomatic || ((AmmoType != None) && (AmmoType.IsA('AmmoNone')) && (bHandToHand)))
		{
			FlagCanRefire = true;
			if (Pawn(Owner) == None || Pawn(Owner).bFire == 0) FlagCanRefire = false;
			if ((AmmoType.AmmoAmount <= 0) && (AmmoNone(AmmoType) == None)) FlagCanRefire = false;
			if (bBurstFire) FlagCanRefire = false;
			
			if (FlagCanRefire)
			{
				if (PlayerPawn(Owner) != None)
					ClientReFire(0);
				else
					GotoState('SimFinishFire');
			}
			else 
				GotoState('SimFinishFire');
		}
	}
	simulated function float GetSimShotTime()
	{
		local float mult, sTime;

		if (ScriptedPawn(Owner) != None)
		{
			Mult = 1.0;
			if ((VMDBufferPawn(Owner) != None) && (VMDBufferPawn(Owner).AugmentationSystem != None))
			{
				Mult = 1.0 / VMDBufferPawn(Owner).AugmentationSystem.VMDConfigureWepSwingSpeedMult(Self);
			}
			
			if (mult <= 0.0)
			{
				mult = 1.0;
			}
			
			return ShotTime * (ScriptedPawn(Owner).BaseAccuracy*2+1) * Mult;
		}
		else
		{
			// AugCombat decreases shot time
			mult = 1.0;
			if (bHandToHand)
			{
				if (DeusExPlayer(Owner) != None)
				{
					if (VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem) != None)
					{
						Mult = 1.0 / VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem).VMDConfigureWepSwingSpeedMult(Self);
					}
					else
					{
						mult = 1.0 / DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
					}
				}
				
				if (mult <= 0.0)
				{
					mult = 1.0;
				}
			}
			sTime = ShotTime * mult;
			return (sTime);
		}
	}
	function EndState()
	{
	 	Super.EndState();
	 
	 	if (DeusExPlayer(Owner) != None)
	  		if ((ClipCount >= ReloadCount) && (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun")) && (ReloadCount > 0)) GoToState('DelayedReload', 'Begin');
	}
Begin:
	if ((ClipCount >= ReloadCount) && (ReloadCount != 0))
	{
		//Part of the war on recoil.
		/*if (!bAutomatic)
		{
			FinishAnim();
			bFiring = False;
		}*/
		if (Owner != None)
		{
			if (Owner.IsA('DeusExPlayer'))
			{
				bFiring = False;
				if (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun"))
				{
					bClientReadyToFire = False;
					bInProcess = False;


					if (VMDIsShooting())
					{
					 FinishAnim();
					}

					if ((AmmoType.AmmoAmount == 0) && (AmmoName != AmmoNames[0]))
						CycleAmmo();

					GoToState('DelayedReload', 'Begin');
					//ReloadAmmo();
					//GotoState('SimQuickFinish');
				}
				else
				{
					if (bHasMuzzleFlash)
						EraseMuzzleFlashTexture();
					IdleFunction();
					GotoState('SimQuickFinish');
				}
			}
			else if (Owner.IsA('ScriptedPawn'))
			{
				bFiring = False;
				GoToState('DelayedReload', 'Begin');
			}
		}
		else
		{
			if (bHasMuzzleFlash)
				EraseMuzzleFlashTexture();
			IdleFunction();
			GotoState('SimQuickFinish');
		}
	}
	Sleep(GetSimShotTime());
	if (bAutomatic)
	{
		SimGenerateBullet();
		Goto('Begin');
	}
	FinishAnim();
	//bFiring = False;
	bInProcess = False;
Done:
	bInProcess = False;
	bFiring = False;
	SimFinish();
}

simulated state SimQuickFinish
{
Begin:
	if ( IsAnimating() && (AnimSequence == 'Shoot') )
		FinishAnim();

	if (bHasMuzzleFlash)
		EraseMuzzleFlashTexture();

	bInProcess = False;
	bFiring=False;
}

simulated state SimIdle
{
	function Timer()
	{
		PlayIdleAnim();
	}
Begin:
	bInProcess = False;
	bFiring = False;
	if (!bNearWall)
	{
		if (HasAnim('Idle1'))
		{
			PlayAnim('Idle1',,0.1);
		}
	}
	SetTimer(3.0, True);
}


simulated state SimFinishFire
{
Begin:
	FinishAnim();

	if ( PlayerPawn(Owner) != None )
		PlayerPawn(Owner).FinishAnim();

	if (bHasMuzzleFlash)
		EraseMuzzleFlashTexture();

	bInProcess = False;
	bFiring = False;
	SimFinish();
}

simulated state SimDownweapon
{
ignores Fire, AltFire, ClientFire, ClientReFire;

Begin:
	if ( bWasInFiring )
	{
		if (bHasMuzzleFlash)
			EraseMuzzleFlashTexture();
		FinishAnim();
	}
	bInProcess = False;
	bFiring = False;
	TweenDown();
	FinishAnim();
}

simulated state SimActive
{
Begin:
	if ( bWasInFiring )
	{
		if (bHasMuzzleFlash)
			EraseMuzzleFlashTexture();
		FinishAnim();
	}
	bInProcess = False;
	bFiring = False;
	if (HasAnim('Select'))
	{
		PlayAnim('Select',1.0,0.0);
	}
	FinishAnim();
	SimFinish();
}

simulated state SimReload
{
ignores Fire, AltFire, ClientFire, ClientReFire;

	simulated function float GetSimReloadTime()
	{
		local float val;

		val = ReloadTime;

		if (ScriptedPawn(Owner) != None)
		{
			val = ReloadTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
		}
		else if (DeusExPlayer(Owner) != None)
		{
			// check for skill use if we are the player
			val = VMDGetWeaponSkill("RELOAD");
			val = ReloadTime + (val*ReloadTime);
		}
		return val;
	}
Begin:
	if ( bWasInFiring )
	{
		if (bHasMuzzleFlash)
			EraseMuzzleFlashTexture();
		FinishAnim();
	}
	bInProcess = False;
	bFiring = False;

	bWasZoomed = bZoomed;
	if (bWasZoomed)
		ScopeOff();

	Owner.PlaySound(CockingSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// CockingSound is reloadbegin
	PlayAnim('ReloadBegin');
	FinishAnim();
	LoopAnim('Reload');
	Sleep(GetSimReloadTime());
	Owner.PlaySound(AltFireSound, SLOT_None,,, 1024, VMDGetMiscPitch());		// AltFireSound is reloadend
	ServerDoneReloading();
	PlayAnim('ReloadEnd');
	FinishAnim();

	if (bWasZoomed)
		ScopeOn();

	GotoState('SimIdle');
}


state Idle
{
	function bool PutDown()
	{
		// alert NPCs that I'm putting away my gun
		AIEndEvent('WeaponDrawn', EAITYPE_Visual);

		return Super.PutDown();
	}

	function AnimEnd()
	{
	}

	function Timer()
	{
		PlayIdleAnim();
	}

Begin:
	bFiring = False;
	ReadyToFire();

	if ((Level.NetMode != NM_DedicatedServer) && (Level == None || Level.NetMode != NM_ListenServer || !Owner.IsA('DeusExPlayer') || DeusExPlayer(Owner).PlayerIsListenClient()))
	{
		if (!bNearWall)
		{
			if (HasAnim('Idle1'))
			{
				PlayAnim('Idle1',,0.1);
			}
		}
		SetTimer(3.0, True);
	}
}

state FlameThrowerOn
{
	function float GetShotTime()
	{
		local float mult, sTime;

		if (ScriptedPawn(Owner) != None)
		{
			Mult = 1.0;
			
			if ((VMDBufferPawn(Owner) != None) && (VMDBufferPawn(Owner).AugmentationSystem != None))
			{
				Mult = 1.0 / VMDBufferPawn(Owner).AugmentationSystem.VMDConfigureWepSwingSpeedMult(Self);
			}
			
			if (mult <= 0.0)
			{
				mult = 1.0;
			}
			
			return ShotTime * (ScriptedPawn(Owner).BaseAccuracy*2+1);
		}
		else
		{
			// AugCombat decreases shot time
			mult = 1.0;
			if (bHandToHand)
			{
				if (DeusExPlayer(Owner) != None)
				{
					if (VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem) != None)
					{
						Mult = 1.0 / VMDBufferAugmentationManager(DeusExPlayer(Owner).AugmentationSystem).VMDConfigureWepSwingSpeedMult(Self);
					}
					else
					{
						Mult = 1.0 / DeusExPlayer(Owner).AugmentationSystem.GetAugLevelValue(class'AugCombat');
					}
					
					if (mult <= 0.0)
					{
						mult = 1.0;
					}
				}
			}
			sTime = ShotTime * mult;
			return (sTime);
		}
	}
Begin:
	if ( (DeusExPlayer(Owner).Health > 0) && bFlameOn && (ClipCount < ReloadCount))
	{
		if (( flameShotCount == 0 ) && (Owner != None))
		{
			PlayerPawn(Owner).PlayFiring();
			PlaySelectiveFiring();
			PlayFiringSound();
			flameShotCount = 6;
		}
		else
			flameShotCount--;

		Sleep( GetShotTime() );
		GenerateBullet();
		goto('Begin');
	}
Done:
	bFlameOn = False;
	GotoState('FinishFire');
}

state Active
{
	function bool PutDown()
	{
		// alert NPCs that I'm putting away my gun
		AIEndEvent('WeaponDrawn', EAITYPE_Visual);
		return Super.PutDown();
	}

Begin:
	//MADDERS: Active automatically!
	if ((bHasLaser) && (!bLasing)) LaserOn();
	
	//MADDERS, 12/25/23: Fix inconsistency with PS20 that starts out partially loaded.
	if (bPocketReload)
	{
		ClipCount = 0;
	}
	
	// Rely on client to fire if we are a multiplayer client
	if ( (Level.NetMode==NM_Standalone) || (Owner.IsA('DeusExPlayer') && DeusExPlayer(Owner).PlayerIsListenClient()) )
		bClientReady = True;
	if (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient()))
	{
		ClientActive();
		bClientReady = False;
	}
	
	if (!Owner.IsA('ScriptedPawn'))
		FinishAnim();
	if ( bChangeWeapon )
		GotoState('DownWeapon');
	
	bWeaponUp = True;
	PlayPostSelect();
	if (!Owner.IsA('ScriptedPawn'))
		FinishAnim();
	
	// reload the weapon if it's empty and autoreload is true
	if ((ClipCount >= ReloadCount) && (ReloadCount != 0))
	{
		if (Owner.IsA('ScriptedPawn') || ( DeusExPlayer(Owner) != None && (DeusExPlayer(Owner).bAutoReload || VMDIsWeaponName("Hideagun")) ))
			ReloadAmmo();
	}
	Finish();
}


state DownWeapon
{
ignores Fire, AltFire;

	function bool PutDown()
	{
		// alert NPCs that I'm putting away my gun
		AIEndEvent('WeaponDrawn', EAITYPE_Visual);
		return Super.PutDown();
	}
	
Begin:
   	ScopeOff();
	ZoomInCount = 0;
	LaserOff();
	
	if (( Level.NetMode == NM_DedicatedServer ) || ((Level.NetMode == NM_ListenServer) && Owner.IsA('DeusExPlayer') && !DeusExPlayer(Owner).PlayerIsListenClient()))
		ClientDownWeapon();
	
	TweenDown();
	FinishAnim();
	
	//MADDERS: Make some guns reload in pocket!
	if ((Level.NetMode != NM_Standalone) || (bPocketReload))
	{
		ClipCount = 0;	// Auto-reload in multiplayer (when putting away)
	}
	bOnlyOwnerSee = false;
	if (Pawn(Owner) != None)
	{
		Pawn(Owner).ChangedWeapon();
	}
SkipHack:
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   	return ((BeltSpot <= 3) && (BeltSpot >= 1));
}

simulated function ResetShake()
{
	local float LaserAngle, LaserDirection;
	
	if ((!bZoomed) && (bLasing))
	{
		//G-Flex: we need radians for trig math, but URot units for the results. Sigh.
		//G-Flex: ACCURACY TESTING
		ShakeMagnitude = 900 + (0.75 * Rand(1920));
		ShakeMagnitudeToward = 900 + (0.75 * Rand(1920));
		ShakeAngleAccel = (FRand() * 4 * pi) - (2 * pi);
		ShakeAngle = Rand(2*pi);
	}
	else if (bZoomed)
	{
		ShakeYaw = currentAccuracy * (Rand(2048 * 2) - 2048);
		ShakePitch = currentAccuracy * (Rand(2048 * 2) - 2048);
	}
	
	ShakeTimer = (FRand() * 0.15) + 0.20;
}

function PlaySelect()
{
	local float Rate;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	
	//MADDERS: Draw speed is affected by both skill augments (heavy weapons) and being underwater.
	Rate = 1.0;
	if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
	{
		Rate *= 0.65;
	}
	if ((GoverningSkill == Class'SkillWeaponHeavy' || bForceHeavyWeapon) && (VMDHasSkillAugment('HeavySwapSpeed')))
	{
		Rate *= 1.5;
	}
	if ((Concealability >= CONC_Visual) && (VMDHasSkillAugment('TagTeamSmallWeapons')))
	{
		Rate *= 1.5;
	}
	//MADDERS, 12/1/24: Increase weapon swap speed for untouchable, too.
	if ((VMDHasSkillAugment('TagTeamDodgeRoll')) && (VMP != None) && (VMP.DodgeRollCooldownTimer >= VMP.DodgeRollCooldown - 2.5))
	{
		Rate *= 2.0;
	}
	
	//MADDERS, boost sword draw speed to make it stop sucking.
	if (WeaponSword(Self) != None)
	{
		Rate *= 1.2;
	}
	
	Rate *= FactorWM2DrawSpeedMultiplier();
	
	PlayAnim('Select',1.0*Rate,0.0);
	
	//MADDERS: Don't shift the pitch of grenade selection.
	if ((bHandToHand) && (!bInstantHit)) Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening,,, VMDGetMiscPitch2());
	else Owner.PlaySound(SelectSound, SLOT_Misc, Pawn(Owner).SoundDampening,,, VMDGetMiscPitch());
}

simulated function TweenDown()
{
	local float Rate;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	
	//MADDERS: Draw speed is affected by both skill augments (heavy weapons) and being underwater.
	Rate = 1.0;
	if ((VMDIsWaterZone()) && (!VMDNegateWaterSlow()))
	{
		Rate *= 0.65;
	}
	if ((GoverningSkill == Class'SkillWeaponHeavy') && (VMDHasSkillAugment('HeavySwapSpeed')))
	{
		Rate *= 1.5;
	}
	if ((Concealability >= CONC_Visual) && (VMDHasSkillAugment('TagTeamSmallWeapons')))
	{
		Rate *= 1.5;
	}
	//MADDERS, 12/1/24: Increase weapon swap speed for untouchable, too.
	if ((VMDHasSkillAugment('TagTeamDodgeRoll')) && (VMP != None) && (VMP.DodgeRollCooldownTimer >= VMP.DodgeRollCooldown - 2.5))
	{
		Rate *= 2.0;
	}
	
	//MADDERS, boost sword draw speed to make it stop sucking.
	if (WeaponSword(Self) != None)
	{
		Rate *= 1.2;
	}
	
	Rate *= FactorWM2HolsterSpeedMultiplier();
	
	if ( (AnimSequence != '') && (GetAnimGroup(AnimSequence) == 'Select') )
		TweenAnim( AnimSequence, AnimFrame * 0.4 );
	else
	{
		// Have the put away animation play twice as fast in multiplayer
		if ( Level.NetMode != NM_Standalone )
			PlayAnim('Down', Rate*2.0, 0.05);
		else
			PlayAnim('Down', Rate, 0.05);
	}
}

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function float GetShotTime();
simulated function float GetSimReloadTime();
simulated function float GetSimShotTime();
function NotifyOwner(bool bStart);
function float GetReloadTime();
function CheckTouching();
function bool ValidTouch( actor Other );

defaultproperties
{
     bReadyToFire=True
     LowAmmoWaterMark=10
     NoiseLevel=1.000000
     ShotTime=0.500000
     reloadTime=1.000000
     HitDamage=10
     maxRange=9600
     AccurateRange=4800
     BaseAccuracy=0.500000
     ScopeFOV=10
     MaintainLockTimer=1.000000
     bPenetrating=True
     bHasMuzzleFlash=True
     bEmitWeaponDrawn=True
     bUseWhileCrouched=True
     bUseAsDrawnWeapon=True
     MinSpreadAcc=0.250000
     MinProjSpreadAcc=1.000000
     bNeedToSetMPPickupAmmo=True
     msgCannotBeReloaded="This weapon can't be reloaded"
     msgOutOf="Out of %s"
     msgNowHas="%s now has %s loaded"
     msgAlreadyHas="%s already has %s loaded"
     msgNone="NONE"
     msgNoAmmo="NO AMMO"
     msgLockInvalid="INVALID"
     msgLockRange="RANGE"
     msgLockAcquire="ACQUIRE"
     msgLockLocked="LOCKED"
     msgRangeUnit="FT"
     msgTimeUnit="SEC"
     msgMassUnit="LBS"
     msgNotWorking="This weapon doesn't work underwater"
     msgInfoAmmoLoaded="Ammo loaded:"
     msgInfoAmmo="Ammo type(s):"
     msgInfoDamage="Base damage:"
     msgInfoClip="Clip size:"
     msgInfoROF="Rate of fire:"
     msgInfoReload="Reload time:"
     msgInfoRecoil="Recoil:"
     msgInfoAccuracy="Base Accuracy:"
     msgInfoAccRange="Acc. range:"
     msgInfoMaxRange="Max. range:"
     msgInfoMass="Mass:"
     msgInfoLaser="Laser sight:"
     msgInfoScope="Scope:"
     msgInfoSilencer="Silencer:"
     msgInfoNA="N/A"
     msgInfoYes="YES"
     msgInfoNo="NO"
     msgInfoAuto="AUTO"
     msgInfoSingle="SINGLE"
     msgInfoRounds="RDS"
     msgInfoRoundsPerSec="RDS/SEC"
     msgInfoPerSec="/SEC"
     msgInfoSkill="Skill:"
     msgInfoWeaponStats="Weapon Stats:"
     ReloadCount=10
     shakevert=10.000000
     Misc1Sound=Sound'DeusExSounds.Generic.DryFire'
     AutoSwitchPriority=0
     bRotatingPickup=False
     PickupMessage="You found"
     ItemName="DEFAULT WEAPON NAME - REPORT THIS AS A BUG"
     LandSound=Sound'DeusExSounds.Generic.DropSmallWeapon'
     bNoSmooth=False
     Mass=10.000000
     Buoyancy=5.000000
     //UnivScopeSwayMult=0.900000
     UnivScopeSwayMult=1.000000
     UnivScopeRecoilMult=0.550000
     RecoilDecayRate=1.000000
     RecoilIndices(0)=(X=0.000000,Y=100.000000) //MADDERS: Legacy recoil, but now with some decay.
     NumRecoilIndices=1
     CurRecoilIndex=-1
     bDebugTilt=False //MADDERS: Barf.
     
     //TILT INDICES!
     ZoomInTilt=(X=-3.000000,Y=3.000000)
     ZoomOutTilt=(X=2.330000,Y=-2.330000)
     ToggleTilt=(X=-1.000000,Y=-0.500000)
     Toggle2Tilt=(X=1.0.000000,Y=0.500000)
     
     DroneMinRange=0
     DroneMaxRange=480
     
     //MADDERS defaults:
     bNameCaseSensitive=True //MADDERS, lots of weird weapon examples, so assume case sensitive until said otherwise. Ugh.
     OverrideNumProj=0 //Likely redundant. ~MADDERS
     OverrideAnimRate=0.000000
     HandSkinIndex(0)=255
     HandSkinIndex(1)=255
     MuzzleFlashIndex=2
     RelativeRange=3750
     SingleLoadSound=Sound'SawedOffShotgunSingleLoad'
     SilencedFireSound=Sound'StealthPistolFire'
     SemiautoSilencedFireSound=Sound'StealthPistolFire'
     EvolvedName="Charles"
     EvolvedBelt="Darwin"
     MaximumAccuracy=2.000000
     AimDecayMult=10.000000
     AimFocusMult=1.000000
     BoltActionRate=1.000000
     FirePitchMin=0.900000
     FirePitchMax=1.100000
     bCanHaveModEvolution=True
     PenetrationHitDamage=5
     RicochetHitDamage=3
     BloodRenderMult=0.900000
     GrimeRenderMult=0.900000
     WaterRenderMult=0.100000
     BulletholeSize=0.100000
     MinimumTracerDist=250.000000
     GrimeRateMult=1.000000
     MeleeAnimRates(0)=1.000000
     MeleeAnimRates(1)=1.000000
     MeleeAnimRates(2)=1.000000
     MoverDamageMult=1.000000
     
     FiringSystemOperation=0
     FiringSystemLabel="Part Style:"
     OpenSystemDesc="Constructed with ROBUST parts"
     ClosedSystemDesc="Constructed with INTRICATE parts"
     MessageTooDirty="Your dirtied weapon fails to fire"
     MessageTooWet="Your flooded weapon fails to fire"
     GrimeLevelLabel="Condition:"
     GrimeLevelDesc(0)="Weapon is CLEAN"
     GrimeLevelDesc(1)="Weapon is DIRTY"
     GrimeLevelDesc(2)="Weapon is VERY DIRTY"
     MessageChangedMode="Mode set to %s"
     PenetrationLabel="Penetration:"
     PenetrationDesc="%d INCH(ES), %d%% effectiveness"
     RicochetLabel="Ricochets:"
     RicochetDesc="%d TIME(S), %d%% effectiveness"
     msgInfoMoverDamageMult="Terrain Damage:"
     msgInfoBurst="BURST"
     FiringModesLabel="Firing modes:"
     ClipsLabel="CLIPS"
     MsgGainedMod="%s gained %s mod"
     MsgMergedMods(0)="%s gained %d %s mod"
     MsgMergedMods(1)="%s gained %d %s mods"
     ModNames(0)="accuracy"
     ModNames(1)="capacity"
     ModNames(2)="evolution"
     ModNames(3)="laser"
     ModNames(4)="range"
     ModNames(5)="recoil"
     ModNames(6)="reload speed"
     ModNames(7)="scope"
     ModNames(8)="silencer"
     
     ExcitementRateThresholds(0)=0
     ExcitementRateThresholds(1)=25
     ExcitementRateThresholds(2)=50
     ExcitementRateThresholds(3)=100
     ExcitementRateThresholds(4)=400
     ExcitementTargetScalars(0)=1.000000
     ExcitementTargetScalars(1)=1.500000
     ExcitementTargetScalars(2)=2.000000
     ExcitementTargetScalars(3)=3.000000
     ExcitementTargetScalars(4)=4.000000
     ExcitementRateScalars(0)=0.500000
     ExcitementRateScalars(1)=1.000000
     ExcitementRateScalars(2)=2.000000
     SkillAccuracyFactors(0)=1.000000
     SkillAccuracyFactors(1)=0.775000
     SkillAccuracyFactors(2)=0.500000
     SkillAccuracyFactors(3)=0.300000
     SwerveRecoveryFactors(0)=49152.000000
     SwerveRecoveryFactors(1)=73728.000000
     SwerveRecoveryFactors(2)=98304.000000
     SwerveRecoveryFactors(3)=147456.000000
     PrimaryBobFactors(0)=256
     PrimaryBobFactors(1)=128
     PrimaryBobFactors(2)=64
     PrimaryBobFactors(3)=32
     SecondaryBobFactors(0)=128
     SecondaryBobFactors(1)=64
     SecondaryBobFactors(2)=16
     SecondaryBobFactors(3)=0
     AccuracyFactorScalar=0.150000
     RecoilDecayMult=12.000000
     RecoilRecoveryFactors(0)=0.40
     RecoilRecoveryFactors(1)=0.30
     RecoilRecoveryFactors(2)=0.225
     RecoilRecoveryFactors(3)=0.175
     AimFocusMults(0)=1.500000
     AimFocusMults(1)=1.680000
     AimFocusMults(2)=1.860000
     AimFocusMults(3)=2.040000
     AimFocusMults(4)=2.220000
     AimFocusMults(5)=2.400000
     AimFocusMults(6)=2.580000
     AimFocusRanges(0)=3.000000
     AimFocusRanges(1)=9.000000
     SwayDistanceCooldown=0.025000
     SwayDistanceRate=0.200000
     SwayExcitementScalar=0.500000
}
