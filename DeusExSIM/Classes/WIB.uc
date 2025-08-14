//=============================================================================
// WIB.
//=============================================================================
class WIB extends HumanMilitary;

var int EMPTakenTotal;

function bool VMDCanRunWithAnyWeapon()
{
	return true;
}

function CheckHealthScaling()
{
	local VMDBufferPlayer VMP;
	
	VMP = GetLastVMP();
 	if ((VMP != None) && (!bSetupBuffedHealth))
 	{
		VMDExtendVision();
		
		LastEnemyHealthScale = VMP.EnemyHPScale;
  		HealthHead *= VMP.EnemyHPScale;
  		HealthTorso *= VMP.EnemyHPScale;
  		HealthArmLeft *= VMP.EnemyHPScale;
  		HealthArmRight *= VMP.EnemyHPScale;
  		HealthLegLeft *= VMP.EnemyHPScale;
  		HealthLegRight *= VMP.EnemyHPScale;
		Health *= VMP.EnemyHPScale;
  		CloakThreshold *= VMP.EnemyHPScale;
  		
  		bSetupBuffedHealth = True;
		
		if (VMP.bRecognizeMovedObjectsEnabled)
		{
			bRecognizeMovedObjects = true;
		}
		if (VMP.bEnemyAlwaysAvoidProj)
		{
			bAvoidHarm = true;
			bReactProjectiles = true;
		}
		DifficultyVisionRangeMult = FMin(2.5, VMP.EnemyVisionRangeMult + 0.5);
		
		if (!bBuffedSenses)
		{
			VisibilityThreshold = FMax(VisibilityThreshold * VMP.EnemyVisionStrengthMult,  0.0025);
			if (!VMDHasHearingExtensionObjection())
			{
				HearingThreshold = FMax(HearingThreshold * (VMP.EnemyHearingRangeMult - 0.1), 0.0375);
			}
			bBuffedSenses = true;
		}
		
		SurprisePeriod = FMin(SurprisePeriod, FMax(VMP.EnemySurprisePeriodMax - 0.5, 0.50));
		
		DifficultyExtraSearchSteps = VMP.EnemyExtraSearchSteps+2;
		DifficultyROFWeight = FMax(-0.15, VMP.EnemyROFWeight - 0.05);
		DifficultyReactionSpeedMult = FMin(3.0, VMP.EnemyReactionSpeedMult + 0.5);
		EnemyGuessingFudge = FMin(0.65, VMP.EnemyGuessingFudge + 0.15);
		if (!bBuffedAccuracy)
		{
			BaseAccuracy = FMax(FMin(VMP.EnemyAccuracyMod - 0.15, BaseAccuracy), -0.35);
			bBuffedAccuracy = true;
		}
		StartingBaseAccuracy = BaseAccuracy;
 	}
	
	if ((MinHealth > 1) && (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Enemy Damage Gate")))
	{
		bDamageGateInTact = true;
	}
	
	StoredScaleGlow = ScaleGlow;
	StoredFatness = Fatness;
	
	SprintStaminaMax = FMin(Health, 200.0);
	SprintStamina = SprintStaminaMax;
	
	StartingGroundSpeed = GroundSpeed;
	StartingBuoyancy = Buoyancy;
	StartingHealthValues[0] = HealthHead;
	StartingHealthValues[1] = HealthTorso;
	StartingHealthValues[2] = HealthArmLeft;
	StartingHealthValues[3] = HealthArmRight;
	StartingHealthValues[4] = HealthLegLeft;
	StartingHealthValues[5] = HealthLegRight;
	StartingHealthValues[6] = Health;
  	GenerateTotalHealth();
}

// ----------------------------------------------------------------------
// SpawnCarcass()
//
// Blow up instead of spawning a carcass
// ----------------------------------------------------------------------

function Carcass SpawnCarcass()
{
	local Carcass TCarc;
	
	if (bStunned || EMPTakenTotal >= 75)
	{
		TCarc = Super.SpawnCarcass();
		if (DeusExCarcass(TCarc) != None)
		{
			DeusExCarcass(TCarc).EMPTakenTotal = EMPTakenTotal;
		}
	}
	else
	{
		Explode();
	}
	
	return None;
}

function TakeDamageBase(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, name damageType, bool bPlayAnim)
{
	local int oldHealth;
	
	oldHealth = Health;
	
	if (DamageType == 'EMP')
	{
		EMPTakenTotal += Damage;
	}
	
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
     bFearEMP=True
     bCanClimbLadders=False
     bDrawShieldEffect=True
     ArmorStrength=0.700000
     bExplosive=True
     EnviroSkillLevel=3
     ROFCounterweight=0.200000
     
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
     Mesh=LodMesh'TranscendedModels.TransGFM_SuitSkirt'
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
