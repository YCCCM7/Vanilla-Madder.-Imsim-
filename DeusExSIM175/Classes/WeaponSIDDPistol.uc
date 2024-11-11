//=============================================================================
// WeaponSIDDPistol.
//=============================================================================
class WeaponSIDDPistol extends WeaponPistol;

var float SpinUpPercentage;

function bool VMDTraceFireHook(float Accuracy)
{
	local float TMod;
	
	Super.VMDTraceFirehook(Accuracy);
	
	TMod = 1.0;
	if (VMDSIDD(Owner) != None)
	{
		TMod = VMDSIDD(Owner).SpinUpModifier;
	}
	SpinUpPercentage += ShotTime + (0.035 * TMod);
	
	return true;
}

state NormalFire
{
	function float GetShotTime()
	{
		if (SpinUpPercentage > 0)
		{
			return ShotTime / SpinUpPercentage;
		}
		else
		{
			return ShotTime;
		}
	}
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	if (SpinUpPercentage > 1.0)
	{
		if (ClipCount >= ReloadCount)
		{
			SpinUpPercentage = 0;
		}
		else
		{
			SpinUpPercentage -= DT;
		}
	}
}

defaultproperties
{
     SpinUpPercentage=1.000000
     
     OverrideAnimRate=50.000000
     AimDecayMult=-12.500000
     PenetrationHitDamage=3
     RicochetHitDamage=2
     
     LowAmmoWaterMark=30
     ShotTime=0.750000
     HitDamage=4
     recoilStrength=0.600000
     AmmoName=Class'DeusEx.Ammo762mm'
     ReloadCount=30
     PickupAmmoCount=0
     ItemName="SIDD Pistol"
     
     AltFireSound=Sound'DeusExSounds.Weapons.AssaultGunReloadEnd'
     CockingSound=Sound'DeusExSounds.Weapons.AssaultGunReload'
}
