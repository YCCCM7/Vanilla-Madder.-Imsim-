//=============================================================================
// Containers.
//=============================================================================
class Containers extends VMDBufferDeco
	abstract;

var() int numThings;
var() bool bGenerateTrash;

//
// copied from Engine.Decoration
//
function Destroyed()
{
	if((Pawn(Base) != None) && (Pawn(Base).CarriedDecoration == self))
		Pawn(Base).DropDecoration();
	
	Super.Destroyed();
}

//G-Flex: drop stuff here instead of Destroyed() so it won't happen on map transitions
simulated function Frag(class<fragment> FragType, vector Momentum, float DSize, int NumFrags) 
{
	local actor dropped;
	local class<actor> tempClass;
	local int i, NumFails;
	local Rotator rot;
	local Vector loc;
	local TrashPaper trash;
	local Rat vermin;
	
	if (bDidItemDrop) return;
	
	// trace down to see if we are sitting on the ground
	loc = vect(0,0,0);
	loc.Z -= CollisionHeight + 8.0;
	loc += Location;
	
	// only generate trash if we are on the ground
	if ((!FastTrace(loc)) && (bGenerateTrash))
	{
		// maybe spawn some paper
		for (i=0; i<4; i++)
		{
			if (FRand() < 0.75)
			{
				loc = Location;
				loc.X += (CollisionRadius / 2) - FRand() * CollisionRadius;
				loc.Y += (CollisionRadius / 2) - FRand() * CollisionRadius;
				loc.Z += (CollisionHeight / 2) - FRand() * CollisionHeight;
				trash = Spawn(class'TrashPaper',,, loc);
				if (trash != None)
				{
					trash.SetPhysics(PHYS_Rolling);
					trash.rot = RotRand(True);
					trash.rot.Yaw = 0;
					trash.dir = VRand() * 20 + vect(20,20,0);
					trash.dir.Z = 0;
				}
			}
		}
		
		// maybe spawn a rat
		//if (FRand() < 0.5)
		//---------------
		//MADDERS, 9/24/22: Tie rat spawns to our seed, as these do net an advantage that load/save could exploit.
		if (StoredSeed % 2 == 0)
		{
			loc = Location;
			loc.Z -= CollisionHeight;
			vermin = Spawn(class'Rat',,, loc);
			if (vermin != None)
				vermin.bTransient = true;
		}
	}
	
	if( (Contents != None || Content2 != None || Content3 != None) && (!Level.bStartup))
	{
		tempClass = Contents;
		if (TempClass == None)
		{
			TempClass = Content2;
			if (TempClass == None)
			{
				TempClass = Content3;
			}
			else
			{
				if ((Content3 != None) && (FRand() < 0.5))
				{
					TempClass = Content3;
				}
			}
		}
		else
		{
			if ((Content2 != None) && (FRand() < 0.33))
			{
				tempClass = Content2;
			}
			else if ((Content3 != None) && (FRand() < 0.5))
			{
				tempClass = Content3;
			}
		}
		
		for (i=0; i<numThings; i++)
		{
			loc = Location + (VRand()*CollisionRadius);
			loc.Z = Location.Z;
			rot = rot(0,0,0);
			rot.Yaw = FRand() * 65535;
			dropped = Spawn(tempClass,,, loc, rot);
			
			if (Dropped == None || ((Dropped.Region.Zone != Region.Zone) && (Dropped.Region.Zone == Level)))
			{
				if (NumFails < 200)
				{
					i--;
					NumFails++;
					continue;
				}
				else
				{
					Dropped = Spawn(tempClass,,, Location, rot);
				}
			}
			
			if (Dropped != None)
			{
				NumFails = 0;
				
				dropped.RemoteRole = ROLE_DumbProxy;
				dropped.SetPhysics(PHYS_Falling);
				dropped.bCollideWorld = true;
				dropped.Velocity = VRand() * 50;
				
				//MADDERS: Patch in new ammos
				if (DeusExAmmo(Dropped) != None)
				{
					DeusExAmmo(Dropped).bCrateSummoned = True;
					
					//MADDERS: Only swap out ammos based on the parent crate, and not their own seed.
					//This stops non-linear replacement locations from occuring.
					DeusExAmmo(Dropped).VMDAttemptCrateSwap(StoredSeed);
				}
				if (DeusExPickup(Dropped) != None)
				{
					//MADDERS: Only swap out pickups based on the parent crate, and not their own seed.
					//This stops non-linear replacement locations from occuring.
					DeusExPickup(Dropped).VMDAttemptCrateSwap(StoredSeed);
				}
				if (inventory(dropped) != None)
				{
					inventory(dropped).GotoState('Pickup', 'Dropped');
				}
			}
		}
	}
	
	bDidItemDrop = true;
	
	Super.Frag(FragType, Momentum, DSize, NumFrags);
}

