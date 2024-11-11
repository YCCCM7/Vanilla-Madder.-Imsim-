//=============================================================================
// VMDNPCAugmentationManager
//=============================================================================
class VMDNPCAugmentationManager extends Actor;

struct S_AugInfo
{
	var int NumSlots;
	var int AugCount;
};

var S_AugInfo AugLocs[7];
var VMDBufferPawn VMBP;				// which buffer pawn am I attached to?
var VMDBufferAugmentation FirstAug;		// Pointer to first Augmentation

// All the available augmentations 
var Class<VMDBufferAugmentation> augClasses[32];

// ----------------------------------------------------------------------
// CreateAugmentations()
// ----------------------------------------------------------------------

function CreateAugmentations(VMDBufferPawn NewVMBP)
{
	local int augIndex;
	local VMDBufferAugmentation anAug, lastAug;
	
	FirstAug = None;
	LastAug  = None;
	
	VMBP = NewVMBP;
	
	for(augIndex=0; augIndex<arrayCount(augClasses); augIndex++)
	{
		if (augClasses[augIndex] != None)
		{
			anAug = Spawn(augClasses[augIndex], Self);
			anAug.VMBP = VMBP;
			
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
// RefreshAugDisplay()
//
// Refreshes the Augmentation display with all the augs that are 
// currently active.
// ----------------------------------------------------------------------

simulated function RefreshAugDisplay()
{
	local VMDBufferAugmentation anAug;
	
	if (VMBP == None)
		return;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		// First make sure the aug is active if need be
		if (anAug.bHasIt)
		{
			if (anAug.bIsActive)
			{
				if (!anAug.IsInState('Active')) // Transcended - Added, superjump, cloak fix
				{
					anAug.GotoState('Active');
				}
			}
		}
		
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
}

// ----------------------------------------------------------------------
// NumAugsActive()
//
// How many augs are currently active?
// ----------------------------------------------------------------------

simulated function int NumAugsActive()
{
	local VMDBufferAugmentation anAug;
	local int count;
	
	if (VMBP == None)
		return 0;
	
	count = 0;
	anAug = FirstAug;
	while(anAug != None)
	{
		if ((anAug.bHasIt) && (anAug.bIsActive) && (!anAug.bAlwaysActive))
			count++;
		
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
	
	return count;
}

// ----------------------------------------------------------------------
// SetVMBP()
// ---------------------------------------------------------------------

function SetVMBP(VMDBufferPawn NewVMBP)
{
	local VMDBufferAugmentation anAug;
	
	VMBP = NewVMBP;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		anAug.VMBP = VMBP;
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
}

// ----------------------------------------------------------------------
// BoostAugs()
// ----------------------------------------------------------------------

function BoostAugs(bool bBoostEnabled, VMDBufferAugmentation augBoosting)
{
	local VMDBufferAugmentation anAug;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		// Don't boost the augmentation causing the boosting!
		if ((anAug != augBoosting) && (AugLight(AnAug) == None))
		{
			if (bBoostEnabled)
			{
				//MADDERS, 4/23/23: Stop restarting spy drone for fuck's sake. It's awful.
				if ((anAug.bIsActive) && (!AnAug.bPassive) && (!anAug.bBoosted) && (anAug.CurrentLevel < anAug.MaxLevel))
				{
					anAug.Deactivate();
					anAug.CurrentLevel++;
					anAug.bBoosted = True;
					anAug.Activate();
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
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
}

// ----------------------------------------------------------------------
// GetClassLevel()
// this returns the level, but only if the augmentation is
// currently turned on
// ----------------------------------------------------------------------

simulated function int GetClassLevel(class<VMDBufferAugmentation> augClass)
{
	local VMDBufferAugmentation anAug;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.Class == augClass)
		{
			if ((AnAug.bPassive) && (!AnAug.bDisabled))
				return AnAug.CurrentLevel;
			else if (anAug.bHasIt && anAug.bIsActive)
				return anAug.CurrentLevel;
			else
				return -1;
		}
		
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
	
	return -1;
}

// ----------------------------------------------------------------------
// GetAugLevelValue()
//
// takes a class instead of being called by actual augmentation
// ----------------------------------------------------------------------

simulated function float GetAugLevelValue(class<VMDBufferAugmentation> AugClass)
{
	local VMDBufferAugmentation anAug;
	local float retval;
	
	retval = 0;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.Class == augClass)
		{
			if ((AnAug.bPassive) && (!AnAug.bDisabled))
				return anAug.LevelValues[anAug.CurrentLevel];
			else if ((anAug.bHasIt) && (anAug.bIsActive))
				return anAug.LevelValues[anAug.CurrentLevel];
			else
				return -1.0;
		}
		
		anAug = VMDBufferAugmentation(AnAug.Next);
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
	local VMDBufferAugmentation anAug;
	
	//MADDERS: 12/27/23: Don't activate augs while dead
	if (VMBP == None || VMBP.IsInState('Dying'))
	{
		return;
	}
	
	// Only allow this if the VMBP still has 
	// Bioleectric Energy(tm)
	if (VMBP.Energy > 0)
	{
		anAug = FirstAug;
		while(anAug != None)
		{
			if (AnAug.bPassive)
			{
				AnAug = VMDBufferAugmentation(AnAug.Next);
				continue;
			}
			
			//MADDERS, 12/28/23: Don't turn off good augs at bad times.
         		if (!AnAug.bBulkAugException)
			{
				anAug.Activate();
			}
			anAug = VMDBufferAugmentation(AnAug.Next);
		}
	}
}

function ActivateAugByClass(class<VMDBufferAugmentation> AugClass)
{
	local VMDBufferAugmentation anAug;
	
	//MADDERS: 12/27/23: Don't activate augs while dead
	if (VMBP == None || VMBP.IsInState('Dying') || AugClass == None)
	{
		return;
	}
	
	// Only allow this if the VMBP still has 
	// Bioleectric Energy(tm)
	if (VMBP.Energy > 0)
	{
		AnAug = FindAugmentation(AugClass);
		if (AnAug != None)
		{
			AnAug.Activate();
		}
	}
}

function DeactivateAugByClass(class<VMDBufferAugmentation> AugClass)
{
	local VMDBufferAugmentation anAug;
	
	//MADDERS: 12/27/23: Don't activate augs while dead
	if (VMBP == None || AugClass == None)
	{
		return;
	}
	
	AnAug = FindAugmentation(AugClass);
	if (AnAug != None)
	{
		AnAug.Deactivate();
	}
}

function ActivateAug(VMDBufferAugmentation anAug)
{
	//MADDERS: 12/27/23: Don't activate augs while dead
	if (VMBP == None || VMBP.IsInState('Dying') || AnAug == None)
	{
		return;
	}
	
	// Only allow this if the VMBP still has 
	// Bioleectric Energy(tm)
	if (VMBP.Energy > 0)
	{
		AnAug.Activate();
	}
}

function DeactivateAug(VMDBufferAugmentation anAug)
{
	//MADDERS: 12/27/23: Don't activate augs while dead
	if (VMBP == None || AnAug == None)
	{
		return;
	}
	
	AnAug.Deactivate();
}

function ActivateAllEco()
{
	local VMDBufferAugmentation anAug;
	
	//MADDERS: 12/27/23: Don't activate augs while dead
	if ((VMBP != None) && (VMBP.IsInState('Dying')))
	{
		return;
	}
	
	// Only allow this if the VMBP still has 
	// Bioleectric Energy(tm)
	if ((VMBP != None) && (VMBP.Energy > 0))
	{
		anAug = FirstAug;
		while(anAug != None)
		{
			if (AnAug.bPassive)
			{
				AnAug = VMDBufferAugmentation(AnAug.Next);
				continue;
			}
			
			//MADDERS, 4/10/21: Don't activate spydrone with ActivateAll.
			//Let's be 100: Nobody has EVER wanted to turn all augs on and lose control of their body at the same time.
         		if (AnAug.bNPCEcoAug)
			{
				anAug.Activate();
			}
			anAug = VMDBufferAugmentation(AnAug.Next);
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
	local VMDBufferAugmentation anAug;

	anAug = FirstAug;
	while(anAug != None)
	{
		if (AnAug.bPassive)
		{
			AnAug = VMDBufferAugmentation(AnAug.Next);
			continue;
		}
		
		//MADDERS, 12/28/23: Don't turn off good augs at bad times.
		if ((anAug.bIsActive) && (!AnAug.bBulkAugException))
		{
			anAug.Deactivate();
		}
		
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
}

function DeactivateAllEconomy()
{
	local VMDBufferAugmentation anAug;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		if (AnAug.bPassive)
		{
			AnAug = VMDBufferAugmentation(AnAug.Next);
			continue;
		}
		if (AnAug.GetEnergyRate() <= 0)
		{
			AnAug = VMDBufferAugmentation(AnAug.Next);
			continue;
		}
		
		if (anAug.bIsActive)
		{
			anAug.Deactivate();
		}
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
}

// ----------------------------------------------------------------------
// FindAugmentation()
//
// Returns the augmentation based on the class name
// ----------------------------------------------------------------------

simulated function VMDBufferAugmentation FindAugmentation(Class<VMDBufferAugmentation> findClass)
{
	local VMDBufferAugmentation anAug;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.Class == findClass)
		{
			break;
		}
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
	
	return anAug;
}

// ----------------------------------------------------------------------
// GiveVMBPAugmentation()
// ----------------------------------------------------------------------

function VMDBufferAugmentation GiveVMBPAugmentation(Class<VMDBufferAugmentation> giveClass)
{
	local VMDBufferAugmentation anAug, TAug;
	local bool bFoundSlot;
	local int StartKey, FreeKey, i;
	
	// Checks to see if the VMBP already has it.  If so, we want to 
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
		return anAug;
	}
	
	anAug.bHasIt = True;
	
	if (anAug.bAlwaysActive)
	{
		anAug.Activate();
	}
	else
	{
		anAug.bIsActive = False;
	}
	
	// Manage our AugLocs[] array
	AugLocs[anAug.AugmentationLocation].augCount++;
	
	//MADDERS, 12/27/23: Barf, but for selectively used augs, save them for faster reference.
	//Let's not go gouging into our entire aug chain 5 times every frame of the game.
	switch(GiveClass.Name)
	{
		case 'AugCloak':
		case 'AugMechCloak':
			VMBP.CurCloakAug = AnAug;
		break;
		
		case 'AugCombat':
		case 'AugMechCombat':
			VMBP.CurCombatAug = AnAug;
		break;
		
		/*case 'AugHealing':
			VMBP.CurHealingAug = AnAug;
		break;*/
		
		/*case 'AugDrone':
			VMBP.CurDroneAug = AnAug;
		break;*/
		
		/*case 'AugRadarTrans':
			VMBP.CurRadarTransAug = AnAug;
		break;*/
		
		case 'AugSpeed':
		case 'AugMechSpeed':
			VMBP.CurSpeedAug = AnAug;
		break;
		
		case 'AugStealth':
			VMBP.CurStealthAug = AnAug;
		break;
		
		case 'AugTarget':
		case 'AugMechTarget':
			VMBP.CurTargetAug = AnAug;
		break;
		
		case 'AugVision':
		case 'AugMechVision':
			VMBP.CurVisionAug = AnAug;
		break;
		
		default:
			if (VMBP.BulkReferenceAug == None && !AnAug.bBulkAugException && !AnAug.bNPCEcoAug)
			{
				VMBP.BulkReferenceAug = AnAug;
			}
		break;
	}
	
	return anAug;
}

// ----------------------------------------------------------------------
// AreSlotsFull()
//
// For the given Augmentation passed in, checks to see if the slots
// for this aug are already filled up.  This is used to prevent to 
// prevent the VMBP from adding more augmentations than the slots
// can accomodate.
// ----------------------------------------------------------------------

simulated function Bool AreSlotsFull(VMDBufferAugmentation augToCheck)
{
	local int num;
	local VMDBufferAugmentation anAug;
	
	// You can only have a limited number augmentations in each location, 
	// so here we check to see if you already have the maximum allowed.
	
	num = 0;
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.AugmentationName != "")
		{
			if (augToCheck != anAug)
			{
				if (augToCheck.AugmentationLocation == anAug.AugmentationLocation)
				{
					if (anAug.bHasIt)
					{
	   					num++;
					}
				}
			}
	 	}
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
	return (num >= AugLocs[augToCheck.AugmentationLocation].NumSlots);
}

// ----------------------------------------------------------------------
// CalcEnergyUse()
//
// Calculates energy use for all active augmentations
// ----------------------------------------------------------------------

simulated function Float CalcEnergyUse(float deltaTime)
{
	local float energyUse, energyMult;
	local VMDBufferAugmentation anAug, PowerAug;
	
	energyUse = 0;
	energyMult = 1.0;
	
	anAug = FirstAug;
	while(anAug != None)
	{
      		if (anAug.IsA('AugPower'))
		{
         		PowerAug = anAug;
		}
		
		if ((anAug.bHasIt) && (anAug.bIsActive))
		{
			energyUse += ((anAug.GetEnergyRate()/60) * deltaTime);
			if (anAug.IsA('AugPower'))
         		{
				energyMult = anAug.LevelValues[anAug.CurrentLevel];
         		}
		}
		anAug = VMDBufferAugmentation(AnAug.Next);
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
	local int i;
	
	if (VMBP == None || !VMBP.bHasAugmentations) return;
	
	for(i=0; i<ArrayCount(VMBP.DefaultAugs); i++)
	{
		if (VMBP.DefaultAugs[i] != None)
		{
			GiveVMBPAugmentation(VMBP.DefaultAugs[i]);
		}
	}
}

// ----------------------------------------------------------------------
// SetAllAugsToMaxLevel()
// ----------------------------------------------------------------------

function SetAllAugsToMaxLevel()
{
	local VMDBufferAugmentation anAug;
	
	anAug = FirstAug;
	while(anAug != None)
	{
		if (anAug.bHasIt)
		{
			anAug.CurrentLevel = anAug.MaxLevel;
		}
		
		anAug = VMDBufferAugmentation(AnAug.Next);
	}
}

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//BUFFER AUGMENTATION MANAGER STUFF!
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

function float VMDConfigureDamageMult(name DT, int HitDamage, Vector HitLocation)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDamageMult(DT, HitDamage, HitLocation);
 	 	}
 	}
 	
 	return Ret;
}

function float VMDConfigureSpeedMult(bool bWater)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret *= VAug.VMDConfigureSpeedMult(bWater);
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureJumpMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureJumpMult();
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureLungMod(bool bWater)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 0.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
		
		//MADDERS, 8/8/23: Custom tweak for aqualung. Weird.
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret += VAug.VMDConfigureLungMod(bWater);
 	 	}
 	}
 	
 	return Ret;
}

