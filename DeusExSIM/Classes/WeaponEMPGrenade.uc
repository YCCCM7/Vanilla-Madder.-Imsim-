//=============================================================================
// WeaponEMPGrenade.
//=============================================================================
class WeaponEMPGrenade extends DeusExWeapon;

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

// Become a pickup
// Weapons that carry their ammo with them don't vanish when dropped
function BecomePickup()
{
	Super.BecomePickup();
   	if (Level.NetMode != NM_Standalone)
      		if (bTossedOut)
         		Lifespan = 0.0;
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   	return (BeltSpot == 4);
}

defaultproperties
{
     //HandSkinIndex=3
     bSemiautoTrigger=True
     bVolatile=True
     bCanHaveModEvolution=False
     
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
     Concealability=CONC_Visual
     ShotTime=0.300000
     reloadTime=0.100000
     HitDamage=0
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=0.600000
     bPenetrating=False
     StunDuration=60.000000
     bHasMuzzleFlash=False
     bHandToHand=True
     bUseAsDrawnWeapon=False
     AITimeLimit=3.500000
     AIFireDelay=5.000000
     bNeedToSetMPPickupAmmo=False
     mpReloadTime=0.100000
     mpBaseAccuracy=1.000000
     mpAccurateRange=2400
     mpMaxRange=2400
     AmmoName=Class'DeusEx.AmmoEMPGrenade'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'DeusEx.EMPGrenade'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.EMPGrenadeSelect'
     InventoryGroup=22
     ItemName="Electromagnetic Pulse (EMP) Grenade"
     ItemArticle="an"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.EMPGrenade'
     LeftPlayerViewMesh=LodMesh'EMPGrenadeLeft'
     PickupViewMesh=LodMesh'DeusExItems.EMPGrenadePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.EMPGrenade3rd'
     LeftThirdPersonMesh=LodMesh'EMPGrenade3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconEMPGrenade'
     largeIcon=Texture'DeusExUI.Icons.LargeIconEMPGrenade'
     largeIconWidth=31
     largeIconHeight=49
     Description="The EMP grenade creates a localized pulse that will temporarily disable all electronics within its area of effect, including cameras and security grids.|n|n<UNATCO OPS FILE NOTE JR134-VIOLET> While nanotech augmentations are largely unaffected by EMP, experiments have shown that it WILL cause the spontaneous dissipation of stored bioelectric energy. -- Jaime Reyes <END NOTE>"
     beltDescription="EMP GREN"
     Mesh=LodMesh'DeusExItems.EMPGrenadePickup'
     CollisionRadius=3.000000
     CollisionHeight=2.430000
     Mass=2.000000
     Buoyancy=1.000000
}
