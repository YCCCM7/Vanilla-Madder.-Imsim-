//=============================================================================
// AugAqualung.
//=============================================================================
class AugAqualung extends VMDBufferAugmentation;

var travel bool FakebIsActive; //MADDERS, 2/23/25: Thanks, I hate it.
var float mult, pct;

var float mpAugValue;
var float mpEnergyDrain;

function Tick(float DT)
{
 	Super.Tick(DT);
 	
	if (Player != None)
	{
 		if ((!FakebIsActive) && (!bDisabled) && (Player.Region.Zone != None) && (Player.Region.Zone.bWaterZone))
		{
			FakeActivate();
		}
 		else if (FakebIsActive && (bDisabled || Player.Region.Zone == None || !Player.Region.Zone.bWaterZone))
		{
			FakeDeactivate();
		}
	}
}

function bool IncLevel()
{
	local bool Ret;
	
	Ret = Super.IncLevel();
	if ((Ret) && (!bDisabled))
	{
		FakeActivate();
	}
	return Ret;
}

function FakeActivate()
{
	if (Player != None)
	{
		FakebIsActive = true;
		mult = class'VMDStaticFunctions'.Static.GetPlayerSwimDurationMult(Player);
		pct = Player.swimTimer / Player.swimDuration;
		Player.UnderWaterTime = LevelValues[CurrentLevel];
		Player.swimDuration = Player.UnderWaterTime * mult;
		Player.swimTimer = Player.swimDuration * pct;
	}
}

function FakeDeactivate()
{
	if (Player != None)
	{
		FakebIsActive = false;
		mult = class'VMDStaticFunctions'.Static.GetPlayerSwimDurationMult(Player);
		pct = Player.swimTimer / Player.swimDuration;
		Player.UnderWaterTime = Player.Default.UnderWaterTime;
		Player.swimDuration = Player.UnderWaterTime * mult;
		Player.swimTimer = Player.swimDuration * pct;
	}
}

state Active
{
Begin:
	if (Player != None)
	{
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
}

function Deactivate()
{
	Super.Deactivate();
	
	if (Player != None)
	{
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
	if (bDisabled)
	{
		return 0;
	}
	else
	{
 		return LevelValues[CurrentLevel];
	}
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int((LevelValues[i]-20.0) / 0.2));
	}
	
	return Ret;
}

defaultproperties
{
     //MADDERS: Don't spam this on/off noise. Yikes.
     ActivateSound=None
     DeActivateSound=None
     LoopSound=None
     bPassive=True
     bSenselessBind=True //Why would you NOT want this?
     
     AdvancedDescription="Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater."
     AdvancedDescLevels(0)="TECH ONE: An agent can go %d%% longer without breathing."
     AdvancedDescLevels(1)="TECH TWO: An agent can go %d%% longer without breathing."
     AdvancedDescLevels(2)="TECH THREE: An agent can go %d%% longer without breathing."
     AdvancedDescLevels(3)="TECH FOUR: An agent can stay underwater nearly indefinitely, at %d%% longer."
     
     mpAugValue=240.000000
     mpEnergyDrain=10.000000
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconAquaLung'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconAquaLung_Small'
     AugmentationName="Aqualung"
     Description="Soda lime exostructures imbedded in the alveoli of the lungs convert CO2 to O2, extending the time an agent can remain underwater.|n|nTECH ONE: An agent can go 50% longer without breathing.|n|nTECH TWO: An agent can go 200% longer without breathing.|n|nTECH THREE: An agent can go 500% longer without breathing.|n|nTECH FOUR: An agent can stay underwater nearly indefinitely, at 1100% longer."
     MPInfo="When active, you can stay underwater 12 times as long and swim twice as fast.  Energy Drain: Low"
     LevelValues(0)=25.000000
     LevelValues(1)=50.000000
     LevelValues(2)=100.000000
     LevelValues(3)=200.000000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=9
}
