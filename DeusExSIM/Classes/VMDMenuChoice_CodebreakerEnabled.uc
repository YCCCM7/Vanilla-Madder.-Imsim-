//=============================================================================
// VMDMenuChoice_CodebreakerEnabled
//=============================================================================
class VMDMenuChoice_CodebreakerEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bCodebreakerPreference));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bCodebreakerPreference = !bool(GetValue());
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
     enumText(0)="Enabled"
     enumText(1)="Disabled"
     defaultValue=1
     defaultInfoWidth=88
     HelpText="If enabled, double click hacks keypads, while singe click engages a mini-game."
     actionText="|&Codebreaker Minigame"
}
