//=============================================================================
// Human.
//=============================================================================
class Human extends VMDBufferPlayer
	abstract;

var float mpGroundSpeed;
var float mpWaterSpeed;
var float humanAnimRate;

//Added MUS_None.
enum EmusicModeRev
{
	MUS_Ambient,
	MUS_Dying,
	MUS_Combat,
	MUS_Conversation,
	MUS_Outro,
	MUS_None
};

//Music vars
var EmusicModeRev musicModeRev;
var travel bool bEntryOggMissingPrinted;
var bool bLevelInfoMissingPrinted;
var travel bool bInAlternativeMusicMode;

replication 
{
	reliable if (( Role == ROLE_Authority ) && bNetOwner )
		humanAnimRate;
}

function ClosedCaptions(string Type, Human Player);

// ----------------------------------------------------------------------
// UpdateDynamicMusic()
//
// Pattern definitions:
//   0 - Ambient 1
//   1 - Dying
//   2 - Ambient 2 (optional)
//   3 - Combat
//   4 - Conversation
//   5 - Outro
//	 255 - Nothing/Silence.
//
//	Bjorn: The initial code was borrowed from Shifter's DeusExPlayer.
//	But it has been heavily modified by me.
// ----------------------------------------------------------------------
function UpdateDynamicMusic(float deltaTime)
{
	local bool bCombat;
	local bool bPlayTrackerAmbient, bPlayTrackerCombat, bPlayTrackerConvo, bPlayTrackerDying, bPlayTrackerOutro;
	local ScriptedPawn npc;
	local Pawn CurPawn;
	local DeusExLevelInfo info;
	local Music LevelSong;
	local String SongString;
	//local DXOggMusicManager entryOggMgr;
	local Actor EntryOggMgr;
	
	//MADERS, 7/20/25: Dual functionality via this means.
	if (class'VMDStaticFunctions'.Static.GetIntendedMapStyle(Self) != 1)
	{
		Super.UpdateDynamicMusic(DeltaTime);
		return;
	}
	
	//Get the level info so we can determine if we are on any special maps.
	info = GetLevelInfo();

	//If we don't have a DeusExLevelInfo, there is something really wrong. Since we know nothing about the map we must abort.
	if (info == None)
	{
		if (!bLevelInfoMissingPrinted)
		{
			log("RevJCDentonMale.UpdateDynamicMusic: Found no DeusExLevelInfo, aborting!");
			bLevelInfoMissingPrinted = True;
		}
		return;
	}

	//Get the entryOggMgr in the entry level.
	//foreach GetEntryLevel().AllActors(class'DXOggMusicManager', entryOggMgr)
	
	forEach GetEntryLevel().AllActors(class'Actor', EntryOggMgr)
	{
		if (EntryOggMgr.IsA('DXOggMusicManager'))
		{
			break;
		}
	}
	
	if (bUseRevisionSoundtrack)
	{
		//If we don't have an ogg manager use vanilla music, otherwise fetch what we should play.
		if (entryOggMgr != None)
		{
			if (entryOggMgr.GetPropertyText("bAmbientExists") ~= "FILE_Missing")
				bPlayTrackerAmbient = True;
			else
				bPlayTrackerAmbient = False;

			if (entryOggMgr.GetPropertyText("bCombatExists") ~= "FILE_Missing")
				bPlayTrackerCombat = True;
			else
				bPlayTrackerCombat = False;

			if (entryOggMgr.GetPropertyText("bConversationExists") ~= "FILE_Missing")
				bPlayTrackerConvo = True;
			else
				bPlayTrackerConvo = False;

			if (entryOggMgr.GetPropertyText("bOutroExists") ~= "FILE_Missing")
				bPlayTrackerOutro = True;
			else
				bPlayTrackerOutro = False;

			if (entryOggMgr.GetPropertyText("bDeathExists") ~= "FILE_Missing")
				bPlayTrackerDying = True;
			else
				bPlayTrackerDying = False;

			//If we are paused but should play the soundtrack it means we are in the process of switching from vanilla to soundtrack.
			/*if (entryOggMgr.bPaused)
			{
				entryOggMgr.UnPause();
				ClientSetMusic(None, 255, 255, MTRAN_Instant); //Set tracker music to silent.
				musicModeRev = MUS_None;
			}*/
			if (EntryOggMgr.GetPropertyText("bPaused") ~= "True")
			{
				EntryOggMgr.PostBeginPlay();
				ClientSetMusic(None, 255, 255, MTRAN_Instant); //Set tracker music to silent.
				musicModeRev = MUS_None;
			}
		}
		else
		{
			if (!bEntryOggMissingPrinted)
			{
				log("RevJCDentonMale.UpdateDynamicMusic: Found no entry DXOggMusicManager (for some reason)! Playing tracker music!");
				bEntryOggMissingPrinted = True;
			}

			bPlayTrackerAmbient = true;
			bPlayTrackerCombat = true;
			bPlayTrackerConvo = true;
			bPlayTrackerOutro = true;
			bPlayTrackerDying = true;
		}
	}
	else //We should play vanilla music since the soundtrack is off.
	{
		bPlayTrackerAmbient = true;
		bPlayTrackerCombat = true;
		bPlayTrackerConvo = true;
		bPlayTrackerOutro = true;
		bPlayTrackerDying = true;

		bInAlternativeMusicMode = false;

		//Pause ogg music.
		/*if (entryOggMgr != None)
			entryOggMgr.Pause();*/
		if (EntryOggMgr != None)
		{
			EntryOggMgr.PreBeginPlay();
		}
	}

	//== If we have tracker music playing we may as well just stick with that.
	if (Song != None)
		LevelSong = Song;
	else //Otherwise try to get the song of the level.
		LevelSong = Level.Song;


	//log ("musicModeRev: " $ musicModeRev);
	// log("bPlayTrackerAmbient: " $bPlayTrackerAmbient);
	// log ("LevelSong=" $ LevelSong);

	//Normal Revision levels does not have a song by default in the map.
	//If we already have a song (set by this function or in the Training maps for instance), then we don't need to load it.
	if(LevelSong == None || LevelSong.Class.Name == '')
	{
		//Load music from flags.
		SongString = FlagBase.GetName('MusicPackageTrack') $"."$ FlagBase.GetName('MusicPackageTrack');

		//Null check before loading music.
		if(SongString != "None.None" && SongString != "")
		{
			LevelSong = Music(DynamicLoadObject(SongString, class'Music'));

			//Check if we shall play the ambient.
			if (bPlayTrackerAmbient)
			{
				//Use the level's SongSection property to determine what song section is the default for ambient in this map.
				ClientSetMusic(LevelSong, Level.SongSection, 255, MTRAN_Instant);
				musicModeRev = MUS_Ambient;
				log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla ambient!", 'DevRevision');
				ClosedCaptions("MUSICAMB", Self);
			}
			else
			{
				//Play silence. It's important that we play something, cause otherwise later functions won't work.
				ClientSetMusic(LevelSong, 255, 255, MTRAN_Instant);
				musicModeRev = MUS_None;
			}
		}
	}

	//We still don't have a song? Then just fuck it!
	if(LevelSong == None)
		return;

	// DEUS_EX AMSD In singleplayer, do the old thing.
	// In multiplayer, we can come out of dying.
	if (!PlayerIsClient())
		if ((musicModeRev == MUS_Dying) || (musicModeRev == MUS_Outro))
			return;
	else
		if (musicModeRev == MUS_Outro)
			return;


	musicCheckTimer += deltaTime;
	musicChangeTimer += deltaTime;

	if (IsInState('Interpolating'))
	{
		//Don't mess with the music on any of the menu maps or in the intro.
		if ((info.MissionNumber < 0) || (info.MissionNumber == 98))
		{
			//If we should play the ambient track, but we have MUS_None that means that something has killed the ogg music and we need to start up vanilla music.
			if (bPlayTrackerAmbient && musicModeRev == MUS_None)
			{
				ClientSetMusic(LevelSong, Level.SongSection, 255, MTRAN_Instant);
				musicModeRev = MUS_Ambient;
				log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla ambient!", 'DevRevision');
				ClosedCaptions("MUSICAMB", Self);
			}

			return;
		}


		if (musicModeRev != MUS_Outro)
		{
			if (bPlayTrackerOutro)
			{
				ClientSetMusic(LevelSong, 5, 255, MTRAN_FastFade);
				musicModeRev = MUS_Outro;
				log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla outro!", 'DevRevision');
			}
			else
			{
				ClientSetMusic(LevelSong, 255, 255, MTRAN_FastFade);
				musicModeRev = MUS_None;
			}

		}
	}
	else if (IsInState('Conversation'))
	{
		if (musicModeRev != MUS_Conversation)
		{
			//Save our place in the ambient track
			if (musicModeRev == MUS_Ambient)
				savedSection = SongSection;
			else
				savedSection = 255;


			if (bPlayTrackerConvo)
			{
				ClientSetMusic(LevelSong, 4, 255, MTRAN_FastFade);
				musicModeRev = MUS_Conversation;
				log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla convo!", 'DevRevision');
			}
			else
			{
				ClientSetMusic(LevelSong, 255, 255, MTRAN_FastFade);
				musicModeRev = MUS_None;
			}

		}
	}
	else if (IsInState('Dying'))
	{
		if (musicModeRev != MUS_Dying)
		{
			if (bPlayTrackerDying)
			{
				ClientSetMusic(LevelSong, 1, 255, MTRAN_FastFade);
				musicModeRev = MUS_Dying;
				log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla death!", 'DevRevision');
			}
			else
			{
				ClientSetMusic(LevelSong, 255, 255, MTRAN_FastFade);
				musicModeRev = MUS_None;
			}
		}
	}
	else
	{
		// only check for combat music every second
		if (musicCheckTimer >= 1.0)
		{
			musicCheckTimer = 0.0;
			bCombat = False;

			// check a 100 foot radius around me for combat
			for (CurPawn = Level.PawnList; CurPawn != None; CurPawn = CurPawn.NextPawn)
			{
				npc = ScriptedPawn(CurPawn);
				if ((npc != None) && (VSize(npc.Location - Location) < (1600 + npc.CollisionRadius)))
				{
					if ((npc.GetStateName() == 'Attacking') && (npc.Enemy == Self))
					{
						bCombat = True;
						break;
					}
				}
			}

			//If we are in combat.
			if (bCombat)
			{
				//But not we have not set the combat music.
				if (musicModeRev != MUS_Combat)
				{
					// save our place in the ambient track
					if (musicModeRev == MUS_Ambient)
						savedSection = SongSection;
					else
						savedSection = 255;

					//Should we play combat music?
					if(bPlayTrackerCombat)
					{
						ClientSetMusic(LevelSong, 3, 255, MTRAN_FastFade);
						// Special case for endgame
						if (info != None && (Caps(info.mapName) == "15_AREA51_PAGE" || Caps(info.mapName) == "15_AREA51_FINAL") && flagBase != None && flagBase.GetBool('MeetBobPage_Played'))
							ClientSetMusic(LevelSong, 5, 255, MTRAN_FastFade);
						musicModeRev = MUS_Combat;
						log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla combat!", 'DevRevision');
						ClosedCaptions("MUSICCOM", Self);
					}
					else
					{
						ClientSetMusic(LevelSong, 255, 255, MTRAN_FastFade);
						musicModeRev = MUS_None;
					}
				}

				musicChangeTimer = 0.0;
			}
			else if (musicModeRev != MUS_Ambient)
			{
				// wait until we've been out of combat for 5 seconds before switching music
				if (musicChangeTimer >= 5.0)
				{
					// use the default ambient section for this map
					if (savedSection == 255)
						savedSection = Level.SongSection;

					// fade slower for combat transitions
					if (musicModeRev == MUS_Combat)
					{
						if (bPlayTrackerAmbient)
						{
							ClientSetMusic(LevelSong, savedSection, 255, MTRAN_SlowFade);
							musicModeRev = MUS_Ambient;
							log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla ambient!", 'DevRevision');
							ClosedCaptions("MUSICAMB", Self);
						}
						else
						{
							ClientSetMusic(LevelSong, 255, 255, MTRAN_SlowFade);
							musicModeRev = MUS_None;
						}
					}
					else
					{
						if (bPlayTrackerAmbient)
						{
							ClientSetMusic(LevelSong, savedSection, 255, MTRAN_FastFade);
							musicModeRev = MUS_Ambient;
							log("RevJCDentonMale.UpdateDynamicMusic: Playing vanilla ambient!", 'DevRevision');
							ClosedCaptions("MUSICAMB", Self);
						}
						else
						{
							ClientSetMusic(LevelSong, 255, 255, MTRAN_FastFade);
							musicModeRev = MUS_None;
						}
					}

					savedSection = 255;
					musicChangeTimer = 0.0;
				}
			}
		}
	}
}

