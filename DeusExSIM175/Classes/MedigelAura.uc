//=============================================================================
// MedigelAura.
//=============================================================================
class MedigelAura extends VMDFakeBuffAura;

var int NumHeals;

function VMDFakeAuraTimerHook(bool bWhole)
{
	local DeusExPlayer DXP;
	
	if (bWhole)
	{
		DXP = DeusExPlayer(Owner);
		if (DXP != None)
		{
			if (NumHeals < 3)
			{
				DXP.HealPlayer(19, False);
			}
			else
			{
				DXP.HealPlayer(18, False);
			}
			NumHeals++;
		}
	}
	
	Super.VMDFakeAuraTimerHook(bWhole);
}

defaultproperties
{
     Charge=160
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 5/17/22: No sound needed.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconMedigel'
}
