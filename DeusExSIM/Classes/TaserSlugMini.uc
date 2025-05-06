//=============================================================================
// TaserSlugMini.
//=============================================================================
class TaserSlugMini extends TaserSlug;

#exec OBJ LOAD FILE=VMDAssets

function PlayImpactSound()
{
	local float rad;
	
	if ((Level.NetMode == NM_Standalone) || (Level.NetMode == NM_ListenServer) || (Level.NetMode == NM_DedicatedServer))
	{
		rad = Max(blastRadius*4, 1024);
		PlaySound(ImpactSound, SLOT_None, 2.0,, rad, VMDGetMiscPitch() * 2);
	}
}

defaultproperties
{
     bBlood=True
     bStickToWall=True
     DamageType=stunned
     spawnAmmoClass=None
     bIgnoresNanoDefense=False //MADDERS: This one has a funny interaction.
     ItemName="Miniature Taser Slug"
     ItemArticle="a"
     speed=3000.000000
     MaxSpeed=4500.000000
     Damage=3.000000
     MomentumTransfer=1000
     ImpactSound=Sound'TaserSlugImpact'
     Mesh=LodMesh'VMDTaserSlug'
     DrawScale=0.650000
     CollisionRadius=1.330000
     CollisionHeight=0.330000
     LifeSpan=0.000000
}
