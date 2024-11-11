//=============================================================================
// VMDFakeBuffAura.
//=============================================================================
class VMDFakeBuffAura extends ChargedPickup;

var int TChargeSteps;
var VMDBufferPlayer MyVMP;
var bool bLoudLoopSound;

//--------------------
//MADDERS, 1/30/21: Hey. Time to have a weird talk:
//This is a theoretical concept I made possible a while back with the expansion of pickup damage reduction.
//Technically, this could also be done with Lifespan on a non-charged pickup, in fact, but that's REALLY ugly and bad.
//For now, we're an empty class with no mesh, icons, inventory size, names, etc...
//But what we DO do is leave " " as item name and article so INI doesn't default to our class name.
//Then we use PickupMessage as "begin" and ExpireMessage as "expire" messages.
//These are not mandatory, and if left as empty will just never be given to the player at all.
//Past that, program a charge value (duration, at 40 charge per second), and plug damage effects into the function as such.
//This function is actually REALLY fatty to begin with, but that's just how I roll: Posterity above succinctness.
//This shit is wild, and I hope the concept, if nothing else, is a bit of a shitgiggler for folks at home. Peace.

function float VMDConfigurePickupDamageMult(name DT)
{
	local float Ret;
	
	//Emergency mega failsafe. Likely paranoid, but why not double bag it?
	if (Charge <= 0)
	{
		Destroy();
		return 1.0;
	}
	
	Ret = 1.0;
	switch(DT)
	{
		default:
			Ret = 1.0;
		break;
	}
	
	return Ret;
}

state Activated
{
	function Timer()
	{
		VMDFakeAuraTimerHook(TChargeSteps == 0);
		TChargeSteps = ((TChargeSteps+1) % 10);
		
		Super.Timer();
	}
	function BeginState()
	{
		Super(DeusExPickup).BeginState();
		
		MyVMP = VMDBufferPlayer(Owner);
		if (MyVMP != None)
		{
			// remove it from our inventory, but save our owner info
			if (bOneUseOnly)
			{
				//MyVMP.DeleteInventory(Self);
				
				// Remove from player's hand
				//MyVMP.PutInHand(None);
				
				SetOwner(MyVMP);
			}
			
			ChargedPickupBegin(MyVMP);
			SetTimer(0.1, True);
		}
	}
}


//MADDERS, 1/31/21: Lower volume for ambient sounds slightly, as these ARE supposed to be subtle.
function ChargedPickupBegin(DeusExPlayer Player)
{
	MyVMP = VMDBufferPlayer(Player);
	Player.AddChargedDisplay(Self);
	
	PlaySound(ActivateSound, SLOT_None);
	if (LoopSound != None)
	{
		AmbientSound = LoopSound;
		if (bLoudLoopSound) SoundVolume = 128;
		else if (bLatentChargeCost) SoundVolume = 64;
		else SoundVolume = 32;
	}
	
	bIsActive = True;
}

//Latent control over this as well.
function VMDFakeAuraTimerHook(bool bWhole);

//MADDERS, 2/6/21: These buffs do not clear reliably.
function Tick(float DT)
{
	Super.Tick(DT);
	
	if (Charge > 0)
	{
		if (!IsInState('Activated'))
		{
			GoToState('Activated');
		}
		if (!bIsActive) bIsActive = true;
	}
}

//MADDERS, 2/6/21: Hack patrol. Please stop doing this, thanks.
State Idle2
{
	function BeginState()
	{
		GoToState('Activated');
		bIsActive = true;
	}
}

function TravelPostAccept()
{
	Super.TravelPostAccept();
	
	MyVMP = VMDBufferPlayer(GetPlayerPawn());
}

defaultproperties
{
     bLatentChargeCost=True
     ItemName=" "
     ItemArticle=" "
     M_Activated=""
     M_Deactivated=""
     InvSlotsX=0
     InvSlotsY=0
     MaxCopies=1
     bCanHaveMultipleCopies=True
     bOneUseOnly=True
     
     //MADDERS, 1/30/21: 40 charge per second, AKA 60 seconds.
     Charge=2400
     PickupMessage=""
     ExpireMessage=""
     skillNeeded=None
     
     //MADDERS, 1/30/21: Use this in for audio feedback sake.
     LoopSound=None
     ChargedIcon=Texture'BeltIconVialAmbrosia'
     ActivateSound=None
     DeActivateSound=None
     bDisplayableInv=False
     
     PlayerViewMesh=None
     PickupViewMesh=None
     ThirdPersonMesh=None
     LandSound=None
     Icon=None
     largeIcon=None
     largeIconWidth=0
     largeIconHeight=0
     Description="WHOOPS! You shouldn't be reading this, FRIENDO! Report this as a bug!"
     beltDescription=""
     Mesh=None
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Mass=0.000000
     Buoyancy=0.000000
}
