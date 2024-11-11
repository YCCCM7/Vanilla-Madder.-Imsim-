//=============================================================================
// AugHealing.
//=============================================================================
class AugHealing extends VMDBufferAugmentation;

var float mpAugValue;
var float mpEnergyDrain;

state Active
{
Begin:
Loop:
	Sleep(1.0);
	
	if ((IsPlayerDamaged(Player)) && (Player.Energy > GetNeededEnergy()))
	{
		Player.Energy -= GetNeededEnergy();
		Player.HealPlayer(GetHealAmount() , False);
		VMDBufferPlayer(Player).VMDRegisterFoodEaten(0, "Regen");
	}
	else
		Deactivate();
	
	Player.ClientFlash(0.5, vect(0, 0, 500));
	Goto('Loop');
}

function int GetHealAmount()
{
	local float Ret;
	
	Ret = LevelValues[CurrentLevel] * GetVelModInv();
	if (VMDBufferPlayer(Player) != None) Ret *=  1.0 - (0.75 * int(VMDBufferPlayer(Player).bUseSharedHealth));
	return int(Ret);
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
	
	return Ret;
}

function float GetVelMod()
{
	local float Ret;
	
	Ret = 1.0 + (FClamp(VSize(Player.Velocity * vect(1,1,0)) / 700.0, 0.0, 1.0));
	return Ret;
}

//MADDERS: Return inverse, for when it matters for opposite reasons.
function float GetVelModInv()
{
	local float Ret;
	
	Ret = 1.0 - (FClamp(VSize(Player.Velocity * vect(1,1,0)) / 700.0, 0.0, 1.0));
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
	if ((VMP != None) && (VMP.ModHealthMultiplier > 0.0))
	{
		ModMult = VMP.ModHealthMultiplier;
	}
	
	HealthTotal = Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight;
	
	if ((VMP != None) && (VMP.KSHealthMult < 1.0))
	{
		if (Abs(float(VMP.HealthHead) - (float(VMP.Default.HealthHead) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthTorso) - (float(VMP.Default.HealthTorso) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthLegLeft) - (float(VMP.Default.HealthLegLeft) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthLegRight) - (float(VMP.Default.HealthLegRight) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthArmLeft) - (float(VMP.Default.HealthArmLeft) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthArmRight) - (float(VMP.Default.HealthArmRight) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		return false;
	}
	else
	{
		//return (HealthTotal < 600*ModMult);
		return ((600*ModMult) - HealthTotal >= 1);
	}
}

defaultproperties
{
     mpAugValue=10.000000
     mpEnergyDrain=100.000000
     EnergyRate=8.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconHealing'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconHealing_Small'
     AugmentationName="Regeneration"
     Description="Programmable polymerase automatically directs construction of proteins in injured cells, restoring an agent to full health over time. However, this process performs best when the body is not burdened by excess movement.|n|nTECH ONE: Healing occurs at 5 units per tick.|n|nTECH TWO: Healing occurs at 10 units per tick.|n|nTECH THREE: Healing occurs at 17 units per tick.|n|nTECH FOUR: Healing occurs at 25 units per tick."
     MPInfo="When active, you heal, but at a rate insufficient for healing in combat.  Energy Drain: High"
     LevelValues(0)=5.000000
     LevelValues(1)=10.000000
     LevelValues(2)=17.000000
     LevelValues(3)=25.000000
     AugmentationLocation=LOC_Torso
     MPConflictSlot=2
}
