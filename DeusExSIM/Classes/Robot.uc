//=============================================================================
// Robot.
//=============================================================================
class Robot extends VMDBufferPawn
	abstract;

var(Sounds) sound SearchingSound;
var(Sounds) sound SpeechTargetAcquired;
var(Sounds) sound SpeechTargetLost;
var(Sounds) sound SpeechOutOfAmmo;
var(Sounds) sound SpeechCriticalDamage;
var(Sounds) sound SpeechScanning;
var(Sounds) sound SpeechAreaSecure;

var() int EMPHitPoints;
var ParticleGenerator sparkGen;
var float crazedTimer;

var(Sounds) sound explosionSound;

//MADDERS additions!
var() bool bBlockRockets;

//MADDERS: Porting from the boys at GMDE.
var string HitBoxArchetype;
var bool bEMPIsFatal;

var(MADDERS) localized string TextTargetAcquired, TextTargetLost, TextOutOfAmmo, TextCriticalDamage, TextScanning, TextAreaSecure;

//DXT additions!
var int criticalDamageSound, targetAcquiredSound, StartingEMPHitPoints;
var float RebootTimer;

var ParticleGenerator SmokeGen;

//MADDERS: Make robots 4x faster and have rockets. Thanks.
function ApplySpecialStats()
{
	Super.ApplySpecialStats();
	
	//MADDERS: Holy shit, what a devious hack.
	if (!VMDOtherIsName("DeusEx."))
	{
		//Hack pile, I stand corrected. Use this to check for foreign animals,
		//and set them accordingly if they're gonna need a hitbox.
		if (VMDOtherIsName("SecurityBot2"))
		{
			HitboxArchetype = "Biped";
		}
		else if (VMDOtherIsName("Military"))
		{
			HitboxArchetype = "Big Biped";
		}
		else if (VMDOtherIsName("SecurityBot3") || VMDOtherIsName("SecurityBot4"))
		{
			HitboxArchetype = "Roller";
		}
		else if (VMDOtherIsName("Spider"))
		{
			HitboxArchetype = "Spiderbot";
		}
		else if (VMDOtherIsName("Cleaner"))
		{
			HitboxArchetype = "Cleanerbot";
		}
	}
	
	//MADDERS, 5/29/23: Nihilum and some vanilla have hearing robots. Very inconsistent.
	bReactLoudNoise = False;
}

//MADDERS: Use this for checking classes. Pretty hacky.
function bool VMDOtherIsName(string S, optional Actor Other)
{
	if (Other == None) Other = Self;
	
 	if (InStr(CAPS(String(Other.Class)), CAPS(S)) > -1) return true;
 	return false;
}

