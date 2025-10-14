//=============================================================================
// VMDCraftingManager
//=============================================================================
class VMDCraftingManager extends Actor;

// which player am I attached to?
var VMDBufferPlayer Player;

var travel string DiscoverableItems[64];
var travel byte bDiscoveredItems[64], RecipeTypes[64], RecipeFatigue[64];

var localized string StrDiscoveredItem, TypeDescStrings[2], FatigueDescs[4];
var float FatigueLevels[4];

var travel VMDNonStaticCraftingFunctions StatRef;

function SetPlayer(DeusExPlayer newPlayer)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(NewPlayer);
	if (VMP != None)
	{
		Player = VMP;
	}
}

function PostPostBeginPlay()
{
	Super.PostPostBeginPlay();
	
	CheckStatRef();
	
	if (GetDiscoverableItem(0) == "")
	{
		GenerateDiscoverableItems();
	}
}

function CheckStatRef()
{
	local VMDNonStaticCraftingFunctions TStat;
	
	if (StatRef == None)
	{
		forEach AllActors(class'VMDNonStaticCraftingFunctions', TStat)
		{
			break;
		}
		if (TStat == None)
		{
			TStat = Spawn(class'VMDNonStaticCraftingFunctions');
		}
		
		if (TStat != None)
		{
			StatRef = TStat;
		}
		else
		{
			Log("WARNING! Could not spawn OR find VMDNonStaticCraftingFunctions for actor"@Self$"!");
		}
	}
}

function bool DiscoveredItem(class<Inventory> TItem)
{
	local int i;
	local string TStr;
	
	if (TItem == None) return false;
	
	TStr = string(TItem);
	for(i=0; i<ArrayCount(DiscoverableItems); i++)
	{
		if (TStr == GetDiscoverableItem(i))
		{
			return bool(bDiscoveredItems[i]);
		}
	}
}

function string GetDiscoverableItem(int TArray)
{
	return DiscoverableItems[TArray];
}

function int GetRecipeType(int TArray)
{
	return RecipeTypes[TArray];
}

function GenerateDiscoverableItems()
{
	local int i, ArrayLen[2];
	local string TStr;
	local class<Inventory> TItem;
	local VMDNonStaticCraftingFunctions CF;
	
	if (StatRef == None) return;
	
	CF = StatRef;
	ArrayLen[0] = ArrayCount(CF.Default.MechanicalItems);
	ArrayLen[1] = ArrayLen[0] + ArrayCount(CF.Default.MedicalItems);
	
	for (i=0; i<ArrayCount(DiscoverableItems); i++)
	{
		if (i < ArrayLen[0])
		{
			TItem = CF.GetMechanicalItemGlossary(i);
			RecipeTypes[i] = 0;
		}
		else if (i < ArrayLen[1])
		{
			TItem = CF.GetMedicalItemGlossary(i-ArrayLen[0]);
			RecipeTypes[i] = 1;
		}
		
		if (TItem != None)
		{
			TStr = string(TItem);
			
			DiscoverableItems[i] = TStr;
			bDiscoveredItems[i] = 0;
		}
	}
	
	MarkItemDiscovered(class'VMDToolbox');
	MarkItemDiscovered(class'VMDChemistrySet');
}

function MarkItemDiscovered(class<Inventory> TItem)
{
	local bool bGaveMessage;
	local int i, TType;
	local string TStr;
	
	if (TItem == None) return;
	
	TStr = string(TItem);
	
	for (i=0; i<ArrayCount(DiscoverableItems); i++)
	{
		if ((GetDiscoverableItem(i) == TStr) && (bDiscoveredItems[i] == 0))
		{
			TType = GetRecipeType(i);
			if ((Player != None) && (!bGaveMessage))
			{
				bGaveMessage = true;
				if (Player.bCraftingSystemEnabled)
				{
					switch(Player.SelectedCampaign)
					{
						case "HiveDays":
						break;
						default:
							Player.ClientMessage(SprintF(StrDiscoveredItem, TypeDescStrings[TType], TItem.Default.ItemName));
							if ((TType == 0) && (Player.SkillSystem != None) && (Player.SkillSystem.GetSkillLevel(class'SkillTech') > 0 || Player.IsSpecializedInSkill(class'SkillTech')))
							{
								Player.PlayItemDiscoverySound();
							}
							else if ((TType == 1) && (Player.SkillSystem != None) && (Player.SkillSystem.GetSkillLevel(class'SkillMedicine') > 0 || Player.IsSpecializedInSkill(class'SkillMedicine')))
							{
								Player.PlayItemDiscoverySound();
							}
						break;
					}
				}
			}
			bDiscoveredItems[i] = 1;
		}
	}
}

function DiscoverAllItems()
{
	local int i;
	
	for (i=0; i<ArrayCount(DiscoverableItems); i++)
	{
		if (GetDiscoverableItem(i) != "")
		{
			bDiscoveredItems[i] = 1;
		}
	}
}

function UpdateFatigue(class<Inventory> NewFatigue, int CraftCount, bool bMedical)
{
	local int i;
	
	if (NewFatigue == None || StatRef == None || !Player.bUseCraftingFatigue) return;
	
	for(i=0; i<ArrayCount(RecipeFatigue); i++)
	{
		if ((StatRef.GetMechanicalItemArrayFromString(DiscoverableItems[i]) == -1) == bMedical)
		{
			if (string(NewFatigue) == DiscoverableItems[i])
			{
				RecipeFatigue[i] = Clamp(RecipeFatigue[i] + CraftCount, 0, 3);
			}
			else
			{
				RecipeFatigue[i] = Clamp(RecipeFatigue[i] - CraftCount, 0, 3);
			}
		}
	}
}

function string GetFatigueDesc(class<Inventory> CheckType)
{
	local int i;
	local string Ret;
	
	if (!Player.bUseCraftingFatigue) return "";
	
	for(i=0; i<ArrayCount(DiscoverableItems); i++)
	{
		if (DiscoverableItems[i] == string(CheckType))
		{
			Ret = SprintF(FatigueDescs[RecipeFatigue[i]], int(FatigueLevels[RecipeFatigue[i]] * 100.0));
			
			return Ret;
		}
	}
	
	return Ret;
}

function float GetFatigueLevel(class<Inventory> CheckType)
{
	local int i;
	
	if (!Player.bUseCraftingFatigue) return 1.0;
	
	for(i=0; i<ArrayCount(DiscoverableItems); i++)
	{
		if (DiscoverableItems[i] == string(CheckType))
		{
			return (1.0 - FatigueLevels[RecipeFatigue[i]]);
		}
	}
	
	return 1.0;
}

defaultproperties
{
     bHidden=True
     bTravel=True
     
     StrDiscoveredItem="New %s recipe: %s"
     TypeDescStrings(0)="Hardware"
     TypeDescStrings(1)="Medicine"
     
     FatigueDescs(0)=""
     FatigueDescs(1)="- Light Fatigue (-%d%%)"
     FatigueDescs(2)="- Fatigue (-%d%%)"
     FatigueDescs(3)="- Heavy Fatigue (-%d%%)"
     FatigueLevels(0)=0.000000
     FatigueLevels(1)=0.250000
     FatigueLevels(2)=0.500000
     FatigueLevels(3)=0.660000
}
