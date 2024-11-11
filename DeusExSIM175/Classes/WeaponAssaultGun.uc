//=============================================================================
// WeaponAssaultGun.
//=============================================================================
class WeaponAssaultGun extends DeusExWeapon;

var float mpRecoilStrength;

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
		
		// Tuned for advanced -> master skill system (Monte & Ricardo's number) client-side
		recoilStrength = 0.75;
	}
}

//=========================
//MADDERS, 12/27/20: This is now used as an example of how to setup parallel firing feeds and other nonsense.
//=========================

function bool VMDHandleParallelAmmoFeed(class<Ammo> RelAmmoType, Ammo NewAmmo, int AmmoIndex)
{
	if ((ClipCount >= 0) && (VMDIsQuickSwapAmmo(RelAmmoType)))
	{
		//MADDERS: Hack for 20mm preservation.
		Last20mmCount = NewAmmo.AmmoAmount;
		ClipCount -= NewAmmo.AmmoAmount;
	}
	else if ((RelAmmoType == class'Ammo762mm') && (VMDIsQuickSwapAmmoFA(AmmoType)))
	{
		//MADDERS: Hack for denying cycle ammo during firing.
		if (VMDShotTimeProgression() < 1.0) return False;
		
		ClipCount += AmmoType.AmmoAmount;
	}
	
	return true;
}

function Sound VMDGetIntendedFireSound(Ammo NewAmmo)
{
	if (VMDIsQuickSwapAmmoFA(NewAmmo)) return Sound'AssaultGunFire20mm';
	
	return Default.FireSound;
}

function bool VMDHasSelectiveFiringObjection()
{
	if (VMDIsQuickSwapAmmoFA(AmmoType)) return true;
	
	return false;
}

function bool VMDHasParallelAmmoFeed()
{
	return true;
}

function bool VMDHasReloadObjection()
{
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).TaseDuration > 0))
		return true;
	
	//MADDERS: Cockblock 20mm reloads.
	if (VMDIsQuickSwapAmmoFA(AmmoType))
		return true;
	
	return false;
}

//Update bolt action accordingly.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	//MADDERS: Change our fire sound, operation type, and low ammo water mark.
	if (Ammo762mm(AmmoType) != None)
	{
		SilencedFireSound = Default.SilencedFireSound;
		bBoltAction = false;
     		LowAmmoWaterMark = 30;
	}
	else
	{
		//MADDERS: Hack for silenced GL handling.
 		SilencedFireSound = Sound'AssaultGunFire20mm';
		bBoltAction = true;
    		LowAmmoWaterMark = 4;
	}
	ShotTime = Default.ShotTime;
}

