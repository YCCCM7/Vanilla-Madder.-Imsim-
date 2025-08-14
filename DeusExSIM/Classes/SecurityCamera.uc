//=============================================================================
// SecurityCamera.
//=============================================================================
class SecurityCamera extends HackableDevices;

var() bool bSwing;
var() int swingAngle;
var() float swingPeriod;
var() int cameraFOV;
var() int cameraRange;
var() float memoryTime;
var() bool bActive;
var() bool bNoAlarm;			// if True, does NOT sound alarm
var Rotator origRot;
var Rotator ReplicatedRotation; // for net propagation
var bool bTrackPlayer;
var bool bPlayerSeen;
var bool bEventTriggered;
var bool bFoundCurPlayer;  // in multiplayer, if we found a player this tick.
var float lastSeenTimer;
var float playerCheckTimer;
var float swingTimer;
var bool bConfused;				// used when hit by EMP
var float confusionTimer;		// how long until camera resumes normal operation
var float confusionDuration;	// how long does EMP hit last?
var float triggerDelay;			// how long after seeing the player does it trigger?
var float triggerTimer;			// timer used for above
var vector playerLocation;		// last seen position of player

// DEUS_EX AMSD Used for multiplayer target acquisition.
var Actor curTarget;          // current view target
var Actor prevTarget;         // target we had last tick.
var Pawn safeTarget;          // in multiplayer, this actor is strictly off-limits
                               // Usually for the player who activated the turret.

var localized string msgActivated;
var localized string msgDeactivated;

var int team;						// Keep track of team the camera is  on
var bool bOverwriteControl;			// Transcended - Is the player in control? (Disable rotating)

// ------------------------------------------------------------------------------------
// Network replication
// ------------------------------------------------------------------------------------

replication
{
   	//server to client var
   	reliable if (Role == ROLE_Authority)
      		bActive, ReplicatedRotation, team, safeTarget;   
}

function HackAction(Actor Hacker, bool bHacked)
{
   	local ComputerSecurity CompOwner;
   	local ComputerSecurity TempComp;
	local AutoTurret turret;
	local name Turrettag;
   	local int ViewIndex;
	
   	if (bConfused)
		return;
	
	Super.HackAction(Hacker, bHacked);
	
	if (bHacked)
	{
      		if (Level.NetMode == NM_Standalone)
      		{
         		if (bActive)
            			UnTrigger(Hacker, Pawn(Hacker));
         		else
            			Trigger(Hacker, Pawn(Hacker));
      		}
      		else
      		{
         		//DEUS_EX AMSD Reset the hackstrength afterwards
         		if (hackStrength == 0.0)
            			hackStrength = 0.6;
         		if (bActive)
            			UnTrigger(Hacker, Pawn(Hacker));
         		//Find the associated computer.
         		foreach AllActors(class'ComputerSecurity',TempComp)
         		{
            			for (ViewIndex = 0; ViewIndex < ArrayCount(TempComp.Views); ViewIndex++)
            			{
               				if (TempComp.Views[ViewIndex].cameraTag == self.Tag)
               				{
                  				CompOwner = TempComp;
						
                  				//find associated turret
                  				Turrettag = TempComp.Views[ViewIndex].Turrettag;
                  				if (Turrettag != '')
                  				{
                     					foreach AllActors(class'AutoTurret', turret, TurretTag)
                     					{
                        					break;
                     					}
                  				}
               				}
            			}
         		}
			
         		if (CompOwner != None)
         		{
            			//Turn off the associated turret as well
            			if ( (Hacker.IsA('DeusExPlayer')) && (Turret != None))
            			{
               				Turret.bDisabled = True;
               				Turret.gun.HackStrength = 0.6;
            			}
         		}
      		}
   	}
}

function Trigger(Actor Other, Pawn Instigator)
{
	if (bConfused)
		return;
	
	Super.Trigger(Other, Instigator);
	
	if (!bActive)
	{
		if (Instigator != None)
			Instigator.ClientMessage(msgActivated);
		bActive = True;
		LightType = LT_Steady;
		LightHue = 80;
		MultiSkins[2] = Texture'GreenLightTex';
		AmbientSound = sound'CameraHum';
	}
}

