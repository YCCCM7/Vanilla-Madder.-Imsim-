//=============================================================================
// MilitaryBot.
//=============================================================================
class MilitaryBot extends Robot;

enum ESkinColor
{
	SC_UNATCO,
	SC_Chinese
};

var() ESkinColor SkinColor;

var bool bShellSwap;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_UNATCO:		Skin = Texture'MilitaryBotTex1'; break;
		case SC_Chinese:	Skin = Texture'MilitaryBotTex2'; break;
	}
}

function PlayDisabled()
{
	local int rnd;

	rnd = Rand(3);
	if (rnd == 0)
		TweenAnimPivot('Disabled1', 0.2);
	else if (rnd == 1)
		TweenAnimPivot('Disabled2', 0.2);
	else
		TweenAnimPivot('Still', 0.2);
}

function PlayFootStep()
{
	Super.PlayFootStep();
	
	StepOn();
}

function StepOn()
{
	local vector EndTrace, HitLocation, HitNormal;
	local DeusExCarcass hitActor;
	
	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);
	
	foreach TraceVisibleActors(class'DeusExCarcass', hitActor, HitLocation, HitNormal, EndTrace)
	{
		hitActor.TakeDamage(50, self, Location, vect(0,0,0), 'Exploded');
	}
}

// Spawn shells near guns
function Vector GetShellOffset()
{	
	local vector offset, tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	if (bShellSwap)
		offset = -0.75 * CollisionRadius * Y;
	else
		offset = 0.75 * CollisionRadius * Y;
	tempvec = 0.5 * CollisionHeight * Z;
	offset.Z += tempvec.Z;
	
	bShellSwap = !bShellSwap;
	
	return offset;
}

function Vector GetShellVelocity()
{	
	local vector tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	
	if (bShellSwap)
		tempvec = (FRand()*20+90) * Y + (10-FRand()*20) * X;
	else
		tempvec = ((FRand()*20+90) * -1) * Y + ((10-FRand()*20) * -1) * X;
	
	return tempvec;
}

defaultproperties
{
     HitboxArchetype="Big Biped"
     TextOutOfAmmo="Ammunition depleted."
     
     SearchingSound=Sound'DeusExSounds.Robot.MilitaryBotSearching'
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.MilitaryBotTargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.MilitaryBotTargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.MilitaryBotOutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.MilitaryBotCriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.MilitaryBotScanning'
     EMPHitPoints=200
     explosionSound=Sound'DeusExSounds.Robot.MilitaryBotExplode'
     WalkingSpeed=1.000000
     bEmitDistress=True
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponMilbotMachinegun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=96)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponRobotRocket')
     InitialInventory(3)=(Inventory=Class'DeusEx.AmmoRocketRobot',Count=10)
     WalkSound=Sound'DeusExSounds.Robot.MilitaryBotWalk'
     GroundSpeed=44.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=500.000000
     Health=600
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'TranscendedModels.TransMilitaryBot'
     CollisionRadius=80.000000
     CollisionHeight=79.000000
     Mass=2000.000000
     Buoyancy=100.000000
     RotationRate=(Yaw=10000)
     BindName="MilitaryBot"
     FamiliarName="Military Bot"
     UnfamiliarName="Military Bot"
     MaxStepHeight=20.000000 // Transcended - Added
     BaseEyeHeight=30.000000
}
