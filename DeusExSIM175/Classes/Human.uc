//=============================================================================
// Human.
//=============================================================================
class Human extends VMDBufferPlayer
	abstract;

var float mpGroundSpeed;
var float mpWaterSpeed;
var float humanAnimRate;

replication 
{
	reliable if (( Role == ROLE_Authority ) && bNetOwner )
		humanAnimRate;
}

function Bool IsFiring()
{
	if ((Weapon != None) && ( Weapon.IsInState('NormalFire') || Weapon.IsInState('ClientFiring') ) ) 
		return True;
	else
		return False;
}

function Bool HasTwoHandedWeapon()
{
	if ((DeusExWeapon(Weapon) != None) && (DeusExWeapon(Weapon).VMDIsTwoHandedWeapon()))
		return True;
	else
		return False;
}

//
// animation functions
//
function PlayTurning()
{
//	ClientMessage("PlayTurning()");
	if (bForceDuck || bCrouchOn || IsLeaning())
		AttemptTweenAnim('CrouchWalk', 0.1);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptTweenAnim('Walk2H', 0.1);
		else
			AttemptTweenAnim('Walk', 0.1);
	}
}

function TweenToWalking(float tweentime)
{
//	ClientMessage("TweenToWalking()");
	if (bForceDuck || bCrouchOn)
		AttemptTweenAnim('CrouchWalk', tweentime);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptTweenAnim('Walk2H', tweentime);
		else
			AttemptTweenAnim('Walk', tweentime);
	}
}

function PlayWalking()
{
	local float newhumanAnimRate;

	newhumanAnimRate = humanAnimRate;

	// UnPhysic.cpp walk speed changed by proportion 0.7/0.3 (2.33), but that looks too goofy (fast as hell), so we'll try something a little slower
	if ( Level.NetMode != NM_Standalone ) 
		newhumanAnimRate = humanAnimRate * 1.75;

	//	ClientMessage("PlayWalking()");
	if (bForceDuck || bCrouchOn)
		AttemptLoopAnim('CrouchWalk', newhumanAnimRate);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptLoopAnim('Walk2H', newhumanAnimRate);
		else
			AttemptLoopAnim('Walk', newhumanAnimRate);
	}
}

function TweenToRunning(float tweentime)
{
//	ClientMessage("TweenToRunning()");
	if (bIsWalking)
	{
		TweenToWalking(0.1);
		return;
	}

	if (IsFiring())
	{
		if (aStrafe != 0)
		{
			if (HasTwoHandedWeapon())
				AttemptPlayAnim('Strafe2H',humanAnimRate, tweentime);
			else
				AttemptPlayAnim('Strafe',humanAnimRate, tweentime);
		}
		else
		{
			if (HasTwoHandedWeapon())
				AttemptPlayAnim('RunShoot2H',humanAnimRate, tweentime);
			else
				AttemptPlayAnim('RunShoot',humanAnimRate, tweentime);
		}
	}
	else if (bOnFire)
		AttemptPlayAnim('Panic',humanAnimRate, tweentime);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptPlayAnim('RunShoot2H',humanAnimRate, tweentime);
		else
			AttemptPlayAnim('Run',humanAnimRate, tweentime);
	}
}

function PlayRunning()
{
//	ClientMessage("PlayRunning()");
	if (IsFiring())
	{
		if (aStrafe != 0)
		{
			if (HasTwoHandedWeapon())
				AttemptLoopAnim('Strafe2H', humanAnimRate);
			else
				AttemptLoopAnim('Strafe', humanAnimRate);
		}
		else
		{
			if (HasTwoHandedWeapon())
				AttemptLoopAnim('RunShoot2H', humanAnimRate);
			else
				AttemptLoopAnim('RunShoot', humanAnimRate);
		}
	}
	else if (bOnFire)
		AttemptLoopAnim('Panic', humanAnimRate);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptLoopAnim('RunShoot2H', humanAnimRate);
		else
			AttemptLoopAnim('Run', humanAnimRate);
	}
}

function TweenToWaiting(float tweentime)
{
//	ClientMessage("TweenToWaiting()");
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
	{
		if (IsFiring())
			AttemptLoopAnim('TreadShoot');
		else
			AttemptLoopAnim('Tread');
	}
	else if (IsLeaning() || bForceDuck)
		AttemptTweenAnim('CrouchWalk', tweentime);
	else if (((AnimSequence == 'Pickup') && bAnimFinished) || ((AnimSequence != 'Pickup') && !IsFiring()))
	{
		if (HasTwoHandedWeapon())
			AttemptTweenAnim('BreatheLight2H', tweentime);
		else
			AttemptTweenAnim('BreatheLight', tweentime);
	}
}

