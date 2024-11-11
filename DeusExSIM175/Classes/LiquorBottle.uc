//=============================================================================
// LiquorBottle.
//=============================================================================
class LiquorBottle extends DeusExPickup;

//MADDERS additions
var localized string MsgDrinkUnderwater;

function bool VMDHasActivationObjection()
{
	local DeusExPlayer Player;
	
	Player = DeusExPlayer(Owner);
	if ((Player != None) && (Player.HeadRegion.Zone.bWaterZone))
	{
		Player.ClientMessage(MsgDrinkUnderwater);
		return true;
	}
	
	return false;
}

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local int FoodSeed;
		local DeusExPlayer player;
		local DrunkEffectAura DEA; //Irony.
		local VMDBufferPlayer VMP;
		
		Super.BeginState();

		player = DeusExPlayer(Owner);
		if (player != None)
		{
			VMP = VMDBufferPlayer(Player);
			player.HealPlayer(2, False);
			player.drugEffectTimer += 10.0;
			
			if (VMP != None)
			{
			 	//Alcohol is considerably addictive. This is a high dose.
			 	VMP.VMDAddToAddiction("Alcohol", 120.0);
				
				FoodSeed = GetFoodSeed(9);
				if (FoodSeed == 1 || FoodSeed == 3 || FoodSeed == 6)
				{
			 		VMP.VMDRegisterFoodEaten(2, "WhiskeyFluff"); //Half for drinks, 2x for being big AF.
				}
				else
				{
			 		VMP.VMDRegisterFoodEaten(2, "Whiskey"); //Half for drinks, 2x for being big AF.
				}
				
				if (VMP != None)
				{
					DEA = DrunkEffectAura(VMP.FindInventoryType(class'DrunkEffectAura'));
					if (DEA == None)
					{
						DEA = Spawn(class'DrunkEffectAura');
						if (DEA != None)
						{
							DEA.Frob(VMP, None);
							DEA.Activate();
						}
					}
					if (DEA != None)
					{
						DEA.Charge = VMP.DrugEffectTimer*40.0;
					}
				}
			}
		}

		UseOnce();
	}
Begin:
}

defaultproperties
{
     SmellType="Food"
     SmellUnits=150
     M_Activated="You drink the %s"
     MsgCopiesAdded="You found %d %ss"
     
     MsgDrinkUnderwater="You cannot do that while underwater"
     bBreakable=True
     maxCopies=5
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Liquor"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.LiquorBottle'
     PickupViewMesh=LodMesh'DeusExItems.LiquorBottle'
     ThirdPersonMesh=LodMesh'DeusExItems.LiquorBottle'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconLiquorBottle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconLiquorBottle'
     largeIconWidth=20
     largeIconHeight=48
     Description="The label is torn off, but it looks like some of the good stuff."
     beltDescription="LIQUOR"
     Mesh=LodMesh'DeusExItems.LiquorBottle'
     CollisionRadius=4.620000
     CollisionHeight=12.500000
     Mass=2.000000
     Buoyancy=1.600000
}
