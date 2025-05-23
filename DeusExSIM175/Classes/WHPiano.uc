//=============================================================================
// WHPiano.
//=============================================================================
class WHPiano extends WashingtonDecoration;

var bool bUsing;

function Timer()
{
	bUsing = False;
}

function Frob(actor Frobber, Inventory frobWith)
{
	local float rnd;
	
	Super.Frob(Frobber, frobWith);
	
	if (bUsing)
		return;
	
	SetTimer(2.0, False);
	bUsing = True;
	
	rnd = FRand();
	
	//MADDERS: Using us generates noise. LOTS of it.
	Instigator = Pawn(Frobber);
	AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 1280);
	
	if (rnd < 0.5)
		PlaySound(sound'Piano1', SLOT_Misc,,, 256);
	else
		PlaySound(sound'Piano2', SLOT_Misc,,, 256);
}

defaultproperties
{
     bFlammable=True
     FragType=Class'DeusEx.WoodFragment'
     bCanBeBase=True
     ItemName="Grand Piano"
     bPushable=False
     Mesh=LodMesh'DeusExDeco.WHPiano'
     CollisionRadius=100.000000
     CollisionHeight=32.500000
     Mass=750.000000
     Buoyancy=100.000000
}
