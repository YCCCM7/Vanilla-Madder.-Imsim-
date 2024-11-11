//=============================================================================
// DodgeRollCooldownAura.
//=============================================================================
class DodgeRollCooldownAura extends VMDFakeBuffAura;

function ChargedPickupBegin(DeusExPlayer DXP)
{
	UpdateAugmentStatus();
	
	Super.ChargedPickupBegin(DXP);
}

simulated function Float GetCurrentCharge()
{
	if (MyVMP != None)
	{
		return 100 * (MyVMP.DodgeRollCooldownTimer / (MyVMP.DodgeRollCooldown));
	}
	return 100.0;
}

function UpdateAugmentStatus()
{
}

defaultproperties
{
     Charge=400
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/31/22: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconDodgeRollCooldown'
}
