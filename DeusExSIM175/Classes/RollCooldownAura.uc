//=============================================================================
// RollCooldownAura.
//=============================================================================
class RollCooldownAura extends VMDFakeBuffAura;

var bool bHasAugment;

function ChargedPickupBegin(DeusExPlayer DXP)
{
	UpdateAugmentStatus();
	
	Super.ChargedPickupBegin(DXP);
}

simulated function Float GetCurrentCharge()
{
	local float TMult;
	
	if (MyVMP != None)
	{
		TMult = 1.0;
		if (bHasAugment) TMult = 0.75;
		
		return 100 * (MyVMP.RollCooldownTimer / (MyVMP.RollCooldown * TMult));
	}
	return 100.0;
}

function UpdateAugmentStatus()
{
	if (MyVMP != None)
	{
		bHasAugment = MyVMP.HasSkillAugment("SwimmingFitness");
	}
}

defaultproperties
{
     Charge=450
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/31/22: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconRollCooldown'
}
