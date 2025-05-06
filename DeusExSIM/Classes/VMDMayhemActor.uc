//=============================================================================
// VMDMayhemActor.
//=============================================================================
class VMDMayhemActor extends VMDFillerActors;

var bool bRanTweaks, bRevisionMapSet;
var int RandIndex, RandBarf[100], AltRandIndex, AltRandBarf[100];
var float TweakTimer;

var VMDBufferPlayer VMP;

function VMDUpdateRevisionMapStatus()
{
	bRevisionMapSet = false;
}

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (!bRanTweaks)
	{
 		if (TweakTimer < 0.6)
		{
			TweakTimer += DT;
		}
		else if (TweakTimer > -10)
 		{
 	 		TweakTimer = -30;
			CommitMayhemBuffing();
	 	}
	}
}

function InitRandData(VMDBufferPlayer VMP)
{
	local int i, CurRip, MySeed, MyAltSeed;
	local float TMission;
	local class<VMDStaticFunctions> SF;
	
	SF = class'VMDStaticFunctions';
	TMission = VMDGetMissionNumber();
	
	MySeed = SF.Static.DeriveStableMayhemSeed(Self, 32, true);
	MyAltSeed = int( float(SF.Static.DeriveMayhemGrenadeSeed(Self, 32, true)) * (TMission + Sqrt(TMission)) ) % 32;
	for(i=0; i<ArrayCount(RandBarf); i++)
	{
		CurRip = SF.Static.RipLongSeedChunk(MySeed, i);
		RandBarf[i] = CurRip;
		CurRip = SF.Static.RipLongSeedChunk(MyAltSeed, i);
		AltRandBarf[i] = CurRip;
	}
}

function float FakeFRand()
{
	local float Ret;
	
	Ret = float(RandBarf[RandIndex]) / 100.0;
	RandIndex = (RandIndex+1)%ArrayCount(RandBarf);
	
	return Ret;
}

function float FakeRand(int Ceil)
{
	local int Ret;
	
	Ret = RandBarf[RandIndex] % Ceil;
	RandIndex = (RandIndex+1)%ArrayCount(RandBarf);
	
	return Ret;
}

function float AltFakeFRand()
{
	local float Ret;
	
	Ret = float(AltRandBarf[AltRandIndex]) / 100.0;
	AltRandIndex = (AltRandIndex+1)%ArrayCount(AltRandBarf);
	
	return Ret;
}

function float AltFakeRand(int Ceil)
{
	local int Ret;
	
	Ret = AltRandBarf[AltRandIndex] % Ceil;
	AltRandIndex = (AltRandIndex+1)%ArrayCount(AltRandBarf);
	
	return Ret;
}

function CommitMayhemBuffing()
{
	local int StartMayhem, TMayhem, NumSpawns, i, TSpawnLimit, TIndex, SpawnWeight[64], AlreadySpawned[64];
	local VMDBufferPawn SP, StoredSpawns[64];
	
	bRanTweaks = true;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None)
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
	}
	
	if (VMP == None || !VMP.bMayhemSystemEnabled) return;
	
	InitRandData(VMP);
	
	StartMayhem = VMP.MayhemFactor;
	TMayhem = StartMayhem;
	
	if (StartMayhem < 1) return;
	
	if ((TMayhem >= 75) && (VMP.bMayhemGrenadesEnabled))
	{
		TMayhem = SpawnMapSpecificGrenades(TMayhem);
	}
	
	forEach AllActors(class'VMDBufferPawn', SP)
	{
		if ((NumSpawns < ArrayCount(StoredSpawns)) && (CanReinforcePawn(SP)))
		{
			SpawnWeight[NumSpawns] = DeriveSpawnWeight(SP);
			StoredSpawns[NumSpawns] = SP;
			NumSpawns++;
			if (NumSpawns >= ArrayCount(StoredSpawns)) break;
		}
	}
	
	TSpawnLimit = int(NumSpawns*1.25);
	for(i=0; i<TSpawnLimit; i++)
	{
		TIndex = FakeRand(NumSpawns);
		if (AlreadySpawned[TIndex] > 1 || (AlreadySpawned[TIndex] > 0 && StoredSpawns[TIndex].IsInState('Standing')))
		{
			continue;
		}
		else
		{
			TMayhem -= UpgradePawnAmmo(StoredSpawns[TIndex], StartMayhem, TMayhem);
			
			if (ReinforcePawn(StoredSpawns[TIndex], SpawnWeight[TIndex], StartMayhem))
			{
				//MADDERS, 10/27/22: Wandering looks like shit. Do it at the minimum rate.
				if (StoredSpawns[TIndex].Orders == 'Wandering')
				{
					AlreadySpawned[TIndex] += 2;
				}
				AlreadySpawned[TIndex]++;
				TMayhem -= SpawnWeight[TIndex];
			}
		}
		
		if (TMayhem <= 0)
		{
			break;
		}
	}
}

function bool CanReinforcePawn(VMDBufferPawn SP)
{
	if (SP == None)
	{
		return false;
	}
	
	//MADDERS, 5/29/22: Cloning important NPCs? Bad.
	if (SP.Default.bImportant)
	{
		return false;
	}
	if (SP.Default.bInvincible || SP.bInvincible)
	{
		return false;
	}
	
	//MADDERS, 4/23/24: Not default bImportant. Rookie mistake.
	//Also, leave out bounty hunters because they're a special case.
	if (SP.IsA('Boss') || SP.IsA('MrVenom') || SP.IsA('VMDBountyHunter'))
	{
		return false;
	}
	
	//MADDERS, 9/17/22: Reinforce UNATCO troops anyways on 04_NSFHQ.
	if ((VMDGetMapName() == "04_NYC_NSFHQ") && (SP.IsA('UNATCOTroop')))
	{
		//MADDERS, 11/4/22: Except this guy. Blocks the doors.
		if (class'VMDStaticFunctions'.Static.StripBaseActorSeed(SP) == 2)
		{
			return false;
		}
		return true;
	}
	
	//MADDERS, 2/27/25: These guys can spawn janky NPC placements, so don't reinforce.
	if ((VMDGetMapName() == "UNDERGROUND_LAB2") && (SP.IsA('MJ12Troop')))
	{
		switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(SP))
		{
			case 3:
			case 4:
				return false;
			break;
		}
		return true;
	}
	
	//MADDERS, 11/4/22: Don't reinforce the ones that are a MAJOR dick move for completion of the level.
	//Rest is fair game.
	if ((VMDGetMapName() == "05_NYC_UNATCOMJ12LAB") && (SP.IsA('MJ12Troop')))
	{
		switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(SP))
		{
			case 7:
			case 11: //Bottom armory guy added 12/7/23. *I* have a hard time playing through it, especially with new AI.
				 //Top + Bottom both being multiple in some seeds can make success come down to RNG (where they get placed, how many you get).
				 //This is bullshit and I can't ask other people to put up with this.
			case 12:
				return false;
			break;
			default:
			break;
		}
	}
	
	//MADDERS, 8/7/2023: Reinforce versalife now, too.
	//Rest is fair game.
	if ((VMDGetMapName() == "06_HONGKONG_VERSALIFE") && (SP.IsA('Cop')))
	{
		return true;
		/*switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(SP))
		{
			default:
			break;
		}*/
	}
	
	//MADDERS, 8/7/2023: Reinforce mj12 lab with it.
	//Rest is fair game.
	if ((VMDGetMapName() == "06_HONGKONG_MJ12LAB") && (SP.IsA('MJ12Troop') || SP.IsA('MJ12Commando') || SP.IsA('MIB') || SP.IsA('WIB')))
	{
		return true;
		/*switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(SP))
		{
			default:
			break;
		}*/
	}
	
	//MADDERS, 9/17/22: Moved here so we can use the UNATCO cheat.
	if (SP.GetPawnAllianceType(VMP) != ALLIANCE_Hostile)
	{
		return false;
	}
	
	//MADDERS, 5/29/22: Yeah, let's not do this on dudes who aren't even in yet, capeesh?
	if (!SP.bInWorld)
	{
		return false;
	}
	
	//MADDERS, 5/29/22: No gun wielding secretaries, thank you.
	if ((!SP.IsA('HumanMilitary')) && (!SP.IsA('HumanThug')))
	{
		return false;
	}
	
	//MADDERS, 5/27/22: These are not deployed as guards. Do not reinforce them.
	//5/29/22 UPDATE: Don't allow mil bots. We're just too big to spawn elegantly.
	if (SP.IsA('Greasel') || SP.IsA('Karkian') || SP.IsA('Gray') || SP.IsA('SpiderBot') || SP.IsA('MilitaryBot'))
	{
		return false;
	}
	
	//MADDERS, 5/27/22: Do not add more robots to vandenberg command, thanks.
	if ((SP.IsA('Robot')) && (VMDGetMapName() == "12_VANDENBERG_CMD"))
	{
		return false;
	}
	
	return true;
}

