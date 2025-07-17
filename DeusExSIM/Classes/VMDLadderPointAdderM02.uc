//=============================================================================
// VMDLadderPointAdderM02.
//=============================================================================
class VMDLadderPointAdderM02 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "02_NYC_WAREHOUSE":
			if (!bRevisionMapSet)
			{
				//#01: Ladder from elevator start up to the double 3006 and ballistic guy.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-573,2945,1584)+TSpacing, Vect(-573,2945,1824)+TSpacing, Vect(-573,2852,1776),, 4+8);
				
				//#02: Ladder from double 3006 and ballistic guy to the roof above him.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-1346,2211,1768)+TSpacing, Vect(-1376,2211,1822)+TSpacing, Vect(-1376,2211,2057)+TSpacing, Vect(-1462,2211,2008), 1+4+8);
				
				//#03: Ladder from #2's rooftop, going down to abandoned building with glass window.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-1724,1777,1795)+(TSpacing*0.2), Vect(-1724,1777,2064)+TSpacing, Vect(-1724,1876,2012),, 4+8);
				
				//MADDERS, 8/10/24: These are too fringe to be useful, and the long space of #4 makes going down the ladder clumsy.
				//Offsetting it to de-clumsy it ruins the ability to climb up. The annotated values are the best middleground, but it still sucks and is niche.
				//#04: Ladder from #2's rooftop, going down to the alleyway with the LAM.
				/*TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-2077,2239,355)+(TSpacing*0.0), Vect(-2077,2239,2064)+(TSpacing*0.3), Vect(-2002,2237,2008),, 4+8);
				
				//#05: Ladder from alleyway up to catwalk of #4.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-2178,2082,48)+TSpacing, Vect(-2178,2094,53)+TSpacing, Vect(-2178,2094,352)+TSpacing, Vect(-2178,2160,352), 1+2+4+8);
				*/
				
				//#06: Ladder from area near the jumpable window up to the sniper outlook. This one's the prettier one.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-1627,680,1187)+TSpacing, Vect(-1627,680,1504)+TSpacing, Vect(-1627,766,1456),, 4+8);
				
				//#07: Ladder from area near the jumpable window up to the sniper outlook. This one's the ugly one with the billboard.
				TSpacing = Vect(0,16,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-1245,1127,1184)+TSpacing, Vect(-1245,1092,1201)+TSpacing, Vect(-1245,1040,1480), Vect(-1336,1040,1456), 1+2+4+8);
				
				//#08: Ladder from #6 up to this weird little square that's just vibin'.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-1835,1120,1459)+TSpacing, Vect(-1835,1120,1664)+TSpacing, Vect(-1835,1192,1616),, 4+8);
				
				//#09: Ladder from isolated dude down to chimneys.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-7,529,784)+TSpacing, Vect(-28,529,831)+TSpacing, Vect(-28,529,1176)+TSpacing, Vect(-109,529,1104), 1+2+4+8,,, 1.3);
				
				//#10: Ladder from chimneys to the collapsed catwalk adjacent area.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(349,532,624)+TSpacing, Vect(279,532,693)+TSpacing, Vect(279,532,856)+TSpacing, Vect(159,532,784), 1+2+4+8,,, 1.3);
				
				//#11: Ladder from catwalk adjacent area to the little squat at bottom.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(632,532,464)+TSpacing, Vect(615,532,498)+TSpacing, Vect(615,532,688)+TSpacing, Vect(532,532,624), 1+2+4+8,,, 1.3);
				
				//#12: Ladder from concrete top of garage to the dishes.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(752,-97,480)+TSpacing, Vect(752,-136,491)+TSpacing, Vect(752,-135,1096)+TSpacing, Vect(752,-254,1024), 1+2+4+8);
				
				//#13: Ladder from dishes to top of computer room.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(1285,-648,752)+TSpacing, Vect(1240,-648,770)+TSpacing, Vect(1240,-648,1096)+TSpacing, Vect(1113,-648,1024), 1+2+4+8);
				
				//#14: Ladder from concrete top of garage to the dishes.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(1452,-1229,256)+TSpacing, Vect(1452,-1177,280)+TSpacing, Vect(1452,-1177,760)+TSpacing, Vect(1454,-1114,752), 1+2+4+8);
			}
		break;
		case "02_NYC_UNDERGROUND":
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
