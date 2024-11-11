//=============================================================================
// MIB.
//=============================================================================
class MIB extends HumanMilitary;

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

// ----------------------------------------------------------------------
// SpawnCarcass()
//
// Blow up instead of spawning a carcass
// ----------------------------------------------------------------------

function Carcass SpawnCarcass()
{
	local Carcass TCarc;
	
	if (bStunned)
	{
		TCarc = Super.SpawnCarcass();
		if (TCarc != None)
		{
		 	TCarc.Multiskins[0] = Multiskins[0];
		 	TCarc.Multiskins[2] = Multiskins[2];
		}
	}
	else
	{
	 	Explode();
	 	return None;
	}
	
	return TCarc;
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local int oldHealth;
	
	oldHealth = Health;
	
	Super.TakeDamageBase(Damage, instigatedBy, hitlocation, momentum, damageType, bPlayAnim);
	
	if ((Health > 0) && (Health <= (StartingHealthValues[6] / 4)) && (oldHealth > (StartingHealthValues[6] / 4)))
	{
        	PlayCriticalDamageSound();
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
     CarcassType=Class'DeusEx.MIBCarcass'
     WalkingSpeed=0.213333
     CloseCombatMult=0.500000
     GroundSpeed=180.000000
     Health=350
     HealthHead=350
     HealthTorso=350
     HealthLegLeft=350
     HealthLegRight=350
     HealthArmLeft=350
     HealthArmRight=350
     Mesh=LodMesh'DeusExCharacters.GM_Suit'
     DrawScale=1.100000
     MultiSkins(0)=Texture'DeusExCharacters.Skins.MIBTex0'
     MultiSkins(1)=Texture'DeusExCharacters.Skins.PantsTex5'
     MultiSkins(2)=Texture'DeusExCharacters.Skins.MIBTex0'
     MultiSkins(3)=Texture'DeusExCharacters.Skins.MIBTex1'
     MultiSkins(4)=Texture'DeusExCharacters.Skins.MIBTex1'
     MultiSkins(5)=Texture'DeusExCharacters.Skins.FramesTex2'
     MultiSkins(6)=Texture'DeusExCharacters.Skins.LensesTex3'
     MultiSkins(7)=Texture'DeusExItems.Skins.PinkMaskTex'
     CollisionHeight=52.250000
     BindName="MIB"
     FamiliarName="Man In Black"
     UnfamiliarName="Man In Black"
}
