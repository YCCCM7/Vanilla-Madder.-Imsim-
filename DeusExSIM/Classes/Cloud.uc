//=============================================================================
// Cloud.
//=============================================================================
class Cloud extends DeusExProjectile;

var bool bFloating;
var float cloudRadius;
var float damageInterval;
var vector CloudLocation; //to make sure location is updated w/o making it dumb proxy

//MADDERS additions.
var Pawn HitPawns[8];
var bool bLethalCloud;

replication 
{
	reliable if ( Role == ROLE_Authority )
		CloudLocation;
}

auto simulated state Flying
{
	function HitWall(vector HitNormal, actor Wall)
	{
		// do nothing
		Velocity = vect(0,0,0);
	}
	function ProcessTouch (Actor Other, Vector HitLocation)
	{
		// do nothing
	}
}

event ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);

	// clouds can't live underwater, so kill us quickly if we enter the water
	if ((NewZone.bWaterZone) && (LifeSpan > 2.0))
		LifeSpan = 2.0;
}

function Timer()
{
	local Actor A;
	local Vector offset, dist;
	local Pawn apawn;

	if ( Level.NetMode != NM_Standalone )
	{
		// Use PawnList for multiplayer
		apawn = Level.PawnList;
		while ( apawn != None )
		{
			dist = apawn.Location - Location;
			if ( VSize(dist) < cloudRadius )
			{
				offset = apawn.Location;
				apawn.TakeDamage( Damage, Instigator, offset, vect(0,0,0), damageType );														  
			}
			apawn = apawn.nextPawn;
		}
	}
	else
	{
		// check to see if anything has entered our effect radius
		// don't damage our owner
		foreach VisibleActors(class'Actor', A, cloudRadius)
		{
			if (A != Owner || (DamageType == 'HalonGas' && DeusExPlayer(Owner) != None))
			{
				if (ShouldHurtActor(A))
				{
					// be sure to damage the torso
					offset = A.Location;
					if ((DamageType == 'HalonGas') && (A == Owner))
					{
						A.TakeDamage(Damage, Instigator, offset, vect(0,0,0), 'OwnedHalonGas');
					}
					else
					{
						A.TakeDamage(Damage, Instigator, offset, vect(0,0,0), damageType);
					}
				}
				AddHitPawn(Pawn(A));
			}
		}
	}
}

function bool ShouldHurtActor(Actor A)
{
	//MADDERS, 6/22/24: Stop destroying casings and magazines with tear gas lol.
	if (Fragment(A) != None) return false;
	
	if (Pawn(A) == None || !bLethalCloud) return true;
	
	if (HasHitPawn(Pawn(A))) return false;
	if ((A.IsInState('RubbingEyes')) && (FRand() < 0.8))
	{
		return false;
	}
	return true;
}

function AddHitPawn(Pawn P)
{
	local int i;
	
	if (P == None || HasHitPawn(P)) return;
	
	for(i=0; i<ArrayCount(HitPawns); i++)
	{
		if (HitPawns[i] == None || i == 7)
		{
			HitPawns[i] = P;
			break;
		}
	}
}

function bool HasHitPawn(Pawn P)
{
	local int i;
	
	if (P == None) return false;
	
	for(i=0; i<ArrayCount(HitPawns); i++)
	{
		if (P == HitPawns[i])
		{
			return true;
		}
	}
	return false;
}

simulated function Tick(float deltaTime)
{
	local float value;
	local float sizeMult;
   	local float NewDrawScale;

   	if (Role == ROLE_Authority)
      		CloudLocation = Location;
   	else
      		SetLocation(CloudLocation);

	// don't Super.Tick() becuase we don't want gravity to affect the stream
	time += deltaTime;
	
	value = 1.0+time;
	if (MinDrawScale > 0)
		sizeMult = MaxDrawScale/MinDrawScale;
	else
		sizeMult = 1;
	
   	// DEUS_EX AMSD Update drawscale less often in mp, to reduce bandwidth hit.
   	// Effect won't look quite as good for listen server client... but will otherwise
   	// help tremendously (one gas grenade was 3k a sec in traffic).
   	NewDrawScale = (-sizeMult/(value*value) + (sizeMult+1))*MinDrawScale;

	if (Level.Netmode == NM_Standalone)
   	{
      		DrawScale = NewDrawScale;
   	}
   	else if (Level.Netmode == NM_Client)
   	{
      		DrawScale = NewDrawScale;
   	}
   	else if (Level.Netmode == NM_DedicatedServer)
   	{
      		//Do nothing
   	}
   	else
   	{
      		//On a listen server, just start it full size.
      		DrawScale = (-sizeMult/(50*50) + (sizeMult+1))*MinDrawScale;
   	}
	
	//      DrawScale = (-sizeMult/(value*value) + (sizeMult+1))*MinDrawScale;
   	if (Role == ROLE_Authority)	
      		ScaleGlow = FClamp(LifeSpan*0.5, 0.0, 1.0);
	
	// make it swim around a bit at random
	if (bFloating)
	{
		Acceleration = VRand() * 15;
		Acceleration.Z = 0;
	}
}

function BeginPlay()
{
	Super.BeginPlay();
	
	// set the cloud damage timer
	SetTimer(damageInterval, True);
}

defaultproperties
{
     cloudRadius=128.000000
     damageInterval=0.5000000
     blastRadius=1.000000
     DamageType=PoisonGas
     AccurateRange=100
     maxRange=100
     maxDrawScale=5.000000
     bIgnoresNanoDefense=True
     ItemName="Gas Cloud"
     ItemArticle="a"
     speed=300.000000
     MaxSpeed=300.000000
     Damage=1.000000
     MomentumTransfer=100
     LifeSpan=1.000000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=None
     DrawScale=0.010000
     bUnlit=True
     CollisionRadius=16.000000
     CollisionHeight=16.000000
}
