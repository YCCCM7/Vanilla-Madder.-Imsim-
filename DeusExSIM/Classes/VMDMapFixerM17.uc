//=============================================================================
// VMDMapFixerM17.
//=============================================================================
class VMDMapFixerM17 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//WAREHOUSE/WAREHOUSE_REMAKE: Alex freaks out.
		case "WAREHOUSE":
		case "WAREHOUSE_REMAKE":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (AlexJacobson(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							DumbAllReactions(SP);
						break;
					}
				}
			}
		break;
	}
}

defaultproperties
}
