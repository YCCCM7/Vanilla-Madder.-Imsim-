//=============================================================================
// DeusExProjectile.
//=============================================================================
class DeusExProjectile extends Projectile
	abstract;

var bool bExplodes;				// does this projectile explode?
var bool bBlood;				// does this projectile cause blood?
var bool bDebris;				// does this projectile cause debris?
var bool bStickToWall;			// does this projectile stick to walls?
var bool bStuck;				// is this projectile stuck to the wall?
var vector initDir;				// initial direction of travel
var float blastRadius;			// radius to explode
var Actor damagee;				// who is being damaged
var name damageType;			// type of damage that this projectile does
var int AccurateRange;			// maximum accurate range in world units (feet * 16)
var int MaxRange;				// maximum range in world units (feet * 16)
var vector initLoc;				// initial location for range tracking
var bool bTracking;				// should this projectile track a target?
var Actor Target;				// what target we are tracking
var float time;					// misc. timer
var float MinDrawScale;
var float MaxDrawScale;

var vector LastSeenLoc;    // Last known location of target
var vector NetworkTargetLoc; // For network propagation (non relevant targets)
var bool bHasNetworkTarget;
var bool bHadLocalTarget;

var int gradualHurtSteps;		// how many separate explosions for the staggered HurtRadius
var int gradualHurtCounter;		// which one are we currently doing

var bool bEmitDanger;
var class<DeusExWeapon>	spawnWeaponClass;	// weapon to give the player if this projectile is disarmed and frobbed
var class<Ammo>			spawnAmmoClass;		// weapon to give the player if this projectile is disarmed and frobbed

var bool bIgnoresNanoDefense; //True if the aggressive defense aug does not blow this up.

var bool bAggressiveExploded; //True if exploded by Aggressive Defense 

var localized string itemName;		// human readable name
var localized string	itemArticle;	// article much like those for weapons

//MADDERS additions
var int StartSoundSnap;
var bool bClosedSystemHit;
var float LastWeaponDamageSkillMult, MoverDamageMult;

var bool bSpentStress;
var VMDBufferPlayer LastVMP;

//MADDERS, 1/5/21: Now use inventory and not ammo.
var class<Inventory> StuckAmmoClass;
var float StickAmmoRate;

var Pawn AggressiveExplodedOwner; 
var bool bHitFakeBackdrop, bOwnerless; // Have we hit a brush face with a fakebackdrop flag, and therefore should not spawn effects?

//MADDERS, 2/19/25: The things I do for Zodiac C4, I swear.
var bool bSticky, bStuckToWorld, bStuckToActor;
var Vector StickOffset;
var Rotator StuckToRotation, StickRotation;

var Actor StuckTo;

// network replication
replication
{
   	//server to client
   	reliable if (Role == ROLE_Authority)
      		bTracking, Target, bAggressiveExploded, bHasNetworkTarget, NetworkTargetLoc;
}

//--------------------
//VMD Functions.
//--------------------
simulated function VMDStickTo(Actor Other)
{
	if (Other == None || Other == Owner || !bSticky) return;
	
	bFixedRotationDir = True;
	SetPhysics(PHYS_None);
	
        if (Other.IsA('Brush') || Other == Level)
	{
		if (IsA('C4_Projectile'))
		{
			BlastRadius *= 1.5;
		}
		
		SetBase(Other);
        	bStuckToWorld = True;
		bCollideWorld = False;
		return;
	}
	
	bStuckToActor = true;
	StuckTo = Other;
	StickOffset = (Location - Other.Location) * 0.5;
	StuckToRotation = Other.Rotation;
	StickRotation = Rotation;
	
	if (IsA('C4_Projectile'))
	{
		BlastRadius *= 1.5;
		SetTimer(0.016, True);
	}
}

