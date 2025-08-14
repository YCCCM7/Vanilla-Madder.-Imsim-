//=============================================================================
// MJ12CyborgBountyHunter.
//=============================================================================
class MJ12CyborgBountyHunter extends VMDBountyHunter;

var float EMPTimer, LastVisibilityThreshold;
var localized string MsgBlindDuration;

var sound SprintSound;

function bool VMDCanDropWeapon()
{
	return false;
}

function bool ShouldDropWeapon()
{
	return false;
}

function InitializeBountyHunter(int HunterIndex, VMDBufferPlayer VMP, int MissionNumber)
{
	//Universals.
	local int i;
	
	//Clothing stuff.
	local int TColor, TGraffiti;
	local Texture FaceTex;
	
	//Inventory stuff.
	local bool bHasCells;
	local int TMeleeDamage, THealingCount, TSupportCount, TUtilityCount, TPrimaryCount, TSecondaryCount, TExtraCount;
	local class<DeusExWeapon> TPrimaryWeapon, TSecondaryWeapon, TExtraWeapon;
	local class<DeusExAmmo> TPrimaryAmmo, TSecondaryAmmo, TExtraAmmo;
	local class<DeusExPickup> THealingItem, TSupportItem, TUtilityItem, TProtectiveItem;
	
	//1111111111111111111111111111111111
	// Step 1: Decide our appearance.
	TColor = Rand(3);
	TGraffiti = Rand(5);
	
	switch(TColor)
	{
		case 0:
			Multiskins[1] = Texture'VMDMJ12Commando2Tex1Base';
			switch(TGraffiti)
			{
				case 0:
					Multiskins[0] = Texture'VMDMJ12Commando2Tex1';
					Multiskins[2] = Texture'VMDMJ12Commando2Tex0';
					Multiskins[3] = Texture'VMDMJ12Commando2Tex1';
				case 1:
					Multiskins[0] = Texture'VMDMJ12Commando2Tex3';
					Multiskins[2] = Texture'VMDMJ12Commando2Tex2';
					Multiskins[3] = Texture'VMDMJ12Commando2Tex3';
				break;
				case 2:
					Multiskins[0] = Texture'VMDMJ12Commando2Tex5';
					Multiskins[2] = Texture'VMDMJ12Commando2Tex4';
					Multiskins[3] = Texture'VMDMJ12Commando2Tex5';
				break;
				case 3:
					Multiskins[0] = Texture'VMDMJ12Commando2Tex7';
					Multiskins[2] = Texture'VMDMJ12Commando2Tex6';
					Multiskins[3] = Texture'VMDMJ12Commando2Tex7';
				break;
				case 4:
					Multiskins[0] = Texture'VMDMJ12Commando2Tex9';
					Multiskins[2] = Texture'VMDMJ12Commando2Tex8';
					Multiskins[3] = Texture'VMDMJ12Commando2Tex9';
				break;
			}
		break;
		case 1:
			Multiskins[1] = Texture'VMDMJ12Commando3Tex1Base';
			switch(TGraffiti)
			{
				case 0:
					Multiskins[0] = Texture'VMDMJ12Commando3Tex1';
					Multiskins[2] = Texture'VMDMJ12Commando3Tex0';
					Multiskins[3] = Texture'VMDMJ12Commando3Tex1';
				break;
				case 1:
					Multiskins[0] = Texture'VMDMJ12Commando3Tex3';
					Multiskins[2] = Texture'VMDMJ12Commando3Tex2';
					Multiskins[3] = Texture'VMDMJ12Commando3Tex3';
				break;
				case 2:
					Multiskins[0] = Texture'VMDMJ12Commando3Tex5';
					Multiskins[2] = Texture'VMDMJ12Commando3Tex4';
					Multiskins[3] = Texture'VMDMJ12Commando3Tex5';
				break;
				case 3:
					Multiskins[0] = Texture'VMDMJ12Commando3Tex7';
					Multiskins[2] = Texture'VMDMJ12Commando3Tex6';
					Multiskins[3] = Texture'VMDMJ12Commando3Tex7';
				break;
				case 4:
					Multiskins[0] = Texture'VMDMJ12Commando3Tex9';
					Multiskins[2] = Texture'VMDMJ12Commando3Tex8';
					Multiskins[3] = Texture'VMDMJ12Commando3Tex9';
				break;
			}
		break;
		case 2:
			Multiskins[1] = Texture'VMDMJ12Commando4Tex1Base';
			switch(TGraffiti)
			{
				case 0:
					Multiskins[0] = Texture'VMDMJ12Commando4Tex1';
					Multiskins[2] = Texture'VMDMJ12Commando4Tex0';
					Multiskins[3] = Texture'VMDMJ12Commando4Tex1';
				break;
				case 1:
					Multiskins[0] = Texture'VMDMJ12Commando4Tex3';
					Multiskins[2] = Texture'VMDMJ12Commando4Tex2';
					Multiskins[3] = Texture'VMDMJ12Commando4Tex3';
				break;
				case 2:
					Multiskins[0] = Texture'VMDMJ12Commando4Tex5';
					Multiskins[2] = Texture'VMDMJ12Commando4Tex4';
					Multiskins[3] = Texture'VMDMJ12Commando4Tex5';
				break;
				case 3:
					Multiskins[0] = Texture'VMDMJ12Commando4Tex7';
					Multiskins[2] = Texture'VMDMJ12Commando4Tex6';
					Multiskins[3] = Texture'VMDMJ12Commando4Tex7';
				break;
				case 4:
					Multiskins[0] = Texture'VMDMJ12Commando4Tex9';
					Multiskins[2] = Texture'VMDMJ12Commando4Tex8';
					Multiskins[3] = Texture'VMDMJ12Commando4Tex9';
				break;
			}
		break;
	}
	
	StoredSkin = Skin;
	StoredTexture = Texture;
	StoredFatness = Fatness;
	StoredScaleGlow = ScaleGlow;
	for(i=0; i<ArrayCount(StoredMultiskins); i++)
	{
		StoredMultiskins[i] = Multiskins[i];
	}
	
	//2222222222222222222222222222222222
	// Step 2: Decide our weapons and equipment.
	
	//GOOFY: Run this up front to know our utility item.
	//40% chance for a vision aug.
	DefaultAugs[1] = class'AugMechTarget';
	if (FRand() < 0.35)
	{
		DefaultAugs[1] = class'AugMechVision';
	}
	
	TSecondaryWeapon = ObtainSecondaryWeapon(MissionNumber, TSecondaryAmmo, TSecondaryCount);
	TPrimaryWeapon = ObtainPrimaryWeapon(MissionNumber, TPrimaryAmmo, TPrimaryCount);

	if (DefaultAugs[1] == class'AugMechVision')
	{
		TExtraWeapon = class'WeaponRetributorRailgun';
		TExtraAmmo = class<DeusExAmmo>(TExtraWeapon.Default.AmmoName);
		TExtraCount = 4;
	}
	else
	{
		TExtraWeapon = ObtainExtraWeapon(MissionNumber, TExtraAmmo, TExtraCount);
	}
	
	THealingItem = ObtainHealingItem(MissionNumber, THealingCount);
	TSupportItem = ObtainSupportItem(MissionNumber, TSupportCount);
	TUtilityItem = ObtainUtilityItem(MissionNumber, TUtilityCount);
	TProtectiveItem = ObtainProtectiveItem(MissionNumber);
	
	//We don't need goggles if we have them inside our eyes.
	if ((DefaultAugs[1] == class'AugMechVision') && (TUtilityItem == class'TechGoggles'))
	{
		TUtilityItem = None;
	}
	
	if (TSecondaryWeapon != None)
	{
		if (TSecondaryAmmo != None)
		{
			AddExactAmountToInitialInventory(TSecondaryAmmo, TSecondaryCount);
		}
		AddToInitialInventory(TSecondaryWeapon, 1, false);
	}
	if (TPrimaryWeapon != None)
	{
		if (TPrimaryAmmo != None)
		{
			AddExactAmountToInitialInventory(TPrimaryAmmo, TPrimaryCount);
		}
		AddToInitialInventory(TPrimaryWeapon, 1, false);
	}
	if (TExtraWeapon != None)
	{
		if (TExtraAmmo != None)
		{
			AddExactAmountToInitialInventory(TExtraAmmo, TExtraCount);
		}
		AddToInitialInventory(TExtraWeapon, 1, false);
	}
	
	if (THealingItem != None)
	{
		AddToInitialInventory(THealingItem, THealingCount, true);
	}
	if (TSupportItem != None)
	{
		AddToInitialInventory(TSupportItem, TSupportCount, true);
		bHasCells = (TSupportItem == class'BioelectricCell');
	}
	if (TUtilityItem != None)
	{
		AddToInitialInventory(TUtilityItem, TUtilityCount, true);
	}
	if (TProtectiveItem != None)
	{
		AddToInitialInventory(TProtectiveItem, 1, true);
	}
	
	SwitchToBestWeapon();
	
	//3333333333333333333333333333333333
	// Step 3: Decide our augs.
	bHasAugmentations = true;
	bMechAugs = true;
	
	//Always give muscle aug. We don't melee and shit getting in our way is annoying.
	DefaultAugs[0] = class'AugMechMuscle';
	
	//We're assuming lore-wise that mech cloaking is incompatible with the armor worn over the user.
	//That makes perfect sense to me.
	//We also won't have ballistic because we already have body armor to do that at all points in time.
	
	//We always have energy shield because we really hate being GEPd at a bad time.
	DefaultAugs[3] = class'AugMechEnergy';
	
	//45% chance of poison reduction as well.
	if ((bHasCells) || (Frand() < 0.45))
	{
		DefaultAugs[4] = class'AugMechEnviro';
	}
	
	//65% chance for EMP reduction, cells regardless.
	if (FRand() < 0.65)
	{
		DefaultAugs[5] = class'AugMechEMP';
	}
	
	//Commandos seem to have pre-existing cybernetic legs built especially for use with their power armor.
	//We're going to assume these legs were strengthened with the intent of supporting the power armor and its needs.
	//As such, standard leg augs are off the table.
	
	VMDInitializeSubsystems();
	
	//Bark bind name work.
	HunterBarkBindName = "MJ12CyborgBountyHunter"$string(AssignedID+1);
	
	Super.InitializeBountyHunter(HunterIndex, VMP, MissionNumber);
}

