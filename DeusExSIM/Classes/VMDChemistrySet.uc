//=============================================================================
// VMDChemistrySet.
//=============================================================================
class VMDChemistrySet extends DeusExPickup;

#exec OBJ LOAD FILE=CoreTexGlass

var localized string MsgNoSkill, MsgNoRecipes, MsgAlreadyCrafting, MsgCantCraftUnderwater;

//Open our window 'n shit.
function OpenCraftingWindow(VMDBufferPlayer VMP)
{
	if (VMP != None)
	{
		VMP.VMDInvokeChemistrySetWindow();
	}
}

//How good are we with Hardware?
function int GetPlayerSkill(DeusExPlayer DXP)
{
	local int Ret;
	
	if ((DXP != None) && (DXP.SkillSystem != None))
	{
		Ret = DXP.SkillSystem.GetSkillLevel(class'SkillMedicine');
	}
	
	return Ret;
}

function bool GetPlayerSpecialization(VMDBufferPlayer VMP)
{
	if (VMP == None) return false;
	
	return VMP.IsSpecializedInSkill(class'SkillMedicine');
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
		for (i=1; i<ArrayCount(CF.Default.MedicalItemsGlossary); i++)
		{
			TType = CF.GetMedicalItemGlossary(i);
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
	}
	return false;
}

//MADDERS: Rotate items in inventory with this one weird trick
function Texture VMDConfigureLargeIcon()
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if ((bCanRotateInInventory) && (bRotatedInInventory))
	{
		return RotatedIcon;
	}
	if ((VMP != None) && (VMP.VMDHasBuffType(class'VMDMedicalCraftingAura')))
	{
		return Texture'LargeIconVMDChemistrySet';
	}
	return LargeIcon;
}

function Tick(float DT)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(Owner);
	if ((VMP != None) && (VMP.VMDHasBuffType(class'VMDMedicalCraftingAura')))
	{
		Multiskins[1] = Texture'VMDChemistrySetFluids';
	}
	else
	{
		Multiskins[1] = Texture'BlackMaskTex';
	}
}

defaultproperties
{
     M_Activated="You begin toiling with your %s"
     MsgNoSkill="This is of no use to you. It's not like you practice MEDICINE or anything..."
     MsgNoRecipes="You don't actually know any medical recipes, now that you think about it"
     MsgCantCraftUnderwater="You cannot craft underwater"
     MsgAlreadyCrafting="You are already crafting"
     bCanRotateInInventory=True //MADDERS, 5/12/22: Dry icon, lesss gooo
     RotatedIcon=Texture'LargeIconVMDChemistrySetRotatedDry'     
     
     InvSlotsX=2
     bCanHaveMultipleCopies=False
     bActivatable=True
     ItemName="Chemistry Set"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDChemistrySet'
     PickupViewMesh=LodMesh'VMDChemistrySet'
     ThirdPersonMesh=LodMesh'VMDChemistrySet3rd'
     LandSound=Sound'DeusExSounds.Generic.MetalHit1'
     Icon=Texture'BeltIconVMDChemistrySet'
     largeIcon=Texture'LargeIconVMDChemistrySetDry'
     largeIconWidth=89
     largeIconHeight=53
     Description="A basic chemistry set. Can you make anything medicinal with it?"
     beltDescription="CHEMISTRY"
     Mesh=LodMesh'VMDChemistrySet'
     CollisionRadius=9.000000
     CollisionHeight=5.000000
     Mass=7.000000
     Buoyancy=5.000000
     
     Multiskins(1)=Texture'BlackMaskTex'
     Texture=Texture'CoreTexGlass.07WindOpacStrek'
}
