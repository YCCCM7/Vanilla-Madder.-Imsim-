//=============================================================================
// AmmoEMPGrenade.
//=============================================================================
class AmmoEMPGrenade extends DeusExAmmo;

//MADDERS, 1/28/21: Use this for max ammo configuring.
function int VMDConfigureMaxAmmo()
{
	local int Ret;
	
	Ret = Super.VMDConfigureMaxAmmo();
	if (VMDHasSkillAugment('DemolitionGrenadeMaxAmmo'))
	{
		Ret += 5;
	}
	
	return Ret;
}

defaultproperties
{
     Mass=0.000000
     AmmoAmount=1
     MaxAmmo=5
     PickupViewMesh=LodMesh'DeusExItems.TestBox'
     Icon=Texture'DeusExUI.Icons.BeltIconEMPGrenade'
     beltDescription="EMP GREN"
     Mesh=LodMesh'DeusExItems.TestBox'
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     bCollideActors=True
}
