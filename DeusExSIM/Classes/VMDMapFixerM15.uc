//=============================================================================
// VMDMapFixerM15.
//=============================================================================
class VMDMapFixerM15 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//15_AREA51_BUNKER: Slightly illogical login.
		case "15_AREA51_BUNKER":
			if (!bRevisionMapSet)
			{
				forEach AllActors(class'Computers', Comp)
				{
					if (ComputerSecurity(Comp) != None)
					{
						switch(SF.Static.StripBaseActorSeed(Comp))
						{
							case 1:
								Comp.UserList[0].UserName = "A51";
								Comp.UserList[0].Password = "xx15yz";
							break;
						}
					}
				}
			}
		break;
		//15_AREA51_ENTRANCE: Fix nabbable aug through the glass.
		case "15_AREA51_ENTRANCE":
			if (!bRevisionMapSet)
			{
				TCamp = Spawn(class'VMDCabinetCampActor',,, Vect(4805,484,-95));
				if (TCamp != None)
				{
					TCamp.MinCampLocation = Vect(4733,386,-130);
					TCamp.MaxCampLocation = Vect(4898,514,132);
					TCamp.NumWatchedDoors = 1;
					TCamp.CabinetDoors[0] = DeusExMover(FindActorBySeed(class'DeusExMover', 126));
					TCamp.CabinetDoorClosedFrames[0] = 0;
					TCamp.bIgnoreLockStatus = true;
					TCamp.bLastOpened = true;
					TCamp.bOpenOnceOnly = true; //Hack for the fact we can climb INTO this one.
				}
			}
		break;
		case "15_AREA51_FINAL":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				SP = ScriptedPawn(TPawn);
				if ((Mechanic(SP) != None) && (SF.Static.StripBaseActorSeed(SP) == 0))
				{
					SP.bReactLoudNoise = false;
					SP.bReactProjectiles = false;
					SP.bHateShot = false;
				}
			}
			
			if (!bRevisionMapSet)
			{
				//MADDERS, 4/3/24: Helios NG plus.
				NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-4001, 892, -1359), Rot(0, -16384, 0));
				if (NGPortal != None)
				{
					NGPortal.FlagRequired = 'HeliosFree';
				}
				
				//MADDERS, 4/3/24: A51 nuke NG plus.
				NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-3279, -4972, -1596) + Vect(0, 0, 16), Rot(0, -16384, 0));
				if (NGPortal != None)
				{
					NGPortal.FlagRequired = 'ReactorButton1';
				}
			}
			else
			{
				//MADDERS, 4/3/24: Helios NG plus.
				NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-3960, 966, -1347), Rot(0, -16384, 0));
				if (NGPortal != None)
				{
					NGPortal.FlagRequired = 'HeliosFree';
				}
				
				//MADDERS, 4/3/24: A51 nuke NG plus.
				NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(-3262, -5825, -1584) + Vect(0, 0, 32), Rot(0, -16384, 0));
				if (NGPortal != None)
				{
					NGPortal.FlagRequired = 'ReactorButton1';
				}
			}
		break;
		//15_Area51_Page: Turret rework, bby.
		case "15_AREA51_PAGE":
			forEach AllActors(class'AutoTurret', ATur)
			{
				ATur.bDisabled = false;
				ATur.bPreAlarmActiveState = true;
				ATur.bActive = true;
				
				//MADDERS, 1/31/21: We're inverted default turret state, since most mods can't keep it in their pants.
				//This is one of very few places where turrets are on by default.
				switch(SF.Static.StripBaseActorSeed(ATur))
				{
					case 1:
						if (AutoTurretSmall(ATur) != None)
						{
							ATur.MoverTag = 'turretman1';
							ATur.BeginPlay();
						}
					break;
				}
			}
			
			if (!bRevisionMapSet)
			{
				//MADDERS, 4/3/24: Bob page kill NG plus.
				NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(6268, -6537, -5140), Rot(0, 16384, 0));
				if (NGPortal != None)
				{
					NGPortal.FlagRequired = 'DL_Blue4_Played';
				}
			}
			else
			{
				//MADDERS, 4/3/24: Bob page kill NG plus.
				NGPortal = Spawn(class'VMDNGPlusPortal',,, Vect(99, 3069, 212) + Vect(0, 0, 16), Rot(0, 16384, 0));
				if (NGPortal != None)
				{
					NGPortal.FlagRequired = 'DL_Blue4_Played';
				}
			}
		break;
	}
}

defaultproperties
{
}
