//=============================================================================
// HelmetProjectile
//=============================================================================
class HelmetProjectile extends DeusExProjectile;

#exec OBJ LOAD FILE=Effects

//MADDERS: Randomize ricochet sounds on impact!
function PostBeginPlay()
{
 local int R;
 
 R = Rand(4)+1;
 ImpactSound = Sound(DynamicLoadObject("DeusExSounds.Ricochet"$R, class'Sound', True));
 
 Super.PostBeginPlay();
}

defaultproperties
{
     bUnlit=True
     Scaleglow=20.000000
     ImpactSound=Sound'Ricochet1'

     bBlood=True
     bStickToWall=True
     DamageType=shot
     spawnAmmoClass=None
     bIgnoresNanoDefense=True
     ItemName="Bullet"
     ItemArticle="a"
     speed=2000.000000
     MaxSpeed=3000.000000
     Damage=5.000000
     MomentumTransfer=1000
     ImpactSound=None
     Mesh=LodMesh'Tracer'
     Style=STY_Translucent
     DrawScale=1.750000
     //Multiskins(0)=Texture'SparkFX1'
     CollisionRadius=3.000000
     CollisionHeight=0.500000
}
