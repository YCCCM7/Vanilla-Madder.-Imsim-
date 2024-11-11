//=============================================================================
// WeaponFlamethrower.
//=============================================================================
class WeaponFlamethrower extends DeusExWeapon;

var int BurnTime, BurnDamage;

var int		mpBurnTime;
var int		mpBurnDamage;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
      		HitDamage = mpHitDamage;
      		BaseAccuracy=mpBaseAccuracy;
      		ReloadTime = mpReloadTime;
      		AccurateRange = mpAccurateRange;
      		MaxRange = mpMaxRange;
      		ReloadCount = mpReloadCount;
      		BurnTime = mpBurnTime;
      		BurnDamage = mpBurnDamage;
      		PickupAmmoCount = mpReloadCount;
	}
}

//MADDERS: Glowing effect, ripping shamelessly from nanosword, and inspired by Revision.
state DownWeapon
{
	function BeginState()
	{
		Super.BeginState();
		LightType = LT_None;
	}
}

auto state Pickup
{
	function BeginState()
	{
		Super.BeginState();
		LightType = LT_None;
	}
	function EndState()
	{
		Super.EndState();
		LightType = LT_None;
	}
}

//MADDERS: Flame stuff.
//Also: Use this for glow effect.
simulated event RenderOverlays( Canvas Can )
{
	if (Region.Zone.bWaterZone)
	{
		LightType = LT_None;
		Multiskins[1] = Texture'BlackMaskTex';
	}
	else if (!IsInState('DownWeapon'))
	{
		LightType = LT_Steady;
		if (bHasEvolution)
		{
			LightHue = 60;
			Multiskins[1] = Texture'Effects.Fire.OneFlame_G';	
		}
		else
		{
			LightHue = 158;
			Multiskins[1] = Texture'Effects.Fire.Flmethrwr_Flme';
		}
	}
  	Super.RenderOverlays(Can);
}

//MADDERS: Setting up for scaleable inventory size. Yeet.
function int VMDConfigureInvSlotsX(Pawn Other)
{
	//MADDERS: This is now outdated.
 	/*if (VMDBufferPlayer(Other) != None)
 	{
  		if (VMDBufferPlayer(Other).HasSkillAugment("HeavyWeaponSize")) return InvSlotsX-1;
  		return InvSlotsX;
 	}*/
 	
	return Super.VMDConfigureInvSlotsX(Other);
}

function bool VMDIndexIsCloakException(int TestIndex)
{
	if (TestIndex == 1) return true;
	if (TestIndex == MuzzleFlashIndex) return true;
	return false;
}

defaultproperties
{
     EvolvedName="Fire Hose"
     EvolvedBelt="HOLY SMOKES"
     
     RecoilStrength=0.000000
     AimDecayMult=0.000000 //Don't actually decay aim on this one during firing.
     MuzzleFlashIndex=3 //HACK for not reskinning our hand
     OverrideNumProj=1
     HandSkinIndex(0)=0
     NPCOverrideAnimRate=1.000000 //1/5th the previous rate.
     OverrideAnimRate=1.000000
     bVolatile=True
     NumFiringModes=0
     FiringModes(0)="Full Auto"
     FiringModes(1)="Semi Auto"
     ModeNames(0)="Full Auto"
     ModeNames(1)="Semi Auto"
     AimDecayMult=20.000000
     ClipsLabel="CANS"
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconFlamethrowerRotated'
     
     SelectTilt(0)=(X=30.000000,Y=40.000000)
     SelectTilt(1)=(X=40.000000,Y=20.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.525000
     DownTilt(0)=(X=25.000000,Y=50.000000)
     DownTilt(1)=(X=45.000000,Y=-30.000000)
     DownTilt(2)=(X=20.000000,Y=-55.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.275000
     DownTiltTimer(2)=0.650000
     
     ReloadBeginTilt(0)=(X=-40.000000,Y=-20.000000)
     ReloadBeginTilt(1)=(X=-30.000000,Y=-40.000000)
     ReloadBeginTiltIndices=2
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.500000
     
     ReloadTilt(0)=(X=0.000000,Y=0.000000)
     ReloadTilt(1)=(X=-5.000000,Y=-12.500000)
     ReloadTilt(2)=(X=5.000000,Y=12.500000)
     ReloadTiltIndices=3
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     ReloadTiltTimer(2)=0.750000
     
     ReloadEndTilt(0)=(X=45.000000,Y=25.000000)
     ReloadEndTilt(1)=(X=30.000000,Y=40.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.500000
     
     ShootTilt(0)=(X=75.000000,Y=-7.500000)
     ShootTilt(1)=(X=-75.000000,Y=7.500000)
     ShootTilt(2)=(X=37.500000,Y=-3.750000)
     ShootTiltIndices=3
     ShootTiltTimer(0)=0.000000
     ShootTiltTimer(1)=0.350000
     ShootTiltTimer(2)=0.700000
     
     burnTime=20 //Used to be 30.
     BurnDamage=4
     mpBurnTime=15
     mpBurnDamage=2
     LowAmmoWaterMark=50
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     EnviroEffective=ENVEFF_Air
     bAutomatic=True
     ShotTime=0.110000
     reloadTime=5.500000
     HitDamage=2
     maxRange=320
     AccurateRange=320
     BaseAccuracy=0.900000
     bHasMuzzleFlash=False
     mpReloadTime=0.500000
     mpHitDamage=5
     mpBaseAccuracy=0.900000
     mpAccurateRange=320
     mpMaxRange=320
     mpReloadCount=100
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     AmmoName=Class'DeusEx.AmmoNapalm'
     ReloadCount=100
     PickupAmmoCount=100
     FireOffset=(Y=10.000000,Z=10.000000)
     ProjectileClass=Class'DeusEx.Fireball'
     shakemag=10.000000
     FireSound=Sound'DeusExSounds.Weapons.FlamethrowerFire'
     AltFireSound=Sound'DeusExSounds.Weapons.FlamethrowerReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.FlamethrowerReload'
     SelectSound=Sound'DeusExSounds.Weapons.FlamethrowerSelect'
     InventoryGroup=15
     bNameCaseSensitive=False
     ItemName="Flamethrower"
     PlayerViewOffset=(X=20.000000,Y=-14.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Flamethrower'
     PickupViewMesh=LodMesh'DeusExItems.FlamethrowerPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Flamethrower3rd'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconFlamethrower'
     largeIcon=Texture'DeusExUI.Icons.LargeIconFlamethrower'
     largeIconWidth=203
     largeIconHeight=69
     invSlotsX=4
     invSlotsY=2
     Description="A portable flamethrower that discards the old and highly dangerous backpack fuel delivery system in favor of pressurized canisters of napalm. Inexperienced agents will find that a flamethrower can be difficult to maneuver, however."
     beltDescription="FLAMETHWR"
     Mesh=LodMesh'DeusExItems.FlamethrowerPickup'
     CollisionRadius=20.500000
     CollisionHeight=4.400000
     Mass=40.000000
     
     //MADDERS: Light data
     LightType=LT_Steady
     LightEffect=LE_WateryShimmer
     LightBrightness=128
     LightHue=158
     LightSaturation=64
     LightRadius=1
}
