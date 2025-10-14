//=============================================================================
// PlasmaBoltMini.
//=============================================================================
class PlasmaBoltMini extends PlasmaBolt;

function Tick(float DT)
{
	local float TDist;
	
	TDist = Abs(VSize(InitLoc - Location));
	if (TDist < AccurateRange)
	{
		Speed = Default.Speed - (TDist *2);
		Velocity = Speed * InitDir;
	}
	
	Super.Tick(DT);
}

defaultproperties
{
     mpDamage=8.000000
     mpBlastRadius=300.000000
     bExplodes=True
     blastRadius=128.000000
     DamageType=Burned
     AccurateRange=1024
     maxRange=24000
     speed=3000.000000
     MaxSpeed=3000.000000
     Damage=17.000000
     MomentumTransfer=5000
     DrawScale=1.500000
}
