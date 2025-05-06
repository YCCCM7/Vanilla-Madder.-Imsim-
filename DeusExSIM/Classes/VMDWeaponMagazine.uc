//=============================================================================
// VMDWeaponMagazine.
//=============================================================================
class VMDWeaponMagazine extends DeusExFragment;

var bool bAmmoLookAlike;

function InitDropBy(Pawn Dropper)
{
	bHidden = true;
	
	if (bAmmoLookalike)
	{
		Lifespan = 30.0;
	}
	
	if ((Mesh != None) && (PlayerPawn(Dropper) == None || PlayerPawn(Dropper).bBehindView))
	{
		bHidden = false;
	}
}

simulated function HitWall (vector HitNormal, actor HitWall)
{
	if ((bHidden) && (HitNormal.Z != 0))
	{
		bHidden = false;
	}
	
	if ((RotationRate.Pitch > -10000) && (RotationRate.Pitch < 10000))
	{
		RotationRate.Pitch=10000;
	}
	if ((RotationRate.Roll > -10000) && (RotationRate.Roll < 10000))
	{
		RotationRate.Roll = 10000;	
	}
	
	Super.HitWall(HitNormal, HitWall);
}

defaultproperties
{
     bHidden=True
     Lifespan=0.000000
     Elasticity=0.400000
     ImpactSound=None
     MiscSound=None
     Mesh=None
     Fragments(0)=None
     NumFragmentTypes=1
     CollisionRadius=5.000000
     CollisionHeight=5.000000
}
