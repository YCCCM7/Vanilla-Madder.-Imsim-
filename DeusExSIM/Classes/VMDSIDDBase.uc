//=============================================================================
// VMDSIDDBase.
//=============================================================================
class VMDSIDDBase extends VMDBufferDeco;

singular function SupportActor(Actor standingActor)
{
	local float angle, zVelocity, baseMass, standingMass;
	local vector newVelocity;
	
	if (VMDBufferPlayer(StandingActor) == None)
	{
		zVelocity = standingActor.Velocity.Z;
		// We've been stomped!
		if (zVelocity < -500)
		{
			standingMass = FMax(1, standingActor.Mass);
			baseMass = FMax(1, Mass);
			TakeDamage((1 - standingMass/baseMass * zVelocity/30), standingActor.Instigator, standingActor.Location, 0.2*standingActor.Velocity, 'stomped');
		}
		
		angle = FRand()*Pi*2;
		newVelocity.X = cos(angle);
		newVelocity.Y = sin(angle);
		newVelocity.Z = 0;
		newVelocity *= FRand()*25 + 25;
		newVelocity += standingActor.Velocity;
		newVelocity.Z = 50;
		standingActor.Velocity = newVelocity;
		if (ThrownProjectile(StandingActor) == None)
		{
			standingActor.SetPhysics(PHYS_Falling);
		}
	}
	else
	{
		standingActor.SetBase(self);
	}
}

defaultproperties
{
     bInvincible=True
     Physics=PHYS_None
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bCollideActors=False
     Mesh=LodMesh'VMDSIDDBase'
     CollisionRadius=12.000000
     CollisionHeight=8.500000
     Mass=50.000000
     Buoyancy=25.000000
}
