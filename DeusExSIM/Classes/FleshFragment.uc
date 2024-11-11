//=============================================================================
// FleshFragment.
//=============================================================================
class FleshFragment extends DeusExFragment;

var float SmellSeconds, SmellCooldown, SmellLeft;

function TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, name DamageType)
{
	if (DamageType == 'Munch')
	{
		Destroy();
	}
	else
	{
		Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
	}
}

auto state Flying
{
	function BeginState()
	{
		Super.BeginState();
		
		Velocity = VRand() * 300;
		DrawScale = FRand() + 1.5;
		
		// Gore check
		if (Level.Game.bLowGore || Level.Game.bVeryLowGore)
		{
			Destroy();
			return;
		}
	}
}

function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	
	//MADDERS, 1/18/21: Lower blood smelliness over time.
	if (SmellLeft > 12) SmellLeft -= DeltaTime;
	
	if ((!IsInState('Dying')) && (VSize(Velocity) > 20))
	{
		if (FRand() < 0.5)
		{
			Spawn(class'BloodDrop',,, Location);
		}
	}
}

//MADDERS: Walking in gibs smell like ass. Fact.
//NOTE: We do 60 because we're small and scattered. Contact not guaranteed.
function Touch(Actor Other)
{
	if ((VMDBufferPlayer(Other) != None) && (Level.TimeSeconds > (SmellSeconds+SmellCooldown)))
	{
		SmellSeconds = Level.TimeSeconds;
		VMDBufferPlayer(Other).AddBloodLevel(SmellLeft); //12 to 60 seconds to wear off
	}
}

defaultproperties
{
     //MADDERS additions.
     SmellCooldown=7.500000
     SmellSeconds=-500.000000
     SmellLeft=60.000000
     
     bCollideActors=True
     Fragments(0)=LodMesh'DeusExItems.FleshFragment1'
     Fragments(1)=LodMesh'DeusExItems.FleshFragment2'
     Fragments(2)=LodMesh'DeusExItems.FleshFragment3'
     Fragments(3)=LodMesh'DeusExItems.FleshFragment4'
     numFragmentTypes=4
     elasticity=0.400000
     ImpactSound=Sound'DeusExSounds.Generic.FleshHit1'
     MiscSound=Sound'DeusExSounds.Generic.FleshHit2'
     Mesh=LodMesh'DeusExItems.FleshFragment1'
     CollisionRadius=2.000000
     CollisionHeight=2.000000
     Mass=5.000000
     Buoyancy=5.500000
     bVisionImportant=True
}