// ----------------------------------------------------------------------
// PauseMus()
// Pauses music in the entry DXOggMusicManager.
// ----------------------------------------------------------------------
exec function PauseMus()
{
	//local DXOggMusicManager entryDxOgg;
	local Actor EntryDxOgg;
	
	//Find the music manager in the Entry map.
	//foreach GetEntryLevel().AllActors(class'DXOggMusicManager', entryDxOgg)
	forEach GetEntryLevel().AllActors(class'Actor', EntryDxOgg)
	{
		if (EntryDxOgg.IsA('DXOggMusicManager'))
		{
			//entryDxOgg.Pause();
			EntryDXOgg.PreBeginPlay();
			break;
		}
	}
}

// ----------------------------------------------------------------------
// UnpauseMus()
// Unpauses paused music in the entry DXOggMusicManager.
// ----------------------------------------------------------------------
exec function UnpauseMus()
{
	//local DXOggMusicManager entryDxOgg;
	local Actor EntryDxOgg;
	
	//Find the music manager in the Entry map.
	//foreach GetEntryLevel().AllActors(class'DXOggMusicManager', entryDxOgg)
	forEach GetEntryLevel().AllActors(class'Actor', EntryDxOgg)
	{
		if (EntryDxOgg.IsA('DXOggMusicManager'))
		{
			//entryDxOgg.UnPause();
			EntryDXOgg.PostBeginPlay();
			break;
		}
	}
}

