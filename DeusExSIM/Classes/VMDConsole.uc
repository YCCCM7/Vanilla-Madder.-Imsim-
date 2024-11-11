//=============================================================================
// VMDConsole: Custom load shit, thanks.
//=============================================================================
class VMDConsole extends Console
	transient;

var bool bExpandingLadders;
var localized string ExpandingPathsMessage;

function DrawLevelAction( canvas C )
{
	local string BigMessage;
	
	// DEUS_EX AJY - don't want to print any text 
	// if the game is paused because we're in a menu
	if (Viewport.Actor.bShowMenu )
	{
		BigMessage = "";
		return;
	}
	if ( (Viewport.Actor.Level.Pauser != "") && (Viewport.Actor.Level.LevelAction == LEVACT_None) )
	{
		C.Font = C.BigFont;
		C.Style = 1;
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;

		BigMessage = PausedMessage; // Add pauser name?
		PrintActionMessage(C, BigMessage);
		return;
	}
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Loading )
		BigMessage = LoadingMessage;
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Saving )
		BigMessage = SavingMessage;
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Connecting )
		BigMessage = ConnectingMessage;
	else if ( Viewport.Actor.Level.LevelAction == LEVACT_Precaching )
		BigMessage = PrecachingMessage;
	else if ( bExpandingLadders )
		BigMessage = ExpandingPathsMessage;
	
	if ( BigMessage != "" )
	{
		C.Style = 3;
		C.DrawColor.R = 0;
		C.DrawColor.G = 0;
		C.DrawColor.B = 255;
		C.Font = C.LargeFont;	
		PrintActionMessage(C, BigMessage);
	}
}

defaultproperties
{
     ExpandingPathsMessage="Expanding Paths..."
}
