//=============================================================================
// VendingMachineFlare.
//=============================================================================
class VendingMachineFlare extends DeusExPickup;

function Tick(Float DT)
{
	Super.Tick(DT);
	
	SetCollision(False, False, False);
}

defaultproperties
{
     bCollideActors=False
     bBlockActors=False
     bProjTarget=False
     DrawScale=0.500000
     PlayerViewMesh=LodMesh'DeusExItems.SphereEffect'
     PickupViewMesh=LodMesh'DeusExItems.SphereEffect'
     ThirdPersonMesh=LodMesh'DeusExItems.SphereEffect'
     Mesh=LodMesh'DeusExItems.SphereEffect'
     CollisionRadius=6.200000
     CollisionHeight=1.200000
     
     PickupViewScale=0.500000
     DrawScale=0.500000
     Style=STY_Translucent
     Multiskins(0)=Texture'SolidRed'
     Physics=PHYS_None
}
