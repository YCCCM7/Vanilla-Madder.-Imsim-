//=============================================================================
// HumanThug.
//=============================================================================
class HumanThug extends VMDBufferPawn
	abstract;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	// change the sounds for chicks
	if (bIsFemale)
	{
		HitSound1 = Sound'FemalePainMedium';
		HitSound2 = Sound'FemalePainLarge';
		Die = Sound'FemaleDeath';
	}
}

function bool WillTakeStompDamage(actor stomper)
{
	// This blows chunks!
	if (stomper.IsA('PlayerPawn') && (GetPawnAllianceType(Pawn(stomper)) != ALLIANCE_Hostile))
		return false;
	else
		return true;
}

defaultproperties
{
     MedicineSkillLevel=1
     EnviroSkillLevel=1
     bLookAtPlayer=True
     bSuspiciousToPlayer=True
     SmellTypes(0)="PlayerFoodSmell"
     SmellTypes(1)="StrongPlayerFoodSmell"
     SmellTypes(2)="StrongPlayerBloodSmell"
     SmellTypes(3)=""
     SmellTypes(4)=""

     BaseAccuracy=1.200000
     maxRange=700.000000
     bPlayIdle=True
     bAvoidAim=False
     bCanCrouch=True
     bSprint=True
     CrouchRate=0.200000
     SprintRate=0.500000
     bReactAlarm=True
     EnemyTimeout=3.500000
     bCanTurnHead=True
     WaterSpeed=80.000000
     AirSpeed=160.000000
     AccelRate=500.000000
     BaseEyeHeight=40.000000
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     HitSound1=Sound'DeusExSounds.Player.MalePainSmall'
     HitSound2=Sound'DeusExSounds.Player.MalePainMedium'
     Die=Sound'DeusExSounds.Player.MaleDeath'
     VisibilityThreshold=0.010000
     DrawType=DT_Mesh
     Mass=150.000000
     Buoyancy=155.000000
     BindName="HumanThug"
     RotationRate=(Pitch=4096,Yaw=60000,Roll=3072)
}
