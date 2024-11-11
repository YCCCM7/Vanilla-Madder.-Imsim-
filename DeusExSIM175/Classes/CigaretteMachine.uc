//=============================================================================
// CigaretteMachine.
//=============================================================================
class CigaretteMachine extends ElectronicDevices;

#exec OBJ LOAD FILE=Ambient

var localized String msgDispensed;
var localized String msgNoCredits;
var int numUses;
var localized String msgEmpty;

//MADDERS additions.
var localized String msgCannotReach;

//MADDERS: Fix offset problems on buggy maps. Fucking why?
//9/11/21: Yeah, we're averting this disaster as it sometimes just breaks shit.
function ApplySpecialStats()
{
 	local Vector Off, CH, CR;
 	local float OR, OH;
 	
 	if (bDidSetup) return;
 	
 	/*CR = vect(-0.8, 0, 0) * CollisionRadius;
 	CH = vect(0, 0, 1) * CollisionHeight;
 	Off = (CR + CH) >> Rotation;
 	if (FastTrace(Location + (Off/2), Location))
 	{
  		OR = CollisionRadius;
  		OH = CollisionHeight;
  		SetCollisionSize(0, 0);
  		SetLocation(Location + Off);
  		SetCollisionSize(OR, OH);
 	}*/
 	
 	Super.ApplySpecialStats();
}

function Frob(actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
	local Vector loc;
	local Pickup product;

	Super.Frob(Frobber, frobWith);
	
	player = DeusExPlayer(Frobber);

	if ((player != None) && (VMDTargetIsFacing(32768, 6144, Player)))
	{
		if (numUses <= 0)
		{
			player.ClientMessage(msgEmpty);
			return;
		}

		if (player.Credits >= 8)
		{
			PlaySound(sound'VendingCoin', SLOT_None);
			loc = Vector(Rotation) * CollisionRadius * 0.8;
			loc.Z -= CollisionHeight * 0.6; 
			loc += Location;

			product = Spawn(class'Cigarettes', None,, loc);

			if (product != None)
			{
				PlaySound(sound'VendingSmokes', SLOT_None);
				product.Velocity = Vector(Rotation) * 100;
				product.bFixedRotationDir = True;
				product.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
				product.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
			}

			player.Credits -= 8;
			player.ClientMessage(msgDispensed);
			numUses--;
			
			//MADDERS: Fucking with vending machines makes lots of noise.
			Instigator = Pawn(Frobber);
			AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 768);
		}
		else
			player.ClientMessage(msgNoCredits);
	}
	else if (Player != None)
	{
		Player.ClientMessage(MsgCannotReach);
	}
}

defaultproperties
{
     //MADDERS additions
     msgCannotReach="You can't reach the buttons from here"
     bBlockSight=True
     
     msgDispensed="8 credits deducted from your account"
     msgNoCredits="Costs 8 credits..."
     numUses=10
     msgEmpty="It's empty"
     ItemName="Cigarette Machine"
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.CigaretteMachine'
     SoundRadius=8
     SoundVolume=96
     AmbientSound=Sound'Ambient.Ambient.HumLight3'
     CollisionRadius=27.000000
     CollisionHeight=26.320000
     Mass=150.000000
     Buoyancy=100.000000
}