function VMDStopSticking()
{
	bSticky = False;
	StuckTo = None;
	bStuckToActor = False;
	bStuckToWorld = False;
	bCollideWorld = True;
	if (Region.Zone.bWaterZone)
	{
		Destroy();
	}
	else
	{
		Speed = 0;
		Velocity = Vect(0,0,0);
		Acceleration = Vect(0,0,0);
		SetPhysics(PHYS_Falling);
	}
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

function VMDBufferPlayer GetLastVMP()
{
	if (LastVMP == None)
	{
		LastVMP = VMDBufferPlayer(GetPlayerPawn());
	}
	return LastVMP;
}

function float VMDGetFirePitch()
{
	local bool bUnderwater;
	local float GMult;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	if (Owner != None)
        {
         	if (Owner.Region.Zone.bWaterZone) bUnderwater = True;
        }
        else if (Region.Zone.bWaterZone) bUnderwater = True;
	
	//Make splash noises.
	if (bUnderwater)
	{
		return (1.1 - (Frand() * 0.2)) * 0.7 * GMult;
	}
	
	return (1.1 - (Frand() * 0.2)) * GMult;
}
function float VMDGetMiscPitch()
{
	local bool bUnderwater;
	local float GMult;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	if (Owner != None)
        {
         	if (Owner.Region.Zone.bWaterZone) bUnderwater = True;
        }
        else if (Region.Zone.bWaterZone) bUnderwater = True;	
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
	
	if (Owner != None)
        {
         	if (Owner.Region.Zone.bWaterZone) bUnderwater = True;
        }
        else if (Region.Zone.bWaterZone) bUnderwater = True;	
	//Make splash noises.
	if (bUnderwater)
	{
		return 0.7 * GMult;
	}
	
	//MADDERS: Subtler pitch variation on smaller bois.
	return 1.0 * GMult;
}

//MADDERS: Used for speed tweaks.
//So far this seems clean, but that may change depending on behavior uncovered later.
function VMDApplySpeedMult(float NewMult)
{
	MaxSpeed *= NewMult;
	Speed *= NewMult;
	Velocity *= NewMult;
	
	//MADDERS, 7/22/21: Use this as a hook for making C4 sticky when thrown. Bouncing, it is useless.
	if ((IsA('C4_Projectile')) && (Physics == PHYS_Falling))
	{
		//bStickToWall = True;
		bSticky = True;
	}
}

//MADDERS: To be continued in other classes, such as Rocket.
function float VMDGetExplosionDamageMult()
{
	return 1.0;
}

//Let this be edited if needed.
function HurtRadiusVMD( float DamageAmount, float DamageRadius, name DamageName, float Momentum, vector HitLocation, optional bool bIgnoreLOS )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local DeusExPlayer DXP;
	local DeusExRootWindow DXRW;
	
	// DEUS_EX CNN
	local Mover M;				
	
	if( bHurtEntry )
		return;
	
	if (DeusExPlayer(AggressiveExplodedOwner) != None) // Transcended - Added
		instigator = AggressiveExplodedOwner;
	
	DXP = DeusExPlayer(Owner);
	bHurtEntry = true;
   	if (!bIgnoreLOS)
   	{
      		foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
      		{
         		if( Victims != self )
         		{
				if (DXP != None)
				{
					if (Spydrone(Self) == None)
					{
						if (VMDBufferPlayer(Victims) != None)
						{
							VMDBufferPlayer(Victims).bLastSplashWasSelf = true;
						}
					}
					else
					{
						if (VMDBufferPlayer(Victims) != None)
						{
							VMDBufferPlayer(Victims).bLastSplashWasDrone = true;
						}
						else if (AutoTurret(Victims) != None)
						{
							AutoTurret(Victims).bLastSplashWasDrone = true;
						}
						else if (BeamTrigger(Victims) != None)
						{
							BeamTrigger(Victims).bLastSplashWasDrone = true;
						}
						else if (HackableDevices(Victims) != None)
						{
							HackableDevices(Victims).bLastSplashWasDrone = true;
						}
						else if (LaserTrigger(Victims) != None)
						{
							LaserTrigger(Victims).bLastSplashWasDrone = true;
						}
					}
				}
				
            			dir = Victims.Location - HitLocation;
            			dist = FMax(1,VSize(dir));
            			dir = dir/dist; 
            			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				
				if (VMDBufferPawn(Victims) != None || VMDBufferPlayer(Victims) != None)
				{
            				Victims.TakeDamage(
               					damageScale * Default.Damage,
               					Instigator, 
               					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
               					(damageScale * Momentum * dir),
               					DamageName);
				}
				else if (Brush(Victims) != None)
				{
            				Victims.TakeDamage(
               					damageScale * MoverDamageMult * Default.Damage,
               					Instigator, 
               					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
               					(damageScale * Momentum * dir),
               					DamageName);
				}
				else
				{
            				Victims.TakeDamage(
               					damageScale * DamageAmount,
               					Instigator, 
               					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
               					(damageScale * Momentum * dir),
               					DamageName);
				}
				
				if ((DXP != None) && (Victims.IsA('DeusExDecoration') || Victims.IsA('Pawn')))
				{
					if ((FastTrace(DXP.Location+vect(0,0,1)*DXP.BaseEyeHeight, Victims.Location)) && ((VMDBufferPawn(Victims) == None) || (!VMDBufferPawn(Victims).bInsignificant)))
					{
						if (VMDBufferPawn(Victims) != None)
						{
							VMDBufferPawn(Victims).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
							if (bClosedSystemHit)
							{
								VMDBufferPawn(Victims).bClosedSystemHit = bClosedSystemHit;
							}
						}
						else if (VMDBufferPlayer(Victims) != None)
						{
							VMDBufferPlayer(Victims).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
						}
						
		 				DXRW = DeusExRootWindow(DXP.RootWindow);
		 				if (DXRW != None)
		 				{
		  					DXRW.Hud.HitInd.SetIndicator(True);
		 				}
					}
				}
         		} 
      		}
   	}
   	else
   	{
      		foreach RadiusActors(class 'Actor', Victims, DamageRadius, HitLocation )
      		{
         		if( Victims != self )
         		{
				if (DXP != None)
				{
					if (Spydrone(Self) == None)
					{
						if (VMDBufferPlayer(Victims) != None)
						{
							VMDBufferPlayer(Victims).bLastSplashWasSelf = true;
						}
					}
					else
					{
						if (VMDBufferPlayer(Victims) != None)
						{
							VMDBufferPlayer(Victims).bLastSplashWasDrone = true;
						}
						else if (AutoTurret(Victims) != None)
						{
							AutoTurret(Victims).bLastSplashWasDrone = true;
						}
						else if (BeamTrigger(Victims) != None)
						{
							BeamTrigger(Victims).bLastSplashWasDrone = true;
						}
						else if (HackableDevices(Victims) != None)
						{
							HackableDevices(Victims).bLastSplashWasDrone = true;
						}
						else if (LaserTrigger(Victims) != None)
						{
							LaserTrigger(Victims).bLastSplashWasDrone = true;
						}
					}
				}
				
            			dir = Victims.Location - HitLocation;
            			dist = FMax(1,VSize(dir));
            			dir = dir/dist; 
            			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
				if (VMDBufferPawn(Victims) != None || VMDBufferPlayer(Victims) != None)
				{
 	           			Victims.TakeDamage(
 	              				damageScale * Default.Damage,
 	              				Instigator, 
 	              				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
 	              				(damageScale * Momentum * dir),
 	              				DamageName);
				}
				else if (Brush(Victims) != None)
				{
            				Victims.TakeDamage(
               					damageScale * MoverDamageMult * Default.Damage,
               					Instigator, 
               					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
               					(damageScale * Momentum * dir),
               					DamageName);
				}
				else
				{
 	           			Victims.TakeDamage(
 	              				damageScale * DamageAmount,
 	              				Instigator, 
 	              				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
 	              				(damageScale * Momentum * dir),
 	              				DamageName);
				}
				
				if ((DXP != None) && (Victims.IsA('DeusExDecoration') || Victims.IsA('Pawn')))
				{
					if ((FastTrace(DXP.Location+vect(0,0,1)*DXP.BaseEyeHeight, Victims.Location)) && ((VMDBufferPawn(Victims) == None) || (!VMDBufferPawn(Victims).bInsignificant)))
					{
						if (VMDBufferPawn(Victims) != None)
						{
							VMDBufferPawn(Victims).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
							if (bClosedSystemHit)
							{
								VMDBufferPawn(Victims).bClosedSystemHit = bClosedSystemHit;
							}
						}
						else if (VMDBufferPlayer(Victims) != None)
						{
							VMDBufferPlayer(Victims).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
						}
		 				DXRW = DeusExRootWindow(DXP.RootWindow);
		 				if (DXRW != None)
		 				{
		  					DXRW.Hud.HitInd.SetIndicator(True);
						}
		 			}
				}
         		} 
      		}
   	}
	
	//
	// DEUS_EX - CNN - damage the movers, also
	//
	foreach RadiusActors(class 'Mover', M, DamageRadius, HitLocation)
	{
		if (M != self)
		{
			dir = M.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist; 
			damageScale = 1 - FMax(0,(dist - M.CollisionRadius)/DamageRadius);
			M.TakeDamage
			(
				damageScale * MoverDamageMult * DamageAmount,
				Instigator, 
				M.Location - 0.5 * (M.CollisionHeight + M.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageName
			);
			
			if ((DXP != None) && (M.IsA('DeusExMover')) && (FastTrace(DXP.Location+vect(0,0,1)*DXP.BaseEyeHeight, Location)))
			{
			 	DXRW = DeusExRootWindow(DXP.RootWindow);
			 	if (DXRW != None)
			 	{
			  		DXRW.Hud.HitInd.SetIndicator(True);
			 	}
			}
		} 
	}

	bHurtEntry = false;
}

function PostBeginPlay()
{
	//MADDERS, 3/29/25: Initialize this here, in case our owner dies mid-check later, and clears its reference.
	if (Owner == None)
	{
		bOwnerless = true;
	}
	
	Super.PostBeginPlay();
	
 	if ((bEmitDanger) && (!bOwnerless))
	{
		AIStartEvent('Projectile', EAITYPE_Visual);
	}
}

//
// Let the player pick up stuck projectiles
//
function Frob(Actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);

	// if the player frobs it and it's stuck, the player can grab it
	if (bStuck)
	{
		GrabProjectile(DeusExPlayer(Frobber));
	}
}

