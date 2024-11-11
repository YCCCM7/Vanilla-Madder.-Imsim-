//=============================================================================
// RocketNuclearLAW. Get glassed, scrubs!
//=============================================================================
class RocketNuclearLAW extends Rocket;

simulated function PreBeginPlay()
{
	Super.PreBeginPlay();

	if (( Level.NetMode != NM_Standalone ) && (Class == Class'RocketLAW'))
	{
		SoundRadius = 64;
	}
}

defaultproperties
{
     blastRadius=2048.000000
     ItemName="Nuclear Rocket"
     Damage=1000.000000
     MomentumTransfer=40000
     SpawnSound=Sound'DeusExSounds.Robot.RobotFireRocket'
     Mesh=LodMesh'DeusExItems.RocketLAW'
     DrawScale=3.000000
     AmbientSound=Sound'DeusExSounds.Weapons.LAWApproach'
}
