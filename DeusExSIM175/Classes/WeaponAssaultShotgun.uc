//=============================================================================
// WeaponAssaultShotgun.
//=============================================================================
class WeaponAssaultShotgun extends DeusExWeapon;

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
	}
}

//Update penetration and ricochet damage.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (AmmoSabot(AmmoType) != None)
	{
     		PenetrationHitDamage = 2;
     		RicochetHitDamage = 1;
		BulletHoleSize = 0.175000;
	}
	else
	{
     		PenetrationHitDamage = Default.PenetrationHitDamage;
     		RicochetHitDamage = Default.RicochetHitDamage;
		BulletHoleSize = 0.075000;
	}
}

function int VMDGetCorrectNumProj( int In )
{
 	if (AmmoSabot(AmmoType) != None) return 1;
 	
 	if (OverrideNumProj < 1)
 	{
 		return In;
 	}
 	return OverrideNumProj;
}

function int VMDGetCorrectHitDamage( int In )
{
 	//MADDERS: Always return full damage with sabot. We'll truncate like a mother fucker at all times.
 	if (AmmoSabot(AmmoType) != None) return Default.HitDamage*OverrideNumProj;
 	return Max(int(Default.HitDamage > 0), In);
}

defaultproperties
{
     BulletHoleSize=0.075000
     NumFiringModes=0
     FiringModes(0)="Semi Auto"
     FiringModes(1)="Full Auto "
     ModeNames(0)="Semo Auto"
     ModeNames(1)="Full Auto"
     bSingleLoaded=False //Used to be single.
     SingleLoadSound=Sound'AssaultShotgunSingleLoad'
     EvolvedName="Official Jackhammer"
     EvolvedBelt="JACK OFF"
     AimDecayMult=8.500000 //Used to be 12.5 before the buff
     FiringSystemOperation=2
     PenetrationHitDamage=0
     RicochetHitDamage=2
     ClipsLabel="BELTS"
     GrimeRateMult=0.650000
     
     //MADDERS: Shotguns are A-OK to use precision style mods on now.
     bCanHaveLaser=True
     bCanHaveModBaseAccuracy=True
     bCanHaveModAccurateRange=True
     
     //MADDERS: Shotgun info. 0.25 is the vanilla equivalent.
     MinSpreadAcc=0.075000 //Used to be 0.2, but holy shit the med range accuracy. Then 0.1 before buff lmao.
     BaseAccuracy=0.600000 //Used to be 0.8, then 0.7 pre-overhaul, then 6.25 before buff.
     MaximumAccuracy=0.5500000
     
     //MADDERS: Actual spam cannon.
     //HandSkinIndex=1
     //ProjectileClass=class'RocketGEP'
     OverrideNumProj=10
     OverrideAnimRate=2.333000
     OverrideReloadAnimRate=0.750000
     bInstantHit=True
     bSemiautoTrigger=True
     bAutomatic=False
     
     RecoilIndices(0)=(X=15.000000,Y=85.000000)
     RecoilIndices(1)=(X=10.000000,Y=90.000000)
     RecoilIndices(2)=(X=15.000000,Y=85.000000)
     RecoilIndices(3)=(X=20.000000,Y=80.000000)
     NumRecoilIndices=4
     
     SelectTilt(0)=(X=30.000000,Y=40.000000)
     SelectTilt(1)=(X=40.000000,Y=20.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.525000
     DownTilt(0)=(X=10.000000,Y=-25.000000)
     DownTiltIndices=1
     DownTiltTimer(0)=0.000000
     
     ReloadBeginTilt(0)=(X=0.000000,Y=0.000000)
     ReloadBeginTilt(1)=(X=-40.000000,Y=-30.000000)
     ReloadBeginTilt(2)=(X=-30.000000,Y=-35.000000)
     ReloadBeginTiltIndices=3
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.650000
     ReloadBeginTiltTimer(2)=0.750000
     
     ReloadTilt(0)=(X=5.000000,Y=10.000000)
     ReloadTilt(1)=(X=10.000000,Y=5.000000)
     ReloadTilt(2)=(X=-10.000000,Y=-5.000000)
     ReloadTilt(3)=(X=-5.000000,Y=-10.000000)
     ReloadTiltIndices=4
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.250000
     ReloadTiltTimer(2)=0.500000
     ReloadTiltTimer(3)=0.750000
     
     ReloadEndTilt(0)=(X=20.000000,Y=30.000000)
     ReloadEndTilt(1)=(X=30.000000,Y=20.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.450000
     
     LowAmmoWaterMark=10
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     ShotTime=0.300000 //Used to be 0.7.
     reloadTime=3.500000 //Down from 4.5, but we've counterbalanced this quite a lot already.
     HitDamage=2
     maxRange=4800
     AccurateRange=2400
     AmmoNames(0)=Class'DeusEx.AmmoShell'
     AmmoNames(1)=Class'DeusEx.AmmoSabot'
     //ProjectileNames(0)=Class'DeusEx.RocketGEP'
     AreaOfEffect=AOE_Cone
     recoilStrength=0.700000
     mpReloadTime=0.500000
     mpHitDamage=5
     mpBaseAccuracy=0.200000
     mpAccurateRange=1800
     mpMaxRange=1800
     mpReloadCount=24
     bCanHaveModReloadCount=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.AmmoShell'
     ReloadCount=10
     PickupAmmoCount=10
     FireOffset=(X=-30.000000,Y=10.000000,Z=12.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.AssaultShotgunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultShotgunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultShotgunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultShotgunSelect'
     InventoryGroup=7
     bNameCaseSensitive=False
     ItemName="Assault Shotgun"
     ItemArticle="an"
     PlayerViewOffset=(Y=-10.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.AssaultShotgun'
     PickupViewMesh=LodMesh'DeusExItems.AssaultShotgunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.AssaultShotgun3rd'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconAssaultShotgun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultShotgun'
     largeIconWidth=99
     largeIconHeight=55
     invSlotsX=2
     invSlotsY=2
     Description="The assault shotgun (sometimes referred to as a 'street sweeper') combines the best traits of a normal shotgun with a fully automatic feed that can clear an area of hostiles in a matter of seconds. Particularly effective in urban combat, the assault shotgun accepts either buckshot or sabot shells."
     beltDescription="SHOTGUN"
     Mesh=LodMesh'DeusExItems.AssaultShotgunPickup'
     CollisionRadius=15.000000
     CollisionHeight=8.000000
     Mass=30.000000
}
