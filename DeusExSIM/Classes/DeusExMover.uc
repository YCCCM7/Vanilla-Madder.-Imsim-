//=============================================================================
// DeusExMover.
//=============================================================================
class DeusExMover extends Mover;

var() bool 				bOneWay;				// this door can only be opened from one side
var() bool 				bLocked;				// this door is locked
var() bool 				bPickable;				// this lock can be picked
var() float 			lockStrength;			// "toughness" of the lock on this door - 0.0 is easy, 1.0 is hard
var() float          initiallockStrength; // for resetting lock, initial lock strength of door.
var() bool           bInitialLocked;      // for resetting lock
var() bool 				bBreakable;				// this door can be destroyed
var() float				doorStrength;			// "toughness" of this door - 0.0 is weak, 1.0 is strong
var() name				KeyIDNeeded;			// key ID code to open the door
var() bool				bHighlight;				// should this door highlight when focused?
var() bool				bFrobbable;				// this door can be frobbed

var bool				bPicking;				// a lockpick is currently being used
var float				pickValue;				// how much this lockpick is currently picking
var float				pickTime;				// how much time it takes to use a single lockpick
var int					numPicks;				// how many times to reduce hack strength
var float            TicksSinceLastPick; //num ticks done since last pickstrength update(includes partials)
var float            TicksPerPick;       // num ticks needed for a hackstrength update (includes partials)
var float			 LastTickTime;		 // Time at which last tick occurred.

var DeusExPlayer		pickPlayer;				// the player that is picking
var Lockpick			curPick;				// the lockpick that is being used

var() int 				minDamageThreshold;		// damage below this amount doesn't count
var bool				bDestroyed;				// has this mover already been destroyed?

var() int				NumFragments;			// number of fragments to spew on destroy
var() float				FragmentScale;			// scale of fragments
var() int				FragmentSpread;			// distance fragments will be thrown
var() class<Fragment>	FragmentClass;			// which fragment
var() texture			FragmentTexture;		// what texture to use on fragments
var() bool				bFragmentTranslucent;	// are these fragments translucent?
var() bool				bFragmentUnlit;			// are these fragments unlit?
var() sound				ExplodeSound1;			// small explosion sound
var() sound				ExplodeSound2;			// large explosion sound
var() bool				bDrawExplosion;			// should we draw an explosion?
var() bool				bIsDoor;				// is this mover an actual door?

var() float          TimeSinceReset;   // how long since we relocked it
var() float          TimeToReset;      // how long between relocks

var localized string	msgKeyLocked;			// message when key locked door
var localized string	msgKeyUnlocked;			// message when key unlocked door
var localized string	msgLockpickSuccess;		// message when lock is picked
var localized string	msgOneWayFail;			// message when one-way door can't be opened
var localized string	msgLocked;				// message when the door is locked
var localized string	msgPicking;				// message when the door is being picked
var localized string	msgAlreadyUnlocked;		// message when the door is already unlocked
var localized string	msgNoNanoKey;			// message when the player doesn't have the right nanokey

//+++++++++++++++++++++++++
//MADDERS additions!
var bool bMaddersSetup, bMadderPatched; //MADDERS: Patching doors with map fixer. Don't do it more than once.
var bool bDamageRevealed, bLockRevealed;
var int RevealedDamageThreshold; //Show our threshold in chunks.
var int TimesPicked;
var localized string RushMessage;

var bool bAltPicking; //Rush mechanic

function bool VMDIsBasePosException()
{
	return false;
}

function VMDProduceScoutNoise(DeusExPlayer DXP, name DT)
{
	local float UsePitch, GSpeed;
	
	//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if (DXP == None || DeusExWeapon(DXP.InHand) == None || DeusExWeapon(DXP.InHand).VMDIsBulletWeapon()) return;
	
	if (DT == 'Shot' || DT == 'KnockedOut' || DT == 'Stunned')
	{			
			UsePitch = (1.45 + (Frand() * 0.3)) / 2;
			UsePitch *= GSpeed;
			if ((FragmentClass == class'WoodFragment') && (bBreakable))
			{
				PlaySound(sound'BatonHitHard',SLOT_Misc,10.0,,,UsePitch);
			}
			else
			{
				PlaySound(sound'BulletproofHit',SLOT_Misc,10.0,,,UsePitch);
				PlaySound(sound'BulletproofHit',SLOT_Interact,10.0,,,UsePitch);
			}
	}
}

