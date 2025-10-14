//=============================================================================
// VMDMenuSelectAdditionalCustomRevision
//=============================================================================
class VMDMenuSelectAdditionalCustomRevision expands VMDMenuSelectCustomRevision;

function InvokeNewGameScreen()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		class'VMDStaticFunctions'.Static.StartCampaign(VMP, StoredCampaign);
	}
}

defaultproperties
{
     actionButtons(0)=(Align=HALIGN_Left,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Start",Key="START")
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Randomize",Key="RANDOMIZE")
}
