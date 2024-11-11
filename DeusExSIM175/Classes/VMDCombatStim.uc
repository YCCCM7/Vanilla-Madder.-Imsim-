//=============================================================================
// VMDCombatStim.
//=============================================================================
class VMDCombatStim extends DeusExPickup;

function VMDAddStimEffect(VMDBufferPlayer VMP)
{
	local CombatStimAura CSA;
	
	if (VMP == None) return;
	
	CSA = CombatStimAura(VMP.FindInventoryType(class'CombatStimAura'));
	if (CSA == None)
	{
		CSA = Spawn(class'CombatStimAura');
		CSA.Frob(VMP, None);
		CSA.Activate();
	}
	else
	{
		VMP.TakeDamage(Max(30, VMP.HealthTorso/3), VMP, VMP.Location, Vect(0,0,0), 'DrugDamage');
		
		CSA.Charge = CSA.Default.Charge;
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
		local DeusExPlayer player;
		local VMDBufferPlayer VMP;
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		if (player != None)
		{
			VMP = VMDBufferPlayer(Player);
			if (VMP != None)
			{
				VMDAddStimEffect(VMP);
			}
		}
		
		UseOnce();
	}
Begin:
}

defaultproperties
{
     M_Activated="You shoot up the %s"
     MsgCopiesAdded="You found %d %ss"
     
     maxCopies=5
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Combat Stimulant"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDSyringe'
     PickupViewMesh=LodMesh'VMDSyringe'
     ThirdPersonMesh=LodMesh'VMDSyringe3rd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'BeltIconCombatStim'
     largeIcon=Texture'BeltIconCombatStim'
     largeIconWidth=42
     largeIconHeight=42
     Description="Known through rumors as 'Compound 23', this experimental combat drug is seriously heavy duty.|n|nEFFECTS: For 17 seconds: Gain clarity against visual effects. For 25 seconds: Max out stress level, increase melee speed by 65%, aim focus rate by 65%, and movement speed by 35%. You will crash after the effect ends."
     beltDescription="STIM"
     Mesh=LodMesh'VMDSyringe'
     CollisionRadius=7.500000
     CollisionHeight=1.000000
     Mass=1.000000
     Buoyancy=0.800000
     
     Multiskins(1)=Texture'VMDCombatStimLiquid'
     Texture=Texture'CoreTexGlass.07WindOpacStrek'
}
