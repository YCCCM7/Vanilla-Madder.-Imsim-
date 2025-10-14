//=============================================================================
// WeaponRifle.
//=============================================================================
class WeaponRifle extends DeusExWeapon;

var float mpNoScopeMult;

function bool VMDIsTwoHandedWeapon()
{
	return true;
}

simulated function PlayFiringSound()
{
	local Sound OldFire;
	
	if (Ammo3006AP(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'RifleFire3006AP';
		Super.PlayFiringSound();
		FireSound = OldFire;
	}
	else if ((Ammo3006Tranq(AmmoType) != None) && (!bHasSilencer))
	{
		OldFire = FireSound;
		FireSound = Sound'RifleFire3006Tranq';
		Super.PlayFiringSound();
		FireSound = OldFire;
	}
	else if (Ammo3006HEAT(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'RifleFire3006HEAT';
		Super.PlayFiringSound();
		FireSound = OldFire;
	}
	else
	{
		Super.PlayFiringSound();
	}
}

//Update penetration effects accordingly.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	local float EvoMod;
	
	EvoMod = 1.0;
	if (bHasEvolution) EvoMod = 1.75;
	
	if (Ammo3006AP(AmmoType) != None)
	{
     		PenetrationHitDamage = 25 * EvoMod;
     		RicochetHitDamage = 10 * EvoMod;
		HitDamage = Default.HitDamage * EvoMod;
		AmmoDamageMultiplier = 1.0 * EvoMod;
	}
	if (Ammo3006Tranq(AmmoType) != None)
	{
     		PenetrationHitDamage = 0 * EvoMod;
     		RicochetHitDamage = 0 * EvoMod;
		HitDamage = Default.HitDamage * EvoMod * 0.5;
		AmmoDamageMultiplier = 0.5 * EvoMod;
	}
	else if (Ammo3006HEAT(AmmoType) != None)
	{
     		PenetrationHitDamage = 20 * EvoMod;
     		RicochetHitDamage = 0 * EvoMod;
		HitDamage = Default.HitDamage * EvoMod;
		AmmoDamageMultiplier = 1.0 * EvoMod;
	}
	else
	{
     		PenetrationHitDamage = Default.PenetrationHitDamage * EvoMod;
     		RicochetHitDamage = Default.RicochetHitDamage * EvoMod;
		HitDamage = Default.HitDamage * EvoMod;
		AmmoDamageMultiplier = 1.0 * EvoMod;
	}
	ShotTime = Default.ShotTime;
}

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
      		bHasMuzzleFlash = True;
      		ReloadCount = 1;
      		ReloadTime = ShotTime;
	}
}

function VMDDropEmptyMagazine(int THand)
{
	local vector TOffset, TVect, X, Y, Z;
	local VMDWeaponMagazine Mag;
	
	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	Y *= -1 * THand;
	TOffset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
	TVect = 0.8 * Owner.CollisionHeight * Z;
	TOffset.Z += TVect.Z;
	
	if (VMDBufferPawn(Owner) != None)
	{
		TOffset = VMDBufferPawn(Owner).GetShellOffset();
	}
	
	Mag = Spawn(class'SniperRifleMagazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * -0.45 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
	}
}