function Bool IsFiring()
{
	if ((Weapon != None) && ( Weapon.IsInState('NormalFire') || Weapon.IsInState('ClientFiring') ) ) 
		return True;
	else
		return False;
}

function Bool HasTwoHandedWeapon()
{
	if ((DeusExWeapon(Weapon) != None) && (DeusExWeapon(Weapon).VMDIsTwoHandedWeapon()))
		return True;
	else
		return False;
}

//
// animation functions
//
function PlayTurning()
{
//	ClientMessage("PlayTurning()");
	if (bForceDuck || bCrouchOn || IsLeaning())
		AttemptTweenAnim('CrouchWalk', 0.1);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptTweenAnim('Walk2H', 0.1);
		else
			AttemptTweenAnim('Walk', 0.1);
	}
}

function TweenToWalking(float tweentime)
{
//	ClientMessage("TweenToWalking()");
	if (bForceDuck || bCrouchOn)
		AttemptTweenAnim('CrouchWalk', tweentime);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptTweenAnim('Walk2H', tweentime);
		else
			AttemptTweenAnim('Walk', tweentime);
	}
}

function PlayWalking()
{
	local float newhumanAnimRate;

	newhumanAnimRate = humanAnimRate;

	// UnPhysic.cpp walk speed changed by proportion 0.7/0.3 (2.33), but that looks too goofy (fast as hell), so we'll try something a little slower
	if ( Level.NetMode != NM_Standalone ) 
		newhumanAnimRate = humanAnimRate * 1.75;

	//	ClientMessage("PlayWalking()");
	if (bForceDuck || bCrouchOn)
		AttemptLoopAnim('CrouchWalk', newhumanAnimRate);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptLoopAnim('Walk2H', newhumanAnimRate);
		else
			AttemptLoopAnim('Walk', newhumanAnimRate);
	}
}

