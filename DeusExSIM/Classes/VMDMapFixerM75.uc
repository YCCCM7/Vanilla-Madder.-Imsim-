//=============================================================================
// VMDMapFixerM75.
//=============================================================================
class VMDMapFixerM75 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//75_ZODIAC_NEWMEXICO_HOLLOMAN: Add more pathing for MEGH.
		case "75_ZODIAC_NEWMEXICO_HOLLOMAN":
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-2284,-4551,217));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-2284,-4551,217);
				TCamp.MaxCampLocation = Vect(-2229,-4529,263);
				TCamp.NumWatchedDoors = 2;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 27));
				TCamp.CabinetDoorClosedFrames[1] = 0;
				TCamp.bLastOpened = true;
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				//MADDERS, 4/29/25: Hela is very similar to Anna Navarre, so not much room for creativity.
				VMBP = VMDBufferPawn(TPawn);
				if ((VMBP != None) && (VMBP.IsA('Hela')))
				{
					VMBP.bHasAugmentations = true;
					VMBP.bMechAugs = true;
					VMBP.Energy = 65;
					VMBP.EnergyMax = 65;
					VMBP.AddToInitialInventory(class'BioelectricCell', 5);
					VMBP.AddToInitialInventory(class'VMDMedigel', 3);
					VMBP.VMDWipeAllAugs();
					VMBP.DefaultAugs[0] = class'AugMechCloak';
					VMBP.DefaultAugs[1] = class'AugMechDermal';
					VMBP.DefaultAugs[2] = class'AugMechEnviro';
					VMBP.DefaultAugs[3] = class'AugMechSpeed';
					VMBP.DefaultAugs[4] = class'AugMechTarget';
					VMBP.DefaultAugs[5] = class'AugMechEnergy';
					VMBP.VMDInitializeSubsystems();
				}
			}
		break;
	}
}

defaultproperties
{
}
