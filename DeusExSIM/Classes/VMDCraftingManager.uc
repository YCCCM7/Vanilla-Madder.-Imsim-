//=============================================================================
// VMDCraftingManager
//=============================================================================
class VMDCraftingManager extends Actor;

// which player am I attached to?
var VMDBufferPlayer Player;

var travel string DiscoverableItems[64];
var travel byte bDiscoveredItems[64], RecipeTypes[64];

var localized string StrDiscoveredItem, TypeDescStrings[2];

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
					Player.ClientMessage(SprintF(StrDiscoveredItem, TypeDescStrings[TType], TItem.Default.ItemName));
					if ((TType == 0) && (Player.SkillSystem != None) && (Player.SkillSystem.GetSkillLevel(class'SkillTech') > 0 || Player.IsSpecializedInSkill(class'SkillTech')))
					{
						Player.PlayItemDiscoverySound();
					}
					else if ((TType == 1) && (Player.SkillSystem != None) && (Player.SkillSystem.GetSkillLevel(class'SkillMedicine') > 0 || Player.IsSpecializedInSkill(class'SkillMedicine')))
					{
						Player.PlayItemDiscoverySound();
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

defaultproperties
{
     bHidden=True
     bTravel=True
     
     StrDiscoveredItem="New %s recipe: %s"
     TypeDescStrings(0)="Hardware"
     TypeDescStrings(1)="Medicine"
}
