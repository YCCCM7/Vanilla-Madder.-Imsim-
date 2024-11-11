//=============================================================================
// MJ12Commando.
//=============================================================================
class MJ12Commando extends HumanMilitary;

function Bool HasTwoHandedWeapon()
{
	return False;
}

function PlayReloadBegin()
{
	TweenAnimPivot('Shoot', 0.1);
}

function PlayReload()
{
}

function PlayReloadEnd()
{
}

function PlayIdle()
{
}

function TweenToShoot(float tweentime)
{
	if (Region.Zone.bWaterZone)
		TweenAnimPivot('TreadShoot', tweentime, GetSwimPivot());
	else if (!bCrouching)
		TweenAnimPivot('Shoot2', tweentime);
}

function PlayShoot()
{
	if (Region.Zone.bWaterZone)
		PlayAnimPivot('TreadShoot', , 0, GetSwimPivot());
	else
		PlayAnimPivot('Shoot2', , 0);
}

function bool IgnoreDamageType(Name damageType)
{
	if ((damageType == 'TearGas') || (damageType == 'PoisonGas') || (damageType == 'DrugDamage'))
		return True;
	else
		return False;
}

function float ShieldDamage(Name damageType)
{
	if (IgnoreDamageType(damageType))
		return 0.0;
	else if ((damageType == 'Burned') || (damageType == 'Flamed'))
		return 0.5;
	else if ((damageType == 'Poison') || (damageType == 'PoisonEffect'))
		return 0.5;
	else
		return Super.ShieldDamage(damageType);
}


function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	else if (!IgnoreDamageType(damageType) && CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local int oldHealth;
	
	oldHealth = Health;
	
	Super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
	
	if ((Health > 0) && (Health <= (StartingHealthValues[6] / 4)) && (oldHealth > (StartingHealthValues[6] / 4)))
        	PlayCriticalDamageSound();
}

//MADDERS: Give commandos assloads of specialized gear, making them some robust sons of bitches to deal with.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local Texture TChest;
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
 	
 	//1111111111111
 	//MADDERS: Obtain a seed.
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 23);
	
	if (DXLI != None)
	{
		switch(Seed)
		{
			case 3:
			case 7:
			case 8:
				if (DXLI.MissionNumber >= 10)
				{
					AddToInitialInventory(class'BallisticArmor', 1);
				}
			break;
			case 4:
			case 15:
			case 21:
				if (DXLI.MissionNumber >= 8)
				{
					AddToInitialInventory(class'HazmatSuit', 1);
				}
			break;
			case 9:
			case 12:
			case 22:
				if (DXLI.MissionNumber >= 6)
				{
					AddToInitialInventory(class'BioelectricCell', 1);
				}
			break;
			case 13:
			case 17:
				if (DXLI.MissionNumber >= 12)
				{
					AddToInitialInventory(class'AdaptiveArmor', 1);
				}
			break;
		}
	}
}

defaultproperties
{
     bDoesntSniff=True
     SmellTypes(0)=""
     SmellTypes(1)=""
     SmellTypes(2)=""
     SmellTypes(3)=""
     SmellTypes(4)=""
     SmellTypes(5)=""
     SmellTypes(6)=""
     SmellTypes(7)=""
     
     //MADDERS additions.
     bAerosolImmune=True
     bDrawShieldEffect=True
     MedicineSkillLevel=1
     EnviroSkillLevel=3
     
     ArmorStrength=0.750000
     MinHealth=0.000000
     CarcassType=Class'DeusEx.MJ12CommandoCarcass'
     WalkingSpeed=0.296000
     bCanCrouch=False
     CloseCombatMult=0.500000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponMJ12Commando')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo762mm',Count=24)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponMJ12Rocket')
     InitialInventory(3)=(Inventory=Class'DeusEx.AmmoRocketMini',Count=10)
     
     //MADDERS: Hack for making commandos drop 7.62mm.
     //InitialInventory(5)=(Inventory=Class'DeusEx.WeaponGEPGunDummyNONONO')
     //InitialInventory(6)=(Inventory=Class'DeusEx.AmmoRocketNONONO',Count=10)
     InitialInventory(7)=(Inventory=Class'DeusEx.WeaponAssaultGunDummy')
     BurnPeriod=0.000000
     GroundSpeed=200.000000
     HealthHead=200
     HealthTorso=200
     HealthLegLeft=200
     HealthLegRight=200
     HealthArmLeft=200
     HealthArmRight=200
     Mesh=LodMesh'DeusExCharacters.GM_ScaryTroop'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12CommandoTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MJ12CommandoTex1'
     CollisionRadius=28.000000
     CollisionHeight=49.880001
     BindName="MJ12Commando"
     FamiliarName="MJ12 Commando"
     UnfamiliarName="MJ12 Commando"
     NameArticle=" an "
     RotationRate=(Pitch=4096,Yaw=60000,Roll=3072)
}
