//=============================================================================
// SecurityBot2.
//=============================================================================
class SecurityBot2 extends Robot;

enum ESkinColor
{
	SC_UNATCO,
	SC_Chinese
};

var() ESkinColor SkinColor;

//MADDERS: Wonky fix for busted Zodiac MS.
//It doesn't consider EMP as a takedown method, so fuck it. Fix that.
function ApplySpecialStats()
{
	Super.ApplySpecialStats();
	
	if (VMDGetMapName() ~= "72_Zodiac_BuenosAires")
	{
		bEMPIsFatal = True;
	}
}

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_UNATCO:		MultiSkins[1] = Texture'SecurityBot2Tex1'; break;
		case SC_Chinese:	MultiSkins[1] = Texture'SecurityBot2Tex2'; break;
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

// Spawn shells near middle
function Vector GetShellOffset()
{	
	local vector offset, tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	offset = X + 0.3 * Y;
	tempvec = 0.1 * CollisionHeight * Z;
	offset.Z += tempvec.Z;
	
	return offset;
}

defaultproperties
{
     HitboxArchetype="Biped"
     
     SearchingSound=Sound'DeusExSounds.Robot.SecurityBot2Searching'
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.SecurityBot2TargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.SecurityBot2TargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.SecurityBot2OutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.SecurityBot2CriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.SecurityBot2Scanning'
     EMPHitPoints=100
     explosionSound=Sound'DeusExSounds.Robot.SecurityBot2Explode'
     WalkingSpeed=1.000000
     bEmitDistress=True
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponRobotMachinegun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=24)
     WalkSound=Sound'DeusExSounds.Robot.SecurityBot2Walk'
     GroundSpeed=95.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=500.000000
     Health=250
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'TranscendedModels.TransSecurityBot2'
     CollisionRadius=62.000000
     CollisionHeight=58.279999
     Mass=800.000000
     Buoyancy=100.000000
     BindName="SecurityBot2"
     FamiliarName="Security Bot"
     UnfamiliarName="Security Bot"
     MaxStepHeight=20.000000 // Transcended - Added
     BaseEyeHeight=25.000000
}