function GrabProjectile(DeusExPlayer player)
{
	local Inventory item;

	if (player != None)
	{
		if (spawnWeaponClass != None)		// spawn the weapon
		{
			item = Spawn(spawnWeaponClass);
			if (item != None)
			{				
				if ( (Level.NetMode != NM_Standalone ) && Self.IsA('Shuriken'))
					DeusExWeapon(item).PickupAmmoCount = DeusExWeapon(item).PickupAmmoCount * 3;
				else
					DeusExWeapon(item).PickupAmmoCount = 1;
				
				//MADDERS, 11/1/22: Let us nab grenades, since we already double frob for these, usually.
				DeusExWeapon(Item).bItemRefusalOverride = true;
				
				if (Player.FindInventoryType(DeusExWeapon(item).AmmoName) == None)
				{
					//MADDERS: Shuriken weapons = shuriken ammo. Display it as such.
					//class'VMDStaticFunctions'.Static.AddReceivedItem(Player, Item, DeusExWeapon(Item).PickupAmmoCount);
				}
			}
		}
		else if (spawnAmmoClass != None)	// or spawn the ammo
		{
			item = Spawn(spawnAmmoClass);
			if (item != None)
			{
				if ( (Level.NetMode != NM_Standalone ) && Self.IsA('Dart'))
					Ammo(item).AmmoAmount = Ammo(item).AmmoAmount * 3;
				else
					Ammo(item).AmmoAmount = 1;
			}
		}
		if (item != None)
		{
			player.FrobTarget = item;
			
			// check to see if we can pick up the new weapon/ammo
			if (player.HandleItemPickup(item))
			{
				Destroy();				// destroy the projectile on the wall
				if ( Level.NetMode != NM_Standalone )
				{
					if ( item != None )
						item.Destroy();
				}
			}
			else
			{
				item.Destroy();			// destroy the weapon/ammo if it can't be picked up
			}
			player.FrobTarget = None;
		}
	}
}

