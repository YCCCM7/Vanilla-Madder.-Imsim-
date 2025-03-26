//=============================================================================
// VMDMapFixerM01.
//=============================================================================
class VMDMapFixerM01 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//01_NYC_UNATCOISLAND: Add a datalink and fix lack of baton in GOTY.
		case "01_NYC_UNATCOISLAND":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (UNATCOTroop(SP) != None)
				{
					SP.ChangeAlly('Gunther', 1.0, true);
				}
				else if (SecurityBot2(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 3:
							SP.bHateDistress = false;
						break;
					}
					SP.ChangeAlly('Gunther', 1.0, true);
				}
				else if (PaulDenton(SP) != None)
				{
					SP.ChangeAlly('Gunther', 1.0, true);
				}
				else if (GuntherHermann(SP) != None)
				{
					SP.Alliance = 'Gunther';
					SP.ChangeAlly('Gunther', 1.0, true);
					SP.ChangeAlly('UNATCO', 1.0, true);
					GuntherHermann(SP).bAugsGuardDown = true;
				}
			}
			
			if (!bRevisionMapSet)
			{
				FoundFlag = false;
				forEach AllActors(class'WeaponBaton', Bat)
				{
					if ((Bat != None) && (IsApproximateLocation(Bat, vect(-2911, 6977, -239))))
					{
						FoundFlag = true;
					}
				}
				if (!FoundFlag)
				{
					Spawn(class'WeaponBaton',,,vect(-2911,6977,-239));
				}
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("DeusEx.UNATCOTroop", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'UNATCOTroop',vect(-4721,2039,-191), rot(0,-31072,0));
						if (SP != None)
						{
							SP.SetOrders('Standing',, true);
							SP.BindName = "LDDPPrivateNash";
							SP.BarkBindName = "UNATCOTroop";
							SP.Alliance = 'UNATCO';
							SP.InitialAlliances[0].AllianceName = 'Player';
							SP.InitialAlliances[0].AllianceLevel = 1.0;
							SP.ConBindEvents();
						}
						SP = Spawn(SPLoad,,'UNATCOTroop',vect(-4782,2023,-191), rot(0,35184,0));
						if (SP != None)
						{
							SP.SetOrders('Sitting','ChairLeather', true);
							SP.SeatActor = Seat(FindActorBySeed(class'ChairLeather', 2));
							SP.BindName = "LDDPPrivateWills";
							SP.BarkBindName = "UNATCOTroop";
							SP.Alliance = 'UNATCO';
							SP.InitialAlliances[0].AllianceName = 'Player';
							SP.InitialAlliances[0].AllianceLevel = 1.0;
							SP.ConBindEvents();
						}
					}
				}
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 16:
							case 17:
								DXM.bIsDoor = false;
							break;
						}
						DXM.bMadderPatched = true;
					}
				}
			}
		break;
		//01_NYC_UNATCOHQ: First easter egg, and return encroach type on Manderley's door.
		case "01_NYC_UNATCOHQ":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/17/24: Gunther gives us back our loaned weapon, with interest. Yay.
				if ((VMP != None) && (VMP.LastGenerousWeaponClass != "NULL"))
				{
					LDXW = class<DeusExWeapon>(DynamicLoadObject(VMP.LastGenerousWeaponClass, class'Class', true));
					if (LDXW != None)
					{
						A = Spawn(class'CrateUnbreakableSmall',,, vect(-397,1385,256), Rot(0, 8192, 0));
						A = Spawn(class'Datacube',,, vect(-397,1348,242));
						if (A != None)
						{
							Datacube(A).TextPackage = "VMDText";
							Datacube(A).TextTag = '01_GuntherThanks';
						}
						
						DXW = Spawn(LDXW,,, vect(-397,1385,276));
						if (DXW != None)
						{
							A = Spawn(class'WeaponModAccuracy',,, Vect(-397,1385,296));
							
							DXW.PickupAmmoCount = 0;
							
							if (VMP.LastGenerousWeaponModSilencer > 0) DXW.bHasSilencer = true;
							if (VMP.LastGenerousWeaponModScope > 0) DXW.bHasScope = true;
							if (VMP.LastGenerousWeaponModLaser > 0) DXW.bHasLaser = true;
							
							DXW.ModBaseAccuracy = VMP.LastGenerousWeaponModAccuracy;
							if (DXW.BaseAccuracy == 0.0)
							{
								DXW.BaseAccuracy -= DXW.ModBaseAccuracy;
							}
							else
							{
								DXW.BaseAccuracy -= (DXW.Default.BaseAccuracy * DXW.ModBaseAccuracy);
							}
							
							DXW.ModReloadCount = VMP.LastGenerousWeaponModReloadCount;
							Diff = Float(DXW.Default.ReloadCount) * DXW.ModReloadCount;
							DXW.ReloadCount += Max(Diff, DXW.ModReloadCount / 0.1);
							
							DXW.ModAccurateRange = VMP.LastGenerousWeaponModAccurateRange;
							DXW.RelativeRange += (DXW.Default.RelativeRange * DXW.ModAccurateRange);
							DXW.AccurateRange += (DXW.Default.AccurateRange * DXW.ModAccurateRange);
							
							DXW.ModReloadTime = VMP.LastGenerousWeaponModReloadTime;
							DXW.ReloadTime += (DXW.Default.ReloadTime * DXW.ModReloadTime);
							if (DXW.ReloadTime < 0.0) DXW.ReloadTime = 0.0;
							
							DXW.ModRecoilStrength = VMP.LastGenerousWeaponModRecoilStrength;
							DXW.RecoilStrength += (DXW.Default.RecoilStrength * DXW.ModRecoilStrength);
							
							if (VMP.LastGenerousWeaponModEvolution > 0)
							{
								DXW.bHasEvolution = true;
								DXW.VMDUpdateEvolution();
							}
						}
					}
					VMP.VMDClearGenerousWeaponData();
				}
				
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (SP != None)
					{
						SP.bFearHacking = false;
						SP.bHateHacking = false;
					}
				}
				
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(392,1097,303));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(364,1113,280);
					TCamp.MaxCampLocation = Vect(418,1133,328);
					TCamp.NumWatchedDoors = 2;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 1));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.CabinetDoors[1] = DeusExMover(FindActorBySeed(class'DeusExMover', 27));
					TCamp.CabinetDoorClosedFrames[1] = 0;
					TCamp.bLastOpened = true;
				}
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					A = Spawn(class'OrdersTrigger',,, Vect(225,184,32));
					if (A != None)
					{
						A.Event = 'LDDPChet';
						OrdersTrigger(A).Orders = 'Patrolling';
						OrdersTrigger(A).OrdersTag = 'ChetBathroomRoute01';
					}
					Pat = Spawn(class'PatrolPointMobile',,'ChetBathroomRoute01', Vect(253,275,7), Rot(0, 16080, 0));
					Pat.NextPatrol = 'ChetBathroomRoute02';
					Pat = Spawn(class'PatrolPointMobile',,'ChetBathroomRoute02', Vect(212,195,7), Rot(0, -608, 0));
					Pat.NextPatrol = 'ChetBathroomRoute01';
					VMP.VMDRebuildPaths();
					
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if (Female2(SP) != None)
						{
							SP.Destroy();
						}
					}
					
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPChet',vect(140,173,40));
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
				
				CreateHallucination(vect(-258, 1265, 290), 0, false);
			}
		break;
		//JH1_RITTERPARK: Alex freaks out.
		case "JH1_RITTERPARK":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (AlexJacobson(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							DumbAllReactions(SP);
						break;
					}
				}
			}
			
			forEach AllActors(class'NanoKey', Key)
			{
				switch(SF.Static.StripBaseActorSeed(Key))
				{
					case 0:
						Key.SetLocation(Vect(-131,456,-2089));
					break;
				}
			}
		break;
		//01_APARTMENTBUILDING: Bad mover positions, bad encroach types.
		case "01_APARTMENTBUILDING":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if (DXM.Class == Class'DeusExMover')
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 54:
						case 55:
						case 57:
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
						break;
						case 58:
						case 61:
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
							DXM.KeyPos[1].X *= -1;
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
		break;
		//01_TECHFORCEHQ: Chair inside desk. Sigh.
		case "01_TECHFORCEHQ":
			A = FindActorBySeed(class'OfficeChair', 18);
			if (A != None)
			{
				A.SetRotation(Rot(0, 16384, 0));
				A.SetLocation(Vect(-148, -966, -2534));
			}
		break;
	}
}

defaultproperties
{
}
