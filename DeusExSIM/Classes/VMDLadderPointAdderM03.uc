//=============================================================================
// VMDLadderPointAdderM03.
//=============================================================================
class VMDLadderPointAdderM03 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "03_NYC_AIRFIELDHELIBASE":
			if (!bRevisionMapSet)
			{
				//#1: Ladder up from glass roof to sniper catwalk.
				TSpacing = Vect(0,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-1380,1223,416)+TSpacing, Vect(-1380,1223,822)+TSpacing, Vect(-1394,1141,808),, 4+8);
				
				//Keep sniper guy up here, thanks.
				VMBP = VMDBufferPawn(FindActorBySeed(class'Terrorist', 37));
				if (VMBP != None)
				{
					VMBP.bCanClimbLadders = false;
				}
				
				//#2: Ladder from sewer grate up to the previously very cursed catwalk.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-1344,-463,48)+TSpacing, Vect(-1344,-463,216)+TSpacing, Vect(-1344,-363,200),, 4+8);
				
				//#3: Ladder from the cursed area up to the glass skylight area.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-1344,-27,213)+TSpacing, Vect(-1344,-27,456)+TSpacing, Vect(-1344,72,416),, 4+8);
				
				//#4: Ladder from skylight area up to the previously unused catwalk. Cool.
				TSpacing = Vect(0,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(1380,1224,419)+TSpacing, Vect(1380,1224,810)+TSpacing, Vect(1381,1146,808),, 4+8);
				
			}
		break;
		case "03_NYC_AIRFIELD":
			if (!bRevisionMapSet)
			{
				//#1: First isolated crate, closer to water, from ground to mid.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-792,-293,51)+TSpacing, Vect(-792,-293,217)+TSpacing, Vect(-792,-403,209),, 4+8);
				
				//#2: First isolated crate, from mid to high.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-847,-560,212)+TSpacing, Vect(-847,-560,377)+TSpacing, Vect(-936,-560,369),, 4+8);
				
				//#3: Second isolated crate, further from water, from ground to mid.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-475,-144,51)+TSpacing, Vect(-475,-144,217)+TSpacing, Vect(-371,-144,209),, 4+8);
				
				//#4: Second isolated crate, from mid to high.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-314,-304,212)+TSpacing, Vect(-314,-304,377)+TSpacing, Vect(-236,-304,369),, 4+8);
				
				//#5: The most interesting double ladder crate, this one goes somewhere. Low to mid.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-720,3387,51)+TSpacing, Vect(-720,3387,216)+TSpacing, Vect(-720,3279,208),, 4+8);
				
				//#6: Same double crate, mid to high.
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-945,3227,211)+TSpacing, Vect(-945,3227,376)+TSpacing, Vect(-945,3129,368),, 4+8);
			}
		break;
	}
}

defaultproperties
{
}
