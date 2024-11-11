//=============================================================================
// VMDBountyHunterSpawner.
//=============================================================================
class VMDBountyHunterSpawner extends VMDFillerActors transient;

var bool bRanTweaks, bRevisionMapSet;
var int RandIndex, RandBarf[100];
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
 		if (TweakTimer < 0.8)
		{
			TweakTimer += DT;
		} 
		else if (TweakTimer > -10)
 		{
 	 		TweakTimer = -30;
			SpawnHunters();
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

function SpawnHunters()
{
	local bool bDebug;
	local int TMission, SpawnStrength, HideListSize, TIndex, SpawnAttempts, StartingID, i, j;
	local float TOdds;
	local Vector BaseLoc, TLoc;
	local Rotator TRot;
	local HidePoint THide, HideList[32];
	local Pawn TPawn;
	local VMDBountyHunter THunters[10];
	local VMDBufferPawn VMBP;
	local class<VMDBountyHunter> HunterClass;
	
	bRanTweaks = true;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP == None)
	{
		VMP = VMDBufferPlayer(GetPlayerPawn());
	}
	
	bDebug = false;
	if (!bDebug)
	{
		if (VMP == None || !VMP.bMayhemSystemEnabled) return;
		if (VMP.MayhemFactor < VMP.SavedHunterThreshold || !VMP.bBountyHuntersEnabled) return;
	}
	
	if (class'VMDStaticFunctions'.Static.VMDIsWeaponSensitiveMap(Self, true))
	{
		if (bDebug) BroadcastMessage("SENSITIVE MAP! NO COVERAGE!");
		return;
	}
	
	InitRandData(VMP);
	
	TMission = VMDGetMissionNumber();
	HunterClass = class'NSFMechBountyHunter';
	if (TMission > 15)
	{
		switch(FakeRand(3))
		{
			case 0:
				HunterClass = class'NSFMechBountyHunter';
			break;
			case 1:
				HunterClass = class'MJ12NanoAugBountyHunter';
			break;
			case 2:
				HunterClass = class'MJ12CyborgBountyHunter';
			break;
		}
	}
	else if (TMission >= 11)
	{
		HunterClass = class'MJ12NanoAugBountyHunter';
	}
	else if (TMission >= 5)
	{
		HunterClass = class'MJ12CyborgBountyHunter';
	}
	
	//If other bounty hunters exist, don't do this.
	for (TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
	{
		VMBP = VMDBufferPawn(TPawn);
		if ((!TPawn.bDeleteMe) && (VMBP != None) && (VMBP.bInWorld))
		{
			//Condition 1 for bad map: We have hunters.
			if (VMDBountyHunter(VMBP) != None)
			{
				return;
			}
			
			//Condition 2 for bad map: We have an alliance who doesn't like us hanging out.
			switch(VMBP.Alliance)
			{
				case 'Player': //Player alliance, save for MEGH and SIDD, indicates pacifist map.
					if (VMDMEGH(VMBP) == None && VMDSIDD(VMBP) == None)
					{
						if (bDebug) BroadcastMessage("PLAYER DUDES COCKBLOCKING US");
						
						return;
					}
				break;
				case 'UNATCO': //UNATCO before Denton's fully gone rogue doesn't want us poking around.
					if (TMission < 6)
					{
						if (bDebug) BroadcastMessage("UNATCO DUDES COCKBLOCKING US");
						
						return;
					}
				break;
				case 'NSF': //NSF after Denton's gone rogue are gonna make dropping in a pickle.
					if (TMission > 4)
					{
						if (bDebug) BroadcastMessage("NSF DUDES COCKBLOCKING US");
						
						return;
					}
				break;
			}
		}
	}
	
	TOdds = 0.4 + (VMP.AllureFactor * 0.15);
	if (TOdds > 1.45)
	{
		SpawnStrength = 2;
	}
	else if (TOdds > 1.0)
	{
		SpawnStrength = 1;
	}
	
	if (FakeFRand() < TOdds)
	{
		SpawnStrength += 1;
	}
	
	if (bDebug)
	{
		SpawnStrength = 10;
	}
	
	if (SpawnStrength > 0)
	{
		ForEach AllActors(class'HidePoint', THide)
		{
			if ((VSize(THide.Location - VMP.Location) > 800) && (!FastTrace(VMP.Location, THide.Location)))
			{
				HideList[HideListSize] = THide;
				HideListSize++;
				if (HideListSize >= ArrayCount(HideList))
				{
					break;
				}
			}
		}
		
		if (HideListSize <= 0)
		{
			if (bDebug) BroadcastMessage("HIDE LIST SIZE?"@HideListSize);
		}
		else
		{
			StartingID = Rand(3 - (SpawnStrength-1));
			TIndex = Rand(HideListSize);
			THide = HideList[TIndex];
			BaseLoc = THide.Location;
			for(i=0; i<SpawnStrength; i++)
			{
				if (i == 0)
				{
					TRot = THide.Rotation;
					TLoc = BaseLoc;
				}
				else
				{
					TRot.Yaw = Rand(65536);
					TLoc = BaseLoc + Vector(TRot) * 128;
				}
				
				if (FastTrace(BaseLoc, TLoc))
				{
					THunters[i] = Spawn(HunterClass,,, TLoc, THide.Rotation);
				}
				
				if ((i == 0) && (THunters[i] == None))
				{
					if (bDebug) BroadcastMessage("FAILED BASE HUNTER SPAWN AT"@THide);
					return;
				}
				else if ((i > 0) && (THunters[i] == None))
				{
					SpawnAttempts = 20;
					for (j=0; j<SpawnAttempts; j++)
					{
						TRot.Yaw = Rand(65536);
						TLoc = BaseLoc + Vector(TRot) * 128;
						TRot.Yaw = Rand(65536); //Use for spawn rotation
						if (FastTrace(BaseLoc, TLoc))
						{
							THunters[i] = Spawn(HunterClass,,, TLoc, TRot);
						}
						
						if (THunters[i] != None)
						{
							break;
						}
						else if (j == (SpawnAttempts-1))
						{
							if (bDebug) BroadcastMessage("FAILED SECONDARY HUNTER SPAWN AT"@THide@"HIS NUMBER WAS"@(i+1));
							return;
						}
					}
				}
				
				if (THunters[i] != None)
				{
					THunters[i].AssignedID = StartingID + i;
					THunters[i].InitializeBountyHunter(i, VMP, TMission);
				}
			}
		}
	}
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
