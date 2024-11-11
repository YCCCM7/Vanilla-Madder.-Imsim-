//=============================================================================
// PersonaAugmentationItemButton
//=============================================================================
class PersonaAugmentationItemButton extends PersonaItemButton;

var PersonaLevelIconWindow winLevels;
var bool  bActive;
var int   hotkeyNumber;
var Color colIconActive;
var Color colIconNormal;

//MADDERS: Our other colors, for disabled/enabled
var Color ColIconEnabled, ColIconDisabled;
var bool bEnabled, bPassive;

var PersonaScreenAugmentations WinAug;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super.InitWindow();
	
	SetActive(False);
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{	
	local String str;
	
	Super.DrawWindow(gc);
	
	// Draw the hotkey info in lower-left corner
	if (hotkeyNumber >= 3)
	{
		str = "F" $ hotkeyNumber;
		gc.SetFont(Font'FontMenuSmall_DS');
		gc.SetAlignments(HALIGN_Left, VALIGN_Top);
		gc.SetTextColor(colHeaderText);
		gc.DrawText(2, iconPosHeight - 9, iconPosWidth - 2, 10, str);
	}
}

// ----------------------------------------------------------------------
// CreateControls()
// ----------------------------------------------------------------------

function CreateControls()
{
	winLevels = PersonaLevelIconWindow(NewChild(Class'PersonaLevelIconWindow'));
	winLevels.SetPos(30, 54);
	winLevels.SetSelected(True);
}

// ----------------------------------------------------------------------
// SetHotkeyNumber()
// ----------------------------------------------------------------------

function SetHotkeyNumber(int num)
{
	hotkeyNumber = num;
}

// ----------------------------------------------------------------------
// SetActive()
// ----------------------------------------------------------------------

function SetActive(bool bNewActive)
{
	if (!bPassive)
	{
		bActive = bNewActive;
		
		if (bActive)
		{
			colIcon = colIconActive;
		}
		else
		{
			colIcon = colIconNormal;
		}
	}
	else
	{
		bActive = bNewActive;
		if (bActive)
		{
			ColIcon = ColIconEnabled;
		}
		else
		{
			ColIcon = ColIconDisabled;
		}
	}
}

// ----------------------------------------------------------------------
// SetLevel()
// ----------------------------------------------------------------------

function SetLevel(int newLevel)
{
	if (winLevels != None)
		winLevels.SetLevel(newLevel);
}

// ----------------------------------------------------------------------
// SetAugWindow()
// ----------------------------------------------------------------------

function SetAugWindow(PersonaScreenAugmentations newWinAug)
{
	winAug = newWinAug;
}

// ----------------------------------------------------------------------
// MouseButtonPressed()
//
// If the user presses the mouse button, initiate drag mode
// ----------------------------------------------------------------------

event bool MouseButtonPressed(float pointX, float pointY, EInputKey button, int numClicks)
{
	local Bool bResult;
	
	bResult = False;
	
	if (button == IK_RightMouse)
	{
		RemoteQuickToggle();
		bResult = True;
	}
	return bResult;
}

function RemoteQuickToggle()
{
	if (WinAug != None)
	{
		WinAug.SelectAugmentation(Self);
		WinAug.ActivateAugmentation();
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     //MADDERS additions.
     ColIconEnabled=(R=192,G=255,B=96)
     ColIconDisabled=(R=255,G=96,B=96)
     
     colIconActive=(G=255)
     colIconNormal=(R=255,G=255)
     buttonHeight=59
}