//MADDERS: Handle hitboxes per robot type.
function EHitLocation HandleDamage(int Damage, Vector hitLocation, Vector offset, name damageType)
{
	local bool bHeadshot, FlagDrone;
	local int OldDamage, TPos;
	local float headOffsetZ, headOffsetZ2, headOffsetY, LegOffsetY, ArmOffsetZ, FDamage, BonusFDamage;
	local EHitLocation hitPos;
	local Texture CurSkin;
	local VMDBufferPlayer VPlayer;
	local VMDMEGH GMEGH;
	local VMDSIDD GSIDD;
	
	hitPos = HITLOC_None;
	
	FDamage = float(Damage);
	Offset.Z += PrePivot.Z;
	if (DamageType != 'Test')
	{
		FDamage = LastFDamage;
	}
	
	OldDamage = Damage;
	
	GSIDD = VMDSIDD(Self);
	GMEGH = VMDMEGH(Self);
	FlagDrone = (GSIDD != None || GMEGH != None);
	
	//Falling hurts for robots. They're stupid heavy.
	if (damageType == 'Fell')
	{
		FDamage *= (Mass / 150.0);
		Health -= int(FDamage);
		
		TPos = 1;
		if (TPos > -1)
		{
			FloatDamageValues[TPos] = (FloatDamageValues[TPos] + FDamage) % 1.0;
		}
		
		//NOTE: Do not process damage location for fall damage.
		return HITLOC_TorsoFront;
	}
	
	//MADDERS: Assume an armor hit until proven otherwise.
	bLastArmorHit = true;
	
	switch(DamageType)
	{
		case 'Poison':
		case 'PoisonEffect':
			FDamage = 0;
		break;
		case 'Flamed':
			FDamage *= 0.25;
		break;
		case 'Shot':
			if (FlagDrone)
			{
				if (GMEGH != None)
				{
					FDamage *= 0.67;
				}
				else
				{
					FDamage *= 0.5;
				}
			}
			else
			{
				FDamage *= 0.25;
			}
		break;
		case 'Burned':
			FDamage *= 0.2;
		break;
		case 'KnockedOut':
		case 'Stunned':
			FDamage *= 0.5;
		break;
		case 'Sabot':
			FDamage *= 1.5;
		break;
		case 'Test':
			FDamage = 0;
		break;
		default:
			bLastArmorHit = false;
		break;
	}
	
	if (offset.X < 0.0)
	{
		hitPos = HITLOC_TorsoBack;
		TPos = 1;
	}
	else
	{
		hitPos = HITLOC_TorsoFront;
		TPos = 1;
	}
	
	switch(CAPS(HitboxArchetype))
	{
		//--------------------------
		//Mystery guys.
		case "SPIDERBOT":
		case "CLEANERBOT":
			//These bots aren't meant for combat. Even damage for front and sides.
			if (Abs(Offset.Y) > Abs(Offset.X))
			{
				if (Offset.Y > 0) 
				{
					HitPos = HITLOC_RightLegFront;
					TPos = 5;
				}
				else
				{ 
					HitPos = HITLOC_LeftLegFront;
					TPos = 4;
				}
			}
			else
			{
				//Front armor is completely standard stuff. These are not combat robots.
				if (Offset.X > 0)
				{
					HitPos = HITLOC_TorsoFront;
					TPos = 1;
				}
				//Rear armor is super weak, but do note that
				//spiderbots are near impossible to rearshot.
				else
				{
					bHeadshot = True;
					HitPos = HITLOC_TorsoBack;
					FDamage *= 1.35;
					TPos = 1;
				}
			}
		break;
		//===========================
		//BIPEDAL ROBOT!
		//===========================
		case "BIPED":
			LegOffsetY = CollisionRadius * 0.33;
			
			//Legs are well rounded in material distribution, and meant for taking a hit or two.
			if (offset.Y > LegOffsetY)
			{
				if (offset.X < 0.0)
				{
					hitPos = HITLOC_RightLegBack;
					TPos = 5;
				}
				else
				{
					hitPos = HITLOC_RightLegFront;
					TPos = 5;
				}
			}
			else if (offset.Y < (LegOffsetY * -1))
			{
				if (offset.X < 0.0)
				{
					hitPos = HITLOC_LeftLegBack;
					TPos = 4;
				}
				else
				{
					hitPos = HITLOC_LeftLegFront;
					TPos = 4;
				}
			}
			//Torso is meant to take a blow, but the rear less so.
			else
			{
				if (offset.X < 0.0)
				{
					//MADDERS: Don't do this, for clarity sake.
					//bHeadshot = true;
					Damage *= 1.2;
					hitPos = HITLOC_TorsoBack;
					TPos = 1;
				}
				else
				{
					Damage *= 0.8;
					hitPos = HITLOC_TorsoFront;
					TPos = 1;
				}
			}
	 		
			HeadOffsetY = CollisionRadius * 0.302;
			HeadOffsetZ = CollisionHeight * 0.47; //Floor
			HeadOffsetZ2 = CollisionHeight * 0.61; //Ceiling
			
			if (AnimSequence == 'Idle')
			{
				HeadOffsetZ += 0.07*CollisionHeight;
				HeadOffsetZ2 += 0.07*CollisionHeight;
			}
	 		
			//The actual underside of the head. No easy task.
			if ((Offset.X > 0.0) && (Offset.Z > HeadOffsetZ) && (Offset.Z < HeadOffsetZ2) && (Offset.Y < HeadOffsetY) && (Offset.Y > -HeadOffsetY))
			{
				TPos = 0;
				bHeadshot = true;
				hitPos = HITLOC_HeadFront;
				FDamage *= 2;
				if (DamageType != 'EMP') 
				{
					TakeDamage(int(FDamage * 1.5), LastDamager, HitLocation, vect(0,0,0), 'EMP');
					CurSkin = Multiskins[1];
					if (CurSkin == None) CurSkin = Skin;
					if (CurSkin == None) CurSkin = GetMeshTexture(1);
					
					if (CurSkin != None)
					{
						switch(CurSkin.Name)
						{
							case 'SecurityBot2Tex1':
							case 'VMDSecurityBot2Tex1Crack01':
							case 'VMDSecurityBot2Tex1Crack02':
							case 'VMDSecurityBot2Tex1Crack03':
								if (EMPHitPoints < 1)
								{
									Multiskins[1] = Texture'VMDSecurityBot2Tex1Crack03';
								}
								else if (EMPHitPoints < StartingEMPHitPoints * 0.5)
								{
									Multiskins[1] = Texture'VMDSecurityBot2Tex1Crack02';
								}
								else if (EMPHitPoints < StartingEMPHitPoints)
								{
									Multiskins[1] = Texture'VMDSecurityBot2Tex1Crack01';
								}
							break;
							case 'SecurityBot2Tex2':
							case 'VMDSecurityBot2Tex2Crack01':
							case 'VMDSecurityBot2Tex2Crack02':
							case 'VMDSecurityBot2Tex2Crack03':
								if (EMPHitPoints < 1)
								{
									Multiskins[1] = Texture'VMDSecurityBot2Tex2Crack03';
								}
								else if (EMPHitPoints < StartingEMPHitPoints * 0.5)
								{
									Multiskins[1] = Texture'VMDSecurityBot2Tex2Crack02';
								}
								else if (EMPHitPoints < StartingEMPHitPoints)
								{
									Multiskins[1] = Texture'VMDSecurityBot2Tex2Crack01';
								}
							break;
						}
					}
				}
			}
		break;
		//+++++++++++++++++++++++++++
		//BIG BIPEDAL ROBOT! (Milbot)
		//+++++++++++++++++++++++++++
		case "BIG BIPED":
	 		ArmOffsetZ = CollisionHeight * 0.72;
	 		LegOffsetY = CollisionRadius * 0.36;
	 		
         		if (offset.Y > LegOffsetY)
	 		{
	  			if (offset.Z < ArmOffsetZ)
	  			{
	   				//Legs are meant to take a beating.
	   				if (offset.X < 0.0)
	   				{
						FDamage *= 1.16;
						hitPos = HITLOC_RightLegBack;
						TPos = 5;
	   				}
	   				else
	   				{
						FDamage *= 0.84;
						hitPos = HITLOC_RightLegFront;
						TPos = 5;
	   				}
	  			}
	  			else
	  			{
	   				//Arms aren't meant to take a real hit.
	   				if (offset.X < 0.0)
	   				{
						bHeadshot = true;
						FDamage *= 1.25;
						hitPos = HITLOC_RightArmBack;
						TPos = 3;
	   				}
	   				else
	   				{
						hitPos = HITLOC_RightArmFront;
						TPos = 3;
	   				}
	  			}
	 		}
         		else if (offset.Y < (LegOffsetY * -1))
	 		{
	  			if (offset.Z < ArmOffsetZ)
	  			{
	   				//Legs are meant to take a beating.
	   				if (offset.X < 0.0)
	   				{
						FDamage *= 1.16;
						hitPos = HITLOC_LeftLegBack;
						TPos = 4;
	   				}
	   				else
	   				{
						FDamage *= 0.84;
						hitPos = HITLOC_LeftLegFront;
						TPos = 4;
	   				}
	  			}
	  			else
	  			{
	   				//Arms aren't meant to take a real hit.
	   				if (offset.X < 0.0)
	   				{
						bHeadshot = true;
						FDamage *= 1.25;
						hitPos = HITLOC_LeftArmBack;
						TPos = 2;
	   				}
	   				else
	   				{
						hitPos = HITLOC_LeftArmFront;
						TPos = 2;
	   				}
	  			}
	 		}
	 		else
			{
	  			//Torso is plated for full on war. However, its back is weak.
	  			if (offset.X < 0.0)
	  			{
					bHeadshot = true;
					FDamage *= 1.35;
					hitPos = HITLOC_TorsoBack;
					TPos = 1;
	  			}
	  			else
	  			{
					FDamage *= 0.8;
	 				hitPos = HITLOC_TorsoFront;
					TPos = 1;
	  			}
			}
		break;
		//---------------------------
		//ROLLER ROBOT!
		//---------------------------
		case "ROLLER":
		default:
	 		//Side armor is weaker than front armor.
	 		if (Abs(Offset.Y) > Abs(Offset.X))
	 		{
	  			if (Offset.Y > 0)
				{
					TPos = 5;
					HitPos = HITLOC_RightLegFront;
				}
	  			else
				{
					TPos = 4;
					HitPos = HITLOC_LeftLegFront;
				}
	  			FDamage *= 1.16;
	 		}
	 		else
	 		{
	  			//Front armor is tanky as hell.
	  			if (Offset.X > 0)
	  			{
	   				FDamage *= 0.84;
	   				HitPos = HITLOC_TorsoFront;
					TPos = 1;
	  			}
	  			//Rear armor is super weak.
	  			else
	  			{
					bHeadshot = true;
	   				HitPos = HITLOC_TorsoBack;
	   				FDamage *= 1.35;
					TPos = 1;
	  			}
	 		}
		break;
	}
	
	if (bHeadshot)
	{
	 	VPlayer = VMDBufferPlayer(LastDamager);
	 	if ((VPlayer != None) && (DamageType != 'PoisonEffect') && (!bOnFire || DamageType != 'Burned'))
		{
			PlayPlayerHeadshotSound(VPlayer);
		}
	}
	else if (bLastArmorHit)
	{
		TransferArmorHit(DeusExPlayer(LastDamager));
	}
	
	if ((class'VMDStaticFunctions'.Static.DamageTypeIsLethal(DamageType, false)) && (TPos > -1))
	{
		BonusFDamage = FloatDamageValues[TPos];
	}
	
	if (!bInvincible)
		Health -= int(FDamage + BonusFDamage);
	
	if ((class'VMDStaticFunctions'.Static.DamageTypeIsLethal(DamageType, false)) && (TPos > -1))
	{
		FloatDamageValues[TPos] = (FloatDamageValues[TPos] + FDamage) % 1.0;
	}
	
	//MADDERS: Nobody likes hitting a robo karkian 300 times with a DTS to kill it. Let's try 50.
	if ((Health > 800) && (IsA('Siddhartha')))
	{
		Health = 800;
	}
	return hitPos;
}