//
// update our flight path based on our ranges and tracking info
//
simulated function Tick(float deltaTime)
{
	local float dist, size, HeadingDiffDot, GSpeed;
	local Rotator dir, TRot;
   	local vector TargetLocation, vel, NormalHeading, NormalDesiredHeading, zerovec;
	local VMDBufferPlayer VMP;
	
	if (bStuck)
	{
		return;
	}
	
	//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
	if ((AmbientSound != None) && (Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
		if (GSpeed > 1.0)
		{
			SoundPitch = Min(255, 64 + (16 * (GSpeed - 1.0)));
		}
		else
		{
			SoundPitch = Max(1, 64 * GSpeed);
		}
	}
	
	Super.Tick(deltaTime);
	
	//MADDRES, 6/24/23: Projectiles = scary. True story.
	if (!bSpentStress)
	{
		if (bStuck || DeusExPlayer(Owner) != None)
		{
			bSpentStress = true;
		}
		else
		{
			VMP = GetLastVMP();
			if ((VMP != None) && (VSize(VMP.Location - Location) < 80))
			{
				bSpentStress = true;
				if (DamageType == 'Flamed' || DamageType == 'Poison')
				{
					VMP.VMDModPlayerStress(Damage*2, true, 2, true);
				}
				else if (Tracer(Self) != None)
				{
					VMP.VMDModPlayerStress(5, true, 2, true);
				}
				else
				{
					VMP.VMDModPlayerStress(Max(1, Damage*0.25), true, 2, true);
				}
			}
		}
	}
	
   	if (VSize(LastSeenLoc) < 1)
   	{
      		LastSeenLoc = Location + Normal(Vector(Rotation)) * 10000;
   	}
	
   	if (Role == ROLE_Authority)
   	{
      		bHasNetworkTarget = (Target != None);
   	}
   	else
   	{
      		bHadLocalTarget = (bHadLocalTarget || (Target != None));
   	}

	if (bTracking && ((Target != None) || ((Level.NetMode != NM_Standalone) && (bHasNetworkTarget)) || ((Level.Netmode != NM_Standalone) && (bHadLocalTarget))))
	{
		// check it's range
		dist = Abs(VSize(Target.Location - Location));
		if (dist > MaxRange)
		{
			// if we're out of range, lose the lock and quit tracking
			bTracking = False;
			Target = None;
			return;
		}
		else
		{
			// get the direction to the target
         		if (Level.NetMode == NM_Standalone)
            			TargetLocation = Target.Location;
         		else
            			TargetLocation = AcquireMPTargetLocation();
         		if (Role == ROLE_Authority)
            			NetworkTargetLoc = TargetLocation;
         		LastSeenLoc = TargetLocation;
			dir = Rotator(TargetLocation - Location);
			dir.Roll = 0;

         		if (Level.Netmode != NM_Standalone)
         		{
            			NormalHeading = Normal(Vector(Rotation));
            			NormalDesiredHeading = Normal(TargetLocation - Location);
            			HeadingDiffDot = NormalHeading Dot NormalDesiredHeading;
         		}
			
			// set our new rotation
			bRotateToDesired = True;
			DesiredRotation = dir;
			
			// move us in the new direction that we are facing
			size = VSize(Velocity);
			vel = Normal(Vector(Rotation));
			
         		if (Level.NetMode != NM_Standalone)
         		{
            			size = FMax(HeadingDiffDot,0.4) * Speed;
         		}
			Velocity = vel * size;
		}
	}
   	else
   	{
      		// make the rotation match the velocity direction
		SetRotation(Rotator(Velocity));
   	}
	
	dist = Abs(VSize(initLoc - Location));
	
	if (dist > AccurateRange)		// start descent due to "gravity"
		Acceleration = Region.Zone.ZoneGravity / 2;
	
   	if ((Role < ROLE_Authority) && (bAggressiveExploded))
      		Explode(Location, vect(0,0,1));
	
 	if ((StuckTo != None) && (!StuckTo.bDeleteMe))
 	{
		TRot = (StuckTo.Rotation - StuckToRotation);
  		SetRotation(TRot + StickRotation);
  		SetLocation(StuckTo.Location + (StickOffset >> TRot));
 	}
	else if (bStuckToActor || bStuckToWorld)
	{
		VMDStopSticking();
	}
}

function Timer()
{
   	//if (bStuck)
   	//   Destroy();
}

simulated function vector AcquireMPTargetLocation()
{   	
   	local vector StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor hit, retval;
	
   	if (Target == None)
   	{
      		if (bHasNetworkTarget)
         		return NetworkTargetLoc;
      		else
         		return LastSeenLoc;
   	}
	
	StartTrace = Location;
   	EndTrace = Target.Location;
	
   	if (!Target.IsA('Pawn'))
      		return Target.Location;
	
	foreach TraceActors(class'Actor', hit, HitLocation, HitNormal, EndTrace, StartTrace)
   	{
		if (hit == Target)
			return Target.Location;
   	}
      	
   	// adjust for eye height
	EndTrace.Z += Pawn(Target).BaseEyeHeight;
	
	foreach TraceActors(class'Actor', hit, HitLocation, HitNormal, EndTrace, StartTrace)
   	{
		if (hit == Target)
			return EndTrace;
   	}
	
	return LastSeenLoc;
}

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
	local int i;
	
   	if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      		return;
	
   	spawn(class'BloodSpurt',,,HitLocation+HitNormal);
	for (i=0; i<Damage/7; i++)
	{
		if (FRand() < 0.5)
			spawn(class'BloodDrop',,,HitLocation+HitNormal*4);
	}
}

simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local int i;
	local DeusExDecal mark;
   	local Rockchip chip;
	local DeusExMover mov;
	local float effectiveDamage;

   	local bool HDTP_NotDetected;
	local PlayerPawn playerPawn;
	local DeusExPlayer localPlayer;
		
	// Don't do anything if we hit a FakeBackdrop
	if (!bHitFakeBackdrop)
		CheckIfHitFakeBackDrop();

	if (bHitFakeBackdrop)
		return;
	
	mov = DeusExMover(Other);

	// don't draw damage art on destroyed movers
	if (mov != None)
		if (mov.bDestroyed)
			ExplosionDecal = None;
	
	// draw the explosion decal here, not in Engine.Projectile
	if (ExplosionDecal != None)
	{
		mark = DeusExDecal(Spawn(ExplosionDecal, Self,, HitLocation, Rotator(HitNormal)));
		if (mark != None)
		{
			mark.DrawScale = FClamp(damage/30, 0.5, 3.0);
			mark.ReattachDecal();
		}

		ExplosionDecal = None;
	}
	else if ((mov != None) && !mov.bDestroyed && mov.bBreakable)
	{
		effectiveDamage = Damage * MoverDamageMult;
		if ((DamageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage') || (damageType == 'HalonGas')
		|| (damageType == 'Stunned') || (damageType == 'Radiation') || (DamageType == 'EMP')
		|| (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
			effectiveDamage = -1.000;
		if (mov.minDamageThreshold <= effectiveDamage)
		{
			mark = Spawn(class'BulletHole', mov,, HitLocation, Rotator(HitNormal));
			if (mark != None)
			{
				mark.remoteRole = ROLE_None;
				if (mov.FragmentClass == class'GlassFragment')
				{
					// glass hole
					if (FRand() < 0.5)
						mark.Texture = Texture'FlatFXTex29';
					else
						mark.Texture = Texture'FlatFXTex30';

					mark.DrawScale = 0.1;
					mark.ReattachDecal();
				}
				else
				{
					// non-glass crack
					if (FRand() < 0.5)
						mark.Texture = Texture'FlatFXTex7';
					else
						mark.Texture = Texture'FlatFXTex8';

					mark.DrawScale = 0.4;
					mark.ReattachDecal();
				}
			}
		}
	}
	
   	//DEUS_EX AMSD Don't spawn these on the server.
   	if ((Level.NetMode == NM_DedicatedServer) && (Role == ROLE_Authority))
      		return;

   	if (bDebris)
	{
		for (i=0; i<Damage/5; i++)
			if (FRand() < 0.8)
         		{
				chip = spawn(class'Rockchip',,,HitLocation+HitNormal);
            			//DEUS_EX AMSD In multiplayer, don't propagate these to 
            			//other players (or from the listen server to clients).
            			if (chip != None)            
               				chip.RemoteRole = ROLE_None;
         		}
	}
}

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ShockRing ring;
   	local SphereEffect sphere;
	local ExplosionLight light;
   	local AnimatedSprite expeffect;
	
	// Don't do anything if we hit a FakeBackdrop
	if (!bHitFakeBackdrop)
		CheckIfHitFakeBackDrop();
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
   	if (light != None)
      		light.RemoteRole = ROLE_None;
	
	if (blastRadius < 128)
	{
		expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
		light.size = 2;
	}
	else if (blastRadius < 256)
	{
		expeffect = Spawn(class'ExplosionMedium',,, HitLocation);
		light.size = 4;
	}
	else
	{
		expeffect = Spawn(class'ExplosionLarge',,, HitLocation);
		light.size = 8;
	}
	
   	if (expeffect != None)
      		expeffect.RemoteRole = ROLE_None;
	
	// draw a pretty shock ring
   	// For nano defense we are doing something else.
   	if ((!bAggressiveExploded) || (Level.NetMode == NM_Standalone))
   	{
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(16384,0,0));
      		if (ring != None)
      		{
         		ring.RemoteRole = ROLE_None;
         		ring.size = blastRadius / 32.0;
      		}
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,0,0));
      		if (ring != None)
      		{
         		ring.RemoteRole = ROLE_None;
         		ring.size = blastRadius / 32.0;
      		}
      		ring = Spawn(class'ShockRing',,, HitLocation, rot(0,16384,0));
      		if (ring != None)
      		{
         		ring.RemoteRole = ROLE_None;
         		ring.size = blastRadius / 32.0;
      		}
   	}
   	else
   	{
      		sphere = Spawn(class'SphereEffect',,, HitLocation, rot(16384,0,0));
      		if (sphere != None)
      		{
         		sphere.RemoteRole = ROLE_None;
         		sphere.size = blastRadius / 32.0;
      		}
      		sphere = Spawn(class'SphereEffect',,, HitLocation, rot(0,0,0));
      		if (sphere != None)
      		{
         		sphere.RemoteRole = ROLE_None;
         		sphere.size = blastRadius / 32.0;
      		}
      		sphere = Spawn(class'SphereEffect',,, HitLocation, rot(0,16384,0));
      		if (sphere != None)
      		{
         		sphere.RemoteRole = ROLE_None;
         		sphere.size = blastRadius / 32.0;
      		}
   	}
}