function TweenToRunning(float tweentime)
{
//	ClientMessage("TweenToRunning()");
	if (bIsWalking)
	{
		TweenToWalking(0.1);
		return;
	}

	if (IsFiring())
	{
		if (aStrafe != 0)
		{
			if (HasTwoHandedWeapon())
				AttemptPlayAnim('Strafe2H',humanAnimRate, tweentime);
			else
				AttemptPlayAnim('Strafe',humanAnimRate, tweentime);
		}
		else
		{
			if (HasTwoHandedWeapon())
				AttemptPlayAnim('RunShoot2H',humanAnimRate, tweentime);
			else
				AttemptPlayAnim('RunShoot',humanAnimRate, tweentime);
		}
	}
	else if (bOnFire)
		AttemptPlayAnim('Panic',humanAnimRate, tweentime);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptPlayAnim('RunShoot2H',humanAnimRate, tweentime);
		else
			AttemptPlayAnim('Run',humanAnimRate, tweentime);
	}
}

function PlayRunning()
{
//	ClientMessage("PlayRunning()");
	if (IsFiring())
	{
		if (aStrafe != 0)
		{
			if (HasTwoHandedWeapon())
				AttemptLoopAnim('Strafe2H', humanAnimRate);
			else
				AttemptLoopAnim('Strafe', humanAnimRate);
		}
		else
		{
			if (HasTwoHandedWeapon())
				AttemptLoopAnim('RunShoot2H', humanAnimRate);
			else
				AttemptLoopAnim('RunShoot', humanAnimRate);
		}
	}
	else if (bOnFire)
		AttemptLoopAnim('Panic', humanAnimRate);
	else
	{
		if (HasTwoHandedWeapon())
			AttemptLoopAnim('RunShoot2H', humanAnimRate);
		else
			AttemptLoopAnim('Run', humanAnimRate);
	}
}

