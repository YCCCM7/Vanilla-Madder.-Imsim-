//=============================================================================
//VMDPawnOverlay. High tech and fancy.
//=============================================================================
class VMDPawnOverlay extends Effects
	abstract;

var bool bFadeOverTime;
var float BrightnessMult;

simulated function Tick(float deltaTime)
{
	local int i;
	
	Super.Tick(deltaTime);
	
	if (bFadeOvertime)
	{
		ScaleGlow = (LifeSpan/Default.LifeSpan) * BrightnessMult;
	}
	
	if (Owner == None)
	{
		Destroy();
	}
	else
	{
		Fatness = Owner.Fatness;
		PrePivot = Owner.PrePivot;
		//Texture = Owner.Texture;
		SetLocation(Owner.Location);
		
		for(i=0; i<4; i++)
		{
		    BlendAnimSequence[i] = Owner.BlendAnimSequence[i];
		    BlendAnimFrame[i] = Owner.BlendAnimFrame[i];
		    BlendAnimRate[i] = Owner.BlendAnimRate[i];
		    BlendTweenRate[i] = Owner.BlendTweenRate[i];
		    BlendAnimLast[i] = Owner.BlendAnimLast[i];
		    BlendAnimMinRate[i] = Owner.BlendAnimMinRate[i];
		    OldBlendAnimRate[i] = Owner.OldBlendAnimRate[i];
		    SimBlendAnim[i] = Owner.SimBlendAnim[i];
		}
	}
}

function ApplyOverlayTexture(Texture TTex)
{
	local int i;
	
	Texture = TTex;
	Skin = TTex;
	
	//don't draw masked stuff, blackmasktex will be completely translucent
	for(i=0; i<ArrayCount(Multiskins); i++)
	{
		switch(Owner.Multiskins[i])
		{
			case None:
			case Texture'BlackMaskTex':
			case Texture'PinkMaskTex':
			case Texture'GrayMaskTex':
				Multiskins[i] = Texture'BlackMaskTex'; //Don't show masked stuff
			break;
			default:
				MultiSkins[i] = TTex;
			break;
		}
	}
	
	//don't draw glasses, they don't look good with their material settings and the firetexture
	switch(Mesh)
	{
		case LODMesh'GM_DressShirt_B':
		case LODMesh'TransGM_DressShirt_B':
			MultiSkins[4] = Texture'BlackMaskTex';
		break;
		case LODMesh'GFM_TShirtPants':
		case LODMesh'TransGFM_TShirtPants':
			MultiSkins[3]= Texture'BlackMaskTex';
			MultiSkins[4] = Texture'BlackMaskTex';
		break;
		case LODMesh'GM_DressShirt':
		case LODMesh'GM_DressShirt_F':
		case LODMesh'GM_DressShirt_S':
		case LODMesh'GMK_DressShirt':
		case LODMesh'GMK_DressShirt_F':
		case LODMesh'TransGM_DressShirt':
		case LODMesh'TransGM_DressShirt_F':
		case LODMesh'TransGM_DressShirt_S':
		case LODMesh'TransGMK_DressShirt':
		case LODMesh'TransGMK_DressShirt_F':
		case LODMesh'GM_Trench':
		case LODMesh'GM_Trench_F':
		case LODMesh'GFM_Trench':
		case LODMesh'GM_TrenchLeft':
		case LODMesh'GM_Trench_FLeft':
		case LODMesh'GFM_TrenchLeft':
		case LODMesh'TransGM_Trench':
		case LODMesh'TransGM_Trench_F':
		case LODMesh'TransGFM_Trench':
		case LODMesh'GFM_SuitSkirt':
		case LODMesh'GFM_SuitSkirt_F':
		case LODMesh'TransGFM_SuitSkirt':
		case LODMesh'TransGFM_SuitSkirt_F':
			MultiSkins[6] = Texture'BlackMaskTex';
			MultiSkins[7] = Texture'BlackMaskTex';
		break;
		case LODMesh'GM_Jumpsuit':
		case LODMesh'MP_Jumpsuit':
		case LODMesh'TransGM_Jumpsuit':
		//case LODMesh'TransMP_Jumpsuit': Lol. Doesn't exist.
			MultiSkins[5] = Texture'BlackMaskTex';
		break;
		case LODMesh'GM_Suit':
		case LODMesh'TransGM_Suit':
			MultiSkins[5] = Texture'BlackMaskTex';
			MultiSkins[6] = Texture'BlackMaskTex';
		break;
		default: //GFM_Dress?
		break;
	}
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	
	Mesh = Owner.Mesh;
	DrawScale = Owner.DrawScale;
	
	Fatness = Owner.Fatness;
	Prepivot = Owner.Prepivot;
	
	ApplyOverlayTexture(Texture);
	
	bTrailerSameRotation = true;
	bAnimByOwner = true;
	
	SetBase(Owner);
}

defaultproperties
{
     BrightnessMult=1.000000
     
     bTravel=True
     Physics=PHYS_Trailer
     DrawType=DT_Mesh
     Style=STY_Translucent
     ScaleGlow=0.700000
     bUnlit=True
     bOwnerNoSee=True
}