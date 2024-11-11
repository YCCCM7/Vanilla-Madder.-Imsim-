//=============================================================================
// WaterCooler.
//=============================================================================
class WaterCooler extends VMDBufferDeco;

var bool bUsing;
var int numUses;
var localized String msgEmpty;

//MADDERS additions. Defeat RNG.
var int WaterCount;

function Timer()
{
	//MADDERS: End noise generation.
	AIEndEvent('LoudNoise', EAITYPE_Audio);
	
	bUsing = False;
	AmbientSound = None;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	local int SeedTweak;
	local int WaterInt, WaterInt2;
	
	Super.Frob(Frobber, frobWith);
	
	if (bUsing)
		return;
	
	if (numUses <= 0)
	{
		if (Pawn(Frobber) != None)
			Pawn(Frobber).ClientMessage(msgEmpty);
		return;
	}
	
	//MADDERS: Don't let us use these at light speed.
	if ((Frobber != None) && (VSize(Frobber.Velocity) > 40))
		return;
	
	SetTimer(2.0, False);
	bUsing = True;
	
	// heal the frobber a small bit
	if (DeusExPlayer(Frobber) != None)
	{
		DeusExPlayer(Frobber).HealPlayer(1);
		if (VMDBufferPlayer(Frobber) != None)
		{
			//MADDERS: Fucking with a water cooler makes noise. Louder than fountain marginally.
			Instigator = Pawn(Frobber);
			if (!VMDPlausiblyDeniableNoise())
			{
				AIStartEvent('LoudNoise', EAITYPE_Audio, 5.0, 960);
			}
			
			//MADDERS: Note, we're higher quality water, in addition to being more concise in quantity.
			SeedTweak = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 2, true);
			WaterCount++;
			WaterInt = (WaterCount + SeedTweak) % 2;
			WaterInt2 = (WaterCount + SeedTweak) % 7;
			
			if (WaterInt == 0)
			{
			 	VMDBufferPlayer(Frobber).VMDRegisterFoodEaten(1, "Water");
			}
			if (WaterInt2 == 2 || WaterInt2 == 4)
			{
				VMDBufferPlayer(Frobber).VMDRegisterFoodEaten(3, "WaterPoisonFluff");
			}
			else
			{
				VMDBufferPlayer(Frobber).VMDRegisterFoodEaten(3, "WaterPoison");
			}
			VMDBufferPlayer(Frobber).VMDAddToAddiction("Water", 30);
		}
	}
	
	PlayAnim('Bubble');
	AmbientSound = sound'WaterBubbling';
	numUses--;
}

function Destroyed()
{
	local Vector HitLocation, HitNormal, EndTrace;
	local Actor hit;
	local WaterPool pool;
	
	// trace down about 20 feet if we're not in water
	if (!Region.Zone.bWaterZone)
	{
		EndTrace = Location - vect(0,0,320);
		hit = Trace(HitLocation, HitNormal, EndTrace, Location, False);
		pool = spawn(class'WaterPool',,, HitLocation+HitNormal, Rotator(HitNormal));
		if (pool != None)
			pool.maxDrawScale = CollisionRadius / 20.0;
	}

	Super.Destroyed();
}

defaultproperties
{
     numUses=10
     msgEmpty="It's out of water"
     FragType=Class'DeusEx.PlasticFragment'
     bCanBeBase=True
     ItemName="Water Cooler"
     bPushable=False
     Mesh=LodMesh'DeusExDeco.WaterCooler'
     CollisionRadius=14.070000
     CollisionHeight=41.570000
     Mass=70.000000
     Buoyancy=100.000000
}
