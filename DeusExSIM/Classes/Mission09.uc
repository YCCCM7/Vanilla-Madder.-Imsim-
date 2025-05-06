//=============================================================================
// Mission09.
//=============================================================================
class Mission09 extends MissionScript;

var int KlaxonID;

// ----------------------------------------------------------------------
// FirstFrame()
// 
// Stuff to check at first frame
// ----------------------------------------------------------------------

function FirstFrame()
{
	local DeusExMover M;
	local BlackHelicopter chopper;
	local TimerDisplay TTimer;
	
	Super.FirstFrame();
	
	if (localURL == "09_NYC_SHIP")
	{
		if (flags.GetBool('MS_ShipBreeched'))
		{
			foreach AllActors(class'DeusExMover', M)
			{
				if ((M.Tag == 'SewerGrate') || (M.Tag == 'FrontDoor'))
				{
					// close and lock the door
					if (M.KeyNum != 0)
						M.InterpolateTo(0,0);
					M.bBreakable = False;
					M.bPickable = False;
					M.bFrobbable = False;
					M.bLocked = True;
				}
			}
		}
	}
	else if (localURL == "09_NYC_DOCKYARD")
	{
		if (flags.GetBool('MS_ShipBreeched'))
		{
			foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter')
				chopper.EnterWorld();
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
	local TimerDisplay TTimer;
	
	if ((Player != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None) && (DeusExRootWindow(Player.RootWindow).HUD.Timer != None))
	{
		TTimer = DeusExRootWindow(Player.RootWindow).HUD.Timer;
		Flags.SetInt('VMDShipBlowUpTime', int(TTimer.Time + 0.99),, 10);
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
	local int count;
	local DeusExMover M;
	local BlackHelicopter chopper;
	local MJ12Troop troop;
	local Trigger trig;
	local MJ12Commando commando;
	local WaltonSimons Walton;
	
	//MADDERS additions.
	local DeusExMover DXM;
	local Janitor Jan;
	local PathNode TPath;
	local Pawn TPawn;
	local ScriptedPawn SP;
	local TimerDisplay TTimer;
	
	Super.Timer();
	
	if (localURL == "09_NYC_SHIP")
	{
		// unhide Walton Simons
		if (!flags.GetBool('MS_SimonsAppeared') &&
			flags.GetBool('SummonSimons'))
		{
			foreach AllActors(class'WaltonSimons', Walton)
				Walton.EnterWorld();

			flags.SetBool('MS_SimonsAppeared', True,, 10);
		}
		
		// hide Walton Simons, and make this convo retriggerable
		if (flags.GetBool('MS_SimonsAppeared') &&
			flags.GetBool('M09SimonsDisappears'))
		{
			foreach AllActors(class'WaltonSimons', Walton)
			{
				Walton.EnterWorld();
				Walton.bLookingForEnemy = false;
				Walton.bLookingForLoudNoise = false;
				Walton.bLookingForAlarm = false;
				Walton.bLookingForDistress = false;
				Walton.bLookingForProjectiles = false;
				Walton.bLookingForShot = false;
				Walton.bLookingForInjury = false;
				Walton.bLookingForIndirectInjury = false;
			}

			flags.SetBool('M09SimonsDisappears', False,, 10);
			flags.SetBool('MS_SimonsAppeared', False,, 10);
			flags.SetBool('SummonSimons', False,, 10);
		}
		
		// randomly play explosions and shake the view
		// if the ship has been breeched
		if (flags.GetBool('MS_ShipBreeched'))
		{
			ShipSinkingEffects();
			ShipExplosionEffects(False);
		}
	}
	else if (localURL == "09_NYC_SHIPBELOW")
	{
		// check for blown up ship
		if (!flags.GetBool('MS_ShipBreeched'))
		{
			count = 0;
			foreach AllActors(class'DeusExMover', M, 'ShipBreech')
				if (!M.bDestroyed)
					count++;

			if (count == 0)
			{
				if (flags.GetBool('Bilge'))
				{
					if ((Player != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
					{
						TTimer = DeusExRootWindow(Player.RootWindow).HUD.CreateTimerWindow();
						TTimer.Time = 1800;
						TTimer.bCritical = False;
						TTimer.Message = "Ship Sinking";
						TTimer.bIntegerDisplay = true;
						Flags.SetInt('VMDShipBlowUpTime', int(TTimer.Time + 0.99),, 10);
					}
					
					Player.StartDataLinkTransmission("DL_AllDone");
					flags.SetBool('MS_ShipBreeched', True,, 10);
					
					for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
					{
						SP = ScriptedPawn(TPawn);
						if ((SP != None) && (Robot(SP) == None))
						{
							SP.bStasis = false;
							if (SP.IsInState('Attacking'))
							{
								SP.SetOrders('RunningTo', 'ShipBlowUpFleePoint', false);
							}
							else
							{
								SP.SetOrders('RunningTo', 'ShipBlowUpFleePoint', true);
							}
						}
					}
				}
				else if (!flags.GetBool('DL_AllPlaced_Played'))
				{
					Player.StartDataLinkTransmission("DL_AllPlaced");
				}
			}
		}

		// randomly play explosions and shake the view
		// if the ship has been breeched
		if (flags.GetBool('MS_ShipBreeched'))
		{
			forEach AllActors(class'PathNode', TPath, 'ShipBlowUpFleePoint')
			{
				forEach RadiusActors(class'ScriptedPawn', SP, 160, TPath.Location)
				{
					SP.Destroy();
				}
				break;
			}
			ShipSinkingEffects();
			ShipExplosionEffects(True);
		}
	}
	else if (localURL == "09_NYC_GRAVEYARD")
	{
		//MADDERS: This is fucking hideous, but this is a fix for killing the damned gatekeeper.
		//He's otherwise set to invuln by the map fixer, so it's ran only once to make him invuln.
		if (!flags.GetBool('MS_UnhideHelicopter'))
		{
			forEach AllActors(class'DeusExMover', DXM)
			{
				if ((DXM.Tag == 'MainGate') && (DXM.KeyNum > 0))
				{
					forEach AllActors(class'Janitor', Jan)
					{
						if ((Jan != None) && (Jan.bInvincible))
						{
							Jan.bInvincible = false;
						}
					}
				}
			}
		}

		// unhide the helicopter when the "little device" is destroyed
		if (!flags.GetBool('MS_UnhideHelicopter'))
		{
			if (flags.GetBool('deviceDestroyed') &&
				flags.GetBool('M09MeetStantonDowd_Played'))
			{
				foreach AllActors(class'BlackHelicopter', chopper, 'BlackHelicopter')
					chopper.EnterWorld();

				Player.StartDataLinkTransmission("DL_ComingIn");

				foreach AllActors(class'MJ12Troop', troop, 'TroopSupport')
					troop.EnterWorld();

				flags.SetBool('MS_UnhideHelicopter', True,, 10);
			}
		}

		// activate a trigger and unhide some troops
		// once Stanton Dowd has been talked to
		if (!flags.GetBool('MS_TriggerOn') &&
			flags.GetBool('M09MeetStantonDowd_Played'))
		{
			foreach AllActors(class'Trigger', trig, 'TunnelTrigger')
				trig.SetCollision(True);

			foreach AllActors(class'MJ12Troop', troop, 'TroopInsertion')
				troop.EnterWorld();

			flags.SetBool('MS_TriggerOn', True,, 10);
		}

		// spawn some commandos
		if (flags.GetBool('GreenKnowsAboutDowd') &&
			flags.GetBool('suprisePoint') &&
			!flags.GetBool('MS_UnhideCommandos'))
		{
			foreach AllActors(class'MJ12Commando', commando, 'paratroop')
				commando.EnterWorld();

			flags.SetBool('MS_UnhideCommandos', True,, 10);
		}
	}
}

function ShipSinkingEffects()
{
	local float Size, ShakeTime, ShakeRoll, ShakeVert;
	local Actor A;
	local Pawn TPawn;
	local TimerDisplay TTimer;
	
	if ((Player != None) && (DeusExRootWindow(Player.RootWindow) != None) && (DeusExRootWindow(Player.RootWindow).HUD != None))
	{
		if (DeusExRootWindow(Player.RootWindow).HUD.Timer != None)
		{
			TTimer = DeusExRootWindow(Player.RootWindow).HUD.Timer;
			TTimer.Time -= 1;
			Flags.SetInt('VMDShipBlowUpTime', int(TTimer.Time + 0.99),, 10);
			if (TTimer.Time <= 0)
			{
				for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
				{
					if (!(localURL ~= "09_NYC_SHIP") || (TPawn.Location.Y > -900 && TPawn.Location.X > -3546))
					{
						if (TTimer.Time <= -2)
						{
							Level.Game.SendPlayer(Player, "dxonly");
							break;
						}
						else
						{
							if (PlayerPawn(TPawn) != None)
							{
								A = Spawn(class'ExplosionLarge',,, TPawn.Location - Normal(TPawn.Location) * 128);
								if (A == None)
								{
									A = Spawn(class'ExplosionLarge',,, TPawn.Location - Normal(TPawn.Location) * 64);
								}
								if (A == None)
								{
									A = Spawn(class'ExplosionLarge',,, TPawn.Location - Normal(TPawn.Location) * 15);
								}
							}
							TPawn.TakeDamage(10000, TPawn, TPawn.Location, Normal(TPawn.Location) * 1000, 'Exploded');
						}
					}
					else
					{
						if (TTimer.Time <= -2)
						{
							//Send to menu at another time? Maybe?
							break;
						}
						else
						{
							// pick a random explosion size and modify everything accordingly
							Size = FRand();
							ShakeTime = 0.5 + size;
							ShakeRoll = 512.0 + 1024.0 * size;
							ShakeVert = 8.0 + 16.0 * size;
							
							TPawn.TakeDamage(50, Player, Player.Location, VRand() * 300, 'DieNerd');
							
							// shake the view
							if (PlayerPawn(TPawn) != None)
							{
								Player.ShakeView(ShakeTime, ShakeRoll, ShakeVert);
								
								// play a sound
								if (Size < 0.2)
								{
									TPawn.PlaySound(Sound'SmallExplosion1', SLOT_None, 2.0,, 16384);
								}
								else if (Size < 0.4)
								{
									TPawn.PlaySound(Sound'MediumExplosion1', SLOT_None, 2.0,, 16384);
								}
								else if (Size < 0.6)
								{
									TPawn.PlaySound(Sound'MediumExplosion2', SLOT_None, 2.0,, 16384);
								}
								else if (Size < 0.8)
								{
									TPawn.PlaySound(Sound'LargeExplosion1', SLOT_None, 2.0,, 16384);
								}
								else
								{
									TPawn.PlaySound(Sound'LargeExplosion2', SLOT_None, 2.0,, 16384);
								}
							}
						}
					}
				}
			}
			else if (TTimer.Time <= 300)
			{
				TTimer.bCritical = true;
			}
		}
		else
		{
			TTimer = DeusExRootWindow(Player.RootWindow).HUD.CreateTimerWindow();
			TTimer.Time = Flags.GetInt('VMDShipBlowUpTime');
			TTimer.bCritical = (TTimer.Time <= 300);
			TTimer.Message = "Ship Sinking";
			TTimer.bIntegerDisplay = true;
			ShipSinkingEffects();
		}
	}
}

function ShipExplosionEffects(bool bFragments)
{
	local int i;
	local float shakeTime, shakeRoll, shakeVert, size, explosionFreq, amount;
	local Vector bobble, loc, endloc, HitLocation, HitNormal;
	local Actor HitActor;
	local BreakableGlass window;
	local Cart cart;
	local HangingDecoration deco;
	local MetalFragment frag;
	local VMDBufferPlayer VMP;

	if (bFragments)
		explosionFreq = 0.33;
	else
		explosionFreq = 0.1;
	
	VMP = VMDBufferPlayer(Player);
	if (FRand() < explosionFreq)
	{
		if (VMP != None)
		{
			VMP.VMDModPlayerStress(30, true, 2, true);
		}
		
		// pick a random explosion size and modify everything accordingly
		size = FRand();
		shakeTime = 0.5 + size;
		shakeRoll = 512.0 + 1024.0 * size;
		shakeVert = 8.0 + 16.0 * size;
		
		// play a sound
		if (size < 0.2)
			Player.PlaySound(Sound'SmallExplosion1', SLOT_None, 2.0,, 16384);
		else if (size < 0.4)
			Player.PlaySound(Sound'MediumExplosion1', SLOT_None, 2.0,, 16384);
		else if (size < 0.6)
			Player.PlaySound(Sound'MediumExplosion2', SLOT_None, 2.0,, 16384);
		else if (size < 0.8)
			Player.PlaySound(Sound'LargeExplosion1', SLOT_None, 2.0,, 16384);
		else
			Player.PlaySound(Sound'LargeExplosion2', SLOT_None, 2.0,, 16384);

		// shake the view
		Player.ShakeView(shakeTime, shakeRoll, shakeVert);

		// bobble the player around
		bobble = vect(300.0,300.0,200.0) + 500.0 * size * VRand();
		
		if ((Player != None) && (Player.IsInState('PlayerWalking')) && (Player.Physics != PHYS_Falling) && (VMP == None || !VMP.VMDUsingLadder()))
			Player.Velocity += bobble;

		// make all the hanging decorations sway randomly
		foreach AllActors(class'HangingDecoration', deco)
		{
			deco.CalculateHit(deco.Location + 10.0 * FRand() * VRand(), 0.5 * bobble);
			deco.bSwaying = True;
		}

		// make all the carts move randomly
		foreach AllActors(class'Cart', cart)
			cart.StartRolling(vect(100.0,100.0,0.0) + 200.0 * size * VRand());

		amount = FRand();
		
		//Bjorn: Destroy glass windows randomly around the player.
		foreach player.RadiusActors(Class'BreakableGlass', window, 300)
		{
			//Only blow up windows that's on the same "level" as the player (a shame to blow out stuff the player can't see).
			if (Abs(player.location.Z - window.location.Z) < 100)
			{
				window.BlowItUp(player);
				amount -= 0.33;
			}
			
			if (amount <= 0.34)
				break;
			else if (amount <= 0.67)
				amount -= 0.33;
		}

		// have random metal fragments fall from the ceiling
		if (bFragments)
		{
			for (i=0; i<Int(size*20.0); i++)
			{
				loc = Player.Location + 256.0 * VRand();
				loc.Z = Player.Location.Z;
				endloc = loc;
				endloc.Z += 1024.0;
				HitActor = Trace(HitLocation, HitNormal, endloc, loc, False);
				if (HitActor == None)
					HitLocation = endloc;
				frag = Spawn(class'MetalFragment',,, HitLocation);
				if (frag != None)
				{
					//MADDERS: Force lifespan to be shorter for these. Permanence makes this a no-no!
					frag.Lifespan = 5.0;
					
					frag.CalcVelocity(vect(20000,0,0),256);
					frag.DrawScale = 0.5 + 2.0 * FRand();
					if (FRand() < 0.25)
						frag.bSmoking = True;
				}
			}
		}
	}
	
	//Bjorn: If we have no Klaxon ID we haven't started the sound yet. The sound and the ID resets on travel.
	if (KlaxonID == 0)
	{
		KlaxonID = player.PlaySound(Sound'Klaxon', SLOT_None, 2.0,, 16384);
	}
	
	// make sure the player's zone has an alarm ambient sound
	// if (Player.HeadRegion.Zone != None)
	// {
		// Player.HeadRegion.Zone.AmbientSound = sound'Klaxon';
		// Player.HeadRegion.Zone.SoundRadius = 255;
		// Player.HeadRegion.Zone.SoundVolume = 255;
	// }
}

// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
}
