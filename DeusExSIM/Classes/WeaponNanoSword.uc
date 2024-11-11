//=============================================================================
// WeaponNanoSword.
//=============================================================================
class WeaponNanoSword extends DeusExWeapon;

var float bubbleTimer;

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
		LightType = LT_Steady;
		
		//MADDERS, 11/30/21: Drawing sword is loud. Keeping it out is OK enough, since the light can reveal ourselves in the dark.
		if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Self, "Reload Noise"))
		{
			AISendEvent('LoudNoise', EAITYPE_Audio, TransientSoundVolume, 320);
		}
	}
	
	simulated function Tick(float deltaTime)
	{
		local vector loc;
		
		Super.Tick(deltaTime);
		
		if (Region.Zone != None && Region.Zone.bWaterZone)
		{	
			// Randomly spawn an air bubble every 0.2 seconds
			bubbleTimer += deltaTime;
			if (bubbleTimer >= 0.2)
			{
				bubbleTimer = 0;
				// if (FRand() < 0.4)
				// {
					// loc = Location + VRand();
					if (Pawn(Owner) != None)
						loc = Owner.Location + CalcDrawOffset() + VRand() * 4;
					Spawn(class'AirBubble', Self,, loc);
				// }
			}
		}
	}
}

auto state Pickup
{
	simulated function Tick(float deltaTime)
	{
		local vector loc;
		
		Super.Tick(deltaTime);
		
		if (Region.Zone != None && Region.Zone.bWaterZone)
		{	
			// Randomly spawn an air bubble every 0.2 seconds
			bubbleTimer += deltaTime;
			if (bubbleTimer >= 0.2)
			{
				bubbleTimer = 0;
				// if (FRand() < 0.4)
				// {
					loc = Location + (VRand() * CollisionRadius);
					loc.Z = Location.Z;
					Spawn(class'AirBubble', Self,, loc);
				// }
			}
		}
	}
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

defaultproperties
{
     //HandSkinIndex=0
     bSemiautoTrigger=True
     //MADDERS: Don't reskin our blade. Yuck.
     SkinSwapException(4)=1
     SkinSwapException(5)=1
     SkinSwapException(6)=1
     OverrideNumProj=3
     EvolvedName="Nonotech Blade"
     EvolvedBelt="TWENTY-ONE"
     MeleeAnimRates(0)=1.000000
     MeleeAnimRates(1)=1.000000
     MeleeAnimRates(2)=1.000000
     
     ShotTime=0.050000
     bCanRotateInInventory=True
     RotatedIcon=Texture'LargeIconDragonToothRotated'
     
     SelectTilt(0)=(X=20.000000,Y=15.000000)
     SelectTilt(1)=(X=0.000000,Y=0.000000)
     SelectTilt(2)=(X=-15.000000,Y=-10.000000)
     SelectTilt(3)=(X=0.000000,Y=0.000000)
     SelectTiltIndices=4
     SelectTiltTimer(0)=0.000000
     SelectTiltTimer(1)=0.500000
     SelectTiltTimer(2)=0.583000
     SelectTiltTimer(3)=0.750000
     DownTilt(0)=(X=15.000000,Y=-10.000000)
     DownTilt(1)=(X=0.000000,Y=0.000000)
     DownTilt(2)=(X=20.000000,Y=-15.000000)
     DownTiltIndices=3
     DownTiltTimer(0)=0.000000
     DownTiltTimer(1)=0.420000
     DownTiltTimer(2)=0.500000
     
     MeleeSwing1Tilt(0)=(X=40.000000,Y=25.000000)
     MeleeSwing1Tilt(1)=(X=-40.000000,Y=-25.000000)
     MeleeSwing1Tilt(2)=(X=-30.000000,Y=-15.000000)
     MeleeSwing1Tilt(3)=(X=0.000000,Y=0.000000)
     MeleeSwing1Tilt(4)=(X=30.000000,Y=-15.000000)
     MeleeSwing1Tilt(5)=(X=15.000000,Y=40.000000)
     MeleeSwing1TiltIndices=6
     MeleeSwing1TiltTimer(0)=0.000000
     MeleeSwing1TiltTimer(1)=0.250000
     MeleeSwing1TiltTimer(2)=0.500000
     MeleeSwing1TiltTimer(3)=0.666000
     MeleeSwing1TiltTimer(4)=0.750000
     MeleeSwing1TiltTimer(5)=0.875000
     
     //Attack2 is the same thing as Attack1. Keep it empty so it defers to Attack1 by default.
     
     MeleeSwing3Tilt(0)=(X=-135.000000,Y=-50.000000)
     MeleeSwing3Tilt(1)=(X=0.000000,Y=0.000000)
     MeleeSwing3Tilt(2)=(X=67.500000,Y=25.000000)
     MeleeSwing3Tilt(3)=(X=52.500000,Y=-15.000000)
     MeleeSwing3Tilt(4)=(X=0.000000,Y=0.000000)
     MeleeSwing3Tilt(5)=(X=-52.500000,Y=25.000000)
     MeleeSwing3TiltIndices=6
     MeleeSwing3TiltTimer(0)=0.000000
     MeleeSwing3TiltTimer(1)=0.125000
     MeleeSwing3TiltTimer(2)=0.250000
     MeleeSwing3TiltTimer(3)=0.500000
     MeleeSwing3TiltTimer(4)=0.625000
     MeleeSwing3TiltTimer(5)=0.875000
     
     MinSpreadAcc=4.000000
     LowAmmoWaterMark=0
     GoverningSkill=Class'DeusEx.SkillWeaponLowTech'
     NoiseLevel=0.050000
     reloadTime=0.000000
     HitDamage=15
     maxRange=96
     AccurateRange=96
     BaseAccuracy=1.000000
     AreaOfEffect=AOE_Cone
     bHasMuzzleFlash=False
     bHandToHand=True
     SwingOffset=(X=24.000000,Z=2.000000)
     mpHitDamage=10
     mpBaseAccuracy=1.000000
     mpAccurateRange=150
     mpMaxRange=150
     AmmoName=Class'DeusEx.AmmoNone'
     ReloadCount=0
     bInstantHit=True
     FireOffset=(X=-21.000000,Y=16.000000,Z=27.000000)
     shakemag=20.000000
     FireSound=Sound'DeusExSounds.Weapons.NanoSwordFire'
     SelectSound=Sound'DeusExSounds.Weapons.NanoSwordSelect'
     Misc1Sound=Sound'DeusExSounds.Weapons.NanoSwordHitFlesh'
     Misc2Sound=Sound'DeusExSounds.Weapons.NanoSwordHitHard'
     Misc3Sound=Sound'DeusExSounds.Weapons.NanoSwordHitSoft'
     InventoryGroup=14
     bNameCaseSensitive=False
     ItemName="Dragon's Tooth Sword"
     ItemArticle="the"
     PlayerViewOffset=(X=21.000000,Y=-16.000000,Z=-27.000000)
     PlayerViewMesh=LodMesh'DeusExItems.NanoSword'
     LeftPlayerViewMesh=LodMesh'NanoSwordLeft'
     PickupViewMesh=LodMesh'DeusExItems.NanoSwordPickup'
     ThirdPersonMesh=LodMesh'DeusExItems.NanoSword3rd'
     LeftThirdPersonMesh=LodMesh'NanoSword3rdLeft'
     LandSound=Sound'DeusExSounds.Generic.DropLargeWeapon'
     Icon=Texture'DeusExUI.Icons.BeltIconDragonTooth'
     largeIcon=Texture'DeusExUI.Icons.LargeIconDragonTooth'
     largeIconWidth=205
     largeIconHeight=46
     invSlotsX=4 //MADDERS: Fuck this weapon. Too op.
     Description="The true weapon of a modern warrior, the Dragon's Tooth is not a sword in the traditional sense, but a nanotechnologically constructed blade that is dynamically 'forged' on command into a non-eutactic solid. Nanoscale whetting devices insure that the blade is both unbreakable and lethally sharp."
     beltDescription="DRAGON"
     Mesh=LodMesh'DeusExItems.NanoSwordPickup'
     CollisionRadius=32.000000
     CollisionHeight=2.400000
     LightType=LT_Steady
     LightEffect=LE_WateryShimmer
     LightBrightness=224
     LightHue=160
     LightSaturation=64
     LightRadius=4
     Mass=6.000000
     Buoyancy=3.000000
}
