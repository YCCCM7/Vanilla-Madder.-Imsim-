//=============================================================================
// AugDrone.
//=============================================================================
class AugDrone extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

var float reconstructTime;
var float lastDroneTime;

var localized String ReconstructionPrefix;
var localized String ReconstructionSecond, ReconstructionSeconds;
var localized String LowEnergy;

var int timeLeft;

function UpdateDroneTo(int NewLevel)
{
	if (Player != None)
	{
		Player.SpyDroneLevel = NewLevel;
		Player.SpyDroneLevelValue = LevelValues[NewLevel];
		
		if (Player.ADrone != None)
		{
			Player.ADrone.Speed = 3 * Player.SpyDroneLevelValue;
			Player.ADrone.MaxSpeed = 3 * Player.SpyDroneLevelValue;
			Player.ADrone.Damage = 5 * Player.SpyDroneLevelValue;
			Player.ADrone.blastRadius = 8 * Player.SpyDroneLevelValue;
		}
	}
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (LastDroneTime > 0)
	{
		LastDroneTime -= DT;
	}
}

state Active
{
	function BeginState()
	{
		Super.BeginState();
	}
Begin:
	
	if (LastDroneTime > 0)
	{
		if (Player != None)
		{
			timeLeft = int((reconstructTime - (Level.TimeSeconds - lastDroneTime)) + 0.99);
			if (timeLeft == 1)
			{
				Player.ClientMessage(ReconstructionPrefix @ int(LastDroneTime+0.99) @ ReconstructionSecond);
			}
			else
			{
				Player.ClientMessage(ReconstructionPrefix @ int(LastDroneTime+0.99) @ ReconstructionSeconds);
			}
		}
		Deactivate();
	}
	else
	{
		if (Player != None)
		{
			Player.bSpyDroneActive = True;
			Player.spyDroneLevel = CurrentLevel;
			Player.spyDroneLevelValue = LevelValues[CurrentLevel];
		}
	}
}

function Deactivate()
{
	local AugLight aLight;
	
	Super.Deactivate();
	
	if (Player != None)
	{
		// record the time if we were just active
		if (Player.bSpyDroneActive)
		{
			lastDroneTime = ReconstructTime;
		}
		
		aLight = AugLight(Player.AugmentationSystem.FindAugmentation(class'AugLight'));
		if (aLight != None)
		{
			if (aLight.b4 != None)
			{
				aLight.b4.Destroy();
				aLight.b4 = None;
			}
			if (aLight.b5 != None)
			{
				aLight.b5.Destroy();
				aLight.b5 = None;
			}
			if (aLight.b6 != None)
			{
				aLight.b6.Destroy();
				aLight.b6 = None;
			}				
		}
		
		Player.bSpyDroneActive = False;
		Player.bBehindView = False; // To make the camera reset if using the alternate mode.
	}
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
	
	Ret = AdvancedDescription$"|n|n"$AdvancedDescLevels[0];
	
	for (i=1; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 20.0) * 10) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Advanced nanofactories can assemble a spy drone upon demand which can then be remotely controlled by the agent until released or destroyed, at which a point a new drone will be assembled."
     AdvancedDescLevels(0)="TECH ONE: Drone speed is standard. It possesses an EMP blast of 100 damage out to a 10 ft radius."
     AdvancedDescLevels(1)="TECH TWO: Drone speed is increased by %d%%, as is blast radius and EMP damage."
     AdvancedDescLevels(2)="TECH THREE: Drone speed is increased by %d%%, as is blast radius and EMP damage."
     AdvancedDescLevels(3)="TECH FOUR: The spy drone is a supremely effective weapon, boasting %d%% more movement speed, blast radius, and EMP damage."
     
     mpAugValue=100.000000
     mpEnergyDrain=20.000000
     reconstructTime=30.000000
     lastDroneTime=-30.000000
     EnergyRate=150.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconDrone'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconDrone_Small'
     AugmentationName="Spy Drone"
     Description="Advanced nanofactories can assemble a spy drone upon demand which can then be remotely controlled by the agent until released or destroyed, at which a point a new drone will be assembled.|n|nTECH ONE: Drone speed is standard. It possesses an EMP blast of 50 damage out to a 5 ft radius.|n|nTECH TWO: Drone speed is increased by 100%, as is blast radius and EMP damage.|n|nTECH THREE: Drone speed is increased by 250%, as is blast radius and EMP damage.|n|nTECH FOUR: The spy drone is a supremely effective weapon, boasting 400% more movement speed, blast radius, and EMP damage."
     MPInfo="Activation creates a remote-controlled spy drone.  Deactivation disables the drone.  Firing while active detonates the drone in a massive EMP explosion.  Energy Drain: Medium"
     LevelValues(0)=20.000000
     LevelValues(1)=30.000000
     LevelValues(2)=40.000000
     LevelValues(3)=50.000000
     ReconstructionPrefix="Reconstruction will be complete in"
     ReconstructionSeconds="seconds"
     ReconstructionSecond="second"
     LowEnergy="Not enough energy to construct drone"
     MPConflictSlot=7
}
