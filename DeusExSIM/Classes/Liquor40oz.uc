//=============================================================================
// Liquor40oz.
//=============================================================================
class Liquor40oz extends DeusExPickup;

enum ESkinColor
{
	SC_Super45,
	SC_Bottle2,
	SC_Bottle3,
	SC_Bottle4
};

var() ESkinColor SkinColor;

//MADDERS additions
var localized string MsgDrinkUnderwater;

var() travel int SkinIndices[10]; //1-4.

function VMDUpdatePropertiesHook()
{
 	Super.VMDUpdatePropertiesHook();
 	
 	if (Owner != None)
 	{
  		UpdateBeerSkin(NumCopies-1);
 	}
}

function DetermineOwnSkin()
{
 	local Liquor40Oz Peers[16], LF;
 	local int NumPeers, AxisLock;
 	local bool bSupX;
 	local Vector TLoc, TNorm;
 	
 	//Get our data to work with.
 	TNorm = vector(Rotation);
 	if (Abs(TNorm.X) < Abs(TNorm.Y)) bSupX = True; //INVERSE FOR LIQUOR!
 	if (bSupX) AxisLock = int(Location.Y / 16.0);
 	else AxisLock = int(Location.X / 16.0);
 	
 	//Search for parallel, nearby peers.
 	forEach RadiusActors(class'Liquor40Oz', LF, 256)
 	{
  		if ((LF != Self) && (LF.SkinIndices[0] != 0))
  		{
   			if ((bSupX) && (int(LF.Location.Y / 16.0) == AxisLock))
   			{
    				Peers[NumPeers] = LF;
    				NumPeers++;
    				SkinIndices[0] = LF.SkinIndices[0];
   			}
   			else if ((!bSupX) && (int(LF.Location.X / 16.0) == AxisLock))
   			{
    				Peers[NumPeers] = LF;
   				NumPeers++;
    				SkinIndices[0] = LF.SkinIndices[0];
   			}
  		}
 	}
 	
 	//If scouting fails, become the first.
 	if (NumPeers == 0)
 	{
  		SkinIndices[0] = 1 + Rand(4);
 	}
}

function PostBeginPlay()
{
 	Super.PostBeginPlay();
 	
 	if (SkinIndices[0] == 0) SkinIndices[0] = 1 + Rand(4);
 	UpdateBeerSkin(0);
}

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Super45: //Super 45
			SkinIndices[0] = 1;
		break;
		case SC_Bottle2: //Bull
			SkinIndices[0] = 2;
		break;
		case SC_Bottle3: //Smoked
			SkinIndices[0] = 3;
		break;
		case SC_Bottle4: //Chinese
			SkinIndices[0] = 4;
		break;
	}
}

function VMDSignalDropUpdate(DeusExPickup Dropped, DeusExPickup Parent)
{
	Super.VMDSignalDropUpdate(Dropped, Parent);
	
 	//Add from the last stack, just removed.
 	if ((Liquor40oz(Dropped) != None) && (Liquor40oz(Parent) != None))
 	{
  		Liquor40oz(Dropped).SkinIndices[0] = Liquor40oz(Parent).SkinIndices[Parent.NumCopies];
  		Liquor40oz(Dropped).UpdateBeerSkin(0);
  		Liquor40oz(Parent).UpdateBeerSkin(0);
 	}
}

function UpdateBeerSkin( optional int TMod )
{
 	local Texture TTex;
 	local int TInd, TGet, i;
 	local string TStr;
 	
 	TGet = NumCopies-1+TMod; 
 	TInd = SkinIndices[TGet];
 	TStr = "";
 	for(i=0; i<10; i++)
 	{
  		TStr = TStr$SkinIndices[i];
 	}
 	
 	TTex = Texture(DynamicLoadObject("DeusExItems.Liquor40ozTex"$TInd, class'Texture', True));
 	if (TTex != None)
 	{
  		Multiskins[0] = TTex;
 	}
}

//G Flex: Index our skins when removed or added.
function VMDSignalCopiesAdded(DeusExPickup AddTo, DeusExPickup AddFrom)
{
	Super.VMDSignalCopiesAdded(AddTo, AddFrom);
	
 	if ((Liquor40oz(AddTo) != None) && (Liquor40oz(AddFrom) != None))
 	{
  		Liquor40oz(AddTo).SkinIndices[Liquor40oz(AddTo).NumCopies-1] = Liquor40oz(AddFrom).SkinIndices[AddFrom.NumCopies-1];
  		Liquor40oz(AddTo).UpdateBeerSkin(0);
 	}
}

function VMDSignalCopiesRemoved()
{
	Super.VMDSignalCopiesRemoved();
	
 	if (NumCopies > 0)
 	{
  		SkinIndices[NumCopies] = 0;
  		UpdateBeerSkin(0);
 	}
}

function bool VMDHasActivationObjection()
{
	local DeusExPlayer Player;
	
	Player = DeusExPlayer(Owner);
	if ((Player != None) && (Player.HeadRegion.Zone.bWaterZone))
	{
		Player.ClientMessage(MsgDrinkUnderwater);
		return true;
	}
	
	return false;
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local int FoodSeed;
		local DeusExPlayer player;
		local VMDBufferPlayer VMP;
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		if (player != None)
		{
			VMP = VMDBufferPlayer(Player);
			player.HealPlayer(2, False);
			player.drugEffectTimer += 5.0;
			
			if (VMP != None)
			{
			 	//Alcohol is considerably addictive.
			 	VMP.VMDAddToAddiction("Alcohol", 60.0);
				FoodSeed = GetFoodSeed(17);
				if (FoodSeed == 2 || FoodSeed == 5 || FoodSeed == 9 || FoodSeed == 14)
				{
			 		VMP.VMDRegisterFoodEaten(1, "BeerFluff"); //Half for liquids.
				}
				else
				{
					VMP.VMDRegisterFoodEaten(1, "Beer"); //Half for liquids.
				}
				
				VMP.VMDGiveBuffType(class'DrunkEffectAura', VMP.DrugEffectTimer*40.0);
			}
		}

		UseOnce();
	}
Begin:
}

defaultproperties
{
     SmellType="Food"
     SmellUnits=75
     M_Activated="You drink the %s"
     MsgCopiesAdded="You found %d %ss"
     
     MsgDrinkUnderwater="You cannot do that while underwater"
     bBreakable=True
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Forty Oz Beer"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Liquor40oz'
     PickupViewMesh=LodMesh'DeusExItems.Liquor40oz'
     ThirdPersonMesh=LodMesh'DeusExItems.Liquor40oz'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconBeerBottle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconBeerBottle'
     largeIconWidth=14
     largeIconHeight=47
     Description="'COLD SWEAT forty ounce malt liquor. Never let 'em see your COLD SWEAT.'"
     beltDescription="FORTY"
     Mesh=LodMesh'DeusExItems.Liquor40oz'
     CollisionRadius=3.000000
     CollisionHeight=9.140000
     Mass=1.000000
     Buoyancy=0.800000
}
