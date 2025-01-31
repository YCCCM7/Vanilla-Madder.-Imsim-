//=============================================================================
// AugAqualung.
//=============================================================================
class AugAqualung extends VMDBufferAugmentation;

var float mult, pct;

var float mpAugValue;
var float mpEnergyDrain;

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (Player != None)
	{
 		if ((!bIsActive) && (Player.HeadRegion.Zone.bWaterZone) && (!bDisabled)) Activate();
 		else if (((bIsActive) && (!Player.HeadRegion.Zone.bWaterZone)) || ((bIsActive) && (bDisabled))) Deactivate();
	}
}

state Active
{
Begin:
	mult = class'VMDStaticFunctions'.Static.GetPlayerSwimDurationMult(Player);
	//mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
	pct = Player.swimTimer / Player.swimDuration;
	Player.UnderWaterTime = LevelValues[CurrentLevel];
	Player.swimDuration = Player.UnderWaterTime * mult;
	Player.swimTimer = Player.swimDuration * pct;
	
	if ((Level.NetMode != NM_Standalone) && (Player.IsA('Human')))
	{
		mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
		Player.WaterSpeed = Human(Player).Default.mpWaterSpeed * 2.0 * mult;
	}
}

function Deactivate()
{
	Super.Deactivate();
	
	mult = class'VMDStaticFunctions'.Static.GetPlayerSwimDurationMult(Player);
	//mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
	pct = Player.swimTimer / Player.swimDuration;
	Player.UnderWaterTime = Player.Default.UnderWaterTime;
	Player.swimDuration = Player.UnderWaterTime * mult;
	Player.swimTimer = Player.swimDuration * pct;
	
	if ((Level.NetMode != NM_Standalone) && (Player.IsA('Human')))
	{
		mult = Player.SkillSystem.GetSkillLevelValue(class'SkillSwimming');
		Player.WaterSpeed = Human(Player).Default.mpWaterSpeed * mult;
	}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if (Level.NetMode != NM_StandAlone)
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
	}
}

//------------------------------------------
//MADDERS: Allow for more dynamic configuration of aug bonuses. Yeet.
//------------------------------------------
function float VMDConfigureLungMod(bool bWater)
{
 	return LevelValues[CurrentLevel];
}

defaultproperties
{
     //MADDERS: Don't spam this on/off noise. Yikes.
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     
     mpAugValue=240.000000
     mpEnergyDrain=10.000000
     EnergyRate=10.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconAquaLung'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconAquaLung_Small'
     AugmentationName="Aqualung"
     Description="Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater.|n|nTECH ONE: An agent can go 50% longer without breathing.|n|nTECH TWO: An agent can go 200% longer without breathing.|n|nTECH THREE: An agent can go 500% longer without breathing.|n|nTECH FOUR: An agent can stay underwater nearly indefinitely, at 1100% longer."
     MPInfo="When active, you can stay underwater 12 times as long and swim twice as fast.  Energy Drain: Low"
     LevelValues(0)=30.000000
     LevelValues(1)=60.000000
     LevelValues(2)=120.000000
     LevelValues(3)=240.000000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=9
}