function PlayWaiting()
{
//	ClientMessage("PlayWaiting()");
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
	{
		if (IsFiring())
			AttemptLoopAnim('TreadShoot');
		else
			AttemptLoopAnim('Tread');
	}
	else if (IsLeaning() || bForceDuck)
		AttemptTweenAnim('CrouchWalk', 0.1);
	else if (!IsFiring())
	{
		if (HasTwoHandedWeapon())
			AttemptLoopAnim('BreatheLight2H');
		else
			AttemptLoopAnim('BreatheLight');
	}

}

function PlaySwimming()
{
//	ClientMessage("PlaySwimming()");
	AttemptLoopAnim('Tread');
}

function TweenToSwimming(float tweentime)
{
//	ClientMessage("TweenToSwimming()");
	AttemptTweenAnim('Tread', tweentime);
}

function PlayInAir()
{
//	ClientMessage("PlayInAir()");
	if (!bIsCrouching && (AnimSequence != 'Jump'))
		AttemptPlayAnim('Jump',3.0,0.1);
}

function PlayLanded(float impactVel)
{
//	ClientMessage("PlayLanded()");
	PlayFootStep();
	if (!bIsCrouching)
		AttemptPlayAnim('Land',3.0,0.1);
}

function PlayDuck()
{
//	ClientMessage("PlayDuck()");
	if ((AnimSequence != 'Crouch') && (AnimSequence != 'CrouchWalk'))
	{
		if (IsFiring())
			AttemptPlayAnim('CrouchShoot',,0.1);
		else
			AttemptPlayAnim('Crouch',,0.1);
	}
	else
		AttemptTweenAnim('CrouchWalk', 0.1);
}

function PlayRising()
{
//	ClientMessage("PlayRising()");
	AttemptPlayAnim('Stand',,0.1);
}

function PlayCrawling()
{
//	ClientMessage("PlayCrawling()");
	if (IsFiring())
		AttemptLoopAnim('CrouchShoot');
	else
		AttemptLoopAnim('CrouchWalk');
}

function PlayFiring()
{
	local DeusExWeapon W;

//	ClientMessage("PlayFiring()");

	W = DeusExWeapon(Weapon);

	if ((W != None) && (!IsInState('Dying')))
	{
		if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
			AttemptLoopAnim('TreadShoot',,0.1);
		else if (W.bHandToHand)
		{
			if (bAnimFinished || (AnimSequence != 'Attack'))
				AttemptPlayAnim('Attack',W.VMDGetCorrectAnimRate(1.0, False),0.1);
		}
		else if (bIsCrouching || IsLeaning())
			AttemptLoopAnim('CrouchShoot',,0.1);
		else
		{
			if (HasTwoHandedWeapon())
				AttemptLoopAnim('Shoot2H',,0.1);
			else
				AttemptLoopAnim('Shoot',,0.1);
		}
	}
}

function PlayWeaponSwitch(Weapon newWeapon)
{
//	ClientMessage("PlayWeaponSwitch()");
	if ((!bIsCrouching) && (!bForceDuck) && (!bCrouchOn) && (!IsLeaning()) && (!IsInState('Dying')))
		AttemptPlayAnim('Reload');
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

//	ClientMessage("PlayDying()");
	GetAxes(Rotation, X, Y, Z);
	dotp = (Location - HitLoc) dot X;

	if (Region.Zone.bWaterZone)
	{
		AttemptPlayAnim('WaterDeath',,0.1);
	}
	else
	{
		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
			AttemptPlayAnim('DeathBack',,0.1);
		else				// shot from the back, fall front
			AttemptPlayAnim('DeathFront',,0.1);
	}

	PlayDyingSound();
}

//
// sound functions
//

function float RandomPitch()
{
	local float GMult;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	return (1.1 - 0.2*FRand()) * GMult;
}

function Gasp()
{
	if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCGasp', SLOT_Pain,,,, RandomPitch());
	else PlaySound(sound'MaleGasp', SLOT_Pain,,,, RandomPitch());
}

