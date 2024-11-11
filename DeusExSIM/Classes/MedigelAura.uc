//=============================================================================
// MedigelAura.
//=============================================================================
class MedigelAura extends VMDFakeBuffAura;

var int NumHeals;
var localized string HealedPointsLabel, HealedPointLabel;

function VMDFakeAuraTimerHook(bool bWhole)
{
	local bool bWasLowHealth;
	local DeusExPlayer DXP;
	local VMDBufferPawn VMBP;
	
	if (bWhole)
	{
		DXP = DeusExPlayer(Owner);
		VMBP = VMDBufferPawn(Owner);
		if (DXP != None)
		{
			/*if (NumHeals < 3)
			{
				HealPlayer(DXP, 19);
			}
			else
			{
				HealPlayer(DXP, 18);
			}*/
			
			HealPlayer(DXP, 15);
			NumHeals++;
		}
		//MADDERS, 6/23/24: Heal us our intended amount, and if need be, send us back into the fight.
		else if ((VMBP != None) && (VMBP.Health > 0))
		{
			bWasLowHealth = VMBP.ShouldFlee();
			
			VMBP.ReceiveHealing(VMDGetNPCHealSize());
			if ((VMBP.Enemy != None) && (VMBP.IsInState('Fleeing')) && (bWasLowHealth) && (!VMBP.ShouldFlee()))
			{
				VMBP.SetNextState('Attacking');
				VMBP.GoToNextState();
			}
			NumHeals++;
		}
	}
	
	Super.VMDFakeAuraTimerHook(bWhole);
}

function int VMDGetNPCHealSize()
{
	local VMDBufferPawn VMBP;
	
	VMBP = VMDBufferPawn(Owner);
	
	if (VMBP == None)
	{
		return 0;
	}
	
	if (VMBP.bHasAugmentations)
	{
		if (VMBP.bMechAugs) //Mechs don't have much left in flesh, so they heal for 50% value.
		{
			return 5;
		}
		else //Nanoaugs can better jive with the solution, so they heal 150% value.
		{
			return 15;
		}
	}
	
	//Normal humans heal for 100% value.
	return 10;
}

function HealPlayer(DeusExPlayer DXP, int HealAmount)
{
	local int THealth, TDam, MostDam, MostDamIndex, i;
	local float ModMult;
	local VMDBufferPlayer VMP;
	
	if (DXP == None || DXP.IsInState('Dying')) return;
	
	VMP = VMDBufferPlayer(DXP);
	
	ModMult = 1.0;
	if ((VMP != None) && (VMP.ModHealthMultiplier > 0.0))
	{
		ModMult = VMP.ModHealthMultiplier;
	}
	
	for (i=0; i<6; i++)
	{
		switch(i)
		{
			case 0:
				if (VMP == None)
				{
					THealth = DXP.Default.HealthHead;
					TDam = THealth - DXP.HealthHead;
				}
				else
				{
					THealth = float(DXP.Default.HealthHead) * VMP.KSHealthMult * ModMult;
					TDam = THealth - DXP.HealthHead;
				}
			break;
			case 1:
				if (VMP == None)
				{
					THealth = DXP.Default.HealthTorso;
					TDam = THealth - DXP.HealthTorso;
				}
				else
				{
					THealth = float(DXP.Default.HealthTorso) * VMP.KSHealthMult * ModMult;
					TDam = THealth - DXP.HealthTorso;
				}
			break;
			case 2:
				if (VMP == None)
				{
					THealth = DXP.Default.HealthArmLeft;
					TDam = THealth - DXP.HealthArmLeft;
				}
				else
				{
					THealth = float(DXP.Default.HealthArmLeft) * VMP.KSHealthMult * ModMult;
					TDam = THealth - DXP.HealthArmLeft;
				}
			break;
			case 3:
				if (VMP == None)
				{
					THealth = DXP.Default.HealthArmRight;
					TDam = THealth - DXP.HealthArmRight;
				}
				else
				{
					THealth = float(DXP.Default.HealthArmRight) * VMP.KSHealthMult * ModMult;
					TDam = THealth - DXP.HealthArmRight;
				}
			break;
			case 4:
				if (VMP == None)
				{
					THealth = DXP.Default.HealthLegLeft;
					TDam = THealth - DXP.HealthLegLeft;
				}
				else
				{
					THealth = float(DXP.Default.HealthLegLeft) * VMP.KSHealthMult * ModMult;
					TDam = THealth - DXP.HealthLegLeft;
				}
			break;
			case 5:
				if (VMP == None)
				{
					THealth = DXP.Default.HealthLegRight;
					TDam = THealth - DXP.HealthLegRight;
				}
				else
				{
					THealth = float(DXP.Default.HealthLegRight) * VMP.KSHealthMult * ModMult;
					TDam = THealth - DXP.HealthLegRight;
				}
			break;
		}
		
		if (TDam > MostDam)
		{
			MostDam = TDam;
			MostDamIndex = i;
		}
	}
	
	if (MostDam >= HealAmount)
	{
		HealPart(DXP, MostDamIndex, HealAmount);
	}
	else
	{
		DXP.HealPlayer(HealAmount, False);
	}
}

function HealPart(DeusExPlayer DXP, int HealIndex, int HealAmount)
{
	if (DXP == None || DXP.IsInState('Dying')) return;
	
	switch(HealIndex)
	{
		case 0:
			DXP.HealthHead += HealAmount;
		break;
		case 1:
			DXP.HealthTorso += HealAmount;
		break;
		case 2:
			DXP.HealthArmLeft += HealAmount;
		break;
		case 3:
			DXP.HealthArmRight += HealAmount;
		break;
		case 4:
			DXP.HealthLegLeft += HealAmount;
		break;
		case 5:
			DXP.HealthLegRight += HealAmount;
		break;
	}
	
	if (HealAmount == 1)
	{
		DXP.ClientMessage(Sprintf(HealedPointLabel, HealAmount));
	}
	else
	{
		DXP.ClientMessage(Sprintf(HealedPointsLabel, HealAmount));
	}
}

defaultproperties
{
     Charge=160
     PickupMessage=""
     ExpireMessage=""
     HealedPointsLabel="Healed %d points"
     HealedPointLabel="Healed %d point"
     
     //MADDERS, 5/17/22: No sound needed.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconMedigel'
}