function float VMDConfigureHealingMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret *= VAug.VMDConfigureHealingMult();
 	 	}
 	}
 	
 	return Ret;
}

function float VMDConfigureDecoPushMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDecoPushMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureDecoLiftMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDecoLiftMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureDecoThrowMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	 	 	Ret *= VAug.VMDConfigureDecoThrowMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureNoiseMult()
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret *= VAug.VMDConfigureNoiseMult();
 	 	}
 	}
	
 	return Ret;
}

function float VMDConfigureWepDamageMult(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	if (DXW == None) return 1.0;
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureWepDamageMult(DXW);
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureWepVelocityMult(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
	 
 	if (DXW == None) return 1.0;
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
  		VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureWepVelocityMult(DXW);
  		}
 	}
 	
 	return Ret;
}

function float VMDConfigureWepSwingSpeedMult(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	if (DXW == None) return 1.0;
 	Ret = 1.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			Ret *= VAug.VMDConfigureWepSwingSpeedMult(DXW);
  		}
 	}
 	
 	return Ret;
}


function float VMDConfigureWepAccuracyMod(DeusExWeapon DXW)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	if (DXW == None) return 0.0;
 	Ret = 0.0;
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
 	 	VAug = VMDBufferAugmentation(Aug);
 	 	if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
 	 	{
 	  		Ret += VAug.VMDConfigureWepAccuracyMod(DXW);
 	 	}
 	}
 	
 	return Ret;
}

