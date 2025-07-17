//=============================================================================
// VMDSuperCarcass.
//=============================================================================
class VMDSuperCarcass extends DeusExCarcass;

function InitFor(Actor Other)
{
 	local int i;
 	local String S;
 	
 	if (Other == None)
 	{
  		Super.InitFor(Other);
  		return;
 	}
 	
 	if (VMDBufferPawn(Other) != None) SetSkin(VMDBufferPawn(Other));
	if (VMDBufferPlayer(Other) != None) SetSkinPlayer(VMDBufferPlayer(Other));
}

function SetSkin(VMDBufferPawn P)
{
	local int i;
	local String S;
	
	if (P != None)
	{
	 	for(i=0; i<8; i++)
	 	{
	  		Multiskins[i] = P.Multiskins[i];
	  		Texture = P.Texture;
	  		Mesh = ParseMesh(P.Mesh);
	  		Mesh2 = MakeMesh(Mesh, "B");
	  		Mesh3 = MakeMesh(Mesh, "C");
			
			if (P.AnimSequence == 'DeathFront')
			{
				Mesh = Mesh2;
			}
			if ((P.Region.Zone != None) && (P.Region.Zone.bWaterZone))
			{
				Mesh = Mesh3;
			}
	 	}
	}
}

function SetSkinPlayer(VMDBufferPlayer P)
{
	local int i;
	local String S;
	
	if (P != None)
	{
	 	for(i=0; i<8; i++)
	 	{
	  		Multiskins[i] = P.Multiskins[i];
	  		Texture = P.Texture;
	  		Mesh = ParseMesh(P.Mesh);
	  		Mesh2 = MakeMesh(Mesh, "B");
	  		Mesh3 = MakeMesh(Mesh, "C");
			
			if (P.AnimSequence == 'DeathFront')
			{
				Mesh = Mesh2;
			}
			if ((P.Region.Zone != None) && (P.Region.Zone.bWaterZone))
			{
				Mesh = Mesh3;
			}
	 	}
	}
}

function Mesh MakeMesh(Mesh In, string S)
{
 	local Mesh Out;
 	local string Load;
 	
 	Load = string(In)$S;
 	Out = Mesh(DynamicLoadObject(Load, class'Mesh', True));
 	
 	return Out;
}

function Mesh ParseMesh(Mesh StartingMesh)
{
 	local Mesh M;
 	local String SelfString, Trim, OS;
 	
 	SelfString = String(Mesh);
 	Trim = Right(SelfString, 1);
 	OS = String(StartingMesh);
 	OS = OS$"_Carcass";
 	M = Mesh(DynamicLoadObject(OS, class'Mesh', True));
 	
 	if (M == None)
 	{
  		return StartingMesh;
 	}
 	
 	return M;
}

defaultproperties
{
     Mesh2=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassB'
     Mesh3=LodMesh'DeusExCharacters.GM_Jumpsuit_CarcassC'
     Texture=Texture'DeusExItems.Skins.PinkMaskTex'
     Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit_Carcass'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.SkinTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.MJ12TroopTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MJ12TroopTex2'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.SkinTex1'
     MultiSkins(4)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.MJ12TroopTex3'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.MJ12TroopTex4'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionRadius=40.000000
}
