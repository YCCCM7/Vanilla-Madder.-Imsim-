//=============================================================================
// VMDLadderPoint.
//=============================================================================
class VMDLadderPoint extends VMDTechnicalActors;

var() bool bForward, bBackward, bNextJump, bPreviousJump;
var() float JumpZMult;
var() Vector LadderNormal;
var() DeusExMover OpenMoverRequired;
var() VMDLadderPoint NextPoint, PreviousPoint, OppositePoint;

var bool bDebugLadders, bObjectToUse;
var VMDLadderDeathFlag LastDeathFlag;

function Tick(float DT)
{
	Super.Tick(DT);
	
	bObjectToUse = true;
	if (OpenMoverRequired == None || OpenMoverRequired.bDeleteMe || OpenMoverRequired.KeyNum > 0)
	{
		bObjectToUse = false;
	}
}

function AdvanceLadderSequence(VMDBufferPawn VMBP)
{
	local bool TForward, bJumped, bWillJump, bMyJump, bFutureJump;
	local Vector TLoc;
	local VMDLadderPoint TNext, TPrev, TNextNext;
	
	if ((VMBP != None) && (VMBP.Health > 0))
	{
		if (!VMBP.bClimbingLadder)
		{
			//Hack to stop ladder looping.
			if (VMBP.LastUsedLadder != Self)
			{
				VMBP.LastUsedLadder = OppositePoint;
			}
			else
			{
				VMBP.LastUsedLadder = None;
			}
			TForward = bForward;
			VMBP.bLadderClimbForward = TForward;
		}
		else
		{
			TForward = VMBP.bLadderClimbForward;
		}
		
		if (TForward)
		{
			TNext = NextPoint;
			if (TNext != None)
			{
				TNextNext = TNext.NextPoint;
				if (bNextJump)
				{
					bMyJump = true;
					bWillJump = true;
				}
				if (TNext.bNextJump)
				{
					bFutureJump = true;
					bWillJump = true;
				}
			}
			if (TPrev != None)
			{
				bJumped = TPrev.bNextJump;
			}
			TPrev = PreviousPoint;
		}
		else
		{
			TNext = PreviousPoint;
			if (TNext != None)
			{
				TNextNext = TNext.PreviousPoint;
				if (bPreviousJump)
				{
					bMyJump = true;
					bWillJump = true;
				}
				if (TNext.bPreviousJump)
				{
					bFutureJump = true;
					bWillJump = true;
				}
			}
			if (TPrev != None)
			{
				bJumped = TPrev.bPreviousJump;
			}
			TPrev = NextPoint;
		}
		
		VMBP.LastLadderPoint = Location;
		if (TNext == None)
		{
			VMBP.VMDClearLadderData();
			VMBP.DestPoint = None;
			
			if (VMBP.Region.Zone.bWaterZone)
			{
				VMBP.SetPhysics(PHYS_Swimming);
			}
			else
			{
				VMBP.SetPhysics(PHYS_Falling);
			}
			
			if (VMBP.IsInState('Attacking'))
			{
				VMBP.EnemyLastSeen = FMax(VMBP.EnemyLastSeen-0.25, 0.0);
				VMBP.GoToState('Attacking', 'Begin');
			}
			else
			{
				VMBP.GoToState('VMDClimbingLadder', 'End');
			}
		}
		else if (bWillJump)
		{
			VMBP.TargetedLadderPoint = TNext;
			VMBP.bClimbingLadder = true;
			VMBP.bLadderClimbForward = TForward;
			if (bMyJump)
			{
				VMBP.LadderJumpZMult = JumpZMult;
			}
			else
			{
				VMBP.LadderJumpZMult = TNext.JumpZMult;
			}
			
			if (TNextNext == None)
			{
				if (bDebugLadders)
				{
					BroadcastMessage("JUMPING FINAL TIME!");
				}
				
				if (VMBP.IsInState('Attacking'))
				{
					VMBP.GoToState('Attacking', 'JumpLastLadder');
				}
				else
				{
					VMBP.GoToState('VMDClimbingLadder', 'JumpLastLadder');
				}
			}
			else
			{
				if (bDebugLadders)
				{
					BroadcastMessage("JUMPING!");
				}
				
				if (VMBP.IsInState('Attacking'))
				{
					VMBP.GoToState('Attacking', 'JumpLadder');
				}
				else
				{
					VMBP.GoToState('VMDClimbingLadder', 'JumpLadder');
				}
			}
		}
		else
		{
			if (bDebugLadders)
			{
				BroadcastMessage("CLIMBING"@Self@TNext);
			}
			VMBP.LadderJumpZMult = 1.0;
			VMBP.TargetedLadderPoint = TNext;
			if (VMBP.Region.Zone.bWaterZone)
			{
				VMBP.SetPhysics(PHYS_Swimming);
			}
			else
			{
				VMBP.SetPhysics(PHYS_Falling);
			}
			VMBP.bJumpedFromLadder = false;
			VMBP.bClimbingLadder = true;
			
			if (VMBP.IsInState('Attacking'))
			{
				VMBP.GoToState('Attacking', 'ClimbLadder');
			}
			else
			{
				VMBP.GoToState('VMDClimbingLadder', 'ClimbLadder');
			}
		}
	}
}

defaultproperties
{
     bCollideActors=True
     bCollideWhenPlacing=True
     CollisionRadius=20.000000
     CollisionHeight=48.000000
     
     bUnlit=True
     Texture=Texture'VMDPatrolPointer'
     DrawScale=0.250000
     bStatic=False
     bHidden=True
}
