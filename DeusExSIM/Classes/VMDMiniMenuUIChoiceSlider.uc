//=============================================================================
// MenuUIChoiceSlider
//=============================================================================
class VMDMiniMenuUIChoiceSlider extends MenuUIChoiceSlider;

var int ExtraHeight, SliderShiftX, WinScaleX;

var MenuUIInfoButtonWindow winScaleText;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetSize(540-ChoiceControlPosX, 21+ExtraHeight+2);
}

// ----------------------------------------------------------------------
// ParentRequestedPreferredSize()
// ----------------------------------------------------------------------

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth,
                                   bool bHeightSpecified, out float preferredHeight)
{
	local float sliderWidth, sliderHeight;

	if (btnSlider!= None)
		btnSlider.QueryPreferredSize(sliderWidth, sliderHeight);

	preferredWidth  = sliderWidth;
	preferredHeight = sliderHeight+ExtraHeight+2;
}

// ----------------------------------------------------------------------
// CreateSlider()
// ----------------------------------------------------------------------

function CreateSlider()
{
	btnSlider = VMDMiniMenuUISliderButtonWindow(NewChild(Class'VMDMiniMenuUISliderButtonWindow'));
	
	//if (bUseScaleText)
	//{
		winScaleText = MenuUIInfoButtonWindow(NewChild(Class'MenuUIInfoButtonWindow'));
		winScaleText.SetSelectability(False);
		winScaleText.SetWidth(60);
		winScaleText.SetPos(WinScaleX, 1);
	//}
	BtnSlider.WinScaleText = WinScaleText;
	
	btnSlider.SetSelectability(False);
	btnSlider.SetPos(0, ExtraHeight+2); //choiceControlPosX
	btnSlider.SetTicks(numTicks, startValue, endValue);
}

// ----------------------------------------------------------------------
// SetEnumerators()
// ----------------------------------------------------------------------

function SetEnumerators()
{
}

// ----------------------------------------------------------------------
// SetEnumeration()
// ----------------------------------------------------------------------

function SetEnumeration(int tickPos, coerce string newStr)
{
	if (btnSlider != None)
		btnSlider.winSlider.SetEnumeration(tickPos, newStr);
}

// ----------------------------------------------------------------------
// SetValue()
// ----------------------------------------------------------------------

function SetValue(float newValue)
{
	if (btnSlider  != None)
		btnSlider.winSlider.SetValue(newValue);
}

// ----------------------------------------------------------------------
// GetValue()
// ----------------------------------------------------------------------

function float GetValue()
{
	if (btnSlider != None)
		return btnSlider.winSlider.GetValue();
	else
		return 0;
}

// ----------------------------------------------------------------------
// CycleNextValue()
// ----------------------------------------------------------------------

function CycleNextValue()
{
	local int newValue;

	if (btnSlider != None)
	{
		// Get the current slider value and attempt to increment.
		// If at the max go back to the beginning

		newValue = btnSlider.winSlider.GetTickPosition() + 1;

		if (newValue == btnSlider.winSlider.GetNumTicks())
			newValue = 0;

		btnSlider.winSlider.SetTickPosition(newValue);
	}
}

// ----------------------------------------------------------------------
// CyclePreviousValue()
// ----------------------------------------------------------------------

function CyclePreviousValue()
{
	local int newValue;

	if (btnSlider != None)
	{
		// Get the current slider value and attempt to increment.
		// If at the max go back to the beginning

		newValue = btnSlider.winSlider.GetTickPosition() - 1;

		if (newValue < 0)
			newValue = btnSlider.winSlider.GetNumTicks() - 1;

		btnSlider.winSlider.SetTickPosition(newValue);
	}
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	if (configSetting != "")
		SetValue(float(player.ConsoleCommand("get " $ configSetting)));
	else
		ResetToDefault();
}

// ----------------------------------------------------------------------
// SaveSetting()
// ----------------------------------------------------------------------

function SaveSetting()
{
	if (configSetting != "")
		player.ConsoleCommand("set " $ configSetting $ " " $ GetValue());
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function ResetToDefault()
{
	if (configSetting != "")
	{
		player.ConsoleCommand("set " $ configSetting $ " " $ defaultValue);
		LoadSetting();
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ExtraHeight=19
     SliderShiftX=24
     WinScaleX=116
     
     numTicks=11
     endValue=10.000000
     buttonVerticalOffset=1
     actionText="Slider Choice"
}
