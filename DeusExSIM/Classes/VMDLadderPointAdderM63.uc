//=============================================================================
// VMDLadderPointAdderM63.
//=============================================================================
class VMDLadderPointAdderM63 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "63_NYC_QUEENSSTREETS":
			//Pathing at top of Ladder #1.
			Spawn(class'PathNodeMobile',,, Vect(1000,35,271));
			Spawn(class'PathNodeMobile',,, Vect(732,39,271));
			Spawn(class'PathNodeMobile',,, Vect(990,-246,271));
			Spawn(class'PathNodeMobile',,, Vect(693,-251,271));
			Spawn(class'PathNodeMobile',,, Vect(387,-240,271));
			Spawn(class'PathNodeMobile',,, Vect(194,-194,271));
			Spawn(class'PathNodeMobile',,, Vect(195,169,271));
			Spawn(class'PathNodeMobile',,, Vect(179,418,271));
			
			//Pathing at top of ladder #2.
			Spawn(class'PathNodeMobile',,, Vect(1465,3801,399));
			Spawn(class'PathNodeMobile',,, Vect(1717,3811,399));
			Spawn(class'PathNodeMobile',,, Vect(1464,3681,399));
			Spawn(class'PathNodeMobile',,, Vect(1413,3462,399));
			Spawn(class'PathNodeMobile',,, Vect(1397,3195,399));
			Spawn(class'PathNodeMobile',,, Vect(1325,3679,462));
			Spawn(class'PathNodeMobile',,, Vect(1152,3687,527));
			Spawn(class'PathNodeMobile',,, Vect(1152,3873,527));
			Spawn(class'PathNodeMobile',,, Vect(983,3879,527));
			
			//Pathing at top of Ladder #4.
			Spawn(class'PathNodeMobile',,, Vect(321,-2141,431));
			Spawn(class'PathNodeMobile',,, Vect(571,-2161,431));
			Spawn(class'PathNodeMobile',,, Vect(572,-2316,431));
			Spawn(class'PathNodeMobile',,, Vect(359,-2276,431));
			
			bRebuildRequired = true;
			
			//Ladder on weird quarter of octagon.
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(915,207,69)+TSpacing, Vect(915,207,303)+TSpacing, Vect(915,140,303),, 4+8,,,, None);
			
			//Ladder near window thing, behind gate.
			TSpacing = Vect(0,16,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(1530,3855,63)+TSpacing, Vect(1530,3855,432)+TSpacing, Vect(1530,3810,432),, 4+8,,,, None);
			
			//Ladder near crates in under area.
			TSpacing = Vect(0,-8,0);
			AddLadderGroup(Vect(0, 1, 0), Vect(255,-3375,-273)+TSpacing, Vect(255,-3375,-72)+TSpacing, Vect(255,-3311,-81),, 4+8,,,, None);
			
			//Ladder inside of thug compound.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(241,-2320,79)+TSpacing, Vect(241,-2320,463)+TSpacing, Vect(299,-2320,463),, 4+8,,,, None);
		break;
	}
}

defaultproperties
{
}
