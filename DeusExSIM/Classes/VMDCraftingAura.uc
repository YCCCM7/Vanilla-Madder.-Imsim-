//=============================================================================
// VMDCraftingAura.
//=============================================================================
class VMDCraftingAura extends VMDFakeBuffAura;

//Medical vs mechanical, breakdown vs craft, and tools vs freehand.
var travel bool bMedicalCrafting, bBreakdown, bToolsRequired;
var travel int ComponentCost, CraftQuan, MatQuanA, MatQuanB, MatQuanC, MaxCharge;
var travel float CraftTimeMult;

var class<Inventory> CraftClass, CraftMatA, CraftMatB, CraftMatC;
var travel string TravelCraftClass, TravelCraftMatA, TravelCraftMatB, TravelCraftMatC;

var localized string StrCraftingSuccess, StrBreakdownSuccess, StrStartCrafting, StrStartBreakdown, StrCraftingCanceled,
			StrCraftingFailedSupplies, StrCraftingFailedWater, StrCraftingFailedInterrupted;

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	if (TravelCraftClass != "")
	{
		CraftClass = class<Inventory>(DynamicLoadObject(TravelCraftClass, class'Class', false));
	}
	
	if (TravelCraftMatA != "")
	{
		CraftMatA = class<Inventory>(DynamicLoadObject(TravelCraftMatA, class'Class', false));
	}
	if (TravelCraftMatB != "")
	{
		CraftMatB = class<Inventory>(DynamicLoadObject(TravelCraftMatB, class'Class', false));
	}
	if (TravelCraftMatC != "")
	{
		CraftMatC = class<Inventory>(DynamicLoadObject(TravelCraftMatC, class'Class', false));
	}
}

function VMDFakeAuraTimerHook(bool bWhole)
{
	local VMDToolbox TB;
	local VMDChemistrySet CS;
	local bool FlagInappropriate;
	
	TB = VMDToolbox(MyVMP.InHand);
	CS = VMDChemistrySet(MyVMP.InHand);
	
	MyVMP = VMDBufferPlayer(Owner);
	if (MyVMP != None)
	{
		if ((MyVMP.Region.Zone != None) && (MyVMP.Region.Zone.bWaterZone))
		{
			ExpireMessage = StrCraftingFailedWater;
			UsedUp();
		}
		//MADDERS, 5/16/22: Don't allow for frame-perfect crafting in MJ12 prison.
		else if (MyVMP.VMDHasItemDropObjection(None))
		{
			ExpireMessage = StrCraftingFailedInterrupted;
			UsedUp();
		}
		
		//MADDERS, 5/13/22: Shoving this system around a lot, but basically, as it stands:
		//If we have shit in the way of us crafting, pause progress until later.
		//Otherwise, let it ride.
		else if (bToolsRequired)
		{
			if (bMedicalCrafting)
			{
				if (CS != None)
				{
					BeginNoise();
				}
				else
				{
					EndNoise();
					Charge += CalcChargeDrain(MyVMP);
				}
			}
			else
			{
				if (TB != None)
				{
					BeginNoise();
				}
				else
				{
					EndNoise();
					Charge += CalcChargeDrain(MyVMP);
				}
			}
		}
		else
		{
			FlagInappropriate = false;
			BeginNoise();
			if ((bMedicalCrafting) && (CS != None))
			{
			}
			else if ((!bMedicalCrafting) && (TB != None))
			{
			}
			//MADDERS, 4/28/23: Don't let us craft while carrying decos now.
			else if (MyVMP.InHand != None || MyVMP.CarriedDecoration != None)
			{
				FlagInappropriate = true;
			}
			
			if (FlagInappropriate)
			{
				EndNoise();
				Charge += CalcChargeDrain(MyVMP);
			}
			else
			{
				BeginNoise();
			}
		}
	}
	
	Super.VMDFakeAuraTimerHook(bWhole);
}

function VMDCancelCrafting()
{
	ExpireMessage = StrCraftingCanceled;
	UsedUp();
}

