//=============================================================================
// AugmentationManager
//=============================================================================
class AugmentationManager extends Actor
	intrinsic;

struct S_AugInfo
{
	var int NumSlots;
	var int AugCount;
	var int KeyBase;
};

var travel S_AugInfo AugLocs[7];
var DeusExPlayer Player;				// which player am I attached to?
var travel Augmentation FirstAug;		// Pointer to first Augmentation

// All the available augmentations 
var Class<Augmentation> augClasses[25];
var Class<Augmentation> defaultAugs[3];

var localized string AugLocationFull;
var localized String NoAugInSlot;

// ----------------------------------------------------------------------
// Network Replication
// ----------------------------------------------------------------------

replication
{

    	//variables server to client
	reliable if ((Role == ROLE_Authority) && (bNetOwner))
	    AugLocs, FirstAug, Player;

	//functions client to server
	reliable if (Role < ROLE_Authority)
	    ActivateAugByKey, AddAllAugs, SetAllAugsToMaxLevel, ActivateAll, DeactivateAll, GivePlayerAugmentation;

}

// ----------------------------------------------------------------------
// CreateAugmentations()
// ----------------------------------------------------------------------

function CreateAugmentations(DeusExPlayer newPlayer)
{
	local int augIndex;
	local Augmentation anAug;
	local Augmentation lastAug;

	FirstAug = None;
	LastAug  = None;

	player = newPlayer;

	for(augIndex=0; augIndex<arrayCount(augClasses); augIndex++)
	{
		if (augClasses[augIndex] != None)
		{
			anAug = Spawn(augClasses[augIndex], Self);
			anAug.Player = player;

			// Manage our linked list
			if (anAug != None)
			{
				if (FirstAug == None)
				{
					FirstAug = anAug;
				}
				else
				{
					LastAug.next = anAug;
				}

				LastAug  = anAug;
			}
		}
	}
}

// ----------------------------------------------------------------------
// AddDefaultAugmentations()
// ----------------------------------------------------------------------

function AddDefaultAugmentations()
{
	local int augIndex;

	for(augIndex=0; augIndex<arrayCount(defaultAugs); augIndex++)
	{
		if (defaultAugs[augIndex] != None)
			GivePlayerAugmentation(defaultAugs[augIndex]);
	}
}

// ----------------------------------------------------------------------
// RefreshAugDisplay()
//
// Refreshes the Augmentation display with all the augs that are 
// currently active.
// ----------------------------------------------------------------------

simulated function RefreshAugDisplay()
{
	local Augmentation anAug;

	if (player == None)
		return;

	// First make sure there are no augs visible in the display
	player.ClearAugmentationDisplay();

	anAug = FirstAug;
	while(anAug != None)
	{
		// First make sure the aug is active if need be
		if (anAug.bHasIt)
		{
			if (anAug.bIsActive)
			{
				if (!anAug.IsInState('Active')) // Transcended - Added, superjump, cloak fix
					anAug.GotoState('Active');

				// Now, if this is an aug that isn't *always* active, then 
				// make sure it's in the augmentation display

				if (!anAug.bAlwaysActive)
					player.AddAugmentationDisplay(anAug);
			}
			else if ((player.bHUDShowAllAugs) && (!anAug.bAlwaysActive))
			{
				player.AddAugmentationDisplay(anAug);		
			}
		}

		anAug = anAug.next;
	}
}

// ----------------------------------------------------------------------
// NumAugsActive()
//
// How many augs are currently active?
// ----------------------------------------------------------------------

simulated function int NumAugsActive()
{
	local Augmentation anAug;
	local int count;

	if (player == None)
		return 0;

	count = 0;
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.bHasIt && anAug.bIsActive && !anAug.bAlwaysActive && (VMDBufferAugmentation(AnAug) == None || !VMDBufferAugmentation(AnAug).bPassive))
			count++;

		anAug = anAug.next;
	}

	return count;
}

// ----------------------------------------------------------------------
// SetPlayer()
// ---------------------------------------------------------------------