function InitGenerator()
{
	local Vector loc;

	if ((sparkGen == None) || (sparkGen.bDeleteMe))
	{
		loc = Location;
		loc.z += CollisionHeight/2;
		sparkGen = Spawn(class'ParticleGenerator', Self,, loc, rot(16384,0,0));
		if (sparkGen != None)
			sparkGen.SetBase(Self);
	}
}

function InitSmokeGenerator()
{
	local Vector loc;

	if ((SmokeGen == None) || (SmokeGen.bDeleteMe))
	{
		loc = Location;
		loc.z += CollisionHeight/2;
		SmokeGen = Spawn(class'ParticleGenerator', Self,, loc, rot(16384,0,0));
		if (SmokeGen != None)
		{
			SmokeGen.particleLifeSpan = 2.0;
			SmokeGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
			SmokeGen.particleDrawScale = 0.3 * (CollisionRadius / 25.35);
			SmokeGen.bRandomEject = False;
			SmokeGen.ejectSpeed = 20.0;
			SmokeGen.bGravity = False;
			SmokeGen.bParticlesUnlit = True;
			SmokeGen.frequency = 0.6;
			SmokeGen.riseRate = 6;
			
			SmokeGen.SetBase(Self);
		}
	}
}

function DestroyGenerator()
{
	if (sparkGen != None)
	{
		sparkGen.DelayedDestroy();
		sparkGen = None;
	}
}

