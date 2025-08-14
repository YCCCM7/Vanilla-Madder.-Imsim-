//=============================================================================
// AutoTurret.
//=============================================================================
class AutoTurret extends VMDBufferDeco;

var AutoTurretGun gun;

var() localized String titleString;		// So we can name specific turrets in multiplayer
var() bool bTrackPawnsOnly;
var() bool bTrackPlayersOnly;
var() bool bActive;
var() int maxRange;
var() float fireRate;
var() float gunAccuracy;
var() int gunDamage;
var() int ammoAmount;
var Actor curTarget;
var Actor prevTarget;         // target we had last tick.
var Pawn safeTarget;          // in multiplayer, this actor is strictly off-limits
                               // Usually for the player who activated the turret.
var float fireTimer;
var bool bConfused;				// used when hit by EMP
var float confusionTimer;		// how long until turret resumes normal operation
var float confusionDuration;	// how long does an EMP hit last?
var Actor LastTarget;			// what was our last target?
var float pitchLimit;			// what's the maximum pitch?
var Rotator origRot;			// original rotation
var bool bPreAlarmActiveState;	// was I previously awake or not?
var bool bDisabled;				// have I been hacked or shut down by computers?
var float TargetRefreshTime;      // used for multiplayer to reduce rate of checking for targets.

var int team;						// Keep track of team the turrets on

var int mpTurretDamage;			// Settings for multiplayer
var int mpTurretRange;

var bool bComputerReset;			// Keep track of if computer has been reset so we avoid all actors checks

var bool bSwitching;
var float SwitchTime, beepTime;
var Pawn savedTarget;

var bool bLastSplashWasDrone; //MADDERS, 12/28/23: We're putting a stop to megahertz + spydrone combo. RIP.

// networking replication
replication
{
   	//server to client
   	reliable if (Role == ROLE_Authority)
      		safeTarget, bDisabled, bActive, team, titleString;
}

//MADDERS, 11/30/23: Oops. Stop triggering ourselves and activating the turret when frobbed.
function Frob(Actor Frobber, Inventory frobWith)
{
	local Actor A;
	local Pawn P;
	local DeusExPlayer Player;
	
	P = Pawn(Frobber);
	Player = DeusExPlayer(Frobber);
	
	Super(Decoration).Frob(Frobber, frobWith);
	
	// First check to see if there's a conversation associated with this 
	// decoration.  If so, trigger the conversation instead of triggering
	// the event for this decoration
	
	if (Player != None)
	{
		if (player.StartConversation(Self, IM_Frob))
			return;
	}
}

// if we are triggered, turn us on
function Trigger(Actor Other, Pawn Instigator)
{
	if (bConfused || bDisabled)
		return;
	
	if (!bActive)
	{
		bActive = True;
		AmbientSound = Default.AmbientSound;
	}

	Super.Trigger(Other, Instigator);
}

// if we are untriggered, turn us off
function UnTrigger(Actor Other, Pawn Instigator)
{
	if (bDisabled || bTrackPawnsOnly)
	{
		return;
	}
	
	if (bConfused)
	{
		//return;
		bConfused = false;
		confusionTimer = 0;
		confusionDuration = Default.confusionDuration;
	}
	
	if (bActive)
	{
		bActive = False;
		AmbientSound = None;
	}
	
	Super.UnTrigger(Other, Instigator);
}

function Destroyed()
{
	if (gun != None)
	{
		gun.Destroy();
		gun = None;
	}

	Super.Destroyed();		
}

function UpdateSwitch()
{
	local float GSpeed;
	
	if ( Level.Timeseconds > SwitchTime )
	{
		bSwitching = False;
		//safeTarget = savedTarget;
		SwitchTime = 0;
		beepTime = 0;
	}
	else
	{
		if ( Level.Timeseconds > beepTime )
		{
			GSpeed = 1.0;
			if (Level.Game != None)
			{
				GSpeed = Level.Game.GameSpeed;
			}
			PlaySound(Sound'TurretSwitch', SLOT_Interact, 1.0,, maxRange, GSpeed );
			beepTime = Level.Timeseconds + 0.75;
		}
	}
}

function SetSafeTarget( Pawn newSafeTarget )
{
	local DeusExPlayer aplayer;

	bSwitching = True;
	SwitchTime = Level.Timeseconds + 2.5;
	beepTime = 0.0;
   	safeTarget = newSafeTarget;
   	//savedTarget = newSafeTarget;
}

