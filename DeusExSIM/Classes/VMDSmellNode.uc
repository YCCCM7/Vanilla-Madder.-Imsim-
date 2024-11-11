//=============================================================================
// VMDSmellNode.
//=============================================================================
class VMDSmellNode extends VMDBufferDeco;

var float VerticalMitigationFactor, TouchRefreshTimer;
var name SmellType;
var VMDSmellManager SmellOwner;

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (TouchRefreshTimer > 0)
	{
		TouchRefreshTimer -= DT;
	}
	else
	{
		CheckTouchList();
		TouchRefreshTimer = 0.25;
	}
}

singular function Touch( actor Other )
{
	local bool bHeightTraceWin, bTraceWin, bTraceWin2;
	local int i, TraceWins;
	local float EffectiveRange, TraceDist, SmellCap;
	local vector StartTrace, StartTrace2, EndTrace, EndTrace2;
	local Rotator TRot;
	local VMDBufferPawn VMBP;
	
	VMBP = VMDBufferPawn(Other);
	if ((VMBP != None) && (SmellType != '') && (SmellOwner != None) && (SmellOwner.bSmellActive))
	{
 		for (i=0; i<8; i++)
 		{
  			if (VMBP.SmellTypes[i] == SmellType)
  			{
				TraceWins = 0;
				
				EffectiveRange = CollisionRadius;
				StartTrace = VMBP.Location;
				StartTrace2 = VMBP.Location + Vect(0, 0, 32);
				SmellCap = 3.0;
				bTraceWin = FastTrace(StartTrace, StartTrace2);
				if (bTraceWin)
				{
					bHeightTraceWin = true;
					SmellCap = 6.0;
				}
				
				EndTrace = Location;
				bTraceWin = FastTrace(EndTrace, StartTrace);
				if (bTraceWin) TraceWins++;
				if (bHeightTraceWin)
				{
					EndTrace2 = EndTrace + Vect(0, 0, 32);
					bTraceWin2 = FastTrace(EndTrace2, StartTrace2);
					if (bTraceWin2) TraceWins++;
				}
				
				TraceDist = VSize(EndTrace - StartTrace);
				TRot = Rotator(EndTrace - StartTrace);
				TRot.Yaw += 8192;
				EndTrace = StartTrace + ((vect(1,0,0) * TraceDist) >> TRot);
				bTraceWin = FastTrace(EndTrace, StartTrace);
				if (bTraceWin) TraceWins++;
				if (bHeightTraceWin)
				{
					EndTrace2 = EndTrace + Vect(0, 0, 32);
					bTraceWin2 = FastTrace(EndTrace2, StartTrace2);
					if (bTraceWin2) TraceWins++;
				}
				
				TRot = Rotator(EndTrace - StartTrace);
				TRot.Yaw -= 8192;
				EndTrace = StartTrace + ((vect(1,0,0) * TraceDist) >> TRot);
				bTraceWin = FastTrace(EndTrace, StartTrace);
				if (bTraceWin) TraceWins++;
				if (bHeightTraceWin)
				{
					EndTrace2 = EndTrace + Vect(0, 0, 32);
					bTraceWin2 = FastTrace(EndTrace2, StartTrace2);
					if (bTraceWin2) TraceWins++;
				}
				
				EffectiveRange *= (float(TraceWins) / SmellCap);
				if (VSize(VMBP.Location - Location) < EffectiveRange * 1.2)
				{
   					VMBP.LastSmellType = SmellType;
   					VMBP.HandleSmell('Smell', EAISTATE_Begin, FirstPlayer());
 				}
  				break;
  			}
 		}
	}
}

function CheckTouchList()
{
	local int i;
	
	for (i=0;i<4;i++)
	{
		if (Touching[i] != None)
		{
			Touch(Touching[i]);
		}
	}
}

function SignalPositionChanged()
{
 	local VMDBufferPawn VMBP;
 	local int i;
 	
 	if ((SmellType != '') && (SmellOwner != None) && (SmellOwner.bSmellActive))
 	{
  		forEach RadiusActors(class'VMDBufferPawn', VMBP, CollisionRadius, Location)
  		{
   			if ((VMBP != None) && ((VMBP.Location.Z - Location.Z) < CollisionRadius / VerticalMitigationFactor))
   			{
    				Touch(VMBP);
   			}
  		}
 	}
}

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

defaultproperties
{
     bHidden=True
     bAlwaysRelevant=True
     
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
