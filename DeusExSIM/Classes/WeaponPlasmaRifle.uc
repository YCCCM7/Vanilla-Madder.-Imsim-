//=============================================================================
// WeaponPlasmaRifle.
//=============================================================================
class WeaponPlasmaRifle extends DeusExWeapon;

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
		LightType = LT_None;
	}
}

//MADDERS: Setting up for scaleable inventory size. Yeet.
function int VMDConfigureInvSlotsX(Pawn Other)
{
	//MADDERS: This is now outdated.
 	/*if (VMDBufferPlayer(Other) != None)
 	{
  		if (VMDBufferPlayer(Other).HasSkillAugment('HeavyWeaponSize')) return InvSlotsX-1;
  		return InvSlotsX;
	}*/
 	
	return Super.VMDConfigureInvSlotsX(Other);
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

state Idle
{
	function BeginState()
	{
		Super.BeginState();
		if (Level.NetMode == NM_StandAlone)
			LightType = LT_Steady;
	}
}

auto state Pickup
{
	function BeginState()
	{
		Super.BeginState();
		LightType = LT_Steady;
	}
	function EndState()
	{
		Super.EndState();
		LightType = LT_None;
	}
}

//MADDERS: Use render of overlays to swap out our unique plasma texture.
simulated event RenderOverlays( Canvas Can )
{
 	local Texture TTex;
 	
 	//Object load annoying. Do this instead.
 	if (DeusExPlayer(Owner) != None)
 	{
		//MADDERS: Toggle light state based on reload/ammo state, same with effect type but also with ammos.
		LightBrightness = 128;
		if (VMDOwnerIsCloaked() || IsInState('Reload') || ClipCount >= ReloadCount || AmmoType == None || AmmoType.AmmoAmount <= 0)
		{
			TTex = Texture'BlackMaskTex';
			LightBrightness = 0;
		}
 	 	else if (AmmoPlasmaPlague(AmmoType) != None)
		{
			LightHue = 160;
    			TTex = Texture'Effects.Electricity.Nano_SFX_A';
		}
   		else
		{
			LightHue = 80;
    			TTex = Texture'Effects.Fire.Wepn_PRifle_SFX';
  		}
  		
		if (VMDOwnerIsCloaked())
		{
			Multiskins[2] = TTex;
		}
  		MultiSkins[1] = TTex;
  		Super.RenderOverlays(Can);
  		
  		MultiSkins[1] = Default.Multiskins[1];
		MultiSkins[2] = Default.Multiskins[2];
 	}
 	else
 	{
  		Super.RenderOverlays(Can);
 	}
}

//Update light hue accordingly.
//NOTE: Obsolete with RenderOverlays doing this every frame. Yucky.
/*function VMDAlertPostAmmoLoad( bool bInstant )
{
	local float EvoMod;
	
	if (AmmoPlasmaPlague(AmmoType) != None)
	{
     		LightHue = 160;
	}
	else
	{
     		LightHue = 80;
	}
}*/

function VMDDropEmptyMagazine(int THand)
{
	local vector TOffset, TVect, X, Y, Z;
	local VMDWeaponMagazine Mag;
	
	GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
	Y *= -1 * THand;
	TOffset = Owner.CollisionRadius * X + 0.3 * Owner.CollisionRadius * Y;
	TVect = 0.8 * Owner.CollisionHeight * Z;
	TOffset.Z += TVect.Z;
	
	if (VMDBufferPawn(Owner) != None)
	{
		TOffset = VMDBufferPawn(Owner).GetShellOffset();
	}
	
	Mag = Spawn(class'PlasmaRifleMagazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * 0.1 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
	}
}

defaultproperties
{
     DrawAnimFrames=8
     DrawAnimRate=8.000000
     HolsterAnimFrames=8
     HolsterAnimRate=10.000000
     
     OverrideNumProj=3
     bSemiautoTrigger=True
     //HandSkinIndex=-1
     EvolvedName="Plasmathrower"
     EvolvedBelt="HERE, CATCH!"
     AimDecayMult=15.000000
     ThirdPersonScale=1.25
     SkinSwapException(1)=1
     SkinSwapException(2)=1
     
     //MADDERS: Shotgun info.
     MinSpreadAcc=0.112500
     BaseAccuracy=0.600000
     MaximumAccuracy=0.6000000
     
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconPlasmaRifleRotated'
     
     RecoilIndices(0)=(X=25.000000,Y=75.000000)
     RecoilIndices(1)=(X=15.000000,Y=85.000000)
     RecoilIndices(2)=(X=20.000000,Y=80.000000)
     NumRecoilIndices=3
     
     SelectTilt(0)=(X=35.000000,Y=35.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTilt(2)=(X=-5.000000,Y=15.000000)
     SelectTiltIndices=3
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.450000
     SelectTiltTimer(2)=0.600000
     DownTilt(0)=(X=5.000000,Y=-15.000000)
     DownTilt(1)=(X=0.000000,Y=0.000000)
     DownTilt(2)=(X=-35.000000,Y=-35.000000)
     DownTiltIndices=3
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.400000
     DownTiltTimer(2)=0.550000
     
     ReloadBeginTilt(0)=(X=10.000000,Y=-35.000000)
     ReloadBeginTiltIndices=1
     ReloadBeginTiltTimer(0)=0.000000
     
     ReloadTilt(0)=(X=0.000000,Y=0.000000)
     ReloadTilt(1)=(X=5.000000,Y=12.500000)
     ReloadTilt(2)=(X=-5.000000,Y=-12.500000)
     ReloadTiltIndices=3
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     ReloadTiltTimer(2)=0.750000
     
     ReloadEndTilt(0)=(X=-10.000000,Y=35.000000)
     ReloadEndTiltIndices=1
     ReloadEndTiltTimer(0)=0.000000
     
     LowAmmoWaterMark=12
     GoverningSkill=Class'DeusEx.SkillWeaponHeavy'
     EnviroEffective=ENVEFF_AirVacuum
     reloadTime=2.000000
     HitDamage=20
     maxRange=24000
     AccurateRange=14400
     bCanHaveScope=True
     ScopeFOV=20
     bCanHaveLaser=True
     AreaOfEffect=AOE_Cone
     bPenetrating=False
     recoilStrength=0.300000
     mpReloadTime=0.500000
     mpHitDamage=20
     mpBaseAccuracy=0.500000
     mpAccurateRange=8000
     mpMaxRange=8000
     mpReloadCount=12
     bCanHaveModBaseAccuracy=True
     bCanHaveModReloadCount=True
     bCanHaveModAccurateRange=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.AmmoPlasma'
     ReloadCount=12
     PickupAmmoCount=12
     ProjectileClass=Class'DeusEx.PlasmaBolt'
     AmmoNames(0)=Class'DeusEx.AmmoPlasma'
     AmmoNames(1)=Class'DeusEx.AmmoPlasmaPlague'
     ProjectileNames(0)=Class'DeusEx.PlasmaBolt'
     ProjectileNames(1)=Class'DeusEx.PlasmaBoltPlague'
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.PlasmaRifleFire'
     AltFireSound=Sound'DeusExSounds.Weapons.PlasmaRifleReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.PlasmaRifleReload'
     SelectSound=Sound'DeusExSounds.Weapons.PlasmaRifleSelect'
     InventoryGroup=8
     bNameCaseSensitive=False
     ItemName="Plasma Rifle"
     PlayerViewOffset=(X=18.000000,Z=-8.000000)
     PlayerViewMesh=LodMesh'DeusExItems.PlasmaRifle'
     LeftPlayerViewMesh=LodMesh'PlasmaRifleLeft'
     PickupViewMesh=LodMesh'DeusExItems.PlasmaRiflePickup'
     ThirdPersonMesh=LodMesh'VMDPlasmaRifle3rd'
     LeftThirdPersonMesh=LodMesh'PlasmaRifle3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconPlasmaRifle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconPlasmaRifle'
     largeIconWidth=203
     largeIconHeight=66
     invSlotsX=4
     invSlotsY=2
     Description="An experimental weapon that is currently being produced as a series of one-off prototypes, the plasma gun superheats slugs of magnetically-doped plastic and accelerates the resulting gas-liquid mix using an array of linear magnets. The resulting plasma stream is deadly when used against slow-moving targets."
     beltDescription="PLASMA"
     Mesh=LodMesh'DeusExItems.PlasmaRiflePickup'
     CollisionRadius=15.600000
     CollisionHeight=5.200000
     Mass=35.000000
     Buoyancy=17.500000
     
     //MADDERS: Light data
     LightType=LT_Steady
     LightEffect=LE_WateryShimmer
     LightBrightness=128
     LightHue=80
     LightSaturation=64
     LightRadius=1
}