function SetPlayer(DeusExPlayer newPlayer)
{
	local Augmentation anAug;

	player = newPlayer;

	anAug = FirstAug;
	while(anAug != None)
	{
		anAug.player = player;
		if (VMDBufferAugmentation(AnAug) != None)
		{
			VMDBufferAugmentation(AnAug).VMDAugWasPoked();
		}
		anAug = anAug.next;
	}
}

// ----------------------------------------------------------------------
// BoostAugs()
// ----------------------------------------------------------------------

function BoostAugs(bool bBoostEnabled, Augmentation augBoosting)
{
	local Augmentation anAug;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		// Don't boost the augmentation causing the boosting!
		if ((anAug != augBoosting) && (AugLight(AnAug) == None))
		{
			if (bBoostEnabled)
			{
				//MADDERS, 4/23/23: Stop restarting spy drone for fuck's sake. It's awful.
				if ((anAug.bIsActive) && (VMDBufferAugmentation(AnAug) == None || !VMDBufferAugmentation(AnAug).bPassive) && (!anAug.bBoosted) && (anAug.CurrentLevel < anAug.MaxLevel))
				{
					if (AugDrone(AnAug) != None)
					{
						Player.ClientMessage(Sprintf(AnAug.AugDeactivated, AnAug.AugmentationName));
						Player.PlaySound(AnAug.DeactivateSound, SLOT_None);
						anAug.CurrentLevel++;
						anAug.bBoosted = True;
						AugDrone(AnAug).UpdateDroneTo(AnAug.CurrentLevel);
						Player.PlaySound(AnAug.ActivateSound, SLOT_None);
						Player.ClientMessage(Sprintf(AnAug.AugActivated, AnAug.AugmentationName));
					}
					else
					{
						anAug.Deactivate();
						anAug.CurrentLevel++;
						anAug.bBoosted = True;
						anAug.Activate();
					}
				}
			}
			else if (anAug.bBoosted)
			{
				anAug.CurrentLevel--;
				anAug.bBoosted = False;
				if (AugDrone(AnAug) != None)
				{
					AugDrone(AnAug).UpdateDroneTo(AnAug.CurrentLevel);
				}
			}
		}
		anAug = anAug.next;
	}
}

// ----------------------------------------------------------------------
// GetClassLevel()
// this returns the level, but only if the augmentation is
// currently turned on
// ----------------------------------------------------------------------

simulated function int GetClassLevel(class<Augmentation> augClass)
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.Class == augClass)
		{
			if ((VMDBufferAugmentation(AnAug) != None) && (VMDBufferAugmentation(AnAug).bPassive) && (!VMDBufferAugmentation(AnAug).bDisabled))
				return AnAug.CurrentLevel;
			else if (anAug.bHasIt && anAug.bIsActive)
				return anAug.CurrentLevel;
			else
				return -1;
		}

		anAug = anAug.next;
	}

	return -1;
}

// ----------------------------------------------------------------------
// GetAugLevelValue()
//
// takes a class instead of being called by actual augmentation
// ----------------------------------------------------------------------

simulated function float GetAugLevelValue(class<Augmentation> AugClass)
{
	local Augmentation anAug;
	local float retval;

	retval = 0;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.Class == augClass)
		{
			if ((VMDBufferAugmentation(AnAug) != None) && (VMDBufferAugmentation(AnAug).bPassive) && (!VMDBufferAugmentation(AnAug).bDisabled))
				return anAug.LevelValues[anAug.CurrentLevel];
			else if (anAug.bHasIt && anAug.bIsActive)
				return anAug.LevelValues[anAug.CurrentLevel];
			else
				return -1.0;
		}

		anAug = anAug.next;
	}

	return -1.0;
}

// ----------------------------------------------------------------------
// ActivateAll()
//
// Loops through all the Augmentations, deactivating any that are active.
// ----------------------------------------------------------------------

