//=============================================================================
// VMDBufferPawn.
//=============================================================================
class VMDBufferPawn extends ScriptedPawn
	abstract;

//++++++++++++++++++++++++
//MADDERS ADDITIONS!
var(MADDERS) int AttackStateLaps, ConsecutiveShittyPaths;
var(MADDERS) Actor LastShittyPathTarget;
var float OldAgitation;

var bool bSetupBuffedHealth, bAppliedSpecial, bAppliedSpecial2, bBuffedVision, bBuffedSenses, bBuffedAccuracy; //Already better health scaling than &%)*. God save us all
var int MedkitHealthLevel; //MADDERS, 12/27/23: In some special cases, we may have a special threshold.
var float HealthScaleTimer, MedkitUseTimer, FireExtinguisherUseTimer, WeaponSwapTimer;
var(MADDERS) float OverrideHeight; //For locking collision height on reskinned chars.
var bool bExplosive, bAerosolImmune, bEverNotFrobbed; //Watch me check for this super EZ.
var float LastHitSeconds; //Set and reset as needed.
var int SeedSet; //Binary sum.
var int SelfAssessedSeed; //MADDERS, 10/2/25: New means of getting seeds - proves more reliable than other means.
var float TimeSinceEngaged, TimeSincePickpocket; //If < 0.15

//Silent kills yo.
var bool bDoScream, bScreamStart, bStatusAlert, bDamageGateInTact, bDamageGateBullshitFrame, bStunnedThisFrame; //Fast kills are now silent.
var float ScreamTimer, StatusAlertTime, TurretFleeTimer;
var float ArmorStrength; //How much damage reduction for armor hits?

//Do some stuff with tech goggles here.
var bool bTechGogglesActive;
var float TechGogglesCheckTimer, TechGogglesSeekCooldown, TechGogglesRadius;
var TechGoggles ActiveGoggles;

//Sprint system. Used in niche circumstances.
var bool bSprinting, bStrafing;
var float SprintStamina, SprintStaminaMax;

//Ladder climbing? Holy fucking shit, m8. Can I even be stopped?
var bool bClimbingLadder, bLadderClimbForward, bJumpedFromLadder, bCanClimbLadders;
var int LadderJumpLoops;
var float LadderJumpZMult, LadderCheckinTimer;
var Vector LastLadderPoint, LastLadderCheckInPos;
var VMDLadderPoint TargetedLadderPoint, LastUsedLadder;
var EPhysics LastPhysics;

//Hacks? Sure, hacks section here.
var float VMDClearTargetTime, LastTickDelta;

var bool bDoesntSniff, bRobotVision;
var name SmellTypes[10];
var name LastSmellType;
var VMDSmellManager IgnoredSmells[20];
var localized string FakeBarkSniffing;
var localized string MessagePickpocketingSuccess, MessagePickpocketingFailure, MessagePickpocketingSpotted;

//Used for drug FX.
var float StoredScaleGlow;
var byte StoredFatness;
var Texture StoredSkin, StoredTexture;
var Texture StoredMultiskins[8];

//MADDERS: Don't do much for us. We don't matter.
var bool bInsignificant, bCorpseUnfrobbable;
var bool bDrawShieldEffect;

//MADDERS: Body armor and helmets.
var(MADDERS) bool bHasHelmet, bHasHeadArmor, bHasBodyArmor, bFearEMP;
var(MADDERS) byte ArmorNoiseIndex[2];
var(MADDERS) bool bMilitantCower;
var(MADDERS) int HelmetDamageThreshold, ArmorDamageThreshold;
var(MADDERS) int CaptiveEscapeSteps;

var float StartingGroundSpeed, StartingBuoyancy, StartingBaseAccuracy, LastEnemyHealthScale; //MADDERS, 5/26/23: For slowdown effects. Neat.
var bool bDebugFractionalDamage;
var bool bNoticedPoisonOrigin, bFirstSearchedForPoison;
var VMDPoisonScout OwnedPoisonScout;
var int TotalPoisonDamage, StartingHealthValues[7]; //Head, Body, Left Arm, Right Arm, Left Leg, Right Leg... And lastly, Health itself.
var float PoisonGuessingFudge, MaxGuessingFudge;
var float LastWeaponDamageSkillMult, LastFDamage, FloatDamageValues[6]; //Same as starting health values, but with no health brand health var.
var Vector FirstPoisonOrigin;

//MADDERS: Grenade looting related.
var bool bEverDrewGrenade;
var float GrenadeSkillAugmentCheckTime;
var Vector LastPredictedGrenadePos;
var rotator LastPredictedGrenadeAngle;

var byte bItemUnnatural[8]; //Are our items unnatural? Used by mayhem system.

//MADDERS: Stuck projectiles looting.
var class<Inventory> StuckProjectiles[4];
var byte StuckCount[4];

//MADDERS: Stun update.
var float StunLengthModifier, PoisonReactThreshold;

//MADDERS, 6/3/22: How good are we with pickups we wear?
//Also, how good are we with medkits?
var(MADDERSSKILLS) int EnviroSkillLevel, MedicineSkillLevel;
var(MADDERSSKILLS) float ROFCounterWeight, DifficultyROFWeight;

var(MADDERSDIFF) int DifficultyExtraSearchSteps;
var(MADDERSDIFF) float DifficultyVisionRangeMult, DifficultyReactionSpeedMult, EnemyGuessingFudge;

//MADDERS: Closed system hits, and armor hits.
var bool bClosedSystemHit, bLastArmorHit, bArsonistIgnited;
var Pawn LastInstigator;
var VMDCorpseBlocker CorpseBlocker;

var() float DrawShieldCooldown, DrawAugShieldCooldown, SmellSniffCooldown;
var Pawn LastDamager; //Use this for not doing spam headshot calls. Yeet.

var Actor LastSoughtExtinguisher;
var FireExtinguisher ActiveExtinguisher;
var bool bCanGrabWeapons;
var DeusExWeapon LastSoughtWeapon;
var bool bMayhemSuspect, bAntiMayhemSuspect; //Flag our corpse with this when it's placed. Also give us good boy points if we're alive after we're done.

var VMDBufferPlayer LastVMP;

//WCCC, 3/17/19: "Let me guess... Experimental?" "Very."
//Re-pasted 11/30/20 for VMD. This should be fun.
//-------------------
//When set to 0.0 (default), these don't run.
//When set to any other level, multiply effective height by the value in question.
//These apply to both sending footstep noise, and receiving noise in general.
//For optimization, it's recommended to keep these defaulted to 0.0.
//--------------------
//Both receive and send sound can be altered by setting ReceiveNoiseHeightTolerance and
//SendNoiseHeightTolerance. At 0 or less, the values do nothing. At 1.0, output is normal.
//Any value less than 1.0 will act as a divisor for how much height is accounted for.
//
//Example: If 1000 distance is present and 200 units of it is height, with a divisor of 0.5, let's
//do the math. 200 / 0.5 = 400. 1000 - 200 + 400 = 1200. Resulting in 83% output at said conditions.
//
//My honest to god advice: Play with the setting, and see what works. Use this math formula
//to sketch some examples in a ballpark fashion. 

var(VMDExperimental) float ReceiveNoiseHeightTolerance;
var(VMDExperimental) float SendNoiseHeightTolerance;

//Less experimental, but this is our footstep sending range.
//In vanilla, this defaults to 768 and 2048, respectively.
var() float FootstepProjectRadius;
var() float FootstepProjectMaxRadius;

//MADDERS, 8/26/23: Bullshit hack to stop running iterators every footstep, specifically on maps that don't have any textures.
var transient int HousingScriptedTexcount;

//MADDERS, 12/27/23: Aug system. Neato.
var(VMDAugs) bool bHasAugmentations, bMechAugs, bKillswitchEngaged, bAugsGuardDown; //Ayooo
var(VMDAugs) int LastAugActivateSoundID, LastAugDeactivateSoundID;
var(VMDAugs) float Energy, EnergyMax,
			BiocellUseTimer, SpeedAfterimageTimer,
			LastSpeedAugValue, LastLungAugValue;
var(VMDAugs) string ActiveAugStr;

//MADDERS, 12/27/23: Barf, but for selectively used augs, save them for faster reference.
//Let's not go gouging into our entire aug chain 5 times every frame of the game.
var(VMDAugs) VMDBufferAugmentation CurSpeedAug, CurTargetAug, CurCombatAug, CurCloakAug, CurVisionAug, CurStealthAug, BulkReferenceAug;
			//CurRadarTransAug, CurSpydroneAug;

var(VMDAugs) class<VMDBufferAugmentation> DefaultAugs[10];
var(VMDAugs) VMDNPCAugmentationManager AugmentationSystem;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//DXT additions.
var Pawn Burner;         // person who initiated Burned damage
var float LaserCheckTimer;
var() bool bNoGunQuestioning; 	// do I not care about a gun being pointed at me?
var() float dripRate;
var() float waterDripCounter;

var() bool bLookAtPlayer;			// Do we look at the player as they get near (10ft)?
var() bool bLookingReset;			// Have we been told to look forward?
var() float playerLastSeenTimer;	// When was the last time we saw the player?
var() float lookCheckTime;			// Internal, for performance
var() float lookingAtPlayerTime;	// How long have we been looking at the player?

var bool bClientHostileTowardsPlayers; // From HX, are pawns hostile to the player?
var bool bSuspiciousToPlayer; //Uuuuuh... Not sure WTF this dodes, but it's DXT stuff, so whatever.

var() bool bExtraSuspicious;		// Look around while patrolling?
var() float patrolLookTimer;

var() bool bRecognizeMovedObjects; // Notice objects that have been moved into sight.

var bool bJustTurned; //MADDERS, 11/29/21: Technically G-Flex, but whatever.

var DeusExPlayer localPlayer;

function bool Facelift(bool bOn)
{
}

function bool VMDShouldUseAdvancedMelee()
{
	local VMDBufferPlayer VMP;
	
	if (Animal(Self) != None || Robot(Self) != None || HumanThug(Self) != None || HumanCivilian(Self) != None)
	{
		return false;
	}
	
	if (StartingHealthValues[6] < 100*LastEnemyHealthScale)
	{
		return false;
	}
	
	VMP = GetLastVMP();
	if ((VMP != None) && (VMP.bUseAdvancedMelee))
	{
		return true;
	}
	
	return false;
}

function bool VMDCanRunWithAnyWeapon()
{
	return false;
}

function NavigationPoint VMDFindShittyPathTo(Vector Destination, Vector Start, float SearchRadius, optional bool bNeedFastTrace)
{
	local int i;
	local float TDist, BestDist;
	local Vector RadCenter, AddLevel, UseLevel;
	local NavigationPoint TPoint, BestPoint;
	
	AddLevel = Destination - Start;
	UseLevel = AddLevel;
	TDist = 100;
	for (i=0; i<4; i++)
	{
		RadCenter = Start + (UseLevel * (float(i+1) / 4.0));
		forEach RadiusActors(class'NavigationPoint', TPoint, SearchRadius, RadCenter)
		{
			TDist = VSize(Location - TPoint.Location);
			if ((TDist > BestDist) && (!bNeedFastTrace || FastTrace(TPoint.Location, Destination)) && (ActorReachable(TPoint)))
			{
				BestDist = TDist;
				BestPoint = TPoint;
			}
		}
	}
	
	if (BestPoint == None || BestDist < SearchRadius * 0.5)
	{
		UseLevel = AddLevel >> Rot(0, 4096, 0);
		for (i=0; i<4; i++)
		{
			RadCenter = Start + (UseLevel * (float(i+1) / 4.0));
			forEach RadiusActors(class'NavigationPoint', TPoint, SearchRadius, RadCenter)
			{
				TDist = VSize(Location - TPoint.Location);
				if ((TDist > BestDist) && (!bNeedFastTrace || FastTrace(TPoint.Location, Destination)) && (ActorReachable(TPoint)))
				{
					BestDist = TDist;
					BestPoint = TPoint;
				}
			}
		}
		if (BestPoint == None || BestDist < SearchRadius * 0.5)
		{
			UseLevel = AddLevel >> Rot(0, -4096, 0);
			for (i=0; i<4; i++)
			{
				RadCenter = Start + (UseLevel * (float(i+1) / 4.0));
				forEach RadiusActors(class'NavigationPoint', TPoint, SearchRadius, RadCenter)
				{
					TDist = VSize(Location - TPoint.Location);
					if ((TDist > BestDist) && (!bNeedFastTrace || FastTrace(TPoint.Location, Destination)) && (ActorReachable(TPoint)))
					{
						BestDist = TDist;
						BestPoint = TPoint;
					}
				}
			}
		}
	}
	
	//MADDERS, 5/4/25: Forced cludge to stop repetitive paths when we think this is a "solution", but is just on repeat.
	//Don't clear this after returning none either
	if (BestPoint != LastShittyPathTarget)
	{
		LastShittyPathTarget = BestPoint;
		return BestPoint;
	}
	else
	{
		return None;
	}
}

function float VMDGetGuessingFudge()
{
	local float Ret;
	
	if (PoisonCounter > 0)
	{
		Ret = FClamp(EnemyGuessingFudge + PoisonGuessingFudge, 0.0, MaxGuessingFudge);
	}
	else
	{
		Ret = FClamp(EnemyGuessingFudge, 0.0, MaxGuessingFudge);
	}
	
	return Ret;
}

function Actor VMDFindTurretComputer()
{
	local int i;
	local float BestDist;
	local Actor Best;
	local AutoTurret TTurret;
	local Computers TComp;
	local ComputerSecurity TSec;
	local PathNode TNode;
	
	forEach AllActors(class'AutoTurret', TTurret)
	{
		if (TTurret.CurTarget == Self)
		{
			forEach AllActors(class'ComputerSecurity', TSec)
			{
				for(i=0; i<ArrayCount(TSec.Views); i++)
				{
					if (TSec.Views[i].TurretTag == TTurret.Tag)
					{
						TComp = TSec;
						break;
					}
				}
				if (TComp != None)
				{
					break;
				}
			}
			break;
		}
	}
	
	if (TComp != None)
	{
		forEach AllActors(class'PathNode', TNode)
		{
			if (Best == None || VSize(TNode.Location - TComp.Location) < BestDist)
			{
				BestDist = VSize(TNode.Location - TComp.Location);
				Best = TNode;
			}
		}
	}
	
	return Best;
}

//MADDERS, 10/31/24: Quick hack for tweaking water zone sounds based on game speed.
event FootZoneChange(ZoneInfo newFootZone)
{
	local float splashSize, GSpeed;
	local vector HitNormal, HitLocation;
	local actor HitActor, splash;
	
	if ( Level.NetMode == NM_Client )
		return;
	if ( Level.TimeSeconds - SplashTime > 0.25 ) 
	{
		GSpeed = 1.0;
		if (Level.Game != None)
		{
			GSpeed = Level.Game.GameSpeed;
		}
		
		SplashTime = Level.TimeSeconds;
		if (Physics == PHYS_Falling)
			MakeNoise(1.0);
		else
			MakeNoise(0.3);
		if ( FootRegion.Zone.bWaterZone )
		{
			if ( !newFootZone.bWaterZone && (Role==ROLE_Authority) )
			{
				if ( FootRegion.Zone.ExitSound != None )
					PlaySound(FootRegion.Zone.ExitSound, SLOT_Interact, 1,,, GSpeed); 
				if ( FootRegion.Zone.ExitActor != None )
					Spawn(FootRegion.Zone.ExitActor,,,Location - CollisionHeight * vect(0,0,1));
			}
		}
		else if ( newFootZone.bWaterZone && (Role==ROLE_Authority) )
		{
			splashSize = FClamp(0.000025 * Mass * (300 - 0.5 * FMax(-500, Velocity.Z)), 1.0, 4.0 );
			if ( newFootZone.EntrySound != None )
			{
				HitActor = Trace(HitLocation, HitNormal, 
						Location - (CollisionHeight + 40) * vect(0,0,0.8), Location - CollisionHeight * vect(0,0,0.8), false);
				if ( HitActor == None )
					PlaySound(newFootZone.EntrySound, SLOT_Misc, 2 * splashSize,,, GSpeed);
				else 
					PlaySound(WaterStep, SLOT_Misc, 1.5 + 0.5 * splashSize,,, GSpeed);
			}
			if( newFootZone.EntryActor != None )
			{
				splash = Spawn(newFootZone.EntryActor,,,Location - CollisionHeight * vect(0,0,1));
				if ( splash != None )
					splash.DrawScale = splashSize;
			}
			//log("Feet entering water");
		}
	}
	
	if (FootRegion.Zone.bPainZone)
	{
		if ( !newFootZone.bPainZone && !HeadRegion.Zone.bWaterZone )
			PainTime = -1.0;
	}
	else if (newFootZone.bPainZone)
		PainTime = 0.01;
}

function int VMDGetHousingScriptedTexCount()
{
	local int TCount;
	local VMDHousingScriptedTexture STex;
	
	if (HousingScriptedTexCount < 0) return -1;
	
	forEach AllObjectS(class'VMDHousingScriptedTexture', STex)
	{
		TCount++;
		break; //Hack. We just need to know they exist.
	}
	
	if (TCount > 0) HousingScriptedTexCount = TCount;
	else HousingScriptedTexCount = -1;
	
	return HousingScriptedTexCount;
}

state VMDClimbingLadder
{
	function ReactToInjury(Pawn instigatedBy, Name damageType, EHitLocation hitPos)
	{
		local Pawn oldEnemy;
		local bool bHateThisInjury;
		local bool bFearThisInjury;

		if ((health > 0) && (bLookingForInjury || bLookingForIndirectInjury))
		{
			oldEnemy = Enemy;

			bHateThisInjury = ShouldReactToInjuryType(damageType, bHateInjury, bHateIndirectInjury);
			bFearThisInjury = ShouldReactToInjuryType(damageType, bFearInjury, bFearIndirectInjury);

			if (bHateThisInjury)
				IncreaseAgitation(instigatedBy, 1.0);
			if (bFearThisInjury)
				IncreaseFear(instigatedBy, 2.0);

			if (ReadyForNewEnemy())
				SetEnemy(instigatedBy);

			if (ShouldFlee())
			{
				SetDistressTimer();
				PlayCriticalDamageSound();
				if (RaiseAlarm == RAISEALARM_BeforeFleeing)
				{
					SetNextState('Alerting');
				}
				else
				{
					SetNextState('Fleeing');
				}
			}
			else
			{
				SetDistressTimer();
				if (oldEnemy != Enemy)
					PlayNewTargetSound();
				SetNextState('Attacking', 'ContinueAttack');
			}
			GotoDisabledState(damageType, hitPos);
		}
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	
	function bool ShouldCrouch()
	{
		return false;
	}
	
	function SetFall()
	{
	}
	
	function EndCrouch()
	{
		if (bCrouching)
		{
			bCrouching = false;
			ResetBasedPawnSize();
		}
	}
	
	function BeginState()
	{
		StandUp();
		
		bCanFire = false;
		bFacingTarget = false;
		
		//SwitchToBestWeapon();
		
		ResetReactions();
		if (ShouldFlee())
		{
			BlockReactions();
		}
		bCanConverse = False;
		bStasis = False;
		
		CrouchTimer = 0;
		EnableCheckDestLoc(false);
	}
	
	function EndState()
	{
		//MADDERS, 8/8/24: Clear our ladder shit if we were frozen.
		if (Physics == PHYS_Rotating)
		{
			SetFall();
		}
		
		EnableCheckDestLoc(false);
		bCanFire = false;
		bFacingTarget = false;
		
		ResetReactions();
		bCanConverse = True;
		bAttacking = False;
		bStasis = True;
		bReadyToReload = false;
		
		EndCrouch();
	}
	
	function Landed(Vector HitNormal)
	{
		local float LandVol, GSpeed;
		local Vector LegLocation;
		
		if (bJumpedFromLadder)
		{
			bJumpedFromLadder = false;
		}
		
		if ( (Velocity.Z < -0.8 * FMax(150, JumpZ)) || bUpAndOut)
		{
			PlayLanded(Velocity.Z);
			if (Velocity.Z < -700)
			{
				legLocation = Location + vect(-1,0,-1);			// damage left leg
				TakeDamage(-0.14 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
				legLocation = Location + vect(1,0,-1);			// damage right leg
				TakeDamage(-0.14 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
				legLocation = Location + vect(0,0,1);			// damage torso
				TakeDamage(-0.04 * (Velocity.Z + 700), Self, legLocation, vect(0,0,0), 'fell');
			}
			landVol = Velocity.Z/JumpZ;
			landVol = 0.005 * Mass * FMin(5, landVol * landVol);
			
			GSpeed = 1.0;
			if ((Level != None) && (Level.Game != None))
			{
				GSpeed = Level.Game.GameSpeed;
			}
			
			if (!FootRegion.Zone.bWaterZone)
			{
				PlaySound(Land, SLOT_Interact, FMin(20, landVol),,, GSpeed);
			}
		}
		
		Global.Landed(HitNormal);
	}
	
ClimbLadder:
	if (TargetedLadderPoint == None || !FastTrace(TargetedLadderPoint.Location, Location))
	{
		DestPoint = None;
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
		}
		else
		{
			SetPhysics(PHYS_Falling);
		}
		TweenAnim('Land', 0.1);
		
	}
	else
	{
		bCanFire = false;
		TweenAnim('Land', 0.1);
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
		}
		else
		{
			SetPhysics(PHYS_Falling);
		}
		if ((VMDLadderIsBelow()) && (VMDLadderDropClear()))
		{
			Velocity = GroundSpeed * VMDFlatLadderDirectionNormal();
			//Fall into the ground really fast. Ugly.
			if (VMDLadderIsBelow())
			{
				Velocity.Z = -120;
			}
		}
		else
		{
			Velocity = GroundSpeed * Normal(TargetedLadderPoint.Location - Location);
		}
		Acceleration = Velocity;
		TurnTo(Location + (TargetedLadderPoint.LadderNormal*40));
		if ((VMDLadderSpaceClear()) && (VMDIsOverlappingLadder()))
		{
			TargetedLadderPoint.AdvanceLadderSequence(Self);
		}
		else
		{
			Sleep(0.05);
			GoTo('ClimbLadder');
		}
	}
	
JumpLadder:
	if (TargetedLadderPoint == None)
	{
		DestPoint = None;
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
		}
		else
		{
			SetPhysics(PHYS_Falling);
		}
		TweenAnim('Land', 0.1);
		GoTo('End');
	}
	else
	{
		//TurnTo(Location + VMDFlatLadderJumpNormal()*40);
		VMDJumpTowardsLadder();
		LadderJumpLoops = 0;
		while(!VMDIsOverlappingLadder())
		{
			if ((LadderJumpLoops >= 20) && (Velocity.Z < 10) && (TargetedLadderPoint.Location.Z > Location.Z || !VMDLadderDropClear()))
			{
				break;
			}
			
			Velocity.X = GroundSpeed * VMDFlatLadderDirectionNormal(true).X;
			Velocity.Y = GroundSpeed * VMDFlatLadderDirectionNormal(true).Y;
			Sleep(0.05);
			LadderJumpLoops += 1;
		}
		TargetedLadderPoint.AdvanceLadderSequence(Self);
	}
JumpLastLadder:
	if (TargetedLadderPoint == None)
	{
		DestPoint = None;
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
		}
		else
		{
			SetPhysics(PHYS_Falling);
		}
		TweenAnim('Land', 0.1);
		GoTo('End');
	}
	else
	{
		//TurnTo(Location + VMDFlatLadderJumpNormal()*40);
		VMDJumpTowardsLadder();
		VMDClearLadderData();
		Sleep(0.75);
		GoTo('End');
	}
AwaitLanding:
	while((Physics == PHYS_Falling) && (Region.Zone != None) && (!Region.Zone.bWaterZone) && (bJumpedFromLadder) && (Health > 0))
	{
		Sleep(0.15);
	}
	
	if (Health > 0)
	{
		GoTo('ClimbLadder');
	}
	else
	{
		GoToState('Dying');
	}
End:
	VMDClearLadderData();
	if (ShouldFlee())
	{
		SetDistressTimer();
		//PlayCriticalDamageSound();
		if (RaiseAlarm == RAISEALARM_BeforeFleeing)
		{
			GoToState('Alerting');
		}
		else
		{
			GoToState('Fleeing');
		}
	}
	else
	{
		FollowOrders();
	}
}

function VMDAddLadderDeathFlag()
{
	local VMDLadderDeathFlag TFlag;
	
	TFlag = Spawn(class'VMDLadderDeathFlag',,, Location);
	if (TargetedLadderPoint != None)
	{
		TargetedLadderPoint.LastDeathFlag = TFlag;
	}
}

function bool VMDIsTouchingLadder()
{
	local int TexFlags, i, Cycles;
	local float GrabDist;
	local name TexName, TexGroup;
	local Rotator TRot;
	local Vector EndTrace, StartTrace, HitLocation, HitNormal, TVect;
	local Actor Target;
	
	GrabDist = 24;
	
	// MADDERS, 8/4/24: Here we are again. More stupid solutions because native functionality doesn't work.
	// In this case, using even a SINGLE axis of extents in this function will cause a GPF in the game...
	// So fuck it. Do lots of mini traces, looking for ladder association.
	// Right now this is quite dense, but that's to account for a huge area required. Some ladders are quite elusive, but this seems to find them all.
	for (i=0; i<36; i++)
	{
		TVect.Z = -1.0 + (0.5 * (i%9));
		TRot.Yaw = (i / 9) * 16384;
		StartTrace = Location + (TVect * CollisionHeight);
		EndTrace = StartTrace + (Vector(TRot) * (CollisionRadius + GrabDist));
		foreach TraceTexture(class'Actor', Target, TexName, TexGroup, texFlags, HitLocation, HitNormal, EndTrace, StartTrace)
		{
			if ((target == Level) || target.IsA('Mover'))
				break;
		}
		
		if (TexGroup == 'Ladder')
		{
			return true;
		}
	}
	
	return false;
}

