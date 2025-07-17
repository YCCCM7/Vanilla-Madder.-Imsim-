//=============================================================================
// VMDLadderPointAdderM66.
//=============================================================================
class VMDLadderPointAdderM66 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "66_WHITEHOUSE_EXTERIOR":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder to and from white house yard.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(4206,-64,-329)+TSpacing, Vect(4206,-64,88)+TSpacing, Vect(4127,-64,87),, 4+8,,,, None);
			
			//Ladder on construction region near map exit.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(658,-46,-616)+TSpacing, Vect(658,-46,-417)+TSpacing, Vect(715,9,-441),, 4+8,,,, None);
		break;
	}
}

defaultproperties
{
}
