//=============================================================================
// AmmoOverchargedBattery.
//=============================================================================
class AmmoOverchargedBattery extends DeusExAmmo;

function name VMDGetSpecialDamageType()
{
	return 'Shocked';
}

defaultproperties
{
     Mass=0.030000
     bShowInfo=True
     AmmoAmount=2
     MaxAmmo=10
     ItemName="Prod Overcharger"
     ItemArticle="a"
     PickupViewMesh=LodMesh'DeusExItems.AmmoProd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoOverchargedBattery'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoOverchargedBattery'
     largeIconWidth=17
     largeIconHeight=46
     Description="These experimental batteries were designed for dealing with augmented individuals. While more energy dense than the conventional batteries that the prod commonly employs, they burn through their energy much faster. The frequency of the electricity generated fails to stun, but can short circuit or outright kill instead."
     beltDescription="OVRCHRG"
     Mesh=LodMesh'DeusExItems.AmmoProd'
     Multiskins(0)=Texture'AmmoOverchargedBattery'
     CollisionRadius=2.100000
     CollisionHeight=5.600000
     bCollideActors=True
}
