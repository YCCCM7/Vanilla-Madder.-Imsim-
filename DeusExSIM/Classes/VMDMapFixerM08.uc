//=============================================================================
// VMDMapFixerM08.
//=============================================================================
class VMDMapFixerM08 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//08_NYC_STREET: Desist. Stop running away like a bitch. Also, adjust trigger for LDDP.
		case "08_NYC_STREET":
			if (!bRevisionMapSet)
			{
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
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (StantonDowd(SP) != None)
				{
					//MADDERS: Eliminate reactions here.
					DumbAllReactions(SP);
				}
				
				//MADDERS, 1/28/21: Friendly fire is off the charts.
				//MADDERS, 8/8/23: Just found out the real bug. Fuck me lmao.
				//You're not my buddy, guy.
				//You're not my guy, buddy.
				else if (UNATCOTroop(SP) != None)
				{
					SP.ChangeAlly('RiotCop', 1.0, true, false);
					SP.ChangeAlly('Robot', 1.0, true, false);
				}
				else if (RiotCop(SP) != None)
				{
					SP.ChangeAlly('Robot', 1.0, true, false);
					SP.ChangeAlly('UNATCO', 1.0, true, false);
				}
			}
		break;
		//08_NYC_HOTEL: Patrol points be :b:roke
		case "08_NYC_HOTEL":
			if (!bRevisionMapSet)
			{
				//MADDERS, 11/18/24: Mr Renton returns our lent gat in M08 silently.
				if ((VMP != None) && (VMP.LastGenerousWeaponClass != "NULL") && (!Flags.GetBool('GilbertRenton_Dead')))
				{
					LDXW = class<DeusExWeapon>(DynamicLoadObject(VMP.LastGenerousWeaponClass, class'Class', true));
					if (LDXW != None)
					{
						DXW = Spawn(LDXW,,, Vect(-730,-3146,109), Rot(0, 16384, 0));
						if (DXW != None)
						{
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
				
				forEach AllActors(class'PatrolPoint', Pat)
				{
					if (Pat != None)
					{
						switch(SF.Static.StripBaseActorSeed(Pat))
						{
							case 44:
								Pat.Tag = 'HotelPatrol2A';
								Pat.NextPatrol = 'HotelPatrol2B';
								StoredPats[0] = Pat;
							break;
							case 48:
								Pat.Tag = 'HotelPatrol2B';
								Pat.NextPatrol = 'HotelPatrol2C';
								StoredPats[1] = Pat;
							break;
							case 49:
								Pat.Tag = 'HotelPatrol2C';
								Pat.NextPatrol = 'HotelPatrol2A';
								StoredPats[2] = Pat;
							break;
						}
					}
				}
				//Let's try this *one* more time.
				for(i=0; i<3; i++)
				{
					if (StoredPats[i] != None)
					{
						StoredPats[i].PreBeginPlay();
					}
				}
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (RiotCop(SP) != None)
					{
						switch(SF.Static.StripBaseActorSeed(SP))
						{
							case 8:
								SP.SetOrders('Patrolling', 'HotelPatrol2A', true);
							break;
						}
					}
				}
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("DeusEx.BumMale2", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'BumMale2',vect(1499,-1590,112));
						if (SP != None)
						{
							SP.bCower = true;
							SP.BarkBindName = "Man";
							SP.BindName = "LDDPM08Bum";
							SP.UnfamiliarName = "Bum";
							SP.FamiliarName = "Bum";
							SP.ConBindEvents();
						}
					}
				}
			}
			else
			{
				//MADDERS, 11/18/24: Mr Renton returns our lent gat in M08 silently.
				if ((VMP != None) && (VMP.LastGenerousWeaponClass != "NULL") && (!Flags.GetBool('GilbertRenton_Dead')))
				{
					LDXW = class<DeusExWeapon>(DynamicLoadObject(VMP.LastGenerousWeaponClass, class'Class', true));
					if (LDXW != None)
					{
						DXW = Spawn(LDXW,,, Vect(-171,-3863,117), Rot(0, 16384, 0));
						if (DXW != None)
						{
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
			}
		break;
		//08_NYC_FREECLINIC: Microscope inside floor.
		case "08_NYC_FREECLINIC":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExDecoration', DXD)
				{	
					if (Microscope(DXD) != None)
					{
						switch(SF.Static.StripBaseActorSeed(SP))
						{
							case 1:
								DXD.Destroy();
								//DXD.SetPhysics(PHYS_Falling);
								//DXD.SetRotation(rot(0,0,0));
								//DXD.SetLocation(vect(707,-2392,-304));
							break;
						}
					}
				}
			}
		break;
		//08_NYC_UNDERGROUND: Fourth easter egg.
		case "08_NYC_UNDERGROUND":
			if (!bRevisionMapSet)
			{
				CreateHallucination(vect(-1103, -92, -828), 3, false);
			}
			else
			{
				CreateHallucination(vect(-1062, -94, -827), 3, false);
			}
		break;
		//08_NYC_BAR: LDDP stuff.
		case "08_NYC_BAR":
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
						SP = Spawn(SPLoad,,'LDDPBarFly',vect(-1958,-329,48), rot(0,-16392,0));
						if (SP != None)
						{
							SP.SetOrders('Wandering',, true);
							SP.BarkBindName = "Man";
							SP.UnfamiliarName = "Bar Fly";
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
						if ((TInv.Owner == None) && (ItemIsLocation(TInv, Vect(-517, -491, 0))))
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
					//No stealable items in Revision map set?
				}
			}
		break;
		//08_NYC_SMUG: LDDP convo base fix for the augumentation upgrade, courtesy of the boys at DX Rando
		case "08_NYC_SMUG":
			if (!bRevisionMapSet)
			{
			        FixConversationGiveItem(GetConversation('M08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
      				FixConversationGiveItem(GetConversation('FemJCM08MeetFordSchick'), "AugmentationUpgrade", None, class'AugmentationUpgradeCannister');
			}
		break;
	}
}

defaultproperties
{
}
