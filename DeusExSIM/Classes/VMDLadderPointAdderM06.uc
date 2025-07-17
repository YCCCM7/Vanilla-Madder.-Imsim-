//=============================================================================
// VMDLadderPointAdderM06.
//=============================================================================
class VMDLadderPointAdderM06 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "06_HONGKONG_HELIBASE":
			if (!bRevisionMapSet)
			{
				//#1: Ladder from ground to roof.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(590,-832,440)+TSpacing, Vect(590,-832,840)+TSpacing, Vect(676,-832,816),, 4+8);
			}
		break;
		case "06_HONGKONG_WANCHAI_MARKET":
			if (!bRevisionMapSet)
			{
				//#1: Ladder up/down from police watch area
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-721,-624,48)+TSpacing, Vect(-721,-624,183)+TSpacing, Vect(-721,-684,176),, 4+8);
				
				//#2: Ladder up/down from police armory
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-200,-719,-109)+TSpacing, Vect(-200,-719,56)+TSpacing, Vect(-207,-640,48),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 8)));
			}
		break;
		case "06_HONGKONG_WANCHAI_CANAL":
			if (!bRevisionMapSet)
			{
				//#1: Water to china hand freezer, recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(-703,1705,-528), Vect(-703,1803,-432),,, 1+2+4+8+64,, 1.5);
				
				//#2: Water to china hand side door, recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(-2212,2672,-531), Vect(-2149,2673,-432),,, 1+2+4+8+64,, 2.0);
				
				//#3: Water to path near boat guy, but no to him. Recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(-1939,1184,-532), Vect(-1867,1186,-409),,, 1+2+4+8+64,, 1.5);
				
				//#4: Water to stairway near dead worker location. Recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(-2126,-618,-537), Vect(-2197,-618,-464),,, 1+2+4+8+64,, 1.5);
				
				//#5: Water to last area nearest boat guy's place. Recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(445,1264,-530), Vect(445,1194,-448),,, 1+2+4+8+64,, 1.75);
				
				//#6: Water to boat guy's place, finally. Recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(1633,1299,-533), Vect(1633,1369,-448),,, 1+2+4+8+64,, 1.75);
				
				//#7: Water to giant ship area. Recovery area.
				AddLadderGroup(Vect(0, 0, 0), Vect(2655,1749,-526), Vect(2655,1827,-448),,, 1+2+4+8+64,, 2.0);
				
				//#8: Ladder from lower area without door to main walk area.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-224,904,-333)+TSpacing, Vect(-224,904,52)+TSpacing, Vect(-299,913,48),, 4+8);
			}
		break;
	}
}

defaultproperties
{
}