//MADDERS: Update doors here.
function VMDApplySpecialDoorStats(optional bool bForce)
{
	local VMDBufferPlayer VMP;
	
 	if ((bMaddersSetup) && (!bForce)) return;
 	if (class != Class'DeusExMover') return;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.HasSkillAugment('LockpickStartStealth')))
	{
		bDamageRevealed = true;
		if (RevealedDamageThreshold < MinDamageThreshold) RevealedDamageThreshold = MinDamageThreshold;
	}
 	
 	bMaddersSetup = true;
}

function int VMDGenerateNumPicks()
{
	local int Ret, RandChunk, Seed;
	
	//Seed = (TimesPicked + class'VMDStaticFunctions'.Static.DeriveActorSeed(21, true)) % 21;
	//RandChunk = class'VMDStaticFunctions'.Static.RipSeedChunk("Picking 1", Seed);
	
	//MADDERS: Messy history, but we've gradually steered closer to non-gameability, vs the original version.
	//------------
	//Ret = PickValue * (50 + Rand(102));
	//Ret = (50 + Rand(102));
	//Ret = (50 + (5 * RandChunk));
	
	Ret = 100;
	
	return Ret;
}

function float VMDGeneratePickTime()
{
	local float Ret, FRandChunk;
	local int Seed;
	
	//Seed = (TimesPicked + class'VMDStaticFunctions'.Static.DeriveActorSeed(21, false)) % 21;
	//FRandChunk = class'VMDStaticFunctions'.Static.RipSeedChunk("Picking 2", Seed);
	
	//MADDERS: Also messy history, but just purely randomize it, since it doesn't even matter.
	Ret = Default.PickTime * (0.5 + Frand());
	//Ret = Default.PickTime * (0.5 + (0.05*FRandChunk));
	
	Ret *= 1.35;
	
	return Ret;
}

function bool VMDIsSoftDoor()
{
 	//MADDERS: Wood and glass soft. Unbreakable normally has fragments unset, so assume hard, which makes sense anyways.
 	if (!bBreakable) return false;
 	if (FragmentClass == class'WoodFragment' || FragmentClass == class'GlassFragment') return true;
 	return false;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// keep these within limits
	lockStrength = FClamp(lockStrength, 0.0, 1.0);
	doorStrength = FClamp(doorStrength, 0.0, 1.0);

	if (!bPickable)
		lockStrength = 1.0;
	if (!bBreakable)
		doorStrength = 1.0;

	initiallockStrength = lockStrength;
	TimeSinceReset = 0.0;
	bInitialLocked = bLocked;
}


// -------------------------------------------------------------------------------
// Network Replication
// -------------------------------------------------------------------------------

replication
{
   	//Variables server to client
   	reliable if (Role == ROLE_Authority)
      		bLocked, pickValue, lockStrength, doorStrength;
}

//
// ComputeMovementArea() - Computes a bounding box for the area
//                         in which this mover will move
//
function ComputeMovementArea(out vector center, out vector area)
{
	local int     i, j;
	local float   mult;
	local int     count;
	local vector  box1, box2;
	local vector  minVect;
	local vector  maxVect;
	local vector  newLocation;
	local rotator newRotation;

	if (NumKeys > 0)  // better safe than silly
	{
		// Initialize our bounding box
		GetBoundingBox(box1, box2, false, KeyPos[0]+BasePos, KeyRot[0]+BaseRot);

		// Compute the total area of our bounding box
		for (i=1; i<NumKeys; i++)
		{
			if (KeyRot[i] == KeyRot[i-1])
				count = 1;
			else
				count = 3;
			for (j=0; j<count; j++)
			{
				mult = float(j+1)/count;
				newLocation = BasePos + (KeyPos[i]-KeyPos[i-1])*mult + KeyPos[i-1];
				newRotation = BaseRot + (KeyRot[i]-KeyRot[i-1])*mult + KeyRot[i-1];
				if (GetBoundingBox(minVect, maxVect, false, newLocation, newRotation))
				{
					// Expand the bounding box
					box1.X = FMin(FMin(box1.X, maxVect.X), minVect.X);
					box1.Y = FMin(FMin(box1.Y, maxVect.Y), minVect.Y);
					box1.Z = FMin(FMin(box1.Z, maxVect.Z), minVect.Z);
					box2.X = FMax(FMax(box2.X, maxVect.X), minVect.X);
					box2.Y = FMax(FMax(box2.Y, maxVect.Y), minVect.Y);
					box2.Z = FMax(FMax(box2.Z, maxVect.Z), minVect.Z);
				}
			}
		}
	}

	// Fallback
	else
	{
		box1 = vect(0,0,0);
		box2 = vect(0,0,0);
	}

	// Compute center/area of the bounding box and return
	center = (box1+box2)/2;
	area = box2 - center;

}

