//=============================================================================
// WeaponNanoVirusGrenade.
//=============================================================================
class WeaponNanoVirusGrenade extends DeusExWeapon;

function PostBeginPlay()
{
   	Super.PostBeginPlay();
   	bWeaponStay = False;
}

function Fire(float Value)
{
	local float TRate;
	
	if ((VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).RejectWeaponFire())) return;
	
	// if facing a wall, affix the LAM to the wall
	if (Pawn(Owner) != None)
	{
		if (bNearWall)
		{
			bReadyToFire = False;
			GotoState('NormalFire');
			bPointing = True;
			
			//MADDERS, 1/28/21: Scale speed based on skill augment presence.
			TRate = 0.5;
			if (VMDHasSkillAugment('DemolitionMines')) TRate = 2.0;
			
			PlayAnim('Place',TRate, 0.1);
			return;
		}
	}
	
	// otherwise, throw as usual
	Super.Fire(Value);
}

function Projectile ProjectileFire(class<projectile> ProjClass, float ProjSpeed, bool bWarn)
{
	local Projectile proj;
	
	proj = Super.ProjectileFire(ProjClass, ProjSpeed, bWarn);
	
	if (proj != None)
		proj.PlayAnim('Open');
	
	return Proj;
}

defaultproperties
{
     DrawAnimFrames=8
     DrawAnimRate=7.000000
     HolsterAnimFrames=8
     HolsterAnimRate=7.000000
     
     //HandSkinIndex=3
     bSemiautoTrigger=True
     bCanHaveModEvolution=False
     SkinSwapException(4)=1
     
     SelectTilt(0)=(X=5.000000,Y=35.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTilt(2)=(X=7.500000,Y=-25.000000)
     SelectTilt(3)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=4
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.300000
     SelectTiltTimer(2)=0.500000
     SelectTiltTimer(3)=0.600000
     DownTilt(0)=(X=10.000000,Y=20.000000)
     DownTilt(1)=(X=0.000000,Y=0.000000)
     DownTilt(2)=(X=5.000000,Y=-35.000000)
     DownTiltIndices=3
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.300000
     DownTiltTimer(2)=0.550000
     
     MeleeSwing1Tilt(0)=(X=10.000000,Y=20.000000)
     MeleeSwing1Tilt(1)=(X=20.000000,Y=10.000000)
     MeleeSwing1Tilt(2)=(X=0.000000,Y=0.000000)
     MeleeSwing1Tilt(3)=(X=-75.000000,Y=-75.000000)
     MeleeSwing1Tilt(4)=(X=-30.000000,Y=-20.000000)
     MeleeSwing1TiltIndices=5
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.250000
     MeleeSwing1TiltTimer(2)=0.500000
     MeleeSwing1TiltTimer(3)=0.600000
     MeleeSwing1TiltTimer(4)=0.700000
     
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillDemolition'
     EnemyEffective=ENMEFF_Robot
     Concealability=CONC_Visual //MADDERS: Used to be all... Unlike EMP Grenade? Fuck it.
     ShotTime=0.300000
     reloadTime=0.100000
     HitDamage=0
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=0.600000
     bPenetrating=False
     bHasMuzzleFlash=False
     bHandToHand=True
     bUseAsDrawnWeapon=False
     AITimeLimit=3.500000
     AIFireDelay=5.000000
     AmmoName=Class'DeusEx.AmmoNanoVirusGrenade'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'DeusEx.NanoVirusGrenade'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.NanoVirusGrenadeSelect'
     InventoryGroup=23
     bNameCaseSensitive=False
     ItemName="Scramble Grenade"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.NanoVirusGrenade'
     LeftPlayerViewMesh=LodMesh'NanoVirusGrenadeLeft'
     PickupViewMesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.NanoVirusGrenade3rd'
     LeftThirdPersonMesh=LodMesh'NanoVirusGrenade3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconWeaponNanoVirus'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWeaponNanoVirus'
     largeIconWidth=24
     largeIconHeight=49
     Description="The detonation of a GUARDIAN scramble grenade broadcasts a short-range, polymorphic broadband assault on the command frequencies used by almost all bots manufactured since 2028. The ensuing electronic storm causes bots within its radius of effect to invert their friend/foe identification until command control can be re-established. Like a LAM, scramble grenades can be attached to any surface."
     beltDescription="SCRM GREN"
     Mesh=LodMesh'DeusExItems.NanoVirusGrenadePickup'
     CollisionRadius=3.000000
     CollisionHeight=2.430000
     Mass=2.000000
     Buoyancy=1.000000
}
