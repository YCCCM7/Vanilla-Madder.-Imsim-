//=============================================================================
// FireComet.
//=============================================================================
class FireComet extends DeusExFragment;

auto simulated state Flying
{
	simulated function HitWall(vector HitNormal, actor Wall)
	{
		local BurnMark mark;

		mark = spawn(class'BurnMark',,, Location, Rotator(HitNormal));
		if (mark != None)
		{
			mark.DrawScale = 0.4*DrawScale;
			mark.ReattachDecal();
		}
		Destroy();
	}
	simulated function BeginState()
	{
		Velocity = VRand() * 300;
		Velocity.Z = FRand() * 200 + 200;
		DrawScale = 0.3 + FRand();
		SetRotation(Rotator(Velocity));
	}
}

simulated function Tick(float deltaTime)
{
	local DeusExDecal Dec;
	
	if (Velocity == vect(0,0,0))
	{
		//MADDERS: Nerf spark splash size. It's a bit much.
		//UPDATE: Yikes! Try setting in default, because this just makes a 2x2 grid.
		Dec = spawn(class'BurnMarkSmall',,, Location, rot(16384,0,0));
		Destroy();
	}
	else
		SetRotation(Rotator(Velocity));
}

defaultproperties
{
     Style=STY_Translucent
     Mesh=LodMesh'DeusExItems.FireComet'
     ScaleGlow=2.000000
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBounce=False
}
