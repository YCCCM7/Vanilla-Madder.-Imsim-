//=============================================================================
// ObliteratorRocketWP.
//=============================================================================
class ObliteratorRocketWP extends ObliteratorRocket;

#exec OBJ LOAD FILE=Effects

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ExplosionLight light;
	local ParticleGenerator gen;
   	local ExplosionSmall expeffect;
	
	if (!bHitFakeBackdrop)
		CheckIfHitFakeBackDrop();
	
	if (bHitFakeBackdrop)
		return;
	
	// draw a pretty explosion
	light = Spawn(class'ExplosionLight',,, HitLocation);
	if (light != None)
   	{
      		light.RemoteRole = ROLE_None;
			light.size = 12;
   	}
	
   	expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
   	if (expeffect != None)
      		expeffect.RemoteRole = ROLE_None;
	
	// create a particle generator shooting out white-hot fireballs
	gen = Spawn(class'ParticleGenerator',,, HitLocation, Rotator(HitNormal));
	if (gen != None)
	{
      		gen.RemoteRole = ROLE_None;
		gen.particleDrawScale = 0.25;
		gen.checkTime = 0.05;
		gen.frequency = 1.0;
		gen.ejectSpeed = 200.0;
		gen.bGravity = True;
		gen.bRandomEject = True;
		gen.particleTexture = Texture'Effects.Fire.FireballWhite';
		gen.LifeSpan = 2.0;
	}
}

defaultproperties
{
     bBlood=False
     bDebris=False
     blastRadius=256.000000
     DamageType=Flamed
     ItemName="Obliterator WP Rocket"
     ImpactSound=Sound'DeusExSounds.Generic.SmallExplosion2'
     Mesh=LodMesh'DeusExItems.RocketHE'
     DrawScale=0.500000
     AmbientSound=Sound'DeusExSounds.Weapons.WPApproach'
}
