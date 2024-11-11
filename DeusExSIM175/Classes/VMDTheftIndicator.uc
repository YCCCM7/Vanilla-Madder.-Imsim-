//=============================================================================
// Another hand-me-down.
//=============================================================================
class VMDTheftIndicator extends VMDFillerActors;

var VMDBufferPlayer Player;
var VMDBufferPawn Pawn;
var int NoiseLevel, AngerLevel;
var Name AngeredAlliance;

function bool GetPlayer()
{
	local VMDBufferPlayer VP;
	
	Pawn = VMDBufferPawn(Owner);
	
	forEach AllActors(Class'VMDBufferPlayer', VP)
	{
		if (VP != None)
	 	{
	  		Player = VP;
          		break;
	 	}
	}
	return ((VP != None) && (Pawn != None));
}

function InvokeCrime()
{
	if (GetPlayer())
	{
	 	//Player.AIStartEvent('LoudNoise', EAITYPE_Audio, 1.0, 128);
	 	//Pawn.AIStartEvent('Distress', EAITYPE_Audio, 1.0, 128);
         	AngeredAlliance = Pawn.Alliance;
	 	SetTimer(0.2, False);
	}
}

function InvokeRadialAnger()
{
 	local VMDBufferPawn VP;
 	
 	//Always enrage the offended party, and get them angry 2x as fast!
 	Pawn.IncreaseAgitation(Player, 1); 
 	
 	forEach RadiusActors(class'VMDBufferPawn', VP, 192)
 	{
  		if ((FastTrace(VP.Location)) && (VP.Alliance == AngeredAlliance))
  		{
   			VP.IncreaseAgitation(Player, 1);
  		}
 	}
}

function Timer()
{
	local int i;
	
	//Player.AIEndEvent('LoudNoise', EAITYPE_Audio);
	//Pawn.AIEndEvent('Distress', EAITYPE_Audio);
	
	Pawn.bDistressed = True;
	Pawn.EnemyLastSeen = 0;
	Pawn.SetDistressTimer();
	
	//Create some good ol' fashioned agitation!
	if (AngerLevel > 0)
	{
	 	for (i=0; i<AngerLevel; i++)
	 	{
	  		InvokeRadialAnger();
	 	}
	}
	
	//Make some noise, too!
	if (NoiseLevel > 0)
	{
	 	for (i=0; i<NoiseLevel; i++)
	 	{
	  		Player.AISendEvent('LoudNoise', EAITYPE_Audio, 10.0, 256);
	 	}
	}
	
	Pawn.AISendEvent('Distress', EAITYPE_Audio, 1.0, 256);
	
	Destroy();
}

defaultproperties
{
     bHidden=True
     NoiseLevel=1
     AngerLevel=3
}
