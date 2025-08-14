//=============================================================================
// Mission01.
//=============================================================================
class Mission01 extends MissionScript;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local AnnaNavarre Anna;
	local GuntherHermann Gunther;
	local PaulDenton Paul;
	local UNATCOTroop troop;
	local TerroristCommander cmdr;

	Super.FirstFrame();

	if (localURL == "01_NYC_UNATCOISLAND")
	{
		// delete Paul and company after final briefing
		if (flags.GetBool('M02Briefing_Played'))
		{
			foreach AllActors(class'PaulDenton', Paul)
				Paul.Destroy();
			foreach AllActors(class'UNATCOTroop', troop, 'custodytroop')
				troop.Destroy();
			foreach AllActors(class'TerroristCommander', cmdr, 'TerroristCommander')
				cmdr.Destroy();
		}
		
		// make Gunther drained of bio.
		foreach AllActors(class'GuntherHermann', Gunther)
		{
			if (!flags.GetBool('VMD_GuntherLibertyGoodies'))
			{
				Gunther.Energy = 0;
				flags.SetBool('VMD_GuntherLibertyGoodies', True,, 2);
			}
		}
	}
	
	else if (localURL == "01_NYC_UNATCOHQ")
	{
		// make Anna not flee in this mission
		foreach AllActors(class'GuntherHermann', Gunther)
		{
			if (!flags.GetBool('VMD_GuntherUNATCOGoodies'))
			{
				Gunther.Energy = 0;
				flags.SetBool('VMD_GuntherUNATCOGoodies', True,, 2);
			}
		}
		foreach AllActors(class'AnnaNavarre', Anna)
		{
			if (!flags.GetBool('VMD_AnnaUNATCO1Goodies'))
			{
				Anna.bAugsGuardDown = True;
				flags.SetBool('VMD_AnnaUNATCO1Goodies', True,, 2);
			}
		}
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	Super.PreTravel();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local int count;
	local Actor A;
	local AutoTurret turret;
	local DeusExMover M;
	local Inventory item, nextItem;
	local LaserTrigger laser;
	local PaulDenton Paul;
	local ScriptedPawn P;
	local SecurityCamera cam;
	local SpawnPoint SP;
	local Terrorist T;
	local TerroristCarcass carc;
	local ThrownProjectile TP;

	Super.Timer();

	if (localURL == "01_NYC_UNATCOISLAND")
	{
		if (!flags.GetBool('VMDStarterPicked'))
		{
			if (Player.FindInventoryType(class'WeaponGEPGun') != None)
			{
				Flags.SetBool('VMDStarterPicked', True,, 2);
				Flags.SetBool('VMDStarterWasGEPGun', True,, 2);
			}
			else if (Player.FindInventoryType(class'WeaponRifle') != None)
			{
				Flags.SetBool('VMDStarterPicked', True,, 2);
				Flags.SetBool('VMDStarterWasRifle', True,, 2);
			}
			else if (Player.FindInventoryType(class'WeaponMiniCrossbow') != None)
			{
				Flags.SetBool('VMDStarterPicked', True,, 2);
				Flags.SetBool('VMDStarterWasMiniCrossbow', True,, 2);
			}
		}
		
		// count the number of dead terrorists
		if (!flags.GetBool('M01PlayerAggressive'))
		{
			count = 0;

			// count the living
			foreach AllActors(class'Terrorist', T)
				count++;

			// add the unconscious ones to the not dead count
			// there are 28 terrorists total on the island
			foreach AllActors(class'TerroristCarcass', carc)
			{
				if ((carc.KillerBindName == "JCDenton") && (carc.bNotDead))
					count++;
				else if (carc.KillerBindName != "JCDenton")
					count++;
			}

			// if the player killed more than 5, set the flag
			if (count < 23)
				flags.SetBool('M01PlayerAggressive', True,, 6);		// don't expire until mission 6
		}

		// check for the leader being killed
		if (!flags.GetBool('MS_DL_Played'))
		{
			if (flags.GetBool('TerroristCommander_Dead'))
			{
				if (!flags.GetBool('DL_LeaderNotKilled_Played'))
					Player.StartDataLinkTransmission("DL_LeaderKilled");
				else
					Player.StartDataLinkTransmission("DL_LeaderKilledInSpite");

				flags.SetBool('MS_DL_Played', True,, 2);
			}
		}

		// check for player not killing leader
		if (!flags.GetBool('PlayerAttackedStatueTerrorist') &&
			flags.GetBool('MeetTerrorist_Played') &&
			!flags.GetBool('MS_DL2_Played'))
		{
			Player.StartDataLinkTransmission("DL_LeaderNotKilled");
			flags.SetBool('MS_DL2_Played', True,, 2);
		}

		// remove guys and move Paul
		if (!flags.GetBool('MS_MissionComplete'))
		{
			if (flags.GetBool('StatueMissionComplete'))
			{
				// open the HQ blast doors and unlock some other doors
				foreach AllActors(class'DeusExMover', M)
				{
					if (M.Tag == 'UN_maindoor')
					{
						M.bLocked = False;
						M.lockStrength = 0.0;
						M.Trigger(None, None);
					}
					else if ((M.Tag == 'StatueRuinDoors') || (M.Tag == 'temp_celldoor'))
					{
						M.bLocked = False;
						M.lockStrength = 0.0;
					}
				}
				
				//MADDERS, 3/26/25: UNATCO disables explosives on way in. Why wouldn't they?
				forEach AllActors(class'ThrownProjectile', TP)
				{
					if (TP.bProximityTriggered)
					{
						TP.bDisabled = true;
					}
				}
				
				// unhide the troop, delete the terrorists, Gunther, and teleport Paul
				foreach AllActors(class'ScriptedPawn', P)
				{
					if (P.IsA('UNATCOTroop') && (P.BindName == "custodytroop"))
						P.EnterWorld();
					else if (P.IsA('UNATCOTroop') && (P.BindName == "postmissiontroops"))
						P.EnterWorld();
					else if (P.IsA('ThugMale2'))
						P.Destroy();
					
					//MADDERS: As is common practice, EMP the bot for use with relevant datalink.
					else if (P.IsA('SecurityBot3'))
					{
						P.TakeDamage(1000, P, P.Location, vect(0,0,0), 'EMP');
						P.Alliance = 'NULL';
					}
					else if (P.IsA('Terrorist') && (P.BindName != "TerroristCommander"))
					{
						// actually kill the terrorists instead of destroying them
						P.HealthTorso = 0;
						P.Health = 0;
						P.TakeDamage(1000, P, P.Location, vect(0,0,0), 'Shot');

						// delete their inventories as well
						if (P.Inventory != None)
						{
							do
							{
								item = P.Inventory;
								nextItem = item.Inventory;
								P.DeleteInventory(item);
								item.Destroy();
								item = nextItem;
							}
							until (item == None);
						}
					}
					else if (P.BindName == "GuntherHermann")
						P.Destroy();
					else if (P.BindName == "PaulDenton")
					{
						SP = GetSpawnPoint('PaulTeleport');
						if (SP != None)
						{
							P.SetLocation(SP.Location);
							P.SetRotation(SP.Rotation);
							P.SetOrders('Standing',, True);
							P.SetHomeBase(SP.Location, SP.Rotation);
						}
					}
				}

				// delete all tagged turrets
				foreach AllActors(class'AutoTurret', turret)
					if ((turret.Tag == 'NSFTurret01') || (turret.Tag == 'NSFTurret02'))
						turret.Destroy();

				// delete all tagged lasertriggers
				foreach AllActors(class'LaserTrigger', laser, 'statue_lasertrap')
					laser.Destroy();

				// turn off all tagged cameras
				foreach AllActors(class'SecurityCamera', cam)
					if ((cam.Tag == 'NSFCam01') || (cam.Tag == 'NSFCam02') || (cam.Tag == 'NSFCam03'))
						cam.bNoAlarm = True;

				flags.SetBool('MS_MissionComplete', True,, 2);
			}
		}
	}
	else if (localURL == "01_NYC_UNATCOHQ")
	{
		// unhide Paul
		if (!flags.GetBool('MS_ReadyForBriefing'))
		{
			if (flags.GetBool('M01ReadyForBriefing'))
			{
				foreach AllActors(class'PaulDenton', Paul)
					Paul.EnterWorld();

				flags.SetBool('MS_ReadyForBriefing', True,, 2);
				
				//MADDERS, 11/17/24: Paul shows up and gives us an extra thanks, if we've been good boys and girls.
				if ((!Flags.GetBool('TerroristCommander_Dead')) && (!Flags.GetBool('M01PlayerAggressive')))
				{
					if (Flags.GetBool('VMDStarterWasGEPGun'))
					{
						A = Spawn(Class'Datacube',,, Vect(-178,1230,288), Rot(0,8192,0));
						if (A != None)
						{
							Datacube(A).TextPackage = "VMDText";
							Datacube(A).TextTag = '01_PaulThanks';
						}
						A = Spawn(class'AmmoRocketEMP',,, Vect(-155,1210,248), Rot(0,-6000,0));
					}
					else if (Flags.GetBool('VMDStarterWasRifle'))
					{
						A = Spawn(Class'Datacube',,, Vect(-178,1230,288), Rot(0,8192,0));
						if (A != None)
						{
							Datacube(A).TextPackage = "VMDText";
							Datacube(A).TextTag = '01_PaulThanks';
						}
						A = Spawn(class'Ammo3006Tranq',,, Vect(-155,1210,248), Rot(0,-6000,0));
					}
					else if (Flags.GetBool('VMDStarterWasMiniCrossbow'))
					{
						A = Spawn(Class'Datacube',,, Vect(-178,1230,288), Rot(0,8192,0));
						if (A != None)
						{
							Datacube(A).TextPackage = "VMDText";
							Datacube(A).TextTag = '01_PaulThanks';
						}
						A = Spawn(class'AmmoDartPoison',,, Vect(-155,1210,248), Rot(0,-6000,0));
						A = Spawn(class'Ammo10mmGasCap',,, Vect(-197,1210,248), Rot(0,6000,0));
					}
				}
			}
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
