//=============================================================================
// VMDMenuSelectAdditionalCampaign
//=============================================================================
class VMDMenuSelectAdditionalCampaign expands VMDMenuSelectCustomCampaign;

function ProcessAction(String actionKey)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP == None) return;
	
	VMP.InvokedBindName = StoredBindName;
	VMP.SelectedCampaign = StoredCampaign;
	VMP.CampaignNewGameMap = StoredStartMap;
	VMP.VMDResetPlayerNewGamePlus();
	
	switch(CAPS(ActionKey))
	{
		case "START":
			class'VMDStaticFunctions'.Static.StartCampaign(VMP, StoredCampaign);
		break;
	}
}

defaultproperties
{
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Start",Key="START")
     Title="New Game+ Campaign Selection"
}