defaultproperties
{
     BulletHoleSize=0.125000
     SemiautoFireSound=Sound'AssaultGunSemi'
     SilencedFireSound=Sound'AssaultGunFireSilenced'
     NumFiringModes=2
     FiringModes(0)="Burst Fire"
     FiringModes(1)="Semi Auto"
     FiringModes(2)="Full Auto"
     ModeNames(0)="Burst Fire"
     ModeNames(1)="Semi Auto"
     ModeNames(2)="Full Auto"
     EvolvedName="Assault Weapon"
     EvolvedBelt="BANNED"
     AimDecayMult=4.000000 //MADDERS: Used to be 8.0, but then recoil reduction nerf happened.
     AimFocusMult=1.250000
     FiringSystemOperation=1
     PenetrationHitDamage=2
     RicochetHitDamage=2
     GrimeRateMult=0.400000
     
     //HandSkinIndex=0
     NPCOverrideAnimRate=1.000000 //1/5th the previous rate.
     OverrideAnimRate=1.400000 //Used to be 0.8
     bSemiAutoTrigger=False
     bBurstFire=True
     
     BoltStartSound=Sound'DeusExSounds.Weapons.SawedOffShotgunReload'
     BoltEndSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
     BoltActionDelay=1.200000
     BoltStartSeq=ReloadBegin
     BoltDelaySeq=Reload
     BoltEndSeq=ReloadEnd
     BoltActionRate=1.250000
     ClipsLabel="MAGS"
     
     //MADDERS: We're nerfing our accurate range, since it's way too good with falloff.
     maxRange=9600
     AccurateRange=3600 //Used to be 4800
     
     RecoilIndices(0)=(X=20.000000,Y=80.000000)
     RecoilIndices(1)=(X=-10.000000,Y=90.000000)
     RecoilIndices(2)=(X=15.000000,Y=85.000000)
     RecoilIndices(3)=(X=-20.000000,Y=80.000000)
     RecoilIndices(4)=(X=20.000000,Y=80.000000)
     RecoilIndices(5)=(X=-15.000000,Y=85.000000)
     RecoilIndices(6)=(X=10.000000,Y=90.000000)
     NumRecoilIndices=7
     
     SelectTilt(0)=(X=-30.000000,Y=-35.000000)
     SelectTilt(1)=(X=-6.000000,Y=-7.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.800000
     DownTilt(0)=(X=15.000000,Y=30.000000)
     DownTilt(1)=(X=30.000000,Y=15.000000)
     DownTilt(2)=(X=15.000000,Y=-30.000000)
     DownTiltIndices=3
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.200000
     DownTiltTimer(2)=0.400000
     
     ReloadBeginTilt(0)=(X=-35.000000,Y=-20.000000)
     ReloadBeginTilt(1)=(X=-20.000000,Y=-35.000000)
     ReloadBeginTiltIndices=2
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.500000
     
     //Down-right to up-left.
     ReloadTilt(0)=(X=20.000000,Y=10.000000)
     ReloadTilt(1)=(X=-20.000000,Y=-10.000000)
     ReloadTilt(2)=(X=20.000000,Y=10.000000)
     ReloadTilt(3)=(X=-20.000000,Y=-10.000000)
     ReloadTiltIndices=4
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.250000
     ReloadTiltTimer(2)=0.500000
     ReloadTiltTimer(3)=0.750000
     
     ReloadEndTilt(0)=(X=20.000000,Y=35.000000)
     ReloadEndTilt(1)=(X=35.000000,Y=20.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.500000
     
     LowAmmoWaterMark=30
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     //Concealability=CONC_Visual
     bAutomatic=True //USED TO BE TRUE!
     ShotTime=0.100000 //Used to be 0.2, and before that 0.1 in vanilla
     reloadTime=3.000000
     HitDamage=3
     BaseAccuracy=0.700000
     bCanHaveLaser=True
     bCanHaveSilencer=True
     AmmoNames(0)=Class'DeusEx.Ammo762mm'
     AmmoNames(1)=Class'DeusEx.Ammo20mm'
     ProjectileNames(1)=Class'DeusEx.HECannister20mm'
     recoilStrength=0.750000
     MinWeaponAcc=0.200000
     mpReloadTime=0.500000
     mpHitDamage=9
     mpBaseAccuracy=1.000000
     mpAccurateRange=2400
     mpMaxRange=2400
     mpReloadCount=30
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.Ammo762mm'
     ReloadCount=30
     PickupAmmoCount=30
     bInstantHit=True
     FireOffset=(X=-16.000000,Y=5.000000,Z=11.500000)
     shakemag=200.000000
     FireSound=Sound'DeusExSounds.Weapons.AssaultGunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultGunSelect'
     InventoryGroup=4
     bNameCaseSensitive=False
     ItemName="Assault Rifle"
     ItemArticle="an"
     PlayerViewOffset=(X=16.000000,Y=-5.000000,Z=-11.500000)
     PlayerViewMesh=LodMesh'DeusExItems.AssaultGun'
     PickupViewMesh=LodMesh'DeusExItems.AssaultGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.AssaultGun3rd'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconAssaultGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultGun'
     largeIconWidth=94
     largeIconHeight=65
     invSlotsX=2
     invSlotsY=2
     Description="The 7.62x51mm assault rifle is designed for close-quarters combat, utilizing a shortened barrel and 'bullpup' design for increased maneuverability. An additional underhand 20mm HE launcher increases the rifle's effectiveness against a variety of targets."
     beltDescription="ASSAULT"
     Mesh=LodMesh'DeusExItems.AssaultGunPickup'
     CollisionRadius=15.000000
     CollisionHeight=1.100000
     Mass=30.000000
}
