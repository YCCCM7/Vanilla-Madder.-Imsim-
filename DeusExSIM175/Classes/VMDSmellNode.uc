//=============================================================================
// VMDSmellNode.
//=============================================================================
class VMDSmellNode extends VMDBufferDeco;

var float VerticalMitigationFactor;
var string SmellType;
var VMDSmellManager SmellOwner;

singular function Touch( actor Other )
{
 	local int i;
 	
 	if ((VMDBufferPawn(Other) != None) && (SmellType != "") && (SmellOwner != None) && (SmellOwner.bSmellActive))
 	{
  		for (i=0; i<8; i++)
  		{
   			if (VMDBufferPawn(Other).SmellTypes[i] ~= SmellType)
   			{
    				VMDBufferPawn(Other).LastSmellType = SmellType;
    				VMDBufferPawn(Other).HandleSmell('Smell', EAISTATE_Begin, FirstPlayer());
    				break;
   			}
  		}
 	}
}

function SignalPositionChanged()
{
 	local VMDBufferPawn VMBP;
 	local int i;
 	
 	if ((SmellType != "") && (SmellOwner != None) && (SmellOwner.bSmellActive))
 	{
  		forEach RadiusActors(class'VMDBufferPawn', VMBP, CollisionRadius, Location)
  		{
   			if ((VMBP != None) && ((VMBP.Location.Z - Location.Z) < CollisionRadius / VerticalMitigationFactor))
   			{
    				for (i=0; i<8; i++)
    				{
     					if (VMBP.SmellTypes[i] ~= SmellType)
     					{
      						VMBP.LastSmellType = SmellType;
      						VMBP.HandleSmell('Smell', EAISTATE_Begin, FirstPlayer());
     					}
    				}
   			}
  		}
 	}
}

/*function Tick(float DT)
{
 	local VMDBufferPawn VMBP;
 	local int i;
 	
 	if ((SmellType != "") && (Frand() < 0.2) && (SmellOwner != None) && (SmellOwner.bSmellActive))
 	{
  		forEach TouchingActors(class'VMDBufferPawn', VMBP)
  		{
   			for (i=0; i<8; i++)
   			{
   				if (VMBP.SmellTypes[i] ~= SmellType)
    				{
     					VMBP.LastSmellType = SmellType;
     					VMBP.HandleSmell('Smell', EAISTATE_Begin, FirstPlayer());
    				}
   			}
  		}
 	}
}*/

function VMDBufferPlayer FirstPlayer()
{
 	local VMDBufferPlayer VMP;
 	
 	forEach AllActors(class'VMDBufferPlayer', VMP) break;
 	return VMP;
}

//MADDERS, 3/18/21: Ha-ha... NO.
singular function DripWater(float deltaTime)
{
}

//MADDERS, 0/12/25: Don't play landed sounds.
function Landed(vector HitNormal)
{
}

defaultproperties
{
     bHidden=True
     bAlwaysRelevant=True
     bInvincible=True
     
     VerticalMitigationFactor=2.500000
     CollisionHeight=0.000000
     CollisionRadius=0.000000
     Physics=PHYS_None
     
     bBlockActors=False
     bBlockPlayers=False
     bCollideActors=False
     bProjTarget=False
     bCollideWorld=False
     
     bPushable=False
}
