//=============================================================================
// MissionScript.
//=============================================================================
class MissionScript extends Info
	transient
	abstract;

//
// State machine for each mission
// All flags set by this mission controller script should be
// prefixed with MS_ for consistency
//

var float checkTime;
var DeusExPlayer Player;
var FlagBase flags;
var string localURL;
var DeusExLevelInfo dxInfo;

// ----------------------------------------------------------------------
// PostPostBeginPlay()
//
// Set the timer
// ----------------------------------------------------------------------

function PostPostBeginPlay()
{
	// start the script
	SetTimer(checkTime, True);
}

// ----------------------------------------------------------------------
// InitStateMachine()
//
// Get the player's flag base, get the map name, and set the player
// ----------------------------------------------------------------------

function InitStateMachine()
{
	local DeusExLevelInfo info;

	Player = DeusExPlayer(GetPlayerPawn());

	foreach AllActors(class'DeusExLevelInfo', info)
		dxInfo = info;

	if (Player != None)
	{
		flags = Player.FlagBase;
		
		// Get the mission number by extracting it from the
		// DeusExLevelInfo and then delete any expired flags.
		//
		// Also set the default mission expiration so flags
		// expire in the next mission unless explicitly set
		// differently when the flag is created.
		
		if (flags != None)
		{
			// Don't delete expired flags if we just loaded
			// a savegame
			if (flags.GetBool('PlayerTraveling'))
				flags.DeleteExpiredFlags(dxInfo.MissionNumber);

			flags.SetDefaultExpiration(dxInfo.MissionNumber + 1);

			localURL = Caps(dxInfo.mapName);

			log("**** InitStateMachine() -"@player@"started mission state machine for"@localURL);
		}
		else
		{
			log("**** InitStateMachine() - flagBase not set - mission state machine NOT initialized!");
		}
	}
	else
	{
		log("**** InitStateMachine() - player not set - mission state machine NOT initialized!");
	}
}

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local name flagName;
	local ScriptedPawn P;
	local VMDBufferPlayer VMP;
	local int i;
	local DeusExWeapon ourWeapon;
	local DeusExRootWindow 	root;
	
	flags.DeleteFlag('PlayerTraveling', FLAG_Bool);
	
	// Check to see which NPCs should be dead from prevous missions
	foreach AllActors(class'ScriptedPawn', P)
	{
		if (P.bImportant)
		{
			flagName = Player.rootWindow.StringToName(P.BindName$"_Dead");
			if (flags.GetBool(flagName))
			{
				P.Destroy();
			}
		}
	}
	
	// Transcended - Ported, fixes crash
	if ((dxInfo != None) && (dxInfo.MissionNumber >= 0))
	{
		// print the mission startup text only once per map
		flagName = Player.rootWindow.StringToName("M"$Caps(dxInfo.mapName)$"_StartupText");
		if (!flags.GetBool(flagName) && (dxInfo.startupMessage[0] != ""))
		{
			for (i=0; i<ArrayCount(dxInfo.startupMessage); i++)
				DeusExRootWindow(Player.rootWindow).hud.startDisplay.AddMessage(dxInfo.startupMessage[i]);
			DeusExRootWindow(Player.rootWindow).hud.startDisplay.StartMessage();
			flags.SetBool(flagName, True);
		}

		flagName = Player.rootWindow.StringToName("M"$dxInfo.MissionNumber$"MissionStart");
		if (!flags.GetBool(flagName))
		{
			// Remove completed Primary goals and all Secondary goals
			Player.ResetGoals();

			// Remove any Conversation History.
			Player.ResetConversationHistory();

			// Set this flag so we only get in here once per mission.
			flags.SetBool(flagName, True);
		}
	}
	
	// print the mission startup text only once per map
	flagName = Player.rootWindow.StringToName("M"$Caps(dxInfo.mapName)$"_StartupText");
	if (!flags.GetBool(flagName) && (dxInfo.startupMessage[0] != ""))
	{
		for (i=0; i<ArrayCount(dxInfo.startupMessage); i++)
			DeusExRootWindow(Player.rootWindow).hud.startDisplay.AddMessage(dxInfo.startupMessage[i]);
		DeusExRootWindow(Player.rootWindow).hud.startDisplay.StartMessage();
		flags.SetBool(flagName, True);
	}
	
	if (DXInfo.MissionNumber >= 0)
	{
		flagName = Player.rootWindow.StringToName("M"$dxInfo.MissionNumber$"MissionStart");
		if (!flags.GetBool(flagName))
		{
			// Remove completed Primary goals and all Secondary goals
			Player.ResetGoals();
			
			// Remove any Conversation History.
			Player.ResetConversationHistory();
			
			// Set this flag so we only get in here once per mission.
			flags.SetBool(flagName, True);
		}
	}
	
	VMP = VMDBufferPlayer(Player);
	if (VMP != None)
	{
		VMP.VMDRequestAutoSave();
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	// turn off the timer
	SetTimer(0, False);

	// zero the flags so FirstFrame() gets executed at load
	flags = None;
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	// make sure our flags are initialized correctly
	if (flags == None)
	{
		InitStateMachine();

		// Don't want to do this if the user just loaded a savegame
		if ((player != None) && (flags.GetBool('PlayerTraveling')))
			FirstFrame();
	}
}

// ----------------------------------------------------------------------
// GetPatrolPoint()
// Y|y: Fixed to actually do something
// ----------------------------------------------------------------------

function PatrolPoint GetPatrolPoint(Name patrolTag, optional bool bRandom)
{
	local PatrolPoint aPoint;
	
	foreach AllActors(class'PatrolPoint', aPoint, patrolTag)
	{			
		if (bRandom)
		{
			if(FRand() < 0.5)
				break;
		}
		else
			break;
	}
	
	return aPoint;
}

// ----------------------------------------------------------------------
// GetSpawnPoint()
// Y|y: Fixed to actually do something
// ----------------------------------------------------------------------

function SpawnPoint GetSpawnPoint(Name spawnTag, optional bool bRandom)
{
	local SpawnPoint aPoint;

	foreach AllActors(class'SpawnPoint', aPoint, spawnTag)
	{
		if (bRandom)
		{
			if(FRand() < 0.5)
				break;
		}
		else
			break;
	}

	return aPoint;
}

defaultproperties
{
     checkTime=1.000000
     localURL="NOTHING"
}
