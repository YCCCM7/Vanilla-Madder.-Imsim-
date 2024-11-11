//=============================================================================
// Lamp.
//=============================================================================
class Lamp extends Furniture
	abstract;

var() bool bOn;

//MADDERS: AI related.
var float OffCheckTimer, OnTime;
var bool bStartedOn;
var bool bProjectingSound, bSemiSound;

//MADDERS, 3/7/21: Fun fact. These are not actually seen in DXT, but are compartmentalizations of key processes.
//Let it be known I *hate* literal actor casting for special effects. Very mod un-friendly.
function bool DXTHasOtherPositionObject()
{
	if (bOn != LastSeenState)
	{
		return true;
	}
	return false;
}

function DXTUpdateSeenExtras()
{
	LastSeenState = bOn;
	if (bSemiSound)
	{
		AIEndEvent('LoudNoise', EAITYPE_Audio);
		bSemiSound = false;
		//bProjectingSound = false;
	}
}

function Tick(float DT)
{
	local ScriptedPawn SP;
	
	Super.Tick(DT);
	
	//If we're on, pawns will attempt to turn us off.
	if (bOn != bStartedOn)
	{
		if (OnTime < 30)
		{
			OnTime += DT;
		}
		else if (bSemiSound)
		{
			AIEndEvent('LoudNoise', EAITYPE_Audio);
			bSemiSound = false;
			//bProjectingSound = false;
		}
		
		if (OffCheckTimer <= 0)
		{
			if ((VMDGetObservingFrobber(320) != None) && (bProjectingSound))
			{
				AIEndEvent('LoudNoise', EAITYPE_Audio);
				bSemiSound = false;
				bProjectingSound = false;
			}
			SP = VMDGetSeekingFrobber();
			
			if (SP != None) Frob(SP, None);
			OffCheckTimer = 1.0;
		}
		else
		{
			OffCheckTimer -= DT;
		}
	}
}

function Frob(Actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);

	if (!bOn)
	{		
		bOn = True;
		LightType = LT_Steady;
		PlaySound(sound'Switch4ClickOn');
		bUnlit = True;
		ScaleGlow = 2.0;
	}
	else
	{
		bOn = False;
		LightType = LT_None;
		PlaySound(sound'Switch4ClickOff');
		bUnlit = False;
		ResetScaleGlow();
	}
	
	//Was this lamp toggled? If so, start aggro.
	if (bOn != bStartedOn)
	{
		//MADDERS: Turning on lamps makes noise.
		Instigator = Pawn(Frobber);
		AIStartEvent('LoudNoise', EAITYPE_Audio, 5.0, 512);
		bSemiSound = true;
		bProjectingSound = true;
		OnTime = 0.0;
	}
	else
	{
		//MADDERS: End noise when turned off.
		AIEndEvent('LoudNoise', EAITYPE_Audio);
		bSemiSound = false;
		bProjectingSound = false;
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (bOn)
	{
		bStartedOn = true;
		LightType = LT_Steady;
		bUnlit = True;
		ScaleGlow = 2.0;
	}
}

function ResetScaleGlow()
{
   local float mod;

   if (!bInvincible)
      mod = float(HitPoints) / float(Default.HitPoints) * 0.9 + 0.1;
   else
      mod = 1;

	if (bOn)
	{
		ScaleGlow = 2.0 * mod;
		bUnlit = true;
	}
	else
	{
		ScaleGlow = mod;
		bUnlit = false;
	}
}

defaultproperties
{
     FragType=Class'DeusEx.GlassFragment'
     bPushable=False
     LightBrightness=255
     LightSaturation=255
     LightRadius=10
     bOwned=True // Transcended - Added
}
