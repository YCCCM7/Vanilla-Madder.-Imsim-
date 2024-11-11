//=============================================================================
// Chemicals.
//=============================================================================
class VMDChemicals extends DeusExPickup;

var int ChemicalThresholds[3];
var Mesh BottleSets[4];

//MADDERS: Do this nonsense for dropping swapped ammos.
function VMDAttemptCrateSwap(int Seed)
{
 	Super.VMDAttemptCrateSwap(Seed);
 	
	Seed = (Seed%4)+1;
	NumCopies = Seed*30;
	UpdateModel();
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	UpdateModel();
}

function UpdateModel()
{
	local Mesh TModel;
	
	TModel = BottleSets[3];
	if (NumCopies <= ChemicalThresholds[0])
	{
		TModel = BottleSets[0];
	}
	else if (NumCopies <= ChemicalThresholds[1])
	{
		TModel = BottleSets[1];
	}
	else if (NumCopies <= ChemicalThresholds[2])
	{
		TModel = BottleSets[2];
	}
	
	if (TModel != None)
	{
		Mesh = TModel;
		PickupViewMesh = TModel;
		ThirdPersonMesh = TModel;
		PlayerViewMesh = TModel;
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
			AddAmount = Min(NumCopies, VMP.MaxChemicals-VMP.CurChemicals);
			if (AddAmount > 0)
			{
				NumCopies -= AddAmount;
				VMP.AddChemicals(AddAmount);
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
				VMP.ClientMessage(VMP.MsgChemicalsFull);
			}
		}
	}
}

defaultproperties
{
     BottleSets(0)=LODMesh'VMDChemicals01'
     BottleSets(1)=LODMesh'VMDChemicals02'
     BottleSets(2)=LODMesh'VMDChemicals03'
     BottleSets(3)=LODMesh'VMDChemicals04'
     
     ChemicalThresholds(0)=50
     ChemicalThresholds(1)=100
     ChemicalThresholds(2)=150
     maxCopies=1000
     bCanHaveMultipleCopies=True
     ItemName="Chemicals"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDChemicals04'
     PickupViewMesh=LodMesh'VMDChemicals04'
     ThirdPersonMesh=LodMesh'VMDChemicals04'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'BeltIconVMDChemicals'
     LargeIconWidth=51
     LargeIconHeight=51
     LargeIcon=Texture'LargeIconVMDChemicals'
     beltDescription="CHEMICALS"
     Mesh=LodMesh'VMDChemicals04'
     CollisionRadius=6.000000
     CollisionHeight=4.250000
     Mass=2.000000
     Buoyancy=1.000000
     
     Texture=Texture'CoreTexGlass.07WindOpacStrek'
}
