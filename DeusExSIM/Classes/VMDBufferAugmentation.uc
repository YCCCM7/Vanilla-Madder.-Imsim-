//=============================================================================
// VMDBufferAugmentation.
//=============================================================================
class VMDBufferAugmentation extends Augmentation;

//MADDERS: Allow disabling of otherwise passive augs
var travel bool bDisabled;
var bool bPassive, bSenselessBind; //Is there no conceivable reason to bind this by default?

//MADDERS, 12/27/23: If we're an NPC Aug, what NPC are we attached to?
var bool bNPCEcoAug, bBulkAugException;
var VMDBufferPawn VMBP;

var() localized string AdvancedDescription, EnergyRateLabel2, AdvancedDescLevels[4];

//------------------------------------------
//MADDERS: Allow for more dynamic configuration of aug bonuses. Yeet.
//------------------------------------------
function float VMDConfigureDamageMult(name DT, int HitDamage, vector HitLocation)
{
 	return 1.0;
}
function float VMDConfigureSpeedMult(bool bWater)
{
 	return 1.0;
}
function float VMDConfigureLungMod(bool bWater)
{
 	return 0.0;
}
function float VMDConfigureHealingMult()
{
 	return 1.0;
}
function float VMDConfigureJumpMult()
{
 	return 1.0;
}
function float VMDConfigureDecoPushMult()
{
 	return 1.0;
}
function float VMDConfigureDecoLiftMult()
{
 	return 1.0;
}
function float VMDConfigureDecoThrowMult()
{
 	return 1.0;
}
function float VMDConfigureNoiseMult()
{
 	return 1.0;
}

function float VMDConfigureWepDamageMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	return 1.0;
}

function float VMDConfigureWepVelocityMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	return 1.0;
}

function float VMDConfigureWepSwingSpeedMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	return 1.0;
}

function float VMDConfigureWepAccuracyMod(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 0.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 0.0;
 	
 	return 0.0;
}

function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
}

function float GetNeededEnergy()
{
	return 0;
}

//MADDERS, 6/26/24: For when weird shit happens after saving and loading. Target and vision both need this.
function VMDAugWasPoked();

//MADDERS, 6/25/23: Give exact values per aug.
//Well, uh... THEY gotta make the move.
function string VMDGetAdvancedDescription()
{
	return Description;
}

//++++++++++++++++++++++++++++++++++++
//MADDERS, 8/16/23: Ported from biomod.
//We don't modify native here, sorry.
//++++++++++++++++++++++++++++++++++++
simulated function bool AppendInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local String strOut;
	local AugPower powerAug;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;
	
	winInfo.AppendText(winInfo.CR() $ winInfo.CR());
	
	if (bUsingMedbot)
	{
		winInfo.AppendText(Sprintf(OccupiesSlotLabel, AugLocsText[AugmentationLocation]));
		winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ VMDGetAdvancedDescription());
	}
	else
	{
		winInfo.AppendText(VMDGetAdvancedDescription());
	}
	
	// Current Level
	strOut = Sprintf(CurrentLevelLabel, CurrentLevel + 1);
	
	// Can Upgrade / Is Active labels
	if (CanBeUpgraded())
	{
		strOut = strOut @ CanUpgradeLabel;
	}
	else if (CurrentLevel == MaxLevel )
	{
		strOut = strOut @ MaximumLabel;
	}
	
	winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ strOut);
	
	// Always Active?
	if (bAlwaysActive)
	{
		winInfo.AppendText(winInfo.CR() $ winInfo.CR() $ AlwaysActiveLabel);
	}
	
	return True;
}

defaultproperties
{
     EnergyRateLabel2="Energy Rate: %d Units/Tick"
}
