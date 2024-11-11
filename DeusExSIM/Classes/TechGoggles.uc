//=============================================================================
// TechGoggles.
//=============================================================================
class TechGoggles extends ChargedPickup;

var float GoggleThermalRange;

// ----------------------------------------------------------------------
// ChargedPickupBegin()
// ----------------------------------------------------------------------

function ChargedPickupBegin(DeusExPlayer Player)
{
	Super.ChargedPickupBegin(Player);

	DeusExRootWindow(Player.rootWindow).augDisplay.activeCount++;
	UpdateHUDDisplay(Player);
}

// ----------------------------------------------------------------------
// UpdateHUDDisplay()
// ----------------------------------------------------------------------

function UpdateHUDDisplay(DeusExPlayer Player)
{
	local AugmentationDisplayWindow TDisplay;
	
	if (Player == None || DeusExRootWindow(Player.RootWindow) == None) return;
	
	TDisplay = DeusExRootWindow(Player.rootWindow).AugDisplay;
	if (TDisplay == None) return;
	
	if ((TDisplay.activeCount == 0) && (IsActive()))
	{
		TDisplay.activeCount++;
	}
	
	TDisplay.bVisionActive = True;
	TDisplay.visionLevel = 3;
	TDisplay.visionLevelValue = GoggleThermalRange;
}

// ----------------------------------------------------------------------
// ChargedPickupEnd()
// ----------------------------------------------------------------------

function ChargedPickupEnd(DeusExPlayer Player)
{
	Super.ChargedPickupEnd(Player);

	if (--DeusExRootWindow(Player.rootWindow).augDisplay.activeCount == 0)
		DeusExRootWindow(Player.rootWindow).augDisplay.bVisionActive = False;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

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
}

function bool VMDHasActivationObjection()
{
	local DeusExPlayer DXP;
	local ChargedPickup TCharge;
	local Inventory Inv;
	
	DXP = DeusExPlayer(Owner);
	
	if ((DXP != None) && (!VMDHasSkillAugment('EnviroDurability')))
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
     //MADDERS additions
     GoggleThermalRange=800.000000
     MsgCopiesAdded="You found %d %ss"
     Charge=500
     MaxLootCharge=500
     
     skillNeeded=Class'DeusEx.SkillEnviro'
     bOneUseOnly=False
     LoopSound=Sound'DeusExSounds.Pickup.TechGogglesLoop'
     ChargedIcon=Texture'DeusExUI.Icons.ChargedIconGoggles'
     ExpireMessage="Infrared Goggles power supply used up"
     ItemName="Infrared Goggles"
     ItemArticle="some"
     PlayerViewOffset=(X=20.000000,Z=-6.000000)
     PlayerViewMesh=LodMesh'DeusExItems.GogglesIR'
     PickupViewMesh=LodMesh'DeusExItems.GogglesIR'
     ThirdPersonMesh=LodMesh'DeusExItems.GogglesIR'
     LandSound=Sound'DeusExSounds.Generic.PaperHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconTechGoggles'
     largeIcon=Texture'DeusExUI.Icons.LargeIconTechGoggles'
     largeIconWidth=49
     largeIconHeight=36
     Description="Tech goggles are used by many special ops forces throughout the world under a number of different brand names, but they all provide some form of portable light amplification in a disposable package."
     beltDescription="GOGGLES"
     Mesh=LodMesh'DeusExItems.GogglesIR'
     CollisionRadius=8.000000
     CollisionHeight=2.800000
     Mass=1.250000
     Buoyancy=0.625000
}
