//=============================================================================
// VMDMapFixerM22.
//=============================================================================
class VMDMapFixerM22 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//22_TOKYO_AQUA: Broke door pivot. Also, give Quick the boot.
		case "22_TOKYO_AQUA":
			//Broken door pivot to doggo room
			forEach AllActors(class'Actor', A)
			{
				DXM = DeusExMover(A);
				if (WineBottle(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 18:
						case 19:
						case 20:
						case 21:
							A.SetLocation(A.Location + Vect(0,0,9));
						break;
					}
				}
				else if (LiquorBottle(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 13:
						case 14:
						case 15:
						case 16:
							A.SetLocation(A.Location + Vect(0,0,6));
						break;
					}
				}
				else if ((DXM != None) && (DXM.Class == Class'DeusExMover'))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						//Base of -5632, 2432, -1120
						//Intended base of -5632, 2436, -1120
						//Ignoring Z.
						//Rotation Yaw of 16384, AND pitch of 32768, AND roll of 32768... What the fuck?
						//This is equivalent to 49152 yaw, though.
						//Also, this door sucks at how it moves.
						case 50:
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
							if (MoverIsLocation(DXM, vect(-5632,2432,-1120)))
							{
								LocAdd = vect(0,4,0);
								PivAdd = vect(-4,0,0);
								FrameAdd[0] = vect(0,4,0);
								FrameAdd[1] = vect(0,4,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
					}
				}
				//Gordon quick is awkwardly standing here and invincible, with no dialogue. Axe him.
				else if (GordonQuick(A) != None)
				{
					A.Destroy();
				}
			}
		break;
		//22_TOKYO_DISCO: Softlock for raising aggro before talking to Tomoko.
		case "22_TOKYO_DISCO":
			//MADDERS: Stop making us killable. This is also a vanilla issue.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (MaggieChow(SP) != None)
				{
					DumbAllReactions(SP);
				}
			}
		break;
		//22_KUROKUMA_BASE1: Remove silencer, and add a backup password for the bad font usage.
		case "22_KUROKUMA_BASE1":
			forEach AllActors(class'Computers', Comp)
			{
				if ((Comp != None) && (Comp.IsA('RS_ComputerSecurity')))
				{
					switch(SF.Static.StripBaseActorSeed(Comp))
					{
						case 0:
							Comp.UserList[1].UserName = "Basel_Security";
							Comp.UserList[1].Password = "Yakuzza1";
						break;
					}
				}
	
			}
			
			forEach AllActors(class'Actor', A)
			{
				//Duplicate aug can. Blank aug cans out the whazoo. Fuck's sake, RS2020.
				if (AugmentationCannister(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 1:
							AugmentationCannister(A).AddAugs[0] = 'AugAqualung';
							AugmentationCannister(A).AddAugs[1] = 'AugEMP';
						break;
					}
				}
			}
			
			//MADDERS: No silencer, please.
			forEach AllActors(class'DeusExWeapon', DXW)
			{
				if ((DXW != None) && (DXW.IsA('WeaponPistol')))
				{
					switch(SF.Static.StripBaseActorSeed(DXW))
					{
						case 0:
							DXW.bHasSilencer = false;
						break;
					}
				}
			}
		break;
		//22_KUROKUMA_HIDEOUT: Bad map transfer URL. Duplicate aug can. 2 blank aug cans. Broken door pivot.
		//Undersized button collision. 6 gas grenades that falsely detonate on map start and are hidden.
		//2 gas grenades with 10x their intended collision size for... Some reason. Random BSP hole. JFC.
		//This may genuinely be the worst map fix I ever have to do.
		case "22_KUROKUMA_HIDEOUT":
			//Oops. Improper Map URL.
			forEach AllActors(class'MapExit', MapEx)
			{
				if (MapEx != None)
				{
					switch(SF.Static.StripBaseActorSeed(MapEx))
					{
						case 2:
							MapEx.DestMap = "22_Kurokuma_Base2#Base2ExitElevator";
						break;
					}
				}
			}
			forEach AllActors(class'Actor', A)
			{
				//Duplicate aug can. Blank aug cans out the whazoo. Fuck's sake, RS2020.
				if (AugmentationCannister(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 0:
							AugmentationCannister(A).AddAugs[0] = 'AugBallistic';
							AugmentationCannister(A).AddAugs[1] = 'AugRadarTrans';
						break;
						case 2:
							AugmentationCannister(A).AddAugs[0] = 'AugHeartlung';
							AugmentationCannister(A).AddAugs[1] = 'AugDrone';
						break;
						case 5:
							A.Destroy();
						break;
					}
				}
				//Giant buttons with small collision. JFC.
				if (Button1(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 2:
						case 3:
						case 4:
						case 5:
						case 6:
						case 12:
							A.SetCollisionSize(A.Default.CollisionRadius * A.DrawScale, A.Default.CollisionHeight * A.DrawScale);
						break;
					}
				}
				if (GasGrenade(A) != None)
				{
					A.bHidden = false;
					A.SetCollisionSize(A.Default.CollisionRadius, A.Default.CollisionHeight);
					switch(SF.Static.StripBaseActorSeed(A))
					{
						//Not prox triggered. Oops.
						case 8:
							GasGrenade(A).bProximityTriggered = true;
							A.SetPhysics(PHYS_None);
							A.SetLocation(vect(634, -2541, -6935));
							A.SetRotation(rot(65536, 65536, 0));
						break;
						case 10:
							GasGrenade(A).bProximityTriggered = true;
							A.SetPhysics(PHYS_None);
							A.SetLocation(vect(636, -2367, -6982));
							A.SetRotation(rot(65536, 65536, 0));
						break;
						case 11:
							GasGrenade(A).bProximityTriggered = true;
							A.SetPhysics(PHYS_None);
							A.SetLocation(vect(636, -2787, -6938));
							A.SetRotation(rot(65536, 65536, 0));
						break;
						case 12:
							GasGrenade(A).bProximityTriggered = true;
							A.SetPhysics(PHYS_None);
							A.SetLocation(vect(636, -1905, -6956));
							A.SetRotation(rot(65536, 65536, 0));
						break;
						case 13:
							GasGrenade(A).bProximityTriggered = true;
							A.SetPhysics(PHYS_None);
							A.SetLocation(vect(636, -2178, -6917));
							A.SetRotation(rot(65536, 65536, 0));
						break;
						case 14:
							GasGrenade(A).bProximityTriggered = true;
							A.SetPhysics(PHYS_None);
							A.SetLocation(vect(636, -2864, -6900));
							A.SetRotation(rot(65536, 65536, 0));
						break;
					}
				}
			}
			//Broken door pivot to doggo room
			forEach AllActors(class'DeusExMover', DXM)
			{
				if (DXM.Class == Class'DeusExMover')
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						//Base of 176, -1856, -6912
						//Intended base of 170, -1856, -6911.
						//Ignoring Z.
						//Rotation Yaw of 49152 (3/4 spin)
						case 11:
							if (MoverIsLocation(DXM, vect(176,-1856,-6912)))
							{
								LocAdd = vect(-6,0,0);
								PivAdd = vect(0,6,0);
								FrameAdd[0] = vect(-6,0,0);
								FrameAdd[1] = vect(-6,0,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
					}
				}
			}
			AddBSPPlug(vect(-3474, -4089, -7154), 75.0, 2.0);
		break;
		//22_LOSTCITY: Bad door pivots, and DTS clipping through its box. "Circumcised", as one person called it, I believe.
		case "22_LOSTCITY":
			forEach AllActors(class'Actor', A)
			{
				//Clipping DTS. Ech. Drop it on the ground outside the box. Anything is an upgrade from phasing through shit.
				if (WeaponNanoSword(A) != None)
				{
					switch(SF.Static.StripBaseActorSeed(A))
					{
						case 0:
							A.SetLocation(vect(2130,1153,-741));
						break;
					}
				}
			}
			//Busted pivots ahoy.
			forEach AllActors(class'DeusExMover', DXM)
			{
				if (DXM.Class == Class'DeusExMover')
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						//Base of -896, -1040, -368
						//Intended -901, -1040, -367.
						//Ignoring Z.
						//Rotation Yaw of 32768 (1/2 spin)
						case 0:
							if (MoverIsLocation(DXM, vect(-896,-1040,-368)))
							{
								LocAdd = vect(-5,0,0);
								PivAdd = vect(5,0,0);
								FrameAdd[0] = vect(-5,0,0);
								FrameAdd[1] = vect(-5,0,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
						//Base of -2288, 320, -880
						//Intended -2288, 321, -880.
						//Ignoring Z.
						//Rotation Yaw of 32768 (1/2 spin)
						case 3:
							if (MoverIsLocation(DXM, vect(-2288,320,-880)))
							{
								LocAdd = vect(0,1,0);
								PivAdd = vect(0,-1,0);
								FrameAdd[0] = vect(0,1,0);
								FrameAdd[1] = vect(0,1,0);
								DXM.SetLocation(DXM.Location + LocAdd);
								DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
								DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
								DXM.PrePivot = DXM.PrePivot + PivAdd;
							}
						break;
						//Base of 496, 1056, -240
						//Intended 502, 1057, -240.
						//UPDATE: Aiming for 506, 1057, -240
						//Ignoring Z.
						//Rotation Yaw of 32768 (1/2 spin)
						case 4:
							if (MoverIsLocation(DXM, vect(496,1056,-240)))
							{
								LocAdd = vect(6,1,0)+vect(4,0,0);
								PivAdd = vect(-6,-1,0);
								FrameAdd[0] = vect(6,1,0)+vect(4,0,0);
								FrameAdd[1] = vect(6,1,0)+vect(4,0,0);
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
		case "22_TOKYOSTATION":
			forEach AllActors(class'CrateExplosiveSmall', CExpSmall)
			{
				switch(SF.Static.StripBaseActorSeed(CExpSmall))
				{
					case 0:
					case 1:
					case 2:
						CExpSmall.bHidden = true;
					break;
				}
			}
			
			//MADDERS, 4/3/24: Redsun NG plus. Just outside the bossfight.
			//6/20/24: Actually found a better way to do this lol.
			/*NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(2004, -9783, 426), Rot(0, -16384, 0));
			if (NGPortal != None)
			{
				NGPortal.FlagRequired = '';
			}*/
		break;
		case "22_OTEMACHIRETURN":
			VMP.InHand = None;
			VMP.InHandPending = None;
			
			//MADDERS, 5/31/22: Bad chef placement.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (Chef(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 0:
							SP.SetLocation(Vect(3333, -2481, -448));
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