//
// FinishNotify() - overridden from Mover; called when mover has finished moving
//
function FinishNotify()
{
	local Pawn   curPawn;
	local vector box1, box2;
	local vector center, area;
	local float  distX, distY, distZ;
	local float  maxX, maxY, maxZ;
	local float  dist;
	local float  maxDist;
	local vector tempVect;
	local bool   bNotify;

	Super.FinishNotify();

	if ((NumKeys > 0) && (MoverEncroachType == ME_IgnoreWhenEncroach))
	{
		GetBoundingBox(box1, box2, false, KeyPos[KeyNum]+BasePos, KeyRot[KeyNum]+BaseRot);
		center  = (box1+box2)/2;
		area    = box2 - center;
		maxDist = VSize(area)+200;
      		// XXXDEUS_EX AMSD Slow Pawn Iterator
		//foreach RadiusActors(Class'Pawn', curPawn, maxDist)
      		for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
		{
         		if ((CurPawn != None) && (VSize(CurPawn.Location - Location) < (MaxDist + CurPawn.CollisionRadius)))
         		{
            			bNotify = false;
            			distZ = Abs(center.Z - curPawn.Location.Z);
            			maxZ  = area.Z + curPawn.CollisionHeight;
            			if (distZ < maxZ)
            			{
               				distX = Abs(center.X - curPawn.Location.X);
               				distY = Abs(center.Y - curPawn.Location.Y);
               				maxX  = area.X + curPawn.CollisionRadius;
               				maxY  = area.Y + curPawn.CollisionRadius;
               				if ((distX < maxX) && (distY < maxY))
               				{
                  				if ((distX >= area.X) && (distY >= area.Y))
                  				{
                     					tempVect.X = distX-area.X;
                     					tempVect.Y = distY-area.Y;
                     					tempVect.Z = 0;
                     					if (VSize(tempVect) < CollisionRadius)
                        					bNotify = true;
                  				}
                  				else
                     					bNotify = true;
               				}
            			}
            			if (bNotify)
               				curPawn.EncroachedByMover(self);
         		}
		}
		AIEndEvent('LoudNoise', EAITYPE_Visual);
	}
}

//
// DropThings() - drops everything that is based on this mover
//
function DropThings()
{
	local actor A;

	// drop everything that is on us
	foreach BasedActors(class'Actor', A)
		A.SetPhysics(PHYS_Falling);
}

//
// "Destroy" the mover
//
function BlowItUp(Pawn instigatedBy)
{
	local bool bTempFrags;
	local int i, TWidth, TBreadth, THeight;
	local float GSpeed;
	local Vector spawnLoc, ColBoxMin, ColBoxMax;
	local Actor A;
	local DeusExDecal D;
	local ExplosionLight light;
	local Fragment frag;
	
	//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	// force the mover to stop
	if (Leader != None)
		Leader.MakeGroupStop();
	
	Instigator = instigatedBy;
	
	// trigger our event
	if (Event != '')
	{
		foreach AllActors(class'Actor', A, Event)
		{
			if (A != None)
			{
				A.Trigger(Self, instigatedBy);
			}
		}
	}
	
	// destroy all effects that are on us
	foreach BasedActors(class'DeusExDecal', D)
		D.Destroy();
	
	DropThings();
	
	// get the origin of the mover
	spawnLoc = Location - (PrePivot >> Rotation);
	
	//MADDERS, 8/6/23: Make small containers have their fragments fade.
	GetBoundingBox(ColBoxMin, ColBoxMax, false, KeyPos[KeyNum]+BasePos, KeyRot[KeyNum]+BaseRot);
	TWidth = ColBoxMax.Y - ColBoxMin.Y;
	TBreadth = ColBoxMax.X - ColBoxMin.X;
	THeight = ColBoxMax.Z - ColBoxMin.Z;
	if (TWidth < 48)
	{
		if (TBreadth < 48)
		{
			bTempFrags = true;
		}
		else if (THeight < 48)
		{
			bTempFrags = true;
		}
	}
	else if (TBreadth < 48)
	{
		if (THeight < 48)
		{
			bTempFrags = true;
		}
	}
	
	// spawn some fragments and make a sound
	for (i=0; i<NumFragments; i++)
	{
		frag = Spawn(FragmentClass,,, spawnLoc + FragmentSpread * VRand());
		if (frag != None)
		{
			frag.Instigator = instigatedBy;
			
			// make the last fragment just drop down so we have something to attach the sound to
			if (i == NumFragments - 1)
				frag.Velocity = vect(0,0,0);
			else
				frag.CalcVelocity(VRand(), FragmentSpread);
			
			frag.DrawScale = FragmentScale;
			if (FragmentTexture != None)
				frag.Skin = FragmentTexture;
			if (bFragmentTranslucent)
				frag.Style = STY_Translucent;
			if (bFragmentUnlit)
				frag.bUnlit = True;
			
			//MADDERS, 8/6/23: And here we force a fade...
			if ((bTempFrags) && (DeusExFragment(Frag) != None))
			{
				DeusExFragment(Frag).bForceFade = true;
			}
		}
	}

	// should we draw explosion effects?
	if (bDrawExplosion)
	{
		light = Spawn(class'ExplosionLight',,, spawnLoc);
		if (FragmentSpread < 64)
		{
			Spawn(class'ExplosionSmall',,, spawnLoc);
			if (light != None)
				light.size = 2;
		}
		else if (FragmentSpread < 128)
		{
			Spawn(class'ExplosionMedium',,, spawnLoc);
			if (light != None)
				light.size = 4;
		}
		else
		{
			Spawn(class'ExplosionLarge',,, spawnLoc);
			if (light != None)
				light.size = 8;
		}
	}

	// alert NPCs that I'm breaking
	AISendEvent('LoudNoise', EAITYPE_Audio, 2.0, FragmentSpread * 16);

	MakeNoise(2.0);
	if (frag != None)
	{
		if (NumFragments <= 5)
			frag.PlaySound(ExplodeSound1, SLOT_None, 2.0,, FragmentSpread*256, GSpeed);
		else
			frag.PlaySound(ExplodeSound2, SLOT_None, 2.0,, FragmentSpread*256, GSpeed);
	}

   	//DEUS_EX AMSD Mover is dead, make it a dumb proxy so location updates
   	RemoteRole = ROLE_DumbProxy;
	SetLocation(Location+vect(0,0,20000));		// move it out of the way
	SetCollision(False, False, False);			// and make it non-colliding
	bDestroyed = True;
}