function bool VMDLadderIsBelow()
{
	//Is our ladder below us? Simple question.
	if (TargetedLadderPoint == None || TargetedLadderPoint.Location.Z >= LastLadderPoint.Z)
	{
		return false;
	}
	else
	{
		return true;
	}
}

function bool VMDIsOverlappingLadder()
{
	local bool Ret, bNeedGreater;
	local int TSign;
	local float TMult;
	local name TState;
	local Vector LocA, LocB;
	
	if (TargetedLadderPoint == None)
	{
		return false;
	}
	
	LocA = Location;
	LocB = TargetedLadderPoint.Location;
	
	LocA.Z = 0;
	LocB.Z = 0;
	
	//So this is really fucking dumb, I won't sugarcoat it. Try to squeeze in close with the move point intended.
	//After that, allow us to be slightly wrong if we're about to jump.
	//If we're going down or up, try to match the Z as close as we can.
	TMult = 1.0;
	TState = GetStateName();
	if (TState == 'GoingTo')
	{
		TMult = 2.0;
	}
	else
	{
		TMult = 1.5;
	}
	
	if (VSize(LocB - LocA) < CollisionRadius*0.65*TMult)
	{
		if (!bClimbingLadder)
		{
			Ret = true;
		}
		else if ((TargetedLadderPoint.bNextJump) && (bLadderClimbForward))
		{
			Ret = true;
		}
		else if ((TargetedLadderPoint.bPreviousJump) && (!bLadderClimbForward))
		{
			Ret = true;
		}
		else if (!VMDLadderIsBelow())
		{
			if (Location.Z >= TargetedLadderPoint.Location.Z || Abs(Location.Z - TargetedLadderPoint.Location.Z) < 12)
			{
				Ret = true;
			}
		}
		else
		{
			if (Location.Z <= TargetedLadderPoint.Location.Z || Abs(Location.Z - TargetedLadderPoint.Location.Z) < 12)
			{
				Ret = true;
			}
		}
	}
	
	return Ret;
}

function bool VMDLadderDropClear()
{
	local bool Ret;
	local Actor TActor;
	local Vector ST, ET, HL, HN, TExtent;
	
	if (TargetedLadderPoint == None)
	{
		return false;
	}
	
	//Trace a chunky boy our size, but below us. If we hit anything, we're standing on the ground, and hence not drop cleared.
	Ret = true;
	if (VMDLadderIsBelow())
	{
		ST = Location;
		ET = ST - (Vect(0,0,1.1) * CollisionHeight);
		TExtent = Vect(1, 1, 0) * CollisionRadius;
		TExtent.Z = CollisionHeight;
		
		TActor = Trace(HL, HN, ET, ST, true, TExtent);
		if (TActor != None)
		{
			Ret = false;
		}
	}
	
	return Ret;
}

function bool VMDLadderDropWouldBeFatal()
{
	local bool Ret;
	local Actor TActor;
	local Vector ST, ET, HL, HN, TExtent;
	
	if (TargetedLadderPoint == None)
	{
		return false;
	}
	
	//Trace a chunyk boy our size, but below us. If we hit anything, we're standing on the ground, and hence not drop cleared.
	Ret = true;
	if (VMDLadderIsBelow())
	{
		ST = Location;
		ET = ST - (Vect(0,0,6) * CollisionHeight);
		TExtent = Vect(1, 1, 0) * CollisionRadius;
		TExtent.Z = CollisionHeight;
		
		TActor = Trace(HL, HN, ET, ST, true, TExtent);
		if (TActor != None)
		{
			Ret = false;
		}
	}
	
	return Ret;
}

function bool VMDLadderSpaceClear()
{
	local bool Ret;
	local Vector ST, ET;
	
	if (TargetedLadderPoint == None)
	{
		return false;
	}
	
	//MADDERS, 8/10/24: Via better manipulation of points, this function should now be obsolete. Leaving it be.
	return true;
	
	//So, basically, if our goal is to go up, we want room in front of us to move forward.
	//Conversely, if we're going down, we WANT the ground to be below us, so we know we've landed.
	if (!VMDLadderIsBelow())
	{
		ST = Location - (Vect(0,0,1.1) * CollisionHeight);
		ET = ST + (TargetedLadderPoint.LadderNormal * CollisionRadius * 3.0);
		Ret = FastTrace(ET, ST);
	}
	else
	{
		Ret = !VMDLadderDropClear();
	}
	
	return Ret;
}

function Vector VMDFlatEnemyNormal()
{
	local Vector Ret;
	
	//Which way is the enemy? Point towards them using this function + TurnTo.
	if (Enemy != None)
	{
		Ret = Normal(Enemy.Location - Location);
		Ret.Z = 0;
	}
	return Ret;
}

function Vector VMDFlatLadderDirectionNormal(optional bool bLight)
{
	local Vector Ret;
	local VMDLadderPoint LP;
	
	LP = TargetedLadderPoint;
	if (LP != None)
	{
		//For light, give us JUST where the ladder is relative to us.
		//For more intensive checks, shove our asses way out there to make sure we're clearing our gap.
		if (bLight)
		{
			Ret = Normal(TargetedLadderPoint.Location - Location);
		}
		else
		{
			Ret = Normal((TargetedLadderPoint.Location - Location) + (TargetedLadderPoint.LadderNormal * -4));
		}
		Ret.Z = 0;
	}
	return Ret;
}

function Vector VMDFlatLadderJumpNormal()
{
	local Vector Ret;
	local VMDLadderPoint LP;
	
	//Which way should we be jumping to land near our ladder point?
	LP = TargetedLadderPoint;
	if (LP != None)
	{
		Ret = Normal(TargetedLadderPoint.Location - LastLadderPoint);
		Ret.Z = 0;
	}
	return Ret;
}

function VMDClearLadderData()
{
	//Forget all our ladder shit.
	bClimbingLadder = false;
	bLadderClimbForward = false;
	bJumpedFromLadder = false;
	TargetedLadderPoint = None;
	LastLadderPoint = Vect(0,0,0);
	LastLadderCheckInPos = Vect(0,0,0);
	LadderJumpZMult = 1.0;
	
	//Stop being rotating physics. Good god. Almost forgot.
	if (Physics == PHYS_Rotating)
	{
		if (Region.Zone.bWaterZone)
		{
			SetPhysics(PHYS_Swimming);
		}
		else
		{
			SetPhysics(PHYS_Falling);
		}
	}
}

function VMDJumpTowardsLadder()
{
	local float GSpeed;
	local vector LadderLoc, TVel;
	
	if (TargetedLadderPoint == None) return;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	LadderLoc = TargetedLadderPoint.Location;		
	SetPhysics(PHYS_Falling);
	
	//Do a hop so we move along the path intended. Hopefully this keeps us in-line.
	TVel = Normal(LadderLoc - LastLadderPoint) * GroundSpeed;
	TVel.Z = 330.0 * LadderJumpZMult; //MADDERS, 8/8/24: Jump just like the player does.
	
	bJumpedFromLadder = true;
	Acceleration = TVel;
	Velocity = TVel;
	PlayAnim('Jump');
	if (bIsFemale)
	{
		PlaySound(sound'VMDFJCJump', SLOT_Pain,,,, 0.65 * GSpeed);
	}
	else
	{
		PlaySound(sound'MaleJump', SLOT_Pain,,,, 0.65 * GSpeed);
	}
}

function bool VMDLadderIsSafe(VMDLadderPoint SuspectedPoint)
{
	local bool TForward;
	local float THeight, TRad;
	local int TCycles;
	local Vector LadderBoxMin, LadderBoxMax, MinVect, MaxVect;
	local DeusExProjectile DXProj;
	local Pawn TPawn;
	local VMDBufferPawn VMBP;
	local VMDLadderDeathFlag TFlag;
	local VMDLadderPoint TPoint;
	
	if (SuspectedPoint == None || SuspectedPoint.OppositePoint == None) return false;
	
	if (SuspectedPoint.NextPoint != None)
	{
		TForward = true;
	}
	
	LadderBoxMin = Vect(99999, 999999, 999999);
	LadderBoXMax = Vect(-99999, -99999, -99999);
	
	//MADDERS, 8/13/24: Wild thought: Don't mix ladder directions lol.
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		VMBP = VMDBufferPawn(TPawn);
		if ((VMBP != None) && (VMBP != Self) && (VMBP.bClimbingLadder) && (VMBP.TargetedLadderPoint != None) && (VMBP.bLadderClimbForward != TForward))
		{
			if (TForward)
			{
				for(TPoint = SuspectedPoint; TPoint != None; TPoint = TPoint.NextPoint)
				{
					if (TPoint == VMBP.TargetedLadderPoint)
					{
						return false;
					}
				}
			}
			else
			{
				for(TPoint = SuspectedPoint; TPoint != None; TPoint = TPoint.PreviousPoint)
				{
					if (TPoint == VMBP.TargetedLadderPoint)
					{
						return false;
					}
				}
			}
		}
	}
	
	//MADDERS, 8/12/24: Also, don't crowd on ladders, please. Wait your turn.
	ForEach RadiusActors(class'VMDBufferPawn', VMBP, 144, SuspectedPoint.Location)
	{
		if ((VMBP != Self) && (VMBP.bClimbingLadder || VMBP.TargetedLadderPoint == SuspectedPoint))
		{
			return false;
		}
	}
	
	//MADDERS, 8/12/24: Build an extent of our ladder network, for what region to check within for bullshit.
	//It's a little overkill, but that's prefferable.
	if (TForward)
	{
		for(TPoint = SuspectedPoint; TPoint != None; TPoint = TPoint.NextPoint)
		{
			if ((TPoint.LastDeathFlag != None) && (!TPoint.LastDeathFlag.bDeleteMe))
			{
				return false;
			}
			LadderBoxMin.X = FMin(LadderBoxMin.X, TPoint.Location.X - TPoint.CollisionRadius);
			LadderBoxMax.X = FMax(LadderBoxMax.X, TPoint.Location.X + TPoint.CollisionRadius);
			LadderBoxMin.Y = FMin(LadderBoxMin.Y, TPoint.Location.Y - TPoint.CollisionRadius);
			LadderBoxMax.Y = FMax(LadderBoxMax.Y, TPoint.Location.Y + TPoint.CollisionRadius);
			LadderBoxMin.Z = FMin(LadderBoxMin.Z, TPoint.Location.Z - TPoint.CollisionHeight);
			LadderBoxMax.Z = FMax(LadderBoxMax.Z, TPoint.Location.Z + TPoint.CollisionHeight);
		}
	}
	else
	{
		for(TPoint = SuspectedPoint; TPoint != None; TPoint = TPoint.PreviousPoint)
		{
			if ((TPoint.LastDeathFlag != None) && (!TPoint.LastDeathFlag.bDeleteMe))
			{
				return false;
			}
			LadderBoxMin.X = FMin(LadderBoxMin.X, TPoint.Location.X - TPoint.CollisionRadius);
			LadderBoxMax.X = FMax(LadderBoxMax.X, TPoint.Location.X + TPoint.CollisionRadius);
			LadderBoxMin.Y = FMin(LadderBoxMin.Y, TPoint.Location.Y - TPoint.CollisionRadius);
			LadderBoxMax.Y = FMax(LadderBoxMax.Y, TPoint.Location.Y + TPoint.CollisionRadius);
			LadderBoxMin.Z = FMin(LadderBoxMin.Z, TPoint.Location.Z - TPoint.CollisionHeight);
			LadderBoxMax.Z = FMax(LadderBoxMax.Z, TPoint.Location.Z + TPoint.CollisionHeight);
		}
	}
	
	//MADDERS, 8/12/24: We've overhauled this to not be necessary. Save the math, refer to the assigned variable instead.
	/*TRad = CollisionRadius*2;
	THeight = CollisionHeight*2;
	forEach AllActors(class'VMDLadderDeathFlag', TFlag)
	{
		if ((TFlag.Location.X - TRad < LadderBoxMax.X) && (TFlag.Location.X + TRad > LadderBoxMin.X) && 
			(TFlag.Location.Y - TRad < LadderBoxMax.Y) && (TFlag.Location.Y + TRad > LadderBoxMin.Y) && 
			(TFlag.Location.Z - THeight < LadderBoxMax.Z) && (TFlag.Location.Z + THeight > LadderBoxMin.Z))
		{
			return false;
		}
	}*/
	
	//MADDERS, 8/12/24: Finally, if all else is fine, do some chunky checks for thrown grenades, possible rockets[?], and tear gas etc.
	TRad = CollisionRadius*1.25;
	THeight = CollisionHeight*1.25;
	forEach AllActors(class'DeusExProjectile', DXProj)
	{
		if (!IsProjectileDangerous(DXProj)) continue;
		
		if (Cloud(DXProj) != None)
		{
			if ((DXProj.Location.X - TRad - DXProj.CollisionRadius < LadderBoxMax.X) && (DXProj.Location.X + TRad + DXProj.CollisionRadius > LadderBoxMin.X) && 
				(DXProj.Location.Y - TRad - DXProj.CollisionRadius < LadderBoxMax.Y) && (DXProj.Location.Y + TRad + DXProj.CollisionRadius > LadderBoxMin.Y) && 
				(DXProj.Location.Z - THeight - DXProj.CollisionHeight < LadderBoxMax.Z) && (DXProj.Location.Z + THeight + DXProj.CollisionHeight > LadderBoxMin.Z))
			{
				return false;
			}
		}
		else if ((DXProj.bExplodes) && (ThrownProjectile(DXProj) == None || !ThrownProjectile(DXProj).bProximityTriggered))
		{
			if ((DXProj.Location.X - TRad - DXProj.BlastRadius < LadderBoxMax.X) && (DXProj.Location.X + TRad + DXProj.BlastRadius > LadderBoxMin.X) && 
				(DXProj.Location.Y - TRad - DXProj.BlastRadius < LadderBoxMax.Y) && (DXProj.Location.Y + TRad + DXProj.BlastRadius > LadderBoxMin.Y) && 
				(DXProj.Location.Z - THeight - DXProj.BlastRadius < LadderBoxMax.Z) && (DXProj.Location.Z + THeight + DXProj.BlastRadius > LadderBoxMin.Z))
			{
				return false;
			}
		}
	}
	
	return true;
}

function VMDLadderPoint VMDFindLadderTowards(Vector NeededLocation)
{
	local bool bException;
	local int i, j, NumLadders, NumExceptions;
	local float ValidDist, BestDist;
	local Vector TarLoc;
	local Actor NextPoint;
	local VMDLadderPoint LP, BestTarget, LadderList[64], Exceptions[64];
	
	forEach AllActors(class'VMDLadderPoint', LP)
	{
		if ((LP.OppositePoint != None) && (!LP.bObjectToUse))
		{
 			LadderList[NumLadders] = LP;
			NumLadders++;
		}
	}
	
	//MADDERS, 8/10/24: Do some fudge so we don't take far-off ladders when the player is close by.
	//MADDERS, 8/10/24: Nevermind, actually. A fast trace is faster and more consistent than this.
	BestTarget = VMDFindLadderFrom(Enemy, BestDist);
	/*if (Enemy != None)
	{
		BestDist = VSize(Enemy.Location - Location) * 3;
	}*/
	
	ValidDist = 384;
	TarLoc = NeededLocation;
	for (i=0; i<NumLadders; i++)
	{
		bException = false;
		for(j=0; j<NumExceptions; j++)
		{
			if (Exceptions[j] == LadderList[i])
			{
				bException = true;
				break;
			}
		}
		if (bException)
		{
			continue;
		}
		
		LP = LadderList[i];
		if ((FastTrace(TarLoc, LP.Location)) && (VSize(LP.Location - TarLoc) < ValidDist))
		{
			NextPoint = GetNextWaypoint(LP.OppositePoint);
			if ((NextPoint != None) && (VSize(LP.OppositePoint.Location - Location) < BestDist))
			{
				BestTarget = LP.OppositePoint;
				BestDist = VSize(LP.OppositePoint.Location - Location);
				//return LP.OppositePoint;
			}
			
			Exceptions[NumExceptions] = LP;
			Exceptions[NumExceptions+1] = LP.OppositePoint;
			NumExceptions += 2;
			
			ValidDist = 768;
			TarLoc = LP.OppositePoint.Location;
			i = -1;
			continue;
		}
	}
	
	if (!VMDLadderIsSafe(BestTarget))
	{
		return None;
	}
	return BestTarget;
}

function VMDLadderPoint VMDFindLadderFrom(Pawn TEnemy, out float BestDist)
{
	local bool bException;
	local int i, j, NumLadders, NumExceptions;
	local float ValidDist;
	local Vector TarLoc;
	local Actor NextPoint;
	local VMDLadderPoint FP, LP, BestTarget, LadderList[64], Exceptions[64];
	
	BestDist = 9999;
	if (TEnemy == None || 1 == 1) return None;
	
	forEach AllActors(class'VMDLadderPoint', LP)
	{
		if ((LP.OppositePoint != None) && (!LP.bObjectToUse))
		{
 			LadderList[NumLadders] = LP;
			NumLadders++;
		}
	}
	
	//MADDERS, 8/10/24: Do some fudge so we don't take far-off ladders when the player is close by.
	//MADDERS, 8/10/24: Nevermind, actually. A fast trace is faster and more consistent than this.
	/*if (Enemy != None)
	{
		BestDist = VSize(Enemy.Location - Location) * 3;
	}*/
	
	ValidDist = 384;
	TarLoc = Location;
	for (i=0; i<NumLadders; i++)
	{
		bException = false;
		for(j=0; j<NumExceptions; j++)
		{
			if (Exceptions[j] == LadderList[i])
			{
				bException = true;
				break;
			}
		}
		if (bException)
		{
			continue;
		}
		
		LP = LadderList[i];
		if ((FastTrace(TarLoc, LP.Location)) && (VSize(LP.Location - TarLoc) < ValidDist))
		{
			if (FP == None)
			{
				FP = LP;
			}
			
			NextPoint = VMDFakeGetNextWaypoint(TEnemy, LP.OppositePoint);
			if ((NextPoint != None) && (VSize(FP.Location - Location) < BestDist))
			{
				BestTarget = FP;
				BestDist = VSize(FP.Location - Location);
				//return LP.OppositePoint;
			}
			
			Exceptions[NumExceptions] = LP;
			Exceptions[NumExceptions+1] = LP.OppositePoint;
			NumExceptions += 2;
			
			ValidDist = 768;
			TarLoc = LP.OppositePoint.Location;
			i = -1;
			continue;
		}
	}
	
	if (!VMDLadderIsSafe(BestTarget))
	{
		BestDist = 9999;
		return None;
	}
	return BestTarget;
}

function VMDLadderPoint VMDFindNearestLadder()
{
	local float BestDist;
	local Actor NextPoint;
	local VMDLadderPoint LP, BestTarget;
	
	BestDist = 384;
	forEach AllActors(class'VMDLadderPoint', LP)
	{
		if ((FastTrace(Location, LP.Location)) && (VSize(LP.Location - Location) < BestDist) && (VMDLadderIsSafe(LP)))
		{
			NextPoint = GetNextWaypoint(LP);
			if (NextPoint != None)
			{
				BestTarget = LP;
				BestDist = VSize(LP.Location - Location);
			}
		}
	}
	
	return BestTarget;
}

function Actor VMDFakeGetNextWaypoint(Pawn TEnemy, Actor destination)
{
	local Actor moveTarget;
	
	if (destination == None)
		moveTarget = None;
	else if (TEnemy.ActorReachable(destination))
		moveTarget = destination;
	else
		moveTarget = TEnemy.FindPathToward(destination);

	return (moveTarget);
}

function bool VMDFindCheekyGrenadeAngle(Out Vector FinalLocation, Out Rotator NeededRotationTweak, optional Weapon InputWeapon)
{
	local bool bFoundAlly;
	local int i;
	local float TTime, MaxTime, Elasticity, LandingSpeed, Range, TDist, BestDist, TRadius;
	local Rotator TRot, BestRot;
	local Vector FinalPos, TExtent, FireLoc, SimulatedVelocity, X, Y, Z, BestPlacement, HL, HN;
	local CandyBar TBar;
	local DeusExWeapon DXW;
	local ScriptedPawn SP;
	local SodaCan TCan;
	local class<ThrownProjectile> ThrownProj;
	
	LandingSpeed = 60;
	if (InputWeapon != None)
	{
		DXW = DeusExWeapon(InputWeapon);
	}
	else
	{
		DXW = DeusExWeapon(Weapon);
	}
	
	if (DXW == None || Enemy == None || class<ThrownProjectile>(DXW.ProjectileClass) == None)
	{
		return false;
	}
	
	ThrownProj = class<ThrownProjectile>(DXW.ProjectileClass);
	if (!ThrownProj.Default.bExplodes)
	{
		return false;
	}
	
	TExtent = vect(1,1,0)*ThrownProj.Default.CollisionRadius;
	TExtent.Z = ThrownProj.Default.CollisionHeight*1.35;
	
	MaxTime = Max(2, ThrownProj.Default.FuseLength);
	
	Elasticity = ThrownProj.Default.Elasticity;
	TRadius = ThrownProj.Default.BlastRadius * 0.66;
	
	Range = CollisionRadius + 60;
	Range += ThrownProj.Default.BlastRadius;
	
	BestDist = 9999;
	for (i=0; i<25; i++)
	{
		bFoundAlly = false;
		
		TRot.Yaw = -8192 + (4096 * (i%5));
		TRot.Pitch = 4096 - (2048 * (i/5));
		TRot = TRot + ViewRotation;
		
		SimulatedVelocity = ThrownProj.Default.Speed * Vector(TRot);
		if (Base != None)
		{
			SimulatedVelocity += Base.Velocity;
		}
		else
		{
			SimulatedVelocity += Velocity;
		}
		
		if (Region.Zone != None)
		{
			SimulatedVelocity += Region.Zone.ZoneGravity / 60.0; //* LastTickDelta;
		}
		
		GetAxes(TRot,X,Y,Z);
		FireLoc = DXW.ComputeProjectileStart(X, Y, Z);
		
		//MADDERS, 8/7/24: Stop throwing grenades into shit that's right in our face.
		if (Trace(HL, HN, FireLoc, FireLoc + (Normal(SimulatedVelocity) * 32), true, TExtent) != None)
			continue;
		
		TTime = ParabolicTrace(FinalPos, SimulatedVelocity, FireLoc, True, TExtent, MaxTime, Elasticity, ThrownProj.Default.bBounce, 60);
		if (TTime > 0)
		{
			TDist = VSize(Location - FinalPos);
			if ((FastTrace(FinalPos, Enemy.Location)) && (TDist < TRadius) && (TDist < BestDist))
			{
				forEach RadiusActors(class'ScriptedPawn', SP, TRadius, FinalPos)
				{
					if (SP.Alliance == Alliance)
					{
						bFoundAlly = true;
						break;
					}
				}
				if (!bFoundAlly)
				{
					BestDist = TDist;
					BestPlacement = FinalPos;
					BestRot = TRot - ViewRotation;
				}
			}
		}
	}
	
	if (BestDist < 9000)
	{
		FinalLocation = BestPlacement;
		NeededRotationTweak = BestRot;
		return true;
	}
	
	return false;
}

state VMDPickingUpWeapon
{
	function SetFall()
	{
		StartFalling('VMDPickingUpWeapon', 'ContinueRun');
	}
	
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
		{
			return;
		}
		
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	
	function Bump(actor bumper)
	{
		// If we hit the guy we're going to, end the state
		if (bumper == LastSoughtWeapon)
		{
			GotoState('VMDPickingUpWeapon', 'Done');
		}
		
		// Handle conversations, if need be
		Global.Bump(bumper);
	}
	
	function Touch(actor toucher)
	{
		// If we hit the guy we're going to, end the state
		if (toucher == LastSoughtWeapon)
		{
			GotoState('VMDPickingUpWeapon', 'Done');
		}
		
		// Handle conversations, if need be
		Global.Touch(toucher);
	}
	
	function BeginState()
	{
		StandUp();
		BlockReactions();
		SetupWeapon(false);
		SetDistress(false);
		bStasis = False;
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}
	function EndState()
	{
		EnableCheckDestLoc(false);
		ResetReactions();
	}

Begin:
	Acceleration = vect(0, 0, 0);
	if (LastSoughtWeapon == None || (LastSoughtWeapon.Owner != None && DeusExCarcass(LastSoughtWeapon.Owner) == None) || VSize(LastSoughtWeapon.Location - Location) < 112)
	{
		Goto('Done');
	}
Follow:
	if (LastSoughtWeapon == None || (LastSoughtWeapon.Owner != None && DeusExCarcass(LastSoughtWeapon.Owner) == None) || IsOverlapping(LastSoughtWeapon) || VSize(LastSoughtWeapon.Location - Location) < 112)
	{
		Goto('Done');
	}
	
	if ((FastTrace(LastSoughtWeapon.Location, Location)) && (VSize(LastSoughtWeapon.Location - Location) < 112))
	{
		MoveTarget = LastSoughtWeapon;
	}
	else
	{
		MoveTarget = GetNextWaypoint(LastSoughtWeapon);
	}
	
	if ((MoveTarget != None) && (!MoveTarget.Region.Zone.bWaterZone) && (MoveTarget.Physics != PHYS_Falling))
	{
		if (ShouldPlayWalk(MoveTarget.Location))
		{
			PlayRunning();
		}
		MoveToward(MoveTarget, MaxDesiredSpeed);
		CheckDestLoc(MoveTarget.Location, true);
		
		if (LastSoughtWeapon == None || (LastSoughtWeapon.Owner != None && DeusExCarcass(LastSoughtWeapon.Owner) == None) || IsOverlapping(LastSoughtWeapon) || VSize(LastSoughtWeapon.Location - Location) < 112)
		{
			Goto('Done');
		}
		else
		{
			Goto('Follow');
		}
	}

Pause:
	Acceleration = vect(0, 0, 0);
	TurnToward(LastSoughtWeapon);
	PlayWaiting();
	Sleep(1.0);
	Goto('Follow');

Done:
	Acceleration = vect(0, 0, 0);
	if ((LastSoughtWeapon != None) && (LastSoughtWeapon.Owner == None || DeusExCarcass(LastSoughtWeapon.Owner) != None))
	{
		PlayAnim('Pickup');
		FinishAnim();
		
		VMDGrabWeapon(LastSoughtWeapon);
		SwitchToBestWeapon();
	}
	
	if (SetEnemy(Enemy))
	{
		HandleEnemy();
	}
	else
	{
		if (VMDMEGH(Self) != None)
		{
			FollowOrders();
		}
		else
		{
			GoToState('Standing');
		}
	}

ContinueRun:
ContinueFromDoor:
	PlayRunning();
	Goto('Follow');
}

