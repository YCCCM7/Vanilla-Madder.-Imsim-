//=============================================================================
// VMDMapFixerM09.
//=============================================================================
class VMDMapFixerM09 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//09_NYC_DOCKYARD: Fix the infamous infinite skill trigger.
		//5/24/23: Also, now fix this fragment class.
		case "09_NYC_DOCKYARD":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'SkillAwardTrigger', SAT)
				{
					if (SAT != None)
					{
						switch(SF.Static.StripBaseActorSeed(SAT))
						{
							case 10:
								if (SAT.Tag != 'BackGate')
								{
									SAT.Tag = 'BackGate';
								}
							break;
						}
					}
				}
				
				//MADDERS, 11/16/24: Add a box here, to prevent softlocks.
				Spawn(class'CrateUnbreakableSmall',,, Vect(4105, 2149, 24));
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 29:
								DXM.MinDamageThreshold = 50;
								SetMoverFragmentType(DXM, "Metal");
							break;
							case 31:
								SetMoverFragmentType(DXM, "Metal");
							break;
							case 34:
								DXM.GoToState('TriggerOpenTimed');
								DXM.StayOpenTime = 9999;
							break;
						}
					}
				}
			}
		break;
		//09_NYC_GRAVEYARD: Make the janitor invulnerable, so we can't kill him and bug the opening sequence.
		//This is god awful, but part of this is handlined in Mission09's script.
		//3/28/23: Also, make Dowd chill out just for extra measure. Why not?
		case "09_NYC_GRAVEYARD":
			if (!bRevisionMapSet)
			{
				PlugVect = Vect(17, 0, 25);
				for (i=388; i<444; i += 4)
				{
					PlugVect.Y = i;
					AddBSPPlug(PlugVect, 2, 24);
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
				else if (Janitor(SP) != None)
				{
					SP.bInvincible = true;
				}
			}
		break;
		//09_NYC_SHIP: Fix the infamous infinite skill trigger.
		case "09_NYC_SHIP":
			if (!bRevisionMapSet)
			{
				//MADDERS, 8/1/23: BSP hole in crate near PCS Wall Cloud. 
				AddBSPPlug(vect(-2720, -1264, -460), 45, 32);
				
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							//Base of 2336, -144, 464
							//Intended base of 2329, -144, 508.
							//Ignoring Z.
							//Rotation Yaw of -65536, but pitch of 32768, in a twist.
							case 26:
								if (MoverIsLocation(DXM, vect(2336,-144,464)))
								{
									LocAdd = vect(-7,0,0);
									PivAdd = vect(7,0,0);
									FrameAdd[0] = vect(-7,0,0);
									FrameAdd[1] = vect(-7,0,0);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
							DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
							DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
						}
							break;
							
							//Base: 2160, 128, 928
							//Intended: 2160, 124, 936
							//Rotation: -32768, 49152
							case 282:
								if (MoverIsLocation(DXM, vect(2160,128,928)))
								{
									LocAdd = vect(0,-4,8);
									PivAdd = vect(4,0,-8);
									FrameAdd[0] = vect(0,-4,8);
									FrameAdd[1] = vect(0,-4,8);
									DXM.SetLocation(DXM.Location + LocAdd);
									DXM.PrePivot = DXM.PrePivot + PivAdd;
									DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
									DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								}
							break;
						}
					}
				}
				forEach AllActors(class'Seat', TSeat)
				{
					if (OfficeChair(TSeat) != None)
					{
						UnRandoSeat(TSeat);
					}
				}
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					SP = ScriptedPawn(TPawn);
					if (Sailor(SP) != None)
					{
						SP.ChangeAlly('Guards', 1.0, true, false);
					}
					else if (HKMilitary(SP) != None)
					{
						SP.ChangeAlly('Sailors', 1.0, true, false);
					}
					else if (WaltonSimons(SP) != None)
					{
						DumbAllReactions(SP);
					}
				}
			}
		break;
		//09_NYC_SHIPBELOW: Bad door pivot.
		case "09_NYC_SHIPBELOW":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'DeusExMover', DXM)
				{
					if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
					{
						switch(SF.Static.StripBaseActorSeed(DXM))
						{
							case 24:
								if (MoverIsLocation(DXM, vect(-2544,-624,-128)))
								{
									LocAdd = vect(0,-4,0);
									PivAdd = vect(0,-4,0);
									FrameAdd[0] = vect(0,-4,0);
									FrameAdd[1] = vect(0,-4,0);
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
		break;
	}
}

defaultproperties
{
}
