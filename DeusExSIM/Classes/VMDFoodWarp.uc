//=============================================================================
// Food Warp.
// Zoop in some food for us, my guy.
//=============================================================================
class VMDFoodWarp extends VMDSurrealDeco
				config(VMDHousing);

var bool bBobDown;
var float SpinRate, BobRate, BobHeight, CurBobHeight, DefaultDrawScale;

var Mesh MeshIndices[3];
var int CurMeshIndex, NumMeshBobs, MaxMeshBobs;

var(DATA) int CabinetIndex;
var(DATA) float MaxCollisionRadius, MaxCollisionHeight;
var Vector StartLocation;
var Rotator IntendedRotation;

var int NumSummonCodes;

var class<Inventory> CurSummonCode, ValidatedSummonCodeList[64];
var string CurPropertyName, CurPropertyValue, CurItemName;
var Texture LoadedSkin;

var Mesh ItemGivenMesh;
var globalconfig string DefaultSummonCodeList[64], SavedSummonCodes[64];
var globalconfig string SavedPropertyNames[64], SavedPropertyValues[64], SavedSkins[64];

var VMDBufferPlayer WindowPlayer;
var VMDFoodWarpTip MyTip;
var bool bHasWindow;

function class<Inventory> GetValidatedSummonFromIndex(int TarIndex)
{
	return ValidatedSummonCodeList[TarIndex];
}

function string GetSavedSummonFromIndex(int TarIndex)
{
	return SavedSummonCodes[TarIndex];
}

function class<Inventory> GetDefaultSummonFromIndex(int TarIndex)
{
	local string DSC;
	local class<Inventory> Ret;
	
	DSC = DefaultSummonCodeList[TarIndex];
	Ret = class<Inventory>(DynamicLoadObject(DSC, class'Class', True));
	
	return Ret;
}

function SetSavedDataMirror(int NewArray, class<Inventory> NewCode, string NewProp, string NewValue, string NewSkin)
{
	SavedSummonCodes[NewArray] = string(NewCode);
	SavedPropertyNames[NewArray] = NewProp;
	SavedPropertyValues[NewArray] = NewValue;
	SavedSkins[NewArray] = NewSkin;
}

function ApplySpecialStats()
{
	local int i;
	local string TGet;
	local class<Inventory> TLoad;
	
	StartLocation = Location;
	IntendedRotation = Rotation;
	MaxCollisionRadius = FMax(CollisionRadius, MaxCollisionRadius);
	MaxCollisionHeight = FMax(CollisionHeight, MaxCollisionHeight);
	
	CurMeshIndex = class'VMDStaticFunctions'.Static.StripBaseActorSeed(Self) % ArrayCount(MeshIndices);
	Mesh = MeshIndices[CurMeshIndex];
	
	NumSummonCodes = 0;
	for(i=0; i<ArrayCount(DefaultSummonCodeList); i++)
	{
		TLoad = GetDefaultSummonFromIndex(i);
		
		if ((TLoad != None) && (TLoad.Default.CollisionRadius < MaxCollisionRadius) && (TLoad.Default.CollisionHeight < MaxCollisionHeight))
		{
			ValidatedSummonCodeList[NumSummonCodes++] = TLoad;
		}
	}
	
	if ((CabinetIndex >= 0) && (CabinetIndex < ArrayCount(SavedSummonCodes)))
	{
		TGet = GetSavedSummonFromIndex(CabinetIndex);
		TLoad = class<Inventory>(DynamicLoadObject(TGet, class'Class', true));
		
		if (TLoad != None)
		{
			ApplySummonCode(TLoad, SavedPropertyNames[CabinetIndex], SavedPropertyValues[CabinetIndex], LoadSavedSkin(CabinetIndex), false);
		}
	}
}

function Texture LoadSavedSkin(int Index)
{
	local Texture TTex;
	
	TTex = Texture(DynamicLoadObject(SavedSkins[Index], class'Texture', False));
	
	return TTex;
}

