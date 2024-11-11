//=============================================================================
// VMDMEGH.
//=============================================================================
class VMDMEGH extends Robot;

var localized string MsgMeghKilled;
var(MADDERS) localized string BritishTextTargetAcquired[5];

var(MEGH) bool bCanHack, bCanHeal, bHasHeal, bHealthBuffed, bMeleeBuff, bHasMedigel, bReversePatrol, bReconMode, bSaidOutOfAmmo;
var(MEGH) string CustomName;

var(MEGHAI) int NumReconTargets;
var(MEGHAI) float ReconScanTimer, LiteHackRefreshTimer, TargetAcquiredSpeechTimer, ReconPingSoundTimer;

var(MEGHAI) Actor LiteHackTarget, DestroyOtherActor, LastMEGHPatrolPoint;
var(MEGHAI) ComputerSecurity LiteHackComputer;
var(MEGHAI) VMDBufferPawn OppressTarget, GuardedOther;
var(MEGHAI) ScriptedPawn ReconTargets[16], DestroyOtherPawn, MEGHLastEnemy;

var(MEGHAI) AllianceInfoEx CachedAlliances[16];

var(MEGHHacks) bool bWallCrammed, bDoorGhosting, bDebugState, bQueueTalentUpdate;
var(MEGHHacks) int PathingFailures, PathingFailures2, LastLocationFailures;
var(MEGHHacks) float PositionRecheckTimer;
var(MEGHHacks) vector LastLocation, FirstLocation;
var(MEGHHacks) Rotator WallCramPointer;

//MADDERS, 9/4/22: This used to be "elevatorhackloc", for elevator stuff, but this
//very rapidly devolved into one more hack, and another, and another... And fuck me.
//If it didn't work in such an immaculate fashion, I'd stop using it, but 3d pathfinding
//(We fly, remember) absolutely shits the bed minute 1 of trying to navigate anywhere,
//and even after solving those issues, it still sometimes gets the nighttime squirties.
//I'm sorry I can't make it work by Eidos' AI structure rules, but as I figure:
//New movement type = new ruleset = new methodology.
//Because 3d movement is always freaking out, we have to always be ready to correct,
//state tag irrelevant. Jesus. Longest notation of my life. ~WCCC
var(MEGHHacks) Vector PathOverrideHackLoc, DoorGhostLoc;

struct Empty {};

struct GraftedComputerSecurityRef extends Empty
{
    var Actor Value; 
};

struct GraftedHCComputerSecurityRef extends Empty
{
    var Actor Value; 
};

final function GraftedComputerSecurity AizomeFudgeCast(Actor OrderActor)
{
	local GraftedComputerSecurityRef GraftedComputerSecurityRef;
	local Empty Empty;
	local GraftedComputerSecurity Result;
	
	GraftedComputerSecurityRef.Value = OrderActor;
	Empty = GraftedComputerSecurityRef;
	
	return Result;
}

final function GraftedHCComputerSecurity AizomeHCFudgeCast(Actor OrderActor)
{
	local GraftedHCComputerSecurityRef GraftedHCComputerSecurityRef;
	local Empty Empty;
	local GraftedHCComputerSecurity Result;
	
	GraftedHCComputerSecurityRef.Value = OrderActor;
	Empty = GraftedHCComputerSecurityRef;
	
	return Result;
}

