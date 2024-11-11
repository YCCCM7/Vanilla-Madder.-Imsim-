//=============================================================================
// SkillWeaponPistol.
//=============================================================================
class SkillWeaponPistol extends Skill;

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

	//if ( Level.NetMode == NM_Standalone )
	//	CurrentLevel = 0;

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
     SkillName="Weapons: Pistol"
     Description="The use of hand-held weapons, including the standard 10mm pistol, its stealth variant, and the mini-crossbow.|n|nUNTRAINED: An agent can use pistols.|n|nTRAINED: Accuracy and reload speed increase by 10%, while damage is increased by 20%.|n|nADVANCED: Accuracy and reload speed increase by 25%, while damage is increased by 50%.|n|nMASTER: An agent is lethally precise with pistols, with a 50% boost to accuracy and reload speed, paired with a 100% boost in damage."
     SkillIcon=Texture'DeusExUI.UserInterface.SkillIconWeaponPistol'
     cost(0)=1475 //Used to be 1575, then 1425.
     cost(1)=3150
     cost(2)=5250
     LevelValues(1)=-0.100000
     LevelValues(2)=-0.250000
     LevelValues(3)=-0.500000
}
