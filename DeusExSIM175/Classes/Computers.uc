//=============================================================================
// Computers.
//=============================================================================
class Computers extends ElectronicDevices
	abstract;

struct sSpecialOptions
{
	var() localized string	Text;
	var() localized string	TriggerText;
	var() string			userName;
	var() name				TriggerEvent;
	var() name				UnTriggerEvent;
	var() bool				bTriggerOnceOnly;
	var bool				bAlreadyTriggered;
};

var() localized sSpecialOptions specialOptions[4];

var class<NetworkTerminal> terminalType;
var NetworkTerminal termwindow;
var bool bOn;
var bool bAnimating;
var bool bLockedOut;				// true if this terminal is locked out
var() float lockoutDelay;			// delay until locked out terminal can be used
var float lockoutTime;				// time when terminal was locked out
var float lastHackTime;				// last time the terminal was hacked
var DeusExPlayer curFrobber;     // player currently frobbing.
var localized String msgLockedOut;

enum EAccessLevel
{
	AL_Untrained,
	AL_Trained,
	AL_Advanced,
	AL_Master
};

// userlist information
struct sUserInfo
{
	var() string		userName;
	var() string		password;
	var() EAccessLevel	accessLevel;
};

var() sUserInfo userList[8];

// specific location information
var() string nodeName;
var() string titleString;
var() texture titleTexture;

var() string TextPackage; // Package from which text for emails/bulletins for this computer should be loaded.

// NEW STUFF!!

enum EComputerNodes
{
	CN_UNATCO, 
	CN_VersaLife,
	CN_QueensTower,
	CN_USNavy,
	CN_MJ12Net,
	CN_PageIndustries,
	CN_Area51,
	CN_Everett,
	CN_NSF,
	CN_NYC,
	CN_China,
	CN_HKNet,
	CN_QuickStop,
	CN_LuckyMoney,
	CN_Illuminati
};

struct sNodeInfo
{
	var localized string nodeName;
	var localized string nodeDesc;
	var string nodeAddress;
	var Texture nodeTexture;
};

var() EComputerNodes ComputerNode;
var   localized sNodeInfo NodeInfo[20];

// alarm vars
var float lastAlarmTime;		// last time the alarm was sounded
var int alarmTimeout;			// how long before the alarm silences itself

var localized string CompInUseMsg;

//MADDERS: Randomize our skill level based on story progression!
function ApplySpecialStats()
{
 	local float F, HM, MM, LM;
 	local int TGet;
 	local DeusExLevelInfo Info;
 	
 	forEach AllActors(class'DeusExLevelInfo', Info) break;
 	
 	if ((Info != None) && (HackSkillRequired == -1))
 	{
  		TGet = Info.MissionNumber;
  		
  		HM = 0.15; //HM + LM + MM = Trained Odds (OBSOLETE!)
  		MM = 0.15; //MM + LM = Advanced Odds
  		LM = 0.15; //LM = Master Odds
  		
  		//Each field has 15% chance base.
  		//First half of the game, make master more common.
  		//Second half, make trained more common.
  		//During the middle 5, make middle most common.
  		if (TGet < 8)
  		{
   			HM += (0.078571 * Max(0, 8-TGet));
   			MM = 1.0 - HM - LM;
  		}
  		if (TGet > 8)
  		{
   			LM += (0.078571 * Max(0, TGet-8));
   			MM = 1.0 - HM - LM;
  		}
  		if ((TGet > 5) && (TGet < 11))
  		{
   			MM += (2 - Abs(8-TGet)) * 0.275;
   			if (TGet < 8) LM = 1.0 - HM - MM;
   			if (TGet > 8) HM = 1.0 - LM - MM;
  		}
  		
  		//MADDERS: For post-endgame (mods), turn this to static odds.
  		if (TGet > 15)
  		{
   			LM = 0.2;
   			MM = 0.25;
  		}
  		
  		//If there's any inaccuracy, take it out on MM.
  		else if (1.0 - HM - MM - LM != 0)
  		{
  		 	MM = (1.0 - HM - LM);
  		}
  		
  		//NOW FLIPPED!
  		F = Frand();
  		if ((F < LM) && (TGet > 5)) HackSkillRequired = 2;
  		else if ((F < LM + MM) && (TGet > 2)) HackSkillRequired = 1;
  		else HackSkillRequired = 0;
 	}
}

