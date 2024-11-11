//=============================================================================
// Dart.
//=============================================================================
class Dart extends DeusExProjectile;

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
     Skin=Texture'DartTex1Standard'
     StickAmmoRate=0.350000
     
     mpDamage=20.000000
     bBlood=True
     bStickToWall=True
     DamageType=shot
     spawnAmmoClass=Class'DeusEx.AmmoDart'
     bIgnoresNanoDefense=True //MADDERS: Used to be true.
     ItemName="Dart"
     ItemArticle="a"
     speed=2000.000000
     MaxSpeed=3000.000000
     Damage=15.000000
     MomentumTransfer=1000
     ImpactSound=Sound'DeusExSounds.Generic.BulletHitFlesh'
     Mesh=LodMesh'DeusExItems.Dart'
     CollisionRadius=3.000000
     CollisionHeight=0.500000
     LifeSpan=0.000000 //MADDERS: Dart persistence.
}
