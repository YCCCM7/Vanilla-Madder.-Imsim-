//=============================================================================
// WeaponSawedOffShotgun.
//=============================================================================
class WeaponSawedOffShotgun extends DeusExWeapon;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		HitDamage = mpHitDamage;
		BaseAccuracy = mpBaseAccuracy;
		ReloadTime = mpReloadTime;
		AccurateRange = mpAccurateRange;
		MaxRange = mpMaxRange;
		ReloadCount = mpReloadCount;
      		PickupAmmoCount = 12; //to match assaultshotgun
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
		MaxRange = 7200;
	}
	else if (AmmoTaserSlug(AmmoType) != None)
	{
     		FirePitchMin = 1.150000;
     		FirePitchMax = 1.400000;
		MaxRange = 4800;
	}
	else
	{
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
		
     		PenetrationHitDamage = Default.PenetrationHitDamage;
     		RicochetHitDamage = Default.RicochetHitDamage;
		BulletHoleSize = 0.075000;
		MaxRange = 4800;
	}
}

function int VMDGetCorrectNumProj( int In )
{
 	if (AmmoSabot(AmmoType) != None || AmmoTaserSlug(AmmoType) != None) return 1;
 	
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
	
 	return In;
}

defaultproperties
{
     BulletHoleSize=0.075000
     PumpPurpose=2
     bPumpAction=True
     PumpStart=0.400000
     NumFiringModes=0
     FiringModes(0)="Single Fire"
     FiringModes(1)="Double Fire "
     ModeNames(0)="Single Fire"
     ModeNames(1)="Double Fire"
     bSingleLoaded=True
     SingleLoadSound=Sound'SawedOffShotgunSingleLoad'
     bSemiautoTrigger=True
     EvolvedName="Bubble Darel"
     EvolvedBelt="WHO THE FUCK IS DARREL?"
     AimDecayMult=17.000000
     FiringSystemOperation=2
     PenetrationHitDamage=0
     RicochetHitDamage=2
     ClipsLabel="TUBES"
     
     //MADDERS: Shotguns are A-OK to use precision style mods on now.
     bCanHaveLaser=True
     bCanHaveModBaseAccuracy=True
     bCanHaveModAccurateRange=True
     
     //MADDERS: Shotgun info. 0.25 is the vanilla equivalent.
     MinSpreadAcc=0.075000 //Used to be 0.15, but holy shit the med range aim.
     BaseAccuracy=0.600000 //Used to be 0.6.
     MaximumAccuracy=0.5000000
     FalloffStartRange=1200
     
     //HandSkinIndex=0 //MADDERS: Obsolete
     OverrideNumProj=12
     OverrideAnimRate=1.250000
     OverrideReloadAnimRate=1.000000
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconShotgunRotated'
     
     RecoilIndices(0)=(X=25.000000,Y=75.000000)
     RecoilIndices(1)=(X=20.000000,Y=80.000000)
     RecoilIndices(2)=(X=15.000000,Y=85.000000)
     RecoilIndices(3)=(X=20.000000,Y=80.000000)
     NumRecoilIndices=4
     
     SelectTilt(0)=(X=-15.000000,Y=90.000000)
     SelectTilt(1)=(X=20.000000,Y=-35.000000)
     SelectTilt(2)=(X=-30.000000,Y=60.000000)
     SelectTilt(3)=(X=30.000000,Y=-15.000000)
     SelectTiltIndices=4
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.250000
     SelectTiltTimer(2)=0.575000
     SelectTiltTimer(3)=0.800000
     DownTilt(0)=(X=40.000000,Y=-25.000000)
     DownTilt(1)=(X=25.000000,Y=-40.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.500000
     
     ReloadBeginTilt(0)=(X=-25.000000,Y=-15.000000)
     ReloadBeginTilt(1)=(X=-15.000000,Y=-25.000000)
     ReloadBeginTiltIndices=2
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.450000
     
     ReloadTilt(0)=(X=-30.000000,Y=10.000000)
     ReloadTilt(1)=(X=30.000000,Y=-10.000000)
     ReloadTilt(2)=(X=0.000000,Y=0.000000)
     ReloadTiltIndices=3
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.250000
     ReloadTiltTimer(2)=0.500000
     
     ReloadEndTilt(0)=(X=15.000000,Y=25.000000)
     ReloadEndTilt(1)=(X=25.000000,Y=15.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.450000
     
     ShootTilt(0)=(X=-30.000000,Y=60.000000)
     ShootTilt(1)=(X=45.000000,Y=-75.000000)
     ShootTilt(2)=(X=-30.000000,Y=60.000000)
     ShootTilt(3)=(X=30.000000,Y=-15.000000)
     ShootTiltIndices=4
     ShootTiltTimer(0)=0.100000
     ShootTiltTimer(1)=0.275000
     ShootTiltTimer(2)=0.625000
     ShootTiltTimer(3)=0.825000
     
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=0.300000
     reloadTime=3.000000
     HitDamage=2
     maxRange=4800
     AccurateRange=2400
     AmmoNames(0)=Class'DeusEx.AmmoShell'
     AmmoNames(1)=Class'DeusEx.AmmoSabot'
     AmmoNames(2)=Class'DeusEx.AmmoTaserSlug'
     ProjectileNames(2)=Class'DeusEx.TaserSlug'
     AreaOfEffect=AOE_Cone
     recoilStrength=1.350000 //MADDERS: Buffed because of our small impulse period.
     mpReloadTime=0.500000
     mpHitDamage=9
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=1200
     mpReloadCount=6
     mpPickupAmmoCount=12
     bCanHaveModReloadCount=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.AmmoShell'
     ReloadCount=4
     PickupAmmoCount=4
     bInstantHit=True
     FireOffset=(X=-11.000000,Y=4.000000,Z=13.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.SawedOffShotgunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReload'
     SelectSound=Sound'DeusExSounds.Weapons.SawedOffShotgunSelect'
     InventoryGroup=6
     bNameCaseSensitive=False
     ItemName="Sawed-off Shotgun"
     PlayerViewOffset=(X=11.000000,Y=-4.000000,Z=-13.000000)
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
     invSlotsX=3
     Description="The sawed-off, pump-action shotgun features a truncated barrel resulting in a wide spread at close range and will accept either buckshot or sabot shells."
     beltDescription="SAWED-OFF"
     Mesh=LodMesh'DeusExItems.ShotgunPickup'
     CollisionRadius=12.000000
     CollisionHeight=0.900000
     Mass=5.500000
     Buoyancy=2.750000
}
