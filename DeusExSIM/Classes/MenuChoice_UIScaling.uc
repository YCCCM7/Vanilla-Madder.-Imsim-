//=============================================================================
// RFMenuChoice_UIScaling
//
// UI scaling menu option.
//
// Created for the Revision Framework, and may be used according to the project license.
//=============================================================================
class MenuChoice_UIScaling extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// ButtonActivated()
// ----------------------------------------------------------------------
function bool ButtonActivated(Window buttonPressed)
{
	CycleNextValue();
	return True;
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------
function LoadSetting()
{
	SetValue(Int(player.GetPropertyText(configSetting)) + 1);
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------
function SaveSetting()
{
	//Change user.ini setting, our ini settings go from -1 and up (no real limit) so here we just offset since our values here go from 0 to 3.
	player.SetPropertyText(configSetting, String(currentValue-1));
}

// ----------------------------------------------------------------------
// BoxOptionSelected()
// ----------------------------------------------------------------------
event bool BoxOptionSelected(Window button, int buttonNumber)
{
	CyclePreviousValue();
	return True;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     defaultInfoWidth=98
	 defaultValue=2
	 configSetting="scaleMode"
	 enumText(0)="Relaxed"
	 enumText(1)="Dynamic"
	 enumText(2)="Normal"
	 enumText(3)="HiDPI"
	 HelpText="In dynamic mode, the UI is scaled based on your resolution. HiDPI enlarges the UI up to 2x scale. Relaxed may be useful for unusual resolutions."
	 actionText="|&UI Scaling"
}
