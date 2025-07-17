//=============================================================================
// VMDLadderPointAdderM60.
//=============================================================================
class VMDLadderPointAdderM60 extends VMDLadderPointAdder;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "60_HONGKONG_STREETS":
			//Rear ladder in lot pathing
			Spawn(class'PathNodeMobile',,, Vect(4054,3249,759));
			Spawn(class'PathNodeMobile',,, Vect(4288,3256,759));
			Spawn(class'PathNodeMobile',,, Vect(4471,3244,759));
			Spawn(class'PathNodeMobile',,, Vect(4798,3254,647));
			Spawn(class'PathNodeMobile',,, Vect(5117,3227,532));
			Spawn(class'PathNodeMobile',,, Vect(5481,3098,527));
			Spawn(class'PathNodeMobile',,, Vect(5574,2709,527));
			Spawn(class'PathNodeMobile',,, Vect(5492,2865,527));
			Spawn(class'PathNodeMobile',,, Vect(5571,2464,527));
			Spawn(class'PathNodeMobile',,, Vect(5573,2317,527));
			Spawn(class'PathNodeMobile',,, Vect(5284,2318,527));
			Spawn(class'PathNodeMobile',,, Vect(5055,2314,527));
			Spawn(class'PathNodeMobile',,, Vect(4029,2989,767));
			Spawn(class'PathNodeMobile',,, Vect(4432,2992,767));
			Spawn(class'PathNodeMobile',,, Vect(4906,2995,767));
			Spawn(class'PathNodeMobile',,, Vect(4938,2625,767));
			Spawn(class'PathNodeMobile',,, Vect(4934,2307,767));
			Spawn(class'PathNodeMobile',,, Vect(4513,2973,767));
			Spawn(class'PathNodeMobile',,, Vect(4536,2993,767));
			Spawn(class'PathNodeMobile',,, Vect(4533,2853,767));
			
			//Upper trellis area pathing
			Spawn(class'PathNodeMobile',,, Vect(3747,2034,1503));
			Spawn(class'PathNodeMobile',,, Vect(3625,2151,1503));
			Spawn(class'PathNodeMobile',,, Vect(3428,2122,1507));
			Spawn(class'PathNodeMobile',,, Vect(3276,2069,1507));
			Spawn(class'PathNodeMobile',,, Vect(3659,2376,1503));
			Spawn(class'PathNodeMobile',,, Vect(3489,2409,1503));
			Spawn(class'PathNodeMobile',,, Vect(3334,2483,1503));
			Spawn(class'PathNodeMobile',,, Vect(3341,2776,1503));
			Spawn(class'PathNodeMobile',,, Vect(3699,2542,1503));
			Spawn(class'PathNodeMobile',,, Vect(3710,2725,1503));
			
			//Paths around Feng's place. Fun fact: Feng had no pathing in his original apartment at all.
			Spawn(class'PathNodeMobile',,, Vect(242,3110,623));
			Spawn(class'PathNodeMobile',,, Vect(372,3244,623));
			Spawn(class'PathNodeMobile',,, Vect(467,3259,623));
			Spawn(class'PathNodeMobile',,, Vect(538,3116,623));
			Spawn(class'PathNodeMobile',,, Vect(443,3410,623));
			Spawn(class'PathNodeMobile',,, Vect(677,3557,623));
			Spawn(class'PathNodeMobile',,, Vect(409,3614,623));
			Spawn(class'PathNodeMobile',,, Vect(678,3566,879));
			Spawn(class'PathNodeMobile',,, Vect(652,3569,1151));
			Spawn(class'PathNodeMobile',,, Vect(412,3569,1151));
			Spawn(class'PathNodeMobile',,, Vect(-38,3566,1151));
			Spawn(class'PathNodeMobile',,, Vect(-27,3892,1151));
			Spawn(class'PathNodeMobile',,, Vect(-174,4020,1151));
			Spawn(class'PathNodeMobile',,, Vect(-253,3555,1151));
			Spawn(class'PathNodeMobile',,, Vect(-370,3542,1151));
			Spawn(class'PathNodeMobile',,, Vect(-371,3337,1151));
			Spawn(class'PathNodeMobile',,, Vect(-570,3571,1151));
			Spawn(class'PathNodeMobile',,, Vect(-574,3783,1151));
			Spawn(class'PathNodeMobile',,, Vect(-736,3549,1151));
			Spawn(class'PathNodeMobile',,, Vect(-554,3336,1151));
			Spawn(class'PathNodeMobile',,, Vect(-724,3342,1151));
			
			bRebuildRequired = true;
			
			//Ladder out back behind the car lot, near informant.
			TSpacing = Vect(8,0,0);
			AddLadderGroup(Vect(-1, 0, 0), Vect(5011,2322,574)+TSpacing, Vect(5011,2322,799)+TSpacing, Vect(4952,2322,799),, 4+8);
			
			//Ladder trellis... Thing... This building makes no fucking sense.
			TSpacing = Vect(0,8,0);
			AddLadderGroup(Vect(0, -1, 0), Vect(3611,1980,804)+TSpacing, Vect(3611,1980,1527)+TSpacing, Vect(3727,2033,1527),, 4+8);
			
			//Bottom level to mid level for Feng's triple ladder.
			TSpacing = Vect(0,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(788,3564,692)+TSpacing, Vect(788,3564,928)+TSpacing, Vect(682,3564,879),, 4+8);
			
			//Mid level to top level for Feng's triple ladder.
			TSpacing = Vect(0,0,0);
			AddLadderGroup(Vect(1, 0, 0), Vect(682,3564,879), Vect(788,3564,928)+TSpacing, Vect(788,3564,1200)+TSpacing, Vect(682,3564,1151), 4+8);
		break;
	}
}

defaultproperties
{
}
