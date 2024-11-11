//=============================================================================
// Basketball.
//=============================================================================
class Basketball extends VMDBufferDeco;

event HitWall(vector HitNormal, actor HitWall)
{
	local float speed;

	Velocity = 0.8*((Velocity dot HitNormal) * HitNormal * (-2.0) + Velocity);   // Reflect off Wall w/damping
	speed = VSize(Velocity);
	bFixedRotationDir = True;
	RotationRate = RotRand(False);
	if ((speed > 0) && (speed < 30) && (HitNormal.Z > 0.7))
	{
		SetPhysics(PHYS_None, HitWall);
		if (Physics == PHYS_None)
			bFixedRotationDir = False;
	}
	else if (speed > 30)
	{
		if (!VMDPlausiblyDeniableNoise())
		{
			PlaySound(sound'BasketballBounce', SLOT_None);
			AISendEvent('LoudNoise', EAITYPE_Audio);
		}
	}
}

defaultproperties
{
     bInvincible=True
     ItemName="Basketball"
     Mesh=LodMesh'DeusExDeco.Basketball'
     CollisionRadius=5.500000
     CollisionHeight=5.500000
     bBounce=True
     Mass=8.000000
     Buoyancy=10.000000
}
