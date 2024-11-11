//=============================================================================
// AugMechVision.
//=============================================================================
class AugMechVision extends VMDMechAugmentation;

var bool bLastActive;

// ----------------------------------------------------------------------------
// Networking Replication
// ----------------------------------------------------------------------------

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
		SetVisionAugStatus(CurrentLevel,LevelValues[CurrentLevel],True);
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
		SetVisionAugStatus(CurrentLevel,LevelValues[CurrentLevel],False);
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
     AdvancedDescription="An optical membrane implant that allows the user to see through walls."
     AdvancedDescLevels(0)="TECH ONE: Thermal imaging, and sonar vision out to %d ft of range."
     MaxLevel=0
     
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconVision'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconVision_Small'
     AugmentationName="Smart Vision"
     LevelValues(0)=720.000000
     AugmentationLocation=LOC_Eye
}
