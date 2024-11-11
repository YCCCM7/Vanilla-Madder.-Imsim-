//=============================================================================
// Switch2.
//=============================================================================
class Switch2 extends VMDBufferDeco;

var bool bOn;

function Frob(Actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);

	//MADDERS: Spook nearby baddies.
	Instigator = Pawn(Frobber);
	AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 240);
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
     Skin=Texture'DeusExDeco.Skins.Switch1Tex2'
     Mesh=LodMesh'DeusExDeco.Switch1'
     DrawScale=2.000000
     CollisionRadius=5.260000
     CollisionHeight=5.940000
     Mass=10.000000
     Buoyancy=12.000000
}