function UsedUp()
{
	local bool FlagWon;
	local int i;
	local Inventory TInv;
	
	EndNoise();
	
	MyVMP = VMDBufferPlayer(Owner);
	if ((Charge <= 0) && (MyVMP != None) && (CraftClass != None || ((CraftMatA != None) && (bBreakdown)) ))
	{
		FlagWon = True;
		
		if (MyVMP.RestrictInput()) FlagWon = false;
		
		if (!bBreakdown)
		{
			if ((bMedicalCrafting) && (MyVMP.CurChemicals < ComponentCost))
			{
				FlagWon = False;
			}
			else if ((!bMedicalCrafting) && (MyVMP.CurScrap < ComponentCost))
			{
				FlagWon = False;
			}
			else if (!ExpendResource(CraftMatA, MatQuanA, true) || !ExpendResource(CraftMatB, MatQuanB, true) || !ExpendResource(CraftMatC, MatQuanC, true))
			{
				FlagWon = False;
			}
		}
		else
		{
			if (!ExpendResource(CraftMatA, MatQuanA, true))
			{
				FlagWon = False;
			}
		}
		
		if (FlagWon)
		{
			if (!bBreakdown)
			{
				TInv = MyVMP.Spawn(CraftClass);
				TInv.SetPropertyText("bItemRefusalOverride", "true");
			}
			if ((TInv == None) && (!bBreakdown))
			{
				FlagWon = False;
			}
			else if (FlagWon)
			{
				if (CraftQuan > 1)
				{
					if ((DeusExWeapon(TInv) != None && DeusExWeapon(TInv).AmmoName == class'AmmoNone')  || (DeusExPickup(TInv) != None && !DeusExPickup(TInv).bCanHaveMultipleCopies))
					{
						for(i=1; i<CraftQuan; i++)
						{
							MyVMP.FrobTarget = TInv;
							MyVMP.ParseRightClick();
							
							TInv = MyVMP.Spawn(CraftClass);
							TInv.SetPropertyText("bItemRefusalOverride", "true");
						}
					}
				}
				
				if (!bBreakdown)
				{
					if (bMedicalCrafting)
					{
						MyVMP.CurChemicals -= ComponentCost;
					}
					else
					{
						MyVMP.CurScrap -= ComponentCost;
					}
				}
				else
				{
					if (bMedicalCrafting)
					{
						MyVMP.AddChemicals(ComponentCost, True);
						MyVMP.LastMedicalBreakdown = TravelCraftMatA;
					}
					else
					{
						MyVMP.AddScrap(ComponentCost, True);
						MyVMP.LastMechanicalBreakdown = TravelCraftMatA;
					}
				}
				ExpendResource(CraftMatA, MatQuanA, false);
				ExpendResource(CraftMatB, MatQuanB, false);
				ExpendResource(CraftMatC, MatQuanC, false);
				
				if (!bBreakdown)
				{
					if (DeusExAmmo(TInv) != None)
					{
						DeusExAmmo(TInv).AmmoAmount = CraftQuan;
					}
					if ((DeusExPickup(TInv) != None) && (DeusExPickup(TInv).bCanHaveMultipleCopies))
					{
						DeusExPickup(TInv).NumCopies = CraftQuan;
					}
					if ((DeusExWeapon(TInv) != None) && (DeusExWeapon(TInv).bHandToHand) && (AmmoNone(DeusExWeapon(TInv).AmmoType) == None))
					{
						DeusExWeapon(TInv).PickupAmmoCount = CraftQuan;
					}
					
					if (VMDMeghPickup(TInv) != None)
					{
						VMDMeghPickup(TInv).VMDCraftingCalledBullshit();
					}
					if (VMDSIDDPickup(TInv) != None)
					{
						VMDSIDDPickup(TInv).VMDCraftingCalledBullshit();
					}
					
					MyVMP.FrobTarget = TInv;
					MyVMP.ParseRightClick();
					
					ExpireMessage = StrCraftingSuccess;
				}
				else
				{
					ExpireMessage = StrBreakdownSuccess;
				}
			}
		}
		
		if (!FlagWon)
		{
			ExpireMessage = StrCraftingFailedSupplies;
		}
	}
	
	Super.UsedUp();
}

state Activated
{
	function BeginState()
	{
		BeginNoise();
		
		if (!bBreakdown)
		{
			if (CraftClass != None)
			{
				PickupMessage = SprintF(StrStartCrafting, CraftClass.Default.ItemName);
			}
		}
		else
		{
			if (CraftMatA != None)
			{
				PickupMessage = SprintF(StrStartBreakdown, CraftMatA.Default.ItemName);
			}
		}
		
		//MADDERS, 5/18/22: What if bulk crafting tho?
		if (Charge == 200)
		{
			Charge *= CraftTimeMult;
		}
		
		Super.BeginState();
	}
}

// ----------------------------------------------------------------------
// ExpendResource()
// ----------------------------------------------------------------------

