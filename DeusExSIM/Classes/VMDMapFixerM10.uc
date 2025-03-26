//=============================================================================
// VMDMapFixerM10.
//=============================================================================
class VMDMapFixerM10 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//10_PARIS_CLUB: Omelette Du Fromage: Hide wall painting and the entry vent
		case "10_PARIS_CLUB":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 0:
							case 10:
								DXM.bHighlight = false;
							break;
							
							//Base: 400, -864, -48
							//Intended: 404, -864, -48
							//Rotation: -16384 Yaw
							case 2:
								if (MoverIsLocation(DXM, vect(400,-864,-48)))
								{
									LocAdd = vect(4,0,0);
									PivAdd = vect(0,4,0);
									FrameAdd[0] = vect(4,0,0);
									FrameAdd[1] = vect(4,0,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							
							//Base: -1712, -1476, -160
							//Intended: -1708, -1476, -160
							//Rotation: -16384 Yaw
							case 4:
								if (MoverIsLocation(DXM, vect(-1712,-1476,-160)))
								{
									LocAdd = vect(4,0,0);
									PivAdd = vect(0,4,0);
									FrameAdd[0] = vect(4,0,0);
									FrameAdd[1] = vect(4,0,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							
							//Base: -2016, -1168, -176
							//Intended: -2016, -1164, -176
							//Rotation: 0 Yaw
							case 5:
								if (MoverIsLocation(DXM, vect(-2016,-1168,-176)))
								{
									LocAdd = vect(0,4,0);
									PivAdd = vect(0,4,0);
									FrameAdd[0] = vect(0,4,0);
									FrameAdd[1] = vect(0,4,0);
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
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (Bartender(SP) != None)
					{
						SP.bFearHacking = true;
						SP.bHateHacking = true;
					}
					else if (Hooker2(SP) != None)
					{
						switch(SF.Static.StripBaseActorSeed(SP))
						{
							case 2:
								SP.bFearHacking = true;
								SP.bHateHacking = true;
							break;
						}
					}
				}
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPAchille", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPAchille',vect(-217,1144,-144));
						if (SP != None)
						{
							SP.SetOrders('Sitting',, true);
							SP.SeatActor = Seat(FindActorBySeed(class'Chair1', 2));
							SP.Alliance = 'Patrons';
							SP.BarkBindName = "Man";
							SP.InitialAlliances[0].AllianceName = 'ClubStaff';
							SP.InitialAlliances[0].AllianceLevel = 1.0;
							SP.InitialAlliances[1].AllianceName = 'Player';
							SP.InitialInventory[0].Inventory = class'Credits';
							SP.InitialInventory[0].Count = 1;
							SP.ConBindEvents();
						}
					}
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPParisClubGuy", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPParisClubGuy',vect(-463,-327,60), rot(0,-65392,0));
						if (SP != None)
						{
							SP.SetOrders('Dancing',, true);
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
				}
			}
		break;
		//10_PARIS_METRO: BSP error inside a wall.
		//In DXT Maps, hole inside the front desk of the hostel.
		case "10_PARIS_METRO":
			if (!bRevisionMapSet)
			{
				PlugVect = Vect(4373, 0, 860);
				for (i=2161; i<2938; i += 97)
				{
					PlugVect.Y = i;
					AddBSPPlug(PlugVect, 44, 1024);
				}
				
				//One for the hostel, too.
				AddBSPPlug(vect(3281,2240,176), 48, 32);
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 20:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(593,1248,823));
				if (TCamp != None)
				{
					//587, 1220, 825
					//567, 1275, 873
					TCamp.MinCampLocation = Vect(567,1220,825);
					TCamp.MaxCampLocation = Vect(587,1275,873);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
			}
		break;
		//10_PARIS_CATACOMBS: We just came here over beef with the locked cabinet lol.
		case "10_PARIS_CATACOMBS":
			if (!bRevisionMapSet)
			{
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-1280,-1092,6));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(-1308,-1085,8);
					TCamp.MaxCampLocation = Vect(-1253,-1065,56);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 17));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 18));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
			}
		break;
		//10_PARIS_CATACOMBS_TUNNELS: Weird fragment classes.
		case "10_PARIS_CATACOMBS_TUNNELS":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 0:
							case 12:
							case 13:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
			}
		break;
		//10_PARIS_CHATEAU: Fifth easter egg.
		case "10_PARIS_CHATEAU":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 16:
								//MADDERS, 6/9/22: This is door is way too fucky.
								//Don't make us crush shit, and don't get diddled by nicolette. Jesus.
								DXM.SetPropertyText("MoverEncroachType", "3");
								DXM.bIsDoor = false;
							break;
						}
					}
				}
				CreateHallucination(vect(-1250, 262, -12), 4, false);
			}
		break;
	}
}

defaultproperties
{
}
