//=============================================================================
// VMDMapFixerM70.
//=============================================================================
class VMDMapFixerM70 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//70_NORTHMONROE_ENTRY: Fix player's skills not resetting.
		case "70_NORTHMONROE_ENTRY":
			VMP.VMDResetNewGameVars(5);
		break;
		
		//70_MUTATIONS: Tip about bind map key.
		case "70_MUTATIONS":
			VMP.BigClientMessage(VMP.MutationsMapTip);
		break;
	}
}

defaultproperties
{
}
