//=============================================================================
// WeaponGEPGun.
//=============================================================================
class WeaponGEPGun extends DeusExWeapon;

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
		ReloadCount = mpReloadCount;
		bHasScope = True;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	SetupTracking(Pawn(Owner));
	
	// don't let NPC geps lock on to targets
	//if ((Owner != None) && !Owner.IsA('DeusExPlayer'))
	//	bCanTrack = False;
}

function GiveTo(Pawn Other)
{	
	SetupTracking(Other); // Transcended - Fix GEP gun not having lock-on when taken from NPCs

	Super.GiveTo(Other);
}

function SetupTracking(Pawn p)
{
	local human pp;
	
	pp = Human(GetPlayerPawn());
	
	if(p != None)
	{
		//== Ensure that NPCs can't lock on to targets.
		if (p.IsA('DeusExPlayer'))
		{
			LockTime = Default.LockTime;
			bCanTrack = True;
		}
		else if (class'VMDStaticfunctions'.Static.VMDUseDifficultyModifier(PP, "Enemy GEP Lock")) // Unless on realistic
		{
			LockTime = 1.25;
			bCanTrack = True;
		}
		else
		{
			LockTime = Default.LockTime;
			bCanTrack = False;
		}
	}
}

//Update tracking for EMP vs non-EMP.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (AmmoRocketEMP(AmmoType) != None)
	{
		bCanTrack = false;
	}
	else
	{
		bCanTrack = true;
	}
	ShotTime = Default.ShotTime;
}

function float VMDGetCorrectHitDamage( float In )
{
	if (AmmoRocketEMP(AmmoType) != None)
	{
		return 0.0;
	}
	else
	{
		return 150.0;
	}
}

defaultproperties
{
     DrawAnimFrames=10
     DrawAnimRate=10.000000
     HolsterAnimFrames=10
     HolsterAnimRate=10.000000
     
     bSemiautoTrigger=True
     //OverrideAnimRate=3.000000
     //bCanHaveModReloadCount=True
     //HandSkinIndex=-1
     bVolatile=True
     NumFiringModes=0
     FiringModes(0)="Semi Auto"
     FiringModes(1)="Burst Fire"
     ModeNames(0)="Semi Auto"
     ModeNames(1)="Burst Fire"
     EvolvedName="Vaporizer"
     EvolvedBelt="VA-POO-RIZE"
     AimDecayMult=8.000000
     OverrideReloadAnimRate=1.350000

     BaseAccuracy=0.500000
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconGEPGunRotated'
     
     RecoilIndices(0)=(X=35.000000,Y=65.000000)
     NumRecoilIndices=1
     
     SelectTilt(0)=(X=65.000000,Y=85.000000)
     SelectTilt(1)=(X=85.000000,Y=45.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.525000
     DownTilt(0)=(X=95.000000,Y=-50.000000)
     DownTilt(1)=(X=10.000000,Y=-5.000000)
     DownTilt(2)=(X=50.000000,Y=-95.000000)
     DownTiltIndices=3
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.250000
     DownTiltTimer(2)=0.750000
     
     ReloadBeginTilt(0)=(X=-35.000000,Y=-35.000000)
     ReloadBeginTiltIndices=1
     ReloadBeginTiltTimer(0)=0.000000
     
     ReloadEndTilt(0)=(X=35.000000,Y=35.000000)
     ReloadEndTiltIndices=1
     ReloadEndTiltTimer(0)=0.000000
     
     ShortName="GEP Gun"
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     NoiseLevel=2.000000
     EnviroEffective=ENVEFF_Air
     ShotTime=2.000000
     reloadTime=2.000000
     HitDamage=150
     maxRange=24000
     AccurateRange=14400
     bCanHaveLaser=True
     bCanHaveScope=True
     bCanTrack=True
     LockTime=2.000000
     LockedSound=Sound'DeusExSounds.Weapons.GEPGunLock'
     TrackingSound=Sound'DeusExSounds.Weapons.GEPGunTrack'
     AmmoNames(0)=Class'DeusEx.AmmoRocket'
     AmmoNames(1)=Class'DeusEx.AmmoRocketWP'
     AmmoNames(2)=Class'DeusEx.AmmoRocketEMP'
     ProjectileNames(0)=Class'DeusEx.Rocket'
     ProjectileNames(1)=Class'DeusEx.RocketWP'
     ProjectileNames(2)=Class'DeusEx.RocketEMP'
     bHasMuzzleFlash=False
     recoilStrength=1.000000
     bUseWhileCrouched=False
     mpHitDamage=40
     mpAccurateRange=14400
     mpMaxRange=14400
     mpReloadCount=1
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     AmmoName=Class'DeusEx.AmmoRocket'
     ReloadCount=1
     PickupAmmoCount=4
     FireOffset=(X=-46.000000,Y=32.000000,Z=10.000000)
     ProjectileClass=Class'DeusEx.Rocket'
     shakemag=500.000000
     FireSound=Sound'DeusExSounds.Weapons.GEPGunFire'
     CockingSound=Sound'DeusExSounds.Weapons.GEPGunReload'
     SelectSound=Sound'DeusExSounds.Weapons.GEPGunSelect'
     InventoryGroup=17
     ItemName="Guided Explosive Projectile (GEP) Gun"
     PlayerViewOffset=(X=46.000000,Y=-32.000000,Z=-10.000000)
     PlayerViewMesh=LodMesh'DeusExItems.GEPGun'
     LeftPlayerViewMesh=LodMesh'GEPGunLeft'
     PickupViewMesh=LodMesh'DeusExItems.GEPGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.GEPGun3rd'
     LeftThirdPersonMesh=LodMesh'GEPGun3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconGEPGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconGEPGun'
     largeIconWidth=203
     largeIconHeight=77
     invSlotsX=4
     invSlotsY=2
     Description="The GEP gun is a relatively recent invention in the field of armaments: a portable, shoulder-mounted launcher that can fire rockets and laser guide them to their target with pinpoint accuracy. While suitable for high-threat combat situations, it can be bulky for those agents who have not grown familiar with it."
     beltDescription="GEP GUN"
     Mesh=LodMesh'DeusExItems.GEPGunPickup'
     CollisionRadius=27.000000
     CollisionHeight=6.600000
     Mass=50.000000
     AIMinRange=225 // Transcended - Added
}