function Actor AcquireMultiplayerTarget()
{
	local float GSpeed;
	local Vector dist;
	local Actor noActor;
	local DeusExPlayer aplayer, TPlayer;
   	local Pawn apawn;

	if ( bSwitching )
	{
		noActor = None;
		return noActor;
	}
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
   	//DEUS_EX AMSD See if our old target is still valid.
   	if ((prevtarget != None) && (prevtarget != safetarget) && (Pawn(prevtarget) != None))
   	{
		TPlayer = DeusExPlayer(PrevTarget);
      		if (Pawn(prevtarget).AICanSee(self, 1.0, false, false, false, true) > 0)
      		{
         		if ((TPlayer != None) && (!TPlayer.bHidden))
         		{
				dist = DeusExPlayer(prevtarget).Location - gun.Location;
				if (VSize(dist) < maxRange )
				{
					curtarget = prevtarget;
					return curtarget;
				}
         		}
         		else
         		{
	  			//MADDERS: This is actually a potential accessed none waiting to happen x1000. Fix this.
	  			if (TPlayer.AugmentationSystem != None)
	  			{
            				if ((TPlayer.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0) && (!TPlayer.UsingChargedPickup(class'AdaptiveArmor')) && (!TPlayer.bHidden ))
            				{
						dist = DeusExPlayer(prevtarget).Location - gun.Location;
						if (VSize(dist) < maxRange )
						{
							curtarget = prevtarget;
							return curtarget;
						}
            				}
	  			}
         		}
      		}
   	}
	// MB Optimized to use pawn list, previous way used foreach VisibleActors
	apawn = gun.Level.PawnList;
	while ( apawn != None )
	{
      		if (apawn.bDetectable && !apawn.bIgnore && apawn.IsA('DeusExPlayer'))
      		{
			aplayer = DeusExPlayer(apawn);

			dist = aplayer.Location - gun.Location;

			if ( VSize(dist) < maxRange )
			{
				// Only players we can see
				if ( aplayer.FastTrace( aplayer.Location, gun.Location ))
				{
					//only shoot at players who aren't the safetarget.
					//we alreayd know prevtarget not valid.
					if ((aplayer != safeTarget) && (aplayer != prevTarget))
					{
						if (! ( (TeamDMGame(aplayer.DXGame) != None) &&	(safeTarget != None) &&	(TeamDMGame(aplayer.DXGame).ArePlayersAllied( DeusExPlayer(safeTarget),aplayer)) ) )
						{
	  					 	//MADDERS: This is actually a potential accessed none waiting to happen x1000. Fix this.
	  					 	if (aPlayer.AugmentationSystem != None)
	  					 	{
								// If the player's RadarTrans aug is off, the turret can see him
								if ((aplayer.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0) && (!APlayer.UsingChargedPickup(class'AdaptiveArmor')) && (!aplayer.bHidden))
								{
									curTarget = apawn;
									PlaySound(Sound'TurretLocked', SLOT_Interact, 1.0,, maxRange, GSpeed);
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

function Tick(float deltaTime)
{
	local bool bSwitched;
	local float near, GSpeed;
	local Rotator destRot;
	local DeusExDecoration deco;
	local DeusExPlayer DXP;
	local Pawn pawn;
	local ScriptedPawn sp;
	
	Super.Tick(deltaTime);
	
	bSwitched = False;
	
	if (bSwitching)
	{
		UpdateSwitch();
		return;
	}
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	// Make sure everything is valid and account for when players leave or switch teams
	if ((!bDisabled) && (Level.NetMode != NM_Standalone))
	{
		if (safeTarget == None)
		{
			bDisabled = True;
			bComputerReset = False;
		}
		else
		{
			if (DeusExPlayer(safeTarget) != None)
			{
				if ((TeamDMGame(DeusExPlayer(safeTarget).DXGame) != None) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.team != team))
					bSwitched = True;
				else if ((DeathMatchGame(DeusExPlayer(safeTarget).DXGame) != None ) && (DeusExPlayer(safeTarget).PlayerReplicationInfo.PlayerID != team))
					bSwitched = True;
				
				if ( bSwitched )
				{
					bDisabled = True;
					safeTarget = None;
					bComputerReset = False;
				}
			}
		}
	}
	if ((bDisabled) && (Level.NetMode != NM_Standalone))
	{
		team = -1;
		safeTarget = None;
		if ( !bComputerReset )
		{
			gun.ResetComputerAlignment();
			bComputerReset = True;
		}
	}

	if (bConfused)
	{
		confusionTimer += deltaTime;

		// pick a random facing
		if (confusionTimer % 0.25 > 0.2)
		{
			gun.DesiredRotation.Pitch = origRot.Pitch + (pitchLimit / 2 - Rand(pitchLimit));
			gun.DesiredRotation.Yaw = Rand(65535);
		}
		if (confusionTimer > confusionDuration)
		{
			bConfused = False;
			confusionTimer = 0;
			confusionDuration = Default.confusionDuration;
		}
	}

	if ((bActive) && (!bDisabled))
	{
		curTarget = None;

		if (!bConfused)
		{
			// if we've been EMP'ed, act confused
			if ((Level.NetMode != NM_Standalone) && (Role == ROLE_Authority))
			{
				// DEUS_EX AMSD If in multiplayer, get the multiplayer target.

				if (TargetRefreshTime < 0)
					TargetRefreshTime = 0;
         
				TargetRefreshTime = TargetRefreshTime + deltaTime;

				if (TargetRefreshTime >= 0.3)
				{
					TargetRefreshTime = 0;
					curTarget = AcquireMultiplayerTarget();
					if (( curTarget != prevTarget ) && ( curTarget == None ))
							PlaySound(Sound'TurretUnlocked', SLOT_Interact, 1.0,, maxRange, GSpeed);
					prevtarget = curtarget;
				}
				else
				{
					curTarget = prevtarget;
				}
			}
			else
			{
				//
				// Logic table for turrets
				//
				// bTrackPlayersOnly		bTrackPawnsOnly		Should Attack
				// 			T						X				Allies
				//			F						T				Enemies
				//			F						F				Everything
				//
         
				// Attack allies and neutrals
				if (bTrackPlayersOnly || (!bTrackPlayersOnly && !bTrackPawnsOnly))
				{
					foreach gun.VisibleActors(class'Pawn', pawn, maxRange, gun.Location)
					{
						if ((pawn.bDetectable) && (!pawn.bIgnore) && (!Pawn.bHidden))
						{
							DXP = DeusExPlayer(Pawn);
							if (DXP != None)
							{
	 						 	//MADDERS: This is actually a potential accessed none waiting to happen x1000. Fix this.
	 						 	if (DXP.AugmentationSystem != None)
	 						 	{
									// If the player's RadarTrans aug is off, the turret can see him
									if ((DXP.AugmentationSystem.GetAugLevelValue(class'AugRadarTrans') == -1.0) && (!DXP.UsingChargedPickup(class'AdaptiveArmor')))
									{
										curTarget = pawn;
										break;
									}
							 	}
							}
							else if (pawn.IsA('ScriptedPawn') && (ScriptedPawn(pawn).GetPawnAllianceType(GetPlayerPawn()) != ALLIANCE_Hostile) && (pawn.Mass > 2))
							{
								curTarget = pawn;
								break;
							}
						}
					}
				}
         
				if (!bTrackPlayersOnly)
				{
					// Attack everything
					if (!bTrackPawnsOnly)
					{
						foreach gun.VisibleActors(class'DeusExDecoration', deco, maxRange, gun.Location)
						{
							if (!deco.IsA('ElectronicDevices') && !deco.IsA('AutoTurret') &&
								!deco.bInvincible && deco.bDetectable && !deco.bIgnore)
							{
								curTarget = deco;
								break;
							}
						}
					}
            
					// Attack enemies
					foreach gun.VisibleActors(class'ScriptedPawn', sp, maxRange, gun.Location)
					{
						if (sp.bDetectable && !sp.bIgnore && (sp.GetPawnAllianceType(GetPlayerPawn()) == ALLIANCE_Hostile))
						{
							curTarget = sp;
							break;
						}
					}
				}
			}

			// if we have a target, rotate to face it
			if (curTarget != None)
			{
				destRot = Rotator(curTarget.Location - gun.Location);
				gun.DesiredRotation = destRot;
				near = pitchLimit / 2;
				gun.DesiredRotation.Pitch = FClamp(gun.DesiredRotation.Pitch, origRot.Pitch - near, origRot.Pitch + near);
			}
			else
				gun.DesiredRotation = origRot;
		}
	}
	else
	{
		if (!bConfused)
			gun.DesiredRotation = origRot;
	}
	
	near = (Abs(gun.Rotation.Pitch - gun.DesiredRotation.Pitch)) % 65536;
	near += (Abs(gun.Rotation.Yaw - gun.DesiredRotation.Yaw)) % 65536;
	
	if ((bActive) && (!bDisabled))
	{
		// play an alert sound and light up
		if ((curTarget != None) && (curTarget != LastTarget))
			PlaySound(Sound'Beep6',,,, 1280, GSpeed);

		// if we're aiming close enough to our target
		if (curTarget != None)
		{
			gun.MultiSkins[1] = Texture'RedLightTex';
			if ((near < 4096) && (((Abs(gun.Rotation.Pitch - destRot.Pitch)) % 65536) < 8192))
			{
				if (fireTimer > fireRate)
				{
					Fire();
					fireTimer = 0;
				}
			}
		}
		else
		{
			if (gun.IsAnimating())
				gun.PlayAnim('Still', 10.0, 0.001);

			if (bConfused)
				gun.MultiSkins[1] = Texture'YellowLightTex';
			else
				gun.MultiSkins[1] = Texture'GreenLightTex';
		}

		fireTimer += deltaTime;
		LastTarget = curTarget;
	}
	else
	{
		if (gun.IsAnimating())
			gun.PlayAnim('Still', 10.0, 0.001);
		gun.MultiSkins[1] = None;
	}

	// make noise if we're still moving
	if (near > 64)
	{
		gun.AmbientSound = Sound'AutoTurretMove';
		if (bConfused)
			gun.SoundPitch = 128;
		else
			gun.SoundPitch = 64;
	}
	else
		gun.AmbientSound = None;
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
		
		if (DamageType == 'EMP' || DamageType == 'Shocked')
		{
        		if (bScramblerAugment)
			{
				Gun.HackStrength = FClamp(Gun.HackStrength - (float(Damage) / 200.0), 0.0, 1.0);
				if (Gun.HackStrength <= 0.0)
				{
					bConfused = false;
					if (!bDisabled)
					{
						Gun.HackAction(DeusExPlayer(EventInstigator), True);
					}
					return;
				}
			}
			
			// duration is based on daamge
			// 10 seconds min to 30 seconds max
			mindmg = Max(Damage - 15.0, 0.0);
			confusionDuration += mindmg / 5.0;
         		confusionDuration = FClamp(confusionDuration,10.0,30.0);
			confusionTimer = 0;
			if (!bConfused)
			{
				bConfused = True;
				PlaySound(sound'EMPZap', SLOT_None,,, 1280, GSpeed);
			}
			
			bLastSplashWasDrone = false;
			
			return;
		}
		if (( Level.NetMode != NM_Standalone ) && (EventInstigator.IsA('DeusExPlayer')))
			DeusExPlayer(EventInstigator).ServerConditionalNotifyMsg( DeusExPlayer(EventInstigator).MPMSG_TurretInv );
		
		bLastSplashWasDrone = false;
		
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

function Fire()
{
	local float GSpeed;
	local Rotator rot;
	local Vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local Actor hit;
	local Pawn attacker;
	local ShellCasing shell;
	local Spark spark;
	
	if ((Gun != None) && (!Gun.IsAnimating()))
		gun.LoopAnim('Fire');
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	// CNN - give turrets infinite ammo
	//MADDERS: Nah.
	if (ammoAmount > 0)
	{
		ammoAmount--;
		
		GetAxes(gun.Rotation, X, Y, Z);
		StartTrace = gun.Location;
		EndTrace = StartTrace + gunAccuracy * (FRand()-0.5)*Y*1000 + gunAccuracy * (FRand()-0.5)*Z*1000 ;
		EndTrace += 10000 * X;
		hit = Trace(HitLocation, HitNormal, EndTrace, StartTrace, True);

		// spawn some effects
      		if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      		{
         		shell = None;
      		}
      		else
      		{
         		shell = Spawn(class'ShellCasing',,, gun.Location);
      		}
		if (shell != None)
			shell.Velocity = Vector(gun.Rotation - rot(0,16384,0)) * 100 + VRand() * 30;

		MakeNoise(1.0);
		PlaySound(sound'PistolFire', SLOT_None,,,, GSpeed);
		AISendEvent('LoudNoise', EAITYPE_Audio);

		// muzzle flash
		gun.LightType = LT_Steady;
		gun.MultiSkins[2] = Texture'FlatFXTex34';
		SetTimer(0.1, False);

		// randomly draw a tracer
		if (FRand() < 0.5)
		{
			if (VSize(HitLocation - StartTrace) > 250)
			{
				rot = Rotator(EndTrace - StartTrace);
				Spawn(class'Tracer',,, StartTrace + 96 * Vector(rot), rot);
			}
		}

		if (hit != None)
		{
         		if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
         		{
            			spark = None;
         		}
         		else
         		{
            			// spawn a little spark and make a ricochet sound if we hit something
            			spark = spawn(class'Spark',,,HitLocation+HitNormal, Rotator(HitNormal));
         		}
			
			if (spark != None)
			{
				spark.DrawScale = 0.05;
				PlayHitSound(spark, hit);
			}

			attacker = None;
			if ((curTarget == hit) && !curTarget.IsA('PlayerPawn'))
				attacker = GetPlayerPawn();
         		if (Level.NetMode != NM_Standalone)
            			attacker = safetarget;
			if ( hit.IsA('DeusExPlayer') && ( Level.NetMode != NM_Standalone ))
				DeusExPlayer(hit).myTurretKiller = Self;
			hit.TakeDamage(gunDamage, attacker, HitLocation, 1000.0*X, 'AutoShot');

			if (hit.IsA('Pawn') && !hit.IsA('Robot'))
				SpawnBlood(HitLocation, HitNormal);
			else if ((hit == Level) || hit.IsA('Mover'))
				SpawnEffects(HitLocation, HitNormal, hit);
		}
	}
	else
	{
		PlaySound(sound'DryFire', SLOT_None,,,, GSpeed);
	}
}

function SpawnBlood(Vector HitLocation, Vector HitNormal)
{
	local rotator rot;
	
	rot = Rotator(Location - HitLocation);
	rot.Pitch = 0;
	rot.Roll = 0;
	
   	if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      		return;
	
	spawn(class'BloodSpurt',,,HitLocation+HitNormal, rot);
	spawn(class'BloodDrop',,,HitLocation+HitNormal);
	if (FRand() < 0.5)
		spawn(class'BloodDrop',,,HitLocation+HitNormal);
}

simulated function SpawnEffects(Vector HitLocation, Vector HitNormal, Actor Other)
{
	local SmokeTrail puff;
	local int i;
	local BulletHole hole;
	local Rotator rot;

   	if ((DeusExMPGame(Level.Game) != None) && (!DeusExMPGame(Level.Game).bSpawnEffects))
      		return;

   	if (FRand() < 0.5)
	{
		puff = spawn(class'SmokeTrail',,,HitLocation+HitNormal, Rotator(HitNormal));
		if (puff != None)
		{
			puff.DrawScale *= 0.3;
			puff.OrigScale = puff.DrawScale;
			puff.LifeSpan = 0.25;
			puff.OrigLifeSpan = puff.LifeSpan;
		}
	}

	if (!Other.IsA('BreakableGlass'))
		for (i=0; i<2; i++)
			if (FRand() < 0.8)
				spawn(class'Rockchip',,,HitLocation+HitNormal);

	hole = spawn(class'BulletHole', Other,, HitLocation, Rotator(HitNormal));

	// should we crack glass?
	if (GetWallMaterial(HitLocation, HitNormal) == 'Glass')
	{
		if (FRand() < 0.5)
			hole.Texture = Texture'FlatFXTex29';
		else
			hole.Texture = Texture'FlatFXTex30';

		hole.DrawScale = 0.1;
		hole.ReattachDecal();
	}
}

function name GetWallMaterial(vector HitLocation, vector HitNormal)
{
	local vector EndTrace, StartTrace;
	local actor newtarget;
	local int texFlags;
	local name texName, texGroup;

	StartTrace = HitLocation + HitNormal*16;		// make sure we start far enough out
	EndTrace = HitLocation - HitNormal;

	foreach TraceTexture(class'Actor', newtarget, texName, texGroup, texFlags, StartTrace, HitNormal, EndTrace)
		if ((newtarget == Level) || newtarget.IsA('Mover'))
			break;

	return texGroup;
}

function PlayHitSound(actor destActor, Actor hitActor)
{
	local float rnd, GSpeed;
	local sound snd;
	
	GSpeed = 1.0;
	if ((Level != None) && (Level.Game != None))
	{
		GSpeed = Level.Game.GameSpeed;
	}
	
	rnd = FRand();

	if (rnd < 0.25)
		snd = sound'Ricochet1';
	else if (rnd < 0.5)
		snd = sound'Ricochet2';
	else if (rnd < 0.75)
		snd = sound'Ricochet3';
	else
		snd = sound'Ricochet4';

	// play a different ricochet sound if the object isn't damaged by normal bullets
	if (hitActor != None) 
	{
		if (hitActor.IsA('DeusExDecoration') && (DeusExDecoration(hitActor).minDamageThreshold > 10))
			snd = sound'ArmorRicochet';
		else if (hitActor.IsA('Robot'))
			snd = sound'ArmorRicochet';
	}
	
	if (destActor != None)
		destActor.PlaySound(snd, SLOT_None,,, 1024, (1.1 - (0.2*FRand())) * GSpeed);
}

// turn off the muzzle flash
simulated function Timer()
{
	gun.LightType = LT_None;
	gun.MultiSkins[2] = None;
}

function AlarmHeard(Name event, EAIEventState state, XAIParams params)
{
	if (state == EAISTATE_Begin)
	{
		if (!bActive)
		{
			bPreAlarmActiveState = bActive;
			bActive = True;
		}
	}
	else if (state == EAISTATE_End)
	{
		if (bActive)
			bActive = bPreAlarmActiveState;
	}
}

function PreBeginPlay()
{
	local Vector v1, v2;
	local class<AutoTurretGun> gunClass;
	local Rotator rot;

	Super.PreBeginPlay();

	if (IsA('AutoTurretSmall'))
		gunClass = class'AutoTurretGunSmall';
	else
		gunClass = class'AutoTurretGun';

	rot = Rotation;
	rot.Pitch = 0;
	rot.Roll = 0;
	origRot = rot;
	if (!bDeleteMe) 	// Transcended - Added
		gun = Spawn(gunClass, Self,, Location, rot);
	
	if (gun != None)
	{
		v1.X = 0;
		v1.Y = 0;
		v1.Z = CollisionHeight + gun.Default.CollisionHeight;
		v2 = v1 >> Rotation;
		v2 += Location;
		
		gun.SetLocation(v2);
		gun.SetBase(Self);
		Gun.AttachOff = Gun.Location - Location;
	}

	// set up the alarm listeners
	AISetEventCallback('Alarm', 'AlarmHeard');

	if ( Level.NetMode != NM_Standalone )
	{
		maxRange = mpTurretRange;
		gunDamage = mpTurretDamage;
		bInvincible = True;
      		bDisabled = !bActive;
	}
}

function PostBeginPlay()
{
   	safeTarget = None;
   	prevTarget = None;
   	TargetRefreshTime = 0;
   	Super.PostBeginPlay();
}

function string VMDGetItemName()
{
	local string Ret;
	local VMDBufferPlayer VMP;
	
	Ret = ItemName;
	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (VMP.HasSkillAugment('TagTeamMiniTurret')))
	{
		Ret = Ret@"("$AmmoAmount$")";
	}
	
	return Ret;
}

defaultproperties
{
     titleString="AutoTurret"
     bTrackPlayersOnly=True
     bActive=False
     maxRange=512
     fireRate=0.250000
     gunAccuracy=0.500000
     gunDamage=5
     AmmoAmount=300 //MADDERS: Nerfed from 1000, then buffed from 100, and then 200 after.
     confusionDuration=10.000000
     pitchLimit=11000.000000
     Team=-1
     mpTurretDamage=20
     mpTurretRange=1024
     HitPoints=50
     minDamageThreshold=50
     bHighlight=False
     ItemName="Turret Base"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.AutoTurretBase'
     SoundRadius=48
     SoundVolume=192
     AmbientSound=Sound'DeusExSounds.Generic.AutoTurretHum'
     CollisionRadius=14.000000
     CollisionHeight=20.200001
     Mass=50.000000
     Buoyancy=10.000000
     bVisionImportant=True
}