function bool VMDPlayerIsOnElevator(DeusExPlayer DXP)
{
	local int TWidth, TBreadth, THeight;
	local Vector ColBoxMin, ColBoxMax;
	local Mover TMov;
	
	if ((DXP != None) && (DXP.Base != Level) && (DXP.Base != None) && (Mover(DXP.Base) != None))
	{
		//MADDERS, 7/15/24: Do some really swoocey shit here.
		//Basically, if it's too big to be an elevator, it's probably some moving piece of floor (NYC sewer bridge, for instance)
		//Or, if it's really small on 2 axes, it's not big enough to be a real elevator.
		TMov = Mover(DXP.Base);
		TMov.GetBoundingBox(ColBoxMin, ColBoxMax, false, TMov.KeyPos[TMov.KeyNum]+TMov.BasePos, TMov.KeyRot[TMov.KeyNum]+TMov.BaseRot);
		
		TWidth = ColBoxMax.Y - ColBoxMin.Y;
		TBreadth = ColBoxMax.X - ColBoxMin.X;
		THeight = ColBoxMax.Z - ColBoxMin.Z;
		
		if (TWidth > 256 || TBreadth > 256 || THeight > 256)
		{
			return false;
		}
		else if (TWidth < 48)
		{
			if (TBreadth < 48)
			{
				return false;
			}
			else if (THeight < 48)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		else if (TBreadth < 48)
		{
			if (THeight < 48)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
		else
		{
			return true;
		}
	}
	
	return false;
}

function bool VMDCanBeMEGHEnemy(Actor Other)
{
	if (Other == None || PlayerPawn(Other) != None) return false;
	
	switch(Other.Class.Name)
	{
		case 'JaimeReyes':
		case 'PaulDenton':
		case 'AlexJacobson':
		case 'SamCarter':
		case 'JCDouble':
		case 'VMDMEGH':
		case 'VMDSIDD':
			ScriptedPawn(Other).ChangeAlly('PlayerDrone', 1.0, true);
			return false;
		break;
	}
	
	return true;
}

function PlayOutOfAmmoSound()
{
	if (bSaidOutOfAmmo) return;
	
	SpoofBarkLine(GetLastVMP(), TextOutOfAmmo);
	
	if (!bDeleteMe)
	{
		bSaidOutOfAmmo = true;
		PlaySound(SpeechOutOfAmmo, SLOT_None,,, 2048);
	}
}

// ----------------------------------------------------------------------
// ChangeAlly()
// ----------------------------------------------------------------------

function ChangeAlly(Name newAlly, optional float allyLevel, optional bool bPermanent, optional bool bHonorPermanence)
{
	local int i;
	
	if (!bReconMode)
	{
		// Members of the same alliance will ALWAYS be friendly to each other
		if (newAlly == Alliance)
		{
			allyLevel  = 1;
			bPermanent = true;
		}
		
		if (bHonorPermanence)
		{
			for (i=0; i<16; i++)
				if (AlliancesEx[i].AllianceName == newAlly)
					if (AlliancesEx[i].bPermanent)
						break;
			if (i < 16)
				return;
		}		
		
		if (allyLevel < -1)
			allyLevel = -1;
		if (allyLevel > 1)
			allyLevel = 1;
		
		for (i=0; i<16; i++)
			if ((AlliancesEx[i].AllianceName == newAlly) || (AlliancesEx[i].AllianceName == ''))
				break;
		
		if (i >= 16)
			for (i=15; i>0; i--)
			AlliancesEx[i] = AlliancesEx[i-1];
		
		AlliancesEx[i].AllianceName         = newAlly;
		AlliancesEx[i].AllianceLevel        = allyLevel;
		AlliancesEx[i].AgitationLevel       = 0;
		AlliancesEx[i].bPermanent           = bPermanent;
		
		bAlliancesChanged    = True;
		bNoNegativeAlliances = False;
	}
	else
	{
		// Members of the same alliance will ALWAYS be friendly to each other
		if (newAlly == Alliance)
		{
			allyLevel  = 1;
			bPermanent = true;
		}
		
		if (bHonorPermanence)
		{
			for (i=0; i<16; i++)
				if (CachedAlliances[i].AllianceName == newAlly)
					if (CachedAlliances[i].bPermanent)
						break;
			if (i < 16)
				return;
		}		
		
		if (allyLevel < -1)
			allyLevel = -1;
		if (allyLevel > 1)
			allyLevel = 1;
		
		for (i=0; i<16; i++)
			if ((CachedAlliances[i].AllianceName == newAlly) || (CachedAlliances[i].AllianceName == ''))
				break;
		
		if (i >= 16)
			for (i=15; i>0; i--)
			CachedAlliances[i] = CachedAlliances[i-1];
		
		CachedAlliances[i].AllianceName         = newAlly;
		CachedAlliances[i].AllianceLevel        = allyLevel;
		CachedAlliances[i].AgitationLevel       = 0;
		CachedAlliances[i].bPermanent           = bPermanent;
		
		bAlliancesChanged    = True;
		bNoNegativeAlliances = False;
	}
}

// ----------------------------------------------------------------------
// AgitateAlliance()
// ----------------------------------------------------------------------

function AgitateAlliance(Name newEnemy, float agitation)
{
	local int   i;
	local float oldLevel;
	local float newLevel;
	
	if (NewEnemy == 'Player') return;
	
	if (!bReconMode)
	{
		if (newEnemy != '')
		{
			for (i=0; i<16; i++)
				if ((AlliancesEx[i].AllianceName == newEnemy) || (AlliancesEx[i].AllianceName == ''))
					break;
			
			if (i < 16)
			{
				if ((AlliancesEx[i].AllianceName == '') || !(AlliancesEx[i].bPermanent))
				{
					if (AlliancesEx[i].AllianceName == '')
						AlliancesEx[i].AllianceLevel = 0;
					oldLevel = AlliancesEx[i].AgitationLevel;
					newLevel = oldLevel + agitation;
						if (newLevel > 1.0)
						newLevel = 1.0;
					AlliancesEx[i].AllianceName   = newEnemy;
					AlliancesEx[i].AgitationLevel = newLevel;
					if ((newEnemy == 'Player') && (oldLevel < 1.0) && (newLevel >= 1.0))  // hack
						PlayerAgitationTimer = 2.0;
					bAlliancesChanged = True;
				}
			}
		}
	}
	else
	{
		if (newEnemy != '')
		{
			for (i=0; i<16; i++)
				if ((CachedAlliances[i].AllianceName == newEnemy) || (CachedAlliances[i].AllianceName == ''))
					break;
			
			if (i < 16)
			{
				if ((CachedAlliances[i].AllianceName == '') || !(CachedAlliances[i].bPermanent))
				{
					if (CachedAlliances[i].AllianceName == '')
						CachedAlliances[i].AllianceLevel = 0;
					oldLevel = CachedAlliances[i].AgitationLevel;
					newLevel = oldLevel + agitation;
						if (newLevel > 1.0)
						newLevel = 1.0;
					CachedAlliances[i].AllianceName   = newEnemy;
					CachedAlliances[i].AgitationLevel = newLevel;
					if ((newEnemy == 'Player') && (oldLevel < 1.0) && (newLevel >= 1.0))  // hack
						PlayerAgitationTimer = 2.0;
					bAlliancesChanged = True;
				}
			}
		}
	}
}


// ----------------------------------------------------------------------
// UpdateAgitation()
// ----------------------------------------------------------------------

function UpdateAgitation(float deltaSeconds)
{
	local float mult;
	local float decrement;
	local int   i;
	
	if (!bReconMode)
	{
		if (AgitationCheckTimer > 0)
		{
			AgitationCheckTimer -= deltaSeconds;
			if (AgitationCheckTimer < 0)
				AgitationCheckTimer = 0;
		}	
		
		decrement = 0;
		if (AgitationTimer > 0)
		{
			if (AgitationTimer < deltaSeconds)
			{
				mult = 1.0 - (AgitationTimer/deltaSeconds);
				AgitationTimer = 0;
				decrement = mult * (AgitationDecayRate*deltaSeconds);
			}
			else
				AgitationTimer -= deltaSeconds;
		}
		else
			decrement = AgitationDecayRate*deltaSeconds;
		
		if (bAlliancesChanged && (decrement > 0))
		{
			bAlliancesChanged = False;
			for (i=15; i>=0; i--)
			{
				if ((AlliancesEx[i].AllianceName != '') && (!AlliancesEx[i].bPermanent))
				{
					if (AlliancesEx[i].AgitationLevel > 0)
					{
						bAlliancesChanged = true;
						AlliancesEx[i].AgitationLevel -= decrement;
						if (AlliancesEx[i].AgitationLevel < 0)
							AlliancesEx[i].AgitationLevel = 0;
					}
				}
			}
		}
	}
	else
	{
		if (AgitationCheckTimer > 0)
		{
			AgitationCheckTimer -= deltaSeconds;
			if (AgitationCheckTimer < 0)
				AgitationCheckTimer = 0;
		}	
		
		decrement = 0;
		if (AgitationTimer > 0)
		{
			if (AgitationTimer < deltaSeconds)
			{
				mult = 1.0 - (AgitationTimer/deltaSeconds);
				AgitationTimer = 0;
				decrement = mult * (AgitationDecayRate*deltaSeconds);
			}
			else
				AgitationTimer -= deltaSeconds;
		}
		else
			decrement = AgitationDecayRate*deltaSeconds;
		
		if (bAlliancesChanged && (decrement > 0))
		{
			bAlliancesChanged = False;
			for (i=15; i>=0; i--)
			{
				if ((CachedAlliances[i].AllianceName != '') && (!CachedAlliances[i].bPermanent))
				{
					if (CachedAlliances[i].AgitationLevel > 0)
					{
						bAlliancesChanged = true;
						CachedAlliances[i].AgitationLevel -= decrement;
						if (CachedAlliances[i].AgitationLevel < 0)
							CachedAlliances[i].AgitationLevel = 0;
					}
				}
			}
		}
	}
}

function ToggleReconMode()
{
	bReconMode = !bReconMode;
	if (bReconMode)
	{
		CacheAlliances();
	}
	else
	{
		UncacheAlliances();
	}
	SetupWeapon(!bReconMode, true);
	
	UpdateMEGHAlliance();
}

function CacheAlliances()
{
	local int i;
	local AllianceInfoEx EmptyAlliance;
	local Pawn TPawn;
	local ScriptedPawn SP;
	
	for (i=0; i<ArrayCount(AlliancesEx); i++)
	{
		CachedAlliances[i] = AlliancesEx[i];
		AlliancesEx[i] = EmptyAlliance;
	}
	
	//Our defining feature is the ability to make peace with this entity in a mutual sense.
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((SP != None) && (SP.GetPawnAllianceType(Self) == ALLIANCE_Hostile))
		{
			SP.ChangeAlly('PlayerDrone', 1, true);
			if (SP.Enemy == Self)
			{
				SP.SetEnemy(None);
			}
		}
	}
}

function UncacheAlliances()
{
	local int i;
	local AllianceInfoEx EmptyAlliance;
	
	for (i=0; i<ArrayCount(AlliancesEx); i++)
	{
		AlliancesEx[i] = CachedAlliances[i];
		CachedAlliances[i] = EmptyAlliance;
	}
}

function int VMDGetMaxHealth()
{
	local int Ret;
	
	if (VMDGetMissionNumber() < 5)
	{
		if (!bHealthBuffed)
		{
			Ret = 25;
		}
		else
		{
			Ret = 75;
		}
	}
	else
	{
		if (!bHealthBuffed)
		{
			Ret = 50;
		}
		else
		{
			Ret = 150;
		}
	}
	
	if (VMDMayhemEnabled())
	{
		Ret *= 2;
	}
	
	return Ret;
}

function int VMDGetMaxEMPHitPoints()
{
	local int Ret;
	
	Ret = 100;
	if ((GetLastVMP() != None) && (LastVMP.HasSkillAugment('ElectronicsDroneArmor')))
	{
		Ret += 200;
	}
	
	if (VMDMayhemEnabled())
	{
		Ret *= 2;
	}
	
	return Ret;
}

function bool VMDMayhemEnabled()
{
	if (GetLastVMP() != None)
	{
		return LastVMP.bMayhemSystemEnabled;
	}
	return false;
}

function PlayAttack()
{
	if (WeaponBaton(Weapon) != None || WeaponCombatKnife(Weapon) != None)
	{
		Super(VMDBufferPawn).PlayAttack();
	}
	else
	{
		Super.PlayAttack();
	}
}

function TweenToAttack(float tweentime)
{
	if (WeaponBaton(Weapon) != None || WeaponCombatKnife(Weapon) != None)
	{
		Super(VMDBufferPawn).TweenToAttack(TweenTime);
	}
	else
	{
		Super.TweenToAttack(TweenTime);
	}
}

function TweenToShoot(float tweentime)
{
	if (WeaponBaton(Weapon) != None || WeaponCombatKnife(Weapon) != None)
	{
		Super(VMDBufferPawn).TweenToShoot(TweenTime);
	}
	else
	{
		Super.TweenToShoot(TweenTime);
	}
}

function PlayShoot()
{
}

function PlayFlying()
{
}

function PlayRunningAndFiring()
{
	if (WeaponBaton(Weapon) != None || WeaponCombatKnife(Weapon) != None)
	{
		Super(VMDBufferPawn).PlayAttack();
	}
	else
	{
		Super.PlayRunningAndFiring();
	}
}

//MADDERS, 9/14/22: Reduce select damage types that hard counter us. Try and balance things out, you know?
function float ShieldDamage(Name damageType)
{
	local float Ret;
	
	switch(DamageType)
	{
		case 'Exploded':
			Ret = 0.35;
		break;
		case 'Burned':
			Ret = 0.5;
		break;
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

//MADDERS, 9/14/22: Don't draw shield tho.
function DrawShield()
{
}

function PlayTargetAcquiredSound()
{
	local int TRand;
	local string TSpoof;
	local Sound TSound;
	
	if (TargetAcquiredSpeechTimer > 0.0) return;
	
	TargetAcquiredSpeechTimer = 2.0;
	
	if ((!bDeleteMe) && (DeusExWeapon(Weapon) != None) && (DeusExWeapon(Weapon).VMDIsMeleeWeapon()))
	{
		TRand = Rand(5);
		TSpoof = BritishTextTargetAcquired[TRand];
		
		switch(TRand)
		{
			case 0:
				TSound = Sound'VMDMeghBritTalk01';
			break;
			case 1:
				TSound = Sound'VMDMeghBritTalk02';
			break;
			case 2:
				TSound = Sound'VMDMeghBritTalk03';
			break;
			case 3:
				TSound = Sound'VMDMeghBritTalk04';
			break;
			case 4:
				TSound = Sound'VMDMeghBritTalk05';
			break;
		}
		
		SpoofBarkLine(GetLastVMP(), TSpoof);
		TargetAcquiredSound = PlaySound(TSound, SLOT_None,,, 2048);
	}
	else
	{
		Super.PlayTargetAcquiredSound();
	}
}

function int VMDGetMissionNumber()
{
	local DeusExLevelInfo DXLI;
	
	ForEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		return DXLI.MissionNumber;
	}
	
	return 1;
}

simulated event RenderOverlays( canvas Canvas )
{
	Super.RenderOverlays(Canvas);
}

function string VMDGetDisplayName(string InName)
{
	if (CustomName == "")
	{
		return InName;
	}
	else
	{
		return CustomName;
	}
}

function InvokeMEGHManagementWindow(DeusExPlayer DXP)
{
 	local DeusExRootWindow Root;
	local VMDMenuMEGHManagement TarWindow;
	
	if (DXP == None) return;
	
  	Root = DeusExRootWindow(DXP.RootWindow);
    	if (Root != None)
  	{
		//Set to true for real time ordering.
   		TarWindow = VMDMenuMEGHManagement(Root.InvokeMenuScreen(Class'VMDMenuMEGHManagement', False));
		if (TarWindow != None)
		{
			if (TarWindow.CustomNameEntry != None)
			{
				TarWindow.CustomNameEntry.SetText(CustomName);
			}
			TarWindow.UpdateInfo();
		}
	}
}

function Frob(Actor Frobber, Inventory FrobWith)
{
	Super.Frob(Frobber, FrobWith);
	
	if ((EMPHitPoints > 0) && (DeusExPlayer(Frobber) != None))
	{
		InvokeMEGHManagementWindow(DeusExPlayer(Frobber));
	}
}

function CheckHealthScaling()
{
  	bSetupBuffedHealth = True;
 	
	StartingHealthValues[0] = HealthHead;
	StartingHealthValues[1] = HealthTorso;
	StartingHealthValues[2] = HealthArmLeft;
	StartingHealthValues[3] = HealthArmRight;
	StartingHealthValues[4] = HealthLegLeft;
	StartingHealthValues[5] = HealthLegRight;
	
	StartingHealthValues[6] = VMDGetMaxHealth();
	
	StartingEMPHitPoints = EMPHitPoints;
}

function ApplySpecialStats()
{
	local Vector BarfVect;
	local VMDBufferPlayer VMP;
	
	Super.ApplySpecialStats();
	
	if (FirstLocation == BarfVect) FirstLocation = Location;
	
	ROFCounterweight = 0;
	
	VMP = GetLastVMP();
	if ((VMP != None) && (bQueueTalentUpdate))
	{
		bQueueTalentUpdate = false;
		UpdateTalentEffects(VMP);
	}
}

//MADDERS, 09/04/22: Update weapon model.
function PostSpecialStatCheck()
{
	Super.PostSpecialStatCheck();
	
	UpdateWeaponModel();
}

function UpdateSensitiveMap()
{
	if ((class'VMDStaticFunctions'.Static.VMDIsWeaponSensitiveMap(Self)) && (!bReconMode))
	{
		BroadcastMessage("Sensitive zone detected. Holstering weapon.");
		bReconMode = true;
	}
	SetupWeapon(!bReconMode, true);
}

function UpdateHackAlliances()
{
	local string TName;
	local Pawn TPawn;
	local ScriptedPawn SP;
	local VMDBufferPlayer VMP;
	
	VMP = GetLastVMP();
	if (VMP == None) return;
	
	TName = VMP.VMDGetMapName();
	switch(TName)
	{
		case "75_ZODIAC_NEWMEXICO_HOLLOMAN":
			ChangeAlly('Good_guys', 1, true);
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if ((SP != None) && (SP.IsA('AmandaShaysFast')))
				{
					SP.ChangeAlly('PlayerDrone', 1, true);
				}
			}
		break;
	}
}

function DeusExWeapon FirstWeapon()
{
	local Inventory Inv;
	
	for(Inv = Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (DeusExWeapon(Inv) != None)
		{
			return DeusExWeapon(Inv);
		}
	}
	return None;
}

function DropAmmo(DeusExAmmo DXA, Vector DropVect)
{
	if ((DXA != None) && (!DXA.bDeleteMe) && (DXA.PickupViewMesh != LODMesh'TestBox'))
	{
		if (DXA.AmmoAmount <= 0)
		{
			DXA.Destroy();
		}
		else
		{
			DXA.DropFrom(DropVect);
			DXA.AmmoAmount = Min(DXA.MaxAmmo, DXA.AmmoAmount);
		}
	}
}

function bool VMDMeghDropWeapon()
{
	local bool bWon;
	local Vector DropVect, DropVect2;
	
	local DeusExWeapon DXW;
	local DeusExAmmo DXA;
	
	DXW = FirstWeapon();
	if (DXW != None)
	{
		DropVect = Location-vect(0,0,15);
		DropVect2 = Location-vect(0,0,10);
		
		DXA = DeusExAmmo(DXW.AmmoType);
		if ((DXA != None) && (!DXA.bDeleteMe) && (DXA.AmmoAmount > 0))
		{
			if (DXA.PickupViewMesh != LODMesh'TestBox')
			{
				bWon = VMDDropItemFrom(DXW, DropVect);
				DXW.PickupAmmoCount = 0;
			}
			else
			{
				if (DXW.bInstantHit)
				{
					bWon = VMDDropItemFrom(DXW, DropVect);
					DXW.PickupAmmoCount = 1; //DXA.AmmoAmount
				}
				else
				{
					if (Health > 0)
					{
						bWon = VMDDropItemFrom(DXW, DropVect);
						DXW.PickupAmmoCount = 1;
					}
					else
					{
						VMDDumpSuicideGrenade(DXW);
					}
				}
			}
		}
		else
		{
			bWon = VMDDropItemFrom(DXW, DropVect);
			
			if (DXW.AmmoName == None)
			{
				DXW.PickupAmmoCount = 0;
			}
			else if (DXW.AmmoName.Default.PickupViewMesh == LODMesh'TestBox')
			{
				if (DXW.bInstantHit)
				{
					DXW.PickupAmmoCount = 0;
				}
				else
				{
					if (Health > 0)
					{
						DXW.PickupAmmoCount = 1;
					}
					else
					{
						DXW.Destroy();
					}
				}
			}
			else
			{
				DXW.PickupAmmoCount = 0;
			}
		}
		
		if (bWon)
		{
			SetWeapon(None);
			
			DXW.AmmoType = None;
			if (DXW.bLasing) DXW.LaserOff();
			if (DXW.bZoomed) DXW.ScopeOff();
			
			DropAmmo(DXA, DropVect2);
		}
	}
	
	return bWon;
}

function VMDMedigel VMDMeghDropSyringe()
{
	local VMDMedigel Gel;
	
	if (bHasHeal)
	{
		Gel = Spawn(class'VMDMedigel',,, Location-vect(0,0,7), Rotation);
		if (Gel != None)
		{
			bHasHeal = false;
		}
	}
	
	return Gel;
}

function bool VMDDropItemFrom(Inventory Item, vector StartLocation)
{
	if (!Item.SetLocation(StartLocation))
	{
		return false;
	}
	
	Item.RespawnTime = 0.0; //don't respawn
	Item.SetPhysics(PHYS_Falling);
	Item.RemoteRole = ROLE_DumbProxy;
	Item.BecomePickup();
	Item.NetPriority = 2.5;
	Item.bCollideWorld = true;
	if (Pawn(Item.Owner) != None)
	{
		Pawn(Item.Owner).DeleteInventory(Item);
	}
	Item.Inventory = None;
	Item.GotoState('PickUp', 'Dropped');
	
	return true;
}

function bool DroneWeaponIsGrenade()
{
	local DeusExWeapon DXW;
	
	DXW = FirstWeapon();
	if (DXW != None)
	{
		switch(DXW.Class.Name)
		{
			case 'WeaponEMPGrenade':
			case 'WeaponGasGrenade':
			case 'WeaponLAM':
			case 'WeaponNanovirusGrenade':
			
			case 'WeaponHCEMPGrenade':
			case 'WeaponHCHCGasGrenade':
			case 'WeaponHCLAM':
			case 'WeaponHCNanoVirusGrenade':
				return true;
			break;
		}
		
		if (DXW.bDroneGrenadeWeapon)
		{
			return true;
		}
	}
	
	return false;
}

function VMDDumpSuicideGrenade(DeusExWeapon DXW)
{
	local class<ThrownProjectile> TPC;
	local ThrownProjectile TP;
	
	if ((DXW != None) && (!DXW.bInstantHit) && (DXW.bHandToHand) && (DXW.ReloadCount == 1))
	{
		TPC = class<ThrownProjectile>(DXW.ProjectileClass);
		if (TPC != None)
		{
			TP = Spawn(TPC, Self,, Location + ( (vect(1.2,0,0) * (CollisionRadius + TPC.Default.CollisionRadius)) >> Rotation ));
			if (TP != None)
			{
				TP.TakeDamage(1, Self, TP.Location, vect(0,0,0), 'Shot');
				DXW.Destroy();
			}
		}
	}
}

function ReturnToItem()
{
	local VMDMeghPickup TPick;
	
	if (!FastTrace(Location-vect(0,0,12), Location)) return;
	
	VMDMeghDropWeapon();
	VMDMeghDropSyringe();
	
	VMDCleanFakeDroneActors();
	
	TPick = Spawn(class'VMDMeghPickup',,, Location, Rotation);
	if (TPick != None)
	{
		TPick.CustomName = CustomName;
		TPick.DroneHealth = Health;
		TPick.DroneEMPHealth = EMPHitPoints;
		TPick.bDroneHealthBuff = bHealthBuffed;
		TPick.bDroneHealing = bCanHeal;
		TPick.bDroneReconMode = bReconMode;
		TPick.UpdateDroneSkins();
		Destroy();
	}
}

function UpdateTalentEffects(VMDBufferPlayer VMP)
{
	local bool bForceReconState, NewbReconMode;
	local VMDMEGH TMegh;
	local VMDSIDD TSidd, LastSIDD;
	
	forEach AllActors(class'VMDSidd', TSidd)
	{
		if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			bForceReconState = true;
			NewbReconMode = TSidd.bReconMode;
			LastSIDD = TSidd;
			break;
		}
	}
	
	if (bForceReconState)
	{
		bReconMode = NewbReconMode;
		if (bReconMode)
		{
			CacheAlliances();
		}
		else
		{
			UncacheAlliances();
		}
		SetupWeapon(!bReconMode, true);
		
		if (LastSIDD != None)
		{
			MatchAlliances(LastSIDD);
		}	
	}
	
	if ((VMP != None) && (EMPHitPoints > 0))
	{
		BaseAccuracy = -0.25;
     		GroundSpeed = 250;
     		WaterSpeed = 250;
     		AirSpeed = 250;
		if (VMP.HasSkillAugment('TagTeamMeleeSkillware'))
		{
			bMeleeBuff = true;
     			SpeechTargetAcquired = Sound'VMDMeghBritTargetAcquired';
     			SpeechTargetLost = Sound'VMDMeghBritTargetLost';
     			SpeechOutOfAmmo = Sound'VMDMeghBritOutOfAmmo';
     			SpeechCriticalDamage = Sound'VMDMeghBritCriticalDamage';
     			SpeechScanning = Sound'VMDMeghBritScanningArea';
		}
		
		if (VMP.HasSkillAugment('TagTeamSkillware'))
		{
			BaseAccuracy = -0.5;
     			GroundSpeed = 300;
     			WaterSpeed = 300;
     			AirSpeed = 300;
		}
		
		bCanHack = false;
		if (VMP.HasSkillAugment('TagTeamLiteHack'))
		{
			bCanHack = true;
		}
		
		if (VMDGetMissionNumber() < 5)
		{
			if ((VMP.HasSkillAugment('ElectronicsDroneArmor')) && (!bHealthBuffed))
			{
				Health += 50;
				EMPHitPoints += 200;
				
				if (VMDMayhemEnabled())
				{
					Health *= 2;
					EMPHitPoints *= 2;
				}
				
				bHealthBuffed = true;
			}
		}
		else
		{
			if ((VMP.HasSkillAugment('ElectronicsDroneArmor')) && (!bHealthBuffed))
			{
				Health += 100;
				EMPHitPoints += 200;
				
				if (VMDMayhemEnabled())
				{
					Health *= 2;
					EMPHitPoints *= 2;
				}
				
				bHealthBuffed = true;
			}
		}
		
		bCanHeal = false;
		if (VMP.HasSkillAugment('TagTeamMedicalSyringe'))
		{
			bCanHeal = true;
		}
		
		if (!bHealthBuffed)
		{
			Multiskins[0] = Texture'VMDMeghTex01';
			Multiskins[1] = Texture'VMDMeghTex02';
			Multiskins[3] = Texture'VMDMeghTex04';
			Multiskins[4] = Texture'VMDMeghTex05';
		}
		else
		{
			//Lower, heavier pitch blade for heavier fan.
			SoundPitch = 56;
			
			Multiskins[0] = Texture'VMDMeghTex01Heavy';
			Multiskins[1] = Texture'VMDMeghTex02Heavy';
			Multiskins[3] = Texture'VMDMeghTex04Heavy';
			Multiskins[4] = Texture'VMDMeghTex05Heavy';
		}
		
		EMPHitPoints = Clamp(EMPHitPoints, 1, VMDGetMaxEMPHitPoints());
	}
	
	if (VMDGetMissionNumber() < 5)
	{
		if (!bHealthBuffed)
		{
			StartingHealthValues[6] = 25;
		}
		else
		{
			StartingHealthValues[6] = 75;
		}
	}
	else
	{
		if (!bHealthBuffed)
		{
			StartingHealthValues[6] = 50;
		}
		else
		{
			StartingHealthValues[6] = 150;
		}
	}
	
	UpdateSensitiveMap();
	UpdateHackAlliances();
}

//MADDERS, 8/29/22: Update our model to match our weapon.
function UpdateWeaponModel()
{
	local DeusExWeapon DXW;
	local Inventory TInv;
	
	DXW = FirstWeapon();
	
	if (DXW == None)
	{
		Mesh = LODMesh'VMDHelidronePistol';
		return;
	}
	
	switch(DXW.Class.Name)
	{
		case 'WeaponBaton':
			Mesh = LODMesh'VMDHelidroneBaton';
		break;
		case 'WeaponCombatKnife':
			Mesh = LODMesh'VMDHelidroneCombatKnife';
		break;
		case 'WeaponHideAGun':
			Mesh = LODMesh'VMDHelidroneHideAGun';
		break;
		case 'WeaponMiniCrossbow':
			Mesh = LODMesh'VMDHelidroneMiniCrossbow';
		break;
		case 'WeaponPeppergun':
			Mesh = LODMesh'VMDHelidronePeppergun';
		break;
		case 'WeaponPistol':
			Mesh = LODMesh'VMDHelidronePistol';
		break;
		case 'WeaponSawedOffShotgun':
			Mesh = LODMesh'VMDHelidroneSawedOffShotgun';
		break;
		case 'WeaponStealthPistol':
			Mesh = LODMesh'VMDHelidroneStealthPistol';
		break;
		case 'WeaponLAM':
		case 'WeaponEMPGrenade':
		case 'WeaponScramblerGrenade':
		case 'WeaponGasGrenade':
		
		case 'WeaponHCEMPGrenade':
		case 'WeaponHCHCGasGrenade':
		case 'WeaponHCLAM':
		case 'WeaponHCNanoVirusGrenade':
		default:
			Mesh = LODMesh'VMDHelidroneGrenade';
		break;
	}
	
	MaxRange = GetDroneWeaponMaxRange();
	MinRange = GetDroneWeaponMinRange();
	SetWeapon(DXW);
	
	SetupWeapon(!bReconMode, true);
}

