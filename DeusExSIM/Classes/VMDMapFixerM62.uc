//=============================================================================
// VMDMapFixerM62.
//=============================================================================
class VMDMapFixerM62 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//62_BERLIN_AIRBORNELAB: Cabinets with exploits. Easy enough to fix.
		case "62_BERLIN_AIRBORNELAB":
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-1751,-319,-63));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-1751,-319,-63);
				TCamp.MaxCampLocation = Vect(-1695,-257,-1);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 24));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-507,225,273));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-507,225,273);
				TCamp.MaxCampLocation = Vect(-489,287,335);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 31));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-3855,373,272));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-3855,373,272);
				TCamp.MaxCampLocation = Vect(-3792,391,334);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
		break;
		//62_BERLIN_STREETS: More cabinets, but just one set.
		case "62_BERLIN_STREETS":
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-1535,1283,-367));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-1535,1283,-367);
				TCamp.MaxCampLocation = Vect(-1473,1291,-341);
				TCamp.NumWatchedDoors = 2;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 6));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 19));
				TCamp.CabinetDoorClosedFrames[1] = 0;
				TCamp.bLastOpened = true;
			}
		break;
	}
}

defaultproperties
{
}
