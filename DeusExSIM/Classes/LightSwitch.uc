//=============================================================================
// LightSwitch.
//=============================================================================
class LightSwitch extends VMDBufferDeco;

var bool bOn;

function Frob(Actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);
	
	//MADDERS: Spook nearby baddies.
	Instigator = Pawn(Frobber);
	AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 640);
	
	if (bOn)
	{
		PlaySound(sound'Switch4ClickOff');
		PlayAnim('Off');
	}
	else
	{
		PlaySound(sound'Switch4ClickOn');
		PlayAnim('On');
	}

	bOn = !bOn;
}

defaultproperties
{
     bEverNotFrobbed=False
     
     bInvincible=True
     ItemName="Switch"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.LightSwitch'
     CollisionRadius=3.750000
     CollisionHeight=6.250000
     Mass=30.000000
     Buoyancy=40.000000
}
