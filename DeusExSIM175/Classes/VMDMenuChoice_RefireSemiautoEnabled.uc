//=============================================================================
// VMDMenuChoice_RefireSemiautoEnabled
//=============================================================================
class VMDMenuChoice_RefireSemiautoEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bRefireSemiauto));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bRefireSemiauto = !bool(GetValue());
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
     HelpText="If enabled, all weapons (not just automatic) will refire when holding down the trigger. Some weapons may be hard to control without trigger discipline."
     actionText="Semi-auto R|&efire "
}