function TweenToWaiting(float tweentime)
{
//	ClientMessage("TweenToWaiting()");
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
	{
		if (IsFiring())
			AttemptLoopAnim('TreadShoot');
		else
			AttemptLoopAnim('Tread');
	}
	else if (IsLeaning() || bForceDuck)
		AttemptTweenAnim('CrouchWalk', tweentime);
	else if (((AnimSequence == 'Pickup') && bAnimFinished) || ((AnimSequence != 'Pickup') && !IsFiring()))
	{
		if (HasTwoHandedWeapon())
			AttemptTweenAnim('BreatheLight2H', tweentime);
		else
			AttemptTweenAnim('BreatheLight', tweentime);
	}
}

function PlayWaiting()
{
//	ClientMessage("PlayWaiting()");
	if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
	{
		if (IsFiring())
			AttemptLoopAnim('TreadShoot');
		else
			AttemptLoopAnim('Tread');
	}
	else if (IsLeaning() || bForceDuck)
		AttemptTweenAnim('CrouchWalk', 0.1);
	else if (!IsFiring())
	{
		if (HasTwoHandedWeapon())
			AttemptLoopAnim('BreatheLight2H');
		else
			AttemptLoopAnim('BreatheLight');
	}

}

function PlaySwimming()
{
//	ClientMessage("PlaySwimming()");
	AttemptLoopAnim('Tread');
}

function TweenToSwimming(float tweentime)
{
//	ClientMessage("TweenToSwimming()");
	AttemptTweenAnim('Tread', tweentime);
}

function PlayInAir()
{
//	ClientMessage("PlayInAir()");
	if ((!bIsCrouching) && (AnimSequence != 'Jump'))
	{
		AttemptPlayAnim('Jump',3.0,0.1);
	}
}

function PlayLanded(float impactVel)
{
//	ClientMessage("PlayLanded()");
	PlayFootStep();
	if (!bIsCrouching)
		AttemptPlayAnim('Land',3.0,0.1);
}

function PlayDuck()
{
//	ClientMessage("PlayDuck()");
	if ((AnimSequence != 'Crouch') && (AnimSequence != 'CrouchWalk'))
	{
		if (IsFiring())
			AttemptPlayAnim('CrouchShoot',,0.1);
		else
			AttemptPlayAnim('Crouch',,0.1);
	}
	else
		AttemptTweenAnim('CrouchWalk', 0.1);
}

