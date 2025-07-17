//=============================================================================
// VMDLadderPointAdderM21.
//=============================================================================
class VMDLadderPointAdderM21 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "21_TMGCOMPLEX":
			Spawn(class'PathNodeMobile',,, Vect(-1025,831,-577));
			Spawn(class'PathNodeMobile',,, Vect(-1221,807,-577));
			Spawn(class'PathNodeMobile',,, Vect(-1161,726,-721));
			Spawn(class'PathNodeMobile',,, Vect(-1388,713,-721));
			Spawn(class'PathNodeMobile',,, Vect(-1405,578,-721));
			Spawn(class'PathNodeMobile',,, Vect(-1454,385,-721));
			Spawn(class'PathNodeMobile',,, Vect(-928,785,-113));
			Spawn(class'PathNodeMobile',,, Vect(-705,776,-113));
			Spawn(class'PathNodeMobile',,, Vect(-679,430,-113));
			Spawn(class'PathNodeMobile',,, Vect(-284,576,-113));
			Spawn(class'PathNodeMobile',,, Vect(3,393,-113));
			Spawn(class'PathNodeMobile',,, Vect(-20,745,-113));
			Spawn(class'PathNodeMobile',,, Vect(-1289,702,-577));
			Spawn(class'PathNodeMobile',,, Vect(-1227,703,-577));
			
			bRebuildRequired = true;
			
			//Upper ladder near terries
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(-1010,766,-517)+TSpacing, Vect(-1010,766,-72)+TSpacing, Vect(-936,783,-113),, 4+8+256+512);
			
			//Lower ladder near terries
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(-1172,686,-687)+TSpacing, Vect(-1172,686,-497)+TSpacing, Vect(-1242,702,-577),, 4+8+256+512);
		break;
		case "21_OTEMACHIKU":
			Spawn(class'PathNodeMobile',,, Vect(3813,-2240,-497));
			Spawn(class'PathNodeMobile',,, Vect(4093,-2240,-497));
			Spawn(class'PathNodeMobile',,, Vect(4446,-2240,-497));
			Spawn(class'PathNodeMobile',,, Vect(4547,-2352,15));
			Spawn(class'PathNodeMobile',,, Vect(4554,-2749,15));
			Spawn(class'PathNodeMobile',,, Vect(4549,-3001,15));
			Spawn(class'PathNodeMobile',,, Vect(4186,-3011,15));
			Spawn(class'PathNodeMobile',,, Vect(3747,-3009,15));
			Spawn(class'PathNodeMobile',,, Vect(3332,-3008,15));
			Spawn(class'PathNodeMobile',,, Vect(2982,-3010,15));
			Spawn(class'PathNodeMobile',,, Vect(2727,-3004,15));
			Spawn(class'PathNodeMobile',,, Vect(2340,-2998,15));
			Spawn(class'PathNodeMobile',,, Vect(2331,-2870,15));
			Spawn(class'PathNodeMobile',,, Vect(2726,-2884,15));
			Spawn(class'PathNodeMobile',,, Vect(2148,-3004,15));
			Spawn(class'PathNodeMobile',,, Vect(2156,-2903,15));
			Spawn(class'PathNodeMobile',,, Vect(1881,-3018,15));
			Spawn(class'PathNodeMobile',,, Vect(1866,-2900,15));
			
			bRebuildRequired = true;
			
			//Ladder to upper rooftop with loot.
			TSpacing = Vect(-8,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(4594,-2241,-425)+TSpacing, Vect(4594,-2241,39)+TSpacing, Vect(4548,-2383,15),, 4+8+256+512);
		break;
		case "21_KABUKICHO":
			bRebuildRequired = true;
		break;
	}
}

defaultproperties
{
}