function class<DeusExWeapon> ObtainSecondaryWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo, out int OutCount)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(3);
	
	switch(R)
	{
		case 0:
			Ret = class'WeaponRetributorShotgun';
			OutCount = 20;
		break;
		case 1:
			Ret = class'WeaponRetributorFlamethrower';
			OutCount = 200;
		break;
		case 2:
			Ret = class'WeaponRetributorRocket';
			OutCount = 3;
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
		switch(Ret.Class.Name)
		{
			case 'WeaponRetributorShotgun':
				R = Rand(1) + int(MissionNumber > 3);
				switch(R)
				{
					case 0:
						OutAmmo = class'AmmoSabot';
					break;
					case 1:
						OutAmmo = class'AmmoTaserSlug';
					break;
				}
			break;
			case 'WeaponRetributorRocket':
				R = Rand(1) + int(MissionNumber > 5);
				switch(R)
				{
					case 0:
						OutAmmo = class'AmmoRocket';
					break;
					case 1:
						OutAmmo = class'AmmoRocketWP';
					break;
				}
			break;
		}
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainPrimaryWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo, out int OutCount)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(3);
	
	switch(R)
	{
		case 0:
			Ret = class'WeaponRetributor3006';
			OutCount = 60; //60 rounds total
		break;
		case 1:
			Ret = class'WeaponRetributor762mm';
			OutCount = 400;
		break;
		case 2:
			Ret = class'WeaponRetributor10mm';
			OutCount = 108;
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
		switch(Ret.Class.Name)
		{
			//Demolisher is compatible with all 3006 ammo types.
			case 'WeaponRetributor3006':
				R = Rand(2) + int(MissionNumber > 3);
				switch(R)
				{
					case 0:
						OutAmmo = class'Ammo3006';
					break;
					case 1:
						OutAmmo = class'Ammo3006Tranq';
					break;
					case 2:
						OutAmmo = class'Ammo3006HEAT';
					break;
				}
			break;
		}
	}
	
	return Ret;
}

