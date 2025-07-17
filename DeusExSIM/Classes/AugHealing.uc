//=============================================================================
// AugHealing.
//=============================================================================
class AugHealing extends VMDBufferAugmentation;

var float mpAugValue, mpEnergyDrain;
var localized string HungerDescription, AdvancedHungerDescription, HealedPointsLabel, HealedPointLabel;

state Active
{
Begin:
Loop:
	Sleep(1.0);
	
	if ((Player != None) && (IsPlayerDamaged(Player)) && (Player.Energy > GetNeededEnergy()))
	{
		Player.Energy -= GetNeededEnergy();
		//MADDERS, 5/4/25: Redirect healing to broken limbs now.
		//Player.HealPlayer(GetHealAmount(), False);
		HealPlayer(Player, GetHealAmount());
		VMDBufferPlayer(Player).VMDRegisterFoodEaten(1, "Regen");
	}
	else if ((VMBP != None) && (IsVMBPDamaged(VMBP)) && (VMBP.Energy > GetNeededEnergy()))
	{
		VMBP.Energy -= GetNeededEnergy();
		VMBP.ReceiveHealing(GetHealAmount());
		if ((Level != None) && (Level.Game != None))
		{
			VMBP.PlaySound(Sound'AugDefenseOn', SLOT_Interact, 2.5,, 800, 1.05 * Level.Game.GameSpeed);
		}
		else
		{
			VMBP.PlaySound(Sound'AugDefenseOn', SLOT_Interact, 2.5,, 800, 1.05);
		}
	}
	else
	{
		if (VMBP == None)
		{
			Deactivate();
		}
	}
	
	if (Player != None)
	{
		Player.ClientFlash(0.5, vect(0, 0, 500));
	}
	Goto('Loop');
}

function int GetHealAmount()
{
	local float Ret;
	
	Ret = LevelValues[CurrentLevel] * GetVelModInv();
	if (VMDBufferPlayer(Player) != None)
	{
		Ret *=  1.0 - (0.75 * int(VMDBufferPlayer(Player).bUseSharedHealth));
	}
	
	return int(Ret);
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
		
		if ((TDam > MostDam) && (TDam >= THealth))
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

function Deactivate()
{
	Super.Deactivate();
}

//MADDERS: Cost energy only when healing!
simulated function float GetEnergyRate()
{
	return 0.0;
}

function float GetNeededEnergy()
{
	local float Ret;
	
	Ret = EnergyRate * GetVelMod() * GetPowerMult();
	//MADDERS: Makes regen too strong. Whoopsies.
	//Ret /= Sqrt(CurrentLevel+1);
	return Ret;
}

function float GetPowerMult()
{
	local Augmentation anAug;
	local float Ret;
	
	Ret = 1.0;
	
	if (Player != None)
	{
		anAug = Player.AugmentationSystem.FirstAug;
		while(anAug != None)
		{
			if ((anAug.bHasIt) && (anAug.bIsActive))
			{
				if (anAug.IsA('AugPower'))
        	 		{
					Ret = anAug.LevelValues[anAug.CurrentLevel];
					break;
        	 		}
			}
			anAug = anAug.next;
		}
	}
	else if (VMBP != None)
	{
		anAug = VMBP.AugmentationSystem.FirstAug;
		while(anAug != None)
		{
			if ((anAug.bHasIt) && (anAug.bIsActive))
			{
				if (anAug.IsA('AugPower'))
        	 		{
					Ret = anAug.LevelValues[anAug.CurrentLevel];
					break;
        	 		}
			}
			anAug = anAug.next;
		}
	}
	
	return Ret;
}

function float GetVelMod()
{
	local float Ret;
	
	if (Player != None)
	{
		Ret = 1.0 + (FClamp(VSize(Player.Velocity * vect(1,1,0)) / 1050.0, 0.0, 1.0));
	}
	else if (VMBP != None)
	{
		Ret = 1.0 + (FClamp(VSize(VMBP.Velocity * vect(1,1,0)) / 1050.0, 0.0, 1.0));
	}
	
	return Ret;
}

//MADDERS: Return inverse, for when it matters for opposite reasons.
function float GetVelModInv()
{
	local float Ret;
	
	if (Player != None)
	{
		Ret = 1.0 - (FClamp(VSize(Player.Velocity * vect(1,1,0)) / 1050.0, 0.0, 1.0));
	}
	else if (VMBP != None)
	{
		Ret = 1.0 - (FClamp(VSize(VMBP.Velocity * vect(1,1,0)) / 1050.0, 0.0, 1.0));
	}
	
	return Ret;
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		LevelValues[3] = mpAugValue;
		EnergyRate = mpEnergyDrain;
	}
}

