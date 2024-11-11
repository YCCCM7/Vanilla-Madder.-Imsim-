//=============================================================================
// VMDMenuChoice_AddictionEnabled
//=============================================================================
class VMDMenuChoice_AddictionEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(VMDBufferPlayer(Player).bAddictionEnabled);
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bAddictionEnabled = GetValue();
}

// ----------------------------------------------------------------------
// ResetToDefault()
// ----------------------------------------------------------------------

function ResetToDefault()
{
	SetValue(defaultValue);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     enumText(0)="None"
     enumText(1)="Major"
     enumText(2)="ALL"
     defaultValue=1
     defaultInfoWidth=88
     HelpText="Toggles the degree to which JC can be addicted to substances. Minor addictions can be annoying."
     actionText="|&Addiction System"
}
