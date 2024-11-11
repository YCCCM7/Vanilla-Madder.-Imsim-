//=============================================================================
// DrunkEffectAura.
//=============================================================================
class DrunkEffectAura extends VMDFakeBuffAura;

function ChargedPickupBegin(DeusExPlayer DXP)
{
	Charge = DXP.DrugEffectTimer*40.0;
	
	Super.ChargedPickupBegin(DXP);
}

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	Charge = (MyVMP.DrugEffectTimer)*40.0;
	
	if (GetCurrentCharge() <= 0.0)
	{
		UsedUp();
	}
}

simulated function Float GetCurrentCharge()
{
	if (MyVMP != None)
	{
		return FMin(100.0, 100.0 * (MyVMP.DrugEffectTimer / 30.0));
	}
	return 100.0;
}

defaultproperties
{
     Charge=320
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/31/22: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconDrunkEffect'
}