function DestroySmokeGenerator()
{
	if (SmokeGen != None)
	{
		SmokeGen.DelayedDestroy();
		SmokeGen = None;
	}
}

//
// Special tick for robots to show effects of EMP damage
//
function Tick(float deltaTime)
{
	local float pct, mod, GSpeed;
	local Vector Loc;
	
	Super.Tick(deltaTime);
	
	//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
	if ((AmbientSound != None) && (Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
		if (GSpeed > 1.0)
		{
			SoundPitch = Min(255, 64 + (16 * (GSpeed - 1.0)));
		}
		else
		{
			SoundPitch = Max(1, 64 * GSpeed);
		}
	}
	
	if ((sparkGen != None) && (!sparkGen.bDeleteMe))
	{
		Loc = Location;
		Loc.z += CollisionHeight/2;
		SparkGen.SetLocation(Loc);
	}
	if ((SmokeGen != None) && (!SmokeGen.bDeleteMe))
	{
		Loc = Location;
		Loc.z += CollisionHeight/2;
		SmokeGen.SetLocation(Loc);
	}
	
   	// DEUS_EX AMSD All the MP robots have massive numbers of EMP hitpoints, not equal to the default.  In multiplayer, at least, only do this if
   	// they are DAMAGED.
	if ((StartingEMPHitPoints > EMPHitPoints) && (EMPHitPoints != 0) && ((Level.Netmode == NM_Standalone) || (EMPHitPoints < StartingEMPHitPoints)))
	{
		pct = (StartingEMPHitPoints - EMPHitPoints) / StartingEMPHitPoints;
		mod = pct * (1.0 - (2.0 * FRand()));
		DesiredSpeed = MaxDesiredSpeed + (mod * MaxDesiredSpeed * 0.5);
		SoundPitch = Default.SoundPitch + (mod * 8.0);
	}
	
	if ((EMPHitPoints <= 0) && (bEMPIsFatal))
	{
		TakeDamage(10000, None, Location, vect(0,0,0), 'Exploded');
	}
	
	if (CrazedTimer > 0)
	{
		CrazedTimer -= deltaTime;
		if (CrazedTimer < 0)
		{
			CrazedTimer = 0;
			RebootTimer = 5;
		}
	}

	if ((RebootTimer > 0) && (!IsInState('Dying')))
	{
		if (EMPHitPoints > 0)
			GotoState('Rebooting');
		
		RebootTimer -= deltaTime;
		if (RebootTimer < 0)
		{
			RebootTimer = 0;
			if (EMPHitPoints > 0)
				FollowOrders();
		}
	}
	
	if (CrazedTimer > 0)
		bReverseAlliances = true;
	else
		bReverseAlliances = false;
}


function ImpartMomentum(Vector momentum, Pawn instigatedBy)
{
	// nil
}

function bool ShouldFlee()
{
	return (Health <= MinHealth);
}

function bool ShouldDropWeapon()
{
	return false;
}

function bool VMDCanDropWeapon()
{
	return false;
}

//
// Called when the robot is destroyed
//
simulated event Destroyed()
{
	StopSound(targetAcquiredSound);
	StopSound(criticalDamageSound);
	
	Super.Destroyed();

	DestroyGenerator();
	DestroySmokeGenerator();
}

function Carcass SpawnCarcass()
{
	if ((VMDBufferPlayer(Instigator) != None) && (Instigator.Alliance == 'Player'))
	{
		VMDBufferPlayer(Instigator).OwedMayhemFactor++;
	}
	
	Explode(Location);
	
	return None;
}

function bool IgnoreDamageType(Name damageType)
{
	if ((damageType == 'TearGas') || (damageType == 'HalonGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage') || (damageType == 'Radiation'))
		return True;
	else if ((damageType == 'Poison') || (damageType == 'PoisonEffect'))
		return True;
	else if (damageType == 'KnockedOut')
		return True;
	else
		return False;
}

function SetOrders(Name orderName, optional Name newOrderTag, optional bool bImmediate)
{
	if (EMPHitPoints > 0)  // ignore orders if disabled
		Super.SetOrders(orderName, newOrderTag, bImmediate);
}


//MADDERS: Rev filler
simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
}


