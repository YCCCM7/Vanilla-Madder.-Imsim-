//=============================================================================
// GrayRoller.
//=============================================================================
class GrayRoller extends Animal;

#exec OBJ LOAD FILE=Ambient

var float damageRadius;
var float damageInterval;
var float damageAmount;
var float damageTime;

function Carcass SpawnCarcass()
{
	local Carcass TCarc;
	
	if (bStunned)
	{
		TCarc = Super.SpawnCarcass();
		if (TCarc != None)
		{
		 TCarc.Multiskins[0] = Multiskins[0];
		 TCarc.Multiskins[2] = Multiskins[2];
		}
	}
	else
	{
	 Explode();
	 return None;
	}
	
	return TCarc;
}

//Justice: Make this behave just like a real robot. 4/11/09
function Explode(optional vector HL)
{
	local SphereEffect sphere;
	local ScorchMark s;
	local ExplosionLight light;
	local int i;
	local float explosionDamage;
	local float explosionRadius;

	explosionDamage = 100;
	explosionRadius = 256;

	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, Location);
	if (light != None)
		light.size = 4;

	Spawn(class'ExplosionSmall',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, Location + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, Location + 2*VRand()*CollisionRadius);

	sphere = Spawn(class'SphereEffect',,, Location);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;

	// spawn a mark
	s = spawn(class'ScorchMark', Base,, Location-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}

	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,Location);
		else
			spawn(class'FleshFragment',,,Location);
	}

	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, Location);
}

// check every damageInterval seconds and damage any player near the gray
function Tick(float deltaTime)
{
	local DeusExPlayer player;

	damageTime += deltaTime;

	if (damageTime >= damageInterval)
	{
		damageTime = 0;
		foreach VisibleActors(class'DeusExPlayer', player, damageRadius)
			if (player != None)
				player.TakeDamage(damageAmount, Self, player.Location, vect(0,0,0), 'Radiation');
	}

	Super.Tick(deltaTime);
}

function ComputeFallDirection(float totalTime, int numFrames,
                              out vector moveDir, out float stopTime)
{
	// Determine direction, and how long to slide
	if (AnimSequence == 'DeathFront')
	{
		moveDir = Vector(DesiredRotation) * Default.CollisionRadius*2.0;
		stopTime = totalTime*0.7;
	}
	else if (AnimSequence == 'DeathBack')
	{
		moveDir = -Vector(DesiredRotation) * Default.CollisionRadius*1.8;
		stopTime = totalTime*0.65;
	}
}

function bool FilterDamageType(Pawn instigatedBy, Vector hitLocation,
                               Vector offset, Name damageType)
{
	// Grays aren't affected by radiation or fire or gas
	if ((damageType == 'Radiation') || (damageType == 'Flamed') || (damageType == 'Burned'))
		return false;
	else if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage'))
		return false;
	else
		return Super.FilterDamageType(instigatedBy, hitLocation, offset, damageType);
}

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	else if (damageType == 'Stunned')
		GotoNextState();
	else if (CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

function TweenToAttack(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) TweenAnimPivot('Tread', tweentime, GetSwimPivot());
	}
	else
	{
		if (HasAnim('Attack')) TweenAnimPivot('Attack', tweentime);
	}
}

function PlayAttack()
{
	if ((Weapon != None) && Weapon.IsA('WeaponGraySpit'))
	{
		if (HasAnim('Shoot')) PlayAnimPivot('Shoot');
	}
	else
	{
		if (HasAnim('Attack')) PlayAnimPivot('Attack');
	}
}

function PlayPanicRunning()
{
	PlayRunning();
}

function PlayTurning()
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) LoopAnimPivot('Tread',,,, GetSwimPivot());
	}
	else
	{
		if (HasAnim('Walk')) LoopAnimPivot('Walk', 0.1);
	}
}

function TweenToWalking(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) TweenAnimPivot('Tread', tweentime, GetSwimPivot());
	}
	else
	{
		if (HasAnim('Walk')) TweenAnimPivot('Walk', tweentime);
	}
}

function PlayWalking()
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) LoopAnimPivot('Tread',,,, GetSwimPivot());
	}
	else
	{
		if (HasAnim('Walk')) LoopAnimPivot('Walk', , 0.15);
	}
}

function TweenToRunning(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) TweenAnimPivot('Tread', tweentime, GetSwimPivot());
	}
	else
	{
		if (HasAnim('Run')) LoopAnimPivot('Run',, tweentime);
	}
}

