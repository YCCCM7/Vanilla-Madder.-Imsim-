//=============================================================================
// SkillWeaponHeavy.
//=============================================================================
class SkillWeaponHeavy extends Skill;

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
     mpCost1=2000
     mpCost2=2000
     mpCost3=2000
     mpLevel0=-0.100000
     mpLevel1=-0.250000
     mpLevel2=-0.370000
     mpLevel3=-0.500000
     SkillName="Weapons: Heavy"
     Description="The use of heavy weaponry, including flamethrowers, LAWs, and the experimental plasma and GEP guns.|n|nUNTRAINED: An agent can use heavy weaponry, but their accuracy is low and movement is difficult.|n|nTRAINED: Accuracy and reload speed are increased by 10%, damage by 20%, and movement is somewhat faster.|n|nADVANCED: Accuracy and reload speed are increased by 25%, damage by 50%, and movement speed is even faster.|n|nMASTER: An agent is a walking tank when equipped with heavy weaponry, boasting 50% more accuracy and reload speed, paired with 100% more damage dealt and good movement speed."
     SkillIcon=Texture'DeusExUI.UserInterface.SkillIconWeaponHeavy'
     cost(0)=1275 //Used to be 1350, then 1225.
     cost(1)=2700
     cost(2)=4500
     LevelValues(1)=-0.100000
     LevelValues(2)=-0.250000
     LevelValues(3)=-0.500000
}
