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

	if (StoredCampaign ~= "VANILLA")
	{
		if (bool(DynamicLoadObject("FemJC.FJCJump", class'Sound', True)))
		{
			VMP.bDisableFemaleVoice = False;
		}
		else
		{
			VMP.bDisableFemaleVoice = True;
		}
	}
	else
	{
		VMP.bDisableFemaleVoice = True;
	}
	
	switch(CAPS(ActionKey))
	{
		case "START":
			VMP.VMDInterpolateHook();
			VMP.bPendingNGPlusSave = true;
			VMP.NGPlusLaps += 1;
			class'VMDStaticFunctions'.Static.StartCampaign(VMP, StoredCampaign);
		break;
	}
}

//MADDERS, 8/4/23: Don't allow us to select campaigns that female JC can't play in.
function EnableButtons()
{
	local int TranslatedIndex;
	
	Super.EnableButtons();
	
	if ((SelectedIndex >= 0))
	{
		TranslatedIndex = TranslateIndices[SelectedIndex];
		
		if (TranslatedIndex >= 0)
		{
			switch(CAPS(KnownMissions[TranslatedIndex].StartingMapName))
			{
				case "21_TOKYO_BANK":
				case "21_INTRO1":
				case "69_ZODIAC_INTRO":
				case "80_BURDEN_INTRO":
				case "59_INTRO":
				case "44in":
				case "CF_00_Intro":
				case "GOTEM":
				case "01_BASE":
				case "01_APARTMENTBUILDING":
				case "16_THE_HQ":
				case "CORRUPTION_INTRO":
				case "16_FLINSCHMAP":
				case "71_WHITEHOUSE":
				case "FLuCHTWEG":
				case "17_FLINSCHMAP":
				case "51_GVILLE_DOWNTOWN":
				case "16_RESCUE_INTRO": //Non-aroo has us play a thug.
					if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bAssignedFemale) && (!VMDBufferPlayer(Player).bAllowAnyNGPlus))
					{
						if (ActionButtons[1].btn != None)
						{
							ActionButtons[1].btn.SetSensitivity(False);
						}
					}
					else
					{
						if (ActionButtons[1].btn != None)
						{
							ActionButtons[1].btn.SetSensitivity(True);
						}
					}
				break;
				default:
					if (ActionButtons[1].btn != None)
					{
						ActionButtons[1].btn.SetSensitivity(True);
					}
				break;
			}
			
			//MADDERS, 8/6/23: Stop starting new games on the map we're on, context regardless. It throws up, and some places would do this almost every time.
			if (CAPS(KnownMissions[TranslatedIndex].StartingMapName) == class'VMDStaticFunctions'.Static.VMDGetMapName(Player))
			{
				ActionButtons[1].btn.SetSensitivity(False);
			}
		}
	}
}

defaultproperties
{
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Start",Key="START")
     Title="New Game+ Campaign Selection"
}
