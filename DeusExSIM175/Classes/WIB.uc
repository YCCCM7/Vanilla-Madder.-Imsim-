//=============================================================================
// WIB.
//=============================================================================
class WIB extends HumanMilitary;

// ----------------------------------------------------------------------
// SpawnCarcass()
//
// Blow up instead of spawning a carcass
// ----------------------------------------------------------------------

function Carcass SpawnCarcass()
{
	if (bStunned)
		return Super.SpawnCarcass();

	Explode();

	return None;
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local int oldHealth;
	
	oldHealth = Health;
	
	Super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
	
	if ((Health > 0) && (Health <= (StartingHealthValues[6] / 4)) && (oldHealth > (StartingHealthValues[6] / 4)))
        	PlayCriticalDamageSound();
}

//MADDERS: Give us ballistic armor and hazmat suits on ocassion.
function ApplySpecialStats()
{
 	local class<Inventory> IC;
 	local Texture TChest;
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
	forEach AllActors(Class'DeusExLevelInfo', DXLI) break;
 	
 	//1111111111111
 	//MADDERS: Obtain a seed.
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 9);
	
	if (DXLI != None)
	{
 		if ((Seed == 3) && (DXLI.MissionNumber > 12))
 		{
			AddToInitialInventory(class'BallisticArmor', 1);
 		}
 		if ((Seed == 7) && (DXLI.MissionNumber > 10))
 		{
			AddToInitialInventory(class'HazmatSuit', 1);
		}
 	}
}

defaultproperties
{
     //MADDERS additions.
     bDrawShieldEffect=True
     ArmorStrength=0.700000
     bExplosive=True
     EnviroSkillLevel=3
     
     MinHealth=0.000000
     CarcassType=Class'DeusEx.WIBCarcass'
     WalkingSpeed=0.296000
     CloseCombatMult=0.500000
     BaseAssHeight=-18.000000
     walkAnimMult=0.870000
     bIsFemale=True
     GroundSpeed=200.000000
     Health=200
     HealthHead=200
     HealthTorso=200
     HealthLegLeft=200
     HealthLegRight=200
     HealthArmLeft=200
     HealthArmRight=200
     Mesh=LodMesh'DeusExCharacters.GFM_SuitSkirt'
     DrawScale=1.100000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.WIBTex0'
     MultiSkins(1)=Texture'DeusExItems.Skins.PinkMaskTex'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.WIBTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.LegsTex2'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.WIBTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.WIBTex1'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.FramesTex2'
     MultiSkins(7)=Texture'DeusExCharacters.Skins.LensesTex3'
     CollisionHeight=47.299999
     BindName="WIB"
     FamiliarName="Woman In Black"
     UnfamiliarName="Woman In Black"
}
