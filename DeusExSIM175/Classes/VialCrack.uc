//=============================================================================
// VialCrack.
//=============================================================================
class VialCrack extends DeusExPickup;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local DeusExPlayer player;
		local ZymeArmorAura ZAA;
		local VMDBufferplayer VMP;
		
		Super.BeginState();
		
		player = DeusExPlayer(Owner);
		VMP = VMDBufferPlayer(Player);
		if (player != None)
		{
			player.HealPlayer(120, False);
			//This shit is literally crack. 2/3 chance to be addicted from just one.
			if (VMP != None)
			{
				if (Player.DrugEffectTimer < 30)
				{
			 		VMP.VMDRegisterFoodEaten(0, "ZymeFluff");
				}
				else
				{
			 		VMP.VMDRegisterFoodEaten(0, "Zyme");
				}
			 	VMP.VMDAddToAddiction("Zyme", 180.0 + (18 * GetAddictionSeed(11)));
			}
			
			ZAA = ZymeArmorAura(Player.FindInventoryType(class'ZymeArmorAura'));
			if (ZAA == None)
			{
				ZAA = Spawn(class'ZymeArmorAura');
				if (ZAA != None)
				{
					ZAA.Frob(Player, None);
					ZAA.Activate();
				}
			}
			else
			{
				ZAA.Charge = ZAA.Default.Charge;
			}
			player.drugEffectTimer += 60.0;
			if (VMP != None)
			{
				VMP.bZymeAffected = True;
			}
		}
		
		UseOnce();
	}
Begin:
}

defaultproperties
{
     M_Activated="You snort the %s"
     MsgCopiesAdded="You found %d %ss"
     
     maxCopies=20
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Zyme Vial"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.VialCrack'
     PickupViewMesh=LodMesh'DeusExItems.VialCrack'
     ThirdPersonMesh=LodMesh'DeusExItems.VialCrack'
     LandSound=Sound'DeusExSounds.Generic.GlassHit1'
     Icon=Texture'DeusExUI.Icons.BeltIconVial_Crack'
     largeIcon=Texture'DeusExUI.Icons.LargeIconVial_Crack'
     largeIconWidth=24
     largeIconHeight=43
     Description="A vial of zyme, brewed up in some basement lab.|n|nEFFECTS: ???"
     beltDescription="ZYME"
     Mesh=LodMesh'DeusExItems.VialCrack'
     CollisionRadius=0.910000
     CollisionHeight=1.410000
     Mass=1.000000
     Buoyancy=1.500000
}
