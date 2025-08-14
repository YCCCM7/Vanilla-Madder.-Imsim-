//=============================================================================
// WeaponLAW.
//=============================================================================
class WeaponLAW extends DeusExWeapon;

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

function PostBeginPlay()
{
   	Super.PostBeginPlay();
   	bWeaponStay = False;
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

//MADDERS: Setting up for scaleable inventory size. Yeet.
function int VMDConfigureInvSlotsX(Pawn Other)
{
	//MADDERS: This is now outdated.
 	/*if (VMDBufferPlayer(Other) != None)
 	{
  		if (VMDBufferPlayer(Other).HasSkillAugment('HeavyLAWSize')) return InvSlotsX-1;
  		return InvSlotsX;
 	}*/
 	
	return Super.VMDConfigureInvSlotsX(Other);
}

function VMDDestroyOnFinishHook()
{
	Super.VMDDestroyOnFinishHook();
	
	if ((Robot(Owner) == None) && (Owner != None) && (!Owner.IsInState('Dying')))
	{
		Spawn(class'EmptyLAW');
	}
}

defaultproperties
{
     DrawAnimFrames=10
     DrawAnimRate=7.000000
     HolsterAnimFrames=10
     HolsterAnimRate=8.000000
     
     //HandSkinIndex=0
     bVolatile=True
     bCanHaveModEvolution=False
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconLAWRotated'
     
     ScopeFOV=20 //MADDERS, 1/9/21: Lowered from 25, because FOV succc.
     bHasScope=True
     bCanHaveScope=True
     
     RecoilIndices(0)=(X=25.000000,Y=75.000000)
     NumRecoilIndices=1

     SelectTilt(0)=(X=50.000000,Y=20.000000)
     SelectTilt(1)=(X=40.000000,Y=40.000000)
     SelectTilt(2)=(X=40.000000,Y=30.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.275000
     SelectTiltTimer(2)=0.650000
     DownTilt(0)=(X=25.000000,Y=50.000000)
     DownTilt(1)=(X=45.000000,Y=-30.000000)
     DownTilt(2)=(X=20.000000,Y=-55.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.275000
     DownTiltTimer(2)=0.650000
     
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=0.300000
     reloadTime=0.000000
     HitDamage=500
     maxRange=24000
     AccurateRange=14400
     BaseAccuracy=0.300000
     bHasMuzzleFlash=False
     recoilStrength=3.000000
     mpHitDamage=100
     mpBaseAccuracy=0.600000
     mpAccurateRange=14400
     mpMaxRange=14400
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     FireOffset=(X=28.000000,Y=12.000000,Z=4.000000)
     ProjectileClass=Class'DeusEx.RocketLAW'
     shakemag=500.000000
     FireSound=Sound'DeusExSounds.Weapons.LAWFire'
     SelectSound=Sound'DeusExSounds.Weapons.LAWSelect'
     InventoryGroup=16
     ItemName="Light Anti-Tank Weapon (LAW)"
     PlayerViewOffset=(X=18.000000,Y=-24.000000,Z=-7.000000)
     PlayerViewMesh=LodMesh'DeusExItems.LAW'
     LeftPlayerViewMesh=LodMesh'LAWLeft'
     PickupViewMesh=LodMesh'DeusExItems.LAWPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.LAW3rd'
     LeftThirdPersonMesh=LodMesh'LAW3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconLAW'
     largeIcon=Texture'DeusExUI.Icons.LargeIconLAW'
     largeIconWidth=166
     largeIconHeight=47
     invSlotsX=4
     Description="The LAW provides cheap, dependable anti-armor capability in the form of an integrated one-shot rocket and delivery system, though at the expense of any laser guidance. Like other heavy weapons, the LAW can slow agents who have not trained with it extensively."
     beltDescription="LAW"
     Mesh=LodMesh'DeusExItems.LAWPickup'
     CollisionRadius=25.000000
     CollisionHeight=6.800000
     Mass=35.000000
}