// -----------------------------------------------------------------------
// PostBeginPlay
// -----------------------------------------------------------------------
function PostBeginPlay()
{
   	Super.PostBeginPlay();
   	curFrobber = None;
}

//
// Alarm functions for when you get caught hacking
//
function BeginAlarm()
{
	AmbientSound = Sound'Klaxon2';
	SoundVolume = 128;
	SoundRadius = 64;
	SoundPitch = 64;
	//lastAlarmTime = Level.TimeSeconds;
	LastAlarmTime = AlarmTimeout;
	AIStartEvent('Alarm', EAITYPE_Audio, SoundVolume/255.0, 25*(SoundRadius+1));

	// make sure we can't go into stasis while we're alarming
	bStasis = False;
}

function EndAlarm()
{
	AmbientSound = Default.AmbientSound;
	SoundVolume = Default.SoundVolume;
	SoundRadius = Default.SoundRadius;
	SoundPitch = Default.SoundPitch;
	lastAlarmTime = 0.0; //Level.TimeSeconds
	AIEndEvent('Alarm', EAITYPE_Audio);

	// reset our stasis info
	bStasis = Default.bStasis;
}

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

   	// DEUS_EX AMSD IN multiplayer, set lockout to 0
   	if (Level.NetMode != NM_Standalone)
      		bLockedOut = False;
	
	//Shut off the alarm if the timeout has expired
	//MADDERS: See below.
	//----------------
	//MADDERS, 5/29/22: This is now done in the player, fun fact. No "unrendered" time not counting.
	/*if ((lastAlarmTime > 0) && (LastAlarmTime <= 1))
	{
		LastAlarmTime -= DeltaTime;
		if (LastAlarmTime <= 0) //Level.TimeSeconds - lastAlarmTime >= alarmTimeout
			EndAlarm();
	}
	
	//MADDERS: Tick down on this time to be less exploitable, ffs.
	//Legitimate exploit to be found here.
	if (LockoutTime > 0)
	{
		//LockoutTime -= DeltaTime;
	}
	if (LastHackTime > 0)
	{
		//LastHackTime -= DeltaTime;
	}*/
}
// ----------------------------------------------------------------------
// ChangePlayerVisibility()
// ----------------------------------------------------------------------

function ChangePlayerVisibility(bool bInviso)
{
	local DeusExPlayer player;

   	if (Level.NetMode != NM_Standalone)
      		return;
	player = DeusExPlayer(GetPlayerPawn());
	if (player != None)
		player.MakePlayerIgnored(!bInviso);
}

// ----------------------------------------------------------------------
// state On
// ----------------------------------------------------------------------

state On
{
	function Tick(float deltaTime)
	{
		Global.Tick(deltaTime);

		if (bOn)
		{
			if ((termwindow == None) && (Level.NetMode == NM_Standalone))
         		{
				GotoState('Off');
         		}            
         		if (curFrobber == None)
         		{
            			GotoState('Off');
         		}
         		else if (VSize(curFrobber.Location - Location) > 1500)
         		{
            			log("Disabling computer "$Self$" because user "$curFrobber$" was too far away");
				//Probably should be "GotoState('Off')" instead, but no good way to test, so I'll leave it alone.
            			curFrobber = None;
         		}
		}
	}
	
	function PlayerVisibilityChange()
	{
		local Human player;
		
		//Justice: Using a computer shouldn't make you invisible
		player = Human(GetPlayerPawn());
		if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Player, "Computer Visibility"))
			return;
		else
			ChangePlayerVisibility(False);
	}

Begin:
	if (!bOn)
	{
      		AdditionalActivation(curFrobber);
		bAnimating = True;
		if (ComputerSecurity(Self) != None) // Transcended - Added
			PlayAnim('Activate', 2.5);
		else
			PlayAnim('Activate');
		FinishAnim();
		bOn = True;
		bAnimating = False;
		PlayerVisibilityChange(); // Transcended - Added
      		TryInvoke();
	}
}

// ----------------------------------------------------------------------
// state Off
// ----------------------------------------------------------------------

auto state Off
{
Begin:
	if (bOn)
	{
      		AdditionalDeactivation(curFrobber);
		ChangePlayerVisibility(True);
		bAnimating = True;
		if (AnimSequence == 'Activate') 
		{
			if (ComputerSecurity(Self) != None) // Transcended - Added
				PlayAnim('Deactivate', 2.5);
			else
				PlayAnim('Deactivate');
		}
		FinishAnim();
		bOn = False;
		bAnimating = False;
		if (bLockedOut)
			BeginAlarm();

		// Resume any datalinks that may have started while we were 
		// in the computers (don't want them to start until we pop back out)
		ResumeDataLinks();
      		curFrobber = None;
	}
}

