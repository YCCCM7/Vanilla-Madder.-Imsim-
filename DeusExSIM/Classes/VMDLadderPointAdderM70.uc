//=============================================================================
// VMDLadderPointAdderM70.
//=============================================================================
class VMDLadderPointAdderM70 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		//70_ZODIAC_HONGKONG_TONGBASE: Add some more path nodes for MEGH.
		case "70_ZODIAC_HONGKONG_TONGBASE":
			Spawn(class'PathNodeMobile',,, Vect(-530,92,15));
			Spawn(class'PathNodeMobile',,, Vect(-526,-320,15));
			Spawn(class'PathNodeMobile',,, Vect(-630,-320,15));
			Spawn(class'PathNodeMobile',,, Vect(-1013,-320,143));
			Spawn(class'PathNodeMobile',,, Vect(-1229,-320,143));
			Spawn(class'PathNodeMobile',,, Vect(-1488,-305,143));
			bRebuildRequired = true;
		break;
	}
}

defaultproperties
{
}