// ----------------------------------------------------------------------
// TakeDamageBase()
// ----------------------------------------------------------------------

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local float actualDamage;
	local int oldEMPHitPoints;
	local int oldHealth;
	
	local int TPos;
	local float FDamage, BonusFDamage, GSpeed;
	local vector loc, Offset;
	local EHitLocation hitPos;
	local VMDBufferPlayer VMPlayer;
	
	// Robots are invincible to EMP in multiplayer as well
	if (( Level.NetMode != NM_Standalone ) && (damageType == 'EMP') && (Self.IsA('MedicalBot') || Self.IsA('RepairBot')) )
		return;
	
	if ( bInvincible )
		return;
	
	// robots aren't affected by gas or radiation
	if (IgnoreDamageType(damageType))
		return;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	OldHealth = Health;
	
	//MADDERS: Track who shot us last.
	LastDamager = InstigatedBy;
	
	// enough EMP damage shuts down the robot
	if (damageType == 'EMP')
	{
		oldEMPHitPoints = EMPHitPoints;
		EMPHitPoints   -= Damage;

		// make smoke!
		if (EMPHitPoints <= 0)
		{
			EMPHitPoints = 0;
			if (oldEMPHitPoints > 0)
			{
				VMDEMPHook();
				PlaySound(sound'EMPZap', SLOT_None,,, (CollisionRadius+CollisionHeight)*8, 2.0 * GSpeed);
				InitGenerator();
				if (sparkGen != None)
				{
					sparkGen.LifeSpan = 6;
					sparkGen.particleTexture = Texture'Effects.Smoke.SmokePuff1';
					sparkGen.particleDrawScale = 0.3;
					sparkGen.bRandomEject = False;
					sparkGen.ejectSpeed = 10.0;
					sparkGen.bGravity = False;
					sparkGen.bParticlesUnlit = True;
					sparkGen.frequency = 0.3;
					sparkGen.riseRate = 3;
					sparkGen.spawnSound = Sound'Spark2';
				}
			}
			AmbientSound = None;
			if (GetStateName() != 'Disabled')
				GotoState('Disabled');
		}

		// make sparks!
		else if (sparkGen == None)
		{
			InitGenerator();
			if (sparkGen != None)
			{
				sparkGen.particleTexture = Texture'Effects.Fire.SparkFX1';
				sparkGen.particleDrawScale = 0.2;
				sparkGen.bRandomEject = True;
				sparkGen.ejectSpeed = 100.0;
				sparkGen.bGravity = True;
				sparkGen.bParticlesUnlit = True;
				sparkGen.frequency = 0.2;
				sparkGen.riseRate = 10;
				sparkGen.spawnSound = Sound'Spark2';
			}
		}

		return;
	}
	else if (damageType == 'NanoVirus')
	{
		if ((VMDBufferPlayer(InstigatedBy) != None) && (VMDBufferPlayer(InstigatedBy).HasSkillAugment('TagTeamScrambler')))
		{
			CrazedTimer += 10.0*Damage;
		}
		else
		{
			CrazedTimer += 0.5*Damage;
		}
		return;
	}
	
	// play a hit sound
	PlayTakeHitSound(Damage, damageType, 1);
	
	// increase the pitch of the ambient sound when damaged
	if (SoundPitch == Default.SoundPitch)
		SoundPitch += 16;
	
	actualDamage = Level.Game.ReduceDamage(Damage, DamageType, self, instigatedBy);
	FDamage = ActualDamage;
	
	LastInstigator = InstigatedBy;
	VMPlayer = GetLastVMP();
	if (LastWeaponDamageSkillMult >= 0)
	{
		FDamage *= LastWeaponDamageSkillMult;
		LastWeaponDamageSkillMult = -1.0;
	}
	TPos = VMDGetDamageLocation(HitLocation);
	if (!class'VMDStaticFunctions'.Static.DamageTypeIsLethal(DamageType, false))
	{
		TPos = -1;
	}
	else if (TPos > -1)
	{
		BonusFDamage = FloatDamageValues[TPos];
		
		if ((TPos == 0) && (bClosedSystemHit) && (VMPlayer != None) && (VMPlayer == InstigatedBy) && (VMPlayer.HasSkillAugment('TagTeamClosedHeadshot')))
		{
			FDamage *= 1.25;
		}
		
		bClosedSystemHit = false;
	}
	
	if (ReducedDamageType == 'All') //God mode
		FDamage = 0;
	else if (Inventory != None) //then check if carrying armor
		FDamage = Inventory.ReduceDamage(int(FDamage + BonusFDamage), DamageType, HitLocation);
	
	//MADDERS: Handle damage per location now.
	Offset = (HitLocation - Location) << Rotation;
	
	ActualDamage = float(int(FDamage + BonusFDamage));
	if (TPos > -1)
	{
		FloatDamageValues[TPos] = (FloatDamageValues[TPos] + FDamage) % 1.0;
	}
	LastFDamage = FDamage;
	
	hitPos = HandleDamage(ActualDamage, hitLocation, offset, damageType);
	if (!bPlayAnim || (actualDamage <= 0))
		hitPos = HITLOC_None;
	
	//if (!bInvincible)
	//	Health -= int(FDamage);
	
	if (Health <= 0)
	{
		ClearNextState();
		//PlayDeathHit(ActualDamage, hitLocation, damageType);
		if ( actualDamage > mass )
			Health = -1 * ActualDamage;
		Enemy = instigatedBy;
		Died(instigatedBy, damageType, HitLocation);
	}
	MakeNoise(1.0);
	
	// Transcended - Play the critical damage sound once if health is below 25% and the bot is not disabled.
	if (Health > 0 && Health <= (Default.Health / 4) && oldHealth > (Default.Health / 4) && EMPHitPoints > 0)
	{
        	PlayCriticalDamageSound();
	}
	//MADDERS, 5/27/23: Generate smoke when we're not doing so hot.
	if (Health > 0 && Health < (Default.Health / 3) && OldHealth > (Default.Health / 3))
	{
		InitSmokeGenerator();
	}
	
	//MADDERS, 11/1/24: Tweak for not reacting to turrets.
	if (DamageType != 'AutoShot')
	{
		ReactToInjury(instigatedBy, damageType, HITLOC_None);
	}
}

