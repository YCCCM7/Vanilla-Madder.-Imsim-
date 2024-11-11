//=============================================================================
// Cigarettes.
//=============================================================================
class Cigarettes extends DeusExPickup;

state Activated
{
	function Activate()
	{
		// can't turn it off
	}

	function BeginState()
	{
		local Pawn P;
		local vector loc;
		local rotator rot;
		local SmokeTrail puff;
		local Augmentation TAug;
		local VMDBufferPlayer VMP;
		local int FoodSeed;
		local CigarettesBuffAura CBA;
		
		Super.BeginState();
		
		VMP = VMDBufferPlayer(Owner);
		if (VMP != None)
		{
			FoodSeed = GetFoodSeed(3);
			if (FoodSeed == 1)
			{
				VMP.VMDRegisterFoodEaten(0, "CigarettesFluff");
			}
			else
			{
		 		VMP.VMDRegisterFoodEaten(0, "Cigarettes");
			}
			
		 	//Cigarettes are mad addictive. 1/4 chance for addiction in one shot.
		 	VMP.VMDAddToAddiction("Nicotine", 195.0 + (10 * GetAddictionSeed(11)));
		}
		
		P = Pawn(Owner);
		if (P != None)
		{
		 	P.TakeDamage(5, P, P.Location, vect(0,0,0), 'DrugDamage');
			
			loc = Owner.Location;
			rot = Owner.Rotation;
			loc += 2.0 * Owner.CollisionRadius * vector(P.ViewRotation);
			loc.Z += Owner.CollisionHeight * 0.9;
			puff = Spawn(class'SmokeTrail', Owner,, loc, rot);
			if (puff != None)
			{
				puff.DrawScale = 1.0;
				puff.origScale = puff.DrawScale;
			}
			if ((VMP != None) && (VMP.bAssignedFemale))
			{
				PlaySound(sound'VMDFJCCough');
			}
			else
			{
				PlaySound(sound'MaleCough');
			}
			
			if (VMP != None)
			{
				VMP.VMDGiveBuffType(class'CigarettesBuffAura', class'CigarettesBuffAura'.Default.Charge);
				VMP.CigaretteAppetitePeriod = 360;
			}
		}

		UseOnce();
	}
Begin:
}

defaultproperties
{
     M_Activated="You light up the %s"
     MsgCopiesAdded="You found %d %s"
     
     maxCopies=8 //Ironically, nerfed from 20 ~MADDERS
     bCanHaveMultipleCopies=True
     bActivatable=True
     ItemName="Cigarettes"
     ItemArticle="some"
     PlayerViewOffset=(X=30.000000,Z=-12.000000)
     PlayerViewMesh=LodMesh'DeusExItems.Cigarettes'
     PickupViewMesh=LodMesh'DeusExItems.Cigarettes'
     ThirdPersonMesh=LodMesh'DeusExItems.Cigarettes'
     Icon=Texture'DeusExUI.Icons.BeltIconCigarettes'
     largeIcon=Texture'DeusExUI.Icons.LargeIconCigarettes'
     largeIconWidth=29
     largeIconHeight=43
     Description="'COUGHING NAILS -- when you've just got to have a cigarette.'|n|nEFFECTS: For 20 seconds: Massively reduced stress levels.|nFor 180 seconds: Suppress appetite. For 180 seconds after this effect ends, increase appetite."
     beltDescription="CIGS"
     Mesh=LodMesh'DeusExItems.Cigarettes'
     CollisionRadius=5.200000
     CollisionHeight=1.320000
     Mass=0.500000
     Buoyancy=0.750000
}
