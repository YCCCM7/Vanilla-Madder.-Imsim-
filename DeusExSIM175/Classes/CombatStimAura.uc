//=============================================================================
// CombatStimAura.
//=============================================================================
class CombatStimAura extends VMDFakeBuffAura;

function UsedUp()
{
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(Owner);
	if (DXP != None)
	{
		DXP.TakeDamage(Max(15, DXP.HealthTorso/6), DXP, DXP.Location, Vect(0,0,0), 'DrugDamage');
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