//
// SupportActor()
//
// Called when somebody lands on us (copied from DeusExDecoration)
//

singular function SupportActor(Actor standingActor)
{
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

	if (!bDestroyed)
		standingActor.SetBase(self);
	else
		standingActor.SetPhysics(PHYS_Falling);
}


//
// Copied from Engine.Mover
//
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType)
{
	local int DamageAdd;
	local VMDBufferPlayer VMP;
	local DeusExPlayer DXP;
	
	if (bDestroyed)
		return;
	
	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage') || (damageType == 'HalonGas'))
		return;
	
	if ((damageType == 'Stunned') || (damageType == 'Radiation'))
		return;
	
	if ((DamageType == 'EMP') || (DamageType == 'NanoVirus') || (DamageType == 'Shocked'))
		return;
	
	VMP = VMDBufferPlayer(InstigatedBy);
	DXP = DeusExPlayer(Instigatedby);
	
	if (DXP != None)
	{
		if ((!bBreakable) && (!bDamageRevealed))
		{
			VMDProduceScoutNoise(DXP, DamageType);
		}
		bDamageRevealed = true;
	}
	if (bBreakable)
	{
		//MADDERS: Any damage dealt by players reveals us, if breakable.
		if ((!bHighlight) && (DXP != None))
		{
			bHighlight = true;
		}
		if ((VMP != None) && (bBreakable) && (RevealedDamageThreshold < MinDamageThreshold))
		{
			//MADDERS: Streamline this for non-augment usage.
			DamageAdd = Damage * (1.0);
			if (FragmentClass == class'WoodFragment') DamageAdd *= 2;
			
			//MADDERs, 1/20/21: QOL for scouting not taking too long.
			DamageAdd *= 2; //if (VMP.HasSkillAugment('LockpickScoutNoise')) 
			DamageAdd += 1;
			
			//MADDERS: Limit door scouting to be non-iterative when we don't have the skill augment.
			/*if (!VMP.HasSkillAugment('LockpickScoutNoise')) //"MeleeDoorScouting"
			{
				if (RevealedDamageThreshold < Min(DamageAdd, MinDamageThreshold))
				{
					VMDProduceScoutNoise(DXP, DamageType);
				}
				
				RevealedDamageThreshold = Clamp(Max(RevealedDamageThreshold, DamageAdd), 0, MinDamageThreshold);
			}
			else
			{*/
				//MADDERS, 12/5/23: This is now standard functionality again.
				if (RevealedDamageThreshold < MinDamageThreshold)
				{
					VMDProduceScoutNoise(DXP, DamageType);
				}
				
				//MADDERS: Moved randomization here for convenience sake.
				DamageAdd = Damage * (1.0 + FRand() * 0.4);
				RevealedDamageThreshold = Clamp(RevealedDamageThreshold + DamageAdd, 0, MinDamageThreshold);
			//}
		}
		
		// add up the damage
		if (Damage >= minDamageThreshold)
			doorStrength -= Damage * 0.01;
//		else
//			doorStrength -= Damage * 0.001;		// damage below the threshold does 1/10th the damage
		
		doorStrength = FClamp(doorStrength, 0.0, 1.0);
		if (doorStrength ~= 0.0)
		{
			BlowItUp(instigatedBy);
			if (!VMDIsBasePosException())
			{
				BasePos = Location;
			}
		}
	}
}

