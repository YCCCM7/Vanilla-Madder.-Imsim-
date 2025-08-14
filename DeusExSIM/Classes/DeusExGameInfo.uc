//=============================================================================
// DeusExGameInfo.
//=============================================================================
class DeusExGameInfo expands GameInfo
	config;

var Float PauseStartTime;
var Float PauseEndTime;

// ----------------------------------------------------------------------
// Login()
// ----------------------------------------------------------------------

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local DeusExPlayer player;
	local NavigationPoint StartSpot;
	local byte InTeam;
	local DumpLocation dump;
	
	//DEUS_EX AMSD In non multiplayer games, force JCDenton.
	if (!ApproveClass(SpawnClass))
	{
		SpawnClass = None;
		if (SpawnClass == None)
		{
			/*if (IsBurdenLevel())
			{
				SpawnClass = class<PlayerPawn>(DynamicLoadObject("Burden.BurdenPeterKent", class'Class', true));
			}
			else if (IsCassandraLevel())
			{
				SpawnClass = class<PlayerPawn>(DynamicLoadObject("TCPCore.TCPPlayerCharlotte", class'Class', true));
			}
			
			if (SpawnClass == None)
			{*/
				SpawnClass = class'JCDentonMale';
			//}
		}
	}
	
	player = DeusExPlayer(Super.Login(Portal, Options, Error, SpawnClass));
	
	// If we're traveling across a map on the same mission, 
	// nuke the player's crap and 
	
	if ((player != None) && (!HasOption(Options, "Loadgame")))
	{
		player.ResetPlayerToDefaults();
		
		dump = player.CreateDumpLocationObject();
		
		if ((dump != None) && (dump.HasLocationBeenSaved()))
		{
			dump.LoadLocation();
			
			player.Pause();
			player.SetLocation(dump.currentDumpLocation.Location);
			player.SetRotation(dump.currentDumpLocation.ViewRotation);
			player.ViewRotation = dump.currentDumpLocation.ViewRotation;
			player.ClientSetRotation(dump.currentDumpLocation.ViewRotation);
			
			CriticalDelete(dump);
		}
		else
		{
			InTeam    = GetIntOption( Options, "Team", 0 ); // Multiplayer now, defaults to Team_Unatco=0
         		if (Level.NetMode == NM_Standalone)
			{
            			StartSpot = FindPlayerStart( None, InTeam, Portal );
			}
         		else
			{
            			StartSpot = FindPlayerStart( Player, InTeam, Portal );
			}
			player.SetLocation(StartSpot.Location);
			player.SetRotation(StartSpot.Rotation);
			player.ViewRotation = StartSpot.Rotation;
			player.ClientSetRotation(player.Rotation);
		}
	}
	return player;
}

event PostLogin(playerpawn NewPlayer)
{
	local class<DeusExGameInfo> LoadInfo;
	
	Super.PostLogin(NewPlayer);
	
	//SetupMusic(DeusExPlayer(NewPlayer));
	/*LoadInfo = class<DeusExGameInfo>(DynamicLoadObject("Revision.RevGameInfo", class'Class', true));
	if (LoadInfo != None)
	{
		LoadInfo.Static.SetupMusic(DeusExPlayer(NewPlayer));
	}*/
	
	if (DeusExPlayer(NewPlayer) != None)
	{
		ApplyGamemode(DeusExPlayer(NewPlayer));
	}
}

function ApplyGamemode(DeusExPlayer player)
{
	local Human 					localPlayer;
	local Light 					light;
	local BarrelFire 				BarrelFire;

	localPlayer = Human(player);

	if (localPlayer != None)
	{
		if (localPlayer.bEpilepsyReduction) // Disable all flickering lights.
		{
			foreach AllActors(class'Light', light)
			{
				if (light.LightType == LT_Flicker || light.LightType == LT_Strobe)
				{
					light.LightType = LT_Steady;
					light.bLightChanged = True;
				}
			}
			
			foreach AllActors(class'BarrelFire', BarrelFire) // These too, just incase.
			{
				BarrelFire.LightType = LT_Steady;
			}
		}
	}
}

// ----------------------------------------------------------------------
// ApproveClass()
// Is this class allowed for this gametype?  Override if you want to be 
// other than JCDentonMale.  If it returns false, will force JCDenton spawn.
// ----------------------------------------------------------------------

function bool ApproveClass( class<playerpawn> SpawnClass)
{
	return false;
}

// ----------------------------------------------------------------------
// DiscardInventory()
// ----------------------------------------------------------------------

function DiscardInventory( Pawn Other )
{
	// do nothing
}

// ----------------------------------------------------------------------
// ScoreKill()
// ----------------------------------------------------------------------

function ScoreKill(pawn Killer, pawn Other)
{
	// do nothing	
}

// ----------------------------------------------------------------------
// ClientPlayerPossessed()
// ----------------------------------------------------------------------
function ClientPlayerPossessed(PlayerPawn CheckPlayer)
{
	CheckPlayerWindow(CheckPlayer);
	CheckPlayerConsole(CheckPlayer);
}

// ----------------------------------------------------------------------
// CheckPlayerWindow()
// ----------------------------------------------------------------------
function CheckPlayerWindow(PlayerPawn CheckPlayer)
{
	// do nothing.
}

