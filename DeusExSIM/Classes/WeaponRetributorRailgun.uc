//=============================================================================
// WeaponRetributorRailgun.
//=============================================================================
class WeaponRetributorRailgun extends DeusExWeapon;

#exec OBJ LOAD FILE=Ambient

var bool bRecharging;

function Tick(float DT)
{
	Super.Tick(DT);
	
	if ((VMDShotTimeProgression() < ShotTime) && (bRecharging) && (AmmoType.AmmoAmount > 0))
	{
		AmbientSound = Sound'HumLow3';
		SoundVolume = 255 * ((ShotTime - VMDShotTimeProgression()) / ShotTime);
		SoundPitch = 48 + (88 * VMDShotTimeProgression());
		SoundRadius = 160;
	}
	else if (bRecharging)
	{
		AmbientSound = None;
		bRecharging = false;
	}
}

function bool VMDTraceFireHook(float Accuracy)
{
	bRecharging = true;
	
	return true;
}

function bool VMDAngleMeansRicochet(Vector HitLocation, Vector A, Vector B, name TexGroup, Actor Other)
{
	return false;
}

function name WeaponDamageType()
{
	return 'Sabot';
}

function float VMDGetMaterialPenetration(Actor TTarget)
{
	return Super.VMDGetMaterialPenetration(TTarget) * 6;
}

simulated function PlayFiringSound()
{
	local Sound OldFire;
	
	Super.PlayFiringSound();
	
	OldFire = FireSound;
	
	FireSound = Sound'MediumExplosion1';
     	FirePitchMin = 1.900000;
     	FirePitchMax = 2.100000;
	Super.PlayFiringSound();
	FireSound = Sound'PlasmaRifleFire';
     	FirePitchMin = 1.400000;
     	FirePitchMax = 1.600000;
	Super.PlayFiringSound();
	
     	FirePitchMin = 0.900000;
     	FirePitchMax = 1.100000;
	FireSound = OldFire;
}

//MADDERS: To configure your way out of gascaps, I guess. Why not?
function class<DeusExProjectile> VMDConfigureTracerClass(int RicNum, int PenNum)
{
	local int RicCap, PenCap;
	
	PenCap = 1;
	RicCap = VMDGetNumRicochets();
	
	if ((PenNum == PenCap) && (PenNum > 0) && (PenCap > 0))
	{
		return class'TracerSilver';
	}
	else if ((RicNum == RicCap) && (RicNum > 0) && (RicCap > 0))
	{
		return class'TracerSilver';
	}
	else if ((RicNum >= 0) && (PenNum >= 0))
	{
		return class'SniperTracerSilver';
	}
	
	return class'TracerSilver';
} 

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     InvSlotsX=999
     
     BulletHoleSize=0.500000
     bSemiautoTrigger=True
     OverrideAnimRate=1.600000
     AimDecayMult=12.500000
     PenetrationHitDamage=28
     RicochetHitDamage=0
     
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=2.500000
     reloadTime=1.000000
     HitDamage=28
     maxRange=48000
     AccurateRange=6400
     BaseAccuracy=0.350000
     recoilStrength=0.600000
     AmmoName=Class'DeusEx.AmmoLAM'
     ReloadCount=1
     PickupAmmoCount=1
     bInstantHit=True
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.RifleFire'
     AltFireSound=None
     CockingSound=None
     SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
     InventoryGroup=2
     bNameCaseSensitive=False
     ItemName="Trustrike Mag Cannon"
     PlayerViewMesh=LodMesh'DeusExItems.Glock'
     LeftPlayerViewMesh=LodMesh'GlockLeft'
     PickupViewMesh=LodMesh'DeusExItems.GlockPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Glock3rd'
     LeftThirdPersonMesh=LodMesh'Glock3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconPistol'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPistol'
     largeIconWidth=46
     largeIconHeight=28
     Mesh=LodMesh'DeusExItems.GlockPickup'
     CollisionRadius=7.000000
     CollisionHeight=1.000000
}
