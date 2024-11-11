//=============================================================================
// SecurityBot4.
//=============================================================================
class SecurityBot4 extends Robot;

#exec OBJ LOAD FILE=VMDAssets

var int LeftTreadIndex, RightTreadIndex, LastYaw;
var float LeftTreadProg, RightTreadProg;
var Vector LastLocation;
var Texture TreadTextures[3];

function Tick(float DT)
{
	local int TRot;
	local Vector TVel;
	
	Super.Tick(DT);
	
	//Calculate movement differences since last frame.
	TVel = (Location - LastLocation) << Rotation;
	TRot = (Rotation.Yaw - LastYaw);
	
	//We're going forwards.
	//Or, we're going backwards.
	if (TVel.X != 0)
	{
		LeftTreadProg += (TVel.X * 0.22);
		RightTreadProg += (TVel.X * 0.22);
	}
	
	//We're turning right. This means left tread forwards, and right tread backwards.
	//Or, we're turning left. This means right tread forwards, and left tread backwards.
	if (TRot != 0)
	{
		LeftTreadProg += TRot * 0.00497 * 0.5;
		RightTreadProg -= TRot * 0.00497 * 0.5;
	}
	
	if (LeftTreadProg > 1.0)
	{
		LeftTreadIndex++;
		LeftTreadProg = 0.0;
		if (LeftTreadIndex > 2) LeftTreadIndex = 0;
	}
	else if (LeftTreadProg < 0.0)
	{
		LeftTreadIndex--;
		LeftTreadProg = 1.0;
		if (LeftTreadIndex < 0) LeftTreadIndex = 2;
	}
	if (RightTreadProg > 1.0)
	{
		RightTreadIndex++;
		RightTreadProg = 0.0;
		if (RightTreadIndex > 2) RightTreadIndex = 0;
	}
	else if (RightTreadProg < 0.0)
	{
		RightTreadIndex--;
		RightTreadProg = 1.0;
		if (RightTreadIndex < 0) RightTreadIndex = 2;
	}
	
	Multiskins[1] = TreadTextures[LeftTreadIndex];
	Multiskins[2] = TreadTextures[RightTreadIndex];
	
	LastLocation = Location;
	LastYaw = Rotation.Yaw;
}

defaultproperties
{
     //MADDERS, 5/27/23: Oops. We pointed these the wrong way... Invert frame order.
     TreadTextures(0)=Texture'VMDSecurityBot4Tex1Tread0'
     TreadTextures(1)=Texture'VMDSecurityBot4Tex1Tread1'
     TreadTextures(2)=Texture'VMDSecurityBot4Tex1Tread2'
     HitboxArchetype="Roller"
     
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.SecurityBot3TargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.SecurityBot3TargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.SecurityBot3OutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.SecurityBot3CriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.SecurityBot3Scanning'
     WalkingSpeed=1.000000
     bEmitDistress=True
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponRobotMachinegun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=24)
     GroundSpeed=95.000000
     WaterSpeed=50.000000
     AirSpeed=144.000000
     AccelRate=500.000000
     Health=150
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'VMDSecurityBot4'
     SoundRadius=16
     SoundVolume=128
     AmbientSound=Sound'DeusExSounds.Robot.SecurityBot4Move'
     CollisionRadius=27.500000
     CollisionHeight=29.500000
     Mass=1000.000000
     Buoyancy=100.000000
     BindName="SecurityBot4"
     FamiliarName="Security Bot"
     UnfamiliarName="Security Bot"
     BaseEyeHeight=20.000000 // Transcended - Added
}
