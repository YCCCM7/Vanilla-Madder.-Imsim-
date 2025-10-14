//=============================================================================
// Mission04.
//=============================================================================
class Mission04 extends MissionScript;

var vector PlayerLocation;
var rotator PlayerRotation;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local ScriptedPawn pawn;

	Super.FirstFrame();

	// Transcended - Requested flag for MJ12 Troop barks
	if (!flags.GetBool('M4MissionStart'))
		flags.SetBool('M4MissionStart', True,, 16);
	
	//MADDERS, 12/28/23: Load this baby up with cells for the coming fight.
	if (LocalURL == "04_NYC_BATTERYPARK")
	{
		forEach AllActors(class'ScriptedPawn', Pawn)
		{
			if ((AnnaNavarre(Pawn) != None) && (!flags.GetBool('VMD_AnnaSubwayGoodies')))
			{
				AnnaNavarre(Pawn).AddToInitialInventory(class'BioelectricCell', 5);
				flags.SetBool('VMD_AnnaSubwayGoodies', True,, 5);
			}
		}
	}
	if (localURL == "04_NYC_STREET")
	{
		// unhide a bunch of stuff on this flag
		if (flags.GetBool('TalkedToPaulAfterMessage_Played'))
		{
			foreach AllActors(class'ScriptedPawn', pawn)
				if (pawn.IsA('UNATCOTroop') || pawn.IsA('SecurityBot2'))
					pawn.EnterWorld();
		}
	}
	else if (localURL == "04_NYC_FREECLINIC")
	{
		// unhide a bunch of stuff on this flag
		if (flags.GetBool('TalkedToPaulAfterMessage_Played'))
		{
			foreach AllActors(class'ScriptedPawn', pawn)
				if (pawn.IsA('UNATCOTroop'))
					pawn.EnterWorld();
		}
	}
	else if (localURL == "04_NYC_HOTEL")
	{
		// unhide the correct JoJo
		if (flags.GetBool('SandraRenton_Dead') ||
			flags.GetBool('GilbertRenton_Dead'))
		{
			if (!flags.GetBool('JoJoFine_Dead'))
				foreach AllActors(class'ScriptedPawn', pawn, 'JoJoInLobby')
					pawn.EnterWorld();
		}
	}
	else if (localURL == "04_NYC_SMUG")
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
	local int count;
	local DeusExMover Mover;
	
	// If the hotel is clear of hostiles when the player leaves through the window,
	//  remove the "Player Bailed" flag so Paul doesn't wind up dead anyway
	if (localURL == "04_NYC_HOTEL" && flags.GetBool('M04RaidTeleportDone'))
	{
		CheckPaulWellbeing();
	}
	else if(localURL == "04_NYC_BATTERYPARK") // Transcended - Ported
	{
		//Bjorn: Check if player is doing a cinematic or dying in this map, otherwise it's a level transition back to NYC_Street.
		if (player.IsInState('Interpolating') || player.IsInState('Dying'))
		{
			//Bjorn: Also make sure to stop drugs or poison before going to MJ12 HQ.
			player.drugEffectTimer = 0;
			player.StopPoison();
			
			//MADDERS, 8/9/25: Missing prior annotation, but do some KO elimination here.
			if (Flags.GetBool('AnnaNavarre_Unconscious'))
			{
				Flags.SetBool('AnnaNavarre_Unconscious', False,, 6);
				Flags.SetBool('AnnaNavarre_Dead', False,, 6);
			}
			if (Flags.GetBool('JordanShea_Unconscious'))
			{
				Flags.SetBool('JordanShea_Unconscious', False,, 6);
				Flags.SetBool('JordanShea_Dead', False,, 6);
				Flags.SetBool('VMDPlayerCrossedJordanShea', True,, 9);
			}
			
			if (!Player.IsA('GreaselPlayer'))
			{
				for(count=0; count < 10; count++)
				{
					if(DeusExRootWindow(Player.rootWindow).hud.belt.objects[count].GetItem() != None && !DeusExRootWindow(Player.rootWindow).hud.belt.objects[count].GetItem().IsA('NanoKeyRing'))
					{
						DeusExRootWindow(Player.rootWindow).hud.belt.objects[count].GetItem().bInObjectBelt = False;
						DeusExRootWindow(Player.rootWindow).hud.belt.objects[count].GetItem().beltPos = -1;
					}
				}
				DeusExRootWindow(Player.rootWindow).hud.belt.ClearBelt();
			}
		}
	}
	//MADDERS, 9/1/25: Doing some spicy work here with elevators to reset them as makes sense. Modified DXT 06 code.
	else if (localURL == "04_NYC_STREET" || localURL == "04_NYC_SMUG")
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
	local ScriptedPawn pawn;
	local SatelliteDish dish;
	local SandraRenton Sandra;
	local GilbertRenton Gilbert;
	local GilbertRentonCarcass GilbertCarc;
	local SandraRentonCarcass SandraCarc;
	local UNATCOTroop troop;
	local Actor A;
	local PaulDenton Paul;
	local int count;
	local ThrownProjectile grenades;
	local DeusExMover m;
	local float yPosition;
	local pawn curPawn;
	local JCDouble JCDouble;
	
	local DeusExRootWindow DXRW;
	local Inventory TItem;
	local VMDBufferPlayer VMP;
	local name UseTag;
	local bool bConvoWon;

	Super.Timer();
	
	if (Flags == None || Player == None) return;
	VMP = VMDBufferPlayer(Player);
	
	// do this for every map in this mission
	// if the player is "killed" after a certain flag, he is sent to mission 5
	if (!flags.GetBool('MS_PlayerCaptured'))
	{
		if (flags.GetBool('TalkedToPaulAfterMessage_Played'))
		{
			if ((Player != None) && (Player.IsInState('Dying')) && (!flags.GetBool('MS_ClonePlaced')))
			{
				PlayerLocation = Player.Location;
				PlayerRotation = Player.Rotation;
				
				//MADDERS, 8/9/25: Missing prior annotation, but do some KO elimination here.
				if (Flags.GetBool('AnnaNavarre_Unconscious'))
				{
					Flags.SetBool('AnnaNavarre_Unconscious', False,, 6);
					Flags.SetBool('AnnaNavarre_Dead', False,, 6);
				}
				if (Flags.GetBool('JordanShea_Unconscious'))
				{
					Flags.SetBool('JordanShea_Unconscious', False,, 6);
					Flags.SetBool('JordanShea_Dead', False,, 6);
					Flags.SetBool('VMDPlayerCrossedJordanShea', True,, 9);
				}
				
				flags.SetBool('MS_PlayerCaptured', True,, 5);
				Player.GoalCompleted('EscapeToBatteryPark');
				if ((Level != None) && (Level.Game != None))
				{
					Level.Game.SendPlayer(Player, "05_NYC_UNATCOMJ12Lab");
				}
			}
			if ((Player.IsInState('Dying')) && (!Player.IsAnimating())) // Transcended - Allow death animation to finish so it's not on the same frame they die
			{				
				if (localURL == "04_NYC_HOTEL")
					CheckPaulWellbeing();
				
				//MADDERS, 8/9/25: Missing prior annotation, but do some KO elimination here.
				if (Flags.GetBool('AnnaNavarre_Unconscious'))
				{
					Flags.SetBool('AnnaNavarre_Unconscious', False,, 6);
					Flags.SetBool('AnnaNavarre_Dead', False,, 6);
				}
				if (Flags.GetBool('JordanShea_Unconscious'))
				{
					Flags.SetBool('JordanShea_Unconscious', False,, 6);
					Flags.SetBool('JordanShea_Dead', False,, 6);
					Flags.SetBool('VMDPlayerCrossedJordanShea', True,, 9);
				}
				
				// Transcended - Ported
				//== Clear out the object belt now; otherwise the player will see their items being "confiscated" when they wake up in prison
				if (!Player.IsA('GreaselPlayer'))
				{
					DXRW = DeusExRootWindow(Player.RootWindow);
					if ((DXRW != None) && (DXRW.HUD != None) && (DXRW.HUD.Belt != None))
					{
						for(count=0; count < 10; count++)
						{
							if (DXRW.HUD.Belt.Objects[count] != None)
							{
								TItem = DXRW.HUD.Belt.Objects[count].GetItem();
								if ((TItem != None) && (!TItem.IsA('NanoKeyRing')))
								{
									TItem.bInObjectBelt = False;
									TItem.beltPos = -1;
								}
							}
						}
						DXRW.HUD.Belt.ClearBelt();
					}
				}
				flags.SetBool('MS_PlayerCaptured', True,, 5);
				Player.GoalCompleted('EscapeToBatteryPark');
				if ((Level != None) && (Level.Game != None))
				{
					Level.Game.SendPlayer(Player, "05_NYC_UNATCOMJ12Lab");
				}
			}
			// Spawn a copy of JC where he was
			else if ((player.IsInState('Interpolating')) && (!flags.GetBool('MS_ClonePlaced')))
			{
				JCDouble = Spawn(class'JCDouble', None,, PlayerLocation, PlayerRotation);
				if (JCDouble != None)
				{
					JCDouble.SetOrders('Standing',, True);
				}
				flags.SetBool('MS_ClonePlaced', True,, 5);
			}
		}
	}
	
	if (localURL == "04_NYC_HOTEL")
	{
		// check to see if the player has killed either Sandra or Gilbert
		if (!flags.GetBool('PlayerKilledRenton'))
		{
			count = 0;
			foreach AllActors(class'SandraRenton', Sandra)
				count++;
			
			foreach AllActors(class'GilbertRenton', Gilbert)
				count++;
			
			foreach AllActors(class'SandraRentonCarcass', SandraCarc)
				if ((SandraCarc != None) && (SandraCarc.KillerBindName == "JCDenton"))
					count = 0;
			
			foreach AllActors(class'GilbertRentonCarcass', GilbertCarc)
				if ((GilbertCarc != None) && (GilbertCarc.KillerBindName == "JCDenton"))
					count = 0;
			
			if (count < 2)
			{
				flags.SetBool('PlayerKilledRenton', True,, 5);
				foreach AllActors(class'Actor', A, 'RentonsHatePlayer')
				{
					if ((A != None) && (!A.bDeleteMe) && (Player != None))
					{
						A.Trigger(Self, Player);
					}
				}
			}
		}
		
		if ((!flags.GetBool('M04RaidTeleportDone')) && (flags.GetBool('ApartmentEntered')))
		{
			if (flags.GetBool('NSFSignalSent'))
			{
				foreach AllActors(class'ScriptedPawn', pawn)
				{
					if (Pawn == None)
					{
						continue;
					}
					
					if (pawn.IsA('UNATCOTroop') || pawn.IsA('MIB'))
					{
						pawn.EnterWorld();
					}
					else if (pawn.IsA('SandraRenton') || pawn.IsA('GilbertRenton') || pawn.IsA('HarleyFilben') || Pawn.IsA('JojoFine'))
					{
						pawn.LeaveWorld();
					}
				}
				
				if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Player, "ENEMY DISARM EXPLOSIVES"))
				{
					// Transcended - First, find the location of Paul's door
					// Movers still exist but at Z + 20k if destroyed
					foreach AllActors(class'DeusExMover', m)
					{
						if ((m != None) && (m.KeyIDNeeded == 'Apartment'))
						{
							yPosition = m.Location.Y;
							break;
						}
					}
					
					// Transcended - Anything in front of the door counts as outside his apartment, disable grenades there.
					if (yPosition != 0)
					{
						foreach AllActors(class'ThrownProjectile', grenades)
						{
							if ((grenades.IsA('LAM') || grenades.IsA('GasGrenade') || grenades.IsA('EMPGrenade') || grenades.IsA('NanovirusGrenade')) && !grenades.bDisabled && grenades.Location.Y > yPosition)
								grenades.bDisabled = True;
						}
					}
				}
				
				//MADDERS, 8/9/25: Missing previous annotation. Give Paul his raid gear, and make him fight with everything he's got.
				foreach AllActors(class'PaulDenton', Paul)
				{
					if (Paul != None)
					{
						UseTag = 'TalkedToPaulAfterMessage';
						if ((VMP != None) && (VMP.bAssignedFemale) && (VMP.bAllowFemaleVoice) && (!VMP.bDisableFemaleVoice))
						{
							UseTag = Player.FlagBase.StringToName("FemJC"$string(UseTag));
						}
						
						bConvoWon = Player.StartConversationByName(UseTag, Paul, False, False);
						
						//MADDERS, 12/27/23: We've given you plenty of tools for the task. Good luck, dude.
						if (bConvoWon)
						{
							Paul.Energy = 0;
							Paul.bKillswitchEngaged = true;
							Paul.AddToInitialInventory(class'AmmoTaserSlug', 3);
							Paul.AddToInitialInventory(class'WeaponSawedOffShotgun', 1);
							Paul.AddToInitialInventory(class'WeaponSword', 1);
							Paul.AddToInitialInventory(class'BioelectricCell', 15);
							Paul.AddToInitialInventory(class'Medkit', 15);
							if ((VMP != None) && (VMP.bPaulMortalEnabled))
							{
								Paul.bInvincible = false;
							}
						}
						break;
					}
				}
				
				if (bConvoWon)
				{
					flags.SetBool('M04RaidTeleportDone', True,, 5);
				}
				else
				{
					foreach AllActors(class'ScriptedPawn', pawn)
					{
						if (Pawn == None)
						{
							continue;
						}
						
						if (pawn.IsA('UNATCOTroop') || pawn.IsA('MIB'))
						{
							pawn.LeaveWorld();
						}
						else if (pawn.IsA('SandraRenton') || pawn.IsA('GilbertRenton') || pawn.IsA('HarleyFilben') || Pawn.IsA('JojoFine'))
						{
							pawn.EnterWorld();
						}
					}
				}
			}
		}
		
		// make the MIBs mortal
		if (!flags.GetBool('MS_MIBMortal'))
		{
			if (flags.GetBool('TalkedToPaulAfterMessage_Played'))
			{
				foreach AllActors(class'ScriptedPawn', pawn)
				{
					if (Pawn == None)
					{
						continue;
					}
					
					if (pawn.IsA('MIB'))
					{
						pawn.bInvincible = False;
					}
				}
				flags.SetBool('MS_MIBMortal', True,, 5);
			}
		}
		
		// unhide the correct JoJo
		if (!flags.GetBool('MS_JoJoUnhidden') && (flags.GetBool('SandraWaitingForJoJoBarks_Played') || flags.GetBool('GilbertWaitingForJoJoBarks_Played')))
		{
			if (!flags.GetBool('JoJoFine_Dead'))
			{
				foreach AllActors(class'ScriptedPawn', pawn, 'JoJoUpstairs')
				{
					if (Pawn == None)
					{
						continue;
					}
					
					pawn.EnterWorld();
				}
				flags.SetBool('MS_JoJoUnhidden', True,, 5);
			}
		}
		
		// unhide the correct JoJo
		if (!flags.GetBool('MS_JoJoUnhidden') &&
			(flags.GetBool('M03OverhearSquabble_Played') &&
			!flags.GetBool('JoJoOverheard_Played') &&
			flags.GetBool('JoJoEntrance')))
		{
			if (!flags.GetBool('JoJoFine_Dead'))
			{
				foreach AllActors(class'ScriptedPawn', pawn, 'JoJoUpstairs')
				{
					if (Pawn == None)
					{
						continue;
					}
					
					pawn.EnterWorld();
				}
				flags.SetBool('MS_JoJoUnhidden', True,, 5);
			}
		}

		// trigger some stuff based on convo flags
		if (flags.GetBool('JoJoOverheard_Played') && !flags.GetBool('MS_JoJo1Triggered'))
		{
			if (flags.GetBool('GaveRentonGun'))
			{
				foreach AllActors(class'Actor', A, 'GilbertAttacksJoJo')
				{
					if (A != None)
					{
						A.Trigger(Self, Player);
					}
				}
			}
			else
			{
				foreach AllActors(class'Actor', A, 'JoJoAttacksGilbert')
				{
					if (A != None)
					{
						A.Trigger(Self, Player);
					}
				}
			}
			
			flags.SetBool('MS_JoJo1Triggered', True,, 5);
		}
		
		// trigger some stuff based on convo flags
		if (flags.GetBool('JoJoAndSandraOverheard_Played') && !flags.GetBool('MS_JoJo2Triggered'))
		{
			foreach AllActors(class'Actor', A, 'SandraLeaves')
			{
				if (A != None)
				{
					A.Trigger(Self, Player);
				}
			}
			flags.SetBool('MS_JoJo2Triggered', True,, 5);
		}
		
		// trigger some stuff based on convo flags
		if (flags.GetBool('JoJoAndGilbertOverheard_Played') && !flags.GetBool('MS_JoJo3Triggered'))
		{
			foreach AllActors(class'Actor', A, 'JoJoAttacksGilbert')
			{
				if (A != None)
				{
					A.Trigger(Self, Player);
				}
			}
			flags.SetBool('MS_JoJo3Triggered', True,, 5);
		}
	}
	else if (localURL == "04_NYC_NSFHQ")
	{
		// rotate the dish when the computer sets the flag
		if (!flags.GetBool('MS_Dish1Rotated'))
		{
			if (flags.GetBool('Dish1InPosition'))
			{
				foreach AllActors(class'SatelliteDish', dish, 'Dish1')
					dish.DesiredRotation.Yaw = 49152;

				flags.SetBool('MS_Dish1Rotated', True,, 5);
			}
		}
		
		// rotate the dish when the computer sets the flag
		if (!flags.GetBool('MS_Dish2Rotated'))
		{
			if (flags.GetBool('Dish2InPosition'))
			{
				foreach AllActors(class'SatelliteDish', dish, 'Dish2')
					dish.DesiredRotation.Yaw = 0;

				flags.SetBool('MS_Dish2Rotated', True,, 5);
			}
		}
		
		// rotate the dish when the computer sets the flag
		if (!flags.GetBool('MS_Dish3Rotated'))
		{
			if (flags.GetBool('Dish3InPosition'))
			{
				foreach AllActors(class'SatelliteDish', dish, 'Dish3')
					dish.DesiredRotation.Yaw = 16384;

				flags.SetBool('MS_Dish3Rotated', True,, 5);
			}
		}
		
		// set a flag when all dishes are rotated
		if (!flags.GetBool('CanSendSignal'))
		{
			if (flags.GetBool('Dish1InPosition') &&
				flags.GetBool('Dish2InPosition') &&
				flags.GetBool('Dish3InPosition'))
				flags.SetBool('CanSendSignal', True,, 5);
		}
		
		// count non-living troops
		if (!flags.GetBool('MostWarehouseTroopsDead'))
		{
			count = 0;
			foreach AllActors(class'UNATCOTroop', troop)
				count++;

			// if two or less are still alive
			if (count <= 2)
				flags.SetBool('MostWarehouseTroopsDead', True);
		}
		
		// Transcended - Set the troops to look around for JC when patrolling.
		if (!flags.GetBool('M04TroopsSuspicious') && flags.GetBool('NSFSignalSent'))
		{
			for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
			{
				if (UNATCOTroop(curPawn) != None)	
					UNATCOTroop(curPawn).bExtraSuspicious = True;
			}
			flags.SetBool('M04TroopsSuspicious', True,, 5);
		}
	}
}

