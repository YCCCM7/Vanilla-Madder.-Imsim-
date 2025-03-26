//=============================================================================
// VMDMapFixerM21.
//=============================================================================
class VMDMapFixerM21 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		case "21_TOKYO_BANK":
			//MADDERS, 4/3/24: Helios NG plus.
			NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(0, 395, -268), Rot(0, -16384, 0));
			if (NGPortal != None)
			{
				NGPortal.FlagRequired = 'Hacking_Played';
			}
		break;
		
		//+++++++++++++++++++++++
		//REDSUN Maps
		
		//21_OTEMACHILAB: Add food to be merciful
		case "21_OTEMACHILAB_1":
			//Candy near starting area, for generosity
			Spawn(class'CandyBar',,,vect(616.5, 389, 1), rot(0,-5200,0));
			
			//Medical room soyfood
			Spawn(class'SoyFood',,,vect(533, -527, 49), rot(0,0,0));
			
			//Gamer dude's soda
			Spawn(class'SodaCan',,,vect(-808.5, -291, 53), rot(0,0,0));
			Spawn(class'SodaCan',,,vect(-818, -295, 53), rot(0,13000,0));
			
			//Barracks table food
			Spawn(class'SoyFood',,,vect(1760, -1257.25, 31), rot(0,0,0));
			Spawn(class'CandyBar',,,vect(1764, -1284, 31), rot(0,-4640,0));
		break;
		
		//21_OTEMACHIKU: Pivot fixes out the fucking ass.
		case "21_OTEMACHIKU":
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					PivAdd = vect(0,0,0);
					LocAdd = vect(0,0,0);
					for(i=0; i<8; i++)
					{
						FrameAdd[i] = vect(0,0,0);
					}
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						//2nd door on entry; Slightly busted pivot
						case 9:
							FrameAdd[0] = vect(0,0,0);
							PivAdd = (vect(-1,0,0));
							LocAdd = vect(1,0,0);
							DXM.SetLocation(DXM.Location + LocAdd);
							DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
							DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
							DXM.PrePivot = DXM.PrePivot + PivAdd;
						break;
						//MADDERS, 7/2/24: Door gets stuck. It's crap.
						case 42:
							DXM.MoverEncroachType = ME_IgnoreWhenEncroach;
						break;
						//Vent into CD shop; Lots wrong here.
						case 44:
							FrameAdd[0] = vect(4,0,-0.05);
							FrameAdd[1] = vect(3,1,-1); //X is for forward/back
							PivAdd = (vect(4, 0, 1));
							LocAdd = FrameAdd[0];
							DXM.SetLocation(DXM.Location + LocAdd);
							DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
							DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
							DXM.PrePivot = DXM.PrePivot + PivAdd;
						break;
						//Sewer door; All sorts of fucked.
						case 50:
							FrameAdd[0] = vect(0,-5,0);
							FrameAdd[1] = vect(0,-5,4);
							PivAdd = (vect(-4, 0, 0));
							LocAdd = FrameAdd[0];
							DXM.SetLocation(DXM.Location + LocAdd);
							DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
							DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
							DXM.PrePivot = DXM.PrePivot + PivAdd;
						break;
						//Upstairs lobby; Door clips into wall.
						case 71:
							FrameAdd[1] = vect(0,-4,0);
							DXM.SetLocation(DXM.Location + LocAdd);
							DXM.KeyPos[0] = DXM.KeyPos[0] + FrameAdd[0];
							DXM.KeyPos[1] = DXM.KeyPos[1] + FrameAdd[1];
							DXM.PrePivot = DXM.PrePivot + PivAdd;
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
			//MADDERS, 5/31/22: We can step on these filler cleaner bots. JFC.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (Cleanerbot(SP) != None)
				{
					SP.bProjTarget = false;
					SP.bBlockPlayers = false;
				}
				else if (Chef(SP) != None)
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
		//21_TMGComplex: Fix this rogue turret.
		case "21_TMGComplex":
			/*forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = false;
				}
			}*/
		break;
		//21_HIBIYAPARK_TOWERS: Hide this mover, for the sake of exploration.
		//Also, fix these rogue turrets.
		case "21_HIBIYAPARK_TOWERS":
			/*forEach AllActors(class'AutoTurret', ATur)
			{
				if (ATur != None)
				{
					ATur.bActive = false;
				}
			}*/
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Class == Class'DeusExMover') && (!DXM.bMadderPatched))
				{
					switch(SF.Static.StripBaseActorSeed(DXM))
					{
						case 27:
							DXM.bHighlight = false;
						break;
					}
					DXM.bMadderPatched = true;
				}
			}
		break;
		//21_SHINJUKUSTATION: Sound volume gets fucked up for some players after travel.
		case "21_SHINJUKUSTATION":
			if (VMP != None)
			{
				VMP.SetInstantSoundVolume(byte(float(VMP.ConsoleCommand("get ini:Engine.Engine.AudioDevice SoundVolume"))));
				VMP.SetInstantMusicVolume(byte(float(VMP.ConsoleCommand("get ini:Engine.Engine.AudioDevice MusicVolume"))));
				VMP.SetInstantSpeechVolume(byte(float(VMP.ConsoleCommand("get ini:Engine.Engine.AudioDevice SpeechVolume"))));
			}
		break;
		//21_WEST_SHINJUKU: Bad cop placement with DXT meshes being used.
		case "21_WEST_SHINJUKU":
			//MADDERS, 5/31/22: We can step on these filler cleaner bots. JFC.
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if (Cop(SP) != None)
				{
					switch(SF.Static.StripBaseActorSeed(SP))
					{
						case 6:
							SP.SetLocation(Vect(1884, -1046, 128));
						break;
						case 20:
							SP.SetLocation(Vect(476, -1046, 128));
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