function ActivateAll()
{
	local Augmentation anAug;
	
	//MADDERS: 6/6/23: Can activate augs while dead or traveing? Oops.
	if ((Player != None) && (Player.IsInState('Paralyzed') || Player.IsInState('Dying') || IsInState('TrulyParalyzed')))
	{
		return;
	}
	
	// Only allow this if the player still has 
	// Bioleectric Energy(tm)
	if ((player != None) && (player.Energy > 0))
	{
		anAug = FirstAug;
		while(anAug != None)
		{
			if ((VMDBufferAugmentation(AnAug) != None) && (VMDBufferAugmentation(AnAug).bPassive))
			{
				AnAug = AnAug.Next;
				continue;
			}
			
			//MADDERS, 4/10/21: Don't activate spydrone with ActivateAll.
			//Let's be 100: Nobody has EVER wanted to turn all augs on and lose control of their body at the same time.
         		if ((Level.NetMode == NM_Standalone || !anAug.IsA('AugLight')) && (!AnAug.IsA('AugDrone')))
			{			
				anAug.Activate();
			}
			anAug = anAug.next;
		}
	}
}

// ----------------------------------------------------------------------
// DeactivateAll()
//
// Loops through all the Augmentations, deactivating any that are active.
// ----------------------------------------------------------------------

function DeactivateAll()
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if ((VMDBufferAugmentation(AnAug) != None) && (VMDBufferAugmentation(AnAug).bPassive))
		{
			AnAug = AnAug.Next;
			continue;
		}
		
		if (anAug.bIsActive)
			anAug.Deactivate();
		anAug = anAug.next;
	}
}

function DeactivateAllEconomy()
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if ((VMDBufferAugmentation(AnAug) != None) && (VMDBufferAugmentation(AnAug).bPassive))
		{
			AnAug = AnAug.Next;
			continue;
		}
		if (AnAug.GetEnergyRate() <= 0)
		{
			AnAug = AnAug.Next;
			continue;
		}
		
		if (anAug.bIsActive)
			anAug.Deactivate();
		anAug = anAug.next;
	}
}

// ----------------------------------------------------------------------
// FindAugmentation()
//
// Returns the augmentation based on the class name
// ----------------------------------------------------------------------

simulated function Augmentation FindAugmentation(Class<Augmentation> findClass)
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.Class == findClass)
			break;

		anAug = anAug.next;
	}

	return anAug;
}

// ----------------------------------------------------------------------
// GivePlayerAugmentation()
// ----------------------------------------------------------------------

function Augmentation GivePlayerAugmentation(Class<Augmentation> giveClass)
{
	local Augmentation anAug, TAug;
	local bool bFoundSlot;
	local int StartKey, FreeKey, i;

	// Checks to see if the player already has it.  If so, we want to 
	// increase the level
	anAug = FindAugmentation(giveClass);

	if (anAug == None)
		return None;		// shouldn't happen, but you never know!

	if (anAug.bHasIt)
	{
		anAug.IncLevel();
		return anAug;
	}

	if (AreSlotsFull(anAug))
	{
		Player.ClientMessage(AugLocationFull);
		return anAug;
	}

	anAug.bHasIt = True;

	if (anAug.bAlwaysActive)
	{
		anAug.Activate();
		//anAug.bIsActive = True;
		//anAug.GotoState('Active');
	}
	else
	{
		anAug.bIsActive = False;
	}


	if ( Player.Level.Netmode == NM_Standalone )
		Player.ClientMessage(Sprintf(anAug.AugNowHaveAtLevel, anAug.AugmentationName, anAug.CurrentLevel + 1));

	// Manage our AugLocs[] array
	AugLocs[anAug.AugmentationLocation].augCount++;
	
	//MADDERS, 8/17/23: Some augs have no good reason to be bound by default. Ignore hotkeying those ones.
	if ((!AnAug.bAlwaysActive) && (VMDBufferAugmentation(AnAug) == None || !VMDBufferAugmentation(AnAug).bSenselessBind))
	{
		// Assign hot key to new aug 
		// (must be after before augCount is incremented!)
   		if (Level.NetMode == NM_Standalone)
		{
			//MADDERS, 8/17/23: This method fucks up with replacing augs now. Let's overhaul it.
      			//anAug.HotKeyNum = AugLocs[anAug.AugmentationLocation].augCount + AugLocs[anAug.AugmentationLocation].KeyBase;
			//------------------------------
			//Here's the logic:
			//1. Check every aug in our slot series. If any owned aug takes up a key, keep looking.
			//2. If we find nothing, check every aug hotkey slot in general. Same routine, bigger scope.
			//3. If we found something, assign this aug key. I can't conceive of any time this would fail.
			StartKey = AugLocs[anAug.AugmentationLocation].KeyBase;
			for(i=StartKey+1; i<StartKey+1+AugLocs[AnAug.AugmentationLocation].NumSlots; i++)
			{
				bFoundSlot = true;
				for (TAug = FirstAug; TAug != None; TAug = TAug.Next)
				{
					if ((TAug != AnAug) && (TAug.bHasIt) && (!TAug.bAlwaysActive) && (TAug.HotKeyNum == i))
					{
						bFoundSlot = false;
						break;
					}
				}
				if (bFoundSlot)
				{
					FreeKey = i;
					break;
				}
			}
			
			if (!bFoundSlot)
			{
				for(i=3; i<13; i++)
				{
					bFoundSlot = true;
					for (TAug = FirstAug; TAug != None; TAug = TAug.Next)
					{
						if ((TAug != AnAug) && (TAug.bHasIt) && (!TAug.bAlwaysActive) && (TAug.HotKeyNum == i))
						{
							bFoundSlot = false;
							break;
						}
					}
					if (bFoundSlot)
					{
						FreeKey = i;
						break;
					}
				}
			}
			
			if (bFoundSlot)
			{
				AnAug.HotKeyNum = FreeKey;
			}
			else
			{
				AnAug.HotKeyNum = 3;
				Log("VMD WARNING: UNABLE TO FIND FREE KEY FOR "@AnAug);
			}
		}  
 		else
		{
      			anAug.HotKeyNum = anAug.MPConflictSlot + 2;
		}
	}
	
	if ((!anAug.bAlwaysActive) && (Player.bHUDShowAllAugs))
	{
		Player.AddAugmentationDisplay(anAug);
	}
	return anAug;
}

