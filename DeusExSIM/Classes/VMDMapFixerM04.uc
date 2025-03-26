//=============================================================================
// VMDMapFixerM04.
//=============================================================================
class VMDMapFixerM04 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//04_NYC_HOTEL: LDDP stuff. Also, we found an issue with renton's reactions, so fix those, too.
		case "04_NYC_HOTEL":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/17/24: Spawn a phone here for consistency.
				A = Spawn(class'Phone',,, Vect(-610,-3244,96), Rot(0,32768,0));
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					DXCLoad = class<DeusExCarcass>(DynamicLoadObject("FemJC.LDDPHotelAddictCarcass", class'Class', true));
					if (DXCLoad != None)
					{
						DXC = Spawn(DXCLoad,,'LDDPHotelAddictCarcass',vect(1850,-1208,82));
					}
				}
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (SandraRenton(SP) != None)
					{
						//MADDERS: Eliminate fears here.
						SP.bFearHacking = False;
						SP.bFearWeapon = False;
						SP.bFearShot = False;
						SP.bFearCarcass = False;
						SP.bFearDistress = False;
						SP.bFearAlarm = False;
						SP.bFearProjectiles = False;
					}
					else if (GilbertRenton(SP) != None)
					{
						//MADDERS: Eliminate fears here.
						SP.bFearHacking = False;
						SP.bFearWeapon = False;
						SP.bFearShot = False;
						SP.bFearInjury = False;
						SP.bFearIndirectInjury = False;
						SP.bFearCarcass = False;
						SP.bFearDistress = False;
						SP.bFearAlarm = False;
						SP.bFearProjectiles = False;
					}
					else if (PaulDenton(SP) != None)
					{
						//SP.bReactFutz = false;
					}
				}
			}
		break;
		//04_NYC_STREET: Update special event for female again.
		case "04_NYC_STREET":
			if (!bRevisionMapSet)
			{
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					forEach AllActors(class'Actor', A)
					{
						if (SpecialEvent(A) != None)
						{
							switch(SF.Static.StripBaseActorSeed(A))
							{
								case 0:
									SpecialEvent(A).Message = "Sign her up for Liberty!!!";
								break;
							}
						}
					}
				}
			}
		break;
		//04_NYC_NSFHQ: Bad pivot on these doors, and a bad frame position on one in general.
		case "04_NYC_NSFHQ":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 4:
								//FrameAdd[0] = vect(0,0,0);
								FrameAdd[1] = vect(0,-4,0);
								FrameAdd[2] = vect(128,0,0);
								//DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[0] + FrameAdd[1];
								DXM.KeyPos[2] = DXM.KeyPos[1] + FrameAdd[2];
							break;
							case 21:
								if (MoverIsLocation(DXM, vect(-664,-60,-256)))
								{
									LocAdd = vect(-4,0,0);
									PivAdd = vect(0, 4, 0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								}
							break;
							case 24:
								if (MoverIsLocation(DXM, vect(-288,792,-256)))
								{
									LocAdd = vect(-4,-4,0);
									PivAdd = vect(-4,4,0);
									FrameAdd[0] = vect(0,-4,0);
									FrameAdd[1] = vect(0,-4,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 26:
								//Base of -188, 944, -256
								//Intended base of -192, 948, -256.
								//Ignoring Z.
								//Rotation Yaw of 0
								if (MoverIsLocation(DXM, vect(-188,944,-256)))
								{
									LocAdd = vect(-4, 4, 0);
									PivAdd = vect(-4, 4, 0);
									FrameAdd[0] = vect(-4, 4, 0);
									FrameAdd[1] = vect(-4, 4, 0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 72:
								//Base of 1126, 168, 16
								//Intended base of 1120, 168, 16.
								//Ignoring Z.
								//Rotation Yaw of 32768
								if (MoverIsLocation(DXM, vect(1126,168,16)))
								{
									LocAdd = vect(-6, 0, 0);
									//PivAdd = vect(6, 0, 0);
									FrameAdd[0] = vect(-6, 0, 0);
									FrameAdd[1] = vect(-6, 0, 0);
									DXM.SetLocation(vect(1120,168,16));
									//DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
						}
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(1219,1349,-216);
					TCamp.MaxCampLocation = Vect(1244,1403,-168);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (RepairBot(SP) != None)
					{
						RepairBot(SP).bHubBot = false;
					}
					else if (MedicalBot(SP) != None)
					{
						MedicalBot(SP).bHubBot = false;
					}
				}
			}
		break;
		//04_NYC_UNATCOHQ: Return door encroach type on manderley's door.
		case "04_NYC_UNATCOHQ":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 10:
								DXM.MoverEncroachType = ME_ReturnWhenEncroach;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(381,1113,280);
					TCamp.MaxCampLocation = Vect(435,1133,328);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPChet',vect(227,1258,288), rot(0,-16456,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
							SP.InitialInventory[0].Inventory = class'WeaponPepperGun';
							SP.InitialInventory[0].Count = 1;
							SP.InitialInventory[1].Inventory = class'AmmoPepper';
							SP.InitialInventory[1].Count = 8;
							SP.BindName = "LDDPChet";
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
				}
			}
			forEach AllActors(class'ElectronicDevices', ED)
			{
				if (VendingMachine(ED) != None)
				{
					switch(SF.Static.StripBaseActorSeed(ED))
					{
						case 0:
							VendingMachine(ED).AdvancedUses[0]++;
							VendingMachine(ED).bOrangeGag = true;
						break;
					}
				}
			}
		break;
		//04_NYC_BAR: LDDP stuff.
		case "04_NYC_BAR":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBarFly", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPBarFly',vect(-1728,-362,48), rot(0,-16392,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
							SP.BarkBindName = "Man";
							SP.UnfamiliarName = "Bar Fly";
							SP.FamiliarName = "Liam";
							SP.bFearWeapon = True;
							SP.bFearInjury = True;
							SP.bFearProjectiles = True;
							SP.ConBindEvents();
						}
					}
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPNYC2BarGuy", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPNYC2BarGuy',vect(-807,-413,51), rot(0,-16504,0));
						if (SP != None)
						{
							SP.Alliance = 'BarPatrons';
							SP.SetOrders('Standing',, true);
							SP.bFearWeapon = True;
							SP.bFearInjury = True;
							SP.bFearProjectiles = True;
						}
					}
					//MADDERS, 11/1/21: LDDP branching functionality.
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPLyla", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPLyla',vect(-2739,523,22));
						if (SP != None)
						{
							if (SP.CollisionHeight < 42)
							{
								SP.Destroy();
							}
							else
							{
								SP.Alliance = 'BarPatrons';
								SP.bFearWeapon = True;
								SP.bFearInjury = True;
								SP.bFearProjectiles = True;
							}
						}
					}
				}
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (JordanShea(SP) != None)
					{
						SP.bFearHacking = true;
						SP.bHateHacking = true;
						FoundFlag = true;
						break;
					}
				}
				
				if (FoundFlag)
				{
					forEach AllActors(class'Inventory', TInv)
					{
						if ((TInv.Owner == None) && (ItemIsLocation(TInv, Vect(-540, -502, 0)) || ItemIsLocation(TInv, Vect(-514, -499, 0))))
						{
							if (DeusExAmmo(TInv) != None)
							{
								DeusExAmmo(TInv).bOwned = true;
								DeusExAmmo(TInv).bSuperOwned = true;
							}
							else if (DeusExPickup(TInv) != None)
							{
								DeusExPickup(TInv).bOwned = true;
								DeusExPickup(TInv).bSuperOwned = true;
							}
							else if (DeusExWeapon(TInv) != None)
							{
								DeusExWeapon(TInv).bOwned = true;
								DeusExWeapon(TInv).bSuperOwned = true;
							}
						}
					}
				}
			}
		break;
		//04_NYC_BATTERYPARK: Broken trigger collision. Also, bad alliances.
		case "04_NYC_BATTERYPARK":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'AllianceTrigger', ATrig)
				{
					switch(SF.Static.StripBaseActorSeed(ATrig))
					{
						case 12:
						case 13:
						case 14:
							ATrig.SetCollision(False, False, False);
						break;
					}
				}
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (Robot(SP) != None)
					{
						SP.ChangeAlly('Gunther', 1.0, true, false);
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
