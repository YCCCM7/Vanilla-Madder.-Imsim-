//=============================================================================
// Another hand-me-down.
//=============================================================================
class VMDTheftIndicator extends VMDFillerActors;

var VMDBufferPlayer Player;
var VMDBufferPawn Pawn;
var int NoiseLevel, AngerLevel;
var Name AngeredAlliance;

function bool GetPlayer()
{
	local VMDBufferPlayer VP;
	
	Pawn = VMDBufferPawn(Owner);
	
	forEach AllActors(Class'VMDBufferPlayer', VP)
	{
		if (VP != None)
	 	{
	  		Player = VP;
          		break;
	 	}
	}
	return ((VP != None) && (Pawn != None));
}

function InvokeCrime()
{
	if (GetPlayer())
	{
	 	//Player.AIStartEvent('LoudNoise', EAITYPE_Audio, 1.0, 128);
	 	//Pawn.AIStartEvent('Distress', EAITYPE_Audio, 1.0, 128);
         	AngeredAlliance = Pawn.Alliance;
	 	SetTimer(0.2, False);
	}
}

function InvokeRadialAnger()
{
 	local VMDBufferPawn VP;
 	
 	//Always enrage the offended party, and get them angry 2x as fast!
 	Pawn.IncreaseAgitation(Player, 1);
	Pawn.SwitchToBestWeapon();
	Pawn.SetEnemy(Player);
	if (Pawn.Weapon == None)
	{
		Pawn.GoToState('Fleeing');
	}
	else
	{
		Pawn.HandleEnemy();
	}
 	
 	forEach RadiusActors(class'VMDBufferPawn', VP, 192)
 	{
  		if ((VP != Pawn) && (VP.Alliance == AngeredAlliance) && (FastTrace(VP.Location)))
  		{
   			VP.IncreaseAgitation(Player, 1);
			VP.SwitchToBestWeapon();
			VP.SetEnemy(Player);
			if (VP.Weapon == None)
			{
				VP.GoToState('Fleeing');
			}
			else
			{
				VP.HandleEnemy();
			}
  		}
 	}
}

function Timer()
{
	local int i;
	
	//Player.AIEndEvent('LoudNoise', EAITYPE_Audio);
	//Pawn.AIEndEvent('Distress', EAITYPE_Audio);
	
	Pawn.bDistressed = True;
	Pawn.EnemyLastSeen = 0;
	Pawn.SetDistressTimer();
	
	//Create some good ol' fashioned agitation!
	if (AngerLevel > 0)
	{
	 	for (i=0; i<AngerLevel; i++)
	 	{
	  		InvokeRadialAnger();
	 	}
	}
	
	//Make some noise, too!
	if (NoiseLevel > 0)
	{
	 	for (i=0; i<NoiseLevel; i++)
	 	{
	  		Player.AISendEvent('LoudNoise', EAITYPE_Audio, 10.0, 256);
	 	}
	}
	
	Pawn.AISendEvent('Distress', EAITYPE_Audio, 1.0, 256);
	
	if (HasWeapon(Pawn))
	{
		Pawn.SetOrders('Attacking', Player.Tag, true);
	}
	
	Destroy();
}

function bool HasWeapon(ScriptedPawn TPawn)
{
	local bool bWeapon, bAmmo;
	local int i;
	local class<Inventory> TInv;
	local class<DeusExWeapon> TWep;
	local class<DeusExAmmo> TAmm;
	
	if (TPawn == None) return false;
	
	for(i=0; i<ArrayCount(TPawn.InitialInventory); i++)
	{
		if (TPawn.InitialInventory[i].Count > 0)
		{
			TInv = TPawn.InitialInventory[i].Inventory;
			TWep = class<DeusExWeapon>(TInv);
			if (TWep != None)
			{
				bWeapon = true;
				break;
			}
		}
	}
	
	return (bWeapon);
}

defaultproperties
{
     bHidden=True
     NoiseLevel=1
     AngerLevel=3
}
