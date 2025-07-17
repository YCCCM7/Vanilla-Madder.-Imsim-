//=============================================================================
// VMDLadderPointAdderM15.
//=============================================================================
class VMDLadderPointAdderM15 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "15_AREA51_BUNKER":
			if (!bRevisionMapSet)
			{
				//#1: Ladder from bottom of tower up to ground level.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-1232,29,-452)+TSpacing, Vect(-1232,29,-168)+TSpacing, Vect(-1232,125,-176),, 4+8);
				
				//#2: Ladder from ground level of tower up to F2.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-1380,29,-168)+TSpacing, Vect(-1380,29,111)+TSpacing, Vect(-1391,111,103),, 4+8);
				
				//#3: Ladder from F2 of tower to F3.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-1232,29,106)+TSpacing, Vect(-1232,29,390)+TSpacing, Vect(-1308,30,425),, 4+8);
				
				//Keep sniper guy up here, thanks.
				VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 0));
				if (VMBP != None)
				{
					VMBP.bCanClimbLadders = false;
				}
				
				//#4: Barracks ground level to roof.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(978,2885,-461)+TSpacing, Vect(978,2885,-229)+TSpacing, Vect(935,2879,-237),, 4+8);
				
				//#5: Barracks to basement.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(982,2824,-744)+TSpacing, Vect(982,2824,-456)+TSpacing, Vect(1048,2791,-461),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 26)));
				
				//#6: Not truly a ladder, but these stair things that are collapsed that the player can climb. Sure.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(1311,-1654,-472)+TSpacing, Vect(1313,-1729,-288)+TSpacing, Vect(1313,-1798,-288),, 4+8);
				
				//#7: Ladder #1 on elevator power area going to the top with spiderbots.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(2881,3632,-909)+TSpacing, Vect(2881,3632,-728)+TSpacing, Vect(2881,3577,-736),, 4+8+256+512);
				
				//#8: Ladder #2 on elevator power area going to the top with spiderbots.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(4542,3616,-909)+TSpacing, Vect(4542,3616,-728)+TSpacing, Vect(4542,3561,-736),, 4+8+256+512);
			}
		break;
		case "15_AREA51_FINAL":
			if (!bRevisionMapSet)
			{
				//#1: Ladder up to catwalk at very start.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-5560,-4640,-1389)+TSpacing, Vect(-5560,-4640,-1032)+TSpacing, Vect(-5492,-4640,-1040),, 4+8);
				
				//#2: Ladder to and from sniper's nest.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-5044,-2838,-841)+TSpacing, Vect(-5044,-2838,-707)+TSpacing, Vect(-4984,-2838,-715),, 4+8);
				
				//Keep sniper guy up here, thanks.
				VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 8));
				if (VMBP != None)
				{
					VMBP.bCanClimbLadders = false;
				}
				
				//#3: Ladder up to dead maintenance guy on roof.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-4865,-3659,-712)+TSpacing, Vect(-4865,-3659,-544)+TSpacing, Vect(-4936,-3659,-560),, 4+8);
				
				//#4: Ladder from grays up to random PC office area. Weird.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-5308,-1740,-1179)+TSpacing, Vect(-5308,-1740,-837)+TSpacing, Vect(-5308,-1646,-875),, 4+8+256+512);
			}
		break;
		case "15_AREA51_PAGE":
			if (!bRevisionMapSet)
			{
				//#1: Ladder at start of tong section up to catwalk.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(7318,-8764,-5968)+TSpacing, Vect(7318,-8764,-5662)+TSpacing, Vect(7318,-8703,-5670),, 4+8);
				
				//#2: Ladder towards back of ton section up to hallway towards catwalk.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(7806,-9950,-6160)+TSpacing, Vect(7806,-9950,-5642)+TSpacing, Vect(7891,-9949,-5650),, 4+8);
			}
		break;
	}
}

defaultproperties
{
}