function VMDSignalDamageTaken(int Damage, name DamageType, Vector HitLocation, bool bCheckOnly)
{
 	local Augmentation Aug;
 	local VMDBufferAugmentation VAug;
 	local float Ret;
 	
 	//For now, treat this as a no. Might change later? We'll see.
 	if (bCheckOnly) return;
 	
 	for (Aug = FirstAug; Aug != None; Aug = Aug.Next)
 	{
  		VAug = VMDBufferAugmentation(Aug);
  		if ((VAug != None) && (VAug.bHasIt) && (VAug.bIsActive || (VAug.bPassive && !VAug.bDisabled)))
  		{
   			VAug.VMDSignalDamageTaken(Damage, DamageType, HitLocation, bCheckOnly);
  		}
 	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     AugLocs(0)=(NumSlots=1,KeyBase=4)
     AugLocs(1)=(NumSlots=2,KeyBase=7) //Mech augs hold more eyeball shit I think, so shove more of it in here.
     AugLocs(2)=(NumSlots=3,KeyBase=8)
     AugLocs(3)=(NumSlots=1,KeyBase=5)
     AugLocs(4)=(NumSlots=1,KeyBase=6)
     AugLocs(5)=(NumSlots=3,KeyBase=2) //MADDERS, 12/27/23: Thank you Walton, for making me cheat. Newer firmware, I suppose?
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
     augClasses(11)=Class'DeusEx.AugMuscle'
     augClasses(12)=Class'DeusEx.AugVision'
     augClasses(13)=Class'DeusEx.AugDrone'
     augClasses(14)=Class'DeusEx.AugDefense'
     augClasses(15)=Class'DeusEx.AugAqualung'
     augClasses(16)=Class'DeusEx.AugHeartLung'
     augClasses(17)=Class'DeusEx.AugPower'
     
     augClasses(18)=Class'DeusEx.AugMechCloak'
     augClasses(19)=Class'DeusEx.AugMechDermal'
     augClasses(20)=Class'DeusEx.AugMechEMP'
     augClasses(21)=Class'DeusEx.AugMechEnergy'
     augClasses(22)=Class'DeusEx.AugMechEnviro'
     augClasses(23)=Class'DeusEx.AugMechSpeed'
     augClasses(24)=Class'DeusEx.AugMechTarget'
     augClasses(25)=Class'DeusEx.AugMechVision'
     bHidden=True
}
