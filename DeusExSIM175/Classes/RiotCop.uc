//=============================================================================
// RiotCop.
//=============================================================================
class RiotCop extends HumanMilitary;

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
 	if (Seed == 4)
 	{
  		IC = ObtainRandomGoodie();
  		
		AddToInitialInventory(IC, 1 + (int(IC == class'Credits')*Rand(90)));
 	}
}

defaultproperties
{
     CarcassType=Class'DeusEx.RiotCopCarcass'
     WalkingSpeed=0.296000
     walkAnimMult=0.780000
     GroundSpeed=200.000000
     Texture=Texture'DeusExCharacters.Skins.VisorTex1'
     Mesh=LodMesh'DeusExCharacters.GM_Jumpsuit'
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MiscTex1'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.RiotCopTex1'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.RiotCopTex2'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MiscTex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.MiscTex1'
     MultiSkins(5)=Texture'DeusExItems.Skins.GrayMaskTex'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.RiotCopTex3'
     CollisionRadius=20.000000
     CollisionHeight=47.500000
     BindName="RiotCop"
     FamiliarName="Riot Cop"
     UnfamiliarName="Riot Cop"
}
