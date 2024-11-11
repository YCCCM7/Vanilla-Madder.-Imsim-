//=============================================================================
// MissionCharacterSetup.
//=============================================================================
class MissionCharacterSetup extends MissionScript;

var bool bInvokedScreen;

//MADDERS: Just invoke the starting screen. That's all we ask.
function FirstFrame()
{
	Super.FirstFrame();

	if (player != None)
	{
		//Player.ShowMainMenu();
	}
}

function Timer()
{
	Super.Timer();
	
	if ((player != None) && (!bInvokedScreen))
	{
		bInvokedScreen = True;
		Player.ShowMainMenu();
		
		if (VMDBufferPlayer(Player) != None)
		{
			VMDBufferPlayer(Player).SetupSkillAugmentManager(true);
		}
	}
}

defaultproperties
{
}
