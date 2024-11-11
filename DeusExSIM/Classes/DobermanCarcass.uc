//=============================================================================
// DobermanCarcass.
//=============================================================================
class DobermanCarcass extends DeusExCarcass;

defaultproperties
{
     FamiliarName="Doberman" // Transcended - Added
     Mesh2=LodMesh'TranscendedModels.TransDobermanCarcass'
     Mesh3=LodMesh'TranscendedModels.TransDobermanCarcass'
     bAnimalCarcass=True
     Mesh=LodMesh'DeusExCharacters.DobermanCarcass'
     CollisionRadius=30.000000
     Mass=25.000000
     Buoyancy=27.000000 // Transcended - No longer bouncy in water
}
