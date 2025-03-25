//=============================================================================
// MJ12Commando.
//=============================================================================
class MJ12Commando extends HumanMilitary;

var float EMPTimer, LastVisibilityThreshold;
var localized string MsgBlindDuration;

var sound SprintSound;

//MADDERS, 8/30/23: EMP grenades now scramble our vision for a bit.
function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local int oldHealth;
	
	oldHealth = Health;
	
	if ((DamageType == 'EMP' || DamageType == 'Shocked') && (Damage/3 > 5))
	{
		if (LastVisibilityThreshold < 0)
		{
			LastVisibilityThreshold = VisibilityThreshold;
		}
		EMPTimer += Damage / 3;
		
		if (bSprinting)
		{
			SprintStamina = 0;
		}
	}
	
	Super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
	
	/*if ((Health > 0) && (Health <= (StartingHealthValues[6] / 4)) && (oldHealth > (StartingHealthValues[6] / 4)))
	{
        	PlayCriticalDamageSound();
	}*/
}

//MADDERS, 12/30/23: We need to activate cells on our own accord, since we are formally augless.
function VMDPawnTickHook(float DeltaTime)
{
	local BioelectricCell TCell;
	
	if ((BiocellUseTimer > 0) && (VMDIsInHealableState()))
	{
		BiocellUseTimer -= DeltaTime;
		if (BioCellUseTimer <= 0)
		{
			BioCellUseTimer = 0;
			TCell = BioelectricCell(FindInventoryType(class'BioelectricCell'));
			if ((TCell != None) && (!TCell.bDeleteMe) && (TCell.NumCopies > 0) && (!TCell.IsInState('Activated')))
			{
				TCell.Activate();
				
				VMDCommandoStartSprinting();
			}
		}
	}
	
	Super.VMDPawnTickHook(DeltaTime);
	
	if (bSprinting)
	{
		VMDUpdateSpeedAugEffects(DeltaTime);
	}
}

// ----------------------------------------------------------------------
// PlayFootStep()
//
// Plays footstep sounds based on the texture group
// (yes, I know this looks nasty -- I'll have to figure out a cleaner way to do this)
// ----------------------------------------------------------------------

function PlayFootStep()
{
	local Sound stepSound;
	local float rnd;
	local name mat;
	local float speedFactor, massFactor, RunSilentValue;
	local float volume, pitch, range;
	local float radius, maxRadius, PlayRadius, PlayRange; //WCCC NOTE: Play radius + Range are hacks for sound vs emission range.
	local float volumeMultiplier;
	
	local DeusExPlayer dxPlayer;
	local float shakeRadius, shakeMagnitude;
	local float playerDist;
	
	rnd = FRand();
	mat = GetFloorMaterial();
	
	volumeMultiplier = 1.0;
	StepSound = FootStepSound(Volume, volumeMultiplier);
	
	// compute sound volume, range and pitch, based on mass and speed
	speedFactor = VSize(Velocity)/120.0;
	massFactor  = Mass/150.0;
	radius      = 768.0;
	maxRadius   = 2048.0;
	
	PlayRadius = Radius;
	//WCCC, 3/17/19: Experimental noise reception, relative to height. Spicy.
	if ((GetPlayerPawn() != None) && (SendNoiseHeightTolerance > 0))
	{
		PlayRadius *= ScaleSoundByHeight(SendNoiseHeightTolerance, GetPlayerPawn());
	}
	
	volume = massFactor*1.5;
	
	range = radius * volume;
	PlayRange = PlayRadius * Volume;
	pitch = (volume+0.5);
	volume = 1.0;
	
	range = FClamp(range, 0.01, maxRadius);
	PlayRange = FClamp(PlayRange, 0.01, maxRadius);
	pitch = FClamp(pitch, 1.0, 1.5);
	
	//MADDERS: Water steps are lower pitch.
	if (FootRegion.Zone.bWaterZone)
	{
		Pitch *= 0.7;
	}
	
	//MADDERS: Configure this remotely.
	if (AugmentationSystem != None)
	{
		RunSilentValue = AugmentationSystem.VMDConfigureNoiseMult();
	}
	
	//MADDERS, 12/28/22: Scale pitch with slomo command.
	if ((Level != None) && (Level.Game != None))
	{
		Pitch *= Level.Game.GameSpeed;
	}
	
	if ((!Region.Zone.bWaterZone) && (bSprinting))
	{
		StepSound = Sound'SecurityBot2Walk';
		Volume *= 2.5;
		PlayRange *= 2;
		Range *= 2;
		Pitch *= 1.3;
	}
	
	// play the sound and send an AI event
	// HX: slightly vary playback volume.
	PlaySound(stepSound, SLOT_Interact, volume*(0.9 + 0.2 * FRand()), , PlayRange, pitch);
	AISendEvent('LoudNoise', EAITYPE_Audio, volume*volumeMultiplier, range*volumeMultiplier);
	
	// Shake the camera when heavy things tread
	if (Mass > 400)
	{
		dxPlayer = DeusExPlayer(GetPlayerPawn());
		if (dxPlayer != None)
		{
			playerDist = DistanceFromPlayer;
			shakeRadius = FClamp((Mass-400)/600, 0, 1.0) * (range*0.5);
			shakeMagnitude = FClamp((Mass-400)/1600, 0, 1.0);
			shakeMagnitude = FClamp(1.0-(playerDist/shakeRadius), 0, 1.0) * shakeMagnitude;
			if (shakeMagnitude > 0)
				dxPlayer.JoltView(shakeMagnitude);
		}
	}
}

