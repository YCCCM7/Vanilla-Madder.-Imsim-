//=============================================================================
// VMDMenuChoice_HungerEnabled
//=============================================================================
class VMDMenuChoice_HungerEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bHungerEnabled));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bHungerEnabled = !bool(GetValue());
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
     HelpText="Whether you consume food bar over time, leading to eventual health damage."
     actionText="|&Hunger system"
}
