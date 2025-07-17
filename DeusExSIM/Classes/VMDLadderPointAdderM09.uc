//=============================================================================
// VMDLadderPointAdderM09.
//=============================================================================
class VMDLadderPointAdderM09 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "09_NYC_DOCKYARD":
			if (!bRevisionMapSet)
			{
				//#1: Ladder to LAW area near robot cages.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(3898,3190,96)+TSpacing, Vect(3898,3190,336)+TSpacing, Vect(3964,3191,296),, 4+8);
			}
		break;
		case "09_NYC_SHIP":
			if (!bRevisionMapSet)
			{
				//#1: Rightmost ladder from water back up to docks. Recovery area.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(3565,-909,-709)+TSpacing, Vect(3565,-953,-653)+TSpacing, Vect(3565,-953,-424), Vect(3565,-1039,-444), 4+8+64);
				
				//#2: Middle ladder from water back up to docks. Recovery area.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(2686,-909,-709)+TSpacing, Vect(2686,-953,-653)+TSpacing, Vect(2686,-953,-424), Vect(2686,-1039,-444), 4+8+64);
				
				//#3: Leftmost ladder from water back up to docks. Recovery area.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-874,-909,-709)+TSpacing, Vect(-874,-953,-653)+TSpacing, Vect(-874,-953,-424), Vect(-874,-1039,-444), 4+8+64);
			}
		break;
		case "09_NYC_SHIPBELOW":
			if (!bRevisionMapSet)
			{
				//#1: Ladder towards the security room, requiring catwalk.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-233,301,-333)+TSpacing, Vect(-233,301,-181)+TSpacing, Vect(-308,301,-185),, 4+8);
				
				//#2: Ladder up to the security room at last.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-491,-604,-181)+TSpacing, Vect(-491,-604,0)+TSpacing, Vect(-491,-537,-16),, 4+8);
				
				//#3: Ladder up to the shocky cat walky thing.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-3034,1213,-432)+TSpacing, Vect(-2961,1241,-397)+TSpacing, Vect(-2961,1241,-200), Vect(-2961,1312,-209), 1+2+4+8);
				
				//#4: Ladder up to control room near copter.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-5088,1502,-464)+TSpacing, Vect(-5088,1502,-208)+TSpacing, Vect(-5088,1422,-208),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 38)));
			}
		break;
		case "09_NYC_GRAVEYARD":
			if (!bRevisionMapSet)
			{
				//#1: Ladder to/from dowd's below tunnel.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-124,-415,-173)+TSpacing, Vect(-111,-412,-61)+TSpacing, Vect(-57,-415,54)+TSpacing, Vect(-54,-499,48),, 4+8);
			}
		break;
	}
}

defaultproperties
{
}
