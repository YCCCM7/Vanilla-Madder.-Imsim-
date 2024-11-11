//=============================================================================
// VendingMachine.
//=============================================================================
class VendingMachine extends ElectronicDevices;

#exec OBJ LOAD FILE=Ambient

enum ESkinColor
{
	SC_Drink,
	SC_Snack
};

var() ESkinColor SkinColor;

var localized String msgDispensed;
var localized String msgNoCredits;
var int numUses;
var localized String msgEmpty;

var int CreditCost;

//MADDERS additions.
var localized String msgCannotReach;

function BeginPlay()
{
	Super.BeginPlay();
	
	NumUses = 10;
	CreditCost = 2;
	switch (SkinColor)
	{
		case SC_Drink:	Skin = Texture'VendingMachineTex1'; break;
		case SC_Snack:	Skin = Texture'VendingMachineTex2'; break;
	}
}

function Frob(actor Frobber, Inventory frobWith)
{
	local DeusExPlayer player;
	local Vector loc;
	local Pickup product;
	local string UseStr;

	Super.Frob(Frobber, frobWith);
	
	player = DeusExPlayer(Frobber);

	if ((player != None) && (VMDTargetIsFacing(32768, 8192, Player)))
	{
		if (numUses <= 0)
		{
			player.ClientMessage(msgEmpty);
			return;
		}

		if (player.Credits >= CreditCost)
		{
			PlaySound(sound'VendingCoin', SLOT_None);
			loc = Vector(Rotation) * CollisionRadius * 0.8;
			loc.Z -= CollisionHeight * 0.7; 
			loc += Location;
			
			switch (SkinColor)
			{
				case SC_Drink:	product = Spawn(class'Sodacan', None,, loc); break;
				case SC_Snack:	product = Spawn(class'Candybar', None,, loc); break;
			}
			
			if (product != None)
			{
				if (product.IsA('Sodacan'))
					PlaySound(sound'VendingCan', SLOT_None);
				else
					PlaySound(sound'VendingSmokes', SLOT_None);

				product.Velocity = Vector(Rotation) * 100;
				product.bFixedRotationDir = True;
				product.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
				product.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
			}
			
			player.Credits -= CreditCost;
			UseStr = MsgDispensed;
			player.ClientMessage(UseStr);
			numUses--;
			
			//MADDERS: Fucking with vending machines makes lots of noise.
			Instigator = Pawn(Frobber);
			AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 1024);
		}
		else
		{
			UseStr = MsgNoCredits;
			player.ClientMessage(UseStr);
		}
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
     
     CreditCost=2
     msgDispensed="2 credits deducted from your account"
     msgNoCredits="Costs 2 credits..."
     numUses=10
     msgEmpty="It's empty"
     bCanBeBase=True
     ItemName="Vending Machine"
     Mesh=LodMesh'DeusExDeco.VendingMachine'
     SoundRadius=8
     SoundVolume=96
     AmbientSound=Sound'Ambient.Ambient.HumLow3'
     CollisionRadius=34.000000
     CollisionHeight=50.000000
     Mass=150.000000
     Buoyancy=100.000000
}
