//=============================================================================
// HUDActiveSmell
//=============================================================================
class HUDActiveSmell extends HUDActiveItemBase;

var Color colBlack;
var Color colSmellActive;
var Color colSmellInactive;

var String SmellType, PlayerSmellType;

function string TranslateSmellType(string S)
{
	switch(CAPS(S))
	{
		case "PLAYERSMELL":
			return "Odor";
		break;
		case "PLAYERANIMALSMELL":
			return "Dog Odor";
		break;
		case "PLAYERFOODSMELL":
			return "Small Food";
		break;
		case "STRONGPLAYERFOODSMELL":
			return "Large Food";
		break;
		case "PLAYERBLOODSMELL":
			return "Blood";
		break;
		case "STRONGPLAYERBLOODSMELL":
			return "Large Blood";
		break;
	}
	
	return "ERR";
}

// ----------------------------------------------------------------------
// DrawHotKey()
// ----------------------------------------------------------------------

function DrawHotKey(GC gc)
{
	local VMDSmellManager Smell;
	
	Smell = VMDSmellManager(GetClientObject());
	
	if (Smell != None)
	{
		if (Smell.bSmellActive)
		{
			gc.SetAlignments(HALIGN_Right, VALIGN_Top);
			gc.SetFont(Font'FontTiny');
			
			// Draw Dropshadow
			gc.SetTextColor(colBlack);
			gc.DrawText(16, 1, 15, 8, PlayerSmellType);
			
			// Draw Dropshadow
			gc.SetTextColor(colText);
			gc.DrawText(17, 0, 15, 8, PlayerSmellType);
		}
	}
}

// ----------------------------------------------------------------------
// SetObject()
//
// Had to write this because SetClientObject() is FINAL in Extension
// ----------------------------------------------------------------------

function SetObject(object newClientObject)
{
	if (newClientObject.IsA('VMDSmellManager'))
	{
		// Get the function key and set the text
		SetSmellType(VMDSmellManager(newClientObject).SmellType);
		UpdateSmellIconStatus();
	}
}

// ----------------------------------------------------------------------
// SetSmellType()
// ----------------------------------------------------------------------

function SetSmellType(String NewSmell)
{
	//Set the smell and player equivalent.
	SmellType = NewSmell;
	PlayerSmellType = TranslateSmellType(NewSmell);
}

// ----------------------------------------------------------------------
// UpdateSmellIconStatus()
// ----------------------------------------------------------------------

function UpdateSmellIconStatus()
{
	local VMDSmellManager Smell;
	
	Smell = VMDSmellManager(GetClientObject());
	
	if (Smell != None)
	{
		if (Smell.bSmellActive)
		{
			Show(True);
			colItemIcon = colSmellActive;
		}
		else
		{
			colItemIcon = colSmellInActive;
			Show(False);
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     colSmellActive=(R=255,G=255)
     colSmellInactive=(R=100,G=100,B=100)
     colItemIcon=(B=0)
}
