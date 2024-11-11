//=============================================================================
// EllipseEffectPickup.
//=============================================================================
class EllipseEffectPickup extends Effects;

#exec OBJ LOAD FILE=VMDEffects

//MADDERS: Our entire job is to indicate when pickups are reducing damage for us.

simulated function Tick(float deltaTime)
{
	ScaleGlow = 0.5 * (LifeSpan / Default.LifeSpan);
}

defaultproperties
{
     LifeSpan=1.250000
     DrawType=DT_Mesh
     Style=STY_Translucent
     Mesh=LodMesh'DeusExItems.EllipseEffect'
     Multiskins(0)=FireTexture'VMDEffects.PickupShieldEffect'
     bUnlit=True
}
