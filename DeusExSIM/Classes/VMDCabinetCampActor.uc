//=============================================================================
// VMDCabinetCampActor
//=============================================================================
class VMDCabinetCampActor extends VMDFillerActors;

var() bool bLastOpened, bIgnoreLockStatus, bOpenOnceOnly, bEverOpened;
var() int CabinetDoorClosedFrames[4], NumWatchedDoors;
var() Vector MinCampLocation, MaxCampLocation;
var() DeusExMover CabinetDoors[4];

function BeginPlay()
{
	local int TSeed;
	
	Super.BeginPlay();
	
	SetTimer(0.5, True);
}

function Timer()
{
	local bool bOpened;
	local int i;
	local DeusExDecoration DXD;
	local Inventory TInv;
	
	bOpened = false;
	for(i=0; i<NumWatchedDoors; i++)
	{
		if (CabinetDoors[i] == None || CabinetDoors[i].bDestroyed || (CabinetDoors[i].DoorStrength ~= 0.0 && !bIgnoreLockStatus) || CabinetDoors[i].KeyNum != CabinetDoorClosedFrames[i])
		{
			bOpened = true;
			break;
		}
	}
	
	if ((bOpened != bLastOpened) && (!bEverOpened || !bOpenOnceOnly))
	{
		if (bOpened)
		{
			bEverOpened = true;
			forEach AllActors(class'Inventory', TInv)
			{
				if (TInv.Location.X > MinCampLocation.X && TInv.Location.X < MaxCampLocation.X &&
					TInv.Location.Y > MinCampLocation.Y && TInv.Location.Y < MaxCampLocation.Y &&
					TInv.Location.Z > MinCampLocation.Z && TInv.Location.Z < MaxCampLocation.Z)
				{
					TInv.SetCollisionSize(TInv.Default.CollisionRadius, TInv.CollisionHeight);
				}
			}
			forEach AllActors(class'DeusExDecoration', DXD)
			{
				if (DXD.Location.X > MinCampLocation.X && DXD.Location.X < MaxCampLocation.X &&
					DXD.Location.Y > MinCampLocation.Y && DXD.Location.Y < MaxCampLocation.Y &&
					DXD.Location.Z > MinCampLocation.Z && DXD.Location.Z < MaxCampLocation.Z)
				{
					DXD.SetCollisionSize(DXD.Default.CollisionRadius, DXD.CollisionHeight);
				}
			}
		}
		else
		{
			forEach AllActors(class'Inventory', TInv)
			{
				if (TInv.Location.X > MinCampLocation.X && TInv.Location.X < MaxCampLocation.X &&
					TInv.Location.Y > MinCampLocation.Y && TInv.Location.Y < MaxCampLocation.Y &&
					TInv.Location.Z > MinCampLocation.Z && TInv.Location.Z < MaxCampLocation.Z)
				{
					TInv.SetCollisionSize(0, TInv.CollisionHeight);
				}
			}
			forEach AllActors(class'DeusExDecoration', DXD)
			{
				if (DXD.Location.X > MinCampLocation.X && DXD.Location.X < MaxCampLocation.X &&
					DXD.Location.Y > MinCampLocation.Y && DXD.Location.Y < MaxCampLocation.Y &&
					DXD.Location.Z > MinCampLocation.Z && DXD.Location.Z < MaxCampLocation.Z)
				{
					DXD.SetCollisionSize(0, DXD.CollisionHeight);
				}
			}
		}
	}
	
	bLastOpened = bOpened;
}

defaultproperties
{
     NumWatchedDoors=2
     bHidden=True
     DrawScale=0.500000
     Physics=PHYS_None
     DrawType=DT_Mesh
     Mesh=LodMesh'VMDHallucination'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
