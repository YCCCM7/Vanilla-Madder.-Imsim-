//=============================================================================
// HUDMedBotAugItemButton
//=============================================================================
class HUDMedBotAugItemButton extends PersonaItemButton;

//Modified -- Y|yukichigai

var AugmentationCannister augCan;

var bool bSlotFull;
var bool bHasIt;

var Color colBorder;
var Color colIconDisabled;
var Color colIconNormal;

//MADDERS, 8/16/23: New colors for better visual information.
var Color ColIconReplace, ColIconUpgrade;

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	local Augmentation anAug;

	anAug = GetAugmentation();
	//Only renders the icon disabled if the slot is full, not if you already have it
	
	//if ((bSlotFull) || (bHasIt))	
	//	colIcon = colIconDisabled;
	//else
	if (bSlotFull)
	{
		if (bHasIt)
		{
			colIcon = colIconDisabled;
		}
		else
		{
			ColIcon = ColIconReplace;
		}
	}
	else if (!bHasIt || anAug.CurrentLevel < anAug.MaxLevel)
	{
		if (!bHasIt)
		{
			colIcon = colIconNormal;
		}
		else
		{
			ColIcon = ColIconUpgrade;
		}
	}
	else
	{
		colIcon = colIconDisabled;
	}
	
	Super.DrawWindow(gc);

	// Draw selection border
	if (!bSelected)
	{
		gc.SetTileColor(colBorder);
		gc.SetStyle(DSTY_Masked);
		gc.DrawBorders(0, 0, borderWidth, borderHeight, 0, 0, 0, 0, texBorders);
	}
}

// ----------------------------------------------------------------------
// SetAugmentation()
// ----------------------------------------------------------------------

function SetAugmentation(Augmentation newAug)
{
	SetClientObject(newAug);
	SetIcon(newAug.smallIcon);

	// First check to see if the player already has this augmentation
	bHasIt = newAug.bHasIt;

	// Now check to see if this augmentation slot is full
	bSlotFull = player.AugmentationSystem.AreSlotsFull(newAug);
}

// ----------------------------------------------------------------------
// SetAugCan()
// ----------------------------------------------------------------------

function SetAugCan(AugmentationCannister newAugCan)
{
	augCan = newAugCan;
}

// ----------------------------------------------------------------------
// GetAugCan()
// ----------------------------------------------------------------------

function AugmentationCannister GetAugCan()
{
	return augCan;
}

// ----------------------------------------------------------------------
// GetAugmentation()
// ----------------------------------------------------------------------

function Augmentation GetAugmentation()
{
	return Augmentation(GetClientObject());
}

// ----------------------------------------------------------------------
// GetAugDesc()
// ----------------------------------------------------------------------

function String GetAugDesc()
{
	if (GetClientObject() != None)
		return Augmentation(GetClientObject()).augmentationName;
	else
		return "";
}

// ----------------------------------------------------------------------
// StyleChanged()
// ----------------------------------------------------------------------

event StyleChanged()
{
	local ColorTheme theme;

	Super.StyleChanged();

	colBorder.r = Int(Float(colBackground.r) * 0.75);
	colBorder.g = Int(Float(colBackground.g) * 0.75);
	colBorder.b = Int(Float(colBackground.b) * 0.75);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     ColIconReplace=(R=182,G=56,B=182)
     ColIconUpgrade=(R=30,G=208,B=44)
     
     colIconDisabled=(R=64,G=64,B=64)
     colIconNormal=(R=255,G=255)
     iconPosWidth=32
     iconPosHeight=32
     buttonWidth=34
     buttonHeight=34
     borderWidth=34
     borderHeight=34
}
