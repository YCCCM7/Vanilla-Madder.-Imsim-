//=============================================================================
// BiocellSpark.
//=============================================================================
class BiocellSpark extends Effects;

#exec OBJ LOAD FILE=Effects

function Tick(float DT)
{
	Super.Tick(DT);
	
	ScaleGlow = FMin(Lifespan, 1.0)*1;
	
	if (Region.Zone != None)
	{
		Velocity += Region.Zone.ZoneGravity * DT * 0.4;
	}
}

defaultproperties
{
     LifeSpan=1.000000
     DrawType=DT_Sprite
     Physics=PHYS_Projectile
     Style=STY_Translucent
     Texture=FireTexture'WaterDrop1'
     DrawScale=0.125000
}
