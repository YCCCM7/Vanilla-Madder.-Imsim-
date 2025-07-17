//=============================================================================
// PS20Magazine.
//=============================================================================
class PS20Magazine extends VMDWeaponMagazine;

defaultproperties
{
     bAmmoLookalike=True
     Mesh=LODMesh'HideAGunPickup'
     Fragments(0)=LODMesh'HideAGunPickup'
     NumFragmentTypes=1
     CollisionRadius=6.000000
     CollisionHeight=1.200000 //2 * 0.6
}
