//=============================================================================
// VMDBountyHunter.
//=============================================================================
class VMDBountyHunter extends HumanMilitary
	abstract;

var bool bSprungAmbush;
var int AssignedID, LastCheckDir;
var string HunterBarkBindName, HunterConversationPackage;
var Rotator LastCheckRot;

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
  		
  		bSetupBuffedHealth = True;
		
		if (VMP.bRecognizeMovedObjectsEnabled)
		{
			bRecognizeMovedObjects = true;
		}
		if (VMP.bEnemyAlwaysAvoidProj)
		{
			bAvoidHarm = true;
			bReactProjectiles = true;
		}
		DifficultyVisionRangeMult = FMin(2.5, VMP.EnemyVisionRangeMult + 0.5);
		
		if (!bBuffedSenses)
		{
			VisibilityThreshold = FMax(VisibilityThreshold * VMP.EnemyVisionStrengthMult,  0.0025);
			if (!VMDHasHearingExtensionObjection())
			{
				HearingThreshold = FMax(HearingThreshold * (VMP.EnemyHearingRangeMult - 0.1), 0.0375);
			}
			bBuffedSenses = true;
		}
		
		SurprisePeriod = FMin(SurprisePeriod, FMax(VMP.EnemySurprisePeriodMax - 0.5, 0.50));
		
		DifficultyExtraSearchSteps = VMP.EnemyExtraSearchSteps+2;
		DifficultyROFWeight = FMax(-0.15, VMP.EnemyROFWeight - 0.05);
		DifficultyReactionSpeedMult = FMin(3.0, VMP.EnemyReactionSpeedMult + 0.5);
		EnemyGuessingFudge = FMin(0.65, VMP.EnemyGuessingFudge + 0.15);
		if (!bBuffedAccuracy)
		{
			//MADDERS, 6/26/24: These guys use accurate weapons that also get accuracy mods. Don't fuck it up.
			if (MJ12NanoaugBountyHunter(Self) != None)
			{
				BaseAccuracy = FMax(FMin(VMP.EnemyAccuracyMod, BaseAccuracy), -0.35);
			}
			else
			{
				BaseAccuracy = FMax(FMin(VMP.EnemyAccuracyMod - 0.15, BaseAccuracy), -0.35);
			}
			bBuffedAccuracy = true;
		}
		StartingBaseAccuracy = BaseAccuracy;
 	}
	
	if ((MinHealth > 1) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Enemy Damage Gate")))
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

function InitializeBountyHunter(int HunterIndex, VMDBufferPlayer VMP, int MissionNumber)
{
	local int AllianceCounts[8], BestAmount, i;
	local name AlliancesList[8];
	local Pawn TPawn;
	local VMDBufferPawn VMBP, BestPawn, Representatives[8];
	
	for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		if (!TPawn.bDeleteMe)
		{
			VMBP = VMDBufferPawn(TPawn);
			if ((VMBP != None) && (VMBP.GetAllianceType('Player') == ALLIANCE_Hostile))
			{
				for (i=0; i<ArrayCount(AlliancesList); i++)
				{
					if (AlliancesList[i] == VMBP.Alliance)
					{
						AllianceCounts[i] += 1;
						break;
					}
					else if (AlliancesList[i] == '')
					{
						Representatives[i] = VMBP;
						AlliancesList[i] = VMBP.Alliance;
						AllianceCounts[i] = 1;
						break;
					}
				}
			}
		}
	}
	
	for(i=0; i<ArrayCount(AlliancesList); i++)
	{
		if (AllianceCounts[i] > BestAmount)
		{
			BestAmount = AllianceCounts[i];
			BestPawn = Representatives[i];
		}
	}
	
	if (BestPawn != None)
	{
		Alliance = BestPawn.Alliance;
		ChangeAlly(Alliance, 1.0, true);
		ChangeAlly('Player', -1.0, true);
		for (i=0; i<ArrayCount(AlliancesEx); i++)
		{
			ChangeAlly(BestPawn.VMDGetAllianceName(i), BestPawn.VMDGetAllianceLevel(i), BestPawn.VMDGetAlliancePermanent(i));
		}
	}
	else
	{
		Alliance = 'BountyHunter';
		ChangeAlly(Alliance, 1.0, true);
		ChangeAlly('Player', -1.0, true);
	}
	
	VMDUpdateHunterBarks();
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	VMDUpdateHunterBarks();
}