function int DeriveSpawnWeight(VMDBufferPawn SP)
{
	if (SP.IsA('MJ12Commando'))
	{
		return 3;
	}
	if (SP.IsA('MIB') || SP.IsA('WIB'))
	{
		return 4;
	}
	if (SP.IsA('MilitaryBot'))
	{
		return 10;
	}
	if (SP.IsA('Robot'))
	{
		return 5;
	}
	if (SP.IsA('MJ12Troop'))
	{
		return 2;
	}
	
	return 2;
}

function bool ReinforcePawn(VMDBufferPawn SP, int TWeight, int TMayhem)
{
	local bool bCanGetCoolShit, bClearPlacement;
	local int i, InvStart, InvEnd;
	local float RotRand;
	local Vector TOffs, EndTrace, StartTrace;
	local Rotator RelRot;
	local class<Ammo> TAmmo;
	local Seat TSeat;
	local VMDBufferPawn TP;
	
	if (SP == None) return false;
	if (!ExactPawnCanBeDuped(SP, TSeat)) return false;
	
	//MADDERS, 6/9/23: New, more dynamic randomization. Less robotic is better, I would argue.
	for (i=0; i<8; i++)
	{
		RotRand = FakeFRand()*65536;
		RelRot.Yaw = RotRand;
		
		TOffs = (vect(1,0,0) * SP.CollisionRadius * 2.7) >> RelRot;
		StartTrace = SP.Location + TOffs + (vect(0,0,1) * SP.CollisionHeight);
		EndTrace = StartTrace - (SP.CollisionHeight * vect(0,0,2.25));
		
		bClearPlacement = !FastTrace(EndTrace, StartTrace);
		if (bClearPlacement)
		{
			TP = Spawn(SP.Class, SP.Owner, SP.Tag, SP.Location + TOffs, RelRot);
			if (TP != None)
			{
				if (TP.Location.Z > SP.Location.Z + 10)
				{
					TP.Destroy();
				}
				else
				{
					break;
				}
			}
		}
		else if (i == 7)
		{
			return false;
		}
	}
	
	if (TP != None)
	{
		TP.Orders = SP.Orders;
 		TP.OrderTag = SP.OrderTag;
		
		if (TP.Orders == 'Patrolling')
		{
			if (!RandomizePatrolStart(TP, TP.OrderTag))
			{
				TP.Destroy();
				return false;
			}
		}
		if (SP.Orders == 'Sitting')
		{
			TP.Orders = 'Standing';
			TP.OrderTag = '';
		}
		if (SP.Orders == 'Standing')
		{
			TP.Orders = 'Wandering';
		}
		
		TP.RaiseAlarm = SP.RaiseAlarm;
		TP.bKeepWeaponDrawn = SP.bKeepWeaponDrawn;
		
		TP.bBuffedVision = SP.bBuffedVision;
		TP.bBuffedSenses = SP.bBuffedSenses;
		TP.bBuffedAccuracy = SP.bBuffedAccuracy;
		
		TP.BaseAccuracy = SP.BaseAccuracy;
		TP.HearingThreshold = SP.VisibilityThreshold;
		TP.VisibilityThreshold = SP.VisibilityThreshold;
		TP.AIHorizontalFov = SP.AIHorizontalFov;
		TP.SightRadius = SP.SightRadius;
		
		TP.bHateHacking = SP.bHateHacking;
		TP.bHateWeapon = SP.bHateWeapon;
		TP.bHateShot = SP.bHateShot;
		TP.bHateInjury = SP.bHateInjury;
		TP.bHateIndirectInjury = SP.bHateIndirectInjury;
		TP.bHateCarcass = SP.bHateCarcass;
		TP.bHateDistress = SP.bHateDistress;
		
		TP.bReactFutz = SP.bReactFutz;
		TP.bReactPresence = SP.bReactPresence;
		TP.bReactLoudNoise = SP.bReactLoudNoise;
		TP.bReactAlarm = SP.bReactAlarm;
		TP.bReactShot = SP.bReactShot;
		TP.bReactCarcass = SP.bReactCarcass;
		TP.bReactProjectiles = SP.bReactProjectiles;
		TP.bReactDistress = SP.bReactDistress;
		
		TP.bFearHacking = SP.bFearHacking;
		TP.bFearWeapon = SP.bFearWeapon;
		TP.bFearShot = SP.bFearShot;
		TP.bFearInjury = SP.bFearInjury;
		TP.bFearIndirectInjury = SP.bFearIndirectInjury;
		TP.bFearCarcass = SP.bFearCarcass;
		TP.bFearDistress = False;
		TP.bFearAlarm = SP.bFearAlarm;
		TP.bFearProjectiles = SP.bFearProjectiles;
		
		TP.Alliance = SP.Alliance;
		
		switch(SP.BindName)
		{
			case "NSFHQBalconyGuard":
				TP.BindName = "UNATCOCrimeSceneGuard";
			break;
			default:
				TP.BindName = SP.BindName;
			break;
		}
		TP.BarkBindName = SP.BarkBindName;
		TP.ConBindEvents();
		
		//Please do not give flamethrowers and armor to dogs, thank you.
		//(Robot(TP) == None) && (Animal(TP) == None) && 
		bCanGetCoolShit = ((MJ12Commando(TP) == None) && (Terrorist(TP) != None || HumanMilitary(TP) != None));
		
		if (bCanGetCoolShit)
		{
			if (TMayhem < 25 || TP.IsA('HumanCivilian'))
			{
				TP.InitialInventory[0].Inventory = ObtainLowLevelWeapon(TP, TAmmo);
				TP.InitialInventory[0].Count = 1;
				TP.InitialInventory[1].Inventory = TAmmo;
				TP.InitialInventory[1].Count = 12;
				
				InvStart = 2;
			}
			else if (TMayhem >= 75)
			{
				TP.InitialInventory[0].Inventory = ObtainHighLevelWeapon(TP, TAmmo);
				TP.InitialInventory[0].Count = 1;
				
				switch(TP.InitialInventory[0].Inventory.Name)
				{
					case 'WeaponRifle':
					case 'WeaponLAW':
					case 'WeaponGEPGun':
						TP.BaseAccuracy = FMax(-0.35, TP.BaseAccuracy-0.35);
					case 'WeaponAssaultGun':
					case 'WeaponAssaultShotgun':
					case 'WeaponSawedOffShotgun':
					case 'WeaponPlasmaRifle':
					case 'WeaponFlamethrower':
						TP.bKeepWeaponDrawn = true;
					break;
				}
				
				TP.InitialInventory[1].Inventory = TAmmo;
				TP.InitialInventory[1].Count = 12;
				
				InvStart = 2;
			}
		}
		
		for(i=0; i<8; i++)
		{
			if ((i >= InvStart) && (SP.bItemUnnatural[i] == 0))
			{
				TP.InitialInventory[i] = SP.InitialInventory[i];
			}
			TP.InitialAlliances[i] = SP.InitialAlliances[i];
			
			if (TP.InitialInventory[i].Inventory != None)
			{
				InvEnd = i;
			}
		}
		
		if (bCanGetCoolShit)
		{
			if (InvEnd < 7)
			{
				if (TMayhem >= 65)
				{
					TP.AddToInitialInventory(ObtainHighLevelPickup(TP), 1);
					
					InvEnd++;
				}
				if (TMayhem >= 50)
				{
					TP.AddToInitialInventory(ObtainMediumLevelPickup(TP), 1);
					
					InvEnd++;
				}
				if (TMayhem >= 35)
				{
					TP.AddToInitialInventory(ObtainLowLevelPickup(TP), 1);
					
					InvEnd++;
				}
			}
		}
		
	  	TP.CheckForHelmets();
	  	TP.RunModInvChecks();
	  	TP.bAppliedSpecial = True;
	  	
	  	//------------------
	  	//MADDERS: Store these for drug effects!
	  	TP.StoredScaleGlow = ScaleGlow;
	  	TP.StoredFatness = Fatness;
		
		//MADDERS, 6/6/22: Total bullshit ensues. Dudes in chairs can't have alliances reliably cloned.
		TP.ChangeAlly(TP.Alliance, 1, true);
		if (TSeat != None)
		{
			TP.Orders = 'Sitting';
			TP.OrderTag = TSeat.Tag;
			
			TP.SeatActor = TSeat;
			TP.SetOrders('Sitting',, true);
			TP.ResetReactions();
		}
		
		//MADDERS, 10/17/24: Randomize our appearance with a dedicated function now.
		//Combined with Bogie's skin work, this keeps things feeling fresh.
		TP.VMDRandomizeAppearance();
		
		return true;
	}
	
	return false;
}

