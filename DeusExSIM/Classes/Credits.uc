//=============================================================================
// Credits.
//=============================================================================
class Credits extends DeusExPickup;

var() int numCredits;
var localized String msgCreditsAdded;

var bool bCreditsSet;

//Fix our credits if lying around in world.
function PostPostBeginPlay()
{
 	Super.PostPostBeginPlay();
 	
 	if ((!bCreditsSet) && (Pawn(Owner) == None) && (NumCredits == 1)) NumCredits = 100;
 	bCreditsSet = true;
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
		local int TAdd;
		local DeusExPlayer player;
		
		Super.Frob(Frobber, frobWith);
		
		player = DeusExPlayer(Frobber);
		
		if (player != None)
		{
			TAdd = NumCredits;
			
			//MADDERS: No, seriously. How did nobody think of this shit before?
			TAdd = (numCredits*NumCopies);
			if (VMDBufferPlayer(Player) != None)
			{
			 	VMDBufferPlayer(Player).VMDModPlayerStress(TAdd * -1 * Min(TAdd / 100, 1),,, true);
			}
			class'VMDStaticFunctions'.Static.AddReceivedItem(Player, Self, TAdd);
			player.Credits += TAdd;
			player.ClientMessage(Sprintf(msgCreditsAdded, TAdd));
			player.FrobTarget = None;
			Destroy();
		}
	}
}

function string VMDGetItemName()
{
	return ItemName@"("$Max(NumCopies, NumCredits)$")";
}

defaultproperties
{
     maxCopies=9999
     bCanHaveMultipleCopies=True
     numCredits=1
     msgCreditsAdded="%d credit(s) added"
     ItemName="Credit Chit"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Credits'
     PickupViewMesh=LodMesh'DeusExItems.Credits'
     ThirdPersonMesh=LodMesh'DeusExItems.Credits'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconCredits'
     beltDescription="CREDITS"
     Mesh=LodMesh'DeusExItems.Credits'
     CollisionRadius=7.000000
     CollisionHeight=0.550000
     Mass=2.000000
     Buoyancy=3.000000
}