function VMDUpdateHunterBarks()
{
	local string OldPackageName;
	local DeusExLevelInfo DXLI;
	
	//MADDERS, 6/22/24: Universal bark loading. Devious, but effective.
	forEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		OldPackageName = DXLI.ConversationPackage;
		BarkBindName = HunterBarkBindName;
		DXLI.ConversationPackage = HunterConversationPackage;
		ConBindEvents();
		DXLI.ConversationPackage = OldPackageName;
		break;
	}
}

function bool AddToInitialInventory(class<Inventory> NewClass, int NewCount, optional bool bAllowDuplicates)
{
	local int i, j, k, TCopies;
	local Vector TOffset;
	local DeusExAmmo DXA;
	local DeusExWeapon DXW;
	local Inventory Inv, TItem;
	
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
		if (class<Credits>(NewClass) != None)
		{
			inv = FindInventoryType(NewClass);
			if (inv != None)
			{
				Credits(inv).NumCopies += 1;
			}
		}
		if (class<DeusExPickup>(NewClass) != None)
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
		if (class<DeusExWeapon>(NewClass) != None)
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
			if ((Weapon(Inv) != None) && (DeusExAmmo(Weapon(Inv).AmmoType) != None)) DeusExAmmo(Weapon.AmmoType).bCrateSummoned = true;
			if (DeusExAmmo(Inv) != None) DeusExAmmo(Inv).bCrateSummoned = true;
			if (DeusExPickup(Inv) != None) DeusExPickup(Inv).NumCopies = TCopies;
			
			if (DeusExWeapon(Inv) != None)
			{
				VMDModAddWeaponMods(DeusExWeapon(Inv));
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
	
	PostSpecialStatCheck();
	return false;
}

function VMDModAddWeaponMods(DeusExWeapon DXW);

function bool AddExactAmountToInitialInventory(class<Inventory> NewClass, int NewCount)
{
	local int i,  j, k;
	local Vector TOffset;
	local Inventory Inv;
	
	inv = None;
	if (Class<Ammo>(NewClass) != None)
	{
		inv = FindInventoryType(NewClass);
		if (inv != None)
		{
			Ammo(inv).AmmoAmount = NewCount;
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
		if (DeusExAmmo(Inv) != None)
		{
			DeusExAmmo(Inv).bCrateSummoned = true;
			DeusExAmmo(Inv).AmmoAmount = NewCount;
		}
		
		if (inv != None)
		{
			inv.InitialState = 'Idle2';
			inv.GiveTo(Self);
			inv.SetBase(Self);
			
			PostSpecialStatCheck();
			return true;
		}
	}
	
	PostSpecialStatCheck();
	return false;
}

State Attacking
{
	function BeginState()
	{
		Super.BeginState();
		
		if (VMDBufferPlayer(Enemy) != None)
		{
			bSprungAmbush = true;
		}
	}
}

function bool SetEnemy(Pawn NewEnemy, optional float newSeenTime, optional bool bForce)
{
	local bool Ret;
	
	Ret = Super.SetEnemy(NewEnemy, NewSeenTime, bForce);
	
	if ((Ret) && (VMDBufferPlayer(NewEnemy) != None))
	{
		bSprungAmbush = true;
	}
	
	return Ret;
}

state Standing
{
Begin:
	WaitForLanding();
	if (!bUseHome)
		Goto('StartStand');

MoveToBase:
	if (!IsPointInCylinder(self, HomeLoc, 16-CollisionRadius))
	{
		EnableCheckDestLoc(true);
		while (true)
		{
			if (PointReachable(HomeLoc))
			{
				if (ShouldPlayWalk(HomeLoc))
					PlayWalking();
				MoveTo(HomeLoc, GetWalkingSpeed());
				CheckDestLoc(HomeLoc);
				break;
			}
			else
			{
				MoveTarget = FindPathTo(HomeLoc);
				if (MoveTarget != None)
				{
					if (ShouldPlayWalk(MoveTarget.Location))
						PlayWalking();
					MoveToward(MoveTarget, GetWalkingSpeed());
					CheckDestLoc(MoveTarget.Location, true);
				}
				else
					break;
			}
		}
		EnableCheckDestLoc(false);
	}
	TurnTo(Location+HomeRot);

StartStand:
	Acceleration=vect(0,0,0);
	Goto('Stand');

ContinueFromDoor:
	Goto('MoveToBase');

Stand:
ContinueStand:
	// nil
	//bStasis = True; //MADDERS, 6/25/24: Keep us active, please.
	
	PlayWaiting();
	Sleep(4+(FRand()*6));

Fidget:
	//TurnTo(Location + Vector(Rotation + Rot(0, 16384, 0)));
	//TurnTo(Location + (Vect(1,0,0) * (FRand() - 0.5)) + (Vect(0,1,0) * (FRand() - 0.5)));
	LastCheckRot = GetCheckCoastLocation(LastCheckDir);
	if (ShouldPlayTurn(Location + Vector(LastCheckRot)))
	{
		PlayTurning();
	}
	TurnTo(Location + Vector(LastCheckRot));
	Goto('Stand');

DoNothing:
	// nil
}

//This is crap, but check what spots around us need peeking at.
//Store this as a way to tilt our head, and also a place to look towards.
function Rotator GetCheckCoastLocation(out int LookDir)
{
	local bool bTraceWin;
	local int i, NumValidRots;
	local Vector StartLoc, EndLoc;
	local Rotator TRot, ValidRotations[6];
	
	//Start by checking at least 45 degrees of our location, until we've done a 270 around.
	StartLoc = Location;
	for(i=0; i<ArrayCount(ValidRotations); i++)
	{
		TRot.Yaw = Rotation.Yaw + (8192 * (i+1));
		EndLoc = StartLoc + (Vector(TRot) * 160);
		bTraceWin = FastTrace(EndLoc, StartLoc);
		
		if (bTraceWin)
		{
			ValidRotations[NumValidRots] = TRot;
			NumValidRots++;
		}
	}
	
	//If we found some empty spaces to check, pick one at random. Otherwise fuck around.
	if (NumValidRots > 0)
	{
		TRot = ValidRotations[Rand(NumValidRots)];
	}
	else
	{
		TRot.Yaw = Rotation.Yaw + Rand(49152);
	}
	
	//For our direction, higher yaw is clockwise, lower rot is counter clockwise.
	if (TRot.Yaw > Rotation.Yaw)
	{
		LookDir = 1; //Right
	}
	else if (TRot.Yaw < Rotation.Yaw)
	{
		LookDir = -1; //Left
	}
	
	//If we shot over 180 degrees past our goal, treat it as reverse, because our look to function will.
	if (Abs(TRot.Yaw - Rotation.Yaw) > 32768)
	{
		LookDir *= -1;
	}
	
	return TRot;
}

function HandleSighting(Pawn pawnSighted)
{
	local VMDBufferPawn VMBP;
	
	//MADDERS, 6/29/24: Similar to status alert, but permanent.
	//If we see the player, leap on them ASAP.
	if (SetEnemy(PawnSighted))
	{
		SetDistressTimer();
		HandleEnemy();
	}
	else
	{
		SetSeekLocation(pawnSighted, pawnSighted.Location, SEEKTYPE_Sight);
		GotoState('Seeking');
	}
}

function HandleLoudNoise(Name event, EAIEventState state, XAIParams params)
{
	// React
	local Actor bestActor;
	local Pawn  instigator;
	
	if (state == EAISTATE_Begin || state == EAISTATE_Pulse)
	{
		bestActor = params.bestActor;
		if (bestActor != None)
		{
			instigator = Pawn(bestActor);
			if (instigator == None)
			{
				instigator = bestActor.Instigator;
			}
			if (instigator != None)
			{
				if (IsValidEnemy(instigator))
				{
					if ((VMDBufferPlayer(Instigator) != None) && (!bSprungAmbush))
					{
						SetEnemy(VMDBufferPlayer(Instigator));
						SetOrders('Attacking',, true);
					}
					else
					{
						SetSeekLocation(instigator, bestActor.Location, SEEKTYPE_Sound);
						HandleEnemy();
					}
				}
			}
		}
	}
}

defaultproperties
{
     MinHealth=0.000000
     bLeaveAfterFleeing=True //This stops us from raising allure. We're backing off for a while.
     RaiseAlarm=RAISEALARM_Never
     bFearHacking=False
     bFearWeapon=False
     bFearShot=False
     bFearInjury=False
     bFearIndirectInjury=False
     bFearCarcass=False
     bFearDistress=False
     bFearAlarm=False
     bFearProjectiles=False
     
     Orders=Standing
     HunterConversationPackage="VMDBountyHunterConversations"
     MedicineSkillLevel=2
     EnviroSkillLevel=2
     CarcassType=Class'VMDBountyHunterSuperCarcass'
}
