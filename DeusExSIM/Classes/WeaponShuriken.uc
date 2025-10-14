//=============================================================================
// WeaponShuriken.
//=============================================================================
class WeaponShuriken extends DeusExWeapon;

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
      		PickupAmmoCount = 7;
	}
}

function bool VMDCanBeDualWielded()
{
	return true;
}

//MADDERS, 10/6/25: Our one melee test weapon.
function bool VMDCanDualWield()
{
	return ShouldUseGP2();
}

defaultproperties
{
     DrawAnimFrames=9
     DrawAnimRate=11.000000
     HolsterAnimFrames=7
     HolsterAnimRate=13.000000
     
     //HandSkinIndex=0
     bCanHaveModEvolution=False
     
     SelectTilt(0)=(X=30.000000,Y=60.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTilt(2)=(X=10.000000,Y=40.000000)
     SelectTilt(3)=(X=20.000000,Y=30.000000)
     SelectTilt(4)=(X=30.000000,Y=-5.000000)
     SelectTilt(5)=(X=0.000000,Y=0.000000)
     SelectTilt(6)=(X=-30.000000,Y=5.000000)
     SelectTilt(7)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=8
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.200000
     SelectTiltTimer(2)=0.350000
     SelectTiltTimer(3)=0.450000
     SelectTiltTimer(4)=0.550000
     SelectTiltTimer(5)=0.650000
     SelectTiltTimer(6)=0.750000
     SelectTiltTimer(7)=0.850000
     DownTilt(0)=(X=-5.000000,Y=-20.000000)
     DownTilt(1)=(X=0.000000,Y=-25.000000)
     DownTilt(2)=(X=5.000000,Y=-20.000000)
     DownTilt(3)=(X=10.000000,Y=-15.000000)
     DownTilt(4)=(X=-20.000000,Y=-20.000000)
     DownTiltIndices=5
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.150000
     DownTiltTimer(2)=0.300000
     DownTiltTimer(3)=0.450000
     DownTiltTimer(4)=0.550000
     
     MeleeSwing1Tilt(0)=(X=20.000000,Y=5.000000)
     MeleeSwing1Tilt(1)=(X=-20.000000,Y=-5.000000)
     MeleeSwing1Tilt(2)=(X=0.000000,Y=0.000000)
     MeleeSwing1TiltIndices=3
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.300000
     MeleeSwing1TiltTimer(2)=0.600000
     
     LowAmmoWaterMark=5
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     EnviroEffective=ENVEFF_AirVacuum
     Concealability=CONC_Visual
     ShotTime=0.200000
     reloadTime=0.200000
     HitDamage=15
     maxRange=1280
     AccurateRange=640
     BaseAccuracy=0.300000
     bHasMuzzleFlash=False
     bHandToHand=True
     mpReloadTime=0.200000
     mpHitDamage=35
     mpBaseAccuracy=0.100000
     mpAccurateRange=640
     mpMaxRange=640
     mpPickupAmmoCount=7
     AmmoName=Class'DeusEx.AmmoShuriken'
     ReloadCount=1
     PickupAmmoCount=5
     FireOffset=(X=-10.000000,Y=14.000000,Z=22.000000)
     ProjectileClass=Class'DeusEx.Shuriken'
     shakemag=5.000000
     InventoryGroup=12
     bNameCaseSensitive=False
     ItemName="Throwing Knives"
     ItemArticle="some"
     PlayerViewOffset=(X=24.000000,Y=-12.000000,Z=-21.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Shuriken'
     LeftPlayerViewMesh=LodMesh'ShurikenLeft'
     PickupViewMesh=LodMesh'DeusExItems.ShurikenPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Shuriken3rd'
     LeftThirdPersonMesh=LodMesh'Shuriken3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconShuriken'
     largeIcon=Texture'DeusExUI.Icons.LargeIconShuriken'
     largeIconWidth=36
     largeIconHeight=45
     Description="A favorite weapon of assassins in the Far East for centuries, throwing knives can be deadly when wielded by a master but are more generally used when it becomes desirable to send a message. The message is usually 'Your death is coming on swift feet.'"
     beltDescription="THW KNIFE"
     Texture=Texture'DeusExItems.Skins.ReflectionMapTex1'
     Mesh=LodMesh'DeusExItems.ShurikenPickup'
     CollisionRadius=7.500000
     CollisionHeight=0.300000
     
     Mass=2.500000
     Buoyancy=1.250000
}
