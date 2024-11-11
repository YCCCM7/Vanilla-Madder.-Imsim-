//=============================================================================
// SoyFood.
//=============================================================================
class SoyFood extends DeusExPickup;

#exec OBJ LOAD FILE=HK_Signs
#exec OBJ LOAD FILE=HK_Helibase
#exec OBJ LOAD FILE=CoreTexMisc
#exec OBJ LOAD FILE=Catacombs
#exec OBJ LOAD FILE=Paris

//The kind of actual effort I put into my jokes, I swear to god. ~Han/Nah
var() travel int SkinIndices[10]; //1-11.

function VMDUpdatePropertiesHook()
{
 	Super.VMDUpdatePropertiesHook();
 	
 	if (Owner != None)
 	{
  		UpdateSoySkin(0);
 	}
}

function Texture ObtainSoyLoadTex(String LoadID)
{
 	local Texture Ret;
 	
 	Ret = Texture(DynamicLoadObject(LoadID, class'Texture', false));
 	if (Ret == None)
 	{
  		Ret = Texture'SoyFoodTex1';
 	}
 	return Ret;
}

function Texture GetSoyTexture(int TInd)
{
 	local int R;
 	
 	switch(TInd)
 	{
  		//See these starting M01
  		//case 1:
  		//case 2: return Texture'SoyFoodTex1'; break;
  		//case 2: return Texture'VendMachine_C'; break;
  		
  		//See these starting M05
  		//case 3: return Texture'Cenfold_A'; break;
  		//case 4: return Texture'VialCrackTex1'; break;
  		
  		//See these only in M06
		//MADDERS: Alas, we are a parody no longer.
  		/*case 5: return Texture'HK_Sign_28'; break;
  		case 6: return Texture'HK_Sign_25'; break;
  		case 7: return Texture'HK_Sign_10'; break;
  		case 8: return Texture'HK_Sign_11'; break;*/
  		
  		//See these only in M10-M11
  		//case 9: return Texture'pa_TrainSign_F'; break;
  		//case 10: return Texture'pa_TrainSign_G'; break;
  		//case 11: return Texture'pa_bldng_h_a'; break;
  		
  		//SPECIAL CASE: Redsun 2020.
  		case 20: return ObtainSoyLoadTex("RS2020_Tex2.RS-COD-Popup"); break;
  		case 21: return ObtainSoyLoadTex("RS2020_Tex2.RS-TokyoS005"); break;
  		case 22: return ObtainSoyLoadTex("RS2020_Textures.RS-DogFood"); break;
  		case 23: return ObtainSoyLoadTex("RS2020_Textures.RS-TMGLogo01b"); break;
  		
  		//Everything else.
  		default: return Texture'SoyFoodTex1'; break;
 	}
 	
 	return Texture'SoyFoodTex1';
}

function int GetRandIndex( int MN )
{
 	local int TR;
 	
 	TR = Rand(2)+1;
 	
 	if (MN < 5) return TR;
 	
 	switch(MN)
 	{
  		case 5:
  		case 7:
  		case 8:
  		case 9:
  		case 12:
  		case 13:
  		case 14:
  		case 15:
   			if (Frand() < 0.5) TR = Rand(2) + 3; 
   			return TR;
  		break;
  		case 6:
   			TR = Rand(4) + 5;
   			return TR;
  		break;
  		case 10:
  		case 11:
   			TR = Rand(3) + 9;
  		break;
  		case 20:
  		case 21:
  		case 22:
   			TR = Rand(4) + 20;
  		break;
 	}
 	
 	return TR;
}

function PostBeginPlay()
{
 	local DeusExLevelInfo LI; 
 	local int TMis;
 	
 	forEach AllActors(class'DeusExLevelInfo', LI) break;
 	
 	Super.PostBeginPlay();
 	
 	if (SkinIndices[0] == 0)
 	{
  		if (LI != None)
  		{
   			TMis = LI.MissionNumber;
   			
   			SkinIndices[0] = GetRandIndex(TMis);
  		}
 	}
 	UpdateSoySkin(0);
}

function VMDSignalDropUpdate(DeusExPickup Dropped, DeusExPickup Parent)
{
	Super.VMDSignalDropUpdate(Dropped, Parent);
	
 	//Add from the last stack, just removed.
 	if ((SoyFood(Dropped) != None) && (SoyFood(Parent) != None))
 	{
  		SoyFood(Dropped).SkinIndices[0] = SoyFood(Parent).SkinIndices[Parent.NumCopies];
  		SoyFood(Dropped).UpdateSoySkin(0);
  		SoyFood(Parent).UpdateSoySkin(0);
 	}
}

function UpdateSoySkin( optional int TMod )
{
 	local Texture TTex;
 	local int TInd, TGet, i;
 	
 	TGet = Clamp(NumCopies-1+TMod, 0, 9); 
 	TInd = SkinIndices[TGet];
 	
 	TTex = GetSoyTexture(TInd);
 	if (TTex != None)
 	{
  		Multiskins[0] = TTex;
 	}
}

//MADDERS: Index our skins when removed or added.
function VMDSignalCopiesAdded(DeusExPickup AddTo, DeusExPickup AddFrom)
{
	Super.VMDSignalCopiesAdded(AddTo, AddFrom);
	
 	if ((SoyFood(AddTo) != None) && (SoyFood(AddFrom) != None))
 	{ 
  		SoyFood(AddTo).SkinIndices[SoyFood(AddTo).NumCopies-1] = SoyFood(AddFrom).SkinIndices[AddFrom.NumCopies-1];
  		SoyFood(AddTo).UpdateSoySkin(0);
 	}
}

function VMDSignalCopiesRemoved()
{
	Super.VMDSignalCopiesRemoved();
	
 	if (NumCopies > 0)
 	{  
  		SkinIndices[NumCopies] = 0;
  		UpdateSoySkin(0);
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
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		if (player != None)
		{
			//There is literally nothing addicting about soyfood.
			player.HealPlayer(5, False);
			if (VMDBufferPlayer(Player) != None)
			{
				FoodSeed = GetFoodSeed(17);
				if (FoodSeed == 2 || FoodSeed == 5 || FoodSeed == 9 || FoodSeed == 14)
				{
					VMDBufferPlayer(Player).VMDRegisterFoodEaten(4, "Literal Soy Food");
				}
				else
				{
					VMDBufferPlayer(Player).VMDRegisterFoodEaten(4, "Soy Food");
				}
			}
		}
		
		UseOnce();
	}
Begin:
}

defaultproperties
{
     SmellType="Food"
     SmellUnits=200
     M_Activated="You eat the %s"
     MsgCopiesAdded="You found %d %s"
     
     maxCopies=10
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Soy Food"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.SoyFood'
     PickupViewMesh=LodMesh'DeusExItems.SoyFood'
     ThirdPersonMesh=LodMesh'DeusExItems.SoyFood'
     Icon=Texture'DeusExUI.Icons.BeltIconSoyFood'
     largeIcon=Texture'DeusExUI.Icons.LargeIconSoyFood'
     largeIconWidth=42
     largeIconHeight=46
     Description="Fine print: 'Seasoned with nanoscale mechanochemical generators, this TSP (textured soy protein) not only tastes good but also self-heats when its package is opened.'"
     beltDescription="SOY FOOD"
     Mesh=LodMesh'DeusExItems.SoyFood'
     CollisionRadius=8.000000
     CollisionHeight=0.980000
     Mass=0.300000
     Buoyancy=0.400000
}
