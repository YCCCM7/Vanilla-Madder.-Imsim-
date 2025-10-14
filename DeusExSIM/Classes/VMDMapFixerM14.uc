//=============================================================================
// VMDMapFixerM14.
//=============================================================================
class VMDMapFixerM14 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	//MADDERS note: Defective path node.
	//For all the bullshit we can pull, this ain't under the umbrella.
	//We'll package the minor fix, but otherwise keep it untouched.
	switch(MapName)
	{
		//14_OCEANLAB_SILO: Door becomes delet with new path setup, so make it a door, as it should always have been.
		case "14_OCEANLAB_SILO":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'Actor', A)
				{
					DXM = DeusExMover(A);
					if ((DXM != None) && (DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 10:
								//Rotation yaw of 0
								//Base: 428, -1456, 513
								//Desired: 424, -1456, 510
								//----------------------
								//IGNORING Z
								if (MoverIsLocation(DXM, Vect(428, -1456, 513)))
								{
									LocAdd = vect(-4,0,0);
									PivAdd = vect(-4,0,0);
									FrameAdd[0] = vect(-4,0,0);
									FrameAdd[1] = vect(-4,0,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 15:
								DXM.bIsDoor = true;
							break;
							case 21:
							case 22:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
						DXM.bMadderPatched = true;
					}
					else if (A.IsA('WeaponModSilencer'))
					{
						switch(SF.Static.StripBaseActorSeed(A))
						{
							case 0:
								Spawn(class'WeaponModReload',,, A.Location, A.Rotation);
								A.Destroy();
							break;
						}
					}
				}
			}
			else
			{
				forEach AllActors(class'Actor', A)
				{
					if (AlarmLight(A) != None)
					{
						AlarmLight(A).LightBrightness = 0;
					}
				}
			}
		break;
		//14_VANDENBERG_SUB: Bad door pivot on a hatch... Or two...
		case "14_VANDENBERG_SUB":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 0:
								//Base of 2640, 3228, 340
								//BEST FIT IS 2640, 3228, 344.
								//+++++++++++++++++++++++++++++++
								//Ignoring Z.
								//Rotation Yaw of 16384
								if (MoverIsLocation(DXM, vect(2640,3228,340)))
								{
									LocAdd = vect(0, 0, 4);
									PivAdd = vect(0, 0, 4);
									FrameAdd[0] = vect(0, 0, 4);
									FrameAdd[1] = vect(0, 0, 4);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 7:
								//Base of 2784, 3672, 546
								//BEST FIT IS 2784, 3669, 546.
								//+++++++++++++++++++++++++++++++
								//Ignoring Z.
								//Rotation Yaw of 16384
								if (MoverIsLocation(DXM, vect(2784,3672,546)))
								{
									LocAdd = vect(3, 0, 0);
									PivAdd = vect(0, -3, 0);
									FrameAdd[0] = vect(3, 0, 0);
									FrameAdd[1] = vect(3, -6, 0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 11:
								//Base of 3093, 4096, 512
								//BEST FIT IS 3086, 4184, 521.
								//+++++++++++++++++++++++++++++++
								//BUT Intended base of 3083, 4184, 522.
								//Ignoring Y.
								//Rotation Yaw of 0
								if (MoverIsLocation(DXM, vect(3093,4096,512)))
								{
									LocAdd = vect(-10, 0, 10);
									PivAdd = vect(-10, 0, 10);
									FrameAdd[0] = vect(-10, 0, 10);
									FrameAdd[1] = vect(-10, 0, 10);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
			}
			
			//Fix gary losing his shit on the roof.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (GarySavage(SP) != None)
				{
					//MADDERS: Eliminate reactions here.
					DumbAllReactions(SP);
				}
			}
		break;
		//14_OCEANLAB_LAB: Turrets, plus Simons forgiving the player if they shoot him during the fight, then run.
		//5/24/23: Bad fragments on some lockers, as well.
		case "14_OCEANLAB_LAB":
			//MADDERS, 1/31/21: We're inverted default turret state, since most mods can't keep it in their pants.
			//This is one of very few places where turrets are on by default.
			forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bDisabled = false;
					ATur.bPreAlarmActiveState = true;
					ATur.bActive = true;
				}
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (WaltonSimons(SP) != None)
				{
					SP.EnemyTimeout = 3600;
				}
			}
			
			if (!bRevisionMapSet)
			{
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if ((MedicalBot(SP) != None) && (SP.Region.Zone.bWaterZone))
					{
						SP.TakeDamage(250, SP, SP.Location, vect(0,0,0), 'EMP');
					}
				}
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 1:
							case 12:
							case 14:
							case 15:
							case 16:
							case 17:
							case 18:
							case 19:
								SetMoverFragmentType(DXM, "Metal");
							break;
							
							//MADDERS, 8/8/23: For some reason DXT breaks this key combo. Fix it here.
							case 54:
							case 64:
								DXM.KeyIDNeeded = 'OLStorage';
							break;
						}
					}
				}
			}
		break;
		//14_OCEANLAB_UC: Seventh and final easter egg.
		case "14_OCEANLAB_UC":
			//MADDERS, 1/31/21: We're inverted default turret state, since most mods can't keep it in their pants.
			//This is one of very few places where turrets are on by default.
			forEach AllActors(class'AutoTurret', ATur)
			{
				switch(SF.Static.StripBaseActorSeed(ATur))
				{
					case 2:
						if (!bRevisionMapSet)
						{
							ATur.bDisabled = false;
							ATur.bPreAlarmActiveState = true;
							ATur.bActive = true;
						}
					break;
					default:
						ATur.bDisabled = false;
						ATur.bPreAlarmActiveState = true;
						ATur.bActive = true;
					break;
				}
			}
			
			if (!bRevisionMapSet)
			{
				CreateHallucination(vect(1878, 6436, -3083), 6, false);
			}
			else
			{
				CreateHallucination(vect(272, 4512, -2950), 6, false);
			}
		break;
	}
}

defaultproperties
{
}
