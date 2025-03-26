//=============================================================================
// VMDMapFixerM66.
//=============================================================================
class VMDMapFixerM66 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	local Vector TPiv, TAdd, TLoc;
	
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//66_WHITEHOUSE_STREETS: Takara needs a new ammo type for her fucked up, unbugged gun.
		case "66_WHITEHOUSE_STREETS":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				if (TPawn.IsA('LienTakara'))
				{
					VMDBufferPawn(TPawn).AddToInitialInventory(class'Ammo762mm', 5);
				}
			}
		break;
		//CORRUPTION: Arsenal of supremely fucked up doors.
		case "CORRUPTION":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 1:
							//Base of -1772, -856, 1064
							//BEST FIT IS -1772, -852, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(-1772,-856,1064)))
							{
								LocAdd = vect(0, 6, 0);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(0, 6, 0);
								FrameAdd[1] = vect(0, 6, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 2:
							//Base of 808, -1880, 1064
							//BEST FIT IS 808, -1886, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(808,-1880,1064)))
							{
								LocAdd = vect(0, -6, 0);
								PivAdd = vect(0, -8, 0);
								FrameAdd[0] = vect(0, -6, 0);
								FrameAdd[1] = vect(0, -6, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = -16384;
							}
						break;
						case 4:
							//Base of -1792, -1888, 1056
							//BEST FIT IS -1784, -1886, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(-1792,-1888,1056)))
							{
								LocAdd = vect(8, 2, 0);
								PivAdd = vect(8, 0, 0);
								FrameAdd[0] = vect(8, 2, 0);
								FrameAdd[1] = vect(8, 2, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = -16384;
							}
						break;
						case 6:
							//OPEN FRAME OF: -1184, -2368, 1440
							//Base of -1184, -2368, 1440
							//BEST FIT IS -1180, -2360, 1360
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//STARTS ON FRAME 1! EW!
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(-1184,-2368,1440)))
							{
								DXM.Trigger(None, None);
								LocAdd = vect(4, 10, 0);
								PivAdd = vect(4, 8, 0);
								FrameAdd[0] = vect(4, 10, 0);
								FrameAdd[1] = vect(4, 10, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 7:
							//Base of -768, -1524, 1440
							//BEST FIT IS -772, -1536, 1360
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 16 X AND 8 Y!
							if (MoverIsLocation(DXM, vect(-768,-1524,1440)))
							{
								LocAdd = vect(12, -4, 0);
								PivAdd = vect(-4, -12, 0);
								FrameAdd[0] = vect(12, -4, 0);
								FrameAdd[1] = vect(12, -4, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 8:
							//Base of 156, -2336, 1440
							//BEST FIT IS 152, -2332, 1360
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 32768
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(156,-2336,1440)))
							{
								LocAdd = vect(-4, 6, 0);
								PivAdd = vect(4, -4, 0);
								FrameAdd[0] = vect(-4, 6, 0);
								FrameAdd[1] = vect(-4, 6, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = -16384;
							}
						break;
						case 9:
							//Base of 40, -1808, 1440
							//BEST FIT IS 40, -1816, 1360
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(40,-1808,1440)))
							{
								LocAdd = vect(0, -6, 0);
								PivAdd = vect(0, -8, 0);
								FrameAdd[0] = vect(0, -6, 0);
								FrameAdd[1] = vect(0, -6, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = -16384;
							}
						break;
						case 10:
							//Base of -1024, -2208, 1440
							//BEST FIT IS -1024, -2220, 1360
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 16 X AND 8 Y!
							if (MoverIsLocation(DXM, vect(-1024,-2208,1440)))
							{
								LocAdd = vect(16, -4, 0);
								PivAdd = vect(0, -12, 0);
								FrameAdd[0] = vect(16, -4, 0);
								FrameAdd[1] = vect(16, -4, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 11:
							//Base of -12, -2180, 1440
							//BEST FIT IS -4, -2180, 1360
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 16384
							if (MoverIsLocation(DXM, vect(-12,-2180,1440)))
							{
								LocAdd = vect(8, 0, 0);
								PivAdd = vect(0, -8, 0);
								FrameAdd[0] = vect(8, 0, 0);
								FrameAdd[1] = vect(8, 0, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = -16384;
							}
						break;
						case 23:
							//Base of 816, -856, 1064
							//BEST FIT IS 816, -850, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							if (MoverIsLocation(DXM, vect(816,-856,1064)))
							{
								LocAdd = vect(0, 4, 0);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(0, 4, 0);
								FrameAdd[1] = vect(0, 4, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 22:
							//Base of -992, 560, 1056
							//BEST FIT IS -988, 558, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(-992,560,1056)))
							{
								LocAdd = vect(4, 0, 0);
								PivAdd = vect(4, -2, 0);
								FrameAdd[0] = vect(4, 0, 0);
								FrameAdd[1] = vect(4, 0, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 24:
							//Base of -492, 560, 1056
							//BEST FIT IS -488, 558, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(-492,560,1056)))
							{
								LocAdd = vect(4, 0, 0);
								PivAdd = vect(4, -2, 0);
								FrameAdd[0] = vect(4, 0, 0);
								FrameAdd[1] = vect(4, 0, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 25:
							//Base of 20, 560, 1056
							//BEST FIT IS 24, 558, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							//FUDGING NON-PIVOT BY 2 Y!
							if (MoverIsLocation(DXM, vect(20,560,1056)))
							{
								LocAdd = vect(4, 0, 0);
								PivAdd = vect(4, -2, 0);
								FrameAdd[0] = vect(4, 0, 0);
								FrameAdd[1] = vect(4, 0, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = 16384;
							}
						break;
						case 26:
							//Base of -1160, 340, 1120
							//BEST FIT IS -1148, 340, 984
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 16384
							if (MoverIsLocation(DXM, vect(-1160,340,1120)))
							{
								LocAdd = vect(12, 0, 0);
								PivAdd = vect(0, -12, 0);
								FrameAdd[0] = vect(12, 0, 0);
								FrameAdd[1] = vect(12, 0, 0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.KeyRot[1].Yaw = -16384;
							}
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
		break;
	}
}

defaultproperties
{
}
