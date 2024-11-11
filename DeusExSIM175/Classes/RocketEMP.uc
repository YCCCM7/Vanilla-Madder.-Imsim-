//=============================================================================
// RocketEMP.
//=============================================================================
class RocketEMP extends Rocket;

var float mpExplodeDamage;

#exec OBJ LOAD FILE=Effects

simulated function DrawExplosionEffects(vector HitLocation, vector HitNormal)
{
	local ExplosionLight light;
	local int i;
	local Rotator rot;
	local SphereEffect sphere;
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
		light.size = 8;
		light.LightHue = 128;
		light.LightSaturation = 96;
		light.LightEffect = LE_Shell;
	}

	expeffect = Spawn(class'ExplosionSmall',,, HitLocation);
   	if (expeffect != None)
      		expeffect.RemoteRole = ROLE_None;

	// draw a cool light sphere
	sphere = Spawn(class'SphereEffect',,, HitLocation);
	if (sphere != None)
   	{
		sphere.RemoteRole = ROLE_None;
		sphere.size = blastRadius / 32.0;
   	}
}

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();
	
	if ( ( Level.NetMode != NM_Standalone ) && (Class == Class'RocketWP') )
	{
      		speed = 2000.0000;
      		SetTimer(5,false);
      		Damage = mpExplodeDamage;
		blastRadius = mpBlastRadius;
		SoundRadius=76;
	}
}

defaultproperties
{
     mpExplodeDamage=75.000000
     mpBlastRadius=384.000000
     bBlood=False
     bDebris=False
     blastRadius=256.000000
     Damage=800.000000
     DamageType=EMP
     ItemName="EMP Rocket"
     ImpactSound=Sound'DeusExSounds.Weapons.EMPGrenadeExplode'
     Mesh=LodMesh'DeusExItems.Rocket'
     DrawScale=0.250000
     AmbientSound=Sound'DeusExSounds.Weapons.RocketLoop'
}
