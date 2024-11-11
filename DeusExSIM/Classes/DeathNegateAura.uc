//=============================================================================
// DeathNegateAura.
//=============================================================================
class DeathNegateAura extends VMDFakeBuffAura;

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	MyVMP = VMDBufferPlayer(Owner);
	if (MyVMP != None)
	{
		Charge = MyVMP.NegateDeathCooldown * 40;
	}
	
	if (GetCurrentCharge() == 0.0)
	{
		UsedUp();
	}
}

defaultproperties
{
     Charge=4800
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/31/22: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconDeathNegate'
}
