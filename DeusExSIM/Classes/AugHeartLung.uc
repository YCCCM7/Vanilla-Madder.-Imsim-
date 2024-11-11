//=============================================================================
// AugHeartLung.
//=============================================================================
class AugHeartLung extends VMDBufferAugmentation;

var int InactiveCount;
var localized string MsgSavingPower;

state Active
{
Begin:
	// make sure if the player turns on any other augs while
	// this one is on, it gets affected also.
Loop:
	if ((Player != None) && (Player.AugmentationSystem != None))
	{
		Player.AugmentationSystem.BoostAugs(True, Self);
		if (NumAugsBoosted(Player.AugmentationSystem) - int(Player.AugmentationSystem.GetAugLevelValue(class'AugLight') > -1) < 1)
		{
			InactiveCount++;
		}
		else
		{
			InactiveCount = 0;
		}
		
		if (InactiveCount >= 15)
		{
			InactiveCount = 0;
			Player.ClientMessage(MsgSavingPower);
			Deactivate();
		}
	}
	else if ((VMBP != None) && (VMBP.AugmentationSystem != None))
	{
		VMBP.AugmentationSystem.BoostAugs(True, Self);
		if (NumVMBPAugsBoosted(VMBP.AugmentationSystem) - int(VMBP.AugmentationSystem.GetAugLevelValue(class'AugLight') > -1) < 1)
		{
			InactiveCount++;
		}
		else
		{
			InactiveCount = 0;
		}
		
		if (InactiveCount >= 15)
		{
			InactiveCount = 0;
			Deactivate();
		}
	}
	Sleep(0.2);
	
	Goto('Loop');
}

simulated function int NumAugsBoosted(AugmentationManager TSystem)
{
	local Augmentation anAug;
	local int count;
	
	if (TSystem == None || TSystem.Player == None)
		return 0;
	
	count = 0;
	anAug = TSystem.FirstAug;
	while(anAug != None)
	{
		if ((anAug.bHasIt) && (anAug.bIsActive) && (!anAug.bAlwaysActive) && (AnAug.bBoosted))
		{
			if (VMDBufferAugmentation(AnAug) == None || !VMDBufferAugmentation(AnAug).bPassive)
			{
				count++;
			}
		}
		anAug = anAug.next;
	}
	
	return count;
}

simulated function int NumVMBPAugsBoosted(VMDNPCAugmentationManager TSystem)
{
	local Augmentation anAug;
	local int count;
	
	if (TSystem == None || TSystem.VMBP == None)
		return 0;
	
	count = 0;
	anAug = TSystem.FirstAug;
	while(anAug != None)
	{
		if ((anAug.bHasIt) && (anAug.bIsActive) && (!anAug.bAlwaysActive) && (AnAug.bBoosted))
		{
			if (VMDBufferAugmentation(AnAug) == None || !VMDBufferAugmentation(AnAug).bPassive)
			{
				count++;
			}
		}
		
		anAug = anAug.next;
	}
	
	return count;
}

function Deactivate()
{
	local Augmentation anAug;
	local AugmentationManager AM;
	
	Super.Deactivate();
	
	if ((Player != None) && (Player.AugmentationSystem != None))
	{
		AM = Player.AugmentationSystem;
		AM.BoostAugs(False, Self);
		
		//MADDERS, 11/11/24: This is crap. Stop doing this for fuck's sake.
		/*anAug = AM.FirstAug;
		while(anAug != None)
		{
			if ((anAug.bIsActive) && (anAug != Self) && (AugLight(AnAug) == None) && (AugDrone(AnAug) == None))
			{
				anAug.Deactivate();
			}
			anAug = anAug.next;
		}*/
	}
}

defaultproperties
{
     EnergyRate=25.000000
     MaxLevel=0
     Icon=Texture'DeusExUI.UserInterface.AugIconHeartLung'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconHeartLung_Small'
     AugmentationName="Synthetic Heart"
     Description="This synthetic heart circulates not only blood but a steady concentration of mechanochemical power cells, smart phagocytes, and liposomes containing prefab diamondoid machine parts, resulting in upgraded performance for all installed, non-passive augmentations.|n|n<UNATCO OPS FILE NOTE JR133-VIOLET> However, this will not enhance any augmentation past its maximum upgrade level. -- Jaime Reyes <END NOTE>|n|nNO UPGRADES"
     LevelValues(0)=1.000000
     AugmentationLocation=LOC_Torso
     MsgSavingPower="No augs to boost. Saving power..."
}
