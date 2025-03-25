//=============================================================================
// MedKit.
//=============================================================================
class MedKit extends DeusExPickup;

//
// Healing order is head, torso, legs, then arms (critical -> less critical)
//
var int healAmount;
var bool bNoPrintMustBeUsed;

var localized string MustBeUsedOn;

//MADDERS additions
var localized string MsgHealthFull;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
		MaxCopies = 5;
}

function VMDRunMedkitShellEffects(VMDBufferPlayer VMP)
{
	local int SkillLevel;
	local ZymeArmorAura ZAA;
	
	if (VMP == None) return;
	
	SkillLevel = VMP.SkillSystem.GetSkillLevel(class'SkillMedicine');
	
	if (VMDHasSkillAugment('MedicineStress'))
	{
		//MADDERSE, 6/9/22: Halve the effects of zyme in our system, in addition to poison.
		ZAA = ZymeArmorAura(VMP.FindInventoryType(class'ZymeArmorAura'));
		if ((ZAA != None) && (ZAA.Charge > 1))
		{
			ZAA.Charge /= 2;
		}
		if (VMP.DrugEffectTimer > 0)
		{
			VMP.DrugEffectTimer /= 2;
			VMP.VMDGiveBuffType(class'DrunkEffectAura', VMP.DrugEffectTimer*40.0, true); //Only update existing.
		}
		
		//MADDERS, 12/10/21: Nerfed. No more stress reduction.
		/*if (VMP.bStressEnabled)
		{
			if (Frand() < 0.33) VMP.ClientMessage(VMP.MedkitUsedDescs[0]);
    			VMP.VMDModPlayerStress(-500,,,true);
		}*/
		
		VMP.VMDGiveBuffType(class'PharmacistArmorAura', class'PharmacistArmorAura'.Default.Charge);
	}
	else
	{
		/*if (VMP.bStressEnabled)
		{
			if (Frand() < 0.33) VMP.ClientMessage(VMP.MedkitUsedDescs[1]);
			VMP.VMDModPlayerStress(25);
		}*/
	}
	
	//Give messages about being shaken on untrained, no message at trained, and a cool guy message at advanced or master.
	if (Frand() < 0.33)
	{
		if (SkillLevel > 1)
		{
			VMP.ClientMessage(VMP.MedkitUsedDescs[0]);
		}
		else if (SkillLevel < 1)
		{
			VMP.ClientMessage(VMP.MedkitUsedDescs[1]);
		}
	}
	
 	VMP.VMDRegisterFoodEaten(0, "Medkit");
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
		local VMDBufferPawn VMBP;
		local DeusExPlayer player;
		local VMDBufferPlayer VMP;
		
		Super.BeginState();
		
		Player = DeusExPlayer(Owner);
		VMBP = VMDBufferPawn(Owner);
		
		if (player != None)
		{
			VMP = VMDBufferPlayer(Player);
			
			if (!IsPlayerDamaged(Player))
			{
			 	Player.ClientMessage(MsgHealthFull);
			 	GoToState('Deactivated');
			 	return;
			}
			else
			{
				if (VMP != None) VMDRunMedkitShellEffects(VMP);
				
				Owner.AISendEvent('LoudNoise', EAITYPE_Audio, 1.0, 256);
			 	if (VMP != None) 
				{
					VMP.HealPlayer(healAmount* (1 - (0.35 * int(VMP.bUseSharedHealth))), True);
				}
			 	else
				{
					player.HealPlayer(healAmount, True);
				}
				
			 	// Medkits kill all status effects when used in multiplayer
			 	if ( player.Level.NetMode != NM_Standalone )
			 	{
					player.StopPoison();
					player.ExtinguishFire();
					player.drugEffectTimer = 0;
			 	}
			}
		}
		if (VMBP != None)
		{
			VMBP.ReceiveMedicalHealing(HealAmount * class'SkillMedicine'.Default.LevelValues[VMBP.MedicineSkillLevel]);
			VMBP.PlaySound(sound'MedicalHiss', SLOT_None,,, 512, VMDGetMiscPitch2());
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

// ----------------------------------------------------------------------
// UpdateInfo()
// ----------------------------------------------------------------------

function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local DeusExPlayer player;
	local String outText;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;
	
	player = DeusExPlayer(Owner);
	
	if (player != None)
	{
		winInfo.SetTitle(itemName);
		winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR());
		
		if (!bNoPrintMustBeUsed)
		{
			winInfo.AppendText(winInfo.CR() $ MustBeUsedOn $ winInfo.CR());
		}
		else
		{
			bNoPrintMustBeUsed = False;
		}
		
		// Print the number of copies
		outText = CountLabel @ String(NumCopies);
		
		winInfo.AppendText(winInfo.CR() $ outText);
	}
	
	return True;
}

