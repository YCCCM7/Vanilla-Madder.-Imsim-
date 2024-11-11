//=============================================================================
// HazMatSuit.
//=============================================================================
class HazMatSuit extends ChargedPickup;

//
// Reduces poison gas, tear gas, and radiation damage
//
//MADDERS: Configure our damage reduction!
function float VMDConfigurePickupDamageMult(name DT)
{
	local float Ret, SpecMult;
	local DeusExPlayer DXP;
	local VMDBufferPawn VMBP;
	local class<Skill> TSkill;
	
	TSkill = SkillNeeded;
	Ret = 1.0;
	
	DXP = DeusExPlayer(Owner);
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
		Ret = (DXP.SkillSystem.GetSkillLevelValue(TSkill) + 1.0) / 2;
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
	if ((VMDBufferPlayer(Owner) != None))
	{
		if (VMDBufferPlayer(Owner).HasSkillAugment("EnviroDurability"))
		{
			bAugmentReduction = true;
		}
		if (VMDBufferPlayer(Owner).SkillSystem != None)
		{
			//MADDERS: Reduce erode rate slightly based on skill level.
			if (bAugmentReduction)
			{
				SkillValue = 12.0 * (Sqrt(VMDBufferPlayer(Owner).SkillSystem.GetSkillLevelValue(TSkill)));
			}
			else
			{
				SkillValue = 16.0 * (Sqrt(VMDBufferPlayer(Owner).SkillSystem.GetSkillLevelValue(TSkill)));
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
			Charge -= Damage * SkillValue;
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
			Owner.AmbientSound = None;
			Owner.PlaySound(DeactivateSound, SLOT_None);
			UseOnce();
		}
	}
}

//MADDERS, 5/29/22: Backwards logic is vanilla logic. IE, we block tear gas and halon gas rubbing eyes effect.
function bool VMDFilterDamageTaken(name DT)
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
     Description="A standard hazardous materials suit that protects against a full range of environmental hazards including radiation, fire, biochemical toxins, electricity, and EMP. Hazmat suits contain an integrated bacterial oxygen scrubber that degrades over time and thus should not be reused. At base, a hazmat suit reduces poison gas and radiation by 50%, and other hazards by 25%, but grants full immunity to blinding aerosols. Any user's skill fitting the suit, however, has a strong influence on its lifetime and effectiveness."
     beltDescription="HAZMAT"
     Texture=Texture'DeusExItems.Skins.ReflectionMapTex1'
     Mesh=LodMesh'DeusExItems.HazMatSuit'
     CollisionRadius=17.000000
     CollisionHeight=11.520000
     Mass=20.000000
     Buoyancy=12.000000
}
