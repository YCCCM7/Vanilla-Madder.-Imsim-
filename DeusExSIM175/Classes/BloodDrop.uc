//=============================================================================
// BloodDrop.
//=============================================================================
class BloodDrop extends DeusExFragment;

auto state Flying
{
	function HitWall(vector HitNormal, actor Wall)
	{
		if (!Region.Zone.bWaterZone)
		{
			spawn(class'BloodSplat',,, Location, Rotator(HitNormal));
			Destroy();
		}
	}
	function BeginState()
	{
		Velocity = VRand() * 100;
		DrawScale = 1.0 + FRand();
		SetRotation(Rotator(Velocity));
		
		// Gore check
		if (Level.Game.bLowGore || Level.Game.bVeryLowGore)
		{
			Destroy();
			return;
		}
	}
	
	function ZoneChange(ZoneInfo NewZone)
	{
		local BloodCloudEffectSmall B;
		
		if (NewZone.bWaterZone)
		{			
			SpawnBloodCloud();
			Destroy();
		}
		
		Super.ZoneChange(NewZone);
	}
}

function SpawnBloodCloud()
{
	local BloodCloudEffectSmall B;
	
	//MADDERS: Blood cloud when hitting water. Spicy.
	B = Spawn(Class'BloodCloudEffectSmall',,,Location+(Velocity / 60));
	B.BaseDrawScale = B.Default.DrawScale * (0.85 + (FRand() * 0.3));
	B.Velocity = Velocity / 30;
	B.Acceleration = Acceleration / 30;
}

function ZoneChange(ZoneInfo NewZone)
{
	if (NewZone.bWaterZone)
	{			
		SpawnBloodCloud();
		Destroy();
	}
	
	Super.ZoneChange(NewZone);
}

//MADDERS: Add blood smell for 1/3rd of blood level dropped, when at close range.
function Touch(Actor Other)
{
	//Also: This is a latent function, so be careful about tripping twice.
	if ((VMDBufferPlayer(Other) != None) && (Other == Owner) && (!bDeleteMe))
	{
		VMDBufferPlayer(Other).AddBloodLevel(40); //40 seconds to wear off
		Destroy();
	}
}

function Tick(float deltaTime)
{
	if ((Velocity == vect(0,0,0)) && (!Region.Zone.bWaterZone))
	{
		spawn(class'BloodSplat',,, Location, rot(16384,0,0));
		Destroy();
	}
	else
		SetRotation(Rotator(Velocity));
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_Standalone )
	{
		ScaleGlow = 2.0;
		DrawScale *= 1.5;
		LifeSpan *= 2.0;
		bUnlit=True;
	}
}

defaultproperties
{
     Style=STY_Modulated
     Mesh=LodMesh'DeusExItems.BloodDrop'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBounce=False
     NetPriority=1.000000
     NetUpdateFrequency=5.000000
     bCollideActors=True
}
