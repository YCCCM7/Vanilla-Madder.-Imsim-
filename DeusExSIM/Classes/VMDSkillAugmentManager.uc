//=============================================================================
// VMDSkillAugmentManager
//=============================================================================
class VMDSkillAugmentManager extends Actor;

// which player am I attached to?
var DeusExPlayer Player;

var() byte SkillAugmentAssumed[80], SkillAugmentLevel[80], SkillAugmentLevelRequired[80], SecondarySkillAugmentLevelRequired[80];
//MADDERS: Late patch, but change this over to int, due to issues with negative logic.
var() travel int SkillAugmentPointsLeft[15], SkillAugmentPointsSpent[15], SkillAugmentAcquired[80];

var() name SkillAugmentIDs[80], SkillAugmentRequired[80], SecondarySkillAugmentRequired[80];
var localized string SkillAugmentNames[80], SkillAugmentDescs[80];
var() class<Skill> SkillAugmentPointClasses[15], SkillAugmentSkillRequired[80], SecondarySkillAugmentSkillRequired[80];
var() travel byte SkillSpecializations[2];

// ----------------------------------------------------------------------
// SetPlayer()
//
// Kind of a hack, until we figure out why the player doesn't get set 
// correctly initially.
// ----------------------------------------------------------------------

static function bool StaticSkillAugmentAssumed(name S)
{
 	local int i;
 	
 	i = StaticSkillAugmentArrayOf(S);
 	if (i == -1 || i >= ArrayCount(Default.SkillAugmentAssumed)) return false;
	
  	if (Default.SkillAugmentAssumed[i] > 0)
	{
		return true;
 	}
	
 	return false;
}

static function int StaticSkillAugmentArrayOf(name SkillAugmentName)
{
 	local int i;
 	
 	for (i=1; i<ArrayCount(Default.SkillAugmentIDs)+1; i++)
 	{
  		if (SkillAugmentName == Default.SkillAugmentIDs[i-1]) break;
 	}
 	if (i > ArrayCount(Default.SkillAugmentIDs)+1) i = 0;
 	i--;
 	
 	return i;
}

function SetPlayer(DeusExPlayer newPlayer)
{
	local VMDBufferPlayer VMP;
	
	VMP = VMDBufferPlayer(NewPlayer);
	Player = newPlayer;
}

function int GetSkillAugmentPointsFromSkill(class<Skill> S)
{
	local int i;
	
	i = SkillArrayOf(S);
	
	if (i < 0) return 0;
	
	return SkillAugmentPointsLeft[i] - SkillAugmentPointsSpent[i];
}

function FormatSkillAugmentPointsLeft()
{
	local int i;
	
	//NOTE: 1 is our starting point because accessed nones are bad.
	for (i=1; i<ArrayCount(SkillAugmentPointsLeft)+1; i++)
	{
		if (SkillAugmentPointClasses[i-1] != None)
		{
			SkillAugmentPointsLeft[i] = SkillAugmentPointWeightOf(i-1);
		}
	}
}

function bool IsSpecializedIn(int i)
{
	return (SkillSpecializations[0]-1 == i || SkillSpecializations[1]-1 == i);
}

function bool IsSpecializedInSkill(class<Skill> S)
{
	return (IsSpecializedIn(SkillArrayOf(S)-1));
}

function int SkillAugmentPointWeightOf(int i)
{
	local Skill S;
	local int SpecMod;
	
	if (i < 0) return 0;
	if (SkillAugmentPointClasses[i] == None) return 0;
	if (Player == None || Player.SkillSystem == None) return 0;
	
	S = Player.SkillSystem.GetSkillFromClass(SkillAugmentPointClasses[i]);
	if (IsSpecializedIn(i))
	{
		SpecMod = 1;
	}
	if (S == None) return 0;
	
	switch(S.CurrentLevel)
	{
		case 0:
			return 0+SpecMod;
		break;
		case 1:
			return 1+SpecMod;
		break;
		case 2:
			return 3+SpecMod;
		break;
		case 3:
			return 6;
		break;
	}
	
	return 0;
}

function class<Skill> GetSecondarySkillAugmentSkillRequired(int Array)
{
	return SecondarySkillAugmentSkillRequired[Array];
}

function class<Skill> GetSkillAugmentSkillRequired(int Array)
{
	return SkillAugmentSkillRequired[Array];
}

function name GetSkillAugmentRequired(int Array)
{
	return SkillAugmentRequired[Array];
}

function name GetSecondarySkillAugmentRequired(int Array)
{
	return SecondarySkillAugmentRequired[Array];
}

function int SkillArrayOf(class<Skill> RelSkill)
{
 	local int i;
 	
 	for (i=1; i<ArrayCount(SkillAugmentPointClasses)+1; i++)
 	{
  		if (RelSkill == SkillAugmentPointClasses[i-1]) return i;
 	}
 	if (i == ArrayCount(SkillAugmentPointClasses)+1) i = -1;
 	
 	return i;
}

function int SkillAugmentArrayOf(Name SkillAugmentName)
{
 	local int i;
 	
 	for (i=1; i<ArrayCount(SkillAugmentIDs)+1; i++)
 	{
  		if (SkillAugmentName == SkillAugmentIDs[i-1]) break;
 	}
 	if (i > ArrayCount(SkillAugmentIDs)+1) i = 0;
 	i--;
 	
 	return i;
}

function bool ProcessSkillAugmentCostException(Name S)
{
	local Name CS, CS2;
	
	CS = 'TagTeamOpenDecayRate';
	CS2 = 'TagTeamClosedWaterproof';
	
 	//if ((S == CS || S == CS2) && (!HasSkillAugment(CS)) && (!HasSkillAugment(CS2))) return true;
	return false;
}

function bool HasSkillAugment(Name S)
{
 	local int i;
 	
 	i = SkillAugmentArrayOf(S);
 	if (i == -1 || i >= ArrayCount(SkillAugmentAcquired)) return false;
 	if (VMDBufferPlayer(Player) == None) return false;
	
 	if ((VMDBufferPlayer(Player).ShouldUseSkillAugments()) && (!VMDHasSkillAugmentObjection(VMDBufferPlayer(Player))))
 	{
  		if (SkillAugmentAcquired[i] > 0) return true;
 	}
 	else
 	{
  		if (SkillAugmentAssumed[i] > 0) return true;
 	}
 	
 	return false;
}

function int SkillArrayFromAugment(Name AugmentID)
{
	local class<Skill> SC;
	local int i;
	
	SC = SkillAugmentSkillRequired[SkillAugmentArrayOf(AugmentID)];
	i = SkillArrayOf(SC);
	
	if (i < -1) return 0;
	return i;
}

function int SecondarySkillArrayFromAugment(Name AugmentID)
{
	local class<Skill> SC;
	local int i;
	
	SC = SecondarySkillAugmentSkillRequired[SkillAugmentArrayOf(AugmentID)];
	i = SkillArrayOf(SC);
	
	if (i < -1) return 0;
	return i;
}

function int SkillArrayFromAugmentInt(int AugmentArray)
{
	if (AugmentArray < 0) return 0;
	return SkillArrayFromAugment(SkillAugmentIDs[AugmentArray]);
}

function int SecondarySkillArrayFromAugmentInt(int AugmentArray)
{
	if (AugmentArray < 0) return 0;
	return SecondarySkillArrayFromAugment(SkillAugmentIDs[AugmentArray]);
}

function bool CanBuySkillAugment(int i, optional bool bAlt, optional bool bBoth, optional bool bBypassCost)
{
 	local Name OtherUS1, OtherUS2;
 	local bool bReq1, bReq2;
 	local class<Skill> OtherSA1, OtherSA2;
 	local int OtherSL1, OtherSL2, SpecMod;
 	
	if (Player == None || Player.SkillSystem == None) return false;
 	if (i < 0) return false;
 	if (SkillAugmentSkillRequired[i] != None) bReq1 = true;
 	if (SecondarySkillAugmentSkillRequired[i] != None) bReq2 = true;
 	
	//MADDERS: Specializations give 1 more point initially, and allow for 1 less skill level to be needed for an augment.
 	if (bReq1)
 	{
		SpecMod = 0;
  		OtherSA1 = SkillAugmentSkillRequired[i];
  		OtherSL1 = Player.SkillSystem.GetSkillLevel(OtherSA1);
		if (IsSpecializedIn(SkillArrayFromAugmentInt(i)-1)) SpecMod = -1;
		
  		if (OtherSL1 < SkillAugmentLevelRequired[i]+SpecMod) return false;
 	}
 	if (bReq2)
 	{
		SpecMod = 0;
  		OtherSA2 = SecondarySkillAugmentSkillRequired[i];
  		OtherSL2 = Player.SkillSystem.GetSkillLevel(OtherSA2);
		if (IsSpecializedIn(SecondarySkillArrayFromAugmentInt(i)-1)) SpecMod = -1;
		
  		if (OtherSL2 < SecondarySkillAugmentLevelRequired[i]+SpecMod) return false;
 	}
 	if (i > -1)
 	{
  		OtherUS1 = SkillAugmentRequired[i];
  		OtherUS2 = SecondarySkillAugmentRequired[i];
 	}
 	else
 	{
  		OtherUS1 = '';
  		OtherUS2 = '';
 	}
 	
 	if ((OtherUS1 != '') && (!HasSkillAugment(OtherUS1))) return false;
 	if ((OtherUS2 != '') && (!HasSkillAugment(OtherUS2))) return false;
 	
	if ((!bBypassCost) && (!CanAffordSkillAugment(SkillAugmentIDs[i], bAlt, bBoth))) return false;
	
 	return true;
}

