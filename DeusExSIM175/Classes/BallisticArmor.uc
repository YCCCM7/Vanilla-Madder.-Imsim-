//=============================================================================
// BallisticArmor.
//=============================================================================
class BallisticArmor extends ChargedPickup;

//
// Reduces ballistic damage
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
		Ret = (DXP.SkillSystem.GetSkillLevelValue(TSkill) + 1.0) / 2;
		switch(DT)
		{
			case 'Shot':
			case 'AutoShot':
				SpecMult = 0.5;
			break;
			case 'Sabot':
			case 'Exploded':
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
	if ((VMP != None))
	{
		if (VMP.HasSkillAugment("EnviroDurability"))
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
		case 'Shot':
		case 'AutoShot':
			Charge -= Damage * SkillValue;
		break;
		case 'Sabot':
		case 'Exploded':
			Charge -= Damage * 2 * SkillValue;
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
			Owner.AmbientSound = None;
			Owner.PlaySound(DeactivateSound, SLOT_None);
			UseOnce();
		}
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
     Description="Ballistic armor is manufactured from electrically sensitive polymer sheets that intrinsically react to the violent impact of a bullet or an explosion by 'stiffening' in response and absorbing the majority of the damage.  These polymer sheets must be charged before use; after the charge has dissipated they lose their reflexive properties and should be discarded. At base, ballistic armor reduces small arms and autoturret fire by 50%, but armor piercing rounds and explosives by a mere 25%. Any user's skill fitting the armor, however, has a strong influence on its lifetime and effectiveness."
     beltDescription="BAL ARMOR"
     Mesh=LodMesh'DeusExItems.BallisticArmor'
     CollisionRadius=11.500000
     CollisionHeight=13.810000
     Mass=40.000000
     Buoyancy=30.000000
}
