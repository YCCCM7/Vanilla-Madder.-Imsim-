//=============================================================================
// VMDLadderPointAdderM64.
//=============================================================================
class VMDLadderPointAdderM64 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		//NOTE: Stafford is a baren landscape for path nodes. We're not going to add more because most the level is useless for pathing already.
		case "64_WOODFIBRE_STAFFORD":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder at very top.
			TSpacing = Vect(0,-16,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(8,357,50)+TSpacing, Vect(8,357,286)+TSpacing, Vect(8,413,286),, 4+8,,,, None);
			
			//Ladder in middle
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(1061,-240,-2718)+TSpacing, Vect(1061,-240,-2483)+TSpacing, Vect(1098,-240,-2483),, 4+8,,,, None);
		break;
		case "64_WOODFIBRE_TUNNELS":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder near entrance.
			TSpacing = Vect(16,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(3179,128,66)+TSpacing, Vect(3179,128,269)+TSpacing, Vect(3140,128,269),, 4+8,,,, None);
			
			//Obscure one off to the side.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(1405,-862,-196)+TSpacing, Vect(1405,-862,5)+TSpacing, Vect(1472,-862,5),, 4+8,,,, None);
		break;
	}
}

defaultproperties
{
}
