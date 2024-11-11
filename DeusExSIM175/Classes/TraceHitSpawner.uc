//=============================================================================
// TraceHitSpawner class so we can reduce nettraffic for hitspangs
//=============================================================================
class TraceHitSpawner extends Actor;

var float HitDamage;
var bool bPenetrating; // shot that hit was a penetrating shot
var bool bHandToHand;  // shot that hit was hand to hand
var bool bInstantHit;
var Name damageType;

var BulletHole Hole;
var float BulletHoleSize;

//MADDERS: Update our size relative to our override. Yikes.
function VMDAlertDamageChange()
{	
	if (Hole != None)
	{
		Hole.Drawscale = BulletHoleSize;
		Hole.ReattachDecal();
	}
}

simulated function PostBeginPlay()
{
   	Super.PostBeginPlay();
   	
   	if (Owner == None)
	{
      		SetOwner(Level);
	}
	
	// SpawnEffects(Owner,HitDamage);
	// Need the slightest bit of delay to get the correct damageType and HitDamage
	SetTimer(0.01,False);
}

simulated function Timer()
{
	SpawnEffects(Owner,HitDamage);
	Destroy();
}

//
// we have to use an actor to play the hit sound at the correct location
//
simulated function PlayHitSound(actor destActor, Actor hitActor)
{
	local float rnd;
	local sound snd;
	
	// don't ricochet unless it's hit by a bullet
	if ((damageType != 'Shot') && (damageType != 'Sabot'))
		return;
	
	rnd = FRand();
	
	if (rnd < 0.25)
		snd = sound'Ricochet1';
	else if (rnd < 0.5)
		snd = sound'Ricochet2';
	else if (rnd < 0.75)
		snd = sound'Ricochet3';
	else
		snd = sound'Ricochet4';
	
	// play a different ricochet sound if the object isn't damaged by normal bullets
	if (hitActor != None) 
	{
		if (hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10))
			snd = sound'ArmorRicochet';
		else if (hitActor.IsA('Robot'))
			snd = sound'ArmorRicochet';
		else if ((hitActor != Level) && (!hitActor.IsA('DeusExMover'))) //Lork: Prevents sparks and ricochet sounds on normal decorations
		{
			snd = None;
			if (destActor != None)
				destActor.bHidden = True;
		}
	}
	if (destActor != None)
		destActor.PlaySound(snd, SLOT_None,,, 1024, 1.1 - 0.2*FRand());
}

simulated function SpawnEffects(Actor Other, float Damage)
{
	local ParticleGenerator puff;
   	local int i;
   	//local BulletHole hole;
   	local RockChip chip;
   	local Rotator rot;
   	local DeusExMover mov;
	local Spark spark;
	
   	SetTimer(0.1,False);
   	if (Level.NetMode == NM_DedicatedServer)
      		return;
	
	if ((bPenetrating) && (!bHandToHand) && (!Other.IsA('DeusExDecoration')))
	{
		// Every hit gets a puff in multiplayer
		if (Level.NetMode != NM_Standalone)
		{
			puff = spawn(class'ParticleGenerator',,,Location+(Vector(Rotation)*1.5), Rotator((Location+Vector(Rotation)*1.5) - Location));
			if (puff != None)
			{
				puff.particleTexture = FireTexture'Effects.Smoke.SmokePuff1';	
				puff.particleDrawScale = 0.025 + FRand() * 0.025;
				puff.RiseRate = 2.500000;
				puff.ejectSpeed = 2.500000;
				puff.LifeSpan = 2.000000;
				puff.particleLifeSpan = 3.000000;
				puff.checkTime=0.300000;
				puff.bRandomEject = True;
				puff.RemoteRole = ROLE_None;
			}
		}
		else
		{
			if (FRand() < 0.5)
			{
				puff = spawn(class'ParticleGenerator',,,Location+Vector(Rotation),Rotator((Location+Vector(Rotation)) - Location));
				if (puff != None)
				{
					puff.particleTexture = FireTexture'Effects.Smoke.SmokePuff1';	
					puff.particleDrawScale = 0.025 + FRand() * 0.025;
					puff.RiseRate = 2.500000;
					puff.ejectSpeed = 2.500000;
					puff.LifeSpan = 2.000000;
					puff.particleLifeSpan = 3.000000;
					puff.checkTime=0.300000;
					puff.bRandomEject = True;
					puff.RemoteRole = ROLE_None;
				}
			}
		}
     		if (!Other.IsA('DeusExMover'))
		{
         		for (i=0; i<2; i++)
			{
            			if (FRand() < 0.8)
            			{
               				chip = spawn(class'Rockchip',,,Location+Vector(Rotation));
               				if (chip != None)
					{
                  				chip.RemoteRole = ROLE_None;
					}
            			}
			}
		}
	}
	
   	if ((!bHandToHand) && (bInstantHit) && (bPenetrating))
	{
      		hole = spawn(class'BulletHole', Other,, Location+Vector(Rotation), Rotation);
      		if (hole != None)
		{
         		hole.RemoteRole = ROLE_None;
			//hole.DrawScale = 0.00075 * (Sqrt((HitDamage+5)/2));
		}
		
		if ((DeusExPlayer(Other) == None) && (DeusExCarcass(Other) == None) && (ScriptedPawn(Other) == None || Robot(Other) != None)) // Sparks on people look bad
		{
			spark = spawn(class'Spark',,,Location+Vector(Rotation), Rotation);
			if (spark != None)
			{
				spark.RemoteRole = ROLE_None;
				if ( Level.NetMode != NM_Standalone )
					spark.DrawScale = 0.20;
				else
					spark.DrawScale = 0.05;
				PlayHitSound(spark, Other);
			}
		}
	}
	
	// draw the correct damage art for what we hit
	if (bPenetrating || bHandToHand)
	{
		Mov = DeusExMover(Other);
		if (Mov != None)
		{
			if (hole == None)
         		{
            			hole = spawn(class'BulletHole', Other,, Location+Vector(Rotation), Rotation);
            			if (hole != None)
				{
               				hole.remoteRole = ROLE_None;
					//hole.DrawScale = 0.00075 * (Sqrt((HitDamage+5)/2));
				}
         		}
			
			if (hole != None)
			{
				if ((mov.bBreakable) && (mov.minDamageThreshold <= Damage))
				{
					// don't draw damage art on destroyed movers
					if (mov.bDestroyed)
						hole.Destroy();
					else if (mov.FragmentClass == class'GlassFragment')
					{
						// glass hole
						if (FRand() < 0.5)
							hole.Texture = Texture'FlatFXTex29';
						else
							hole.Texture = Texture'FlatFXTex30';
						
						hole.DrawScale = 0.1;
						hole.ReattachDecal();
					}
					else
					{
						// non-glass crack
						if (FRand() < 0.5)
							hole.Texture = Texture'FlatFXTex7';
						else
							hole.Texture = Texture'FlatFXTex8';
						
						hole.DrawScale = 0.25;
						hole.ReattachDecal();
					}
				}
				else
				{
					if (!bPenetrating || bHandToHand)
						hole.Destroy();
				}
			}
		}
	}
}

defaultproperties
{
     HitDamage=-1.000000
     bPenetrating=True
     bInstantHit=True
     RemoteRole=ROLE_None
     DrawType=DT_None
     bGameRelevant=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
