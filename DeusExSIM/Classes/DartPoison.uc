//=============================================================================
// DartPoison.
//=============================================================================
class DartPoison extends Dart;

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
     Skin=Texture'DartTex1Poison'
     StickAmmoRate=0.500000
     
     mpDamage=10.000000
     DamageType=Poison
     spawnAmmoClass=Class'DeusEx.AmmoDartPoison'
     ItemName="Tranquilizer Dart"
     Damage=5.000000
}
