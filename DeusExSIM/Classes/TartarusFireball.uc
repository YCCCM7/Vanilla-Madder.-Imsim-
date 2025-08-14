//=============================================================================
// TartarusFireball.
//=============================================================================
class TartarusFireball extends DeusExProjectile;

#exec OBJ LOAD FILE=Effects

simulated function Tick(float deltaTime)
{
	local float value;
	local float sizeMult;
	
	//Don't call Super.Tick() because we don't want gravity to affect the stream
	time += deltaTime;
	
	value = 1.0+time;
	if (MinDrawScale > 0)
		sizeMult = MaxDrawScale/MinDrawScale;
	else
		sizeMult = 1;
	
	DrawScale = (-sizeMult/(value*value) + (sizeMult+1))*MinDrawScale;
	ScaleGlow = Default.ScaleGlow/(value*value*value);
}

function ZoneChange(ZoneInfo NewZone)
{
	Super.ZoneChange(NewZone);
	
	// If the fireball enters water, extingish it
	if (NewZone.bWaterZone)
		Destroy();
}

defaultproperties
{
     blastRadius=1.000000
     DamageType=Flamed
     AccurateRange=640
     maxRange=640
      bIgnoresNanoDefense=True //MADDERS: Used to be false, and true before that.
     ItemName="Fireball"
     ItemArticle="a"
     speed=2000.000000
     MaxSpeed=2000.000000
     Damage=3.000000
     MomentumTransfer=500
     ExplosionDecal=Class'DeusEx.BurnMark'
     LifeSpan=0.400000
     DrawType=DT_Sprite
     Style=STY_Translucent
     Texture=FireTexture'Effects.Fire.Flmethrwr_Flme'
     DrawScale=0.025000
     bUnlit=True
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=200
     LightHue=16
     LightSaturation=32
     LightRadius=6 // Transcended - Increased
}
