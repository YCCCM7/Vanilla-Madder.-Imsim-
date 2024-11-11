//=============================================================================
// AugRadarTrans.
//=============================================================================
class AugRadarTrans extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

function Tick(float DT)
{
 	Super.Tick(DT);
 	
 	/*if (FRand() < 1.0 / (180 / Max(1, CurrentLevel)))
 	{
  		if (bIsActive) Deactivate();
  		else Activate();
 	}*/
}

state Active
{
Begin:
}

function Deactivate()
{
	Super.Deactivate();
}

function float GetEnergyRate()
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
      		AugmentationLocation = LOC_Torso;
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
     AdvancedDescription="Radar-absorbent resin augments epithelial proteins; microprojection units distort agent's visual signature. Provides highly effective concealment from automated detection systems -- bots, cameras, turrets, and some forms of bionic vision."
     AdvancedDescLevels(0)="TECH ONE: Power drain is normal, at %d units per minute."
     AdvancedDescLevels(1)="TECH TWO: Power drain is reduced slightly, at %d units per minute."
     AdvancedDescLevels(2)="TECH THREE: Power drain is reduced moderately, at %d units per minute."
     AdvancedDescLevels(3)="TECH FOUR: Power drain is reduced significantly, at %d units per minute."
     
     mpAugValue=0.500000
     mpEnergyDrain=30.000000
     EnergyRate=300.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconRadarTrans'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconRadarTrans_Small'
     AugmentationName="Radar Transparency"
     Description="Radar-absorbent resin augments epithelial proteins; microprojection units distort agent's visual signature. Provides highly effective concealment from automated detection systems -- bots, cameras, turrets, and some forms of bionic vision.|n|nTECH ONE: Power drain is normal, at 300 units per minute.|n|nTECH TWO: Power drain is reduced slightly, at 250 units per minute.|n|nTECH THREE: Power drain is reduced moderately, at 200 units per minute.|n|nTECH FOUR: Power drain is reduced significantly, at 150 units per minute."
     MPInfo="When active, you are invisible to electronic devices such as cameras, turrets, and proximity mines.  Energy Drain: Very Low"
     LevelValues(0)=1.000000
     LevelValues(1)=0.834000
     LevelValues(2)=0.667000
     LevelValues(3)=0.500000
     AugmentationLocation=LOC_Subdermal
     MPConflictSlot=2
}