function bool IsPlayerDamaged( DeusExPlayer Player )
{
	local int HealthTotal;
	local VMDBufferPlayer VMP;
	local float ModMult;
	
	if (Player == None) return false;
	VMP = VMDBufferPlayer(Player);
	
	ModMult = 1.0;
	if (VMP != None)
	{
		if (VMP.KSHealthMult > 0)
		{
			ModMult *= VMP.KSHealthMult;
		}
		if (VMP.ModHealthMultiplier > 0.0)
		{
			ModMult *= VMP.ModHealthMultiplier;
		}
	}
	
	HealthTotal = Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight;
	
	if ((VMP != None) && (VMP.KSHealthMult < 1.0))
	{
		if (Abs(float(VMP.HealthHead) - (float(VMP.Default.HealthHead) * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthTorso) - (float(VMP.Default.HealthTorso) * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthLegLeft) - (float(VMP.Default.HealthLegLeft) * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthLegRight) - (float(VMP.Default.HealthLegRight) * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthArmLeft) - (float(VMP.Default.HealthArmLeft) * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthArmRight) - (float(VMP.Default.HealthArmRight) * ModMult)) >= 1.0) return true;
		return false;
	}
	else
	{
		//return (HealthTotal < 600*ModMult);
		return ((600*ModMult) - HealthTotal >= 1);
	}
}

function bool IsVMBPDamaged(VMDBufferPawn TPawn)
{
	local int HealthTotal, HealthMax;
	
	if (TPawn == None) return false;
	
	HealthMax = TPawn.StartingHealthValues[0] + TPawn.StartingHealthValues[1] + TPawn.StartingHealthValues[2] + TPawn.StartingHealthValues[3] + TPawn.StartingHealthValues[4] + TPawn.StartingHealthValues[5];
	
	HealthTotal = TPawn.HealthHead + TPawn.HealthTorso + TPawn.HealthArmLeft + TPawn.HealthArmRight + TPawn.HealthLegLeft + TPawn.HealthLegRight;
	
	return (HealthMax - HealthTotal >= 1);
}

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local String strOut;
	local int UsedEnergy;
	local VMDBufferAugmentation VMA;

	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;

	winInfo.Clear();
	winInfo.SetTitle(AugmentationName);

	if (bUsingMedbot)
	{
		winInfo.SetText(Sprintf(OccupiesSlotLabel, AugLocsText[AugmentationLocation]));
		if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bHungerEnabled))
		{
			winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ VMDGetAdvancedHungerDescription());
		}
		else
		{
			winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ VMDGetAdvancedDescription());
		}
	}
	else
	{
		if ((VMDBufferPlayer(Player) != None) && (VMDBufferPlayer(Player).bHungerEnabled))
		{
			winInfo.SetText(VMDGetAdvancedHungerDescription());
		}
		else
		{
			winInfo.SetText(VMDGetAdvancedDescription());
		}
	}
	
	VMA = Self;
	if (VMA == None || GetEnergyRate() > 0)
	{
		// Energy Rate
		UsedEnergy = int(GetEnergyRate());
		winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ Sprintf(EnergyRateLabel, UsedEnergy));
	}
	else
	{
		UsedEnergy = int(VMA.GetNeededEnergy());
		winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ Sprintf(VMA.EnergyRateLabel2, UsedEnergy));
	}
	

	// Current Level
	strOut = Sprintf(CurrentLevelLabel, CurrentLevel + 1);
	
	// Can Upgrade / Is Active labels
	if (CanBeUpgraded())
		strOut = strOut @ CanUpgradeLabel;
	else if (CurrentLevel == MaxLevel )
		strOut = strOut @ MaximumLabel;

	winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ strOut);

	// Always Active?
	if (bAlwaysActive)
		winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ AlwaysActiveLabel);

	return True;
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(LevelValues[i]));
	}
	
	return Ret;
}

function string VMDGetAdvancedHungerDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedHungerDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(LevelValues[i] + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     AdvancedDescription="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time. However, this process performs best when the body is not burdened by excess movement."
     AdvancedHungerDescription="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time. However, this process performs best when the body is not burdened by excess movement. Additionally, rapidly constructing the body's tissues can increase the amount of food an agent requires."
     HealedPointsLabel="Healed %d points"
     HealedPointLabel="Healed %d point"
     AdvancedDescLevels(0)="TECH ONE: Healing occurs at up to %d units per tick."
     AdvancedDescLevels(1)="TECH TWO: Healing occurs at up to %d units per tick."
     AdvancedDescLevels(2)="TECH THREE: Healing occurs at up to %d units per tick."
     AdvancedDescLevels(3)="TECH FOUR: Healing occurs at up to %d units per tick."
     
     mpAugValue=10.000000
     mpEnergyDrain=100.000000
     EnergyRate=8.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconHealing'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconHealing_Small'
     AugmentationName="Regeneration"
     HungerDescription="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time. However, this process performs best when the body is not burdened by excess movement. Additionally, rapidly constructing the body's tissues can increase the amount of food an agent requires.|n|nTECH ONE: Healing occurs at up to 5 units per tick.|n|nTECH TWO: Healing occurs at up to 10 units per tick.|n|nTECH THREE: Healing occurs at up to 17 units per tick.|n|nTECH FOUR: Healing occurs at up to 25 units per tick."
     Description="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time. However, this process performs best when the body is not burdened by excess movement.|n|nTECH ONE: Healing occurs at 5 units per tick.|n|nTECH TWO: Healing occurs at 10 units per tick.|n|nTECH THREE: Healing occurs at 17 units per tick.|n|nTECH FOUR: Healing occurs at 25 units per tick."
     MPInfo="When active, you heal, but at a rate insufficient for healing in combat.  Energy Drain: High"
     LevelValues(0)=10.000000
     LevelValues(1)=14.000000
     LevelValues(2)=18.000000
     LevelValues(3)=25.000000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=2
}
