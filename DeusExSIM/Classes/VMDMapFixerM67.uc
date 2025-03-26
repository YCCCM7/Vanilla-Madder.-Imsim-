//=============================================================================
// VMDMapFixerM67.
//=============================================================================
class VMDMapFixerM67 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//67_DYNAMENE_EXTERIOR: Add vending machines so we don't starve, thanks.
		case "67_DYNAMENE_EXTERIOR":
			A = Spawn(class'VendingMachine',,, Vect(105, 1831, 690), Rot(0, 32768, 0));
			VendingMachine(A).SetPropertyText("SkinColor", "SC_Snack");
			VendingMachine(A).BeginPlay();
			A = Spawn(class'VendingMachine',,, Vect(105, 1781, 690), Rot(0, 32768, 0));
		break;
		//67_DYNAMENE_OUTERSECTION: More vending machines, these ones are goofier.
		case "67_DYNAMENE_OUTERSECTION":
			A = Spawn(class'VendingMachine',,, Vect(-97, 441, 50), Rot(0, -16384, 0));
			VendingMachine(A).SetPropertyText("SkinColor", "SC_Snack");
			VendingMachine(A).BeginPlay();
			A = Spawn(class'VendingMachine',,, Vect(161, 441, 50), Rot(0, -16384, 0));
		break;
	}
}

defaultproperties
{
}
