//=============================================================================
// AugPower.
//=============================================================================
class AugPower extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

function Tick(float DT)
{
 	local bool bAugsOn;
 	local AugmentationManager AM;
	local VMDNPCAugmentationManager NPCAM;
 	
 	Super.Tick(DT);
 	
 	if (Player != None)
 	{
  		AM = Player.AugmentationSystem;
  		if (AM != None)
  		{
   			bAugsOn = ((AM.NumAugsActive() - int(bIsActive)) > 0);
   			
   			if ((bAugsOn) && (!bIsActive) && (!bDisabled)) Activate();
   			else if ((!bAugsOn && bIsActive) || (bIsActive && bDisabled)) Deactivate();
  		}
 	}
	if (VMBP != None)
	{
		NPCAM = VMBP.AugmentationSystem;
  		if (NPCAM != None)
  		{
   			bAugsOn = ((NPCAM.NumAugsActive() - int(bIsActive)) > 0);
   			
   			if ((bAugsOn) && (!bIsActive) && (!bDisabled)) Activate();
   			else if ((!bAugsOn && bIsActive) || (bIsActive && bDisabled)) Deactivate();
  		}
	}
}

state Active
{
Begin:
}

function Deactivate()
{
	Super.Deactivate();
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

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((1.0 - LevelValues[i]) * 100) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     AdvancedDescription="Power consumption for all augmentations is reduced by polyanilene circuits, plugged directly into cell membranes, that allow nanite particles to interconnect electronically without leaving their host cells."
     AdvancedDescLevels(0)="TECH ONE: Power drain of augmentations is reduced by %d%%."
     AdvancedDescLevels(1)="TECH TWO: Power drain of augmentations is reduced by %d%%."
     AdvancedDescLevels(2)="TECH THREE: Power drain of augmentations is reduced by %d%%."
     AdvancedDescLevels(3)="TECH FOUR: Power drain of augmentations is reduced by %d%%."
     
     //MADDERS: Don't spam this on/off noise. Yikes.
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     bSenselessBind=True //Why would you NOT want this?
     
     mpAugValue=0.650000
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconPowerRecirc'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconPowerRecirc_Small'
     AugmentationName="Power Recirculator"
     Description="Power consumption for all augmentations is reduced by polyanilene circuits, plugged directly into cell membranes, that allow nanite particles to interconnect electronically without leaving their host cells.|n|nTECH ONE: Power drain of augmentations is reduced by 10%.|n|nTECH TWO: Power drain of augmentations is reduced by 20%.|n|nTECH THREE: Power drain of augmentations is reduced by 40%.|n|nTECH FOUR: Power drain of augmentations is reduced by 60%."
     MPInfo="Reduces the cost of other augs.  Automatically used when needed.  Energy Drain: None"
     LevelValues(0)=0.900000
     LevelValues(1)=0.800000
     LevelValues(2)=0.600000
     LevelValues(3)=0.400000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=5
}
