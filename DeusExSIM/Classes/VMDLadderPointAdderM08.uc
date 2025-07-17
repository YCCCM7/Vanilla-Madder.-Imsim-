//=============================================================================
// VMDLadderPointAdderM08.
//=============================================================================
class VMDLadderPointAdderM08 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "08_NYC_UNDERGROUND":
			if (!bRevisionMapSet)
			{
				//#1: Ladder up to main room from the laser area.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(627,-342,-557)+TSpacing, Vect(627,-342,-328)+TSpacing, Vect(627,-204,-336),, 4+8);
				
				//#2: ONE WAY ladder from water up to the side with lasers.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(550,19,-1296)+TSpacing, Vect(550,19,-328)+TSpacing, Vect(642,19,-336),, 4+8+64);
				
				//#3: ONE WAY ladder from water up to the side with schick.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-678,-261,-1296)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-668,-190,-784),, 4+8+64);
				
				//#4: Ladder up to top from schick area.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-668,-190,-784)+TSpacing, Vect(-678,-261,-777)+TSpacing, Vect(-678,-261,-328),Vect(-749,-260,-336), 1+2+4+8);
			}
		break;
	}
}

defaultproperties
{
}
