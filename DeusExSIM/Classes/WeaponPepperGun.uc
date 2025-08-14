//=============================================================================
// WeaponPepperGun.
//=============================================================================
class WeaponPepperGun extends DeusExWeapon;

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
	}
}

function bool VMDIndexIsCloakException(int TestIndex)
{
	if (TestIndex == 1 || TestIndex == 2) return true;
	if (TestIndex == MuzzleFlashIndex) return true;
	return false;
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
	
	Mag = Spawn(class'PeppergunMagazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * -0.2 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
	}
}

defaultproperties
{
     DrawAnimFrames=18
     DrawAnimRate=19.000000
     HolsterAnimFrames=6
     HolsterAnimRate=15.000000
     
     MuzzleFlashIndex=7
     HandSkinIndex(0)=0
     HandSkinIndex(1)=4
     EvolvedName="Halo Gun"
     EvolvedBelt="COMBAT EVOLVED"
     AimDecayMult=20.000000
     ClipsLabel="CARTS"
     
     RecoilStrength=0.000000
     AimDecayMult=0.000000 //Don't actually decay aim on this one during firing.
     
     SelectTilt(0)=(X=30.000000,Y=40.000000)
     SelectTilt(1)=(X=40.000000,Y=20.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.525000
     DownTilt(0)=(X=25.000000,Y=-15.000000)
     DownTilt(1)=(X=15.000000,Y=-25.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.500000
     
     ReloadBeginTilt(0)=(X=-40.000000,Y=-20.000000)
     ReloadBeginTilt(1)=(X=-30.000000,Y=-40.000000)
     ReloadBeginTiltIndices=2
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.500000
     
     ReloadTilt(0)=(X=20.000000,Y=10.000000)
     ReloadTilt(1)=(X=-20.000000,Y=-10.000000)
     ReloadTilt(2)=(X=20.000000,Y=10.000000)
     ReloadTilt(3)=(X=-20.000000,Y=-10.000000)
     ReloadTiltIndices=4
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.250000
     ReloadTiltTimer(2)=0.500000
     ReloadTiltTimer(3)=0.750000
     
     ReloadEndTilt(0)=(X=35.000000,Y=35.000000)
     ReloadEndTiltIndices=1
     ReloadEndTiltTimer(0)=0.000000
     
     ShootTilt(0)=(X=75.000000,Y=-7.500000)
     ShootTilt(1)=(X=-75.000000,Y=7.500000)
     ShootTiltIndices=2
     ShootTiltTimer(0)=0.000000
     ShootTiltTimer(1)=0.500000
     
     LowAmmoWaterMark=50
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.200000
     EnemyEffective=ENMEFF_Organic
     EnviroEffective=ENVEFF_AirVacuum
     Concealability=CONC_Visual
     bAutomatic=True
     ShotTime=0.075000
     reloadTime=4.000000
     HitDamage=0
     maxRange=100
     AccurateRange=100
     BaseAccuracy=0.400000
     AreaOfEffect=AOE_Sphere
     bPenetrating=False
     StunDuration=15.000000
     bHasMuzzleFlash=False
     mpReloadTime=4.000000
     mpBaseAccuracy=0.700000
     mpAccurateRange=100
     mpMaxRange=100
     AmmoName=Class'DeusEx.AmmoPepper'
     ReloadCount=100
     PickupAmmoCount=100
     FireOffset=(X=8.000000,Y=4.000000,Z=14.000000)
     ProjectileClass=Class'DeusEx.TearGas'
     shakemag=10.000000
     FireSound=Sound'DeusExSounds.Weapons.PepperGunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.PepperGunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.PepperGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.PepperGunSelect'
     InventoryGroup=18
     bNameCaseSensitive=False
     ItemName="Pepper Gun"
     PlayerViewOffset=(X=16.000000,Y=-10.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExItems.PepperGun'
     LeftPlayerViewMesh=LodMesh'PepperGunLeft'
     PickupViewMesh=LodMesh'DeusExItems.PepperGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.PepperGun3rd'
     LeftThirdPersonMesh=LodMesh'PepperGun3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconPepperSpray'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPepperSpray'
     largeIconWidth=46
     largeIconHeight=40
     Description="The pepper gun will accept a number of commercially available riot control agents in cartridge form and disperse them as a fine aerosol mist that can cause blindness or blistering at short-range."
     beltDescription="PEPPER"
     Mesh=LodMesh'DeusExItems.PepperGunPickup'
     CollisionRadius=7.000000
     CollisionHeight=1.500000
     Mass=0.500000
     Buoyancy=0.250000
}
