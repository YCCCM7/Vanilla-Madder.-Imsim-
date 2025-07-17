//=============================================================================
// VMDLadderPointAdderM11.
//=============================================================================
class VMDLadderPointAdderM11 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "11_PARIS_CATHEDRAL":
			if (!bRevisionMapSet)
			{
				//#1: This one ladder is the focus. No sane person would chase after someone on a trelis.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(3773,-872,-301)+TSpacing, Vect(3773,-872,-8)+TSpacing, Vect(3692,-872,-16),, 4+8);
			}
		break;
	}
}

defaultproperties
{
}
