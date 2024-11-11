//=============================================================================
// SheepsGiveItemTriggerTweaked
//
// Gives the pawn triggering it (must be triggered/touched by a pawn, then) the item specified.
//
// By: Sheep
// Tweaked by WCCC for fallback instigator, non-package dependency, null checking, custom props, and better pickup code.
//=============================================================================
class SheepsGiveItemTriggerTweaked extends Trigger;

struct SItemProps {
	var string SetItemPropertiesName;
	var string SetItemPropertiesTo;
};

var() string GiveClass;
var() SItemProps SetItemProperties[8];
var() bool bSetFlagOnFail, FailedFlagValue;
var() name FailedFlagName;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	if (GiveClass == "")
	{
		Destroy();
	}
}

function bool BeenTriggered(Actor instigator)
{
	local DeusExPlayer DXP;
	local Pawn Pwn;
	local Inventory Inv;
	local class<Actor> LoadClass;
	local int i;
	
	Pwn = Pawn(instigator);
	
	if (Pwn == None)
	{
		Pwn = GetPlayerPawn();
		if (Pwn == None) //Should never happen, but good practice
		{
			return false;
		}
	}
	DXP = DeusExPlayer(Pwn);
	
	LoadClass = class<Actor>(DynamicLoadObject(GiveClass, class'Class', false));
	if (LoadClass == None)
	{
		return false;
	}
	
	Inv = Inventory(Spawn(LoadClass));
	if (Inv == None)
	{
		return false;
	}
	
	for (i=0; i<ArrayCount(SetItemProperties); i++)
	{
		if (SetItemProperties[i].SetItemPropertiesName != "")
		{
			Inv.SetPropertyText(SetItemProperties[i].SetItemPropertiesName, SetItemProperties[i].SetItemPropertiesTo);
		}
	}
	
	if (DXP != None)
	{
		if (Inv.IsA('Nanokey'))
		{
			DXP.PickupNanoKey(NanoKey(Inv));
			Inv.Destroy();
		}
		else
		{
			if (!DXP.HandleItemPickup(Inv, True))
			{
				return false;
			}
			DXP.FrobTarget = Inv;
			//DXP.FindInventorySlot(Inv);
			DXP.ParseRightClick();
		}
	}
	else
	{
		Inv.RespawnTime = 0;
		Inv.bHeldItem = true;
		Inv.GiveTo(pwn);
	}
	
	if (Inv.Owner == None)
	{
		Inv.Destroy();
		return false;
	}
	
	return true;
}

function Trigger(Actor other,Pawn instigator)
{
	local bool bTriggerWon;
	local DeusExPlayer Player;
	
	Player = DeusExPlayer(GetPlayerPawn());
	bTriggerWon = (BeenTriggered(instigator));
	
	if ((bSetFlagOnFail) && (Player != None))
	{
		Player.FlagBase.SetBool(FailedFlagName, !FailedFlagValue);
	}
	
	//WCCC, 9/5/21: Only destroy if it worked.
	if ((bTriggerWon) && (bTriggerOnceOnly))
	{
		Destroy();
	}
	if (!bTriggerWon)
	{
		if ((bSetFlagOnFail) && (Player != None))
		{
			Player.FlagBase.SetBool(FailedFlagName, FailedFlagValue);
		}
	}
}

function Touch(Actor other)
{
	local bool bTriggerWon;
	local DeusExPlayer Player;
	
	if (IsRelevant(other))
	{
		Player = DeusExPlayer(GetPlayerPawn());
		bTriggerWon = (BeenTriggered(Other));
		
		if ((bSetFlagOnFail) && (Player != None))
		{
			Player.FlagBase.SetBool(FailedFlagName, !FailedFlagValue);
		}
		
		//WCCC, 9/5/21: Only destroy if it worked.
		if ((bTriggerWon) && (bTriggerOnceOnly))
		{
			Destroy();
		}
		if (!bTriggerWon)
		{
			if ((bSetFlagOnFail) && (Player != None))
			{
				Player.FlagBase.SetBool(FailedFlagName, FailedFlagValue);
			}
		}
	}
}

defaultproperties
{
	FailedFlagValue=true
}