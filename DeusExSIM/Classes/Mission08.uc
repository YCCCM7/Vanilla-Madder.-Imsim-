//=============================================================================
// Mission08.
//=============================================================================
class Mission08 extends MissionScript;

var int AugCanCount;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local FordSchick Ford;
	local JordanShea Jordan;
	local SandraRenton Sandra;

	Super.FirstFrame();

	if (flags.GetBool('SandraWentToCalifornia'))
	{
		foreach AllActors(class'SandraRenton', Sandra)
			Sandra.Destroy();
	}
	
	//MADDERS, 4/27/25: If we pissed off Jordan in M02 or M04, make her remember and take it personally.
	if (localURL == "08_NYC_BAR")
	{
		//MADDERS, 8/9/25: Start beef between us and Jordan, if we crossed her.
		if (flags.GetBool('VMDPlayerCrossedJordanShea'))
		{
			foreach AllActors(class'JordanShea', Jordan)
			{
				Jordan.ChangeAlly('Player', -1.0, true);
			}
		}
	}
	else if (localURL == "08_NYC_SMUG")
	{
		// unhide Ford if you've rescued him
		if (flags.GetBool('FordSchickRescued'))
		{
			foreach AllActors(class'FordSchick', Ford)
				Ford.EnterWorld();
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
	local BlackHelicopter chopper;

	Super.PreTravel();

	if (localURL == "08_NYC_STREET")
	{
		// make sure that damn helicopter is gone
		foreach AllActors(class'BlackHelicopter', chopper, 'EntranceCopter')
			chopper.Destroy();
	}
}

// ----------------------------------------------------------------------
// Timer()
//
// Main state machine for the mission
// ----------------------------------------------------------------------

function Timer()
{
	local int count, ACCount;
	local AugmentationUpgradeCannister TCan;
	local BlackHelicopter chopper;
	local Inventory TItem;
	local RiotCop cop;
	local ScriptedPawn Pawn, MJ12;
	local StantonDowd Stanton;
	local ThugMale Thug;
	local UNATCOTroop troop;
	
	Super.Timer();
	
	if (localURL == "08_NYC_FREECLINIC")
	{
		if (flags.GetBool('JoeGreene_Dead') &&
			!flags.GetBool('MS_GreeneGoalSet'))
		{
			Player.GoalCompleted('KillGreene');
			flags.SetBool('MS_GreeneGoalSet', True,, 9);
		}
	}
	else if (localURL == "08_NYC_STREET")
	{
		// spawn reinforcements as cops are killed
		if (!flags.GetBool('MS_UnhideTroop1'))
		{
			count = 0;
			foreach AllActors(class'RiotCop', cop, 'Cop1')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', troop, 'troop1')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideTroop1', True,, 9);
			}
		}
		if (!flags.GetBool('MS_UnhideTroop2'))
		{
			count = 0;
			foreach AllActors(class'RiotCop', cop, 'Cop2')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', troop, 'troop2')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideTroop2', True,, 9);
			}
		}
		if (!flags.GetBool('MS_UnhideTroop3'))
		{
			count = 0;
			foreach AllActors(class'RiotCop', cop, 'Cop3')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', troop, 'troop3')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideTroop3', True,, 9);
			}
		}
		if (!flags.GetBool('MS_UnhideTroop4'))
		{
			count = 0;
			foreach AllActors(class'RiotCop', cop, 'Cop4')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', troop, 'troop4')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideTroop4', True,, 9);
			}
		}
		if (!flags.GetBool('MS_UnhideTroop5'))
		{
			count = 0;
			foreach AllActors(class'RiotCop', cop, 'Cop5')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', troop, 'troop5')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideTroop5', True,, 9);
			}
		}
		if (!flags.GetBool('MS_UnhideTroop6'))
		{
			count = 0;
			foreach AllActors(class'RiotCop', cop, 'Cop6')
				count++;

			if (count == 0)
			{
				foreach AllActors(class'UNATCOTroop', troop, 'troop6')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideTroop6', True,, 9);
			}
		}
		
		// unhide Thomas Dieter
		if (!flags.GetBool('MS_ThomasUnhidden'))
		{
			if (flags.GetBool('HarleyFilben_Dead'))
			{
				foreach AllActors(class'ScriptedPawn', pawn, 'ThomasDieter')
					if (pawn.IsA('Janitor'))
						pawn.EnterWorld();

				flags.SetBool('MS_ThomasUnhidden', True,, 9);
			}
		}
		
		// unhide Stanton Dowd
		if (!flags.GetBool('MS_StantonUnhidden'))
		{
			if (flags.GetBool('M08MeetHarleyFilben_Played') ||
				flags.GetBool('MeetThomasDieter_Played'))
			{
				foreach AllActors(class'ScriptedPawn', pawn, 'StantonDowd')
					if (pawn.IsA('StantonDowd'))
						pawn.EnterWorld();

				flags.SetBool('MS_StantonUnhidden', True,, 9);
			}
		}
		
		// unhide shady guy
		if (!flags.GetBool('MS_ShadyGuyUnhidden'))
		{
			if (flags.GetBool('MS_StantonUnhidden'))
			{
				if ((flags.GetBool('GreenKnowsAboutDowd') &&
					!flags.GetBool('JoeGreen_Dead')) ||
					flags.GetBool('SheaKnowsAboutDowd'))
				{
					foreach AllActors(class'ScriptedPawn', pawn, 'ShadyGuy')
						if (pawn.IsA('ThugMale'))
							pawn.EnterWorld();

					flags.SetBool('MS_ShadyGuyUnhidden', True,, 9);
				}
			}
		}
		
		// spawn MJ12 attack force when Shady Guy gets close (8 feet) to Dowd
		if (!flags.GetBool('StantonAmbush'))
		{
			Stanton = None;
			foreach AllActors(class'ScriptedPawn', pawn, 'StantonDowd')
				if (pawn.IsA('StantonDowd'))
					Stanton = StantonDowd(pawn);
			
			if (Stanton != None)
			{
				Thug = None;
				foreach AllActors(class'ScriptedPawn', pawn, 'ShadyGuy')
					Thug = ThugMale(pawn);

				if (Thug != None)
				{
					if (VSize(Thug.Location - Stanton.Location) <= 128)
					{
						foreach AllActors(class'ScriptedPawn', mj12, 'MJ12AttackForce')
							mj12.EnterWorld();

						flags.SetBool('StantonAmbush', True,, 9);
					}
				}
			}
		}
		
		// spawn MJ12 attack force when a flag is set
		if (!flags.GetBool('StantonAmbush') &&
			flags.GetBool('MJ12Converging'))
		{
			foreach AllActors(class'ScriptedPawn', mj12, 'MJ12AttackForce')
				mj12.EnterWorld();

			flags.SetBool('StantonAmbush', True,, 9);
		}
		
		// if the MJ12 attack force is killed, set a flag
		if (flags.GetBool('StantonAmbush') &&
			!flags.GetBool('StantonAmbushDefeated'))
		{
			count = 0;
			foreach AllActors(class'ScriptedPawn', mj12, 'MJ12AttackForce')
				count++;

			if (count == 0)
				flags.SetBool('StantonAmbushDefeated', True,, 9);
		}
		
		// unhide the helicopter when its time
		if (flags.GetBool('StantonDowd_Played') &&
			flags.GetBool('DL_Exit_Played') &&
			!flags.GetBool('MS_Helicopter_Unhidden'))
		{
			foreach AllActors(class'BlackHelicopter', chopper, 'CopterExit')
				chopper.EnterWorld();

			flags.SetBool('MS_Helicopter_Unhidden', True,, 9);
		}
	}
	else if (localURL == "08_NYC_SMUG")
	{
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
