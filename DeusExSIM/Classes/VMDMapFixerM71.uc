//=============================================================================
// VMDMapFixerM71.
//=============================================================================
class VMDMapFixerM71 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//71_MUTATIONS: Turrets are intended to be active, but are not. Fix this.
		case "71_MUTATIONS":
			forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = true;
				}
			}
		break;
		//71_ZODIAC_LANGLEY_CIAHQ: Hiding portrait, in-line with prior changes.
		//2/18/25: Also, add more paths for MEGH.
		case "71_ZODIAC_LANGLEY_CIAHQ":
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-3647,-4751,1160));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-3647,-4751,1160);
				TCamp.MaxCampLocation = Vect(-3618,-4705,1247);
				TCamp.NumWatchedDoors = 1;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 59));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.bLastOpened = true;
			}
			
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 1:
							DXM.bHighlight = false;
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
		break;
		//71_ZODIAC_LANGLEY_MJ12: Add more MEGH paths.
		case "71_ZODIAC_LANGLEY_MJ12":
			TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-2393,1121,617));
			if (TCamp != None)
			{
				TCamp.MinCampLocation = Vect(-2393,1121,617);
				TCamp.MaxCampLocation = Vect(-2336,1143,663);
				TCamp.NumWatchedDoors = 2;
				TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
				TCamp.CabinetDoorClosedFrames[0] = 0;
				TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 27));
				TCamp.CabinetDoorClosedFrames[1] = 0;
				TCamp.bLastOpened = true;
			}
		break;
		//71_WHITEHOUSE: 10mm ammo inside the floor.
		case "71_WHITEHOUSE":
			forEach AllActors(class'Actor', A)
			{
				if (Ammo10mm(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 2:
							A.SetLocation(Vect(3507, 5598, 268));
						break;
					}
				}
				else if (Ammo10mmGasCap(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 0:
							A.SetLocation(Vect(3507, 5598, 268));
						break;
					}
				}
			}
		break;
		//71_CANYON: Horrendously fucked up doors.
		case "71_CANYON":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 0:
							//Base of -897, -712, -1492
							//BEST FIT IS -899, -712, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of -16384, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-897,-712,-1492)))
							{
								LocAdd = vect(-4, 0, 128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(-4, 0, 128);
								FrameAdd[1] = vect(-4, 0, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 2:
							//Base of -1440, -24, -1492
							//BEST FIT IS -1440, -22, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 32768, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-1440,-24,-1492)))
							{
								LocAdd = vect(0, 4, 128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(0, 4, 128);
								FrameAdd[1] = vect(0, 4, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 20:
							//Base of -627, -1520, -1364
							//BEST FIT IS -625, -1520, -1236
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Pitch of 32768, Yaw of -16384, Roll of 0
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-627,-1520,-1364)))
							{
								LocAdd = vect(4, 0, -128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(4, 0, -128);
								FrameAdd[1] = vect(4, 0, -128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 23:
							//Base of -1203, -1632, -1364
							//BEST FIT IS -1205, -1632, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Pitch of 32768, Yaw of -16384, Roll of 0
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-1203,-1632,-1364)))
							{
								LocAdd = vect(-4, 0, -128);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(-4, 0, -128);
								FrameAdd[1] = vect(-4, 0, -128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 32:
							//Base of -1312, -24, -1496
							//BEST FIT IS -1312, -22, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-1312,-24,-1496)))
							{
								LocAdd = vect(0, 4, 136);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(0, 4, 136);
								FrameAdd[1] = vect(0, 4, 136);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 36:
							//Base of -743, -752, -1492
							//BEST FIT IS -743, -750, -1364
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0, Roll of 32768
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-743,-752,-1492)))
							{
								LocAdd = vect(0, 4, 128);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(0, 4, 128);
								FrameAdd[1] = vect(0, 4, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
						case 39:
							//Base of -627, -1648, -1492
							//BEST FIT IS -625, -1648, -1492
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Pitch of 32768, Yaw of -16384, Roll of 0
							//180-ing ROLL!
							if (MoverIsLocation(DXM, vect(-627,-1648,-1492)))
							{
								LocAdd = vect(4, 0, 128);
								PivAdd = vect(0, 4, 0);
								FrameAdd[0] = vect(4, 0, 128);
								FrameAdd[1] = vect(4, 0, 128);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.PrePivot = DXM.PrePivot + PivAdd;
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.SetRotation(DXM.Rotation + Rot(0, 0, 32768));
								DXM.KeyRot[0].Roll += 32768;
								DXM.KeyRot[1].Roll += 32768;
							}
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
			
			class'VMDNative.VMDLightRebuilder'.Static.RebuildLighting();
		break;
	}
}

defaultproperties
{
}
