//=============================================================================
// WeaponGasGrenade.
//=============================================================================
class WeaponGasGrenade extends DeusExWeapon;

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
   	return (BeltSpot == 5);
}

defaultproperties
{
     DrawAnimFrames=12
     DrawAnimRate=10.000000
     HolsterAnimFrames=9
     HolsterAnimRate=10.000000
     
     bSemiautoTrigger=True
     //HandSkinIndex=1
     bVolatile=True
     bCanHaveModEvolution=False
     
     SelectTilt(0)=(X=5.000000,Y=35.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTilt(2)=(X=7.500000,Y=-25.000000)
     SelectTilt(3)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=4
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.300000
     SelectTiltTimer(2)=0.650000
     SelectTiltTimer(3)=0.750000
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
     EnemyEffective=ENMEFF_Organic
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual //MADDERS: Used to be all... Unlike EMP grenade? Fuck it.
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
     AITimeLimit=4.000000
     AIFireDelay=20.000000
     bNeedToSetMPPickupAmmo=False
     mpReloadTime=0.100000
     mpHitDamage=2
     mpBaseAccuracy=1.000000
     mpAccurateRange=2400
     mpMaxRange=2400
     AmmoName=Class'DeusEx.AmmoGasGrenade'
     ReloadCount=1
     PickupAmmoCount=1
     FireOffset=(Y=10.000000,Z=20.000000)
     ProjectileClass=Class'DeusEx.GasGrenade'
     shakemag=50.000000
     SelectSound=Sound'DeusExSounds.Weapons.GasGrenadeSelect'
     InventoryGroup=21
     bNameCaseSensitive=False
     ItemName="Gas Grenade"
     PlayerViewOffset=(X=28.000000,Y=-13.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.GasGrenade'
     LeftPlayerViewMesh=LodMesh'GasGrenadeLeft'
     PickupViewMesh=LodMesh'DeusExItems.GasGrenadePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.GasGrenade3rd'
     LeftThirdPersonMesh=LodMesh'GasGrenade3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconGasGrenade'
     largeIcon=Texture'DeusExUI.Icons.LargeIconGasGrenade'
     largeIconWidth=23
     largeIconHeight=46
     Description="Upon detonation, the gas grenade releases a large amount of CS (a military-grade 'tear gas' agent) over its area of effect. CS will cause irritation to all exposed mucous membranes leading to temporary blindness and uncontrolled coughing. Like a LAM, gas grenades can be attached to any surface."
     beltDescription="GAS GREN"
     Mesh=LodMesh'DeusExItems.GasGrenadePickup'
     CollisionRadius=2.300000
     CollisionHeight=3.300000
     Mass=2.000000
     Buoyancy=1.000000
}
