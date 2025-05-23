//=============================================================================
// RiotCop.
//=============================================================================
class RiotCop extends HumanMilitary;

function VMDRandomizeAppearance()
{
	local int TRand;
	local Texture TTex;
	
	TRand = Rand(14);
	switch(TRand)
	{
		case 1:
			TTex = Texture'MiscTex2';
		break;
		case 2:
			TTex = Texture'MiscTex3';
		break;
		case 3:
			TTex = Texture'MiscTex4';
		break;
		case 4:
			TTex = Texture'MiscTex5';
		break;
		case 5:
			TTex = Texture'MiscTex6';
		break;
		case 6:
			TTex = Texture'MiscTex7';
		break;
		case 7:
			TTex = Texture'MiscTex8';
		break;
		case 8:
			TTex = Texture'MiscTex9';
		break;
		case 9:
			TTex = Texture'MiscTex10';
		break;
		case 10:
			TTex = Texture'MiscTex11';
		break;
		case 11:
			TTex = Texture'MiscTex12';
		break;
		case 12:
			TTex = Texture'MiscTex13';
		break;
		case 13:
			TTex = Texture'MiscTex14';
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

function GotoDisabledState(name damageType, EHitLocation hitPos)
{
	if (!bCollideActors && !bBlockActors && !bBlockPlayers)
		return;
	else if ((damageType == 'TearGas') || (damageType == 'HalonGas'))
		GotoNextState();
	else if (damageType == 'Stunned')
		GotoState('Stunned');
	else if (CanShowPain())
		TakeHit(hitPos);
	else
		GotoNextState();
}

//MADDERS: Gives us random loot.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local int Seed;
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5);
 	if ((Seed == 4) && (!bAppliedSpecial))
 	{
  		IC = ObtainRandomGoodie();
  		
		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

defaultproperties
{
     SmellTypes(6)=PlayerZymeSmell
     CarcassType=Class'DeusEx.RiotCopCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExCharacters.Skins.VisorTex1'
     Mesh=LodMesh'TranscendedModels.TransGM_Jumpsuit'
     MultiSkins(0)=Texture'MiscFixedTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.RiotCopTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.RiotCopTex2'
     MultiSkins(3)=Texture'MiscFixedTex1'
     MultiSkins(4)=Texture'MiscFixedTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.RiotCopTex3'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="RiotCop"
     FamiliarName="Riot Cop"
     UnfamiliarName="Riot Cop"
}
