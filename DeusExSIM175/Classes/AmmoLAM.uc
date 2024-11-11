//=============================================================================
// AmmoLAM.
//=============================================================================
class AmmoLAM extends DeusExAmmo;

//MADDERS, 1/28/21: Use this for max ammo configuring.
function int VMDConfigureMaxAmmo()
{
	local VMDBufferPlayer VMP;
	local int Ret;
	
	Ret = Super.VMDConfigureMaxAmmo();
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.HasSkillAugment("DemolitionGrenadeMaxAmmo")))
	{
		Ret += 5;
	}
	
	return Ret;
}

defaultproperties
{
     AmmoAmount=1
     MaxAmmo=5
     PickupViewMesh=LodMesh'DeusExItems.TestBox'
     Icon=Texture'DeusExUI.Icons.BeltIconLAM'
     beltDescription="LAM"
     Mesh=LodMesh'DeusExItems.TestBox'
     CollisionRadius=22.500000
     CollisionHeight=16.000000
     bCollideActors=True
}
