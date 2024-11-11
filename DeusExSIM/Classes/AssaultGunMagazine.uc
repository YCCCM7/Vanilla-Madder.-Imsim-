//=============================================================================
// AssaultGunMagazine.
//=============================================================================
class AssaultGunMagazine extends VMDWeaponMagazine;

defaultproperties
{
     Multiskins(0)=Texture'VMDAssaultGunMagTex1'
     Mesh=LODMesh'Ammo762mm'
     Fragments(0)=LODMesh'Ammo762mm'
     NumFragmentTypes=1
     CollisionRadius=6.000000
     CollisionHeight=1.500000 //2 * 0.75
}