//
// Called every 0.1 seconds while the pick is actually picking
//
function Timer()
{
	local DeusExMover M;

	if (bPicking)
	{
		curPick.PlayUseAnim();
		
		TicksSinceLastPick += LastTickTime*10; //TicksSinceLastPick += (Level.TimeSeconds - LastTickTime) * 10;
	  	LastTickTime = 0; //Level.TimeSeconds
      		//TicksSinceLastPick = TicksSinceLastPick + 1;
      		while (TicksSinceLastPick > TicksPerPick && numPicks > 0)
      		{
         		numPicks--;
         		lockStrength -= CurPick.GetPickPotency() * 0.01 * ((int(bAltPicking)*2)+1);
         		TicksSinceLastPick = TicksSinceLastPick - TicksPerPick;      
         		lockStrength = FClamp(lockStrength, 0.0, 1.0);
      		}
		
		// pick all like-tagged movers at once (for double doors and such)
		if ((Tag != '') && (Tag != 'DeusExMover'))
			foreach AllActors(class'DeusExMover', M, Tag)
				if (M != Self)
					M.lockStrength = lockStrength;

		// did we unlock it?
		if (lockStrength < 0.01)
		{
			lockStrength = 0.0;
			bLocked = False;
         		TimeSinceReset = 0.0;

			// unlock all like-tagged movers at once (for double doors and such)
			if ((Tag != '') && (Tag != 'DeusExMover'))
				foreach AllActors(class'DeusExMover', M, Tag)
					if (M != Self)
					{
						M.bLocked = False;
						M.TimeSinceReset = 0;
						M.lockStrength = 0.0;
					}

			pickPlayer.ClientMessage(msgLockpickSuccess);
			StopPicking();
		}

		// are we done with this pick?
		else if (numPicks <= 0)
		{
			StopPicking();
		}

		// check to see if we've moved too far away from the door to continue
		else if (pickPlayer.frobTarget != Self)
		{
			StopPicking();
		}

		// check to see if we've put the lockpick away
		else if (pickPlayer.inHand != curPick)
			StopPicking();
	}
}

//
// Called to deal with resetting the device
//
function Tick(float deltaTime)
{
	if (bPicking) LastTickTime += deltaTime;
	
	if (!bMaddersSetup)
	{
		VMDApplySpecialDoorStats();
	}
	
   	TimeSinceReset = TimeSinceReset + deltaTime;
   	//only reset in multiplayer, if we aren't picking it, and if it has been completely unlocked
   	if ((!bPicking) && (Level.NetMode != NM_Standalone) && (lockStrength == 0.0) && !(bLocked))
   	{
      		if (TimeSinceReset > TimeToReset)
      		{
         		lockStrength = initiallockStrength;
         		TimeSinceReset = 0.0;
         		if (lockStrength > 0)
		 	{
			 	//Force door closed and locked appropriately.
			 	DoClose();
			 	bLocked = bInitialLocked;
		 	}
      		}
   	}
   	// In multi, force it closed if locked.  Keep trying until it closes.
   	if ((Level.NetMode != NM_Standalone) && (bLocked) && (KeyNum != 0))
	   	DoClose();
   	Super.Tick(deltaTime);
}

//
// Stops the current pick-in-progress
//
function StopPicking()
{
	if (PickPlayer != None)
	{
		PickPlayer.AIEndEvent('MegaFutz', EAITYPE_Visual);
	}
	bPicking = False;
	if (curPick != None)
	{
		curPick.StopUseAnim();
		curPick.bBeingUsed = False;
		curPick.UseOnce();
	}
	curPick = None;
	SetTimer(0.1, False);
}

