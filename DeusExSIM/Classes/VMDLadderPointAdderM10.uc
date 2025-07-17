//=============================================================================
// VMDLadderPointAdderM10.
//=============================================================================
class VMDLadderPointAdderM10 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "10_PARIS_CATACOMBS":
			if (!bRevisionMapSet)
			{
				//#1: Ladder from greasel area to the street. First is most likely to be relevant.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(0,-63,-445)+TSpacing, Vect(0,-63,-216)+TSpacing, Vect(-22,32,-224),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 3)));
				
				//#2: Ladder from greasel room up to repair bot and radiation.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-33,3895,-461)+TSpacing, Vect(-33,3895,-8)+TSpacing, Vect(-113,3870,-16),, 4+8);
			}
		break;
		case "10_PARIS_CATACOMBS_TUNNELS":
			if (!bRevisionMapSet)
			{
				//#1: Ladder to electricity and repair bot.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-1201,-856,-381)+TSpacing, Vect(-1201,856,124)+TSpacing, Vect(-1121,856,112),, 4+8);
				
				//#2: Ladder from hela's area to upper section. Misc.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(829,-2495,-285)+TSpacing, Vect(829,-2495,-24)+TSpacing, Vect(893,-2495,-32),, 4+8);
			}
		break;
	}
}

defaultproperties
{
}
