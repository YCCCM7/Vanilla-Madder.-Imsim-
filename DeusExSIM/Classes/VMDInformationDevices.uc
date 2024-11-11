//=============================================================================
// VMDInformationDevices.
//=============================================================================
class VMDInformationDevices extends VMDBufferDeco
          abstract;

//MADDERS: Huge shout out to my boi Atrey on developing this for me in the day.
//This is some really fantastic tech.

var String textHeader; //Without this, the text is just one long line...
var() string text; //The device's information text, what you want the player to know.
var int ScreenHeight; //used for calculating the window size and location

var transient HUDSharedBorderWindow winTile; // Window to display the information in
var transient TextWindow winText;				// Last text window we added
var transient TextWindow winTextTitle;         //This makes multiple lines in the text.
var() Bool bAddToDataVault;					// Do we need to add this text to the DataVault?
var DeusExPlayer aReader;				// who is reading this?
var() String msgNoText; //If there is no text on the device, let the player know.

// ----------------------------------------------------------------------
// Destroyed()
//
// If the item is destroyed, make sure we also destroy the window
// if it happens to be visible!
// ----------------------------------------------------------------------

function Destroyed()
{
	DestroyWindow();
	
	Super.Destroyed();
}

// ----------------------------------------------------------------------
// DestroyWindow()
// ----------------------------------------------------------------------

function DestroyWindow()
{
	// restore the crosshairs and the other hud elements
	if (aReader != None)
	{
		DeusExRootWindow(aReader.rootWindow).hud.cross.SetCrosshair(aReader.bCrosshairVisible);
		DeusExRootWindow(aReader.rootWindow).hud.frobDisplay.Show();
	}
	
	if (winTile != None)
		winTile.Hide();
	
    	winTile = None;
	winText.SetText("");
	winTextTitle.SetText("");
	winTextTitle = None;
	winText = None;
	aReader = None;
}

// ----------------------------------------------------------------------
// Tick()
//
// Only display the window while the player is in front of the object
// ----------------------------------------------------------------------

function Tick(float deltaTime)
{
	// if the reader strays too far from the object, kill the text window
	if ((aReader != None) && (winTile !=None))
		if (aReader.FrobTarget != Self)
			DestroyWindow();
}

// ----------------------------------------------------------------------
// Frob()
// ----------------------------------------------------------------------

function Frob(Actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
	
	//Super.Frob(Frobber, frobWith);
	
	player = DeusExPlayer(Frobber);
	
	if (player != None)
	{
		if (winTile == None)
		{
       			DeusExRootWindow(areader.rootWindow).hud.cross.SetCrosshair(False);
	   		DeusExRootWindow(areader.rootWindow).hud.frobDisplay.Hide();
			aReader = player;
			
	  		if  (text == "")
			{
				areader.ClientMessage(msgNoText);
				DestroyWindow();
				return;
			}
			else
		    		CreateInfoWindow();
        	}
	}
}

// ----------------------------------------------------------------------
// CreateInfoWindow()
// ----------------------------------------------------------------------

function CreateInfoWindow()
{
	local DeusExRootWindow rootWindow;
    	
    	rootWindow = DeusExRootWindow(areader.rootWindow);
    	
    	winText = TextWindow(rootWindow.NewChild(class'TextWindow', True));
    	winTextTitle = TextWindow(rootWindow.NewChild(class'TextWindow', True));
    	winTile = HUDSharedBorderWindow(rootWindow.NewChild(class'HUDSharedBorderWindow',True));
    	
     	if (winTile != None)
      	{
       		winTile.InitWindow();
       		
     		if (winText != None)
     		{
      			winText.InitWindow();
      			winText.SetText("|p1"$textheader$WinText.CR()$"|cdfdfdf"$text);
      			winText.SetTextAlignments(HALIGN_Center,VALIGN_Center);
      			winText.SetWordWrap(True);
      			winText.SetFont(Font'FontMenuSmall_DS');
      			winText.SetLines(1,3);
      			winText.SetPos(610,270);
     		}      
     		
     		if (winTextTitle != None)
     		{
      			winTextTitle.InitWindow();
      			winTextTitle.SetText(""); //$TextHeader
      			winTextTitle.SetTextAlignments(HALIGN_Center,VALIGN_Center);
      			winText.SetSize(200,350);
      			winTextTitle.SetWordWrap(true);
			//winTextTitle.SetFont(Font'FontMenuSmall_DS');
      			winTextTitle.SetLines(1,10);
      			winTextTitle.SetPos(500,100);
     		} 
       		
     		if (bAddToDataVault)
      		{
       			bAddToDataVault = False;
       			aReader.NoteAdd(text);
			areader.ClientMessage("Notes Recieved - Check Datavault for Details.");
			DeusExRootWindow(areader.rootWindow).hud.msgLog.PlayLogSound(Sound'LogNoteAdded');              
       		}      
		
		//Since the HUDSharedBorder Window is kinda screwy, I gotta do all these
		//calculations to try and keep everything centered.
    		
    		if  (winText.GetTextLength() < 40 )
        		screenHeight = 50; 
        	
    		if  (winText.GetTextLength() > 40 )
        		screenHeight = 70;     
		
    		if  (winText.GetTextLength() > 80 )
        		screenHeight = 90;
   		
    		if  (winText.GetTextLength() > 120 )
        		screenHeight = 120;                              
            	
    		winTile.SetSize(300,screenHeight); 
    		
   		if  (winText.GetTextLength() < 119 )
       			winTile.SetPos(555,415);  
   		else
       			winTile.SetPos(555,385);                       
      	}
}

defaultproperties
{
     bInvincible=True
     bPushable=False
}
