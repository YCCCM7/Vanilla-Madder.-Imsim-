//=============================================================================
// VMDMapFixerM12.
//=============================================================================
class VMDMapFixerM12 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//12_VANDENBERG_CMD: Cabinets and reactions oh my.
		case "12_VANDENBERG_CMD":
			if (!bRevisionMapSet)
			{
				PlugVect = Vect(3081, 0, -1954);
				for (i=1631; i<2094; i += 16)
				{
					PlugVect.Y = i;
					AddBSPPlug(PlugVect, 35, 226);
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(2159,1448,-2041));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(2131,1454,-2039);
					TCamp.MaxCampLocation = Vect(2187,1474,-1991);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 27));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 0:
							case 3:
							case 4:
							case 10:
								DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (Mechanic(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 1:
						case 2:
							DumbAllReactions(SP);
						break;
					}
				}
				else if (ScientistMale(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
						case 1:
							DumbAllReactions(SP);
						break;
					}
				}
			}
		break;
		//12_VANDENBERG_TUNNEL: Turret needs re-arming.
		//5/24/23: Also, a broken door pivot. Bah.
		case "12_VANDENBERG_TUNNELS":
			if (!bRevisionMapSet)
			{
				//MADDERS, 3/29/21: We're inverted default turret state, since most mods can't keep it in their pants.
				//This is one of very few places where turrets are on by default.
				forEach AllActors(class'AutoTurretSmall', SATur)
				{
					if (SATur != None)
					{
						switch(SF.Static.StripBaseActorSeed(SATur))
						{
							case 0:
								SATur.bDisabled = false;
								SATur.bPreAlarmActiveState = true;
								SATur.bActive = true;
							break;
						}
					}
				}
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 4:
								//Base of -1672, 2522, -2610
								//BEST FIT IS -1672, 2520, -2610.
								//Ignoring Z.
								//Rotation Yaw of 0
								if (MoverIsLocation(DXM, vect(-1672,2522,-2610)))
								{
									LocAdd = vect(0, -2, 0);
									PivAdd = vect(0, -2, 0);
									FrameAdd[0] = vect(0, -2, 0);
									FrameAdd[1] = vect(0, -2, 0);
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
			else
			{
				//MADDERS, 3/29/21: We're inverted default turret state, since most mods can't keep it in their pants.
				//This is one of very few places where turrets are on by default.
				forEach AllActors(class'AutoTurretSmall', SATur)
				{
					if (SATur != None)
					{
						switch(SF.Static.StripBaseActorSeed(SATur))
						{
							case 0:
								SATur.bDisabled = false;
								SATur.bPreAlarmActiveState = true;
								SATur.bActive = true;
							break;
						}
					}
				}
			}
		break;
		//12_VANDENBERG_COMPUTER: Frobbable softlock doors. Yay.
		case "12_VANDENBERG_COMPUTER":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 11:
							case 12:
								DXM.bFrobbable = false;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPVanSci", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPVanSci',vect(693,2535,-2167));
						if (SP != None)
						{
							SP.BarkBindName = "Woman";
							SP.FamiliarName = "Stacey Marshall";
							SP.ConBindEvents();
						}
					}
				}
			}
			
			//Another softlock in such a tiny map? Good grief. Fix scientists breaking trigger positions from things being blown up upstairs.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (SP != None)
				{
					//MADDERS: Eliminate reactions here.
					DumbAllReactions(SP);
				}
			}
		break;
		//12_VANDENBERG_GAS: Fix bad truck key, and add the sixth easter egg.
		//8/11/21: Oops. Loud noise bug inherited from Zodiac attempted fix.
		case "12_VANDENBERG_GAS":
			forEach AllActors(class'ScriptedPawn', SP)
			{
				if (TiffanySavage(SP) != None)
				{
					SP.bReactLoudNoise = false;
				}
			}
			
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 6:
							case 5:
								DXM.KeyIDNeeded = 'VMDPatchedTruck';
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				Key = Spawn(class'Nanokey',,,vect(-2906,1142,-938));
				if (Key != None)
				{
					Key.Description = VMDPatchedTruckDesc;
					Key.KeyID = 'VMDPatchedTruck';
				}
				
				CreateHallucination(vect(633, 741, -970), 5, false);
			}
			else
			{
				CreateHallucination(vect(873, 1298, -966), 5, false);
			}
		break;
	}
}

defaultproperties
{
}
