//=============================================================================
// ScrapMetal.
//=============================================================================
class VMDScrapMetal extends DeusExPickup;

var int ScrapThresholds[3];

//MADDERS: Do this nonsense for dropping swapped ammos.
function VMDAttemptCrateSwap(int Seed)
{
 	Super.VMDAttemptCrateSwap(Seed);
 	
	Seed = (Seed%4)+1;
	NumCopies = Seed*15;
	UpdateModel();
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	UpdateModel();
}

function UpdateModel()
{
	Multiskins[2] = None;
	Multiskins[3] = None;
	Multiskins[4] = None;
	if (NumCopies <= ScrapThresholds[0])
	{
		Multiskins[2] = Texture'PinkMaskTex';
	}
	if (NumCopies <= ScrapThresholds[1])
	{
		Multiskins[3] = Texture'PinkMaskTex';
	}
	if (NumCopies <= ScrapThresholds[2])
	{
		Multiskins[4] = Texture'PinkMaskTex';
	}
}

// ----------------------------------------------------------------------
// Frob()
//
// Add these credits to the player's credits count
// ----------------------------------------------------------------------
auto state Pickup
{
	function Frob(Actor Frobber, Inventory frobWith)
	{
		local VMDBufferPlayer VMP;
		local int AddAmount;
		
		//Super.Frob(Frobber, frobWith);
		
		VMP = VMDBufferPlayer(Frobber);
		if (VMP != None)
		{
			AddAmount = Min(NumCopies, VMP.MaxScrap-VMP.CurScrap);
			if (AddAmount > 0)
			{
				NumCopies -= AddAmount;
				VMP.AddScrap(AddAmount);
				class'VMDStaticFunctions'.Static.AddReceivedItem(VMP, Self, AddAmount, true);
				
				if (NumCopies <= 0)
				{
					VMP.FrobTarget = None;
					Destroy();
				}
				else
				{
					UpdateModel();
				}
			}
			else
			{
				VMP.ClientMessage(VMP.MsgScrapFull);
			}
		}
	}
}

defaultproperties
{
     ScrapThresholds(0)=50
     ScrapThresholds(1)=100
     ScrapThresholds(2)=150
     maxCopies=1000
     bCanHaveMultipleCopies=True
     ItemName="Scrap Metal"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDScrapMetal'
     PickupViewMesh=LodMesh'VMDScrapMetal'
     ThirdPersonMesh=LodMesh'VMDScrapMetal'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'BeltIconVMDScrapMetal'
     LargeIconWidth=51
     LargeIconHeight=51
     LargeIcon=Texture'LargeIconVMDScrapMetal'
     beltDescription="SCRAP"
     Mesh=LodMesh'VMDScrapMetal'
     CollisionRadius=5.000000
     CollisionHeight=2.500000
     Mass=2.000000
     Buoyancy=1.000000
}
