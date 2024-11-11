//=============================================================================
// CandyBuffAura.
//=============================================================================
class CandyBuffAura extends VMDFakeBuffAura;

//--------------------
//MADDERS, 1/30/21: We reduce damage as a very hacky "aura" of sorts.
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	return 1.0;
}

//Latent control over this as well.
function VMDFakeAuraTimerHook(bool bWhole)
{
	/*local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if ((bWhole) && (VMP != None))
	{
		VMP.VMDModPlayerStress(-1,,,false);
	}*/
}

defaultproperties
{
     Charge=400
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 1/30/21: No sound.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconCandyBar'
}
