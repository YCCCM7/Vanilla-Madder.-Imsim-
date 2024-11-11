//=============================================================================
// CatCarcass.
//=============================================================================
class CatCarcass extends DeusExCarcass;

defaultproperties
{
     FamiliarName="Cat" // Transcended - Added
     Mesh2=LodMesh'TranscendedModels.TransCatCarcass'
     Mesh3=LodMesh'TranscendedModels.TransCatCarcass'
     bAnimalCarcass=True
     Mesh=LodMesh'DeusExCharacters.CatCarcass'
     CollisionRadius=17.000000
     CollisionHeight=3.600000
     Mass=10.000000
     Buoyancy=12.000000 // Transcended - No longer bouncy in water
}
