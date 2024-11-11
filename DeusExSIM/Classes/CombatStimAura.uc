//=============================================================================
// CombatStimAura.
//=============================================================================
class CombatStimAura extends VMDFakeBuffAura;

function UsedUp()
{
	local DeusExPlayer DXP;
	local VMDBufferPawn VMBP;
	
	DXP = DeusExPlayer(Owner);
	VMBP = VMDBufferPawn(Owner);
	if (DXP != None)
	{
		DXP.TakeDamage(Max(15, DXP.HealthTorso/6), DXP, DXP.Location, Vect(0,0,0), 'DrugDamage');
	}
	else if (VMBP != None)
	{
		VMBP.TakeDamage(Max(15, VMBP.HealthTorso/6), VMBP, VMBP.Location, Vect(0,0,0), 'DrugDamage');
		VMBP.VMDUpdateGroundSpeedBuoyancy();
	}
	
	Super.UsedUp();
}

//Latent control over this as well.
function VMDFakeAuraTimerHook(bool bWhole)
{
	local int TLap;
	
	if ((bWhole) && (Charge > 320))
	{
		if ((MyVMP != None) && (MyVMP.DrugEffectTimer > 0))
		{
			MyVMP.DrugEffectTimer = 0;
		}
	}
}

defaultproperties
{
     Charge=1000
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/17/22: Add a sound later?
     LoopSound=None
     ChargedIcon=Texture'ChargedIconCombatStim'
}
