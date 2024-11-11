//=============================================================================
// Faucet.
//=============================================================================
class Faucet extends VMDBufferDeco;

#exec OBJ LOAD FILE=Ambient
#exec OBJ LOAD FILE=MoverSFX
#exec OBJ LOAD FILE=Effects

var() bool				bOpen;
var ParticleGenerator	waterGen;

//MADDERS: AI related.
var float OffCheckTimer, OnTime;
var bool bProjectingSound, bSemiSound;
var bool bHasWater;
var localized string NoWater;

//MADDERS, 3/7/21: Fun fact. These are not actually seen in DXT, but are compartmentalizations of key processes.
//Let it be known I *hate* literal actor casting for special effects. Very mod un-friendly.
function bool DXTHasOtherPositionObject()
{
	if (bOpen != LastSeenState)
	{
		return true;
	}
	return false;
}

function DXTUpdateSeenExtras()
{
	LastSeenState = bOpen;
	if (bSemiSound)
	{
		AIEndEvent('LoudNoise', EAITYPE_Audio);
		bSemiSound = false;
		//bProjectingSound = false;
	}
}

function Destroyed()
{
	if (waterGen != None)
		waterGen.DelayedDestroy();
	
	Super.Destroyed();
}


function Tick(float DT)
{
	local ScriptedPawn SP;
	
	Super.Tick(DT);
	
	//If we're on, pawns will attempt to turn us off.
	if (bOpen)
	{
		if (OnTime < 30)
		{
			OnTime += DT;
		}
		else if (bSemiSound)
		{
			OnTime = 300;
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
				//bProjectingSound = false;
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

function Frob(actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);
	
	if (bHasWater) // Do we have water? (Chapter 3)
	{
		bOpen = !bOpen;
		if (bOpen)
		{
			PlaySound(sound'ValveOpen',,,, 256, 2.0);
			PlayAnim('On');
			
			//MADDERS: Turning on faucets makes noise.
			Instigator = Pawn(Frobber);
			AIStartEvent('LoudNoise', EAITYPE_Audio, 5.0, 1024);
			bSemiSound = true;
			bProjectingSound = true;
			OnTime = 0.0;
			
			if (waterGen != None)
				waterGen.Trigger(Frobber, Pawn(Frobber));
			
			// extinguish the player if he frobbed this
			if ((DeusExPlayer(Frobber) != None) && (DeusExPlayer(Frobber).bOnFire))
				DeusExPlayer(Frobber).ExtinguishFire();
		}
		else
		{
			//MADDERS: End noise when turned off.
			AIEndEvent('LoudNoise', EAITYPE_Audio);
			bSemiSound = false;
			bProjectingSound = false;
			
			PlaySound(sound'ValveClose',,,, 256, 2.0);
			PlayAnim('Off');
	
			if (waterGen != None)
				waterGen.UnTrigger(Frobber, Pawn(Frobber));
		}
	}
	else
	{
		if (DeusExPlayer(Frobber) != None)
			DeusExPlayer(Frobber).ClientMessage(NoWater);
	}
}

function PostBeginPlay()
{
	local Vector loc;
	
	Super.PostBeginPlay();
	
	// spawn a particle generator
	// rotate the spray offsets into object coordinate space
	loc = vect(0,0,0);
	loc.X += CollisionRadius * 0.9;
	loc = loc >> Rotation;
	loc += Location;
	
	waterGen = Spawn(class'ParticleGenerator', Self,, loc, Rotation-rot(12288,0,0));
	if (waterGen != None)
	{
		waterGen.particleDrawScale = 0.05;
		waterGen.checkTime = 0.05;
		waterGen.frequency = 1.0;
		waterGen.bGravity = True;
		waterGen.bScale = False;
		waterGen.bFade = True;
		waterGen.ejectSpeed = 50.0;
		waterGen.particleLifeSpan = 0.5;
		waterGen.numPerSpawn = 5;
		waterGen.bRandomEject = True;
		waterGen.particleTexture = Texture'Effects.Generated.WtrDrpSmall';
		waterGen.bAmbientSound = True;
		waterGen.AmbientSound = Sound'Sink';
		waterGen.SoundRadius = 16;
		waterGen.bTriggered = True;
		waterGen.bInitiallyOn = ((bOpen) && (bHasWater));
		waterGen.SetBase(Self);
		
		//MADDERS, 1/18/21: Faucet starting with particles on? Unclear.
		waterGen.UnTrigger(None, None);
	}
	
	// play the correct startup animation
	if ((bOpen) && (bHasWater))
		PlayAnim('On', 10.0, 0.001);
	else
		PlayAnim('Off', 10.0, 0.001);
}

defaultproperties
{
     bInvincible=True
     ItemName="Faucet"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.Faucet'
     CollisionRadius=11.200000
     CollisionHeight=4.800000
     Mass=20.000000
     Buoyancy=10.000000
     bHasWater=True
     NoWater="It has no connected water"
}
