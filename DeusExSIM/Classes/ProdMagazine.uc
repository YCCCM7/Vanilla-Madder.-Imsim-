//=============================================================================
// ProdMagazine.
//=============================================================================
class ProdMagazine extends VMDWeaponMagazine;

defaultproperties
{
     bAmmoLookalike=True
     Mesh=LODMesh'VMDProdMag'
     Fragments(0)=LODMesh'VMDProdMag'
     NumFragmentTypes=1
     CollisionRadius=6.000000
     CollisionHeight=1.500000 //2 * 0.75
}