function VMDGrabWeapon(DeusExWeapon DXW)
{
	local bool bLoadedAmmo;
	local int i;
	local DeusExCarcass DXC;
	
	if (DXW == None || (DXW.Owner != None && DeusExCarcass(DXW.Owner) == None))
	{
		return;
	}
	
	//MADDERS, 8/7/24: Happy accident. When looting dead bodies (sometimes owner isn't set right), give it some ammo.
	forEach AllActors(class'DeusExCarcass', DXC)
	{
		if (DXC.VMDHasInventory(DXW))
		{
			if (DXW.AmmoType != None)
			{
				DXW.PickupAmmoCount = Max(DXW.ReloadCount - DXW.ClipCount, class'VMDStaticFunctions'.Static.GWARR(DXW, DeusExAmmo(DXW.AmmoType), GetLastVMP()));
			}
			DXC.VMDRemoveInventory(DXW, true);
			break;
		}
	}
	
	DXW.InitialState = 'Idle2';
	DXW.GiveTo(Self);
	DXW.SetBase(Self);
	
	for(i=2; i>=0; i--)
	{
		//MADDERS, 8/6/24: A couple quick hacks so load ammo works...
		if ((DXW.AmmoNames[i] != None) && (FindInventoryType(DXW.AmmoNames[i]) != None))
		{
			bLoadedAmmo = true;
			DXW.AmmoName = None;
			DXW.AmmoType = None;
			DXW.LoadAmmo(i);
			break;
		}
	}
	
	//MADDERS, 2/22/25: Don't shoot and use ammo we don't own, bonus round. Very important for MEGH.
	if ((!bLoadedAmmo) && (DXW.PickupAmmoCount > 0 || DXW.AmmoType == None || (DXW.AmmoType != None && DXW.AmmoType.Owner != Self)))
	{
		DXW.AmmoType = Spawn(DXW.Default.AmmoName,,, Location);
		if (DXW.AmmoType == None)
		{
			DXW.AmmoType = Spawn(DXW.Default.AmmoName,,, Location + Vect(0,0,16));
		}
		if (DXW.AmmoType == None)
		{
			DXW.AmmoType = Spawn(DXW.Default.AmmoName,,, Location - Vect(0,0,16));
		}
		
		if (DXW.AmmoType != None)
		{
			DXW.AmmoType.AmmoAmount = DXW.PickupAmmoCount;
			DXW.PickupAmmoCount = 0;
			DXW.AmmoType.InitialState = 'Idle2';
			DXW.AmmoType.GiveTo(Self);
			DXW.AmmoType.SetBase(Self);
		}
	}
}

function DeusExWeapon VMDFindClosestFreeWeapon(optional bool bDiscludeMelee)
{
	local bool FlagOwnerValid, FlagMeleePassed, FlagDistancePassed;
	local int i;
	local float BestDistance;
	local Vector EyePos;
	local DeusExWeapon DXW, Best;
	
	//Weird and hacky, but don't let us pick up weapons if we're not known for dropping them normally.
	if (Animal(Self) != None || Robot(Self) != None || VMDPawnIsCommando()) return None;
	
	//MADDERS, 11/0/24: A little late, but don't grab weapons if we're just honestly afraid and not fighting back.
	if (Enemy == None || GetPawnAllianceType(Enemy) != ALLIANCE_Hostile) return None;
	
	//MADDERS, 3/15/25: Even later, decide who can or can't grab weapons on an individual basis.
	if (!bCanGrabWeapons)
	{
		return None;
	}
	
	BestDistance = 9999;
	EyePos = Location + (Vect(0,0,1) * BaseEyeHeight);
	
	forEach RadiusActors(class'DeusExWeapon', DXW, 640, Location)
	{
		if ((VSize(DXW.Velocity) < 20) && (DXW.Physics != PHYS_Falling) && (FastTrace(EyePos, DXW.Location)))
		{
			//MADDERS, 3/15/25: Skip over this shit because it's bad to be grabbing.
			if (DXW.VMDConfigureInvSlotsX(None) > 90 || DXW.Default.Mesh == LODMesh'TestBox')
			{
				continue;
			}
			
			//MADDERS, 8/7/24: I know it's slower this way, but I get tired of debugging chunky bois in weird situations, and the performance hit is virtually immeasurable anyways.
			FlagOwnerValid = (DXW.Owner == None || DeusExCarcass(DXW.Owner) != None);
			FlagMeleePassed = (!DXW.VMDIsMeleeWeapon() || !bDiscludeMelee);
			FlagDistancePassed = (VSize(DXW.Location - Location) < BestDistance || (Best != None && Best.bHandToHand && !DXW.bHandToHand));
			if ((FlagOwnerValid) && (FlagMeleePassed) && (FlagDistancePassed))
			{
				if (DXW.AmmoName == class'AmmoNone')
				{
					Best = DXW;
					BestDistance = VSize(DXW.Location - Location);
				}
				else if (DXW.PickupAmmoCount > 0)
				{
					Best = DXW;
					BestDistance = VSize(DXW.Location - Location);
				}
				else if (DeusExCarcass(DXW.Owner) != None)
				{
					Best = DXW;
					BestDistance = VSize(DXW.Location - Location);
				}
				else
				{
					for(i=0; i<ArrayCount(DXW.AmmoNames); i++)
					{
						if ((DXW.AmmoNames[i] != None) && (FindInventoryType(DXW.AmmoNames[i]) != None))
						{
							Best = DXW;
							BestDistance = VSize(DXW.Location - Location);
							break;
						}
					}
				}
			}
		}
	}
	
	return Best;
}

function bool VMDDisarmWeapon()
{
	local bool Ret;
	local DeusExWeapon DXWeapon, OldWeapon;
	local Medkit TMedkit;
	local VMDMedigel TGel;
	
	if (Weapon != None)
	{
		DXWeapon = DeusExWeapon(Weapon);
		if ((DXWeapon != None) && (!DXWeapon.bNativeAttack))
		{
			if (DXWeapon.bZoomed)
			{
				DXWeapon.ScopeOff();
			}
			if (DXWeapon.bHasLaser)
			{
				DXWeapon.LaserOff();
			}
			
			OldWeapon = DXWeapon;
			SetWeapon(None);
			OldWeapon.SetPropertyText("bCorpseUnclog", "True");
			if (oldWeapon.VMDDropFrom(Location))
			{
				Ret = true;
			}
			
			OldWeapon.PickupAmmoCount = class'VMDStaticFunctions'.Static.GWARRRand(0, 0, OldWeapon, DeusExAmmo(OldWeapon.AmmoType), VMDBufferPlayer(GetPlayerPawn()));
		}
		
		if (ShouldDropWeapon())
		{
			TMedkit = Medkit(FindInventoryType(class'Medkit'));
			TGel = VMDMedigel(FindInventoryType(class'VMDMedigel'));
			if ((TMedkit != None && !TMedkit.bDeleteMe && TMedkit.NumCopies > 0 && !TMedkit.IsInState('Activated')) || (TGel != None && !TGel.bDeleteMe && TGel.NumCopies > 0 && !TGel.IsInState('Activated')))
			{
				MedkitUseTimer = 1.5;
			}
		}
	}
	
	return Ret;
}

function bool VMDCanDropWeapon()
{
	return true;
}

function bool VMDPawnIsLawEnforcement()
{
	switch(class.Name)
	{
		case 'Cop':
		case 'Doberman':
		case 'HKMilitary':
		case 'RiotCop':
		//case 'UNATCOTroop': //These guys are our friends. Don't fuck around and find out, even if they aid police often.
			return true;
		break;
	}
	
	return false;
}

function bool VMDPawnIsCommando()
{
	switch(class.Name)
	{
		case 'MJ12Commando':
		case 'ZodiacCommando':
		case 'MJ12CyborgBountyHunter':
			return true;
		break;
	}
	
	return false;
}

function bool VMDPawnIsMIBWIB()
{
	switch(class.Name)
	{
		case 'MIB':
		case 'WIB':
		case 'Z1':
			return true;
		break;
	}
	
	return false;
}

function bool VMDPawnIsChild()
{
	switch(Die)
	{
		case Sound'ChildDeath':
			return true;
		break;
	}
	
	return false;
}

function string VMDGetDisplayName(string InName)
{
	return InName;
}

function name VMDGetAllianceName(int i)
{
	return AlliancesEx[i].AllianceName;
}

function int VMDGetAllianceLevel(int i)
{
	return AlliancesEx[i].AllianceLevel;
}

function bool VMDGetAlliancePermanent(int i)
{
	return AlliancesEx[i].bPermanent;
}

function bool AllianceIsPermanent(Name CheckAlliance)
{
	local int i;
	
	for(i=0; i<ArrayCount(AlliancesEx); i++)
	{
		if (AlliancesEx[i].AllianceName == CheckAlliance)
		{
			return AlliancesEx[i].bPermanent;
		}
	}
	
	return false;
}

function VMDTriggerDroneAggro(ScriptedPawn TAggro)
{
	local VMDBufferPlayer VMP;
	local VMDMegh TMegh, Meghs;
	
	ForEach AllActors(class'VMDMegh', Meghs)
	{
		if (Meghs.EMPHitPoints > 0)
		{
			TMegh = Meghs;
			break;
		}
	}
	
	if (TMegh == None || TMegh.GuardedOther != Self) return;
	
	ForEach AllActors(class'VMDBufferPlayer', VMP) break;
	
	if (VMP != None)
	{
		VMP.VMDTriggerDroneAggro(TAggro);	
	}
}

function ReceiveHealing(int HealingReceived)
{
	local int HealLeft, THeal;
	
	if (Robot(Self) != None) return;
	
	HealLeft = HealingReceived;
	if ((HealthArmLeft <= 0) && (HealLeft > 0))
	{
		THeal = Clamp(StartingHealthValues[2] - HealthArmLeft, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmLeft += THeal;
	}
	if ((HealthArmRight <= 0) && (HealLeft > 0))
	{
		THeal = Clamp(StartingHealthValues[3] - HealthArmRight, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmRight += THeal;
	}
	
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[0] - HealthHead, 0, HealLeft);
		HealLeft -= THeal;
		HealthHead += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[1] - HealthTorso, 0, HealLeft);
		HealLeft -= THeal;
		HealthTorso += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[2] - HealthArmLeft, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmLeft += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[3] - HealthArmRight, 0, HealLeft);
		HealLeft -= THeal;
		HealthArmRight += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[4] - HealthLegLeft, 0, HealLeft);
		HealLeft -= THeal;
		HealthLegLeft += THeal;
	}
	if (HealLeft > 0)
	{
		THeal = Clamp(StartingHealthValues[5] - HealthLegRight, 0, HealLeft);
		HealLeft -= THeal;
		HealthLegRight += THeal;
	}
	
	GenerateTotalHealth();
}

function ReceiveMedicalHealing(int HealingReceived)
{
	local Vector TVect;
	local ParticleGenerator Puff;
	
	if (Robot(Self) != None) return;
	
	ReceiveHealing(HealingReceived);
	
	if (PoisonCounter > 0)
	{
		StopPoison();
	}
	
	TVect = Location + (Vector(Rotation) * CollisionRadius * 0.65);
	puff = spawn(class'ParticleGenerator',,, TVect, Rotator(TVect - Location));
	if (puff != None)
	{
		Puff.SetBase(Self);
		puff.particleTexture = FireTexture'Effects.Smoke.SmokePuff1';	
		puff.particleDrawScale = 0.25;
		puff.RiseRate = 2.500000;
		puff.ejectSpeed = 2.500000;
		puff.LifeSpan = 1.500000;
		puff.particleLifeSpan = 3.000000;
		puff.checkTime=0.150000;
		puff.bRandomEject = True;
		puff.RemoteRole = ROLE_None;
	}
}

// ----------------------------------------------------------------------
// state Conversation
//
// Just sit here until the conversation is over
// ----------------------------------------------------------------------

state Conversation
{
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if (VMDMuteFemaleVoice())
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
  	}

	event Tick(float deltaTime)
	{
		Super.Tick(DeltaTime);
		
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
	}

Begin:

	Acceleration = vect(0,0,0);

	DesiredRotation.Pitch = 0;
	if (!bSitting && !bDancing)
		PlayWaiting();

	// we are now idle
}


// ----------------------------------------------------------------------
// state FirstPersonConversation
//
// Just sit here until the conversation is over
// ----------------------------------------------------------------------

state FirstPersonConversation
{
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS: Mute our voice in convos if female. I need not state why, you dummy, but jesus this is hot trash.
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
  	}
	
	function EndState()
	{
		Super.EndState();
		
		//MADDERS: Unmute our sounds otherwise.
		if (VMDMuteFemaleVoice())
		{
   			TransientSoundVolume = Default.TransientSoundVolume;
		}
  	}

	event Tick(float deltaTime)
	{
		Super.Tick(DeltaTime);
		
		if (VMDMuteFemaleVoice())
		{
			TransientSoundVolume = 0;
		}
	}

Begin:

	Acceleration = vect(0,0,0);

	DesiredRotation.Pitch = 0;
	if (!bSitting && !bDancing)
		PlayWaiting();

	// we are now idle
}

function bool VMDMuteFemaleVoice()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (BindName ~= "JCDenton" || BindName ~= "JCDouble"))
	{
		if ((VMP.bAssignedFemale) && (!VMP.bAllowFemaleVoice || VMP.bDisableFemaleVoice))
		{
			return true;
		}
	}
	
	return false;
}

function GetPlayer() 
{
	local PlayerPawn playerPawn;
	
    	if (localPlayer != None)
		return;
    	playerPawn = GetPlayerPawn();
    	if (playerPawn != None)      
		localPlayer = DeusExPlayer(playerPawn);
}

function bool CheckLaserPresence(float deltaSeconds)
{
	local VMDBufferPlayer player;
	local LaserSpot    beamActor;	// Changed from beam to LaserSpot
	local bool         bReactToBeam;
	local float yaw, pitch, dist;
	local Rotator rot;	
	
	//MADDERS, 3/13/21: We don't do this here. Too counterintuitive.
	return false;
	
	if ((bReactPresence) && (bLookingForEnemy) && (LaserCheckTimer <= 0) && (LastRendered() < 5.0))
	{
		LaserCheckTimer = 1.0;
		player = GetLastVMP();
		if ((player != None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Player, "See Laser")))
		{
			bReactToBeam = false;
			if (IsValidEnemy(player))
			{
				foreach RadiusActors(Class'LaserSpot', beamActor, 1200)
				{
					// Spot > Emitter > Weapon > Player
					if ((beamActor.Owner != None) && (beamActor.Owner.Owner != None) && (beamActor.Owner.Owner.Owner != None) && 
					(beamActor.Owner.Owner.Owner == player) && (VSize(beamActor.Location - Location+vect(0,0,1)*BaseEyeHeight) < ((Human(player).combatDifficulty+6)*25)))
					{
						// figure out if we can see the dot
						rot = Rotator(beamActor.Location - Location+vect(0,0,1)*BaseEyeHeight);
						rot.Roll = 0;
						yaw = (Abs(Rotation.Yaw - rot.Yaw)) % 65536;
						pitch = (Abs(Rotation.Pitch - rot.Pitch)) % 65536;

						// center the angles around zero
						if (yaw > 32767)
							yaw -= 65536;
						if (pitch > 32767)
							pitch -= 65536;

						// if we are in the  FOV
						if ((Abs(yaw) < 4096) && (Abs(pitch) < 4096))
							bReactToBeam = true;
					}
					
					if (bReactToBeam)
						break;
				}
			}
			if (bReactToBeam)
				HandleSighting(player);
		}
	}
}

function UpdateFire()
{
	// continually burn and do damage
	if (IsA('Robot'))
	{
		//HealthTorso -= 1;
		if (Burner != None)
			TakeDamage(1, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(1, None, Location, vect(0,0,0), 'Burned');
	}
	else if (IsA('AnnaNavarre'))
	{
		if (Burner != None)
			TakeDamage(2, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(2, None, Location, vect(0,0,0), 'Burned');
	}
	else
	{
		//HealthTorso -= 5;
		if (Burner != None)
			TakeDamage(3, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(3, None, Location, vect(0,0,0), 'Burned');
	}
	//GenerateTotalHealth();
	if (Health <= 0)
	{
		if (Burner != None)
			TakeDamage(10, Burner, Location, vect(0,0,0), 'Burned');
		else
			TakeDamage(10, None, Location, vect(0,0,0), 'Burned');
		ExtinguishFire();
	}
}

// ----------------------------------------------------------------------
// ExtinguishFire()
// ----------------------------------------------------------------------

function ExtinguishFire()
{
	Super.ExtinguishFire();
	Burner = None;
}
// ----------------------------------------------------------------------
// DripWater()
// ----------------------------------------------------------------------

singular function DripWater(float deltaTime)
{
	local float  dripPeriod;
	local float  adjustedRate;
	local vector waterVector;
	local vector vel;
	local rotator SpawnRotation;
	
	if (!DeusExGameInfo(Level.Game).SpawnEffects())
	{
		dripRate = 0;
		waterDripCounter = 0;
		return;
	}
	
	// Copied from ScriptedPawn::Tick()
	dripRate = FClamp(dripRate, 0.0, 15.0);
	if (dripRate > 0)
	{
		adjustedRate = 1;
		dripPeriod = adjustedRate / FClamp(VSize(Velocity)/512.0, 5, 10);
		waterDripCounter += deltaTime;
		while (waterDripCounter >= dripPeriod)
		{
			vel = 0.1*Velocity;
			vel.Z = 0;
			
			SpawnRotation = rot(0,0,0);
			SpawnRotation.Pitch = 49152;
		
			waterVector = VRand() * CollisionRadius;
			if (VSize(Velocity) > 8)
				spawn(Class'WaterDrop',Self,,waterVector+Location,rotator(Velocity-vel));
			else
				spawn(Class'WaterDrop',Self,,waterVector+Location, SpawnRotation);
			waterDripCounter -= dripPeriod;
		}
		dripRate -= deltaTime;
	}
	
	if (dripRate <= 0)
	{
		dripRate   		 = 0;
		waterDripCounter = 0;
	}
}

simulated function Tick(float deltaTime)
{	
	Super.Tick(deltaTime);

	VMDPawnTickHook(deltaTime);
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
			
	if (!HasAnim('HeadLeft'))
		bLookAtPlayer = False;
		
	GetPlayer();
	
	// if (TriadLumPath(Self) != None || TriadRedArrow(Self) != None || HKMilitary(Self) != None)
		// bReactToNanosword = True;
}

state Patrolling
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		LipSynchBarks(deltaTime);
		
		patrolLookTimer += deltaTime;
		
		if ((bCanTurnHead) && (bExtraSuspicious))
		{
			if (patrolLookTimer > 13.0)
			{
				PlayTurnHead(LOOK_Right, 1.0, 1.0);
				patrolLookTimer = 0;
			}
			else if (patrolLookTimer > 7.0)
				PlayTurnHead(LOOK_Forward, 1.0, 1.0);
			else if (patrolLookTimer > 3.0)
				PlayTurnHead(LOOK_Left, 1.0, 1.0);
		}
	}
}

event PreBeginPlay()
{
	local int i;
	local Pawn TPawn;
	
	Super.PreBeginPlay();
	
	//MADDERS, 10/2/25: Get our own seed this way.
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		if (TPawn.NextPawn == None)
		{
			SelfAssessedSeed = i;
			break;
		}
		
		if (ScriptedPawn(TPawn) != None && (VMDBufferPawn(TPawn) == None || !VMDBufferPawn(TPawn).bInsignificant))
		{
			i += 1;
		}
	}
	
	//fake shrink to fix faked collision with floor problems - DEUS_EX CNN
	//UNDO
	if ((CollisionHeight > 9) && (InStr(String(Mesh), ".Trans") != -1))
	{
		//if (bIsFemale)
			//SetCollisionSize(CollisionRadius, CollisionHeight + 4.5);
		//else
			SetCollisionSize(CollisionRadius, CollisionHeight + 2.25);
			BaseEyeHeight -= 1.125;
	}
}

function float GetDefaultCollisionHeight()
{
	// return (Default.CollisionHeight-4.5);
	return (Default.CollisionHeight-2.25);
}




//
// lip synching support - DEUS_EX CNN
//
function LipSynchBarks(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.1;
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		if (nextPhoneme == "A")
			animseq = 'MouthA';
		else if (nextPhoneme == "E")
			animseq = 'MouthE';
		else if (nextPhoneme == "F")
			animseq = 'MouthF';
		else if (nextPhoneme == "M")
			animseq = 'MouthM';
		else if (nextPhoneme == "O")
			animseq = 'MouthO';
		else if (nextPhoneme == "T")
			animseq = 'MouthT';
		else if (nextPhoneme == "U")
			animseq = 'MouthU';
		else if (nextPhoneme == "X")
			animseq = 'MouthClosed';

		if (animseq != '' && HasAnim(animseq))
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if (HasAnim('MouthClosed'))
			TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if ((FRand() < 0.4  || IsInState('RubbingEyes')) && (HasAnim('Blink')))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}

	// LoopHeadConvoAnim();
	// LoopBaseConvoAnim();
}

//Typically implemented in subclass
function string KillMessage( name damageType, pawn Other )
{
	local string message;

	message = Level.Game.CreatureKillMessage(damageType, Other); // " was killed by"
	// return (message$namearticle$menuname);
	return (message $ namearticle $ FamiliarName);
}

function Vector GetShellOffset()
{	
	local vector offset, tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	offset = CollisionRadius * X + 0.3 * CollisionRadius * Y;
	// tempvec = 0.8 * CollisionHeight * Z;
	tempvec = 0.5 * CollisionHeight * Z;
	offset.Z += tempvec.Z;
	
	return offset;
}

function Vector GetShellVelocity()
{	
	local vector tempvec, X, Y, Z;
	
	GetAxes(ViewRotation, X, Y, Z);
	
	tempvec = (FRand()*20+90) * Y + (10-FRand()*20) * X;
	
	return tempvec;
}

// ----------------------------------------------------------------------
// FootStepSound()
//
// Tries to figure out which footstep sound to use.
//
// Potential Additional Footstep Sounds:
//	* MoverSFX.StallDoorClose
//  * DeusExSounds.KarkianFootstep
//  * DeusExSounds.GreaselFootstep
//  * DeusExSounds.GrayFootstep
//
// Note:
//  * Maybe add FootSteps for Fragment.
// ----------------------------------------------------------------------

simulated function Sound FootStepSound( out float Volume, out float AIVolumeMul )
{
	local int texFlags;
	local float Rnd;
	local name texName, texGroup;
	local Vector EndTrace, HitLocation, HitNormal;
	local Actor target;
	local Texture Tex;
	local Mover Mover;
	local DeusExDecoration Decoration;
	local DeusExCarcass Carcass;
	
	local VMDHousingScriptedTexture STex;
	
	Volume = 1.0;
	AIVolumeMul = 1.0;
	
	// Handle Water
	if (Physics == PHYS_Swimming)
		return SwimmingStepSound(Volume, AIVolumeMul);
	if (FootRegion.Zone.bWaterZone)
		return WaterStepSound(Volume, AIVolumeMul);
	
	// Prefer WalkSound over any texture speficic sound.
	if (WalkSound != None)
		return WalkSound;
	
	// trace down to our feet
	EndTrace = Location - CollisionHeight * 2 * vect(0,0,1);
	
	foreach TraceTexture(class'Actor', target, texName, texGroup, texFlags, HitLocation, HitNormal, EndTrace)
	{
		if ((TexName != '') && (VMDGetHousingScriptedTexCount() > 0))
		{
			forEach AllObjects(class'VMDHousingScriptedTexture', STex)
			{
				if (STex.Name == TexName)
				{
					if (STex.LastTexGroup != '')
					{
						TexGroup = STex.LastTexGroup;
					}
					break;
				}
			}
		}
		
		// Vanilla behaviour for Level Geometry.
		if (target == Level)
			return TextureGroupStepSound(Volume, AIVolumeMul, Tex, TexGroup);
		
		// Choose Decoration FootStepSound based on FragType.
		Decoration = DeusExDecoration(target);
		if (Decoration != None)
			return DecorationStepSound(Volume, AIVolumeMul, Decoration);
		
		// Carcass.
		Carcass = DeusExCarcass(target);
		if (Carcass != None) 
			return CarcassStepSound(Volume, AIVolumeMul, Carcass);
		
		//Not yet supported.
		//Mover = Mover(target);
		//if (Mover != None)
			//;
	}
	return FallbackStepSound(Volume, AIVolumeMul);
}


