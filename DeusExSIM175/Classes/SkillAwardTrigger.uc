//=============================================================================
// SkillAwardTrigger.
//=============================================================================
class SkillAwardTrigger extends Trigger;

// Gives the player skill points when touched or triggered
// Set bCollideActors to False to make it triggered

var() int skillPointsAdded;
var() localized String awardMessage;

function Trigger(Actor Other, Pawn Instigator)
{
	local DeusExPlayer player;
	
	Super.Trigger(Other, Instigator);
	
	player = DeusExPlayer(Instigator);
	
	if (player != None)
	{
		player.SkillPointsAdd(skillPointsAdded);
		player.ClientMessage(awardMessage);
		
		//== Y|y: we need to ACTUALLY pay attention to the bTriggerOnceOnly variable
		if(bTriggerOnceOnly)
		{
			Tag = '';
			Destroy();
		}
	}
}

function Touch(Actor Other)
{
	local DeusExPlayer player;
	
	Super.Touch(Other);
	
	if (IsRelevant(Other))
	{
		player = DeusExPlayer(Other);
		
		// Transcended - Assume player, for things like basketballs
		if (player == None)
			player = DeusExPlayer(GetPlayerPawn());

		if (player != None)
		{
			player.SkillPointsAdd(skillPointsAdded);
			if ((Message != "") && (awardMessage == Default.AwardMessage)) // Transcended - Play message if set and awardMessage isn't
			{
				player.ClientMessage(Message);
			}
			player.ClientMessage(awardMessage);
			
			//== Y|y: we need to ACTUALLY pay attention to the bTriggerOnceOnly variable
			if(bTriggerOnceOnly)
				Tag = '';
		}
	}
}

defaultproperties
{
     skillPointsAdded=10
     awardMessage="DEFAULT SKILL AWARD MESSAGE - REPORT THIS AS A BUG"
     bTriggerOnceOnly=True
}
