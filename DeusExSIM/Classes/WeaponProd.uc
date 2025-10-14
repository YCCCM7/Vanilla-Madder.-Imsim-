//=============================================================================
// WeaponProd.
//=============================================================================
class WeaponProd extends DeusExWeapon;

#exec OBJ LOAD FILE=VMDEffects

var Ammo LastAttackAmmo;

//MADDERS: Use render of overlays to show JC hands. Easy, :) Ded 4/1/07
simulated event RenderOverlays( Canvas Can )
{
	if (Region.Zone.bWaterZone || ClipCount >= ReloadCount || IsInState('Reloading'))
	{
	 	Multiskins[1] = Texture'BlackMaskTex';
	 	Multiskins[2] = Texture'BlackMaskTex';
	}
	else
	{
		if (AmmoOverchargedBattery(AmmoType) != None)
		{
		 	Multiskins[1] = Texture'VMDEffects.Overcharge_EMPG_SFX';
		 	Multiskins[2] = Texture'VMDEffects.OverchargeProd_FX';
		}
		else
		{
		 	Multiskins[1] = Texture'Effects.Electricity.WEPN_EMPG_SFX';
		 	Multiskins[2] = Texture'Effects.Electricity.WEPN_Prod_FX';
		}
	}	
  	Super.RenderOverlays(Can);
}

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

state Idle
{
	function BeginState()
	{
		Super.BeginState();
		
		//MADDERS, 5/28/23: Drawing prod makes noise, although less than DTS.
		if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Reload Noise"))
		{
			AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 240);
		}
	}
}

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
	
	Mag = Spawn(class'ProdMagazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * -0.1 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
		
		if (AmmoOverchargedBattery(LastAttackAmmo) != None)
		{
			Mag.Multiskins[0] = Texture'VMDProdMagTex2';
		}
	}
}

//MADDERS, 7/23/25: Nifty hack using our own mod support functions. Use this to make sure we drop the right battery types when reloading.
function bool VMDTraceFireHook(float Accuracy)
{
	LastAttackAmmo = AmmoType;
	
	return true;
}

//Update penetration and ricochet damage.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (AmmoOverchargedBattery(AmmoType) != None)
	{
     		FirePitchMin = 1.200000;
     		FirePitchMax = 1.400000;
		
		if (ReloadCount != 2)
		{
			ReloadCount = 2;
			ClipCount = ReloadCount;
		}
		AmmoDamageMultiplier = 3.0;
	}
	else
	{
     		FirePitchMin = 0.900000;
     		FirePitchMax = 1.100000;
		
		if (ReloadCount != 4)
		{
			ReloadCount = 4;
			ClipCount = ReloadCount;
		}
		AmmoDamageMultiplier = 1.0;
	}
}

function bool VMDCanBeDualWielded()
{
	return true;
}

//MADDERS, 10/6/25: Our one melee test weapon.
function bool VMDCanDualWield()
{
	return ShouldUseGP2();
}

defaultproperties
{
     DrawAnimFrames=15
     DrawAnimRate=15.000000
     HolsterAnimFrames=8
     HolsterAnimRate=20.000000
     
     //HandSkinIndex=3
     bCanHaveModEvolution=False
     bSemiautoTrigger=True
     ClipsLabel="BATS"
     MoverDamageMult=0.000000
     
     SelectTilt(0)=(X=20.000000,Y=40.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.550000
     DownTilt(0)=(X=5.000000,Y=-20.000000)
     DownTilt(1)=(X=10.000000,Y=-35.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.300000
     
     ReloadBeginTilt(0)=(X=20.000000,Y=-20.000000)
     ReloadBeginTilt(1)=(X=-15.000000,Y=-15.000000)
     ReloadBeginTilt(2)=(X=0.000000,Y=0.000000)
     ReloadBeginTiltIndices=3
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.300000
     ReloadBeginTiltTimer(2)=0.500000
     
     ReloadTilt(0)=(X=-2.500000,Y=-12.500000)
     ReloadTilt(1)=(X=2.500000,Y=12.500000)
     ReloadTiltIndices=2
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.500000
     
     ReloadEndTilt(0)=(X=20.000000,Y=25.000000)
     ReloadEndTiltIndices=1
     ReloadEndTiltTimer(0)=0.000000
     
     ShootTilt(0)=(X=-30.000000,Y=5.000000)
     ShootTilt(1)=(X=0.000000,Y=0.000000)
     ShootTiltIndices=2
     ShootTiltTimer(0)=0.000000
     ShootTiltTimer(1)=0.300000
     
     LowAmmoWaterMark=4
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     EnemyEffective=ENMEFF_Organic
     EnviroEffective=ENVEFF_Air
     Concealability=CONC_Visual
     ShotTime=1.000000
     reloadTime=3.000000
     HitDamage=15
     maxRange=120
     AccurateRange=120
     BaseAccuracy=0.0000000
     bPenetrating=False
     StunDuration=10.000000
     bHasMuzzleFlash=False
     mpReloadTime=3.000000
     mpHitDamage=15
     mpBaseAccuracy=0.500000
     mpAccurateRange=80
     mpMaxRange=80
     mpReloadCount=4
     AmmoName=Class'DeusEx.AmmoBattery'
     AmmoNames(0)=Class'DeusEx.AmmoBattery'
     AmmoNames(1)=Class'DeusEx.AmmoOverchargedBattery'
     ReloadCount=4
     PickupAmmoCount=4
     bInstantHit=True
     FireOffset=(X=-21.000000,Y=12.000000,Z=19.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.ProdFire'
     AltFireSound=Sound'DeusExSounds.Weapons.ProdReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.ProdReload'
     SelectSound=Sound'DeusExSounds.Weapons.ProdSelect'
     InventoryGroup=19
     bNameCaseSensitive=False
     ItemName="Riot Prod"
     PlayerViewOffset=(X=21.000000,Y=-12.000000,Z=-19.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Prod'
     LeftPlayerViewMesh=LodMesh'ProdLeft'
     PickupViewMesh=LodMesh'DeusExItems.ProdPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.Prod3rd'
     LeftThirdPersonMesh=LodMesh'Prod3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconProd'
     largeIcon=Texture'DeusExUI.Icons.LargeIconProd'
     largeIconWidth=49
     largeIconHeight=48
     Description="The riot prod has been extensively used by security forces who wish to keep what remains of the crumbling peace and have found the prod to be an valuable tool. Its short range tetanizing effect is most effective when applied to the torso or when the subject is taken by surprise."
     beltDescription="PROD"
     Mesh=LodMesh'DeusExItems.ProdPickup'
     CollisionRadius=8.750000
     CollisionHeight=1.350000

     Mass=1.700000
     Buoyancy=0.850000
}