function UnTrigger(Actor Other, Pawn Instigator)
{
	if (bConfused)
	{
		//return;
		bConfused = false;
		confusionTimer = 0;
		confusionDuration = Default.confusionDuration;
	}
	
	Super.UnTrigger(Other, Instigator);
	
	if (bActive)
	{
		if (Instigator != None)
			Instigator.ClientMessage(msgDeactivated);
		TriggerEvent(False);
		bActive = False;
		LightType = LT_None;
		AmbientSound = None;
		DesiredRotation = origRot;
		hackStrength = 0.0;
	}
}

function TriggerEvent(bool bTrigger)
{
	local VMDBufferPlayer VMP;
	
	bEventTriggered = bTrigger;
	bTrackPlayer = bTrigger;
	triggerTimer = 0;
	
	// now, the camera sounds its own alarm
	if (bTrigger)
	{
		AmbientSound = Sound'Klaxon2';
		SoundVolume = 128;
		SoundRadius = 64;
		LightHue = 0;
		MultiSkins[2] = Texture'RedLightTex';
		
		//MADDERS, 7/24/25: End stasis in radius for alarms. Special treatment.
		class'VMDStaticFunctions'.Static.EndStasisInAOE(Self, Location, 50*(SoundRadius+1));
		AIStartEvent('Alarm', EAITYPE_Audio, SoundVolume/255.0, 50*(SoundRadius+1));
		
		//MADDERS, 8/7/23: Add player stress.
		forEach RadiusActors(class'VMDBufferPlayer', VMP, 25*(SoundRadius+1), Location)
		{
			VMP.VMDModPlayerStress(65, true, 2, true);
		}
		
		// make sure we can't go into stasis while we're alarming
		bStasis = False;
	}
	else
	{
		AmbientSound = Sound'CameraHum';
		SoundRadius = 48;
		SoundVolume = 192;
		LightHue = 80;
		MultiSkins[2] = Texture'GreenLightTex';
		AIEndEvent('Alarm', EAITYPE_Audio);
		
		// reset our stasis info
		bStasis = Default.bStasis;
	}
}

