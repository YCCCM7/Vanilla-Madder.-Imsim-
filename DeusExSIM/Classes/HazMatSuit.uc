//=============================================================================
// HazMatSuit.
//=============================================================================
class HazMatSuit extends ChargedPickup;

var localized string ReductionStr, ReductionStr2, ImmunityStr;

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
		
		ReductionLevel = int((1.0 - VMDConfigurePickupDamageMult('Radiation', 1, Owner.Location)) * 100.0);
		ReductionLevel2 = int((1.0 - VMDConfigurePickupDamageMult('Poison', 1, Owner.Location)) * 100.0);
		
		//MADDERS, 1/8/21: Update charge stacks at all times.
		ChargeStacks[NumCopies-1] = Charge;
		
		winInfo.SetTitle(itemName);
		winInfo.SetText(Description $ winInfo.CR() $ winInfo.CR() $ ImmunityStr @ SprintF(ReductionStr, ReductionLevel) @ SprintF(ReductionStr2, ReductionLevel2) $ winInfo.CR() $ winInfo.CR());
		
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
// Reduces poison gas, tear gas, and radiation damage
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
	
	DXP = DeusExPlayer(Owner);
	VMBP = VMDBufferPawn(Owner);
	if ((VMBP != None) && (TSkill != None))
	{
		Ret = (TSkill.Default.LevelValues[VMBP.EnviroSkillLevel] + 1.0) / 2;
		
		switch(DT)
		{
			case 'TearGas':
			case 'HalonGas':
			case 'OwnedHalonGas':
				return 0.0;
			break;
			//Poison gas and radiation is classic hazmat realm of expertise. 50% at base, please.
			case 'Radiation':
			case 'PoisonGas':
				SpecMult = 0.5;
			break;
			//case 'PoisonEffect':
			case 'Poison':
			//MADDERS: Adding these to make the desc shut the fuck up.
			//It was probably lost in translation, given how messy the old pickup processing was.
			case 'EMP':
			case 'Shocked':
			case 'Burned':
				SpecMult = 0.75;
			break;
			default:
			 	return 1.0;
			break;
		}
		return Ret*SpecMult;
	}
	
	//MADDERS: Nerf damage reduction somewhat, since we're left on long term, even if not for a high number of hits.
	if (DXP != None)
	{
		Ret = (DXP.SkillSystem.GetSkillLevelValue(TSkill) + 0.75) / 2;
		switch(DT)
		{
			case 'TearGas':
			case 'HalonGas':
			case 'OwnedHalonGas':
				return 0.0;
			break;
			//Poison gas and radiation is classic hazmat realm of expertise. 50% at base, please.
			case 'Radiation':
			case 'PoisonGas':
				SpecMult = 0.5;
			break;
			//case 'PoisonEffect':
			case 'Poison':
			//MADDERS: Adding these to make the desc shut the fuck up.
			//It was probably lost in translation, given how messy the old pickup processing was.
			case 'EMP':
			case 'Shocked':
			case 'Burned':
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
	if (VMP != None)
	{
		if (VMDHasSkillAugment('EnviroDurability'))
		{
			bAugmentReduction = true;
		}
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
		case 'TearGas':
		case 'PoisonGas':
		case 'Radiation':
		case 'HalonGas':
		case 'PoisonEffect':
		case 'Poison':
		case 'Shocked':
			if (VMP != None)
			{
				Charge -= Max(1, Damage * SkillValue * 0.5);
			}
			else
			{
				Charge -= Max(1, Damage * SkillValue);
			}
		break;
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
				VMDBufferPawn(Owner).RestoreHazmatSuitModel();
			}
			Owner.AmbientSound = None;
			Owner.PlaySound(DeactivateSound, SLOT_None);
			UseOnce();
		}
	}
}

//MADDERS, 5/29/22: Backwards logic is vanilla logic. IE, we block tear gas and halon gas rubbing eyes effect.
function bool VMDFilterDamageTaken(name DT, int HitDamage, Vector HitLocation)
{
	switch(DT)
	{
		case 'TearGas':
		case 'HalonGas':
		case 'OwnedHalonGas':
			return false;
		break;
		default:
			return true;
		break;
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
				if ((BallisticArmor(Inv) != None) && (BallisticArmor(Inv).bIsActive))
				{
					TCharge = BallisticArmor(Inv);
					break;
				}
				if ((Rebreather(Inv) != None) && (Rebreather(Inv).bIsActive))
				{
					TCharge = Rebreather(Inv);
					break;
				}
				if ((TechGoggles(Inv) != None) && (TechGoggles(Inv).bIsActive))
				{
					TCharge = TechGoggles(Inv);
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
     LoopSound=Sound'VMDAssets.Pickup.VMDHazmatSuitLoop'
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconHazMatSuit'
     ExpireMessage="Hazmat Suit power supply used up"
     ItemName="Hazmat Suit"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.HazMatSuit'
     PickupViewMesh=LodMesh'DeusExItems.HazMatSuit'
     ThirdPersonMesh=LodMesh'DeusExItems.HazMatSuit'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconHazMatSuit'
     largeIcon=Texture'DeusExUI.Icons.LargeIconHazMatSuit'
     largeIconWidth=46
     largeIconHeight=45
     Description="A standard hazardous materials suit that protects against a full range of environmental hazards including radiation, fire, biochemical toxins, electricity, and EMP. Hazmat suits contain an integrated bacterial oxygen scrubber that degrades over time and thus should not be reused."
     
     ReductionStr="Reduces poison gas and radiation by %d%%."
     ReductionStr2="Reduces other hazards by %d%%."
     ImmunityStr="Grants full immunity to blinding aerosols."
     
     beltDescription="HAZMAT"
     Texture=Texture'DeusExItems.Skins.ReflectionMapTex1'
     Mesh=LodMesh'DeusExItems.HazMatSuit'
     CollisionRadius=17.000000
     CollisionHeight=11.520000
     Mass=35.000000
     Buoyancy=20.000000
}
