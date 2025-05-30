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
		//75_ZODIAC_NEWMEXICO_HLAB: Add more pathing for MEGH.
		case "75_ZODIAC_NEWMEXICO_HLAB":
			Spawn(class'PathNodeMobile',,, Vect(-1103,1901,-209));
			Spawn(class'PathNodeMobile',,, Vect(-1112,2126,-270));
			Spawn(class'PathNodeMobile',,, Vect(-1110,2526,-369));
			Spawn(class'PathNodeMobile',,, Vect(-75,-3927,-1193));
			Spawn(class'PathNodeMobile',,, Vect(100,4046,-1193));
			Spawn(class'PathNodeMobile',,, Vect(977,2411,-1147));
			Spawn(class'PathNodeMobile',,, Vect(956,2130,-1076));
			Spawn(class'PathNodeMobile',,, Vect(949,1820,-1033));
			Spawn(class'PathNodeMobile',,, Vect(964,1958,-1033));
			Spawn(class'PathNodeMobile',,, Vect(1825,3722,-1193));
			VMP.VMDRebuildPaths();
		break;
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
			
			Spawn(class'PathNodeMobile',,, Vect(513,-2296,239));
			Spawn(class'PathNodeMobile',,, Vect(285,-2282,239));
			Spawn(class'PathNodeMobile',,, Vect(319,-2554,239));
			Spawn(class'PathNodeMobile',,, Vect(58,-2297,239));
			Spawn(class'PathNodeMobile',,, Vect(-113,-2294,239));
			Spawn(class'PathNodeMobile',,, Vect(-104,-2533,239));
			Spawn(class'PathNodeMobile',,, Vect(-282,-2557,239));
			Spawn(class'PathNodeMobile',,, Vect(-285,-2282,239));
			Spawn(class'PathNodeMobile',,, Vect(-456,-2282,239));
			Spawn(class'PathNodeMobile',,, Vect(-535,-2002,239));
			Spawn(class'PathNodeMobile',,, Vect(-559,-2636,239));
			Spawn(class'PathNodeMobile',,, Vect(-1260,-4920,191));
			Spawn(class'PathNodeMobile',,, Vect(-1559,-4638,191));
			Spawn(class'PathNodeMobile',,, Vect(-1762,-4639,191));
			Spawn(class'PathNodeMobile',,, Vect(-1933,-4642,191));
			Spawn(class'PathNodeMobile',,, Vect(-2198,-4707,191));
			Spawn(class'PathNodeMobile',,, Vect(-1852,-4385,191));
			Spawn(class'PathNodeMobile',,, Vect(-2299,-4432,191));
			Spawn(class'PathNodeMobile',,, Vect(-2324,-4133,191));
			Spawn(class'PathNodeMobile',,, Vect(-1678,-4383,191));
			Spawn(class'PathNodeMobile',,, Vect(-1280,-4393,191));
			Spawn(class'PathNodeMobile',,, Vect(-1530,-4123,191));
			Spawn(class'PathNodeMobile',,, Vect(-2069,-4376,191));
			Spawn(class'PathNodeMobile',,, Vect(-559,-2636,239));
			Spawn(class'PathNodeMobile',,, Vect(-439,-2641,239));
			Spawn(class'PathNodeMobile',,, Vect(-587,-2518,239));
			Spawn(class'PathNodeMobile',,, Vect(-598,-2286,95));
			Spawn(class'PathNodeMobile',,, Vect(-704,-2213,90));
			Spawn(class'PathNodeMobile',,, Vect(-798,-2194,87));
			Spawn(class'PathNodeMobile',,, Vect(-1011,-2203,151));
			Spawn(class'PathNodeMobile',,, Vect(-640,-2192,95));
			Spawn(class'PathNodeMobile',,, Vect(-3073,-2039,-1));
			Spawn(class'PathNodeMobile',,, Vect(-3328,-2066,-65));
			VMP.VMDRebuildPaths();
			
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
