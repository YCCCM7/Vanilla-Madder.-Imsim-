//=============================================================================
// VMDMapFixerM67.
//=============================================================================
class VMDMapFixerM67 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//67_DYNAMENE_EXTERIOR: Add vending machines so we don't starve, thanks.
		case "67_DYNAMENE_EXTERIOR":
			A = Spawn(class'VendingMachine',,, Vect(105, 1831, 690), Rot(0, 32768, 0));
			VendingMachine(A).SetPropertyText("SkinColor", "SC_Snack");
			VendingMachine(A).BeginPlay();
			A = Spawn(class'VendingMachine',,, Vect(105, 1781, 690), Rot(0, 32768, 0));
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				//MADDERS, 4/29/25: Give Yoon some augs for this fight.
				// Also some other stuff, to make him a badass.
				VMBP = VMDBufferPawn(TPawn);
				if ((VMBP != None) && (VMBP.IsA('EthanYoon')))
				{
					VMBP.bHasAugmentations = true;
					VMBP.Energy = 75;
					VMBP.EnergyMax = 75;
					VMBP.AddToInitialInventory(class'BioelectricCell', 6);
					VMBP.AddToInitialInventory(class'VMDMedigel', 5);
					VMBP.VMDWipeAllAugs();
					VMBP.DefaultAugs[0] = class'AugBallistic';
					VMBP.DefaultAugs[1] = class'AugShield';
					VMBP.DefaultAugs[2] = class'AugEnviro';
					VMBP.DefaultAugs[3] = class'AugTarget';
					VMBP.DefaultAugs[4] = class'AugHealing';
					VMBP.DefaultAugs[5] = class'AugPower';
					VMBP.DefaultAugs[6] = class'AugCombat';
					VMBP.DefaultAugs[7] = class'AugSpeed';
					VMBP.VMDInitializeSubsystems();
				}
			}
		break;
		//67_DYNAMENE_OUTERSECTION: More vending machines, these ones are goofier.
		case "67_DYNAMENE_OUTERSECTION":
			A = Spawn(class'VendingMachine',,, Vect(-97, 441, 50), Rot(0, -16384, 0));
			VendingMachine(A).SetPropertyText("SkinColor", "SC_Snack");
			VendingMachine(A).BeginPlay();
			A = Spawn(class'VendingMachine',,, Vect(161, 441, 50), Rot(0, -16384, 0));
		break;
		//67_DYNAMENE_INNERSECTION: Cabinet with exploit.
		case "67_DYNAMENE_INNERSECTION":
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-3855,373,272));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(177,-11183,-671);
				TCamp.MaxCampLocation = Vect(239,-11127,-609);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 24));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
		break;
	}
}

defaultproperties
{
}