function bool HasWeapon(ScriptedPawn TPawn)
{
	local int i;
	local bool bWeapon, bAmmo;
	local class<Inventory> TInv;
	local class<DeusExWeapon> TWep;
	local class<DeusExAmmo> TAmm;
	
	if (TPawn == None) return false;
	
	for(i=0; i<ArrayCount(TPawn.InitialInventory); i++)
	{
		if (TPawn.InitialInventory[i].Count > 0)
		{
			TInv = TPawn.InitialInventory[i].Inventory;
			TWep = class<DeusExWeapon>(TInv);
			TAmm = class<DeusExAmmo>(TInv);
			if (TWep != None)
			{
				bWeapon = true;
			}
			else if (TAmm != None)
			{
				bAmmo = true;
			}
		}
		
		if ((bWeapon) && (bAmmo))
		{
			break;
		}
	}
	
	return (bWeapon && bAmmo);
}

function int UpgradePawnAmmo(ScriptedPawn TPawn, int StartMayhem, int TMayhem)
{
	local int i, BuffCount, TMission;
	local class<DeusExWeapon> LastWeapon;
	local class<Inventory> TInv;
	local VMDBufferPawn VMBP;
	
	//MADDERS, 1/4/24: Use alt ammos left often.
	if (TPawn == None || StartMayhem < 65 || TMayhem < 35 || FRand() < 0.4)
	{
		return 0;
	}
	if (MJ12Commando(TPawn) != None || (Terrorist(TPawn) == None && HumanMilitary(TPawn) == None))
	{
		return 0;
	}
	
	VMBP = VMDBufferPawn(TPawn);
	TMission = VMDGetMissionNumber();
	
	if (VMBP != None)
	{
		VMBP.CheckForHelmets();
	  	VMBP.ApplySpecialStats();
	  	//VMBP.PostSpecialStatCheck();
	  	VMBP.RunModInvChecks();
	  	VMBP.bAppliedSpecial = True;
	  	
	  	//------------------
	  	//MADDERS: Store these for drug effects!
	  	VMBP.StoredScaleGlow = ScaleGlow;
	  	VMBP.StoredFatness = Fatness;
	}
	for(i=0; i<8; i++)
	{
		TInv = TPawn.InitialInventory[i].Inventory;
		if (class<DeusExAmmo>(TInv) != None)
		{
			switch(TInv.Name)
			{
				case 'AmmoShell':
					if (FakeRand(2) == 0)
					{
						if ((LastWeapon == class'WeaponSawedOffShotgun') && (TMission > 5))
						{
							ForceLoadAmmo(TPawn, class'AmmoTaserSlug', TPawn.InitialInventory[i].Count);
							BuffCount++;
						}
						else if ((LastWeapon == class'WeaponAssaultShotgun') && (TMission > 9))
						{
							ForceLoadAmmo(TPawn, class'AmmoDragonsBreath', TPawn.InitialInventory[i].Count);
							BuffCount++;
						}
					}
					else
					{
						ForceLoadAmmo(TPawn, class'AmmoSabot', TPawn.InitialInventory[i].Count);
						BuffCount++;
					}
				break;
				case 'Ammo3006':
					if (FakeRand(2) == 0)
					{
						if (TMission < 7)
						{
							ForceLoadAmmo(TPawn, class'Ammo3006Tranq', TPawn.InitialInventory[i].Count);
							BuffCount++;
						}
						else
						{
							ForceLoadAmmo(TPawn, class'Ammo3006HEAT', TPawn.InitialInventory[i].Count);
							BuffCount++;
						}
					}
				break;
				case 'AmmoRocket':
					if ((TMission > 9) && (FakeRand(2) == 0))
					{
						ForceLoadAmmo(TPawn, class'AmmoRocketWP', TPawn.InitialInventory[i].Count);
						BuffCount++;
					}
				break;
				case 'AmmoPlasma':
					if ((TMission > 15) && (FakeRand(2) == 0))
					{
						ForceLoadAmmo(TPawn, class'AmmoPlasmaPlague', TPawn.InitialInventory[i].Count);
						BuffCount++;
					}
				break;
				case 'Ammo10mmHEAT':
					if (TMission > 15)
					{
						ForceLoadAmmo(TPawn, class'Ammo10mmHEAT', TPawn.InitialInventory[i].Count);
						BuffCount++;
					}
				break;
			}
		}
		else if (class<DeusExWeapon>(TInv) != None)
		{
			LastWeapon = class<DeusExWeapon>(TInv);
			switch(LastWeapon.Name)
			{
				case'WeaponRifle':
				case'WeaponLAW':
				case'WeaponGEPGun':
					TPawn.BaseAccuracy = FMax(-0.35, TPawn.BaseAccuracy-0.35);
				break;
			}
		}
	}
	
	return BuffCount;
}

