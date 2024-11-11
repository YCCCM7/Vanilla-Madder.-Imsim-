//=============================================================================
// AmmoPlasmaPlague.
//=============================================================================
class AmmoPlasmaPlague extends DeusExAmmo;

defaultproperties
{
     bShowInfo=True
     AmmoAmount=12
     MaxAmmo=84
     ItemName="Nanoplague Plasma Clip"
     ItemArticle="a"
     PickupViewMesh=LodMesh'DeusExItems.AmmoPlasma'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'BeltIconAmmoPlasmaNanoPlague'
     LargeIcon=Texture'LargeIconAmmoPlasmaNanoPlague'
     largeIconWidth=22
     largeIconHeight=46
     Description="Based off of standard plasma slugs, these rounds fire a nanite solution similar to otherwise hypothetical 'grey goo'. However, trying to use grey goo as a catch all exhibits extreme levels of entropy. As a result, these rounds only consume a target or two at a time before having their 'swarms' give out entirely, thus needing another salvo. Where you found this ammo is dubious, but in its current state, these erratic 'test bots' are incomplete, and only re-assemble matter as either bio cells and yet more plague plasma, both of which are rarely finished in time."
     beltDescription="PLAGUE"
     Mesh=LodMesh'DeusExItems.AmmoPlasma'
     CollisionRadius=4.300000
     CollisionHeight=8.440000
     bCollideActors=True
     Multiskins(0)=Texture'AmmoPlasmaNanoPlague'
}
