//=============================================================================
// VMDMapFixerM16.
//=============================================================================
class VMDMapFixerM16 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//+++++++++++++++++++++++
		//AGENDA Maps... We're secretly M16... Fuck you.
		
		//44_AGENDA10: CameraFOV is so prevalant in some rooms that you will be seen, regardless of camera rotation. Ugh.
		//Additionally, there's a broken door pivot... But the door is so busted it can't be fixed in post.
		case "44_AGENDA10":
			forEach AllActors(class'Actor', A)
			{
				if ((SecurityCamera(A) != None) && (SecurityCamera(A).CameraFOV > 6144))
				{
					SecurityCamera(A).CameraFOV = 6144;
				}
				if (ScriptedPawn(A) != None)
				{
					if (class<Weapon>(ScriptedPawn(A).InitialInventory[0].Inventory) == None)
					{
						ScriptedPawn(A).bReactLoudNoise = false;
					}
					//MADDERS, 2/9/25: Turn down our vertical noise sense even more.
					if (VMDBufferPawn(A) != None)
					{
						VMDBufferPawn(A).ReceiveNoiseHeightTolerance = 0.35;
						VMDBufferPawn(A).SendNoiseHeightTolerance = 0.35;
					}
				}
			}
			
			//MADDERS, 4/5/24: ANT Agenda NG plus. Leave it some distance away from teleporter.
			//6/20/24: Actually found a better way to do this lol.
			/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(2835, 2167, 876), Rot(0, -24576, 0));
			if (NGPortal != None)
			{
				NGPortal.FlagRequired = 'DL_Weisshaupt5_Played';
				NGPortal.bUnlit = true; //MADDERS, 4/5/24: Hack because we are easily lost in the dark.
			}*/
		break;
		
		//+++++++++++++++++++++++
		//Utopia Maps
		//UTOPIA_SUBWAY: Need NG Plus Portal
		case "UTOPIA_SUBWAY":
			//MADDERS, 3/1/25: Supremely fucked up door. Broken pivot, mismatched textures.
			//Most similar doorframes have no door at all in this map. It's for the best.
			/*A = FindActorBySeed(class'DeusExMover', 0);
			if (A != None)
			{
				A.SetLocation(A.Location + Vect(0, 0, 10000));
			}*/
			
			NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(105, 287, -28), Rot(0, 32768, 0));
		break;
		
		//+++++++++++++++++++++++
		//CARONE Maps
		
		//16_HOTELCARONE_INTRO: Mission number hack? Yeet.
		case "16_HOTELCARONE_INTRO":
			//MADDERS, 3/2/25: All this alcohol is fucked up.
			A = FindActorBySeed(class'WineBottle', 0);
			if (A != None)
			{
				A.SetPhysics(PHYS_None);
				A.SetRotation(Rot(-16384,0,0));
			}
			A = FindActorBySeed(class'LiquorBottle', 1);
			if (A != None)
			{
				A.SetPhysics(PHYS_None);
				A.SetRotation(Rot(0,-4892,-16384));
			}
			A = FindActorBySeed(class'LiquorBottle', 2);
			if (A != None)
			{
				A.SetPhysics(PHYS_None);
				A.SetRotation(Rot(0,-11424,-16384));
			}
			
			if (!GetFlagBool('mapdone'))
			{
				DXLI.MissionNumber = 15;
			}
			
			//MADDERS, 4/3/24: HC NG Plus.
			//6/20/24: Actually found a better way to do this lol.
			/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(8444, 29395, -8964), Rot(0, 0, 0));
			NGPortal.FlagRequired = 'MapDone';*/
		break;
		
		//16_HOTELCARONE_HOTEL: Hide alex's walls. Yeah. Work for it.
		//Additionally, there's at least 1 keypad with bad collision vs drawscale. RS2020 flashbacks.
		//Finally, there's some NPCs with vomit for names, so we gotta make it more human friendly, FFS.
		case "16_HOTELCARONE_HOTEL":
			forEach AllActors(class'Keypad', KP)
			{
				if (KP != None)
				{
					KP.SetCollisionSize(KP.Default.CollisionRadius * KP.Drawscale, KP.Default.CollisionHeight * KP.Drawscale);
				}
			}
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 93:
						case 161:
							//DXM.bHighlight = false;
						break;
						case 76:
						case 96:
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
						break;
						case 112:
							//Base of 1280, -5076, -5600
							//Needed of 1280, -5080, -5600
							//+++++++++++++++++++++++++++++++
							//Ignoring Z.
							//Rotation Yaw of 0
							if (MoverIsLocation(DXM, vect(1280,-5076,-5600)))
							{
								LocAdd = vect(0, -4, 0);
								PivAdd = vect(0, -4, 0);
								FrameAdd[0] = vect(0, -4, 0);
								FrameAdd[1] = vect(0, -4, 0);
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
			forEach AllActors(class'SkillAwardTrigger', SAT)
			{
				switch(SF.Static.StripBaseActorSeed(SAT))
				{
					case 2:
						SAT.AwardMessage = "Toilet girl is safe";
					break;
				}
			}
			forEach AllActors(class'Actor', A)
			{
				if (LightSwitch(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 1:
							A.SetRotation(Rot(0, 32768, 0));
						break;
					}
				}
			}
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (SP != None)
				{
					switch (SP.Class.Name)
					{
						case 'HKMilitary':
							switch(SF.Static.StripBaseActorSeed(SP))
							{
								case 0:
								case 1:
									SP.FamiliarName = "UNATCO Back Door Guard";
									SP.UnfamiliarName = SP.FamiliarName;
								break;
								case 2:
								case 3:
									SP.FamiliarName = "Terrorist Back Door Guard";
									SP.UnfamiliarName = SP.FamiliarName;
								break;
							}
						break;
						case 'Female1':
							switch(SF.Static.StripBaseActorSeed(SP))
							{
								case 0:
									SP.FamiliarName = "Toilet Girl";
									SP.UnfamiliarName = SP.FamiliarName;
								break;
							}
						break;
						case 'TerroristCommander':
							switch(SF.Static.StripBaseActorSeed(SP))
							{
								case 0:
							SP.FamiliarName = "Mr. Fish";
						break;
					}
				break;
			}
		}
			}
		break;
		//16_HOTELCARONE_HOUSE: Fix manderley's reactions. Ugh.
		case "16_HOTELCARONE_HOUSE":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (JosephManderley(SP) != None)
				{
					//MADDERS: Eliminate reactions here.
					DumbAllReactions(SP);
				}
			}
		break;
		//16_HOTELCARONE_DXD: Pimp our mr leiderhosen, and fix this stupid newspaper.
		case "16_HOTELCARONE_DXD":
			forEach AllActors(class'Actor', A)
			{
				if (NewspaperOpen(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 2:
							A.SetLocation(Vect(651, -1122, -1051));
							A.SetBase(FindActorBySeed(class'CoffeeTable', 0));
							A.SetPhysics(PHYS_None);
						break;
					}
				}
			}
			
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				/*if (JosephManderley(SP) != None)
				{
					//MADDERS: Eliminate reactions here.
					DumbAllReactions(SP);
				}*/
			}
		break;
		//16_THE_HQ: Broken door pivots galore.
		case "16_THE_HQ":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						//Base of 1120, 512, 64
						//Intended base of 1128, 512, 64.
						//Ignoring Z.
						//Rotation Yaw of 32768
						case 15:
							if (MoverIsLocation(DXM, vect(1120,512,64)))
							{
								LocAdd = vect(8,0,0);
								PivAdd = vect(-8,0,0);
								FrameAdd[0] = vect(8,0,0);
								FrameAdd[1] = vect(8,0,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
						//Base of 192, -896, -16
						//Intended base of 186, -896, -16.
						//Ignoring Z.
						//Rotation Yaw of 0
						//To fix bad placement, final loc of 188, 196, -16.
						//Another +2 X, in other words.
						case 36:
							if (MoverIsLocation(DXM, vect(192,-896,-16)))
							{
								LocAdd = vect(-4,0,0);
								PivAdd = vect(-6,0,0);
								FrameAdd[0] = vect(-4,0,0);
								FrameAdd[1] = vect(-4,0,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
						//Base of -1184, -800, -16
						//Intended base of -1180, -800, -12.
						//Ignoring Z.
						//Rotation Yaw of 0
						case 38:
							if (MoverIsLocation(DXM, vect(-1184,-800,-16)))
							{
								LocAdd = vect(4,0,0);
								PivAdd = vect(4,0,0);
								FrameAdd[0] = vect(4,0,0);
								FrameAdd[1] = vect(4,0,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
						//Base of -2368, -1236, -16
						//Intended base of -2368, -1244, -16.
						//Ignoring Z.
						//Rotation Yaw of 16384
						case 39:
							if (MoverIsLocation(DXM, vect(-2368,-1236,-16)))
							{
								LocAdd = vect(0,-8,0);
								PivAdd = vect(-8,0,0);
								FrameAdd[0] = vect(0,-8,0);
								FrameAdd[1] = vect(0,-8,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
						//Base of 608, -896, 0
						//Intended base of 604, -896, 0.
						//Ignoring Z.
						//Rotation Yaw of 0
						//Also, it's floating by 8 units ffs.
						case 41:
							if (MoverIsLocation(DXM, vect(608,-896,0)))
							{
								LocAdd = vect(-4,0,-8);
								PivAdd = vect(-4,0,0);
								FrameAdd[0] = vect(-4,0,-8);
								FrameAdd[1] = vect(-4,0,-8);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
					}
				}
			}
		break;
		//16_FATAL_WEAPON: Bad teleporter size. Sigh.
		case "16_FATAL_WEAPON":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (AlexJacobson(SP) != None || MargaretWilliams(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							DumbAllReactions(SP);
						break;
					}
				}
			}
			forEach AllActors(class'MapExit', MapEx)
			{
				if (MapEx != None)
				{
					switch(SF.Static.StripBaseActorSeed(MapEx))
					{
						case 0:
						case 1:
						case 2:
							MapEx.SetCollisionSize(65, MapEx.CollisionHeight);
						break;
					}
				}
			}
		break;
		
		//BEDROOM/BEDROOM_REMAKE: Alex freaks out.
		case "BEDROOM":
		case "BEDROOM_REMAKE":
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
		break;
	}
}

defaultproperties
}
