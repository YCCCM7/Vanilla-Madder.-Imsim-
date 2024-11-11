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
				VMP.ZymeSmellLevel += 120 + Rand(30);
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
						
			player.drugEffectTimer += 60.0;
			if (VMP != None)
			{
				VMP.bZymeAffected = True;
				VMP.VMDGiveBuffType(class'ZymeArmorAura', class'ZymeArmorAura'.Default.Charge);
				VMP.VMDGiveBuffType(class'DrunkEffectAura', VMP.DrugEffectTimer * 40.0);
				VMP.PlaySound(sound'ZymeSnort', SLOT_None,,, 512);
			}
		}
		
		UseOnce();
	}
Begin:
}

defaultproperties
{
     bFragile=True
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
     Mass=0.500000
     Buoyancy=0.750000
}