function int GetDroneWeaponMaxRange()
{
	local DeusExWeapon DXW;
	
	DXW = FirstWeapon();
	if (DXW == None) return 10;
	
	switch(DXW.Class.Name)
	{
		case 'WeaponBaton':
			return DXW.MaxRange * 0.8;
		break;
		case 'WeaponCombatKnife':
			return DXW.MaxRange * 0.8;
		break;
		case 'WeaponHideAGun':
			return 400;
		break;
		case 'WeaponMiniCrossbow':
			return 400;
		break;
		case 'WeaponPeppergun':
			return 160;
		break;
		case 'WeaponPistol':
			return 640;
		break;
		case 'WeaponSawedOffShotgun':
			return 480;
		break;
		case 'WeaponStealthPistol':
			return 480;
		break;
		case 'WeaponLAM':
		case 'WeaponEMPGrenade':
		case 'WeaponScramblerGrenade':
		case 'WeaponGasGrenade':
		
		case 'WeaponHCEMPGrenade':
		case 'WeaponHCHCGasGrenade':
		case 'WeaponHCLAM':
		case 'WeaponHCNanoVirusGrenade':
			return 24;
		break;
		default:
			return DXW.DroneMaxRange;
		break;
	}
	
	return 10;
}

function int GetDroneWeaponMinRange()
{
	local DeusExWeapon DXW;
	
	DXW = FirstWeapon();
	if ((DXW != None) && (DXW.bDroneCapableWeapon))
	{
		return DXW.DroneMinRange;
	}
	
	return 0;
}

function MEGHIssueOrder(name NewOrderName, Actor NewOrderActor, optional Actor NewSecondaryOrderActor, optional bool bDontWipe)
{
	local bool bLockOrderActor, bEngageOrderActor;
	
	if (!bDontWipe)
	{
		LiteHackTarget = None;
		DestroyOtherActor = None;
		DestroyOtherPawn = None;
		OppressTarget = None;
		GuardedOther = None;
		MEGHLastEnemy = None;
		LastMEGHPatrolPoint = None;
	}
	
	switch(NewOrderName)
	{
		case 'Attacking':
			if (ScriptedPawn(NewOrderActor) == None)
			{
				return;
			}
			bLockOrderActor = true;
			bEngageOrderActor = true;
		break;
		case 'DestroyingOther':
			if (ScriptedPawn(NewOrderActor) == None)
			{
				return;
			}
			DestroyOtherPawn = ScriptedPawn(NewOrderActor);
			DestroyOtherActor = NewSecondaryOrderActor;
			bLockOrderActor = true;
			bEngageOrderActor = true;
		break;
		case 'GuardingOther':
		case 'HealingGuardedOther':
			bLockOrderActor = true;
			GuardedOther = VMDBufferPawn(NewOrderActor);
		break;
		case 'HealingOther':
		case 'RunningTo':
			bLockOrderActor = true;
			SetEnemy(None);
		break;
		case 'Litehacking':
			bLockOrderActor = true;
		break;
		case 'MEGHFollowing':
			bLockOrderActor = true;
			SetEnemy(None);
			MEGHLastEnemy = ScriptedPawn(NewSecondaryOrderActor);
		break;
		case 'MEGHPatrolling':
			LastMEGHPatrolPoint = VMDFakePatrolPoint(NewOrderActor);
			bLockOrderActor = true;
			SetEnemy(None);
		break;
		case 'Oppressing':
			if (ScriptedPawn(NewOrderActor) == None)
			{
				return;
			}
			OppressTarget = VMDBufferPawn(NewOrderActor);
			bLockOrderActor = true;
			bEngageOrderActor = true;
		break;
	}
	
	if (bLockOrderActor) OrderActor = NewOrderActor;
	SetOrders(NewOrderName,, true);
	if (bLockOrderActor) OrderActor = NewOrderActor;
	
	if (bEngageOrderActor)
	{
		SetEnemy(ScriptedPawn(NewOrderActor));
	}
	
	UpdateMEGHAlliance();
}

function UpdateMEGHAlliance()
{
	Alliance = 'PlayerDrone';
	if ((IsInState('MEGHPatrolling')) && (!bReconMode))
	{
		Alliance = 'Player';
	}
}

function FollowOrders(optional bool bDefer)
{
	local bool bSetEnemy;
	local bool bUseOrderActor;

	if (Orders != '')
	{
		if ((Orders == 'Fleeing') || (Orders == 'Attacking') || 
			/*(Orders == 'DestroyingOther') ||*/ (Orders == 'Oppressing'))
		{
			bSetEnemy      = true;
			bUseOrderActor = true;
		}
		else if ((Orders == 'WaitingFor') || (Orders == 'GoingTo') ||
		         (Orders == 'RunningTo') || (Orders == 'Following') ||
		         (Orders == 'Sitting') || (Orders == 'Shadowing') ||
		         (Orders == 'DebugFollowing') || (Orders == 'DebugPathfinding') ||
			
			(Orders == 'GuardingOther') || (Orders == 'MeghFollowing') || 
			(Orders == 'MeghPatrolling') || (Orders == 'HealingOther') ||
			(Orders == 'LiteHacking'))
		{
			bSetEnemy      = false;
			bUseOrderActor = true;
		}
		else
		{
			bSetEnemy      = false;
			bUseOrderActor = false;
		}
		if (bUseOrderActor)
		{
			FindOrderActor();
			if (bSetEnemy)
				SetEnemy(Pawn(OrderActor), 0, true);
		}
		if (bDefer)  // hack
			SetState(Orders);
		else
			GotoState(Orders);
	}
	else
	{
		if (bDefer)
			SetState('Wandering');
		else
			GotoState('Wandering');
	}
}

// ----------------------------------------------------------------------
// GetPawnWeaponRanges()
// ----------------------------------------------------------------------

function GetPawnWeaponRanges(Pawn other, out float minRange, out float maxAccurateRange, out float maxRange)
{
	local DeusExWeapon            pawnWeapon;
	local Class<DeusExProjectile> projectileClass;
	
	pawnWeapon = DeusExWeapon(other.Weapon);
	if (pawnWeapon != None)
	{
		pawnWeapon.GetWeaponRanges(minRange, maxAccurateRange, maxRange);
		
		if (IsThrownWeapon(pawnWeapon))  // hack
		{
			minRange = 0;
		}
		else if ((Other == Self) && (projectileClass != None) && (ShieldDamage(projectileClass.Default.DamageType) < 1))
		{
			minRange *= ShieldDamage(projectileClass.Default.DamageType); // Transcended - Sacrifice some health for more consistent firing
		}
	}
	else
	{
		minRange         = 0;
		maxAccurateRange = other.CollisionRadius;
		maxRange         = maxAccurateRange;
	}
	
	if (maxAccurateRange > maxRange)
		maxAccurateRange = maxRange;
	if (minRange > maxRange)
		minRange = maxRange;
	
	MinRange = GetDroneWeaponMinRange();
	MaxRange = GetDroneWeaponMaxRange()*2;
	MaxAccurateRange = GetDroneWeaponMaxRange()*1;
}

// ----------------------------------------------------------------------
// GetWeaponBestRange()
// ----------------------------------------------------------------------

function GetWeaponBestRange(DeusExWeapon dxWeapon, out float bestRangeMin, out float bestRangeMax)
{
	local float temp;
	local float minRange,   maxRange;
	local float AIMinRange, AIMaxRange;
	
	if (dxWeapon != None)
	{
		dxWeapon.GetWeaponRanges(minRange, maxRange, temp);
		if (IsThrownWeapon(dxWeapon))  // hack
			minRange = 0;
		AIMinRange = dxWeapon.AIMinRange;
		AIMaxRange = dxWeapon.AIMaxRange;

		if ((AIMinRange > 0) && (AIMinRange >= minRange) && (AIMinRange <= maxRange))
			bestRangeMin = AIMinRange;
		else
			bestRangeMin = minRange;
		if ((AIMaxRange > 0) && (AIMaxRange >= minRange) && (AIMaxRange <= maxRange))
			bestRangeMax = AIMaxRange;
		else
			bestRangeMax = maxRange;

		if (bestRangeMin > bestRangeMax)
			bestRangeMin = bestRangeMax;
	}
	else
	{
		bestRangeMin = 0;
		bestRangeMax = 0;
	}
	
	BestRangeMin = GetDroneWeaponMaxRange();
	BestRangeMax = GetDroneWeaponMinRange();
}