//
// Exploding state
//
state Exploding
{
	ignores ProcessTouch, HitWall, Explode;
	
   	function DamageRing()
   	{
		local Pawn apawn;
		local float damageRadius;
		local Vector dist;

		if ( Level.NetMode != NM_Standalone )
		{
			damageRadius = (blastRadius / gradualHurtSteps) * gradualHurtCounter;

			for ( apawn = Level.PawnList; apawn != None; apawn = apawn.nextPawn )
			{
				if ( apawn.IsA('DeusExPlayer') )
				{
					dist = apawn.Location - Location;
					if ( VSize(dist) < damageRadius )
					{
						if ( gradualHurtCounter <= 2 )
						{
							if ( apawn.FastTrace( apawn.Location, Location ))
								DeusExPlayer(apawn).myProjKiller = Self;
						}
						else
							DeusExPlayer(apawn).myProjKiller = Self;
					}
				}
			}
		}
      		//DEUS_EX AMSD Ignore Line of Sight on the lowest radius check, only in multiplayer
		HurtRadiusVMD
		(
			(2 * Damage * VMDGetExplosionDamageMult()) / gradualHurtSteps,
			(blastRadius / gradualHurtSteps) * gradualHurtCounter,
			damageType,
			MomentumTransfer / gradualHurtSteps,
			Location,
         		((gradualHurtCounter <= 2) && (Level.NetMode != NM_Standalone))
		);
   	}
	
	function Timer()
	{
		gradualHurtCounter++;
      		DamageRing();
		if (gradualHurtCounter >= gradualHurtSteps)
			Destroy();
	}

Begin:
	// stagger the HurtRadius outward using Timer()
	// do five separate blast rings increasing in size
	gradualHurtCounter = 1;
	gradualHurtSteps = 5;
	Velocity = vect(0,0,0);
	bHidden = True;
	LightType = LT_None;
	SetCollision(False, False, False);
   	DamageRing();
	SetTimer(0.25/float(gradualHurtSteps), True);
}

