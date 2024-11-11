//=============================================================================
// ProdMagazine.
//=============================================================================
class ProdMagazine extends VMDWeaponMagazine;

defaultproperties
{
     Mesh=LODMesh'VMDProdMag'
     Fragments(0)=LODMesh'VMDProgMag'
     NumFragmentTypes=1
     CollisionRadius=6.000000
     CollisionHeight=1.500000 //2 * 0.75
}
