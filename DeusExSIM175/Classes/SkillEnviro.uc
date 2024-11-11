//=============================================================================
// SkillEnviro.
//=============================================================================
class SkillEnviro extends Skill;

var int mpCost1;
var int mpCost2;
var int mpCost3;
var float mpLevel0;
var float mpLevel1;
var float mpLevel2;
var float mpLevel3;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		cost[0] = mpCost1;
		cost[1] = mpCost2;
		cost[2] = mpCost3;
		LevelValues[0] = mpLevel0;
		LevelValues[1] = mpLevel1;
		LevelValues[2] = mpLevel2;
		LevelValues[3] = mpLevel3;
	}
}

defaultproperties
{
     mpCost1=1000
     mpCost2=1000
     mpCost3=1000
     mpLevel0=1.000000
     mpLevel1=0.750000
     mpLevel2=0.500000
     mpLevel3=0.250000
     //SkillName="Environmental Training"
     SkillName="Tactical Gear"
     Description="Experience with using goggles, hazmat suits, ballistic armor, thermoptic camo, and rebreathers in a number of dangerous situations.|n|nUNTRAINED: An agent can use goggles, armor, suits, and camo.|n|nTRAINED: Goggles, armor, suits, and camo can be used for 33% more duration and 14% more protection.|n|nADVANCED: Goggles, armor, suits, and camo can be used for 100% more duration and 33% more protection.|n|nMASTER: An agent wears tactical gear like a second skin, with 300% more duration and 60% more protection."
     SkillIcon=Texture'DeusExUI.UserInterface.SkillIconEnviro'
     bAutomatic=True
     //Used to be 675/1350/2250... Then 725/1350/2250.
     cost(0)=900
     cost(1)=1800
     cost(2)=3000
     LevelValues(0)=1.000000
     LevelValues(1)=0.750000
     LevelValues(2)=0.500000
     LevelValues(3)=0.250000
}
