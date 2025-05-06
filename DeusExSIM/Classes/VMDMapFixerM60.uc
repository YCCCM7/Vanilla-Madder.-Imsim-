//=============================================================================
// VMDMapFixerM60.
//=============================================================================
class VMDMapFixerM60 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//60_HONGKONG_STREETS: Fix some exploits with cabinets and such
		case "60_HONGKONG_STREETS":
			
			//Two cabinets in yakedo's basement
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(3441,1869,57));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(3441,1869,57);
				TCamp.MaxCampLocation = Vect(3463,1923,103);
				TCamp.NumWatchedDoors = 2;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 111));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 112));
				TCamp.CabinetDoorClosedFrames[1] = 0;
				TCamp.bLastOpened = true;
			}
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(3673,1869,57));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(3673,1869,57);
				TCamp.MaxCampLocation = Vect(3695,1923,103);
				TCamp.NumWatchedDoors = 2;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
				TCamp.CabinetDoorClosedFrames[1] = 0;
				TCamp.bLastOpened = true;
			}
			
			//Various displays in the shop
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1953,3553,792));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(1953,3553,792);
				TCamp.MaxCampLocation = Vect(1983,3583,807);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 12));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1953,3601,824));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(1953,3601,824);
				TCamp.MaxCampLocation = Vect(1983,3631,839);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 122));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1953,3649,784));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(1953,3649,784);
				TCamp.MaxCampLocation = Vect(1983,3679,847);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 43));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(2145,3649,784));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(2145,3649,784);
				TCamp.MaxCampLocation = Vect(2175,3679,847);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 45));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(2145,3601,792));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(2145,3601,792);
				TCamp.MaxCampLocation = Vect(2176,3631,807);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 49));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
		break;
		//60_HONGKONG_GREASELPIT: Rogue turret.
		case "60_HONGKONG_GREASELPIT":
			/*forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = false;
				}
			}*/
		break;
		//60_HONGKONG_FORICHI: Floating bouncers after DXT model update.
		case "60_HONGKONG_FORICHI":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (TriadLumPath(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							SP.SetLocation(Vect(579, 1117, -945));
						break;
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
