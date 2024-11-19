//=============================================================================
// WeaponAssaultShotgun.
//=============================================================================
class WeaponAssaultShotgun extends DeusExWeapon;

var name LastMagMesh;

function bool VMDIsTwoHandedWeapon()
{
	return true;
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

simulated function PlayFiringSound()
{
	local Sound OldFire;
	
	//Super.PlayFiringSound();
	if (AmmoDragonsBreath(AmmoType) != None)
	{
		OldFire = FireSound;
		FireSound = Sound'AssaultShotgunFireDragonsBreath';
		Super.PlayFiringSound();
		FireSound = OldFire;
	}
	else
	{
		Super.PlayFiringSound();
	}
}

//Update penetration and ricochet damage.
function VMDAlertPostAmmoLoad( bool bInstant )
{
	if (AmmoSabot(AmmoType) != None)
	{
		MinSpreadAcc = 0.075000;
     		PenetrationHitDamage = 2;
     		RicochetHitDamage = 1;
		HitDamage = Default.HitDamage;
		BulletHoleSize = 0.175000;
		MaxRange = 7200;
	}
	else if (AmmoDragonsBreath(AmmoType) != None)
	{
		MinSpreadAcc = 0.300000; //Quadruple width spread, possible to our benefit.
     		PenetrationHitDamage = 0;
     		RicochetHitDamage = 0;
		HitDamage = 1;
		MaxRange = 4800;
	}
	else
	{
		MinSpreadAcc = 0.075000;
     		PenetrationHitDamage = Default.PenetrationHitDamage;
     		RicochetHitDamage = Default.RicochetHitDamage;
		HitDamage = Default.HitDamage;
		BulletHoleSize = 0.075000;
		MaxRange = 4800;
	}
}

function int VMDGetCorrectNumProj( int In )
{
 	if (AmmoSabot(AmmoType) != None) return 1;
 	
 	if (OverrideNumProj < 1)
 	{
 		return In;
 	}
 	return OverrideNumProj;
}

function float VMDGetCorrectHitDamage( float In )
{
 	//MADDERS: Always return full damage with sabot. We'll truncate like a mother fucker at all times.
 	if (AmmoSabot(AmmoType) != None) return Default.HitDamage*OverrideNumProj;
	
 	return In;
}

function VMDHandleDragonsBreath(Actor Other, Vector L, Vector N)
{
	local int i, Margin;
	local float TRand, TDist, TRange;
	local Rotator TRot, BaseRot;
	local Vector Origin, TVect, X, Y, Z;
	local DragonsBreathSpark TSpark;
	
	TRange = 384.0;
	if (!VMDHasSkillAugment('RifleAltAmmos')) TRange *= 0.65;
	
	if (Other != None)
	{
		if (Owner != None)
		{
			TDist = VSize(L - Owner.Location);
		}
		else
		{
			TDist = VSize(L - Location);
		}
		
		if (FRand() > (TDist / TRange))
		{
			Other.TakeDamage(1, Pawn(Owner), L, vect(0,0,0), 'Flamed');
		}
	}
	
	if (Pawn(Owner) == None) return;
	
	if (PlayerPawn(Owner) != None)
	{
		GetAxes(Pawn(owner).ViewRotation,X,Y,Z);
		//Origin = Owner.Location + CalcDrawOffset() + FireOffset.X * X + FireOffset.Y * Y + FireOffset.Z * Z;
		Origin = Owner.Location + CalcDrawOffset();
	}
	else
	{
		Origin = Owner.Location + Pawn(Owner).BaseEyeHeight*Vect(0,0,1);
	}
	
	if (L != Vect(0,0,0))
	{
		BaseRot = Rotator(L - Origin);
		Margin = 256;
	}
	else
	{
		BaseRot = Pawn(Owner).ViewRotation;
		Margin = 768;
	}
	
	for (i=0; i<3; i++)
	{
		TRand = (FRand() - 0.5) * Margin;
		TRot.Yaw += TRand;
		TRand = (FRand() - 0.5) * Margin;
		TRot.Pitch += TRand;
		
		TVect = Vector(TRot);
		TSpark = Spawn(class'DragonsBreathSpark', Owner,, Origin, BaseRot + Rotator(TVect));
	}
}

function VMDDropEmptyMagazine(int THand)
{
	local vector TOffset, TVect, X, Y, Z;
	local rotator TRot;
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
	
	TRot.Yaw = Owner.Rotation.Yaw;
	Mag = Spawn(class'AssaultShotgunMagazine',,, Owner.Location + TOffset, TRot);
	if (Mag != None)
	{
		//MADDERS, 7/1/24: For the sake of looking pretty, don't play the same animation sequence twice in a row.
		Mag.InitDropBy(Pawn(Owner));
		if (Mag.Mesh.Name == LastMagMesh)
		{
			switch(LastMagMesh)
			{
				case 'VMDAssaultShotgunMag01':
					if (Rand(2) == 0)
					{
						Mag.Mesh = LODMesh'VMDAssaultShotgunMag02';
					}
					else
					{
						Mag.Mesh = LODMesh'VMDAssaultShotgunMag03';
					}
				break;
				case 'VMDAssaultShotgunMag02':
					if (Rand(2) == 0)
					{
						Mag.Mesh = LODMesh'VMDAssaultShotgunMag01';
					}
					else
					{
						Mag.Mesh = LODMesh'VMDAssaultShotgunMag03';
					}
				break;
				case 'VMDAssaultShotgunMag03':
					if (Rand(2) == 0)
					{
						Mag.Mesh = LODMesh'VMDAssaultShotgunMag01';
					}
					else
					{
						Mag.Mesh = LODMesh'VMDAssaultShotgunMag02';
					}
				break;
			}
		}
		
		LastMagMesh = Mag.Mesh.Name;
		switch(LastMagMesh)
		{
			case 'VMDAssaultShotgunMag01':
				Mag.Velocity = (FRand()*20+90) * 0.35 * Y + (10-FRand()*20) * X * 0;
				Mag.Velocity.Z = 0;
			break;
			case 'VMDAssaultShotgunMag02':
				Mag.Velocity = (FRand()*20+90) * 1.2 * Y + (10-FRand()*20) * X * 0;
				Mag.Velocity.Z = 0;
			break;
			case 'VMDAssaultShotgunMag03':
				Mag.Velocity = (FRand()*20+90) * 0.1 * Y + (10-FRand()*20) * X * 0;
				Mag.Velocity.Z = 0;
			break;
		}
	}
}

defaultproperties
{
     BulletHoleSize=0.075000
     NumFiringModes=0
     FiringModes(0)="Semi Auto"
     FiringModes(1)="Full Auto "
     ModeNames(0)="Semi Auto"
     ModeNames(1)="Full Auto"
     bSingleLoaded=False //Used to be single.
     SingleLoadSound=Sound'AssaultShotgunSingleLoad'
     EvolvedName="Official Jackhammer"
     EvolvedBelt="JACK OFF"
     AimDecayMult=8.500000 //Used to be 12.5 before the buff
     FiringSystemOperation=2
     PenetrationHitDamage=0
     RicochetHitDamage=2
     ClipsLabel="BELTS"
     GrimeRateMult=0.650000
     
     //MADDERS: Shotguns are A-OK to use precision style mods on now.
     bCanHaveLaser=True
     bCanHaveModBaseAccuracy=True
     bCanHaveModAccurateRange=True
     
     //MADDERS: Shotgun info. 0.25 is the vanilla equivalent.
     MinSpreadAcc=0.075000 //Used to be 0.2, but holy shit the med range accuracy. Then 0.1 before buff lmao.
     BaseAccuracy=0.625000 //Used to be 0.8, then 0.7 pre-overhaul, then 0.625 before buff. Re-nerrfed to 0.625 lol. This thing shreds.
     MaximumAccuracy=0.5500000
     FalloffStartRange=900
     
     //MADDERS: Actual spam cannon.
     //HandSkinIndex=1
     //ProjectileClass=class'RocketGEP'
     OverrideNumProj=12
     OverrideAnimRate=2.333000
     OverrideReloadAnimRate=0.750000
     bInstantHit=True
     bSemiautoTrigger=True
     bAutomatic=False
     
     RecoilIndices(0)=(X=15.000000,Y=85.000000)
     RecoilIndices(1)=(X=10.000000,Y=90.000000)
     RecoilIndices(2)=(X=15.000000,Y=85.000000)
     RecoilIndices(3)=(X=20.000000,Y=80.000000)
     NumRecoilIndices=4
     
     SelectTilt(0)=(X=30.000000,Y=40.000000)
     SelectTilt(1)=(X=40.000000,Y=20.000000)
     SelectTiltIndices=2
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.525000
     DownTilt(0)=(X=10.000000,Y=-25.000000)
     DownTiltIndices=1
     DownTiltTimer(0)=0.000000
     
     ReloadBeginTilt(0)=(X=0.000000,Y=0.000000)
     ReloadBeginTilt(1)=(X=-40.000000,Y=-30.000000)
     ReloadBeginTilt(2)=(X=-30.000000,Y=-35.000000)
     ReloadBeginTiltIndices=3
     ReloadBeginTiltTimer(0)=0.000000
     ReloadBeginTiltTimer(1)=0.650000
     ReloadBeginTiltTimer(2)=0.750000
     
     ReloadTilt(0)=(X=5.000000,Y=10.000000)
     ReloadTilt(1)=(X=10.000000,Y=5.000000)
     ReloadTilt(2)=(X=-10.000000,Y=-5.000000)
     ReloadTilt(3)=(X=-5.000000,Y=-10.000000)
     ReloadTiltIndices=4
     ReloadTiltTimer(0)=0.000000
     ReloadTiltTimer(1)=0.250000
     ReloadTiltTimer(2)=0.500000
     ReloadTiltTimer(3)=0.750000
     
     ReloadEndTilt(0)=(X=20.000000,Y=30.000000)
     ReloadEndTilt(1)=(X=30.000000,Y=20.000000)
     ReloadEndTiltIndices=2
     ReloadEndTiltTimer(0)=0.000000
     ReloadEndTiltTimer(1)=0.450000
     
     LowAmmoWaterMark=10
     GoverningSkill=Class'DeusEx.SkillWeaponRifle'
     EnviroEffective=ENVEFF_Air
     ShotTime=0.300000 //Used to be 0.7.
     reloadTime=3.500000 //Down from 4.5, but we've counterbalanced this quite a lot already.
     HitDamage=2
     maxRange=4800
     AccurateRange=2400
     AmmoNames(0)=Class'DeusEx.AmmoShell'
     AmmoNames(1)=Class'DeusEx.AmmoSabot'
     AmmoNames(2)=Class'DeusEx.AmmoDragonsBreath'
     //ProjectileNames(0)=Class'DeusEx.RocketGEP'
     AreaOfEffect=AOE_Cone
     recoilStrength=0.700000
     mpReloadTime=0.500000
     mpHitDamage=5
     mpBaseAccuracy=0.200000
     mpAccurateRange=1800
     mpMaxRange=1800
     mpReloadCount=24
     bCanHaveModReloadCount=True
     bCanHaveModReloadTime=True
     bCanHaveModRecoilStrength=True
     AmmoName=Class'DeusEx.AmmoShell'
     ReloadCount=10
     PickupAmmoCount=10
     FireOffset=(X=-30.000000,Y=10.000000,Z=12.000000)
     shakemag=50.000000
     FireSound=Sound'DeusExSounds.Weapons.AssaultShotgunFire'
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultShotgunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultShotgunReload'
     SelectSound=Sound'DeusExSounds.Weapons.AssaultShotgunSelect'
     InventoryGroup=7
     bNameCaseSensitive=False
     ItemName="Assault Shotgun"
     ItemArticle="an"
     PlayerViewOffset=(Y=-10.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.AssaultShotgun'
     LeftPlayerViewMesh=LodMesh'AssaultShotgunLeft'
     PickupViewMesh=LodMesh'DeusExItems.AssaultShotgunPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.AssaultShotgun3rd'
     LeftThirdPersonMesh=LodMesh'AssaultShotgun3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropMediumWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconAssaultShotgun'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAssaultShotgun'
     largeIconWidth=99
     largeIconHeight=55
     invSlotsX=2
     invSlotsY=2
     Description="The assault shotgun (sometimes referred to as a 'street sweeper') combines the best traits of a normal shotgun with a fully automatic feed that can clear an area of hostiles in a matter of seconds. Particularly effective in urban combat, the assault shotgun accepts either buckshot or sabot shells."
     beltDescription="SHOTGUN"
     Mesh=LodMesh'DeusExItems.AssaultShotgunPickup'
     CollisionRadius=15.000000
     CollisionHeight=8.000000
     Mass=17.000000
     Buoyancy=8.500000
}
