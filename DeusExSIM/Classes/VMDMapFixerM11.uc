//=============================================================================
// VMDMapFixerM11.
//=============================================================================
class VMDMapFixerM11 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//11_PARIS_CATHEDRAL: Gunther isn't friends with a lot of people, and keeps getting froggy. Turn off his hearing.
		case "11_PARIS_CATHEDRAL":
			if (!bRevisionMapSet)
			{
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-6382,291,-542));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(-6479,257,-607);
					TCamp.MaxCampLocation = Vect(-6289,335,-481);
					TCamp.NumWatchedDoors = 1;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'BreakableGlass', 8));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.bIgnoreLockStatus = true;
					TCamp.bLastOpened = true;
				}
				
				//Plug a hole in a crate we can walk through. Oops.
				PlugVect = Vect(2440, 0, 193);
				for (i=-424; i<-188; i += 8)
				{
					PlugVect.Y = i;
					AddBSPPlug(PlugVect, 8, 16);
				}
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (GuntherHermann(SP) != None)
					{
						SP.bReactLoudNoise = false;
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(3536,-2560,-107));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(3541,-2587,-104);
					TCamp.MaxCampLocation = Vect(3562,-2532,-56);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
			}
		break;
		//11_PARIS_EVERETT: Hide the misc, hidden vent, and also the mirror.
		case "11_PARIS_EVERETT":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 2:
							case 4:
							case 5:
								DXM.bHighlight = false;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-252,2553,198));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(-245,2525,200);
					TCamp.MaxCampLocation = Vect(-224,2581,248);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
			}
		break;
	}
}

defaultproperties
{
}
