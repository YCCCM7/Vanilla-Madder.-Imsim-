//=============================================================================
// WeaponGreaselSpit.
//=============================================================================
class WeaponGreaselSpit extends WeaponNPCRanged;

defaultproperties
{
     ItemName="Spit Glands"
     bForceSoundGeneration=True //MADDERS, 4/11/21: This makes noise now.
     
     ShotTime=1.500000
     HitDamage=8
     maxRange=450
     AccurateRange=300
     bHandToHand=True
     AmmoName=Class'DeusEx.AmmoGreaselSpit'
     PickupAmmoCount=4
     ProjectileClass=Class'DeusEx.GreaselSpit'
}
