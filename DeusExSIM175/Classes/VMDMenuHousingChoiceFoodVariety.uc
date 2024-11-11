//=============================================================================
// VMDMenuHousingChoiceFoodVariety
//=============================================================================
class VMDMenuHousingChoiceFoodVariety extends MenuUIChoice;

// Defaults
var MenuUISliderButtonWindow btnSlider;

var int numTicks;
var float startValue;
var float endValue;
var float defaultValue;
var float saveValue;
var Bool bInitializing;

//MADDERS, 4/17/22: Shove this into oblivion now.
function CreateActionButton()
{
	btnAction = MenuUIChoiceButton(NewChild(Class'MenuUIChoiceButton'));
	btnAction.SetButtonText(actionText);
	btnAction.SetVerticalOffset(buttonVerticalOffset);
	btnAction.EnableRightMouseClick();
	//btnAction.SetPos(512, 0);
	
	BtnAction.SetWidth(179);
}

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	bInitializing = True;
	
	Super.InitWindow();
	
	CreateSlider();
	SetEnumerators();
	
	bInitializing = False;
}

// ----------------------------------------------------------------------
// ParentRequestedPreferredSize()
// ----------------------------------------------------------------------

event ParentRequestedPreferredSize(bool bWidthSpecified, out float preferredWidth, bool bHeightSpecified, out float preferredHeight)
{
	local float sliderWidth, sliderHeight;
	
	if (btnSlider!= None)
		btnSlider.QueryPreferredSize(sliderWidth, sliderHeight);
	
	preferredWidth  = sliderWidth;
	preferredHeight = sliderHeight;
}

// ----------------------------------------------------------------------
// CreateSlider()
// ----------------------------------------------------------------------

function CreateSlider()
{
	btnSlider = MenuUISliderButtonWindow(NewChild(Class'MenuUISliderButtonWindow'));
	
	btnSlider.SetSelectability(False);
	btnSlider.SetPos(0, 20); //ChoiceControlPosX
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

defaultproperties
{
     numTicks=2
     endValue=1.000000
     buttonVerticalOffset=1
     actionText="Food Variety"
}
