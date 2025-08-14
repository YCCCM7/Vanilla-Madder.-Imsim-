//=============================================================================
// VMDMapFixerM03.
//=============================================================================
class VMDMapFixerM03 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//03_NYC_747: Revision special. Assigned invalid index due to NV using non-vanilla indices.
		case "03_NYC_747":
			if (bRevisionMapSet)
			{
				class'VMDTerrainReskinner'.Static.SetSurfaceTexture(XLevel, "", Texture(DynamicLoadObject("CoreTexMisc.Glass.WhiteNoise_A01", class'Texture', False)));
			}
		break;
		//03_NYC_AIRFIELD: Doors that don't open properly if you block them, and can soft lock you. Sigh.
		//Also, 2nd easter egg.
		case "03_NYC_AIRFIELD":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 2:
							case 3:
								DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				//Plug a hole in a crate we can walk through. Oops.
				PlugVect = Vect(752, 0, 224);
				for (i=3278; i<3409; i += 26)
				{
					PlugVect.Y = i;
					AddBSPPlug(PlugVect, 13, 64);
				}
				
				CreateHallucination(vect(-262, -1176, 324), 1, false);
			}
			else
			{
				CreateHallucination(vect(-262, -1176, 324), 1, false);
			}
		break;
		//03_NYC_AIRFIELDHELIBASE Bad fragment class on these doors.
		//NOTE: This is purely a GOTY fix.
		case "03_NYC_AIRFIELDHELIBASE":
			if (!bRevisionMapSet)
			{
				Comp = Spawn(class'ComputerSecurity',,, Vect(-1160,524,269), Rot(0,16384,0));
				if (Comp != None)
				{
					Comp.SetCollisionSize(0, Comp.CollisionHeight);
					Comp.SetLocation(Vect(-1160,515,269));
					Comp.SetCollisionSize(Comp.Default.CollisionRadius, Comp.CollisionHeight);
					Comp.UserList[0].UserName = "JHEARST";
					Comp.UserList[0].Password = "CHUNKOHONEY";
					Comp.SpecialOptions[0].bTriggerOnceOnly = true;
					Comp.SpecialOptions[0].Text = "Join Call";
					Comp.SpecialOptions[0].TriggerEvent = 'RestoredJuanConvoStart';
					Comp.SpecialOptions[0].TriggerText = "Joined... 2 other members";
				}
				
				TDispatch = Spawn(class'Dispatcher',,'RestoredJuanConvoStart', Vect(-1160,544,269));
				if (TDispatch != None)
				{
					TDispatch.SetCollision(False, False, False);
					TDispatch.OutEvents[0] = 'RestoredJuanConvo';
					TDispatch.OutDelays[0] = 1.2500000;
				}
				
				ConTrig = Spawn(class'ConversationTrigger',,'RestoredJuanConvo', Vect(-1160,544,269));
				if (ConTrig != None)
				{
					ConTrig.SetCollision(False, False, False);
					ConTrig.BindName = "JCDenton";
					ConTrig.bCheckFalse = true;
					ConTrig.CheckFlag = 'OverhearLebedev_Played';
					ConTrig.ConversationTag = 'OverhearLebedev';
					ConTrig.bPopWindow = true;
				}
				
				A = Spawn(class'Button1',,, Vect(-1140,514,268));
				if (A != None)
				{
					A.BindName = "JuanLebedev";
					A.bHidden = true;
					A.FamiliarName = "Unknown";
					A.UnfamiliarName = "Unknown";
					A.SetCollision(False, False, False);
					A.SetPhysics(PHYS_None);
					DeusExDecoration(A).ConBindEvents();
					VMDBufferDeco(A).bDisablePassiveConvos = true;
				}
				
				A = Spawn(class'Button1',,, Vect(-1140,514,278));
				if (A != None)
				{
					A.BindName = "TracerTong";
					A.bHidden = true;
					A.FamiliarName = "Unknown";
					A.UnfamiliarName = "Unknown";
					A.SetCollision(False, False, False);
					A.SetPhysics(PHYS_None);
					DeusExDecoration(A).ConBindEvents();
				}
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 127:
								//Rotation yaw of -49152
								//Base: 64, 816, 4
								//Desired: 64, 812, 56
								//----------------------
								//IGNORING Z
								if (MoverIsLocation(DXM, Vect(64, 816, 64)))
								{
									LocAdd = vect(0,-4,0);
									PivAdd = vect(-4,0,0);
									FrameAdd[0] = vect(0,-4,0);
									FrameAdd[1] = vect(0,-4,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 139:
							case 140:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
			}
		break;
		//03_NYC_BATTERYPARK: LDDP stuff.
		case "03_NYC_BATTERYPARK":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBatPark2NiceBum", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPBatPark2NiceBum',vect(-2653,1381,370), rot(0,-36640,0));
						if (SP != None)
						{
							SP.Alliance = 'Civilian';
							SP.SetOrders('Standing',, true);
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
				}
				
				//Beer inside ground. The little things, with me.
				forEach AllActors(class'Actor', A)
				{
					if (Liquor40Oz(A) != None)
					{
						switch(SF.Static.StripBaseActorSeed(Liquor40Oz(A)))
						{
							case 47:
								A.SetLocation(A.Location + vect(0,0,6));
							break;
						}
					}
				}
			}
		break;
		//03_NYC_BROOKLYNBRIDGESTATION: Pivot fixes, but also hide the hidden wall panel
		case "03_NYC_BROOKLYNBRIDGESTATION":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 2:
								DXM.bHighlight = false;
							break;
							case 8:
								SetMoverFragmentType(DXM, "Metal");
							break;
							//180 degree offset in rotation
							//Base: -1128, -1440, 192
							//Desired: -1134, -1440, 192
							case 53:
								if (MoverIsLocation(DXM, vect(-1128, -1440, 192)))
								{
									LocAdd = vect(-6,0,0);
									PivAdd = vect(6,0,0);
									FrameAdd[0] = vect(-6,0,0);
									FrameAdd[1] = vect(-6,0,0);
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
				
				forEach AllActors(class'ElectronicDevices', ED)
				{
					if (CigaretteMachine(ED) != None)
					{
						CigaretteMachine(ED).NumUses = 0;
					}
					if (VendingMachine(ED) != None)
					{
						VendingMachine(ED).NumUses = 0;
					}
				}
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPStationAddict", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPStationAddict',vect(-1005,1315,112), rot(0,-12176,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
						}
					}
				}
			}
		break;
		//03_NYC_HANGAR: Fix for dudes freaking the fuck out in DX rando situations.
		case "03_NYC_HANGAR":
			if (!bRevisionMapSet)
			{
			}
			//4/13/23: Fix for civvies freaking the fuck out.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (HumanCivilian(SP) != None)
				{
					HumanCivilian(SP).bHateShot = False;
				}
			}
		break;
		//03_NYC_MOLEPEOPLE: Add an anti-softlock measure.
		case "03_NYC_MOLEPEOPLE":
			if (!bRevisionMapSet)
			{
				A = Spawn(class'Switch1',,, vect(-2788,-896.75,133), Rot(0,-16384,0));
				
				//This fucker keeps spawning detached from the wall a bit. Yikes.
				A.SetCollisionSize(0, 0);
				A.SetLocation(vect(-2788,-896.75,133));
				A.Event = 'SecretDoor';
				A.SetCollisionSize(A.Default.CollisionRadius, A.Default.CollisionHeight);
			}
			
			//4/13/23: Fix for terrie commander listening to narcs too often.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if ((Terrorist(SP) != None) && (Terrorist(SP).BindName ~= "TerroristLeader"))
				{
					Terrorist(SP).bHateDistress = False;
				}
			}
		break;
		//03_NYC_UNATCOHQ: LDDP stuff.
		case "03_NYC_UNATCOHQ":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/18/24: Anna gives us some seriously sweet ammo for being a terrie shredder.
				if ((Flags.GetBool('AmbrosiaTagged')) && (Flags.GetBool('BatteryParkSlaughter')) && (!Flags.GetBool('M02MechSlur')) && (Flags.GetBool('SubTerroristsDead')) && (!Flags.GetBool('SubHostageMale_Dead')) && (!Flags.GetBool('SubHostageFemale_Dead')))
				{
					A = Spawn(Class'Datacube',,, Vect(-261,1297,288), Rot(0,8192,0));
					if (A != None)
					{
						Datacube(A).TextPackage = "VMDText";
						Datacube(A).TextTag = '03_AnnaThanks';
					}
					A = Spawn(class'Ammo10mmHEAT',,, Vect(-227,1292,244));
					A.SetPhysics(PHYS_None);
					A.SetRotation(Rot(0,0,0));
					A = Spawn(class'Ammo10mmHEAT',,, Vect(-227,1302,244));
					A.SetPhysics(PHYS_None);
					A.SetRotation(Rot(0,0,0));
				}
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPChet',vect(112,1714,288));
						if (SP != None)
						{
							SP.SetOrders('Sitting',, true);
							SP.InitialInventory[0].Inventory = class'WeaponPepperGun';
							SP.InitialInventory[0].Count = 1;
							SP.InitialInventory[1].Inventory = class'AmmoPepper';
							SP.InitialInventory[1].Count = 8;
							SP.BindName = "LDDPChet";
							SP.SeatActor = Seat(FindActorBySeed(class'ChairLeather', 5));
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(364,1113,280);
					TCamp.MaxCampLocation = Vect(418,1133,328);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
			}
			else
			{
				//MADDERS, 11/18/24: Anna gives us some seriously sweet ammo for being a terrie shredder.
				if ((Flags.GetBool('AmbrosiaTagged')) && (Flags.GetBool('BatteryParkSlaughter')) && (!Flags.GetBool('M02MechSlur')) && (Flags.GetBool('SubTerroristsDead')) && (!Flags.GetBool('SubHostageMale_Dead')) && (!Flags.GetBool('SubHostageFemale_Dead')))
				{
					//MADDERS, 8/6/25: Tweak for Revision map placement.
					HackVect = Vect(0, 34, 2);
					A = Spawn(Class'Datacube',,, Vect(-261,1297,288) + HackVect, Rot(0,8192,0));
					if (A != None)
					{
						Datacube(A).TextPackage = "VMDText";
						Datacube(A).TextTag = '03_AnnaThanks';
					}
					A = Spawn(class'Ammo10mmHEAT',,, Vect(-227,1292,244) + HackVect);
					A.SetPhysics(PHYS_None);
					A.SetRotation(Rot(0,0,0));
					A = Spawn(class'Ammo10mmHEAT',,, Vect(-227,1302,244) + HackVect);
					A.SetPhysics(PHYS_None);
					A.SetRotation(Rot(0,0,0));
				}
			}
			
			forEach AllActors(class'ElectronicDevices', ED)
			{
				if (VendingMachine(ED) != None)
				{
					switch(SF.Static.StripBaseActorSeed(ED))
					{
						case 0:
							if (!bRevisionMapSet)
							{
								VendingMachine(ED).AdvancedUses[0]++;
								VendingMachine(ED).bOrangeGag = true;
							}
						break;
						case 1:
							if (bRevisionMapSet)
							{
								VendingMachine(ED).AdvancedUses[0]++;
								VendingMachine(ED).bOrangeGag = true;
							}
						break;
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
