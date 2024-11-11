//=============================================================================
// SodaCan.
//=============================================================================
class SodaCan extends DeusExPickup;

//MADDERS additions
var localized string MsgDrinkUnderwater;

var() travel int SkinIndices[10]; //1-4.

function VMDUpdatePropertiesHook()
{
 	Super.VMDUpdatePropertiesHook();
 	
 	if (Owner != None)
 	{
  		UpdateSodaSkin(0); //NumCopies-1
 	}
}

function DetermineOwnSkin()
{
 	local Sodacan Peers[16], SC;
 	local int NumPeers, AxisLock, MissionNumber;
 	local bool bSupX;
 	local Vector TLoc, TNorm;
	local DeusExLevelInfo DXLI;
 	
 	//Get our data to work with.
 	TNorm = vector(Rotation);
 	if (Abs(TNorm.X) < Abs(TNorm.Y)) bSupX = True; //INVERSE FOR SODACAN!
 	if (bSupX) AxisLock = int(Location.Y / 16.0);
 	else AxisLock = int(Location.X / 16.0);
 	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
	if (DXLI != None) MissionNumber = DXLI.MissionNumber;
	
 	//Search for parallel, nearby peers.
 	forEach RadiusActors(class'Sodacan', SC, 256)
 	{
  		if ((SC != Self) && (SC.SkinIndices[0] != 0) && (NumPeers < 16))
  		{
   			if ((bSupX) && (int(SC.Location.Y / 16.0) == AxisLock))
   			{
    				Peers[NumPeers] = SC;
    				NumPeers++;
    				SkinIndices[0] = SC.SkinIndices[0];
   			}
   			else if ((!bSupX) && (int(SC.Location.X / 16.0) == AxisLock))
   			{
    				Peers[NumPeers] = SC;
    				NumPeers++;
    				SkinIndices[0] = SC.SkinIndices[0];
   			}
  		}
 	}
 	
 	//If scouting fails, become the first.
 	if (NumPeers == 0)
 	{
  		SkinIndices[0] = 1 + Rand(5);
 	}
	
	//MADDERS: Don't make zap soda in fan missions, since it seems to be a classic favorite.
	if (SkinIndices[0] == 2)
	{
		if ((MissionNumber > 69) && (MissionNumber <= 77))
		{
			SkinIndices[0] = 1;
		}
		if (MissionNumber == 16)
		{
			SkinIndices[0] = 1;
		}
	}
}

function PostBeginPlay()
{
 	Super.PostBeginPlay();
 	
 	if (SkinIndices[0] == 0)
 	{
  		DetermineOwnSkin();
 	}
 	UpdateSodaSkin(0);
}

function UpdateSodaSkin( optional int TMod )
{
 	local Texture TTex;
 	local int TInd, TGet, i;
 	local string TStr;
 	
	//MADDERS: Don't reskin zap soda.
	if (InStr(CAPS(String(Class)), "ZAP") > -1)
	{
		return;
	}
	
 	TGet = Clamp(NumCopies-1+TMod, 0, 9);
 	TInd = SkinIndices[TGet];
 	TStr = "";
 	for(i=0; i<10; i++)
 	{
  		TStr = TStr$SkinIndices[i];
 	}
 	
	if (TInd == 5)
	{
		TTex = Texture'VMDSodaCanTex5';
	 	Multiskins[0] = TTex;
	}
	else
	{
 		TTex = Texture(DynamicLoadObject("DeusExItems.SodaCanTex"$TInd, class'Texture', True));
 		if (TTex != None)
 		{
 	 		Multiskins[0] = TTex;
		}
 	}
}

//MADDERS: Index our skins when removed or added.
function VMDSignalCopiesAdded(DeusExPickup AddTo, DeusExPickup AddFrom)
{
	local SodaCan AT, AF;
	
	Super.VMDSignalCopiesAdded(AddTo, AddFrom);
	
	AT = SodaCan(AddTo);
	AF = SodaCan(AddFrom);
	
 	if ((AT != None) && (AF != None))
 	{
  		AT.SkinIndices[AT.NumCopies-1] = AF.SkinIndices[AF.NumCopies-1];
  		AT.UpdateSodaSkin(0);
 	}
}

