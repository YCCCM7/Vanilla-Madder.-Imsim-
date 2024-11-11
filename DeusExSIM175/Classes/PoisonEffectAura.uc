//=============================================================================
// PoisonEffectAura.
//=============================================================================
class PoisonEffectAura extends VMDFakeBuffAura;

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	Charge = MyVMP.PoisonCounter * 80;
	
	if (GetCurrentCharge() == 0.0)
	{
		UsedUp();
	}
}

defaultproperties
{
     Charge=320
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/31/22: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconPoisonEffect'
}