function bool CanAffordSkillAugment(Name S, bool bAlt, bool bBoth)
{
	local int i, j, k;
	local bool FlagWin;
	
	i = SkillAugmentArrayOf(S);
	if (i < 0) return false;
	if (bBoth)
	{
		j = SkillArrayOf(SkillAugmentSkillRequired[i]);
		k = SkillArrayOf(SecondarySkillAugmentSkillRequired[i]);
	}
	else if (!bAlt)
	{
		j = SkillArrayOf(SkillAugmentSkillRequired[i]);
	}
	else
	{
		j = SkillArrayOf(SecondarySkillAugmentSkillRequired[i]);
	}
	if (j < 0) return false;
	
	if (ProcessSkillAugmentCostException(S)) return true;
	
	//NOTE: Due to this structuring, the first skill listed as "required" will be the one that loses points.
	FlagWin = true;
	if (!bBoth)
	{
		if (SkillAugmentPointsLeft[j] - SkillAugmentPointsSpent[j] < SkillAugmentLevel[i]) FlagWin = false;
	}
	else
	{
		if (SkillAugmentPointsLeft[j] - SkillAugmentPointsSpent[j] < SkillAugmentLevel[i] / 2) FlagWin = false;
		if (SkillAugmentPointsLeft[k] - SkillAugmentPointsSpent[k] < SkillAugmentLevel[i] / 2) FlagWin = false;
	}
	
	return FlagWin;
}

function BuySkillAugment(Name S, optional bool bAlt, optional bool bBoth)
{
	local int i, j, k;
	
	i = SkillAugmentArrayOf(S);
	if (i < 0) return;
	if (bBoth)
	{
		j = SkillArrayOf(SkillAugmentSkillRequired[i]);
		k = SkillArrayOf(SecondarySkillAugmentSkillRequired[i]);
	}
	else if (!bAlt)
	{
		j = SkillArrayOf(SkillAugmentSkillRequired[i]);
	}
	else
	{
		j = SkillArrayOf(SecondarySkillAugmentSkillRequired[i]);
	}
	if (j < 0) return;
	
	//NOTE: Due to this structuring, the first skill listed as "required" will be the one that loses points.
	if (CanAffordSkillAugment(S, bAlt, bBoth))
	{
		if (!ProcessSkillAugmentCostException(S))
		{
			if (bBoth)
			{
				SkillAugmentPointsSpent[j] += SkillAugmentLevel[i] / 2;
				SkillAugmentPointsSpent[k] += SkillAugmentLevel[i] / 2;
			}
			else SkillAugmentPointsSpent[j] += SkillAugmentLevel[i];
		}
		UnlockSkillAugment(S);
		
		Player.SwimDuration = class'VMDStaticFunctions'.Static.GetPlayerSwimDuration(Player);
	}
}

//Respecs might be a thing one day? Who knows.
function LockSkillAugment(Name S)
{
 	local int i, j;
 	
 	for (i=0; i<ArrayCount(SkillAugmentIDs); i++)
 	{
  		if (SkillAugmentIDs[i] == S)
		{
			SkillAugmentAcquired[i] = 0;
		}
 	}
	
	if (VMDBufferPlayer(Player) != None)
	{
		VMDBufferPlayer(Player).VMDSignalSkillAugmentUpdate(S, true);
	}
}

function UnlockSkillAugment(Name S)
{
 	local int i;
 	
 	for (i=0; i<ArrayCount(SkillAugmentIDs); i++)
 	{
  		if (SkillAugmentIDs[i] == S) SkillAugmentAcquired[i] = 1;
 	}
	
	if (VMDBufferPlayer(Player) != None)
	{
		VMDBufferPlayer(Player).VMDSignalSkillAugmentUpdate(S, true);
	}
}

function AddSkillAugmentPoints(class<Skill> RefSkill, int AddAmount)
{
 	local int TArray;
 	
 	TArray = SkillArrayOf(RefSkill);
 	if (TArray > -1)
 	{
		//MADDERS: Specializations give 1 more initially, but make master give only 2.
		if ((AddAmount == 3) && (IsSpecializedIn(TArray-1)))
		{
			AddAmount = 2;
  		}
		SkillAugmentPointsLeft[TArray] += AddAmount;
 	}
}

function RemoveSkillAugmentPoints(class<Skill> RefSkill, int NewLevel)
{
 	local int TArray;
 	
 	TArray = SkillArrayOf(RefSkill);
 	if (TArray > -1)
 	{
		//MADDERS: Brute force this shit. This is only called in new game screens, anyways.
		switch(NewLevel)
		{
			case 0:
				if (IsSpecializedIn(TArray-1))
				{
					SkillAugmentPointsLeft[TArray] = 1;
  				}
				else
				{
					SkillAugmentPointsLeft[TArray] = 0;
				}
			break;
			case 1:
				if (IsSpecializedIn(TArray-1))
				{
					SkillAugmentPointsLeft[TArray] = 2;
  				}
				else
				{
					SkillAugmentPointsLeft[TArray] = 1;
				}
			break;
			case 2:
				if (IsSpecializedIn(TArray-1))
				{
					SkillAugmentPointsLeft[TArray] = 4;
  				}
				else
				{
					SkillAugmentPointsLeft[TArray] = 3;
				}
			break;
			case 3: //Posterity, ahoy!
				if (IsSpecializedIn(TArray-1))
				{
					SkillAugmentPointsLeft[TArray] = 6;
  				}
				else
				{
					SkillAugmentPointsLeft[TArray] = 6;
				}
			break;
		}
 	}
}

//MADDERS: Wipe these guys to a null value.
//NOTE: We don't use 0, because I don't trust it for travel vars.
//Unreal can be funky with non-null defaults on traveling actors.
function ResetSkillSpecializations()
{
	SkillSpecializations[0] = 0;
	SkillSpecializations[1] = 0;
}

function ResetSkillAugments()
{
 	local int i;
 	
 	for (i=0; i<ArrayCount(SkillAugmentAcquired); i++)
 	{
  		if (i < ArrayCount(SkillAugmentPointsLeft))
  		{
   			SkillAugmentPointsLeft[i] = 0;
			SkillAugmentPointsSpent[i] = 0;
  		}
  		SkillAugmentAcquired[i] = 0;
 	}
}

function ResetSkillAugmentsNewGame()
{
 	local int i;
 	
 	for (i=0; i<ArrayCount(SkillAugmentAcquired); i++)
 	{
  		if (i < ArrayCount(SkillAugmentPointsLeft))
  		{
   			//SkillAugmentPointsLeft[i] = 0;
			SkillAugmentPointsSpent[i] = 0;
  		}
  		SkillAugmentAcquired[i] = 0;
 	}
}

function bool VMDHasSkillAugmentObjection(VMDBufferPlayer VMP)
{
	if (IsBurden(VMP) || IsCassandra(VMP)) return true;
	
	return false;
}

function bool IsBurden(VMDBufferPlayer VMP)
{
	if ((VMP != None) && (VMP.DatalinkID ~= "Burden" || VMP.IsA('BurdenPeterKent')))
	{
		return true;
	}
	return false;
}

function bool IsCassandra(VMDBufferPlayer VMP)
{
	if ((VMP != None) && (VMP.DatalinkID ~= "Cassandra" || VMP.IsA('TCPPlayerCharolette')))
	{
		return true;
	}
	return false;
}

