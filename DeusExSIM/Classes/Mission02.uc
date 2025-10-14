//=============================================================================
// Mission02.
//=============================================================================
class Mission02 extends MissionScript;

var Keypad ClinicKeypad;

var MissionScriptIntegerMemory BatteryMem;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local AnnaNavarre Anna;
	local ScriptedPawn pawn;
	local Terrorist T;
	
	Super.FirstFrame();
	
	if (localURL == "02_NYC_BATTERYPARK")
	{
		// make Anna not flee in this mission
		foreach AllActors(class'AnnaNavarre', Anna)
		{
			if (!flags.GetBool('VMD_AnnaBatteryGoodies'))
			{
				Anna.bAugsGuardDown = True;
				Anna.AddToInitialInventory(class'BioelectricCell', 5);
				flags.SetBool('VMD_AnnaBatteryGoodies', True,, 3);
			}
		}
	}
	else if (localURL == "02_NYC_STREET")
	{
		flags.SetBool('M02StreetLoaded', True,, 3);

		// if you went to the warehouse without finishing the streets,
		// set some flags
		if (!flags.GetBool('MS_GuardsWandering') &&
			flags.GetBool('WarehouseDistrictEntered'))
		{
			if (!flags.GetBool('StreetOpened') ||
				!flags.GetBool('ClinicCleared'))
			{
				foreach AllActors(class'ScriptedPawn', pawn)
				{
					if (pawn.Tag == 'ClinicGuards')
						pawn.SetOrders('Wandering', '', True);
					else if (pawn.Tag == 'HotelGuards')
						pawn.SetOrders('Wandering', '', True);
				}
			}

			flags.SetBool('MS_GuardsWandering', True,, 3);
		}

		// Manderley will be disappointed if you don't finish the streets
		if (!flags.GetBool('M02ManderleyDisappointed') &&
			!flags.GetBool('BatteryParkComplete'))
		{
			flags.SetBool('M02ManderleyDisappointed', True,, 3);
		}

		// get rid of Sandra if you've talked to her already
		if (flags.GetBool('MeetSandraRenton_Played'))
		{
			foreach AllActors(class'ScriptedPawn', pawn)
				if (pawn.IsA('SandraRenton'))
					pawn.Destroy();
		}

		// unhide some hostages if you've rescued them
		if (flags.GetBool('EscapeSuccessful'))
		{
			foreach AllActors(class'ScriptedPawn', pawn)
			{
				if (pawn.IsA('BumMale') && (pawn.Tag == 'hostageMan'))
					pawn.EnterWorld();
				else if (pawn.IsA('BumFemale') && (pawn.Tag == 'hostageWoman'))
					pawn.EnterWorld();
			}
		}
	}
	else if (localURL == "02_NYC_BAR")
	{
		// unhide Sandra if you've talked to her already
		if (flags.GetBool('MeetSandraRenton_Played'))
		{
			foreach AllActors(class'ScriptedPawn', pawn)
				if (pawn.IsA('SandraRenton'))
				{
					pawn.EnterWorld();
					flags.SetBool('MS_SandraInBar', True,, 3);
				}
		}
	}
	else if (localURL == "02_NYC_SMUG")
	{
		// unhide Ford if you've rescued him
		if (flags.GetBool('FordSchickRescued'))
		{
			foreach AllActors(class'ScriptedPawn', pawn)
				if (pawn.IsA('FordSchick'))
					pawn.EnterWorld();

			flags.SetBool('SchickThankedPlayer', True);
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
	local DeusExMover Mover;
	
	if (localURL == "02_NYC_BATTERYPARK")
	{
		// if you leave without finishing, set some flags and remove the terrorists
		if (!flags.GetBool('MS_MapLeftEarly'))
		{
			if (!flags.GetBool('AmbrosiaTagged') ||
				!flags.GetBool('SubTerroristsDead'))
			{
				flags.SetBool('MS_MapLeftEarly', True,, 3);
			}
		}
	}
	else if (localURL == "02_NYC_UNDERGROUND")
	{
		// if you leave the level with Ford Schick, set a flag
		if (flags.GetBool('MS_FordFollowing') &&
			!flags.GetBool('FordSchick_Dead'))
		{
			flags.SetBool('FordSchickRescued', True,, 9);
		}
	}
	//MADDERS, 9/1/25: Doing some spicy work here with elevators to reset them as makes sense. Modified DXT 06 code.
	else if (localURL == "02_NYC_STREET" || localURL == "02_NYC_SMUG")
	{
		foreach AllActors(class'DeusExMover', Mover)
		{
			if (Mover.Tag == 'ElevatorButton')
			{
				Mover.InterpolateTo(0,0);  // Instantly go back to closed position
				Mover.Enable( 'Trigger' ); // Allow us to instantly reopen it.
			}
		}
	}
	
	Super.PreTravel();
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local int count, TerrieCount;
	local Actor A;
	local BlackHelicopter chopper;
	local BarrelAmbrosia barrel;
	local BumMale bum;
	local DeusExCarcass carc2;
	local Doctor doc;
	local GuntherHermann Gunther;
	local Pawn curPawn;
	local POVCorpse povCarcass;
	local SandraRenton Sandra;
	local ScriptedPawn pawn;
	local Terrorist T;
	local TerroristCarcass carc;
	local ThugMale thug;
	local ThugMale2 thug2;
	local UNATCOTroop guard, troop;
	
	//VMD Additions.
	local AllianceTrigger AllTrig;
	local MissionScriptIntegerMemory TMem;
	
	Super.Timer();
	
	if (localURL == "02_NYC_BATTERYPARK")
	{
		if ((Level.TimeSeconds > 2) && (!flags.GetBool('VMDCountedTerries')))
		{
			foreach AllActors(class'Terrorist', T, 'ClintonTerrorist')
			{
				TerrieCount++;
			}
			
			TMem = GetBatteryMem();
			if (TMem != None)
			{
				TMem.TrackedValue = TerrieCount;
			}
			flags.SetBool('VMDCountedTerries', True,, 3);
		}
		
		// after terrorists are dead, set guards to wandering
		if ((!flags.GetBool('BatteryParkSlaughter')) && (!flags.GetBool('CastleClintonCleared')))
		{
			count = 0;

			// count the number of living terrorists
			foreach AllActors(class'Terrorist', T, 'ClintonTerrorist')
				count++;

			// one way or another, the castle has been cleared
			if(count == 0)
			{
				// nothing to do here anymore, so wander
				for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
				{
					if (curPawn.Tag == 'ClintonGuard')
					{
						troop = UNATCOTroop(curPawn);
						if(troop != None)
							troop.SetOrders('Wandering', '', True);
					}
				}

				flags.SetBool('CastleClintonCleared', True,, 3);
			}

			// count the number of unconscious terrorists
			foreach AllActors(class'TerroristCarcass', carc, 'ClintonTerrorist')
				if (carc.bNotDead || carc.KillerBindName != "JCDenton")
					count++;

			//Check if the player is holding a terrorist carcass, that is either not dead or wasn't killed by the player.
			povCarcass = POVCorpse(player.inHand);
			
			if ((povCarcass != None) && (povCarcass.carcClassString ~= "DeusEx.TerroristCarcass") && (povCarcass.bNotDead || povCarcass.KillerBindName != "JCDenton"))
			{
				count++;
			}
			
			TMem = GetBatteryMem();
			//Bjorn: There are five terrorists in the Castle.
			// if there are three or less, then the player killed at least two.  For shame.
			//MADDERS, 4/21/25: TWeak for rando, so we have an accurate terrie count. Also works with infamy, if I'm not mistaken.
			if ((TMem != None) && (TMem.TrackedValue - count > 2) && (!flags.GetBool('BatteryParkSlaughter')))
			{
				// free up the guards so they can kill 'em
				for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
				{
					if(curPawn.Tag == 'ClintonGuard')
					{
						troop = UNATCOTroop(curPawn);
						if (troop != None)
							troop.SetOrders('Wandering', '', True);
					}
				}
				
				flags.SetBool('BatteryParkSlaughter', True,, 6);
			}
		}

		// set guards to wandering after sub terrorists are dead
		if (!flags.GetBool('SubTerroristsDead'))
		{
			count = 0;

			foreach AllActors(class'Terrorist', T, 'SubTerrorist')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', guard, 'SubGuards')
					guard.SetOrders('Wandering', '', True);

				Player.GoalCompleted('LiberateBatteryParkSubway');
				flags.SetBool('SubTerroristsDead', True,, 6);
			}
		}

		// check to see if hostages are dead
		if (!flags.GetBool('HostagesKilled') && flags.GetBool('SubHostageMale_Dead') &&
			flags.GetBool('SubHostageFemale_Dead'))
		{
			flags.SetBool('HostagesKilled', True,, 3);
		}

		// check a bunch of flags, and start a datalink
		if (!flags.GetBool('MS_MapLeftEarly') &&
			!flags.GetBool('MS_DL_Played'))
		{
			if (!flags.GetBool('SubTerroristsDead') &&
				flags.GetBool('EscapeSuccessful') &&
				!flags.GetBool('HostagesKilled'))
			{
				Player.StartDataLinkTransmission("DL_SubwayComplete3");
				flags.SetBool('MS_DL_Played', True,, 3);
			}
			else if (flags.GetBool('HostagesKilled'))
			{
				Player.StartDataLinkTransmission("DL_SubwayComplete2");
				flags.SetBool('MS_DL_Played', True,, 3);
			}
			else if (flags.GetBool('SubTerroristsDead') ||
				flags.GetBool('EscapeSuccessful'))
			{
				Player.StartDataLinkTransmission("DL_SubwayComplete");
				flags.SetBool('MS_DL_Played', True,, 3);
			}
		}

		if (!flags.GetBool('ShantyTownSecure'))
		{
			count = 0;

			// Transcended - Old, legecy
			foreach AllActors(class'Terrorist', T, 'ShantyTerrorists')
				count++;

			// Transcended - New, correct tag
			foreach AllActors(class'Terrorist', T, 'ShantyTerrorist')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', guard, 'SubGuards')
					guard.SetOrders('Wandering', '', True);
				flags.SetBool('ShantyTownSecure', True);
			}
		}
	}
	else if (localURL == "02_NYC_STREET")
	{
		//MADDERS, 9/11/2021: Identify terries and unatco fighting. Alter alliances accordingly.
		if (!flags.GetBool('VMDStreetAggroEngaged'))
		{
			count = 0;
			
			foreach AllActors(class'Terrorist', T)
			{
				if ((T != None) && (UNATCOTroop(T.Enemy) != None))
				{
					count++;
					break;
				}
			}
			foreach AllActors(class'UNATCOTroop', Guard)
			{
				if ((Guard != None) && (Terrorist(Guard.Enemy) != None))
				{
					count++;
					break;
				}
			}
			
			//MADDERS: This is kind of vomit, to be honest, but it's totally bulletproof.
			if (Count > 0)
			{
				forEach AllActors(Class'AllianceTrigger', AllTrig)
				{
					if (AllTrig != None)
					{
						switch(AllTrig.Event)
						{
							case 'StreetTerrorist':
							case 'LeadTerrorist':
							case 'ClinicTerrorist':
								AllTrig.Trigger(None, GetPlayerPawn());
							break;
						}
					}
				}
				flags.SetBool('VMDStreetAggroEngaged', True,, 6);
			}
		}

		// set guards to wandering after clinc terrorists are dead
		if (!flags.GetBool('ClinicCleared'))
		{
			count = 0;
			
			foreach AllActors(class'Terrorist', T, 'ClinicTerrorist')
				count++;
			
			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', guard, 'ClinicGuards')
					guard.SetOrders('Wandering', '', True);

				flags.SetBool('ClinicCleared', True,, 6);
			}
		}

		// set guards to wandering after street terrorists are dead
		if (!flags.GetBool('StreetOpened'))
		{
			count = 0;
			
			foreach AllActors(class'Terrorist', T, 'StreetTerrorist')
				count++;
			
			// Transcended - Added
			foreach AllActors(class'Terrorist', T, 'LeadTerrorist')
				count++;
			
			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', guard, 'HotelGuards')
					guard.SetOrders('Wandering', '', True);
				
				flags.SetBool('StreetOpened', True,, 6);
				
				//G-Flex: there are 6 relevant dudes now, counting LeadTerrorist, so check for him too.
				//G-Flex: if player killed 2 (was 3) or more, call it a slaughter
				//G-Flex: count terrorists that were only KO'd or weren't killed by JC
				foreach AllActors(class'TerroristCarcass', carc, 'StreetTerrorist')
				{
					if ((carc.KillerBindName != "JCDenton") || (carc.bNotDead))
						count++;
				}
				
				//count LeadTerrorist here too.
				foreach AllActors(class'TerroristCarcass', carc, 'LeadTerrorist')
					if ((carc.KillerBindName != "JCDenton") || (carc.bNotDead))
						count++;
				
				if (count <= 4)
					flags.SetBool('TenderloinSlaughter', True,, 6);
			}
		}

		// check to see if player rescued bum
		if (!flags.GetBool('MS_ThugsDead'))
		{
			count = 0;

			foreach AllActors(class'ThugMale2', thug2, 'AlleyThug')
				count++;

			// set the resuced flag if the bum is still alive
			if (count == 0)
			{
				foreach AllActors(class'BumMale', bum, 'AlleyBum')
					flags.SetBool('AlleyBumRescued', True,, 3);

				flags.SetBool('MS_ThugsDead', True,, 3);
			}
		}

		// if the pimp is dead, set a flag
		if (!flags.GetBool('SandrasPimpDone'))
		{
			count = 0;
			foreach AllActors(class'ThugMale', thug, 'Pimp')
				count++;

			if (count == 0)
			{
				flags.SetBool('SandrasPimpDone', True,, 3);
				Player.GoalCompleted('HelpJaneysFriend');
			}
		}

		// if Sandra is dead, set a flag
		if (!flags.GetBool('MS_SandraDead'))
		{
			count = 0;
			foreach AllActors(class'SandraRenton', Sandra)
				count++;

			if (count == 0)
			{
				flags.SetBool('MS_SandraDead', True,, 3);
				Player.GoalCompleted('HelpJaneysFriend');
			}
		}

		if (flags.GetBool('OverhearAlleyThug_Played') &&
			!flags.GetBool('MS_ThugAttacks'))
		{
			foreach AllActors(class'Actor', A, 'ThugAttacks')
				A.Trigger(Self, Player);

			flags.SetBool('MS_ThugAttacks', True,, 3);
		}
	}
	else if (localURL == "02_NYC_WAREHOUSE")
	{
		// start infolink after generator blown
		// also unhide the helicopter and Gunther on the roof
		if (!flags.GetBool('MS_GeneratorStuff'))
		{
			if (!flags.GetBool('DL_Pickup_Played') &&
				flags.GetBool('GeneratorBlown'))
			{
				Player.StartDataLinkTransmission("DL_Pickup");

				foreach AllActors(class'BlackHelicopter', chopper, 'Helicopter')
					chopper.EnterWorld();
				
				foreach AllActors(class'GuntherHermann', Gunther)
				{
					Gunther.EnterWorld();
					Gunther.bAugsGuardDown = True;
					Gunther.AddToInitialInventory(class'BioelectricCell', 10);
				}
				flags.SetBool('MS_GeneratorStuff', True,, 3);
			}
		}
	}
	else if (localURL == "02_NYC_FREECLINIC")
	{
		// make the bum disappear when he gets to his destination
		if (flags.GetBool('MS_BumLeaving') &&
			!flags.GetBool('MS_BumRemoved'))
		{
			foreach AllActors(class'BumMale', bum, 'SickBum1')
				if (bum.IsInState('Standing'))
					bum.Destroy();

			flags.SetBool('MS_BumRemoved', True,, 3);
			flags.DeleteFlag('MS_BumLeaving', FLAG_Bool);
		}

		// make the bum leave after talking to the doctor
		if (flags.GetBool('Doctor2_Saved') &&
			!flags.GetBool('MS_BumRemoved') &&
			!flags.GetBool('MS_BumLeaving'))
		{
			foreach AllActors(class'BumMale', bum, 'SickBum1')
				bum.SetOrders('GoingTo', 'SickBumDestination', True);

			flags.SetBool('MS_BumLeaving', True,, 3);
		}

		// make the bum face the doctor
		if (flags.GetBool('SickBumInterrupted_Played') &&
			!flags.GetBool('Doctor2_Saved') &&
			!flags.GetBool('MS_BumTurned'))
		{
			foreach AllActors(class'Doctor', doc, 'Doctor2')
				foreach AllActors(class'BumMale', bum, 'SickBum1')
				{
					bum.DesiredRotation = Rotator(doc.Location - bum.Location);
					break;
				}

			flags.SetBool('MS_BumTurned', True,, 3);
		}
		
		ClinicKeypad = GetClinicKeypad();
		if (Flags.GetBool('BoughtClinicPlan'))
		{
			if (ClinicKeypad != None)
			{
				ClinicKeypad.ValidCode = "2153";
			}
		}
		else
		{
			if (ClinicKeypad != None)
			{
				ClinicKeypad.ValidCode = "sup?";
			}
		}
	}
	else if (localURL == "02_NYC_BAR")
	{
		// if the player kills anybody in the bar, set a flag
		if (!flags.GetBool('M02ViolenceInBar'))
		{
			count = 0;

			foreach AllActors(class'DeusExCarcass', carc2)
				count++;

			if (count > 0)
				flags.SetBool('M02ViolenceInBar', True,, 4);
		}
	}
	else if (localURL == "02_NYC_HOTEL")
	{
		// if the player kills all the terrorists, set a flag
		if (!flags.GetBool('M02HostagesRescued'))
		{
			count = 0;

			foreach AllActors(class'Terrorist', T)
				if (T.Tag == 'SecondFloorTerrorist')
					count++;

			if (count == 0)
				flags.SetBool('M02HostagesRescued', True,, 3);
		}
	}
	else if (localURL == "02_NYC_UNDERGROUND")
	{
		if (flags.GetBool('FordSchick_Dead') &&
			!flags.GetBool('FordSchickRescueDone'))
		{
			flags.SetBool('FordSchickRescueDone', True,, 9);
		}
	}
}

function Keypad GetClinicKeypad()
{
	local Keypad2 TKeypad;
	
	if (ClinicKeypad != None) return ClinicKeypad;
	
	forEach AllActors(class'Keypad2', TKeypad)
	{
		if (class'VMDStaticFunctions'.Static.StripBaseActorSeed(TKeypad) == 0)
		{
			return TKeypad;
		}
	}
	
	return None;
}

function MissionScriptIntegerMemory GetBatteryMem()
{
	local PlayerPawn TPlayer;
	
	if (BatteryMem != None)
	{
		return BatteryMem;
	}
	
	forEach AllActors(class'MissionScriptIntegerMemory', BatteryMem, 'BatteryMem')
	{
		return BatteryMem;
	}
	
	TPlayer = GetPlayerPawn();
	if (TPlayer != None)
	{
		BatteryMem = Spawn(class'MissionScriptIntegerMemory',, 'BatteryMem', TPlayer.Location);
		return BatteryMem;
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
