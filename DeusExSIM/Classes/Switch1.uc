//=============================================================================
// Switch1.
//=============================================================================
class Switch1 extends VMDBufferDeco;

var bool bOn;

function Frob(Actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);

	//MADDERS: Spook nearby baddies.
	Instigator = Pawn(Frobber);
	if (!VMDPlausiblyDeniableNoise())
	{
		AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 240);
	}
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
     bInvincible=True
     ItemName="Switch"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.Switch1'
     CollisionRadius=2.630000
     CollisionHeight=2.970000
     Mass=10.000000
     Buoyancy=12.000000
}