function bool AISafeToShoot(out Actor hitActor, vector traceEnd, vector traceStart, optional vector extent, optional bool bIgnoreLevel)
{
	local Actor            traceActor;
	local Vector           hitLocation;
	local Vector           hitNormal;
	local Pawn             tracePawn;
	local DeusExDecoration traceDecoration;
	local DeusExMover      traceMover;
	local bool             bSafe;
	local float TPen, NeededPen;
	local Vector PenBoxMin, PenBoxMax;
	
	// Future improvement:
	// Ideally, this should use the ammo type to determine how many shots
	// it will take to destroy an obstruction, and call it unsafe if it takes
	// more than x shots.  Also, if the ammo is explosive, and the
	// obstruction is too close, it should never be safe...
	
	bSafe    = true;
	hitActor = None;
	
	foreach TraceActors(Class'Actor', traceActor, hitLocation, hitNormal, traceEnd, traceStart, extent)
	{
		if (hitActor == None)
			hitActor = traceActor;
		if (traceActor == Level)
		{
			if (!bIgnoreLevel)
				bSafe = false;
			break;
		}
		tracePawn = Pawn(traceActor);
		if (tracePawn != None)
		{
			if (TracePawn == DestroyOtherPawn)
			{
				bSafe = true;
				break;
			}
			if (tracePawn != self)
			{
				if (GetPawnAllianceType(tracePawn) != ALLIANCE_Hostile)
					bSafe = false;
				break;
			}
		}
		traceDecoration = DeusExDecoration(traceActor);
		if (traceDecoration != None)
		{
			if (TraceDecoration == DestroyOtherActor)
			{
				bSafe = true;
				break;
			}
			else if (((traceDecoration.bExplosive) && (VSize(traceDecoration.Location - Location) <= (traceDecoration.explosionRadius))) || traceDecoration.bInvincible)
			{
				bSafe = false;
				break;
			}
			/*if ((traceDecoration.HitPoints > 20) || (traceDecoration.minDamageThreshold > 4))  // hack
			{
				bSafe = false;
				break;
			}*/
			else if (DeusExWeapon(Weapon) == None)
			{
				bSafe = false;
				break;
			}
			else if ((DeusExWeapon(Weapon).ProjectileClass != None) && ((DeusExWeapon(Weapon).ProjectileClass.Default.Damage) < traceDecoration.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			else if ((DeusExWeapon(Weapon) != None) && ((DeusExWeapon(Weapon).Default.HitDamage) < traceDecoration.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
		}
		traceMover = DeusExMover(traceActor);
		if (traceMover != None)
		{
			//MADDERS: Modified, ported code, with the intent of letting us shoot through thin doors.
			if (DeusExWeapon(Weapon) != None)
			{
				//HACK: Use metal as the group so we assume ricochets are always possible.
				TPen = DeusExWeapon(Weapon).VMDGetMaterialPenetration(Level);
				if ((TPen > 0) && (DeusExWeapon(Weapon).VMDAngleMeansRicochet(HitLocation, HitLocation - TraceStart, HitNormal, 'Metal', TraceActor)))
				{
					TPen = 0;
				}
				
				TraceMover.GetBoundingBox(PenBoxMin, PenBoxMax, false, TraceMover.KeyPos[TraceMover.KeyNum]+TraceMover.BasePos, TraceMover.KeyRot[TraceMover.KeyNum]+TraceMover.BaseRot);
				//NeededPen = Abs(((PenBoxMin-TraceMover.BasePos) >> ViewRotation).X);
				NeededPen = Abs(((PenBoxMax-PenBoxMin) >> ViewRotation).X);
			}
			
			if ((!traceMover.bBreakable) && (TPen < NeededPen))
			{
				bSafe = false;
				break;
			}
			else if (DeusExWeapon(Weapon) == None)
			{
				bSafe = false;
				break;
			}
			else if ((DeusExWeapon(Weapon).ProjectileClass != None) && ((DeusExWeapon(Weapon).ProjectileClass.Default.Damage) < traceMover.minDamageThreshold))
			{
				bSafe = false;
				break;
			}
			/*else if (((traceMover.doorStrength > 0.2) || (traceMover.minDamageThreshold > 8)) && (TPen < NeededPen))  // hack
			{
				bSafe = false;
				break;
			}*/
			else if (DeusExWeapon(Weapon).Default.HitDamage < traceMover.minDamageThreshold && (TPen < NeededPen))
			{
				bSafe = false;
				break;
			}
			else  // hack
				break;
		}
		if (Inventory(traceActor) != None)
		{
			bSafe = false;
			break;
		}
	}

	return (bSafe);
}

// ----------------------------------------------------------------------
// CheckEnemyParams()  [internal use only]
// ----------------------------------------------------------------------

function CheckEnemyParams(Pawn checkPawn, out Pawn bestPawn, out int bestThreatLevel, out float bestDist)
{
	local ScriptedPawn sPawn;
	local bool         bReplace;
	local float        dist;
	local int          threatLevel;
	local bool         bValid;
	
	local DeusExWeapon DXWeapon;
	
	DXWeapon = DeusExWeapon(Weapon);

	bValid = IsValidEnemy(checkPawn);
	if (bValid && (Enemy != checkPawn))
	{
		// Honor cloaking, radar transparency, and other augs if this guy isn't our current enemy
		if (ComputeActorVisibility(checkPawn) < 0.1)
			bValid = false;
	}

	if (bValid)
	{
		sPawn = ScriptedPawn(checkPawn);

		dist = VSize(checkPawn.Location - Location);
		if (checkPawn.IsA('Robot'))
			dist *= 0.5;  // arbitrary
		if (Enemy == checkPawn)
			dist *= 0.75;  // arbitrary

		if (sPawn != None)
		{
			if (sPawn.bAttacking)
			{
				if (sPawn.Enemy == self)
					threatLevel = 2;
				else
					threatLevel = 1;
			}
			else if (sPawn.GetStateName() == 'Alerting')
				threatLevel = 3;
			else if ((sPawn.GetStateName() == 'Fleeing') || (sPawn.GetStateName() == 'Burning'))
				threatLevel = 0;
			else if (sPawn.Weapon != None)
				threatLevel = 1;
			else
				threatLevel = 0;
			
			if (DXWeapon != None)
			{
				if ((DXWeapon.WeaponDamageType() == 'TearGas') && (SPawn.bStunned || (VMDBufferPawn(SPawn) != None && VMDBufferPawn(SPawn).bAerosolImmune)))
				{
					ThreatLevel -= 1;
				}
				if ((DXWeapon.WeaponDamageType() == 'Poison') && (SPawn.PoisonCounter > 0))
				{
					ThreatLevel -= 3;
				}
			}
		}
		else  // player
		{
			if (checkPawn.Weapon != None)
				threatLevel = 2;
			else
				threatLevel = 1;
		}

		bReplace = false;
		if (bestPawn == None)
			bReplace = true;
		else if (bestThreatLevel < threatLevel)
			bReplace = true;
		else if (bestDist > dist)
			bReplace = true;

		if (bReplace)
		{
			if ((Enemy == checkPawn) || (AICanSee(checkPawn, , false, false, true, true) > 0))
			{
				bestPawn        = checkPawn;
				bestThreatLevel = threatLevel;
				bestDist        = dist;
			}
		}
	}

}

// ----------------------------------------------------------------------
// AICanShoot()
// ----------------------------------------------------------------------

function bool AICanShoot(pawn target, bool bLeadTarget, bool bCheckReadiness, optional float throwAccuracy, optional bool bDiscountMinRange)
{
	local DeusExWeapon dxWeapon;
	local Vector X, Y, Z;
	local Vector projStart, projEnd;
	local float  tempMinRange, tempMaxRange;
	local float  temp;
	local float  dist;
	local float  extraDist;
	local actor  hitActor;
	local Vector hitLocation, hitNormal;
	local Vector extent;
	local bool   bIsThrown;
	local float  elevation;
	local bool   bSafe;
	
	if (DroneWeaponIsGrenade())
	{
		return true;
	}
	
	if (target == None)
		return false;
	if (target.bIgnore)
		return false;

	dxWeapon = DeusExWeapon(Weapon);
	if (dxWeapon == None)
		return false;
	if ((bCheckReadiness) && (!dxWeapon.bReadyToFire))
		return false;
	
	if ((DXWeapon.WeaponDamageType() == 'TearGas') && (VMDBufferPawn(Target) != None) && (ScriptedPawn(Target).bStunned || VMDBufferPawn(Target).bAerosolImmune))
	{
		FindBestEnemy(false);
		return false;
	}
	if ((DXWeapon.WeaponDamageType() == 'Poison') && (ScriptedPawn(Target) != None) && (ScriptedPawn(Target).PoisonCounter > 0))
	{
		FindBestEnemy(false);
		return false;
	}
	
	if (dxWeapon.ReloadCount > 0)
	{
		if (dxWeapon.AmmoType == None)
			return false;
		if (dxWeapon.AmmoType.AmmoAmount <= 0)
			return false;
	}
	if (FireElevation > 0)
	{
		elevation = FireElevation + (CollisionHeight+target.CollisionHeight);
		if (elevation < 10)
			elevation = 10;
		if (Abs(Location.Z-target.Location.Z) > elevation)
			return false;
	}
	bIsThrown = IsThrownWeapon(dxWeapon);

	extraDist = target.CollisionRadius;
	//extraDist = 0;

	GetPawnWeaponRanges(self, tempMinRange, tempMaxRange, temp);

	if (bDiscountMinRange)
		tempMinRange = 0;

	if (tempMinRange >= tempMaxRange)
		return false;

	ViewRotation = Rotation;
	GetAxes(ViewRotation, X, Y, Z);
	projStart = dxWeapon.ComputeProjectileStart(X, Y, Z);
	if (bLeadTarget && !dxWeapon.bInstantHit && (dxWeapon.ProjectileSpeed > 0))
	{
		if (bIsThrown)
		{
			// compute target's position 1.5 seconds in the future
			projEnd = target.Location + (target.Velocity*1.5);
		}
		else
		{
			// projEnd = target.Location + (target.Velocity*dist/dxWeapon.ProjectileSpeed);
			if (!ComputeTargetLead(target, projStart, dxWeapon.ProjectileSpeed,
			                       5.0, projEnd))
				return false;
		}
	}
	else
		projEnd = target.Location;

	if (bIsThrown)
		projEnd += vect(0,0,-1)*(target.CollisionHeight-5);

	dist = VSize(projEnd - Location);
	if (dist < 0)
		dist = 0;

	if ((dist < tempMinRange) || (dist-extraDist > tempMaxRange))
		return false;
	
	//MADDERS: Ported code for shooting through select movers. We'll be using this for wall banging.
    	if (!bIsThrown)
    	{
        	bSafe = FastTrace(target.Location, projStart);
        	if (!bSafe)
            		bSafe = AISafeToShoot(hitActor, target.Location, projStart);
        	if ((!bSafe) && (target.bIsPlayer))  // players only... hack
        	{
            		projEnd += vect(0,0,1)*target.BaseEyeHeight;
            		//bSafe = FastTrace(target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
            		bSafe = AISafeToShoot(hitActor, target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
        	}
        	if (!bSafe)
            		return false;
    	}
	/*if (!bIsThrown)
	{
		bSafe = FastTrace(target.Location, projStart);
		if ((!bSafe) && (target.bIsPlayer))  // players only... hack
		{
			projEnd += vect(0,0,1)*target.BaseEyeHeight;
			bSafe = FastTrace(target.Location + vect(0,0,1)*target.BaseEyeHeight, projStart);
		}
		if (!bSafe)
			return false;
	}*/

	if (dxWeapon.bInstantHit)
		return (AISafeToShoot(hitActor, projEnd, projStart, , true));
	else
	{
		if (dxWeapon.ProjectileClass != None)
		{
			extent.X = dxWeapon.ProjectileClass.default.CollisionRadius;
			extent.Y = dxWeapon.ProjectileClass.default.CollisionRadius;
			extent.Z = dxWeapon.ProjectileClass.default.CollisionHeight;
		}
		if ((bIsThrown) && (throwAccuracy > 0))
		{
			return (AISafeToThrow(projEnd, projStart, throwAccuracy, extent));
		}
		else
		{
			return (AISafeToShoot(hitActor, projEnd, projStart, extent*3));
		}
	}
}

// ----------------------------------------------------------------------
// SetupWeapon()
// ----------------------------------------------------------------------

function SetupWeapon(bool bDrawWeapon, optional bool bForce)
{
	if ((bKeepWeaponDrawn || !bReconMode) && (!bForce))
	{
		bDrawWeapon = true;
	}
	if ((bReconMode) && (bDrawWeapon))
	{
		bDrawWeapon = false;
	}
	
	if (bDrawWeapon)
	{
		SwitchToBestWeapon();
	}
	else
	{
		SetWeapon(None);
	}
}

function bool AddReconTarget(ScriptedPawn NewEnemy)
{
	local int i;
	
	if (NewEnemy == None) return false;
	if (!VMDCanBeMEGHEnemy(NewEnemy)) return false;
	
	if (NumReconTargets < ArrayCount(ReconTargets))
	{
		for(i=0; i<NumReconTargets; i++)
		{
			if (NewEnemy == ReconTargets[i])
			{
				return false;
			}
		}
		
		ReconTargets[NumReconTargets] = NewEnemy;
		NumReconTargets++;
		
		return true;
	}
	return false;
}

function GiveReconPulse()
{
	local bool bPaved;
	local int i, j, HighestValid;
	local float GSpeed;
	local Pawn TPawn;
	
	local ScriptedPawn SP;
	local VMDBufferPlayer RenderPlayer;
	local VMDFakeRadarMarker RadarMark, LastMark;
	
	ForEach AllActors(class'VMDBufferPlayer', RenderPlayer) break;
	if (RenderPlayer == None) return;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		SP = ScriptedPawn(TPawn);
		if ((SP != None) && (SP.GetPawnAllianceType(RenderPlayer) == ALLIANCE_Hostile) && (FastTrace(SP.Location, Location)) && (AICanSee(orderActor, , false, false, false, true) > 0))
		{
			if (AddReconTarget(SP))
			{
				if (ReconPingSoundTimer <= 0)
				{
					if (RenderPlayer.bMEGHRadarPing)
					{
						RenderPlayer.PlaySound(Sound'Beep5', SLOT_None, 0.6,, 2048, GSpeed);
					}
					ReconPingSoundTimer = 0.75;
				}
			}
		}
	}
	
	For (i=0; i<ArrayCount(ReconTargets); i++)
	{
		if ((ReconTargets[i] != None) && (!ReconTargets[i].bDeleteMe) && (!ReconTargets[i].IsInState('Dying')) && (!ReconTargets[i].IsA('VMDMegh')) && (!ReconTargets[i].IsA('VMDSidd')) && (FastTrace(ReconTargets[i].Location, Location)))
		{
			HighestValid = i;
			RadarMark = Spawn(class'VMDFakeRadarMarker',,, ReconTargets[i].Location);
			if (RadarMark != None)
			{
				RadarMark.bPlayerAlly = (ReconTargets[i].GetPawnAllianceType(RenderPlayer) != ALLIANCE_Hostile);
				RadarMark.RenderPlayer = RenderPlayer;
				RadarMark.ReconTarget = ReconTargets[i];
				if (LastMark != None)
				{
					LastMark.NextMark = RadarMark;
				}
				else
				{
					RenderPlayer.FirstRadarMark = RadarMark;
				}
				LastMark = RadarMark;
			}
		}
		else
		{
			For (j=i+1; j<ArrayCount(ReconTargets); j++)
			{
				if ((ReconTargets[j] != None) && (FastTrace(ReconTargets[j].Location, Location)))
				{
					bPaved = true;
					ReconTargets[i] = ReconTargets[j];
					ReconTargets[j] = None;
					j--;
					break;
				}
			}
			if (!bPaved)
			{
				ReconTargets[i] = None;
			}
		}
	}
	
	NumReconTargets = HighestValid+1;
}

function HealOtherPawn(Pawn TarPawn)
{
	local int THeal, i;
	local float GSpeed;
	local MedigelAura MGA;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(TarPawn);
	if ((VMDBufferPawn(TarPawn) == None) && (VMP == None)) return;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if (VMDBufferPawn(TarPawn) != None)
	{
		VMDBufferPawn(TarPawn).ReceiveMedicalHealing(75);
	}
	else
	{
		MGA = MedigelAura(VMP.FindInventoryType(class'MedigelAura'));
		if (MGA != None)
		{
			/*for (i=MGA.NumHeals; i<4; i++)
			{
				if (i < 3)
				{
					MGA.NumHeals++;
					THeal += 19;
				}
				else if (i == 3)
				{
					MGA.NumHeals++;
					THeal += 18;
				}
			}*/
			
			THeal = 15*(4-MGA.NumHeals);
			
			if (THeal > 0)
			{
				VMP.HealPlayer(THeal, False);
			}
			MGA.Destroy();
		}
		MGA = Spawn(class'MedigelAura');
		if (MGA != None)
		{
			MGA.Frob(VMP, None);
			MGA.Activate();
		}
	}
	bHasHeal = false;
	TarPawn.PlaySound(sound'MedicalHiss', SLOT_None,,, 768, 1.3 * GSpeed);
}

function LiteHackSecurityComputer(ComputerSecurity NewComp)
{
	local int cameraIndex;
	local name tag;
	local SecurityCamera camera;
   	local AutoTurret turret;
	
	if (NewComp == None) return;
	
	LiteHackComputer = NewComp;
	
	if (LiteHackComputer.AnimSequence != 'Activate')
	{
		LiteHackComputer.PlayAnim('Activate', 2.5);
	}
	
	for (cameraIndex=0; cameraIndex<ArrayCount(LiteHackComputer.Views); cameraIndex++)
	{
		tag = LiteHackComputer.Views[cameraIndex].cameraTag;
		if (tag != '')
		{
			foreach AllActors(class'SecurityCamera', camera, tag)
			{
				Camera.ConfusionTimer = 0;
				Camera.ConfusionDuration = 15;
				Camera.bConfused = true;
				Camera.MultiSkins[2] = Texture'YellowLightTex';
			}
		}
		tag = LiteHackComputer.Views[cameraIndex].turretTag;
		if (tag != '')
		{
			foreach AllActors(class'AutoTurret', turret, tag)
			{
				Turret.ConfusionTimer = 0;
				Turret.ConfusionDuration = 15;
				Turret.bConfused = true;
			}
		}
	}
	LiteHackRefreshTimer = 0;
}

function LiteHackModdedSecurityComputer(Actor NewComp)
{
	local int cameraIndex;
	local name tag;
  	local AutoTurret turret;
	local GraftedComputerSecurity GCS;
	local GraftedHCComputerSecurity GHCCS;
	local SecurityCamera camera;
 	
	if (NewComp == None) return;
	
	if (NewComp.IsA('HCComputerSecurity'))
	{
		GHCCS = AizomeHCFudgeCast(NewComp);
		
		if (GHCCS != None)
		{
			LiteHackTarget = NewComp;
			
			if (LiteHackTarget.AnimSequence != 'Activate')
			{
				LiteHackTarget.PlayAnim('Activate', 2.5);
			}
			
			for (cameraIndex=0; cameraIndex<ArrayCount(GHCCS.Views); cameraIndex++)
			{
				tag = GHCCS.Views[cameraIndex].cameraTag;
				if (tag != '')
				{
					foreach AllActors(class'SecurityCamera', camera, tag)
					{
						Camera.ConfusionTimer = 0;
						Camera.ConfusionDuration = 15;
						Camera.bConfused = true;
						Camera.MultiSkins[2] = Texture'YellowLightTex';
					}
				}
				tag = GHCCS.Views[cameraIndex].turretTag;
				if (tag != '')
				{
					foreach AllActors(class'AutoTurret', turret, tag)
					{
						Turret.ConfusionTimer = 0;
						Turret.ConfusionDuration = 15;
						Turret.bConfused = true;
					}
				}
			}
			LiteHackRefreshTimer = 0;
		}
	}
	else if (NewComp.IsA('RS_ComputerSecurity') || NewComp.IsA('MyComputerSecurity'))
	{
		GCS = AizomeFudgeCast(NewComp);
		
		if (GCS != None)
		{
			LiteHackTarget = NewComp;
			
			if (LiteHackTarget.AnimSequence != 'Activate')
			{
				LiteHackTarget.PlayAnim('Activate', 2.5);
			}
			
			for (cameraIndex=0; cameraIndex<ArrayCount(GCS.Views); cameraIndex++)
			{
				tag = GCS.Views[cameraIndex].cameraTag;
				if (tag != '')
				{
					foreach AllActors(class'SecurityCamera', camera, tag)
					{
						Camera.ConfusionTimer = 0;
						Camera.ConfusionDuration = 15;
						Camera.bConfused = true;
						Camera.MultiSkins[2] = Texture'YellowLightTex';
					}
				}
				tag = GCS.Views[cameraIndex].turretTag;
				if (tag != '')
				{
					foreach AllActors(class'AutoTurret', turret, tag)
					{
						Turret.ConfusionTimer = 0;
						Turret.ConfusionDuration = 15;
						Turret.bConfused = true;
					}
				}
			}
			
			LiteHackRefreshTimer = 0;
		}
	}
}

function StopLiteHacking()
{
	if (LiteHackComputer != None)
	{
		if (LiteHackComputer.AnimSequence == 'Activate')
		{
			LiteHackComputer.PlayAnim('Deactivate', 2.5);
		}
		LiteHackComputer = None;
	}
	else if (LiteHackTarget != None)
	{
		if (LiteHackTarget.AnimSequence == 'Activate')
		{
			LiteHackTarget.PlayAnim('Deactivate', 2.5);
		}
		LiteHackTarget = None;
	}
}

state LiteHackStanding expands Standing
{
	function EndState()
	{
		if (LiteHackComputer != None || LiteHackTarget != None)
		{
			StopLiteHacking();
		}
		
		Super.EndState();
	}
}


State Attacking
{
	function EDestinationType PickDestinationEnum()
	{
		local vector               distVect;
		local vector               tempVect;
		local rotator              enemyDir;
		local float                magnitude;
		local float                calcMagnitude;
		local int                  iterations;
		local EDestinationType     destType;
		local NearbyProjectileList projList;

		destPoint = None;
		destLoc   = vect(0, 0, 0);
		destType  = DEST_Failure;
		
		if ((Enemy != None) && (DroneWeaponIsGrenade()) && (FastTrace(Enemy.Location, Location)))
		{
			DestType = DEST_NewLocation;
			DestLoc = Enemy.Location;
		}
		
		if (enemy == None)
			return (destType);

		if (bCrouching && (CrouchTimer > 0))
			destType = DEST_SameLocation;

		if (destType == DEST_Failure)
		{
			if (AICanShoot(enemy, true, false, 0.025) || ActorReachable(enemy))
			{
				destType = ComputeBestFiringPosition(tempVect);
				if (destType == DEST_NewLocation)
					destLoc = tempVect;
			}
		}

		if (destType == DEST_Failure)
		{
			MoveTarget = FindPathToward(enemy);
			if (MoveTarget != None)
			{
				if (!bDefendHome || IsNearHome(MoveTarget.Location))
				{
					if (bAvoidHarm)
						GetProjectileList(projList, MoveTarget.Location);
					if (!bAvoidHarm || !IsLocationDangerous(projList, MoveTarget.Location))
					{
						destPoint = MoveTarget;
						destType  = DEST_NewLocation;
					}
				}
			}
		}

		// Default behavior, so they don't just stand there...
		if (destType == DEST_Failure)
		{
			enemyDir = Rotator(Enemy.Location - Location);
			if (AIPickRandomDestination(60, 150,
			                            enemyDir.Yaw, 0.5, enemyDir.Pitch, 0.5, 
			                            2, FRand()*0.4+0.35, tempVect))
			{
				if (!bDefendHome || IsNearHome(tempVect))
				{
					destType = DEST_NewLocation;
					destLoc  = tempVect;
				}
			}
		}

		return (destType);
	}
	
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
					//PlayOutOfAmmoSound();
					/*if (Orders == 'MeghPatrolling')
					{
						MEGHIssueOrder('MeghPatrolling', VMDFakePatrolPoint(LastMEGHPatrolPoint), None);
					}
					else
					{*/
						ClearPatrolPoints();
						MEGHIssueOrder('MeghFollowing', GetLastVMP(), Enemy);
					//}
					//SetNextState('Fleeing');
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
	
	function bool FireIfClearShot()
	{
		if (DroneWeaponIsGrenade())
		{
			return false;
		}
		
		return Super.FireIfClearShot();
	}
	
	function CheckAttack(bool bPlaySound)
	{
		local bool bCriticalDamage;
		local bool bOutOfAmmo, bNoWeapon;
		local Pawn oldEnemy;
		local bool bAllianceSwitch;
		
		//MADDERS, 9/14/22: Weird patch, but don't suicide bomb the player in very, very weird edge cases.
		if ((DroneWeaponIsGrenade()) && (ScriptedPawn(Enemy) != None) && (VSize(Enemy.Location - Location) < 64+Enemy.CollisionRadius))
		{
			VMDDumpSuicideGrenade(FirstWeapon());
		}
		
		oldEnemy = enemy;
		
		bAllianceSwitch = false;
		if (!IsValidEnemy(enemy))
		{
			if ((IsValidEnemy(enemy, false)) && (Robot(Enemy) == None || !Robot(Enemy).IsInState('Disabled')))
				bAllianceSwitch = true;
			SetEnemy(None, 0, true);
		}

		if (enemy == None)
		{
			if (Orders == 'Attacking' || Orders == 'Oppressing')
			{
				FindOrderActor();
				SetEnemy(Pawn(OrderActor), 0, true);
			}
		}
		if (ReadyForNewEnemy())
			FindBestEnemy(false);
		if (enemy == None)
		{
			Enemy = oldEnemy;  // hack
			if (bPlaySound)
			{
				if (bAllianceSwitch)
					PlayAllianceFriendlySound();
				else
					PlayAreaSecureSound();
			}
			Enemy = None;
			if ((Orders != 'Attacking') && (Orders != 'Oppressing'))
			{
				if ((Orders == 'MEGHPatrolling') && (!IsInState('MeghPatrolling')) && (LastMEGHPatrolPoint != None))
				{
					MEGHIssueOrder('MeghPatrolling', VMDFakePatrolPoint(LastMEGHPatrolPoint), None);
				}
				else
				{
					FollowOrders();
				}
			}
			else
			{
				GotoState('Wandering');
			}
			return;
		}

		SwitchToBestWeapon();
		if ((bCrouching) && (CrouchTimer <= 0) && (!ShouldCrouch()))
		{
			EndCrouch();
			TweenToShoot(0.15);
		}
		bCriticalDamage = False;
		bOutOfAmmo      = False;
		if (ShouldFlee())
		{
			bCriticalDamage = True;
		}
		else if (Weapon == None)
		{
			//MADDERS, 3/17/21: Don't do this anymore, as this gets weird with pickpocketing.
			//bOutOfAmmo = True;
			bNoWeapon = true;
		}
		else if (Weapon.ReloadCount > 0)
		{
			if (Weapon.AmmoType == None)
			{
				bOutOfAmmo = True;
			}
			else if (Weapon.AmmoType.AmmoAmount < 1)
			{
				bOutOfAmmo = True;
			}
		}
		else if (Weapon.AmmoName == Class'AmmoNone') // Transcended - Added
		{
			//MADDERS, 9/4/22: This is falsely tripping all the time.
			//PlayOutOfAmmoSound();
		}
		
		if (bCriticalDamage || bOutOfAmmo || bNoWeapon)
		{
			if (bPlaySound || bOutOfAmmo)
			{
				if (bCriticalDamage)
					PlayCriticalDamageSound();
				else if (bOutOfAmmo)
					//PlayOutOfAmmoSound();
			}
			if (RaiseAlarm == RAISEALARM_BeforeFleeing)
			{
				GotoState('Alerting');
			}
			else
			{
				PlayOutOfAmmoSound();
				/*if (Orders == 'MeghPatrolling')
				{
					MEGHIssueOrder('MeghPatrolling', VMDFakePatrolPoint(LastMEGHPatrolPoint), None);
				}
				else
				{*/
					ClearPatrolPoints();
					MEGHIssueOrder('MeghFollowing', GetLastVMP(), Enemy);
				//}
				//GotoState('Fleeing');
			}
		}
		else if ((bPlaySound) && (oldEnemy != Enemy))
			PlayNewTargetSound();
	}
}

// ----------------------------------------------------------------------
// state Following
//
// Follow an actor. Also, guarding version.
// ----------------------------------------------------------------------

state MeghFollowing expands Following
{
	function SetFall()
	{
		StartFalling('MeghFollowing', 'ContinueFollow');
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
	
	function Tick(float deltaSeconds)
	{
		local float TDist;
		local Vector TLoc;
		local DeusExPlayer DXP;
		
		Global.Tick(deltaSeconds);
		
		LipSynchBarks(deltaSeconds);
		
		if (BackpedalTimer >= 0)
		{
			BackpedalTimer += deltaSeconds;
		}
		
		animTimer[1] += deltaSeconds;
		if ((Physics == PHYS_Walking) && (orderActor != None))
		{
			if (Acceleration == vect(0,0,0))
			{
				LookAtActor(orderActor, true, true, true, 0, 0.25);
			}
			else
			{
				PlayTurnHead(LOOK_Forward, 1.0, 0.25);
			}
		}
	}
	
	function bool PickDestinationBool()
	{
		local float   dist;
		local float   extra;
		local float   distMax;
		local int     dir;
		local rotator rot;
		local bool    bSuccess;
		
		local DeusExPlayer DXP;
		
		bSuccess = false;
		destPoint = None;
		destLoc = vect(0, 0, 0);
		extra = orderActor.CollisionRadius + CollisionRadius;
		dist = VSize(orderActor.Location - Location);
		dist -= extra;
		if (dist < 0)
		{
			dist = 0;
		}
		
		PathOverrideHackLoc = vect(0,0,0);
		
		DXP = DeusExPlayer(OrderActor);
		
		//MADDERS, 8/29/22: Fuck doors. Sincerely: ~MEGH
		if (bDoorGhosting)
		{
			BackpedalTimer = -1;
			return true;
		}
		
		//MADDERS, 8/29/22: Hack. Don't follow into water, please.
		if (DXP != None)
		{
			if ((DXP.Region.Zone != None) && (DXP.Region.Zone.bWaterZone))
			{
				BackpedalTimer = -1;
				
				//Are we on an elevator, in line of sight?
				if (AICanSee(orderActor, , false, false, false, true) > 0)
				{
					//MADDERS, 8/29/22: Move closer, to get on the elevator.
					PathOverrideHackLoc = DXP.Location;
				}
				return false;
			}
			//Are we on an elevator, in line of sight?
			if ((VMDPlayerIsOnElevator(DXP)) && (AICanSee(orderActor, , false, false, false, true) > 0))
			{
				BackpedalTimer = -1;
				
				//MADDERS, 8/29/22: Move closer, to get on the elevator.
				PathOverrideHackLoc = DXP.Location;
				
				return false;
			}
		}
		
		if ((dist > 180) || (AICanSee(orderActor, , false, false, false, true) <= 0))
		{
			if (ActorReachable(orderActor))
			{
				rot = Rotator(orderActor.Location - Location);
				distMax = (dist-180)+45;
				if (distMax > 80)
				{
					distMax = 80;
				}
				bSuccess = AIDirectionReachable(Location, rot.Yaw, rot.Pitch, 0, distMax, destLoc);
			}
			else
			{
				MoveTarget = FindPathToward(orderActor);
				if (MoveTarget != None)
				{
					destPoint = MoveTarget;
					bSuccess = true;
				}
			}
			BackpedalTimer = -1;
		}
		else if (dist < 60)
		{
			if ((VMDPlayerIsOnElevator(DXP)) && (DXP.bDuck > 0 || DXP.bForceDuck))
			{
				if (dist < 32)
				{
					//MADDERS, 8/29/22: We win?
				}
				else
				{
					if (AICanSee(orderActor, , false, false, false, true) > 0)
					{
						//MADDERS, 8/29/22: Move closer, to get on the elevator.
						PathOverrideHackLoc = DXP.Location;
					}
				}
			}
			else
			{
				if (BackpedalTimer < 0)
				{
					BackpedalTimer = 0;
				}
				if (BackpedalTimer > 1.0)  // give the player enough time to converse, if he wants to
				{
					rot = Rotator(Location - orderActor.Location);
					bSuccess = AIDirectionReachable(orderActor.Location, rot.Yaw, rot.Pitch, 60+extra, 120+extra, destLoc);
				}
			}
		}
		else
		{
			BackpedalTimer = -1;
		}
		
		return (bSuccess);
	}
	
	function BeginState()
	{
		StandUp();
		//Disable('AnimEnd');
		bStasis = False;
		SetupWeapon(false);
		SetDistress(false);
		BackpedalTimer = -1;
		SeekPawn = None;
		EnableCheckDestLoc(true);
		
		PathingFailures = 0;
		PathingFailures2 = 0;
		
		if ((GuardedOther != None) && (!GuardedOther.bDeleteMe))
		{
			MEGHIssueOrder('GuardingOther', GuardedOther,, true);
		}
	}
	
	function EndState()
	{
		EnableCheckDestLoc(false);
		bAcceptBump = False;
		//Enable('AnimEnd');
		bStasis = True;
		StopBlendAnims();
		
		PathingFailures = 0;
		PathingFailures2 = 0;
	}
	
Begin:
	Acceleration = vect(0, 0, 0);
	destPoint = None;
	
	if (orderActor == None)
	{
		GotoState('Standing');
	}
	
	if (!PickDestinationBool())
	{
		Goto('Wait');
	}
	
Follow:
	if (DestPoint != None)
	{
		if (MoveTarget != None)
		{
			if (ShouldPlayWalk(MoveTarget.Location))
			{
				PlayRunning();
			}
			
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
		}
		else
		{
			Sleep(0.0);  // this shouldn't happen
		}
	}
	else
	{
		if (ShouldPlayWalk(DestLoc))
		{
			PlayRunning();
		}
		DestLoc.Z = Location.Z;
		MoveTo(destLoc, MaxDesiredSpeed);
		CheckDestLoc(DestLoc);
	}
	if (PickDestinationBool())
	{
		Goto('Follow');
		PathingFailures = 0;
	}
	else
	{
		PathingFailures++;
	}
Wait:
	//PlayTurning();
	//TurnToward(orderActor);
	PlayWaiting();
	
WaitLoop:
	Acceleration = vect(0,0,0);
	Sleep(0.0);
	if (!PickDestinationBool())
	{
		PathingFailures2++;
		Goto('WaitLoop');
	}
	else
	{
		PathingFailures2 = 0;
		Goto('Follow');
	}
	
ContinueFollow:
ContinueFromDoor:
	Acceleration = vect(0,0,0);
	if (PickDestinationBool())
	{
		Goto('Follow');
	}
	else
	{
		Goto('Wait');
	}
}

state GuardingOther expands MeghFollowing
{
	function SetFall()
	{
		StartFalling('GuardingOther', 'ContinueFollow');
	}
}

// ----------------------------------------------------------------------
// state RunningTo
//
// Just a slightly tricked out set of versions.
// ----------------------------------------------------------------------

state LiteHacking
{
	function SetFall()
	{
		StartFalling('LiteHacking', 'ContinueRun');
	}
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	function Bump(actor bumper)
	{
		// If we hit the guy we're going to, end the state
		if (bumper == OrderActor)
			GotoState('LiteHacking', 'Done');
		
		// Handle conversations, if need be
		Global.Bump(bumper);
	}
	function Touch(actor toucher)
	{
		// If we hit the guy we're going to, end the state
		if (toucher == OrderActor)
			GotoState('LiteHacking', 'Done');
		
		// Handle conversations, if need be
		Global.Touch(toucher);
	}
	function BeginState()
	{
		StandUp();
		//BlockReactions();
		SetupWeapon(false);
		SetDistress(false);
		bStasis = False;
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}
	function EndState()
	{
		EnableCheckDestLoc(false);
		//ResetReactions();
		bStasis = True;
	}

Begin:
	Acceleration = vect(0, 0, 0);
	if (orderActor == None)
		Goto('Done');

Follow:
	if (IsOverlapping(orderActor))
		Goto('Done');
	MoveTarget = GetNextWaypoint(orderActor);
	if ((MoveTarget != None) && (!MoveTarget.Region.Zone.bWaterZone) &&
	    (MoveTarget.Physics != PHYS_Falling))
	{
		if ((MoveTarget == orderActor) && MoveTarget.IsA('Pawn'))
		{
			if (GetNextVector(orderActor, useLoc))
			{
				if (ShouldPlayWalk(useLoc))
					PlayRunning();
				MoveTo(useLoc, MaxDesiredSpeed);
				CheckDestLoc(useLoc);
			}
			else
				Goto('Pause');
		}
		else
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
		}
		if (IsOverlapping(orderActor))
			Goto('Done');
		else
			Goto('Follow');
	}

Pause:
	Acceleration = vect(0, 0, 0);
	TurnToward(orderActor);
	PlayWaiting();
	Sleep(1.0);
	Goto('Follow');

Done:
	if (orderActor.IsA('PatrolPoint'))
	{
		TurnTo(Location + PatrolPoint(orderActor).lookdir);
	}
	if (ComputerSecurity(OrderActor) != None)
	{
		LiteHackSecurityComputer(ComputerSecurity(OrderActor));
	}
	else if ((OrderActor != None) && (OrderActor.IsA('HCComputerSecurity') || OrderActor.IsA('RS_ComputerSecurity') || OrderActor.IsA('MyComputerSecurity')))
	{
		LiteHackModdedSecurityComputer(OrderActor);
	}
	GotoState('LiteHackStanding');

ContinueRun:
ContinueFromDoor:
	PlayRunning();
	Goto('Follow');
}

state HealingGuardedOther
{
	function SetFall()
	{
		StartFalling('HealingGuardedOther', 'ContinueRun');
	}
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	function Bump(actor bumper)
	{
		// If we hit the guy we're going to, end the state
		if (bumper == OrderActor)
			GotoState('HealingGuardedOther', 'Done');

		// Handle conversations, if need be
		Global.Bump(bumper);
	}
	function Touch(actor toucher)
	{
		// If we hit the guy we're going to, end the state
		if (toucher == OrderActor)
			GotoState('HealingGuardedOther', 'Done');

		// Handle conversations, if need be
		Global.Touch(toucher);
	}
	function BeginState()
	{
		StandUp();
		//BlockReactions();
		SetupWeapon(false);
		SetDistress(false);
		bStasis = False;
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}
	function EndState()
	{
		EnableCheckDestLoc(false);
		//ResetReactions();
		bStasis = True;
	}

Begin:
	Acceleration = vect(0, 0, 0);
	if (orderActor == None)
		Goto('Done');

Follow:
	if (IsOverlapping(orderActor))
		Goto('Done');
	MoveTarget = GetNextWaypoint(orderActor);
	if ((MoveTarget != None) && (!MoveTarget.Region.Zone.bWaterZone) &&
	    (MoveTarget.Physics != PHYS_Falling))
	{
		if ((MoveTarget == orderActor) && MoveTarget.IsA('Pawn'))
		{
			if (GetNextVector(orderActor, useLoc))
			{
				if (ShouldPlayWalk(useLoc))
					PlayRunning();
				MoveTo(useLoc, MaxDesiredSpeed);
				CheckDestLoc(useLoc);
			}
			else
				Goto('Pause');
		}
		else
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
		}
		if (IsOverlapping(orderActor))
			Goto('Done');
		else
			Goto('Follow');
	}

Pause:
	Acceleration = vect(0, 0, 0);
	TurnToward(orderActor);
	PlayWaiting();
	Sleep(1.0);
	Goto('Follow');

Done:
	if (orderActor.IsA('PatrolPoint'))
	{
		TurnTo(Location + PatrolPoint(orderActor).lookdir);
	}
	if ((VMDBufferPawn(OrderActor) != None) && (VMDBufferPawn(OrderActor).Health < VMDBufferPawn(OrderActor).StartingHealthValues[6]) && (bCanHeal) && (bHasHeal))
	{
		HealOtherPawn(VMDBufferPawn(OrderActor));
	}
	if (VMDBufferPlayer(OrderActor) != None)
	{
		HealOtherPawn(VMDBufferPlayer(OrderActor));
	}
	MEGHIssueOrder('GuardingOther', GuardedOther);
	//GotoState('Standing');

ContinueRun:
ContinueFromDoor:
	PlayRunning();
	Goto('Follow');
}

state HealingOther
{
	function SetFall()
	{
		StartFalling('HealingOther', 'ContinueRun');
	}
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	function Bump(actor bumper)
	{
		// If we hit the guy we're going to, end the state
		if (bumper == OrderActor)
			GotoState('HealingOther', 'Done');

		// Handle conversations, if need be
		Global.Bump(bumper);
	}
	function Touch(actor toucher)
	{
		// If we hit the guy we're going to, end the state
		if (toucher == OrderActor)
			GotoState('HealingOther', 'Done');

		// Handle conversations, if need be
		Global.Touch(toucher);
	}
	function BeginState()
	{
		StandUp();
		//BlockReactions();
		SetupWeapon(false);
		SetDistress(false);
		bStasis = False;
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}
	function EndState()
	{
		EnableCheckDestLoc(false);
		//ResetReactions();
		bStasis = True;
	}

Begin:
	Acceleration = vect(0, 0, 0);
	if (orderActor == None)
		Goto('Done');

Follow:
	if (IsOverlapping(orderActor))
		Goto('Done');
	MoveTarget = GetNextWaypoint(orderActor);
	if ((MoveTarget != None) && (!MoveTarget.Region.Zone.bWaterZone) &&
	    (MoveTarget.Physics != PHYS_Falling))
	{
		if ((MoveTarget == orderActor) && MoveTarget.IsA('Pawn'))
		{
			if (GetNextVector(orderActor, useLoc))
			{
				if (ShouldPlayWalk(useLoc))
					PlayRunning();
				MoveTo(useLoc, MaxDesiredSpeed);
				CheckDestLoc(useLoc);
			}
			else
				Goto('Pause');
		}
		else
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
		}
		if (IsOverlapping(orderActor))
			Goto('Done');
		else
			Goto('Follow');
	}

Pause:
	Acceleration = vect(0, 0, 0);
	TurnToward(orderActor);
	PlayWaiting();
	Sleep(1.0);
	Goto('Follow');

Done:
	if (orderActor.IsA('PatrolPoint'))
	{
		TurnTo(Location + PatrolPoint(orderActor).lookdir);
	}
	if ((VMDBufferPawn(OrderActor) != None) && (VMDBufferPawn(OrderActor).Health < VMDBufferPawn(OrderActor).StartingHealthValues[6]) && (bCanHeal) && (bHasHeal))
	{
		HealOtherPawn(VMDBufferPawn(OrderActor));
	}
	if (VMDBufferPlayer(OrderActor) != None)
	{
		HealOtherPawn(VMDBufferPlayer(OrderActor));
	}
	MEGHIssueOrder('MeghFollowing', GetLastVMP());
	//GotoState('Standing');

ContinueRun:
ContinueFromDoor:
	PlayRunning();
	Goto('Follow');
}

state MeghPatrolling
{
	function SetFall()
	{
		StartFalling('MeghPatrolling', 'ContinueRun');
	}
	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}
	function Bump(actor bumper)
	{
		// If we hit the guy we're going to, end the state
		if (bumper == OrderActor)
		{
			if (VMDFakePatrolPoint(OrderActor) != None)
			{
				OrderActor = VMDFakePatrolPoint(OrderActor).NextPatrol;
				GotoState('MeghPatrolling', 'Follow');
			}
			else
			{
				GotoState('MeghPatrolling', 'Done');
			}
		}
		
		// Handle conversations, if need be
		Global.Bump(bumper);
	}
	function Touch(actor toucher)
	{
		// If we hit the guy we're going to, end the state
		if (toucher == OrderActor)
		{
			if ((!bReversePatrol) && (VMDFakePatrolPoint(OrderActor) != None) && (VMDFakePatrolPoint(OrderActor).NextPatrol != None))
			{
				if (VMDFakePatrolPoint(OrderActor).NextPatrol.MyArray == 0)
				{
					bReversePatrol = true;
					OrderActor = VMDFakePatrolPoint(OrderActor).PreviousPatrol;
					GotoState('MeghPatrolling', 'Follow');
				}
				else
				{
					OrderActor = VMDFakePatrolPoint(OrderActor).NextPatrol;
					GotoState('MeghPatrolling', 'Follow');
				}
			}
			else if ((bReversePatrol) && (VMDFakePatrolPoint(OrderActor) != None) && (VMDFakePatrolPoint(OrderActor).PreviousPatrol != None))
			{
				if (VMDFakePatrolPoint(OrderActor).MyArray == 0)
				{
					bReversePatrol = false;
					OrderActor = VMDFakePatrolPoint(OrderActor).NextPatrol;
					GotoState('MeghPatrolling', 'Follow');
				}
				else
				{
					OrderActor = VMDFakePatrolPoint(OrderActor).PreviousPatrol;
					GotoState('MeghPatrolling', 'Follow');
				}
			}
			else
			{
				GotoState('MeghPatrolling', 'Done');
			}
		}
		
		// Handle conversations, if need be
		Global.Touch(toucher);
	}
	function BeginState()
	{
		StandUp();
		//BlockReactions();
		SetupWeapon(false);
		SetDistress(false);
		bStasis = False;
		SeekPawn = None;
		EnableCheckDestLoc(true);
	}
	function EndState()
	{
		EnableCheckDestLoc(false);
		//ResetReactions();
		bStasis = True;
	}
	
Begin:
	Acceleration = vect(0, 0, 0);
	if (orderActor == None)
		Goto('Done');
	
Follow:
	if (IsOverlapping(orderActor))
		Goto('Done');
	MoveTarget = GetNextWaypoint(orderActor);
	if ((MoveTarget != None) && (!MoveTarget.Region.Zone.bWaterZone) &&
	    (MoveTarget.Physics != PHYS_Falling))
	{
		if ((MoveTarget == orderActor) && MoveTarget.IsA('Pawn'))
		{
			if (GetNextVector(orderActor, useLoc))
			{
				if (ShouldPlayWalk(useLoc))
					PlayRunning();
				MoveTo(useLoc, MaxDesiredSpeed);
				CheckDestLoc(useLoc);
			}
			else
				Goto('Pause');
		}
		else
		{
			if (ShouldPlayWalk(MoveTarget.Location))
				PlayRunning();
			MoveToward(MoveTarget, MaxDesiredSpeed);
			CheckDestLoc(MoveTarget.Location, true);
		}
		if (IsOverlapping(orderActor) || KindaOverlapping(OrderActor))
		{
			if (VMDFakePatrolPoint(OrderActor) == None)
			{
				Goto('Done');
			}
			else
			{
				if (!bReversePatrol)
				{
					if ((VMDFakePatrolPoint(OrderActor).NextPatrol != None) && (VMDFakePatrolPoint(OrderActor).NextPatrol.MyArray == 0))
					{
						bReversePatrol = true;
						OrderActor = VMDFakePatrolPoint(OrderActor).PreviousPatrol;
						GoTo('Follow');
					}
					else
					{
						OrderActor = VMDFakePatrolPoint(OrderActor).NextPatrol;
						GoTo('Follow');
					}
				}
				else
				{
					if ((VMDFakePatrolPoint(OrderActor).PreviousPatrol != None) && (VMDFakePatrolPoint(OrderActor).MyArray == 0))
					{
						bReversePatrol = false;
						OrderActor = VMDFakePatrolPoint(OrderActor).NextPatrol;
						GoTo('Follow');
					}
					else
					{
						OrderActor = VMDFakePatrolPoint(OrderActor).PreviousPatrol;
						GoTo('Follow');
					}
				}
				LastMEGHPatrolPoint = VMDFakePatrolPoint(OrderActor);
			}
		}
		else
		{
			Goto('Follow');
		}
	}

Pause:
	Acceleration = vect(0, 0, 0);
	TurnToward(orderActor);
	PlayWaiting();
	Sleep(1.0);
	Goto('Follow');

Done:
	if (orderActor.IsA('PatrolPoint'))
		TurnTo(Location + PatrolPoint(orderActor).lookdir);
	//GotoState('Standing');
	//GoToState('MeghFollowing');
	
	if (GetClosestPatrolPoint(Self) != None)
	{
		MEGHIssueOrder('MeghPatrolling', GetClosestPatrolPoint(Self));
	}
ContinueRun:
ContinueFromDoor:
	PlayRunning();
	Goto('Follow');
}

function VMDFakePatrolPoint GetClosestPatrolPoint(VMDMegh TMegh)
{
	local float BestDist, TDist;
	local VMDFakePatrolPoint BestPat, FakePat;
	
	if (TMegh == None) return None;
	BestDist = 9999;
	
	ForEach AllActors(class'VMDFakePatrolPoint', FakePat)
	{
		if ((FakePat != None) && (FastTrace(FakePat.Location, TMegh.Location)))
		{
			TDist = VSize(FakePat.Location - TMegh.Location);
			if (TDist < BestDist)
			{
				BestDist = TDist;
				BestPat = FakePat;
			}
		}
	}
	
	return BestPat;
}

// ----------------------------------------------------------------------
// state BackingOff
//
// Hack state used to back off when the NPC gets stuck.
// ----------------------------------------------------------------------

state BackingOff
{
	ignores EnemyNotVisible;

	function SetFall()
	{
		StartFalling('BackingOff', 'ContinueRun');
	}

	function HitWall(vector HitNormal, actor Wall)
	{
		if (Physics == PHYS_Falling)
			return;
		Global.HitWall(HitNormal, Wall);
		CheckOpenDoor(HitNormal, Wall);
	}

	function bool PickDestinationBool()
	{
		local bool    bSuccess;
		local float   magnitude;
		local rotator rot;
		
		magnitude = 300;
		
		//MADDERS: Reduce this bullshit, please. This is almost always a false positive.
		Magnitude *= 0.175;
		
		rot = Rotator(Destination-Location);
		bSuccess = AIPickRandomDestination(Magnitude*0.75, magnitude, rot.Yaw+32768, 0.8, -rot.Pitch, 0.8, 3,
		                                   0.9, useLoc);

		return bSuccess;
	}

	function bool HandleTurn(Actor Other)
	{
		GotoState('BackingOff', 'Pause');
		return false;
	}

	function BeginState()
	{
		StandUp();
		BlockReactions();
		bStasis = False;
		bInTransientState = True;
		EnableCheckDestLoc(false);
		bCanJump = false;
	}

	function EndState()
	{
		EnableCheckDestLoc(false);
		if (JumpZ > 0)
			bCanJump = true;
		ResetReactions();
		bStasis = True;
		bInTransientState = false;
	}

Begin:
	useRot = Rotation;
	if (!PickDestinationBool())
		Goto('Pause');
	Acceleration = vect(0,0,0);

MoveAway:
	if (ShouldPlayWalk(useLoc))
		PlayRunning();
	MoveTo(useLoc, MaxDesiredSpeed);

Pause:
	Acceleration = vect(0,0,0);
	//PlayWaiting();
	Sleep(0.1);
	//Sleep(FRand()*2+2);

Done:
	if (HasNextState())
		GotoNextState();
	else
		FollowOrders();  // THIS IS BAD!!!

ContinueRun:
ContinueFromDoor:
	Goto('Done');

}

state DestroyingOther expands Attacking
{
	function bool HasEnemyTimedOut()
	{
		return false;
	}
	function UpdateActorVisibility(actor seeActor, float deltaSeconds, float checkTime, bool bCheckDir)
	{
		EnemyLastSeen = 0;
	}
}

state Oppressing expands Attacking
{
	function bool FireIfClearShot()
	{
		local DeusExWeapon dxWeapon;
		
		if (OppressTarget == None || OppressTarget.IsInState('Dying'))
		{
			MEGHIssueOrder('MeghFollowing', GetLastVMP());
		}
		else if (OppressTarget.bCower)
		{
			//Do anything? Probably not.
		}
		else
		{
			dxWeapon = DeusExWeapon(Weapon);
			if (dxWeapon != None)
			{
				if ((dxWeapon.AIFireDelay > 0) && (FireTimer > 0))
				{
					return false;
				}
				else if (AICanShoot(enemy, true, true, 0.025))
				{
					Weapon.Fire(0);
					FireTimer = dxWeapon.AIFireDelay;
					return true;
				}
				else
				{
					return false;
				}
			}
			else
			{
				return false;
			}
		}
	}
}

function bool KindaOverlapping(Actor CheckAct)
{
	local float TDist;
	
	if (CheckAct == None) return false;
	
	TDist = abs(CheckAct.Location.X - Location.X) + abs(CheckAct.Location.Y - Location.Y);
	
	return (TDist < 16);
}

function CheckDestLoc(vector newDestLoc, optional bool bPathnode)
{
	local Vector SterLoc, SterNewDestLoc, SterLastDestLoc, SterLastDestPoint;
	
	SterLoc = Location;
	SterLoc.Z = 0;
	SterNewDestLoc = NewDestLoc;
	SterNewDestLoc.Z = 0;
	SterLastDestLoc = LastDestLoc;
	SterLastDestLoc.Z = 0;
	SterLastDestPoint = LastDestPoint;
	SterLastDestPoint.Z = 0;
	
	if (VSize(SterNewDestLoc-SterLastDestLoc) <= 16)  // too close
	{
		DestAttempts++;
	}
	else if (!IsPointInCylinder(Self, SterNewDestLoc)) //HackNewDestLoc
	{
		//MADDERS, 8/29/22: Smashing shit with a hammer. I smashed this thing and now it works.
		//Grug do good. Grug fix.
		if (DeusExPlayer(OrderActor) == None)
		{
			DestAttempts++;
		}
	}
	else if ((bPathnode) && (VSize(SterNewDestLoc-SterLastDestPoint) <= 16))  // too close
	{
		DestAttempts++;
	}
	else
	{
		DestAttempts = 0;
	}
	
	LastDestLoc = NewDestLoc;
	if ((bPathnode) && (DestAttempts == 0))
	{
		LastDestPoint = NewDestLoc;
	}
	
	if ((bEnableCheckDest) && (DestAttempts >= 4))
	{
		if (DestAttempts > 44)
		{
			BackOff();
		}
		else
		{
			PathOverrideHackLoc.X = SterNewDestLoc.X;
			PathOverrideHackLoc.Y = SterNewDestLoc.Y;
		}
	}
}

// ----------------------------------------------------------------------
// IsPointInCylinder()
// ----------------------------------------------------------------------

function bool IsPointInCylinder(Actor cylinder, Vector point,
                                optional float extraRadius, optional float extraHeight)
{
	local bool  bPointInCylinder;
	local float tempX, tempY, tempRad;
	
	tempX    = cylinder.Location.X - point.X;
	tempX   *= tempX;
	tempY    = cylinder.Location.Y - point.Y;
	tempY   *= tempY;
	tempRad  = cylinder.CollisionRadius + extraRadius;
	tempRad *= tempRad;
	
	bPointInCylinder = false;
	if (tempX+tempY < tempRad)
	{
		//if (Abs(cylinder.Location.Z - point.Z) < (cylinder.CollisionHeight+extraHeight))
		
		//MADDERS, 8/29/22: More grug-smashery. Ignore Z axis.
		bPointInCylinder = true;
	}
	return (bPointInCylinder);
}

function IncreaseAgitation(Actor actorInstigator, optional float AgitationLevel)
{
	local Pawn  instigator;
	local float minLevel;
	local int TProvo;
	
	//MADDERS, 8/29/22: Don't hate the player, no matter what.
	//Last time I made a coop AI, it didn't retain this lesson very well, despite all reason. Scary, but true.
	if (!VMDCanBeMEGHEnemy(ActorInstigator))
	{
		return;
	}
	
	instigator = InstigatorToPawn(actorInstigator);
	if (instigator != None)
	{
		AgitationTimer = AgitationSustainTime;
		if (AgitationCheckTimer <= 0)
		{
			AgitationCheckTimer = 1.5;  // hardcoded for now
			if (AgitationLevel == 0)
			{
				if (MaxProvocations < 0)
					MaxProvocations = 0;
				
				//MADDERS: Forgive aggression less in general, but more if we're in a combat state.
				//Update: This system is more than a little jank. Just skip aggression while fighting.
				TProvo = MaxProvocations-1;
				if (TProvo < 0)
					TProvo = 0;
				
				AgitationLevel = 1.0/(TProvo+1);
			}
			if (AgitationLevel > 0)
			{
				bAlliancesChanged = True;
				bNoNegativeAlliances = False;
				AgitateAlliance(instigator.Alliance, AgitationLevel);
			}
		}
	}
}

function SetOrders(Name orderName, optional Name newOrderTag, optional bool bImmediate)
{
	local bool bHostile;
	local Pawn orderEnemy;
	
	switch (orderName)
	{
		case 'Attacking':
		case 'Fleeing':
		case 'Alerting':
		case 'Seeking':
			bHostile = true;
			break;
		default:
			bHostile = false;
			break;
	}
	
	if (!bHostile)
	{
		bSeatHackUsed = false;  // hack!
		Orders   = orderName;
		OrderTag = newOrderTag;

		if (bImmediate)
			FollowOrders(true);
	}
	else
	{
		ReactionLevel = 1.0;
		if ((NewOrderTag == '') && (ScriptedPawn(OrderActor) != None))
		{
			OrderEnemy = ScriptedPawn(OrderActor);
		}
		else
		{
			orderEnemy = Pawn(FindTaggedActor(newOrderTag, false, Class'Pawn'));
		}
		
		if (orderEnemy != None)
		{
			ChangeAlly(orderEnemy.Alliance, -1, true);
			if (SetEnemy(orderEnemy))
				SetState(orderName);
		}
	}
}

function bool SetEnemy(Pawn newEnemy, optional float newSeenTime, optional bool bForce)
{
	local bool FlagGo;
	
	if (!VMDCanBeMEGHEnemy(NewEnemy))
	{
		return false;
	}
	
	if (bReconMode)
	{
		AddReconTarget(ScriptedPawn(NewEnemy));
		return false;
	}
	else
	{
		FlagGo = false;
		if (bForce) FlagGo = True;
		else if (IsValidEnemy(newEnemy))
		{
			if (Robot(newEnemy) == None || !Robot(newEnemy).IsInState('Disabled')) FlagGo = True;
		}
		
		if (FlagGo)
		{
			if (newEnemy != Enemy)
			{
				EnemyTimer = 0;
			}
			Enemy = newEnemy;
			EnemyLastSeen = newSeenTime;	
			
			return True;
		}
		else
		{
			return False;
		}
	}
}

//MADDERS, 8/31/22: Stop attacking if we're in recon mode.
//Instead, mark dudes out.
function HandleEnemy()
{
	if (bReconMode)
	{
		if ((Enemy != None) && (FastTrace(Enemy.Location, Location)))
		{
			AddReconTarget(ScriptedPawn(Enemy));
		}
	}
	else
	{
		SetState('HandlingEnemy', 'Begin');
	}
}

function bool FrobDoor(actor Target)
{
	local float DoorWidth;
	local Vector StartTrace, EndTrace, HitLocation, HitNormal, DoorBoxMin, DoorBoxMax;
	local Actor HitActor;
	local DeusExMover DXMover;
	
	DoorGhostLoc = vect(0,0,0);
	
	DXMover = DeusExMover(Target);
	if (DXMover != None)
	{
		StartTrace = Location;
		EndTrace = Location + (vect(1000,0,0) >> Rotation);
		
		HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);
		
		if (HitActor == DXMover)
		{
			DXMover.GetBoundingBox(DoorBoxMin, DoorBoxMax, false, DXMover.KeyPos[DXMover.KeyNum]+DXMover.BasePos, DXMover.KeyRot[DXMover.KeyNum]+DXMover.BaseRot);
			
			DoorWidth = Abs(((DoorBoxMax-DoorBoxMin) >> ViewRotation).X);
			
			DoorGhostLoc = HitLocation + ((vect(2.5,0,0) * CollisionRadius + vect(2,0,0) * DoorWidth + vect(80, 0, 0)) >> Rotation);
			if (FastTrace(DoorGhostLoc, DoorGhostLoc + vect(1,0,0)))
			{
				bDoorGhosting = true;
			}
			else
			{
				DoorGhostLoc = vect(0,0,0);
			}
		}
	}
}