// ----------------------------------------------------------------------
// NoPrintMustBeUsed()
// ----------------------------------------------------------------------

function NoPrintMustBeUsed()
{
	bNoPrintMustBeUsed = True;
}

// ----------------------------------------------------------------------
// GetHealAmount()
//
// Arms and legs get healing bonuses
// ----------------------------------------------------------------------

function float GetHealAmount(int bodyPart, optional float pointsToHeal)
{
	local float amt;
	
	if (pointsToHeal == 0)
		pointsToHeal = healAmount;

	// CNN - just make all body parts equal to avoid confusion
	return pointsToHeal;
/*
	switch (bodyPart)
	{
		case 0:		// head
			amt = pointsToHeal * 2; break;
			break;

		case 1:		// torso
			amt = pointstoHeal;
			break;

		case 2:		// right arm
			amt = pointsToHeal * 1.5; break;

		case 3:		// left arm
			amt = pointsToHeal * 1.5; break;

		case 4:		// right leg
			amt = pointsToHeal * 1.5; break;

		case 5:		// left leg
			amt = pointsToHeal * 1.5; break;

		default:
			amt = pointstoHeal;
	}

	return amt;*/
}

// ----------------------------------------------------------------------
// TestMPBeltSpot()
// Returns true if the suggested belt location is ok for the object in mp.
// ----------------------------------------------------------------------

simulated function bool TestMPBeltSpot(int BeltSpot)
{
   return (BeltSpot == 9);
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

function bool VMDHasActivationObjection()
{
	if ((DeusExPlayer(Owner) != None) && (!IsPlayerDamaged(DeusExPlayer(Owner))))
	{
		DeusExPlayer(Owner).ClientMessage(MsgHealthFull);
		return true;
	}
	return false;
}

//MADDERS: Scale medkit count upwards with the relevant skill augments.
function int VMDConfigureMaxCopies()
{
	local int Ret;
	
	Ret = MaxCopies;
	
	if (VMDHasSkillAugment('MedicineCapacity'))
	{
		Ret += 5;
	}
	if (VMDHasSkillAugment('MedicineRevive'))
	{
		Ret += 3;
	}
	
	return Ret;
}

defaultproperties
{
     M_Activated="You use the %s"
     MsgHealthFull="You are already at full health!"
     MsgCopiesAdded="You found %d %ss"
     
     healAmount=30
     MustBeUsedOn="Use to heal critical body parts, or use on character screen to direct healing at a certain body part."
     maxCopies=15
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Medkit"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.MedKit'
     PickupViewMesh=LodMesh'DeusExItems.MedKit'
     ThirdPersonMesh=LodMesh'DeusExItems.MedKit3rd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconMedKit'
     largeIcon=Texture'DeusExUI.Icons.LargeIconMedKit'
     largeIconWidth=39
     largeIconHeight=46
     Description="A first-aid kit.|n|n<UNATCO OPS FILE NOTE JR095-VIOLET> The nanomachines of an augmented agent will automatically metabolize the contents of a medkit to efficiently heal damaged areas. An agent with medical training could greatly expedite this process. -- Jaime Reyes <END NOTE>"
     beltDescription="MEDKIT"
     Mesh=LodMesh'DeusExItems.MedKit'
     CollisionRadius=7.500000
     CollisionHeight=1.000000
     Mass=1.000000
     Buoyancy=0.800000
}
