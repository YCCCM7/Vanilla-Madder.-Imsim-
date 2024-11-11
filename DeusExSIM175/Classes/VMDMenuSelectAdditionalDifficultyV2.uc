//=============================================================================
// VMDMenuSelectAdditionalDifficultyV2
//=============================================================================
class VMDMenuSelectAdditionalDifficultyV2 expands VMDMenuSelectCustomDifficulty;

// ----------------------------------------------------------------------
// InvokeNewGameScreen()
// ----------------------------------------------------------------------

function InvokeNewGameScreen()
{
	local VMDMenuSelectAdditionalCampaign newGame;
	
	newGame = VMDMenuSelectAdditionalCampaign(root.InvokeMenuScreen(Class'VMDMenuSelectAdditionalCampaign'));
	
	if (newGame != None)
	{
		newGame.SetCampaignData(Player.CombatDifficulty);
	}
}

event DestroyWindow()
{
	//Player.ConsoleCommand("Open DXOnly");
}

defaultproperties
{
}
