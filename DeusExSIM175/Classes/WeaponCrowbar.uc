//=============================================================================
// WeaponCrowbar.
//=============================================================================
class WeaponCrowbar extends DeusExWeapon;

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
     //HandSkinIndex=1
     bSemiautoTrigger=True
     bCanHaveModEvolution=False
     MeleeAnimRates(0)=0.950000
     MeleeAnimRates(1)=0.950000
     MeleeAnimRates(2)=1.110000
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconCrowbarRotated'
     ShotTime=0.050000
     
     SelectTilt(0)=(X=25.000000,Y=35.000000)
     SelectTiltIndices=1
     SelectTiltTimer(0)=0.000000
     DownTilt(0)=(X=15.000000,Y=-25.000000)
     DownTiltIndices=1
     DownTiltTimer(0)=0.000000
     
     MeleeSwing1Tilt(0)=(X=40.000000,Y=25.000000)
     MeleeSwing1Tilt(1)=(X=-80.000000,Y=-50.000000)
     MeleeSwing1Tilt(2)=(X=-40.000000,Y=-25.000000)
     MeleeSwing1Tilt(3)=(X=30.000000,Y=-20.000000)
     MeleeSwing1Tilt(4)=(X=20.000000,Y=30.000000)
     MeleeSwing1TiltIndices=5
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.330000
     MeleeSwing1TiltTimer(2)=0.500000
     MeleeSwing1TiltTimer(3)=0.660000
     MeleeSwing1TiltTimer(4)=0.750000
     
     //Note: #2 is literally just #1 again. Leave it empty so it'll defer to #1.
     
     MeleeSwing3Tilt(0)=(X=15.000000,Y=35.000000)
     MeleeSwing3Tilt(1)=(X=-22.500000,Y=-47.500000)
     MeleeSwing3Tilt(2)=(X=-15.000000,Y=-35.000000)
     MeleeSwing3Tilt(3)=(X=20.000000,Y=30.000000)
     MeleeSwing3TiltIndices=4
     MeleeSwing3TiltTimer(0)=0.000000
     MeleeSwing3TiltTimer(1)=0.300000
     MeleeSwing3TiltTimer(2)=0.500000
     MeleeSwing3TiltTimer(3)=0.650000
     
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     reloadTime=0.000000
     HitDamage=7
     maxRange=80
     AccurateRange=80
     BaseAccuracy=1.000000
     bPenetrating=False
     bHasMuzzleFlash=False
     bHandToHand=True
     bFallbackWeapon=True
     bEmitWeaponDrawn=False
     mpHitDamage=12
     mpBaseAccuracy=1.000000
     mpAccurateRange=96
     mpMaxRange=96
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     bInstantHit=True
     FireOffset=(X=-40.000000,Y=15.000000,Z=8.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.CrowbarFire'
     SelectSound=Sound'DeusExSounds.Weapons.CrowbarSelect'
     Misc1Sound=Sound'DeusExSounds.Weapons.CrowbarHitFlesh'
     Misc2Sound=Sound'DeusExSounds.Weapons.CrowbarHitHard'
     Misc3Sound=Sound'DeusExSounds.Weapons.CrowbarHitSoft'
     InventoryGroup=10
     bNameCaseSensitive=False
     ItemName="Crowbar"
     PlayerViewOffset=(X=40.000000,Y=-15.000000,Z=-8.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Crowbar'
     PickupViewMesh=LodMesh'DeusExItems.CrowbarPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Crowbar3rd'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconCrowbar'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCrowbar'
     largeIconWidth=101
     largeIconHeight=43
     invSlotsX=2
     Description="A crowbar. Hit someone or something with it. Repeat.|n|n<UNATCO OPS FILE NOTE GH010-BLUE> Many crowbars we call 'murder of crowbars.'  Always have one for kombat. Ha. -- Gunther Hermann <END NOTE>"
     beltDescription="CROWBAR"
     Mesh=LodMesh'DeusExItems.CrowbarPickup'
     CollisionRadius=19.000000
     CollisionHeight=1.050000
     Mass=15.000000
}
