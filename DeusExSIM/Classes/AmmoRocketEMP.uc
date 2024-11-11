//=============================================================================
// AmmoRocketEMP.
//=============================================================================
class AmmoRocketEMP extends DeusExAmmo;

defaultproperties
{
     Mass=16.000000
     bNameCaseSensitive=True
     bVolatile=True
     
     bShowInfo=True
     AmmoAmount=4
     MaxAmmo=20
     ItemName="EMP Rockets"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.GEPAmmo'
     LandSound=Sound'DeusExSounds.Generic.WoodHit2'
     Icon=Texture'BeltIconAmmoEMPRocket'
     largeIcon=Texture'LargeIconAmmoEMPRocket'
     largeIconWidth=46
     largeIconHeight=36
     Description="A set of EMP based rockets for the GEP gun. While very tactical, these rounds incapable of being guided by the in-weapon laser system."
     beltDescription="EMP ROCKET"
     Mesh=LodMesh'DeusExItems.GEPAmmo'
     CollisionRadius=18.000000
     CollisionHeight=7.800000
     bCollideActors=True
     Skin=Texture'EMPRocketAmmo'
}
