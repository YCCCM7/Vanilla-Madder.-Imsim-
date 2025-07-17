//=============================================================================
// VMDMayhemActor.
//=============================================================================
class VMDMayhemActor extends VMDFillerActors;

var bool bRanTweaks;
var int RandIndex, RandBarf[100];
var float TweakTimer;

var VMDBufferPlayer VMP;

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
	local int i, CurRip, MySeed;
	local class<VMDStaticFunctions> SF;
	
	SF = class'VMDStaticFunctions';
	
	MySeed = SF.Static.DeriveStableActorSeed(Self, 10, true);
	for(i=0; i<ArrayCount(RandBarf); i++)
	{
		CurRip = SF.Static.RipLongSeedChunk(MySeed, i);
		RandBarf[i] = CurRip;
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
	
	if (VMP == None) return;
	
	InitRandData(VMP);
	
	StartMayhem = VMP.MayhemFactor;
	TMayhem = StartMayhem;
	
	if (StartMayhem < 1) return;
	
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
		if (AlreadySpawned[TIndex] > 1)
		{
			continue;
		}
		else
		{
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
	if (SP.IsA('Boss') || SP.IsA('MrVenom'))
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
			case 12:
				return false;
			break;
			default:
			break;
		}
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
	local bool bCanGetCoolShit;
	local int i, InvStart, InvEnd;
	local float RandFor, RandAgainst;
	local Vector TOffs[4];
	local Seat TSeat;
	local VMDBufferPawn TP;
	local class<Ammo> TAmmo;
	
	if (SP == None) return false;
	
	if (!ExactPawnCanBeDuped(SP, TSeat)) return false;
	
	RandFor = FakeFRand()*TMayhem;
	RandAgainst = FakeFRand()*TWeight;
	
	TOffs[0] = vect(1,0,0) * SP.CollisionRadius * 1.35 * 2;
	TOffs[1] = vect(-1,0,0) * SP.CollisionRadius * 1.35 * 2;
	TOffs[2] = vect(0,1,0) * SP.CollisionRadius * 1.35 * 2;
	TOffs[3] = vect(0,-1,0) * SP.CollisionRadius * 1.35 * 2;
	
	TP = Spawn(SP.Class, SP.Owner, SP.Tag, SP.Location + TOffs[0], SP.Rotation);
	if (TP == None) TP = Spawn(SP.Class, SP.Owner, SP.Tag, SP.Location + TOffs[1], SP.Rotation);
	if (TP == None) TP = Spawn(SP.Class, SP.Owner, SP.Tag, SP.Location + TOffs[2], SP.Rotation);
	if (TP == None) TP = Spawn(SP.Class, SP.Owner, SP.Tag, SP.Location + TOffs[3], SP.Rotation);
	
	if ((TP != None) && (TP.Location.Z > SP.Location.Z+12))
	{
		TP.Destroy();
		return false;
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
			TP.OrderTag = 'None';
		}
		
		TP.RaiseAlarm = SP.RaiseAlarm;
		TP.bKeepWeaponDrawn = SP.bKeepWeaponDrawn;
		
		TP.BaseAccuracy = SP.BaseAccuracy;
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
			if (TMayhem < 25)
			{
				TP.InitialInventory[0].Inventory = ObtainLowLevelWeapon(TAmmo);
				TP.InitialInventory[0].Count = 1;
				TP.InitialInventory[1].Inventory = TAmmo;
				TP.InitialInventory[1].Count = 12;
				
				InvStart = 2;
			}
			else if (TMayhem > 75)
			{
				TP.InitialInventory[0].Inventory = ObtainHighLevelWeapon(TAmmo);
				TP.InitialInventory[0].Count = 1;
				
				switch(TP.InitialInventory[0].Inventory.Name)
				{
					case 'WeaponRifle':
						TP.BaseAccuracy -= 0.75;
					case 'WeaponAssaultGun':
					case 'WeaponAssaultShotgun':
					case 'WeaponSawedOffShotgun':
					case 'WeaponPlasmaRifle':
					case 'WeaponLAW':
					case 'WeaponFlamethrower':
					case 'WeaponGEPGun':
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
				if (TMayhem > 65)
				{
					TP.AddToInitialInventory(ObtainHighLevelPickup(), 1);
					
					InvEnd++;
				}
				if (TMayhem > 50)
				{
					TP.AddToInitialInventory(ObtainMediumLevelPickup(), 1);
					
					InvEnd++;
				}
				if (TMayhem > 35)
				{
					TP.AddToInitialInventory(ObtainLowLevelPickup(), 1);
					
					InvEnd++;
				}
			}
		}
		
	  	TP.CheckForHelmets();
	  	//TP.ApplySpecialStats();
	  	//TP.PostSpecialStatCheck();
	  	TP.RunModInvChecks();
	  	TP.bAppliedSpecial = True;
	  	
	  	//------------------
	  	//MADDERS: Store these for drug effects!
	  	TP.StoredScaleGlow = ScaleGlow;
	  	TP.StoredFatness = Fatness;
		
		//MADDERS, 6/6/22: Total bullshit ensues. Dudes in chairs can't have alliances reliably cloned.
		TP.ChangeAlly(TP.Alliance, 1, true);
		/*if (TP.GetAllianceType('Player') >= 0)
		{
			TP.ChangeAlly('Player', -1, true);
			//TP.Destroy();
			//return false;
		}*/
		
		if (TSeat != None)
		{
			TP.Orders = 'Sitting';
			TP.OrderTag = TSeat.Tag;
			
			TP.SeatActor = TSeat;
			TP.SetOrders('Sitting',, true);
			TP.ResetReactions();
		}
		
		return true;
	}
	else
	{
		return false;
	}
}

