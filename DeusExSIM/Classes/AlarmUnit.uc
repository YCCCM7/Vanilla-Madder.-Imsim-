//=============================================================================
// AlarmUnit.
//=============================================================================
class AlarmUnit extends HackableDevices;

#exec OBJ LOAD FILE=Ambient

var() int alarmTimeout;
var localized string msgActivated;
var localized string msgDeactivated;
var bool bActive;
var float curTime;
var Pawn alarmInstigator;
var Vector alarmLocation;
var() name Alliance;
var Pawn associatedPawn;
var bool bDisabled;
var bool bConfused;				// used when hit by EMP
var float confusionTimer;		// how long until unit resumes normal operation
var float confusionDuration;	// how long does EMP hit last?

var localized string MsgActiveAlarm;

//MADDERS, 6/26/25: Feedback for not reaching alarm units properly.
var localized String MsgCannotReach;

//MADDERS, 10/2/25: Related to infamy.
var bool ActivatorHatedPlayer;

function UpdateAIEvents()
{
	local VMDBufferPlayer VMP;
	
	if (bActive)
	{
		// Make noise and light
		//MADDERS, 7/24/25: End stasis in radius for alarms. Special treatment.
		class'VMDStaticFunctions'.Static.EndStasisInAOE(Self, Location, 25*(SoundRadius+1));
		AIStartEvent('Alarm', EAITYPE_Audio, SoundVolume/255.0, 25*(SoundRadius+1));
		
		VMP = VMDBufferPlayer(GetPlayerPawn());
		if ((VMP != None) && (ActivatorHatedPlayer))
		{
			VMP.VMDAttemptAddOwedInfamy(5, 'Alarm');
		}
		
		//MADDERS, 8/7/23: Add player stress.
		forEach RadiusActors(class'VMDBufferPlayer', VMP, 25*(SoundRadius+1), Location)
		{
			VMP.VMDModPlayerStress(65, true, 2, true);
		}
		
		//MADDERS, 8/7/23: Also, do the stasis thing from cameras.
		bStasis = false;
	}
	else
	{
		// Stop making noise and light
		AIEndEvent('Alarm', EAITYPE_Audio);
		
		bStasis = Default.bStasis;
	}
}

function UpdateGroup(Actor Other, Pawn Instigator, bool bActivated)
{
	local AlarmUnit unit;

	// Only do this if we have a group tag set
	if (Tag != '')
	{
		// Trigger (or untrigger) every alarm with the same tag
		foreach AllActors(Class'AlarmUnit', unit, Tag)
		{
			if (bActivated)
				unit.Trigger(Other, Instigator);
			else
				unit.UnTrigger(Other, Instigator);
		}
	}
}

function HackAction(Actor Hacker, bool bHacked)
{
	Super.HackAction(Hacker, bHacked);
	
	if (bHacked)
	{
		if (bActive)
		{
			UnTrigger(Hacker, Pawn(Hacker));
			bDisabled = True;
			LightType = LT_None;
			MultiSkins[1] = Texture'PinkMaskTex';
		}
/*		else		// don't actually ever set off the alarm
		{
			Trigger(Hacker, Pawn(Hacker));
			bDisabled = False;
			LightType = LT_None;
			MultiSkins[1] = Texture'PinkMaskTex';
		}*/
	}
}

function Tick(float deltaTime)
{
	Super.Tick(deltaTime);

	if (bDisabled)
		return;

	// if we've been EMP'ed, act confused
	if (bConfused)
	{
		confusionTimer += deltaTime;

		// randomly flash the light
		if (FRand() > 0.95)
			MultiSkins[1] = Texture'AlarmUnitTex2';
		else
			MultiSkins[1] = Texture'PinkMaskTex';

		if (confusionTimer > confusionDuration)
		{
			bConfused = False;
			confusionTimer = 0;
			//MultiSkins[1] = Texture'AlarmUnitTex2';
			Multiskins[1] = Texture'PinkMaskTex';
		}
		
		return;
	}

	if (bActive)
	{
		curTime += deltaTime;
		if (curTime >= alarmTimeout)
		{
			UnTrigger(Self, None);
			return;
		}

		// flash the light and texture
		if ((Level.TimeSeconds % 0.5) > 0.25)
		{
			LightType = LT_Steady;
			MultiSkins[1] = Texture'AlarmUnitTex2';
		}
		else
		{
			LightType = LT_None;
			MultiSkins[1] = Texture'PinkMaskTex';
		}
	}
}