//MADDERS, 6/2/23: Turns out we don't swap ammo soon enough, so spawn it and force load it instead.
function ForceLoadAmmo(ScriptedPawn TPawn, class<DeusExAmmo> NewAmmo, int Quantity)
{
	local int i;
	local DeusExAmmo DXA;
	local DeusExWeapon DXW;
	local Inventory TInv;
	
	if (TPawn == None || TPawn.IsInState('Dying') || NewAmmo == None) return;
	
	//Make sure we have enough ammo to be comfy.
	if (Quantity < 2) Quantity = 2;
	
	for(TInv = TPawn.Inventory; TInv != None; TInv = TInv.Inventory)
	{
		DXW = DeusExWeapon(TInv);
		if (DXW != None)
		{
			for(i=0; i<ArrayCount(DXW.AmmoNames); i++)
			{
				if (DXW.AmmoNames[i] == NewAmmo)
				{
					DXA = TPawn.Spawn(NewAmmo, TPawn);
					if (DXA == None)
					{
						DXA = TPawn.Spawn(NewAmmo, TPawn,, TPawn.Location + vect(0,0,20));
					}
					if (DXA != None)
					{
						DXA.AmmoAmount *= Quantity;
						DXA.bCrateSummoned = true;
						DXA.InitialState = 'Idle2';
						DXA.GiveTo(TPawn);
						DXA.SetBase(TPawn);
						
						DXW.LoadAmmo(i);
					}
					
					return;
				}
			}
		}
	}
}

function class<Weapon> ObtainLowLevelWeapon(VMDBufferPawn TP, out class<Ammo> OutAmmo)
{
	local int R, TMission;
	local class<Weapon> Ret;
	
	TMission = VMDGetMissionNumber();
	
	R = FakeRand(5);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			Ret = class<Weapon>(MutateItem(VMDBufferPlayer(GetPlayerPawn()), class'WeaponPistol'));
		break;
		case 4:
			Ret = class'WeaponMiniCrossbow';
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = Ret.Default.AmmoName;
	}
	
	return Ret;
}

function class<Weapon> ObtainHighLevelWeapon(VMDBufferPawn TP, out class<Ammo> OutAmmo)
{
	local int R, TMission;
	local class<Weapon> Ret;
	
	TMission = VMDGetMissionNumber();
	
	R = FakeRand(20);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			Ret = class'WeaponRifle';
		break;
		case 4:
		case 5:
		case 6:
			if (!TP.IsA('HumanCivilian'))
			{
				if (TMission < 10)
				{
					Ret = class'WeaponFlamethrower';
				}
				else
				{
					Ret = class'WeaponPlasmaRifle';
				}
			}
			else
			{
				Ret = class'WeaponAssaultGun';
			}
		break;
		case 7:
		case 8:
		case 9:
			if (!TP.IsA('HumanCivilian'))
			{
				Ret = class'WeaponGEPGun';
			}
			else
			{
				Ret = class'WeaponRifle';
			}
		break;
		case 10:
		case 11:
			if (TMission > 15)
			{
				Ret = class<Weapon>(MutateItem(VMDBufferPlayer(GetPlayerPawn()), class'WeaponPistol'));
			}
		case 12:
		case 13:
		case 14:
			if (Ret == None)
			{
				Ret = class'WeaponAssaultGun';
			}
		break;
		case 15:
		case 16:
		case 17:
		case 18:
		case 19:
			if (TMission < 6 || FakeFRand() < 0.4)
			{
				Ret = class'WeaponSawedOffShotgun';
			}
			else
			{
				Ret = class'WeaponAssaultShotgun';
			}
		break;
	}
	
	if (Ret != None)
	{
		OutAmmo = Ret.Default.AmmoName;
		
		if (Ret == class'WeaponRifle')
		{
			R = FakeRand(2) + int(TMission > 6);
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
		}
		else if (Ret == class'WeaponGEPGun')
		{
			R = FakeRand(2);
			if (TMission < 10)
			{
				R = 0;
			}
			
			switch(R)
			{
				case 0:
					OutAmmo = class'AmmoRocket';
				break;
				case 1:
					OutAmmo = class'AmmoRocketWP';
				break;
			}
		}
		else if (Ret == class'WeaponSawedOffShotgun' || Ret == class'WeaponAssaultShotgun')
		{
			R = FakeRand(2);
			
			switch(R)
			{
				case 0:
					if ((TMission > 9) && (Ret == class'WeaponAssaultShotgun'))
					{
						OutAmmo = class'AmmoDragonsBreath';
					}
					else if ((TMission > 5) && (Ret == class'WeaponSawedOffShotgun'))
					{
						OutAmmo = class'AmmoTaserSlug';
					}
					else
					{
						OutAmmo = class'AmmoShell';
					}
				break;
				case 1:
					OutAmmo = class'AmmoSabot';
				break;
			}
		}
		else if (Ret == class'WeaponPlasmaRifle')
		{
			R = FakeRand(2);
			if (TMission <= 15)
			{
				R = 0;
			}
			
			switch(R)
			{
				case 0:
					OutAmmo = class'AmmoPlasma';
				break;
				case 1:
					OutAmmo = class'AmmoPlasmaPlague';
				break;
			}
		}
		else if (Ret == class'WeaponPistol' || Ret == class'WeaponStealthPistol')
		{
			R = 0;
			if (TMission > 15)
			{
				R = 1;
			}
			
			switch(R)
			{
				case 0:
					OutAmmo = class'Ammo10mm';
				break;
				case 1:
					OutAmmo = class'Ammo10mmHEAT';
				break;
			}
		}
	}
	
	return Ret;
}

function class<Inventory> ObtainLowLevelPickup(VMDBufferPawn TP)
{
	local int R, TMission;
	local class<Inventory> Ret;
	
	TMission = VMDGetMissionNumber();
	
	R = FakeRand(5);
	
	switch(R)
	{
		case 0:
		case 1:
			Ret = class'BallisticArmor';
		break;
		case 2:
			if (!TP.IsA('HumanCivilian'))
			{
				Ret = class'TechGoggles';
			}
		break;
		case 3:
			if (!TP.IsA('HumanCivilian'))
			{
				Ret = class'HazmatSuit';
			}
		break;
		case 4:
		break;
	}
	
	return Ret;
}

function class<Inventory> ObtainMediumLevelPickup(VMDBufferPawn TP)
{
	local int R, TMission;
	local class<Inventory> Ret;
	
	TMission = VMDGetMissionNumber();
	
	R = FakeRand(5);
	
	switch(R)
	{
		case 0:
			if (!TP.IsA('HumanCivilian'))
			{
				Ret = class'FireExtinguisher';
			}
		break;
		case 1:
		case 2:
			Ret = class'Medkit';
		break;
		case 2:
		case 3:
		break;
	}
	
	return Ret;
}

function class<Inventory> ObtainHighLevelPickup(VMDBufferPawn TP)
{
	local int R, TMission;
	local class<Inventory> Ret;
	
	TMission = VMDGetMissionNumber();
	
	R = FakeRand(9);
	
	switch(R)
	{
		case 0:
		case 1:
			Ret = MutateItem(VMDBufferPlayer(GetPlayerPawn()), class'WeaponEMPGrenade');
		break;
		case 2:
		case 3:
			if (!TP.IsA('HumanCivilian'))
			{
				Ret = MutateItem(VMDBufferPlayer(GetPlayerPawn()), class'WeaponLAM');
			}
		break;
		case 4:
		case 5:
			if (TMission < 10 || TP.IsA('HumanCivilian'))
			{
			}
			else
			{
				Ret = class'AdaptiveArmor';
			}
		break;
		case 6:
			if ((TMission > 4) && (!TP.IsA('HumanCivilian')))
			{
				Ret = class'WeaponLAW';
			}
		break;
		case 7:
		case 8:
		break;
	}
	
	return Ret;
}

