//=============================================================================
// VMDEmptyGrenade.
//=============================================================================
class VMDEmptyGrenade extends DeusExPickup;

var localized string MsgCannotActivate;

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool VMDHasActivationObjection()
{
	if (DeusExPlayer(Owner) != None)
	{
		DeusExPlayer(Owner).ClientMessage(MsgCannotActivate);
		return true;
	}
	return false;
}

defaultproperties
{
     MsgCannotActivate="This object cannot be activated in its current state"
     Multiskins(0)=Texture'VMDGrenadeHousingTex1'
     
     bCanHaveMultipleCopies=True
     MaxCopies=10
     bActivatable=True
     ItemName="Grenade Housing"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.GasGrenadePickup'
     PickupViewMesh=LodMesh'DeusExItems.GasGrenadePickup'
     ThirdPersonMesh=LodMesh'DeusExItems.GasGrenade3rd'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'BeltIconGrenadeHousing'
     largeIcon=Texture'LargeIconGrenadeHousing'
     largeIconWidth=23
     largeIconHeight=46
     Description="An empty metal housing shell, suitable for use in some grenades, if given a little more touching up."
     beltDescription="EMPTY"
     Mesh=LodMesh'DeusExItems.GasGrenadePickup'
     CollisionRadius=2.300000
     CollisionHeight=3.300000
     Mass=2.000000
     Buoyancy=1.000000
}
