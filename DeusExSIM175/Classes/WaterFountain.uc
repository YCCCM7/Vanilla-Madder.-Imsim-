//=============================================================================
// WaterFountain.
//=============================================================================
class WaterFountain extends VMDBufferDeco;

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
	PlayAnim('Still');
	AmbientSound = None;
}

function Frob(Actor Frobber, Inventory frobWith)
{
	local int SeedTweak;
	local int WaterInt, WaterInt2;
	
	Super.Frob(Frobber, frobWith);

	if (numUses <= 0)
	{
		if (Pawn(Frobber) != None)
			Pawn(Frobber).ClientMessage(msgEmpty);
		return;
	}

	if (bUsing)
		return;
	
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
			//MADDERS: Fucking with a water fountain makes noise. Less than a cooler, tho.
			Instigator = Pawn(Frobber);
			AIStartEvent('LoudNoise', EAITYPE_Audio, 5.0, 800);
			
			//MADDERS: Note, we're lower quality water and take more quantity for the desired effect.
			SeedTweak = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 3, true);
			WaterCount++;
			WaterInt = (WaterCount + SeedTweak) % 5;
			WaterInt2 = (WaterCount + SeedTweak) % 9;
			if (WaterInt == 1 || WaterInt == 3)
			{
			 	VMDBufferPlayer(Frobber).VMDRegisterFoodEaten(1, "Water");
			}
			if (WaterInt2 == 3 || WaterInt2 == 5 || WaterInt2 == 8)
			{
				VMDBufferPlayer(Frobber).VMDRegisterFoodEaten(4, "WaterPoisonFluff");
			}
			else
			{
				VMDBufferPlayer(Frobber).VMDRegisterFoodEaten(4, "WaterPoison");
			}
			VMDBufferPlayer(Frobber).VMDAddToAddiction("Water", 20);
			//MADDERS: Wash off just a bit here.
			VMDBufferPlayer(Frobber).AddBloodLevel(-10);
		}
	}

	LoopAnim('Use');
	AmbientSound = sound'WaterBubbling';
	
	//MADDERS, 4/3/21: With the advent of water poisoning, we can be as bottomless as you would expect from a water fountain.
	//numUses--;
}

defaultproperties
{
     numUses=10
     msgEmpty="It's out of water"
     ItemName="Water Fountain"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.WaterFountain'
     CollisionRadius=20.000000
     CollisionHeight=24.360001
     Mass=70.000000
     Buoyancy=100.000000
}
