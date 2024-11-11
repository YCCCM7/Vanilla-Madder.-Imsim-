//=============================================================================
// VMDRicochetSoundMaker.
//=============================================================================
class VMDRicochetSoundMaker extends Effects;

var int UseRadius;

function PostBeginPlay()
{
 	local int R;
	
	R = Rand(4);
	switch(R)
	{
		case 0:
			PlaySound(Sound'Ricochet1', SLOT_Misc, 48,, UseRadius);
		break;
		case 1:
			PlaySound(Sound'Ricochet2', SLOT_Misc, 48,, UseRadius);
		break;
		case 2:
			PlaySound(Sound'Ricochet3', SLOT_Misc, 48,, UseRadius);
		break;
		case 3:
			PlaySound(Sound'Ricochet4', SLOT_Misc, 48,, UseRadius);
		break;
	}
}

defaultproperties
{
     UseRadius=384
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Physics=PHYS_Projectile
     Drawscale=0.050000
     LifeSpan=1.000000
     Style=STY_Translucent
     Texture=Texture'BlackMaskTex'
     DrawType=DT_None
     bUnlit=True
}