function class<Inventory> MutateItem(VMDBufferPlayer VMP, class<Inventory> InItem)
{
	local class<Inventory> Ret;
	
	Ret = InItem;
	if (VMP == None) return Ret;
	
	switch(VMP.SelectedCampaign)
	{
		case "CARONE":
		case "HOTEL CARONE":
			if (InItem == class'WeaponLAM') Ret = LoadItem("HotelCarone.WeaponHCLAM");
			else if (InItem == class'WeaponEMPGrenade') Ret = LoadItem("HotelCarone.WeaponHCEMPGrenade");
			else if (InItem == class'WeaponGasGrenade') Ret = LoadItem("HotelCarone.WeaponHCGasGrenade");
			else if (InItem == class'WeaponNanoVirusGrenade') Ret = LoadItem("HotelCarone.WeaponHCNanoVirusGrenade");
		break;
		case "NIHILUM":
			if (InItem == class'WeaponPistol') Ret = LoadItem("SGWeap.WeaponBRGlock");
		break;
	}
	
	return Ret;
}

function class<Inventory> LoadItem(string LoadStr)
{
	if (InStr(LoadStr, ".") < 0)
	{
		LoadStr = "DeusEx."$LoadStr;
	}
	
	return class<Inventory>(DynamicLoadObject(LoadStr, class'Class', false));
}

function bool ExactPawnCanBeDuped(VMDBufferPawn SP, out Seat OutSeat)
{
	local Seat TSeat;
	
	if (SP.Orders != 'Standing' || FakeFrand() < 0.25)
	{
		return true;
	}
	else
	{
		//MADDERS, 7/4/22: No sit animation? Yeah. Stop making us sit, jackass.
		switch(SP.Mesh.Name)
		{
			case 'GM_Suit':
			case 'GM_DressShirt':
			case 'GM_DressShirt_S':
			case 'GM_DressShirt_F':
			case 'GM_DressShirt_B':
			case 'GM_Trench':
			case 'GM_Trench_F':
			case 'GM_Jumpsuit':
			case 'GFM_SuitSkirt':
			case 'GFM_SuitSkirt_F':
			case 'GFM_Dress':
			case 'GFM_TShirtPants':
			case 'GFM_Trench':
			
			//MADDERS, 12/29/23: Oops. Patch these in a little late...
			case 'TransGM_Suit':
			case 'TransGM_DressShirt':
			case 'TransGM_DressShirt_S':
			case 'TransGM_DressShirt_F':
			case 'TransGM_DressShirt_B':
			case 'TransGM_Trench':
			case 'TransGM_Trench_F':
			case 'TransGM_Jumpsuit':
			case 'TransGFM_SuitSkirt':
			case 'TransGFM_SuitSkirt_F':
			case 'TransGFM_Dress':
			case 'TransGFM_TShirtPants':
			case 'TransGFM_Trench':
				//MADDERS, 5/29/22: Used to be 512. Too prone to snatching shit at random.
				forEach RadiusActors(class'Seat', TSeat, 384, SP.Location)
				{
					if ((TSeat != None) && (!IsSeatBad(TSeat)) && (!SeatIsPawnTarget(TSeat)))
					{
						OutSeat = TSeat;
						return true;
					}
				}
			break;
			default:
				return false;
			break;
		}
	}
	
	return false;
}

function bool IsSeatBad(Seat TSeat)
{
	local string TMap;
	
	if (TSeat == None) return true;
	
	TMap = VMDGetMapName();
	switch(TMap)
	{
		case "09_NYC_SHIP":
			switch(class'VMDStaticFunctions'.Static.StripBaseActorSeed(TSeat))
			{
				case 8:
					return true;
				break;
			}
		break;
	}
	return false;
}

function bool SeatIsPawnTarget(Seat TSeat)
{
	local Pawn TPawn;
	local ScriptedPawn SP;
	
	if (TSeat != None)
	{
		for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
		{
			SP = ScriptedPawn(TPawn);
			if ((SP != None) && (SP.SeatActor == TSeat || (TSeat.Tag != TSeat.Class.Name && SP.OrderTag == TSeat.Tag)))
			{
				return true;
			}
		}
	}
	
	return false;
}

function bool RandomizePatrolStart(VMDBufferPawn SP, name TTag)
{
	local PatrolPoint TP, TTP;
	local int i, j;
	local Vector V;
	local Name TT;
	
	TP = GetPatrolByTag(TTag);
	TTP = TP;
	TT = TP.Tag;
	
	TP = None; //MADDERS, 10/26/22: Try and really break up this fucking doubling of shit. Sigh.
	j = FakeRand(9)+5;
	for(i=0;i<j;i++)
	{
		TTP = GetPatrolByTag(TTP.NextPatrol);
		if ((IsClearOfPlayer(TTP)) && (TTP.Tag != TTag))
		{
			TP = TTP;
		}
	}
	
	if (TP != None)
	{
		TT = TP.Tag;
		V = SP.Location;
		V.X = TP.Location.X;
		V.Y = TP.Location.Y;
		V.Z = TP.Location.Z -15+SP.CollisionHeight;
		
		if (SP.SetLocation(V))
		{
			SP.OrderTag = TT;
			return True;
		}
		else
		{
			return False;
		}
	}
	
	return False;
}

function bool IsClearOfPlayer(Actor A, optional int TDist)
{
	local DeusExPlayer DXP;
	local ScriptedPawn SP;
	
	if (A == None) return False;
	
	if (TDist == 0) TDist = 512;
	
	forEach RadiusActors(class'ScriptedPawn', SP, TDist / 2, A.Location)
	{
		if ((SP != None) && (!SP.IsInState('Dying')))
		{
			return False;
		}
	}
	
	return True;
}

function PatrolPoint GetPatrolByTag(name Find)
{
	local PatrolPoint P, TP;
	
	forEach AllActors(class'PatrolPoint', P, Find)
	{
		if (P != None)
		{
			TP = P;
			break; //Stop right there.
		}
	}
	
	return TP;
}

