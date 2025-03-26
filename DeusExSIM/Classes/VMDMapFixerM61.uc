//=============================================================================
// VMDMapFixerM61.
//=============================================================================
class VMDMapFixerM61 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//61_HONGKONG_TIANBAOHOTEL: Infighting from bad alliances.
		case "61_HONGKONG_TIANBAOHOTEL":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (SP.Alliance == 'Yoon')
				{
					SP.ChangeAlly('LumPath', 1, True);
				}
			}
		break;
	}
}

defaultproperties
{
}