// ----------------------------------------------------------------------
// TextureGroupStepSound()
//
// Used for Bsp based footsteps.
// ----------------------------------------------------------------------

simulated function Sound TextureGroupStepSound(out float Volume, out float AIVolumeMul, Texture Texture, Name TextureGroup)
{
	local float Rnd;
	local Human player;
	
	player = Human(GetPlayerPawn());

	// Set Volume and VolumeMul first.
	switch (TextureGroup)
	{
		case 'Metal':
		case 'Ladder':
			AIVolumeMul = 1.0;
			break;
		case 'Foliage':
		case 'Earth':
			AIVolumeMul = 0.6;
			break;
		default:
			AIVolumeMul = 0.7;
			break;
	}

	// Use Texture.FootstepSound if available.
	if ((Texture != None) && (Texture.FootstepSound != None))
		return Texture.FootstepSound;

	Rnd = FRand();
	switch (TextureGroup)
	{
		case 'Textile':
		case 'Paper':
			Volume *= 0.8;
			AIVolumeMul = 0.4;
			if (Rnd < 0.25) return Sound'CarpetStep1';
			if (Rnd < 0.5) return Sound'CarpetStep2';
			if (Rnd < 0.75) return Sound'CarpetStep3';
			else return Sound'CarpetStep4';
			break;
		case 'Plastic':
			AIVolumeMul = 0.4;
			if (Rnd < 0.25) return Sound'CarpetStep1';
			if (Rnd < 0.5) return Sound'CarpetStep2';
			if (Rnd < 0.75) return Sound'CarpetStep3';
			else return Sound'CarpetStep4';
			break;

		case 'Foliage':
			AIVolumeMul = 0.55;
			if (Rnd < 0.25) return Sound'GrassStep1';
			if (Rnd < 0.5) return Sound'GrassStep2';
			if (Rnd < 0.75) return Sound'GrassStep3';
			else return Sound'GrassStep4';
			break;
		case 'Earth':
			AIVolumeMul = 0.55;
			if (Rnd < 0.25) return Sound'GrassStep1';
			if (Rnd < 0.5) return Sound'GrassStep2';
			if (Rnd < 0.75) return Sound'GrassStep3';
			else return Sound'GrassStep4';
			break;

		case 'Metal':
		case 'Ladder':
			AIVolumeMul = 1.0;
			if (Rnd < 0.25) return Sound'MetalStep1';
			if (Rnd < 0.5) return Sound'MetalStep2';
			if (Rnd < 0.75) return Sound'MetalStep3';
			else return Sound'MetalStep4';
			break;

		case 'Ceramic':
		case 'Glass':
		case 'Tiles':
			AIVolumeMul = 0.7;
			if (Rnd < 0.25) return Sound'TileStep1';
			if (Rnd < 0.5) return Sound'TileStep2';
			if (Rnd < 0.75) return Sound'TileStep3';
			else return Sound'TileStep4';
			break;

		case 'Wood':			
			AIVolumeMul = 0.7;
			if (Rnd < 0.25) return Sound'WoodStep1';
			if (Rnd < 0.5) return Sound'WoodStep2';
			if (Rnd < 0.75) return Sound'WoodStep3';
			else return Sound'WoodStep4';
			break;

		case 'Brick':
		case 'Concrete':
		case 'Stone':
		case 'Stucco':
		default:
			AIVolumeMul = 0.7;
			if (Rnd < 0.25) return Sound'StoneStep1';
			if (Rnd < 0.5) return Sound'StoneStep2';
			if (Rnd < 0.75) return Sound'StoneStep3';
			else return Sound'StoneStep4';
			break;
	}
}

// ----------------------------------------------------------------------
// CarcassStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------

simulated function Sound CarcassStepSound(out float Volume, out float AIVolumeMul, Carcass Carcass)
{
	AIVolumeMul = 0.5;
	Volume = 0.5;
	return Sound'KarkianFootstep';
}

// ----------------------------------------------------------------------
// DecorationStepSound()
//
// StepSound for walking over carcass.
// ----------------------------------------------------------------------

simulated function Sound DecorationStepSound(out float Volume, out float VolumeMul, DeusExDecoration Decoration)
{
	if (Decoration.FragType == None)
	{
		Log( Decoration@"has empty FragType. Report this as a Bug." );
		return Sound'TouchTone11';	
	}
	switch (Decoration.FragType.Name) 
	{
		case 'GlassFragment':		return TextureGroupStepSound(Volume, VolumeMul, None, 'Glass');
		case 'MetalFragment':		return TextureGroupStepSound(Volume, VolumeMul, None, 'Metal');
		case 'PaperFragment':
			VolumeMul = 0.3;
			Volume = 1.2;
			return Sound'StallDoorClose';
		case 'PlasticFragment':	return TextureGroupStepSound(Volume, VolumeMul, None, 'Plastic');
		case 'WoodFragment':		return TextureGroupStepSound(Volume, VolumeMul, None, 'Wood');
		case 'Rockchip':				return TextureGroupStepSound(Volume, VolumeMul, None, 'Stone');
		case 'FleshFragment':
			VolumeMul = 0.5;
			Volume = 0.5;
			return Sound'KarkianFootstep';
		case 'GrassFragment': return TextureGroupStepSound(Volume, VolumeMul, None, 'Foliage');
		default:
			Log("Unhandled FragType="$Decoration.FragType.Name$" in GetFootStepGroup() Report this as a Bug.");
			return Sound'TouchTone5';
	}
}

// ----------------------------------------------------------------------
// FallbackStepSound()
// ----------------------------------------------------------------------

simulated function Sound FallbackStepSound(out float Volume, out float AIVolumeMul)
{
	return TextureGroupStepSound(Volume, AIVolumeMul, None, 'Brick');
}

// ----------------------------------------------------------------------
// SwimmingStepSound()
// ----------------------------------------------------------------------

simulated function Sound SwimmingStepSound(out float Volume, out float AIVolumeMul)
{
	AIVolumeMul = 0.5;
	if (FRand() < 0.5)
		return Sound'Swimming';
	else
		return Sound'Treading';
}

// ----------------------------------------------------------------------
// WaterStepSound()
// ----------------------------------------------------------------------

simulated function Sound WaterStepSound(out float Volume, out float AIVolumeMul)
{
	local float Rnd;
	AIVolumeMul = 1.0;
	Rnd = FRand();
	if (Rnd < 0.33)
		return Sound'WaterStep1';
	if (Rnd < 0.66) 
		return Sound'WaterStep2';
	else
		return Sound'WaterStep3';
}


// ----------------------------------------------------------------------
// ForcePlaySurpriseSound()
// ----------------------------------------------------------------------

function ForcePlaySurpriseSound()
{
	local DeusExPlayer dxPlayer;

	dxPlayer = DeusExPlayer(GetPlayerPawn());
	if ((dxPlayer != None) && (!HeadRegion.Zone.bWaterZone)) // Only talk if we can breathe underwater or we're not in water
		dxPlayer.StartAIBarkConversation(self, BM_Surprise);
}

// ----------------------------------------------------------------------
// HandleActorSighting()
// ----------------------------------------------------------------------

function HandleActorSighting(Actor actorSighted)
{
	SetSeekLocation(actorSighted, actorSighted.Location, SEEKTYPE_Sound);
	GotoState('Seeking');
}

function int EnemiesOrNeutralLeft()
{
	local int Ret;
	local Pawn TPawn;
	local ScriptedPawn SP;
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((SP !=  None) && (SP.GetPawnAllianceType(Self) != ALLIANCE_Friendly))
		{
			Ret++;
		}
	}
	
	return Ret;
}

//WCCC, 3/17/19: Scale things based on the factor in question, and height differences between other and us.
function float ScaleSoundByHeight(float Factor, Pawn Other)
{
	local float RetVal;
	local Vector OLoc, SLoc;
	local float GetDist, ODist, HeightDist;
	
	if (Other == None || Factor <= 0) return 1.0;
	
	OLoc = Other.Location - (vect(0,0,1) * (Other.CollisionHeight/2));
	SLoc = Location - (vect(0,0,1) * (CollisionHeight/2));
	
	GetDist = VSize(OLoc - SLoc);
	HeightDist = Abs(OLoc.Z - SLoc.Z);
	ODist = GetDist - HeightDist;
	HeightDist /= Factor;
	ODist += HeightDist;
	
	//NOTES: The more height we're comprised of, the more we treat like there's distance between us and sender.
	//More factor also equates to easier desensitization.
	RetVal = GetDist / ODist;
	
	return RetVal;
}

// ----------------------------------------------------------------------
// LoudNoiseScore()
// ----------------------------------------------------------------------

function float LoudNoiseScore(actor receiver, actor sender, float score)
{
	local Pawn pawnSender;
	
	// Cull events received from friends
	pawnSender = Pawn(sender);
	if (pawnSender == None)
		pawnSender = sender.Instigator;
	if (pawnSender == None)
		score = 0;
	else if (!IsValidEnemy(pawnSender))
		score = 0;
	
	//WCCC, 3/17/19: Experimental noise reception, relative to height. Spicy.
	else if ((PawnSender != None) && (ReceiveNoiseHeightTolerance > 0))
	{
		Score *= ScaleSoundByHeight(ReceiveNoiseHeightTolerance, PawnSender);
	}
	
	return score;
}
// ----------------------------------------------------------------------
// DrawPickupShield()
// ----------------------------------------------------------------------

function DrawPickupShield(name DamageType)
{
	local EllipseEffectPickup Shield;
	local EllipseEffectBallistic BallisticShield;
	
	if (DrawShieldCooldown > 0) return;
	
	if (DamageType == 'Shot' || DamageType == 'Autoshot' || DamageType == 'KnockedOut' || DamageType == 'Sabot' || DamageType == 'Exploded')
	{
		BallisticShield = Spawn(class'EllipseEffectBallistic', Self,, Location, Rotation);
		if (BallisticShield != None)
		{
			BallisticShield.SetBase(Self);
		}
	}
	else
	{
		Shield = Spawn(class'EllipseEffectPickup', Self,, Location, Rotation);
		if (Shield != None)
		{
			Shield.SetBase(Self);
		}
	}
	
	//MADDERS: Just enough to stop spamming this on shotguns.
	DrawShieldCooldown = 0.05;
}

function DrawAugShield(name DamageType, float DamageMult)
{
	local VMDAugShieldOverlay TOverlay;
	local Texture TTex;
	
	if (DrawAugShieldCooldown > 0) return;
	
	switch(DamageType)
	{
		case 'Shot':
		case 'Autoshot':
		case 'Sabot':
			TTex = Texture'VMDAugShieldBallistic';
		break;
		
		/*case 'KnockedOut':
			
		break;*/
		
		case 'EMP':
		case 'Shocked':
		case 'Nanovirus':
			TTex = Texture'VMDAugShieldEMP';
		break;
		
		case 'Stunned':
		case 'Flamed':
		case 'Burned':
		case 'Exploded':
			TTex = Texture'VMDAugShieldEnergy';
		break;
		
		case 'Poison':
		case 'PoisonEffect':
		case 'Radiation':
		case 'TearGas':
		case 'HalonGas':
		case 'OwnedHalonGas':
			TTex = Texture'VMDAugShieldEnviro';
		break;
	}
	
	TOverlay = Spawn(class'VMDAugShieldOverlay', Self,, Location, Rotation);
	if (TOverlay != None)
	{
		TOverlay.ApplyOverlayTexture(TTex);
		TOverlay.BrightnessMult = (1.0 - DamageMult) * 1.5;
	}
	
	//MADDERS: Just enough to stop spamming this on shotguns.
	DrawAugShieldCooldown = 0.05;
}

function int VMDGetDamageLocation(Vector HitLocation)
{
	switch(HandleDamage(1, HitLocation, (hitLocation - Location) << Rotation, 'Test'))
	{
		case HITLOC_HeadFront:
		case HITLOC_HeadBack:
			return 0;
		break;
		case HITLOC_TorsoFront:
		case HITLOC_TorsoBack:
			return 1;
		break;
		case HITLOC_LeftArmFront:
		case HITLOC_LeftArmBack:
			return 2;
		break;
		case HITLOC_RightArmFront:
		case HITLOC_RightArmBack:
			return 3;
		break;
		case HITLOC_LeftLegFront:
		case HITLOC_LeftLegBack:
			return 4;
		break;
		case HITLOC_RightLegFront:
		case HITLOC_RightLegBack:
			return 5;
		break;
	}
	
	return -1;
}

function bool VMDHitArmor(int Damage, vector HitLocation, name DamageType)
{
	local vector Offset;
	local float        headOffsetZ, headOffsetY, armOffset;
	local float	HelmetFront, HelmetBack, HelmetX;
	local bool bHitHelmet, bHitArmor;
	
	if (BypassesHelmet(damageType))
	{
		return false;
	}
	if (Robot(Self) != None) return true;
	
	if ((!bHasHelmet) && (!bHasBodyArmor) && (!bHasHeadArmor)) return false;
	
	// calculate our hit extents
	headOffsetZ = CollisionHeight * 0.7;
	headOffsetY = CollisionRadius * 0.3;
	armOffset   = CollisionRadius * 0.35;
	
	HelmetFront = CollisionHeight * 0.95;
	HelmetBack = CollisionHeight * 0.8625;
	HelmetX = CollisionRadius * 0.2;
	
	Offset = (HitLocation-Location) << Rotation;
	
	if ((bHasHelmet) && (Damage < 25))
	{
		if (Offset.X > HelmetX)
		{
			if (Offset.Z > HelmetFront) return True;
		}
		else
		{
			if (Offset.Z > HelmetBack) return True;
		}
	}
	if ((bHasHeadArmor) && (Damage < 25))
	{
		if (Offset.Z >= HeadOffsetZ)
		{
			return True;
		}
	}
	if ((bHasBodyArmor) && (Damage < 50))
	{			
		if ((Offset.Z >= 0.0) && (Offset.Z < HeadOffsetZ) && (Offset.Y > -ArmOffset) && (Offset.Y < ArmOffset))
		{
		 	return True;
		}
	}
	return False;
}

function AddStuckAmmoUnit(class<Inventory> AddType, float StickOdds, int AddAmount)
{
	local int i;
	
	//MADDERS: Add slight entropy to ammo returns.
	if (FRand() > StickOdds) return;
	
	for (i=0; i<ArrayCount(StuckCount); i++)
	{
		if (StuckProjectiles[i] == None || StuckProjectiles[i] == AddType)
		{
			StuckProjectiles[i] = AddType;
			StuckCount[i] += AddAmount;
			break;
		}
	}
}

function VMDPlayRicochetSound()
{
	local int R;
	local float GSpeed;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	R = Rand(4);
	
	//MADDERS: Old gag code. Now obsolete.
	//PlaySound(Sound'ArmorRicochet', SLOT_Misc, 48,, 512, GSpeed);
	
	switch(R)
	{
		case 0:
			PlaySound(Sound'Ricochet1', SLOT_Misc, 48,, 512, GSpeed);
		break;
		case 1:
			PlaySound(Sound'Ricochet2', SLOT_Misc, 48,, 512, GSpeed);
		break;
		case 2:
			PlaySound(Sound'Ricochet3', SLOT_Misc, 48,, 512, GSpeed);
		break;
		case 3:
			PlaySound(Sound'Ricochet4', SLOT_Misc, 48,, 512, GSpeed);
		break;
	}
}
//-----------------------------------------------------
//MADDERS: Configuring damage.
//Footnote: Always treat charged pickups like they're on.
//-----------------------------------------------------
function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
 	local DeusExPickup DXP;
	local DeusExWeapon DXW;
 	local Inventory Inv;
 	
 	if (bCheckOnly) return;
	
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		DXW = DeusExWeapon(Inv);
		
  		if (DXP != None)
		{
   			DXP.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
		}
		else if (DXW != None)
		{
			DXW.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
		}
 	}
}

function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		//MADDERS: Mind the junk pile. Tuning this a bit.
  		if (DXP != None)
   			Ret *= DXP.VMDConfigurePickupDamageMult(DT, HitDamage, HitLocation);
 	}
 	
 	return Ret;
}

function bool VMDConfigurePickupDamageFilter(name DT, int HitDamage, Vector HitLocation)
{
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
  		if (DXP != None)
		{
   			if (!DXP.VMDFilterDamageTaken(DT, HitDamage, HitLocation))
			{
				return false;
			}
		}
 	}
	
	return true;
}

function int VMDConfigureCloakThresholdMod()
{
 	local DeusExPickup DXP;
 	local Inventory Inv;
 	local int Ret;
 	
 	Ret = 0;
 	for (Inv=Inventory; Inv != None; Inv=Inv.Inventory)
 	{
  		DXP = DeusExPickup(Inv);
		//MADDERS: Mind the junk pile. Tuning this a bit.
  		if (DXP != None)
   			Ret += DXP.VMDConfigureCloakThresholdMod();
 	}
 	
 	return Ret;
}

