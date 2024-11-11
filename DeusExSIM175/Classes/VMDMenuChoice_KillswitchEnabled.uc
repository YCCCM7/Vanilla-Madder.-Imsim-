//=============================================================================
// VMDMenuChoice_KillswitchEnabled
//=============================================================================
class VMDMenuChoice_KillswitchEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bImmersiveKillswitch));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bImmersiveKillswitch = !bool(GetValue());
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
     defaultValue=0
     defaultInfoWidth=88
     HelpText="If true, then your killswitch sequence will become a race against the clock."
     actionText="Realistic |&Killswitch"
}
