//=============================================================================
// DeusExLog
//=============================================================================
class DeusExLog extends Object
	native;

var String text;		// Log msg stored here.
var DeusExLog next;		// Next note

// ----------------------------------------------------------------------
// SetLogText()
// ----------------------------------------------------------------------

function SetLogText( String newLogText )
{
	text = newLogText;
}

defaultproperties
{
}