// ----------------------------------------------------------------------
// AreSlotsFull()
//
// For the given Augmentation passed in, checks to see if the slots
// for this aug are already filled up.  This is used to prevent to 
// prevent the player from adding more augmentations than the slots
// can accomodate.
// ----------------------------------------------------------------------

simulated function Bool AreSlotsFull(Augmentation augToCheck)
{
	local int num;
   	local bool bHasMPConflict;
	local Augmentation anAug;

	// You can only have a limited number augmentations in each location, 
	// so here we check to see if you already have the maximum allowed.

	num = 0;
   	bHasMPConflict = false;
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.AugmentationName != "")
		{
			if (augToCheck != anAug)
			{
				if (Level.Netmode == NM_Standalone)
            			{
               				if (augToCheck.AugmentationLocation == anAug.AugmentationLocation)
                  				if (anAug.bHasIt)
                     					num++;
            			}
            			else
            			{
               				if ((AnAug.MPConflictSlot == AugToCheck.MPConflictSlot) && (AugToCheck.MPConflictSlot != 0) && (AnAug.bHasIt))
               				{
                		  		bHasMPConflict = true;
               				}
				}
			}
		}		
		anAug = anAug.next;
	}
	if (Level.NetMode == NM_Standalone)
      		return (num >= AugLocs[augToCheck.AugmentationLocation].NumSlots);
   	else
      		return bHasMPConflict;
}

// ----------------------------------------------------------------------
// CalcEnergyUse()
//
// Calculates energy use for all active augmentations
// ----------------------------------------------------------------------