function bool ExpendResource(class<Inventory> TarResource, int UseQuan, bool bFakeTest)
{
	local Inventory TFind, TInv;
	local DeusExAmmo DXA, TAmmo;
	local DeusExWeapon DXW;
	local DeusExPickup DXP;
	local int i;
	
	MyVMP = VMDBufferPlayer(Owner);
	if ((MyVMP != None) && (TarResource != None))
	{
		TFind = MyVMP.FindInventoryType(TarResource);
		if (TFind == None) return false;
		
		DXA = DeusExAmmo(TFind);
		DXW = DeusExWeapon(TFind);
		DXP = DeusExPickup(TFind);
		if (UseQuan < 2 || DXP == None || DXP.bCanHaveMultipleCopies)
		{
			if (DXA != None)
			{
				if (DXA.AmmoAmount >= UseQuan)
				{
					if (!bFakeTest)
					{
						DXA.AmmoAmount -= UseQuan;
					}
					return true;
				}
				else
				{
					return false;
				}
			}
			if ((DXW != None) && (DeusExAmmo(DXW.AmmoType) != None))
			{
				TAmmo = DeusExAmmo(DXW.AmmoType);
				if (DXW.AmmoName == class'AmmoNone' || !DXW.bHandToHand)
				{
					if (CountNumWeapons(DXW.Class, MyVMP.Inventory) >= UseQuan)
					{
						if (!bFakeTest)
						{
							for (i=0; i<UseQuan; i++)
							{
								DXW = DeusExWeapon(MyVMP.FindInventoryType(TarResource));
								if (DXW != None)
								{
									DXW.Destroy();
								}
								else
								{
									Log("WARNING: Could not find promised number of weapon types:"@TarResource);
									return false;
								}
							}
						}
						return true;
					}
					else
					{
						return false;
					}
				}
				else
				{
					if (TAmmo.AmmoAmount >= UseQuan)
					{
						if (!bFakeTest)
						{
							TAmmo.AmmoAmount -= UseQuan;
							if (TAmmo.AmmoAmount <= 0)
							{
								DXW.Destroy();
							}
							else
							{
								MyVMP.UpdateBeltText(DXW);
							}
						}
						return true;
					}
					else
					{
						return false;
					}
				}
			}
			if (DXP != None)
			{
				if (DXP.NumCopies >= UseQuan || UseQuan < 2)
				{
					if (!bFakeTest)
					{
						DXP.NumCopies -= UseQuan;
						if (DXP.NumCopies <= 0)
						{
							DXP.Destroy();
						}
						else
						{
							MyVMP.UpdateBeltText(DXP);
						}
					}
					return true;
				}
				else
				{
					return false;
				}
			}
		}
		else
		{
			if (CountNumPickups(DXP.Class, MyVMP.Inventory) >= UseQuan)
			{
				if (!bFakeTest)
				{
					for (i=0; i<UseQuan; i++)
					{
						DXP = DeusExPickup(MyVMP.FindInventoryType(TarResource));
						if (DXP != None)
						{
							DXP.Destroy();
						}
						else
						{
							Log("WARNING: Could not find promised number of pickup types:"@TarResource);
							return false;
						}
					}
				}
				return true;
			}
			else
			{
				return false;
			}
		}
	}
	
	return true;
}

function BeginNoise()
{
	if ((SoundVolume < 128) && (VMDBufferPlayer(Owner) != None) && (VMDBufferPlayer(Owner).bEnvironmentalSoundsEnabled))
	{
		SoundVolume = 128;
		AIStartEvent('LoudNoise', EAITYPE_Audio, 1.0, 320);
	}
}

function EndNoise()
{
	if (SoundVolume > 0)
	{
		SoundVolume = 0;
		AIEndEvent('LoudNoise', EAITYPE_Audio);
	}
}

function int CountNumPickups(class<DeusExPickup> CheckClass, Inventory StartInv)
{
	local int Ret;
	local Inventory CurInv;
	
	for(CurInv = StartInv; CurInv != None; CurInv = CurInv.Inventory)
	{
		if (CurInv.Class == CheckClass)
		{
			Ret++;
		}
	}
	return Ret;
}

function int CountNumWeapons(class<DeusExWeapon> CheckClass, Inventory StartInv)
{
	local int Ret;
	local Inventory CurInv;
	
	for(CurInv = StartInv; CurInv != None; CurInv = CurInv.Inventory)
	{
		if (CurInv.Class == CheckClass)
		{
			Ret++;
		}
	}
	return Ret;
}

//MADDERS, 2/6/21: These buffs do not clear reliably.
function Tick(float DT)
{
	Super.Tick(DT);
	
	if (Owner != None)
	{
		SetLocation(Owner.Location);
	}
}

simulated function Float GetCurrentCharge()
{
	return (Float(Charge) / Float(MaxCharge)) * 100.0;
}

defaultproperties
{
     StrCraftingCanceled="Crafting canceled"
     StrCraftingFailedSupplies="Crafting failed. Could not locate supplies"
     StrCraftingFailedWater="You cannot craft underwater"
     StrCraftingSuccess="Crafting success!"
     StrStartCrafting="Now crafting %s..."
     StrBreakdownSuccess="Breakdown success!"
     StrStartBreakdown="Breaking down %s..."
     StrCraftingFailedInterrupted="Crafting was interrupted"
     
     CraftTimeMult=1.000000
     Charge=200
     MaxCharge=200
     PickupMessage=""
     ExpireMessage=""
     
     //MADDERS, 1/30/21: No sound, as we start with a select sound queue, IE medkit usage.
     LoopSound=None
     ChargedIcon=Texture'ChargedIconMedkit'
     bLoudLoopSound=True
}
