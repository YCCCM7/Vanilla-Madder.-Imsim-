//=============================================================================
// MenuUIChoiceEnum
//=============================================================================

class MenuUIChoiceEnum extends MenuUIChoice;

// Defaults
var MenuUIInfoButtonWindow btnInfo;

var localized String enumText[40];
var int    currentEnum;

var int    currentValue;
var int    defaultValue;
var int    defaultInfoWidth;
var int    defaultInfoPosX;

//MADDERS, 7/21/21: Mega hack for HC... Hacking.
var bool bHCHackDone;

// ----------------------------------------------------------------------
// InitWindow()
//
// Initialize the Window
// ----------------------------------------------------------------------

event InitWindow()
{
	CreateInfoButton();

	Super.InitWindow();
}

// ----------------------------------------------------------------------
// ButtonActivated()
//
// If the action button was pressed, cycle to the next available
// choice (if any)
// ----------------------------------------------------------------------

function bool ButtonActivated( Window buttonPressed )
{
	if (!bBeingDestroyed)
	{
		AddTimer(0.25, false, 0, 'VMDHCPeripheralCheck');
	}
	
	if (buttonPressed == btnInfo)
	{
		CycleNextValue();
		return True;
	}
	else
	{
		return Super.ButtonActivated(buttonPressed);
	}
}

// ----------------------------------------------------------------------
// CycleNextValue()
// ----------------------------------------------------------------------

function CycleNextValue()
{
	local int newValue;
		
	// Cycle to the next value, but make sure we don't exceed the 
	// bounds of the enumText array.  If we do, start back at the 
	// bottom.

	newValue = GetValue() + 1;

	if (newValue == arrayCount(enumText))
		newValue = 0;
	else if (enumText[newValue] == "")
		newValue = 0;
		
	SetValue(newValue);
}

// ----------------------------------------------------------------------
// CyclePreviousValue()
// ----------------------------------------------------------------------

function CyclePreviousValue()
{
	local int newValue;

	// Cycle to the next value, but make sure we don't exceed the 
	// bounds of the enumText array.  If we do, start back at the 
	// bottom.

	newValue = GetValue() - 1;

	if (newValue < 0)
	{
		newValue = arrayCount(enumText) - 1;

		while((enumText[newValue] == "") && (newValue > 0))
			newValue--;	
	}

	SetValue(newValue);
}

// ----------------------------------------------------------------------
// CreateInfoButton()
// ----------------------------------------------------------------------

function CreateInfoButton()
{
	btnInfo = MenuUIInfoButtonWindow(NewChild(Class'MenuUIInfoButtonWindow'));

	btnInfo.SetSelectability(False);
	btnInfo.SetSize(defaultInfoWidth, 19);
	btnInfo.SetPos(defaultInfoPosX, 0);
}

// ----------------------------------------------------------------------
// UpdateInfoButton()
// ----------------------------------------------------------------------

function UpdateInfoButton()
{
	btnInfo.SetButtonText(enumText[currentValue]);
}

// ----------------------------------------------------------------------
// SetValue()
// ----------------------------------------------------------------------

function SetValue(int newValue)
{
	currentValue = newValue;
	UpdateInfoButton();
}

// ----------------------------------------------------------------------
// GetValue()
// ----------------------------------------------------------------------

function float GetValue()
{
	return currentValue;
}

// ----------------------------------------------------------------------
// LoadSetting()
// ----------------------------------------------------------------------

function LoadSetting()
{
	if (configSetting != "")
		SetValue(int(player.ConsoleCommand("get " $ configSetting)));
	else
		ResetToDefault();
}

// ----------------------------------------------------------------------
// LoadSettingBool()
// ----------------------------------------------------------------------

function LoadSettingBool()
{
	local String boolString;

	boolString = player.ConsoleCommand("get " $ configSetting);

	if (bool(BoolString))
		setValue(1);
	else
		setValue(0);
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
// SaveSettingBool()
// ----------------------------------------------------------------------

function SaveSettingBool()
{
	player.ConsoleCommand("set " $ configSetting $ " " $ Bool(GetValue()));
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

function VMDHCPeripheralCheck()
{	
	//Hack for tweaking later.
	local float HCBalanceMult;
	
	if (bBeingDestroyed) return;
	
	if (!bHCHackDone)
	{
		HCBalanceMult = 0.425;
		if (IsA('HCComputerSecurityChoice_Turret'))
		{
			VMDHandleTimeCost(7.5*HCBalanceMult);
		}
		else if (IsA('HCComputerSecurityChoice_Camera'))
		{
			VMDHandleTimeCost(5.0*HCBalanceMult);
		}
		else if (IsA('HCComputerSecurityChoice_DoorOpen'))
		{
			VMDHandleTimeCost(4.0*HCBalanceMult);
		}
		else if (IsA('HCComputerSecurityChoice_DoorAccess'))
		{
			VMDHandleTimeCost(4.0*HCBalanceMult);
		}
		bHCHackDone = true;
	}
}

//MADDERS, 7/21/21: Our hack for HC shit here. Thanks, I hate it.
function VMDHandleTimeCost(float TimeCost)
{
	local ComputerScreenHack CoScHa;
	
	if (bBeingDestroyed) return;
	
	forEach AllObjects(class'ComputerScreenHack', CoScHa)
	{
		if ((CoScHa != None) && (!CoScHa.bBeingDestroyed))
		{
			CoScHa.AddTimeCost(TimeCost);
			break;
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     defaultInfoWidth=77
     defaultInfoPosX=270
}
