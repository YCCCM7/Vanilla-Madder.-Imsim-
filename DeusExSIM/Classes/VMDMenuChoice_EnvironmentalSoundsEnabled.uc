//=============================================================================
// VMDMenuChoice_EnvironmentalSoundsEnabled
//=============================================================================
class VMDMenuChoice_EnvironmentalSoundsEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bEnvironmentalSoundsEnabled));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bEnvironmentalSoundsEnabled = !bool(GetValue());
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
     HelpText="Toggles accessory sounds for hunger, stress, and so forth."
     actionText="En|&viromental sounds"
}
