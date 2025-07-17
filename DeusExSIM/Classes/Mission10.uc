//=============================================================================
// Mission10.
//=============================================================================
class Mission10 extends MissionScript;

var localized string StorageRoomHackStr;
var Keypad BackroomKeypad;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local NicoletteDuClare Nicolette;
	local BlackHelicopter chopper;
	local JaimeReyes Jaime;

	Super.FirstFrame();

	if (localURL == "10_PARIS_METRO")
	{
		if (flags.GetBool('NicoletteLeftClub'))
		{
			foreach AllActors(class'NicoletteDuClare', Nicolette)
				Nicolette.EnterWorld();

			foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter')
				chopper.EnterWorld();
		}

		if (!flags.GetBool('JaimeRecruited'))
		{
			foreach AllActors(class'JaimeReyes', Jaime)
				Jaime.EnterWorld();
		}
	}
	else if (localURL == "10_PARIS_CLUB")
	{
		if (flags.GetBool('NicoletteLeftClub'))
		{
			foreach AllActors(class'NicoletteDuClare', Nicolette)
				Nicolette.Destroy();
		}
	}
	else if (localURL == "10_PARIS_CHATEAU")
	{
		flags.SetBool('ClubComplete', True,, 11);
	}
}

// ----------------------------------------------------------------------
// PreTravel()
// 
// Set flags upon exit of a certain map
// ----------------------------------------------------------------------

function PreTravel()
{
	if (localURL == "10_PARIS_CLUB")
	{
		if (flags.GetBool('MeetNicolette_Played') &&
			!flags.GetBool('NicoletteLeftClub'))
		{
			flags.SetBool('NicoletteLeftClub', True,, 11);
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
	local int count, notSafeCount, notDeadCount;
	local Actor A;
	local Greasel greasel;
	local GuntherHermann gunther;
	local MJ12Commando commando;
	local NicoletteDuClare Nicolette;
	local pawn curPawn;
	local ScriptedPawn hostage, guard;

	Super.Timer();

	if (localURL == "10_PARIS_CATACOMBS")
	{
		// see if the greasels are dead
		if (!flags.GetBool('SewerGreaselsDead'))
		{
			count = 0;
			foreach AllActors(class'Greasel', greasel, 'SewerGreasel')
				count++;

			if (count == 0)
				flags.SetBool('SewerGreaselsDead', True,, 11);
		}

		// Transcended - Remove Aimee's goal if she dies.
		if (!flags.GetBool('MS_AimeeDead'))
		{
			count = 0;
			for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
			{
				if (curPawn.BindName ~= "aimee")
				{
					count++;
					break;
				}
			}
			
			if (count == 0)
			{
				player.GoalCompleted('KillGreasels');
				flags.SetBool('MS_AimeeDead', True,, 11);
			}
		}

		// check for dead guards
		if (!flags.GetBool('defoequestcomplete'))
		{
			count = 0;
			foreach AllActors(class'ScriptedPawn', guard, 'mj12metroguards')
				count++;

			if (count == 0)
				flags.SetBool('defoequestcomplete', True,, 11);
		}
	}
	else if (localURL == "10_PARIS_CATACOMBS_TUNNELS")
	{
		if (!flags.GetBool('SilhouetteRescueComplete'))
		{
			// count how many hostages are NOT safe
			notSafeCount = 0;
			notDeadCount = 0;
			foreach AllActors(class'ScriptedPawn', hostage)
			{
				if (hostage.BindName == "hostage")
				{
					notDeadCount++;
					if (!flags.GetBool('CataMaleSafe'))
						notSafeCount++;
				}
				else if (hostage.BindName == "hostage_female")
				{
					notDeadCount++;
					if (!flags.GetBool('CataFemaleSafe'))
						notSafeCount++;
				}
			}

			if ((notSafeCount == 0) || (notDeadCount == 0))
			{
				flags.SetBool('SilhouetteRescueComplete', True,, 11);
				Player.GoalCompleted('EscortHostages');

				if (notDeadCount == 0)
					flags.SetBool('SilhouetteHostagesDead', True,, 11);
				else if (notDeadCount < 2)
					flags.SetBool('SilhouetteHostagesSomeRescued', True,, 11);
				else
					flags.SetBool('SilhouetteHostagesAllRescued', True,, 11);
			}
		}
	}
	else if (localURL == "10_PARIS_METRO")
	{
		// unhide GuntherHermann
		if (!flags.GetBool('MS_GuntherUnhidden') &&
			flags.GetBool('JockReady_Played'))
		{
			foreach AllActors(class'GuntherHermann', gunther)
				gunther.EnterWorld();

			foreach AllActors(class'NicoletteDuClare', Nicolette)
				Nicolette.Destroy();

			flags.SetBool('MS_GuntherUnhidden', True,, 11);
		}

		// bark something
		if (flags.GetBool('AlleyCopSeesPlayer_Played') &&
			!flags.GetBool('MS_CopBarked'))
		{
			foreach AllActors(class'Actor', A, 'AlleyCopAttacks')
				A.Trigger(Self, Player);

			flags.SetBool('MS_CopBarked', True,, 11);
		}
	}
	else if (localURL == "10_PARIS_CLUB")
	{
		BackroomKeypad = GetBackroomKeypad();
		if (Flags.GetBool('GaveCassandraMoney') || Flags.GetBool('ClubVaultEntered'))
		{
			if ((BackroomKeypad != None) && (!BackroomKeypad.bIsSecretGoal))
			{
				BackroomKeypad.bIsSecretGoal = true;
				//MADDERS, 5/12/25: LDDP Confix exists. Yay.
				//Player.AddNote(StorageRoomHackStr);
				BackroomKeypad.ValidCode = "1966";
			}
		}
		else
		{
			if (BackroomKeypad != None)
			{
				BackroomKeypad.ValidCode = "sup?";
			}
		}
	}
	else if (localURL == "10_PARIS_CHATEAU")
	{
		// unhide MJ12Commandos when an infolink is played
		if (!flags.GetBool('MS_CommandosUnhidden') &&
			flags.GetBool('everettsignal'))
		{
			foreach AllActors(class'MJ12Commando', commando)
				commando.EnterWorld();

			flags.SetBool('MS_CommandosUnhidden', True,, 11);
		}
	}
}

function Keypad GetBackroomKeypad()
{
	local Keypad1 TKeypad;
	
	if (BackroomKeypad != None) return BackroomKeypad;
	
	forEach AllActors(class'Keypad1', TKeypad)
	{
		if (class'VMDStaticFunctions'.Static.StripBaseActorSeed(TKeypad) == 0)
		{
			return TKeypad;
		}
	}
	
	return None;
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
    StorageRoomHackStr="The code for the storage room in La Porte de l'Enfer is 1966"
}
