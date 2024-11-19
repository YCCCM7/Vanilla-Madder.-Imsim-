//=============================================================================
// Phone, but with a special message..
//=============================================================================
class PaulM02Phone extends Phone;

function PostBeginPlay()
{
	VMDUpdatePhoneConvos();
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	VMDUpdatePhoneConvos();
}

function VMDUpdatePhoneConvos()
{
	local int OldMissionNumber;
	local string OldPackageName;
	local DeusExLevelInfo DXLI;
	
	//MADDERS, 6/22/24: Universal bark loading. Devious, but effective.
	forEach AllActors(class'DeusExLevelInfo', DXLI)
	{
		OldPackageName = DXLI.ConversationPackage;
		OldMissionNumber = DXLI.MissionNumber;
		DXLI.ConversationPackage = "DeusExConversations";
		DXLI.MissionNumber = 3;
		ConBindEvents();
		DXLI.ConversationPackage = OldPackageName;
		DXLI.MissionNumber = OldMissionNumber;
		break;
	}
}

function Frob(actor Frobber, Inventory frobWith)
{
	Super(ElectronicDevices).Frob(Frobber, frobWith);
	
	if (bUsing)
	{
		return;
	}
	
	SetTimer(3.0, False);
	bUsing = True;
}

defaultproperties
{
     BindName="AnsweringMachine"
}
