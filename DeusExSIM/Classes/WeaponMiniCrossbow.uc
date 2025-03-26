//=============================================================================
// WeaponMiniCrossbow.
//=============================================================================
class WeaponMiniCrossbow extends DeusExWeapon;

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
      		PickupAmmoCount = mpReloadCount;
	}
}

// pinkmask out the arrow when we're out of ammo or the clip is empty
state NormalFire
{
	function BeginState()
	{
		if (ClipCount >= ReloadCount)
			MultiSkins[3] = Texture'PinkMaskTex';
		
		if ((AmmoType != None) && (AmmoType.AmmoAmount <= 0))
			MultiSkins[3] = Texture'PinkMaskTex';
		
		Super.BeginState();
	}
}

// unpinkmask the arrow when we reload
function Tick(float deltaTime)
{
	//MADDERS: Run this in render overlays.
	/*if (MultiSkins[3] != None)
	{
		if ((AmmoType != None) && (AmmoType.AmmoAmount > 0) && (ClipCount < ReloadCount))
		{
			MultiSkins[3] = None;
		}
	}*/
	Super.Tick(deltaTime);
}

//MADDERS: Joking aside, let's just get in and get out.
simulated event RenderOverlays( Canvas Can )
{
	local Texture OldTex;
	
	OldTex = Multiskins[3];
	Multiskins[3] = GetDartTexture();
	
	Super.RenderOverlays(Can);
	
	Multiskins[3] = OldTex;
}

function Texture GetDartTexture()
{
	if ((AmmoType == None) || (AmmoType.AmmoAmount <= 0) || (ClipCount >= ReloadCount))
	{
		return Texture'PinkMaskTex';
	}
	else if (AmmoDartFlare(AmmoType) != None)
	{
		return Texture'MinicrossbowTex2Flare';
	}
	else if (AmmoDartPoison(AmmoType) != None)
	{
		return Texture'MinicrossbowTex2Poison';
	}
	return Texture'MinicrossbowTex2Standard';
}

function float VMDGetCorrectHitDamage( float In )
{
	if (AmmoDartPoison(AmmoType) != None)
	{
		return 5.0;
	}
	else if (AmmoDartFlare(AmmoType) != None)
	{
		return 20.0;
	}
	else
	{
		return 20.0;
	}
}

