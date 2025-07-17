//=============================================================================
// VMDLadderPointAdderM67.
//=============================================================================
class VMDLadderPointAdderM67 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "67_DYNAMENE_EXTERIOR":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder to upper misc area.
			TSpacing = Vect(0,12,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(-719,-3492,57)+TSpacing, Vect(-719,-3492,399)+TSpacing, Vect(-717,-3557,399),, 4+8,,,, None);
			
			//Ladder 1 of 3 at start of missile silo.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-292,1027,311)+TSpacing, Vect(-292,1027,687)+TSpacing, Vect(-139,1027,687),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 5)));
			
			//Ladder 2 of 3 at start of missile silo.
			TSpacing = Vect(-8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(-92,1025,-71)+TSpacing, Vect(-92,1025,359)+TSpacing, Vect(-220,1029,303),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 18)));
			
			//Ladder 3 of 3 at start of missile silo.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-305,1024,-463)+TSpacing, Vect(-305,1024,-81)+TSpacing, Vect(-162,1029,-81),, 4+8,,,, None);
			
			//Ladder near the main 3 ladders, but not in-line.
			TSpacing = Vect(0,-8,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(116,1233,-444)+TSpacing, Vect(116,1233,-249)+TSpacing, Vect(116,1135,-249),, 4+8,,,, None);
			
			//Ladder into massive lift thingie.
			TSpacing = Vect(-8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(977,3265,-696)+TSpacing, Vect(977,3266,-465)+TSpacing, Vect(1036,3266,-465),, 4+8,,,, None);
			
			//Ladder that's fuck off tall also near the big 3.
			TSpacing = Vect(4,-4,0);
			AddLadderGroup(Vect(0.5, -0.5, 0), Vect(-422,740,-1088)+TSpacing, Vect(-422,740,-64)+TSpacing, Vect(-492,820,-64),, 4+8+256+512,,,, None);
		break;
		case "67_DYNAMENE_INNERSECTION":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder near vat of chemical shit.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-1318,-3933,-110)+TSpacing, Vect(-1318,-3933,212)+TSpacing, Vect(-1290,-3842,175),, 4+8,,,, None);
			
			//Ladder to PC at bottom of thing.
			TSpacing = Vect(16,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(2689,-4976,-1121)+TSpacing, Vect(2689,-4976,159)+TSpacing, Vect(2614,-4976,159),, 4+8,,,, None);
			
			//Ladder into giant chute thing with hazard stripes.
			TSpacing = Vect(0,-12,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(130,-8664,326)+TSpacing, Vect(130,-8664,623)+TSpacing, Vect(130,-8591,623),, 4+8,,,, None);
			
			//Ladder inside of said giant stripey chute.
			TSpacing = Vect(0,-8,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(130,-8481,-672)+TSpacing, Vect(130,-8481,623)+TSpacing, Vect(130,-8591,623),, 4+8,,,, None);
			
			//Upper ladder of two in little silo thing.
			TSpacing = Vect(16,0,0);
			AddLadderGroup(Vect(-8, 0, 0), Vect(-836,-9376,-1087)+TSpacing, Vect(-836,-9376,-689)+TSpacing, Vect(-706,-9376,-689),, 4+8,,,, None);
			
			//Lower ladder of two in little silo thing.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(8, 0, 0), Vect(-636,-9374,-1432)+TSpacing, Vect(-636,-9374,-1073)+TSpacing, Vect(-757,-9374,-1073),, 4+8,,,, None);
			
			//Ladder near the hazard stripe chute, off to the side, with the lights.
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(498,-8062,-498)+TSpacing, Vect(498,-8062,175)+TSpacing, Vect(576,-8039,175),, 4+8,,,, None);
		break;
		case "67_DYNAMENE_MISSILEUNIT":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Ladder to big missile launch unit room.
			TSpacing = Vect(0,16,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(31,768,-2944)+TSpacing, Vect(31,768,-1665)+TSpacing, Vect(31,727,-1665),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 5)));
			
			//Ladder on the left coming in, towards vat things.
			TSpacing = Vect(-12,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(908,-1160,-1666)+TSpacing, Vect(908,-1160,-1409)+TSpacing, Vect(960,-1160,-1409),, 4+8,,,, None);
			
			//Ladder on the right coming in, towards vat things.
			TSpacing = Vect(12,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-844,-1158,-1682)+TSpacing, Vect(-844,-1158,-1409)+TSpacing, Vect(-892,-1158,-1409),, 4+8,,,, None);
		break;
		case "67_DYNAMENE_OUTERSECTION":
			//Pathing 
			//Spawn(class'PathNodeMobile',,, Vect(,,));
			
			//bRebuildRequired = true;
			
			//Upper ladder of western silo thing.
			TSpacing = Vect(16,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(892,-3054,104)+TSpacing, Vect(892,-3054,479)+TSpacing, Vect(1024,-3054,479),, 4+8,,,, None);
			
			//Upper ladder of eastern silo thing.
			TSpacing = Vect(16,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-372,2434,102)+TSpacing, Vect(-372,2434,479)+TSpacing, Vect(-240,2434,479),, 4+8,,,, None);
			
			//Normal ass ladder near eastern silo.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(-760,1982,115)+TSpacing, Vect(-760,1982,479)+TSpacing, Vect(-647,1982,479),, 4+8,,,, None);
			
			//Big ladder #1, the one with a security camera.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(-2113,-280,-1234)+TSpacing, Vect(-2113,-280,-561)+TSpacing, Vect(-2149,-384,-552),, 4+8,,,, None);
			
			//Big ladder #2, the one with the big door.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(-1281,-2110,-1194)+TSpacing, Vect(-1281,-2110,-137)+TSpacing, Vect(-1231,-2110,-137),, 4+8,,,, None);
			
			//Big ladder #3, bottom to middle.
			TSpacing = Vect(0,-16,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(-1328,-753,-546)+TSpacing, Vect(-1328,-753,47)+TSpacing, Vect(-1223,-790,63),, 4+8,,,, None);
			
			//Big ladder #3, middle to top.
			TSpacing = Vect(0,-16,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(-1223,-790,63), Vect(-1328,-753,47)+TSpacing, Vect(-1328,-753,479)+TSpacing, Vect(-1328,-682,479), 1+2+4+8,,,, None);
	}
}

defaultproperties
{
}
