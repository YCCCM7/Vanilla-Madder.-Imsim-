//=============================================================================
// Skill.
//=============================================================================
class Skill extends Actor
	intrinsic;

var() localized string		SkillName;
var() localized string		Description;
var   Texture               SkillIcon;
var() bool					bAutomatic;
var() bool					bConversationBased;
var() int					Cost[3];
var() float					LevelValues[4];
var travel int				CurrentLevel;		// 0 is unskilled, 3 is master
var() class<SkilledTool>	itemNeeded;

// which player am I attached to?
var DeusExPlayer Player;

// Pointer to next skill
var travel Skill next;		

// Printable skill level strings
var Localized string skillLevelStrings[4];
var localized string SkillAtMaximum;

// ----------------------------------------------------------------------
// network replication
// ----------------------------------------------------------------------

replication
{
    	//variables server to client
    	reliable if ((Role == ROLE_Authority) && (bNetOwner))
        	CurrentLevel, next;

    	//functions client to server
    	reliable if (Role < ROLE_Authority)
        	IncLevel, Use, DecLevel;

}

// ----------------------------------------------------------------------
// PreBeginPlay()
// ----------------------------------------------------------------------
simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( (Level.NetMode != NM_StandAlone ) && (DeusExGameInfo(Level.Game) != None))
	{
		CurrentLevel = DeusExGameInfo(Level.Game).GetSkillStartLevel();
	}
}

// ----------------------------------------------------------------------
// Use()
// ----------------------------------------------------------------------

function bool Use()
{
	local bool bDoIt;

	bDoIt = True;

	if (itemNeeded != None)
	{
		bDoIt = False;

		if ((Player.inHand != None) && (Player.inHand.Class == itemNeeded))
		{
			SkilledTool(Player.inHand).PlayUseAnim();

			// alert NPCs that I'm messing with stuff
			if (Player.FrobTarget != None)
				if (Player.FrobTarget.bOwned)
					Player.FrobTarget.AISendEvent('MegaFutz', EAITYPE_Visual);

			bDoIt = True;
		}
	}

	return bDoIt;
}

// ----------------------------------------------------------------------
// accessor functions
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------
// GetCost()
// ----------------------------------------------------------------------

simulated function int GetCost()
{
	local int Ret;
	local bool bSpecialized;
	local VMDBufferPlayer VMP;
	
	if (CurrentLevel > ArrayCount(Cost)) return MaxInt;
	
	Ret = Cost[CurrentLevel];
	VMP = VMDBufferPlayer(Player);
	if ((VMP != None) && (VMP.SkillAugmentManager != None))
	{
		if (VMP.SkillAugmentManager.IsSpecializedInSkill(Class))
		{
			switch(CurrentLevel)
			{
				case 0:
					Ret -= 100;
				break;
				case 1:
					Ret -= 200;
				break;
				case 2:
					Ret -= 300;
				break;
			}
		}
		else
		{
			switch(CurrentLevel)
			{
				case 0:
					Ret += 150;
				break;
				case 1:
					Ret += 75;
				break;
				case 2:
					Ret += 0;
				break;
			}
		}
	}
	
	return Ret;
}

// ----------------------------------------------------------------------
// GetCurrentLevel()
// ----------------------------------------------------------------------

simulated function int GetCurrentLevel()
{
	return CurrentLevel;
}

// ----------------------------------------------------------------------
// GetCurrentLevelString()
//
// Returns a string representation of the current skill level.
// ----------------------------------------------------------------------

simulated function String GetCurrentLevelString()
{
	return skillLevelStrings[currentLevel];
}

// ----------------------------------------------------------------------
// IncLevel()
// ----------------------------------------------------------------------

