//=============================================================================
// SpyDrone.
//=============================================================================
class SpyDrone extends ThrownProjectile;

//MADDERS, 6/21/24: Have our guys trace back where the drone came from.
var Vector LastSuspicionLocations[8];
var Pawn IgnoringPawns[32];

function Vector GetSuspicionLocation(Pawn Checker)
{
	local int i;
	local Vector Ret, BlankHack;
	
	//Find the furthest recorded location. If none exists, assume we're still at our player and return our location instead.
	for(i=ArrayCount(LastSuspicionLocations)-1; i>=0; i--)
	{
		if (LastSuspicionLocations[i] != BlankHack)
		{
			Ret = LastSuspicionLocations[i];
			break;
		}
	}
	if (Ret == BlankHack)
	{
		Ret = Location;
	}
	
	//If we're hovering at about the same height, try to make it walkable. If we flew it from above, MAYBE this will get us a better location.
	if ((Checker != None) && (Abs(LastSuspicionLocations[i].Z - Checker.Location.Z) < 128))
	{
		Ret.Z = Checker.Location.Z;
	}
	
	return Ret;
}

function AddSuspicionLocation(Vector NewLoc)
{
	local int i;
	
	for(i=ArrayCount(LastSuspicionLocations)-1; i>=0; i--)
	{
		if (i > 0)
		{
			LastSuspicionLocations[i] = LastSuspicionLocations[i-1];
		}
		else
		{
			LastSuspicionLocations[i] = NewLoc;
		}
	}
}

function AddIgnorePawn(Pawn NewPawn)
{
	local int i;
	
	for(i=0; i<ArrayCount(IgnoringPawns); i++)
	{
		if (IgnoringPawns[i] == None)
		{
			IgnoringPawns[i] = NewPawn;
			break;
		}
	}
}

function bool PawnShouldIgnore(Pawn CheckPawn)
{
	local int i;
	
	for(i=0; i<ArrayCount(IgnoringPawns); i++)
	{
		if (IgnoringPawns[i] == CheckPawn)
		{
			return true;
		}
	}
	
	return false;
}

auto state Flying
{
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		// do nothing
	}
	simulated function HitWall (vector HitNormal, actor HitWall)
	{
		// do nothing
	}
}

function Tick(float deltaTime)
{
	local Vector BlankHack;
	
	//MADDERS, 6/21/24: Actually do something. In this case, record our locations as we travel.
	if (LastSuspicionLocations[0] == BlankHack || VSize(LastSuspicionLocations[0] - Location) > 176)
	{
		AddSuspicionLocation(Location);
	}
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector HitLocation, Vector Momentum, name damageType)
{
	// fall to the ground if EMP'ed
	if ((DamageType == 'EMP') && (!bDisabled))
	{
		bEmitDanger = False;
		SetPhysics(PHYS_Falling);
		bBounce = True;
		LifeSpan = 10.0;
		AmbientSound = None;
	}
	
	//Transcended - Removed
	//if ( Level.NetMode != NM_Standalone )
	//{
		if (DeusExPlayer(Owner) != None)
		{
			DeusExPlayer(Owner).ForceDroneOff();
		}
		else
		{
			log("Warning: Drone with no owner?");
		}
	//}
	
	Super.TakeDamage(Damage, instigatedBy, HitLocation, Momentum, damageType);
}

function BeginPlay()
{
	local AugLight AL;
	local AugmentationManager AS;
	
	// do nothing
	//--------
	//MADDERS, 9/18/22: LolJK.
	if (DeusExPlayer(Owner) != None)
	{
		//MADDERS, 9/18/22: Hack for rebooting flashlight if we deployed drone post-flashlight.
		AS = DeusExPlayer(Owner).AugmentationSystem;
		if (AS != None)
		{
			AL = AugLight(AS.FindAugmentation(class'AugLight'));
			if ((AL != None) && (AL.bIsActive))
			{
				AL.VMDSpawnDroneLight(Self);
			}
		}
	}
}

function Destroyed()
{
	if ( DeusExPlayer(Owner) != None )
	{
		DeusExPlayer(Owner).aDrone = None;
		DeusExPlayer(Owner).ForceDroneOff();
	}

	Super.Destroyed();
}

//MADDERS: Copied from ScriptedPawn, so we can't be used to stack actors... Such as the player.
function SupportActor(Actor standingActor)
{
	local vector newVelocity;
	local float  angle;
	local float  zVelocity;
	local float  baseMass;
	local float  standingMass;
	local vector damagePoint;
	local float  damage;
	
	standingMass = FMax(1, standingActor.Mass);
	baseMass     = FMax(1, Mass);
	
	zVelocity    = standingActor.Velocity.Z;
	damagePoint  = Location + vect(0,0,1)*(CollisionHeight-1);
	damage       = (1 - (standingMass/baseMass) * (zVelocity/100));
	
	// Have we been stomped?
	if ((zVelocity*standingMass < -7500) && (damage > 0))
		TakeDamage(damage, standingActor.Instigator, damagePoint, 0.2*standingActor.Velocity, 'stomped');
	
	// Bounce the actor off the pawn
	angle = FRand()*Pi*2;
	newVelocity.X = cos(angle);
	newVelocity.Y = sin(angle);
	newVelocity.Z = 0;
	newVelocity *= FRand()*25 + 25;
	newVelocity += standingActor.Velocity;
	newVelocity.Z = 50;
	standingActor.Velocity = newVelocity;
	standingActor.SetPhysics(PHYS_Falling);
}

defaultproperties
{
     elasticity=0.200000
     fuseLength=0.000000
     proxRadius=128.000000
     bHighlight=False
     bBlood=False
     bDebris=False
     blastRadius=128.000000
     DamageType=EMP
     bEmitDanger=True
     ItemName="Remote Spy Drone"
     MaxSpeed=0.000000
     Damage=20.000000
     ImpactSound=Sound'DeusExSounds.Generic.SmallExplosion2'
     Physics=PHYS_Projectile
     RemoteRole=ROLE_DumbProxy
     LifeSpan=0.000000
     Mesh=LodMesh'TranscendedModels.TransSpyDrone'
     SoundRadius=24
     SoundVolume=192
     AmbientSound=Sound'DeusExSounds.Augmentation.AugDroneLoop'
     CollisionRadius=13.000000
     CollisionHeight=2.760000
     Mass=10.000000
     Buoyancy=2.000000
}
