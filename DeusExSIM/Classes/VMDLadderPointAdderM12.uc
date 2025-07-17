//=============================================================================
// VMDLadderPointAdderM12.
//=============================================================================
class VMDLadderPointAdderM12 extends VMDLadderPointAdder;

function AddLadderPoints()
{
	Super.AddLadderPoints();
	
	switch(MN)
	{
		case "12_VANDENBERG_CMD":
			if (!bRevisionMapSet)
			{
				//#1: Comsat building back room up to its roof. Mercenary related?
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(-1669,4570,-2112)+TSpacing, Vect(-1669,4570,-1895)+TSpacing, Vect(-1745,4570,-1903),, 4+8);
				
				//#2: Ladder out of water, near the tower thing with LAWs. Recovery area.
				TSpacing = Vect(-8,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-2850,2075,-2146)+TSpacing, Vect(-2850,2080,-1986)+TSpacing,Vect(-2797,2080,-2000),, 4+8+64);
				
				//#3: Small ditch ladder player can hide in, near tower.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-2080,350,-2146)+TSpacing, Vect(-2080,350,-1992)+TSpacing, Vect(-2080,429,-2000),, 4+8);
				
				//#4: Ground level to F2 of water tower.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-1159,214,-1997)+TSpacing, Vect(-1159,214,-1798)+TSpacing, Vect(-1159,265,-1806),, 4+8,, 0.5, 0.5);
				
				//#5: F2 to F3 of water tower. We were built this way to work better with pathfinding.
				TSpacing = Vect(0,-8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(-1159,265,-1806), Vect(-1159,214,-1798)+TSpacing, Vect(-1159,214,-1572)+TSpacing, Vect(-1159,266,-1580), 1+2+4+8,, 0.5, 0.5);
				
				//Keep sniper guy up here, thanks.
				VMBP = VMDBufferPawn(FindActorBySeed(class'MJ12Troop', 7));
				if (VMBP != None)
				{
					VMBP.bCanClimbLadders = false;
				}
				
				//#6: From interior room near vent up to the midsection.
				TSpacing = Vect(0,16,0);
				AddLadderGroup(Vect(0, 1, 0), Vect(-396,1059,-2061)+TSpacing, Vect(-396,1059,-1652)+TSpacing, Vect(-396,1014,-1652),, 4+8+512);
				
				//#7: From midsection in interior room to top.
				TSpacing = Vect(0,0,0);
				AddLadderGroup(Vect(1, 0, 0), Vect(-61,767,-1656)+TSpacing, Vect(-61,767,-1286)+TSpacing, Vect(-61,825,-1324),, 4+8);
			}
		break;
		case "12_VANDENBERG_GAS":
			if (!bRevisionMapSet)
			{
				//#1: Sewers to enclosed trash area.
				TSpacing = Vect(8,0,0);
				AddLadderGroup(Vect(-1, 0, 0), Vect(1636,-620,-1336)+TSpacing, Vect(1636,-620,-940)+TSpacing, Vect(1650,-544,-948),, 4+8);
				
				//#2: Rear gas station to roof
				TSpacing = Vect(0,8,0);
				AddLadderGroup(Vect(0, -1, 0), Vect(628,865,-945)+TSpacing, Vect(628,865,-576)+TSpacing, Vect(628,799,-584),, 4+8,,,,DeusExMover(FindActorBySeed(class'DeusExMover', 16)));
			}
		break;
	}
}

defaultproperties
{
}
