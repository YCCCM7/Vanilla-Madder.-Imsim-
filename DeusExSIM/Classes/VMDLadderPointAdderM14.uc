//=============================================================================
// VMDLadderPointAdderM14.
//=============================================================================
class VMDLadderPointAdderM14 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "14_VANDENBERG_SUB":
			if (!bRevisionMapSet)
			{
				//#1: From water to module near elevator to subs. Recovery zone.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(1448,204,-664)+TSpacing, Vect(1448,204,-456)+TSpacing, Vect(1380,204,-464),, 4+8+64);
				
				//#2: Ladder from module near elevator to the weird bridge piece.
				TSpacing = Vect(0,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(2124,1509,-309)+TSpacing, Vect(2124,1509,-40)+TSpacing, Vect(2119,1608,-48),, 4);
				
				//#3: Ladder from bridge thing to F1 of labs.
				TSpacing = Vect(0,-4,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(2052,3028,-45)+TSpacing, Vect(2052,3028,404)+TSpacing, Vect(2052,2981,396),, 4+8+512+1024);
				
				//#4: Ladder from F1 of labs to F2 of labs.
				TSpacing = Vect(0,-4,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(2052,2981,396), Vect(2052,3028,404)+TSpacing, Vect(2052,3028,586)+TSpacing, Vect(2052,2976,577), 4+8+512+1024);
				
				//#5: Ladder from F2 labs to roof.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(1735,2829,580)+TSpacing, Vect(1735,2829,784)+TSpacing, Vect(1818,2834,776),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 9)));
			}
		break;
		case "14_OCEANLAB_LAB":
			if (!bRevisionMapSet)
			{
				//#1: From water region up to labs with greasels. Recovery area.
				TSpacing = Vect(-4,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(3026,56,-1781)+TSpacing, Vect(3026,56,-1488)+TSpacing, Vect(2947,56,-1496),, 4+8+64);
			}
		break;
		case "14_OCEANLAB_SILO":
			if (!bRevisionMapSet)
			{
				//#1: From ground level to watch tower.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-1389,-3401,1471)+TSpacing, Vect(-1389,-3400,2008)+TSpacing, Vect(-1389,-3331,2000),, 4+8);
				
				//Keep sniper guy up here, thanks.
				VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 0));
				if (VMBP != None)
				{
					VMBP.bCanClimbLadders = false;
				}
				
				//#2: From repair bot room to upper walkway.
				TSpacing = Vect(-4,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(667,-4240,1477)+TSpacing, Vect(667,-4240,1667)+TSpacing, Vect(605,-4240,1660),, 4+8);
				
				//#3: From silo up to chopper area.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-375,-6806,776), Vect(-459,-6806,825)+TSpacing, Vect(-459,-6806,1468)+TSpacing, Vect(-548,-6806,1482), 1+2+4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 12)));
			}
		break;
	}
}

defaultproperties
{
}
