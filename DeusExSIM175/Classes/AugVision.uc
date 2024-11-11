//=============================================================================
// AugVision.
//=============================================================================
class AugVision extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

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
		SetVisionAugStatus(CurrentLevel,LevelValues[CurrentLevel],True);
		Player.RelevantRadius = LevelValues[CurrentLevel];
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
		Player.RelevantRadius = 0;
	}
}

// ----------------------------------------------------------------------
// SetVisionAugStatus()
// ----------------------------------------------------------------------

simulated function SetVisionAugStatus(int Level, int LevelValue, bool IsActive)
{
   	if (IsActive)
   	{
      		if (++DeusExRootWindow(Player.rootWindow).hud.augDisplay.activeCount == 1)      
         		DeusExRootWindow(Player.rootWindow).hud.augDisplay.bVisionActive = True;
   	}
   	else
   	{
      		if (--DeusExRootWindow(Player.rootWindow).hud.augDisplay.activeCount == 0)
         		DeusExRootWindow(Player.rootWindow).hud.augDisplay.bVisionActive = False;
      		DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionBlinder = None;
   	}
	DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevel = Level;
   	DeusExRootWindow(Player.rootWindow).hud.augDisplay.visionLevelValue = LevelValue;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
	}
}

defaultproperties
{
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
