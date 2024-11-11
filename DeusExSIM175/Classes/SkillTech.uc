//=============================================================================
// SkillTech.
//=============================================================================
class SkillTech extends Skill;

var int mpCost1;
var int mpCost2;
var int mpCost3;
var float mpLevel0;
var float mpLevel1;
var float mpLevel2;
var float mpLevel3;

var localized String MultitoolString;

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
		skillName = MultitoolString;
	}
}

//BARF: Historical Log:
//Used to be 1800, then 1350, then 1225, then 1275 for base level.
//Before crafting set it to.
//---------------------------
//MADDERS, 5/17/22: We wanted to be 1275/2700/4500, but now crafting is a thing, soooo...
//Now we're (effectively, with crafting on) 1475/3150/5250
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
				Ret += 100;
				//Ret += 200;
			break;
			case 1:
				Ret += 225;
				//Ret += 450;
			break;
			case 2:
				Ret += 375;
				//Ret += 750;
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
     mpLevel0=0.100000
     mpLevel1=0.400000
     mpLevel2=0.550000
     mpLevel3=0.950000
     MultitoolString="Multitooling"
     SkillName="Hardware"
     Description="By studying electronics and its practical application, agents can more efficiently bypass a number of security systems using multitools.|n|nUNTRAINED: An agent can bypass security systems at 10% per tool.|n|nTRAINED: The efficiency with which an agent bypasses security increases to 25% per tool.|n|nADVANCED: The efficiency with which an agent bypasses security increases to 40% per tool.|n|nMASTER: An agent encounters almost no security systems of any challenge, at 75% per tool"
     SkillIcon=Texture'DeusExUI.UserInterface.SkillIconTech'
     cost(0)=1275
     cost(1)=2700
     cost(2)=4500
     LevelValues(0)=0.100000
     LevelValues(1)=0.250000
     LevelValues(2)=0.400000
     LevelValues(3)=0.750000
     itemNeeded=Class'DeusEx.Multitool'
}
