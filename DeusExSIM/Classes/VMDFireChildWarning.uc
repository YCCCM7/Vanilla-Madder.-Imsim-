//=============================================================================
// VMDFireChildWarning.
// A hack so AI stop running into us.
//=============================================================================
class VMDFireChildWarning extends Cloud;

function Timer()
{
}

defaultproperties
{
     CollisionRadius=20.000000 //Default pawn collision size
     DamageType=Flamed
     bHidden=True
     LifeSpan=0.000000
}
