//=============================================================================
// BeamTrigger.
//=============================================================================
class BeamTrigger extends Trigger;

var LaserEmitter emitter;
var() bool bIsOn;
var actor LastHitActor;
var bool bConfused;				// used when hit by EMP
var float confusionTimer;		// how long until trigger resumes normal operation
var float confusionDuration;	// how long does EMP hit last?
var int HitPoints;
var int minDamageThreshold;
var bool bAlreadyTriggered;

var bool bLastSplashWasDrone; //MADDERS, 12/28/23: We're putting a stop to megahertz + spydrone combo. RIP.

singular function Touch(Actor Other)
{
	// does nothing when touched
}

function Tick(float deltaTime)
{
	local Actor A;
	local AdaptiveArmor armor;
	local bool bTrigger;
	
	if (emitter != None)
	{
		// if we've been EMP'ed, act confused
		if ((bConfused) && (bIsOn))
		{
			confusionTimer += deltaTime;

			// randomly turn on/off the beam
			if (FRand() > 0.95)
				emitter.TurnOn();
			else
				emitter.TurnOff();

			if (confusionTimer > confusionDuration)
			{
				bConfused = False;
				confusionTimer = 0;
				emitter.TurnOn();
			}

			return;
		}

		emitter.SetLocation(Location);
		emitter.SetRotation(Rotation);

		if ((emitter.HitActor != None) && (LastHitActor != emitter.HitActor))
		{
			if (IsRelevant(emitter.HitActor))
			{
				bTrigger = True;

				if (emitter.HitActor.IsA('DeusExPlayer'))
				{
					// check for adaptive armor - makes the player invisible
					if (DeusExPlayer(Emitter.HitActor).UsingChargedPickup(class'AdaptiveArmor'))
					{
						bTrigger = false;
					}
					
	  				//MADDERS: Lasers don't work on cloak now!
	  				if (DeusExPlayer(emitter.HitActor).AugmentationSystem != None)
	  				{
					 	if (DeusExPlayer(emitter.HitActor).AugmentationSystem.GetAugLevelValue(class'AugCloak') != -1.0)
					  		bTrigger = False;
					}
				}
				
				if ((VMDBufferPawn(Emitter.HitActor) != None) && (VMDBufferPawn(Emitter.HitActor).bInsignificant))
				{
					bTrigger = false;
				}

				if (bTrigger)
				{
					// play "beam broken" sound if we are not silent.
					if (SoundVolume != 0)
						PlaySound(sound'Beep2',,,, 1280, 3.0);

					if (!bAlreadyTriggered)
					{
						// only be triggered once?
						if (bTriggerOnceOnly)
							bAlreadyTriggered = True;

						// Trigger event
						if(Event != '')
							foreach AllActors(class 'Actor', A, Event)
								A.Trigger(Self, Pawn(emitter.HitActor));
					}
				}
			}
		}

		LastHitActor = emitter.HitActor;
	}
}

// if we are triggered, turn us on
function Trigger(Actor Other, Pawn Instigator)
{
	if (bConfused)
		return;

	if (emitter != None)
	{
		if (!bIsOn)
		{
			emitter.TurnOn();
			bIsOn = True;
			LastHitActor = None;
			MultiSkins[1] = Texture'LaserSpot1';
		}
	}

	Super.Trigger(Other, Instigator);
}

// if we are untriggered, turn us off
function UnTrigger(Actor Other, Pawn Instigator)
{
	if (bConfused)
		return;

	if (emitter != None)
	{
		if (bIsOn)
		{
			emitter.TurnOff();
			bIsOn = False;
			LastHitActor = None;
			MultiSkins[1] = Texture'BlackMaskTex';
		}
	}

	Super.UnTrigger(Other, Instigator);
}

function BeginPlay()
{
	Super.BeginPlay();

	LastHitActor = None;
	emitter = Spawn(class'LaserEmitter');

	if (emitter != None)
	{
		emitter.SetBlueBeam();
		emitter.TurnOn();
		bIsOn = True;
	}
	else
		bIsOn = False;
}

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	local MetalFragment frag;
        local bool bScramblerAugment;
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(EventInstigator);
	
       	if ((VMP != None) && (!bLastSplashWasDrone))
	{
		bScramblerAugment = VMP.HasSkillAugment('TagTeamScrambler');
	}

	if (DamageType == 'EMP')
	{
        	if (bScramblerAugment)
		{
			if (bIsOn)
			{
				bConfused = false;
				UnTrigger(Self, None);
			}
			return;
		}
		else
		{
			confusionTimer = 0;
			if (!bConfused)
			{
				bConfused = True;
				PlaySound(sound'EMPZap', SLOT_None,,, 1280);
			}
		}
	}
	else if ((DamageType == 'Exploded') || (DamageType == 'Shot'))
	{
		if (Damage >= minDamageThreshold)
			HitPoints -= Damage;

		if (HitPoints <= 0)
		{
			frag = Spawn(class'MetalFragment', Owner);
			if (frag != None)
			{
				frag.Instigator = EventInstigator;
				frag.CalcVelocity(Momentum,0);
				frag.DrawScale = 0.5*FRand();
				frag.Skin = GetMeshTexture();
			}

			Destroy();
		}
	}
	
	bLastSplashWasDrone = false;
}

function Destroyed()
{
	if (emitter != None)
	{
		emitter.Destroy();
		emitter = None;
	}

	Super.Destroyed();
}

defaultproperties
{
     bIsOn=True
     confusionDuration=10.000000
     HitPoints=50
     minDamageThreshold=50
     TriggerType=TT_AnyProximity
     bHidden=False
     bDirectional=True
     DrawType=DT_Mesh
     Mesh=LodMesh'DeusExDeco.LaserEmitter'
     CollisionRadius=2.500000
     CollisionHeight=2.500000
}