//
// The main logic function for doors
//
function Frob(Actor Frobber, Inventory frobWith)
{
	local bool bOpenIt, bDone;
	local int DrawKeyring, DrawCrowbar, DrawLockpick;
	local float dotp, GSpeed;
	local string msg, GotKeyName;
	local Vector X, Y, Z;
	local DeusExMover M;
	local DeusExPlayer Player;
	local Pawn P;
	local VMDBufferPlayer VMP;

	// if we shouldn't be frobbed, get out
	//MADDERS: Don't let hidden, locked doors be frobbed.
	//1/24/21: This is not good for new players.
	if (!bFrobbable)
		return;
	
	// if we are destroyed, don't do anything
	if (bDestroyed)
		return;
	
	//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if ((bFrobbable) && (!bHighlight))
	{
		bHighlight = true;
	}
	
	if (DeusExPlayer(Frobber) != None)
	{
		bLockRevealed = true;
	}
	
	// make sure we frob our leader if we are a slave
	if (bSlave)
	{
		if (Leader != None)
		{
			Leader.Frob(Frobber, frobWith);
		}
	}
	
	P = Pawn(Frobber);
	Player = DeusExPlayer(P);
	VMP = VMDBufferPlayer(P);
	bOpenIt = False;
	bDone = False;
	msg = msgLocked;
	
	// make sure someone is trying to open the door
	if (P == None)
		return;
	
	// ugly hack, so animals can't open doors
	if (P.IsA('Animal'))
		return;
	
	// Let any non-player pawn open any door for now
	if (Player == None)
	{
		bOpenIt = True;
		msg = "";
		bDone = True;
	}
	
	// If we are already trying to pick it, print a message
	if (bPicking)
	{
		if ((FrobWith != None) && (!bAltPicking))
		{
			NumPicks = int((float(NumPicks) / 3) + 0.99);
			PickTime /= 3;
			bAltPicking = true;
			bDone = true;
			msg = RushMessage;
		}
		else
		{
			msg = msgPicking;
			bDone = True;
		}
	}
	
	// If the door is not closed, it can always be closed no matter what
	if ((KeyNum != 0) || (PrevKeyNum != 0))
	{
		bOpenIt = True;
		msg = "";
		bDone = True;
	}
	
	// check to see if this is a one-way door
	if ((!bDone) && (bOneWay))
	{
		GetAxes(Rotation, X, Y, Z);
		dotp = (Location - Frobber.Location) dot X;

		// if we're on the wrong side of the door, then don't open
		if (dotp > 0.0)
		{
			bOpenIt = False;
			msg = msgOneWayFail;
			bDone = True;
		}
	}
	
	//
	// If the door is locked, the player must do one of the following to open it
	// without triggers or explosions:
	// 1. Use the KeyIDNeeded 
	// 2. Use the Lockpick and SkillLockpicking
	//
	if (!bDone)
	{
		// Get what's in the player's hand
		if (frobWith != None)
		{
			// check for the use of lockpicks
			if ((bPickable) && (frobWith.IsA('Lockpick')) && (Player.SkillSystem != None))
			{
				if (bLocked)
				{
					//MADDERS: Lockpicks can now start silently with the augment "sleight of hand".
					if ((VMDBufferPlayer(Player) == None) || (!VMDBufferPlayer(Player).HasSkillAugment('LockpickStartStealth')))
					{
						// alert NPCs that I'm messing with stuff
						Frobber.AIStartEvent('MegaFutz', EAITYPE_Visual);
					}
					pickValue = Player.SkillSystem.GetSkillLevelValue(class'SkillLockpicking');
					pickPlayer = Player;
					
					//MADDERS: Use this for indexing the seed.
					TimesPicked++;
					curPick = LockPick(frobWith);
					curPick.bBeingUsed = True;
					curPick.PlayUseAnim();
					CurPick.LastMover = Self;
					bPicking = True;
               				//DEUS_EX AMSD In multiplayer, slow it down further at low skill levels
               				numPicks = VMDGenerateNumPicks(); //(50 + Rand(102)); //PickValue * 
					PickTime = VMDGeneratePickTime(); //Default.PickTime * (0.5 + Frand());
               				if (Level.Netmode != NM_Standalone)
                  				pickTime = default.pickTime / (pickValue * pickValue);
               				TicksPerPick = (PickTime * 10.0) / numPicks;
			   		LastTickTime = 0; //LastTickTime = Level.TimeSeconds;
               				TicksSinceLastPick = 0;
					SetTimer(0.1, True);
					
					if (bAltPicking) msg = RushMessage;
					else msg = msgPicking;
				}
				else
				{
					msg = msgAlreadyUnlocked;
				}
			}
			else if ((KeyIDNeeded != '') && (frobWith.IsA('NanoKeyRing')) && (lockStrength > 0.0))
			{
				// check for the correct key use
				NanoKeyRing(frobWith).PlayUseAnim();
				if (NanoKeyRing(frobWith).HasKey(KeyIDNeeded))
				{
					bLocked = !bLocked;		// toggle the lock state
					TimeSinceReset = 0;

					// toggle the lock state for all like-tagged movers at once (for double doors and such)
					if ((Tag != '') && (Tag != 'DeusExMover'))
					{
						foreach AllActors(class'DeusExMover', M, Tag)
						{
							if (M != Self)
							{
								M.bLocked = !M.bLocked;
								M.TimeSinceReset = 0;
							}
						}
					}
					
					//MADDERS, 8/8/23: Give feedback on which key we used to open the door.
					GotKeyName = NanoKeyRing(FrobWith).VMDGetKeyName(KeyIDNeeded);
					if (GotKeyName == "") GotKeyName = "a key";
					GotKeyName = CAPS(Left(GotKeyName, 1)) $ Right(GotKeyName, Len(GotKeyName)-1);
					
					bOpenIt = False;
					if (bLocked)
					{
						msg = SprintF(msgKeyLocked, GotKeyName);
					}
					else
					{
						msg = SprintF(msgKeyUnlocked, GotKeyName);
					}
				}
				else if (bLocked)
				{
					bOpenIt = False;
					msg = msgNoNanoKey;
				}
				else
				{
					msg = msgAlreadyUnlocked;
				}
			}
			else if (!bLocked)
			{
				bOpenIt = True;
				msg = "";
			}
		}
		else if ((bLocked) && (VMP != None) && (VMP.InHand == None) && (VMP.InHandPending == None))
		{
			DrawKeyring = VMP.VMDShouldDrawKeyring(Self);
			if (DrawKeyring == 0)
			{
				DrawCrowbar = VMP.VMDShouldDrawCrowbar(Self);
				if (DrawCrowbar == 0)
				{
					DrawLockpick = VMP.VMDShouldDrawLockpick(Self);
				}
			}
			
			if (DrawKeyring > 0 || DrawCrowbar > 0 || DrawLockpick > 0)
			{
				if (DrawKeyring == 2)
				{
					VMP.PutInHand(VMP.FindInventoryType(class'NanoKeyring'));
				}
				else if (DrawCrowbar == 2)
				{
					VMP.PutInHand(VMP.FindInventoryType(class'WeaponCrowbar'));
				}
				else if (DrawLockpick == 2)
				{
					VMP.PutInHand(VMP.FindInventoryType(class'Lockpick'));
				}
				Msg = "";
			}
		}
		else if (!bLocked)
		{
			bOpenIt = True;
			msg = "";
		}
	}
	
	// give the player a message
	if ((Player != None) && (msg != ""))
		Player.ClientMessage(msg);
	
	// open it!
	if (bOpenIt)
	{
		Super.Frob(Frobber, frobWith);
		Trigger(Frobber, P);
		
		// trigger all like-tagged movers at once (for double doors and such)
		if ((Tag != '') && (Tag != 'DeusExMover'))
			foreach AllActors(class'DeusExMover', M, Tag)
				if (M != Self)
					M.Trigger(Frobber, P);
		
		// Transcended - Alert AI.
		if ((Human(Frobber) != None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Human(Frobber), "Door Noise")))
		{
			Instigator = Pawn(Frobber);
			if (OpeningSound != None || MoveAmbientSound != None || ClosingSound != None)
				AISendEvent( 'LoudNoise', EAITYPE_Audio,, 128 );		
			AIStartEvent('LoudNoise', EAITYPE_Visual);
		}
	}
	else if ((bLocked) && (VMDIsSoftDoor()) && (FrobWith == None))
	{
		//MADDERS: Fucking with a locked door generates noise.
		//Update: We can have a skill augment to negate this.
		if ((VMDBufferPlayer(Frobber) == None) || (!VMDBufferPlayer(Frobber).HasSkillAugment('LockpickStartStealth')))
		{
			AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 400);
			PlaySound(Sound'TileStep2',,,,, GSpeed);
		}
	}
}

