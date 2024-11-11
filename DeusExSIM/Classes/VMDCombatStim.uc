//=============================================================================
// VMDCombatStim.
//=============================================================================
class VMDCombatStim extends DeusExPickup;

function VMDAddStimEffect(VMDBufferPlayer VMP)
{
	local float GSpeed;
	local CombatStimAura CSA;
	
	if (VMP == None) return;
	
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	if (VMP.HeadRegion.Zone.bWaterZone)
	{
		VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, GSpeed);
	}
	else
	{
		VMP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.3 * GSpeed);
	}
	
	//MADDERS, 8/9/23: Keeping this older example because of the crash effect.
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

function VMDAddNPCStimEffect(VMDBufferPawn VMBP)
{
	local CombatStimAura CSA;
	local Vector TVect;
	local ParticleGenerator Puff;
	
	if (VMBP == None) return;
	
	if (VMBP.HeadRegion.Zone.bWaterZone)
	{
		VMBP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 0.7);
	}
	else
	{
		VMBP.PlaySound(sound'MedicalHiss', SLOT_None,,, 256, 1.0);
	}
	
	//MADDERS, 8/9/23: Keeping this older example because of the crash effect.
	CSA = CombatStimAura(VMBP.FindInventoryType(class'CombatStimAura'));
	if (CSA == None)
	{
		CSA = Spawn(class'CombatStimAura');
		CSA.Frob(VMBP, None);
		CSA.Activate();
	}
	else
	{
		VMBP.TakeDamage(Max(30, VMBP.HealthTorso/3), VMBP, VMBP.Location, Vect(0,0,0), 'DrugDamage');
		
		CSA.Charge = CSA.Default.Charge;
	}
	VMBP.VMDUpdateGroundSpeedBuoyancy();
	
	TVect = Location + (Vector(Rotation) * CollisionRadius * 0.65);
	puff = spawn(class'ParticleGenerator',,, TVect, Rotator(TVect - Location));
	if (puff != None)
	{
		Puff.SetBase(Self);
		puff.particleTexture = FireTexture'Effects.Smoke.SmokePuff1';	
		puff.particleDrawScale = 0.125;
		puff.RiseRate = 2.500000;
		puff.ejectSpeed = 2.500000;
		puff.LifeSpan = 1.500000;
		puff.particleLifeSpan = 3.000000;
		puff.checkTime=0.150000;
		puff.bRandomEject = True;
		puff.RemoteRole = ROLE_None;
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
				VMDAddStimEffect(VMP);
			}
		}
		else if (VMBP != None)
		{
			VMDAddNPCStimEffect(VMBP);
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
     
     bFragile=True
     Multiskins(1)=Texture'VMDCombatStimLiquid'
     Texture=Texture'CoreTexGlass.07WindOpacStrek'
}