function bool IsDoor(Actor Target, bool bWarn)
{
	local int TWidth, TBreadth, THeight;
	local Vector ColBoxMin, ColBoxMax;
	local Mover TMov;
	
	if (Mover(Target) != None)
	{
		//MADDERS, 7/15/24: Do some really swoocey shit here.
		//Basically, if it's too big to be an elevator, it's probably some moving piece of floor (NYC sewer bridge, for instance)
		//Or, if it's really small on 2 axes, it's not big enough to be a real elevator.
		TMov = Mover(Target);
		TMov.GetBoundingBox(ColBoxMin, ColBoxMax, false, TMov.KeyPos[TMov.KeyNum]+TMov.BasePos, TMov.KeyRot[TMov.KeyNum]+TMov.BaseRot);
		TWidth = ColBoxMax.Y - ColBoxMin.Y;
		TBreadth = ColBoxMax.X - ColBoxMin.X;
		THeight = ColBoxMax.Z - ColBoxMin.Z;
		if (TWidth+TBreadth > 256 || THeight > 256)
		{
			return false;
		}
		else
		{
			return true;
		}
		
		return true;
	}
}

function bool FakePickDestination()
{
	local float   dist;
	local float   extra;
	local float   distMax;
	local int     dir;
	local rotator rot;
	local bool    bSuccess;
	
	local DeusExPlayer DXP;
	
	if (OrderActor == None)
	{
		return false;
	}
	
	bSuccess = false;
	destPoint = None;
	destLoc = vect(0, 0, 0);
	extra = orderActor.CollisionRadius + CollisionRadius;
	dist = VSize(orderActor.Location - Location);
	dist -= extra;
	if (dist < 0)
	{
		dist = 0;
	}
	
	PathOverrideHackLoc = vect(0,0,0);
	
	DXP = DeusExPlayer(OrderActor);
	
	//MADDERS, 8/29/22: Fuck doors. Sincerely: ~MEGH
	if (bDoorGhosting)
	{
		BackpedalTimer = -1;
		return true;
	}
	
	//MADDERS, 8/29/22: Hack. Don't follow into water, please.
	if ((DXP != None) && (DXP.Region.Zone != None) && (DXP.Region.Zone.bWaterZone))
	{
		BackpedalTimer = -1;
		
		//Are we on an elevator, in line of sight?
		if (AICanSee(orderActor, , false, false, false, true) > 0)
		{
			//MADDERS, 8/29/22: Hover over our position underwater. Neato.
			PathOverrideHackLoc = DXP.Location;
		}
		return false;
	}
	
	//Are we on an elevator, in line of sight?
	//(DXP.bDuck > 0) && 
	if ((VMDPlayerIsOnElevator(DXP)) && (AICanSee(orderActor, , false, false, false, true) > 0))
	{
		//MADDERS, 8/29/22: Move closer, to get on the elevator.
		PathOverrideHackLoc = DXP.Location;
	}
	
	else if ((dist > 180) || (AICanSee(orderActor, , false, false, false, true) <= 0))
	{
		if (ActorReachable(orderActor))
		{
			rot = Rotator(orderActor.Location - Location);
			distMax = (dist-180)+45;
			if (distMax > 80)
			{
				distMax = 80;
			}
			bSuccess = AIDirectionReachable(Location, rot.Yaw, rot.Pitch, 0, distMax, destLoc);
		}
		else
		{
			MoveTarget = FindPathToward(orderActor);
			if (MoveTarget != None)
			{
				destPoint = MoveTarget;
				bSuccess = true;
			}
		}
		BackpedalTimer = -1;
	}
	else if (dist < 60)
	{
		if ((VMDPlayerIsOnElevator(DXP)) && (DXP.bDuck > 0 || DXP.bForceDuck))
		{
			if (dist < 32)
			{
				//MADDERS, 8/29/22: We win?
			}
			else
			{
				if (AICanSee(orderActor, , false, false, false, true) > 0)
				{
					//MADDERS, 8/29/22: Move closer, to get on the elevator.
					PathOverrideHackLoc = DXP.Location;
				}
			}
		}
		else
		{
			if (BackpedalTimer < 0)
			{
				BackpedalTimer = 0;
			}
			if (BackpedalTimer > 1.0)  // give the player enough time to converse, if he wants to
			{
				rot = Rotator(Location - orderActor.Location);
				bSuccess = AIDirectionReachable(orderActor.Location, rot.Yaw, rot.Pitch, 60+extra, 120+extra, destLoc);
			}
		}
	}
	else
	{
		BackpedalTimer = -1;
	}
	
	return (bSuccess);
}

