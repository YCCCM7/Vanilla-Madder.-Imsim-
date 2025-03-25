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
var localized String MsgCannotReach, MsgFlavorEmpty, MsgNoFlavor;

var bool bAdvancedUse, bOrangeGag;
var int LastSelectedFlavor, NumProducts, AdvancedUses[5], RandIndex, RandBarf[100];
var Vector AdvancedCalcStart, AdvancedCalcBox;

var VendingMachineFlare ShowEffects[9];

function Tick(float DT)
{
	local Vector AngledStart, AngledBox, AngledZBox;
	
	AngledStart = AdvancedCalcStart >> Rotation;
	AngledBox = AdvancedCalcBox >> Rotation;
	AngledZBox = AdvancedCalcBox;
	AngledZBox.X = 0;
	AngledZBox.Y = 0;
	AngledZBox = AngledZBox >> Rotation;
	
	Super.Tick(DT);
	
	/*if (ShowEffects[0] != None)
	{
		ShowEffects[0].SetLocation(Location + AngledStart);
	}
	if (ShowEffects[1] != None)
	{
		ShowEffects[1].SetLocation(Location + AngledStart + AngledBox);
	}
	if (ShowEffects[2] != None)
	{
		ShowEffects[2].SetLocation(Location + AngledStart + AngledZBox*1);
	}
	if (ShowEffects[3] != None)
	{
		ShowEffects[3].SetLocation(Location + AngledStart + AngledBox + AngledZBox*1);
	}
	if (ShowEffects[4] != None)
	{
		ShowEffects[4].SetLocation(Location + AngledStart + AngledZBox*2);
	}
	if (ShowEffects[5] != None)
	{
		ShowEffects[5].SetLocation(Location + AngledStart + AngledBox + AngledZBox*2);
	}
	if (ShowEffects[6] != None)
	{
		ShowEffects[6].SetLocation(Location + AngledStart + AngledZBox*3);
	}
	if (ShowEffects[7] != None)
	{
		ShowEffects[7].SetLocation(Location + AngledStart + AngledBox + AngledZBox*3);
	}*/
}

