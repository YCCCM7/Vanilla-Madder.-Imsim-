//=============================================================================
// TriadRedArrow.
//=============================================================================
class TriadRedArrow extends HumanThug;

function VMDRandomizeAppearance()
{
	local int TRand;
	local Texture TTex;
	
	TRand = Rand(9);
	switch(TRand)
	{
		case 1:
			TTex = Texture'TriadRedArrow2Tex0';
		break;
		case 2:
			TTex  = Texture'TriadRedArrow3Tex0';
		break;
		case 3:
			TTex  = Texture'TriadRedArrow4Tex0';
		break;
		case 4:
			TTex  = Texture'TriadRedArrow5Tex0';
		break;
		case 5:
			TTex  = Texture'TriadRedArrow6Tex0';
		break;
		case 6:
			TTex  = Texture'TriadRedArrow7Tex0';
		break;
		case 7:
			TTex  = Texture'TriadRedArrow8Tex0';
		break;
		case 8:
			TTex  = Texture'TriadRedArrow9Tex0';
		break;
	}
	
	if (TTex != None)
	{
		Multiskins[0] = TTex;
		Multiskins[3] = TTex;
		StoredMultiskins[0] = Multiskins[0];
		StoredMultiskins[3] = Multiskins[3];
	}
}

defaultproperties
{
     CarcassType=Class'DeusEx.TriadRedArrowCarcass'
     WalkingSpeed=0.300000
     BaseAssHeight=-23.000000
     InitialInventory(0)=(Inventory=Class'DeusEx.WeaponPistol')
     InitialInventory(1)=(Inventory=Class'DeusEx.Ammo10mm',Count=2)
     InitialInventory(2)=(Inventory=Class'DeusEx.WeaponSword')
     walkAnimMult=1.200000
     GroundSpeed=200.000000
     WaterSpeed=240.000000
     AirSpeed=144.000000
     BaseEyeHeight=36.000000
     Mesh=LodMesh'TranscendedModels.TransGM_Trench'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.TriadRedArrowTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.TriadRedArrowTex2'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.TriadRedArrowTex3'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.TriadRedArrowTex0'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.TriadRedArrowTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.TriadRedArrowTex2'
     MultiSkins(6)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(7)=Texture'DeusExItems.Skins.BlackMaskTex'
     CollisionRadius=14.000000
     CollisionHeight=47.500000
     Buoyancy=97.000000
     BindName="TriadRedArrowMember"
     FamiliarName="Gang Member"
     UnfamiliarName="Gang Member"
}