function VMDSignalCopiesRemoved()
{
	Super.VMDSignalCopiesRemoved();
	
 	if (NumCopies > 0)
 	{
  		SkinIndices[NumCopies] = 0;
  		UpdateSodaSkin(0);
 	}
}

function VMDSignalDropUpdate(DeusExPickup Dropped, DeusExPickup Parent)
{
	local SodaCan D, P;
	
	Super.VMDSignalDropUpdate(Dropped, Parent);
	
	D = SodaCan(Dropped);
	P = SodaCan(Parent);
	
 	//Add from the last stack, just removed.
 	if ((D != None) && (P != None))
 	{
  		D.SkinIndices[0] = P.SkinIndices[P.NumCopies];
  		D.UpdateSodaSkin(0);
  		P.UpdateSodaSkin(0);
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
		local DeusExPlayer player;
		local VMDBufferPlayer VMP;
		local int FoodSeed;
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		VMP = VMDBufferPlayer(Owner);
		if (player != None)
		{
			Owner.AISendEvent('LoudNoise', EAITYPE_Audio, 1.0, 192);
			
			player.HealPlayer(2, False);
			if (VMP != None)
			{
			 	//Sugar is really hard to get addicted to.
			 	VMP.VMDAddToAddiction("Sugar", 20.0);
			 	//Caffeine not so much.
			 	VMP.VMDAddToAddiction("Caffeine", 40.0);
				
				FoodSeed = GetFoodSeed(13);
				if (FoodSeed == 2 || FoodSeed == 5 || FoodSeed == 9)
				{
					switch(SkinIndices[NumCopies-1])
					{
						case 0:
					 		VMP.VMDRegisterFoodEaten(1, "Soda");
						break;
						case 1:
					 		VMP.VMDRegisterFoodEaten(1, "Soda1"); //Nuke
						break;
						case 2:
					 		VMP.VMDRegisterFoodEaten(1, "Soda2"); //Zap
						break;
						case 3:
					 		VMP.VMDRegisterFoodEaten(1, "Soda3"); //"B"... Bomb?
						break;
						case 4:
							VMP.VMDRegisterFoodEaten(1, "Soda4"); //Blast
						break;
						case 5:
							VMP.VMDRegisterFoodEaten(1, "Soda5"); //Flash? NEW!
						break;
					}
				}
				else
				{
					VMP.VMDRegisterFoodEaten(1, "Soda");
				}
				
				VMP.VMDGiveBuffType(class'SodaBuffAura', class'SodaBuffAura'.Default.Charge);
			}
		}
		
		if ((VMP != None) && (VMP.bAssignedFemale)) Player.PlaySound(sound'VMDFJCBurp', SLOT_None,,, 256, VMDGetMiscPitch2());
		else Player.PlaySound(sound'MaleBurp', SLOT_None,,, 256, VMDGetMiscPitch2());
		UseOnce();
	}
Begin:
}

defaultproperties
{
     SmellType="Food"
     SmellUnits=100
     M_Activated="You drink the %s"
     MsgCopiesAdded="You found %d %ss"
     MsgDrinkUnderwater="You cannot do that while underwater"
     
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Soda"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDSodacan'
     PickupViewMesh=LodMesh'VMDSodacan'
     ThirdPersonMesh=LodMesh'VMDSodacan'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconSodaCan'
     largeIcon=Texture'DeusExUI.Icons.LargeIconSodaCan'
     largeIconWidth=24
     largeIconHeight=45
     Description="The can is blank except for the phrase 'PRODUCT PLACEMENT HERE.' It is unclear whether this is a name or an invitation.|n|nEFFECTS: For 15 seconds: Increased aim focus rate by 65% and increased vulnerability to stress."
     beltDescription="SODA"
     Mesh=LodMesh'VMDSodacan'
     CollisionRadius=3.000000
     CollisionHeight=4.500000
     Mass=0.500000
     Buoyancy=0.300000
}
