//=============================================================================
// Temporary Nano Scorch
//=============================================================================
class PlasmaPlagueSplash extends AnimatedSprite;

simulated function Tick(float deltaTime)
{
	time += deltaTime;
	totalTime += deltaTime;
	
	//MADDERS: Overwrite the 0.5 base. Strange. You'd think DX crew wouldve thought of that one.
	DrawScale = 0.075 + (1.0 * totalTime / duration);
	ScaleGlow = (duration - totalTime) / duration;
	
	if (time >= animSpeed)
	{
		Texture = frames[nextFrame++];
		if (nextFrame >= numFrames)
			Destroy();

		time -= animSpeed;
	}
}

defaultproperties
{
     AnimSpeed=1.150000
     numFrames=1
     frames(0)=Texture'Effects.water.WaterDrop1'
     Texture=Texture'Effects.water.WaterDrop1'
}
