//=============================================================================
// WineBottle.
//=============================================================================
class WineBottle extends DeusExPickup;

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
			 	//Alcohol is considerably addictive.
			 	VMP.VMDAddToAddiction("Alcohol", 90.0);
				
				FoodSeed = GetFoodSeed(13);
				if (FoodSeed == 2 || FoodSeed == 5 || FoodSeed == 9)
				{
			 		VMP.VMDRegisterFoodEaten(2, "WineFluff"); //Half for drinks, 2x for being big AF.
				}
				else
				{
			 		VMP.VMDRegisterFoodEaten(2, "Wine"); //Half for drinks, 2x for being big AF.
				}
				
				VMP.VMDGiveBuffType(class'DrunkEffectAura', VMP.DrugEffectTimer*40.0);
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
     ItemName="Wine"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.WineBottle'
     PickupViewMesh=LodMesh'DeusExItems.WineBottle'
     ThirdPersonMesh=LodMesh'DeusExItems.WineBottle'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconWineBottle'
     largeIcon=Texture'DeusExUI.Icons.LargeIconWineBottle'
     largeIconWidth=36
     largeIconHeight=48
     Description="A nice bottle of wine."
     beltDescription="WINE"
     Mesh=LodMesh'DeusExItems.WineBottle'
     CollisionRadius=4.060000
     CollisionHeight=16.180000
     Mass=2.000000
     Buoyancy=1.600000
}