//MADDERS, 12/30/23: Powered sprint mode. Fun stuff. Don't sprint for normal reasons.
function VMDStartSprinting()
{
	local BioelectricCell TCell;
	
	if (bSprinting) return;
	
	TCell = BioelectricCell(FindInventoryType(class'BioelectricCell'));
	if (TCell == None) return;
	
	BiocellUseTimer = 1.5;
}

function VMDCommandoStartSprinting()
{
	SprintStaminaMax = 125;
	SprintStamina = 125;
	
	bSprinting = true;
	VMDUpdateGroundSpeedBuoyancy();
	
	if (AmbientSound == None)
	{
		AmbientSound = SprintSound;
		SoundPitch = 122;
		SoundVolume = 128;
	}
}

//MADDERS, 12/30/23: We sprint faster than average, because we are terrifying.
function VMDUpdateGroundSpeedBuoyancy()
{
	local int i, LegSum, HealthChunks[7], ClockTimer;
	local float LegMod, PoisonMod;
	
	for (i=0; i<ArrayCount(HealthChunks); i++)
	{
		HealthChunks[i] = StartingHealthValues[i];
	}
	
   	//MADDERS, 5/26/23: Slow our speed from leg damage. Fun times.
	if (Health > 0)
	{
		LegSum = HealthChunks[4] + HealthChunks[5];
		LegMod = (LegSum - HealthLegLeft - HealthLegRight) / LegSum;
		
		PoisonMod = TotalPoisonDamage / HealthChunks[6];
		
		if (StartingGroundSpeed > 0) GroundSpeed = StartingGroundSpeed + (FMax(LegMod, PoisonMod) * StartingGroundSpeed * -0.5);
		if (StartingBuoyancy > 0) Buoyancy = StartingBuoyancy + (FMax(LegMod, PoisonMod*0.5) * StartingBuoyancy * -1.0);
		
		if ((bSprinting) && (SprintStamina > 0))
		{
			GroundSpeed *= 1.66;
		}
		else if (AmbientSound == SprintSound)
		{
			AmbientSound = None;
		}
	}
}

function string VMDGetDisplayName(string InName)
{
	if (EMPTimer > 0)
	{
		InName = SprintF(MsgBlindDuration, InName, int(EMPTimer));
	}
	
	return InName;
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (EMPTimer > 0)
	{
		if (AmbientSound == None)
		{
			AmbientSound = Sound'CameraHum';
			SoundPitch = 144;
			SoundRadius = 24;
			SoundVolume = 192;
			PlayCriticalDamageSound();
		}
		EMPTimer -= DT;
		VisibilityThreshold = 1000.0;
	}
	else if (VisibilityThreshold > 0.99)
	{
		if (AmbientSound == Sound'CameraHum')
		{
			AmbientSound = None;
			SoundPitch = 128;
			SoundRadius = 0;
			Soundvolume = 0;
		}
		VisibilityThreshold = LastVisibilityThreshold;
	}
}

function PlayCriticalDamageSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(GetPlayerPawn());
	if ((dxPlayer != None) && (!HeadRegion.Zone.bWaterZone))
	{
		dxPlayer.StartAIBarkConversation(self, BM_CriticalDamage);
	}
}

function Bool HasTwoHandedWeapon()
{
	return False;
}

function PlayReloadBegin()
{
	TweenAnimPivot('Shoot', 0.1);
}

function PlayReload()
{
}

function PlayReloadEnd()
{
}

function PlayIdle()
{
}

