//=============================================================================
// VMDBufferAugmentation.
//=============================================================================
class VMDBufferAugmentation extends Augmentation;

//MADDERS: Allow disabling of otherwise passive augs
var travel bool bDisabled;
var bool bPassive;

var localized String EnergyRateLabel2;

//------------------------------------------
//MADDERS: Allow for more dynamic configuration of aug bonuses. Yeet.
//------------------------------------------
function float VMDConfigureDamageMult(name DT)
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

defaultproperties
{
     EnergyRateLabel2="Energy Rate: %d Units/Tick"
}
