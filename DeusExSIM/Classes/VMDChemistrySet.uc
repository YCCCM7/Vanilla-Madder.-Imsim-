//=============================================================================
// VMDChemistrySet.
//=============================================================================
class VMDChemistrySet extends DeusExPickup;

#exec OBJ LOAD FILE=CoreTexGlass

//Open our window 'n shit.
function OpenCraftingWindow(VMDBufferPlayer VMP)
{
	if (VMP != None)
	{
		VMP.VMDInvokeChemistrySetWindow();
	}
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
		if (!VMP.CanCraftMedical(true))
		{
			return true;
		}
		return false;
	}
	return true;
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