function string VMDGetItemName()
{
	local bool bWonX, bWonY;
	local int i, FX, FY, FZ, CX, CY, CZ;
	local float TraceGap;
	local string Ret, Flavor;
	local Vector AngledStart, AngledBox, AngledZBox, StartTrace, EndTrace, HitLoc, CheckMin, CheckMax, ClampVect;
	
	local Actor TraceAct;
	local VMDBufferPlayer VMP;
	
	Ret = ItemName;
	VMP = VMDBufferPlayer(GetPlayerPawn());
	
	LastSelectedFlavor = -1;
	Flavor = "None";
	
	if (!bAdvancedUse || VMP == None || VMP.FrobTarget != Self)
	{
		return Ret;
	}
	
	AngledStart = AdvancedCalcStart >> Rotation;
	AngledBox = AdvancedCalcBox >> Rotation;
	AngledZBox = AdvancedCalcBox;
	AngledZBox.X = 0;
	AngledZBox.Y = 0;
	AngledZBox = AngledZBox >> Rotation;
	
	StartTrace = VMP.Location + (VMP.BaseEyeHeight * vect(0,0,1));
	EndTrace = Location + AngledStart + (AngledBox / 2);
	
	TraceGap = FMax(Abs(EndTrace.X - StartTrace.X), Abs(EndTrace.Y - StartTrace.Y));
	HitLoc = StartTrace + Vector(VMP.ViewRotation) * TraceGap;
	//HitLoc.X = EndTrace.X;
	
	CheckMin = Location + AngledStart + (AngledZBox*i);
	CheckMax = CheckMin + AngledBox;
	
	FX = FMin(CheckMin.X, CheckMax.X);
	FY = FMin(CheckMin.Y, CheckMax.Y);
	CX = FMax(CheckMin.X, CheckMax.X);
	CY = FMax(CheckMin.Y, CheckMax.Y);
	bWonX = (HitLoc.X >= FX) && (HitLoc.X < CX);
	bWonY = (HitLoc.Y >= FY) && (HitLoc.Y < CY);
	
	if (!bWonX || !bWonY)
	{
		for(i=0; i<17; i++)
		{
			HitLoc += Vector(VMP.ViewRotation);
			
			bWonX = (HitLoc.X >= FX) && (HitLoc.X < CX);
			bWonY = (HitLoc.Y >= FY) && (HitLoc.Y < CY);
			
			if (bWonX && bWonY) break;
		}
	}
	
	/*if (ShowEffects[8] != None)
	{
		ShowEffects[8].SetLocation(HitLoc);
	}*/
	
	if (SkinColor == SC_Drink)
	{
		if (VMDTargetIsFacing(32768, 8192, VMP))
		{
			for(i=0; i<NumProducts; i++)
			{
				CheckMin = Location + AngledStart + (AngledZBox*i);
				CheckMax = CheckMin + AngledBox;
				
				FX = FMin(CheckMin.X, CheckMax.X);
				FY = FMin(CheckMin.Y, CheckMax.Y);
				FZ = FMin(CheckMin.Z, CheckMax.Z);
				CX = FMax(CheckMin.X, CheckMax.X);
				CY = FMax(CheckMin.Y, CheckMax.Y);
				CZ = FMax(CheckMin.Z, CheckMax.Z);
				
				if ((HitLoc.X >= FX) && (HitLoc.X < CX)
					&& (HitLoc.Y >= FY) && (HitLoc.Y < CY)
					&& (HitLoc.Z >= FZ) && (HitLoc.Z < CZ))
				{
					switch(4-i)
					{
						case 0:
							LastSelectedFlavor = 4;
							Flavor = "Lemon-Lime";
						break;
						case 1:
							LastSelectedFlavor = 0;
							Flavor = "Orange";
						break;
						case 2:
							LastSelectedFlavor = 1;
							Flavor = "Grape";
						break;
						case 3:
							LastSelectedFlavor = 2;
							Flavor = "Berry";
						break;
						case 4:
							LastSelectedFlavor = 3;
							Flavor = "Tropical";
						break;
					}
				}
			}
		}
		
		Ret = Ret@"("$Flavor$")";
	}
	
	return Ret;
}

function InitAdvancedDrinkUsage()
{
	local int i;
	
	bAdvancedUse = true;
	InitRandData(VMDBufferPlayer(GetPlayerPawn()));
	
	LastSelectedFlavor = -1;
	NumProducts = 5;
	for(i=0; i<ArrayCount(AdvancedUses); i++)
	{
		AdvancedUses[i] = FakeRand(5);
	}
	
	AdvancedCalcStart = Vect(20, -13.5, -14.5);
	AdvancedCalcBox = Vect(1, -8, 4.6);
}

function InitRandData(VMDBufferPlayer VMP)
{
	local int i, CurRip, MySeed;
	local class<VMDStaticFunctions> SF;
	
	SF = class'VMDStaticFunctions';
	
	MySeed = SF.Static.DeriveStableActorSeed(Self, 32, true);
	for(i=0; i<ArrayCount(RandBarf); i++)
	{
		CurRip = SF.Static.RipLongSeedChunk(MySeed, i);
		RandBarf[i] = CurRip;
	}
}

function float FakeRand(int Ceil)
{
	local int Ret;
	
	Ret = RandBarf[RandIndex] % Ceil;
	RandIndex = (RandIndex+1)%ArrayCount(RandBarf);
	
	return Ret;
}

