//=============================================================================
// Valve.
//=============================================================================
class Valve extends VMDBufferDeco;

#exec OBJ LOAD FILE=MoverSFX
#exec OBJ LOAD FILE=Ambient

var() bool bOpen;

function Frob(actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);
	
	//MADDERS: Turning on faucets makes noise.
	Instigator = Pawn(Frobber);
	AIStartEvent('LoudNoise', EAITYPE_Audio, 5.0, 1024);
	
	bOpen = !bOpen;
	if (bOpen)
	{
		PlaySound(sound'ValveOpen',,,, 256);
		PlayAnim('Open',, 0.001);
	}
	else
	{
		PlaySound(sound'ValveClose',,,, 256);
		PlayAnim('Close',, 0.001);
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (bOpen)
	{
		PlayAnim('Open', 10.0, 0.001);
	}
	else
	{
		PlayAnim('Close', 10.0, 0.001);
	}
}

defaultproperties
{
     bInvincible=True
     ItemName="Valve"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.Valve'
     SoundRadius=6
     SoundVolume=48
     SoundPitch=96
     AmbientSound=Sound'Ambient.Ambient.WaterRushing'
     CollisionRadius=7.200000
     CollisionHeight=1.920000
     Mass=20.000000
     Buoyancy=10.000000
}
