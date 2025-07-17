//=============================================================================
// VMDLadderPointAdderM62.
//=============================================================================
class VMDLadderPointAdderM62 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "62_BERLIN_AIRBORNELAB":
			//Pathing to around ladder between decks
			Spawn(class'PathNodeMobile',,, Vect(-1988,-34,239));
			Spawn(class'PathNodeMobile',,, Vect(-1987,-78,-113));
			Spawn(class'PathNodeMobile',,, Vect(-2088,155,-113));
			Spawn(class'PathNodeMobile',,, Vect(-1913,143,-113));
			
			bRebuildRequired = true;
			
			//Ladder between upper and lower decks
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(-1988,-125,-92)+TSpacing, Vect(-1988,-125,305)+TSpacing, Vect(-1988,-9,239),, 4+8,,,, None);
		break;
		case "62_BERLIN_STREETS":
			//Pathing at base of our target ladder
			Spawn(class'PathNodeMobile',,, Vect(1990,2112,-417));
			Spawn(class'PathNodeMobile',,, Vect(2119,2108,-417));
			
			//Pathing at top of ladders, and around the general area. This place is alarmingly understocked in AI pathing.
			Spawn(class'PathNodeMobile',,, Vect(455,2349,15));
			Spawn(class'PathNodeMobile',,, Vect(626,2379,-1));
			Spawn(class'PathNodeMobile',,, Vect(618,1844,-1));
			Spawn(class'PathNodeMobile',,, Vect(454,1876,15));
			Spawn(class'PathNodeMobile',,, Vect(252,1907,-1));
			Spawn(class'PathNodeMobile',,, Vect(654,2619,-1));
			Spawn(class'PathNodeMobile',,, Vect(1109,2668,-1));
			Spawn(class'PathNodeMobile',,, Vect(1558,2658,-1));
			Spawn(class'PathNodeMobile',,, Vect(1903,2629,-1));
			Spawn(class'PathNodeMobile',,, Vect(1931,2171,-1));
			Spawn(class'PathNodeMobile',,, Vect(2132,2221,15));
			Spawn(class'PathNodeMobile',,, Vect(2135,1992,15));
			Spawn(class'PathNodeMobile',,, Vect(2261,2089,15));
			Spawn(class'PathNodeMobile',,, Vect(1939,1813,-1));
			Spawn(class'PathNodeMobile',,, Vect(1936,1553,-1));
			Spawn(class'PathNodeMobile',,, Vect(1595,1535,-1));
			Spawn(class'PathNodeMobile',,, Vect(1160,1545,-1));
			Spawn(class'PathNodeMobile',,, Vect(830,1563,-1));
			Spawn(class'PathNodeMobile',,, Vect(652,1545,-1));
			
			//More pathing nearby that's just completely unfilled. Good god.
			Spawn(class'PathNodeMobile',,, Vect(-1,3341,15));
			Spawn(class'PathNodeMobile',,, Vect(1,3444,-17));
			Spawn(class'PathNodeMobile',,, Vect(1,3705,-153));
			Spawn(class'PathNodeMobile',,, Vect(-5,4054,-354));
			Spawn(class'PathNodeMobile',,, Vect(-9,4280,-369));
			Spawn(class'PathNodeMobile',,, Vect(185,4415,-369));
			Spawn(class'PathNodeMobile',,, Vect(187,4856,-369));
			Spawn(class'PathNodeMobile',,, Vect(181,5185,-369));
			Spawn(class'PathNodeMobile',,, Vect(-173,4449,-369));
			Spawn(class'PathNodeMobile',,, Vect(-220,4646,-369));
			Spawn(class'PathNodeMobile',,, Vect(-354,4762,-369));
			Spawn(class'PathNodeMobile',,, Vect(-634,4780,-369));
			Spawn(class'PathNodeMobile',,, Vect(-807,5011,-369));
			
			bRebuildRequired = true;
			
			//Ladder from and to sewers with special guy.
			TSpacing = Vect(-16,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(2156,2110,-355)+TSpacing, Vect(2156,2110,67)+TSpacing, Vect(2220,2110,67),, 4+8,,,, DeusExMover(FindActorBySeed(class'DeusExMover', 68)));

		break;
	}
}

defaultproperties
{
}
