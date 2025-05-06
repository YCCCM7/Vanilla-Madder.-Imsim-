//=============================================================================
// VMDToolbox.
//=============================================================================
class VMDToolbox extends DeusExPickup;

//Open our window 'n shit.
function OpenCraftingWindow(VMDBufferPlayer VMP)
{
	if (VMP != None)
	{
		VMP.VMDInvokeToolboxWindow();
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
		if (!VMP.CanCraftMechanical(True))
		{
			return true;
		}
		return false;
	}
	return true;
}

defaultproperties
{
     M_Activated="You pop open your %s"
     
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