function CheckPlayerVisibility(DeusExPlayer player)
{
	local float yaw, pitch, dist;
	local Actor hit;
	local Vector HitLocation, HitNormal;
	local Rotator rot;
	local VMDBufferPlayer VMP;
	
   	if (Player == None)
      		return;
	dist = Abs(VSize(player.Location - Location));
	
	// if the player is in range
	if ((player.bDetectable) && (!player.bIgnore) && (dist <= cameraRange))
	{
		hit = Trace(HitLocation, HitNormal, player.Location, Location, True);
		if (hit == player)
		{
			// If the player's RadarTrans aug is on, the camera can't see him
         		// DEUS_EX AMSD In multiplayer, we've already done this test with 
         		// AcquireMultiplayerTarget
         		if (Level.Netmode == NM_Standalone)
         		{
	  			//MADDERS: This is actually a potential accessed none waiting to happen x1000. Fix this.
	  			if (Player.AugmentationSystem != None)
	  			{
            				if (player.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') != -1.0)
               					return;
	  			}
				
				//MADDERS, 8/5/25: Somehow failed making this function earlier. Wow.
				if (Player.UsingChargedPickup(class'AdaptiveArmor'))
				{
					return;
				}
         		}
			
			// figure out if we can see the player
			rot = Rotator(player.Location - Location);
			rot.Roll = 0;
			yaw = (Abs(Rotation.Yaw - rot.Yaw)) % 65536;
			pitch = (Abs(Rotation.Pitch - rot.Pitch)) % 65536;
			
			// center the angles around zero
			if (yaw > 32767)
				yaw -= 65536;
			if (pitch > 32767)
				pitch -= 65536;
			
			// if we are in the camera's FOV
			if ((Abs(yaw) < cameraFOV) && (Abs(pitch) < cameraFOV))
			{
				// rotate to face the player
				if (bTrackPlayer)
					DesiredRotation = rot;
				
				lastSeenTimer = 0;
				bPlayerSeen = True;
				bTrackPlayer = True;
            			bFoundCurPlayer = True;
				
				playerLocation = player.Location - vect(0,0,1)*(player.CollisionHeight-5);
				
				// trigger the event if we haven't yet for this sighting
				if ((!bEventTriggered) && (triggerTimer >= triggerDelay) && (Level.Netmode == NM_Standalone))
					TriggerEvent(True);
				
				return;
			}
		}
	}
}

// Transcended - Look for bodies on realistic
function CheckCarcassVisibility(DeusExPlayer player)
{
	local float yaw, pitch, dist;
	local Actor hit;
	local Vector HitLocation, HitNormal;
	local Rotator rot;	
	local DeusExCarcass SeenCarcass, carcass;		// last seen carcass
	local VMDBufferPlayer pc;
	
	pc = VMDBufferPlayer(player);
	
	if (pc == None)
		return;
	
	foreach RadiusActors(class'DeusExCarcass', carcass, cameraRange)
	{
		if ((!carcass.bAnimalCarcass) && (carcass.KillerBindName != "")) // Don't check for dead animals or bodies that were already dead.
		{
			dist = Abs(VSize(carcass.Location - Location));

			// if the carcass is in range
			if ((carcass.bDetectable) && (!carcass.bIgnore) && (dist <= cameraRange))
			{
				hit = Trace(HitLocation, HitNormal, carcass.Location, Location, True);
				if (hit == carcass)
				{
					// figure out if we can see the carcass
					rot = Rotator(carcass.Location - Location);
					rot.Roll = 0;
					yaw = (Abs(Rotation.Yaw - rot.Yaw)) % 65536;
					pitch = (Abs(Rotation.Pitch - rot.Pitch)) % 65536;

					// center the angles around zero
					if (yaw > 32767)
						yaw -= 65536;
					if (pitch > 32767)
						pitch -= 65536;

					// if we are in the camera's FOV
					if ((Abs(yaw) < cameraFOV) && (Abs(pitch) < cameraFOV))
					{
						SeenCarcass = carcass;
						break;
					}
				}
			}
		}
	}
	
	if (SeenCarcass != None)
	{
		// rotate to face the carcass
		if (bTrackPlayer)
			DesiredRotation = rot;

		lastSeenTimer = 0;
		bPlayerSeen = True;
		bTrackPlayer = True;
		bFoundCurPlayer = True;

		playerLocation = SeenCarcass.Location - vect(0,0,1)*(SeenCarcass.CollisionHeight-5);

		// trigger the event if we haven't yet for this sighting
		if ((!bEventTriggered) && (triggerTimer >= triggerDelay) && (Level.Netmode == NM_Standalone))
		{
			TriggerEvent(True);
		}

		return;
	}
	//else if (PC.CombatDifficulty >= 4)
	//	CheckSpydroneVisibility();
}

function Destroyed()
{
	local AlarmUnit TAlarm;
	local VMDBufferPlayer VMP;
	
	Super.Destroyed();
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.bCameraKillAlarm))
	{
		forEach AllActors(class'AlarmUnit', TAlarm)
		{
			if (VSize(TAlarm.Location - Location) < 1536)
			{
				TAlarm.Trigger(Self, VMP);
			}
		}
	}
}

