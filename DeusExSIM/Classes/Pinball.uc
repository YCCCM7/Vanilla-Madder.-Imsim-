//=============================================================================
// Pinball.
//=============================================================================
class Pinball extends ElectronicDevices;

var bool bUsing;

function Timer()
{
	bUsing = False;
}

function Frob(actor Frobber, Inventory frobWith)
{
	local VMDBufferPlayer VMP;
	
	Super.Frob(Frobber, frobWith);
	
	if (bUsing)
		return;
	
	SetTimer(2.0, False);
	bUsing = True;
	
	PlaySound(sound'PinballMachine',,,, 256);
	
	//MADDERS, 1/9/21: We're loud, aren't we?
	Instigator = Pawn(Frobber);
	if (!VMDPlausiblyDeniableNoise())
	{
		AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 360);
	}
	
	VMP = VMDBufferPlayer(Frobber);
	if (VMP != None)
	{
		VMP.VMDModPlayerStress(-20, true, 0, true);
	}
}

defaultproperties
{
     ItemName="Pinball Machine"
     Mesh=LodMesh'DeusExDeco.Pinball'
     CollisionRadius=37.000000
     CollisionHeight=45.000000
     Mass=100.000000
     Buoyancy=5.000000
}
