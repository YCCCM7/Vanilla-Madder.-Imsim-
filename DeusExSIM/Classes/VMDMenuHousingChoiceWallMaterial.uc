//=============================================================================
// VMDMenuHousingChoiceWallMaterial
//=============================================================================
class VMDMenuHousingChoiceWallMaterial extends MenuUIChoice;

// Defaults
var VMDMenuUISliderButtonWindow288 BtnSlider;

var int NumTicks;
var float StartValue;
var float EndValue;
var float DefaultValue;
var float SaveValue;
var Bool bInitializing;

function SetMaterial(int NewWidth, int CurValue)
{
	BtnAction.SetWidth(NewWidth);
	SetValue(CurValue);
}

//MADDERS, 4/17/22: Shove this into oblivion now.
function CreateActionButton()
{
	BtnAction = MenuUIChoiceButton(NewChild(Class'MenuUIChoiceButton'));
	BtnAction.SetButtonText(ActionText);
	BtnAction.SetVerticalOffset(buttonVerticalOffset);
	BtnAction.EnableRightMouseClick();
	
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

event ParentRequestedPreferredSize(bool bWidthSpecified, out float PreferredWidth, bool bHeightSpecified, out float PreferredHeight)
{
	local float SliderWidth, SliderHeight;
	
	if (BtnSlider!= None)
	{
		BtnSlider.QueryPreferredSize(sliderWidth, sliderHeight);
	}
	PreferredWidth  = SliderWidth;
	PreferredHeight = SliderHeight;
}

// ----------------------------------------------------------------------
// CreateSlider()
// ----------------------------------------------------------------------

function CreateSlider()
{
	BtnSlider = VMDMenuUISliderButtonWindow288(NewChild(Class'VMDMenuUISliderButtonWindow288'));
	
	BtnSlider.SetSelectability(False);
	BtnSlider.SetPos(0, 20); //ChoiceControlPosX
	BtnSlider.SetTicks(NumTicks, StartValue, EndValue);
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

function SetEnumeration(int TickPos, coerce string NewStr)
{
	if (BtnSlider != None)
	{
		BtnSlider.winSlider.SetEnumeration(TickPos, NewStr);
	}
}

// ----------------------------------------------------------------------
// SetValue()
// ----------------------------------------------------------------------

function SetValue(float NewValue)
{
	if (BtnSlider != None)
	{
		BtnSlider.winSlider.SetValue(NewValue);
	}
}

// ----------------------------------------------------------------------
// GetValue()
// ----------------------------------------------------------------------

function float GetValue()
{
	if (BtnSlider != None)
	{
		return BtnSlider.WinSlider.GetValue();
	}
	else
	{
		return 0;
	}
}

// ----------------------------------------------------------------------
// CycleNextValue()
// ----------------------------------------------------------------------

function CycleNextValue()
{
	local int NewValue;
	
	if (BtnSlider != None)
	{
		// Get the current slider value and attempt to increment.
		// If at the max go back to the beginning
		
		NewValue = BtnSlider.WinSlider.GetTickPosition() + 1;
		
		if (NewValue == BtnSlider.WinSlider.GetNumTicks())
			NewValue = 0;
		
		BtnSlider.WinSlider.SetTickPosition(NewValue);
	}
}

// ----------------------------------------------------------------------
// CyclePreviousValue()
// ----------------------------------------------------------------------

function CyclePreviousValue()
{
	local int NewValue;
	
	if (BtnSlider != None)
	{
		// Get the current slider value and attempt to increment.
		// If at the max go back to the beginning
		
		NewValue = BtnSlider.WinSlider.GetTickPosition() - 1;
		
		if (NewValue < 0)
			NewValue = BtnSlider.WinSlider.GetNumTicks() - 1;
		
		BtnSlider.WinSlider.SetTickPosition(NewValue);
	}
}

defaultproperties
{
     NumTicks=2
     EndValue=1.000000
     ButtonVerticalOffset=1
     ActionText="Material"
}