function Tick(float deltaTime)
{
	local float ang, GSpeed;
	local Rotator rot;
   	local DeusExPlayer curplayer;
	local DeusExRootWindow DXRW;
	local VMDBufferPlayer VMP;
	
   	Super.Tick(deltaTime);
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
		
		//MADDERS, 10/30/24: Tweak for adapting to cheat speeds.
		if (AmbientSound != None)
		{
			if (GSpeed > 1.0)
			{
				if (bConfused)
				{
					SoundPitch = Min(255, 128 + (32 * (GSpeed - 1.0)));
				}
				else
				{
					SoundPitch = Min(255, 64 + (16 * (GSpeed - 1.0)));
				}
			}
			else
			{
				if (bConfused)
				{
					SoundPitch = Max(1, 128 * GSpeed);
				}
				else
				{
					SoundPitch = Max(1, 64 * GSpeed);
				}
			}
		}
	}
	
   	curTarget = None;
	
   	// if this camera is not active, get out
	if (!bActive)
	{
      		// DEUS_EX AMSD For multiplayer
      		ReplicatedRotation = DesiredRotation;
		
		MultiSkins[2] = Texture'BlackMaskTex';
		return;
	}
	
	// if we've been EMP'ed, act confused
	if (bConfused)
	{
		confusionTimer += deltaTime;
		
		// pick a random facing at random
		if (confusionTimer % 0.25 > 0.2)
		{
			DesiredRotation.Pitch = origRot.Pitch + 0.5*swingAngle - Rand(swingAngle);
			DesiredRotation.Yaw = origRot.Yaw + 0.5*swingAngle - Rand(swingAngle);
		}
		
		if (confusionTimer > confusionDuration)
		{
			bConfused = False;
			confusionTimer = 0;
			confusionDuration = Default.confusionDuration;
			LightHue = 80;
			MultiSkins[2] = Texture'GreenLightTex';
			SoundPitch = 64;
			DesiredRotation = origRot;
		}
		
		return;
	}

	// check the player's visibility every 0.1 seconds
	if (!bNoAlarm)
	{
		playerCheckTimer += deltaTime;

		if (playerCheckTimer > 0.1)
		{
			playerCheckTimer = 0;
         		if (Level.NetMode == NM_Standalone)
			{
            			CheckPlayerVisibility(DeusExPlayer(GetPlayerPawn()));
			}
         		else
         		{
            			curPlayer = DeusExPlayer(AcquireMultiplayerTarget());
            			if (curPlayer != None)
				{
               				CheckPlayerVisibility(curPlayer);
				}
         		}
		}
	}
	
	// forget about the player after a set amount of time
	if (bPlayerSeen)
	{
		// if the player has been seen, but the camera hasn't triggered yet,
		// provide some feedback to the player (light and sound)
		if (!bEventTriggered)
		{
			triggerTimer += deltaTime;

			if (triggerTimer % 0.5 > 0.4)
			{
				LightHue = 0;
				MultiSkins[2] = Texture'RedLightTex';
				PlaySound(Sound'Beep6',,,, 1280, GSpeed);
				
				VMP = VMDBufferPlayer(GetPlayerPawn());
				if (VMP != None) DXRW = DeusExRootWindow(VMP.RootWindow);
				if ((DXRW != None) && (VMP.HasSkillAugment('LockpickStealthBar')) && (DXRW.HUD != None) && (DXRW.HUD.LightGem != None))
				{
					DeusExRootWindow(VMP.RootWindow).HUD.LightGem.QueueNewColor(0, 1);
				}
			}
			else
			{
				LightHue = 80;
				MultiSkins[2] = Texture'GreenLightTex';
			}
		}
		
		if (lastSeenTimer < memoryTime)
			lastSeenTimer += deltaTime;
		else
		{
			lastSeenTimer = 0;
			bPlayerSeen = False;
			
			// untrigger the event
			TriggerEvent(False);
		}
		
		return;
	}
	
	swingTimer += deltaTime;
	MultiSkins[2] = Texture'GreenLightTex';
	
	// swing back and forth if all is well
	if ((bSwing) && (!bTrackPlayer) && (!bOverwriteControl))
	{
		ang = 2 * Pi * swingTimer / swingPeriod;
		rot = origRot;
		rot.Yaw += Sin(ang) * swingAngle;
		DesiredRotation = rot;
	}
	
   	// DEUS_EX AMSD For multiplayer
   	ReplicatedRotation = DesiredRotation;
}

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
        	local bool bScramblerAugment;
		local float mindmg, GSpeed;
		local VMDBufferPlayer VMP;
		
		VMP = VMDBufferPlayer(EventInstigator);
		
		GSpeed = 1.0;
		if ((Level != None) && (Level.Game != None))
		{
			GSpeed = Level.Game.GameSpeed;
		}
		
        	if ((VMP != None) && (!bLastSplashWasDrone))
		{
			bScramblerAugment = VMP.HasSkillAugment('TagTeamScrambler');
		}
		
		// Transcended - Added
		if (DamageType == 'EMP' || DamageType == 'Shocked')
		{
        		if (bScramblerAugment)
			{
				HackStrength = FClamp(HackStrength - (float(Damage) / 200.0), 0.0, 1.0);
				if (HackStrength <= 0.0)
				{
					MultiSkins[2] = Texture'BlackMaskTex';
					bConfused = False;
					bActive = False;
					LightType = LT_None;
					AmbientSound = None;
					DesiredRotation = origRot;
					return;
				}
			}
			
			// duration is based on daamge
			// 10 seconds min to 30 seconds max
			mindmg = Max(Damage - 15.0, 0.0);
			confusionDuration += mindmg / 5.0;
			confusionTimer = 0;
			if (!bConfused)
			{
				bConfused = True;
				LightHue = 40;
				MultiSkins[2] = Texture'YellowLightTex';
				SoundPitch = 128;
				PlaySound(sound'EMPZap', SLOT_None,,, 1280, GSpeed);
			}
			
			bLastSplashWasDrone = false;
			
			return;
		}
		if (( Level.NetMode != NM_Standalone ) && (EventInstigator.IsA('DeusExPlayer')))
			DeusExPlayer(EventInstigator).ServerConditionalNotifyMsg( DeusExPlayer(EventInstigator).MPMSG_CameraInv );
		
		bLastSplashWasDrone = false;
		
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

