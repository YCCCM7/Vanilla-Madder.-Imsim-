//=============================================================================
// BloodCloudEffectLarge.
//=============================================================================
class BloodCloudEffectLarge extends Effects;

#exec OBJ LOAD FILE=VMDEffects

var int Warnings;
var float BaseDrawScale, BloodReleaseTimer;

simulated function Tick(float deltaTime)
{
	local int i;
	local BloodCloudEffectSmall B;
	
	Super.Tick(deltaTime);
	
	if ((!bDeleteMe) && (LifeSpan < Default.LifeSpan) && (!Region.Zone.bWaterZone))
	{
		Warnings++;
		if (DeusExCarcass(Owner) != None) DeusExCarcass(Owner).BloodCloudOffset = DeusExCarcass(Owner).BloodCloudOffset - vect(0,0,10);
		SetLocation(Location-vect(0,0, 10));
		if (Warnings > 2) Destroy();
	}
	else if (Warnings > 0) Warnings = 0;
	
	if (!bDeleteMe)
	{
		if (BloodReleaseTimer <= 0)
		{
			for(i=0; i<2; i++)
			{
				B = Spawn(class'BloodCloudEffectSmall',,,Location + VRand()*8);
				B.Velocity = Velocity;
				B.Acceleration = Acceleration;
				
				//MADDERS: Sync our alpha level accordingly.
				B.Lifespan = (B.Default.Lifespan * ((Lifespan / Default.LifeSpan) / 2));
			}
			BloodReleaseTimer = 1.25;
		}
		else
		{
			BloodReleaseTimer -= DeltaTime;
		}
	}
	
	DrawScale = BaseDrawScale * (1.0 + (1.0 - (LifeSpan / Default.LifeSpan)));
	ScaleGlow = 1.0 * (LifeSpan / Default.LifeSpan);
}

defaultproperties
{
     BaseDrawScale=0.125000
     Drawscale=0.125000
     LifeSpan=15.000000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Texture=WetTexture'VMDEffects.Effects.BloodCloudTex1'
     DrawType=DT_Sprite
     bUnlit=True
}