function bool IncLevel(optional DeusExPlayer UsePlayer)
{
	local DeusExPlayer LocalPlayer;
	local VMDBufferPlayer VMP;

	// First make sure we're not maxed out
	if (CurrentLevel < 3)
	{		
		// If "usePlayer" is passed in, then we want to use this 
		// as the basis for making our calculations, temporarily
		// overriding whatever this skill's player is set to.
		
		if (UsePlayer != None)
		{
			LocalPlayer = UsePlayer;
		}
		else
		{
			LocalPlayer = Player;
		}
		
		// Now, if a player is defined, then check to see if there enough
		// skill points available.  If no player is defined, just do it.
		VMP = VMDBufferPlayer(LocalPlayer);
		if (LocalPlayer != None) 
		{
			// decrement the cost and increment the current skill level
			if (VMP != None)
			{
				if (VMP.SkillPointsTotal - VMP.SkillPointsSpent >= GetCost())
				{
					VMP.SkillPointsSpent += GetCost();
					CurrentLevel++;
					
					VMP.AddSkillAugmentPoints(Class, CurrentLevel);
					LocalPlayer.SwimDuration = class'VMDStaticFunctions'.Static.GetPlayerSwimDuration(LocalPlayer);
					return True;
				}
			}
			else
			{
				if (LocalPlayer.SkillPointsAvail >= GetCost())
				{
					LocalPlayer.SkillPointsAvail -= GetCost();
					CurrentLevel++;
					LocalPlayer.SwimDuration = class'VMDStaticFunctions'.Static.GetPlayerSwimDuration(LocalPlayer);
					return True;
				}
			}
		}
		else
		{
			CurrentLevel++;
			return True;
		}
	}

	return False;
}

// ----------------------------------------------------------------------
// DecLevel()
// 
// Decrements a skill level, making sure the skill isn't already at 
// the lowest skill level.  Cost of the skill is optionally added back 
// to the player's SkilPointsAvail variable. 
// ----------------------------------------------------------------------

function bool DecLevel(optional bool bGiveUserPoints, optional DeusExPlayer UsePlayer)
{
	local DeusExPlayer LocalPlayer;
	local VMDBufferPlayer VMP;

	// First make sure we're not already at the bottom
	if (CurrentLevel > 0)
	{
		// Decrement the skill level 
		CurrentLevel--;

		// If "usePlayer" is passed in, then we want to use this 
		// as the basis for making our calculations, temporarily
		// overriding whatever this skill's player is set to.

		if (UsePlayer != None)
		{
			LocalPlayer = UsePlayer;
		}
		else
		{
			LocalPlayer = Player;
		}
		
		// If a player exists and the 'bGiveUserPoints' flag is set, 
		// then add the points to the player
		VMP = VMDBufferPlayer(LocalPlayer);
		if (( bGiveUserPoints ) && (LocalPlayer != None))
		{
			if (VMP != None)
			{
				VMP.SkillPointsSpent -= GetCost();
				
				//MADDERS: Upgrading skills adds augment points equivalent to the new level. 1 > 2 > 3
				VMP.RemoveSkillAugmentPoints(Class, CurrentLevel);
			}
			else
			{	
				LocalPlayer.SkillPointsAvail += GetCost();
			}
		}
		
		return True;
	}

	return False;
}

// ----------------------------------------------------------------------
// CanAffordToUpgrade()
//
// Given the points passed in, checks to see if the skill can be 
// upgraded to the next level.  Will always return False if the 
// skill is already at the maximum level.
// ----------------------------------------------------------------------

simulated function bool CanAffordToUpgrade( int skillPointsAvailable )
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Player);
	
	if (CurrentLevel == 3)
	{
		return False;
	}
	else if ((VMP != None) && (GetCost() > VMP.SkillPointsTotal-VMP.SkillPointsSpent))
	{
		return False;
	}
	else if ((VMP == None) && (GetCost() > skillPointsAvailable))
	{
		return False;
	}
	else
	{
		return True;
	}
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
	{
		return False;
	}
	
	winInfo.Clear();
	winInfo.SetTitle(SkillName);
	winInfo.SetText(Description);
	
	return True;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     skillLevelStrings(0)="UNTRAINED"
     skillLevelStrings(1)="TRAINED"
     skillLevelStrings(2)="ADVANCED"
     skillLevelStrings(3)="MASTER"
     SkillAtMaximum="Skill at Maximum Level"
     bHidden=True
     bTravel=True
     NetUpdateFrequency=5.000000
}
