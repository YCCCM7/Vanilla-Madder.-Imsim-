//=============================================================================
// WeaponStealthPistol.
//=============================================================================
class WeaponStealthPistol extends DeusExWeapon;

simulated function PlayFiringSound()
{
	local Sound OldFire;
	
	if (Ammo10mmHEAT(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'StealthPistolFire10mmHEAP';
		Super.PlayFiringSound();
		FireSound = OldFire;
	}
	else
	{
		Super.PlayFiringSound();
	}
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
	}
}

//Update ballistics accordingly.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (Ammo10mmHEAT(AmmoType) != None)
	{
		AmmoDamageMultiplier = 1.0;
		HitDamage = Default.HitDamage;
     		PenetrationHitDamage = 8;
     		RicochetHitDamage = 0;
	}
	else if (Ammo10mmGasCap(AmmoType) != None)
	{
		AmmoDamageMultiplier = (8.0 / Default.HitDamage);
		HitDamage = 8;
     		PenetrationHitDamage = 0;
     		RicochetHitDamage = 8;
	}
	else
	{
		AmmoDamageMultiplier = 1.0;
		HitDamage = Default.HitDamage;
     		PenetrationHitDamage = Default.PenetrationHitDamage;
     		RicochetHitDamage = Default.RicochetHitDamage;
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
	
	Mag = Spawn(class'StealthPistolMagazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * -0.15 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
	}
}

defaultproperties
{
     DrawAnimFrames=6
     DrawAnimRate=12.000000
     HolsterAnimFrames=5
     HolsterAnimRate=12.000000
     
     AmmoNames(0)=Class'DeusEx.Ammo10mm'
     AmmoNames(1)=Class'DeusEx.Ammo10mmGasCap'
     AmmoNames(2)=Class'DeusEx.Ammo10mmHEAT'
     
     Mass=2.400000
     Buoyancy=1.200000
     
     BulletHoleSize=0.150000
     //HandSkinIndex=1
     //MADDERS: Make this thing a full auto pistol (low ROF) with long ass reloads.
     OverrideAnimRate=1.000000
     ShotTime=0.150000
     bSemiautoTrigger=True
     bAutomatic=False
     BaseAccuracy=0.750000
     ReloadCount=10
     ReloadTime=1.500000
     EvolvedName="Super Stealth SMG"
     EvolvedBelt="SS SMG"
     AimDecayMult=16.000000
     FiringSystemOperation=1
     PenetrationHitDamage=7
     RicochetHitDamage=4
     ClipsLabel="MAGS"
     GrimeRateMult=0.800000
     
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
     DownTilt(0)=(X=-30.000000,Y=-15.000000)
     DownTilt(1)=(X=-15.000000,Y=-30.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.450000
     
     ReloadBeginTilt(0)=(X=20.000000,Y=30.000000)
     ReloadBeginTilt(1)=(X=15.000000,Y=-15.000000)
     ReloadBeginTilt(2)=(X=25.000000,Y=25.000000)
     ReloadBeginTilt(3)=(X=-75.000000,Y=-95.000000)
     ReloadBeginTilt(4)=(X=-65.000000,Y=-105.000000)
     ReloadBeginTiltIndices=5
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.250000
     ReloadBeginTiltTimer(2)=0.375000
     ReloadBeginTiltTimer(3)=0.650000
     ReloadBeginTiltTimer(4)=0.800000
     
     ReloadTilt(0)=(X=5.000000,Y=10.000000)
     ReloadTilt(1)=(X=-5.000000,Y=-10.000000)
     ReloadTiltIndices=2
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     
     ReloadEndTilt(0)=(X=20.000000,Y=30.000000)
     ReloadEndTilt(1)=(X=30.000000,Y=20.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.450000
     
     bHasSilencer=True
     NoiseLevel=1.000000
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_All //MADDERS: Keeping this as all, as the signature stealth gun
     //ShotTime=0.150000
     //reloadTime=1.500000
     HitDamage=10
     maxRange=4800
     AccurateRange=1200
     //BaseAccuracy=0.800000
     bCanHaveScope=True
     ScopeFOV=20 //MADDERS, 1/9/21: Lowered from 25, because FOV succc.
     bCanHaveLaser=True
     recoilStrength=0.250000 //Up from 0.1
     mpReloadTime=1.500000
     mpHitDamage=12
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=1200
     mpReloadCount=12
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True //MADDERS, 10/15/21: Re-introduced since bloom is a thing
     AmmoName=Class'DeusEx.Ammo10mm'
     PickupAmmoCount=10
     bInstantHit=True
     FireOffset=(X=-24.000000,Y=10.000000,Z=14.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.StealthPistolFire'
     AltFireSound=Sound'DeusExSounds.Weapons.StealthPistolReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.StealthPistolReload'
     SelectSound=Sound'DeusExSounds.Weapons.StealthPistolSelect'
     InventoryGroup=3
     bNameCaseSensitive=False
     ItemName="Stealth Pistol"
     PlayerViewOffset=(X=24.000000,Y=-10.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.StealthPistol'
     LeftPlayerViewMesh=LodMesh'StealthPistolLeft'
     PickupViewMesh=LodMesh'DeusExItems.StealthPistolPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.StealthPistol3rd'
     LeftThirdPersonMesh=LodMesh'StealthPistol3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconStealthPistol'
     largeIcon=Texture'DeusExUI.Icons.LargeIconStealthPistol'
     largeIconWidth=47
     largeIconHeight=37
     Description="The stealth pistol is a variant of the standard 10mm pistol with a larger clip and integrated silencer designed for wet work at very close ranges."
     beltDescription="STEALTH"
     Mesh=LodMesh'DeusExItems.StealthPistolPickup'
     CollisionRadius=8.000000
     CollisionHeight=0.800000
}