function ApplySummonCode(class<Inventory> LoadClass, string LoadProp, string LoadValue, Texture LoadSkin, bool bSaveConfig)
{
	local int i;
	local Vector MySizeVect, OtherSizeVect, TVect;
	local VMDFoodWarp FFW;
	
	if (LoadClass != None)
	{
		CurSummonCode = LoadClass;
		ItemGivenMesh = LoadClass.Default.PickupViewMesh;
		CurPropertyName = LoadProp;
		CurPropertyValue = LoadValue;
		LoadedSkin = LoadSkin;
		CurItemName = LoadClass.Default.ItemName;
		
		Mesh = ItemGivenMesh;
		DrawScale = LoadClass.Default.DrawScale;
		ScaleGlow = LoadClass.Default.ScaleGlow;
		
		if (LoadedSkin != None)
		{
			Skin = LoadedSkin;
			Multiskins[0] = LoadedSkin;
		}
		else
		{
			Skin = LoadClass.Default.Skin;
			Multiskins[0] = LoadClass.Default.Multiskins[0];
		}
		Texture = LoadClass.Default.Texture;
		
		MySizeVect = vect(0,0,1) * Default.CollisionHeight;
		OtherSizeVect = vect(0,0,1) * LoadClass.Default.CollisionHeight;
		
		SetCollisionSize(0, 0);
		SetLocation(StartLocation - MySizeVect + OtherSizeVect);
		SetRotation(IntendedRotation);
		SetCollisionSize(LoadClass.Default.CollisionRadius, LoadClass.Default.CollisionHeight);
		
		//11/5/22: BARF! Account for mapper error, and get this squeezed in as hard as possible.
		TVect = Location;
		for (i=1; i<7; i++)
		{
			SetLocation(TVect - vect(0,0,0.25)*i);
		}
		
		if (bSaveConfig)
		{
			if ((CabinetIndex >= 0) && (CabinetIndex < ArrayCount(SavedSummonCodes)))
			{
				//MADDERS, 4/12/22: Oops. Right. Globalconfig. Let's consult with our Fellow Food Warps.
				//Update all our vars to be current, THEN save. Make sure we are globally in sync!
				forEach AllActors(class'VMDFoodWarp', FFW)
				{
					if ((FFW != None) && (FFW.CabinetIndex != CabinetIndex))
					{
						FFW.SetSavedDataMirror(CabinetIndex, CurSummonCode, CurPropertyName, CurPropertyValue, string(LoadedSkin));
						
						if ((FFW.CabinetIndex >= 0) && (FFW.CabinetIndex < ArrayCount(SavedSummonCodes)))
						{
							SavedSummonCodes[FFW.CabinetIndex] = string(FFW.CurSummonCode);
							SavedPropertyNames[FFW.CabinetIndex] = FFW.CurPropertyName;
							SavedPropertyValues[FFW.CabinetIndex] = FFW.CurPropertyValue;
							SavedSkins[FFW.CabinetIndex] = string(FFW.LoadedSkin);
						}
					}
				}
				
				SavedSummonCodes[CabinetIndex] = string(CurSummonCode);
				SavedPropertyNames[CabinetIndex] = CurPropertyName;
				SavedPropertyValues[CabinetIndex] = CurPropertyValue;
				SavedSkins[CabinetIndex] = string(LoadedSkin);
				SaveConfig();
			}
		}
	}
}

