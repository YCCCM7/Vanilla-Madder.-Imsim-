//=============================================================================
// VMDLadderPointAdderM01.
//=============================================================================
class VMDLadderPointAdderM01 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	local PatrolPointMobile Pat;
	
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "01_NYC_UNATCOISLAND":
			if (!bRevisionMapSet)
			{
				//#01: SATCOM Ladder. Beats the player hiding inside indefinitely?
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(-1, -1, 0), Vect(-6384,1469,-240)+TSpacing, Vect(-6384,1469,-80)+TSpacing, Vect(-6280,1469,-92),, 4+8);
				
				//#02: Rear of statue up to its first ladder point.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1,0,0), Vect(6120, -2504, -61)+TSpacing, Vect(6120,-2504,72)+TSpacing, Vect(6038,-2505,64),, 4+8);
			}
		break;
		//01_NYC_UNATCOHQ: First easter egg, and return encroach type on Manderley's door.
		case "01_NYC_UNATCOHQ":
			Pat = Spawn(class'PatrolPointMobile',,'ChetBathroomRoute01', Vect(253,275,7), Rot(0, 16080, 0));
			Pat.NextPatrol = 'ChetBathroomRoute02';
			Pat = Spawn(class'PatrolPointMobile',,'ChetBathroomRoute02', Vect(212,195,7), Rot(0, -608, 0));
			Pat.NextPatrol = 'ChetBathroomRoute01';
			bRebuildRequired = true;
		break;
	}
}

defaultproperties
{
}