function float FindTargetFloorZ()
{
	local Vector StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor HitActor;
	
	StartTrace = Location;
	EndTrace = Location + vect(0,0,-1024);
	HitActor = Trace(HitLocation, HitNormal, EndTrace, StartTrace);
	
	if (HitActor == Level)
	{
		return HitLocation.Z;
	}
	return Location.Z;
}

function bool SpawnBehindPlayer()
{
	local bool Ret;
	local float TraceDist;
	local Vector StartTrace, EndTrace, HitLocation, HitNormal;
	local Actor HitAct;
	local DeusExPlayer HackPlayer;
	
	HackPlayer = GetLastVMP();
	if (HackPlayer == None) return false;
	
	if (GuardedOther != None)
	{
		StartTrace = GuardedOther.Location - ((vect(1.5,0,0) * GuardedOther.CollisionRadius) >> GuardedOther.Rotation);
		EndTrace = StartTrace - (vect(384,0,0) >> HackPlayer.Rotation);
		
		HitAct = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
		TraceDist = (VSize(HitLocation - StartTrace));
		
		Ret = SetLocation(GuardedOther.Location - ((vect(0.8,0,0) * TraceDist) >> GuardedOther.Rotation));
		PathingFailures = 0;
		PathingFailures2 = 0;
	}
	else
	{
		StartTrace = HackPlayer.Location - ((vect(1.5,0,0) * HackPlayer.CollisionRadius) >> HackPlayer.Rotation);
		EndTrace = StartTrace - (vect(384,0,0) >> HackPlayer.Rotation);
		
		HitAct = Trace(HitLocation, HitNormal, EndTrace, StartTrace, false);
		TraceDist = (VSize(HitLocation - StartTrace));
		
		Ret = SetLocation(HackPlayer.Location - ((vect(0.8,0,0) * TraceDist) >> HackPlayer.Rotation));
		PathingFailures = 0;
		PathingFailures2 = 0;
	}
	
	return Ret;
}

