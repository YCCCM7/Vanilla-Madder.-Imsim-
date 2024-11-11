//=============================================================================
// AugCloak.
//=============================================================================
class AugCloak extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

/*function Tick(float DT)
{
 	Super.Tick(DT);
 	
 	if (FRand() < 1.0 / (180 / Max(1, CurrentLevel)))
 	{
  		if (bIsActive) Deactivate();
  		else Activate();
 	}
}*/

state Active
{
Begin:
	if ((Player != None) && (DeusExWeapon(Player.inHand) != None))
	{
		Player.ServerConditionalNotifyMsg(Player.MPMSG_NoCloakWeapon);
		Player.PlaySound(Sound'CloakUp', SLOT_Interact, 0.85, ,768,1.0);
	}
}

function Deactivate()
{
	if (Player != None)
	{
		Player.PlaySound(Sound'CloakDown', SLOT_Interact, 0.85, ,768,1.0);
	}
	
	Super.Deactivate();
}

simulated function float GetEnergyRate()
{
	return energyRate * LevelValues[CurrentLevel];
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
      		AugmentationLocation = LOC_Eye;
	}
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int((EnergyRate * LevelValues[i]) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Subdermal pigmentation cells allow the agent to blend with their surrounding environment, rendering them effectively invisible to observation by organic hostiles."
     AdvancedDescLevels(0)="TECH ONE: Power drain is normal, at %d units per minute."
     AdvancedDescLevels(1)="TECH TWO: Power drain is reduced slightly, at %d units per minute."
     AdvancedDescLevels(2)="TECH THREE: Power drain is reduced moderately, at %d units per minute."
     AdvancedDescLevels(3)="TECH FOUR: Power drain is reduced significantly, at %d units per minute."
     
     mpAugValue=1.000000
     mpEnergyDrain=40.000000
     EnergyRate=300.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconCloak'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconCloak_Small'
     AugmentationName="Cloak"
     Description="Subdermal pigmentation cells allow the agent to blend with their surrounding environment, rendering them effectively invisible to observation by unaided organic hostiles.|n|nTECH ONE: Power drain is normal, at 300 units per minute.|n|nTECH TWO: Power drain is reduced slightly, at 250 units per minute.|n|nTECH THREE: Power drain is reduced moderately, at 200 units per minute.|n|nTECH FOUR: Power drain is reduced significantly, at 150 units per minute."
     MPInfo="When active, you are invisible to enemy players.  Electronic devices and players with the vision augmentation can still detect you.  Cannot be used with a weapon.  Energy Drain: Moderate"
     LevelValues(0)=1.000000
     LevelValues(1)=0.834000
     LevelValues(2)=0.667000
     LevelValues(3)=0.500000
     AugmentationLocation=LOC_Subdermal
     MPConflictSlot=6
}
