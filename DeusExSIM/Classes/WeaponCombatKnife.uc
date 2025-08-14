//=============================================================================
// WeaponCombatKnife.
//=============================================================================
class WeaponCombatKnife extends DeusExWeapon;

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
     DrawAnimFrames=3
     DrawAnimRate=7.000000
     HolsterAnimFrames=5
     HolsterAnimRate=10.000000
     
     //HandSkinIndex=1
     bSemiautoTrigger=True
     bCanHaveModEvolution=False
     ShotTime=0.050000 //Buffed from 0.5. Swing speed, ahoy!
     MeleeAnimRates(0)=0.830000
     MeleeAnimRates(1)=1.250000
     MeleeAnimRates(2)=0.910000
     
     SelectTilt(0)=(X=25.000000,Y=40.000000)
     SelectTiltIndices=1
     SelectTiltTimer(0)=0.000000
     DownTilt(0)=(X=35.000000,Y=-10.000000)
     DownTilt(1)=(X=15.000000,Y=-30.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.500000
     
     MeleeSwing1Tilt(0)=(X=-70.000000,Y=20.000000)
     MeleeSwing1Tilt(1)=(X=70.000000,Y=-20.000000)
     MeleeSwing1Tilt(2)=(X=40.000000,Y=-15.000000)
     MeleeSwing1Tilt(3)=(X=-40.000000,Y=15.000000)
     MeleeSwing1TiltIndices=4
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.250000
     MeleeSwing1TiltTimer(2)=0.500000
     MeleeSwing1TiltTimer(3)=0.750000
     
     MeleeSwing2Tilt(0)=(X=30.000000,Y=20.000000)
     MeleeSwing2Tilt(1)=(X=-60.000000,Y=-40.000000)
     MeleeSwing2Tilt(2)=(X=-40.000000,Y=-25.000000)
     MeleeSwing2Tilt(3)=(X=15.000000,Y=15.000000)
     MeleeSwing2TiltIndices=4
     MeleeSwing2TiltTimer(0)=0.000000
     MeleeSwing2TiltTimer(1)=0.330000
     MeleeSwing2TiltTimer(2)=0.500000
     MeleeSwing2TiltTimer(3)=0.660000
     
     MeleeSwing3Tilt(0)=(X=20.000000,Y=-30.000000)
     MeleeSwing3Tilt(1)=(X=-20.000000,Y=30.000000)
     MeleeSwing3Tilt(2)=(X=0.000000,Y=0.000000)
     MeleeSwing3Tilt(3)=(X=15.000000,Y=-15.000000)
     MeleeSwing3TiltIndices=4
     MeleeSwing3TiltTimer(0)=0.000000
     MeleeSwing3TiltTimer(1)=0.250000
     MeleeSwing3TiltTimer(2)=0.500000
     MeleeSwing3TiltTimer(3)=0.750000
     
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     Concealability=CONC_Visual
     reloadTime=0.000000
     HitDamage=5
     maxRange=80
     AccurateRange=80
     BaseAccuracy=1.000000
     bHasMuzzleFlash=False
     bHandToHand=True
     bFallbackWeapon=True
     mpHitDamage=20
     mpBaseAccuracy=1.000000
     mpAccurateRange=96
     mpMaxRange=96
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     bInstantHit=True
     FireOffset=(X=-5.000000,Y=8.000000,Z=14.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.CombatKnifeFire'
     SelectSound=Sound'DeusExSounds.Weapons.CombatKnifeSelect'
     Misc1Sound=Sound'DeusExSounds.Weapons.CombatKnifeHitFlesh'
     Misc2Sound=Sound'DeusExSounds.Weapons.CombatKnifeHitHard'
     Misc3Sound=Sound'DeusExSounds.Weapons.CombatKnifeHitSoft'
     InventoryGroup=11
     bNameCaseSensitive=False
     ItemName="Combat Knife"
     PlayerViewOffset=(X=5.000000,Y=-8.000000,Z=-14.000000)
     PlayerViewMesh=LodMesh'DeusExItems.CombatKnife'
     LeftPlayerViewMesh=LodMesh'CombatKnifeLeft'
     PickupViewMesh=LodMesh'DeusExItems.CombatKnifePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.CombatKnife3rd'
     LeftThirdPersonMesh=LodMesh'CombatKnife3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconCombatKnife'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCombatKnife'
     largeIconWidth=49
     largeIconHeight=45
     Description="An ultra-high carbon stainless steel knife."
     beltDescription="KNIFE"
     Mesh=LodMesh'DeusExItems.CombatKnifePickup'
     CollisionRadius=12.650000
     CollisionHeight=0.800000
     
     Mass=0.700000
     Buoyancy=0.350000
}
