//=============================================================================
// Food Warp Tip.
// Let us know what up.
//=============================================================================
class VMDFoodWarpTip extends VMDSurrealDeco;

var bool bEngaged;
var float IntendedScale;

function Tick(float DT)
{
	if (bEngaged)
	{
		if (DrawScale < IntendedScale)
		{
			DrawScale += DT * 1.5 * IntendedScale;
		}
		else if (DrawScale > IntendedScale)
		{
			DrawScale = IntendedScale;
		}
	}
	else
	{
		if (DrawScale > 0.0)
		{
			DrawScale -= DT * 3 * IntendedScale;
		}
		else
		{
			Destroy();
		}
	}
	
	Super.Tick(DT);
}

defaultproperties
{
     bEngaged=True
     IntendedScale=1.000000
     DrawScale=0.000000
     ScaleGlow=1.000000
     Multiskins(0)=Texture'FoodWarpTooltip'
     //Multiskins(0)=Texture'HDFoodWarpTooltipA'
     //Multiskins(1)=Texture'HDFoodWarpTooltipB'
     //Multiskins(2)=Texture'HDFoodWarpTooltipC'
     //Multiskins(3)=Texture'HDFoodWarpTooltipD'
     
     Physics=PHYS_None
     bInvincible=True
     bCanBeBase=False
     bPushable=False
     ItemName="ERR"
     Mesh=LodMesh'HousingTipSquare'
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bProjTarget=False
     bBlockActors=False
     bBlockPlayers=False
     bCollideActors=False
     bCollideWorld=False
     Mass=0.000000
     Buoyancy=0.000000
}
