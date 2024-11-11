//=============================================================================
// PlasmaFire.
//=============================================================================
class PlasmaFire extends Fire;

simulated function AddFire(optional float fireLifeSpan)
{
	if (fireLifeSpan == 0.0)
		fireLifeSpan = 0.5;

	if (fireGen == None)
	{
		fireGen = Spawn(class'ParticleGenerator', Self,, Location, rot(16384,0,0));
		if (fireGen != None)
		{
			fireGen.particleDrawScale = 0.5;
			fireGen.particleLifeSpan = fireLifeSpan;
			fireGen.checkTime = 0.075;
			fireGen.frequency = 0.9;
			fireGen.riseRate = 30.0;
			fireGen.ejectSpeed = 20.0;
			fireGen.bScale = False;
			fireGen.bRandomEject = True;
			fireGen.particleTexture = Texture'Effects.Fire.flmethrwr_flme';
			fireGen.SetBase(Self);
		}
	}
}

defaultproperties
{
     Texture=FireTexture'Effects.Fire.flmethrwr_flme'
     LightHue=185
     AmbientSound=Sound'Ambient.Ambient.FireSmall2'
}
