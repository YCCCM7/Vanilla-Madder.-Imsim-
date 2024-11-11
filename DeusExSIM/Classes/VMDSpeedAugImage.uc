//=============================================================================
// VMDSpeedAugImage
//=============================================================================
class VMDSpeedAugImage extends Effects;

var float ScaleGlowMult;

function Tick(float DT)
{
	Super.Tick(DT);
	
	ScaleGlow = FMin(Lifespan, 1.0) * 0.4 * ScaleGlowMult;
}

defaultproperties
{
    ScaleGlowMult=1.000000
    DrawType=DT_Mesh
    Style=STY_Translucent
    Lifespan=0.650000
}
