//=============================================================================
// WeaponPistol.
//=============================================================================
class WeaponPistol extends DeusExWeapon;

simulated function PlayFiringSound()
{
	local Sound OldFire;
	
	if (Ammo10mmHEAT(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'PistolFire10mmHEAP';
		Super.PlayFiringSound();
		FireSound = OldFire;
	}
	else
	{
		Super.PlayFiringSound();
	}
}

function bool VMDGetHasSilencer()
{
	if (Ammo10mmHEAT(AmmoType) != None) return false;
	return bHasSilencer;
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
	local float EvoMod;
	
	EvoMod = 1.0;
	if (bHasEvolution) EvoMod = 1.5;
	
	if (Ammo10mmHEAT(AmmoType) != None)
	{
		HitDamage = Default.HitDamage*EvoMod;
     		PenetrationHitDamage = 11*EvoMod;
     		RicochetHitDamage = 0*EvoMod;
	}
	else if (Ammo10mmGasCap(AmmoType) != None)
	{
		HitDamage = 10*EvoMod;
     		PenetrationHitDamage = 0*EvoMod;
     		RicochetHitDamage = 10*EvoMod;
	}
	else
	{
		HitDamage = Default.HitDamage*EvoMod;
     		PenetrationHitDamage = Default.PenetrationHitDamage*EvoMod;
     		RicochetHitDamage = Default.RicochetHitDamage*EvoMod;
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
	
	Mag = Spawn(class'PistolMagazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * -0.15 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
	}
}

defaultproperties
{
     AmmoNames(0)=Class'DeusEx.Ammo10mm'
     AmmoNames(1)=Class'DeusEx.Ammo10mmGasCap'
     AmmoNames(2)=Class'DeusEx.Ammo10mmHEAT'

     BulletHoleSize=0.175000
     bSemiautoTrigger=True
     //HandSkinIndex=1
     //MADDERS: Set this up for the silencer gag.
     //bCanHavesilencer=True
     OverrideAnimRate=1.600000
     EvolvedName="Six Gun"
     EvolvedBelt="YIPPY KAY YAY"
     AimDecayMult=12.500000
     FiringSystemOperation=2
     PenetrationHitDamage=8
     RicochetHitDamage=4
     ClipsLabel="MAGS"
     
     RecoilIndices(0)=(X=20.000000,Y=80.000000)
     RecoilIndices(1)=(X=-25.000000,Y=75.000000)
     RecoilIndices(2)=(X=15.000000,Y=85.000000)
     RecoilIndices(3)=(X=-20.000000,Y=80.000000)
     RecoilIndices(4)=(X=20.000000,Y=80.000000)
     RecoilIndices(5)=(X=-15.000000,Y=85.000000)
     NumRecoilIndices=6
     
     SelectTilt(0)=(X=25.000000,Y=35.000000)
     SelectTilt(1)=(X=35.000000,Y=25.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.650000
     DownTilt(0)=(X=15.000000,Y=-25.000000)
     DownTiltIndices=1
     DownTiltTimer(0)=0.000000
     
     ReloadBeginTilt(0)=(X=20.000000,Y=30.000000)
     ReloadBeginTilt(1)=(X=15.000000,Y=-15.000000)
     ReloadBeginTilt(2)=(X=25.000000,Y=25.000000)
     ReloadBeginTilt(3)=(X=-85.000000,Y=-85.000000)
     ReloadBeginTilt(4)=(X=-75.000000,Y=-95.000000)
     ReloadBeginTiltIndices=5
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.250000
     ReloadBeginTiltTimer(2)=0.375000
     ReloadBeginTiltTimer(3)=0.650000
     ReloadBeginTiltTimer(4)=0.800000
     
     ReloadEndTilt(0)=(X=15.000000,Y=25.000000)
     ReloadEndTilt(1)=(X=25.000000,Y=15.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.450000
     
     LowAmmoWaterMark=6
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=0.500000 //Used to be 0.6, then 0.4.
     reloadTime=2.000000
     HitDamage=14
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=0.700000
     bCanHaveScope=True
     ScopeFOV=20 //MADDERS, 1/9/21: Lowered from 25, because FOV succc.
     bCanHaveLaser=True
     recoilStrength=0.600000
     mpReloadTime=2.000000
     mpHitDamage=20
     mpBaseAccuracy=0.200000
     mpAccurateRange=1200
     mpMaxRange=1200
     mpReloadCount=9
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.Ammo10mm'
     ReloadCount=6
     PickupAmmoCount=6
     bInstantHit=True
     FireOffset=(X=-22.000000,Y=10.000000,Z=14.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.PistolFire'
     CockingSound=Sound'DeusExSounds.Weapons.PistolReload'
     SelectSound=Sound'DeusExSounds.Weapons.PistolSelect'
     InventoryGroup=2
     bNameCaseSensitive=False
     ItemName="Pistol"
     PlayerViewOffset=(X=22.000000,Y=-10.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Glock'
     LeftPlayerViewMesh=LodMesh'GlockLeft'
     PickupViewMesh=LodMesh'DeusExItems.GlockPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Glock3rd'
     LeftThirdPersonMesh=LodMesh'Glock3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconPistol'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPistol'
     largeIconWidth=46
     largeIconHeight=28
     Description="A standard 10mm pistol."
     beltDescription="PISTOL"
     Mesh=LodMesh'DeusExItems.GlockPickup'
     CollisionRadius=7.000000
     CollisionHeight=1.000000
     Mass=3.900000
     Buoyancy=1.950000
}