function Tick(float DT)
{
	local Rotator R;
	local Vector V;
	local float UseRate;
	local bool bFrobTargetConfirmed;
	local DeusExPlayer DXP;
	
	DXP = DeusExPlayer(GetPlayerPawn());
	
	if ((CurSummonCode == None) && (bDidSetup))
	{
		//----------------------------
		//MADDERS: Spin behavior!
		R.Yaw = SpinRate*DT;
		SetRotation(Rotation + R);
		
		//----------------------------
		//MADDERS: Bob behavior!
		UseRate = BobHeight*DT;
		if (BobHeight - CurBobHeight < BobHeight / 6 || CurBobHeight < BobHeight / 6) UseRate /= 1.75;
		if (BobHeight - CurBobHeight < BobHeight / 12 || CurBobHeight < BobHeight / 12) UseRate /= 1.75;
		if (BobHeight - CurBobHeight < BobHeight / 24 || CurBobHeight < BobHeight / 24) UseRate /= 1.75;
		
		if ((!bBobDown) && (NumMeshBobs == 0))
		{
			UseRate *= 2;
		}
		if ((bBobdown) && (NumMeshBobs == MaxMeshBobs))
		{
			UseRate *= 1.5;
		}
		
		if (!bBobDown)
		{
			if (CurBobHeight < BobHeight)
			{
				CurBobHeight += UseRate;
				V = Vect(0,0,1) * UseRate;
				if (CurBobHeight > BobHeight)
				{
					V.Z -= (CurBobHeight - BobHeight);
					
					CurBobHeight = BobHeight;
					bBobDown = true;
				}
				SetLocation(Location + V);
 			}
 		}
		else
		{
			if (CurBobHeight > 0)
			{
				CurBobHeight -= UseRate;
				V = Vect(0,0,1) * UseRate;
				if (CurBobHeight < 0)
				{
					V.Z -= (CurBobHeight);
					
					CurBobHeight = 0;
					bBobDown = false;
					
					//Mesh cycling.
					NumMeshBobs++;
					if (NumMeshBobs > MaxMeshBobs)
					{
						NumMeshBobs = 0;
						CurMeshIndex = (CurMeshIndex+1)%ArrayCount(MeshIndices);
						Mesh = MeshIndices[CurMeshIndex];
					}
				}
				SetLocation(Location - V);
			}
		}
		
		//----------------------------
		//MADDERS: Scale behavior!
		if (((bBobDown) && (NumMeshBobs < MaxMeshBobs)) || ((!bBobDown) && (NumMeshBobs > 0)))
		{
			DrawScale = DefaultDrawScale * (0.65 + (FClamp(CurBobHeight / BobHeight, 0.0, 1.0) * 0.35));
		}
		else
		{
			DrawScale = DefaultDrawScale * (FClamp(CurBobHeight / BobHeight, 0.0, 1.0));
		}
	}
	
	if (DXP != None)
	{
		if ((DXP.FrobTarget == Self) && (!bHasWindow))
		{
			V = (vect(-1,0,0) * CollisionRadius * 1.5) >> DXP.ViewRotation;
			
			if ((MyTip != None) && (!MyTip.bDeleteMe))
			{
				if (CurSummonCode == None)
				{
					MyTip.ScaleGlow = 1.0;
					MyTip.IntendedScale = 1.0;
					MyTip.Style = STY_Normal;
				}
				else
				{
					MyTip.ScaleGlow = 0.65;
					MyTip.Style = STY_Translucent;
					MyTip.IntendedScale = 0.5;
				}
				
				MyTip.bEngaged = true;
				MyTip.SetLocation(Location+V);
				MyTip.SetRotation(DXP.ViewRotation);
			}
			else
			{
				MyTip = Spawn(class'VMDFoodWarpTip',,, Location + V, DXP.ViewRotation);
				MyTip.bEngaged = true;
				
				if (CurSummonCode == None)
				{
					MyTip.ScaleGlow = 1.0;
					MyTip.Style = STY_Normal;
					MyTip.IntendedScale = 1.0;
				}
				else
				{
					MyTip.ScaleGlow = 0.65;
					MyTip.Style = STY_Translucent;
					MyTip.IntendedScale = 0.5;
				}
			}
		}
		else
		{
			if ((MyTip != None) && (!MyTip.bDeleteMe))
			{
				MyTip.bEngaged = false;
			}
		}
	}
	
	Super.Tick(DT);
}

function Frob(Actor Frobber, Inventory FrobWith)
{
	local Inventory TInv;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Frobber);
	
	if (VMP != None)
	{
		if (NanoKeyRing(FrobWith) != None)
		{
			WindowPlayer = VMP;
			InvokePurchaseWindow();
		}
		else if (CurSummonCode != None)
		{
			SetCollision(False, False, False);
			
			TInv = Spawn(CurSummonCode,,, Location, Rotation);
			if (TInv != None)
			{
				if ((CurPropertyName != "") && (CurPropertyValue != ""))
				{
					TInv.SetPropertyText(CurPropertyName, CurPropertyValue);	
				}
				TInv.Multiskins[0] = Multiskins[0];
				
				VMP.FrobTarget = TInv;
				VMP.ParseRightClick();
				
				if (MyTip != None)
				{
					MyTip.Destroy();
				}
				Destroy();
			}
			else
			{
				SetCollision(Default.bCollideActors, Default.bBlockActors, Default.bBlockPlayers);
			}
		}
	}
}

