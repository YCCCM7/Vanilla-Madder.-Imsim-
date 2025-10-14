//=============================================================================
// DestroyOtherTrigger.
//=============================================================================
class DestroyOtherTrigger extends Trigger;

var Actor DestructionTarget;

// Sends an UnTrigger event when touched or triggered
// Set bCollideActors to False to make it triggered

function Trigger(Actor Other, Pawn Instigator)
{
	if (DestructionTarget != None)
	{
		DestructionTarget.Destroy();
	}
}

function Touch(Actor Other)
{
	if (DestructionTarget != None)
	{
		DestructionTarget.Destroy();
	}
}

defaultproperties
{
     bStatic=False
     bCollideActors=False
     bTriggerOnceOnly=True
}
