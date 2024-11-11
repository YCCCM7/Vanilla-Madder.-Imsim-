//=============================================================================
// Toilet2.
//=============================================================================
class Toilet2 extends VMDBufferDeco;

enum ESkinColor
{
	SC_Clean,
	SC_Filthy
};

var() ESkinColor SkinColor;
var bool bUsing;
var bool bHasWater;
var localized string NoWater;

function BeginPlay()
{
	Super.BeginPlay();

	switch (SkinColor)
	{
		case SC_Clean:	Skin = Texture'Toilet2Tex1'; break;
		case SC_Filthy:	Skin = Texture'Toilet2Tex2'; break;
	}
}

function Timer()
{
	bUsing = False;
}

function Frob(actor Frobber, Inventory frobWith)
{
	Super.Frob(Frobber, frobWith);
	
	if (bUsing)
	{
		return;
	}
	
	if (bHasWater) // Do we have water to flush? (Chapter 3)
	{
		SetTimer(2.0, False);
		bUsing = True;
		
		//MADDERS: Using us generates noise.
		//Note: Enemies are basically all male. Urinals are more standard.
		Instigator = Pawn(Frobber);
		if (!VMDPlausiblyDeniableNoise())
		{
			AISendEvent('LoudNoise', EAITYPE_Audio, 5.0, 256);
		}
		PlaySound(sound'FlushUrinal',,,, 256);
		PlayAnim('Flush');
	}
	else
	{
		if (DeusExPlayer(Frobber) != None)
		{
			DeusExPlayer(Frobber).ClientMessage(NoWater);
		}
	}
}

defaultproperties
{
     bInvincible=True
     ItemName="Urinal"
     bPushable=False
     Physics=PHYS_None
     Mesh=LodMesh'DeusExDeco.Toilet2'
     CollisionRadius=18.000000
     CollisionHeight=31.000000
     Mass=100.000000
     Buoyancy=5.000000
     bHasWater=True
     NoWater="It has no connected water"
}