function DoOpen()
{
	local DeusExMover M;
	
	if (bDestroyed)
		return;
	
	if (Level.NetMode != NM_Standalone)
	{
		// In multiplayer, unlock doors that get opened.
		// toggle the lock state for all like-tagged movers at once (for double doors and such)
		bLocked = false;
		TimeSinceReset = 0;
		lockStrength = 0.0;
		if ((Tag != '') && (Tag != 'DeusExMover'))
			foreach AllActors(class'DeusExMover', M, Tag)
			if (M != Self)
			{
				M.bLocked = false;
				M.TimeSinceReset = 0;
				M.lockStrength = 0;
			}
	}
	Super.DoOpen();
}

// Close the mover.
function DoClose()
{
	if (!bDestroyed)
		Super.DoClose();
}

//
// make sure we can't be triggered after we've been destroyed
//
state() TriggerOpenTimed
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!bDestroyed)
			Super.Trigger(Other, EventInstigator);
	}
}

state() TriggerToggle
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!bDestroyed)
			Super.Trigger(Other, EventInstigator);
	}
}

state() TriggerControl
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!bDestroyed)
			Super.Trigger(Other, EventInstigator);
	}
}

state() TriggerPound
{
	function Trigger( actor Other, pawn EventInstigator )
	{
		if (!bDestroyed)
			Super.Trigger(Other, EventInstigator);
	}
}

