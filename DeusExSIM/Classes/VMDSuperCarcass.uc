//=============================================================================
// VMDSuperCarcass.
//=============================================================================
class VMDSuperCarcass extends DeusExCarcass;

function InitFor(Actor Other)
{
 	local int i;
 	local String S;
	local ScriptedPawn SP;
	local VMDBufferPawn VMBP;
	local VMDBufferPlayer VMP;
 	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	SP = ScriptedPawn(Other);
	VMBP = VMDBufferPawn(Other);
 	if (Other == None)
 	{
  		Super.InitFor(Other);
  		return;
 	}
 	else
	{
		if ((VMP != None) && (VMP.bEnemyReactKOdDudes))
		{
			bKOEmitCarcass = true;
		}
		
 		if (VMDBufferPawn(Other) != None) SetSkin(VMDBufferPawn(Other));
		if (VMDBufferPlayer(Other) != None) SetSkinPlayer(VMDBufferPlayer(Other));

		//MADDERS, 9/11/21: Clone fatness for goofy stuff.
		Fatness = Other.Fatness;
		
		MyPawnSeed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Other);
		
		//MADDERS: Store this data for use with complex corpse interactions.
		FlagName = Other.BindName;
		if (VMBP != None)
		{
			if (class'VMDStaticFunctions'.Static.TargetIsMayhemable(Other))
			{
				bMayhemPayback = VMBP.bAntiMayhemSuspect;
				bMayhemSuspect = VMBP.bMayhemSuspect;
			}
			
			if (VMBP.bCorpseUnfrobbable)
			{
				bFrobbable = False;
			}
			
			StoredFamiliarName = VMBP.FamiliarName;
			
			if ((VMDBufferPlayer(GetPlayerPawn()) != None) && (VMDBufferPlayer(GetPlayerPawn()).HasSkillAugment('MeleeProjectileLooting')))
			{
				for (i=0; i<4; i++)
				{
					StuckProjectiles[i] = VMBP.StuckProjectiles[i];
					StuckCount[i] = VMBP.StuckCount[i];
				}
			}
		}
		
		if (bAnimalCarcass)
		{
			itemName = msgAnimalCarcass;
		}
		
		//MADDERS, 12/20/20: Show familiar names of not ded dudes.
		if (bNotDead)
		{
			if (SP.FamiliarName != "")
			{
				itemName = msgNotDead@"("$ScriptedPawn(Other).FamiliarName$")";
			}
			else
			{
				itemName = msgNotDead;
			}
		}
		else if (SP != None)
		{
			if (SP.FamiliarName != "")
			{
				itemName = itemName@"("$ScriptedPawn(Other).FamiliarName$")";
			}
			else
			{
				itemName = itemName;
			}
		}
		
		Mass           = Other.Mass;
		Buoyancy       = Mass * 1.2;
		MaxDamage      = 0.8*Mass;

		if (SP != None)
		{
			if (SP.bBurnedToDeath)
			{
				//G-Flex: Give burn victims close to 1/4 corpse-health instead of 1
				//G-Flex: Instacrowbargibbing burnt bodies feels dumb, albeit hilarious
				//G-Flex: Adding one health to prevent purely hypothetical instagib due to rounding
				CumulativeDamage = MaxDamage * 0.75 - 1;
			}
		}
		SetScaleGlow();
		
		// Will this carcass spawn flies?
		if (bAnimalCarcass)
		{
			if (FRand() < 0.2)
				bGenerateFlies = true;
		}
		else if (!Other.IsA('Robot') && (!bNotDead || bKOEmitCarcass))
		{
			if ((FRand() < 0.1) && (!bNotDead))
			{
				bGenerateFlies = true;
			}
			bEmitCarcass = true;
		}

		if (Other.AnimSequence == 'DeathFront')
			Mesh = Mesh2;

		// set the instigator and tag information
		if (Other.Instigator != None)
		{
			KillerBindName = Other.Instigator.BindName;
			KillerAlliance = Other.Instigator.Alliance;
		}
		else
		{
			KillerBindName = Other.BindName;
			KillerAlliance = '';
		}
		Tag = Other.Tag;
		Alliance = Pawn(Other).Alliance;
		
		if ((bNotDead) && (IsA('ScubaDiverCarcass')))
			AmbientSound = Sound'RebreatherLoop';
		
		CarcassName = Other.Name;
		
		VMDUpdateMassBuoyancy();
	}
}

function SetSkin(VMDBufferPawn P)
{
	local int i;
	local String S;
	
	if (P != None)
	{
	 	for(i=0; i<8; i++)
	 	{
			if (P.StoredMultiskins[i] != None)
			{
				Multiskins[i] = P.StoredMultiskins[i];
			}
			else
			{
	  			Multiskins[i] = P.Multiskins[i];
			}
			Skin = P.StoredSkin;
	  		Texture = P.StoredTexture;
	  		Mesh = ParseMesh(P.Mesh);
	  		Mesh2 = MakeMesh(Mesh, "B");
	  		Mesh3 = MakeMesh(Mesh, "C");
			
			if (P.AnimSequence == 'DeathFront')
			{
				Mesh = Mesh2;
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
			Skin = P.Skin;
	  		Texture = P.Texture;
	  		Mesh = ParseMesh(P.Mesh);
	  		Mesh2 = MakeMesh(Mesh, "B");
	  		Mesh3 = MakeMesh(Mesh, "C");
			
			if (P.AnimSequence == 'DeathFront')
			{
				Mesh = Mesh2;
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
 	
	if (StartingMesh == LODMesh'GM_TrenchLeft')
	{
		StartingMesh = LODMesh'GM_Trench';
	}
	else if (StartingMesh == LODMesh'GM_Trench_FLeft')
	{
		StartingMesh = LODMesh'GM_Trench_F';
	}
	else if (StartingMesh == LODMesh'GFM_TrenchLeft')
	{
		StartingMesh = LODMesh'GFM_Trench';
	}
	else if (StartingMesh == LODMesh'MP_Jumpsuit')
	{
		StartingMesh = LODMesh'GM_Jumpsuit';
	}
	
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
