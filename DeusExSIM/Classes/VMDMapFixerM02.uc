//=============================================================================
// VMDMapFixerM02.
//=============================================================================
class VMDMapFixerM02 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//02_NYC_BATTERYPARK: Unlock the side access, to make it a truly naked solution.
		//Also: Large crates are inside the ground apparently, so WTF.
		case "02_NYC_BATTERYPARK":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 6:
								DXM.bLocked = false;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				forEach AllActors(class'DeusExDecoration', DXD)
				{
					if (CrateUnbreakableLarge(DXD) != None)
					{
						switch(SF.Static.StripBaseActorSeed(DXD))
						{
							case 16:
							case 17:
							case 18:
								DXD.SetLocation(DXD.Location + vect(0,0,16));
							break;
						}
					}
				}
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBatParkOldBum", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPBatParkOldbum',vect(2030,-3547,297), rot(0,-16408,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
							SP.BarkBindName = "Man";
							SP.UnfamiliarName = "Bum";
							SP.InitialAlliances[0].AllianceName = 'Player';
							SP.InitialAlliances[1].AllianceLevel = 1.0;
							SP.InitialAlliances[2].AllianceName = 'UNATCO';
							SP.InitialAlliances[2].bPermanent = True;
							SP.InitialAlliances[3].AllianceName = 'NSF';
							SP.InitialAlliances[3].AllianceLevel = -1.0;
							SP.ConBindEvents();
						}
					}
				}
			}
			//MADDERS, 8/7/25: No idea WTF is going on with these lasers, but make them player trigger only, like in vanilla.
			else
			{
				forEach AllActors(class'Actor', A)
				{
					if (BeamTrigger(A) != None)
					{
						BeamTrigger(A).TriggerType = TT_PlayerProximity;
					}
				}
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
		//02_NYC_BAR: LDDP stuff.
		case "02_NYC_BAR":
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
			
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPBarFly", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPBarFly',vect(-1308,319,52));
						if (SP != None)
						{
							SP.SetOrders('Sitting',, true);
							SP.BarkBindName = "Man";
							SP.UnfamiliarName = "Bar Fly";
							SP.SeatActor = Seat(FindActorBySeed(class'Chair1', 4));
							SP.FamiliarName = "Liam";
							SP.bFearWeapon = True;
							SP.bFearInjury = True;
							SP.bFearProjectiles = True;
							SP.ConBindEvents();
						}
					}
				}
				
				if (FoundFlag)
				{
					forEach AllActors(class'Inventory', TInv)
					{
						if ((TInv.Owner == None) && (ItemIsLocation(TInv, Vect(-519, -491, 0))))
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
			else
			{
				if (FoundFlag)
				{
					//No stealable items in Revision?
				}
			}
		break;
		//02_NYC_FREECLINIC: Balancing changes, baby.
		case "02_NYC_FREECLINIC":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 0:
								if (MoverIsLocation(DXM, Vect(672, -2350, -206)))
								{
									LocAdd = vect(0,0,2);
									PivAdd = vect(0,0,0);
									FrameAdd[0] = vect(0,0,2);
									FrameAdd[1] = vect(0,0,2);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 1:
								if (MoverIsLocation(DXM, Vect(672, -2258, -208)))
								{
									LocAdd = vect(0,0,2);
									PivAdd = vect(0,0,0);
									FrameAdd[0] = vect(0,0,2);
									FrameAdd[1] = vect(0,0,2);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 2:
								if (MoverIsLocation(DXM, Vect(765, -1288, -256)))
								{
									LocAdd = vect(-1,0,0);
									FrameAdd[0] = vect(-1,0,0);
									FrameAdd[1] = vect(-1,0,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 4:
							case 5:
								DXM.MinDamageThreshold = 8;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				if (FoundFlag)
				{
					forEach AllActors(class'Inventory', TInv)
					{
						if ((TInv.Owner == None) && (Medkit(TInv) != None))
						{
							Medkit(TInv).bOwned = true;
							Medkit(TInv).bSuperOwned = true;
						}
					}
				}
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if ((Doctor(SP) != None) || (Nurse(SP) != None))
				{
					SP.bFearHacking = true;
					SP.bHateHacking = true;
					FoundFlag = true;
				}
			}
		break;
		//02_NYC_HOTEL: LDDP stuff.
		case "02_NYC_HOTEL":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/17/24: Use this remote binding special phone.
				A = Spawn(class'PaulM02Phone',,, Vect(-610,-3244,96), Rot(0,32768,0));
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPHotelAddict", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPHotelAddict',vect(1868,-1333,112));
						if (SP != None)
						{
							SP.InitialInventory[0].Inventory = class'VialCrack';
						}
					}
				}
				
				//MADDERS, 11/18/24: Alternatively, Paul gives us some taser slugs for being a thoroughly cool dude.
				if ((Flags.GetBool('AmbrosiaTagged')) && (!Flags.GetBool('BatteryParkSlaughter')) && (!Flags.GetBool('SubHostageMale_Dead')) && (!Flags.GetBool('SubHostageFemale_Dead')))
				{
					A = Spawn(Class'Datacube',,, Vect(14,-2972,114));
					if (A != None)
					{
						Datacube(A).TextPackage = "VMDText";
						if (VMP == None || !VMP.bAssignedFemale)
						{
							Datacube(A).TextTag = '03_PaulThanks';
						}
						else
						{
							Datacube(A).TextTag = '03_PaulThanksFemale';
						}
					}
					A = Spawn(class'AmmoTaserSlug',,, Vect(-13,-2973,123), Rot(0,32768,0));
					A = Spawn(class'AmmoTaserSlug',,, Vect(15,-2947,123), Rot(0,-16384,0));
				}
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 9:
								//Rotation yaw of -16384
								//Base: 1424, -1680, 192
								//Desired: 1424, -1674, 192
								//----------------------
								//IGNORING Z
								if (MoverIsLocation(DXM, Vect(1424, -1680, 192)))
								{
									LocAdd = vect(0,6,0);
									PivAdd = vect(-6,0,0);
									FrameAdd[0] = vect(0,6,0);
									FrameAdd[1] = vect(0,6,0);
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
				//MADDERS, 11/18/24: Alternatively, Paul gives us some taser slugs for being a thoroughly cool dude.
				if ((Flags.GetBool('AmbrosiaTagged')) && (!Flags.GetBool('BatteryParkSlaughter')) && (!Flags.GetBool('SubHostageMale_Dead')) && (!Flags.GetBool('SubHostageFemale_Dead')))
				{
					//MADDERS, 8/7/25: Offset for Revision map.
					HackVect = Vect(544, -736, 0);
					
					A = Spawn(Class'Datacube',,, Vect(14,-2972,114) + HackVect);
					if (A != None)
					{
						Datacube(A).TextPackage = "VMDText";
						if (VMP == None || !VMP.bAssignedFemale)
						{
							Datacube(A).TextTag = '03_PaulThanks';
						}
						else
						{
							Datacube(A).TextTag = '03_PaulThanksFemale';
						}
					}
					A = Spawn(class'AmmoTaserSlug',,, Vect(-13,-2973,123) + HackVect, Rot(0,32768,0));
					A = Spawn(class'AmmoTaserSlug',,, Vect(15,-2947,123) + HackVect, Rot(0,-16384,0));
				}
			}
		break;
		//02_NYC_STREET: Bad fragment classes here. Oops. Also, update trigger with female equivalent.
		case "02_NYC_STREET":
			if (!bRevisionMapSet)
			{
				//MADDERS, 9/21/22: Aggravated by MEGH's inclusion, Paul is a dick and can very rarely end up shooting civilians.
				//Make him too docile to start unloading on civvies. Christ.
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (PaulDenton(SP) != None)
					{
						SP.bHateHacking = false;
						SP.bHateWeapon = false;
						SP.bHateShot = false;
						SP.bHateInjury = false;
						SP.bHateIndirectInjury = false;
						SP.bHateCarcass = false;
						SP.bHateDistress = false;
					}
					else if (UNATCOTroop(SP) != None)
					{
						SP.ChangeAlly('Thugs', -1.0, true);
					}
					else if (RiotCop(SP) != None)
					{
						SP.ChangeAlly('Thugs', -1.0, true);
						SP.ChangeAlly('NSF', -1.0, true);
					}
					//MADDERS, 4/28/25: Stop deleting all the terrorists when one dies. They all share the same bind name for fuck's sake.
					else if ((Terrorist(SP) != None) && (SP.BindName == SP.Default.BindName) && (SP.bImportant))
					{
						SP.bImportant = false;
					}
					else if (ThugMale(SP) != None || SandraRenton(SP) != None)
					{
						SP.bUseHome = true;
						SP.HomeLoc = SP.Location;
					}
				}
				
				//Adapt gender reference for LDDP.
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
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 7:
							case 20:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				forEach AllActors(class'OrdersTrigger', OTrig)
				{
					if (OTrig != None)
					{
						switch(SF.Static.StripBaseActorSeed(OTrig))
						{
							case 8:
								OTrig.SetCollisionSize(4.0, OTrig.CollisionHeight);
								OTrig.Event = 'PaulDenton';
							break;
						}
					}
				}
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPStreetLoser", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPRuss',vect(-2378,-202,-465), rot(0,5040,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
							SP.BindName = "LDDPStreetLoser";
							SP.BarkBindName = "ThugMale";
							SP.bReactLoudNoise = false;
							SP.bReactProjectiles = false;
							SP.bReactAlarm = false;
							SP.ConBindEvents();
						}
					}
				}
			}
			else
			{
				//MADDERS, 9/21/22: Aggravated by MEGH's inclusion, Paul is a dick and can very rarely end up shooting civilians.
				//Make him too docile to start unloading on civvies. Christ.
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (PaulDenton(SP) != None)
					{
						SP.bHateHacking = false;
						SP.bHateWeapon = false;
						SP.bHateShot = false;
						SP.bHateInjury = false;
						SP.bHateIndirectInjury = false;
						SP.bHateCarcass = false;
						SP.bHateDistress = false;
					}
					
					//MADDERS, 8/7/25: Redundant for Revision? We'll see.
					/*else if (UNATCOTroop(SP) != None)
					{
						SP.ChangeAlly('Thugs', -1.0, true);
					}
					else if (RiotCop(SP) != None)
					{
						SP.ChangeAlly('Thugs', -1.0, true);
						SP.ChangeAlly('NSF', -1.0, true);
					}
					//MADDERS, 4/28/25: Stop deleting all the terrorists when one dies. They all share the same bind name for fuck's sake.
					else if ((Terrorist(SP) != None) && (SP.BindName == SP.Default.BindName) && (SP.bImportant))
					{
						SP.bImportant = false;
					}
					else if (ThugMale(SP) != None || SandraRenton(SP) != None)
					{
						SP.bUseHome = true;
						SP.HomeLoc = SP.Location;
					}*/
				}
			}
		break;
		//02_NYC_UNDERGROUND: Fix the ford bug remotely. Yeet.
		case "02_NYC_UNDERGROUND":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'Actor', A)
				{
					if (OfficeChair(A) != None)
					{
						switch(SF.Static.StripBaseActorSeed(A))
						{
							case 2:
								UnRandoSeat(OfficeChair(A));
							break;
						}
					}
				}
				
				forEach AllActors(class'FlagTrigger', FT)
				{
					if (FT != None)
					{
						//Ford's flag isn't set right, notoriously.
						if (FT.FlagName == 'FordSchickRescueDone' || FT.FlagName == 'FordSchickRescued')
						{
							FT.FlagExpiration = 0;
						}
					}
				}
			}
		break;
		//02_NYC_WAREHOUSE: Fix a brick wall that is apparently now too tough.
		case "02_NYC_WAREHOUSE":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((BreakableWall(DXM) != None) && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 1:
								DXM.MinDamageThreshold = 60;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				
				//Beer inside ground. The little things, with me.
				forEach AllActors(class'Actor', A)
				{
					if (Liquor40Oz(A) != None)
					{
						switch(SF.Static.StripBaseActorSeed(Liquor40Oz(A)))
						{
							case 16:
								A.SetLocation(A.Location + vect(0,0,3));
							break;
						}
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