function PlayRunning()
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) LoopAnimPivot('Tread',,,, GetSwimPivot());
	}
	else
	{
		if (HasAnim('Run')) LoopAnimPivot('Run');
	}
}
function TweenToWaiting(float tweentime)
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) TweenAnimPivot('Tread', tweentime, GetSwimPivot());
	}
	else
	{
		if (HasAnim('BreatheLight')) TweenAnimPivot('BreatheLight', tweentime);
	}
}
function PlayWaiting()
{
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('Tread')) LoopAnimPivot('Tread',,,, GetSwimPivot());
	}
	else
	{
		if (HasAnim('BreatheLight')) LoopAnimPivot('BreatheLight', , 0.3);
	}
}

function PlayTakingHit(EHitLocation hitPos)
{
	local vector pivot;
	local name   animName;

	animName = '';
	if (!Region.Zone.bWaterZone)
	{
		switch (hitPos)
		{
			case HITLOC_HeadFront:
			case HITLOC_TorsoFront:
			case HITLOC_LeftArmFront:
			case HITLOC_RightArmFront:
			case HITLOC_LeftLegFront:
			case HITLOC_RightLegFront:
				animName = 'HitFront';
				break;

			case HITLOC_HeadBack:
			case HITLOC_TorsoBack:
			case HITLOC_LeftArmBack:
			case HITLOC_RightArmBack:
			case HITLOC_LeftLegBack:
			case HITLOC_RightLegBack:
				animName = 'HitBack';
				break;
		}
		pivot = vect(0,0,0);
	}

	if (animName != '' && HasAnim(AnimName))
		PlayAnimPivot(animName, , 0.1, pivot);
}

// sound functions
function PlayIdleSound()
{
	if (FRand() < 0.5)
		PlaySound(sound'GrayIdle', SLOT_None);
	else
		PlaySound(sound'GrayIdle2', SLOT_None);
}

function PlayScanningSound()
{
	if (FRand() < 0.3)
	{
		if (FRand() < 0.5)
			PlaySound(sound'GrayIdle', SLOT_None);
		else
			PlaySound(sound'GrayIdle2', SLOT_None);
	}
}

function PlayTargetAcquiredSound()
{
	PlaySound(sound'GrayAlert', SLOT_None);
}

function PlayCriticalDamageSound()
{
	PlaySound(sound'GrayFlee', SLOT_None);
}

defaultproperties
{
     HitBoxArchetype="Gray"

     DamageRadius=256.000000
     damageInterval=1.000000
     DamageAmount=10.000000
     bPlayDying=True
     MinHealth=10.000000
     CarcassType=Class'DeusEx.GrayCarcass'
     WalkingSpeed=0.280000
     bCanBleed=True
     CloseCombatMult=0.500000
     ShadowScale=0.750000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponGraySwipeRoller')
     //InitialInventory(1)=(Inventory=Class'DeusEx.WeaponGraySpit')
     //InitialInventory(2)=(Inventory=Class'DeusEx.AmmoGraySpit',Count=9999)
     WalkSound=Sound'DeusExSounds.Animal.GrayFootstep'
     GroundSpeed=350.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=500.000000
     BaseEyeHeight=25.000000
     Health=400
     ReducedDamageType=Radiation
     ReducedDamagePct=1.000000
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     //HitSound1=Sound'DeusExSounds.Animal.GrayPainSmall'
     //HitSound2=Sound'DeusExSounds.Animal.GrayPainLarge'
     //Die=Sound'DeusExSounds.Animal.GrayDeath'
     HitSound1=Sound'DeusExSounds.Generic.Spark1'
     HitSound2=Sound'DeusExSounds.Generic.Spark1'
     Die=Sound'DeusExSounds.Generic.Spark1'
     Alliance=Gray
     DrawType=DT_Mesh
     //Mesh=LodMesh'DeusExCharacters.Gray'
     Mesh=LodMesh'DeusExCharacters.SecurityBot4'
     AmbientGlow=12
     SoundRadius=14
     SoundVolume=255
     AmbientSound=Sound'Ambient.Ambient.GeigerLoop'
     //CollisionRadius=28.540001
     //CollisionHeight=36.000000
     CollisionRadius=27.500000
     CollisionHeight=28.500000
     LightType=LT_Steady
     LightBrightness=32
     LightHue=96
     LightSaturation=128
     LightRadius=5
     Mass=120.000000
     Buoyancy=97.000000
     BindName="Gray"
     FamiliarName="Gray"
     UnfamiliarName="Gray"
}