//------------------------------
//MADDERS: Female sounds. Experimental.
//------------------------------
function PlayDyingSound()
{
	local Sound TDie;
	
	if (Region.Zone.bWaterZone)
	{
		if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCWaterDeath', SLOT_Pain,,,, RandomPitch());
		else PlaySound(sound'MaleWaterDeath', SLOT_Pain,,,, RandomPitch());
	}
	else
	{
		TDie = Sound'MaleDeath';
		if (bIsFemale || bAssignedFemale) TDie = Sound'VMDFJCDeath';
		
		if (Health < -80)
		{
			switch(Die)
			{
				case Sound'ChildDeath':
					TDie = Sound'ChildDeathGibbed';
				break;
				case Sound'FemaleDeath':
					TDie = Sound'FemaleDeathGibbed';
				break;
				case Sound'MaleDeath':
					TDie = Sound'MaleDeathGibbed';
				break;
				case Sound'VMDFJCDeath':
					TDie = Sound'VMDFJCDeathGibbed';
				break;
			}
		}
		
		PlaySound(TDie, SLOT_Pain,,,, RandomPitch());
	}
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float rnd;

	if ( Level.TimeSeconds - LastPainSound < FRand() + 0.5)
		return;

	LastPainSound = Level.TimeSeconds;
	
	//MADDERS, 1/17/21: Don't make pain noises for these.
	switch(DamageType)
	{
		case 'EMP':
		case 'NanoVirus':
		case 'OwnedHalonGas':
			AISendEvent('LoudNoise', EAITYPE_Audio, FMax(Mult * TransientSoundVolume, Mult * 2.0));
			return;
		break;
	}
	
	//MADDERS: Head region determines damage sound now, unless it's drowning.
	if (HeadRegion.Zone.bWaterZone || damageType == 'Drowned')
	{
		if (damageType == 'Drowned' || HeadRegion.Zone.bWaterZone)
		{
			if (FRand() < 0.8)
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCDrown', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MaleDrown', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
		}
		else
		{
			if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			else PlaySound(sound'MalePainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
	}
	else
	{
		// Body hit sound for multiplayer only
		if (((damageType=='Shot') || (damageType=='AutoShot'))  && ( Level.NetMode != NM_Standalone ))
		{
			PlaySound(sound'BodyHit', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		
		if ((damageType == 'TearGas') || (damageType == 'HalonGas'))
		{
			if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCEyePain', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			else PlaySound(sound'MaleEyePain', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		else if (damageType == 'PoisonGas' || damageType == 'DrugDamage')
		{
			if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCCough', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			else PlaySound(sound'MaleCough', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		else
		{
			rnd = FRand();
			if (rnd < 0.33)
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MalePainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
			else if (rnd < 0.66)
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainMedium', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MalePainMedium', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
			else
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainLarge', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MalePainLarge', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
		}
		AISendEvent('LoudNoise', EAITYPE_Audio, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	}
}

function UpdateAnimRate( float augValue )
{
	if ( Level.NetMode != NM_Standalone )
	{
		if ( augValue == -1.0 )
			humanAnimRate = (Default.mpGroundSpeed/320.0);
		else
			humanAnimRate = (Default.mpGroundSpeed/320.0) * augValue * 0.85;	// Scale back about 15% so were not too fast
	}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		GroundSpeed = mpGroundSpeed;
		WaterSpeed = mpWaterSpeed;
		humanAnimRate = (GroundSpeed/320.0);
	}
	
	if (!bVMDUpdateDone)
	{
		if (MenuThemeName == "Default")
			MenuThemeName = "VMD"; // Transcended - My own flare, MADDERS, 3/3/21: YOINK!
		if (HUDThemeName == "Default")
			HUDThemeName = "VMD"; // Transcended - My own flare, MADDERS, 3/3/21: YOINK!
		
		bVMDUpdateDone = True;
	}
	ConsoleCommand("Set RFRootWindow bUseRFGoalWin False"); // Allow note searching in fullscreen
	SaveConfig();
}

defaultproperties
{
     mpGroundSpeed=230.000000
     mpWaterSpeed=110.000000
     humanAnimRate=1.000000
     bIsHuman=True
     WaterSpeed=300.000000
     AirSpeed=4000.000000
     AccelRate=1000.000000
     JumpZ=300.000000
     BaseEyeHeight=40.000000
     UnderWaterTime=20.000000
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     Mass=150.000000
     Buoyancy=155.000000
     RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
}
