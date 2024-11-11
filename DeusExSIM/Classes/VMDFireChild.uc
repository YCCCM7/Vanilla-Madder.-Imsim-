//=============================================================================
// VMDFireChild. BIG FAT NOTE: This is actually TNMFireChild, but I wanted
// to avoid a naming conflict, while gaining functionality. Sticky flames concept
// courtesy of DX Revision, to my understanding.
//=============================================================================
class VMDFireChild extends Fire;

var VMDFireChildWarning HackCloud;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	HackCloud = Spawn(class'VMDFireChildWarning');
	HackCloud.SetBase(Self);
}

simulated function Destroyed()
{
	if ((HackCloud != None) && (!HackCloud.bDeleteMe))
	{
		HackCloud.Destroy();
	}
	Super.Destroyed();
}

function DoZoneCheck()
{
	local SmokeTrail P;
	
	if ((Region.Zone != None) && (Region.Zone.bWaterZone))
	{
		PlaySound( Sound'MedicalHiss',,/*volume*/,,/*radius*/, 1.45 );
		
		P = Spawn(class'SmokeTrail');
		if ( p != None )
		{
			P.Velocity.Z = 35 + FRand()*30;
			P.OrigVel = P.Velocity;
			P.DrawScale = DrawScale * 1.5;
			P.OrigScale = P.DrawScale;
			P.LifeSpan = 1.0 + FRand();
			P.OrigLifeSpan = P.LifeSpan;
		}
		Destroy();
	}
}

event ZoneChange( ZoneInfo NewZone )
{
	DoZoneCheck();
}

function Touch(Actor Other)
{
	Super.Touch(Other);
	
	if (Decoration(Other) != None || Pawn(Other) != None)
	{
		Other.TakeDamage(1, None, Other.Location, vect(0,0,0), 'Flamed');
	}
	else if (DeusExProjectile(Other) != None)
	{
		if ((Cloud(Other) != None) && (DeusExProjectile(Other).DamageType == 'HalonGas' || DeusExProjectile(Other).DamageType == 'OwnedHalonGas'))
		{
			Destroy();
		}
		else
		{
			Other.TakeDamage(1, None, Other.Location, vect(0,0,0), 'Flamed');
		}
	}
}

defaultproperties
{
    bCollideActors=True
}
