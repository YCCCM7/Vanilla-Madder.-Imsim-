//=============================================================================
// BallisticArmor.
//=============================================================================
class BallisticArmor extends ChargedPickup;

var localized string ReductionStr, ReductionStr2;

simulated function bool UpdateInfo(Object winObject)
{
	local PersonaInfoWindow winInfo;
	local DeusExPlayer player;
	local String outText;
	local float TDrainRate;
	local int i, ReductionLevel, ReductionLevel2;
	
	winInfo = PersonaInfoWindow(winObject);
	if (winInfo == None)
		return False;
	
	player = DeusExPlayer(Owner);
	
	if (player != None)
	{
		TDrainRate = 4;
		if (Player.SkillSystem != None) TDrainRate *= Player.SkillSystem.GetSkillLevelValue(SkillNeeded);
		
		ReductionLevel = int((1.0 - VMDConfigurePickupDamageMult('Shot', 1, Owner.Location)) * 100.0);
		ReductionLevel2 = int((1.0 - VMDConfigurePickupDamageMult('Exploded', 1, Owner.Location)) * 100.0);
		
		//MADDERS, 1/8/21: Update charge stacks at all times.
		ChargeStacks[NumCopies-1] = Charge;
		
		winInfo.SetTitle(itemName);
		winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR() $ SprintF(ReductionStr, ReductionLevel) @ SprintF(ReductionStr2, ReductionLevel2) $ winInfo.CR() $ winInfo.CR());
		
		outText = ChargeRemainingLabel$winInfo.CR();
		if (NumCopies > 1)
		{
			for (i=0; i<NumCopies; i++)
			{
				if (bLatentChargeCost)
				{
					outText = OutText$"#"$((i+1))@Int(VMDGetCurrentCharge(i) + 0.5) $ "%"@ChargeLabel@SprintF(StrSecondsLeft, int((Default.Charge / (10 * TDrainRate) * VMDGetCurrentCharge(i) / 100)+0.5));
				}
				else
				{
					outText = OutText$"#"$((i+1))@Int(VMDGetCurrentCharge(i) + 0.5) $ "%"@ChargeLabel;
				}
				if (i < (NumCopies-1)) OutText = OutText$winInfo.CR();
			}
		}
		else
		{
			if (bLatentChargeCost)
			{
				outText = OutText$Int(VMDGetCurrentCharge(0) + 0.5) $ "%"@ChargeLabel@SprintF(StrSecondsLeft, int((Default.Charge / (10 * TDrainRate) * VMDGetCurrentCharge(0) / 100)+0.5));
			}
			else
			{
				outText = OutText$Int(VMDGetCurrentCharge(0) + 0.5) $ "%"@ChargeLabel;
			}
		}
		winInfo.AppendText(outText);
	}
	
	return True;
}

//
// Reduces ballistic damage
//
//MADDERS: Configure our damage reduction!
function float VMDConfigurePickupDamageMult(name DT, int HitDamage, Vector HitLocation)
{
	local float Ret, SpecMult;
	local DeusExPlayer DXP;
	local VMDBufferPawn VMBP;
	local class<Skill> TSkill;
	
	TSkill = SkillNeeded;
	Ret = 1.0;
	
	VMBP = VMDBufferPawn(Owner);
	DXP = DeusExPlayer(Owner);
	if ((VMBP != None) && (TSkill != None))
	{
		Ret = (TSkill.Default.LevelValues[VMBP.EnviroSkillLevel] + 1.0) / 2;
		
		switch(DT)
		{
			case 'Shot':
			case 'AutoShot':
				SpecMult = 0.5;
			break;
			case 'Sabot':
			case 'Exploded':
			case 'KnockedOut': //MADDERS, 7/6/24: Reduce baton, but not very well.
				SpecMult = 0.75;
			break;
			default:
			 	return 1.0;
			break;
		}
		return Ret*SpecMult;
	}
	
	if (DXP != None)
	{
		//MADDERS: Nerf damage reduction somewhat, since we're left on long term, even if not for a high number of hits.
		Ret = (DXP.SkillSystem.GetSkillLevelValue(TSkill) + 0.75) / 2;
		switch(DT)
		{
			case 'Shot':
			case 'AutoShot':
				SpecMult = 0.5;
			break;
			case 'Sabot':
			case 'Exploded':
			case 'KnockedOut': //MADDERS, 7/6/24: Reduce baton, but not very well.
				SpecMult = 0.75;
			break;
			default:
			 	return 1.0;
			break;
		}
		Ret *= SpecMult;
	}
	
	return Ret;
}