function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
{
	local Pawn oldEnemy;

	if (IgnoreDamageType(damageType))
		return;

	if (EMPHitPoints > 0)
	{
		if (damageType == 'NanoVirus')
		{
			oldEnemy = Enemy;
			FindBestEnemy(false);
			if (oldEnemy != Enemy)
				PlayNewTargetSound();
			instigatedBy = Enemy;
		}
		Super.ReactToInjury(instigatedBy, damageType, hitPos);
	}
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


function ComputeFallDirection(float totalTime, int numFrames,
                              out vector moveDir, out float stopTime)
{
}


function Explode(optional vector HitLocation)
{
	local int i, num;
	local float explosionRadius, GSpeed;
	local Vector loc;
	local DeusExFragment s;
	local ExplosionLight light;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	explosionRadius = (CollisionRadius + CollisionHeight) / 2;
	PlaySound(explosionSound, SLOT_None, 2.0,, explosionRadius*32, GSpeed);

	if (explosionRadius < 48.0)
		PlaySound(sound'LargeExplosion1', SLOT_None,,, explosionRadius*32, GSpeed);
	else
		PlaySound(sound'LargeExplosion2', SLOT_None,,, explosionRadius*32, GSpeed);

	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);

	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	for (i=0; i<explosionRadius/20+1; i++)
	{
		loc = Location + VRand() * CollisionRadius;
		if (explosionRadius < 16)
		{
			Spawn(class'ExplosionSmall',,, loc);
			light.size = 2;
		}
		else if (explosionRadius < 32)
		{
			Spawn(class'ExplosionMedium',,, loc);
			light.size = 4;
		}
		else
		{
			Spawn(class'ExplosionLarge',,, loc);
			light.size = 8;
		}
	}

	// spawn some metal fragments
	num = FMax(3, explosionRadius/6);
	for (i=0; i<num; i++)
	{
		s = Spawn(class'MetalFragment', Owner);
		if (s != None)
		{
			s.Instigator = Instigator;
			s.CalcVelocity(Velocity, explosionRadius);
			s.DrawScale = explosionRadius*0.075*FRand();
			s.Skin = GetMeshTexture();
			if (FRand() < 0.75)
				s.bSmoking = True;
		}
	}

	// cause the damage
	HurtRadius(0.5*explosionRadius, 8*explosionRadius, 'Exploded', 100*explosionRadius, Location);
}