//MADDERS: Add goodies for non-vanilla pawns. Neat.
function RunModInvChecks()
{
 	local class<Inventory> IC;
 	local int Seed, GIS, i;
 	local string S[5], MC;
 	local bool bPass;
 	
 	S[0] = "COP";
 	S[1] = "SOLDIER";
 	S[2] = "TROOP";
 	S[3] = "THUG";
 	S[4] = "TERRORIST";
 	
 	//MC = CAPS(String(Self.Class));
 	//GIS = InStr(MC, "DEUSEX.");
	
 	//Don't run this for vanilla mobs.
	if (VMDOtherIsName("DeusEx.")) return;
 	
 	for(i=0; i<5; i++)
 	{
  		GIS = InStr(MC, S[i]);
  		if (GIS != -1)
  		{
   			bPass = true;
   			break;
  		}
 	}
 	
 	if (!bPass) return;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5, false);
 	if ((Seed == 4) && (!bAppliedSpecial))
 	{
  		IC = ObtainRandomGoodie();
  		
		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

function class<Inventory> ObtainRandomGoodie()
{
 	local int R;
 	
 	R = Rand(4);
 	
 	//>TMW already writing better code than &%)*
 	switch(R)
 	{
  		case 0:
   			if ((Frand() < 0.07) && (!IsA('HumanMilitary'))) return class'VialCrack';
   			return class'CandyBar';
 		break;
  		case 1:
			//MADDERS, 5/24/20: Don't do this anymore. The easter egg has been workshopped into a final form.
   			//if (Frand() < 0.05) return class'WeaponModEvolution';
   			//return class'Lockpick';
			return class 'Sodacan';
  		break;
  		case 2:
   			return class'Credits';
  		break;
  		case 3:
   			if (Frand() < 0.35) return class'WeaponHideagun';
   			return class'Cigarettes'; //The best. Ever.
  		break;
 	}
 	
 	return class'CandyBar';
}

function bool AddToInitialInventory(class<Inventory> NewClass, int NewCount, optional bool bAllowDuplicates)
{
	local int i, j, k, TCopies;
	local Vector TOffset;
	local DeusExAmmo DXA;
	local DeusExWeapon DXW;
	local Inventory Inv, TItem;
	
	if (!bInitialized)
	{
		//MADDERS, 2/25/25: Stop conflicts between plasma rifle and PS20, now that we cap PS20 ammo. You don't need both.
		if (class<WeaponHideAGun>(NewClass) != None)
		{
			for(i=0; i<ArrayCount(InitialInventory); i++)
			{
				if (InitialInventory[i].Inventory == class'WeaponPlasmaRifle')
				{	
					return false;
				}
			}
		}
		
		for(i=0; i<ArrayCount(InitialInventory); i++)
		{
			if ((InitialInventory[i].Inventory == NewClass) && (!bAllowDuplicates))
			{	
				return false;
			}
			
			if (InitialInventory[i].Inventory == None)
			{
				InitialInventory[i].Inventory = NewClass;
				InitialInventory[i].Count = NewCount;
				bItemUnnatural[i] = 1;
				return true;
			}
		}
	}
	//MADDERS, 12/27/23: Now if we missed our timing, just give us fresh shit.
	else
	{
		if (class<DeusExPickup>(NewClass) != None)
		{
			TCopies = NewCount;
			NewCount = 1;
		}
		
		for (j=0; j<Min(NewCount, 49); j++)
		{
			inv = None;
			if (Class<Ammo>(NewClass) != None)
			{
				inv = FindInventoryType(NewClass);
				if (inv != None)
				{
					Ammo(inv).AmmoAmount += Class<Ammo>(NewClass).default.AmmoAmount;
				}
			}
			//MADDERS: Fix credits being spammed 100 times!
			else if (class<Credits>(NewClass) != None)
			{
				inv = FindInventoryType(NewClass);
				if (inv != None)
				{
					Credits(inv).NumCopies += 1;
				}
			}
			else if (class<DeusExPickup>(NewClass) != None)
			{
				inv = FindInventoryType(NewClass);
				if (inv != None)
				{
					if (DeusExPickup(Inv).bCanHaveMultipleCopies)
					{
						DeusExPickup(inv).NumCopies += 1;
					}
					else
					{
						Inv = None;
					}
				}
			}
			else if (class<DeusExWeapon>(NewClass) != None)
			{
				inv = FindInventoryType(NewClass);
				if (inv != None)
				{
					if (DeusExWeapon(Inv).AmmoType != None)
					{
					 	DeusExWeapon(Inv).AmmoType.AmmoAmount += DeusExWeapon(Inv).Default.PickupAmmoCount;
					}
					else
					{
					 	DeusExWeapon(Inv).PickupAmmoCount += DeusExWeapon(Inv).Default.PickupAmmoCount;
					}
				}
			}
			
			if (inv == None)
			{
				inv = spawn(NewClass, self,, Location);
				if (Inv == None)
				{
					for (k=0; k<8; k++)
					{
						switch(k)
						{
							case 0: TOffset = vect(20,0,0); break;
							case 1: TOffset = vect(20,20,0); break;
							case 2: TOffset = vect(0,20,0); break;
							case 3: TOffset = vect(-20,20,0); break;
							case 4: TOffset = vect(-20,0,0); break;
							case 5: TOffset = vect(-20,-20,0); break;
							case 6: TOffset = vect(0,-20,0); break;
							case 7: TOffset = vect(20,-20,0); break;
						}
						inv = spawn(InitialInventory[i].Inventory, self,, Location+TOffset);
						if (Inv != None) break;
					}
				}
				
				//MADDERS: Don't let our ammos be swapped out. Plasma keeps fucking this up, somehow.
				if ((Weapon(Inv) != None) && (DeusExAmmo(Weapon(Inv).AmmoType) != None))
				{
					DeusExAmmo(Weapon.AmmoType).bCrateSummoned = true;
				}
				else if (WeaponHideAGun(Inv) != None)
				{
					WeaponHideAGun(Inv).PickupAmmoCount = 2;
				}
				
				if (DeusExAmmo(Inv) != None)
				{
					DeusExAmmo(Inv).bCrateSummoned = true;
				}
				
				if (DeusExPickup(Inv) != None)
				{
					DeusExPickup(Inv).NumCopies = TCopies;
				}
				
				if (inv != None)
				{
					inv.InitialState = 'Idle2';
					inv.GiveTo(Self);
					inv.SetBase(Self);
				}
			}
		}
		
		for (TItem = Inventory; TItem != None; TItem = TItem.Inventory)
		{
			DXW = DeusExWeapon(TItem);
			if ((DXW != None) && (DXW.AmmoType == None))
			{
				for(i=ArrayCount(DXW.AmmoNames)-1; i>=0; i--)
				{
					DXA = DeusExAmmo(FindInventoryType(DXW.AmmoNames[i]));
					if (DXA != None)
					{
						DXW.LoadAmmo(i);
						break;
					}
				}
				if (DXW.AmmoType == None)
				{
					DXA = DeusExAmmo(FindInventoryType(DXW.AmmoName));
					if (DXA != None)
					{
						DXW.AmmoType = DXA;
					}
				}
			} 
		}
		
		if (Inv != None)
		{
			PostSpecialStatCheck();
			return true;
		}
	}
	
	PostSpecialStatCheck();
	return false;
}

function bool IsInCombatesqueState()
{
	if (IsInState('Seeking')) return true;
	if (IsInState('Attacking')) return true;
	if (IsInState('Fleeing')) return true;
	if (IsInState('Alerting')) return true;
	if (IsInState('Burning')) return true;
	if (IsInState('Stunned')) return true;
	if (IsInState('RubbingEyes')) return true;
	if (IsInState('HandlingEnemy')) return true;
	if (IsInState('AvoidingProjectiles')) return true;
	if (IsInState('TakingHit')) return true;
	if (IsInState('VMDPickingUpWeapon')) return true;
	
	if (IsInState('FallingState')) return true;
	if (IsInState('Swimming')) return true;
	if (IsInState('Dying')) return true;
	if (IsInState('OpeningDoor')) return true;
	if (IsInState('Leaving')) return true;
	//if (IsInState('Conversation')) return true;
	
	return false;
}

function SpoofBarkLine(DeusExPlayer DXP, string SpoofLine, optional float DisplayTime)
{
	local DeusExRootWindow Root;
	
	if (DXP == None) return;
	if (DisplayTime < 0 || DisplayTime ~= 0.0) DisplayTime = 3.5;
	
	DXP.InitRootWindow();
	Root = DeusExRootWindow(DXP.RootWindow);
	if ((Root != None) && (Root.HUD != None) && (Root.HUD.BarkDisplay != None))
	{
		Root.Hud.BarkDisplay.AddBark(SpoofLine, DisplayTime, Self);
	}
}

function VMDAddSmellException(VMDSmellManager TManager)
{
	local int i;
	
	for(i=0; i<ArrayCount(IgnoredSmells); i++)
	{
		if (IgnoredSmells[i] == TManager)
		{
			break;
		}
		if (IgnoredSmells[i] == None || IgnoredSmells[i].bDeleteMe)
		{
			IgnoredSmells[i] = TManager;
			break;
		}
	}
}

function bool VMDSmellsAreEquivalent(name Smell1, name Smell2)
{
	switch(Smell1)
	{
		case 'PlayerSmell':
		case 'PlayerAnimalSmell':
			if (Smell2 == 'PlayerSmell' || Smell2 == 'PlayerAnimalSmell')
			{
				return true;
			}
		break;
		case 'PlayerFoodSmell':
		case 'StrongPlayerFoodSmell':
			if (Smell2 == 'PlayerFoodSmell' || Smell2 == 'StrongPlayerFoodSmell')
			{
				return true;
			}
		break;
		case 'PlayerBloodSmell':
		case 'StrongPlayerBloodSmell':
			if (Smell2 == 'PlayerBloodSmell' || Smell2 == 'StrongPlayerBloodSmell')
			{
				return true;
			}
		break;
		case 'PlayerZymeSmell':
			if (Smell2 == 'PlayerZymeSmell')
			{
				return true;
			}
		break;
		case 'PlayerSmokeSmell':
		case 'StrongPlayerSmokeSmell':
			if (Smell2 == 'PlayerSmokeSmell' || Smell2 == 'StrongPlayerSmokeSmell')
			{
				return true;
			}
		break;
	}
	return false;
}

function bool VMDShouldIgnoreSmell(VMDSmellManager TManager, Name SmellType)
{
	local int i;
	
	if (DeusExCarcass(TManager.Owner) != None)
	{
		if (DeusExCarcass(TManager.Owner).bAnimalCarcass)
		{
			return true;
		}
		//MADDERS, 2/25/25: Only care about our faction's dead bodies, to minimize AI disruption from smells.
		if ((!VMDPawnIsLawEnforcement()) && (DeusExCarcass(TManager.Owner).Alliance != Alliance))
		{
			return true;
		}
	}
	
	for(i=0; i<ArrayCount(IgnoredSmells); i++)
	{
		if (IgnoredSmells[i] != None)
		{
			if (IgnoredSmells[i] == TManager)
			{
				return true;
			}
			else if (VMDSmellsAreEquivalent(TManager.SmellType, IgnoredSmells[i].SmellType) && (VSize(TManager.Location - IgnoredSmells[i].Location) > CollisionRadius * 3) && (VSize(TManager.Location - IgnoredSmells[i].Location) < TManager.CollisionRadius * 1.2))
			{
				return true;
			}
			else if ((i == ArrayCount(IgnoredSmells)-1) && (IgnoredSmells[i] != None))
			{
				return true;
			}
		}
	}
	
	return false;
}

function HandleSmell(Name event, EAIEventState state, Actor SmellOwner)
{
	local float GSpeed;
	//React
	local Actor bestActor;
	local Pawn  instigator;
	local DeusExRootWindow Root;
	local VMDBufferPlayer Player, VMP;
	local VMDSmellManager TManager;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	Player = VMDBufferPlayer(SmellOwner);
	VMP = GetLastVMP();
	TManager = VMDSmellManager(SmellOwner);
	if (VMP == None)
	{
		return;
	}
	if ((TManager != None) && (VMDShouldIgnoreSmell(TManager, TManager.SmellType)))
	{
		return;
	}
	
	if ((state == EAISTATE_Begin || state == EAISTATE_Pulse) && (!IsInCombatesqueState()))
	{
		if ((VMP != None) && (!VMP.IsInState('Dying')) && (EnemiesOrNeutralLeft() > 0))
		{
			//MADDERS: Being seen covered in blood
			if (LastSmellType == 'PlayerStrongBloodSmell' || (LastSmellType == 'PlayerZymeSmell' && VMDPawnIsLawEnforcement()))
			{
				SmellOwner.AISendEvent('MegaFutz', EAITYPE_Audio, 5.0, 384);
			}
			
			if ((SmellSniffCooldown <= 0) && (!Default.bImportant) && (!bInvincible) && (!bInsignificant) && (!bDoesntSniff))
			{
				//MADDERS: Always give sniff for hostile reactions, but give a short cooldown.
				//Rarely give a sniff for neutral reactions, and add a longer cooldown.
				//Never do this for allies, but still parse the blood doodad.
				switch (GetPawnAllianceType(VMP))
				{
					case ALLIANCE_Hostile:
						SmellSniffCooldown = 5.0;
					break;
					case ALLIANCE_Neutral:
						SmellSniffCooldown = 30.0;
						if (FRand() < 0.65) return;
					break;
					case ALLIANCE_Friendly:
						return;
					break;
				}
				if (bIsFemale)
				{
					PlaySound(Sound'SmellSniffFemale', SLOT_None,,,, GSpeed);
				}
				else
				{
					PlaySound(Sound'SmellSniff', SLOT_None,,,, GSpeed);
				}
				
				//MADDERS: Visual feedback, too, please.
				SpoofBarkLine(VMP, FakeBarkSniffing);
			}
			
			if (Player == None || IsValidEnemy(Player))
			{
				//MADDERS, 11/30/20: Close smell = attack. Cheaty, but so is the player swoocing around with smell at point blank.
				if ((Player != None) && (VSize(Player.Location - Location) < CollisionRadius * 3))
				{
					Enemy = Player;
					GoToState('Attacking');
				}
				else
				{
					if ((TManager != None) && (TManager.bIgnoreAfterSmell))
					{
						VMDAddSmellException(TManager);
					}
					//Carcass? Guess?
					SetSeekLocation(VMP, SmellOwner.Location, SEEKTYPE_None); //Guess
					HandleEnemy();
				}
			}
		}
	}
}

function int CountSelf()
{
 	local int Ret;
 	local Actor A;
 	
 	forEach AllActors(Self.Class, A)
 	{
 	 	if (A != None) Ret++;
 	}
 
 	return Ret;
}

function int NumOnlookers(Actor Frobber, optional bool bSpecialHostile)
{
 	local bool FlagHostileEnough;
 	local int Ret, RotDif;
 	local float GDist, GDM, RDM, VD, DarkMult;
	local AugmentationManager AM;
	local DeusExPlayer DXP;
	local Pawn TTar;
	local ScriptedPawn SP;
	local VMDBufferPlayer VMP;
 	
	DXP = DeusExPlayer(Frobber);
	VMP = VMDBufferPlayer(Frobber);
	if (DXP == None || DXP.bHidden) return 0;
	
	if (VMP != None)
	{
		if (VMP.VMDPlayerIsCloaked()) return 0;
	}
	else
	{
		AM = DXP.AugmentationSystem;
		if (AM == None || AM.GetAugLevelValue(class'AugCloak') != -1.0) return 0;
		if (DXP.Style == STY_Translucent) return 0;
	}
	
 	forEach RadiusActors(Class'ScriptedPawn', SP, 960)
 	{
		FlagHostileEnough = !bSpecialHostile;
		
		// && (FastTrace(SP.Location, Location))
  		if ((SP != None) && (SP != Self) && (SP.bInWorld) && (Animal(SP) == None) && (Robot(SP) == None) && (SP.GetPawnAllianceType(Self) < 2))
  		{
			if ((VMDBufferPawn(SP) == None || !VMDBufferPawn(SP).bInsignificant) && (!SP.IsInState('Stunned')) && (!SP.IsInState('RubbingEyes')))
			{
				TTar = DXP;
				//MADDERS, 8/22/23: New boolean. For non-allies, only let people who don't trust the player spot pickpocketing.
				if ((bSpecialHostile) && (SP.GetPawnAllianceType(DXP) > 0))
				{
					FlagHostileEnough = true;
				}
				
				if ((FlagHostileEnough) && (SP.AICanSee(TTar, SP.ComputeActorVisibility(TTar), false, true, true, true) > 0))
				{
					Ret++;
				}
				
   				/*VD = SP.SightRadius / 3.0;
   				GDist = VSize(SP.Location - Location);
   				GDM = (VD - GDist) / VD;
   				RotDif = SP.Rotation.Yaw - Rotator(Location - SP.Location).Yaw;
   				RDM = Abs(RotDif);
   				
   				//MADDERS: Calculate for darkness as well. Bit of a hack, but 0.15 is cap visibility, and 0.005 is zero visibility.
   				DarkMult = FMin(1.0, ((AIGETLIGHTLEVEL(Frobber.Location) - 0.005) / 0.01));
   				
   				if (RDM < 16384 * GDM * DarkMult)
   				{
    					Ret++;
				}*/
			}
  		}
 	}
 	
 	return Ret;
}

//-----------------------------
//Empty 1 item from pockets.
function bool ShouldDoSinglePickPocket(DeusExPlayer Frobbie)
{
	//MADDERS, 3/12/23: Premature hack for when we add player hands. Also, now block decos, too, dummy.
	if (Frobbie == None) return false;
	if ((Frobbie.InHand != None) && (!Frobbie.InHand.IsA('PlayerHands'))) return false;
	if (Frobbie.CarriedDecoration != None) return false;
	
 	//Don't steal from plot important folks.
 	if ((bImportant) && (Default.bImportant)) return False;
	if (bInvincible) return false;
	
	//MADDERS, 1/3/21: Don't allow pickpocketing of animals or robots.
	if (IsA('Animal') || IsA('Robot')) return False;
	
	//MADDERS: Skill augment required now.
	if ((VMDBufferPlayer(Frobbie) != None) && (!VMDBufferPlayer(Frobbie).HasSkillAugment('LockpickPickpocket')))
	{
		return False;
	}
	
	//MADDERS, 1/3/21: Don't allow pickpocketing on seats that are too big and clumsy. CouchLeather, I'm looking at you.
	//MADDERS, 8/7/25: Allow invisible seats (like benches in Revision) to allow pickpocketing.
	if ((SeatActor != None) && (SeatActor.CollisionRadius > CollisionRadius * 1.625) && (!SeatActor.bHidden))
	{
		return False;
 	}
	
	if (IsInState('WaitForRespawn')) return True;
 	
 	if (IsInState('Attacking')) return false;
 	if (IsInState('Alerting')) return false;
 	if (IsInState('HandlingEnemy')) return false;
 	if (IsInState('AvoidingProjectiles')) return false;
 	if (IsInState('AvoidingPawn')) return false;
 	
	if (IsInState('Stunned')) return false;
 	if (IsInState('Burning')) return false;
 	if (IsInState('TakingHit')) return false;
 	if (IsInState('Dying')) return false;
 	if (IsInState('WaitForRespawn')) return false;
 	
 	if (IsInState('FallingState')) return false;
 	
	//MADDERS, 1/17/21: Tear gas lets us pickpocket while they're distracted. Nonlethal delight.
	//UPDATE, 2/6/21: We're blocking this off until further rebalancing occurs. This is very silly until further notice.
	//UPDATE, 12/11/21: We're re-enabling this, but with a twist. If we're rubbing eyes, snap out of it once pickpocketed.
 	if ((Enemy == Frobbie) && (!IsInState('RubbingEyes'))) return False;
 	
 	return True;
}

function bool IsSinglePickPocketing(Actor Frobber, out Actor HitActor)
{
 	local DeusExPlayer DXP;
 	local Vector Offset, HitLocation, HitNormal;
 	local Vector Start, End;
 	//local Actor HitActor;
 	
 	//Null control that also shrinks frob code some.
 	if (!ShouldDoSinglePickPocket(DeusExPlayer(Frobber))) return false;
	
	//MADDERS, 1/3/21: Don't allow pickpocketing while swimming or other nonsense... Unless sitting.
	//Also don't pickpocket if we're moving too fast.
 	if (((Physics != PHYS_Walking) && (SeatActor == None)) || VSize(Frobber.Velocity) > 150) return False;
 	
 	DXP = DeusExPlayer(Frobber);
 	
 	if (DXP == None) return False;
 	
 	if (DXP.bDuck == 0) return False; //Only steal when crouched!
 	
 	Start = DXP.Location + vect(0,0,1) * DXP.BaseEyeHeight;
 	End = Start + Vector(DXP.ViewRotation) * DXP.MaxFrobDistance;
 	
 	HitActor = DXP.Trace(HitLocation, HitNormal, End, Start, True);
 	
 	if ((HitActor != Self) && (SeatActor == None || HitActor != SeatActor)) return False;
 	
 	offset = (hitLocation - (Location-PrePivot)) << Rotation;
 	
 	//Anywhere on back half with at least 20% of "inwards" offset.
 	if ((Offset.X < CollisionRadius * 0.5) && (Abs(Offset.Y) < CollisionRadius * 0.8) && (Offset.Z < CollisionHeight * 0.6)) return True;
 	
 	return False;
}

function Frob(Actor Frobber, Inventory FrobWith)
{
 	local bool bPick;
	local Actor HitActor;
 	
 	//MADDERS: Do this if we're in the dark, as to identify us.
 	if ((bEverNotFrobbed) && (!(AIGETLIGHTLEVEL(Location) > 0.005)))
 	{
  		Frobber.AISendEvent('Player', EAITYPE_Audio, 8.0, 192);
  		Frobber.AISendEvent('LoudNoise', EAITYPE_Audio, 8.0, 192);
  		bEverNotFrobbed = false;
  		return;
 	}
 	bEverNotFrobbed = false;
 	
 	if (IsSinglePickpocketing(Frobber, HitActor))
 	{
  		DoSinglePickpocketDump(Frobber, HitActor);
  		return;
 	}
 	
 	Super.Frob(Frobber, Frobwith);
}

function bool IsInChunkyWeapon(DeusExAmmo DXA)
{
 	local DeusExWeapon DXW;
 	
 	//MADDERS: Extra null check.
 	if (DXA == None) return false;
 	
 	forEach AllActors(class'DeusExWeapon', DXW)
 	{
  		if ((DXW != None) && (DXW.AmmoType == DXA) && (DXW.VMDConfigureInvSlotsX(None) >= 90 || DXW.PickupViewMesh == LodMesh'DeusExItems.InvisibleWeapon'))
  		{
   			return true;
  		}
 	}
 	
 	return false;
}

function DoSinglePickpocketDump(Actor Frobber, Actor HitActor)
{
	local bool bHadWeapon, bShowWepIcon;
 	local int ListSize, DropID, KeyIndex, AmmoRet, MatchCount;
	local float SkillModTime, GSpeed;
 	local DeusExWeapon DXW, CDXW, ODXW, MatchDXW;
 	local DeusExAmmo DXA, ODXA;
 	local DeusExPickup DXP, MatchDXP;
 	local Inventory Inv, Next, List[16], ListNext[16], Dump;
	local VMDBufferPlayer VMP;
 	
 	//MADDERS: Stop only in this part, so we don't interact on accident.
 	if (TimeSincePickpocket > 0.0) return;
 	
	VMP = VMDBufferPlayer(Frobber);
	if (VMP == None) return;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if (VMP.SkillSystem != None)
	{
		SkillModTime = 0.25 * VMP.SkillSystem.GetSkillLevel(class'SkillLockpicking');
	}
	
 	Inv = Inventory;
 	TimeSincePickpocket = 1.0 - SkillModTime;
 	KeyIndex = -1;
 	
 	if (Inv != None)
 	{
  		do
  		{
			ODXA = None;
			ODXW = None;
			
   			Next = Inv.Inventory;
   			DXW = DeusExWeapon(Inv);
			if (DXW != None)
			{
				bHadWeapon = true;
				ODXA = DeusExAmmo(DXW.AmmoType);
			}
   			CDXW = DeusExWeapon(Weapon);
 			
 			DXA = DeusExAmmo(Inv);
			if (DXA != None)
			{
				ODXW = GetOwningWeapon(DXA);
			}
   			DXP = DeusExPickup(Inv);
   			if ((DXW != None) && (DXW != CDXW) && (DXW.VMDConfigureInvSlotsX(None) < 90) && (DXW.PickupViewMesh != LodMesh'DeusExItems.InvisibleWeapon'))
   			{
				//MADDERS, 8/7/25: Stop us from duplicating Gilbert's gun. Shitty, but alright.
   				if ((DXW != Weapon) && (!DXW.bGenerousWeapon)) //(!DXW.bHandToHand) && 
    				{
     					List[ListSize] = Inv;
     					ListNext[ListSize] = Next;
     					ListSize++;
    				}
   			}
   			else if ((DXA != None) && (DXA.AmmoAmount > 0) && (DXA.PickupViewMesh != LodMesh'DeusExItems.TestBox') && (!IsInChunkyWeapon(DXA)))
   			{
				if (ODXW == None || DXA.AmmoAmount > ODXW.ReloadCount - ODXW.ClipCount)
				{
    					//if ((CDXW == None) || (DXA != CDXW.AmmoType))
    					//{
     						List[ListSize] = Inv;
     						ListNext[ListSize] = Next;
     						ListSize++;
					//}
    				}
   			}
   			else if (DXP != None)
   			{
				if (ChargedPickup(DXP) == None || (ChargedPickup(DXP).Charge >= DXP.Default.Charge && VMP.HasSkillAugment('EnviroLooting')))
				{
    					if (NanoKey(DXP) != None)
    					{
     						KeyIndex = ListSize;
    					}
    					List[ListSize] = Inv;
    					ListNext[ListSize] = Next;
    					ListSize++;
				}
   			}
   			Inv = Next;
  		}
  		until (Inv == None);
 	}
 	
 	if (ListSize > 0)
 	{
  		DropID = Rand(ListSize);
  		//NEW, 11/26/19: Prioritize nanokeys.
  		if (KeyIndex != -1) DropID = KeyIndex;
  		Dump = List[DropID];
		
		DXA = DeusExAmmo(Dump);
		DXW = DeusExWeapon(Dump);
		DXP = DeusExPickup(Dump);
		
		if (DXA != None)
		{
			//MADDERS, 11/29/21: Leave one mag in the weapon.
			ODXW = GetOwningWeapon(DXA);
			if (ODXW != None)
			{
				DXA.AmmoAmount = ODXW.ReloadCount - ODXW.ClipCount;
			}
			else
			{
				DXA.AmmoAmount = 0;
			}
			
			//Spawn a copy, dump the rest.
			Dump = Spawn(DXA.Class,,,DXA.Location, DXA.Rotation);
			DXA = DeusExAmmo(Dump);
		}
  		
  		//Repair our item chain.
  		if (Dump == Inventory) Inventory = ListNext[DropID];
  		
		PlaySound(Sound'BasketballSwoosh',,,,,1.35 + (FRand() * 0.3) * GSpeed);
		
  		//MADDERS: Alert NPCs we're picking his pockets
  		Frobber.AISendEvent('Futz', EAITYPE_Visual);
  		
		//MADDERS, 8/21/23: Item clogging fix. Don't block up pathing for AI.
		Dump.SetPropertyText("bCorpseUnclog", "True");
		if (HitActor == SeatActor)
		{
			Dump.DropFrom(HitActor.Location + ((vect(-1.15,0,0) * HitActor.CollisionRadius) >> Frobber.Rotation));
		}
		else
		{
  			Dump.DropFrom(HitActor.Location);
		}
		
  		if (DXA != None)
		{
			DXA.AmmoAmount = class'VMDStaticFunctions'.static.GWARRRand(1, 1, None, DXA, VMP);
		}
		if (DXP != None)
		{
			MatchCount = DXP.NumCopies;
			MatchDXP = DeusExPickup(VMP.FindInventoryType(DXP.Class));
		}
 		if (DXW != None)
		{
			MatchDXW = DeusExWeapon(VMP.FindInventoryType(DXW.Class));
			DXW.PickupAmmoCount = class'VMDStaticFunctions'.Static.GWARRRand(1, 1, DXW, DeusExAmmo(DeusExWeapon(Dump).AmmoType), VMP);
			DXW.bWeaponStay = False;
			if (DXW.AmmoName == None || DXW.AmmoName == class'AmmoNone' || VMP.FindInventoryType(DXW.AmmoName) == None || MatchDXW != None)
			{
				if (DXW.AmmoName == None || DXW.AmmoName.Default.Icon != DXW.Icon) //(VMP.FindInventoryType(DXW.Class) == None) && 
				{
					bShowWepIcon = true;
				}
			}
  		}
  		Dump.Instigator = Self;
  		Dump.Lifespan = 0;
  		Dump.Acceleration = (vect(0, 0, -0.5) + (Vector(Pawn(Frobber).Rotation + Rot(32768, 0, 0)) / 2)) * 256;
  		Dump.Velocity = Dump.Acceleration;
		
		//MADDERS, 8/22/23: New boolean. For non-allies, only let people who don't trust the player spot pickpocketing.
 		if (NumOnlookers(Frobber, (GetAllianceType(VMP.Alliance) > 0 && AllianceIsPermanent(VMP.Alliance)) ) > 0)
 		{
  			AgitatePickpocketFailure(VMP);
			VMP.ClientMessage(MessagePickpocketingSpotted);
 		}
		else
		{
			VMP.FrobTarget = Dump;
			if (VMP.HandleItemPickup(Dump))
			{
				if ((DXA == None) && (NanoKey(Dump) == None) && (Credits(Dump) == None))
				{
					if (MatchDXP != None)
					{
						class'VMDStaticFunctions'.Static.AddReceivedItem(VMP, MatchDXP, MatchCount);
					}
					else if (DXP != None)
					{
						class'VMDStaticFunctions'.Static.AddReceivedItem(VMP, DXP, MatchCount);
					}
					else
					{
						if ((DXW == None || bShowWepIcon) && (Dump != None))
						{
							if (MatchDXW != None) class'VMDStaticFunctions'.Static.AddReceivedItem(VMP, MatchDXW, 1);
							else class'VMDStaticFunctions'.Static.AddReceivedItem(VMP, Dump, 1);
						}
					}
				}
			}
			VMP.ClientMessage(MessagePickpocketingSuccess);
		}
 	}
	else
	{
		VMP.ClientMessage(MessagePickpocketingFailure);
	}
	
	//MADDERS, 1/3/21: Update pickup noises, please.
	PostPickpocketCheck(bHadWeapon);
	PostSpecialStatCheck();
}

function PostPickpocketCheck(bool bHadWeapon)
{
	//MADDERS, 12/11/21: If we're rubbing eyes, snap out of it once pickpocketed.
	if (IsInState('RubbingEyes'))
	{
		if (HasNextState())
			GotoNextState();
		else
			GotoState('Wandering');
	}
	
	//MADDERS, 2/6/21: Make us bitch out if stripped of our weapons.
	//However, MIB's and other elite foes are off the list of candidates.
	if ((bHadWeapon) && (StartingHealthValues[6] <= 100*LastEnemyHealthScale))
	{
		if (!VMDHasWeapon())
		{
			bCower = true;
			bMilitantCower = true;
		}
	}
}

function bool VMDHasWeapon()
{
	local Inventory Inv;
	local DeusExWeapon DXW;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (DeusExWeapon(Inv) != None)
		{
			DXW = DeusExWeapon(Inv);
			break;
		}
	}
	if (DXW == None)
	{
		return false;
	}
	
	return true;
}

function AgitatePickpocketFailure(VMDBufferPlayer Player)
{
 	local VMDTheftIndicator CI;
 	
 	CI = Player.Spawn(class'VMDTheftIndicator',Self,,Player.Location, Player.Rotation);
 	CI.Pawn = Self;
 	CI.Player = Player;
 	CI.InvokeCrime();
}

state TakingHit
{
	ignores seeplayer, hearnoise, bump, hitwall, reacttoinjury;
	
	function BeginState()
	{
		StandUp();
		LastPainTime = Level.TimeSeconds;
		LastPainAnim = AnimSequence;
		bInterruptState = false;
		BlockReactions();
		bCanConverse = False;
		bStasis = False;
		//SetDistress(true);
		TakeHitTimer = 2.0;
		EnemyReadiness = 1.0;
		ReactionLevel  = 1.0;
		bInTransientState = true;
		EnableCheckDestLoc(false);
	}
}

State Fleeing
{
	function BeginState()
	{
		StandUp();
		Disable('AnimEnd');
		//Disable('Bump');
		BlockReactions();
		if (!bCower)
			bCanConverse = False;
		bStasis = False;
		SetupWeapon(false, true);
		//SetDistress(true);
		EnemyReadiness = 1.0;
		//ReactionLevel  = 1.0;
		SeekPawn = None;
		EnableCheckDestLoc(false);
	}
}

State Attacking
{
     function BeginState()
     {
          StandUp();

          // hack
          if (MaxRange < MinRange+10)
               MaxRange = MinRange+10;
          bCanFire      = false;
          bFacingTarget = false;

          SwitchToBestWeapon();

          //EnemyLastSeen = 0;
          BlockReactions();
          bCanConverse = False;
          bAttacking = True;
          bStasis = False;
          //SetDistress(true);

          CrouchTimer = 0;
          EnableCheckDestLoc(false);
     }
}

