//=============================================================================
// HUDActiveAug
//=============================================================================

class HUDActiveAug extends HUDActiveItemBase;

var Color colBlack;
var Color colAugActive;
var Color colAugInactive;

var int    hotKeyNum;
var String hotKeyString;

//MADDERS: Our other colors, for disabled/enabled
var Color ColAugEnabled, ColAugDisabled;

// ----------------------------------------------------------------------
// DrawHotKey()
// ----------------------------------------------------------------------

function DrawHotKey(GC gc)
{
	gc.SetAlignments(HALIGN_Right, VALIGN_Top);
	gc.SetFont(Font'FontTiny');
	
	// Draw Dropshadow
	gc.SetTextColor(colBlack);
	gc.DrawText(16, 1, 15, 8, hotKeyString);

	// Draw Dropshadow
	gc.SetTextColor(colText);
	gc.DrawText(17, 0, 15, 8, hotKeyString);
}

// ----------------------------------------------------------------------
// SetObject()
//
// Had to write this because SetClientObject() is FINAL in Extension
// ----------------------------------------------------------------------

function SetObject(object newClientObject)
{
	if (newClientObject.IsA('Augmentation'))
	{
		// Get the function key and set the text
		SetKeyNum(Augmentation(newClientObject).GetHotKey());
		UpdateAugIconStatus();
	}
}

// ----------------------------------------------------------------------
// SetKeyNum()
// ----------------------------------------------------------------------

function SetKeyNum(int newNumber)
{
	// Get the function key and set the text
	hotKeyNum    = newNumber;
	hotKeyString = "F" $ String(hotKeyNum);
}

// ----------------------------------------------------------------------
// UpdateAugIconStatus()
// ----------------------------------------------------------------------

function UpdateAugIconStatus()
{
	local Augmentation aug;
	local VMDBufferAugmentation VMA;
	
	aug = Augmentation(GetClientObject());
	VMA = VMDBufferAugmentation(Aug);
	
	if (aug != None)
	{
		if ((VMA != None) && (VMA.bPassive))
		{
			if (VMA.bDisabled)
			{
				ColItemIcon = ColAugDisabled;
			}
			else
			{
				ColItemIcon = ColAugEnabled;
			}
		}
		else
		{
			if (aug.IsActive())
			{
				colItemIcon = colAugActive;
			}
			else
			{
				colItemIcon = colAugInactive;
			}
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     //MADDERS additions.
     ColAugEnabled=(R=192,G=255,B=96)
     ColAugDisabled=(R=255,G=96,B=96)
     
     colAugActive=(R=255,G=255)
     colAugInactive=(R=100,G=100,B=100)
     colItemIcon=(B=0)
}