function PlayRising()
{
//	ClientMessage("PlayRising()");
	AttemptPlayAnim('Stand',,0.1);
}

function PlayCrawling()
{
//	ClientMessage("PlayCrawling()");
	if (IsFiring())
		AttemptLoopAnim('CrouchShoot');
	else
		AttemptLoopAnim('CrouchWalk');
}

function PlayFiring()
{
	local DeusExWeapon W;

//	ClientMessage("PlayFiring()");

	W = DeusExWeapon(Weapon);

	if ((W != None) && (!IsInState('Dying')))
	{
		if (IsInState('PlayerSwimming') || (Physics == PHYS_Swimming))
			AttemptLoopAnim('TreadShoot',,0.1);
		else if (W.bHandToHand)
		{
			if (bAnimFinished || (AnimSequence != 'Attack'))
				AttemptPlayAnim('Attack',W.VMDGetCorrectAnimRate(1.0, False),0.1);
		}
		else if (bIsCrouching || IsLeaning())
			AttemptLoopAnim('CrouchShoot',,0.1);
		else
		{
			if (HasTwoHandedWeapon())
				AttemptLoopAnim('Shoot2H',,0.1);
			else
				AttemptLoopAnim('Shoot',,0.1);
		}
	}
}

function PlayWeaponSwitch(Weapon newWeapon)
{
//	ClientMessage("PlayWeaponSwitch()");
	if ((!bIsCrouching) && (!bForceDuck) && (!bCrouchOn) && (!IsLeaning()) && (!IsInState('Dying')))
		AttemptPlayAnim('Reload');
}

function PlayDying(name damageType, vector hitLoc)
{
	local Vector X, Y, Z;
	local float dotp;

//	ClientMessage("PlayDying()");
	GetAxes(Rotation, X, Y, Z);
	dotp = (Location - HitLoc) dot X;

	if (Region.Zone.bWaterZone)
	{
		AttemptPlayAnim('WaterDeath',,0.1);
	}
	else
	{
		// die from the correct side
		if (dotp < 0.0)		// shot from the front, fall back
			AttemptPlayAnim('DeathBack',,0.1);
		else				// shot from the back, fall front
			AttemptPlayAnim('DeathFront',,0.1);
	}
	
	DeathDamageType = DamageType;
	PlayDyingSound();
}

//
// sound functions
//

function float RandomPitch()
{
	local float GMult;
	
	GMult = 1.0;
	if ((Level != None) && (Level.Game != None)) GMult = Level.Game.GameSpeed;
	
	return (1.1 - 0.2*FRand()) * GMult;
}

function Gasp()
{
	if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCGasp', SLOT_Pain,,,, RandomPitch());
	else PlaySound(sound'MaleGasp', SLOT_Pain,,,, RandomPitch());
}

//------------------------------
//MADDERS: Female sounds. Experimental.
//------------------------------
function PlayDyingSound()
{
	local Sound TDie;
	
	if (Region.Zone.bWaterZone)
	{
		if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCWaterDeath', SLOT_Pain,,,, RandomPitch());
		else PlaySound(sound'MaleWaterDeath', SLOT_Pain,,,, RandomPitch());
	}
	else
	{
		if (!class'VMDStaticFunctions'.Static.DamageTypeIsNonLethal(DeathDamageType))
		{
			TDie = Sound'MaleDeath';
			if (bIsFemale || bAssignedFemale) TDie = Sound'VMDFJCDeath';
		}
		else
		{
			TDie = Sound'MaleUnconscious';
			if (bIsFemale || bAssignedFemale) TDie = Sound'VMDFJCUnconscious';
		}
		
		if (Health < -80)
		{
			switch(Die)
			{
				case Sound'ChildDeath':
					TDie = Sound'ChildDeathGibbed';
				break;
				case Sound'FemaleDeath':
				case Sound'FemaleUnconscious':
					TDie = Sound'FemaleDeathGibbed';
				break;
				case Sound'MaleDeath':
				case Sound'MaleUnconscious':
					TDie = Sound'MaleDeathGibbed';
				break;
				case Sound'VMDFJCDeath':
				case Sound'VMDFJCUnconscious':
					TDie = Sound'VMDFJCDeathGibbed';
				break;
			}
		}
		
		PlaySound(TDie, SLOT_Pain,,,, RandomPitch());
	}
}

