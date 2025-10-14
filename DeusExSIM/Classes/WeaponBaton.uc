//=============================================================================
// WeaponBaton.
//=============================================================================
class WeaponBaton extends DeusExWeapon;

function name WeaponDamageType()
{
	return 'KnockedOut';
}

function bool VMDCanBeDualWielded()
{
	return true;
}

function bool VMDCanDualWield()
{
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).bUseGunplayVersionTwo))
	{
		return true;
	}
	
	return false;
}

defaultproperties
{
     DrawAnimFrames=14
     DrawAnimRate=15.000000
     HolsterAnimFrames=12
     HolsterAnimRate=9.000000
     
     //HandSkinIndex=1
     bSemiautoTrigger=True
     bCanHaveModEvolution=False
     MeleeAnimRates(0)=1.250000
     MeleeAnimRates(1)=1.250000
     MeleeAnimRates(2)=0.710000
     ShotTime=0.050000
     DisarmChanceMult=3.000000
     
     SelectTilt(0)=(X=45.000000,Y=30.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTilt(2)=(X=-35.000000,Y=-25.000000)
     SelectTilt(3)=(X=0.000000,Y=0.000000)
     SelectTilt(4)=(X=30.000000,Y=45.000000)
     SelectTilt(5)=(X=30.000000,Y=45.000000)
     SelectTilt(6)=(X=30.000000,Y=45.000000)
     SelectTiltIndices=7
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.285000
     SelectTiltTimer(2)=0.425000
     SelectTiltTimer(3)=0.571000
     SelectTiltTimer(4)=0.642000
     SelectTiltTimer(5)=0.857000
     SelectTiltTimer(6)=0.928000
     DownTilt(0)=(X=-15.000000,Y=-35.000000)
     DownTilt(1)=(X=-15.000000,Y=-15.000000)
     DownTilt(2)=(X=35.000000,Y=25.000000)
     DownTilt(3)=(X=30.000000,Y=-45.000000)
     DownTiltIndices=4
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.160000
     DownTiltTimer(2)=0.416000
     DownTiltTimer(3)=0.666000
     
     MeleeSwing1Tilt(0)=(X=15.000000,Y=30.000000)
     MeleeSwing1Tilt(1)=(X=30.000000,Y=15.000000)
     MeleeSwing1Tilt(2)=(X=-45.000000,Y=-45.000000)
     MeleeSwing1Tilt(3)=(X=-30.000000,Y=-20.000000)
     MeleeSwing1Tilt(4)=(X=20.000000,Y=-30.000000)
     MeleeSwing1Tilt(5)=(X=25.000000,Y=30.000000)
     MeleeSwing1TiltIndices=6
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.166000
     MeleeSwing1TiltTimer(2)=0.333000
     MeleeSwing1TiltTimer(3)=0.500000
     MeleeSwing1TiltTimer(4)=0.666000
     MeleeSwing1TiltTimer(5)=0.833000
     
     //Attack 2 is the same as Attack 1. Leave it blank so we'll defer to it.
     
     MeleeSwing3Tilt(0)=(X=-35.000000,Y=-5.000000)
     MeleeSwing3Tilt(1)=(X=0.000000,Y=0.000000)
     MeleeSwing3Tilt(2)=(X=42.500000,Y=7.500000)
     MeleeSwing3Tilt(3)=(X=15.000000,Y=-15.000000)
     MeleeSwing3Tilt(4)=(X=-15.000000,Y=15.000000)
     MeleeSwing3TiltIndices=5
     MeleeSwing3TiltTimer(0)=0.000000
     MeleeSwing3TiltTimer(1)=0.166000
     MeleeSwing3TiltTimer(2)=0.250000
     MeleeSwing3TiltTimer(3)=0.500000
     MeleeSwing3TiltTimer(4)=0.750000
     
     Concealability=CONC_Visual
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     reloadTime=0.000000
     HitDamage=5
     maxRange=80
     AccurateRange=80
     BaseAccuracy=1.000000
     bPenetrating=False
     bHasMuzzleFlash=False
     bHandToHand=True
     bFallbackWeapon=True
     bEmitWeaponDrawn=False
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     bInstantHit=True
     FireOffset=(X=-24.000000,Y=14.000000,Z=17.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.BatonFire'
     SelectSound=Sound'DeusExSounds.Weapons.BatonSelect'
     Misc1Sound=Sound'DeusExSounds.Weapons.BatonHitFlesh'
     Misc2Sound=Sound'DeusExSounds.Weapons.BatonHitHard'
     Misc3Sound=Sound'DeusExSounds.Weapons.BatonHitSoft'
     InventoryGroup=24
     bNameCaseSensitive=False
     ItemName="Baton"
     PlayerViewOffset=(X=24.000000,Y=-14.000000,Z=-17.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Baton'
     LeftPlayerViewMesh=LodMesh'BatonLeft'
     PickupViewMesh=LodMesh'DeusExItems.BatonPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Baton3rd'
     LeftThirdPersonMesh=LodMesh'Baton3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconBaton'
     largeIcon=Texture'DeusExUI.Icons.LargeIconBaton'
     largeIconWidth=46
     largeIconHeight=47
     Description="A hefty looking baton, typically used by riot police and national security forces to discourage civilian resistance."
     beltDescription="BATON"
     Mesh=LodMesh'DeusExItems.BatonPickup'
     CollisionRadius=14.000000
     CollisionHeight=1.000000
     Mass=1.000000
     Buoyancy=0.500000
}
