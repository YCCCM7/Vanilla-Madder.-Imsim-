//=============================================================================
// VMDToolbox.
//=============================================================================
class VMDToolbox extends DeusExPickup;

var localized string MsgNoSkill, MsgNoRecipes, MsgAlreadyCrafting, MsgCantCraftUnderwater;

//Open our window 'n shit.
function OpenCraftingWindow(VMDBufferPlayer VMP)
{
	if (VMP != None)
	{
		VMP.VMDInvokeToolboxWindow();
	}
}

//How good are we with Hardware?
function int GetPlayerSkill(DeusExPlayer DXP)
{
	local int Ret;
	
	if ((DXP != None) && (DXP.SkillSystem != None))
	{
		Ret = DXP.SkillSystem.GetSkillLevel(class'SkillTech');
	}
	
	return Ret;
}

function bool GetPlayerSpecialization(VMDBufferPlayer VMP)
{
	if (VMP == None) return false;
	
	return VMP.IsSpecializedInSkill(class'SkillTech');
}

function int GetNumRecipes(VMDBufferPlayer VMP)
{
	local int Ret, i;
	local VMDNonStaticCraftingFunctions CF;
	local class<Inventory> TType;
	
	if (VMP == None || VMP.CraftingManager == None || VMP.CraftingManager.StatRef == None) return 0;
	
	CF = VMP.CraftingManager.StatRef;
	
	if (CF != None)
	{
		for (i=1; i<ArrayCount(CF.Default.MechanicalItemsGlossary); i++)
		{
			TType = CF.GetMechanicalItemGlossary(i);
			if (TType == None || !VMP.DiscoveredItem(TType))
			{
				continue;
			}
			Ret++;
		}
	}
	
	return Ret;
}

// ----------------------------------------------------------------------
state Activated
{
	function Activate()
	{
		// can't turn it off
	}
	
	function BeginState()
	{
		local VMDBufferPlayer VMP;
				
		Super.BeginState();
		
		VMP = VMDBufferPlayer(Owner);
		if (VMP != None)
		{
			OpenCraftingWindow(VMP);
		}
		
		VMDDontUseOnce();
	}
Begin:
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool VMDHasActivationObjection()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if (VMP != None)
	{
		if ((GetPlayerSkill(VMP) < 1) && (!GetPlayerSpecialization(VMP)))
		{
			VMP.ClientMessage(MsgNoSkill);
			return true;
		}
		if (GetNumRecipes(VMP) < 1)
		{
			VMP.ClientMessage(MsgNoRecipes);
			return true;
		}
		if ((VMP.Region.Zone != None) && (VMP.Region.Zone.bWaterZone))
		{
			VMP.ClientMessage(MsgCantCraftUnderwater);
			return true;
		}
		if (VMP.VMDPlayerIsCrafting(False))
		{
			VMP.ClientMessage(MsgAlreadyCrafting);
			return true;
		}
		return false;
	}
	return true;
}

defaultproperties
{
     M_Activated="You pop open your %s"
     MsgNoSkill="To be honest, you have no idea what you're doing with all this HARDWARE"
     MsgNoRecipes="You don't actually know any hardware recipes, now that you think about it"
     MsgCantCraftUnderwater="You cannot craft underwater"
     MsgAlreadyCrafting="You are already crafting"
     
     bCanHaveMultipleCopies=False
     bActivatable=True
     ItemName="Toolbox"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDToolbox'
     PickupViewMesh=LodMesh'VMDToolbox'
     ThirdPersonMesh=LodMesh'VMDToolbox3rd'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'BeltIconVMDToolbox'
     largeIcon=Texture'LargeIconVMDToolbox'
     largeIconWidth=42
     largeIconHeight=34
     Description="A box of tools. Can you make any hardware with it?"
     beltDescription="TOOLBOX"
     Mesh=LodMesh'VMDToolbox'
     CollisionRadius=8.500000
     CollisionHeight=5.000000
     Mass=5.000000
     Buoyancy=4.000000
}
