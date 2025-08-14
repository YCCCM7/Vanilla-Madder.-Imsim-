//=============================================================================
// VMDMapFixerM06.
//=============================================================================
class VMDMapFixerM06 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//06_HONGKONG_HELIBASE: Tweak trigger for its arguable typo, but whatever
		case "06_HONGKONG_HELIBASE":
			if (!bRevisionMapSet)
			{
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					forEach AllActors(class'SkillAwardTrigger', SAT)
					{
						switch(SF.Static.StripBaseActorSeed(SAT))
						{
							case 1:
								SAT.Message = "Goddess shot!";
							break;
						}
					}
				}
			}
		break;
		//06_HONGKONG_WANCHAI_CANAL: Weird gripe: But abnormally strong piece of glass.
		//New state requires a swift kick, but it CAN be done without explosives.
		//Finally, let's shove some stuff around for LDDP interactions.
		case "06_HONGKONG_WANCHAI_CANAL":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 18:
							case 19:
								SetMoverFragmentType(DXM, "Glass");
								DXM.MinDamageThreshold = 25;
							break;
							case 84:
							case 85:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				forEach AllActors(class'DeusExDecoration', DXD)
				{	
					if (HKHangingLantern2(DXD) != None)
					{
						switch(SF.Static.StripBaseActorSeed(DXD))
						{
							case 6:
								DXD.Destroy();
							break;
						}
					}
				}
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (LowerClassMale2(SP) != None)
					{
						switch(SF.Static.StripBaseActorSeed(SP))
						{
							case 4:
								SP.SetLocation(vect(-1623, 1700, -367));
								SP.SetRotation(rot(0, -44128, 0));
								
								if (A != None)
								{
									A = Spawn(class'WHChairDining',,'MBChair', vect(-1671, 1641, -380), rot(0,-28000, 0));
									SP.SeatActor = Seat(A);
									SP.SetOrders('Sitting',, true);
								}
								
								OTrig = spawn(class'OrdersTrigger',,'GoGetJC', vect(-1402,2269,-287));
								if (OTrig != None)
								{
									OTrig.Orders = 'RunningTo';
									OTrig.Event = 'MarketBum1';
									OTrig.SetCollision(false, false, false);
								}
								FT = spawn(class'FlagTrigger',,, vect(-1567,2271,-440));
								if (FT != None)
								{
									FT.Event = 'GoGetJC';
									FT.bTrigger = true;
									FT.bSetFlag = false;
									FT.FlagValue = false;
									FT.FlagName = 'LDDPJCIsFemale';
								}
								FT = spawn(class'FlagTrigger',,, vect(-1567,2271,-440));
								if (FT != None)
								{
									FT.Event = 'GoGetJC';
									FT.bTrigger = true;
									FT.bSetFlag = false;
									FT.FlagValue = false;
									FT.FlagName = 'PaulDenton_Dead';
								}
							break;
						}
					}
				}
				
				forEach AllActors(class'Inventory', TInv)
				{
					if (TInv.Owner == None)
					{
						if (WineBottle(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 7:
								case 8:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (Liquor40Oz(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 0:
								case 1:
								case 2:
								case 7:
								case 8:
								case 9:
								case 10:
								case 11:
								case 12:
								case 13:
								case 14:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (LiquorBottle(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 6:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (SodaCan(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 8:
								case 9:
								case 10:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (CandyBar(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 1:
								case 2:
								case 3:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (Medkit(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 0:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (Credits(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 3:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
					}
				}
				forEach AllActors(class'VMDBufferDeco', VMD)
				{
					if (CrateBreakableMedGeneral(VMD) != None)
					{
						switch(SF.Static.StripBaseActorSeed(VMD))
						{
							case 0:
							case 6:
								VMD.bOwned = true;
								VMD.bSuperOwned = true;
							break;
						}
					}
					else if (CrateBreakableMedMedical(VMD) != None)
					{
						switch(SF.Static.StripBaseActorSeed(VMD))
						{
							case 4:
								VMD.bOwned = true;
								VMD.bSuperOwned = true;
							break;
						}
					}
					else if (Basket(VMD) != None)
					{
						switch(SF.Static.StripBaseActorSeed(VMD))
						{
							case 0:
							case 1:
							case 2:
								VMD.bOwned = true;
								VMD.bSuperOwned = true;
							break;
						}
					}
				}
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (LowerClassFemale(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							SP.bFearHacking = true;
							SP.bHateHacking = true;
						break;
					}
				}
				else if (Bartender(SP) != None)
				{
					SP.bFearHacking = true;
					SP.bHateHacking = true;
				}
			}
		break;
		//06_HONGKONG_WANCHAI_MARKET: Ya' know. The easter egg. And another one.
		//Also: One mover has a bad fragment class.
		case "06_HONGKONG_WANCHAI_MARKET":
			if (!bRevisionMapSet)
			{
				Spawn(class'WeaponModEvolution',,,vect(-162, -318, 389));
				Spawn(class'WeaponModEvolution',,,vect(-146, -318, 389));
				Spawn(class'WineBottle',,,vect(-321, -232, 16));
				
				CreateHallucination(vect(-620, 704, 100), 2, true);
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 0:
								if (MoverIsLocation(DXM, vect(0,688,0)))
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
							//Base: 0, 560, 0
							//Intended: -4, 560, 0
							//Rotation: 0
							case 1:
								if (MoverIsLocation(DXM, vect(0,560,0)))
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
							case 3:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
					}
				}
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPHKTourist", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPHKTourist',vect(2278,305,48));
						if (SP != None)
						{
							SP.UnfamiliarName = "Lost Tourist";
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
				}
			}
		break;
		case "06_HONGKONG_WANCHAI_COMPOUND":
			if (bRevisionMapSet)
			{
				CreateHallucination(vect(3620, 2060, 5), 2, true);
			}
		break;
		//06_HONGKONG_WANCHAI_STREET: Aw, screw it. Secondary easter egg for this unused vent,
		//which is arguably an easter egg on its own, given the skull's strange, comedic value.
		case "06_HONGKONG_WANCHAI_STREET":
			if (!bRevisionMapSet)
			{
				A = Spawn(class'Credits',,,vect(917.4, -1025.6, 135.7));
				if (A != None)
				{
					TRot = rot(-12000,-16384,0);
					A.DesiredRotation = TRot;
					A.SetRotation(A.DesiredRotation);
					A.bRotateToDesired = True;
					A.SetPhysics(PHYS_None);
					
					//Credits. Get it? Badum-Tss!
					A.Multiskins[0] = Texture'BogieJokeCreditChit';
					Credits(A).NumCredits = 42;
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(-1442,-1169,2022));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(-1436,-1195,2025);
					TCamp.MaxCampLocation = Vect(-1415,-1140,2073);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 61));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 62));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				A = FindActorBySeed(class'Button1', 0);
				if (A != None)
				{
					A.Event = 'JocksElevatorTop';
				}
				
				//MADDRES, 4/6/25: Broken elevator behavior. Fun times.
				A = FindActorBySeed(class'DeusExMover', 38);
				if (A != None)
				{
					DeusExMover(A).StayOpenTime = 4.0;
					A.GoToState('TriggerOpenTimed');
					A.Tag = 'eledoor03';
				}
				A = FindActorBySeed(class'Trigger', 2);
				if (A != None)
				{
					A.Event = 'eledoor03';
				}
				A = FindActorBySeed(class'Dispatcher', 8);
				if (A != None)
				{
					Dispatcher(A).OutEvents[0] = 'eledoor03';
				}
			}
			
			//9/11/21: Avert this disaster of junkie engaging every MJ12 troop for no reason.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (MaggieChow(SP) != None || JunkieFemale(SP) != None)
				{
					SP.bReactLoudNoise = false;
				}
			}
		break;
		//06_HONGKONG_WANCHAI_UNDERWORLD: Fix credits count on counter lady.
		case "06_HONGKONG_WANCHAI_UNDERWORLD":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (SP != None)
						{
							if (SP.Tag == 'ClubTessa' || SP.Tag == 'ClubMercedes')
							{
								SP.Destroy();
							}
							else if (Sailor(SP) != None)
							{
								switch(SF.Static.StripBaseActorSeed(SP))
								{
									case 4:
										SP.FamiliarName = "Misha";
										SP.UnfamiliarName = "Russian Sailor";
										SP.BindName = "LDDPRussianGuy";
										SP.ConBindEvents();
									break;
								}
							}
						}
					}
					
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPRuss", class'Class', true));
					if (SPLoad != None)
					{
						if (FlagTrigger(FindActorBySeed(class'FlagTrigger', 20)) != None)
						{
							FlagTrigger(FindActorBySeed(class'FlagTrigger', 20)).ClassProximityType = SPLoad;
						}
						SP = Spawn(SPLoad,,'LDDPRuss',vect(-1115,24,-336), rot(0,32760,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
							SP.BindName = "LDDPRuss";
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPHKClubGuy", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPHKClubGuy',vect(-1404,-1089,-336), rot(0,-7648,0));
						if (SP != None)
						{
							SP.HomeTag = 'Start';
							SP.SetOrders('Dancing',, true);
							SP.BarkBindName = "Man";
							SP.ConBindEvents();
						}
					}
				}
				
				//MADDERS, 7/1/24: DXT doesn't fix this flag trigger having collision. Huh.
				forEach AllActors(class'OrdersTrigger', OTrig)
				{
					switch(SF.Static.StripBaseActorSeed(OTrig))
					{
						case 4:
							OTrig.SetCollision(False, False, False);
						break;
					}
				}
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (SarahMead(SP) != None)
					{
						switch(SF.Static.StripBaseActorSeed(SP))
						{
							case 0:
								SP.SetLocation(Vect(-1540,-1608,-341));
							break;
						}
					}
				}
				
				forEach AllActors(class'Inventory', TInv)
				{
					if (TInv.Owner == None)
					{
						if (WineBottle(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 25:
								case 26:
								case 27:
								case 28:
								case 29:
								case 30:
								case 31:
								case 32:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (Liquor40Oz(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 42:
								case 43:
								case 44:
								case 45:
								case 46:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
						else if (Credits(TInv) != None)
						{
							switch(SF.Static.StripBaseActorSeed(TInv))
							{
								case 17:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								break;
							}
						}
					}
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
			}
		break;
		//06_HONGKONG_VERSALIFE: Toughen up our rogue door.
		//Also: Fix hundley's credit count, since it now operates off of a "NumCopies" basis.
		case "06_HONGKONG_VERSALIFE":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 4:
								DXM.MinDamageThreshold = 25;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPVersaEmp", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPVersaEmp',vect(215,1935,208));
						if (SP != None)
						{
							SP.SetOrders('Sitting',, true);
							SP.SeatActor = Seat(FindActorBySeed(class'OfficeChair', 32));
							SP.BarkBindName = "Man";
							SP.Alliance = 'Workers';
							SP.InitialAlliances[0].AllianceName = 'Player';
							SP.InitialAlliances[1].AllianceName = 'MJ12';
							SP.InitialAlliances[2].AllianceName = 'Workers';
							SP.ConBindEvents();
						}
					}
				}
			}
		break;
		//06_HONGKONG_MJ12LAB: Make maggie and bob invincible. No game breaking, please.
		//Additionally, fix some fragment classes.
		case "06_HONGKONG_MJ12LAB":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (MaggieChow(SP) != None || BobPage(SP) != None)
				{
					SP.bInvincible = True;
				}
				else if (MIB(SP) != None || WIB(SP) != None)
				{
					SP.ChangeAlly('Security', 1.0, true, false);
				}
				else if (MJ12Troop(SP) != None || MJ12Commando(SP) != None || MIB(SP) != None)
				{
					SP.bFearHacking = true;
					SP.bHateHacking = true;
					SP.ChangeAlly('MJ12', 1.0, true, false);
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
							//Base of -1648, -384, -688
							//Intended base of -1647, -379, -683.
							//Ignoring Z.
							//Rotation Yaw of 16384
							case 12:
								if (MoverIsLocation(DXM, vect(-1648,-384,-688)))
								{
									LocAdd = vect(1,5,0);
									PivAdd = vect(5,-1,0);
									FrameAdd[0] = vect(1,5,0);
									FrameAdd[1] = vect(1,5,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							
							//Base of -1648, -288, -688
							//Intended base of -1647, -289, -681.
							//Ignoring Z.
							//Rotation Yaw of 16384
							case 13:
								if (MoverIsLocation(DXM, vect(-1648,-288,-688)))
								{
									LocAdd = vect(1,-1,0);
									PivAdd = vect(-1,-1,0);
									FrameAdd[0] = vect(1,-1,0);
									FrameAdd[1] = vect(1,-1,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							
							case 55:
							case 56:
							case 57:
							case 58:
								SetMoverFragmentType(DXM, "Metal");
							break;
						}
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1062,-769,450));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(1030,-796,426);
					TCamp.MaxCampLocation = Vect(1052,-741,474);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 0));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(1174,-2095,449));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(1144,-2124,426);
					TCamp.MaxCampLocation = Vect(1164,-2069,474);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 61));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 62));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				//MADDERS, 4/24/24: Weird fix for and from DX rando folks.
				foreach AllActors(class'DeusExMover', DXM, 'security_doors')
				{
					DXM.bBreakable = false;
					DXM.bPickable = false;
				}
      				foreach AllActors(class'DeusExMover', DXM, 'Lower_lab_doors')
				{
					DXM.bBreakable = false;
					DXM.bPickable = false;
				}
				forEach AllActors(class'Inventory', TInv)
				{
					if (TInv.Owner == None)
					{
						//4/13/24: Stop using seeds on this so DX rando is more consistent.
						if (DeusExAmmo(TInv) != None)
						{
							//switch(SF.Static.StripBaseActorSeed(TInv))
							//{
								//case 0:
									DeusExAmmo(TInv).bOwned = true;
									DeusExAmmo(TInv).bSuperOwned = true;
								//break;
							//}
						}
						else if (AugmentationCannister(TInv) != None)
						{
							DeusExPickup(TInv).bOwned = true;
							DeusExPickup(TInv).bSuperOwned = true;
						}
						else if (BallisticArmor(TInv) != None)
						{
							//switch(SF.Static.StripBaseActorSeed(TInv))
							//{
								//case 1:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								//break;
							//}
						}
						else if (BioelectricCell(TInv) != None)
						{
							//switch(SF.Static.StripBaseActorSeed(TInv))
							//{
								//case 0:
								//case 6:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								//break;
							//}
						}
						else if (TechGoggles(TInv) != None)
						{
							//switch(SF.Static.StripBaseActorSeed(TInv))
							//{
								//case 0:
									DeusExPickup(TInv).bOwned = true;
									DeusExPickup(TInv).bSuperOwned = true;
								//break;
							//}
						}
						else if (DeusExWeapon(TInv) != None)
						{
							//switch(SF.Static.StripBaseActorSeed(TInv))
							//{
								//case 0:
									DeusExWeapon(TInv).bOwned = true;
									DeusExWeapon(TInv).bSuperOwned = true;
								//break;
							//}
						}
					}
				}
				forEach AllActors(class'VMDBufferDeco', VMD)
				{
					if (AlarmUnit(VMD) != None)
					{
						VMD.bOwned = true;
						VMD.bSuperOwned = true;
					}
					else if (CrateBreakableMedCombat(VMD) != None)
					{
						//switch(SF.Static.StripBaseActorSeed(VMD))
						//{
							//MADDERS, 4/13/24: Make all combat crates owned, for DX Rando compatability.
							//case 0:
							//case 1:
								VMD.bOwned = true;
								VMD.bSuperOwned = true;
							//break;
						//}
					}
				}
			}
		break;
	}
}

defaultproperties
{
}