function bool AttemptFollowingRegroupTeleport()
{
	local DeusExPlayer HackPlayer;
	
	HackPlayer = GetLastVMP();
	if (HackPlayer == None) return false;
	
	if (GuardedOther != None)
	{
		if ((HackPlayer != None) && (!PlayerCanSee(HackPlayer, Self)))
		{
			return SpawnBehindPlayer();
		}
	}
	else
	{
		if ((HackPlayer != None) && (!HackPlayer.bForceDuck) && (!PlayerCanSee(HackPlayer, Self)) && (HackPlayer.Region.Zone == None || !HackPlayer.Region.Zone.bWaterZone))
		{
			return SpawnBehindPlayer();
		}
	}
}

function bool ShouldReactToWallCramming()
{
	switch (GetStateName())
	{
		case 'LiteHacking':
		case 'LiteHackStanding':
		case 'Standing':
		case 'RunningTo':
			return false;
		break;
		default:
			return true;
		break;
	}
}

function Tick(float DT)
{
	local bool FlagWallCrammed;
	local float TDist, ATDist, TraceDist, TargetX, TargetY, TargetZ, GSpeed;
	local Vector TNorm, StartTrace, EndTrace, HitLocation, HitNormal, TVect, TLoc;
	local Actor HitAct;
	local DeusExPlayer DXP, HackPlayer;
	
	if (bDebugState)
	{
		BroadcastMessage("MEGH CURRENT STATE?"@GetStateName());
		Log("MEGH CURRENT STATE?"@GetStateName());
		bDebugState = false;
	}
	
	if ((SparkGen != None) && (!SparkGen.bDeleteMe))
	{
		TLoc = Location;
		TLoc.z += CollisionHeight/2;
		SparkGen.SetLocation(TLoc);
	}
	
	if ((!IsInState('Dying')) && (EMPHitPoints > 0))
	{
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
		
		//MADDERS, 8/29/22: NASTY HACK!
		//If we're totally stuck and fucked, wait 15 seconds, then appear behind the player.
		//Pretend like we knew what we were doing all along.
		//----------------
		//9/1/22: Update: Do 6.25 seconds instead. We can afford it.
		HackPlayer = GetLastVMP();
		DXP = DeusExPlayer(OrderActor);
		
		bHidden = (HackPlayer.IsInState('Interpolating') || HackPlayer.IsInState('Paralyzed') || IsInState('TrulyParalyzed'));
		if (bHidden) return;
		
		if ((IsInState('MeghFollowing')) && (HackPlayer != None) && (!bDoorGhosting))
		{
			if ((HackPlayer.Region.Zone != None) && (HackPlayer.Region.Zone.bWaterZone) && (bBlockActors) && (Enemy == None))
			{
				BlockReactions(true);
				SetCollision(False, False, False);
			}
			else if (!bBlockActors)
			{
				ResetReactions();
				SetCollision(True, True, False);
			}
		}
		
		if (TargetAcquiredSpeechTimer >= 0.0)
		{
			TargetAcquiredSpeechTimer -= DT;
		}
		if (ReconPingSoundTimer > 0.0)
		{
			ReconPingSoundTimer -= DT;
		}
		
		if (IsInState('Following'))
		{
			PositionRecheckTimer -= DT;
			if (PositionRecheckTimer < 0.0)
			{
				if ((VSize(LastLocation - Location) < 12) && (VSize(OrderActor.Location - Location) > 384))
				{
					LastLocationFailures++;
					if (LastLocationFailures > 4)
					{
						if (AttemptFollowingRegroupTeleport())
						{
							LastLocationFailures = 0;
						}
					}
				}
				else
				{
					LastLocationFailures = 0;
					LastLocation = Location;
				}
				PositionRecheckTimer = 3.0;
			}
		}
		
		if (bReconMode)
		{
			ReconScanTimer += DT;
			if (ReconScanTimer > 2.0)
			{
				GiveReconPulse();
				ReconScanTimer = 0;
			}
		}
		
		if (LiteHackComputer != None || LiteHackTarget != None)
		{
			LiteHackRefreshTimer += DT;
			if (LiteHackRefreshTimer > 5)
			{
				if (LiteHackComputer != None)
				{
					LiteHackSecurityComputer(LiteHackComputer);
				}
				else
				{
					LiteHackModdedSecurityComputer(LiteHackTarget);
				}
				LiteHackRefreshTimer = DT;
			}
		}
		
		if (IsInState('DestroyingOther'))
		{
			if (DestroyOtherPawn == None)
			{
				MEGHIssueOrder('MeghFollowing', GetLastVMP());
			}
			else if (Enemy != DestroyOtherPawn)
			{
				SetEnemy(DestroyOtherPawn);
			}
		}
		
		Multiskins[6] = Texture'PinkMaskTex';
		if (!bHealthBuffed)
		{
			if ((bCanHeal) && (bHasHeal))
			{
				Multiskins[2] = Texture'VMDMeghTex03Healing';
				Multiskins[6] = Texture'VMDSyringeSilverMetal';
			}
			else if (bCanHeal)
			{
				Multiskins[2] = Texture'VMDMeghTex03NoHealing';
			}
			else
			{
				Multiskins[2] = Texture'VMDMeghTex03';
			}
		}
		else
		{
			if ((bCanHeal) && (bHasHeal))
			{
				Multiskins[2] = Texture'VMDMeghTex03HealingHeavy';
				Multiskins[6] = Texture'VMDSyringeSilverMetal';
			}
			else if (bCanHeal)
			{
				Multiskins[2] = Texture'VMDMeghTex03NoHealingHeavy';
			}
			else
			{
				Multiskins[2] = Texture'VMDMeghTex03Heavy';
			}
		}
		
		if ((IsInState('Following')) && (Max(PathingFailures, PathingFailures2) > 6.25/DT) && (VSize(OrderActor.Location - Location) > 384))
		{
			AttemptFollowingRegroupTeleport();
		}
		
		if ((!FastTrace(Location+((vect(1.2,0,0) * CollisionRadius) >> Rotation), Location)) && (!bWallCrammed))
		{
			bWallCrammed = true;
			WallCramPointer = Rotation;
		}
		
		if (bDoorGhosting)
		{
			TargetX = DoorGhostLoc.X;
			TargetY = DoorGhostLoc.Y;
			TargetZ = Location.Z;
			
			SetCollision(False, False, False);
			bCollideWorld = false;
		}
		else
		{
			if (!bCollideWorld)
			{
				SetCollision(True, True, False);
				if (!FastTrace(Location+vect(1,0,0), Location))
				{
					if (!SpawnBehindPlayer())
					{
						SetLocation(FirstLocation);
					}
				}
				bCollideWorld = true;
			}
			
			if ((!FastTrace(Location+vect(0,0,20), Location)) && (FastTrace(Location-vect(0,0,40), Location)))
			{
				TargetZ = Location.Z - 40;
			}
			else if ((bWallCrammed) && (ShouldReactToWallCramming()))
			{
				if (IsInState('Following'))
				{
					if (FastTrace(Location+((vect(4.0,0,0) * CollisionRadius) >> WallCramPointer), Location) || !FastTrace(Location+((vect(-2.0,0,0) * CollisionRadius) >> WallCramPointer), Location))
					{
						bWallCrammed = false;
					}
					TVect = Location - ((vect(7.5,0,0) * CollisionRadius) >> WallCramPointer);
				}
				else
				{
					if (FastTrace(Location+((vect(1.5,0,0) * CollisionRadius) >> WallCramPointer), Location) || !FastTrace(Location+((vect(-1.0,0,0) * CollisionRadius) >> WallCramPointer), Location))
					{
						bWallCrammed = false;
					}
					TVect = Location - ((vect(7.5,0,0) * CollisionRadius) >> WallCramPointer);
				}
				
				DesiredRotation = Rotator(-Vector(WallCramPointer));
				SetRotation(DesiredRotation);
				TargetX = TVect.X;
				TargetY = TVect.Y;
			}
			else if ((DXP != None) && (GetStateName() == 'MeghFollowing'))
			{
				TDist = DXP.Location.Z - Location.Z;
				if ((VSize(DXP.Location - Location) - Abs(TDist) < 240) && (DXP.Region.Zone == None || !DXP.Region.Zone.bWaterZone))
				{
					TargetZ = DXP.Location.Z;
				}
				
				if (PathOverrideHackLoc != vect(0,0,0))
				{
					TargetX = DXP.Location.X;
					TargetY = DXP.Location.Y;
				}
			}
			else if ((GuardedOther != None) && (IsInState('GuardingOther')))
			{
				TDist = GuardedOther.Location.Z - Location.Z;
				if ((VSize(GuardedOther.Location - Location) - Abs(TDist) < 240) && (GuardedOther.Region.Zone == None || !GuardedOther.Region.Zone.bWaterZone))
				{
					TargetZ = GuardedOther.Location.Z;
				}
				
				if (PathOverrideHackLoc != vect(0,0,0))
				{
					TargetX = GuardedOther.Location.X;
					TargetY = GuardedOther.Location.Y;
				}
			}
			else
			{
				if (IsInState('Following'))
				{
					if (OrderActor != None)
					{
						if (Mover(OrderActor) == None)
						{
							TargetZ = OrderActor.Location.Z;
						}
						else
						{
							TargetZ = FindTargetFloorZ()+CollisionHeight;
						}
					}
					else if (MoveTarget != None)
					{
						if (Mover(MoveTarget) == None)
						{
							TargetZ = MoveTarget.Location.Z+32;
						}
						else
						{
							TargetZ = FindTargetFloorZ()+CollisionHeight;
						}
					}
				}
				if ((IsInState('MeghPatrolling')) && (OrderActor != None))
				{
					TDist = abs(OrderActor.Location.X - Location.X) + abs(OrderActor.Location.Y - Location.Y);
					DesiredSpeed = MaxDesiredSpeed;
					if (!bWallCrammed)
					{
						if (TDist < 48)
						{
							DesiredSpeed *= 0.75;
						}
						if (TDist < 24)
						{
							DesiredSpeed *= 0.65;
						}
					}
				}
				if (IsInState('BackingOff'))
				{
					if (!bWallCrammed)
					{
						DesiredSpeed = MaxDesiredSpeed * 0.75;
					}
				}
			}
		}
		
		if (TargetX != 0)
		{
			TDist = TargetX - Location.X;
			ATDist = Abs(TDist);
			if ((HackPlayer != None) && (VMDPlayerIsOnElevator(HackPlayer)))
			{
				if (ATDist < 32)
				{
					Velocity.X = 0;
					Acceleration.X = 0;
				}
				else if (ATDist < 64)
				{
					Velocity.X = TDist * 5;
					Acceleration.X = TDist * 5;
				}
				else if (ATDist < 96)
				{
					Velocity.X = TDist * 10;
					Acceleration.X = TDist * 10;
				}
				else
				{
					Velocity.X = TDist * 20;
					Acceleration.X = TDist * 20;
				}
			}
			else
			{
				if (ATDist < 32)
				{
					Velocity.X = 0;
					Acceleration.X = 0;
				}
				else
				{
					Velocity.X = TDist;
					Acceleration.X = TDist;
				}
			}
		}
		if (TargetY != 0)
		{
			TDist = TargetY - Location.Y;
			ATDist = Abs(TDist);
			if ((HackPlayer != None) && (VMDPlayerIsOnElevator(HackPlayer)))
			{
				if (ATDist < 32)
				{
					Velocity.Y = 0;
					Acceleration.Y = 0;
				}
				else if (ATDist < 64)
				{
					Velocity.Y = TDist * 5;
					Acceleration.Y = TDist * 5;
				}
				else if (ATDist < 96)
				{
					Velocity.Y = TDist * 10;
					Acceleration.Y = TDist * 10;
				}
				else
				{
					Velocity.Y = TDist * 20;
					Acceleration.Y = TDist * 20;
				}
			}
			else
			{
				if (ATDist < 32)
				{
					Velocity.Y = 0;
					Acceleration.Y = 0;
				}
				else
				{
					Velocity.Y = TDist;
					Acceleration.Y = TDist;
				}
			}
		}
		if (TargetZ != 0)
		{
			TDist = TargetZ - Location.Z;
			ATDist = Abs(TDist);
			if ((HackPlayer != None) && (VMDPlayerIsOnElevator(HackPlayer)))
			{
				if (ATDist < 24)
				{
					//Less? None?
					//Velocity.Z = TDist;
					//Acceleration.Z = TDist;
					Velocity.Z = Velocity.Z * 0.85;
					Acceleration.Z = Acceleration.Z * 0.85;
				}
				else if (ATDist < 48)
				{
					Velocity.Z = TDist * 15;
					Acceleration.Z = TDist * 15;
				}
				else if (ATDist < 96)
				{
					Velocity.Z = TDist * 30;
					Acceleration.Z = TDist * 30;
				}
				else
				{
					Velocity.Z = TDist * 60;
					Acceleration.Z = TDist * 60;
				}
			}
			else
			{
				if (ATDist < 32)
				{
					Velocity.Z = Velocity.Z * 0.85;
					Acceleration.Z = Acceleration.Z * 0.85;
				}
				else
				{
					Velocity.Z = TDist;
					Acceleration.Z = TDist;
				}
			}
		}
		
		if ((!bWallCrammed) && (TargetX != 0 || TargetY != 0))
		{
			TNorm.X = Velocity.X;
			TNorm.Y = Velocity.Y;
			TNorm.Z = Velocity.Z;
			
			SetRotation(Rotator(TNorm));
		}
		
		if (bDoorGhosting)
		{
			Velocity *= 4;
			Acceleration *= 4;
			if (VSize(DoorGhostLoc-Location)-Abs(DoorGhostLoc.Z-Location.Z) < 32)
			{
				bDoorGhosting = false;
				DoorGhostLoc = vect(0,0,0);
				
				SetCollision(True, True, False);
				if (!FastTrace(Location+vect(1,0,0), Location))
				{
					if (!SpawnBehindPlayer())
					{
						SetLocation(FirstLocation);
					}
				}
				bCollideWorld = true;
				
				FakePickDestination();
				if (GuardedOther != None)
				{
					MEGHIssueOrder('MeghFollowing', GuardedOther);
				}
				else
				{
					MEGHIssueOrder('MeghFollowing', GetLastVMP());
				}
			}
		}
	}
	
	Super.Tick(DT);
}