defaultproperties
{
     bHidden=True
     bTravel=True
     
     SkillAugmentPointClasses(0)=class'SkillWeaponPistol'
     SkillAugmentPointClasses(1)=class'SkillWeaponRifle'
     SkillAugmentPointClasses(2)=class'SkillDemolition'
     SkillAugmentPointClasses(3)=class'SkillWeaponHeavy'
     SkillAugmentPointClasses(4)=class'SkillWeaponLowTech'
     SkillAugmentPointClasses(5)=class'SkillLockpicking'
     SkillAugmentPointClasses(6)=class'SkillTech'
     SkillAugmentPointClasses(7)=class'SkillSwimming'
     SkillAugmentPointClasses(8)=class'SkillEnviro'
     SkillAugmentPointClasses(9)=class'SkillMedicine'
     SkillAugmentPointClasses(10)=class'SkillComputer'
     SkillAugmentPointClasses(11)=None
     SkillAugmentPointClasses(12)=None
     SkillAugmentPointClasses(13)=None
     SkillAugmentPointClasses(14)=None
     
     //MADDERS: SkillAugment vomit incoming! YIKES!
     //PISTOL
     //1.) Increased focus rate	(trained)
     SkillAugmentNames(0)="Pistol Focus"
     SkillAugmentDescs(0)="~Your pistol class focus rate bonuses are doubled, relative to skill level."
     SkillAugmentIDs(0)=PistolFocus
     SkillAugmentAssumed(0)=1
     SkillAugmentLevel(0)=1
     SkillAugmentLevelRequired(0)=1
     SkillAugmentRequired(0)=
     SkillAugmentSkillRequired(0)=class'SkillWeaponPistol'
     //2.) Ability to mod weapons (scope, laser >3 generic) (trained)
     SkillAugmentNames(1)="Pistol Modularity"
     SkillAugmentDescs(1)="~Pistol class weapons can be fitted with up to 5 of each standard mod, instead of only 3.|n~Custom mounted scopes give a bigger boost to accuracy for pistol class weapons.|n~Your lasers give a full benefit to accuracy for pistol class weapons."
     SkillAugmentIDs(1)=PistolModding
     SkillAugmentAssumed(1)=1
     SkillAugmentLevel(1)=1
     SkillAugmentLevelRequired(1)=1
     SkillAugmentRequired(1)=
     SkillAugmentSkillRequired(1)=class'SkillWeaponPistol'
     //3.) Reload speed applies to reload anims	(trained)
     SkillAugmentNames(2)="Gunslinger"
     SkillAugmentDescs(2)="~Reload speed bonuses partially apply to the start and end animations of pistol class weapons.|n~The reload speed of pistol class weapons is increased by 33%."
     SkillAugmentIDs(2)=PistolReload
     SkillAugmentAssumed(2)=0
     SkillAugmentLevel(2)=1
     SkillAugmentLevelRequired(2)=1
     SkillAugmentRequired(2)=
     SkillAugmentSkillRequired(2)=class'SkillWeaponPistol'
     //4.) No accuracy penalty for alt ammos (advanced)
     SkillAugmentNames(3)="Pistol Ballistics"
     SkillAugmentDescs(3)="~Alternate crossbow munitions shift from a slight debuff to a slight buff to accuracy.|n~Standard darts gain armor piercing, and flare darts gain the ability to ignite targets.|n~10mm gas caps gain double damage upon ricocheting from a surface.|n~10mm HEAP rounds gain 50% more blast radius."
     SkillAugmentIDs(3)=PistolAltAmmos
     SkillAugmentAssumed(3)=1
     SkillAugmentLevel(3)=2
     SkillAugmentLevelRequired(3)=2
     SkillAugmentRequired(3)=PistolFocus
     SkillAugmentSkillRequired(3)=class'SkillWeaponPistol'
     //5.) Increased scope bonus, no hipfire penalty (advanced)
     SkillAugmentNames(4)="Deadeye"
     SkillAugmentDescs(4)="~Scopes no longer penalize hipfire with pistol class weapons, and the aim benefit is increased.|n~Accurate range is increased by 35%, decreasing falloff at range, delaying bullet/projectile drop, and increasing projectile speed."
     SkillAugmentIDs(4)=PistolScope
     SkillAugmentAssumed(4)=0
     SkillAugmentLevel(4)=2
     SkillAugmentLevelRequired(4)=2
     SkillAugmentRequired(4)=PistolModding
     SkillAugmentSkillRequired(4)=class'SkillWeaponPistol'
     
     //RIFLE
     //1.) Increased focus rate	(trained)
     SkillAugmentNames(5)="Rifle Focus"
     SkillAugmentDescs(5)="~Your rifle class focus rate bonuses are doubled, relative to skill level."
     SkillAugmentIDs(5)=RifleFocus
     SkillAugmentAssumed(5)=1
     SkillAugmentLevel(5)=1
     SkillAugmentLevelRequired(5)=1
     SkillAugmentRequired(5)=
     SkillAugmentSkillRequired(5)=class'SkillWeaponRifle'
     //2.) Ability to mod weapons (scope, laser >2 generic) (trained)
     SkillAugmentNames(6)="Rifle Modularity"
     SkillAugmentDescs(6)="~Rifle class weapons can be fitted with up to 5 of each standard mod, instead of only 3.|n~Lasers give a full benefit to accuracy for rifle class weapons."
     SkillAugmentIDs(6)=RifleModding
     SkillAugmentAssumed(6)=1
     SkillAugmentLevel(6)=1
     SkillAugmentLevelRequired(6)=1
     SkillAugmentRequired(6)=
     SkillAugmentSkillRequired(6)=class'SkillWeaponRifle'
     //3.) Faster pump/bolt/GL operation (trained)
     SkillAugmentNames(7)="Follow-up Shot"
     SkillAugmentDescs(7)="~Rifle class weapons pump, rack, and load grenades faster between shots."
     SkillAugmentIDs(7)=RifleOperation
     SkillAugmentAssumed(7)=0
     SkillAugmentLevel(7)=1
     SkillAugmentLevelRequired(7)=1
     SkillAugmentRequired(7)=
     SkillAugmentSkillRequired(7)=class'SkillWeaponRifle'
     //4.) No accuracy penalty for alt ammos (advanced)
     SkillAugmentNames(8)="Rifle Ballistics"
	// HVAP gains 100% more penetration against humans and robots.
     SkillAugmentDescs(8)="~3006 HEAT and 20mm grenade rounds gain 50% more blast size.|n~Tranq rounds have their accuracy penalty reduced by 65%.|n~Shotgun slugs gain a considerable boost in accuracy.|n~Dragon's breath has more effective range.|n~Taser slugs have 35% more projectile speed."
     SkillAugmentIDs(8)=RifleAltAmmos
     SkillAugmentAssumed(8)=1
     SkillAugmentLevel(8)=2
     SkillAugmentLevelRequired(8)=2
     SkillAugmentRequired(8)=RifleFocus
     SkillAugmentSkillRequired(8)=class'SkillWeaponRifle'
     //5.) Reload speed applies to reload anims, 15% fast reload (advanced)
     SkillAugmentNames(9)="Lock 'n Load"
     SkillAugmentDescs(9)="~Reload speed bonuses partially apply to the start and end animations of rifle class weapons. Additionally, their reload speed bonuses are increased by 33%."
     SkillAugmentIDs(9)=RifleReload
     SkillAugmentAssumed(9)=0
     SkillAugmentLevel(9)=2
     SkillAugmentLevelRequired(9)=2
     SkillAugmentRequired(9)=RifleOperation
     SkillAugmentSkillRequired(9)=class'SkillWeaponRifle'
     
     //DEMOLITIONS
     //1.) No screen blur from tear gas	(trained)
     SkillAugmentNames(10)="Hard Boiled"
     SkillAugmentDescs(10)="~Sources of tear gas no longer impair visual clarity.|n~You can no longer be damaged by your own tear gas."
     SkillAugmentIDs(10)=DemolitionTearGas
     SkillAugmentAssumed(10)=0
     SkillAugmentLevel(10)=1
     SkillAugmentLevelRequired(10)=1
     SkillAugmentRequired(10)=
     SkillAugmentSkillRequired(10)=class'SkillDemolition'
     //2.) No EMP'ing self damage (trained)
     SkillAugmentNames(11)="Technical Glitch"
     SkillAugmentDescs(11)="~Your own EMP and scrambler grenades will no longer affect you."
     SkillAugmentIDs(11)=DemolitionEMP
     SkillAugmentAssumed(11)=0
     SkillAugmentLevel(11)=1
     SkillAugmentLevelRequired(11)=1
     SkillAugmentRequired(11)=
     SkillAugmentSkillRequired(11)=class'SkillDemolition'
     //3.) Ability to place mines (trained)
     SkillAugmentNames(12)="Fumble No More"
     SkillAugmentDescs(12)="~You can now emplace grenades upon surfaces 100% faster.|n~Grenades can be emplaced at any angle, instead of just upon walls."
     SkillAugmentIDs(12)=DemolitionMines
     SkillAugmentAssumed(12)=0
     SkillAugmentLevel(12)=1
     SkillAugmentLevelRequired(12)=1
     SkillAugmentRequired(12)=
     SkillAugmentSkillRequired(12)=class'SkillDemolition'
     //4.) Mines to detonate faster and are disarmed more easily.
     SkillAugmentNames(13)="Frequency Tuning"
     SkillAugmentDescs(13)="~The detection speed of your mines is boosted, scaling with skill level.|n~The detection speed of enemy mines is reduced by 66%, scaling with skill level.|n~Your mines become immune to Aggressive Defense System."
     SkillAugmentIDs(13)=DemolitionMineHandling
     SkillAugmentAssumed(13)=1
     SkillAugmentLevel(13)=1
     SkillAugmentLevelRequired(13)=1
     SkillAugmentRequired(13)=
     SkillAugmentSkillRequired(13)=class'SkillDemolition'
     //5.) Higher grenade capacity
     SkillAugmentNames(14)="Grenade Pouch"
     SkillAugmentDescs(14)="~Your grenade max capacity is increased from 5 units to 10."
     SkillAugmentIDs(14)=DemolitionGrenadeMaxAmmo
     SkillAugmentAssumed(14)=1
     SkillAugmentLevel(14)=1
     SkillAugmentLevelRequired(14)=1
     SkillAugmentRequired(14)=
     SkillAugmentSkillRequired(14)=class'SkillDemolition'
     //6.) Ability to loot grenades from corpses (advanced)
     SkillAugmentNames(15)="Carrion"
     SkillAugmentDescs(15)="~Corpses' tendencies to lay on their grenades no longer limits your grenade looting rates."
     SkillAugmentIDs(15)=DemolitionLooting
     SkillAugmentAssumed(15)=1
     SkillAugmentLevel(15)=2
     SkillAugmentLevelRequired(15)=2
     SkillAugmentRequired(15)=DemolitionGrenadeMaxAmmo
     SkillAugmentSkillRequired(15)=class'SkillDemolition'
     
     //HEAVY
     //1.) Increased focus rate (trained)
     SkillAugmentNames(16)="Heavy Focus"
     SkillAugmentDescs(16)="~Your heavy class focus rate bonuses are doubled, relative to skill level."
     SkillAugmentIDs(16)=HeavyFocus
     SkillAugmentAssumed(16)=1
     SkillAugmentLevel(16)=1
     SkillAugmentLevelRequired(16)=1
     SkillAugmentRequired(16)=
     SkillAugmentSkillRequired(16)=class'SkillWeaponHeavy'
     //2.) Reduced move speed penalty with heavy weapons [scaling] (trained)
     SkillAugmentNames(17)="Heavy Posture"
     SkillAugmentDescs(17)="~Heavy class weapons have decreased speed penalty, relative to skill level."
     SkillAugmentIDs(17)=HeavySpeed
     SkillAugmentAssumed(17)=1
     SkillAugmentLevel(17)=1
     SkillAugmentLevelRequired(17)=1
     SkillAugmentRequired(17)=
     SkillAugmentSkillRequired(17)=class'SkillWeaponHeavy'
     //3.) Ability to stop, drop, and roll (trained)
     SkillAugmentNames(18)="Stop, Drop..."
     SkillAugmentDescs(18)="~Ducking and strafing side to side can extinguish you if you're on fire.|n~Using fall or tactical rolls reduces your burn duration."
     SkillAugmentIDs(18)=HeavyDropAndRoll
     SkillAugmentAssumed(18)=1 //Keeping this for sim purposes
     SkillAugmentLevel(18)=1
     SkillAugmentLevelRequired(18)=1
     SkillAugmentRequired(18)=
     SkillAugmentSkillRequired(18)=class'SkillWeaponHeavy'
     //4.) Ability to stop, drop, and roll (trained)
     SkillAugmentNames(19)="Certified Arsonist"
     SkillAugmentDescs(19)="~Your incendiary weapons are able to spread the fun to other people they bump into, although at a reduced duration."
     SkillAugmentIDs(19)=HeavyFireSpread
     SkillAugmentAssumed(19)=0
     SkillAugmentLevel(19)=2
     SkillAugmentLevelRequired(19)=2
     SkillAugmentRequired(19)=HeavyDropAndRoll
     SkillAugmentSkillRequired(19)=class'SkillWeaponHeavy'
     //5.) Reduced plasma self splash (advanced)
     SkillAugmentNames(20)="Danger Close"
     SkillAugmentDescs(20)="~Your own plasma splashes back on you at 35% strength."
     SkillAugmentIDs(20)=HeavyPlasma
     SkillAugmentAssumed(20)=0
     SkillAugmentLevel(20)=2
     SkillAugmentLevelRequired(20)=2
     SkillAugmentRequired(20)=HeavyProjectileSpeed
     SkillAugmentSkillRequired(20)=class'SkillWeaponHeavy'
     //6.) Projectile Speed
     SkillAugmentNames(21)="Overclock"
     SkillAugmentDescs(21)="~Heavy projectile speeds are increased by 25%, greatly increasing hit reliability, especially when paired with range weapon mods."
     SkillAugmentIDs(21)=HeavyProjectileSpeed
     SkillAugmentAssumed(21)=1
     SkillAugmentLevel(21)=1
     SkillAugmentLevelRequired(21)=1
     SkillAugmentRequired(21)=
     SkillAugmentSkillRequired(21)=class'SkillWeaponHeavy'
     //7.) Heavy Swap Speed (advanced)
     SkillAugmentNames(22)="Show-off"
     SkillAugmentDescs(22)="~Holstering and drawing heavy weapons becomes 50% faster."
     SkillAugmentIDs(22)=HeavySwapSpeed
     SkillAugmentAssumed(22)=0
     SkillAugmentLevel(22)=2
     SkillAugmentLevelRequired(22)=2
     SkillAugmentRequired(22)=HeavySpeed
     SkillAugmentSkillRequired(22)=class'SkillWeaponHeavy'
     
     //MELEE
     //1.) Retrieve projectiles from corpses (trained)
     SkillAugmentNames(23)="Dislodge"
     SkillAugmentDescs(23)="~Darts and throwing knives can be retrieved from enemy corpses successfully.|n*Each projectile type has a unique chance to succeed.|n~Throwing speed for grenades and throwing knives is increased by 5%/15%/30%/50%, depending on skill level."
     SkillAugmentIDs(23)=MeleeProjectileLooting
     SkillAugmentAssumed(23)=1 //Keeping this for sim purposes
     SkillAugmentLevel(23)=1
     SkillAugmentLevelRequired(23)=1
     SkillAugmentRequired(23)=
     SkillAugmentSkillRequired(23)=class'SkillWeaponLowTech'
     //2.) Headshots with baton (trained)
     SkillAugmentNames(24)="Silent Takedown"
     SkillAugmentDescs(24)="~Batons and hits from gas caps are now capable of making effective, nonlethal headshots."
     SkillAugmentIDs(24)=MeleeBatonHeadshots
     SkillAugmentAssumed(24)=0
     SkillAugmentLevel(24)=1
     SkillAugmentLevelRequired(24)=1
     SkillAugmentRequired(24)=
     SkillAugmentSkillRequired(24)=class'SkillWeaponLowTech'
     //3.) No longer cross-class. Crowbars can defeat 15% or less soft locks.
     SkillAugmentNames(25)="Soft Spot"
     SkillAugmentDescs(25)="~Hitting a breakable wood or glass door with <= 15% lockstrength using a crowbar will break its lock integrity."
     SkillAugmentIDs(25)=MeleeDoorCrackingWood
     SkillAugmentAssumed(25)=1 //Keeping for crowbar utility
     SkillAugmentLevel(25)=1
     SkillAugmentLevelRequired(25)=1
     SkillAugmentRequired(25)=
     SkillAugmentSkillRequired(25)=class'SkillWeaponLowTech'
     //4.) Swing speed enhanced with melee (+30%) (advanced)
     SkillAugmentNames(26)="Melee Rhythm"
     SkillAugmentDescs(26)="~The swing speed of melee weapons is enhanced by 30-40%."
     SkillAugmentIDs(26)=MeleeSwingSpeed
     SkillAugmentAssumed(26)=0
     SkillAugmentLevel(26)=2
     SkillAugmentLevelRequired(26)=2
     SkillAugmentRequired(26)=
     SkillAugmentSkillRequired(26)=class'SkillWeaponLowTech'
     //5.) Taser & tear gas longer stun duration (advanced)
     SkillAugmentNames(27)="Low Blow"
     SkillAugmentDescs(27)="~Tasers and stunning aerosols have doubled effect duration."
     SkillAugmentIDs(27)=MeleeStunDuration
     SkillAugmentAssumed(27)=0
     SkillAugmentLevel(27)=1
     SkillAugmentLevelRequired(27)=2
     SkillAugmentRequired(27)=MeleeBatonHeadshots
     SkillAugmentSkillRequired(27)=class'SkillWeaponLowTech'
     //5.) Fast kills = no noise. Don't know why this took me so long.
     SkillAugmentNames(28)="True Assailant"
     SkillAugmentDescs(28)="~Any form of takedown on a human enemy, so long as it is performed quickly, will produce no audible noise to nearby persons."
     SkillAugmentIDs(28)=MeleeAssassin
     SkillAugmentAssumed(28)=0
     SkillAugmentLevel(28)=2
     SkillAugmentLevelRequired(28)=2
     SkillAugmentRequired(28)=MeleeBatonHeadshots
     SkillAugmentSkillRequired(28)=class'SkillWeaponLowTech'
     
     //LOCKPICKING
     //1.) Being detected by enemies is visually indicated.
     SkillAugmentNames(29)="Keen Instincts"
     SkillAugmentDescs(29)="~When an enemy detects or partially detects you, regardless of distance, your light gem will highlight pink on the relevant side."
     SkillAugmentIDs(29)=LockpickStealthBar
     SkillAugmentAssumed(29)=0
     SkillAugmentLevel(29)=1
     SkillAugmentLevelRequired(29)=1
     SkillAugmentRequired(29)=
     SkillAugmentSkillRequired(29)=class'SkillLockpicking'
     //2.) Pick pockets (no UI, no failure) (trained)
     SkillAugmentNames(30)="Pickpocket"
     SkillAugmentDescs(30)="~Ducking and pressing the 'use' button, while facing the rear end of a low priority human character with empty hands, will fish a random item from their pockets.|n~The pickpocket cooldown is 1 second. This cooldown is reduced by 25% per level of infiltration.|n*Remember not to get caught."
     SkillAugmentIDs(30)=LockpickPickpocket
     SkillAugmentAssumed(30)=1 //Keeping this for sim purposes
     SkillAugmentLevel(30)=1
     SkillAugmentLevelRequired(30)=1
     SkillAugmentRequired(30)=
     SkillAugmentSkillRequired(30)=class'SkillLockpicking'
     //3.) Increased food and blood threshold before generating smell 	(trained)
     SkillAugmentNames(31)="Cover-up"
     SkillAugmentDescs(31)="~The threshold for food smell is increased by approximately 15%.|n~The threshold for smoke and blood scents are increased by 25%.|n~These bonuses is increased by another 15/25%, additive, per each level of Infiltration skill."
     SkillAugmentIDs(31)=LockpickScent
     SkillAugmentAssumed(31)=0
     SkillAugmentLevel(31)=1
     SkillAugmentLevelRequired(31)=1
     SkillAugmentRequired(31)=
     SkillAugmentSkillRequired(31)=class'SkillLockpicking'
     //4.) Lockpicking does not emit alert until broken	(advanced)
     SkillAugmentNames(32)="Sleight of Hand"
     SkillAugmentDescs(32)="~Scouting soft material doors' locks no longer generates noise.|n~Initiating lockpicking no longer draws outside attention.|n~The durability of all doors is automatically known."
     SkillAugmentIDs(32)=LockpickStartStealth
     SkillAugmentAssumed(32)=0
     SkillAugmentLevel(32)=2
     SkillAugmentLevelRequired(32)=2
     SkillAugmentRequired(32)=
     SkillAugmentSkillRequired(32)=class'SkillLockpicking'
     
     //HACKING!
     //1.) Hack failure does not produce noise (trained)
     SkillAugmentNames(33)="Silent Mode"
     SkillAugmentDescs(33)="Report this as a bug. This talent has been removed."
     SkillAugmentIDs(33)=ElectronicsFailNoise
     SkillAugmentAssumed(33)=0
     SkillAugmentLevel(33)=1
     SkillAugmentLevelRequired(33)=1
     SkillAugmentRequired(33)=
     SkillAugmentSkillRequired(33)=class'SkillTech'
     //2.) Faster hack timeline	(trained)
     SkillAugmentNames(34)="Speed Dial"
     SkillAugmentDescs(34)="~All electronic bypassing progresses 66% faster, although it is no more efficient in output.|n~Failed rush attempts now produce far less noise, scaling with skill level."
     SkillAugmentIDs(34)=ElectronicsSpeed
     SkillAugmentAssumed(34)=0
     SkillAugmentLevel(34)=2
     SkillAugmentLevelRequired(34)=2
     SkillAugmentRequired(34)=
     SkillAugmentSkillRequired(34)=class'SkillTech'
     //3.) Better potency with multitools
     //MADDERS, 8/10/23: Break this into 2 points, instead of 1. That way it has more flexibility, and it doesn't downgrade trained level for people genuinely want hacking.
     SkillAugmentNames(35)="Data Analyst"
     SkillAugmentDescs(35)="~Your electronic bypassing potency is 50% stronger, relative to skill level."
     SkillAugmentIDs(35)=ElectronicsHackingPotency1
     SkillAugmentAssumed(35)=1
     SkillAugmentLevel(35)=1
     SkillAugmentLevelRequired(35)=1
     SkillAugmentRequired(35)=
     SkillAugmentSkillRequired(35)=class'SkillTech'
     //4.) Better potency with multitools
     //MADDERS, 7/24/23: Overhaul this. It now scales our hacking strength in general.
     SkillAugmentNames(36)="Wave Surfer"
     SkillAugmentDescs(36)="~Your electronic bypassing potency is 100% stronger, relative to skill level.|n*Overrides Data Analyst"
     SkillAugmentIDs(36)=ElectronicsHackingPotency2
     SkillAugmentAssumed(36)=0 //Too OP I find.
     SkillAugmentLevel(36)=1
     SkillAugmentLevelRequired(36)=1
     SkillAugmentRequired(36)=ElectronicsHackingPotency1
     SkillAugmentSkillRequired(36)=class'SkillTech'
     //5.) Hacked turrets change alliance (master)
     SkillAugmentNames(37)="IFF Override"
     SkillAugmentDescs(37)="~Turrets bypassed via multitool will attack hostiles instead of being deactivated."
     SkillAugmentIDs(37)=ElectronicsTurrets
     SkillAugmentAssumed(37)=0
     SkillAugmentLevel(37)=2
     SkillAugmentLevelRequired(37)=2
     SkillAugmentRequired(37)=
     SkillAugmentSkillRequired(37)=class'SkillTech'
     //6.) Helidrone crafting, to distract us from the otherwise bare state of electronics. RIP.
     SkillAugmentNames(38)="M.E.G.H."
     SkillAugmentDescs(38)="~You can craft the Modular Electric General-Use Helidrone, or MEGH. It is a small, flying bot.|n*You may only own one helidrone at a time, and it may only handle small stature weapons, excluding the prod."
     SkillAugmentIDs(38)=ElectronicsDrones
     SkillAugmentAssumed(38)=1 //Costs materials, right?
     SkillAugmentLevel(38)=1
     SkillAugmentLevelRequired(38)=1
     SkillAugmentRequired(38)=
     SkillAugmentSkillRequired(38)=class'SkillTech'
     //7.) Helidrone armor, but at more cost.
     SkillAugmentNames(39)="Reinforced Plating"
     SkillAugmentDescs(39)="~The price of crafting MEGH is increased by 50%.|n~Its overall health is increased by 200%.|n~It gains bonus protection against AOE damage.|n*This upgrade is applied to existing drones automatically."
     SkillAugmentIDs(39)=ElectronicsDroneArmor
     SkillAugmentAssumed(39)=0
     SkillAugmentLevel(39)=1
     SkillAugmentLevelRequired(39)=1
     SkillAugmentRequired(39)=ElectronicsDrones
     SkillAugmentSkillRequired(39)=class'SkillTech'
     //8.) Doubled crafting efficiency.
     SkillAugmentNames(40)="Elbow Grease"
     SkillAugmentDescs(40)="~Relative to skill level, your mechanical crafting efficiency bonus is significantly improved.|n*This bonus also benefits your MEGH and SIDD repair costs."
     SkillAugmentIDs(40)=ElectronicsCrafting
     SkillAugmentAssumed(40)=0
     SkillAugmentLevel(40)=2
     SkillAugmentLevelRequired(40)=2
     SkillAugmentRequired(40)=
     SkillAugmentSkillRequired(40)=class'SkillTech'
     
     //SWIMMING
     //1.) Enhanced breath regen rate (trained)
     SkillAugmentNames(41)="Aquadynamic"
     SkillAugmentDescs(41)="~Swim speed bonuses gain 150% value, relative to skill level.|n~Your breath recovers 4x faster out of water.|n~You take 40% less drowning damage per tick."
     SkillAugmentIDs(41)=SwimmingBreathRegen
     SkillAugmentAssumed(41)=1 //Approved to make swimming usable without talents.
     SkillAugmentLevel(41)=1
     SkillAugmentLevelRequired(41)=1
     SkillAugmentRequired(41)=
     SkillAugmentSkillRequired(41)=class'SkillSwimming'
     //2.) Ability to roll to break falls (trained)
     SkillAugmentNames(42)="Fall Roll"
     SkillAugmentDescs(42)="~If moving straight forward with sufficient speed, holding duck while receiving a hard fall will heavily reduce fall damage by transitioning into a roll.|n*This can only be performed once per every 10 seconds|n*You need at least 1 health in both legs for any type of roll."
     SkillAugmentIDs(42)=SwimmingFallRoll
     SkillAugmentAssumed(42)=1 //Keeping this for sim purposes
     SkillAugmentLevel(42)=1
     SkillAugmentLevelRequired(42)=1
     SkillAugmentRequired(42)=
     SkillAugmentSkillRequired(42)=class'SkillSwimming'
     //3.) Ability to roll freely (advanced)
     SkillAugmentNames(43)="Tactical Roll"
     SkillAugmentDescs(43)="~Pressing space quickly after pressing duck lets you perform a sneaky roll.|n*This roll shares a cooldown with fall roll, at 10 seconds."
     SkillAugmentIDs(43)=SwimmingRoll
     SkillAugmentAssumed(43)=0 //This used to be free, but it's overpowered when combined with jump-duck which is free for QOL reasons.
     SkillAugmentLevel(43)=2
     SkillAugmentLevelRequired(43)=2
     SkillAugmentRequired(43)=SwimmingFallRoll
     SkillAugmentSkillRequired(43)=class'SkillSwimming'
     //4.) Reduced drowning damage rate (advanced)
     SkillAugmentNames(44)="Deep, Steady"
     SkillAugmentDescs(44)="~Underwater breath duration bonuses gain 150% value, relative to skill level.|n~All drowning damage taken occurs 4 seconds apart instead of 2.|n~Taking damage does not reduce oxygen left while in bodies of water.|n~All speed penalties for using equipment underwater are negated.|n~Medkit healing is not impaired underwater.|n~You gain 15% accuracy while in water."
     SkillAugmentIDs(44)=SwimmingDrowningRate
     SkillAugmentAssumed(44)=0
     SkillAugmentLevel(44)=2
     SkillAugmentLevelRequired(44)=2
     SkillAugmentRequired(44)=SwimmingBreathRegen
     SkillAugmentSkillRequired(44)=class'SkillSwimming'
     //5.) Bundle of various improvements
     SkillAugmentNames(45)="Fit as a Fiddle"
     SkillAugmentDescs(45)="~Your rolling cooldown is reduced by 25%.|n~You can duck while jumping.|n~Most types of damage taken while rolling is halved."
     SkillAugmentIDs(45)=SwimmingFitness
     SkillAugmentAssumed(45)=1 //Keeping this for the sake of QOL.
     SkillAugmentLevel(45)=2
     SkillAugmentLevelRequired(45)=2
     SkillAugmentRequired(45)=
     SkillAugmentSkillRequired(45)=class'SkillSwimming'
     
     //ENVIRO
     //1.) Ability to de-activate pickups (trained)
     SkillAugmentNames(46)="Off Switch"
     SkillAugmentDescs(46)="~A quicker yank on the power cord lets you deactivate wearable items more safely, costing 15% potential max charge, instead of a whopping 50%."
     SkillAugmentIDs(46)=EnviroDeactivate
     SkillAugmentAssumed(46)=1 //Keeping this for sim purposes
     SkillAugmentLevel(46)=1
     SkillAugmentLevelRequired(46)=1
     SkillAugmentRequired(46)=
     SkillAugmentSkillRequired(46)=class'SkillEnviro'
     //2.) Ability to carry multiple of one pickup type (trained)
     SkillAugmentNames(47)="Insulation"
     SkillAugmentDescs(47)="~Carrying multiple copies of wearable gear is now possible, with 2 per stack."
     SkillAugmentIDs(47)=EnviroCopies
     SkillAugmentAssumed(47)=1 //Keeping this because it's vanilla
     SkillAugmentLevel(47)=1
     SkillAugmentLevelRequired(47)=1
     SkillAugmentRequired(47)=
     SkillAugmentSkillRequired(47)=class'SkillEnviro'
     //3.) Ability to stack carried pickup types (advanced)
     SkillAugmentNames(48)="Advanced Insulation"
     SkillAugmentDescs(48)="~You may now store up to 3 of a particular type of wearable gear."
     SkillAugmentIDs(48)=EnviroCopyStacks
     SkillAugmentAssumed(48)=0
     SkillAugmentLevel(48)=2
     SkillAugmentLevelRequired(48)=2
     SkillAugmentRequired(48)=EnviroCopies
     SkillAugmentSkillRequired(48)=class'SkillEnviro'
     //4.) Pickup regen while held in hand and inactive (master)
     SkillAugmentNames(49)="Fasten Up"
     SkillAugmentDescs(49)="~Wearable items suffer decreased degradation from incoming damage by 25%, such as bullets hitting ballistic vests.|n~EMP damage is 50% less degrading to your active tactical gear.|n~You can wear otherwise conflicting pieces of tactical gear at the same time."
     SkillAugmentIDs(49)=EnviroDurability
     SkillAugmentAssumed(49)=0
     SkillAugmentLevel(49)=2
     SkillAugmentLevelRequired(49)=2
     SkillAugmentRequired(49)=EnviroDeactivate
     SkillAugmentSkillRequired(49)=class'SkillEnviro'
     //5.) Can remove charged pickups from enemies.
     SkillAugmentNames(50)="Gentle Touch"
     SkillAugmentDescs(50)="~You can now remove tactical gear from fallen enemies with 2x efficiency.|n~If you know how to pickpocket, you can now pickpocket tactical gear that is at full condition."
     SkillAugmentIDs(50)=EnviroLooting
     SkillAugmentAssumed(50)=1
     SkillAugmentLevel(50)=2
     SkillAugmentLevelRequired(50)=2
     SkillAugmentRequired(50)=
     SkillAugmentSkillRequired(50)=class'SkillEnviro'
     
     //MEDICINE
     //1.) Using a medkit restores stress instead of costing stress (trained)
     SkillAugmentNames(51)="Pharmacist"
     SkillAugmentDescs(51)="~Using a medkit grants a 50% reduction in damage taken from poison ticks, overdosing, and inhalated toxins for 10 seconds.|n~Using medkits halves the screen blur effects of drugs and poisons.|n~Medkits heal for 5 extra points."
     SkillAugmentIDs(51)=MedicineStress
     SkillAugmentAssumed(51)=0 //No longer kept, because it is the fucking stronk.
     SkillAugmentLevel(51)=1
     SkillAugmentLevelRequired(51)=1
     SkillAugmentRequired(51)=
     SkillAugmentSkillRequired(51)=class'SkillMedicine'
     //2.) Excess healing to a limb wraps around to other body parts (trained)
     SkillAugmentNames(52)="Trained Professional"
     SkillAugmentDescs(52)="~When healing a specific region, any excess healing wraps around to other areas via standard healing order.|n~Excess medbot charge is not wasted.|n~Activating a biocell in-game (while aiming at a medbot in range) will add 75 points to the medbot's remaining healing.|n~Medkits heal for 15 extra points."
     SkillAugmentIDs(52)=MedicineWraparound
     SkillAugmentAssumed(52)=1 //Keep this for QOL purposes
     SkillAugmentLevel(52)=2
     SkillAugmentLevelRequired(52)=2
     SkillAugmentRequired(52)=
     SkillAugmentSkillRequired(52)=class'SkillMedicine'
     //3.) Medkit carrying capacity is increased (+5) (advanced)
     SkillAugmentNames(53)="Walking Closet"
     SkillAugmentDescs(53)="~Medkit capacity is increased by 5 units."
     SkillAugmentIDs(53)=MedicineCapacity
     SkillAugmentAssumed(53)=1 //Nerfed until we spec into medicine, but without skill augments, just make it free.
     SkillAugmentLevel(53)=2
     SkillAugmentLevelRequired(53)=2
     SkillAugmentRequired(53)=
     SkillAugmentSkillRequired(53)=class'SkillMedicine'
     //4.) Fatal bullet/melee damage will expend 3 medkits once per 2 minutes, instead of dying. Healing is not applied. (master)
     SkillAugmentNames(54)="Vital Coverage"
     SkillAugmentDescs(54)="~Once per 2 minutes, fatal damage will be negated at the cost of 3 medkits.|n*This effect only activates when you have more than 15 medkits.|n~Your medkit capacity is increased by another 3 units."
     SkillAugmentIDs(54)=MedicineRevive
     SkillAugmentAssumed(54)=0
     SkillAugmentLevel(54)=1
     SkillAugmentLevelRequired(54)=3
     SkillAugmentRequired(54)=MedicineCapacity
     SkillAugmentSkillRequired(54)=class'SkillMedicine'
     //5.) More efficiency for medicinal crafting. This is, controversially, not cross class.
     SkillAugmentNames(55)="PHD in Chemistry"
     SkillAugmentDescs(55)="~Relative to skill level, your chemical crafting efficiency bonus is significantly improved."
     SkillAugmentIDs(55)=MedicineCrafting
     SkillAugmentAssumed(55)=0
     SkillAugmentLevel(55)=2
     SkillAugmentLevelRequired(55)=2
     SkillAugmentRequired(55)=
     SkillAugmentSkillRequired(55)=class'SkillMedicine'
     //6.) Drugs, baby, drugs.
     SkillAugmentNames(56)="Compound 23"
     SkillAugmentDescs(56)="~With a little organic chemistry, combat stimulants can now be crafted, although you'll need substantial workspace to do so.|n*When used, they provide a substantial boost to melee and movement speeds, among other things."
     SkillAugmentIDs(56)=MedicineCombatDrugs
     SkillAugmentAssumed(56)=1
     SkillAugmentLevel(56)=1
     SkillAugmentLevelRequired(56)=1
     SkillAugmentRequired(56)=
     SkillAugmentSkillRequired(56)=class'SkillMedicine'
     
     //COMPUTERS
     //1.) Time until hacking detected is extended with level (trained)
     SkillAugmentNames(57)="Wiz Kid"
     SkillAugmentDescs(57)="~Your actions during hacking have reduced detection time impact, scaling with skill level.|n~You may download emails from hacked computers for reading later.|n*This action has no time cost."
     SkillAugmentIDs(57)=ComputerScaling
     SkillAugmentAssumed(57)=1 //Keeping because it's necessary
     SkillAugmentLevel(57)=1
     SkillAugmentLevelRequired(57)=1
     SkillAugmentRequired(57)=
     SkillAugmentSkillRequired(57)=class'SkillComputer'
     //2.) Turrets can be set to target only hostiles, vs just everything (trained)
     SkillAugmentNames(58)="IFF Programing"
     SkillAugmentDescs(58)="~Instead of merely disabling IFF on turrets, you can now patch the value to attack new targets, saving ammo and time."
     SkillAugmentIDs(58)=ComputerTurrets
     SkillAugmentAssumed(58)=1 //Keeping because it's vanilla
     SkillAugmentLevel(58)=2
     SkillAugmentLevelRequired(58)=2
     SkillAugmentRequired(58)=
     SkillAugmentSkillRequired(58)=class'SkillComputer'
     //3.) Hacked computers can have special options used (trained)
     SkillAugmentNames(59)="Deep Fake"
     SkillAugmentDescs(59)="~Your artificial credentials can switch on special options within computers, such as hidden doors or power controls, with zero time cost.|n~Computers' alarm durations are reduced by 50%.|n~Your hacking cooldown is reduced by 35%."
     SkillAugmentIDs(59)=ComputerSpecialOptions
     SkillAugmentAssumed(59)=1 //Keeping because it's vanilla
     SkillAugmentLevel(59)=1
     SkillAugmentLevelRequired(59)=1
     SkillAugmentRequired(59)=
     SkillAugmentSkillRequired(59)=class'SkillComputer'
     //4.) ATMs target the best possible account when hacked (advanced)
     SkillAugmentNames(60)="Check Sum"
     SkillAugmentDescs(60)="~Your familiarity with data structures lets you extract the best possible sum from ATMs, granting 2x the cash extraction, relative to skill level."
     SkillAugmentIDs(60)=ComputerATMQuality
     SkillAugmentAssumed(60)=1 //Keeping because it's vanilla
     SkillAugmentLevel(60)=2
     SkillAugmentLevelRequired(60)=2
     SkillAugmentRequired(60)=
     SkillAugmentSkillRequired(60)=class'SkillComputer'
     //5.) Computer lockout doesn't eject, doesn't sound alarm, costs bio (master)
     SkillAugmentNames(61)="Digital Phantom"
     SkillAugmentDescs(61)="~Your hacking duration length is extended virtually indefinitely, to 300 units of time."
     SkillAugmentIDs(61)=ComputerLockout
     SkillAugmentAssumed(61)=0
     SkillAugmentLevel(61)=3
     SkillAugmentLevelRequired(61)=3
     SkillAugmentRequired(61)=ComputerScaling
     SkillAugmentSkillRequired(61)=class'SkillComputer'
     
     //ENVIRO/PISTOL HYBRID!
     //1.) Ability to hide small arms from view (advanced)
     SkillAugmentNames(62)="Low Profile"
     SkillAugmentDescs(62)="~Small stature weapons can be palmed, making them unseen to prying authorities.|n~Small stature weapons are drawn and holstered 50% faster.|n*This criteria includes grenades, all pistol class weapons, combat knives, batons, and the sawed off shotgun."
     SkillAugmentIDs(62)=TagTeamSmallWeapons
     SkillAugmentAssumed(62)=0
     SkillAugmentLevel(62)=1
     SkillAugmentLevelRequired(62)=1
     SkillAugmentRequired(62)=
     SkillAugmentSkillRequired(62)=class'SkillEnviro'
     SecondarySkillAugmentLevelRequired(62)=1
     SecondarySkillAugmentRequired(62)=
     SecondarySkillAugmentSkillRequired(62)=class'SkillWeaponPistol'
     
     //PISTOL/RIFLE HYBRID!
     //1.) Open system no longer needs cleaning
     SkillAugmentNames(63)="Big Kick Magnum"
     SkillAugmentDescs(63)="~The rate at which your accuracy decays when shooting 'robust' style guns is decreased by 25%.|n*Muzzle flip itself is not reduced."
     SkillAugmentIDs(63)=TagTeamOpenDecayRate //TagTeamOpenGrimeproof
     SkillAugmentAssumed(63)=0
     SkillAugmentLevel(63)=1
     SkillAugmentLevelRequired(63)=1
     SkillAugmentRequired(63)=
     SkillAugmentSkillRequired(63)=class'SkillWeaponRifle'
     SecondarySkillAugmentLevelRequired(63)=1
     SecondarySkillAugmentRequired(63)=
     SecondarySkillAugmentSkillRequired(63)=class'SkillWeaponPistol'
     //2.) Closed system works underwater
     SkillAugmentNames(64)="'Wet' Operations"
     SkillAugmentDescs(64)="~With a little fine tuning, your 'intricate' style guns can operate IN and shortly after BEING in water."
     SkillAugmentIDs(64)=TagTeamClosedWaterproof
     SkillAugmentAssumed(64)=0
     SkillAugmentLevel(64)=1
     SkillAugmentLevelRequired(64)=1
     SkillAugmentRequired(64)=
     SkillAugmentSkillRequired(64)=class'SkillWeaponPistol'
     SecondarySkillAugmentLevelRequired(64)=1
     SecondarySkillAugmentRequired(64)=
     SecondarySkillAugmentSkillRequired(64)=class'SkillWeaponRifle'
     //3.) Open system gets +1 to cap, and +1 to ammo looted
     SkillAugmentNames(65)="Chamber: Check."
     SkillAugmentDescs(65)="~In addition to a +1 capacity with all 'robust' style guns.|n~You loot 'robust' weapons for 1 more round of ammo."
     SkillAugmentIDs(65)=TagTeamOpenChamber
     SkillAugmentAssumed(65)=0
     SkillAugmentLevel(65)=1
     SkillAugmentLevelRequired(65)=2
     SkillAugmentRequired(65)=TagTeamOpenDecayRate
     SkillAugmentSkillRequired(65)=class'SkillWeaponRifle'
     SecondarySkillAugmentLevelRequired(65)=1
     SecondarySkillAugmentRequired(65)=
     SecondarySkillAugmentSkillRequired(65)=class'SkillWeaponPistol'
     //4.) Closed system gains 20% bonus headshot damage
     SkillAugmentNames(66)="Pressurize"
     SkillAugmentDescs(66)="~Your 'intricate' style weapons deal 25% more headshot damage."
     SkillAugmentIDs(66)=TagTeamClosedHeadshot
     SkillAugmentAssumed(66)=0
     SkillAugmentLevel(66)=1
     SkillAugmentLevelRequired(66)=2
     SkillAugmentRequired(66)=TagTeamClosedWaterproof
     SkillAugmentSkillRequired(66)=class'SkillWeaponPistol'
     SecondarySkillAugmentLevelRequired(66)=1
     SecondarySkillAugmentRequired(66)=
     SecondarySkillAugmentSkillRequired(66)=class'SkillWeaponRifle'
     
     //MELEE/LOCKPICKING HYBRID!
     //1.) Break <= 15% locks w/ crowbar
     SkillAugmentNames(67)="Brute Force"
     SkillAugmentDescs(67)="~Any type of door below 5/10/15/20% lock strength can be broken with a crowbar, depending on low tech and infiltration skill level (whichever is higher).|n~Wood and glass doors maintain a minimum threshold of 15%."
     SkillAugmentIDs(67)=TagTeamDoorCrackingMetal
     SkillAugmentAssumed(67)=0 //This is NOT, for being overpowered
     SkillAugmentLevel(67)=1
     SkillAugmentLevelRequired(67)=1
     SkillAugmentRequired(67)=MeleeDoorCrackingWood
     SkillAugmentSkillRequired(67)=class'SkillWeaponLowTech'
     SecondarySkillAugmentLevelRequired(67)=1
     SecondarySkillAugmentRequired(67)=
     SecondarySkillAugmentSkillRequired(67)=class'SkillLockpicking'
     
     //PISTOL/ELECTRONICS HYBRID!
     //1.) Build a mini-turret. (advanced)
     SkillAugmentNames(68)="S.I.D.D."
     SkillAugmentDescs(68)="~You can craft a Static Improvised Defense Device, or SIDD. It is a small turret that uses 7.62 ammo.|n~You can now tweak friendly, full-size autoturrets' rate of fire, range, and turn rates, as well as restock their 7.62 ammo."
     SkillAugmentIDs(68)=TagTeamMiniTurret
     SkillAugmentAssumed(68)=1
     SkillAugmentLevel(68)=2
     SkillAugmentLevelRequired(68)=1
     SkillAugmentRequired(68)=ElectronicsDrones
     SkillAugmentSkillRequired(68)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(68)=1
     SecondarySkillAugmentRequired(68)=
     SecondarySkillAugmentSkillRequired(68)=class'SkillWeaponPistol'
     
     //LOCKPICKING/ELECTRONICS HYBRID!
     //1.) Lockpick/multitool max count increased (+5) (advanced)
     SkillAugmentNames(69)="Invader's Kit"
     SkillAugmentDescs(69)="~Both your lockpick and multitool capacities are doubled, increasing them by 10 units each."
     SkillAugmentIDs(69)=TagTeamInvaderCapacity
     SkillAugmentAssumed(69)=0
     SkillAugmentLevel(69)=2
     SkillAugmentLevelRequired(69)=1
     SkillAugmentRequired(69)=
     SkillAugmentSkillRequired(69)=class'SkillLockpicking'
     SecondarySkillAugmentLevelRequired(69)=1
     SecondarySkillAugmentRequired(69)=
     SecondarySkillAugmentSkillRequired(69)=class'SkillTech'
     
     //DEMOLITIONS/ELECTRONICS HYBRID!
     //1.) Scrambler grenades don't wear off (master)
     SkillAugmentNames(70)="Mega Hertz"
     SkillAugmentDescs(70)="~The disorienting effects of scrambler grenades now stick around almost indefinitely.|n~EMP grenades deal permanent damage to cameras, turrets, control panels, and lasers, potentially rendering them useless."
     SkillAugmentIDs(70)=TagTeamScrambler
     SkillAugmentAssumed(70)=0
     SkillAugmentLevel(70)=2
     SkillAugmentLevelRequired(70)=1
     SkillAugmentRequired(70)=DemolitionEMP
     SkillAugmentSkillRequired(70)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(70)=2
     SecondarySkillAugmentRequired(70)=
     SecondarySkillAugmentSkillRequired(70)=class'SkillDemolition'
     
     //MEDICINE/ELECTRONICS HYBRID!
     //1.) Can craft med gel, and use it with bots.
     SkillAugmentNames(71)="Medigel Treatment"
     SkillAugmentDescs(71)="~For less than the price of a medkit, you can craft syringes of 'Ritegel' medical foam, which heals for 60 health over 4 seconds.|n~It is immediately compatible with the MEGH drone."
     SkillAugmentIDs(71)=TagTeamMedicalSyringe
     SkillAugmentAssumed(71)=0
     SkillAugmentLevel(71)=1
     SkillAugmentLevelRequired(71)=1
     SkillAugmentRequired(71)=
     SkillAugmentSkillRequired(71)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(71)=1
     SecondarySkillAugmentRequired(71)=
     SecondarySkillAugmentSkillRequired(71)=class'SkillMedicine'
     
     //COMPUTERS/ELECTRONICS HYBRID!
     //1.) Software buff for turret and drone.
     SkillAugmentNames(72)="Experimental Skillware"
     SkillAugmentDescs(72)="~MEGH and SIDD drones both gain a 12.5% increase in accuracy.|n~MEGH gains a 20% increase in movement speed.|n~SIDD gains a 400% faster spinup rate."
     SkillAugmentIDs(72)=TagTeamSkillware
     SkillAugmentAssumed(72)=0
     SkillAugmentLevel(72)=2
     SkillAugmentLevelRequired(72)=2
     SkillAugmentRequired(72)=ElectronicsDrones
     SkillAugmentSkillRequired(72)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(72)=1
     SecondarySkillAugmentRequired(72)=
     SecondarySkillAugmentSkillRequired(72)=class'SkillComputer'
     //2.) Drone can do a mini-hack on security consoles.
     SkillAugmentNames(73)="Illegal Modules"
     SkillAugmentDescs(73)="~MEGH gains an auto-reload option, to minimize micromanagement.|n~MEGH gains access to 'litehack' software, and can hack into a security console.|n*MEGH will stay behind, and keep all cameras and turrets on the grid suppressed until assigned to another task."
     SkillAugmentIDs(73)=TagTeamLitehack
     SkillAugmentAssumed(73)=0
     SkillAugmentLevel(73)=1
     SkillAugmentLevelRequired(73)=1
     SkillAugmentRequired(73)=ElectronicsDrones
     SkillAugmentSkillRequired(73)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(73)=1
     SecondarySkillAugmentRequired(73)=
     SecondarySkillAugmentSkillRequired(73)=class'SkillComputer'
     //3.) Melee module.
     SkillAugmentNames(74)="Britware"
     SkillAugmentDescs(74)="~Using some software you found online (admittedly from some unusual sources), you can boost MEGH's melee damage by 50%.|n*It has some quirky side-effects."
     SkillAugmentIDs(74)=TagTeamMeleeSkillware
     SkillAugmentAssumed(74)=0
     SkillAugmentLevel(74)=1
     SkillAugmentLevelRequired(74)=1
     SkillAugmentRequired(74)=ElectronicsDrones
     SkillAugmentSkillRequired(74)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(74)=1
     SecondarySkillAugmentRequired(74)=
     SecondarySkillAugmentSkillRequired(74)=class'SkillComputer'
     
     //FITNESS/MELEE HYBRID!
     //1.) Matrix-esque Dodge Roll.
     SkillAugmentNames(75)="Untouchable"
     SkillAugmentDescs(75)="~You can now double tap a direction to 'dodge roll' towards it, granting high levels of damage reduction mid-roll.|n~For 2.5 seconds after starting a dodge roll, you gain 100% weapon draw and holster speeds|n*Pushing jump during a dodge will interrupt it as soon as possible.|n*Dodge rolls are longer lasting than tactical rolls, with a cooldown of 10 seconds."
     SkillAugmentIDs(75)=TagTeamDodgeRoll
     SkillAugmentAssumed(75)=0
     SkillAugmentLevel(75)=2
     SkillAugmentLevelRequired(75)=1
     SkillAugmentRequired(75)=
     SkillAugmentSkillRequired(75)=class'SkillSwimming'
     SecondarySkillAugmentLevelRequired(75)=1
     SecondarySkillAugmentRequired(75)=
     SecondarySkillAugmentSkillRequired(75)=class'SkillWeaponLowTech'
     
     //INFILTRATION EXPANSION!
     //5.) Poison is less noticeable. Interesting, given that poison is not weapon type specific anymore.
     SkillAugmentNames(76)="Null Aura"
     SkillAugmentDescs(76)="~Tranquilizer poisons no longer alert animals of your presence|n~Tranquilizer poisons are no longer easily traced to you by neutral parties and allies.|n~Stealing noteworthy items found in the world no longer generates noise, although it can still be seen."
     SkillAugmentIDs(76)=LockpickPoisonIdentity
     SkillAugmentAssumed(76)=0
     SkillAugmentLevel(76)=1
     SkillAugmentLevelRequired(76)=1
     SkillAugmentRequired(76)=
     SkillAugmentSkillRequired(76)=class'SkillLockpicking'

     //ACTUAL LAST USED is 76!
}