function TweenToShoot(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnimPivot('TreadShoot', tweentime, GetSwimPivot());
	else if (!bCrouching)
		TweenAnimPivot('Shoot2', tweentime);
}

function PlayShoot()
{
	if (Region.Zone.bWaterZone)
		PlayAnimPivot('TreadShoot', , 0, GetSwimPivot());
	else
		PlayAnimPivot('Shoot2', , 0);
}

function bool IgnoreDamageType(Name damageType)
{
	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage'))
		return True;
	else
		return False;
}

function float ShieldDamage(Name damageType)
{
	if (IgnoreDamageType(damageType))
		return 0.0;
	else if ((damageType == 'Burned') || (damageType == 'Flamed'))
		return 0.5;
	else if ((damageType == 'Poison') || (damageType == 'PoisonEffect'))
		return 0.5;
	else
		return Super.ShieldDamage(damageType);
}


function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	else if (!IgnoreDamageType(damageType) && CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

//MADDERS: Give commandos assloads of specialized gear, making them some robust sons of bitches to deal with.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local Texture TChest;
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
 	
 	//1111111111111
 	//MADDERS: Obtain a seed.
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 23);
	
	if (DXLI != None)
	{
		switch(Seed)
		{
			case 3:
			case 7:
			case 8:
				if (DXLI.MissionNumber >= 10)
				{
					AddToInitialInventory(class'BallisticArmor', 1);
				}
			break;
			case 4:
			case 15:
			case 21:
				if (DXLI.MissionNumber >= 8)
				{
					AddToInitialInventory(class'HazmatSuit', 1);
				}
			break;
			case 9:
			case 12:
			case 22:
				if (DXLI.MissionNumber >= 6)
				{
					AddToInitialInventory(class'BioelectricCell', 1);
				}
			break;
			case 13:
			case 17:
				if (DXLI.MissionNumber >= 12)
				{
					AddToInitialInventory(class'AdaptiveArmor', 1);
				}
			break;
		}
	}
}

//MADDERS, 6/24/23: New pain and death sounds for commando bro.
function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	HitSound1 = Sound'CommandoPainMedium';
	HitSound2 = Sound'CommandoPainLarge';
	Die = Sound'CommandoDeath';
}

defaultproperties
{
     bFearEMP=True
     bRobotVision=True
     SprintSound=Sound'DeusExSounds.Augmentation.AugLoop'
     MsgBlindDuration="%s (Blinded, %d seconds)"
     LastVisibilityThreshold=-1.000000
     bCanClimbLadders=False
     bCanGrabWeapons=False
     bDoesntSniff=True
     SmellTypes(0)=
     SmellTypes(1)=
     SmellTypes(2)=
     SmellTypes(3)=
     SmellTypes(4)=
     SmellTypes(5)=
     SmellTypes(6)=
     SmellTypes(7)=
     SmellTypes(8)=
     SmellTypes(9)=
     
     //MADDERS additions.
     bAerosolImmune=True
     bDrawShieldEffect=True
     MedicineSkillLevel=1
     EnviroSkillLevel=3
     
     ArmorStrength=0.750000
     MinHealth=0.000000
     CarcassType=Class'DeusEx.MJ12CommandoCarcass'
     WalkingSpeed=0.296000
     bCanCrouch=False
     CloseCombatMult=0.500000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponMJ12Commando')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=24)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponMJ12Rocket')
     InitialInventory(3)=(Inventory=Class'DeusEx.AmmoRocketMini',Count=10)
     
     //MADDERS: Hack for making commandos drop 7.62mm.
     //InitialInventory(5)=(Inventory=Class'DeusEx.WeaponGEPGunDummyNONONO')
     //InitialInventory(6)=(Inventory=Class'DeusEx.AmmoRocketNONONO',Count=10)
     InitialInventory(7)=(Inventory=Class'DeusEx.WeaponAssaultGunDummy')
     BurnPeriod=0.000000
     GroundSpeed=200.000000
     Health=200
     HealthHead=200
     HealthTorso=200
     HealthLegLeft=200
     HealthLegRight=200
     HealthArmLeft=200
     HealthArmRight=200
     Mesh=LodMesh'TranscendedModels.TransGM_ScaryTroop'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12CommandoTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     CollisionRadius=28.000000
     CollisionHeight=49.880001
     BindName="MJ12Commando"
     FamiliarName="MJ12 Commando"
     UnfamiliarName="MJ12 Commando"
     NameArticle=" an "
     RotationRate=(Pitch=4096,Yaw=60000,Roll=3072)
}
