//=============================================================================
// VMDHUDSmellIcons
//=============================================================================
class VMDHUDSmellIcons expands HUDBaseWindow;

var VMDBufferPlayer player;
var int OffsetsX[8];
var int SmellActive[8];
var texture SmellIcons[8];
var float IconUpdateTimer, SmellsUpdateRate;

// ----------------------------------------------------------------------
// InitWindow()
// ----------------------------------------------------------------------

event InitWindow()
{
	Super(HUDBaseWindow).InitWindow();
	
	bTickEnabled = TRUE;
	
	player = VMDBufferPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
	
	SetSize(160, 134);
	
	SetPos(0, 73);
}

function Tick(float DT)
{
	local VMDSmellManager Cur;
	
	if (Player == None) Player = VMDBufferPlayer(DeusExRootWindow(GetRootWindow()).parentPawn);
	
	if (IconUpdateTimer > 0)
	{
	 	IconUpdateTimer -= DT;
	}
	if (IconUpdateTimer <= 0)
	{
	 	IconUpdateTimer = SmellsUpdateRate;
	 	if (Player != None)
	 	{
	  		//Player Smell
	  		Cur = Player.PlayerSmellNode;
          		if ((Cur != None) && (Cur.bSmellActive))
	  		{
	   			SmellActive[0] = 1;
	   			SmellIcons[0] = Cur.Icon;
	  		}
	  		else SmellActive[0] = 0;
			
	  		//Player Animal Smell
	  		Cur = Player.PlayerAnimalSmellNode;
          		if ((Cur != None) && (Cur.bSmellActive))
	  		{
	   			SmellActive[1] = 1;
	   			SmellIcons[1] = Cur.Icon;
	  		}
	  		else SmellActive[1] = 0;
			
	  		//Player Food Smell
	  		Cur = Player.PlayerFoodSmellNode;
          		if ((Cur != None) && (Cur.bSmellActive))
	  		{
	   			SmellActive[2] = 1;
	   			SmellIcons[2] = Cur.Icon;
	  		}
	  		else SmellActive[2] = 0;
			
	  		//Strong Player Food Smell
	  		Cur = Player.StrongPlayerFoodSmellNode;
          		if ((Cur != None) && (Cur.bSmellActive))
	  		{
	   			SmellActive[3] = 1;
	   			SmellIcons[3] = Cur.Icon;
	  		}
	  		else SmellActive[3] = 0;
			
	  		//Player Blood Smell
	  		Cur = Player.PlayerBloodSmellNode;
          		if ((Cur != None) && (Cur.bSmellActive))
	  		{
	   			SmellActive[4] = 1;
	   			SmellIcons[4] = Cur.Icon;
	  		}
	  		else SmellActive[4] = 0;
			
	  		//Strong Player Blood Smell
	  		Cur = Player.StrongPlayerBloodSmellNode;
          		if ((Cur != None) && (Cur.bSmellActive))
	  		{
	   			SmellActive[5] = 1;
	   			SmellIcons[5] = Cur.Icon;
	  		}
	  		else SmellActive[5] = 0;
         	}
	}
}

// ----------------------------------------------------------------------
// DrawWindow()
// ----------------------------------------------------------------------

event DrawWindow(GC gc)
{
	Super(HUDBaseWindow).DrawWindow(gc);
}

// ----------------------------------------------------------------------
// DrawBackground()
// ----------------------------------------------------------------------

function DrawBackground(GC gc)
{
	local int T, i;
	
	gc.SetStyle(backgroundDrawStyle);
	gc.SetTileColor(colBackground);
	
	for (i=0; i<8; i++)
	{
	 if ((SmellActive[i] > 0) && (SmellIcons[i] != None))
	 {
	  gc.DrawTexture(OffsetsX[i], 77, 42, 42, 0, 0, SmellIcons[i]);
	 }
	}
}

// ----------------------------------------------------------------------
// DrawBorder()
// ----------------------------------------------------------------------

/*function DrawBorder(GC gc)
{
}

// ----------------------------------------------------------------------
// SetVisibility()
// ----------------------------------------------------------------------

function SetVisibility( bool bNewVisibility )
{
	bVisible = bNewVisibility;
}*/

event StyleChanged()
{
		backgroundDrawStyle = DSTY_Masked;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
 SmellsUpdateRate=0.750000
 OffsetsX(0)=4
 OffsetsX(1)=4
 OffsetsX(2)=34
 OffsetsX(3)=59
 OffsetsX(4)=84
 OffsetsX(5)=109
}
