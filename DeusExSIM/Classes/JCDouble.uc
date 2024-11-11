//=============================================================================
// JCDouble.
//=============================================================================
class JCDouble extends HumanMilitary;

var VMDBufferPlayer VMP;

//
// JC's cinematic stunt double!
//
function SetSkin(DeusExPlayer player)
{
	local int i;
	
	VMP = VMDBufferPlayer(Player);
	if (player != None)
	{
		if (VMP != None)
		{
			VMP.FabricatePlayerAppearance();
		}
		
		Mesh = Player.Mesh;
		for (i=0; i<8; i++)
		{
			Multiskins[i] = Player.Multiskins[i];
		}
		Texture = Player.Texture;
		DrawScale = Player.DrawScale;
	}
}

function ImpartMomentum(Vector momentum, Pawn instigatedBy)
{
	// to ensure JC's understudy doesn't get impact momentum from damage...
}

function AddVelocity( vector NewVelocity)
{
}


// ----------------------------------------------------------------------
// ----------------------------------------------------------------------

defaultproperties
{
     WalkingSpeed=0.120000
     bInvincible=True
     BaseAssHeight=-23.000000
     Mesh=LodMesh'TranscendedModels.TransGM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.JCDentonTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.JCDentonTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.JCDentonTex3'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.JCDentonTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.JCDentonTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.JCDentonTex2'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex4'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex5'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="JCDouble"
     FamiliarName="JC Denton"
     UnfamiliarName="JC Denton"
     NameArticle=" "
}
