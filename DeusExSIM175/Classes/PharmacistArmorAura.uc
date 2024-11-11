//=============================================================================
// PharmacistArmorAura.
//=============================================================================
class PharmacistArmorAura extends VMDFakeBuffAura;

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
		//Reduce these heavily.
		case 'HalonGas':
		case 'TearGas':
		case 'PoisonEffect':
		case 'PoisonGas':
		case 'DrugDamage':
		case 'Overdose':
			Ret = 0.5;
		break;
		//Everything else? Nah brah.
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

defaultproperties
{
     Charge=400
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 1/30/21: No sound, as we start with a select sound queue, IE medkit usage.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconMedkit'
}
