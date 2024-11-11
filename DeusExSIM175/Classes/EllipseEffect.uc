//=============================================================================
// EllipseEffect.
//=============================================================================
class EllipseEffect extends Effects;

var DeusExPlayer AttachedPlayer;

simulated function Tick(float deltaTime)
{
	ScaleGlow = 2.0 * (LifeSpan / Default.LifeSpan);
	if (AttachedPlayer != None)
		SetLocation(AttachedPlayer.Location);
}

defaultproperties
{
     LifeSpan=1.000000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'DeusExItems.EllipseEffect'
     bUnlit=True
}
