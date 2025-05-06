//=============================================================================
// PaulDenton.
//=============================================================================
class PaulDenton extends HumanMilitary;

//
// Damage type table for Paul Denton:
//
// Shot			- 100%
// Sabot		- 100%
// Exploded		- 100%
// TearGas		- 10%
// PoisonGas	- 10%
// Poison		- 10%
// PoisonEffect	- 10%
// HalonGas		- 10%
// Radiation	- 10%
// Shocked		- 10%
// Stunned		- 0%
// KnockedOut   - 0%
// Flamed		- 0%
// Burned		- 0%
// NanoVirus	- 0%
// EMP			- 0%
//

function float ShieldDamage(name damageType)
{
	// handle special damage types
	switch(DamageType)
	{
		/*case 'Flamed':
		case 'Burned':
		case 'Stunned':
		case 'KnockedOut':
			return 0.0;
		break;
		case 'TearGas':
		case 'PoisonGas':
		case 'DrugDamage':
		case 'HalonGas':
		case 'Radiation':
		case 'Shocked':
		case 'Poison':
		case 'PoisonEffect':
			return 0.1;
		break;*/
		default:
			return Super.ShieldDamage(damageType);
		break;
	}
}

// ----------------------------------------------------------------------
// GetLevelInfo()
// ----------------------------------------------------------------------

function DeusExLevelInfo GetLevelInfo()
{
	local DeusExLevelInfo info;

	foreach AllActors(class'DeusExLevelInfo', info)
		break;

	return info;
}

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	/*if ((!bCollideActors) && (!bBlockActors) && (!bBlockPlayers))
		return;
	if (CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();*/
	
	Super.GoToDisabledState(DamageType, HitPos);
}

// ----------------------------------------------------------------------
// SetSkin()
// ----------------------------------------------------------------------

function SetSkin(DeusExPlayer player)
{
	if (player != None)
	{
		switch(player.PlayerSkin)
		{
			case 0:	MultiSkins[0] = Texture'PaulDentonTex0';
				MultiSkins[3] = Texture'PaulDentonTex0';
			break;
			case 1:	MultiSkins[0] = Texture'PaulDentonTex4';
				MultiSkins[3] = Texture'PaulDentonTex4';
			break;
			case 2:	MultiSkins[0] = Texture'PaulDentonTex5';
				MultiSkins[3] = Texture'PaulDentonTex5';
			break;
			case 3:	MultiSkins[0] = Texture'PaulDentonTex6';
				MultiSkins[3] = Texture'PaulDentonTex6';
			break;
			case 4:	MultiSkins[0] = Texture'PaulDentonTex7';
				MultiSkins[3] = Texture'PaulDentonTex7';
			break;
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     MedicineSkillLevel=3
     EnviroSkillLevel=2
     MedkitHealthLevel=500
     Energy=100
     EnergyMax=100
     bHasAugmentations=True
     DefaultAugs(0)=class'AugBallistic'
     DefaultAugs(1)=class'AugTarget'
     DefaultAugs(2)=class'AugEnviro'
     DefaultAugs(3)=class'AugShield'
     DefaultAugs(4)=class'AugEMP'
     DefaultAugs(5)=class'AugPower'
     DefaultAugs(6)=class'AugSpeed'
     DefaultAugs(7)=class'AugCombat'
     
     //MADDERS additions.
     bDrawShieldEffect=True
     
     CarcassType=Class'DeusEx.PaulDentonCarcass'
     WalkingSpeed=0.120000
     bImportant=True
     bInvincible=True
     BaseAssHeight=-23.000000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponAssaultGun')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=12)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponPlasmaRifle')
     InitialInventory(3)=(Inventory=Class'DeusEx.AmmoPlasma')
     InitialInventory(4)=(Inventory=Class'DeusEx.WeaponSword')
     BurnPeriod=0.000000
     bHasCloak=False
     CloakThreshold=0
     Health=600
     HealthHead=600
     HealthTorso=600
     HealthLegLeft=600
     HealthLegRight=600
     HealthArmLeft=600
     HealthArmRight=600
     Mesh=LodMesh'TranscendedModels.TransGM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.PaulDentonTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.PaulDentonTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.PantsTex8'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.PaulDentonTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.PaulDentonTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.PaulDentonTex2'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="PaulDenton"
     FamiliarName="Paul Denton"
     UnfamiliarName="Paul Denton"
     NameArticle=" "
}
