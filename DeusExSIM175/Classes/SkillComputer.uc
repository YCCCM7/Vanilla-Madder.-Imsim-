//=============================================================================
// SkillComputer.
//=============================================================================
class SkillComputer extends Skill;

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
     mpLevel0=0.400000
     mpLevel1=0.400000
     mpLevel2=1.000000
     mpLevel3=5.000000
     SkillName="Software"
     Description="The covert manipulation of computers and security consoles. Actions taken during hacking will increase the risk of being detected.|n|nUNTRAINED: An agent can use terminals to read bulletins and news.|n|nTRAINED: An agent can hack ATMs, computers, and security consoles, but for a very short duration and with limited hacking types.|n|nADVANCED: An agent achieves a moderate increase hack duration, and can learn more advanced hacking types.|n|nMASTER: An agent is an elite hacker that few systems can withstand, boasting a high hack duration and a wide array of hacking types."
     SkillIcon=Texture'DeusExUI.UserInterface.SkillIconComputer'
     //Used to be 1125, 2250, and 3750 respectively. We need more computers for the same utility, however.
     cost(0)=900
     cost(1)=1800
     cost(2)=3000
     LevelValues(0)=1.000000
     LevelValues(1)=1.000000
     LevelValues(2)=2.000000
     LevelValues(3)=4.000000
}
