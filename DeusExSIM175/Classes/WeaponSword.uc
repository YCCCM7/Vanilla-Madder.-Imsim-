//=============================================================================
// WeaponSword.
//=============================================================================
class WeaponSword extends DeusExWeapon;

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

defaultproperties
{
     //HandSkinIndex=2
     bSemiautoTrigger=True
     bCanHaveModEvolution=False
     MeleeAnimRates(0)=1.000000
     MeleeAnimRates(1)=1.000000
     MeleeAnimRates(2)=1.000000
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconSwordRotated'
     ShotTime=0.050000
     
     SelectTilt(0)=(X=45.000000,Y=45.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.375000
     DownTilt(0)=(X=0.000000,Y=0.000000)
     DownTilt(1)=(X=-20.000000,Y=-40.000000)
     DownTilt(2)=(X=20.000000,Y=-40.000000)
     DownTilt(3)=(X=0.000000,Y=0.000000)
     DownTilt(4)=(X=30.000000,Y=-50.000000)
     DownTiltIndices=5
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.250000
     DownTiltTimer(2)=0.375000
     DownTiltTimer(3)=0.500000
     DownTiltTimer(4)=0.750000
     
     MeleeSwing1Tilt(0)=(X=40.000000,Y=25.000000)
     MeleeSwing1Tilt(1)=(X=-40.000000,Y=-25.000000)
     MeleeSwing1Tilt(2)=(X=-30.000000,Y=-15.000000)
     MeleeSwing1Tilt(3)=(X=0.000000,Y=0.000000)
     MeleeSwing1Tilt(4)=(X=30.000000,Y=-15.000000)
     MeleeSwing1Tilt(5)=(X=15.000000,Y=40.000000)
     MeleeSwing1TiltIndices=6
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.250000
     MeleeSwing1TiltTimer(2)=0.500000
     MeleeSwing1TiltTimer(3)=0.666000
     MeleeSwing1TiltTimer(4)=0.750000
     MeleeSwing1TiltTimer(5)=0.875000
     
     //Attack2 is the same thing as Attack1. Keep it empty so it defers to Attack1 by default.
     
     MeleeSwing3Tilt(0)=(X=-135.000000,Y=-50.000000)
     MeleeSwing3Tilt(1)=(X=0.000000,Y=0.000000)
     MeleeSwing3Tilt(2)=(X=67.500000,Y=25.000000)
     MeleeSwing3Tilt(3)=(X=52.500000,Y=-15.000000)
     MeleeSwing3Tilt(4)=(X=0.000000,Y=0.000000)
     MeleeSwing3Tilt(5)=(X=-52.500000,Y=25.000000)
     MeleeSwing3TiltIndices=6
     MeleeSwing3TiltTimer(0)=0.000000
     MeleeSwing3TiltTimer(1)=0.125000
     MeleeSwing3TiltTimer(2)=0.250000
     MeleeSwing3TiltTimer(3)=0.500000
     MeleeSwing3TiltTimer(4)=0.625000
     MeleeSwing3TiltTimer(5)=0.875000
     
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     reloadTime=0.000000
     maxRange=96
     AccurateRange=96
     BaseAccuracy=1.000000
     bHasMuzzleFlash=False
     bHandToHand=True
     bFallbackWeapon=True
     mpHitDamage=20
     mpBaseAccuracy=1.000000
     mpAccurateRange=100
     mpMaxRange=100
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     bInstantHit=True
     FireOffset=(X=-25.000000,Y=10.000000,Z=24.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.SwordFire'
     SelectSound=Sound'DeusExSounds.Weapons.SwordSelect'
     Misc1Sound=Sound'DeusExSounds.Weapons.SwordHitFlesh'
     Misc2Sound=Sound'DeusExSounds.Weapons.SwordHitHard'
     Misc3Sound=Sound'DeusExSounds.Weapons.SwordHitSoft'
     InventoryGroup=13
     bNameCaseSensitive=False
     ItemName="Sword"
     PlayerViewOffset=(X=25.000000,Y=-10.000000,Z=-24.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Sword'
     PickupViewMesh=LodMesh'DeusExItems.SwordPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Sword3rd'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconSword'
     largeIcon=Texture'DeusExUI.Icons.LargeIconSword'
     largeIconWidth=130
     largeIconHeight=40
     invSlotsX=3
     Description="A rather nasty-looking sword."
     beltDescription="SWORD"
     Texture=Texture'DeusExItems.Skins.ReflectionMapTex1'
     Mesh=LodMesh'DeusExItems.SwordPickup'
     CollisionRadius=26.000000
     CollisionHeight=0.500000
     Mass=20.000000
}
