//=============================================================================
// VMDMenuChoice_HitIndicatorAudioEnabled
//=============================================================================
class VMDMenuChoice_HitIndicatorAudioEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bHitIndicatorHasAudio));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bHitIndicatorHasAudio = !bool(GetValue());
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
     HelpText="Whether to give audio feedback for headshots or other critical zone hits, with a bit of a 'crunch' sound."
     actionText="H|&it Indicator (A)"
}
