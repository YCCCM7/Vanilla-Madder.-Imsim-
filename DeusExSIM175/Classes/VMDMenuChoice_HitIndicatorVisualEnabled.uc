//=============================================================================
// VMDMenuChoice_HitIndicatorVisualEnabled
//=============================================================================
class VMDMenuChoice_HitIndicatorVisualEnabled extends MenuUIChoiceEnum;

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	SetValue(int(!VMDBufferPlayer(Player).bHitIndicatorHasVisual));
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	VMDBufferPlayer(Player).bHitIndicatorHasVisual = !bool(GetValue());
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
     HelpText="Whether to give visual feedback of hits made using the crosshair, including coloration for headshots and armor impacts."
     actionText="|&Hit Indicator (V)"
}