function PlayImpactSound()
{
	local float rad;
	
	if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer) || (Level.NetMode == NM_DedicatedServer))
	{
		rad = Max(blastRadius*4, 1024);
		PlaySound(ImpactSound, SLOT_None, 2.0,, rad, VMDGetMiscPitch());
	}
}

auto simulated state Flying
{
	simulated function ProcessTouch (Actor Other, Vector HitLocation)
	{
		if (bSticky)
		{
			VMDStickTo(Other);
		}
		else if ((!bStuckToActor) && (!bStuckToWorld))
		{
			if (bStuck)
				return;
			
			//MADDERS: Stop grenades from insta-blowing up on corpses!
			if ((Carcass(Other) != None) && (ThrownProjectile(Self) != None) && (bExplodes)) return;
			
			if ((Other != instigator) && (DeusExProjectile(Other) == None) && (Other != Owner))
			{
				if (VMDBufferPawn(Other) != None)
				{
					VMDBufferPawn(Other).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
					if (StuckAmmoClass != None)
					{
						VMDBufferPawn(Other).AddStuckAmmoUnit(StuckAmmoClass, StickAmmoRate, 1);
					}
					if (bClosedSystemHit) VMDBufferPawn(Other).bClosedSystemHit = bClosedSystemHit;
				}
				
				damagee = Other;
				Explode(HitLocation, Normal(HitLocation-damagee.Location));
				
         			// DEUS_EX AMSD Spawn blood server side only
         			if (Role == ROLE_Authority)
				{
            				if (damagee.IsA('Pawn') && !damagee.IsA('Robot') && bBlood)
               					SpawnBlood(HitLocation, Normal(HitLocation-damagee.Location));
				}
			}
		}
	}
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		if (bSticky)
		{
			VMDStickTo(Wall);
		}
		else if ((!bStuckToActor) && (!bStuckToWorld))
		{
			if (bStickToWall)
			{
				Velocity = vect(0,0,0);
				Acceleration = vect(0,0,0);
				SetPhysics(PHYS_None);
				bStuck = True;
				
				// MBCODE: Do this only on server side
				if ( Role == ROLE_Authority )
				{
	            			if (Level.NetMode != NM_Standalone)
	               				SetTimer(5.0,False);
	
					if (Wall.IsA('Mover'))
					{
						SetBase(Wall);
						Wall.TakeDamage(int(Damage * MoverDamageMult), Pawn(Owner), Wall.Location, MomentumTransfer*Normal(Velocity), damageType);
					}
				}
			}
			
			if (Wall.IsA('BreakableGlass'))
				bDebris = False;
			
			SpawnEffects(Location, HitNormal, Wall);
			
			Super.HitWall(HitNormal, Wall);
		}
	}
	simulated function Explode(vector HitLocation, vector HitNormal)
	{
		local bool bDestroy;
		local float rad, NoiseMult;
		
		local Pawn OldInstigator;
		local DeusExPlayer DXP;
		local DeusExRootWindow DXRW;
		
      		// Reduce damage on nano exploded projectiles
      		if ((bAggressiveExploded) && (Level.NetMode != NM_Standalone))
         		Damage = Damage/6;
		
		bDestroy = false;
		
		//MADDERS, 5/27/23: Taser slugs now backfire if we get burst too close to our owner. Devastating.
		if ((bAggressiveExploded) && (TaserSlug(Self) != None) && (Pawn(Owner) != None) && (VSize(Owner.Location - Location) < 160))
		{
			Pawn(Owner).TakeDamage(6, Pawn(Owner), HitLocation, HitNormal, 'Stunned');
		}
		
		if (bExplodes)
		{
         		//DEUS_EX AMSD Don't draw effects on dedicated server
         		if ((Level.NetMode != NM_DedicatedServer) || (Role < ROLE_Authority))			
            		DrawExplosionEffects(HitLocation, HitNormal);
			
			GotoState('Exploding');
		}
		else
		{
			// Server side only
			if ( Role == ROLE_Authority )
			{
				if ((damagee != None) && (Tracer(Self) == None)) // Don't even attempt damage with a tracer
				{
					if ( Level.NetMode != NM_Standalone )
					{
						if ( damagee.IsA('DeusExPlayer') )
							DeusExPlayer(damagee).myProjKiller = Self;
					}
					
					DXP = DeusExPlayer(Owner);
					if ((DXP != None) && (Damagee.IsA('DeusExDecoration') || Damagee.IsA('Pawn')))
					{
						if ((FastTrace(DXP.Location, Damagee.Location)) && ((VMDBufferPawn(Damagee) == None) || (!VMDBufferPawn(Damagee).bInsignificant)))
						{
					 		DXRW = DeusExRootWindow(DXP.RootWindow);
					 		if (DXRW != None)
					 		{
					  			DXRW.Hud.HitInd.SetIndicator(True);
							}
					 	}
					}
					
					if (VMDBufferPawn(Damagee) != None)
					{
						VMDBufferPawn(Damagee).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
						damagee.TakeDamage(Default.Damage, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), damageType);
					}
					else if (VMDBufferPlayer(Damagee) != None)
					{
						VMDBufferPlayer(Damagee).LastWeaponDamageSkillMult = LastWeaponDamageSkillMult;
						damagee.TakeDamage(Default.Damage, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), damageType);
					}
					else if (Mover(Damagee) != None)
					{
						damagee.TakeDamage(Damage * MoverDamageMult, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), damageType);
					}
					else
					{
						damagee.TakeDamage(Damage, Pawn(Owner), HitLocation, MomentumTransfer*Normal(Velocity), damageType);
					}
				}
			}
			if (!bStuck)
				bDestroy = true;
		}
		
		rad = Max(blastRadius*24, 1024);
		
		// This needs to be outside the simulated call chain
		PlayImpactSound();
		
      		//DEUS_EX AMSD Only do these server side
      		if (Role == ROLE_Authority)
      		{
         		if ((ImpactSound != None) && (!bOwnerless))
         		{
				NoiseMult = VMDOpenSpaceRadiusMult();
				VMDUseAIEventSender(GetPlayerPawn(), 'LoudNoise', EAITYPE_Audio, 2.0, blastRadius*24*NoiseMult);
				AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, blastRadius*24*NoiseMult);
				
	     			if ((bExplodes) && (OldInstigator == None))
				{
					NoiseMult = VMDOpenSpaceRadiusMult(DamageType == 'Exploded');
					AISendEvent('WeaponFire', EAITYPE_Audio, 2.0, blastRadius*5*NoiseMult);
				}
         		}
      		}
		if (bDestroy)
			Destroy();
	}
	simulated function BeginState()
	{
		local DeusExWeapon W;
		local Vector OwnerInertia;
		local Actor TOwner;
		
		initLoc = Location;
		initDir = vector(Rotation);
		Velocity = speed*initDir;
		
		//MADDERS: Inherit velocity from our owner's movement.
		if (Owner != None) TOwner = Owner;
		else TOwner = Instigator;
		
		if (TOwner != None)
		{
			if (TOwner.Base != None) OwnerInertia = TOwner.Base.Velocity;
			else OwnerInertia = TOwner.Velocity;
			Velocity += OwnerInertia;
		}
		
		//MADDERS: Track our sound play via "snapshot".
		if (SpawnSound != None)
		{
			StartSoundSnap = PlaySound(SpawnSound, SLOT_None,,,,VMDGetFirePitch());
		}
	}
}

