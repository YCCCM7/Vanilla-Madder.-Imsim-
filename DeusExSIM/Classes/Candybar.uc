//=============================================================================
// Candybar.
//=============================================================================
class Candybar extends DeusExPickup;

var() travel int SkinIndices[20]; //1-2.

function VMDUpdatePropertiesHook()
{
 	Super.VMDUpdatePropertiesHook();
 	
 	if (Owner != None)
 	{
  		UpdateCandySkin(NumCopies-1);
 	}
}

function DetermineOwnSkin()
{
 	local CandyBar Peers[16], CB;
 	local int NumPeers, AxisLock;
 	local bool bSupX;
 	local Vector TLoc, TNorm;
 	
 	//Get our data to work with.
 	TNorm = vector(Rotation);
 	if (Abs(TNorm.X) > Abs(TNorm.Y)) bSupX = True; //NOT INVERSE FOR CANDYBAR!
 	if (bSupX) AxisLock = int(Location.Y / 16.0);
 	else AxisLock = int(Location.X / 16.0);
 	
 	//Search for parallel, nearby peers.
 	forEach RadiusActors(class'Candybar', CB, 256)
 	{
  		if ((CB != Self) && (CB.SkinIndices[0] != 0) && (NumPeers < 16))
  		{
   			if ((bSupX) && (int(CB.Location.Y / 16.0) == AxisLock))
   			{
    				Peers[NumPeers] = CB;
    				NumPeers++;
    				SkinIndices[0] = CB.SkinIndices[0];
   			}
   			else if ((!bSupX) && (int(CB.Location.X / 16.0) == AxisLock))
   			{
    				Peers[NumPeers] = CB;
    				NumPeers++;
    				SkinIndices[0] = CB.SkinIndices[0];
   			}
  		}
 	}
 	
 	//If scouting fails, become the first.
 	if (NumPeers == 0)
 	{
  		SkinIndices[0] = 1 + Rand(2);
 	}
}

function PostBeginPlay()
{
 	Super.PostBeginPlay();
 	
 	if (SkinIndices[0] == 0) SkinIndices[0] = 1 + Rand(2);
 	UpdateCandySkin(0);
}

function VMDSignalDropUpdate(DeusExPickup Dropped, DeusExPickup Parent)
{
	Super.VMDSignalDropUpdate(Dropped, Parent);
	
 	//Add from the last stack, just removed.
 	if ((CandyBar(Dropped) != None) && (CandyBar(Parent) != None))
 	{
  		CandyBar(Dropped).SkinIndices[0] = CandyBar(Parent).SkinIndices[Parent.NumCopies];
  		CandyBar(Dropped).UpdateCandySkin(0);
  		CandyBar(Parent).UpdateCandySkin(0);
 	}
}

function UpdateCandySkin( optional int TMod )
{
 	local Texture TTex;
 	local int TInd, TGet, i;
 	local string TStr;
 	
 	TGet = Clamp(NumCopies-1+TMod, 0, 9);; 
 	TInd = SkinIndices[TGet];
 	TStr = "";
 	for(i=0; i<10; i++)
 	{
  		TStr = TStr$SkinIndices[i];
 	}
 	
 	TTex = Texture(DynamicLoadObject("DeusExItems.CandybarTex"$TInd, class'Texture', True));
 	if (TTex != None)
 	{
 		Multiskins[0] = TTex;
 	}
}

//G Flex: Index our skins when removed or added.
function VMDSignalCopiesAdded(DeusExPickup AddTo, DeusExPickup AddFrom)
{
	Super.VMDSignalCopiesAdded(AddTo, AddFrom);
	
 	if ((CandyBar(AddTo) != None) && (CandyBar(AddFrom) != None))
 	{ 
  		CandyBar(AddTo).SkinIndices[CandyBar(AddTo).NumCopies-1] = CandyBar(AddFrom).SkinIndices[AddFrom.NumCopies-1];
  		CandyBar(AddTo).UpdateCandySkin(0);
 	}
}

function VMDSignalCopiesRemoved()
{
	Super.VMDSignalCopiesRemoved();
	
 	if (NumCopies > 0)
 	{  
  		SkinIndices[NumCopies] = 0;
  		UpdateCandySkin(0);
 	}
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player;
		local int FoodSeed;
		local CandyBuffAura CBA;
		local VMDBufferPlayer VMP;
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		VMP = VMDBufferPlayer(Player);
		if (player != None)
		{
			player.HealPlayer(2, False);
			//Sugar is really hard to get addicted to.
			if (VMP != None)
			{
		 		VMP.VMDAddToAddiction("Sugar", 40.0);
				
				FoodSeed = GetFoodSeed(9);
				if (FoodSeed == 1 || FoodSeed == 3 || FoodSeed == 6)
				{
					switch(SkinIndices[NumCopies-1])
					{
						case 0:
					 		VMP.VMDRegisterFoodEaten(2, "Candybar");
							break;
						case 1:
				 			VMP.VMDRegisterFoodEaten(2, "Candybar1"); //Chunk-o-Honey
						break;
						case 2:
				 			VMP.VMDRegisterFoodEaten(2, "Candybar2"); //Monty Bites
						break;
					}
				}
				else
				{
					VMP.VMDRegisterFoodEaten(2, "Candybar");
				}
				
				VMP.VMDGiveBuffType(class'CandyBuffAura', class'CandyBuffAura'.Default.Charge);
			}
		}
		
		UseOnce();
	}
Begin:
}

defaultproperties
{
     SmellType="Food"
     SmellUnits=150
     M_Activated="You eat the %s"
     MsgCopiesAdded="You found %d %ss"
     
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Candy Bar"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Candybar'
     PickupViewMesh=LodMesh'DeusExItems.Candybar'
     ThirdPersonMesh=LodMesh'DeusExItems.Candybar'
     Icon=Texture'DeusExUI.Icons.BeltIconCandyBar'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCandyBar'
     largeIconWidth=46
     largeIconHeight=36
     Description="'CHOC-O-LENT DREAM. IT'S CHOCOLATE! IT'S PEOPLE! IT'S BOTH!(tm) 85% Recycled Material.' |n|nEFFECTS: For 10 seconds: Increased ground speed by 15%."
     beltDescription="CANDY BAR"
     Mesh=LodMesh'DeusExItems.Candybar'
     CollisionRadius=6.250000
     CollisionHeight=0.670000
     Mass=0.300000
     Buoyancy=0.400000
}
