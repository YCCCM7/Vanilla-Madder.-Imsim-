//=============================================================================
// VMDMapFixerM05.
//=============================================================================
class VMDMapFixerM05 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//05_NYC_UNATCOMJ12LAB: Paul keeps losing his shit. We gotta stop this.
		case "05_NYC_UNATCOMJ12LAB":
			if (!bRevisionMapSet)
			{
				//MADDERS, 10/3/25: Can't be arsed to fix it via flag triggers, so have this weird tweak instead.
				A = Spawn(class'DestroyOtherTrigger',, 'BotOrders2', Vect(-4061, 1147, 171));
				DestroyOtherTrigger(A).DestructionTarget = FindActorBySeed(class'AllianceTrigger', 0);
				
				//Busted pivots ahoy.
				forEach AllActors(class'DeusExMover', DXM)
				{
					if (DXM.Class == Class'DeusExMover')
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							//Base of 2380, -900, -212
							//Intended 2384, -796, -212
							//Ignoring Z
							//Rotation Yaw of 32768 (1/2 spin)
							//FRAME 1: 20480 pitch
							//Corrected: 16384 pitch
							case 3:
								if (MoverIsLocation(DXM, vect(2380,-900,-212)))
								{
									LocAdd = vect(4,104,0);
									PivAdd = vect(-4,-104,0);
									FrameAdd[0] = vect(4,104,0);
									FrameAdd[1] = vect(4,104,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								}
							break;
							
							//Base position: 344,3580,-132
							//INTENDED base position: 344, 3576, -132
							//Ignoring Z.
							//Yaw of 49152 (3/4 spin)
							//FRAME 1: 20480 pitch
							//Corrected: 16384 pitch
							case 7:
								if (MoverIsLocation(DXM, vect(344,3580,-132)))
								{
									LocAdd = vect(0,4,0);
									PivAdd = vect(-4,0,0);
									FrameAdd[0] = vect(0,4,0);
									FrameAdd[1] = vect(0,4,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								}
							break;
							
							//Base position: 76,1708,92
							//INTENDED base position: 76, 1712, 92
							//Ignoring Z.
							//Yaw of 49152 (3/4 spin)
							//FRAME 1: 20480 pitch
							//Corrected: 16384 pitch
							case 11:
								if (MoverIsLocation(DXM, vect(76,1708,92)))
								{
									LocAdd = vect(0,4,0);
									PivAdd = vect(-4,0,0);
									FrameAdd[0] = vect(0,4,0);
									FrameAdd[1] = vect(0,4,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								}
							break;
							
							//Base position: 180, 1924, 92
							//INTENDED base position: 180, 1920, 92
							//Ignoring Z.
							//Yaw of 16384 (1/4 spin)
							//FRAME 1: 20480 pitch
							//Corrected: 16384 pitch
							case 12:
								if (MoverIsLocation(DXM, vect(180,1924,92)))
								{
									LocAdd = vect(0,-4,0);
									PivAdd = vect(-4,0,0);
									FrameAdd[0] = vect(0,-4,0);
									FrameAdd[1] = vect(0,-4,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
									DXM.KeyRot[1] = DXM.KeyRot[1] + Rot(-4096,0,0);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
								}
							break;
						}
					}
				}
			}
			forEach AllActors(class'SkillAwardTrigger', SAT)
			{
				switch(SF.Static.StripBaseActorSeed(SAT))
				{
					case 4:
						if (!Flags.GetBool('PaulDenton_Dead'))
						{
							SAT.SkillPointsAdded = 1000;
						}
						else
						{
							SAT.Destroy();
						}
					break;
				}
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (PaulDenton(SP) != None)
				{
					DumbAllReactions(SP);
					SP.ChangeAlly('MJ12', 1.0, true, false);
					SP.Alliance = 'MJ12';
				}
				else if (Terrorist(SP) != None)
				{
					SP.bReactLoudNoise = False;
				}
			}
		break;
		
		//05_NYC_UNATCOHQ: Bad pivot on cabinets, and encroach type on manderley's door.
		case "05_NYC_UNATCOHQ":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 1:
								//----------------------------------
								//EXAMPLE OF PIVOT FIX METHOD:
								//----------------------------------
								//+++Original location+++
								//Loc 416, 1104, 288
								//+++Desired location+++
								//Loc 420, 1108, 280
								if (MoverIsLocation(DXM, vect(416,1104,288)))
								{
									//Add intended offset to the location, and do the same to the frames.
									LocAdd = vect(4,4,-8);
									//Rotation is 90 degrees counter clockwise. X becomes -Y, Y becomes X, -X becomes Y, etc.
									//Use prepivot to tweak the offset all the same
									PivAdd = vect(-4,4,-8);
									FrameAdd[0] = vect(4,4,-8);
									FrameAdd[1] = vect(4,4,-8);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
							case 10:
								DXM.MoverEncroachType = ME_ReturnWhenEncroach;
							break;
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
				
				//MADDERS, 11/1/21: LDDP branching functionality.
				if ((Flags != None) && (Flags.GetBool('LDDPJCIsFemale')))
				{
					SPLoad = class<ScriptedPawn>(DynamicLoadObject("FemJC.LDDPChet", class'Class', true));
					if (SPLoad != None)
					{
						SP = Spawn(SPLoad,,'LDDPChet',vect(76, 1860,288), rot(0,16640,0));
						if (SP != None)
						{
							SP.SetOrders('Sitting',, true);
							SP.SeatActor = Seat(FindActorBySeed(class'ChairLeather', 0));
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
						case 1:
							VendingMachine(ED).AdvancedUses[0]++;
							VendingMachine(ED).bOrangeGag = true;
						break;
					}
				}
			}
			
			//03/28/23: Make alex stop freaking out about combat in UNATCO HQ. Saves a lot of hassle.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (AlexJacobson(SP) != None)
				{
					//MADDERS: Eliminate reactions here.
					DumbAllReactions(SP);
					SP.Alliance = 'GoodGuyUNATCO';
					SP.ChangeAlly('GoodGuyUNATCO', 1.0, true);
					SP.ChangeAlly('UNATCO', 1.0, true);
				}
				else if (JaimeReyes(SP) != None)
				{
					SP.Alliance = 'GoodGuyUNATCO';
					SP.ChangeAlly('GoodGuyUNATCO', 1.0, true);
					SP.ChangeAlly('UNATCO', 1.0, true);
				}
				else if (SamCarter(SP) != None)
				{
					SP.Alliance = 'GoodGuyUNATCO';
					SP.ChangeAlly('GoodGuyUNATCO', 1.0, true);
					SP.ChangeAlly('UNATCO', 1.0, true);
				}
				else if ((SP != None) && (SP.Alliance == 'UNATCO'))
				{
					SP.ChangeAlly('GoodGuyUNATCO', 1.0, true);
				}
			}
		break;
	}
}

defaultproperties
{
}
