//=============================================================================
// AugSpeed.
//=============================================================================
class AugSpeed extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

state Active
{
Begin:
	//Player.GroundSpeed *= LevelValues[CurrentLevel];
	//Player.JumpZ *= LevelValues[CurrentLevel];
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Human(Player) != None )
			Human(Player).UpdateAnimRate( LevelValues[CurrentLevel] );
	}
}

function Deactivate()
{
	Super.Deactivate();

	/*if (( Level.NetMode != NM_Standalone ) && Player.IsA('Human') )
		Player.GroundSpeed = Human(Player).Default.mpGroundSpeed;
	else
		Player.GroundSpeed = Player.Default.GroundSpeed;
	
	Player.JumpZ = Player.Default.JumpZ;*/
	
	if ( Level.NetMode != NM_Standalone )
	{
		if ( Human(Player) != None )
			Human(Player).UpdateAnimRate( -1.0 );
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
      		AugmentationLocation = LOC_Torso;
	}
}

function float VMDConfigureSpeedMult(bool bWater)
{
 	if (!bWater) return LevelValues[CurrentLevel];
 	return 1.0;
}
function float VMDConfigureJumpMult()
{
 	return LevelValues[CurrentLevel];
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 1.0) * 100) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the speed at which an agent can run and climb, the height they can jump, and reducing the damage they receive from falls."
     AdvancedDescLevels(0)="TECH ONE: Speed and jumping are increased by %d%%, while falling damage is reduced."
     AdvancedDescLevels(1)="TECH TWO: Speed and jumping are increased by %d%%, while falling damage is further reduced."
     AdvancedDescLevels(2)="TECH THREE: Speed and jumping are increased by %d%%, while falling damage is substantially reduced."
     AdvancedDescLevels(3)="TECH FOUR: An agent can run like the wind and leap from the tallest building, with %d%% enhanced movement speed and jump height."
     
     mpAugValue=2.000000
     mpEnergyDrain=180.000000
     EnergyRate=80.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconSpeedJump'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconSpeedJump_Small'
     AugmentationName="Speed Enhancement"
     Description="Ionic polymeric gel myofibrils are woven into the leg muscles, increasing the speed at which an agent can run and climb, the height they can jump, and reducing the damage they receive from falls.|n|nTECH ONE: Speed and jumping are increased by 20%, while falling damage is reduced.|n|nTECH TWO: Speed and jumping are increased by 40%, while falling damage is further reduced.|n|nTECH THREE: Speed and jumping are increased by 60%, while falling damage is substantially reduced.|n|nTECH FOUR: An agent can run like the wind and leap from the tallest building, with 80% enhanced movement speed and jump height."
     MPInfo="When active, you move twice as fast and jump twice as high.  Energy Drain: Very High"
     LevelValues(0)=1.300000
     LevelValues(1)=1.450000
     LevelValues(2)=1.600000
     LevelValues(3)=1.800000
     AugmentationLocation=LOC_Leg
     MPConflictSlot=5
}