function TweenToRunningAndFiring(float tweentime)
{
	bIsWalking = FALSE;
	TweenAnimPivot('Run', tweentime);
}

function PlayRunningAndFiring()
{
	bIsWalking = FALSE;
	LoopAnimPivot('Run');
}

function TweenToShoot(float tweentime)
{
	TweenAnimPivot('Still', tweentime);
}

function PlayShoot()
{
	PlayAnimPivot('Still');
}

function TweenToAttack(float tweentime)
{
	TweenAnimPivot('Still', tweentime);
}

function PlayAttack()
{
	PlayAnimPivot('Still');
}

function PlayTurning()
{
	LoopAnimPivot('Walk');
}

function PlayFalling()
{
}

function TweenToWalking(float tweentime)
{
	bIsWalking = True;
	TweenAnimPivot('Walk', tweentime);
}

function PlayWalking()
{
	bIsWalking = True;
	LoopAnimPivot('Walk');
}

function TweenToRunning(float tweentime)
{
	bIsWalking = False;
	PlayAnimPivot('Run',, tweentime);
}

function PlayRunning()
{
	bIsWalking = False;
	LoopAnimPivot('Run');
}

function TweenToWaiting(float tweentime)
{
	TweenAnimPivot('Idle', tweentime);
}

function PlayWaiting()
{
	PlayAnimPivot('Idle');
}

function PlaySwimming()
{
	LoopAnimPivot('Still');
}

function TweenToSwimming(float tweentime)
{
	TweenAnimPivot('Still', tweentime);
}

function PlayLanded(float impactVel)
{
	bIsWalking = True;
}

function PlayDuck()
{
	TweenAnimPivot('Still', 0.25);
}

function PlayRising()
{
	PlayAnimPivot('Still');
}

function PlayCrawling()
{
	LoopAnimPivot('Still');
}

function PlayFiring()
{
	LoopAnimPivot('Still',,0.1);
}

function PlayReloadBegin()
{
	PlayAnimPivot('Still',, 0.1);
}

function PlayReload()
{
	PlayAnimPivot('Still');
}

function PlayReloadEnd()
{
	PlayAnimPivot('Still',, 0.1);
}

function PlayCowerBegin() {}
function PlayCowering() {}
function PlayCowerEnd() {}

function PlayDisabled()
{
	TweenAnimPivot('Still', 0.2);
}

function PlayWeaponSwitch(Weapon newWeapon)
{
}

function PlayIdleSound()
{
}

//MADDERS: Only play this within a select range, and for bots that actually do something of note.
//You can extend this function if you actually do something new, of course.
function SpoofBarkLine(DeusExPlayer DXP, string SpoofLine, optional float DisplayTime)
{
	if (DXP == None) return;
	if (VSize(DXP.Location - Location) > 640) return;
	if (DisplayTime < 0 || DisplayTime ~= 0.0) DisplayTime = 3.5;
	
	if (VMDOtherIsName("Security") || VMDOtherIsName("Military"))
	{
		Super.SpoofBarkLine(DXP, SpoofLine, DisplayTime);
	}
}

function PlayScanningSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextScanning);
	
	if (!bDeleteMe)
		PlaySound(SearchingSound, SLOT_None,,, 2048, GSpeed);
	if (!bDeleteMe)
		PlaySound(SpeechScanning, SLOT_None,,, 2048, GSpeed);
}

function PlaySearchingSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextScanning);
	
	if (!bDeleteMe)
		PlaySound(SearchingSound, SLOT_None,,, 2048, GSpeed);
	if (!bDeleteMe)
		PlaySound(SpeechScanning, SLOT_None,,, 2048, GSpeed);
}

function PlayTargetAcquiredSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextTargetAcquired);
	
	if (!bDeleteMe)
		targetAcquiredSound = PlaySound(SpeechTargetAcquired, SLOT_None,,, 2048, GSpeed);
}

function PlayTargetLostSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextTargetLost);
	
	if (!bDeleteMe)
		PlaySound(SpeechTargetLost, SLOT_None,,, 2048, GSpeed);
}

function PlayGoingForAlarmSound()
{
}

function PlayOutOfAmmoSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextOutOfAmmo);
	
	if (!bDeleteMe)
		PlaySound(SpeechOutOfAmmo, SLOT_None,,, 2048, GSpeed);
}

function PlayCriticalDamageSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextCriticalDamage);
	
	if (!bDeleteMe)
		criticalDamageSound = PlaySound(SpeechCriticalDamage, SLOT_None,,, 2048, GSpeed);
}

function PlayAreaSecureSound()
{
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	SpoofBarkLine(DeusExPlayer(GetPlayerPawn()), TextAreaSecure);
	
	if (!bDeleteMe)
		PlaySound(SpeechAreaSecure, SLOT_None,,, 2048, GSpeed);
}

state Disabled
{
	ignores bump, frob, reacttoinjury;
	function BeginState()
	{
		StandUp();
		BlockReactions(true);
		bCanConverse = False;
		SeekPawn = None;
		bEmitDistress = false;
	}
	function EndState()
	{
		ResetReactions();
		bCanConverse = True;
	}

Begin:
	Acceleration = vect(0,0,0);
	DesiredRotation = Rotation;
	PlayDisabled();

Disabled:
}

state Fleeing
{
	function PickDestination()
	{
	}
	
	function PickDestinationPlain()
	{
		local int     iterations;
		local float   magnitude;
		local rotator rot1;

		iterations = 4;
		magnitude  = 400*(FRand()*0.4+0.8);  // 400, +/-20%
		rot1       = Rotator(Location-Enemy.Location);
		if (!AIPickRandomDestination(40, magnitude, rot1.Yaw, 0.6, rot1.Pitch, 0.6, iterations,
		                             FRand()*0.4+0.35, destLoc))
			destLoc = Location;  // we give up
	}
}

//MADDERS: Rev filler.
state Rebooting
{
	ignores bump, frob, reacttoinjury;
	function BeginState()
	{
	}
	function EndState()
	{
	}
	
Begin:
	Acceleration = vect(0,0,0);
	if (HasAnim('Still')) PlayAnimPivot('Still');
Rebooting:
}

// ------------------------------------------------------------
// IsImmobile
// If the bots are immobile, then we can make them always relevant
// ------------------------------------------------------------
function bool IsImmobile()
{
   	local bool bHasReactions;
   	local bool bHasFears;
   	local bool bHasHates;
	
   	if (Orders != 'Standing')
      		return false;
	
   	bHasReactions = (bReactFutz || bReactPresence || bReactLoudNoise || bReactAlarm || bReactShot || bReactCarcass || bReactDistress || bReactProjectiles);
	
   	bHasFears = (bFearHacking || bFearWeapon || bFearShot || bFearInjury || bFearIndirectInjury || bFearCarcass || bFearDistress || bFearAlarm || bFearProjectiles);
	
   	bHasHates = (bHateHacking || bHateWeapon || bHateShot || bHateInjury || bHateIndirectInjury || bHateCarcass || bHateDistress);
	
   	return ((!bHasReactions) && (!bHasFears) && (!bHasHates));
}

function bool WillTakeStompDamage(Actor stomper)
{
	if (Robot(Stomper) != None)
	{
		return true;
	}
	else
	{
		return false;
	}
}

defaultproperties
{
     bFearEMP=True
     bCanGrabWeapons=False
     bCanClimbLadders=False
     bRobotVision=True
     bAerosolImmune=True
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
     MaxStepHeight=32.000000
     TextTargetAcquired="Target acquired."
     TextTargetLost="Target lost."
     TextOutOfAmmo="Out of ammo."
     TextCriticalDamage="Critical damage!"
     TextScanning="Scanning area..."
     TextAreaSecure="Area secure."
     bReactLoudNoise=False
     
     EMPHitPoints=50
     explosionSound=Sound'DeusExSounds.Robot.RobotExplode'
     maxRange=512.000000
     MinHealth=0.000000
     RandomWandering=0.150000
     bCanOpenDoors=False // Transcended - No longer
     bCanBleed=False
     bShowPain=False
     bCanSit=False
     bAvoidAim=False
     bAvoidHarm=False
     bHateShot=False
     bReactAlarm=True
     bReactCarcass=False
     bReactProjectiles=False
     bEmitDistress=False
     RaiseAlarm=RAISEALARM_Never
     bMustFaceTarget=False
     FireAngle=60.000000
     MaxProvocations=0
     SurprisePeriod=0.000000
     EnemyTimeout=7.000000
     walkAnimMult=1.000000
     bCanStrafe=False
     bCanSwim=False
     bIsHuman=False
     JumpZ=0.000000
     MaxStepHeight=4.000000
     Health=50
     HitSound1=Sound'DeusExSounds.Generic.Spark1'
     HitSound2=Sound'DeusExSounds.Generic.Spark1'
     Die=Sound'DeusExSounds.Generic.Spark1'
     VisibilityThreshold=0.006000
     BindName="Robot"
     bSpawnBubbles=False // Transcended - added
}