function CheckPaulWellbeing()
{
	local bool bPaulSafe;
	local int count;
	local MIB TMIB;
	local Pawn curPawn;
	local ScriptedPawn P;
	local UNATCOTroop troop;
	
	count = 0;
	
	for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
	{
		if (curPawn.isA('PaulDenton'))
		{
			//== If Paul has left the building, or if he acts like he's safe, he's safe. No longer counts the player leaving the room as marking Paul safe.
			if(curPawn.bHidden || (flags.GetBool('M04RaidDone') && !Flags.GetBool('PaulDenton_Dead')))
			{
				bPaulSafe = True;
			}
			break;
		}
	}
	if (!bPaulSafe)
	{
		for (curPawn=Level.PawnList; curPawn != None; curPawn=curPawn.nextPawn)
		{
			if (curPawn.bHidden == False && curPawn.bNetSpecial) // Don't count NG+ ones.
			{
				troop = UNATCOTroop(curPawn);
				TMIB = MIB(CurPawn);
				if ((troop != None) && (troop.health > troop.minhealth) && (!Troop.ShouldDropWeapon()))
				{
					count++;
				}
				else if ((TMIB != None) && (TMIB.health > TMIB.minhealth) && (!TMIB.ShouldDropWeapon()))
				{
					count += 2;
				}
			}
		}
		
		//Allows for two troopers or one MIB to be alive.
		if ((count <= 2) && (!Flags.GetBool('PaulDenton_Dead')))
		{
			bPaulSafe = True;
		}
	}
	
	if (bPaulSafe)
	{
		flags.SetBool('M04_Hotel_Cleared', True,, 6);
		// flags.SetBool('PlayerBailedOutWindow', False,, 0);
		flags.SetBool('PaulDenton_Dead', False,, 16);
		flags.SetBool('PaulDenton_Unconscious', False,, 16);
	}
	else
	{
		flags.SetBool('M04_Hotel_Cleared', False,, 6);
		flags.SetBool('PaulDenton_Dead', True,, 16);
		flags.SetBool('PaulDenton_Unconscious', False,, 16);
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