simulated function Float CalcEnergyUse(float deltaTime)
{
	local int ActiveAugs;
	local float energyUse, energyMult;
	local Augmentation anAug;
	local VMDBufferAugmentation VMA,  PowerAug;
	
	//MADDERS, 4/23/24: Update sounds here in case we forgor.
	if ((VMDBufferAugmentationManager(Self) != None) && (VMDBufferAugmentationManager(Self).bSoundUpdateQueued))
	{
		VMDBufferAugmentationManager(Self).bSoundUpdateQueued = false;
		
		for (AnAug = FirstAug; AnAug != None; AnAug = AnAug.next)
		{
			VMA = VMDBufferAugmentation(AnAug);
			if ((!AnAug.bAutomatic) && (!AnAug.bAlwaysActive) && (VMA == None || !VMA.bPassive) && (AnAug.bIsActive))
			{
				ActiveAugs += 1;
				Player.AmbientSound = AnAug.LoopSound;
				break;
			}
		}
		
		if (ActiveAugs <= 0)
		{
			Player.AmbientSound = None;
		}
	}
	
	energyUse = 0;
	energyMult = 1.0;

	anAug = FirstAug;
	while(anAug != None)
	{
		VMA = VMDBufferAugmentation(AnAug);
      		if (anAug.IsA('AugPower'))
		{
         		PowerAug = AugPower(anAug);
		}
		
		if (anAug.bHasIt && (anAug.bIsActive || (VMA != None && VMA.bPassive && !VMA.bDisabled)))
		{
			energyUse += ((anAug.GetEnergyRate()/60) * deltaTime);
			if (anAug.IsA('AugPower'))
         		{
				energyMult = anAug.LevelValues[anAug.CurrentLevel];
         		}
		}
		anAug = anAug.next;
	}
	
   	// DEUS_EX AMSD Manage the power aug automatically in multiplayer.
   	if ((Level.NetMode != NM_Standalone) && (PowerAug != None) && (PowerAug.bHasIt))
   	{
      		//If using energy, turn on the power aug.
      		if ((energyUse > 0) && (!PowerAug.bIsActive))
         		ActivateAugByKey(PowerAug.HotKeyNum - 3);
		
      		//If not using energy, turn off the power aug.
      		if ((energyUse == 0) && (PowerAug.bIsActive))
         		ActivateAugByKey(PowerAug.HotKeyNum - 3);

      		if (PowerAug.bIsActive || (PowerAug.bPassive && !PowerAug.bDisabled))				
         		energyMult = PowerAug.LevelValues[PowerAug.CurrentLevel];
   	}
	// check for the power augmentation
	energyUse *= energyMult;

	return energyUse;
}

// ----------------------------------------------------------------------
// AddAllAugs()
// ----------------------------------------------------------------------

function AddAllAugs()
{
	local int augIndex;

	// Loop through all the augmentation classes and create
	// any augs that don't exist.  Then set them all to the 
	// maximum level.

	for(augIndex=0; augIndex<arrayCount(augClasses); augIndex++)
	{
		if (augClasses[augIndex] != None)
			GivePlayerAugmentation(augClasses[augIndex]);
	}
}

// ----------------------------------------------------------------------
// SetAllAugsToMaxLevel()
// ----------------------------------------------------------------------

function SetAllAugsToMaxLevel()
{
	local Augmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.bHasIt)
			anAug.CurrentLevel = anAug.MaxLevel;

		anAug = anAug.next;
	}
}

// ----------------------------------------------------------------------
// IncreaseAllAugs()
// ----------------------------------------------------------------------

function IncreaseAllAugs(int Amount)
{
   	local Augmentation anAug;
   
   	anAug = FirstAug;
   	while(anAug != None)
   	{
      		if (anAug.bHasIt)
         		anAug.CurrentLevel = Min(anAug.CurrentLevel + Amount, anAug.MaxLevel);

      		anAug = anAug.next;
   	}
}

// ----------------------------------------------------------------------
// ActivateAugByKey()
// ----------------------------------------------------------------------

