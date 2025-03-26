//=============================================================================
// VMDMapFixerM58.
//=============================================================================
class VMDMapFixerM58 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//58_YUANDAZHU_STREETS: Fix player's skills not resetting.
		case "58_YUANDAZHU_STREETS":
			if (VMP != None)
			{
				VMP.VMDResetNewGameVars(5);
			}
		break;
	}
}

defaultproperties
{
}
