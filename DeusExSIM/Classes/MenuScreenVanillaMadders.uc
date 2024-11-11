//=============================================================================
// MenuScreenVanillaMadders
//=============================================================================
class MenuScreenVanillaMadders expands MenuUIScreenWindow;

// ----------------------------------------------------------------------
// SaveSettings()
// ----------------------------------------------------------------------

function SaveSettings()
{
	Super.SaveSettings();
	player.SaveConfig();
}

// ----------------------------------------------------------------------
// ProcessAction()
// ----------------------------------------------------------------------

function ProcessAction(String actionKey)
{
	switch(CAPS(ActionKey))
	{
		case "NEXTPAGE":
			SaveSettings();
			AddTimer(0.05, false,, 'InvokeNextPage');
		break;
	}
}

//MADDERS, 11/26/20: JFC. I hate when execution speed is life or death. Nasty hack.
function InvokeNextPage()
{
	root.PopWindow();
	root.InvokeMenuScreen(Class'MenuScreenVanillaMaddersPage2');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     choices(0)=Class'DeusEx.VMDMenuChoice_HungerEnabled'
     choices(1)=Class'DeusEx.VMDMenuChoice_AddictionEnabled'
     choices(2)=Class'DeusEx.VMDMenuChoice_StressEnabled'
     choices(3)=Class'DeusEx.VMDMenuChoice_SmellsEnabled'
     choices(4)=Class'DeusEx.VMDMenuChoice_SkillAugmentsEnabled'
     choices(5)=Class'DeusEx.VMDMenuChoice_KillswitchEnabled'
     choices(6)=Class'DeusEx.VMDMenuChoice_RefireSemiautoEnabled'
     choices(7)=Class'DeusEx.VMDMenuChoice_HitIndicatorVisualEnabled'
     choices(8)=Class'DeusEx.VMDMenuChoice_HitIndicatorAudioEnabled'
     //choices(2)=Class'DeusEx.VMDMenuChoice_GrimeEnabled'
     //choices(8)=Class'DeusEx.VMDMenuChoice_D3DPrecachingEnabled'
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Next Page",Key="NEXTPAGE")
     actionButtons(3)=(Action=AB_Reset)
     Title="VMD Options (Page 1)"
     ClientWidth=537
     ClientHeight=406
     clientTextures(0)=Texture'DeusExUI.UserInterface.MenuGameOptionsBackground_1'
     clientTextures(1)=Texture'DeusExUI.UserInterface.MenuGameOptionsBackground_2'
     clientTextures(2)=Texture'DeusExUI.UserInterface.MenuGameOptionsBackground_3'
     clientTextures(3)=Texture'VMDMenuGameOptionsBackground_4'
     clientTextures(4)=Texture'VMDMenuGameOptionsBackground_5'
     clientTextures(5)=Texture'VMDMenuGameOptionsBackground_6'
     helpPosY=354
}
