//=============================================================================
// WaterZone
//=============================================================================
class WaterZone extends ZoneInfo;

var VMDWaterLevelTrigger OwningTrigger;

defaultproperties
{
     EntrySound=Sound'DeusExSounds.Generic.SplashMedium'
     ExitSound=Sound'DeusExSounds.Generic.WaterOut'
     EntryActor=Class'DeusEx.WaterRing'
     ExitActor=Class'DeusEx.WaterRing'
     bWaterZone=True
     ViewFog=(Y=0.050000,Z=0.100000)
     SoundRadius=0
     AmbientSound=Sound'Ambient.Ambient.Underwater'
}
