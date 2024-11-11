//=============================================================================
// VMDMedigel.
//=============================================================================
class VMDMedigel extends DeusExPickup;

var localized string MsgHealthFull;

function VMDAddMedigelEffect(VMDBufferPlayer VMP)
{
	local int THeal, i;
	local MedigelAura MGA;
	
	if (VMP == None) return;
	
	VMP.VMDModPlayerStress(15,,,true);
	
	MGA = MedigelAura(VMP.FindInventoryType(class'MedigelAura'));
	if (MGA != None)
	{
		for (i=MGA.NumHeals; i<4; i++)
		{
			if (MGA.NumHeals < 3)
			{
				MGA.NumHeals++;
				THeal += 19;
			}
			else if (MGA.NumHeals == 3)
			{
				MGA.NumHeals++;
				THeal += 18;
			}
		}
		if (THeal > 0)
		{
			VMP.HealPlayer(THeal, False);
		}
		MGA.Destroy();
	}
	
	MGA = Spawn(class'MedigelAura');
	if (MGA != None)
	{
		MGA.Frob(VMP, None);
		MGA.Activate();
		
		if (VMP.HeadRegion.Zone.bWaterZone)
		{
			VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.0);
		}
		else
		{
			VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.3);
		}
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
				VMDAddMedigelEffect(VMP);
			}
		}
		
		UseOnce();
	}
Begin:
}

function bool IsPlayerDamaged( DeusExPlayer Player )
{
	local int HealthTotal;
	local VMDBufferPlayer VMP;
	local float ModMult;
	
	if (Player == None) return false;
	VMP = VMDBufferPlayer(Player);
	
	ModMult = 1.0;
	if ((VMP != None) && (VMP.ModHealthMultiplier > 0.0))
	{
		ModMult = VMP.ModHealthMultiplier;
	}
	
	HealthTotal = Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight;
	
	if ((VMP != None) && (VMP.KSHealthMult < 1.0))
	{
		if (Abs(float(VMP.HealthHead) - (float(VMP.Default.HealthHead) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthTorso) - (float(VMP.Default.HealthTorso) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthLegLeft) - (float(VMP.Default.HealthLegLeft) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthLegRight) - (float(VMP.Default.HealthLegRight) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthArmLeft) - (float(VMP.Default.HealthArmLeft) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		if (Abs(float(VMP.HealthArmRight) - (float(VMP.Default.HealthArmRight) * VMP.KSHealthMult * ModMult)) >= 1.0) return true;
		return false;
	}
	else
	{
		return (HealthTotal < 600*ModMult);
	}
}

function bool VMDHasActivationObjection()
{
	if ((DeusExPlayer(Owner) != None) && (!IsPlayerDamaged(DeusExPlayer(Owner))))
	{
		DeusExPlayer(Owner).ClientMessage(MsgHealthFull);
		return true;
	}
	return false;
}

defaultproperties
{
     M_Activated="You inject yourself with the %s"
     MsgHealthFull="You are already at full health!"
     MsgCopiesAdded="You found %d %ss"
     
     maxCopies=5
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="'Ritegel' Medical Gel"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'VMDSyringe'
     PickupViewMesh=LodMesh'VMDSyringe'
     ThirdPersonMesh=LodMesh'VMDSyringe3rd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'BeltIconMedigel'
     largeIcon=Texture'BeltIconMedigel'
     largeIconWidth=42
     largeIconHeight=42
     Description="A medical healing solution that jives quite well with nanoaugmented agents. |n|nEFFECTS: Over 4 seconds, heal for 75 points of non-targeted, non-scaling healing. Can be mounted to appropriate drones."
     beltDescription="MEDIGEL"
     Mesh=LodMesh'VMDSyringe'
     CollisionRadius=7.500000
     CollisionHeight=1.000000
     Mass=1.000000
     Buoyancy=0.800000
     
     Multiskins(1)=Texture'VMDMedigelLiquid'
     Texture=Texture'CoreTexGlass.07WindOpacStrek'
}
