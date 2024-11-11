//=============================================================================
// RevMenuChoice_ItemRefusal
//
// Created for the mod Deus Ex: Revision, and may be used according to the project licence.
//=============================================================================
class MenuChoice_ItemRefusal extends MenuUIChoiceAction;

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------
function bool ButtonActivated( Window buttonPressed )
{
	local DeusExRootWindow root;

	root = DeusExRootWindow(GetRootWindow());

	root.PopWindow();
	root.InvokeMenuScreen(Class'MenuScreenItemRefusal');
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------
function LoadSetting()
{
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------
function SaveSetting()
{
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------
event bool BoxOptionSelected(Window button, int buttonNumber)
{
	local DeusExRootWindow root;

	root = DeusExRootWindow(GetRootWindow());

	root.PopWindow();
	root.InvokeMenuScreen(Class'MenuScreenItemRefusal');
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     Action=MA_Custom
     HelpText="Select which items will not be allowed to be placed into your inventory."
     actionText="Item |&Refusal"
}