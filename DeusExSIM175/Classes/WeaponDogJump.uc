//=============================================================================
// WeaponDogJump.
//=============================================================================
class WeaponDogJump extends WeaponNPCRanged;

function Fire(float Value)
{
	local ScriptedPawn PawnOwner;
	local Pawn POEnemy;
	local vector EnemyLoc, TNorm;
	
	Super.Fire(Value);
	
	PawnOwner = ScriptedPawn(Owner);
	if (PawnOwner != None) POEnemy = PawnOwner.Enemy;
	
	if (POEnemy != None)
	{
		if (Dog(Owner) != None)
		{
			Dog(Owner).JumpCooldownLeft = Dog(Owner).JumpCooldown;
		}
		
		PawnOwner.Velocity.Z += 300;		
		PawnOwner.SetPhysics(PHYS_Falling);
		
		EnemyLoc = POEnemy.Location;		
		EnemyLoc.Z += (POEnemy.BaseEyeHeight / 2);
		
		if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Dog Jump"))
		{
			Destroy();
		}
		else
		{
			TNorm = Normal(EnemyLoc - PawnOwner.Location);
			if (TNorm.Z < 0) TNorm.Z *= -1;
			if (TNorm.Z < 0.1) TNorm.Z = 0.1;
			PawnOwner.Velocity = PawnOwner.GroundSpeed * 3 * TNorm;
		}
		
		PawnOwner.PlayAnimPivot('Attack');
	}
}

defaultproperties
{
     ItemName="Jump"
     ShotTime=0.100000
     HitDamage=0
     maxRange=250
     AccurateRange=250
     BaseAccuracy=0.000000
     AITimeLimit=0.000000
     //AIFireDelay=0.500000
     //FireSound=Sound'DeusExSounds.Animal.DogAttack1'
     SelectSound=Sound'DeusExSounds.Animal.DogAttack2'
     Misc1Sound=Sound'DeusExSounds.Animal.DogAttack1'
     Misc2Sound=Sound'DeusExSounds.Animal.DogAttack1'
     Misc3Sound=Sound'DeusExSounds.Animal.DogAttack2'
     AmmoName=Class'DeusEx.AmmoDogJump'
}