defaultproperties
{
     PumpPurpose=1
     PumpStart=0.250000
     EvolvedName="Plus-Bow"
     EvolvedBelt="THICCC"
     bSemiautoTrigger=True
     HandSkinIndex=0
     AimDecayMult=20.000000
     FiringSystemOperation=1
     ClipsLabel="CLIPS"
     GrimeRateMult=1.250000
     OverrideAnimRate=1.350000
     
     RecoilStrength=1.400000
     AimDecayMult=0.000000 //Don't actually decay aim on this one during firing.
     RecoilDecayRate=7.000000
     
     RecoilIndices(0)=(X=10.000000,Y=-45.000000)
     RecoilIndices(1)=(X=15.000000,Y=-40.000000)
     RecoilIndices(2)=(X=20.000000,Y=-40.000000)
     RecoilIndices(3)=(X=15.000000,Y=-45.000000)
     NumRecoilIndices=4
     
     SelectTilt(0)=(X=20.000000,Y=30.000000)
     SelectTilt(1)=(X=30.000000,Y=15.000000)
     SelectTilt(2)=(X=0.000000,Y=0.000000)
     SelectTilt(3)=(X=10.000000,Y=-20.000000)
     SelectTilt(4)=(X=-10.000000,Y=20.000000)
     SelectTilt(5)=(X=-5.000000,Y=10.000000)
     SelectTilt(6)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=7
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.150000
     SelectTiltTimer(2)=0.300000
     SelectTiltTimer(3)=0.350000
     SelectTiltTimer(4)=0.450000
     SelectTiltTimer(5)=0.550000
     SelectTiltTimer(6)=0.650000
     DownTilt(0)=(X=-30.000000,Y=-15.000000)
     DownTilt(1)=(X=-15.000000,Y=-30.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.450000
     
     ReloadBeginTilt(0)=(X=-30.000000,Y=-15.000000)
     ReloadBeginTilt(1)=(X=-15.000000,Y=-30.000000)
     ReloadBeginTiltIndices=2
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.500000
     
     ReloadTilt(0)=(X=-10.000000,Y=10.000000)
     ReloadTilt(1)=(X=10.000000,Y=-10.000000)
     ReloadTiltIndices=2
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     
     ReloadEndTilt(0)=(X=15.000000,Y=30.000000)
     ReloadEndTilt(1)=(X=30.000000,Y=15.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.450000
     
     ShootTilt(0)=(X=0.000000,Y=0.000000)
     ShootTilt(1)=(X=-15.000000,Y=45.000000)
     ShootTiltIndices=2
     ShootTiltTimer(0)=0.150000
     ShootTiltTimer(1)=0.400000
     
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.000000
     EnemyEffective=ENMEFF_Organic
     Concealability=CONC_Visual //MADDERS: Used to be all
     ShotTime=0.800000
     reloadTime=2.000000
     HitDamage=15
     maxRange=1600
     AccurateRange=800
     BaseAccuracy=0.500000 //MADDERS, 8/5/24: Used to be 0.8, but then nerf to 2x spread width.
     bCanHaveScope=True
     ScopeFOV=15
     bCanHaveLaser=True
     bHasSilencer=True
     AmmoNames(0)=Class'DeusEx.AmmoDartPoison'
     AmmoNames(1)=Class'DeusEx.AmmoDart'
     AmmoNames(2)=Class'DeusEx.AmmoDartFlare'
     ProjectileNames(0)=Class'DeusEx.DartPoison'
     ProjectileNames(1)=Class'DeusEx.Dart'
     ProjectileNames(2)=Class'DeusEx.DartFlare'
     StunDuration=10.000000
     bHasMuzzleFlash=False
     mpReloadTime=0.500000
     mpHitDamage=30
     mpBaseAccuracy=0.100000
     mpAccurateRange=2000
     mpMaxRange=2000
     mpReloadCount=6
     mpPickupAmmoCount=6
     bCanHaveModBaseAccuracy=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadCount=True
     bCanHaveModReloadTime=True
     AmmoName=Class'DeusEx.AmmoDartPoison'
     ReloadCount=4
     PickupAmmoCount=4
     FireOffset=(X=-25.000000,Y=8.000000,Z=14.000000)
     ProjectileClass=Class'DeusEx.DartPoison'
     shakemag=30.000000
     FireSound=Sound'DeusExSounds.Weapons.MiniCrossbowFire'
     AltFireSound=Sound'DeusExSounds.Weapons.MiniCrossbowReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.MiniCrossbowReload'
     SelectSound=Sound'DeusExSounds.Weapons.MiniCrossbowSelect'
     InventoryGroup=9
     bNameCaseSensitive=False
     ItemName="Mini-Crossbow"
     PlayerViewOffset=(X=25.000000,Y=-8.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.MiniCrossbow'
     LeftPlayerViewMesh=LodMesh'MiniCrossbowLeft'
     PickupViewMesh=LodMesh'DeusExItems.MiniCrossbowPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.MiniCrossbow3rd'
     LeftThirdPersonMesh=LodMesh'MiniCrossbow3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconCrossbow'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCrossbow'
     largeIconWidth=47
     largeIconHeight=46
     Description="The mini-crossbow was specifically developed for espionage work, and accepts a range of dart types (normal, tranquilizer, or flare) that can be changed depending upon the mission requirements."
     beltDescription="CROSSBOW"
     Mesh=LodMesh'DeusExItems.MiniCrossbowPickup'
     CollisionRadius=8.000000
     CollisionHeight=1.000000
     Mass=2.400000
     Buoyancy=1.200000
}