function PlayTakeHitSound(int Damage, name damageType, int Mult)
{
	local float rnd;

	if ( Level.TimeSeconds - LastPainSound < FRand() + 0.5)
		return;

	LastPainSound = Level.TimeSeconds;
	
	//MADDERS, 1/17/21: Don't make pain noises for these.
	switch(DamageType)
	{
		case 'EMP':
		case 'NanoVirus':
		case 'OwnedHalonGas':
			AISendEvent('LoudNoise', EAITYPE_Audio, FMax(Mult * TransientSoundVolume, Mult * 2.0));
			return;
		break;
	}
	
	//MADDERS: Head region determines damage sound now, unless it's drowning.
	if (HeadRegion.Zone.bWaterZone || damageType == 'Drowned')
	{
		if (damageType == 'Drowned' || HeadRegion.Zone.bWaterZone)
		{
			if (FRand() < 0.8)
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCDrown', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MaleDrown', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
		}
		else
		{
			if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			else PlaySound(sound'MalePainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
	}
	else
	{
		// Body hit sound for multiplayer only
		if (((damageType=='Shot') || (damageType=='AutoShot'))  && ( Level.NetMode != NM_Standalone ))
		{
			PlaySound(sound'BodyHit', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		
		if ((damageType == 'TearGas') || (damageType == 'HalonGas'))
		{
			if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCEyePain', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			else PlaySound(sound'MaleEyePain', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		else if (damageType == 'PoisonGas' || damageType == 'DrugDamage')
		{
			if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCCough', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			else PlaySound(sound'MaleCough', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
		}
		else
		{
			rnd = FRand();
			if (rnd < 0.33)
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MalePainSmall', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
			else if (rnd < 0.66)
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainMedium', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MalePainMedium', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
			else
			{
				if (bIsFemale || bAssignedFemale) PlaySound(sound'VMDFJCPainLarge', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
				else PlaySound(sound'MalePainLarge', SLOT_Pain, FMax(Mult * TransientSoundVolume, Mult * 2.0),,, RandomPitch());
			}
		}
		AISendEvent('LoudNoise', EAITYPE_Audio, FMax(Mult * TransientSoundVolume, Mult * 2.0));
	}
}

function UpdateAnimRate( float augValue )
{
	if ( Level.NetMode != NM_Standalone )
	{
		if ( augValue == -1.0 )
			humanAnimRate = (Default.mpGroundSpeed/320.0);
		else
			humanAnimRate = (Default.mpGroundSpeed/320.0) * augValue * 0.85;	// Scale back about 15% so were not too fast
	}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	// If this is a netgame, then override defaults
	if ( Level.NetMode != NM_StandAlone )
	{
		GroundSpeed = mpGroundSpeed;
		WaterSpeed = mpWaterSpeed;
		humanAnimRate = (GroundSpeed/320.0);
	}
	
	if (!bVMDUpdateDone)
	{
		if (MenuThemeName == "Default")
			MenuThemeName = "VMD"; // Transcended - My own flare, MADDERS, 3/3/21: YOINK!
		if (HUDThemeName == "Default")
			HUDThemeName = "VMD"; // Transcended - My own flare, MADDERS, 3/3/21: YOINK!
		
		bVMDUpdateDone = True;
	}
	ConsoleCommand("Set RFRootWindow bUseRFGoalWin False"); // Allow note searching in fullscreen
	SaveConfig();
}

defaultproperties
{
     bUseRevisionSoundtrack=True
     
     mpGroundSpeed=230.000000
     mpWaterSpeed=110.000000
     humanAnimRate=1.000000
     bIsHuman=True
     WaterSpeed=300.000000
     AirSpeed=4000.000000
     AccelRate=1000.000000
     JumpZ=300.000000
     BaseEyeHeight=40.000000
     UnderWaterTime=20.000000
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     Mass=150.000000
     Buoyancy=155.000000
     RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
}