// ----------------------------------------------------------------------
// ResumeDataLinks()
// ----------------------------------------------------------------------

function ResumeDataLinks()
{
	local DeusExPlayer player;

	player = curFrobber;
	if (player != None)
	{
		player.ResumeDataLinks();
	}
}

// ----------------------------------------------------------------------
// TryInvoke()
// ----------------------------------------------------------------------

function TryInvoke()
{
   	if (IsInState('Off'))
      		return;
   	
   	if (!Invoke())
   	{
      		GotoState('Off');
   	}
	
   	return;
}

// ----------------------------------------------------------------------
// Invoke()
// ----------------------------------------------------------------------

function bool Invoke()
{
	local DeusExPlayer player;

	if (termwindow != None)
		return False;

	player = curFrobber;
	if (player != None)
	{
      		//pass timing info so the player can keep the time uptodate on his end.
      		player.InvokeComputerScreen(self, lastHackTime, Level.TimeSeconds);
      		// set owner for relevancy fer sure;
      		SetOwner(Player);
	}

	return True;
}

// ----------------------------------------------------------------------
// CloseOut()
// ----------------------------------------------------------------------

function CloseOut()
{
   	if (curFrobber != None)
   	{
      		//curFrobber = None;
      		GotoState('Off');
   	}
}

// ----------------------------------------------------------------------
// Frob()
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
	local float elapsed, delay;
	local VMDMEGH TMegh;
	
   	// Don't allow someone else to use the computer when already in use.
   	if (curFrobber != None)
   	{
      		if ((DeusExPlayer(Frobber) != None) && (Level.Netmode != NM_Standalone))
		{
        		 DeusExPlayer(Frobber).ClientMessage(Sprintf(CompInUseMsg,curFrobber.PlayerReplicationInfo.PlayerName));
		}
      		return;
   	}
	if (DeusExPlayer(Frobber) != None)
	{
		forEach AllActors(class'VMDMEGH', TMegh)
		{
			if ((TMegh.EMPHitPoints > 0) && (TMegh.LiteHackComputer == Self))
			{
      				DeusExPlayer(Frobber).ClientMessage(Sprintf(CompInUseMsg, TMEGH.VMDGetDisplayName(TMegh.UnfamiliarName)));			
					return;
			}
		}
	}
	
	Super.Frob(Frobber, frobWith);
	
   	// DEUS_EX AMSD get player from frobber, not from getplayerpawn
	player = DeusExPlayer(Frobber);
	if (player != None)
	{
		if (bLockedOut)
		{
			// computer skill shortens the lockout duration
			delay = lockoutDelay / player.SkillSystem.GetSkillLevelValue(class'SkillComputer');
			
			//elapsed = Level.TimeSeconds - lockoutTime;
			Elapsed = LockoutTime;
			if (elapsed > 0) //< delay
				player.ClientMessage(Sprintf(msgLockedOut, Int(elapsed))); //delay - 
			else
				bLockedOut = False;
		}
		if (!bAnimating && !bLockedOut)
      		{
         		curFrobber = player;
			GotoState('On');
      		}
	}
}

// ----------------------------------------------------------------------
// NumUsers()
// ----------------------------------------------------------------------

function int NumUsers()
{
	local int i;

	for (i=0; i<ArrayCount(userList); i++)
		if (userList[i].userName == "")
			break;

	return i;
}

// ----------------------------------------------------------------------
// GetUserName()
// ----------------------------------------------------------------------

function string GetUserName(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return userList[userIndex].userName;

	return "ERR";
}

// ----------------------------------------------------------------------
// GetPassword()
// ----------------------------------------------------------------------

function string GetPassword(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return userList[userIndex].password;

	return "ERR";
}

// ----------------------------------------------------------------------
// GetAccessLevel()
// ----------------------------------------------------------------------

function int GetAccessLevel(int userIndex)
{
	if ((userIndex >= 0) && (userIndex < ArrayCount(userList)))
		return Int(userList[userIndex].accessLevel);

	return 0;
}

// ----------------------------------------------------------------------
// GetNodeName()
// ----------------------------------------------------------------------

function String GetNodeName()
{
	return nodeInfo[Int(ComputerNode)].nodeName;
}

// ----------------------------------------------------------------------
// GetNodeDesc()
// ----------------------------------------------------------------------

