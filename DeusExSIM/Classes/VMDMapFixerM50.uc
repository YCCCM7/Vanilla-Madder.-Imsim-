//=============================================================================
// VMDMapFixerM50.
//=============================================================================
class VMDMapFixerM50 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		case "50_OMEGASTART":
			//MADDERS, 4/3/24: Omega NG plus. Weird hack with the movers, but aight, this way we'll know.
			NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(20, 5295, 812), Rot(0, -8192, 0));
			if (NGPortal != None)
			{
				NGPortal.FlagRequired = '';
				NGPortal.CampMovers[0] = Mover(FindActorBySeed(class'ElevatorMover', 0));
				NGPortal.CampMoverFrames[0] = 1;
				NGPortal.CampMovers[1] = Mover(FindActorBySeed(class'ElevatorMover', 1));
				NGPortal.CampMoverFrames[1] = 1;
				NGPortal.CampMovers[2] = Mover(FindActorBySeed(class'ElevatorMover', 2));
				NGPortal.CampMoverFrames[2] = 1;
			}
		break;
		//50_OMEGA_VOL2: Killing boss in under 10 seconds (possible with some builds) results in elevator breaking.
		//Add artificial delay to the secondary dispatcher to fix it.
		case "50_OMEGAVOL2":
			A = FindActorBySeed(class'Dispatcher', 8);
			if (A != None)
			{
				Dispatcher(A).OutDelays[6] = 0.0;
			}
			A = FindActorBySeed(class'Dispatcher', 9);
			if (A != None)
			{
				Dispatcher(A).OutDelays[0] = 6.1;
			}
		break;
		case "50_OMEGAVOL3":
			forEach AllActors(class'Mover', TMov)
			{
				if (ElevatorMover(TMov) != None)
				{
					switch(SF.Static.StripBaseActorSeed(TMov))
					{
						//MADDERS, 7/2/24: Door gets stuck. It's crap.
						case 1:
							TMov.MoverEncroachType = ME_IgnoreWhenEncroach;
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