function Trigger(Actor Other, Pawn Instigator)
{
	local Actor A;

	if (bConfused || bDisabled)
		return;

	Super.Trigger(Other, Instigator);

	if (!bActive)
	{
		if (Instigator != None)
		{
			ActivatorHatedPlayer = False;
			if (ScriptedPawn(Other) != None)
			{
				ActivatorHatedPlayer = (ScriptedPawn(Other).GetAllianceType('Player') == ALLIANCE_Hostile);
			}
			Instigator.ClientMessage(msgActivated);
		}
		
		bActive = True;
		AmbientSound = Sound'Klaxon2';
		SoundRadius = 64;
		SoundVolume = 128;
		curTime = 0;
		LightType = LT_Steady;
		MultiSkins[1] = Texture'AlarmUnitTex2';
		alarmInstigator = Instigator;
/* taken out for now...
		if (Instigator != None)
			alarmLocation = Instigator.Location-vect(0,0,1)*(Instigator.CollisionHeight-1);
		else
*/
			alarmLocation = Location;
		UpdateAIEvents();
		UpdateGroup(Other, Instigator, true);

		// trigger the event
		if (Event != '')
			foreach AllActors(class'Actor', A, Event)
				A.Trigger(Self, Instigator);

		// make sure we can't go into stasis while we're alarming
		bStasis = False;
	}
}

function UnTrigger(Actor Other, Pawn Instigator)
{
	local bool bSkillAugment;
	
	if (bDisabled)
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
	
	//MADDERS, 12/10/21: Low pick rate make this unsalvageable. It's free again, now.
	//bSkillAugment = ((VMDBufferPlayer(Other) != None) && (VMDBufferPlayer(Other).HasSkillAugment('ElectronicsAlarms')));
	bSkillAugment = true;
	
	Super.UnTrigger(Other, Instigator);

	if (bActive)
	{
		if (Instigator != None)
			Instigator.ClientMessage(msgDeactivated);
		bActive = False;
		AmbientSound = Default.AmbientSound;
		SoundRadius = 16;
		SoundVolume = 192;
		curTime = 0;
		LightType = LT_None;
		MultiSkins[1] = Texture'PinkMaskTex';
		UpdateAIEvents();
		if (bSkillAugment) UpdateGroup(Other, Instigator, false);
		
		// reset our stasis info
		bStasis = Default.bStasis;
	}
}

auto state Active
{
	function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
	{
        	local bool bScramblerAugment;
		local VMDBufferPlayer VMP;
		
		VMP = VMDBufferPlayer(EventInstigator);
		
        	if ((VMP != None) && (!bLastSplashWasDrone))
		{
			bScramblerAugment = VMP.HasSkillAugment('TagTeamScrambler');
		}
		
		if (DamageType == 'EMP' || DamageType == 'Shocked')
		{
        		if (bScramblerAugment)
			{
				HackStrength = FClamp(HackStrength - (float(Damage) / 200.0), 0.0, 1.0);
				if (HackStrength <= 0.0)
				{
					TimeSinceReset = 0.0;
					HackAction(VMP, True);
					return;
				}
			}
			
			confusionTimer = 0;
			if (!bConfused)
			{
				curTime = alarmTimeout;
				bConfused = True;
				PlaySound(sound'EMPZap', SLOT_None,,, 1280);
				UnTrigger(Self, None);
			}
			
			bLastSplashWasDrone = false;
			return;
		}
		
		bLastSplashWasDrone = false;
		
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

function string VMDGetItemName()
{
	local string Ret;
	
	Ret = ItemName;
	return Ret;
	
	//MADDERS, 6/25/23: While this *does* work, it works in a way that scales funky due to how tools count is rendered.
	//I don't have the patience to bust my balls debugging this bullshit for the millionth time.
	//How tools and bars are added is fucking hot garbage.
	
	if ((CurTime < AlarmTimeout) && (bActive))
	{
		Ret = Ret$Chr(13)$Chr(10)$SprintF(MsgActiveAlarm, int((AlarmTimeout - CurTime) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     MsgCannotReach="You can't reach the alarm from here"
     
     alarmTimeout=30
     msgActivated="Alarm activated"
     msgDeactivated="Alarm deactivated"
     MsgActiveAlarm="(%d sec. left)"
     confusionDuration=10.000000
     HitPoints=50
     minDamageThreshold=50
     bInvincible=False
     ItemName="Alarm Sounder Panel"
     Mesh=LodMesh'DeusExDeco.AlarmUnit'
     MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
     SoundRadius=16
     SoundVolume=192
     AmbientSound=Sound'DeusExSounds.Generic.AlarmUnitHum'
     CollisionRadius=9.720000
     CollisionHeight=9.720000
     LightBrightness=255
     LightRadius=1
     Mass=10.000000
     Buoyancy=5.000000
}
