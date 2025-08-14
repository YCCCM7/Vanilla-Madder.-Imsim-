//=============================================================================
// CombatStimAura.
//=============================================================================
class CombatStimAura extends VMDFakeBuffAura;

//--------------------
//MADDERS, 8/9/25: Reduce the effect of poison, since we fight against it, conceptually.
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
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
		case 'Poison':
		case 'PoisonEffect':
			Ret = 0.35;
		break;
		//Everything else? Nah brah.
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

//--------------------
//MADDERS, 8/9/25: However, poison reduces the duration of our stimulants all the same.
function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
	local VMDBufferPlayer VMP;
	local VMDBufferPawn VMBP;
	
	//MADDERS: Don't do this for now.
	if (bCheckOnly) return;
	
	VMBP = VMDBufferPawn(Owner);
	VMP = VMDBufferPlayer(Owner);
	
	switch(DamageType)
	{
		case 'Poison':
		case 'PoisonEffect':
			if (VMP != None)
			{
				Charge -= Max(1, Damage * 0.5);
			}
			else
			{
				Charge -= Max(1, Damage * 1.0);
			}
		break;
	}
	
	//MADDERS: Simulate a player-esque usage, for visual feedback. The effect is handled in pawns.
	if (PlayerPawn(Owner) == None)
	{
		if (Charge <= 0)
		{
			Destroy();
		}
	}
}

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