//MADDERS, 7/15/24: Stop destroying us. Try to shove us back where we belong.
event FellOutOfWorld()
{
	if (!SpawnBehindPlayer())
	{
		SetLocation(FirstLocation);
	}
}

function bool PlayerCanSee(DeusExPlayer DXP, Pawn TPawn)
{
	local bool bClearTrace;
	local int YawDiff, PitchDiff, TPitch, VPitch;
	local Rotator TRot, VRot;
	
	local Vector HitLoc, HitLoc2, HitNorm, HitNorm2;
	
	if (DXP == None) return false;
	
	if (TPawn == Self)
	{
		bClearTrace = FastTrace(DXP.Location, Location);
		
		TRot = Rotator(TPawn.Location - DXP.Location);
		VRot = DXP.ViewRotation;
		
		YawDiff = Abs((VRot.Yaw%65536) - (TRot.Yaw%65536));
		TPitch = TRot.Pitch;
		if (TPitch < 49152)
		{
			TPitch += 65536;
		}
		VPitch = VRot.Pitch;
		if (VPitch < 49152)
		{
			VPitch += 65536;
		}
		PitchDiff = Abs(VPitch - TPitch) % 65536;
		
		if (!bClearTrace)
		{
			if (VSize(DXP.Location - Location) > 1536)
			{
				return false;
			}
			
			Trace(HitLoc, HitNorm, DXP.Location, Location, false);
			Trace(HitLoc2, HitNorm2, Location, DXP.Location, false);
			
			if (VSize(HitLoc - HitLoc2) > 96)
			{
				return false;
			}
		}
		
		if ((YawDiff < 24576 || YawDiff > 40960) && (PitchDiff < 24576/2))
		{
			return true;
		}
	}
	else
	{
		return DXP.CanSee(TPawn);
	}
	
	return false;
}

function PlayMEGHDeathSound()
{
	local float GSpeed;
	local VMDBufferPlayer VMP;
	
	VMP = GetLastVMP();
	if (VMP != None)
	{
		GSpeed = 1.0;
		if ((Level != None) && (Level.Game != None))
		{
			GSpeed = Level.Game.GameSpeed;
		}
		
		VMP.PlaySound(sound'NanoSwordSelect', SLOT_Interface, 255,, 255, 3.0 * GSpeed);
		VMP.ClientMessage(SprintF(MsgMeghKilled, CustomName));
		
		VMP.VMDClearDroneData();
		VMDCleanFakeDroneActors();
	}
}

function VMDEMPHook()
{
	PlayMEGHDeathSound();
	
	SetPhysics(PHYS_Falling);
	AmbientSound = None;
	Multiskins[5] = Texture'VMDMeghProp01Still';
}

function Carcass SpawnCarcass()
{
	local DeusExWeapon DXW;
	
	if (EMPHitPoints > 0)
	{
		PlayMEGHDeathSound();
	}
	VMDMeghDropWeapon();
	
	return Super.SpawnCarcass();
}

function Destroyed()
{
	local string LastMapName;
	local VMDBufferPlayer VMP;
	
	VMP = GetLastVMP();
	if (VMP != None)
	{
		LastMapName = VMP.VMDGetMapName();
		if ((LastMapName == "16_HOTELCARONE_HOTEL") && (Health > 0) && (EMPHitPoints > 0) && (VMP.FlagBase != None) && (VMP.FlagBase.GetBool('mapdone')))
		{
			VMP.VMDEmergencyPackUpDrones(Self);
		}
	}
	
	Super.Destroyed();
}

function VMDCleanFakeDroneActors()
{
	local VMDMEGH UseMegh, TMegh;
	local VMDSIDD UseSidd, TSidd;
	
	local VMDFakeDestroyOtherPawn TDest;
	local VMDFakePathNode TPath;
	local VMDFakePatrolPoint TPat;
	
	forEach AllActors(class'VMDSIDD', TSidd)
	{
		if ((!TSidd.IsInState('Dying')) && (TSidd.EMPHitPoints > 0))
		{
			UseSidd = TSidd;
			break;
		}
	}
	forEach AllActors(class'VMDMEGH', TMegh)
	{
		if ((TMegh != Self) && (!TMegh.IsInState('Dying')) && (TMegh.EMPHitPoints > 0))
		{
			UseMegh = TMegh;
			break;
		}
	}
	
	if ((UseSidd == None) && (UseMegh == None))
	{
		forEach AllActors(class'VMDFakeDestroyOtherPawn', TDest)
		{
			TDest.Destroy();
		}
	}
	
	forEach AllActors(class'VMDFakePathNode', TPath)
	{
		TPath.Destroy();
	}
	forEach AllActors(class'VMDFakePatrolPoint', TPat)
	{
		TPat.Destroy();
	}
}

function ClearPatrolPoints()
{
	local VMDFakePatrolPoint TPat;
	
	forEach AllActors(class'VMDFakePatrolPoint', TPat)
	{
		TPat.Destroy();
	}
}

function AllianceInfoEx GetAllEx(int i)
{
	return AlliancesEx[i];
}

function AllianceInfoEx GetCachedAll(int i)
{
	return AlliancesEx[i];
}

function MatchAlliances(ScriptedPawn SP)
{
	local int i;
	local AllianceInfoEx TAll;
	
	if (SP == None) return;
	
	for(i=0; i<ArrayCount(AlliancesEx); i++)
	{
		if (VMDMEGH(SP) != None)
		{
			TAll = VMDMEGH(SP).GetAllEx(i);
			AlliancesEx[i] = TAll;
			TAll = VMDMEGH(SP).GetCachedAll(i);
			CachedAlliances[i] = TAll;
		}
		if (VMDSIDD(SP) != None)
		{
			TAll = VMDSIDD(SP).GetAllEx(i);
			AlliancesEx[i] = TAll;
			TAll = VMDSIDD(SP).GetCachedAll(i);
			CachedAlliances[i] = TAll;
		}
	}
}

function float ComputeActorVisibility(actor seeActor)
{
	local float visibility;
	local VMDBufferPawn VMBP;
	
	VMBP = VMDBufferPawn(SeeActor);
	if (DeusExPlayer(SeeActor) != None)
	{
		visibility = DeusExPlayer(seeActor).CalculatePlayerVisibility(self);	
	}
	else if (VMBP != None)
	{
		Visibility = 1.0;
		if (VMBP.bCloakOn)
		{
			Visibility = 0.0;
		}
	}
	else
	{
		visibility = 1.0;
	}
	
	return (visibility);
}

defaultproperties
{
     MaxRange=240.000000
     MinRange=0.000000
     
     MsgMeghKilled="ERROR: Lost connection to %s!"
     BritishTextTargetAcquired(0)="Piss off, you bloody muppet!"
     BritishTextTargetAcquired(1)="What a gormless prick!"
     BritishTextTargetAcquired(2)="Initiating london handshake..."
     BritishTextTargetAcquired(3)="Another feckin idiot!"
     BritishTextTargetAcquired(4)="One more plonker for the pile!"
     
     SoundRadius=8
     SoundVolume=56
     AmbientSound=Sound'VMDMeghPropeller'
     SoundPitch=64
     CustomName="M.E.G.H."
     
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.SecurityBot3TargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.SecurityBot3TargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.SecurityBot3OutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.SecurityBot3CriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.SecurityBot3Scanning'
     
     Orders=MeghFollowing
     Physics=PHYS_Flying
     bBlockPlayers=False
     bCanFly=True
     HitboxArchetype="Roller"
     bKeepWeaponDrawn=False //Used to be true, but now recon mode handles this.
     SpeechTargetAcquired=Sound'DeusExSounds.Robot.SecurityBot3TargetAcquired'
     SpeechTargetLost=Sound'DeusExSounds.Robot.SecurityBot3TargetLost'
     SpeechOutOfAmmo=Sound'DeusExSounds.Robot.SecurityBot3OutOfAmmo'
     SpeechCriticalDamage=Sound'DeusExSounds.Robot.SecurityBot3CriticalDamage'
     SpeechScanning=Sound'DeusExSounds.Robot.SecurityBot3Scanning'
     
     explosionSound=Sound'DeusExSounds.Robot.SecurityBot2Explode'
     WalkingSpeed=1.000000
     bCanOpenDoors=True
     Intelligence=BRAINS_HUMAN
     bEmitDistress=False
     bAimForHead=True
     InitialInventory(0)=(Inventory=None)
     InitialInventory(1)=(Inventory=None, Count=1)
     Alliance=PlayerDrone //HACK!
     InitialAlliances(0)=(AllianceName=Player,AllianceLevel=1.000000,bPermanent=True)
     InitialAlliances(1)=(AllianceName=PaulDenton,AllianceLevel=1.000000,bPermanent=True)
     WalkSound=None
     GroundSpeed=250.000000
     WaterSpeed=250.000000
     AirSpeed=250.000000
     AccelRate=500.000000
     Health=25
     EMPHitPoints=100
     UnderWaterTime=20.000000
     AttitudeToPlayer=ATTITUDE_Ignore
     DrawType=DT_Mesh
     Mesh=LodMesh'VMDHelidronePistol'
     CollisionRadius=12.000000
     CollisionHeight=8.500000
     Mass=50.000000
     Buoyancy=25.000000
     BindName="VMDMEGH"
     FamiliarName="M.E.G.H."
     UnfamiliarName="M.E.G.H."
     MaxStepHeight=20.000000 // Transcended - Added
     BaseEyeHeight=4.2500000
}
