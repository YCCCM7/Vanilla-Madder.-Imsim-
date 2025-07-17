//=============================================================================
// VMDLadderPointAdderM65.
//=============================================================================
class VMDLadderPointAdderM65 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		//NOTE: Stafford is a baren landscape for path nodes. We're not going to add more because most the level is useless for pathing already.
		case "65_WOODFIBRE_BEACHFRONT":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder at very top.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(-1649,-2874,-292)+TSpacing, Vect(-1649,-2874,-59)+TSpacing, Vect(-1580,-2874,-59),, 4+8,,,, None);
		break;
	}
}

defaultproperties
{
}
