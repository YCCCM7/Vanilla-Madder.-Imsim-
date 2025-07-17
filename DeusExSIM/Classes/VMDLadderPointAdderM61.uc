//=============================================================================
// VMDLadderPointAdderM61.
//=============================================================================
class VMDLadderPointAdderM61 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "61_HONGKONG_FACTORY":
			//Pathing for extra helipad area. Only sometimes accessible.
			Spawn(class'PathNodeMobile',,, Vect(-2209,3637,-353));
			Spawn(class'PathNodeMobile',,, Vect(-2216,3880,-353));
			Spawn(class'PathNodeMobile',,, Vect(-2206,3834,15));
			Spawn(class'PathNodeMobile',,, Vect(-2065,3839,15));
			Spawn(class'PathNodeMobile',,, Vect(-2048,4030,15));
			Spawn(class'PathNodeMobile',,, Vect(-2051,4196,15));
			Spawn(class'PathNodeMobile',,, Vect(-2245,4170,15));
			Spawn(class'PathNodeMobile',,, Vect(-1764,4212,15));
			Spawn(class'PathNodeMobile',,, Vect(-1485,4204,15));
			Spawn(class'PathNodeMobile',,, Vect(-1189,4193,15));
			Spawn(class'PathNodeMobile',,, Vect(-827,4200,15));
			Spawn(class'PathNodeMobile',,, Vect(-529,4193,15));
			Spawn(class'PathNodeMobile',,, Vect(-176,4184,15));
			Spawn(class'PathNodeMobile',,, Vect(-960,4228,15));
			Spawn(class'PathNodeMobile',,, Vect(-961,4413,31));
			Spawn(class'PathNodeMobile',,, Vect(-962,4667,31));
			
			bRebuildRequired = true;
			
			//And the ladder itself. NOTE: This one super sucks and has issues with going up it, due to inconsistency.
			//Disable bIsDoor to help it along, but otherwise leave it untouched.
			TSpacing = Vect(0,0,0);
			
			A = FindActorBySeed(class'DeusExMover', 7);
			if (A != None)
			{
				DeusExMover(A).bIsDoor = false;
			}
			AddLadderGroup(Vect(0, 1, 0), Vect(-2210,3969,-292)+TSpacing, Vect(-2210,3969,56)+TSpacing, Vect(-2210,3858,15),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 7)));
		break;
		case "61_HONGKONG_FORICHI":
			//Pathing to better find ladder to helipad.
			Spawn(class'PathNodeMobile',,, Vect(5504,-2860,167));
			Spawn(class'PathNodeMobile',,, Vect(5504,-2921,191));
			Spawn(class'PathNodeMobile',,, Vect(5504,-3055,191));
			Spawn(class'PathNodeMobile',,, Vect(5499,-2980,479));
			
			bRebuildRequired = true;
			
			//Helipad ladder itself.
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(5505,-3089,244)+TSpacing, Vect(5505,-3089,518)+TSpacing, Vect(5505,-3022,479),, 4+8,,,, None);
		break;
		case "61_HONGKONG_STREETS":
			//Pathing to ladder janky staircase ladder.
			Spawn(class'PathNodeMobile',,, Vect(-725,-585,-833));
			Spawn(class'PathNodeMobile',,, Vect(-627,-579,-813));
			Spawn(class'PathNodeMobile',,, Vect(-494,-575,-817));
			
			//Pathing on street leading towards ladder 2, which is in a set of 2.
			Spawn(class'PathNodeMobile',,, Vect(68,518,-473));
			Spawn(class'PathNodeMobile',,, Vect(49,737,-473));
			Spawn(class'PathNodeMobile',,, Vect(34,307,-473));
			Spawn(class'PathNodeMobile',,, Vect(55,896,-473));
			Spawn(class'PathNodeMobile',,, Vect(54,1163,-473));
			Spawn(class'PathNodeMobile',,, Vect(52,1414,-473));
			Spawn(class'PathNodeMobile',,, Vect(57,1794,-473));
			Spawn(class'PathNodeMobile',,, Vect(167,1798,-473));
			Spawn(class'PathNodeMobile',,, Vect(254,1802,-473));
			Spawn(class'PathNodeMobile',,, Vect(510,1797,-473));
			Spawn(class'PathNodeMobile',,, Vect(668,1793,-473));
			Spawn(class'PathNodeMobile',,, Vect(675,1572,-473));
			Spawn(class'PathNodeMobile',,, Vect(415,1567,-289));
			Spawn(class'PathNodeMobile',,, Vect(520,1567,-366));
			
			//Proper pathing to ladder 2.
			Spawn(class'PathNodeMobile',,, Vect(480,1580,15));
			Spawn(class'PathNodeMobile',,, Vect(472,1642,15));
			Spawn(class'PathNodeMobile',,, Vect(476,1499,15));
			Spawn(class'PathNodeMobile',,, Vect(414,1570,-1));
			
			//Pathing to ladder 3.
			Spawn(class'PathNodeMobile',,, Vect(894,1558,23));
			Spawn(class'PathNodeMobile',,, Vect(898,1782,23));
			Spawn(class'PathNodeMobile',,, Vect(1122,1783,23));
			Spawn(class'PathNodeMobile',,, Vect(1357,1775,23));
			
			//Pathing to not have our dick on our hands after ladder 3.
			Spawn(class'PathNodeMobile',,, Vect(1512,1774,783));
			Spawn(class'PathNodeMobile',,, Vect(1394,1634,783));
			Spawn(class'PathNodeMobile',,, Vect(1511,1607,783));
			Spawn(class'PathNodeMobile',,, Vect(1630,1516,783));
			Spawn(class'PathNodeMobile',,, Vect(1491,1934,783));
			Spawn(class'PathNodeMobile',,, Vect(1381,1926,783));
			Spawn(class'PathNodeMobile',,, Vect(1774,1503,783));
			Spawn(class'PathNodeMobile',,, Vect(1802,1389,783));
			
			bRebuildRequired = true;
			
			//From bottom of janky, fake-o staircase to upper area.
			TSpacing = Vect(0,-8,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(-720,-463,-780)+TSpacing, Vect(-720,-463,-506)+TSpacing, Vect(-720,-568,-545),, 4+8,,,, None);
			
			//Ladder 2, the only usable in a set of 2.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(351,1566,-237)+TSpacing, Vect(351,1566,38)+TSpacing, Vect(415,1566,-1),, 4+8,,,, None);
			
			//Ladder 3, the trellis looking mofo.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(1446,1772,75)+TSpacing, Vect(1446,1772,815)+TSpacing, Vect(1520,1772,815),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 13)));
		break;
	}
}

defaultproperties
{
}
