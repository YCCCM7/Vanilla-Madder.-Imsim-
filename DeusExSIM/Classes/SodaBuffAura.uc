//=============================================================================
// SodaBuffAura.
//=============================================================================
class SodaBuffAura extends VMDFakeBuffAura;

//--------------------
//MADDERS, 1/30/21: We reduce damage as a very hacky "aura" of sorts.
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	return 1.0;
}

//Latent control over this as well.
function VMDFakeAuraTimerHook(bool bWhole)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if ((bWhole) && (VMP != None))
	{
		VMP.VMDModPlayerStress(3,,,false);
	}
}

defaultproperties
{
     Charge=600
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 1/30/21: No sound, as we start with a select sound queue, IE soda usage.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconSodaCan'
}