function BeginPlay()
{
	Super.BeginPlay();

	origRot = Rotation;
	DesiredRotation = origRot;

	playerLocation = Location;

   	if (Level.NetMode != NM_Standalone)
   	{
      		bInvincible=True;
      		HackStrength = 0.6;
   	}
}

// ------------------------------------------------------------------------
// AcquireMultiplayerTarget()
// DEUS_EX AMSD Copied from Turret so that cameras will track enemy players
// in multiplayer.
// ------------------------------------------------------------------------
function Actor AcquireMultiplayerTarget()
{
   	local Pawn apawn;
	local DeusExPlayer aplayer;
	local Vector dist;

   	//DEUS_EX AMSD See if our old target is still valid.
   	if ((prevtarget != None) && (prevtarget != safetarget) && (Pawn(prevtarget) != None))
   	{
      		if (Pawn(prevtarget).AICanSee(self, 1.0, false, false, false, true) > 0)
      		{
         		if (DeusExPlayer(prevtarget) == None)         
         		{
            			curtarget = prevtarget;
            			return curtarget;
         		}
         		else
         		{
	  			//MADDERS: This is actually a potential accessed none waiting to happen x1000. Fix this.
	  			if (DeusExPlayer(prevtarget).AugmentationSystem != None)
	  			{
            				if (DeusExPlayer(prevtarget).AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0)
            				{
               					curtarget = prevtarget;
               					return curtarget;
            				}
	  			}
         		}
      		}
   	}
	// MB Optimized to use pawn list, previous way used foreach VisibleActors
	apawn = Level.PawnList;
	while ( apawn != None )
	{
      		if (apawn.bDetectable && !apawn.bIgnore && apawn.IsA('DeusExPlayer'))
      		{
			aplayer = DeusExPlayer(apawn);

			dist = aplayer.Location - Location;

			if ( VSize(dist) < CameraRange )
			{
				// Only players we can see
				if ( aplayer.FastTrace( aplayer.Location, Location ))
				{
					//only track players who aren't the safetarget.
					//we already know prevtarget not valid.
					if ((aplayer != safeTarget) && (aplayer != prevTarget))
					{
						if (! ( (TeamDMGame(aplayer.DXGame) != None) &&	(safeTarget != None) &&	(TeamDMGame(aplayer.DXGame).ArePlayersAllied( DeusExPlayer(safeTarget),aplayer)) ) )
						{
	  					 	//MADDERS: This is actually a potential accessed none waiting to happen x1000. Fix this.
	  					 	if (aPlayer.AugmentationSystem != None)
	  					 	{
								// If the player's RadarTrans aug is off, the turret can see him
								if (aplayer.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0)
								{
									curTarget = apawn;
									break;
								}
						 	}
						}
					}
				}
			}
      		}
		apawn = apawn.nextPawn;
	}
   	return curtarget;
}

defaultproperties
{
     swingAngle=8192
     swingPeriod=8.000000
     cameraFOV=4096
     cameraRange=1024
     memoryTime=5.000000
     bActive=True
     confusionDuration=10.000000
     triggerDelay=4.000000
     msgActivated="Camera activated"
     msgDeactivated="Camera deactivated"
     Team=-1
     HitPoints=50
     minDamageThreshold=50
     bInvincible=False
     FragType=Class'DeusEx.MetalFragment'
     ItemName="Surveillance Camera"
     Physics=PHYS_Rotating
     Texture=Texture'DeusExDeco.Skins.SecurityCameraTex2'
     Mesh=LodMesh'DeusExDeco.SecurityCamera'
     SoundRadius=48
     SoundVolume=192
     AmbientSound=Sound'DeusExSounds.Generic.CameraHum'
     CollisionRadius=10.720000
     CollisionHeight=11.000000
     LightType=LT_Steady
     LightBrightness=120
     LightHue=80
     LightSaturation=100
     LightRadius=1
     bRotateToDesired=True
     Mass=20.000000
     Buoyancy=5.000000
     RotationRate=(Pitch=65535,Yaw=65535)
     bVisionImportant=True
     bForceStasis=False // Transcended - Added
     bStasis=False
}
