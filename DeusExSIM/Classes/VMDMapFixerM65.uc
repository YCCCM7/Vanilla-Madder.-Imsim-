//=============================================================================
// VMDMapFixerM65.
//=============================================================================
class VMDMapFixerM65 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//65_WOODFIBRE_BEACHFRONT: Vending machine is broken lol. Phase 2 onwards issue.
		case "65_WOODFIBRE_BEACHFRONT":
			forEach AllActors(class'Actor', A)
			{
				if (VendingMachine(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 0:
							A.SetRotation(Rot(0, -16384, 0));
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