function PlayDyingSound()
{
	SetDistressTimer();
	
	//Trash pawns always scream.
	if (bDoScream || Animal(Self) != None || Robot(Self) != None || bInsignificant)
	{
		if ((HeadRegion.Zone != None) && (HeadRegion.Zone.bWaterZone))
		{
			if ((Animal(Self) == None) && (Robot(Self) == None) && (UnderwaterTime > 0))
			{
				if (bIsFemale)
				{
					Die = Sound'FemaleWaterDeath';
				}
				else
				{
					Die = Sound'MaleWaterDeath';
				}
				PlaySound(Die, SLOT_Pain,,,, RandomPitch());
			}
			else
			{
				PlaySound(Die, SLOT_Pain,,,, RandomPitch()*0.85);
			}
		}
		else
		{
			PlaySound(Die, SLOT_Pain,,,, RandomPitch());
		}
		AISendEvent('LoudNoise', EAITYPE_Audio);
		if (bEmitDistress)
			AISendEvent('Distress', EAITYPE_Audio);
	}
	else
	{
		//MADDERS: Play a smaller death noise when we're killed off.
		AISendEvent('LoudNoise', EAITYPE_Audio,, 320);
	}
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

//	ClientMessage("PlayDying()");
	if (Region.Zone.bWaterZone)
	{
		if (HasAnim('WaterDeath')) PlayAnimPivot('WaterDeath',, 0.1);
	}
	else if (bSitting)  // if sitting, always fall forward
	{
		if (HasAnim('DeathFront')) PlayAnimPivot('DeathFront',, 0.1);
	}
	else
	{
		GetAxes(Rotation, X, Y, Z);
		dotp = (Location - HitLoc) dot X;

		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
		{
			if (HasAnim('DeathBack')) PlayAnimPivot('DeathBack',, 0.1);
		}
		else				// shot from the back, fall front
		{
			if (HasAnim('DeathFront')) PlayAnimPivot('DeathFront',, 0.1);
		}
	}

	// don't scream if we are stunned
	if (!bOnFire && (damageType == 'Stunned' || damageType == 'KnockedOut' || damageType == 'Poison' || damageType == 'PoisonEffect'))
	{
		bStunned = True;
		
		if (bIsFemale)
		{
			PlaySound(Sound'FemaleUnconscious', SLOT_Pain,,,, RandomPitch());
		}
		//MADDERS, 8/1/23: Swoocing right in with the new unc sound.
		else if (VMDPawnIsCommando())
		{
			PlaySound(Sound'CommandoUnconscious', SLOT_Pain,,,, RandomPitch());
		}
		else
		{
			if (VMDPawnIsChild())
			{
				PlaySound(Sound'MaleUnconscious', SLOT_Pain,,,, RandomPitch()*1.55);
			}
			else
			{
				PlaySound(Sound'MaleUnconscious', SLOT_Pain,,,, RandomPitch());
			}
		}
	}
	else
	{
		//MADDERS, 1/12/21: Being witnessed or being killed as an ally to the player triggers aggro every time.
		//This makes instant kills only good when used tactically... And responsibily.
		//----------------
		if ((Instigator != None) && (GetPawnAllianceType(Instigator) == ALLIANCE_Friendly))
		{
			bDoScream = true;	
		}
		
		if (VMDBufferPlayer(Instigator) == None || !VMDBufferPlayer(Instigator).HasSkillAugment('MeleeAssassin'))
		{
			bDoScream = true;
		}
		
		if (bDoScream || Animal(Self) != None || Robot(Self) != None || bInsignificant)
		{
			bStunned = False;
			PlayDyingSound();
		}
	}
}

//MADDERS: Establish hook functions.
function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	VMDBeginPlayHook();
	VMDInitializeSubsystems();
}

function VMDBeginPlayHook()
{
	local int i;
	
	if (StoredSkin == None)
	{
		StoredSkin = Skin;
	}
	if (StoredTexture == None)
	{
		StoredTexture = Texture;
	}
	for (i=0; i<ArrayCount(Multiskins); i++)
	{
		if (StoredMultiskins[i] == None)
		{
			StoredMultiskins[i] = Multiskins[i];
		}
	}
}

function UpdateActiveAugsStr()
{
	local Augmentation AAug;
	local string TStr, CRHack;
	
	if (AugmentationSystem != None)
	{
		CRHack = Chr(13)$Chr(10);
		
		for(AAug = AugmentationSystem.FirstAug; AAug != None; AAug = AAug.Next)
		{
			if (AAug.bHasIt && (AAug.bIsActive || (VMDBufferAugmentation(AAug) != None && VMDBufferAugmentation(AAug).bPassive)))
			{
				if (TStr != "")
				{
					TStr = TStr$CRHack;
				}
				TStr = TStr$AAug.AugmentationName;
			}
		}
		
		ActiveAugStr = TStr;
	}
}

//MADDERS, 12/27/23: Fun little aug manager for us. Yay.
function VMDInitializeSubsystems()
{
	if (AugmentationSystem != None)
	{
		return;
	}
	
	if (bHasAugmentations)
	{
		bFearEMP = true;
		AugmentationSystem = Spawn(class'VMDNPCAugmentationManager', Self);
		AugmentationSystem.CreateAugmentations(Self);
		AugmentationSystem.AddAllAugs();
		AugmentationSystem.SetAllAugsToMaxLevel();
		AugmentationSystem.SetOwner(Self);
	}
}

//MADDERS, 4/29/25: Scrub this stuff sometimes, like when giving child classes different augs.
function VMDWipeAllAugs()
{
	if (AugmentationSystem != None)
	{
		AugmentationSystem.Destroy();
		AugmentationSystem = None;
	}
	CurSpeedAug = None;
	CurTargetAug = None;
	CurCombatAug = None;
	CurCloakAug = None;
	CurVisionAug = None;
	CurStealthAug = None;
	BulkReferenceAug = None;
}

function VMDMaintainEnergy(float DeltaTime)
{
	local float EnergyUse, LastEnergy, TEnergy;
	local BioelectricCell TCell;
	
	// Don't waste time doing this if the player is dead or paralyzed
	if (!IsInState('Dying'))
   	{
		if ((BiocellUseTimer > 0) && (VMDIsInHealableState()) && (Robot(Self) == None) && (Animal(Self) == None))
		{
			BiocellUseTimer -= DeltaTime;
			if (BioCellUseTimer <= 0)
			{
				LastEnergy = Energy;
				
				BioCellUseTimer = 0;
				TCell = BioelectricCell(FindInventoryType(class'BioelectricCell'));
				if ((TCell != None) && (!TCell.bDeleteMe) && (TCell.NumCopies > 0) && (!TCell.IsInState('Activated')))
				{
					TCell.Activate();
				}
				
				if ((LastEnergy <= 0) && (Energy > 0))
				{
					if (VMDShouldActivateAugs())
					{
						AugmentationSystem.ActivateAll();
					}
					else
					{
						AugmentationSystem.ActivateAllEco();
					}
				}
			}
		}
		
      		if (Energy > 0)
      		{
			if (bKillswitchEngaged)
			{
				TEnergy = FMax((Energy / 15)*DeltaTime, 3.0*DeltaTime);
			}
			
         		// Decrement energy used for augmentations
         		EnergyUse = AugmentationSystem.CalcEnergyUse(DeltaTime);
         		Energy = FClamp(Energy - (EnergyUse + TEnergy), 0, EnergyMax);
		}
		
		//Do check if energy is 0.  
		// If the player's energy drops to zero, deactivate 
		// all augmentations
		//------------------
		//MADDERS: Pop biocells as needed.
		if (Energy < EnergyMax * 0.5)
		{
			if ((BiocellUseTimer == 0) && (Enemy != None || !bKillswitchEngaged))
			{
				TCell = BioelectricCell(FindInventoryType(class'BioelectricCell'));
				
				if ((TCell != None) && (!TCell.bDeleteMe) && (TCell.NumCopies > 0))
				{
					BiocellUseTimer = 1.5;
				}
			}
			
			if (Energy <= 0)
      			{
         			AugmentationSystem.DeactivateAllEconomy();
			}
		}
	}
}

function bool VMDShouldActivateAugs()
{
	if (Enemy != None || IsInState('HandlingEnemy') || IsInState('Attacking') || IsInState('Seeking') || SeekLevel > 0 || IsInState('Burning') || IsInState('Stunned') || IsInState('RubbingEyes'))
	{
		return true;
	}
	
	if ((!bAugsGuardDown) && (!bInvincible) && (Orders == 'WaitingFor' || Orders == 'RunningTo' || Orders == 'GoingTo') && (VSize(Acceleration) > 10))
	{
		return true;
	}
	
	if ((!bAugsGuardDown) && (!bInvincible) && (IsInState('Conversation')))
	{
		return true;
	}
	
	return false;
}

//We're only called during speed aug actually being active. Very handy.
function VMDUpdateSpeedAugEffects(float DT)
{
	local int i, TarIndex[3];
	local VMDSpeedAugImage TImage;
	
	//MADDERS, 12/28/23: This looks bad to do while cloaked, so don't.
	if ((CurCloakAug != None) && (CurCloakAug.IsInState('Active')))
	{
		return;
	}
	
	if (SpeedAfterimageTimer > 0)
	{
		SpeedAfterimageTimer -= DT;
	}
	else
	{
		TImage = Spawn(class'VMDSpeedAugImage',,, Location);
		if (TImage != None)
		{
			TImage.Mesh = Mesh;
			TImage.Skin = Skin;
			TImage.Texture = Texture;
			TImage.ScaleGlowMult = ScaleGlow;
			for(i=0; i<ArrayCount(Multiskins); i++)
			{
				TImage.MultiSkins[i] = MultiSkins[i];
			}
			
			TImage.Prepivot = Prepivot;
			TImage.AnimFrame = AnimFrame;
			TImage.AnimSequence = AnimSequence;
			TImage.bAnimLoop = True;
			
			TarIndex[0] = -1;
			TarIndex[1] = -1;
			TarIndex[2] = -1;
			
			switch(Mesh.Name)
			{
				case 'GFM_TShirtPants':
				case 'TransGFM_TShirtPants':
					TarIndex[0] = 3;
					TarIndex[1] = 4;
				break;
				case 'GM_Jumpsuit':
				case 'Trans_GM_Jumpsuit':
				case 'MP_Jumpsuit':
				case 'VMDMP_Jumpsuit':
					TarIndex[0] = 5;
				break;
				case 'GM_Suit':
				case 'TransGM_Suit':
					TarIndex[0] = 5;
					TarIndex[1] = 6;
				break;
				case 'GM_DressShirt':
				case 'TransGM_DressShirt':
					TarIndex[0] = 6;
					TarIndex[1] = 7;
				break;
				case 'GM_DressShirt_B':
				case 'TransGM_DressShirt_B':
					TarIndex[0] = 5;
					TarIndex[1] = 6;
					TarIndex[2] = 7;
				break;
				case 'GFM_SuitSkirt':
				case 'TransGFM_SuitSkirt':
					TarIndex[0] = 6;
					TarIndex[1] = 7;
				break;
				case 'GM_Trench':
				case 'TransGM_Trench':
				case 'GM_Trench_F':
				case 'TransGM_Trench_F':
				case 'GFM_Trench':
				case 'TransGFM_Trench':
					TarIndex[0] = 6;
					TarIndex[1] = 7;
				break;
			}
			
			for (i=0; i<ArrayCount(TarIndex); i++)
			{
				if (TarIndex[i] != -1)
				{
					TImage.Multiskins[TarIndex[i]] = Texture'BlackMaskTex';
				}
			}
		}
		
		SpeedAfterimageTimer = 0.05;
	}
}

function VMDPawnTickHook(float DeltaTime)
{
	local bool bWasLowHealth;
	local float TSpeedValue, GSpeed, TDist;
			//TLungValue;
	local Vector TLoc;
	local Actor TTarget;
	local FireExtinguisher TExting;
	local Medkit TMedkit;
	local Pawn TPawn;
	local VMDMedigel TGel;
	
	local bool TDying;
 	local int RotDif, TThreshold;
 	local float RDM, TRadius, TDrain, TDegrees, YawDiff;
	local Vector X, Y, Z, Loc1, Loc2;
	local Rotator TRot;
	local Actor HitActor;
	
	LastTickDelta = DeltaTime;
	TDying = IsInState('Dying');
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	//DXT BEGIN!
	//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	if (Role == ROLE_Authority)
	{
		bClientHostileTowardsPlayers = (GetAllianceType('Player') == ALLIANCE_Hostile);
	}
	
	if (Physics == PHYS_Swimming)
	{
		dripRate += deltaTime*2;
				
		if (dripRate >= 15)
			dripRate = 15.0;
	}
	else if (dripRate > 0)
	{
		DripWater(deltaTime);
	}
	
	if (localPlayer == None)
	{
		GetPlayer();
	}
	
	TThreshold = CloakThreshold + VMDConfigureCloakThresholdMod();
	
	//+++++++++++++++++++++++++++++
	//MADDERS BEGIN!
	//+++++++++++++++++++++++++++++
	if ((AugmentationSystem != None) && (!IsInState('Dying')))
	{
		VMDMaintainEnergy(DeltaTime);
		
		if (Energy > 0)
		{
			//If it's a good time to flick on augs, and our informant says he's off, hit the button.
			if (VMDShouldActivateAugs())
			{
				if ((BulkReferenceAug != None) && (!BulkReferenceAug.bIsActive))
				{
					AugmentationSystem.ActivateAll();
				}
			}
			//Otherwise, if we've leaving our guy on (and presumably others), change from high power mode to low power mode.
			//If our augs were on in the first place, this indicates we were almost certainly in combat, and should be alert still.
			else
			{
				if ((BulkReferenceAug != None) && (BulkReferenceAug.bIsActive))
				{
					AugmentationSystem.DeactivateAll();
					AugmentationSystem.ActivateAllEco();
				}
			}
			
			if (CurCloakAug != None)
			{
				if (Health < TThreshold || (Enemy != None && Weapon == None) || IsInState('Fleeing'))
				{
					if (!CurCloakAug.bIsActive)
					{
						CurCloakAug.Activate();
						EnableCloak(True);
					}
				}
				else
				{
					if (CurCloakAug.bIsActive)
					{
						CurCloakAug.Deactivate();
						EnableCloak(False);
					}
				}
			}
			
			if (CurCombatAug != None)
			{
				if (Enemy == None || (DeusExWeapon(Weapon) != None && !DeusExWeapon(Weapon).bHandToHand))
				{
					if (CurCombatAug.bIsActive)
					{
						CurCombatAug.Deactivate();
					}
				}
				else
				{
					if (!CurCombatAug.bIsActive)
					{
						CurCombatAug.Activate();
					}
				}
			}
			
			/*TLungValue = AugmentationSystem.VMDConfigureLungMod(true);
			if (LastLungAugValue != TLungValue)
			{
				if (LastLungAugValue < TLungValue)
				{
					UnderWaterTime -= LastLungAugValue;
					UnderWaterTime += TLungValue;
				}
				else
				{
					UnderWaterTime -= TLungValue;
					UnderWaterTime += LastLungAugValue;
				}
			}
			LastLungAugValue = TLungValue;*/
			
			/*if (CurRadarTransAug != None)
			{
				if (Health < TThreshold || (Enemy != None && Weapon == None))
				{
					if (!CurRadarTransAug.bIsActive)
					{
						CurRadarTransAug.Activate();
					}
					else
					{
						Fatness = Rand(6) + 125;
					}
				}
				else
				{
					if (CurRadarTransAug.bIsActive)
					{
						CurRadarTransAug.Deactivate();
						
						if (StoredFatness > 0)
						{
							Fatness = StoredFatness;
						}
						else
						{
							StoredFatness = Default.Fatness;
							Fatness = Default.Fatness;
						}
					}
				}
			}*/
			
			if (CurSpeedAug != None)
			{
				//MADDERS, 12/28/23: Mechs leave their speed aug on all the time to be flashy.
				if (bMechAugs)
				{
					if (Enemy == None || DeusExWeapon(Weapon) == None)
					{
						if (CurSpeedAug.bIsActive)
						{
							CurSpeedAug.Deactivate();
						}
					}
					else
					{
						if (!CurSpeedAug.bIsActive)
						{
							CurSpeedAug.Activate();
						}
						else
						{
							VMDUpdateSpeedAugEffects(DeltaTime);
						}
					}
				}
				else
				{
					if (Enemy == None || (DeusExWeapon(Weapon) != None && !DeusExWeapon(Weapon).bHandToHand))
					{
						if (CurSpeedAug.bIsActive)
						{
							CurSpeedAug.Deactivate();
						}
					}
					else
					{
						if (!CurSpeedAug.bIsActive)
						{
							CurSpeedAug.Activate();
						}
						else
						{
							VMDUpdateSpeedAugEffects(DeltaTime);
						}
					}
				}
				
				TSpeedValue = AugmentationSystem.VMDConfigureSpeedMult(false);
				if (LastSpeedAugValue != TSpeedValue)
				{
					LastSpeedAugValue = TSpeedValue;
					VMDUpdateGroundSpeedBuoyancy();
				}
			}
			
			if (CurStealthAug != None)
			{
				if (Health < TThreshold || (Enemy != None && Weapon == None))
				{
					if (CurStealthAug.bIsActive)
					{
						CurStealthAug.Deactivate();
					}
				}
				else
				{
					if (!CurStealthAug.bIsActive)
					{
						CurStealthAug.Activate();
					}
				}
			}
			
			if (CurTargetAug != None)
			{
				if (Enemy == None || (DeusExWeapon(Weapon) != None && DeusExWeapon(Weapon).bHandToHand))
				{
					if (CurTargetAug.bIsActive)
					{
						CurTargetAug.Deactivate();
					}
				}
				else
				{
					if (!CurTargetAug.bIsActive)
					{
						CurTargetAug.Activate();
					}
				}
			}
			
			if ((CurVisionAug != None) && (!CurVisionAug.bPassive))
			{
				if ((!IsInState('Seeking')) && (!IsInState('Attacking')))
				{
					if (CurVisionAug.bIsActive)
					{
						CurVisionAug.Deactivate();
					}
				}
				else
				{
					if (!CurVisionAug.bIsActive)
					{
						CurVisionAug.Activate();
					}
				}
			}
		}
		else
		{
			if (CurCloakAug != None)
			{
				EnableCloak(false);
			}
		}
	}
	else if (bHasCloak || bCloakOn || VMDConfigureCloakThresholdMod() > 0)
	{
		if ((Health <= TThreshold) && (Health < StartingHealthValues[6]))
		{
			EnableCloak(true);
		}
		else if ((IsInState('Attacking') || IsInState('Seeking')) && (VMDConfigureCloakThresholdMod() > 0))
		{
			EnableCloak(true);
		}
		else
		{
			EnableCloak(false);
		}
	}
	
	//MADDERS, 12/29/23: See shit through walls. A bit chunky, but this is done only on rare occasions.
	if (VMDCanSeeThroughWalls())
	{
		if (TechGogglesSeekCooldown > 0)
		{
			TechGogglesSeekCooldown -= DeltaTime;
		}
		
		TechGogglesCheckTimer -= DeltaTime;
		if (TechGogglesCheckTimer <= 0)
		{
			TechGogglesCheckTimer = 0.1;
			if (TechGogglesSeekCooldown <= 0 && (Enemy == None || EnemyLastSeen > 1.0 || IsInState('Seeking')))
			{
				if (bTechGogglesActive)
				{
					TRadius = TechGogglesRadius;
				}
				if (CurVisionAug != None && (CurVisionAug.bIsActive || CurVisionAug.bPassive))
				{
					TRadius = FMax(TRadius, CurVisionAug.LevelValues[CurVisionAug.CurrentLevel]);
				}
				
				forEach RadiusActors(class'Pawn', TPawn, TRadius, Location)
				{
					if (GetPawnAllianceType(TPawn) > 1)
					{
						TDegrees = (FOVAngle / 360.0) * 65536;
						RotDif = Rotation.Yaw - Rotator(TPawn.Location - Location).Yaw;
 						RDM = Abs(RotDif & 65535);
						
   						if ((RDM < TDegrees || 65536 - RDM < TDegrees) && (Enemy != TPawn))
   						{
							if (SetEnemy(TPawn))
							{
								if (DeusExWeapon(Weapon) == None)
								{
									bKeepWeaponDrawn = True; //MADDERS, 11/27/24: Hack so we stop doing this shit after one.
									SwitchToBestWeapon();
								}
								
								TechGogglesSeekCooldown = 1.0;
								GetAxes(ViewRotation, X, Y, Z);
								if (!AISafeToShoot(HitActor, Enemy.Location, DeusExWeapon(Weapon).ComputeProjectileStart(X, Y, Z)))
								{
									if (DeusExPlayer(TPawn) == None || !DeusExPlayer(TPawn).bForceDuck)
									{
										//TTarget = GetNextWaypoint(TPawn);
										DestLoc = TPawn.Location;
									}
									else
									{
										TDist = VSize(DestLoc-Location);
										TLoc = Normal(TPawn.Location-Location) * 0.65;
										DestLoc = Normal(DestLoc-Location) * 0.35;
										TLoc = (DestLoc + TLoc);
										TLoc.Z /= 2.0;
										DestLoc = (TLoc * TDist * 2.0) + Location;
									}
									SetSeekLocation(TPawn, DestLoc, SEEKTYPE_None, true);
									GoToState('Seeking', 'GoToLocation');
									//HandleEnemy();
								}
								else
								{
									SetDistressTimer();
									HandleEnemy();
								}
								
								break;
							}
						}
					}
				}
			}
			
			if (bTechGogglesActive)
			{
				if (ActiveGoggles != None)
				{
					TDrain = 4.0;
					TDrain *= ActiveGoggles.SkillNeeded.Default.LevelValues[EnviroSkillLevel];
					if (int(TDrain) < 1) TDrain = 1.0;
					ActiveGoggles.Charge -= TDrain;
					
					if (ActiveGoggles.Charge <= 0)
					{
						if (AmbientSound == class'TechGoggles'.Default.LoopSound)
						{
							AmbientSound = None;
						}
						PlaySound(ActiveGoggles.DeactivateSound, SLOT_NONE,,, 512, GSpeed);
						ActiveGoggles.UsedUp();
						bTechGogglesActive = false;
						RestoreGogglesTexture();
					}
				}
				else //EMP may destroy our goggles early, thank you.
				{
					if (AmbientSound == class'TechGoggles'.Default.LoopSound)
					{
						AmbientSound = None;
					}
					PlaySound(class'TechGoggles'.Default.DeactivateSound, SLOT_NONE,,, 512, GSpeed);
					bTechGogglesActive = false;
					RestoreGogglesTexture();
				}
			}
		}
	}
	
	bStunnedThisFrame = bStunned;
	
	if (bDamageGateBullshitFrame)
	{
		bDamageGateBullshitFrame = false;
	}
	
	if (WeaponSwapTimer > 0.0)
	{
		WeaponSwapTimer -= DeltaTime;
	}
	
	if (TargetedLadderPoint != None || bClimbingLadder)
	{
		LadderCheckInTimer -= DeltaTime;
		if (LadderCheckInTimer <= 0)
		{
			if ((VSize(LastLadderCheckInPos - Location) < 8) && (LastLadderCheckInPos != Vect(0,0,0)) && (!VMDLadderDropWouldBeFatal()))
			{
				VMDClearLadderData();
				if (IsInState('Attacking'))
				{
					DestPoint = None;
					GoToState('Attacking', 'Begin');
				}
			}
			LastLadderCheckInPos = Location;
			LadderCheckInTimer = 2.0;
		}
	}
	else
	{
		LadderCheckinTimer = 2.0;
	}
	
	//MADDERS, 12/30/23: Handle sprinting. We get 1 second of sprint for every 10 stamina.
	//We also regenerate 1% stamina per second, in standard time, so better fit guys can recover faster, too.
	if (bSprinting)
	{
		if (SprintStamina > 0)
		{
			SprintStamina -= DeltaTime * 10;
		}
		else
		{
			SprintStamina = 0;
			bSprinting = false;
			VMDUpdateGroundSpeedBuoyancy();
		}
	}
	else if (SprintStamina < SprintStaminaMax)
	{
		SprintStamina += DeltaTime * (SprintStaminaMax * 0.01);
	}
	
	if ((IsInState('Burning')) && (!TDying))
	{
		if (FireExtinguisher(MoveTarget) != None || Faucet(MoveTarget) != None || ShowerFaucet(MoveTarget) != None)
		{
			TRot = Rotator(MoveTarget.Location - Location);
			YawDiff = Abs(TRot.Yaw - Rotation.Yaw);
			Loc1 = MoveTarget.Location;
			Loc1.Z = 0;
			Loc2 = Location;
			Loc2.Z = 0;
			if ((YawDiff < 16384) && (VSize(Loc1 - Loc2) < 112) && (FastTrace(MoveTarget.Location, Location+(Vect(0,0,1)*BaseEyeHeight))))
			{
				if (FireExtinguisher(MoveTarget) != None)
				{
					FireExtinguisher(MoveTarget).InitialState = 'Idle2';
					FireExtinguisher(MoveTarget).GiveTo(Self);
					FireExtinguisher(MoveTarget).SetBase(Self);
					FireExtinguisherUseTimer = 1.5;
				}
				else
				{
					MoveTarget.Frob(Self, None);
				}
				LastSoughtExtinguisher = None;
			}
		}
	}
	
	if ((FireExtinguisherUseTimer > 0) && (!TDying) && (Robot(Self) == None) && (Animal(Self) == None))
	{
		BiocellUseTimer = 0;
		MedkitUseTimer = 0;
		FireExtinguisherUseTimer -= DeltaTime;
		if ((FireExtinguisherUseTimer <= 0) && (bOnFire))
		{
			TExting = FireExtinguisher(FindInventoryType(class'FireExtinguisher'));
			if (TExting != None)
			{
				TExting.Activate();
				ActiveExtinguisher = TExting;
				
				if ((Enemy != None) && (!ShouldFlee()))
				{
					SetNextState('Attacking');
					GoToNextState();
				}
			}
		}
	}
	else if ((MedkitUseTimer > 0) && (Robot(Self) == None) && (Animal(Self) == None) && (VMDIsInHealableState()))
	{
		BioCellUseTimer = 0;
		MedkitUseTimer -= DeltaTime;
		if ((MedkitUseTimer <= 0))
		{
			bWasLowHealth = ShouldFlee();
			
			TMedkit = Medkit(FindInventoryType(class'Medkit'));
			if ((TMedkit != None) && (!TMedkit.bDeleteMe) && (TMedkit.NumCopies > 0) && (!TMedkit.IsInState('Activated')))
			{
				TMedkit.Activate();
			}
			else
			{
				TGel = VMDMedigel(FindInventoryType(class'VMDMedigel'));
				if ((TGel != None) && (!TGel.bDeleteMe) && (TGel.NumCopies > 0) && (!TGel.IsInState('Activated')))
				{
					TGel.Activate();
				}
			}
			
			if ((Enemy != None) && (IsInState('Fleeing')) && (bWasLowHealth) && (!ShouldFlee()))
			{
				SetNextState('Attacking');
				GoToNextState();
			}
		}
	}
	
	if (SmellSniffCooldown > 0) SmellSniffCooldown -= DeltaTime;
	if (DrawShieldCooldown > 0) DrawShieldCooldown -= DeltaTime;
	if (DrawAugShieldCooldown > 0) DrawAugShieldCooldown -= DeltaTime;
	
	if ((bLookAtPlayer) && (LocalPlayer != None))
	{
		playerLastSeenTimer += deltaTime;
		lookCheckTime += deltaTime;
		
		// Performance
		if (lookCheckTime > 0.25)
		{
			lookCheckTime = 0;
			
			// Only look at the player if we're not busy in a conversation or dealing with an enemy. 
			// Look at them if in fleeing or alerting state because then they're the enemy.
			// Look at them while attacking but not seeking, otherwise our head stays turned during attacks
			if ((ConversationActor == None) && (Enemy == None || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')) && (!IsInState('Burning')) && (!IsInState('TakingHit')) && (!IsInState('Dying')) && (!IsInState('RubbingEyes')) && (!IsInState('Stunned')))
			{
				// Can we see the player
				if (localPlayer != None && 
				(VSize(localPlayer.Location-Location) <= 320) && 
				AICanSee(localPlayer,, True, True, True, True) > 0 && 
				(GetPawnAllianceType(localPlayer) != ALLIANCE_Hostile || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')))
				{
					if (lookingAtPlayerTime < 3)
						LookAtActor(localPlayer, false, true, true, 0, 1);
					bLookingReset = False;
					playerLastSeenTimer = 0;
					lookingAtPlayerTime += deltaTime + 0.25; // Compensate for lookCheckTime
				}	
				
				if (lookingAtPlayerTime >= 3 && !bLookingReset) // Look at the player for three seconds, awkwardly look away for two seconds.			
				{
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					bLookingReset = True;
					if (lookingAtPlayerTime >= 5 + FRand())
						lookingAtPlayerTime = 0;
				}
				else if ((playerLastSeenTimer > FRand() + 0.5) && !bLookingReset) // Lost sight of the player, look forward after 0.5-1.5 seconds
				{
					PlayTurnHead(LOOK_Forward, 1.0, 1.0);
					bLookingReset = True;
				}	
			}
		}
	}
	
	// Can we see the player
        /*if (localPlayer != None && (VSize(localPlayer.Location-Location) <= 320) && AICanSee(localPlayer,, True, True, True, True) > 0 && 
                (GetPawnAllianceType(localPlayer) != ALLIANCE_Hostile || IsInState('Fleeing') || IsInState('Alerting') || IsInState('Attacking')))
        {
               	if (lookingAtPlayerTime < 3)
               		LookAtActor(localPlayer, false, true, true, 0, 1);
                bLookingReset = False;
                playerLastSeenTimer = 0;
                lookingAtPlayerTime += deltaTime + 0.25; // Compensate for lookCheckTime
                
                if (bSuspiciousToPlayer)
                	LookAtActor(localPlayer, true, true, true, 0, 1);
      	}*/
	
	//MADDERS: I ain't proud of this one, but it's 100% bomb-proof, and not a very intense check at all.
	/*if (!bEverDrewGrenade)
	{
		if (GrenadeSkillAugmentCheckTime > 0.0)
		{
			GrenadeSkillAugmentCheckTime -= deltaTime;
		}
		else
		{
			GrenadeSkillAugmentCheckTime = 2.0;
			if ((VMDBufferPlayer(LocalPlayer) != None) && (VMDBufferPlayer(LocalPlayer).HasSkillAugment('DemolitionLooting')))
			{
				bEverDrewGrenade = true;
			}
		}
	}*/
	
	//MADDERS: Only allow us to drop LAM's if we've drawn them before. Kinda a shitty nerf, but so be it.
	if ((DeusExWeapon(Weapon) != None) && (DeusExWeapon(Weapon).bHandToHand) && (!DeusExWeapon(Weapon).bInstantHit) && (DeusExWeapon(Weapon).VMDIsWeaponName("LAM") || DeusExWeapon(Weapon).VMDIsWeaponName("EMPGrenade")))
	{
		bEverDrewGrenade = true;
	}
	
	if (TimeSincePickpocket > 0.0)
	{
		TimeSincePickpocket -= DeltaTime;
	}
	
	//Having an enemy engages scream start. No enemy disengages it.
	if ((!bScreamStart) && (Enemy != None) && (Health > 0))
	{
	 	bScreamStart = true;
	}
	else if ((!bScreamStart) && (Health > 0) && (IsInState('Fleeing')))
	{
	 	bScreamStart = true;
	}
	else if ((bScreamStart) && (Enemy == None) && (Health > 0)) ResetScream();
	
	if ((bScreamStart) && (!bDoScream) && (!IsInState('Stunned')))
	{
	 	ScreamTimer += deltaTime;
	 	if (ScreamTimer > 0.6) bDoScream = true;
	}
	
	//MADDERS, 6/26/24: After 120 seconds (or 339 seconds at highest difficult, about 5 1/2 minutes), lower alert level.
	if ((bStatusAlert) && (GetLastVMP() != None))
	{
		StatusAlertTime += DeltaTime / GetLastVMP().TimerDifficulty;
		if (StatusAlertTime > 90)
		{
			bStatusAlert = false;
			StatusAlertTime = 0;
		}
	}
	
	//NEW! Scream when running away after we've had time to process!
	if ((bDoScream || Animal(Self) != None || Robot(Self) != None || bInsignificant) && (!bDistressed))
	{
	 	SetDistress(True);
	}
	
	LastPhysics = Physics;
}

function bool VMDCanSeeThroughWalls()
{
	if (bTechGogglesActive)
	{
		return true;
	}
	
	if (CurVisionAug != None && (CurVisionAug.bIsActive || CurVisionAug.bPassive))
	{
		return true;
	}
	
	return false;
}

function bool VMDIsInHealableState()
{
	if (Health <= 0 || bClimbingLadder)
	{
		return false;
	}
	
	if (IsInState('Dying') || IsInState('Burning') || IsInState('RubbingEyes') || IsInState('Stunned') || IsInState('TakingHit'))
	{
		return false;
	}
	
	if (IsInState('Attacking') || IsInState('Fleeing') || IsInState('Seeking') || IsInState('HandlingEnemy') || IsInState('Alerting')
		|| IsInState('AvoidingProjectiles'))
		// || IsInState('BackingOff') || IsInState('OpeningDoor') || IsInState('TakingHit')
	{
		return true;
	}
	
	if (Enemy != None)
	{
		return true;
	}
	
	return false;
}

function ResetScream()
{
 	bDoScream = false;
 	bScreamStart = false;
 	ScreamTimer = 0;
}

function bool HasSeedInSet(int In)
{
 	local int TBit;
 	
 	TBit = 2 ** In;
 	
 	if ((Seedset & TBit) == TBit) return True;
 	return False;
}

function string VMDGetMapName()
{
 	return class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
}

function TransferArmorHit( DeusExPlayer P)
{
 	local DeusExRootWindow DXRW;
 	
 	if (VMDBufferPlayer(P) == None) return;
 	if (Abs(LastHitSeconds - Level.TimeSeconds) < 0.1) return;
 	
 	//MADDERS: Only give hit indicators in potential line of sight.
 	if (!FastTrace(P.Location, Location)) return;
 	if (bInsignificant) return; //MADDERS: It will be SIGNIFICANT.
 	
 	DXRW = DeusExRootWindow(P.RootWindow);
 	if ((DXRW != None) && (AIGetLightLevel(Location) > 0.005))
 	{
  		DXRW.Hud.HitInd.SetIndicator(True, False, bLastArmorHit);
 	}
 	
	LastHitSeconds = Level.TimeSeconds;
}

//MADDERS FUNCTIONS!
function PlayPlayerHeadshotSound( DeusExPlayer P )
{
 	local DeusExRootWindow DXRW;
 	
 	if (VMDBufferPlayer(P) == None) return;
 	if (Abs(LastHitSeconds - Level.TimeSeconds) < 0.05) return;
 	
 	//MADDERS: Only give hit indicators in potential line of sight.
 	if (!FastTrace(P.Location, Location)) return;
 	if (bInsignificant) return; //MADDERS: It will be SIGNIFICANT.
 	
 	DXRW = DeusExRootWindow(P.RootWindow);
 	if ((DXRW != None) && (AIGetLightLevel(Location) > 0.005))
 	{
 		VMDBufferPlayer(P).ProjectHeadshotSound();
 		
  		DXRW.Hud.HitInd.SetIndicator(True, True, bLastArmorHit);
 	}
 	
	LastHitSeconds = Level.TimeSeconds;
}

function Explode(optional Vector HL)
{
	local int i;
	local float explosionDamage, explosionRadius, GSpeed;
	local ExplosionLight light;
	local ScorchMark s;
	local SphereEffect sphere;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if (HL == vect(0,0,0)) HL = Location;
	
	explosionDamage = 100;
	explosionRadius = 256;
	
	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16, GSpeed);
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HL);
	if (light != None)
		light.size = 4;
	
	Spawn(class'ExplosionSmall',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionLarge',,, HL + 2*VRand()*CollisionRadius);
	
	sphere = Spawn(class'SphereEffect',,, HL);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;
	
	// spawn a mark
	s = spawn(class'ScorchMark', Base,, HL-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}
	
	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,HL);
		else
			spawn(class'FleshFragment',,,HL);
	}
	
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, HL);
}