defaultproperties
{
     bStationaryFiringOnly=True
     DrawAnimFrames=10
     DrawAnimRate=24.000000
     HolsterAnimFrames=2
     HolsterAnimRate=8.000000
     
     BulletHoleSize=0.225000
     BaseAccuracy=0.450000
     bSemiautoTrigger=False
     bBoltAction=True
     BoltStartSound=Sound'DeusExSounds.Weapons.RifleReloadBegin'
     BoltEndSound=Sound'DeusExSounds.Weapons.RifleSelect'
     BoltStartSeq=ReloadBegin
     BoltEndSeq=ReloadEnd
     //HandSkinIndex=0
     EvolvedName="Antimatter Gun"
     EvolvedBelt="ZOOMY BOOMY"
     AimDecayMult=27.500000
     BoltActionRate=1.000000
     OverrideAnimRate=1.650000
     AmmoNames(0)=Class'DeusEx.Ammo3006'
     AmmoNames(1)=Class'DeusEx.Ammo3006Tranq' //Formerly Ammo3006AP. Redux, baby.
     AmmoNames(2)=Class'DeusEx.Ammo3006HEAT'
     FiringSystemOperation=2
     PenetrationHitDamage=15
     RicochetHitDamage=5
     ClipsLabel="MAGS"
     ScopeFOV=16
     SecondaryScopeFOV=8
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconRifleRotated'
     
     RecoilIndices(0)=(X=15.000000,Y=85.000000)
     NumRecoilIndices=1
     
     SelectTilt(0)=(X=40.000000,Y=60.000000)
     SelectTilt(1)=(X=50.000000,Y=30.000000)
     SelectTilt(2)=(X=40.000000,Y=-40.000000)
     SelectTiltIndices=3
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.250000
     SelectTiltTimer(2)=0.700000
     DownTilt(0)=(X=15.000000,Y=-25.000000)
     DownTiltIndices=1
     DownTiltTimer(0)=0.000000
     
     ReloadBeginTilt(0)=(X=0.000000,Y=0.000000)
     ReloadBeginTilt(1)=(X=-45.000000,Y=-15.000000)
     ReloadBeginTilt(2)=(X=-45.000000,Y=15.000000)
     ReloadBeginTilt(3)=(X=-20.000000,Y=10.000000)
     ReloadBeginTiltIndices=4
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.650000
     ReloadBeginTiltTimer(2)=0.750000
     ReloadBeginTiltTimer(3)=0.850000
     
     ReloadTilt(0)=(X=2.500000,Y=12.500000)
     ReloadTilt(1)=(X=-2.500000,Y=-12.500000)
     ReloadTiltIndices=2
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     
     ReloadEndTilt(0)=(X=45.000000,Y=-15.000000)
     ReloadEndTilt(1)=(X=45.000000,Y=15.000000)
     ReloadEndTilt(2)=(X=0.000000,Y=0.000000)
     ReloadEndTiltIndices=3
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.300000
     ReloadEndTiltTimer(2)=0.700000
     
     mpNoScopeMult=0.350000
     LowAmmoWaterMark=6
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=0.500000 //Buffed from 1.5.
     reloadTime=2.000000
     HitDamage=25
     maxRange=48000 //MADDERS, used to be 48K and 28.8K, respectively.
     AccurateRange=4800 //Used to be 6400, before nerf for fun bullet drop.
     bCanHaveScope=True
     bHasScope=True
     bCanHaveLaser=True
     bCanHaveSilencer=True
     bHasMuzzleFlash=False
     recoilStrength=0.400000
     bUseWhileCrouched=False
     mpReloadTime=2.000000
     mpHitDamage=25
     mpAccurateRange=28800
     mpMaxRange=28800
     mpReloadCount=6
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.Ammo3006'
     ReloadCount=6
     PickupAmmoCount=6
     bInstantHit=True
     FireOffset=(X=-20.000000,Y=2.000000,Z=10.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.RifleFire'
     AltFireSound=Sound'DeusExSounds.Weapons.RifleReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.RifleReload'
     SelectSound=Sound'DeusExSounds.Weapons.RifleSelect'
     InventoryGroup=5
     bNameCaseSensitive=False
     ItemName="Sniper Rifle"
     PlayerViewOffset=(X=20.000000,Y=-2.000000,Z=-10.000000)
     PlayerViewMesh=LodMesh'VMDSniperRifle'
     LeftPlayerViewMesh=LodMesh'SniperRifleLeft'
     PickupViewMesh=LodMesh'DeusExItems.SniperRiflePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.SniperRifle3rd'
     LeftThirdPersonMesh=LodMesh'SniperRifle3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconRifle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconRifle'
     largeIconWidth=159
     largeIconHeight=47
     invSlotsX=4
     Description="The military sniper rifle is the superior tool for the interdiction of long-range targets. When coupled with the proven 30.06 round, a marksman can achieve tight groupings at better than 1 MOA (minute of angle) depending on environmental conditions."
     beltDescription="SNIPER"
     Mesh=LodMesh'DeusExItems.SniperRiflePickup'
     CollisionRadius=26.000000
     CollisionHeight=2.000000
     Mass=17.000000
     Buoyancy=8.500000
}
