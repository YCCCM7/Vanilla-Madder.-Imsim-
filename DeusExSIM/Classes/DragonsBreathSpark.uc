//=============================================================================
// DragonsBreathSpark.
//=============================================================================
class DragonsBreathSpark extends DeusExProjectile;

#exec OBJ LOAD FILE=VMDEffects

function Tick(float DT)
{
	Super.Tick(DT);
	
	ScaleGlow -= DT*4;
	if ((ScaleGlow <= 0) && (!bDeleteMe))
	{
		Destroy();
	}
}

function PostBeginPlay()
{
	local int R;
	local float FR;
	local Texture TTex;
	
	Super.PostBeginPlay();
	
	R = Rand(8);
	
	switch(R)
	{
		case 0:
		case 1:
		case 2:
		case 3:
			TTex = Texture'VMDDBFire01';
		break;
		case 4:
		case 5:
		case 6:
			TTex = Texture'VMDDBFire02';
		break;
		case 7:
			TTex = Texture'VMDDBFire03';
		break;
	}
	Skin = TTex;
	Texture = TTex;
	
	VMDApplySpeedMult(0.5 + (FRand() * 1.25));
}

defaultproperties
{
     bBlood=False
     bDebris=False
     AccurateRange=512
     maxRange=512
     bIgnoresNanoDefense=True
     speed=4000.000000
     MaxSpeed=4000.000000
     Mesh=LodMesh'DeusExItems.Tracer'
     ScaleGlow=2.000000
     bUnlit=True
     
     ExplosionDecal=Class'DeusEx.ScorchMark'
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=FireTexture'FirePelletTex'
     Skin=FireTexture'FirePelletTex'
     DrawScale=0.1250000
}
