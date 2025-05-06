//=============================================================================
// WaltonSimons.
//=============================================================================
class WaltonSimons extends HumanMilitary;

//
// Damage type table for Walton Simons:
//
// Shot			- 100%
// Sabot		- 100%
// Exploded		- 33%
// TearGas		- 0%
// PoisonGas		- 0%
// HalonGas		- 0%
// Poison		- 10%
// PoisonEffect		- 10%
// Radiation		- 10%
// Shocked		- 10%
// Stunned		- 0%
// KnockedOut   	- 0%
// Flamed		- 0%
// Burned		- 0%
// NanoVirus		- 0%
// EMP			- 0%
//

function float ShieldDamage(name damageType)
{
	// handle special damage types
	switch(DamageType)
	{
		/*case 'TearGas':
		case 'HalonGas':
		case 'Flamed':
		case 'Burned':
		case 'Stunned':
		case 'KnockedOut':
			return 0.0;
		break;
		case 'PoisonGas':
		case 'DrugDamage':
		case 'Radiation':
		case 'Shocked':
		case 'Poison':
		case 'PoisonEffect':
			return 0.1;
		break;
		case  'Exploded':
			return 0.33;
		break;*/
		default:
			return Super.ShieldDamage(damageType);
		break;
	}
	return Super.ShieldDamage(damageType);
}

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	/*if ((!bCollideActors) && (!bBlockActors) && (!bBlockPlayers))
	{
		return;
	}
	if (CanShowPain())
	{
		TakeHit(hitPos);
	}
	else
	{
		GotoNextState();
	}*/
	
	Super.GoToDisabledState(DamageType, HitPos);
}

// Transcended - Let's not let bosses drop their weapons, Gunther likes to do it.
function bool ShouldDropWeapon()
{
	if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "Boss Deathmatch"))
	{
		return false;
	}
	return Super.ShouldDropWeapon();
}

function bool VMDCanDropWeapon()
{
	if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "Boss Deathmatch"))
	{
		return false;
	}
	return Super.VMDCanDropWeapon();
}

function ApplySpecialStats()
{
	if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(GetLastVMP(), "Boss Deathmatch"))
	{
		MinHealth = 0;
	}
	Super.ApplySpecialStats();
}

defaultproperties
{
     MedicineSkillLevel=2
     EnviroSkillLevel=2
     MedkitHealthLevel=450
     Energy=200
     EnergyMax=200
     bHasAugmentations=True
     DefaultAugs(0)=class'AugDefense'
     DefaultAugs(1)=class'AugCloak'
     DefaultAugs(2)=class'AugBallistic'
     DefaultAugs(3)=class'AugTarget'
     DefaultAugs(4)=class'AugEnviro'
     DefaultAugs(5)=class'AugShield'
     
     //MADDERS additions.
     bDrawShieldEffect=True
     ROFCounterweight=0.000000
     
     CarcassType=Class'DeusEx.WaltonSimonsCarcass'
     WalkingSpeed=0.333333
     bImportant=True
     bInvincible=True
     CloseCombatMult=0.500000
     BaseAssHeight=-23.000000
     BurnPeriod=0.000000
     bHasCloak=False
     CloakThreshold=150
     walkAnimMult=1.400000
     GroundSpeed=240.000000
     Health=600
     HealthHead=600
     HealthTorso=600
     HealthLegLeft=600
     HealthLegRight=600
     HealthArmLeft=600
     HealthArmRight=600
     Mesh=LodMesh'TranscendedModels.TransGM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.WaltonSimonsTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.WaltonSimonsTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.PantsTex5'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.WaltonSimonsTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.WaltonSimonsTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.WaltonSimonsTex2'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="WaltonSimons"
     FamiliarName="Walton Simons"
     UnfamiliarName="Walton Simons"
     NameArticle=" "
}