function ApplySpecialStats()
{
	local bool bTripped;
	local int NumCon, AltSeed[3];
	local float TDiff;
	local string TMap;
	local VMDBufferPlayer VMP;
	local class<Inventory> TCon;
	
	Super.ApplySpecialStats();
	
	if (Contents != None)
	{
		NumCon++;
		TCon = Contents;
	}
	if (Content2 != None)
	{
		NumCon++;
		TCon = Content2;
	}
	if (Content3 != None)
	{
		NumCon++;
		TCon = Content3;
	}
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((NumCon == 1) && (VMP != None) && (VMP.bCraftingSystemEnabled) && (!VMDContentsImmuneToSwap(string(TCon))))
	{
		TDiff = VMP.CombatDifficulty;
		
		AltSeed[0] = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 7, True);
		AltSeed[1] = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5, True);
		AltSeed[2] = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 3, True);
		if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Loot Swap") || class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Loot Deletion"))
		{
			if ((AltSeed[1] == 2) && (VMP.SavedLootSwapSeverity > 0))
			{
				bTripped = true;
			}
			if ((AltSeed[1] == 4) && (VMP.SavedLootSwapSeverity > 1))
			{
				bTripped = true;
			}
			if ((AltSeed[2] == 2) && (VMP.SavedLootSwapSeverity > 2))
			{
				bTripped = true;
			}
		}
		
		//MADDERS, 4/23/23: Special exceptions! Don't do these for stability reasons.
		if (bTripped)
		{
			TMap = CAPS(class'VMDStaticFunctions'.Static.VMDGetMapName(Self));
			
			//MADDERS, 4/23/23: First up, the "ROFL" crate seed, where a massive explosion goes off when the map starts.
			if ((TMap == "04_NYC_NSFHQ") && (CrateBreakableMedGeneral(Self) != None))
			{
				switch(class'VMDStaticfunctions'.Static.StripBaseActorSeed(Self))
				{
					case 5:
					case 6:
						bTripped = false;
					break;
				}
			}
		}
		
		if (bTripped)
		{
			if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Loot Deletion"))
			{
				Contents = None;
				Content2 = None;
				Content3 = None;
				Destroy();
			}
			else
			{
				switch(TCon.Name)
				{
					case 'Ammo10mm':
					case 'Ammo20mm':
					case 'Ammo3006':
					case 'Ammo3006HEAT':
					case 'Ammo762mm':
					case 'AmmoBattery':
					case 'AmmoDart':
					case 'AmmoPlasma':
					case 'AmmoRocket':
					case 'AmmoRocketEMP':
					case 'AmmoRocketWP':
					case 'AmmoSabot':
					case 'AmmoShell':
					case 'Binoculars':
					case 'Lockpick':
					case 'Multitool':
					case 'WeaponEMPGrenade':
					case 'WeaponGasGrenade':
					case 'WeaponLAM':
					case 'WeaponLAW':
					case 'WeaponNanoVirusGrenade':
					case 'WeaponShuriken':
						TCon = class'VMDScrapMetal';
					break;
					
					case 'Ammo10mmGasCap':
					case 'Ammo3006Tranq':
					case 'AmmoDartPoison':
					case 'AmmoDartFlare':
					case 'AmmoNapalm':
					case 'AmmoPepper':
						TCon = class'VMDChemicals';
					break;
					
					//Don't infringe on HEAT 10mm. It's so damned rare.
					//Same with nanoplague
					case 'Ammo10mmHEAT':
					case 'AmmoPlasmaPlague':
					break;
					
					default:
						if (class<WeaponMod>(TCon) != None)
						{
							//Keep these, thank you.
							TCon = None;
						}
						else if (class<DeusExAmmo>(TCon) != None || class<DeusExWeapon>(TCon) != None)
						{
							TCon = class'VMDScrapMetal';
						}
						else
						{
							TCon = class'VMDChemicals';
						}
					break;
				}
				
				if (TCon != None)
				{
					Contents = TCon;
					Content2 = None;
					Content3 = None;
				}
			}
		}
	}
}

function bool VMDContentsImmuneToSwap(string CheckStr)
{
	//MADDERS: Sometimes Zodiac and other mods have non-DX weapons that are essential to mission completion. Keep these.
	if (InStr(CheckStr, "DeusEx.") == -1)
	{
		return true;
	}
	return false;
}

defaultproperties
{
     bBlockSight=True // Transcended - Added
     numThings=1
     bFlammable=True
     bCanBeBase=True
}
