//=============================================================================
// TriadLumPath2.
//=============================================================================
class TriadLumPath2 extends HumanThug;

function VMDRandomizeAppearance()
{
	local int TRand;
	local Texture TTex;
	
	TRand = Rand(5);
	switch(TRand)
	{
		case 1:
			TTex = Texture'TriadLumPath3Tex0';
		break;
		case 2:
			TTex = Texture'TriadLumPath4Tex0';
		break;
		case 3:
			TTex = Texture'TriadLumPath6Tex0';
		break;
		case 4:
			TTex = Texture'TriadLumPath7Tex0';
		break;
	}
	
	if (TTex != None)
	{
		Multiskins[0] = TTex;
		Multiskins[2] = TTex;
		StoredMultiskins[0] = Multiskins[0];
		StoredMultiskins[2] = Multiskins[2];
	}
}

defaultproperties
{
     CarcassType=Class'DeusEx.TriadLumPath2Carcass'
     WalkingSpeed=0.300000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponPistol')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=2)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponSword')
     walkAnimMult=1.200000
     GroundSpeed=200.000000
     WaterSpeed=240.000000
     AirSpeed=144.000000
     BaseEyeHeight=32.000000
     Mesh=LodMesh'TranscendedModels.TransGM_Suit'
     DrawScale=1.050000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.TriadLumPath2Tex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex10'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.TriadLumPath2Tex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.TriadLumPathTex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.TriadLumPathTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExItems.Skins.BlackMaskTex'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.PonytailTex1'
     CollisionRadius=16.799999
     CollisionHeight=48.830002
     Buoyancy=97.000000
     BindName="TriadLuminousPathLeader"
     FamiliarName="Gang Leader"
     UnfamiliarName="Gang Leader"
}
