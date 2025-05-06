//=============================================================================
// Mission14.
//=============================================================================
class Mission14 extends MissionScript;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local TimerDisplay TTimer;
	
	Super.FirstFrame();

	if (localURL == "14_OCEANLAB_LAB")
	{
		Player.GoalCompleted('StealSub');
	}
	else if (localURL == "14_OCEANLAB_SILO")
	{
		if ((VMDBufferPlayer(Player) != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
		{
			TTimer = DeusExRootWindow(Player.RootWindow).HUD.CreateTimerWindow();
			TTimer.Time = int((25.0 * 60.0) / Sqrt(FMin(VMDBufferPlayer(Player).TimerDifficulty, Sqrt(VMDBufferPlayer(Player).TimerDifficulty))));
			TTimer.bCritical = False;
			TTimer.Message = "Rocket Launch";
			TTimer.bIntegerDisplay = true;
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
	local HowardStrong Howard;
	local BlackHelicopter chopper;
	local MiniSub sub;
	local ScubaDiver diver;
	local GarySavage Gary;
	local WaltonSimons Walton;
	local ThrownProjectile grenades;
	local Actor part;
	local BobPage Bob;

	Super.Timer();

	if (localURL == "14_VANDENBERG_SUB")
	{
		// when the mission is complete, unhide the chopper and Gary Savage,
		// and destroy the minisub and the welding parts
		if (!flags.GetBool('MS_DestroySub'))
		{
			if (flags.GetBool('DL_downloaded_Played'))
			{
				foreach AllActors(class'MiniSub', sub, 'MiniSub2')
					sub.Destroy();

				foreach AllActors(class'Actor', part, 'welding_stuff')
					part.Destroy();

				foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter')
					chopper.EnterWorld();

				foreach AllActors(class'GarySavage', Gary)
					Gary.EnterWorld();

				flags.SetBool('MS_DestroySub', True,, 15);
			}
		}
		
		// If TankKarkian dead, set the desired flag too.
		if (!flags.GetBool('MS_TankKarkian') && flags.GetBool('TankKarkian_Dead'))
		{
			flags.SetBool('TankKharkian_Dead', True,, 15);

			flags.SetBool('MS_TankKarkian', True,, 15);
		}
	}
	else if (localURL == "14_OCEANLAB_LAB")
	{
		// when the mission is complete, unhide the minisub and the diver team
		if (!flags.GetBool('MS_UnhideSub'))
		{
			if (flags.GetBool('DL_downloaded_Played'))
			{
				if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(Player, "ENEMY DISARM EXPLOSIVES"))
				{
					foreach AllActors(class'ThrownProjectile', grenades)
					{
						if ((grenades.IsA('LAM') || grenades.IsA('GasGrenade') || grenades.IsA('EMPGrenade') || grenades.IsA('NanovirusGrenade')) && !grenades.bDisabled)
							grenades.bDisabled = True;
					}
				}
				
				foreach AllActors(class'WaltonSimons', Walton)
				{
					Walton.EnterWorld();
					Walton.AddToInitialInventory(class'BioelectricCell', 15);
					Walton.AddToInitialInventory(class'Medkit', 5);
					if (Walton.AugmentationSystem != None)
					{
						Walton.AugmentationSystem.ActivateAllEco();
					}
				}
				foreach AllActors(class'MiniSub', sub, 'MiniSub2')
					sub.EnterWorld();

				foreach AllActors(class'ScubaDiver', diver, 'scubateam')
					diver.EnterWorld();

				flags.SetBool('MS_UnhideSub', True,, 15);
			}
		}
	}
	else if (localURL == "14_OCEANLAB_SILO")
	{
		if (!flags.GetBool('missile_aborted'))
		{
			RocketLaunchEffects();
		}
		else
		{
			HideTimerWindow();
		}
		
		// when HowardStrong is dead, unhide the helicopter
		if (!flags.GetBool('MS_UnhideHelicopter'))
		{
			count = 0;
			foreach AllActors(class'HowardStrong', Howard)
				count++;

			if (count == 0)
			{
				foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter')
					chopper.EnterWorld();

				Player.StartDataLinkTransmission("DL_Dead");
				flags.SetBool('MS_UnhideHelicopter', True,, 15);
			}
		}
	}
	else if (localURL == "14_OCEANLAB_UC")
	{
		// when a flag is set, unhide Bob Page
		if (!flags.GetBool('MS_UnhideBobPage') &&
			flags.GetBool('schematic_downloaded'))
		{
			foreach AllActors(class'BobPage', Bob)
			{
				Bob.EnterWorld();
				Bob.bLookingForEnemy = false;
				Bob.bLookingForLoudNoise = false;
				Bob.bLookingForAlarm = false;
				Bob.bLookingForDistress = false;
				Bob.bLookingForProjectiles = false;
				Bob.bLookingForShot = false;
				Bob.bLookingForInjury = false;
				Bob.bLookingForIndirectInjury = false;
			}

			flags.SetBool('MS_UnhideBobPage', True,, 15);
		}

		// when a flag is set, hide Bob Page
		if (!flags.GetBool('MS_HideBobPage') &&
			flags.GetBool('PageTaunt_Played'))
		{
			foreach AllActors(class'BobPage', Bob)
				Bob.LeaveWorld();

			flags.SetBool('MS_HideBobPage', True,, 15);
		}
	}
}

function RocketLaunchEffects()
{
	local float Size, ShakeTime, ShakeRoll, ShakeVert;
	local Dispatcher TDis;
	local MapExit TExit;
	local TimerDisplay TTimer;
	
	if ((Player != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
	{
		if (DeusExRootWindow(Player.RootWindow).HUD.Timer != None)
		{
			TTimer = DeusExRootWindow(Player.RootWindow).HUD.Timer;
			TTimer.Time -= 1;
			Flags.SetInt('VMDRocketLaunchTime', int(TTimer.Time + 0.99),, 10);
			if (TTimer.Time <= 0)
			{
				if (!Flags.GetBool('VMDStartedRocketSequence'))
				{
					Flags.SetBool('VMDStartedRocketSequence', true,, 15);
					forEach AllActors(Class'MapExit', TExit, 'ExitPath')
					{
						TExit.DestMap = "dxonly.dx";
					}
					forEach AllActors(class'Dispatcher', TDis, 'SiloExit')
					{
						TDis.Trigger(Player, Player);
					}
				}
				TTimer.Time = 0;
			}
			else if (TTimer.Time <= 180)
			{
				TTimer.bCritical = true;
			}
		}
		else
		{
			TTimer = DeusExRootWindow(Player.RootWindow).HUD.CreateTimerWindow();
			TTimer.Time = Flags.GetInt('VMDRocketLaunchTime');
			TTimer.bCritical = (TTimer.Time <= 180);
			TTimer.Message = "Rocket Launch";
			TTimer.bIntegerDisplay = true;
			RocketLaunchEffects();
		}
	}
}

function HideTimerWindow()
{
	local TimerDisplay TTimer;
	
	if ((Player != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
	{
		TTimer = DeusExRootWindow(Player.RootWindow).HUD.Timer;
		if (TTimer != None)
		{
			TTimer.Show(False);
		}
	}
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
