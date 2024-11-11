//=============================================================================
// VMDVisibilityFlagTrigger.
//=============================================================================
class VMDVisibilityFlagTrigger extends FlagTrigger;

//Wowee, what a hack. Good thing this is (so far) a one-off trigger.
var() ScriptedPawn ReferencePawn;

//
// See whether the other actor is relevant to this trigger.
//
function bool IsRelevant(Actor Other)
{
	if (!bInitiallyActive)
		return false;
	
	// DEUS_EX STM -- added cheat
	if ((Other != None) && (!Other.bDetectable))
		return false;
	
	switch(TriggerType)
	{
		case TT_PlayerProximity:
			return ((Pawn(Other) != None) && (Pawn(Other).bIsPlayer) && (DeusExPlayer(Other) == None || ReferencePawn == None || DeusExPlayer(Other).CalculatePlayerVisibility(ReferencePawn) > 0.1));
		case TT_PawnProximity:
			return ((Pawn(Other) != None) && (Pawn(Other).Intelligence > BRAINS_None));
		case TT_ClassProximity:
			return ClassIsChildOf(Other.Class, ClassProximityType);
		case TT_AnyProximity:
			return true;
		case TT_Shoot:
			return ((Projectile(Other) != None) && (Projectile(Other).Damage >= DamageThreshold));
	}
}

defaultproperties
{
}
