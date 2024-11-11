//=============================================================================
// WeaponRetributorShotgun.
//=============================================================================
class WeaponRetributorShotgun extends DeusExWeapon;

simulated function SawedOffCockSound()
{
	if (AmmoType.AmmoAmount > 0)
	{
		if ((DeusExAmmo(AmmoType) != None) && (!IsInState('ReloadToIdle')) && (!IsInState('Reload')) && (bPumpAction) && (PumpPurpose == 2))
		{
			DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
			DeusExAmmo(AmmoType).VMDForceShellCasing(GetHandType());
		}
		Owner.PlaySound(SelectSound, SLOT_None,,, 1024, VMDGetMiscPitch());
	}
}

//Update penetration and ricochet damage.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (AmmoSabot(AmmoType) != None)
	{
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
		
		//MADDERS: Note that this is multiplied by pellet count later.
     		PenetrationHitDamage = 2;
     		RicochetHitDamage = 1;
		BulletHoleSize = 0.175000;
	}
	else if (AmmoTaserSlug(AmmoType) != None)
	{
     		FirePitchMin = 1.150000;
     		FirePitchMax = 1.400000;
	}
	else
	{
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
		
     		PenetrationHitDamage = Default.PenetrationHitDamage;
     		RicochetHitDamage = Default.RicochetHitDamage;
		BulletHoleSize = 0.075000;
	}
}

function int VMDGetCorrectNumProj( int In )
{
 	if (AmmoSabot(AmmoType) != None || AmmoTaserSlug(AmmoType) != None) return 2;
 	
 	if (OverrideNumProj < 1)
 	{
  		return In;
 	}
 	return OverrideNumProj;
}

function float VMDGetCorrectHitDamage( float In )
{
 	//MADDERS: Always return full damage with sabot falloff. We'll truncate like a mother fucker at all times if we don't.
 	if (AmmoSabot(AmmoType) != None) return Default.HitDamage*OverrideNumProj;
 	return FMax(int(Default.HitDamage > 0), In);
}

defaultproperties
{
     PlayerViewOffset=(Y=-24.000000,Z=-12.000000)
     invSlotsX=999
     BulletHoleSize=0.075000
     PumpPurpose=2
     bPumpAction=True
     PumpStart=0.400000
     NumFiringModes=0
     bSemiautoTrigger=True
     AimDecayMult=17.000000
     PenetrationHitDamage=0
     RicochetHitDamage=2
     
     MinSpreadAcc=0.075000
     BaseAccuracy=0.600000
     MaximumAccuracy=0.5000000
     
     OverrideNumProj=24
     OverrideAnimRate=1.250000
     OverrideReloadAnimRate=1.000000
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconShotgunRotated'
     
     reloadTime=2.000000
     LowAmmoWaterMark=5
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     ShotTime=0.300000
     reloadTime=3.000000
     HitDamage=2
     maxRange=4800
     RelativeRange=4800
     AccurateRange=2400
     AmmoNames(0)=Class'DeusEx.AmmoShell'
     AmmoNames(1)=Class'DeusEx.AmmoSabot'
     AmmoNames(2)=Class'DeusEx.AmmoTaserSlug'
     ProjectileNames(2)=Class'DeusEx.TaserSlug'
     AreaOfEffect=AOE_Cone
     recoilStrength=1.350000
     AmmoName=Class'DeusEx.AmmoSabot'
     ReloadCount=5
     PickupAmmoCount=5
     bInstantHit=True
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.SawedOffShotgunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReload'
     SelectSound=Sound'DeusExSounds.Weapons.SawedOffShotgunSelect'
     InventoryGroup=6
     bNameCaseSensitive=False
     ItemName="Deathknell Heavy Shotgun"
     PlayerViewMesh=LodMesh'DeusExItems.Shotgun'
     LeftPlayerViewMesh=LodMesh'ShotgunLeft'
     PickupViewMesh=LodMesh'DeusExItems.ShotgunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Shotgun3rd'
     LeftThirdPersonMesh=LodMesh'Shotgun3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconShotgun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconShotgun'
     largeIconWidth=131
     largeIconHeight=45
     Mesh=LodMesh'DeusExItems.ShotgunPickup'
     CollisionRadius=12.000000
     CollisionHeight=0.900000
}