function class<Weapon> ObtainLowLevelWeapon(out class<Ammo> OutAmmo)
{
	local int R, TMission;
	local class<Weapon> Ret;
	
	TMission = GetMissionNumber();
	
	R = FakeRand(5);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			Ret = class'WeaponPistol';
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

function class<Weapon> ObtainHighLevelWeapon(out class<Ammo> OutAmmo)
{
	local int R, TMission;
	local class<Weapon> Ret;
	
	TMission = GetMissionNumber();
	
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
			if (TMission < 10)
			{
				Ret = class'WeaponFlamethrower';
			}
			else
			{
				Ret = class'WeaponPlasmaRifle';
			}
		break;
		case 7:
		case 8:
		case 9:
			Ret = class'WeaponGEPGun';
		break;
		case 10:
		case 11:
			if (TMission > 15)
			{
				Ret = class'WeaponPistol';
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
			if (TMission < 6)
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
					OutAmmo = class'Ammo3006Tranq';
				break;
				case 1:
					OutAmmo = class'Ammo3006';
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
			//R = FakeRand(2);
			R = int(TMission > 6);
			
			switch(R)
			{
				case 0:
					OutAmmo = class'AmmoShell';
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

function class<Inventory> ObtainLowLevelPickup()
{
	local int R, TMission;
	local class<Inventory> Ret;
	
	TMission = GetMissionNumber();
	
	R = FakeRand(5);
	
	switch(R)
	{
		case 0:
		case 1:
			Ret = class'BallisticArmor';
		break;
		case 2:
			Ret = class'TechGoggles';
		break;
		case 3:
			Ret = class'HazmatSuit';
		break;
		case 4:
		break;
	}
	
	return Ret;
}

function class<Inventory> ObtainMediumLevelPickup()
{
	local int R, TMission;
	local class<Inventory> Ret;
	
	TMission = GetMissionNumber();
	
	R = FakeRand(3);
	
	switch(R)
	{
		case 0:
		break;
		case 1:
			Ret = class'Medkit';
		break;
		case 2:
		break;
	}
	
	return Ret;
}

function class<Inventory> ObtainHighLevelPickup()
{
	local int R, TMission;
	local class<Inventory> Ret;
	
	TMission = GetMissionNumber();
	
	R = FakeRand(9);
	
	switch(R)
	{
		case 0:
		case 1:
			Ret = class'WeaponEMPGrenade';
		break;
		case 2:
		case 3:
			Ret = class'WeaponLAM';
		break;
		case 4:
		case 5:
			if (TMission < 10)
			{
			}
			else
			{
				Ret = class'AdaptiveArmor';
			}
		break;
		case 6:
			if (TMission > 4)
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

function bool ExactPawnCanBeDuped(VMDBufferPawn SP, out Seat OutSeat)
{
	local Seat TSeat;
	
	//MADDERS, 6/24/25: Special exception for our special-but-not-special Hela.
	if ((WIB(SP) != None) && (SP.BindName == "Hela"))
	{
		return false;
	}
	
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
				//MADDERS, 5/29/22: Used to be 512. Too prone to snatching shit at random.
				forEach RadiusActors(class'Seat', TSeat, 384, SP.Location)
				{
					if ((TSeat != None) && (!SeatIsPawnTarget(TSeat)))
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

function bool SeatIsPawnTarget(Seat TSeat)
{
	local ScriptedPawn TPawn;
	
	if (TSeat != None)
	{
		forEach AllActors(class'ScriptedPawn', TPawn)
		{
			if (TPawn.SeatActor == TSeat || (TSeat.Tag != TSeat.Class.Name && TPawn.OrderTag == TSeat.Tag))
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
	
	forEach RadiusActors(class'DeusExPlayer', DXP, TDist, A.Location)
	{
		if ((DXP != None) && (!DXP.IsInState('Dying')))
		{
			return False;
		}
	}
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

function int GetMissionNumber()
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
