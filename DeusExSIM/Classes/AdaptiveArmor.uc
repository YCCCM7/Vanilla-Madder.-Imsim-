//=============================================================================
// AdaptiveArmor.
//=============================================================================
class AdaptiveArmor extends ChargedPickup;

var float CloakDegradeTimer;
var int AIOwnershipDegradeRate;

//MADDERS: Activate soon after engaging combat if soft, or late in combat if a heavy unit.
function int VMDConfigureCloakThresholdMod()
{
	if (Charge > 0)
	{
		return 99;
	}
	else
	{
		return 0;
	}
}

//
// Behaves just like the cloak augmentation
//
function VMDSignalDamageTaken(int Damage, name DamageType, vector HitLocation, bool bCheckOnly)
{
	local bool bAugmentReduction;
	
	//MADDERS: Don't do this for now.
	if (bCheckOnly) return;
	
	bAugmentReduction = VMDHasSkillAugment('EnviroDurability');
	
	switch(DamageType)
	{
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
			PlaySound(DeactivateSound, SLOT_None);
			UseOnce();
		}
	}
}

//MADDERS: Cost charge per second when used by AI
function Tick(float DT)
{
	Super.Tick(DT);
	
	if ((ScriptedPawn(Owner) != None) && (ScriptedPawn(Owner).bCloakOn))
	{
		CloakDegradeTimer += DT;
		if (CloakDegradeTimer > 1.0)
		{
			Charge -= 1*AIOwnershipDegradeRate;
			CloakDegradeTimer -= 1.0;
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
     //MADDERS: 10 seconds of use for NPC's before depleting.
     AIOwnershipDegradeRate=25
     MaxLootCharge=325 //MADDERS, 1/24/21: 65%.
     
     bOneUseOnly=False
     skillNeeded=Class'DeusEx.SkillEnviro'
     LoopSound=Sound'DeusExSounds.Pickup.SuitLoop'
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconArmorAdaptive'
     ExpireMessage="Thermoptic camo power supply used up"
     ItemName="Thermoptic Camo"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
     PickupViewMesh=LodMesh'DeusExItems.AdaptiveArmor'
     ThirdPersonMesh=LodMesh'DeusExItems.AdaptiveArmor'
     Charge=500
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconArmorAdaptive'
     largeIcon=Texture'DeusExUI.Icons.LargeIconArmorAdaptive'
     largeIconWidth=35
     largeIconHeight=49
     Description="Integrating woven fiber-optics and an advanced computing system, thermoptic camo can render an agent invisible to both humans and bots by dynamically refracting light and radar waves; however, the high power drain makes it impractical for more than short-term use, after which the circuitry is fused and it becomes useless."
     beltDescription="THRM CAMO"
     Mesh=LodMesh'DeusExItems.AdaptiveArmor'
     CollisionRadius=11.500000
     CollisionHeight=13.810000
     Mass=5.000000
     Buoyancy=3.500000
}
