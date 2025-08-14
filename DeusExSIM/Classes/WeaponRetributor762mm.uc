//=============================================================================
// WeaponRetributor762mm.
//=============================================================================
class WeaponRetributor762mm extends DeusExWeapon;

var float SpinUpPercentage;

function bool VMDTraceFireHook(float Accuracy)
{
	local float TMod;
	
	Super.VMDTraceFirehook(Accuracy);
	
	if (DeusExAmmo(AmmoType) != None)
	{
		DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType()*-1);
	}
	
	TMod = 1.0;
	SpinUpPercentage += ShotTime + (0.035 * TMod);
	
	return true;
}

state NormalFire
{
	function float GetShotTime()
	{
		if (SpinUpPercentage > 0)
		{
			return ShotTime / SpinUpPercentage;
		}
		else
		{
			return ShotTime;
		}
	}
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (VMDShotTimeProgression() >= GetShotTime())
	{
		ReadyToFire();
	}
	
	if (SpinUpPercentage > 1.0)
	{
		if (ClipCount >= ReloadCount)
		{
			SpinUpPercentage = 0;
		}
		else
		{
			SpinUpPercentage -= DT;
		}
	}
}

function VMDPlayRicochetSound(Vector HitLocation)
{
}

defaultproperties
{
     bStationaryFiringOnly=True
     OverrideNumProj=2
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     SpinUpPercentage=1.000000
     
     OverrideAnimRate=500.000000
     AimDecayMult=-12.500000
     AimDecayMult=4.000000
     AimFocusMult=1.250000
     PenetrationHitDamage=0
     RicochetHitDamage=1
     
     LowAmmoWaterMark=100
     ShotTime=0.0800000
     HitDamage=2
     recoilStrength=0.600000
     AmmoName=Class'DeusEx.Ammo762mm'
     ReloadCount=100
     PickupAmmoCount=0
     ItemName="Hailstorm Chaingun"
     FireSound=Sound'AssaultGunSemi'
     
     maxRange=9600
     AccurateRange=3600 //Used to be 4800
     
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     EnviroEffective=ENVEFF_Air
     reloadTime=4.000000
     BaseAccuracy=0.250000
     MinWeaponAcc=0.200000
     bInstantHit=True
     shakemag=200.000000
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
     InventoryGroup=4
     bNameCaseSensitive=False
     PlayerViewMesh=LodMesh'DeusExItems.AssaultGun'
     LeftPlayerViewMesh=LodMesh'AssaultGunLeft'
     PickupViewMesh=LodMesh'DeusExItems.AssaultGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.AssaultGun3rd'
     LeftThirdPersonMesh=LodMesh'AssaultGun3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconAssaultGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultGun'
     largeIconWidth=94
     largeIconHeight=65
     Mesh=LodMesh'DeusExItems.AssaultGunPickup'
     CollisionRadius=15.000000
     CollisionHeight=1.100000
}
