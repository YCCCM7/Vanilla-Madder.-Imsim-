//=============================================================================
// WeaponLAM.
//=============================================================================
class WeaponLAM extends DeusExWeapon;

var localized String shortName;

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
	return (BeltSpot == 6);
}

defaultproperties
{
     DrawAnimFrames=12
     DrawAnimRate=10.000000
     HolsterAnimFrames=5
     HolsterAnimRate=6.000000
     
     MuzzleFlashIndex=5 //HACK for not reskinning our hand
     HandSkinIndex(0)=0
     HandSkinIndex(1)=2
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
     SelectTiltTimer(2)=0.550000
     SelectTiltTimer(3)=0.650000
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
     
     ShortName="LAM"
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillDemolition'
     EnviroEffective=ENVEFF_AirWater
     Concealability=CONC_Visual //MADDERS: Used to be all... Unlike EMP grenade? Fuck it.
     ShotTime=0.300000
     reloadTime=0.100000
     HitDamage=100
     maxRange=4800
     AccurateRange=2400
     BaseAccuracy=0.500000
     bHasMuzzleFlash=False
     bHandToHand=True
     bUseAsDrawnWeapon=False
     AITimeLimit=3.500000
     AIFireDelay=5.000000
     bNeedToSetMPPickupAmmo=False
     mpReloadTime=0.100000
     mpHitDamage=500
     mpBaseAccuracy=1.000000
     mpAccurateRange=2400
     mpMaxRange=2400
     AmmoName=Class'DeusEx.AmmoLAM'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'DeusEx.LAM'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.LAMSelect'
     InventoryGroup=20
     ItemName="Lightweight Attack Munitions (LAM)"
     PlayerViewOffset=(X=24.000000,Y=-15.000000,Z=-17.000000)
     PlayerViewMesh=LodMesh'DeusExItems.LAM'
     LeftPlayerViewMesh=LodMesh'LAMLeft'
     PickupViewMesh=LodMesh'DeusExItems.LAMPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.LAM3rd'
     LeftThirdPersonMesh=LodMesh'LAM3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconLAM'
     largeIcon=Texture'DeusExUI.Icons.LargeIconLAM'
     largeIconWidth=35
     largeIconHeight=45
     Description="A multi-functional explosive with electronic priming system that can either be thrown or attached to any surface with its polyhesive backing and used as a proximity mine.|n|n<UNATCO OPS FILE NOTE SC093-BLUE> Disarming a proximity device should only be attempted with the proper demolitions training. Trust me on this. -- Sam Carter <END NOTE>"
     beltDescription="LAM"
     Mesh=LodMesh'DeusExItems.LAMPickup'
     CollisionRadius=3.800000
     CollisionHeight=3.500000
     Mass=2.000000
     Buoyancy=1.000000
}
