//=============================================================================
// Rebreather.
//=============================================================================
class Rebreather extends ChargedPickup;

var float LastSeconds;

//MADDERS: Reset this counter so spamming clicks can't game it.
function ChargedPickupEnd(DeusExPlayer Player)
{
	Super.ChargedPickupEnd(Player);
	
	LastSeconds = 0;
}

//MADDERS: This comes with no delta time attached. Fuck that. Use Level.TimeSeconds to derive DT anyways.
function ChargedPickupUpdate(DeusExPlayer Player)
{	
	Super.ChargedPickupUpdate(Player);
	
	if (Level != None)
	{
		if (LastSeconds > 0)
		{
			//2x rate to create a recovery effect.
			Player.SwimTimer += ((Level.TimeSeconds - LastSeconds) * 2);
			if (Player.SwimTimer > Player.SwimDuration) Player.SwimTimer = Player.SwimDuration;
		}
		LastSeconds = Level.TimeSeconds;
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
     Charge=500
     MaxLootCharge=500
     
     bOneUseOnly=False
     skillNeeded=Class'DeusEx.SkillEnviro'
     LoopSound=Sound'DeusExSounds.Pickup.RebreatherLoop'
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconRebreather'
     ExpireMessage="Rebreather power supply used up"
     ItemName="Rebreather"
     PlayerViewOffset=(X=30.000000,Z=-6.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Rebreather'
     PickupViewMesh=LodMesh'DeusExItems.Rebreather'
     ThirdPersonMesh=LodMesh'DeusExItems.Rebreather'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconRebreather'
     largeIcon=Texture'DeusExUI.Icons.LargeIconRebreather'
     largeIconWidth=44
     largeIconHeight=34
     Description="A disposable chemical scrubber that can extract oxygen from water during brief submerged operations."
     beltDescription="REBREATHR"
     Mesh=LodMesh'DeusExItems.Rebreather'
     CollisionRadius=6.900000
     CollisionHeight=3.610000
     Mass=17.000000
     Buoyancy=15.000000
}
