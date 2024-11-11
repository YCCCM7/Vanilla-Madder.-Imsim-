//=============================================================================
// VMDWaterLevelTrigger.
//=============================================================================
class VMDWaterLevelTrigger extends Trigger;

var() bool bStartsRaised, bTriggerToggle, bEmitBubbles, bAlterScaleGlow;
var bool bRaisingLevel, bDrainingLevel, bEmittingBubbles;

var() Vector WaterSize, WaterCenter;
var() float FaucetX, FaucetY, WaterFillMark, WaterFillTime, WaterDrainTime;
var float WaterFillTimer, BubbleVal, BubbleFreq;

var VMDWaterLevelActor WaterLevelActor;
var() WaterZone TarWaterZone;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (WaterLevelActor == None)
	{
		WaterLevelActor = Spawn(Class'VMDWaterLevelActor',,, WaterCenter); //+vect(0,0,5)
		if (WaterLevelActor != None)
		{
			WaterLevelActor.DrawScale = (FMax(WaterSize.X, WaterSize.Y) / WaterLevelActor.CollisionRadius);
		}
	}
	if (TarWaterZone != None)
	{
		TarWaterZone.OwningTrigger = Self;
	}
	
	if (bStartsRaised)
	{
		WaterFillTimer = WaterFillTime;
	}
	else
	{
		WaterFillTimer = 0;
	}
	
	if (bEmitBubbles)
	{
		bEmittingBubbles = bRaisingLevel;
	}
	UpdateWaterLevelActor();
	UpdateWaterZone(bRaisingLevel);
}

function Trigger(Actor Other, Pawn Instigator)
{
	if (bTriggerToggle)
	{
		bRaisingLevel = !bRaisingLevel;
		bDrainingLevel = !bRaisingLevel;
	}
	else
	{
		bRaisingLevel = !bRaisingLevel;
		if (bRaisingLevel)
		{
			bDrainingLevel = false;
		}
	}
	
	if (bEmitBubbles)
	{
		bEmittingBubbles = bRaisingLevel;
	}
}

function Untrigger(Actor Other, Pawn Instigator)
{
	if (!bTriggerToggle)
	{
		if (!bRaisingLevel)
		{
			bDrainingLevel = true;
		}
	}
}

function UpdateWaterLevelActor()
{
	local float TProg;
	local Vector TVect;
	
	TProg = WaterFillTimer / WaterFillTime;
	
	TVect.X = WaterCenter.X;
	TVect.Y = WaterCenter.Y;
	TVect.Z = WaterCenter.Z + (WaterSize.Z * (WaterFillTimer / WaterFillTime));
	
	if (WaterLevelActor != None)
	{
		WaterLevelActor.SetLocation(TVect);
		//0.15
		WaterLevelActor.ScaleGlow = 1.0 * (WaterFillTimer / WaterFillTime) * FMax(0.075, (AIGetLightLevel(WaterLevelActor.Location)*10));
		WaterLevelActor.bHidden = !(WaterFillTimer > 0);
	}
}

function UpdateWaterZone(bool NewbWaterZone)
{
	if (TarWaterZone != None)
	{
		if (NewbWaterZone)
		{
			TarWaterZone.EntrySound = Sound'SplashMedium';
			TarWaterZone.ExitSound = Sound'WaterOut';
			TarWaterZone.EntryActor = class'WaterRing';
			TarWaterZone.ExitActor = class'WaterRing';
			TarWaterZone.bWaterZone = true;
			TarWaterZone.ViewFog = vect(0,0.05,0.1);
			TarWaterZone.SoundRadius = 0;
			TarWaterZone.AmbientSound = Sound'Underwater';
		}
		else
		{
			TarWaterZone.EntrySound = None;
			TarWaterZone.ExitSound = None;
			TarWaterZone.EntryActor = None;
			TarWaterZone.ExitActor = None;
			TarWaterZone.bWaterZone = false;
			TarWaterZone.ViewFog = vect(0,0,0);
			TarWaterZone.SoundRadius = 32;
			TarWaterZone.AmbientSound = None;
		}
	}
}

function Tick(float DT)
{
	local bool bMetThresh;
	local Vector TVect;
	local VMDBathBubble TBubble;
	
	Super.Tick(DT);
	
	if (WaterLevelActor != None)
	{
		bMetThresh = (WaterFillTimer >= WaterFillMark);
		if (bRaisingLevel)
		{
			if (WaterFillTimer < WaterFillTime)
			{
				WaterFillTimer += DT;
				if ((WaterFillTimer >= WaterFillMark) && (!bMetThresh))
				{
					UpdateWaterZone(true);
				}
			}
		}
		else if (bDrainingLevel)
		{
			if (WaterFillTimer > 0)
			{
				WaterFillTimer -= DT * (WaterFillTime / WaterDrainTime);
				if ((WaterFillTimer < WaterFillMark) && (bMetThresh))
				{
					UpdateWaterZone(false);
				}
			}
		}
		
		if (bEmittingBubbles)
		{
			TVect.X = FaucetX + ((FRand() - 0.5) * 8);
			TVect.Y = FaucetY + ((FRand() - 0.5) * 8);
			TVect.Z = WaterLevelActor.Location.Z;
			
			BubbleVal += DT;
			if (BubbleVal >= BubbleFreq)
			{
				BubbleVal = 0;
				TBubble = Spawn(class'VMDBathBubble',,, TVect);
				if (TBubble != None)
				{
					TBubble.SetBase(WaterLevelActor);
					TBubble.Lifespan = BubbleFreq*5;
					if (bAlterScaleGlow)
					{
						TBubble.ScaleGlow = WaterLevelActor.ScaleGlow * 2;
					}
				}
			}
		}
		
		UpdateWaterLevelActor();
	}
}

defaultproperties
{
     bAlterScaleGlow=True
     bStartsRaised=False
     bTriggerToggle=False
     bEmitBubbles=True
     
     WaterFillTime=15.000000
     WaterDrainTime=5.000000
     WaterFillMark=10.000000
     BubbleFreq=0.040000
     
     bAlwaysRelevant=True
     bTriggerOnceOnly=False
     bCollideActors=False
     CollisionRadius=96.000000
}
