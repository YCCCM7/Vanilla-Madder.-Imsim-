//=============================================================================
// ConversationTrigger.
//=============================================================================
class ConversationTrigger extends Trigger;

//
// Triggers a conversation when touched
//
// * conversationTag is matched to the conversation file which has all of
//   the conversation events in it.
//

var() name conversationTag;
var() string BindName;
var() name checkFlag;
var() bool bCheckFalse;

singular function Trigger(Actor Other, Pawn Instigator)
{
	local DeusExPlayer player;
	local bool bSuccess, bFemaleTweaked;
	local Actor A, conOwner;
	local VMDBufferPlayer VMP;	
	local name UseTag, OldTag;
	
	player = DeusExPlayer(Instigator);
	VMP = VMDBufferPlayer(Player);
	bSuccess = True;
	
	// only works for DeusExPlayers
	if (player == None)
		return;

	if (checkFlag != '')
	{
		if (!player.flagBase.GetBool(checkFlag))
			bSuccess = bCheckFalse;
		else
			bSuccess = !bCheckFalse;
	}

	if ((BindName != "") && (conversationTag != ''))
	{
		UseTag = ConversationTag;
		if ((VMP != None) && (VMP.bAssignedFemale) && (VMP.bAllowFemaleVoice) && (!VMP.bDisableFemaleVoice))
		{
			bFemaleTweaked = true;
			OldTag = UseTag;
			UseTag = Player.FlagBase.StringToName("FemJC"$string(UseTag));
		}
		
		foreach AllActors(class'Actor', A)
		{
			if (A.BindName == BindName)
			{
				conOwner = A;
				break;
			}
		}
		
		if (bSuccess)
		{
			if (player.StartConversationByName(UseTag, conOwner))
			{
				Super.Trigger(Other, Instigator);
			}
			else if (bFemaleTweaked)
			{
				if (player.StartConversationByName(OldTag, conOwner))
				{
					Super.Trigger(Other, Instigator);
				}
			}
		}
	}
}

singular function Touch(Actor Other)
{
	local DeusExPlayer player;
	local bool bSuccess, bFemaleTweaked;
	local Actor A, conOwner;
	
	local name UseTag, OldTag;

	player = DeusExPlayer(Other);
	bSuccess = True;

	// only works for DeusExPlayers
	if (player == None)
		return;

	if (checkFlag != '')
	{
		if (!player.flagBase.GetBool(checkFlag))
			bSuccess = bCheckFalse;
		else
			bSuccess = !bCheckFalse;
	}

	if ((BindName != "") && (conversationTag != ''))
	{
		UseTag = ConversationTag;
		if ((Player.FlagBase != None) && (Player.FlagBase.GetBool('LDDPJCIsFemale')))
		{
			bFemaleTweaked = true;
			OldTag = UseTag;
			UseTag = Player.FlagBase.StringToName("FemJC"$string(UseTag));
		}
		
		foreach AllActors(class'Actor', A)
		{
			if (A.BindName == BindName)
			{
				conOwner = A;
				break;
			}
		}	
		
		if (bSuccess)
		{
			if (player.StartConversationByName(UseTag, conOwner))
			{
				Super.Touch(Other);
			}
			else if (bFemaleTweaked)
			{
				if (player.StartConversationByName(OldTag, conOwner))
				{
					Super.Touch(Other);
				}
			}
		}
	}
}

defaultproperties
{
     bTriggerOnceOnly=True
     CollisionRadius=96.000000
}
