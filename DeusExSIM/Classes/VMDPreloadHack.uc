//=============================================================================
// VMDPreloadHack.
//=============================================================================
class VMDPreloadHack extends VMDFillerActors
				transient;

#exec OBJ LOAD FILE=VMDDrugFX
#exec OBJ LOAD FILE=VMDEffects
#exec OBJ LOAD FILE=Effects

function SetPreloadIndex(int NewIndex)
{
	switch(NewIndex)
	{
		case 0:
			//Assign multiskins of tenuous packages here.
		break;
	}
	
	SetTimer(0.5, true);
}

function Timer()
{
	local Pawn TPawn;
	
	TPawn = Pawn(Owner);
	if (TPawn != None)
	{
		SetLocation(TPawn.Location + (Vect(0,0,1) * TPawn.BaseEyeHeight) + (Vector(TPawn.ViewRotation) * TPawn.CollisionRadius * 2));
	}
}

defaultproperties
{
     DrawType=DT_Mesh
     Mesh=LODMesh'VMDPreloadHack'
     Lifespan=0.000000
     Texture=Texture'Engine.S_Pickup'
     bStatic=False
     bHidden=False
     bCollideWhenPlacing=True
     SoundVolume=0
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     DrawScale=0.000001
     ScaleGlow=0.000001
}