function InvokePurchaseWindow()
{
 	local DeusExRootWindow Root;
 	local VMDMenuHousingFoodWindow StartingWindow;
 	
	if (bHasWindow)
	{
		return;
	}
	if (NumSummonCodes < 1)
	{
		Log("WARNING!"@Self@"attempted to raise window, had no valid items!");
		return;
	}
	
 	if (WindowPlayer != None)
 	{
  		Root = DeusExRootWindow(WindowPlayer.rootWindow);
  		
  		if (Root != None)
  		{
   			StartingWindow = VMDMenuHousingFoodWindow(Root.InvokeMenuScreen(Class'VMDMenuHousingFoodWindow', True));
   			
   			if (StartingWindow != None)
   			{
				StartingWindow.OriginalSummonCode = CurSummonCode;
				StartingWindow.OriginalPropertyName = CurPropertyName;
				StartingWindow.OriginalPropertyValue = CurPropertyValue;
				
				StartingWindow.TargetIndex = CabinetIndex;
				StartingWindow.TargetWarp = Self;
				
				StartingWindow.WindowPlayer = WindowPlayer;
    				bHasWindow = True;
				
				StartingWindow.PopulateItemsList();
       			}
  		}
 	}
}

function string VMDGetItemName()
{
	if (CurSummonCode == None || CurItemName == "")
	{
		return ItemName;
	}
	else
	{
		return CurItemName;
	}
}

defaultproperties
{
     bDirectional=True
     MaxCollisionRadius=9
     MaxCollisionHeight=17
     DefaultDrawScale=0.700000
     MeshIndices(0)=LodMesh'FoodWarpCan'
     MeshIndices(1)=LodMesh'FoodWarpPacket'
     MeshIndices(2)=LodMesh'FoodWarpBar'
     MaxMeshBobs=2
     CurMeshIndex=0
     SpinRate=24576
     BobRate=18.000000
     BobHeight=3.000000
     CabinetIndex=-1
     DefaultSummonCodeList(0)="DeusEx.SodaCan"
     DefaultSummonCodeList(1)="DeusEx.SoyFood"
     DefaultSummonCodeList(2)="DeusEx.CandyBar"
     DefaultSummonCodeList(3)="DeusEx.Liquor40oz"
     DefaultSummonCodeList(4)="DeusEx.LiquorBottle"
     DefaultSummonCodeList(5)="DeusEx.WineBottle"
     DefaultSummonCodeList(6)="DeusEx.Cigarettes"
     DefaultSummonCodeList(7)="DeusEx.VialCrack"
     DefaultSummonCodeList(8)="DeusEx.VialAmbrosia"
     
     DefaultSummonCodeList(57)="FGRHK.NoodleCup"
     DefaultSummonCodeList(58)="FGRHK.Fries"
     DefaultSummonCodeList(59)="FGRHK.CoffeeCup"
     DefaultSummonCodeList(60)="FGRHK.BurgerSodaCan"
     DefaultSummonCodeList(61)="FGRHK.Burger"
     DefaultSummonCodeList(62)="TNMItems.Beans"
     DefaultSummonCodeList(63)="TNMItems.KetchupBar"
     
     bBlockPlayers=False
     DrawScale=1.000000
     Physics=PHYS_None
     bInvincible=True
     bCanBeBase=False
     bPushable=False
     bHighlight=False
     ItemName="???"
     Mesh=LodMesh'FoodWarpCan'
     CollisionRadius=5.000000
     CollisionHeight=5.000000
     Mass=2.000000
     Buoyancy=3.000000
     ScaleGlow=1.000000
     Texture=Texture'FoodWarpBlue'
}