function MiniExplode(optional Vector HL)
{
	local int i;
	local float explosionDamage, explosionRadius, GSpeed;
	local ExplosionLight light;
	local ScorchMark s;
	local SphereEffect sphere;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if (HL == vect(0,0,0)) HL = Location;
	
	explosionDamage = 35;
	explosionRadius = 96;
	
	// alert NPCs that I'm exploding
	AISendEvent('LoudNoise', EAITYPE_Audio, , explosionRadius*16);
	PlaySound(Sound'LargeExplosion1', SLOT_None,,, explosionRadius*16, GSpeed);
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HL);
	if (light != None)
		light.size = 4;
	
	Spawn(class'ExplosionSmall',,, HL + 2*VRand()*CollisionRadius);
	Spawn(class'ExplosionMedium',,, HL + 2*VRand()*CollisionRadius);
	
	sphere = Spawn(class'SphereEffect',,, HL);
	if (sphere != None)
		sphere.size = explosionRadius / 32.0;
	
	// spawn a mark
	s = spawn(class'ScorchMark', Base,, HL-vect(0,0,1)*CollisionHeight, Rotation+rot(16384,0,0));
	if (s != None)
	{
		s.DrawScale = FClamp(explosionDamage/30, 0.1, 3.0);
		s.ReattachDecal();
	}
	
	// spawn some rocks and flesh fragments
	for (i=0; i<explosionDamage/6; i++)
	{
		if (FRand() < 0.3)
			spawn(class'Rockchip',,,HL);
		else
			spawn(class'FleshFragment',,,HL);
	}
	
	HurtRadius(explosionDamage, explosionRadius, 'Exploded', explosionDamage*100, HL);
}

function bool ShouldExplode()
{
	local bool Ret, bDidFirst;
	local int LastAmmoRand, i, NumWins;
	local Vector EndTrace, StartTrace, HL, HN, RandChunk;
	local Actor HitAct;
	local Inventory item, nextitem, lastitem;
	local Projectile Proj;
	local VMDFireChild TFire;
 	
 	if (Inventory != None)
 	{
  		bDidFirst = false;
 		item = Inventory;
  		
  		do
  		{
   			nextitem = Item.Inventory;
   			if ((DeusExWeapon(item) != None) && (DeusExWeapon(Item).bVolatile))
   			{
    				if ((DeusExWeapon(item).bHandToHand) && (!DeusExWeapon(item).bInstantHit))
    				{     
     					//NEW: Configure a proper radius, because so far this seems unreliable to a fault!
     					Proj = Spawn(DeusExWeapon(item).ProjectileClass, Self,, Location + ((vect(1,0,0) >> Rotation) * (CollisionRadius + 5)), RotRand(False));
					if (Proj != None)
					{
     						Proj.TakeDamage(100, Self, Proj.Location, vect(0,0,0), 'Exploded');
					}
     					if (!bDidFirst) Inventory = nextitem;
     					else lastItem.Inventory = NextItem;
     					
     					Item.Destroy();
    				}
				else if ((WeaponFlamethrower(Item) != None || WeaponRetributorFlamethrower(Item) != None) && (Region.Zone == None || !Region.Zone.bWaterZone))
				{
					Ret = True;
					for(i=0; i<16; i++)
					{
						StartTrace = Location;
						RandChunk = VRand() * 96;
						RandChunk.Z = 0;
						EndTrace = StartTrace + (vect(0,0,-1) * CollisionHeight * 2.2) + RandChunk;
						
						HitAct = Trace(HL, HN, EndTrace, StartTrace);
						if (HitAct == Level || Mover(HitAct) != None)
						{
							TFire = Spawn(class'VMDFireChild',HitAct,, HL+(HN*12));
							if (TFire != None)
							{
								TFire.DrawScale = (FRand() + 1.0) / 4;
								TFire.LifeSpan =  5 + Rand(10) + FRand();
								TFire.Texture = FireTexture'Effects.Fire.flame_b';
								TFire.SetBase(HitAct);
								
								// turn off the sound and lights for all but the first one
								if (NumWins > 0)
								{
									TFire.AmbientSound = None;
									TFire.LightType = LT_None;
								}
								NumWins++;
								
								// turn on/off extra fire and smoke
								if (FRand() < 0.9)
								{
									TFire.smokeGen.Destroy();
								}
								if (FRand() < 0.25)
								{
									TFire.AddFire(1.5);
								}
							}
						}
					}
					
     					if (!bDidFirst) Inventory = nextitem;
     					else lastItem.Inventory = NextItem;
     					
     					Item.Destroy();
				}
    				else
    				{
     					if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
     					else lastItem.Inventory = nextitem;
     					Ret = True;
     					lastitem = item;
     					
     					Item.Destroy();
    				}
   			}
   			else if ((DeusExAmmo(item) != None) && (DeusExAmmo(Item).bVolatile))
   			{
    				if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
    				else lastItem.Inventory = nextitem;
    				Ret = True;
    				lastitem = item;
     				
    				Item.Destroy();
   			}
			else if (DeusExPickup(Item) != None && (DeusExPickup(Item).bFragile || DeusExPickup(Item).bVolatile || DeusExPickup(Item).bBreakable))
			{
    				if (!bDidFirst) Inventory = nextitem;//bDidFirst = True;
    				else lastItem.Inventory = nextitem;
				if (FireExtinguisher(Item) != None)
				{
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 0, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 8192, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 16384, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 24576, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 32768, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 40960, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 49152, 0));
					Proj = Spawn(class'HalonGas', Self,, Location + vect(0,0,5), Rot(0, 57344, 0));
				}
				
				if (DeusExPickup(Item).bVolatile)
				{
	    				MiniExplode();
				}
    				lastitem = item;
     				
    				Item.Destroy();
			}
   			else
   			{
    				if (!bDidFirst) bDidFirst = True;
    				lastitem = item;
   			}
   			
   			item = nextitem;
  		}
  		until ((Nextitem == None) && (item == None));
 	}
 	
 	return Ret;
}

function bool VMDBlockDumpOfItem( Inventory I )
{
 	if (WeaponCombatKnife(I) != None) return true;
 	if ((DeusExWeapon(I) == None) && (I.InvSlotsX > 90)) return true;
 	if ((DeusExWeapon(I) != None) && (DeusExWeapon(I).VMDConfigureInvSlotsX(None) > 90)) return true;
 	if (I.Default.Mesh == LODMesh'TestBox') return true;
	if (ChargedPickup(I) != None) return true;
		
	//MADDERS: Destroy our inventory at random. Not a perfect retrieval rate, except for nanokeys.
	if (Nanokey(I) == None)
	{
		//MADDERS: Pickups survive more often, being less volatile.
		if (Pickup(I) != None)
		{
			if (class'VMDStaticFunctions'.Static.DeriveActorSeed(I, 3, true) == 0)
			{
		 		return true;
			}
		}
		else
		{
			if (class'VMDStaticFunctions'.Static.DeriveActorSeed(I, 3, true) != 2)
			{
				return true;
			}
		}
 	}
 	return false;
}

function DeusExWeapon GetOwningWeapon(DeusExAmmo A)
{
	local Inventory Inv;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if ((DeusExWeapon(Inv) != None) && (DeusExWeapon(Inv).AmmoType == A))
		{
			return DeusExWeapon(Inv);
		}
	}
	return None;
}

//MADDERS: Dump inventory items on gib!
function DumpItemInventory()
{
 	local Inventory item, NextItem, LastItem;
 	local float MassMult;
 	local Vector Offs, R;
 	local bool FlagNullItem;
	
	local int AmmoRet;
	local DeusExWeapon DXW, ODXW;
	local DeusExAmmo DXA, ODXA;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
 	
 	//NEW: Explode and shit if we should be doing so.
 	if (ShouldExplode())
 	{
  		Explode();
  		if (bExplosive)
  		{
   			return; //Only return when we were already gonna 'splode!
  		}
 	}
	
	//throw our shit everywhere.
	if (!IsA('Animal') && !IsA('Robot'))
	{
		if (Inventory != None)
		{
			do
			{
				item = Inventory;
				nextItem = item.Inventory;
				DeleteInventory(item);
				//experimental clause for the mystery flung shit.
				item.SetLocation(Self.Location);
				
				ODXA = None;
				ODXW = None;
				
				DXA = DeusExAmmo(Item);
				if (DXA != None)
				{
					ODXW = GetOwningWeapon(DXA);
				}
				DXW = DeusExWeapon(Item);
				if (DXW != None)
				{
					ODXA = DeusExAmmo(DXW.AmmoType);
				}
				
				FlagNullItem = False;
				if (DXA != None)
				{
					if (DXA.AmmoAmount == 0 || Item.Default.Mesh == LODMesh'TestBox') FlagNullItem = true;
				}
				if (DXW != None)
				{
					if (DXW.bNativeAttack || Item.Default.Mesh == LODMesh'TestBox') FlagNullItem = True;
				}
				
				if (Item.InvSlotsX > 90) FlagNullItem = True;
				
				if (FlagNullItem)
				{
				 	Item.Destroy();
				 	if (LastItem != None) LastItem.Inventory = NextItem;
				 	else Inventory = NextItem;
					
					continue;
				}
				else
				{
					LastItem = Item;
				}
				MassMult = 1 + Min(3 / Max(item.Mass, 2.5), 2);
				Offs = Location;
				Offs.X += ((Rand(2) * 2) - 1) * CollisionRadius;
				Offs.Y += ((Rand(2) * 2) - 1) * CollisionRadius;
				Offs.Z += (FRand() + 0.5) * CollisionHeight;
				R = VRand() + vect(0,0,1);
				
				if (DXW != None)
				{
					AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(0, 0, DXW, ODXA, VMP);
					
				 	DXW.AIRating = DXW.Default.AIRating;
				 	DXW.bMuzzleFlash = 0;
				 	DXW.PickupAmmoCount = AmmoRet;
					DXW.EraseMuzzleFlashTexture();
				}
				if (DXA != None)
				{
					AmmoRet = class'VMDStaticFunctions'.Static.GWARRRand(1, 3, ODXW, DXA, VMP);
					
					DXA.AmmoAmount = AmmoRet;
					//DXA.AmmoAmount = Rand(Max(DXA.MaxAmmo / 50, 3))+1;
					
					//MADDERS, 1/13/21: Don't drop 0 ammo, thanks.
					if (AmmoRet <= 0) DXA.Destroy();
				}
				if ((DeusExPickup(Item) != None) && (Credits(Item) == None))
				{
					DeusExPickup(Item).NumCopies = 1;
				}
				
				//MADDERS, 8/7/23: I'm lazy. Sue me.
				item.SetPropertyText("bCorpseUnclog", "True");
				
				item.SetPhysics(PHYS_Falling);
				item.RemoteRole = ROLE_DumbProxy;
				item.NetPriority = 2.5;
				item.BecomePickup();
				item.bCollideWorld = True;
				item.GoToState('PickUp', 'Dropped');
				item.Velocity = R * (Rand(50) + 100) * MassMult;
				item.Velocity = item.Velocity + Velocity; //Magic clause for relative velocity!
				item.bFixedRotationDir = True;
				item.RotationRate = RotRand(True);
				item.RespawnTime = 0;
				
				if (VMDBlockDumpOfItem(item)) item.Destroy();
				item = nextItem;
			}
			until (item == None);
		}
	}
}

//MADDERS: Fix bad anims being called!
//
// lip synching support - DEUS_EX CNN
//
function LipSynch(float deltaTime)
{
	local name animseq;
	local float rnd;
	local float tweentime;

	// update the animation timers that we are using
	animTimer[0] += deltaTime;
	animTimer[1] += deltaTime;
	animTimer[2] += deltaTime;

	if (bIsSpeaking)
	{
		// if our framerate is high enough (>20fps), tween the lips smoothly
		if (Level.TimeSeconds - animTimer[3]  < 0.05)
			tweentime = 0.1;
		else
			tweentime = 0.0;

		// the last animTimer slot is used to check framerate
		animTimer[3] = Level.TimeSeconds;

		if (nextPhoneme == "A")
			animseq = 'MouthA';
		else if (nextPhoneme == "E")
			animseq = 'MouthE';
		else if (nextPhoneme == "F")
			animseq = 'MouthF';
		else if (nextPhoneme == "M")
			animseq = 'MouthM';
		else if (nextPhoneme == "O")
			animseq = 'MouthO';
		else if (nextPhoneme == "T")
			animseq = 'MouthT';
		else if (nextPhoneme == "U")
			animseq = 'MouthU';
		else if (nextPhoneme == "X")
			animseq = 'MouthClosed';

		if (animseq != '')
		{
			if (lastPhoneme != nextPhoneme)
			{
				lastPhoneme = nextPhoneme;
				if (HasAnim(animseq)) TweenBlendAnim(animseq, tweentime);
			}
		}
	}
	else if (bWasSpeaking)
	{
		bWasSpeaking = False;
		if (HasAnim('MouthClosed')) TweenBlendAnim('MouthClosed', tweentime);
	}

	// blink randomly
	if (animTimer[0] > 2.0)
	{
		animTimer[0] = 0;
		if (FRand() < 0.4 && HasAnim('Blink'))
			PlayBlendAnim('Blink', 1.0, 0.1, 1);
	}

	LoopHeadConvoAnim();
	LoopBaseConvoAnim();
}

//
// PlayTurnHead - DEUS_EX STM
//

function bool SimulatedSuperPlayTurnHead(ELookDirection dir, float rate, float tweentime)
{
	local name lookName;
	local bool bSuccess;

	if (dir == LOOK_Left)
		lookName = 'HeadLeft';
	else if (dir == LOOK_Right)
		lookName = 'HeadRight';
	else if (dir == LOOK_Up)
		lookName = 'HeadUp';
	else if (dir == LOOK_Down)
		lookName = 'HeadDown';
	else
		lookName = 'Still';

	bSuccess = false;
	if (BlendAnimSequence[3] != lookName)
	{
		if (animTimer[1] > 0.00)
		{
			animTimer[1] = 0;
			if (BlendAnimSequence[3] == '')
				BlendAnimSequence[3] = 'Still';
			if (HasAnim(lookName)) PlayBlendAnim(lookName, rate, tweentime, 3);
			bSuccess = true;
		}
	}

	return (bSuccess);
}

function VMDBufferPlayer GetLastVMP()
{
	if (LastVMP == None)
	{
		LastVMP = VMDBufferPlayer(GetPlayerPawn());
	}
	return LastVMP;
}

