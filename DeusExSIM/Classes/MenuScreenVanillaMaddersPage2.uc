//=============================================================================
// MenuScreenVanillaMaddersPage2
//=============================================================================
class MenuScreenVanillaMaddersPage2 expands MenuUIScreenWindow;

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
		case "PREVPAGE":
			SaveSettings();
			AddTimer(0.05, false,, 'InvokePrevPage');
		break;
	}
}

//MADDERS, 11/26/20: JFC. I hate when execution speed is life or death. Nasty hack.
function InvokePrevPage()
{
	root.PopWindow();
	root.InvokeMenuScreen(Class'MenuScreenVanillaMadders');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Choices(0)=Class'DeusEx.VMDMenuChoice_D3DPrecachingEnabled'
     choices(1)=Class'DeusEx.VMDMenuChoice_EnvironmentalSoundsEnabled'
     choices(2)=Class'DeusEx.VMDMenuChoice_CustomUIColors'
     //choices(0)=Class'DeusEx.VMDMenuChoice_HitIndicatorVisualEnabled'
     //choices(1)=Class'DeusEx.VMDMenuChoice_HitIndicatorAudioEnabled'
     //choices(3)=Class'DeusEx.VMDMenuChoice_FemJCAllowed'
     actionButtons(0)=(Align=HALIGN_Right,Action=AB_Cancel)
     actionButtons(1)=(Align=HALIGN_Right,Action=AB_OK)
     actionButtons(2)=(Align=HALIGN_Right,Action=AB_Other,Text="|&Prev. Page",Key="PREVPAGE")
     actionButtons(3)=(Action=AB_Reset)
     Title="VMD Options (Page 2)"
     ClientWidth=537
     ClientHeight=207
     clientTextures(0)=Texture'VMDMenuGameOptionsThreeBackground_1'
     clientTextures(1)=Texture'VMDMenuGameOptionsThreeBackground_2'
     clientTextures(2)=Texture'VMDMenuGameOptionsThreeBackground_3'
     //clientTextures(3)=Texture'DeusExUI.UserInterface.MenuGameOptionsBackground_4'
     //clientTextures(4)=Texture'DeusExUI.UserInterface.MenuGameOptionsBackground_5'
     //clientTextures(5)=Texture'DeusExUI.UserInterface.MenuGameOptionsBackground_6'
     helpPosY=138
}
