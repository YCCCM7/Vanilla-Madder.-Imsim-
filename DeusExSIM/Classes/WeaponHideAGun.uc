//=============================================================================
// WeaponHideAGun.
//=============================================================================
class WeaponHideAGun extends DeusExWeapon;

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
	
	Mag = Spawn(class'PS20Magazine',,, Owner.Location + TOffset);
	if (Mag != None)
	{
		Mag.Velocity = (FRand()*20+90) * 1.5 * Y + (10-FRand()*20) * X;
		Mag.Velocity.Z = 0;
		Mag.InitDropBy(Pawn(Owner));
	}
}

defaultproperties
{
     NumFiringModes=0
     FiringModes(0)="Full Auto"
     FiringModes(1)="Double Fire"
     ModeNames(0)="Full Auto"
     ModeNames(1)="Double Fire"
     bPocketReload=True //MADDERS: We just throw these away anyways, and the reload anim is busted, even with good attempts them. Fuck it. Just reload like we're in MP.
     bCanHaveModReloadCount=False
     PickupAmmoCount=2
     bBurstFire=True
     bAutomatic=True
     bHandToHand=False
     //HandSkinIndex=0
     OverrideAnimRate=2.650000
     OverrideReloadAnimRate=2.000000
     OverrideNumProj=1
     EvolvedName="Cricketer"
     EvolvedBelt="OI MATE"
     //FireCutoffFrame=0.250000
     EnviroEffective=ENVEFF_Air //MADDERS: Nerfed until invested in.
     FiringSystemOperation=1
     ClipsLabel="UNITS"
     
     RecoilStrength=0.550000
     AimDecayMult=0.000000 //Don't actually decay aim on this one during firing.
     
     RecoilIndices(0)=(X=10.000000,Y=90.000000)
     RecoilIndices(1)=(X=-10.000000,Y=90.000000)
     NumRecoilIndices=2
     
     SelectTilt(0)=(X=10.000000,Y=25.000000)
     SelectTilt(1)=(X=35.000000,Y=15.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.500000
     DownTilt(0)=(X=25.000000,Y=-15.000000)
     DownTilt(1)=(X=15.000000,Y=-25.000000)
     DownTiltIndices=2
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.500000
     
     ShootTilt(0)=(X=40.000000,Y=75.000000)
     ShootTilt(1)=(X=75.000000,Y=40.000000)
     ShootTiltIndices=2
     ShootTiltTimer(0)=0.700000
     ShootTiltTimer(1)=0.850000
     
     LowAmmoWaterMark=2
     GoverningSkill=Class'DeusEx.SkillWeaponPistol'
     NoiseLevel=0.010000
     Concealability=CONC_All //MADDERS: We're keeping it, because why else would it be the HideAGun?
     ShotTime=0.120000
     reloadTime=0.200000
     HitDamage=20
     maxRange=24000
     AccurateRange=14400
     BaseAccuracy=0.000000
     bHasMuzzleFlash=False
     bEmitWeaponDrawn=False
     bUseAsDrawnWeapon=False
     AmmoName=Class'DeusEx.AmmoPlasma'
     ReloadCount=2
     FireOffset=(X=-20.000000,Y=10.000000,Z=16.000000)
     ProjectileClass=Class'DeusEx.PlasmaBoltMini'
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.PlasmaRifleFire'
     SelectSound=Sound'DeusExSounds.Weapons.HideAGunSelect'
     ItemName="PS20"
     PlayerViewOffset=(X=20.000000,Y=-10.000000,Z=-16.000000)
     PlayerViewMesh=LodMesh'DeusExItems.HideAGun'
     LeftPlayerViewMesh=LodMesh'HideAGunLeft'
     PickupViewMesh=LodMesh'DeusExItems.HideAGunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.HideAGun3rd'
     LeftThirdPersonMesh=LodMesh'HideAGun3rdLeft'
     Icon=Texture'DeusExUI.Icons.BeltIconHideAGun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconHideAGun'
     largeIconWidth=29
     largeIconHeight=47
     Description="The PS20 is a disposable, plasma-based weapon developed by an unknown security organization as a next generation stealth pistol.  Unfortunately, the necessity of maintaining a small physical profile restricts the weapon to a single shot.  Despite its limited functionality, the PS20 can be lethal at close range."
     beltDescription="PS20"
     Mesh=LodMesh'DeusExItems.HideAGunPickup'
     CollisionRadius=3.300000
     CollisionHeight=0.600000
     Mass=1.000000
     Buoyancy=0.500000
}
