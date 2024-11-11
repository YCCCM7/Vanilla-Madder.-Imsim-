//=============================================================================
// DartFlare.
//=============================================================================
class DartFlare extends Dart;

var float mpDamage;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
		Damage = mpDamage;
}

defaultproperties
{
     //MADDERS: New stuck ammo drops.
     StuckAmmoClass=class'DeusEx.AmmoDart'
     Skin=Texture'DartTex1Flare'
     StickAmmoRate=0.650000
     
     mpDamage=10.000000
     DamageType=Burned
     //MADDERS: Used to be AmmoDartFlare, but is no longer.
     spawnAmmoClass=Class'DeusEx.AmmoDart'
     ItemName="Flare Dart"
     Damage=15.000000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=16
     LightSaturation=192
     LightRadius=4
}