function String GetNodeDesc()
{
	return nodeInfo[Int(ComputerNode)].nodeDesc;
}

// ----------------------------------------------------------------------
// GetNodeAddress()
// ----------------------------------------------------------------------

function String GetNodeAddress()
{
	return nodeInfo[Int(ComputerNode)].nodeAddress;
}

// ----------------------------------------------------------------------
// GetNodeTexture()
// ----------------------------------------------------------------------

function Texture GetNodeTexture()
{
	return nodeInfo[Int(ComputerNode)].nodeTexture;
}

// ----------------------------------------------------------------------
// AdditionalActivation()
// Called for subclasses to do any additional activation steps.
// ----------------------------------------------------------------------

function AdditionalActivation(DeusExPlayer ActivatingPlayer)
{
}

// ----------------------------------------------------------------------
// AdditionalDeactivation()
// ----------------------------------------------------------------------

function AdditionalDeactivation(DeusExPlayer DeactivatingPlayer)
{
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     bOn=True
     lockoutDelay=30.000000
     lastHackTime=0.000000 //-9999
     msgLockedOut="Terminal is locked out for %d more seconds"
     nodeName="UNATCO"
     titleString="United Nations Anti-Terrorist Coalition (UNATCO)"
     titleTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoUNATCO'
     TextPackage="DeusExText"
     NodeInfo(0)=(nodeName="UNATCO",nodeAddress="UN//UNATCO//RESTRICTED//923.128.6430",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoUNATCO')
     NodeInfo(1)=(nodeName="VersaLife",nodeDesc="VersaLife",nodeAddress="VERSALIFECORP//GLOBAL//3939.39.8",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoVersaLife')
     NodeInfo(2)=(nodeName="Queens Tower",nodeDesc="Queens Tower Luxury Suites",nodeAddress="QT_UTIL//LOCAL//673.9845.09531",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoQueensTower')
     NodeInfo(3)=(nodeName="USN",nodeDesc="United States Navy",nodeAddress="USGOV//MIL//USN//GLOBAL//0001",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoUSNavy')
     NodeInfo(4)=(nodeName="MJ12Net",nodeDesc="Majestic 12 Net",nodeAddress="MAJESTIC//GLOBAL//12.12.12",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoMJ12')
     NodeInfo(5)=(nodeName="Page Industries",nodeDesc="Page Industries",nodeAddress="PAGEIND//USERWEB//NODE.34@778",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoPage')
     NodeInfo(6)=(nodeName="X-51 SecureNet",nodeDesc="X-51 SecureNet",nodeAddress="X51//SECURENET//NODE.938@893",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoArea51')
     NodeInfo(7)=(nodeName="Everett Enterprises",nodeDesc="Everett Enterprises",nodeAddress="EE//INTSYS.TT//0232.98//TERMINAL",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoEverettEnt')
     NodeInfo(8)=(nodeName="NSF",nodeDesc="NSF",nodeAddress="HUB//RESISTANCE.7654//NSFNODES",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoNSF')
     NodeInfo(9)=(nodeName="NYComm",nodeDesc="NYC Communications",nodeAddress="USA//DOMESTIC//NYCCOM.USERS.PUB",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoNYComm')
     NodeInfo(10)=(nodeName="PRChina",nodeDesc="Peoples Republic of China",nodeAddress="PRC//GOV//RESTRICTED.HK.562",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoPRChina')
     NodeInfo(11)=(nodeName="HKNet",nodeDesc="HK Net",nodeAddress="PUB//HKNET//USERS.ACCTS.20435//2",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoHKNet')
     NodeInfo(12)=(nodeName="Quick Stop",nodeDesc="Quick Stop",nodeAddress="PUB//HKNET//QUICKSTOPINT//NODE98",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoQuickStop')
     NodeInfo(13)=(nodeName="Lucky Money",nodeDesc="Lucky Money Club",nodeAddress="PUB//HKNET//LUCKYMONEY/BUSSYS.294",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoLuckyMoney')
     NodeInfo(14)=(nodeName="IIS",nodeDesc="Illuminati Information Systems",nodeAddress="SECURE//IIS.INFTRANS.SYS//UEU",nodeTexture=Texture'DeusExUI.UserInterface.ComputerLogonLogoIlluminati')
     alarmTimeout=30
     CompInUseMsg="The computer is already in use by %s."
     Mass=20.000000
     Buoyancy=5.000000
}