// Return true to abort, false to continue.
function bool EncroachingOn( actor Other )
{
	local float GSpeed;
	local Pawn P;
	
	if ( Other.IsA('Carcass') || Other.IsA('Decoration') )
	{
		Other.TakeDamage(10000, None, Other.Location, vect(0,0,0), 'Crushed');
		return false;
	}
	// DEUS_EX CNN - Don't destroy inventory items when encroached!
//	if ( Other.IsA('Fragment') || (Other.IsA('Inventory') && (Other.Owner == None)) )
	if (Other.IsA('Fragment'))
	{
		Other.Destroy();
		return false;
	}

	// DEUS_EX CNN - make based actors not stop movers
	if (Other.Base == Self)
	{
		return False;
	}
	
	//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	// Damage the encroached actor.
	if( EncroachDamage != 0 )
		Other.TakeDamage( EncroachDamage, Instigator, Other.Location, vect(0,0,0), 'Crushed' );

	// If we have a bump-player event, and Other is a pawn, do the bump thing.
	P = Pawn(Other);
	if( P!=None && P.bIsPlayer )
	{
		if ( PlayerBumpEvent!='' )
			Bump( Other );
		if ( (MyMarker != None) && (P.Base != self) 
			&& (P.Location.Z < MyMarker.Location.Z - P.CollisionHeight - 0.7 * MyMarker.CollisionHeight) )
			// pawn is under lift - tell him to move
			P.UnderLift(self);
	}

	// Stop, return, or whatever.
	if( MoverEncroachType == ME_StopWhenEncroach )
	{
		Leader.MakeGroupStop();
		return true;
	}
	else if( MoverEncroachType == ME_ReturnWhenEncroach )
	{
		Leader.MakeGroupReturn();
		if ( Other.IsA('Pawn') && Pawn(Other).Health > 0)	// Transcended - Fixed the player making the sound while dead.
		{
			if ( Pawn(Other).bIsPlayer)
				Pawn(Other).PlaySound(Pawn(Other).Land, SLOT_None,,,, GSpeed);			// DEUS_EX CNN - Changed from SLOT_Talk
			else
				Pawn(Other).PlaySound(Pawn(Other).HitSound1, SLOT_None,,,, GSpeed);	// DEUS_EX CNN - Changed from SLOT_Talk
		}	
		return true;
	}
	else if( MoverEncroachType == ME_CrushWhenEncroach )
	{
		// Kill it.
		Other.KilledBy( Instigator );
		return false;
	}
	else if( MoverEncroachType == ME_IgnoreWhenEncroach )
	{
		// Ignore it.
		return false;
	}
}

defaultproperties
{
     RushMessage="Rushing pick attempt..."
     bDamageRevealed=False
     bLockRevealed=False
     
     bPickable=True
     lockStrength=0.200000
     doorStrength=0.250000
     bHighlight=True
     bFrobbable=True
     pickTime=2.750000
     minDamageThreshold=10
     NumFragments=16
     FragmentScale=2.000000
     FragmentSpread=32
     FragmentClass=Class'DeusEx.WoodFragment'
     ExplodeSound1=Sound'DeusExSounds.Generic.WoodBreakSmall'
     ExplodeSound2=Sound'DeusExSounds.Generic.WoodBreakLarge'
     TimeToReset=28.000000
     msgKeyLocked="%d on your Nanokey Ring locked it"
     msgKeyUnlocked="%d on your Nanokey Ring unlocked it"
     msgLockpickSuccess="You picked the lock"
     msgOneWayFail="It won't open from this side"
     msgLocked="It's locked"
     msgPicking="Picking the lock..."
     msgAlreadyUnlocked="It's already unlocked"
     msgNoNanoKey="Your NanoKey Ring doesn't have the right code"
     MoverEncroachType=ME_StopWhenEncroach
     BumpType=BT_PawnBump
     bBlockSight=True
     InitialState=TriggerToggle
     bDirectional=True
}
