//=============================================================================
// VMDBathBubble.
//=============================================================================
class VMDBathBubble extends VMDFillerActors;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	DrawScale = FRand() * 0.25;
}

function Tick(float DT)
{
	Super.Tick(DT);
	
	Acceleration.X = Clamp(Acceleration.X + (FRand() - 0.5) * 40, -50, 50);
	Acceleration.Y = Clamp(Acceleration.Y + (FRand() - 0.5) * 40, -50, 50);
	Velocity.X = Acceleration.X;
	Velocity.Y = Acceleration.Y;
}

defaultproperties
{
     Physics=PHYS_Projectile
     DrawType=DT_Mesh
     Mesh=LODMesh'VMDBathBubble'
     DrawScale=1.000000
     bHidden=False
     bUnlit=True
     ScaleGlow=0.250000
     Texture=Texture'VMDBubbleGloss'
     
     Lifespan=0.250000
     bStatic=False
     bCollideWorld=False
     bCollideActors=False
     bBlockActors=False
     bBlockPlayers=False
     CollisionHeight=0.000000
     CollisionRadius=0.000000
}
