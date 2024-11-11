//=============================================================================
// WeaponProd.
//=============================================================================
class WeaponProd extends DeusExWeapon;

//MADDERS: Use render of overlays to show JC hands. Easy, :) Ded 4/1/07
simulated event RenderOverlays( Canvas Can )
{
	if (Region.Zone.bWaterZone)
	{
	 	Multiskins[1] = Texture'BlackMaskTex';
	 	Multiskins[2] = Texture'BlackMaskTex';
	}
	else
	{
	 	Multiskins[1] = Texture'Effects.Electricity.WEPN_EMPG_SFX';
	 	Multiskins[2] = Texture'Effects.Electricity.WEPN_Prod_FX';
	}	
  	Super.RenderOverlays(Can);
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

defaultproperties
{
     //HandSkinIndex=3
     bCanHaveModEvolution=False
     bSemiautoTrigger=True
     ClipsLabel="BATS"
     
     SelectTilt(0)=(X=20.000000,Y=40.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.550000
     DownTilt(0)=(X=5.000000,Y=-20.000000)
     DownTilt(1)=(X=10.000000,Y=-35.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.300000
     
     ReloadBeginTilt(0)=(X=20.000000,Y=-20.000000)
     ReloadBeginTilt(1)=(X=-15.000000,Y=-15.000000)
     ReloadBeginTilt(2)=(X=0.000000,Y=0.000000)
     ReloadBeginTiltIndices=3
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.300000
     ReloadBeginTiltTimer(2)=0.500000
     
     ReloadTilt(0)=(X=-2.500000,Y=-12.500000)
     ReloadTilt(1)=(X=2.500000,Y=12.500000)
     ReloadTiltIndices=2
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     
     ReloadEndTilt(0)=(X=20.000000,Y=25.000000)
     ReloadEndTiltIndices=1
     ReloadEndTiltTimer(0)=0.000000
     
     ShootTilt(0)=(X=-30.000000,Y=5.000000)
     ShootTilt(1)=(X=0.000000,Y=0.000000)
     ShootTiltIndices=2
     ShootTiltTimer(0)=0.000000
     ShootTiltTimer(1)=0.300000
     
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=1.000000
     reloadTime=3.000000
     HitDamage=15
     maxRange=96
     AccurateRange=96
     BaseAccuracy=0.0000000
     bPenetrating=False
     StunDuration=10.000000
     bHasMuzzleFlash=False
     mpReloadTime=3.000000
     mpHitDamage=15
     mpBaseAccuracy=0.500000
     mpAccurateRange=80
     mpMaxRange=80
     mpReloadCount=4
     AmmoName=Class'DeusEx.AmmoBattery'
     ReloadCount=4
     PickupAmmoCount=4
     bInstantHit=True
     FireOffset=(X=-21.000000,Y=12.000000,Z=19.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.ProdFire'
     AltFireSound=Sound'DeusExSounds.Weapons.ProdReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.ProdReload'
     SelectSound=Sound'DeusExSounds.Weapons.ProdSelect'
     InventoryGroup=19
     bNameCaseSensitive=False
     ItemName="Riot Prod"
     PlayerViewOffset=(X=21.000000,Y=-12.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Prod'
     PickupViewMesh=LodMesh'DeusExItems.ProdPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Prod3rd'
     Icon=Texture'DeusExUI.Icons.BeltIconProd'
     largeIcon=Texture'DeusExUI.Icons.LargeIconProd'
     largeIconWidth=49
     largeIconHeight=48
     Description="The riot prod has been extensively used by security forces who wish to keep what remains of the crumbling peace and have found the prod to be an valuable tool. Its short range tetanizing effect is most effective when applied to the torso or when the subject is taken by surprise."
     beltDescription="PROD"
     Mesh=LodMesh'DeusExItems.ProdPickup'
     CollisionRadius=8.750000
     CollisionHeight=1.350000
}
