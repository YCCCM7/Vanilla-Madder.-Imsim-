//=============================================================================
// CigarettesBuffAura.
//=============================================================================
class CigarettesBuffAura extends VMDFakeBuffAura;

//--------------------
//MADDERS, 1/30/21: We reduce damage as a very hacky "aura" of sorts.
function float VMDConfigurePickupDamageMult(name DT)
{
	local float Ret;
	
	//Emergency mega failsafe.
	if (Charge <= 0)
	{
		Destroy();
		return 1.0;
	}
	
	Ret = 1.0;
	switch(DT)
	{
		//We're not good at breathing now.
		case 'HalonGas':
		case 'TearGas':
		case 'PoisonGas':
		case 'DrugDamage':
			Ret = 2.0;
		break;
		//Everything else? Nah brah.
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

//Latent control over this as well.
function VMDFakeAuraTimerHook(bool bWhole)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if ((bWhole) && (VMP != None))
	{
		VMP.VMDModPlayerStress(-3,,,true);
	}
}

defaultproperties
{
     Charge=800
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 1/30/21: No sound, as we start with a select sound queue, IE cig usage.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconCigarettes'
}
