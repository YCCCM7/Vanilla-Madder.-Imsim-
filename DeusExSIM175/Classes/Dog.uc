//=============================================================================
// Dog.
//=============================================================================
class Dog extends Animal
	abstract;

var float time, JumpCooldownLeft, JumpCooldown; //MADDERS, 12/1/21: Jump limitation bullshit. Ugh.

var bool bPurgedDogBarf; //MADDERS, 12/1/21: I hate it *so* fucking much, you have no idea.

function PlayDogBark()
{
	// overridden in subclasses
}

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	time += deltaTime;

	// check for random noises
	if (time > 1.0)
	{
		//MADDERS, 12/1/21: Thanks, I hate it.
		CheckForDogJumpBarf();
		
		time = 0;
		if ((FRand() < 0.05) && (!IsInState('Dying')))
			PlayDogBark();
	}
	if (JumpCooldownLeft > 0)
	{
		JumpCooldownLeft -= DeltaTime;
	}
}

function PlayTakingHit(EHitLocation hitPos)
{
	// nil
}

function PlayAttack()
{
	PlayAnimPivot('Attack');
}

function TweenToAttack(float tweentime)
{
	TweenAnimPivot('Attack', tweentime);
}

function PlayBarking()
{
	PlayAnimPivot('Bark');
}

function TweenToShoot(float tweentime) 
{
	TweenAnimPivot('Bark', tweentime);
}

function PlayShoot() 
{
	PlayAnimPivot('Bark', 2.0);
}

// Transcended - Added
function bool PlayBeginAttack()
{
	return PlayBarkingAnim();
}

// Transcended - Added
function bool PlayBarkingAnim()
{
	local human Playerpawn;
	
	Playerpawn = Human(GetPlayerPawn());
	
	PlayAnimPivot('Bark');
	PlayDogBark();
	
	// if (Pawn(Enemy) != None)
		// Instigator = Pawn(Enemy);
	
	Instigator = Enemy;
	AISendEvent('LoudNoise', EAITYPE_Audio, 2, Playerpawn.CombatDifficulty*128);
	AISendEvent('Distress', EAITYPE_Audio, 2, Playerpawn.CombatDifficulty*128);
	return true;
}

// fake a charge attack using bump
function Bump(actor Other)
{
	local DeusExWeapon dxWeapon;
	local DeusExPlayer dxPlayer;
	local float        damage;

	Super.Bump(Other);

	if (IsInState('Attacking') && (Other != None) && (Other == Enemy))
	{
		// damage both of the player's legs if the karkian "charges"
		// just use Shot damage since we don't have a special damage type for charged
		// impart a lot of momentum, also
		if (VSize(Velocity) > 100)
		{
			dxWeapon = DeusExWeapon(Weapon);
			if ((dxWeapon != None) && (dxWeapon.IsA('WeaponDogJump')) && (FireTimer <= 0))
			{
				if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "Dog Jump"))
				{
					dxWeapon.Destroy();
					SwitchToBestWeapon();
				}
				else
				{
					FireTimer = DeusExWeapon(Weapon).AIFireDelay + 1;
					damage = VSize(Velocity) / 100;
					Other.TakeDamage(damage, Self, Other.Location+vect(1,1,-1), 100*Velocity, 'Shot');
					Other.TakeDamage(damage, Self, Other.Location+vect(-1,-1,-1), 100*Velocity, 'Shot');
					dxPlayer = DeusExPlayer(Other);
					if (dxPlayer != None)
						dxPlayer.ShakeView(0.05 + 0.002*damage*2, damage*30*2, 0.3*damage*2);
				}
			}
		}
	}
}

//BARF! Force weapon swap once we've landed, so we put away our jump only after having had our shot to monch.
function PlayLanded(float impactVel)
{
	Super.PlayLanded(impactVel);
	
	SwitchToBestWeapon();
}

function CheckForDogJumpBarf()
{
	local Inventory Inv, Last, Next;
	
	//BARF!
	if (bPurgedDogBarf) return;
	
	if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "Dog Jump"))
	{
		for (Inv = Inventory; Inv != None; Inv = Inv.Inventory)
		{			
			Next = Inv.Inventory;
			
			if (WeaponDogJump(Inv) != None)
			{
				if (Inv == Inventory)
				{
					Inventory = Next;
				}
				
				Inv.Destroy();
				bPurgedDogBarf = true;
				
				if (Last != None)
				{
					Last.Inventory = Next;
				}
				break;
			}
			
			Last = Inv;
		}
	}
	else
	{
		bPurgedDogBarf = true;
	}
}

//MADDERS, 11/29/21: Make sure weapon dog jump is deleted by sane, reliable means.
function ApplySpecialStats()
{
	local Inventory Inv, Last, Next;
	
	Super.ApplySpecialStats();
	
	CheckForDogJumpBarf();
}

defaultproperties
{
     SmellTypes(0)="PlayerAnimalSmell"
     SmellTypes(1)="PlayerSmell"
     SmellTypes(2)="StrongPlayerFoodSmell"
     SmellTypes(3)="PlayerBloodSmell"
     SmellTypes(4)="StrongPlayerBloodSmell"
     HitBoxArchetype="Dog"
     JumpCooldown=6.000000
     
     bPlayDying=True
     MinHealth=2.000000
     InitialAlliances(7)=(AllianceName=Cat,AllianceLevel=-1.000000)
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponDogBite')
     InitialInventory(1)=(Inventory=Class'DeusEx.WeaponDogJump')
     InitialInventory(2)=(Inventory=Class'DeusEx.AmmoDogJump',Count=159)
     BaseEyeHeight=12.500000
     Alliance=Dog
     Buoyancy=97.000000
     bEmitDistress=True // Transcended - Added
     bCanBleed=True
}