function float VMDOpenSpaceRadiusMult(optional bool bStrongScale)
{
	if (!bStrongScale)
	{
		return FMax(1.0, Sqrt(Max(1, VMDOpenSpaceLevel())) / 3.33);
	}
	else
	{
		return FMax(1.0, Sqrt(Max(1, VMDOpenSpaceLevel())) / 2);
	}
}

function int VMDOpenSpaceLevel(optional bool bPlayerRelevant)
{
	local Vector TStart, TEnds[14], HL, HN;
	local int Ret, i;
	
	if ((bPlayerRelevant) && (PlayerPawn(Owner) == None)) return 1;
	if (Owner == None) return 1;
	
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

function CheckIfHitFakeBackDrop()
{	
	local vector StartTrace, EndTrace, HitLocation2, HitNormal2;
	local actor target;
	local int texFlags;
	local name texName, texGroup;
	
	StartTrace = Location;
	EndTrace = Location + 500 * vector(Rotation);
	if (IsA('Shuriken'))	// Shurikens rotate while in the air, so use their velocity instead. This might work for all classes, but the old method works so I don't want to risk it
		EndTrace = Location + 500 * Velocity;
	
	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation2, HitNormal2, EndTrace, StartTrace)
	{
		if ((target.DrawType == DT_None) || target.bHidden)
		{
			// do nothing - keep on tracing
		}
		else if ((target == Level) || target.IsA('Mover'))
		{
			break;
		}
		else
		{
			break;
		}
	}
	
	// 0x00000080 is the PF_FakeBackdrop flag from UnObj.h
	if ((texFlags & 0x00000080) != 0)
		bHitFakeBackdrop = True;
	
	return;
}

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function DamageRing();

defaultproperties
{
     MoverDamageMult=1.000000
     LastWeaponDamageSkillMult=-1.000000
     StartSoundSnap=-1
     StickAmmoRate=0.800000
     
     AccurateRange=800
     maxRange=1600
     MinDrawScale=0.050000
     maxDrawScale=2.500000
     bEmitDanger=True
     ItemName="DEFAULT PROJECTILE NAME - REPORT THIS AS A BUG"
     ItemArticle="Error"
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=60.000000
     RotationRate=(Pitch=65536,Yaw=65536)
}