function int SpawnMapSpecificGrenades(int TMayhem)
{
	local bool bSpawnAll, bCarone;
	local int i, TMission, MissionGrenadeSize[2], GRand[2], LocWater[10];
	local string TMap;
	local Vector TLocs[10];
	local Rotator TRots[10];
	local Mover TMovers[10];
	local class<Mover> LoadClass, LoadClass2; //Thanks, carone movers.
	
	if (TMayhem < 75) return TMayhem;
	
	GRand[1] = -1;
	
	//MADDERS, 12/15/23: Used only for testing all grenade spawns for accuracy at once.
	//bSpawnAll = true;
	
	TMap = VMDGetMapName();
	TMission = VMDGetMissionNumber();
	
	if (!bRevisionMapSet)
	{
		switch(TMap)
		{
			//1111111111111111111111111111111111111111
			case "01_NYC_UNATCOISLAND":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Medbot crate #1.
				TLocs[0] = vect(-2938.6, 5314.3, -110.6);
				TRots[0] = rot(0, 0, 0);
				TMovers[0] = PinpointMover(class'DeusExMover', 0);
				
				//Hidey area near robot patrol. Devious.
				TLocs[1] = vect(-2538.5, 221.8, -139.5);
				TRots[1] = rot(16383, 65208, 32768);
				
				//Side of crate near the laser site spawn. Oh my god, how evil.
				TLocs[2] = vect(6699, -3294.5, -427.4);
				TRots[2] = rot(0, -32767, 0);
				
				//Medbot crate #2.
				TLocs[3] = vect(7717.4, 737.4, -112.3);
				TRots[3] = rot(0, 0, 0);
				TMovers[3] = PinpointMover(class'DeusExMover', 2);
				
				//Last of 4 entryways towards staircases, near the 2 mixed guards and other gas grenades.
				TLocs[4] = vect(2974.5, -417, 1044.4);
				TRots[4] = rot(16383, 16398, 32768);
				
				//Stairwell going up to the 2 mixed guards and other grenades. Mostly a problem going down, not up.
				TLocs[5] = vect(2877.2, 261, 932.4);
				TRots[5] = rot(0, 16384, 0);
				
				//Vent towards gunther.
				TLocs[6] = vect(2667.2, -691.6, -158.5);
				TRots[6] = rot(19109, 32590, 32768);
				
				//Late entry: Docks near loot crates.
				TLocs[7] = vect(2697, -7781, -276.7);
				TRots[7] = rot(0, -16383, 0);
			break;
			//2222222222222222222222222222222222222222
			case "02_NYC_BATTERYPARK":
				MissionGrenadeSize[0] = 10;
				MissionGrenadeSize[1] = 10;
				
				//Stairwell down to alt route in castle clinton tunnels.
				TLocs[0] = vect(-709, -3266.5, 114.6);
				TRots[0] = rot(0, 32767, 0);
				
				//Most popular vent to circumvent flamethrower guy and other dude completely in castle clinton tunnels.
				TLocs[1] = vect(-661, -1828.5, -401.6);
				TRots[1] = rot(0, 32767, 0);
				
				//Door to aug can in castle clinton tunnels start.
				TLocs[2] = vect(804.4, -877, -167);
				TRots[2] = rot(0, 0, 0);
				TMovers[2] = PinpointMover(class'DeusExMover', 19);
				
				//Main alt route towards main subway entrance, through vents.
				TLocs[3] = vect(-4303, 2420.3, 12.4);
				TRots[3] = rot(16384, 16618, 32768);
			break;
			case "02_NYC_UNDERGROUND":
				MissionGrenadeSize[0] = 10;
				MissionGrenadeSize[1] = 10;
				
				//Easy way into sewers, approaching the spinning grate junction.
				TLocs[4] = vect(-66.3, -836, -379.5);
				TRots[4] = rot(16384, -15721, 32768);
				
				//MJ12 armory.
				TLocs[5] = vect(-2981.2, 1306.9, -944.9);
				TRots[5] = rot(0, -16383, 0);
			break;
			case "02_NYC_WAREHOUSE":
				MissionGrenadeSize[0] = 10;
				MissionGrenadeSize[1] = 10;
				
				//Dark area in abandoned building, next to medkit and biocell.
				TLocs[6] = vect(643.9, 1104.8, 969);
				TRots[6] = rot(0, 0, 0);
				
				//Near the switch to the swimming route to the basement.
				TLocs[7] = vect(-1237, 830.7, -261);
				TRots[7] = rot(0, 32767, 0);
				
				//Mirror entry to computer. Too easy.
				TLocs[8] = vect(1606.7, -1138.4, 320.7);
				TRots[8] = rot(0, -16383, 0);
				TMovers[8] = PinpointMover(class'DeusExMover', 69);
				
				//Ramp towards bonus aug. It's a very nice aug, after all.
				TLocs[9] = vect(326.9, -1264.6, -154.4);
				TRots[9] = rot(10747, 16383, 0);
			break;
			//3333333333333333333333333333333333333333
			case "03_NYC_AIRFIELDHELIBASE":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//The one pipe set you can naked solution around (easily).
				TLocs[0] = vect(-9626, 3293.7, 52.4);
				TRots[0] = rot(16383, 3389, 32768);
				
				//Vent around lasers and stuff.
				TLocs[1] = vect(-6604.9, 3383, 166.2);
				TRots[1] = rot(0, 32767, 0);
				
				//Route around robots. Possibly of use?
				TLocs[2] = vect(-1300.8, 3167.2, 53.3);
				TRots[2] = rot(0, 27931, 0);
				
				//Easy route to escape roof area.
				TLocs[3] = vect(-1365, 841.9, 250.1);
				TRots[3] = rot(0, 32767, 0);
				
				//Bonus aug can area. It's got a ton of shit, in fairness.
				TLocs[4] = vect(-1253.8, 498.4, 245.2);
				TRots[4] = rot(0, 16383, 0);
				TMovers[4] = PinpointMover(class'DeusExMover', 18);
				
				//Water escape route. So close, but not quite.
				TLocs[5] = vect(-3499.5, -577.4, 10.7);
				TRots[5] = rot(0, -24575, 0);
			break;
			case "03_NYC_AIRFIELD":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Corner where you can hide from flamethrower guy. A bit mean.
				TLocs[6] = vect(-1943.1, 1860.8, 51.8);
				TRots[6] = rot(0, 16383, 0);
				
				//Route to high ground, behind weapon mod crate. Devious.
				TLocs[7] = vect(587.1, 3025.9, 328.4);
				TRots[7] = rot(16383, -65458, 32768);
			break;
			//4444444444444444444444444444444444444444
			case "04_NYC_NSFHQ":
				MissionGrenadeSize[0] = 2;
				MissionGrenadeSize[1] = 2;
			
				//Next to computer in sub-basement. Makes progression easy AF.
				TLocs[0] = vect(-230, 175, -190.8);
				TRots[0] = rot(0, -16383, 0);
				
				//Stairwell down, in case we tried to skip sublevel entirely.
				TLocs[1] = vect(1901.8, 1400.9, -123.6);
				TRots[1] = rot(16383, 31897, 32768);
			break;
			//8888888888888888888888888888888888888888
			case "08_NYC_STREET":
				MissionGrenadeSize[0] = 4;
				MissionGrenadeSize[1] = 4;
				
				//Mine going into free clinic. Brutal.
				TLocs[0] = vect(-1778.8, 895.9, -443.6);
				TRots[0] = rot(16383, 31978, 32768);
			break;
			case "08_NYC_HOTEL":
				MissionGrenadeSize[0] = 4;
				MissionGrenadeSize[1] = 4;
				
				//Painting near paul's stuff.
				TLocs[1] = vect(-410.9, -2671.5, 122.7);
				TRots[1] = rot(0, 0, 0);
			break;
			case "08_NYC_UNDERGROUND":
				MissionGrenadeSize[0] = 4;
				MissionGrenadeSize[1] = 4;
				
				//Way into water area, easy route.
				TLocs[2] = vect(-62.7, -962.3, -361.2);
				TRots[2] = rot(13027, 16383, 0);
			break;
			case "08_NYC_SMUG":
				MissionGrenadeSize[0] = 4;
				MissionGrenadeSize[1] = 4;
				
				//Guarding smuggler's goodies in the mirror. Not completely forced, as that would be a dick move.
				TLocs[3] = vect(-578.2, 1681.4, 244.4);
				TRots[3] = rot(16383, 48723, 32768);
			break;
			//9999999999999999999999999999999999999999
			case "09_NYC_DOCKYARD":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Slip-between on buildings on outskirt. Too easy to stealth.
				TLocs[0] = vect(2235.8, 1659, 45.3);
				TRots[0] = rot(0, -16383, 0);
				
				//Elevator up to crane, skipping past everything. Again, too meta.
				TLocs[1] = vect(4532.9, 5832.8, 53.4);
				TRots[1] = rot(0, 0, 0);
			break;
			case "09_NYC_SHIP":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Button to move metal girder thing. Makes route too easy.
				TLocs[2] = vect(3252.1, -1236.4, 1213.6);
				TRots[2] = rot(-2047, -16383, 0);
				
				//Aug can. If you use the TNT wallbang trick, the journey isn't over yet.
				TLocs[3] = vect(2997.2, 252.2, 518.4);
				TRots[3] = rot(16383, 32299, 32768);
				
				//Vents that can bypass all top floor security.
				TLocs[4] = vect(2737.2, -274.1, 676.4);
				TRots[4] = rot(16383, 19308, 32768);
			break;
			case "09_NYC_SHIPBELOW":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Deck to top with sailors and security console. Also guards some ammo.
				TLocs[5] = vect(-435.1, -486.6, -173.1);
				TRots[5] = rot(0, 0, 0);
				
				//Door to GEP gun, aug can, and scrambler.
				TLocs[6] = vect(-4321.1, -414.4, -188);
				TRots[6] = rot(0, -16383, 0);
				TMovers[6] = PinpointMover(class'DeusExMover', 7);
				
				//Vent to chopper area. Again, too powerful.
				TLocs[7] = vect(-5908.9, 570.7, -569.7);
				TRots[7] = rot(0, 32767, 0);
			break;
			//1010101010101010101010101010101010101010
			case "10_PARIS_CATACOMBS":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Tunnels to dodge most of radiation damage.
				TLocs[0] = vect(-773.3, 3848.2, -11.5);
				TRots[0] = rot(16383, 30888, 32768);
				
				//Vent to medbot.
				TLocs[1] = vect(1133, -2052.2, -773.6);
				TRots[1] = rot(0, 0, 0);
			break;
			case "10_PARIS_CATACOMBS_TUNNELS":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Vent used to dodge most guys on way to good guy bunker.
				TLocs[2] = vect(-3554.2, 213, -43.6);
				TRots[2] = rot(16383, -95, 32768);
				
				//Tunnel used to dodge lasers and such on way in. Brutal, but our options are limited.
				TLocs[3] = vect(-535.1, -1034.9, -238.2);
				TRots[3] = rot(0, 16383, 0);
			break;
			case "10_PARIS_METRO":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Vent out to dodge massive wad of dudes. Brutal, but hopefully you have demo or EMPs or drone by now.
				TLocs[4] = vect(-195.1, -2876.9, -130.7);
				TRots[4] = rot(0, -16383, 0);
				
				//Rear door to club.
				TLocs[5] = vect(2212.2, 409.5, 207.4);
				TRots[5] = rot(0, -16383, 0);
				TMovers[5] = PinpointMover(class'DeusExMover', 9);
			break;
			//1111111111111111111111111111111111111111
			case "11_PARIS_CATHEDRAL":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Beam up to alt route around gate.
				TLocs[0] = vect(-4072.4, 2101.5, -549.5);
				TRots[0] = rot(9083, -16383, 0);
				
				//Sneak attack/mil bot computer area.
				TLocs[1] = vect(-6452.9, -268, -89.8);
				TRots[1] = rot(0, 32767, 0);
				
				//Well coming into cathedral. You can see this underwater, so it's very defusable with good swimming + demo.
				TLocs[2] = vect(3354.9, -1020.5, -571.5);
				TRots[2] = rot(0, 32767, 0);
				LocWater[2] = 1;
				
				//Door towards secret passage towards computer.
				TLocs[3] = vect(3565.4, -1413.5, 146.1);
				TRots[3] = rot(0, 16383, 0);
				TMovers[3] = PinpointMover(class'DeusExMover', 10);
				
				//Trellis up to roof. I know I didn't pioneer this, but with >50 new grenades being placed in world, I can't always be first.
				TLocs[4] = vect(3427.4, 169, -392.7);
				TRots[4] = rot(0, 16383, 0);
				
				//Computer securing the gold reserve area. Risky.
				TLocs[5] = vect(4031.7, -4299, -756.5);
				TRots[5] = rot(0, 16383, 0);
			break;
			//1212121212121212121212121212121212121212
			case "12_VANDENBERG_CMD":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Top of elevator circumvention.
				TLocs[0] = vect(969.5, 1323.8, -1188.3);
				TRots[0] = rot(0, 16383, 0);
				
				//We won't stop the player getting milbots, but the LAWs are under watch sometimes.
				TLocs[1] = vect(-1456.7, 1047.7, -1531.5);
				TRots[1] = rot(16383, 17017, 32768);
				
				//One to circumvent lobby security and get to medbot. Not a total stopper, but it will make you go loud somewhat.
				TLocs[2] = vect(-1027.7, 1719, -1787.6);
				TRots[2] = rot(16383, 62964, 18866);
			break;
			case "12_VANDENBERG_TUNNELS":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Underwater, way to aug upgrade.
				TLocs[3] = vect(-2857, 3553.8, -3205.1);
				TRots[3] = rot(0, 0, 0);
				LocWater[3] = 1;
			break;
			case "12_VANDENBERG_GAS":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Ropes up to side entrance. Too quick, maybe?
				TLocs[4] = vect(-313.1, -2038, -1024.6);
				TRots[4] = rot(16383, 17121, 32768);
				
				//Vent to roof. Again, too simple. You can take the other vent, if you're a legend.
				TLocs[5] = vect(593.4, 739.9, -782.6);
				TRots[5] = rot(0, 0, 0);
			break;
			//1414141414141414141414141414141414141414
			case "14_VANDENBERG_SUB":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Way up stairs is easier than the alternative route, for once.  Acknowledge it.
				TLocs[0] = vect(2307.3, 3487.6, -412.3);
				TRots[0] = rot(0, 24575, 0);
				
				//Vent sneaking around most of lab.
				TLocs[1] = vect(2916.9, 3794.1, 275.4);
				TRots[1] = rot(0, 0, 0);
				
				//Computer to disarm a lot of security. Rough it.
				TLocs[2] = vect(3882.9, 26.9, -1720.4);
				TRots[2] = rot(0, -32767, 0);
			break;
			case "14_OCEANLAB_LAB":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Floor into bonus armory.
				TLocs[3] = vect(942.8, 81.7, -1627.6);
				TRots[3] = rot(16383, 65345, 32768);
				
				//Water subversion route. Sorry swimmers.
				TLocs[4] = vect(1009.1, -108.2, -1835.7);
				TRots[4] = rot(16383, 62924, 32768);
				LocWater[4] = 1;
			break;
			case "14_OCEANLAB_SILO":
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Attic with free shit. Might be able to juke this one.
				TLocs[5] = vect(-2022.9, -6322.5, 1788.2);
				TRots[5] = rot(16383, 56976, 32768);
				
				//Alt route that goes to vent around main door/elevator.
				TLocs[6] = vect(647.9, -4081.8, 1430.4);
				TRots[6] = rot(16383, 15667, 32768);
				
				//Escape route from main ambush. I'm sorry, this one sucks.
				TLocs[7] = vect(18.7, -4099, 410.9);
				TRots[7] = rot(0, 16383, 0);
			break;
			//1515151515151515151515151515151515151515
			case "15_AREA51_BUNKER":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Fan to circumvent main area.
				TLocs[0] = vect(363, -2743, -527.6);
				TRots[0] = rot(16383, 10741, 32768);
				
				//Pickable door around spiderbots. It's a stretch, frankly.
				TLocs[1] = vect(4087.5, 3593.6, -908.1);
				TRots[1] = rot(0, 32767, 0);
			break;
			case "15_AREA51_ENTRANCE":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Aug can for the second legendary aug. Work for it, baby.
				TLocs[2] = vect(4736.9, 478.8, -114.6);
				TRots[2] = rot(0, 0, 0);
				
				//Vent route around dudes, part 2?
				TLocs[3] = vect(-312.9, -592.9, -310.2);
				TRots[3] = rot(0, 0, 0);
			break;
			case "15_AREA51_FINAL":
				MissionGrenadeSize[0] = 6;
				MissionGrenadeSize[1] = 6;
				
				//Water route with code. Just plain brutal.
				TLocs[4] = vect(-4563, -3961.6, -1387.5);
				TRots[4] = rot(0, 0, 0);
				
				//Route through hatch, to bypass commandos.
				TLocs[5] = vect(-4875, -730.4, -998.5);
				TRots[5] = rot(16383, 15585, 32768);
			break;
			//1616161616161616 CARONE! 1616161616161616
			case "16_HOTELCARONE_HOTEL":
				bCarone = true;
				LoadClass = class<Mover>(DynamicLoadObject("HotelCarone.CaroneElevator", class'Class', false));
				LoadClass2 = class<Mover>(DynamicLoadObject("HotelCarone.CEDoor", class'Class', false));
				
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Floor 2 alarm that's super easy to turn off.
				TLocs[0] = vect(1711.5, -5027, -5944.5);
				TRots[0] = rot(0, 16383, 0);
				
				//Elevator up to top floors, from lobby. Too easy.
				TLocs[1] = vect(2441, -5151, -6414);
				TRots[1] = rot(16383, -16431, 32768);
				TMovers[1] = PinpointMover(LoadClass, 8);
				
				//Floor 3 breakable panel to hostages, sneak attack route.
				TLocs[2] = vect(1014, -3501, -5571);
				TRots[2] = rot(0, -16383, 0);
				
				//Penthouse vent to sneak attack and wallbang the hostage takers.
				TLocs[3] = vect(361, -5233, -2677);
				TRots[3] = rot(0, 0, 0);
				
				//Floor 16 standard entrance. Forces us to use the multimover.
				TLocs[4] = vect(365.5, -5183, -3795.5);
				TRots[4] = rot(16383, 49354, 32768);
				
				//Floor 2 restraunt towards free shit and also the penthouse entrance.
				TLocs[5] = vect(606.5, -5143.5, -5940);
				TRots[5] = rot(0, 0, 0);
				TMovers[5] = PinpointMover(LoadClass2, 62);
			break;
			case "16_HOTELCARONE_DXD":
				bCarone = true;
				LoadClass = class<Mover>(DynamicLoadObject("HotelCarone.CBreakableGlass", class'Class', false));
				
				MissionGrenadeSize[0] = 8;
				MissionGrenadeSize[1] = 8;
				
				//Underwater passage to DXD.
				TLocs[6] = vect(1149.5, -4363.5, -2318);
				TRots[6] = rot(11251, -11891, 0);
				
				//To warehouse full of free shit.
				TLocs[7] = vect(2356, -3536.5, -1867.5);
				TRots[7] = rot(0, 16383, 0);
				TMovers[7] = PinpointMover(LoadClass, 70);
		}
	}
	
	if (MissionGrenadeSize[0] < 1) return TMayhem;
	
	if (bSpawnAll)
	{
		for (i=0; i<Max(MissionGrenadeSize[0], MissionGrenadeSize[1]); i++)
		{
			if (TLocs[i] != Vect(0,0,0))
			{
				MayhemPlaceGrenade(class'LAM', TLocs[i], TRots[i], TMovers[i]);
			}
		}
	}
	else
	{
		GRand[0] = AltFakeRand(MissionGrenadeSize[0]);
		if ((TMayhem >= 100) && (MissionGrenadeSize[1] > 0)) GRand[1] = AltFakeRand(MissionGrenadeSize[1]);
		
		if ((TLocs[GRand[0]] != Vect(0,0,0)) && (MayhemPlaceGrenade(RandomGrenadeClass(TMission, bool(LocWater[GRand[0]]), bCarone), TLocs[GRand[0]], TRots[GRand[0]], TMovers[GRand[0]]) != None))
		{
			TMayhem -= 5;
		}
		if ((GRand[1] > -1) && (GRand[1] != GRand[0]) && (TLocs[GRand[1]] != Vect(0,0,0)) && (MayhemPlaceGrenade(RandomGrenadeClass(TMission, bool(LocWater[GRand[1]]), bCarone), TLocs[GRand[1]], TRots[GRand[1]], TMovers[GRand[1]]) != None))
		{
			TMayhem -= 5;
		}
	}
	
	return TMayhem;
}

