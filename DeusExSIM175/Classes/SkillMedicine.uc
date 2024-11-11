//=============================================================================
// SkillMedicine.
//=============================================================================
class SkillMedicine extends Skill;

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

//MADDERS, 5/17/22: We wanted to be 900/1800/3000, but now crafting is a thing, soooo...
//Now we're (effectively, with crafting on) 1275/2700/4500
simulated function int GetCost()
{
	local int Ret;
	local VMDBufferPlayer VMP;
	
	Ret = Super.GetCost();
	VMP = VMDBufferPlayer(Player);
	
	if (VMP.bCraftingSystemEnabled)
	{
		switch(CurrentLevel)
		{
			case 0:
				Ret += 125;
				//Ret += 375;
			break;
			case 1:
				Ret += 300;
				//Ret += 900;
			break;
			case 2:
				Ret += 500;
				//Ret += 1500;
			break;
		}
	}
	
	return Ret;
}

defaultproperties
{
     mpCost1=1000
     mpCost2=1000
     mpCost3=1000
     mpLevel0=1.000000
     mpLevel1=1.000000
     mpLevel2=2.000000
     mpLevel3=3.000000
     SkillName="Medicine"
     Description="Practical knowledge of human physiology can be applied by an agent in the field allowing more efficient use of medkits.|n|nUNTRAINED: An agent can use medkits at 30 health per use.|n|nTRAINED: An agent can heal 50 health per medkit used.|n|nADVANCED: An agent can heal 70 damage per medkit used.|n|nMASTER: An agent can perform a heart bypass with household materials, healing for an impressive 90 damage per medkit used."
     SkillIcon=Texture'DeusExUI.UserInterface.SkillIconMedicine'
     cost(0)=900
     cost(1)=1800
     cost(2)=3000
     LevelValues(0)=1.000000
     LevelValues(1)=1.670000 //Used to be 2.0, then 1.5
     LevelValues(2)=2.340000 //Used to be 2.5, then 2.25
     LevelValues(3)=3.000000
}
