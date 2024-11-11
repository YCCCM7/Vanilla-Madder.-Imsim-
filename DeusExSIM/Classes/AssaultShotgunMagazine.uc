//=============================================================================
// AssaultShotgunMagazine.
//=============================================================================
class AssaultShotgunMagazine extends VMDWeaponMagazine;

var bool bFirstTween;

function InitDropBy(Pawn Dropper)
{
	bHidden = true;
	
	Mesh = Fragments[Rand(NumFragmentTypes)];
	
	if ((Mesh != None) && (PlayerPawn(Dropper) == None || PlayerPawn(Dropper).bBehindView))
	{
		bHidden = false;
	}
	
	PlayAnim('Drop');
}

simulated function HitWall (vector HitNormal, actor HitWall)
{
	local Sound sound;
	local float volume, radius;
	
	if (HitNormal.Z != 0)
	{
		if (bHidden)
		{
			bHidden = false;
		}
		
		if (!bFirstTween)
		{
			bFirstTween = True;
			PlayAnim('Land');
		}
	}
	
	// if we are stuck, stop moving
	if (lastHitLoc == Location)
	{
		Velocity = vect(0,0,0);
	}
	else
	{
		Velocity = Elasticity*(( Velocity dot HitNormal ) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	}
	
	speed = VSize(Velocity);
	
	if ((speed < 60 && HitNormal.Z > 0.7) || speed == 0)
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
	{
		sound = ImpactSound;
	}
	else
	{
		sound = MiscSound;
	}
	
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
	}
}

auto state Flying
{
	simulated singular function ZoneChange(ZoneInfo NewZone)
	{
		local float splashsize;
		local actor splash;
		
		if (NewZone.bWaterZone)
		{
			Velocity = 0.2 * Velocity;
			splashSize = 0.0005 * (250 - 0.5 * Velocity.Z);
			if (Level.NetMode != NM_DedicatedServer)
			{
				if (NewZone.EntrySound != None)
				{
					PlaySound(NewZone.EntrySound, SLOT_Interact, splashSize);
				}
				if (NewZone.EntryActor != None)
				{
					splash = Spawn(NewZone.EntryActor); 
					if (splash != None)
					{
						splash.DrawScale = 4 * splashSize;
					}
				}
			}
			if (bFirstHit) 
			{
				bFirstHit = False;
				bRotatetoDesired = False;
				bFixedRotationDir = False;
			}
			
			GotoState('Dying');
		}
		if ((NewZone.bPainZone) && (NewZone.DamagePerSec > 0))
		{
			Destroy();
		}
	}
	simulated function BeginState()
	{			
		SetTimer(5.0,True);			
	}
}

defaultproperties
{
     bFixedRotationDir=False
     Elasticity=0.000000
     Mesh=LODMesh'VMDAssaultShotgunMag01'
     Fragments(0)=LODMesh'VMDAssaultShotgunMag01'
     Fragments(1)=LODMesh'VMDAssaultShotgunMag02'
     Fragments(2)=LODMesh'VMDAssaultShotgunMag03'
     NumFragmentTypes=1
     CollisionRadius=11.000000
     CollisionHeight=5.000000 //2 * 0.75
}