function Mover PinpointMover(class<Mover> TargetMoverClass, int TargetSeed)
{
	local Mover M, Ret;
	
	forEach AllActors(class'Mover', M)
	{
		if (M.Class == TargetMoverClass)
		{
			if (class'VMDStaticFunctions'.Static.StripBaseActorSeed(M) == TargetSeed)
			{
				Ret = M;
				break;
			}
		}
	}
	
	return Ret;
}

function class<ThrownProjectile> RandomGrenadeClass(int TMission, bool bWater, optional bool bCarone)
{
	local int TRand;
	local class<ThrownProjectile> Ret;
	
	if (bCarone)
	{
		Ret = class<ThrownProjectile>(DynamicLoadObject("HotelCarone.HCLAM", class'Class', true));
	}
	else
	{
		if (TMission < 5)
		{
			TRand = AltFakeRand(3);
		}
		else
		{
			TRand = AltFakeRand(2);
		}
		
		switch(TRand)
		{
			case 0:
				if (bWater)
				{
					Ret = class'EMPGrenade';
				}
				else
				{
					Ret = class'GasGrenade';
				}
			break;
			default:
				Ret = class'LAM';
			break;
		}
	}
	
	return Ret;
}

//MADDERSE, 12/13/23: Emplace grenades with infamy! Yay.
function ThrownProjectile MayhemPlaceGrenade(class<ThrownProjectile> PlaceClass, Vector PlaceLoc, Rotator PlaceRot, optional Mover PlaceMover)
{
	local ThrownProjectile Ret;
	
	if (PlaceClass == None)
	{
		return None;
	}
	
	Ret = Spawn(PlaceClass, None,, PlaceLoc, PlaceRot);
	if (Ret != None)
	{
		if (Ret.HasAnim('Open'))
		{
			Ret.PlayAnim('Open');
		}
		
		//MADDERS, 12/13/23: Yeah, we don't play sounds.
		Ret.SetPhysics(PHYS_None);
		Ret.bBounce = False;
		Ret.bProximityTriggered = True;
		Ret.bStuck = True;
		if (PlaceMover != None)
		{
			Ret.SetBase(PlaceMover);
		}
	}
}

function string VMDGetMapName()
{
 	local string S, S2;
 	
 	S = GetURLMap();
 	S2 = Chr(92); //What the fuck. Can't type this anywhere!
	
	//MADDERS, 3/23/21: Uuuuh... Oceanlab machine :B:ROKE.
	//No idea how or why this happens, and only post-DXT merge. Fuck it. Chop it down.
	if (Right(S, 1) ~= " ") S = Left(S, Len(S)-1);
	
 	//HACK TO FIX TRAVEL BUGS!
 	if (InStr(S, S2) > -1)
 	{
  		do
  		{
   			S = Right(S, Len(S) - InStr(S, S2) - 1);
  		}
  		until (InStr(S, S2) <= -1);

		if (InStr(S, ".") > -1)
		{
  			S = Left(S, Len(S) - 4);
		}
 	}
 	else
	{
		if (InStr(S, ".") > -1)
		{
			S = Left(S, Len(S)-3);
		}
 	}
	
 	return CAPS(S);
}

function int VMDGetMissionNumber()
{
	local DeusExLevelInfo DXLI;
	
 	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
	
	if (DXLI != None)
	{
		return DXLI.MissionNumber;
	}
	return 1;
}

defaultproperties
{
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=True
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