function class<DeusExWeapon> ObtainExtraWeapon(int MissionNumber, out class<DeusExAmmo> OutAmmo, out int OutCount)
{
	local int R;
	local class<DeusExWeapon> Ret;
	
	R = Rand(2); //Used to be rand 3, but now we wait for the aug to act.
	
	switch(R)
	{
		case 0:
			Ret = class'WeaponRetributor20mm';
			OutCount = 3;
		break;
		case 1:
			Ret = class'WeaponRetributorStickyRocket';
			OutCount = 1;
		break;
		/*case 2:
			Ret = class'WeaponRetributorRailgun';
			OutCount = 4;
		break;*/
	}
	
	if (Ret != None)
	{
		OutAmmo = class<DeusExAmmo>(Ret.Default.AmmoName);
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainHealingItem(int MissionNumber, out int ItemCount)
{
	local class<DeusExPickup> Ret;
	
	ItemCount = Rand(3) + 2;
	Ret = class'VMDMedigel';
	
	return Ret;
}

function class<DeusExPickup> ObtainSupportItem(int MissionNumber, out int ItemCount)
{
	local class<DeusExPickup> Ret;
	
	ItemCount = Rand(3) + 2;
	Ret = class'BioelectricCell';
	
	return Ret;
}

function class<DeusExPickup> ObtainUtilityItem(int MissionNumber, out int ItemCount)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(5);
	switch(R)
	{
		case 0:
		case 1:
		case 2:
			ItemCount = 1;
			Ret = class'TechGoggles';
		break;
		case 3:
		case 4:
			//MADDERS, 6/24/25: This makes these guys OP. Axe it.
			ItemCount = 1;
			//Ret = class'AdaptiveArmor';
		break;
	}
	
	return Ret;
}

function class<DeusExPickup> ObtainProtectiveItem(int MissionNumber)
{
	local int R;
	local class<DeusExPickup> Ret;
	
	R = Rand(3);
	switch(R)
	{
		case 0:
			Ret = class'HazmatSuit';
		break;
		case 1:
		case 2:
			Ret = class'BallisticArmor';
		break;
	}
	
	return Ret;
}

function bool AICanShoot(pawn target, bool bLeadTarget, bool bCheckReadiness, optional float throwAccuracy, optional bool bDiscountMinRange)
{
	local DeusExWeapon DXW;
	
	DXW = DeusExWeapon(Weapon);
	if ((WeaponRetributorStickyRocket(DXW) == None) || (DXW.LockMode == LOCK_Locked))
	{
		return Super.AICanShoot(Target, bLeadTarget, bCheckReadiness, ThrowAccuracy, bDiscountMinRange);
	}
	else
	{
		return false;
	}
}

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
     ArmorNoiseIndex(0)=1
     ArmorNoiseIndex(1)=1
     bHasHelmet=False
     bHasHeadArmor=True
     bHasBodyArmor=True
     
     HelmetDamageThreshold=50
     ArmorDamageThreshold=100
     bRobotVision=True
     Energy=50 //NOTE: These guys have small energy capacity for augs because this is the portion of their energy not used for their suit.
     EnergyMax=50
     MedkitHealthLevel=150
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
     
     ArmorStrength=0.600000
     MinHealth=0.000000
     WalkingSpeed=0.296000
     bCanCrouch=False
     CloseCombatMult=0.500000
     BurnPeriod=0.000000
     GroundSpeed=200.000000
     Health=250
     HealthHead=250
     HealthTorso=250
     HealthLegLeft=250
     HealthLegRight=250
     HealthArmLeft=250
     HealthArmRight=250
     DrawScale=1.100000
     Mesh=LodMesh'TranscendedModels.TransGM_ScaryTroop'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12CommandoTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     CollisionRadius=28.000000
     CollisionHeight=54.868001
     BindName="MJ12Retributor"
     FamiliarName="MJ12 Retributor"
     UnfamiliarName="MJ12 Retributor"
     NameArticle=" an "
     RotationRate=(Pitch=4096,Yaw=60000,Roll=3072)
}