function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
	local bool bAugmentReduction;
	local float SkillValue;
	local VMDBufferPlayer VMP;
	local VMDBufferPawn VMBP;
	local class<Skill> TSkill;
	
	//MADDERS: Don't do this for now.
	if (bCheckOnly) return;
	
	TSkill = SkillNeeded;
	
	VMBP = VMDBufferPawn(Owner);
	VMP = VMDBufferPlayer(Owner);
	bAugmentReduction = VMDHasSkillAugment('EnviroDurability');
	if (VMP != None)
	{
		if (VMP.SkillSystem != None)
		{
			//MADDERS: Reduce erode rate slightly based on skill level.
			if (bAugmentReduction)
			{
				SkillValue = 12.0 * (Sqrt(VMP.SkillSystem.GetSkillLevelValue(TSkill)));
			}
			else
			{
				SkillValue = 16.0 * (Sqrt(VMP.SkillSystem.GetSkillLevelValue(TSkill)));
			}
		}
	}
	else
	{
		//MADDERS: Highly debated, but wear down our copies rapidly, so we don't make tactical gear too OP.
		SkillValue = 12.0;
		if ((VMBP != None) && (TSkill != None))
		{
			SkillValue = 12 * TSkill.Default.LevelValues[VMBP.EnviroSkillLevel];
		}
	}
	if (SkillValue <= 0) SkillValue = 12.0;
	
	switch(DamageType)
	{
		case 'Shot':
		case 'AutoShot':
		case 'KnockedOut':
			if (VMP != None)
			{
				Charge -= Max(1, Damage * SkillValue * 0.5);
			}
			else
			{
				Charge -= Max(1, Damage * SkillValue);
			}
		break;
		case 'Sabot':
			if (VMP != None)
			{
				Charge -= Max(1, Damage * 2 * SkillValue * 0.5);
			}
			else
			{
				Charge -= Max(1, Damage * 2 * SkillValue);
			}
		break;
		case 'Exploded':
			if (VMP != None)
			{
				Charge -= Max(1, Damage * 2 * SkillValue * 0.5);
			}
			else
			{
				Charge -= Max(1, Damage * 2 * SkillValue);
			}
		break;
		case 'Shocked':
		case 'EMP':
			if (bAugmentReduction) Charge -= Damage*5;
			else Charge -= Damage*10;
		break;
	}
	
	//MADDERS: Simulate a player-esque usage, for visual feedback. The effect is handled in pawns.
	if (PlayerPawn(Owner) == None)
	{
		if (Charge <= 0)
		{
			if (VMDBufferPawn(Owner) != None)
			{
				VMDBufferPawn(Owner).RestoreBallisticArmorTexture();
			}
			Owner.AmbientSound = None;
			Owner.PlaySound(DeactivateSound, SLOT_None);
			UseOnce();
		}
	}
}

function bool VMDHasActivationObjection()
{
	local DeusExPlayer DXP;
	local ChargedPickup TCharge;
	local Inventory Inv;
	
	DXP = DeusExPlayer(Owner);
	
	if ((DXP != None) && (!bIsActive) && (!VMDHasSkillAugment('EnviroDurability')))
	{
		for (Inv=DXP.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (Inv != Self)
			{
				if ((AdaptiveArmor(Inv) != None) && (AdaptiveArmor(Inv).bIsActive))
				{
					TCharge = AdaptiveArmor(Inv);
					break;
				}
				if ((HazmatSuit(Inv) != None) && (HazmatSuit(Inv).bIsActive))
				{
					TCharge = HazmatSuit(Inv);
					break;
				}
			}
		}
		
		if (TCharge != None)
		{
			DXP.ClientMessage(SprintF(MsgConflictingPickup, VMDPickupCase(MsgConflictingPickup, TCharge.ItemName)));
			return true;
		}
	}
	return false;
}

defaultproperties
{
     //MADDERS: Scale charge as needed, so we only tank so much.
     //1000 units was good, but a little too much. Do 800 now.
     Charge=800
     MaxLootCharge=800
     bLatentChargeCost=False
     
     bOneUseOnly=False
     skillNeeded=Class'DeusEx.SkillEnviro'
     LoopSound=Sound'DeusExSounds.Pickup.SuitLoop'
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconArmorBallistic'
     ExpireMessage="Ballistic Armor power supply used up"
     ItemName="Ballistic Armor"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.BallisticArmor'
     PickupViewMesh=LodMesh'DeusExItems.BallisticArmor'
     ThirdPersonMesh=LodMesh'DeusExItems.BallisticArmor'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconArmorBallistic'
     largeIcon=Texture'DeusExUI.Icons.LargeIconArmorBallistic'
     largeIconWidth=34
     largeIconHeight=49
     Description="Ballistic armor is manufactured from electrically sensitive polymer sheets that intrinsically react to the violent impact of a bullet or an explosion by 'stiffening' in response and absorbing the majority of the damage.  These polymer sheets must be charged before use; after the charge has dissipated they lose their reflexive properties and should be discarded."
     ReductionStr="Reduces small arms, blades, and autoturret fire by %d%%."
     ReductionStr2="Reduces armor piercing rounds, blunt attacks, and explosives by only %d%%."
     beltDescription="BAL ARMOR"
     Mesh=LodMesh'DeusExItems.BallisticArmor'
     CollisionRadius=11.500000
     CollisionHeight=13.810000
     Mass=5.000000
     Buoyancy=3.500000
}
