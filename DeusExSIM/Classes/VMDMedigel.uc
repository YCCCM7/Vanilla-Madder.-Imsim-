//=============================================================================
// VMDMedigel.
//=============================================================================
class VMDMedigel extends DeusExPickup;

var localized string MsgHealthFull;

function VMDAddMedigelEffect(VMDBufferPlayer VMP)
{
	local int THeal, i;
	local float GSpeed;
	local MedigelAura MGA;
	
	if (VMP == None) return;
	
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	VMP.VMDModPlayerStress(15,,,true);
	
	//MADDERS, 8/9/23: Keeping this older version because of the instant heal effect.
	MGA = MedigelAura(VMP.FindInventoryType(class'MedigelAura'));
	if (MGA != None)
	{
		THeal = 15*(4-MGA.NumHeals);
		
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
			VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, GSpeed);
		}
		else
		{
			VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.3 * GSpeed);
		}
	}
}

function VMDAddNPCMedigelEffect(VMDBufferPawn VMBP)
{
	local int THeal, i;
	local Vector TVect;
	local MedigelAura MGA;
	local ParticleGenerator Puff;
	
	if (VMBP == None) return;
	
	//MADDERS, 8/9/23: Keeping this older version because of the instant heal effect.
	MGA = MedigelAura(VMBP.FindInventoryType(class'MedigelAura'));
	if (MGA != None)
	{
		THeal = VMDGetNPCHealSize()*(4-MGA.NumHeals);
		
		if (THeal > 0)
		{
			VMBP.ReceiveHealing(THeal);
		}
		MGA.Destroy();
	}
	
	MGA = Spawn(class'MedigelAura');
	if (MGA != None)
	{
		MGA.Frob(VMBP, None);
		MGA.Activate();
		
		if (VMBP.HeadRegion.Zone.bWaterZone)
		{
			VMBP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.0);
		}
		else
		{
			VMBP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.3);
		}
		
		TVect = Location + (Vector(Rotation) * CollisionRadius * 0.65);
		puff = spawn(class'ParticleGenerator',,, TVect, Rotator(TVect - Location));
		if (puff != None)
		{
			Puff.SetBase(Self);
			puff.particleTexture = FireTexture'Effects.Smoke.SmokePuff1';	
			puff.particleDrawScale = 0.25;
			puff.RiseRate = 2.500000;
			puff.ejectSpeed = 2.500000;
			puff.LifeSpan = 1.500000;
			puff.particleLifeSpan = 3.000000;
			puff.checkTime = 0.150000;
			puff.bRandomEject = True;
			puff.RemoteRole = ROLE_None;
		}
	}
}

function int VMDGetNPCHealSize()
{
	local VMDBufferPawn VMBP;
	
	VMBP = VMDBufferPawn(Owner);
	
	if (VMBP == None)
	{
		return 0;
	}
	
	if (VMBP.bHasAugmentations)
	{
		if (VMBP.bMechAugs) //Mechs don't have much left in flesh, so they heal for 50% value.
		{
			return 5;
		}
		else //Nanoaugs can better jive with the solution, so they heal 150% value.
		{
			return 15;
		}
	}
	
	//Normal humans heal for 100% value.
	return 10;
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
		local VMDBufferPawn VMBP;
		local VMDBufferPlayer VMP;
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		VMBP = VMDBufferPawn(Owner);
		if (player != None)
		{
			VMP = VMDBufferPlayer(Player);
			if (VMP != None)
			{
				VMDAddMedigelEffect(VMP);
			}
		}
		else if (VMBP != None)
		{
			VMDAddNPCMedigelEffect(VMBP);
		}
		
		UseOnce();
	}
Begin:
}

function bool IsPlayerDamaged( DeusExPlayer Player )
{
	local float HealthDiffs[6];
	local int HealthTotal, i;
	local VMDBufferPlayer VMP;
	local float ModMult;
	
	if (Player == None) return false;
	VMP = VMDBufferPlayer(Player);
	
	ModMult = 1.0;
	if (VMP != None)
	{
		if (VMP.KSHealthMult > 0)
		{
			ModMult *= VMP.KSHealthMult;
		}
		if (VMP.ModHealthMultiplier > 0.0)
		{
			ModMult *= VMP.ModHealthMultiplier;
		}
	}
	
	HealthTotal = Player.HealthHead + Player.HealthTorso + Player.HealthArmLeft + Player.HealthArmRight + Player.HealthLegLeft + Player.HealthLegRight;
	
	HealthDiffs[0] = Abs(float(Player.HealthHead) - (float(Player.Default.HealthHead) * ModMult));
	HealthDiffs[1] = Abs(float(Player.HealthTorso) - (float(Player.Default.HealthTorso) * ModMult));
	HealthDiffs[2] = Abs(float(Player.HealthLegLeft) - (float(Player.Default.HealthLegLeft) * ModMult));
	HealthDiffs[3] = Abs(float(Player.HealthLegRight) - (float(Player.Default.HealthLegRight) * ModMult));
	HealthDiffs[4] = Abs(float(Player.HealthArmLeft) - (float(Player.Default.HealthArmLeft) * ModMult));
	HealthDiffs[5] = Abs(float(Player.HealthArmRight) - (float(Player.Default.HealthArmRight) * ModMult));
	
	for (i=0; i<ArrayCount(HealthDiffs); i++)
	{
		if (HealthDiffs[i] >= 1.0)
		{
			return true;
		}
	}
	
	return false;
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
     Description="A medical healing solution that jives quite well with nanoaugmented agents. |n|nEFFECTS: Over 4 seconds, heal for 60 points of non-scaling healing. Your most wounded regions will be targeted first. Can be mounted to appropriate drones."
     beltDescription="MEDIGEL"
     Mesh=LodMesh'VMDSyringe'
     CollisionRadius=7.500000
     CollisionHeight=1.000000
     Mass=1.000000
     Buoyancy=0.800000
     
     bFragile=True
     Multiskins(1)=Texture'VMDMedigelLiquid'
     Texture=Texture'CoreTexGlass.07WindOpacStrek'
}