function bool ActivateAugByKey(int keyNum)
{	
	local Augmentation anAug;
	local bool bActivated;

	local VMDBufferAugmentation VMA;
	local VMDBufferAugmentationManager VMAM;

	bActivated = False;

	//MADDERS: 12/14/20: Can activate augs while dead? Oops.
	if ((Player != None) && (Player.IsInState('Paralyzed') || Player.IsInState('Dying') || IsInState('TrulyParalyzed')))
	{
		return false;
	}
	
	if ((keyNum < 0) || (keyNum > 9))
		return False;

	anAug = FirstAug;
	while(anAug != None)
	{
		if ((anAug.HotKeyNum - 3 == keyNum) && (anAug.bHasIt))
			break;

		anAug = anAug.next;
	}

	if (anAug == None)
	{
		player.ClientMessage(NoAugInSlot);
	}
	else
	{
		VMA = VMDBufferAugmentation(AnAug);
		VMAM = VMDBufferAugmentationManager(Self);
		if ((VMAM != None) && (VMA != None) && (VMA.bPassive))
		{
			VMA.bDisabled = !VMA.bDisabled;
			if (VMA.bDisabled)
			{
				Player.PlaySound(Sound'AugDeactivate', SLOT_None);
				Player.ClientMessage(SprintF(VMAM.MsgAugDisabled, VMA.AugmentationName));
			}
			else
			{
				Player.PlaySound(Sound'AugActivate', SLOT_None);
				Player.ClientMessage(SprintF(VMAM.MsgAugEnabled, VMA.AugmentationName));
			}
			if (Player.bHUDShowAllAugs)
			{
				Player.UpdateAugmentationDisplayStatus(VMA);
			}
			else
			{
				if (!VMA.bDisabled)
				{
					Player.RemoveAugmentationDisplay(VMA);
				}
				else
				{
					Player.AddAugmentationDisplay(VMA);
				}
			}
		}
		else if ((Player.Energy == 0) && (anAug.GetEnergyRate() > 0)) // Transcended - Allow free augs to be used
		{
			//G-Flex: mostly copied this from DeusExPlayer.ActivateAugmentation()
			//G-Flex: we can probably delete it from there
			Player.ClientMessage(Player.EnergyDepleted);
			Player.PlaySound(anAug.DeactivateSound, SLOT_None);
		}
		else
		{
			// Toggle
			if (anAug.bIsActive)
				anAug.Deactivate();
			else
				anAug.Activate();
		}
		bActivated = True;
	}

	return bActivated;
}

// ----------------------------------------------------------------------
// ResetAugmentations()
// ----------------------------------------------------------------------

function ResetAugmentations()
{
	local Augmentation anAug;
	local Augmentation nextAug;
    	local int LocIndex;

	anAug = FirstAug;
	while(anAug != None)
	{
		nextAug = anAug.next;
		anAug.Destroy();
		anAug = nextAug;
	}

	FirstAug = None;

    	//Must also clear auglocs.
    	for (LocIndex = 0; LocIndex < 7; LocIndex++)
    	{
        	AugLocs[LocIndex].AugCount = 0;
    	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     AugLocs(0)=(NumSlots=1,KeyBase=4)
     AugLocs(1)=(NumSlots=1,KeyBase=7)
     AugLocs(2)=(NumSlots=3,KeyBase=8)
     AugLocs(3)=(NumSlots=1,KeyBase=5)
     AugLocs(4)=(NumSlots=1,KeyBase=6)
     AugLocs(5)=(NumSlots=2,KeyBase=2)
     AugLocs(6)=(NumSlots=3,KeyBase=11)
     augClasses(0)=Class'DeusEx.AugSpeed'
     augClasses(1)=Class'DeusEx.AugTarget'
     augClasses(2)=Class'DeusEx.AugCloak'
     augClasses(3)=Class'DeusEx.AugBallistic'
     augClasses(4)=Class'DeusEx.AugRadarTrans'
     augClasses(5)=Class'DeusEx.AugShield'
     augClasses(6)=Class'DeusEx.AugEnviro'
     augClasses(7)=Class'DeusEx.AugEMP'
     augClasses(8)=Class'DeusEx.AugCombat'
     augClasses(9)=Class'DeusEx.AugHealing'
     augClasses(10)=Class'DeusEx.AugStealth'
     augClasses(11)=Class'DeusEx.AugIFF'
     augClasses(12)=Class'DeusEx.AugLight'
     augClasses(13)=Class'DeusEx.AugMuscle'
     augClasses(14)=Class'DeusEx.AugVision'
     augClasses(15)=Class'DeusEx.AugDrone'
     augClasses(16)=Class'DeusEx.AugDefense'
     augClasses(17)=Class'DeusEx.AugAqualung'
     augClasses(18)=Class'DeusEx.AugDatalink'
     augClasses(19)=Class'DeusEx.AugHeartLung'
     augClasses(20)=Class'DeusEx.AugPower'
     defaultAugs(0)=Class'DeusEx.AugLight'
     defaultAugs(1)=Class'DeusEx.AugIFF'
     defaultAugs(2)=Class'DeusEx.AugDatalink'
     AugLocationFull="You can't add any more augmentations to that location!"
     NoAugInSlot="There is no augmentation in that slot"
     bHidden=True
     bTravel=True
}
