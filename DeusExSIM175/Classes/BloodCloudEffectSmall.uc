//=============================================================================
// BloodCloudEffectSmall.
//=============================================================================
class BloodCloudEffectSmall extends Effects;

#exec OBJ LOAD FILE=VMDEffects

var int Warnings;
var float BaseDrawScale;

simulated function Tick(float deltaTime)
{
	Super.Tick(deltaTime);
	
	//MADDERS note: We only spawn from blood drops. Keep on keepin' on.
	if ((!bDeleteMe) && (LifeSpan < Default.LifeSpan) && (!Region.Zone.bWaterZone))
	{
		Warnings++;
		SetLocation(Location-vect(0,0, 5));
		if (Warnings > 2) Destroy();
	}
	
	Velocity += VRand()*0.65;
	DrawScale = BaseDrawScale * (1.0 + (1.0 - (LifeSpan / Default.LifeSpan)));
	ScaleGlow = 1.0 * (LifeSpan / Default.LifeSpan);
}

defaultproperties
{
     Physics=PHYS_Projectile
     BaseDrawScale=0.050000
     Drawscale=0.050000
     LifeSpan=3.000000
     Style=STY_Translucent
     Texture=WetTexture'VMDEffects.Effects.BloodCloudTex1'
     DrawType=DT_Sprite
     bUnlit=True
}
