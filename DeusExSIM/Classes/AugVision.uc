//=============================================================================
// AugVision.
//=============================================================================
class AugVision extends VMDBufferAugmentation;

var float mpAugValue, mpEnergyDrain;
var bool bLastActive;

// ----------------------------------------------------------------------------
// Networking Replication
// ----------------------------------------------------------------------------

replication
{
	//server to client function calls
	reliable if (Role == ROLE_Authority)
		SetVisionAugStatus;
}

state Active
{
Begin:
}

function Activate()
{
	local bool bWasActive;
	
	bWasActive = bIsActive;
	
	Super.Activate();
	
	if ((!bWasActive) && (bIsActive))
	{ 
		SetVisionAugStatus(CurrentLevel, LevelValues[CurrentLevel], True);
		if (Player != None)
		{
			Player.RelevantRadius = LevelValues[CurrentLevel]*1.2; //Attempt to clean this up some, hopefully...
		}
	}
}

function Deactivate()
{
	local bool bWasActive;
	
	bWasActive = bIsActive;
	
	Super.Deactivate();
	
	if ((bWasActive) && (!bIsActive))
	{
		SetVisionAugStatus(CurrentLevel, LevelValues[CurrentLevel], False);
		if (Player != None)
		{
			Player.RelevantRadius = 0;
		}
	}
}

// ----------------------------------------------------------------------
// SetVisionAugStatus()
// ----------------------------------------------------------------------

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
	local AugmentationDisplayWindow TDisplay;
	
	if ((Player != None) && (DeusExRootWindow(Player.RootWindow) != None))
	{
		TDisplay = DeusExRootWindow(Player.rootWindow).augDisplay;
		if (TDisplay == None) return;
		
		//MADDERs, 8/16/23: Well, came to investigate this because it initially was
		//outdated logic, when HUD controlled augmentation display window.
		//...Then I realized the logic sucked and was horribly unoptimized.
		//...Then I realized that calling this at a bad timing glitches out vision aug,
		//due to a very brave operator.
		//Hopefully this new code solves this entire mess.
		//----------------------------------------------------------------------------
		//-Use last active to not change active count redundantly.
		//-But, if the root window is recreated (any time map changes or a save is loaded),
		//then our count gets reset. So be willing to admit we can be wrong about activecount vs bLastActive.
		//-Similarly, when turning off, active count can go from 0 to -1, so install a floor.
		//-In theory, there's now a bug of loading a save with both vision aug and tech goggles active, then turning off vision.
		//But we can't really devise any fix for it, because you should never rely on variables on transient actors, for fuck's sake.
		//Vanilla's bad code method, not mine. We'll call this edge case acceptable for now.
   		if (IsActive)
   		{
			if (!bLastActive || TDisplay.ActiveCount == 0)
			{
				TDisplay.ActiveCount++;
				TDisplay.bVisionActive = true;
				bLastActive = true;
			}
   		}
   		else
   		{
			if (bLastActive)
			{
      				TDisplay.ActiveCount = Max(TDisplay.ActiveCount-1, 0);
				if (TDisplay.ActiveCount == 0)
				{
        	 			TDisplay.bVisionActive = False;
				}
			 	TDisplay.VisionBlinder = None;
				bLastActive = false;
			}
   		}
		TDisplay.visionLevel = Level;
   		TDisplay.visionLevelValue = LevelValue;
	}
	else if (VMBP != None)
	{
		//To be continued...
	}
}

//MADDERS, 6/26/24: Fix for targeting not rebooting after we start.
//Sometimes we're also out of range and in stasis, so tick can't save us. Great to see.
function VMDAugWasPoked()
{
	if (bIsActive)
	{
		bLastActive = false;
		SetVisionAugStatus(CurrentLevel, LevelValues[CurrentLevel], bIsActive);
	}
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int((LevelValues[i] / 16.0) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="By bleaching selected rod photoreceptors and saturating them with metarhodopsin XII, the 'infravision' present in many commercial goggles can be duplicated. Subsequent upgrades increase the distance of infravision and sonar-resonance imaging, better allowing an agent to see through walls."
     AdvancedDescLevels(0)="TECH ONE: Thermal imaging, and sonar vision out to %d ft of range."
     AdvancedDescLevels(1)="TECH TWO: Sonar imaging is extended to %d feet."
     AdvancedDescLevels(2)="TECH THREE: Sonar imaging is extended to %d feet."
     AdvancedDescLevels(3)="TECH FOUR: Sonar imaging is extended to %d feet."
     
     mpAugValue=800.000000
     mpEnergyDrain=50.000000
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconVision'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconVision_Small'
     AugmentationName="Vision Enhancement"
     Description="By bleaching selected rod photoreceptors and saturating them with metarhodopsin XII, the 'infravision' present in many commercial goggles can be duplicated. Subsequent upgrades increase the distance of infravision and sonar-resonance imaging, better allowing an agent to see through walls.|n|nTECH ONE: Thermal imaging, and sonar vision out to 15 ft of range.|n|nTECH TWO: Sonar imaging is extended to 30 feet.|n|nTECH THREE: Sonar imaging is extended to 45 feet.|n|nTECH FOUR: Sonar imaging is extended to 60 feet."
     MPInfo="When active, you can see enemy players in the dark from any distance, and for short distances you can see through walls and see cloaked enemies.  Energy Drain: Moderate"
     LevelValues(0)=240.000000
     LevelValues(1)=480.000000
     LevelValues(2)=720.000000
     LevelValues(3)=960.000000
     AugmentationLocation=LOC_Eye
     MPConflictSlot=6
}