// ----------------------------------------------------------------------
// CheckPlayerConsole()
// ----------------------------------------------------------------------
function CheckPlayerConsole(PlayerPawn CheckPlayer)
{
	// do nothing.
}

// ----------------------------------------------------------------------
// FailRootWindowCheck()
// ----------------------------------------------------------------------
function FailRootWindowCheck(PlayerPawn FailPlayer)
{
	// do nothing
}

// ----------------------------------------------------------------------
// FailConsoleCheck()
// ----------------------------------------------------------------------
function FailConsoleCheck(PlayerPawn FailPlayer)
{
	// do nothing
}

function bool SetPause(BOOL bPause, PlayerPawn P)
{
	if(bPause && Level.Pauser == "")
		PauseStartTime = Level.TimeSeconds;
	if(!bPause && Level.Pauser != "")
		PauseEndTime = Level.TimeSeconds;

	return Super.SetPause(bPause, P);
}

// ---------------------------------------------------------------------
// ArePlayersAllied()
// Should be overwrote in subclasses (RevTeamDMGame)
// ---------------------------------------------------------------------

simulated function bool ArePlayersAllied(DeusExPlayer FirstPlayer, DeusExPlayer SecondPlayer)
{
   if ((FirstPlayer == None) || (SecondPlayer == None))
      return false;
   return (FirstPlayer.PlayerReplicationInfo.team == SecondPlayer.PlayerReplicationInfo.team);
}

simulated function bool bIsTeamGame()
{
	if (TeamDMGame(Self) != None)
		return true;
}

simulated function bool bIsMPGame()
{
	if (DeusExMPGame(Self) != None)
		return true;
}

simulated function bool AutoInstall()
{
}

simulated function bool SpawnEffects()
{
	return True;
}

simulated function float GetFriendlyFireMult()
{
	return 1;
}

simulated function int GetSkillStartLevel()
{
	return 1;
}

simulated function TrackWeapon(DeusExWeapon WeaponUsed, float RawDamage)
{
}

simulated function ShowDMScoreboard( DeusExPlayer thisPlayer, GC gc, float screenWidth, float screenHeight )
{
}

simulated function ShowTeamDMScoreboard( DeusExPlayer thisPlayer, GC gc, float screenWidth, float screenHeight )
{
}

event DetailChange()
{
	local DeusExPlayer player;
	
	Super.DetailChange();
	
	if(Level.NetMode==NM_Standalone)
	{
		foreach AllActors(class'DeusExPlayer', player)
			break;
	
		// Transcended - Ported from Revision
		if ((player != None) && (player.bIsCrouching) && (player.bToggleCrouch))
			player.bDuck = 1;
	}
}

event InitGame( string Options, out string Error )
{
	local string InOpt;
	local float TempDifficulty;
	
	Super.InitGame(Options, Error);

	//Bjorn: We need to convert the CombatDifficulty to match the Difficulty var that the engine uses for filter out stuff on difficulty.
	//Just converting the CombatDifficulty to an int WILL NOT WORK!
	InOpt = ParseOption( Options, "Difficulty" );
	if( InOpt != "" )
		TempDifficulty = float(InOpt);

	if (TempDifficulty < 1.5)
		Difficulty = 0;
	else if (TempDifficulty < 4.0)
		Difficulty = 1;
	else if (TempDifficulty <= 4.0)
		Difficulty = 2;
	else if (TempDifficulty > 4.0)
		Difficulty = 3;
}

function bool IsBurdenLevel()
{
	local DeusExLevelInfo DXLI;
	
	forEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		if ((DXLI != None) && (DXLI.Script != None) && (DXLI.Script.Name == 'Mission80'))
		{
			return true;
		}
	}
	return false;
}

function bool IsCassandraLevel()
{
	local DeusExLevelInfo DXLI;
	
	forEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		if ((DXLI != None) && (DXLI.Script != None))
		{
			switch(DXLI.Script.Name)
			{
				case 'TCP69DangerRoom':
				case 'TCP69HQ':
				case 'TCP69Intro':
				case 'TCP69Outro':
				case 'TCP69Streets':
					return true;
				break;
				default:
					return false;
				break;
			}
		}
	}
	return false;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function SendPlayer( PlayerPawn aPlayer, string URL )
{
	//MADDERS, 8/8/25: This needs to be a map fix for this map, but Revision's maps aren't ours to ship... Gah.
	if ((URL ~= "12_VANDENBERG_CMD") && (Level.TimeSeconds < 1.0))
	{
		return;
	}
	
	if ((DeusExPlayer(APlayer) != None) && (DeusExPlayer(APlayer).FlagBase != None) && (DeusExPlayer(APlayer).FlagBase.GetBool('VMDPlayerTraveling')))
	{
		Log("STILL TRAVELING! CANCELING!");
		return;
	}
	
	URL = class'VMDStaticFunctions'.Static.MutateDestinationByStyle(Self, URL);
	
	Super.SendPlayer(aPlayer, URL);
}

static function SetupMusic(DeusExPlayer player)
{
}

defaultproperties
{
     bMuteSpectators=True
     AutoAim=1.000000
     PauseStartTime=-999999.000000
     PauseEndTime=-999999.000000
}