//Check all our health bullshit.
function CheckHealthScaling()
{
	local VMDBufferPlayer VMP;
	
	VMP = GetLastVMP();
 	if ((VMP != None) && (!bSetupBuffedHealth))
 	{
		VMDExtendVision();
		
		LastEnemyHealthScale = VMP.EnemyHPScale;
  		HealthHead *= VMP.EnemyHPScale;
  		HealthTorso *= VMP.EnemyHPScale;
  		HealthArmLeft *= VMP.EnemyHPScale;
  		HealthArmRight *= VMP.EnemyHPScale;
  		HealthLegLeft *= VMP.EnemyHPScale;
  		HealthLegRight *= VMP.EnemyHPScale;
		Health *= VMP.EnemyHPScale;
  		CloakThreshold *= VMP.EnemyHPScale;
		if (Robot(Self) != None)
		{
			Robot(Self).EMPHitPoints *= (1.0 + VMP.EnemyHPScale) / 2;
			Robot(Self).StartingEMPHitPoints = Robot(Self).EMPHitPoints;
		}
  		
  		bSetupBuffedHealth = True;
		
		if ((VMP.bRecognizeMovedObjectsEnabled) && (Robot(Self) == None) && (Animal(Self) == None))
		{
			bRecognizeMovedObjects = true;
		}
		if ((VMP.bEnemyAlwaysAvoidProj) && (Robot(Self) == None) && (Animal(Self) == None))
		{
			bAvoidHarm = true;
			bReactProjectiles = true;
		}
		DifficultyVisionRangeMult = VMP.EnemyVisionRangeMult;
		
		if (!bBuffedSenses)
		{
			if ((Robot(Self) == None) && (Animal(Self) == None))
			{
				VisibilityThreshold = FMax(VisibilityThreshold * VMP.EnemyVisionStrengthMult,  0.0025);
			}
			if (!VMDHasHearingExtensionObjection())
			{
				HearingThreshold = FMax(HearingThreshold * VMP.EnemyHearingRangeMult, 0.0375);
			}
			bBuffedSenses = true;
		}
		
		SurprisePeriod = FMin(SurprisePeriod, VMP.EnemySurprisePeriodMax);
		
		DifficultyExtraSearchSteps = VMP.EnemyExtraSearchSteps;
		DifficultyROFWeight = VMP.EnemyROFWeight;
		DifficultyReactionSpeedMult = VMP.EnemyReactionSpeedMult;
		if ((Robot(Self) == None) && (Animal(Self) == None))
		{
			EnemyGuessingFudge = VMP.EnemyGuessingFudge;
			if (!bBuffedAccuracy)
			{
				BaseAccuracy = FMax(FMin(VMP.EnemyAccuracyMod, BaseAccuracy), -0.35);
				bBuffedAccuracy = true;
			}
			StartingBaseAccuracy = BaseAccuracy;
		}
 	}
	
	if ((MinHealth > 1) && (Robot(Self) == None) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Enemy Damage Gate")))
	{
		bDamageGateInTact = true;
	}
	
	StoredScaleGlow = ScaleGlow;
	StoredFatness = Fatness;
	
	SprintStaminaMax = FMin(Health, 200.0);
	SprintStamina = SprintStaminaMax;
	
	StartingGroundSpeed = GroundSpeed;
	StartingBuoyancy = Buoyancy;
	StartingHealthValues[0] = HealthHead;
	StartingHealthValues[1] = HealthTorso;
	StartingHealthValues[2] = HealthArmLeft;
	StartingHealthValues[3] = HealthArmRight;
	StartingHealthValues[4] = HealthLegLeft;
	StartingHealthValues[5] = HealthLegRight;
	StartingHealthValues[6] = Health;
  	GenerateTotalHealth();
}

function VMDStartSprinting()
{
	local VMDCombatStim TStim;
	
	if (Animal(Self) != None || Robot(Self) != None) return;
	
	if (!VMDHasBuffType(class'CombatStimAura'))
	{
		TStim = VMDCombatStim(FindInventoryType(class'VMDCombatStim'));
		if ((TStim != None) && (!TStim.bDeleteMe) && (TStim.NumCopies > 0) && (!TStim.IsInState('Activated')))
		{
			 TStim.Activate();
		}
	}
	
	if (bHasAugmentations || bSprinting) return;
	
	bSprinting = true;
	VMDUpdateGroundSpeedBuoyancy();
}

//MADDERS, 6/22/24: Check for charge level, because we're both more timing sensitive and checked less often.
//More benefit and less risk for the chunkier check.
function bool VMDHasBuffType(class<VMDFakeBuffAura> BuffType)
{
	local VMDFakeBuffAura TBuff;
	
	TBuff = VMDFakeBuffAura(FindInventoryType(BuffType));
	if ((TBuff != None) && (TBuff.Charge > 0))
	{
		return true;
	}
	return false;
}

function VMDUpdateGroundSpeedBuoyancy()
{
	local bool bStimmed;
	local int i, ArmSum, LegSum, HealthChunks[7], ClockTimer;
	local float ArmMod, LegMod, PoisonMod;
	
	if (Animal(Self) != None || Robot(Self) != None) return;
	
	for (i=0; i<ArrayCount(HealthChunks); i++)
	{
		HealthChunks[i] = StartingHealthValues[i];
	}
	
 	if (Health > 0)
	{
		bStimmed = VMDHasBuffType(class'CombatStimAura');
		
 		ArmSum = HealthChunks[2] + HealthChunks[3];
		ArmMod = (ArmSum - HealthLegLeft - HealthLegRight) / ArmSum;
		
		LegSum = HealthChunks[4] + HealthChunks[5];
		LegMod = (LegSum - HealthLegLeft - HealthLegRight) / LegSum;
		
		PoisonMod = TotalPoisonDamage / HealthChunks[6];
		
 		//MADDERS, 5/26/23: Slow our speed from leg damage. Fun times.
		if (StartingGroundSpeed > 0) GroundSpeed = StartingGroundSpeed + (FMax(LegMod, PoisonMod) * StartingGroundSpeed * -0.5);
		if (StartingBuoyancy > 0) Buoyancy = StartingBuoyancy + (FMax(LegMod, PoisonMod*0.5) * StartingBuoyancy * -1.0);
		
		if ((bSprinting) && (SprintStamina > 0))
		{
			//MADDERS, 8/3/25: 33% * .706. Cancels out the diagonal movement going CRAZY for strafing melee NPCs.
			if (bStrafing)
			{
				GroundSpeed *= 1.23;
			}
			else
			{
				GroundSpeed *= 1.33;
			}
		}
		
		//MADDERS, 6/22/24: Enemies don't gain as much from combat stim as we would.
		//Also, mechs don't get boosted in speed at all.
		if ((bStimmed) && (!bMechAugs)) GroundSpeed *= 1.35;
		
		if (LastSpeedAugValue > 0)
		{
			GroundSpeed *= LastSpeedAugValue;
		}
		
		//MADDERS, 3/27/24: Lower our accuracy based on poison and arm damage. Neato mosquito.
		if ((Robot(Self) == None) && (Animal(Self) == None))
		{
			BaseAccuracy = StartingBaseAccuracy + ((ArmMod + PoisonMod)*2);
		}
	}
}

function bool VMDHasHearingExtensionObjection()
{
	local string TName;
	
	TName = class'VMDStaticFunctions'.Static.VMDGetMapName(Self);
	switch(TName)
	{
		case "05_NYC_UNATCOMJ12lab":
			if (Terrorist(Self) != None)
			{
				return true;
			}
			else if (MJ12Troop(Self) != None)
			{
				switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(Self))
				{
					case 2:
					case 4:
					case 12:
					case 17:
						return true;
					break;
				}
			}
		break;
		case "06_HONGKONG_WANCHAI_STREET":
		case "10_PARIS_CATACOMBS_TUNNELS":
			return true;
		break;
	}
	
	return false;
}

function VMDExtendVision()
{
	local int i;
	local float VisionRadiusBonus;
	local Vector TLocs[8];
	
	if (bBuffedVision) return;
	
	bBuffedVision = true;
	if (!class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "ENEMY VISION EXTENSION")) return;
	
	TLocs[0] = Location + Vect(1000, 0, 0);
	TLocs[1] = Location + Vect(2000, 0, 0);
	TLocs[2] = Location + Vect(-1000, 0, 0);
	TLocs[3] = Location + Vect(-2000, 0, 0);
	TLocs[4] = Location + Vect(0, 1000, 0);
	TLocs[5] = Location + Vect(0, 2000, 0);
	TLocs[6] = Location + Vect(0, -1000, 0);
	TLocs[7] = Location + Vect(0, -2000, 0);
	
	VisionRadiusBonus = 1.0;
	for (i=0; i<ArrayCount(TLocs); i++)
	{
		if (FastTrace(Location, TLocs[i]))
		{
			VisionRadiusBonus += 0.1024;
		}
	}
	SightRadius *= VisionRadiusBonus;
	SightRadius *= DifficultyVisionRangeMult;
}

function ApplySpecialStats()
{
	//MADDERS, 8/1/23: Zodiac commando noise patch. Neat.
	if (VMDPawnIsCommando())
	{
		//MADDERS, 3/29/25: Force our balancing to be like vanilla. Less health, damage reducing armor.
		if (IsA('ZodiacCommando'))
		{
			ArmorStrength = 0.75;
			HealthArmLeft = Min(HealthArmLeft, 200);
			HealthArmRight = Min(HealthArmRight, 200);
			HealthLegLeft = Min(HealthLegLeft, 200);
			HealthLegRight = Min(HealthLegRight, 200);
			HealthTorso = Min(HealthTorso, 200);
			HealthHead = Min(HealthHead, 200);
			StartingHealthValues[0] = HealthHead;
			StartingHealthValues[1] = HealthTorso;
			StartingHealthValues[2] = HealthArmLeft;
			StartingHealthValues[3] = HealthArmRight;
			StartingHealthValues[4] = HealthLegLeft;
			StartingHealthValues[5] = HealthLegRight;
			StartingHealthValues[6] = Health;
		}
		bRobotVision = true;
		HitSound1 = Sound'CommandoPainMedium';
		HitSound2 = Sound'CommandoPainLarge';
		Die = Sound'CommandoDeath';
	}
}

function ApplySpecialStats2();

//MADDERS, 5/24/20: Give ambient sounds to pawns with ballistic/hazmat on them, as to give some audio feedback.
function PostSpecialStatCheck()
{
	local Inventory Inv;
	
	//MADDERS, 12/20/20: Don't do this to civvies.
	if ((HumanMilitary(Self) == None) && (HumanThug(Self) == None)) return; 
	
	AmbientSound = None;
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (BallisticArmor(Inv) != None)
		{
			bFearEMP = true;
			GiveBallisticArmorTexture();
			AmbientSound = ChargedPickup(Inv).LoopSound;
			SoundVolume = 128;
		}
		else if (HazmatSuit(Inv) != None)
		{
			bFearEMP = true;
			GiveHazmatSuitModel();
			AmbientSound = ChargedPickup(Inv).LoopSound;
			SoundVolume = 128;
		}
		//MADDERS, 12/30/23: Show our tech goggles skins as necessary.
		else if (TechGoggles(Inv) != None)
		{
			bFearEMP = true;
			GiveGogglesTexture();
		}
	}
}

function GiveBallisticArmorTexture()
{
	local bool bTrenchcoat;
	local int TarIndex;
	
	TarIndex = -1;
	
	switch(Mesh.Name)
	{
		case 'GM_Jumpsuit':
		case 'TransGM_Jumpsuit':
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
			TarIndex = 2;
		break;
		case 'GM_Trench':
		case 'GM_Trench_F':
		case 'TransGM_Trench':
		case 'TransGM_Trench_F':
			bTrenchCoat = true;
			TarIndex = 4;
		break;
	}
	
	if (TarIndex > -1)
	{
		//A little uncreative feeling, but it's exactly what we need, I hate to say.
		if (bTrenchcoat)
		{
			Multiskins[TarIndex] = Texture'VMDTrenchCoatBallisticArmor';
		}
		else
		{
			switch(Multiskins[TarIndex])
			{
				case Texture'TerroristTex1':
					Multiskins[TarIndex] = Texture'VMDTerroristTex1BallisticArmor';
				break;
				case Texture'HKMilitaryTex1':
					Multiskins[TarIndex] = Texture'VMDHKMilitaryTex1BallisticArmor';
				break;
				case Texture'SoldierTex1':
					Multiskins[TarIndex] = Texture'VMDSoldierTex1BallisticArmor';
				break;
				case Texture'MJ12TroopTex2':
					Multiskins[TarIndex] = Texture'VMDMJ12TroopTex2BallisticArmor';
				break;
				case Texture'RiotCopTex2':
					Multiskins[TarIndex] = Texture'VMDRiotCopTex2BallisticArmor';
				break;
				case Texture'UNATCOTroopTex2':
					Multiskins[TarIndex] = Texture'VMDUNATCOTroopTex2BallisticArmor';
				break;
				//Revision specific
				case Texture'NathanMadisonTex1':
					Multiskins[TarIndex] = Texture'VMDNathanMadisonTex1BallisticArmor';
				break;
				
				case Texture'VMDNSFBountyHunter2Shirt01':
					Multiskins[TarIndex] = Texture'VMDNSFBountyHunter2Shirt01Armor';
				break;
				case Texture'VMDNSFBountyHunter2Shirt02':
					Multiskins[TarIndex] = Texture'VMDNSFBountyHunter2Shirt02Armor';
				break;
				case Texture'VMDNSFBountyHunter2Shirt03':
					Multiskins[TarIndex] = Texture'VMDNSFBountyHunter2Shirt03Armor';
				break;
				case Texture'VMDNSFBountyHunter2Shirt04':
					Multiskins[TarIndex] = Texture'VMDNSFBountyHunter2Shirt04Armor';
				break;
				case Texture'VMDNSFBountyHunter2Shirt05':
					Multiskins[TarIndex] = Texture'VMDNSFBountyHunter2Shirt05Armor';
				break;
			}
		}
	}
}

function RestoreBallisticArmorTexture()
{
	local int TarIndex;
	
	TarIndex = -1;
	
	switch(Mesh.Name)
	{
		case 'GM_Jumpsuit':
		case 'TransGM_Jumpsuit':
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
			TarIndex = 2;
		break;
		case 'GM_Trench':
		case 'GM_Trench_F':
		case 'TransGM_Trench':
		case 'TransGM_Trench_F':
			TarIndex = 4;
		break;
	}
	
	if (TarIndex > -1)
	{
		Multiskins[TarIndex] = StoredMultiskins[TarIndex];
	}
}

function GiveHazmatSuitModel();
function RestoreHazmatSuitModel();

function GiveGogglesTexture()
{
	local int TarIndex;
	
	TarIndex = -1;
	
	switch(Mesh.Name)
	{
		case 'GM_Jumpsuit':
		case 'TransGM_Jumpsuit':
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
			TarIndex = 6;
		break;
	}
	
	if (TarIndex > -1)
	{
		switch(Multiskins[TarIndex])
		{
			case None:
			case Texture'GogglesTex1':
			case Texture'VMDGogglesTex2':
			case Texture'VMDGogglesTex3':
			case Texture'VMDGogglesTex4':
			case Texture'VMDGogglesTex5':
				Multiskins[TarIndex] = Texture'VMDTechGogglesTex1';
			break;
			case Texture'VMDMJ12TroopTex4':
				Multiskins[TarIndex] = Texture'VMDMJ12TroopTex4TechGoggles';
			break;
			case Texture'RiotCopTex3':
				Multiskins[TarIndex] = Texture'VMDRiotCopTex3TechGoggles';
			break;
			case Texture'SoldierTex3':
				Multiskins[TarIndex] = Texture'VMDSoldierTex3TechGoggles';
			break;
			case Texture'UNATCOTroopTex3':
				Multiskins[TarIndex] = Texture'VMDUNATCOTroopTex3TechGoggles';
			break;
		}
	}
}

function RestoreGogglesTexture()
{
	local int TarIndex;
	
	TarIndex = -1;
	
	switch(Mesh.Name)
	{
		case 'GM_Jumpsuit':
		case 'TransGM_Jumpsuit':
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
			TarIndex = 6;
		break;
	}
	
	if (TarIndex > -1)
	{
		Multiskins[TarIndex] = StoredMultiskins[TarIndex];
	}
}

function VMDResetSkinHook()
{
	local int i, TarIndex[3];
	
	TarIndex[0] = -1;
	TarIndex[1] = -1;
	TarIndex[2] = -1;
	
	switch(Mesh.Name)
	{
		case 'GFM_TShirtPants':
		case 'TransGFM_TShirtPants':
			TarIndex[0] = 3;
			TarIndex[1] = 4;
		break;
		case 'GM_Jumpsuit':
		case 'Trans_GM_Jumpsuit':
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
			TarIndex[0] = 5;
		break;
		case 'GM_Suit':
		case 'TransGM_Suit':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
		break;
		case 'GM_DressShirt':
		case 'TransGM_DressShirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_DressShirt_B':
		case 'TransGM_DressShirt_B':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
			TarIndex[2] = 7;
		break;
		case 'GFM_SuitSkirt':
		case 'TransGFM_SuitSkirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_Trench':
		case 'TransGM_Trench':
		case 'GM_Trench_F':
		case 'TransGM_Trench_F':
		case 'GFM_Trench':
		case 'TransGFM_Trench':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
	}
	
	for (i=0; i<ArrayCount(TarIndex); i++)
	{
		if (TarIndex[i] != -1)
		{
			Multiskins[TarIndex[i]] = StoredMultiskins[TarIndex[i]];
			//Default.Multiskins[TarIndex[i]];
		}
	}
}

function VMDEnableCloakHook(bool bEnable)
{
	local int i, TarIndex[3];
	
	TarIndex[0] = -1;
	TarIndex[1] = -1;
	TarIndex[2] = -1;
	
	switch(Mesh.Name)
	{
		case 'GFM_TShirtPants':
		case 'TransGFM_TShirtPants':
			TarIndex[0] = 3;
			TarIndex[1] = 4;
		break;
		case 'GM_Jumpsuit':
		case 'Trans_GM_Jumpsuit':
		case 'MP_Jumpsuit':
		case 'VMDMP_Jumpsuit':
			TarIndex[0] = 5;
		break;
		case 'GM_Suit':
		case 'TransGM_Suit':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
		break;
		case 'GM_DressShirt':
		case 'TransGM_DressShirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_DressShirt_B':
		case 'TransGM_DressShirt_B':
			TarIndex[0] = 5;
			TarIndex[1] = 6;
			TarIndex[2] = 7;
		break;
		case 'GFM_SuitSkirt':
		case 'TransGFM_SuitSkirt':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
		case 'GM_Trench':
		case 'TransGM_Trench':
		case 'GM_Trench_F':
		case 'TransGM_Trench_F':
		case 'GFM_Trench':
		case 'TransGFM_Trench':
			TarIndex[0] = 6;
			TarIndex[1] = 7;
		break;
	}
	
	for (i=0; i<ArrayCount(TarIndex); i++)
	{
		if (TarIndex[i] != -1)
		{
			if (bEnable)
			{
				Multiskins[TarIndex[i]] = Texture'BlackMaskTex';
			}
			else
			{
				Multiskins[TarIndex[i]] = StoredMultiskins[TarIndex[i]];
				//Default.Multiskins[TarIndex[i]];
			}
		}
	}
}

//MADDERS: For robots, as far as anyone can tell.
function VMDEMPHook();

//MADDERS, 10/17/24: Called my infamy reinforcement.
function VMDRandomizeAppearance();

//MADDERS: Use this for checking classes. Pretty hacky.
function bool VMDOtherIsName(string S, optional Actor Other)
{
	if (Other == None) Other = Self;
	
 	if (InStr(CAPS(String(Other.Class)), CAPS(S)) != -1) return true;
 	return false;
}

//MADDERS: This shit's just too easy.
function CheckForHelmets()
{
 	/*if (VMDOtherIsName("MIB", Self) || VMDOtherIsName("WIB", Self))
 	{
     		ArmorNoiseIndex[0] = 0;
     		ArmorNoiseIndex[1] = 0;
  		bHasBodyArmor = True;
 	}*/
	
	if (VMDOtherIsName("Gunther", Self))
	{
     		ArmorNoiseIndex[0] = 1;
     		ArmorNoiseIndex[1] = 1;
  		bHasHelmet = False;
		bHasHeadArmor = True;
  		bHasBodyArmor = True;
	}

	if (VMDOtherIsName("Navarre", Self))
	{
     		ArmorNoiseIndex[0] = 1;
     		ArmorNoiseIndex[1] = 0;
  		bHasHelmet = False;
		bHasHeadArmor = False;
  		bHasBodyArmor = True;
	}
	
 	if (VMDOtherIsName("Commando", Self))
 	{
     		ArmorNoiseIndex[0] = 1;
     		ArmorNoiseIndex[1] = 1;
  		bHasHelmet = False;
		bHasHeadArmor = True;
  		bHasBodyArmor = True;
 	}
 	
 	if ((Mesh != LODMesh'GM_Jumpsuit') && (Mesh != LODMesh'TransGM_Jumpsuit') && (Mesh != LODMesh'MP_Jumpsuit') && (Mesh != LODMesh'VMDMP_Jumpsuit')) return;
 	
 	//Goggles is the only real exception here, tbh.
 	switch(Multiskins[6])
 	{
		case None:
  		case Texture'PinkMaskTex':
  		case Texture'GogglesTex1':
		case Texture'VMDTechGogglesTex1':
		case Texture'ThugMale3Tex3':
   			bHasHelmet = False;
  		break;
  		default:
   			bHasHelmet = True;
  		break;
 	}
}

function bool BypassesHelmet( name DT )
{
 	switch(DT)
 	{
  		case 'Shot':
  		case 'Poison':
  		case 'KnockedOut':
		case 'Stunned': //MADDERS, 6/22/25: Taser and taser slug can be reduced by helmets now, too.
   			return False;
  		break;
  		default:
   			return True;
  		break;
 	}
 	
 	return False;
}

function DeflectHelmetProjectile(int D, vector HL, vector Off, name DT, optional bool bHelmet)
{
 	local float TSize, TMult, GSpeed;
 	local Vector DAngle, OAngle, HAngle, TPos;
 	local Rotator TRot;
	local HelmetProjectile HP;
  	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
 	if (ArmorNoiseIndex[int(bHelmet)] > 0)
 	{
  		VMDPlayRicochetSound();
 	}
 	
 	//Step 1: Derive original hit normal.
 	/*OAngle = Off >> Rotator(HL - Location);
 	TPos = Location; //While we're at it, derive our spawn loc.
 	TPos.Z = HL.Z;
 	
 	//Step 2: Deflect this shit in offset.
 	DAngle = Normal(OAngle);
 	if (Frand() < 0.9) DAngle.X *= -1;
 	if (Frand() > 0.1) DAngle.Y *= -1;
 	DAngle.Z = 0;
 	
 	TRot = RotRand(False);
 	TRot = TRot / 16;
 	TRot = TRot - Rot(0, -8192, 0);
 	
 	DAngle = Vector((Rotator(DAngle) + TRot));
 	DAngle.Z = 0.05 - (Frand() * 0.1);
 	
 	//Step 3: Fire that shit and match DT and D.
 	PlaySound(Sound'ArmorRicochet', SLOT_Misc, 48,, 512, GSpeed);
 	HP = Spawn(Class'HelmetProjectile',Self,, TPos + (DAngle * (5 + CollisionRadius)), Rotator(DAngle));
 	if (HP != None)
 	{
  		HP.Damage = D;
  		HP.DamageType = DT;
 	}*/
}

//MADDERS, 1/25/23: So far only used in ford, but fuck it, have at it.
function VMDConvoBindHook();

//MADDERS, 12/22/22: Recommendations from Han on missing functions. These might resolve crashes.
function AdjustJump();
function MoveFallingBody();
function Vector FocusDirection();
function FindBackupPoint();
function bool DoorEncroaches();

//BARF! Thanks, Ion.
function PickDestinationPlain();
function PickDestinationInputBool(bool ExampleBool);
function bool PickDestinationBool();
function EDestinationType PickDestinationEnum();

function float DistanceToTarget();
function AlarmUnit FindTarget();
function bool GetNextAlarmPoint(AlarmUnit alarm);
function vector FindAlarmPosition(Actor alarm);
function bool IsAlarmInRange(AlarmUnit alarm);
function TriggerAlarm();
function bool IsAlarmReady(Actor actorAlarm);
function EndCrouch();
function StartCrouch();
function bool ShouldCrouch();
function bool ReadyForWeapon();
function bool IsHandToHand();
function CheckAttack(bool bPlaySound);
function bool FireIfClearShot();
function bool InSeat(out vector newLoc);
function FinishFleeing();
function NavigationPoint GetOvershootDestination(float randomness, optional float focus);
function bool GetNextLocation(out vector nextLoc);
function PatrolPoint PickStartPoint();
function bool GoHome();
function FollowSeatFallbackOrders();
function FindBestSeat();
function int FindBestSlot(Seat seatActor, out float slotDist);
function bool IsIntersectingSeat();
function vector GetDestinationPosition(Seat seatActor, optional float extraDist);
function Vector SitPosition(Seat seatActor, int slot);

defaultproperties
{
     bCanGrabWeapons=True
     bCanClimbLadders=True
     LadderJumpZMult=1.000000
     DifficultyVisionRangeMult=1.000000
     DifficultyReactionSpeedMult=1.000000
     ROFCounterweight=0.300000
     EnviroSkillLevel=1
     PoisonReactThreshold=0.800000
     MaxGuessingFudge=0.650000
     bDoesntSniff=False
     ArmorNoiseIndex(0)=0
     ArmorNoiseIndex(1)=1
     SmellTypes(0)=StrongPlayerFoodSmell
     SmellTypes(9)=PlayerSmell
     FakeBarkSniffing="(Sniffing)"
     MessagePickpocketingSuccess="No prying eyes witness your expert pickpocketing"
     MessagePickpocketingFailure="Your target's pockets hold nothing worth while"
     MessagePickpocketingSpotted="While succesful, your pickpocketing is seen by a nearby witness"
     
     HelmetDamageThreshold=25
     ArmorDamageThreshold=50
     ArmorStrength=0.650000
     bEverNotFrobbed=true
     //MADDERS: New stuff!
     LastWeaponDamageSkillMult=-1.000000
     OverrideHeight=-2.000000
     bExplosive=False
     bHasBodyArmor=False
     bHasHeadArmor=False
     bHasHelmet=False
     
     //Audio.
     FootstepProjectRadius=768.000000
     FootstepProjectMaxRadius=2048.00000
     ReceiveNoiseHeightTolerance=0.650000
     SendNoiseHeightTolerance=0.650000
}