function BeginPlay()
{
	Super.BeginPlay();
	
	NumUses = 10;
	CreditCost = 2;
	switch (SkinColor)
	{
		case SC_Drink:
			Skin = Texture'VMDVendingMachineTex1';
			InitAdvancedDrinkUsage();
		break;
		case SC_Snack:
			Skin = Texture'VendingMachineTex2';
			bAdvancedUse = False;
		break;
	}
	
	/*ShowEffects[0] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[0] != None)
	{
	}
	ShowEffects[1] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[1] != None)
	{
		ShowEffects[1].Multiskins[0] = Texture'SolidYellow';
	}
	ShowEffects[2] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[2] != None)
	{
	}
	ShowEffects[3] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[3] != None)
	{
		ShowEffects[3].Multiskins[0] = Texture'SolidYellow';
	}
	ShowEffects[4] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[4] != None)
	{
	}
	ShowEffects[5] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[5] != None)
	{
		ShowEffects[5].Multiskins[0] = Texture'SolidYellow';
	}
	ShowEffects[6] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[6] != None)
	{
	}
	ShowEffects[7] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[7] != None)
	{
		ShowEffects[7].Multiskins[0] = Texture'SolidYellow';
	}
	ShowEffects[8] = Spawn(Class'VendingMachineFlare');
	if (ShowEffects[8] != None)
	{
		ShowEffects[8].Multiskins[0] = Texture'SolidGreen';
	}*/
}

function Frob(actor Frobber, Inventory frobWith)
{
	local bool bDispenseWin;
	local int i, CurTotal;
	local string UseStr;
	local Vector loc;
	local Pickup product;
	local DeusExPlayer player;

	Super.Frob(Frobber, frobWith);
	
	player = DeusExPlayer(Frobber);

	if ((player != None) && (VMDTargetIsFacing(32768, 8192, Player)))
	{
		if (bAdvancedUse)
		{
			if (LastSelectedFlavor < 0)
			{
				Player.ClientMessage(MsgNoFlavor);
			}
			else if (AdvancedUses[LastSelectedFlavor] < 1)
			{
				for (i=0; i<ArrayCount(AdvancedUses); i++)
				{
					if (AdvancedUses[i] > 0) CurTotal += AdvancedUses[i];
				}
				
				if (CurTotal > 0)
				{
					Player.ClientMessage(MsgFlavorEmpty);
				}
				else
				{
					Player.ClientMessage(msgEmpty);
				}
			}
			else
			{
				bDispenseWin = true;
			}
		}
		else
		{
			if (numUses <= 0)
			{
				player.ClientMessage(msgEmpty);
			}
			else
			{
				bDispenseWin = true;
			}
		}
		
		if (bDispenseWin)
		{
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
					{
						PlaySound(sound'VendingCan', SLOT_None);
						if (bAdvancedUse)
						{
							if ((bOrangeGag) && (LastSelectedFlavor == 0))
							{
								SodaCan(Product).SkinIndices[0] = 5;
								bOrangeGag = false;
							}
							else
							{
								SodaCan(Product).SkinIndices[0] = LastSelectedFlavor+1;
							}
							SodaCan(Product).UpdateSodaSkin(0);
							AdvancedUses[LastSelectedFlavor]--;
						}
						else
						{
							NumUses--;
						}
					}
					else
					{
						PlaySound(sound'VendingSmokes', SLOT_None);
						NumUses--;
					}
					product.Velocity = Vector(Rotation) * 100;
					product.bFixedRotationDir = True;
					product.RotationRate.Pitch = (32768 - Rand(65536)) * 4.0;
					product.RotationRate.Yaw = (32768 - Rand(65536)) * 4.0;
					
					player.Credits -= CreditCost;
					UseStr = MsgDispensed;
					player.ClientMessage(UseStr);
					
					//MADDERS: Fucking with vending machines makes lots of noise.
					Instigator = Pawn(Frobber);
					if (!VMDPlausiblyDeniableNoise())
					{
						AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 1024);
					}
				}
			}
			else
			{
				UseStr = MsgNoCredits;
				player.ClientMessage(UseStr);
			}
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
     MsgCannotReach="You can't reach the buttons from here"
     MsgFlavorEmpty="That flavor is empty"
     MsgNoFlavor="Please select a flavor first"
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
