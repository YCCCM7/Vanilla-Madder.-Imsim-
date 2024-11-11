//=============================================================================
// FireAura.
//=============================================================================
class FireAura extends VMDFakeBuffAura;

var travel float BurnTime;

function ChargedPickupBegin(DeusExPlayer DXP)
{
	UpdateBurnTime();
	
	Super.ChargedPickupBegin(DXP);
}

simulated function Float GetCurrentCharge()
{
	if (MyVMP != None)
	{
		return 100 * (1.0 - (MyVMP.BurnTimer / (BurnTime)));
	}
	return 100.0;
}

function UpdateBurnTime()
{
	if ( Level.NetMode != NM_Standalone )
	{
		burnTime = Class'WeaponFlamethrower'.Default.mpBurnTime;
	}
	else
	{
		burnTime = Class'WeaponFlamethrower'.Default.BurnTime;
	}
}

function TravelPostAccept()
{
	UpdateBurnTime();
	
	Super.TravelPostAccept();
	
	if (GetCurrentCharge() == 0.0)
	{
		UsedUp();
	}
}

defaultproperties
{
     Charge=9999
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/31/22: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconFire'
}
