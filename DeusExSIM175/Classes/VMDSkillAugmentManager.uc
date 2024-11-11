//=============================================================================
// VMDSkillAugmentManager
//=============================================================================
class VMDSkillAugmentManager extends Actor;

// which player am I attached to?
var DeusExPlayer Player;

var() byte SkillAugmentAssumed[80], SkillAugmentLevel[80], SkillAugmentLevelRequired[80], SecondarySkillAugmentLevelRequired[80];
//MADDERS: Late patch, but change this over to int, due to issues with negative logic.
var() travel int SkillAugmentPointsLeft[15], SkillAugmentPointsSpent[15], SkillAugmentAcquired[80];

var() string SkillAugmentIDs[80], SkillAugmentRequired[80], SecondarySkillAugmentRequired[80];
var localized string SkillAugmentNames[80], SkillAugmentDescs[80];
var() class<Skill> SkillAugmentPointClasses[15], SkillAugmentSkillRequired[80], SecondarySkillAugmentSkillRequired[80];
var() travel byte SkillSpecializations[2];

// ----------------------------------------------------------------------
// SetPlayer()
//
// Kind of a hack, until we figure out why the player doesn't get set 
// correctly initially.
// ----------------------------------------------------------------------

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

function int SkillAugmentArrayOf(string SkillAugmentName)
{
 	local int i;
 	
 	for (i=1; i<ArrayCount(SkillAugmentIDs)+1; i++)
 	{
  		if (SkillAugmentName ~= SkillAugmentIDs[i-1]) break;
 	}
 	if (i > ArrayCount(SkillAugmentIDs)+1) i = 0;
 	i--;
 	
 	return i;
}

function bool ProcessSkillAugmentCostException(string S)
{
	local string CS, CS2;
	
	CS = "TagTeamOpenDecayRate";
	CS2 = "TagTeamClosedWaterproof";
	
 	//if ((S ~= CS || S ~= CS2) && (!HasSkillAugment(CS)) && (!HasSkillAugment(CS2))) return true;
	return false;
}

function bool HasSkillAugment(string S)
{
 	local int i;
 	
 	i = SkillAugmentArrayOf(S);
 	if (i == -1) return false;
 	if (VMDBufferPlayer(Player) == None) return false;
	
 	if ((VMDBufferPlayer(Player).bSkillAugmentsEnabled) && (!VMDHasSkillAugmentObjection(VMDBufferPlayer(Player))))
 	{
  		if (SkillAugmentAcquired[i] > 0) return true;
 	}
 	else
 	{
  		if (SkillAugmentAssumed[i] > 0) return true;
 	}
 	
 	return false;
}

function int SkillArrayFromAugment(string AugmentID)
{
	local class<Skill> SC;
	local int i;
	
	SC = SkillAugmentSkillRequired[SkillAugmentArrayOf(AugmentID)];
	i = SkillArrayOf(SC);
	
	if (i < -1) return 0;
	return i;
}

function int SecondarySkillArrayFromAugment(string AugmentID)
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
 	local string OtherUS1, OtherUS2;
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
  		OtherUS1 = "";
  		OtherUS2 = "";
 	}
 	
 	if ((OtherUS1 != "") && (!HasSkillAugment(OtherUS1))) return false;
 	if ((OtherUS2 != "") && (!HasSkillAugment(OtherUS2))) return false;
 	
	if ((!bBypassCost) && (!CanAffordSkillAugment(SkillAugmentIDs[i], bAlt, bBoth))) return false;
	
 	return true;
}

function bool CanAffordSkillAugment(string S, bool bAlt, bool bBoth)
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

function BuySkillAugment(string S, optional bool bAlt, optional bool bBoth)
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
function LockSkillAugment(string S)
{
 	local int i, j;
 	
 	for (i=0; i<ArrayCount(SkillAugmentIDs); i++)
 	{
  		if (SkillAugmentIDs[i] ~= S)
		{
			SkillAugmentAcquired[i] = 0;
		}
 	}
	
	if (VMDBufferPlayer(Player) != None)
	{
		VMDBufferPlayer(Player).VMDSignalSkillAugmentUpdate(S, true);
	}
}

function UnlockSkillAugment(string S)
{
 	local int i;
 	
 	for (i=0; i<ArrayCount(SkillAugmentIDs); i++)
 	{
  		if (SkillAugmentIDs[i] ~= S) SkillAugmentAcquired[i] = 1;
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
     SkillAugmentDescs(0)="Your pistol class focus rate bonuses are doubled relative to skill level."
     SkillAugmentIDs(0)="PistolFocus"
     SkillAugmentAssumed(0)=1
     SkillAugmentLevel(0)=1
     SkillAugmentLevelRequired(0)=1
     SkillAugmentRequired(0)=""
     SkillAugmentSkillRequired(0)=class'SkillWeaponPistol'
     //2.) Ability to mod weapons (scope, laser >3 generic) (trained)
     SkillAugmentNames(1)="Pistol Modularity"
     SkillAugmentDescs(1)="Pistol class weapons can be fitted with up to 5 of each standard mod, instead of only 3. Additionally, custom mounted scopes give a bigger boost to accuracy, and your lasers give a full benefit to accuracy."
     SkillAugmentIDs(1)="PistolModding"
     SkillAugmentAssumed(1)=1
     SkillAugmentLevel(1)=1
     SkillAugmentLevelRequired(1)=1
     SkillAugmentRequired(1)=""
     SkillAugmentSkillRequired(1)=class'SkillWeaponPistol'
     //3.) Reload speed applies to reload anims	(trained)
     SkillAugmentNames(2)="Gunslinger"
     SkillAugmentDescs(2)="Reload speed bonuses partially apply to the start and end animations of pistol class weapons. Additionally, their reload speed bonuses are increased by 33%."
     SkillAugmentIDs(2)="PistolReload"
     SkillAugmentAssumed(2)=0
     SkillAugmentLevel(2)=1
     SkillAugmentLevelRequired(2)=1
     SkillAugmentRequired(2)=""
     SkillAugmentSkillRequired(2)=class'SkillWeaponPistol'
     //4.) No accuracy penalty for alt ammos (advanced)
     SkillAugmentNames(3)="Pistol Ballistics"
     SkillAugmentDescs(3)="Alternate crossbow munitions shift from a slight debuff to a slight buff to accuracy. Additionally, 10mm gas caps gain double damage upon ricocheting from a surface."
     SkillAugmentIDs(3)="PistolAltAmmos"
     SkillAugmentAssumed(3)=1
     SkillAugmentLevel(3)=2
     SkillAugmentLevelRequired(3)=2
     SkillAugmentRequired(3)="PistolFocus"
     SkillAugmentSkillRequired(3)=class'SkillWeaponPistol'
     //5.) Increased scope bonus, no hipfire penalty (advanced)
     SkillAugmentNames(4)="Deadeye"
     SkillAugmentDescs(4)="Scopes no longer penalize hipfire with pistol class weapons, and the aim benefit is increased. Additionally, accurate range is increased by 35%, decreasing falloff at range, delaying bullet/projectile drop, and increasing projectile speed."
     SkillAugmentIDs(4)="PistolScope"
     SkillAugmentAssumed(4)=0
     SkillAugmentLevel(4)=2
     SkillAugmentLevelRequired(4)=2
     SkillAugmentRequired(4)="PistolModding"
     SkillAugmentSkillRequired(4)=class'SkillWeaponPistol'
     
     //RIFLE
     //1.) Increased focus rate	(trained)
     SkillAugmentNames(5)="Rifle Focus"
     SkillAugmentDescs(5)="Your rifle class focus rate bonuses are doubled relative to skill level."
     SkillAugmentIDs(5)="RifleFocus"
     SkillAugmentAssumed(5)=1
     SkillAugmentLevel(5)=1
     SkillAugmentLevelRequired(5)=1
     SkillAugmentRequired(5)=""
     SkillAugmentSkillRequired(5)=class'SkillWeaponRifle'
     //2.) Ability to mod weapons (scope, laser >2 generic) (trained)
     SkillAugmentNames(6)="Rifle Modularity"
     SkillAugmentDescs(6)="Rifle class weapons can be fitted with up to 5 of each standard mod, instead of only 3. Lasers also give a full benefit to accuracy."
     SkillAugmentIDs(6)="RifleModding"
     SkillAugmentAssumed(6)=1
     SkillAugmentLevel(6)=1
     SkillAugmentLevelRequired(6)=1
     SkillAugmentRequired(6)=""
     SkillAugmentSkillRequired(6)=class'SkillWeaponRifle'
     //3.) Faster pump/bolt/GL operation (trained)
     SkillAugmentNames(7)="Follow-up Shot"
     SkillAugmentDescs(7)="Rifle class weapons pump, rack, and load grenades faster between shots."
     SkillAugmentIDs(7)="RifleOperation"
     SkillAugmentAssumed(7)=0
     SkillAugmentLevel(7)=1
     SkillAugmentLevelRequired(7)=1
     SkillAugmentRequired(7)=""
     SkillAugmentSkillRequired(7)=class'SkillWeaponRifle'
     //4.) No accuracy penalty for alt ammos (advanced)
     SkillAugmentNames(8)="Rifle Ballistics"
	// HVAP gains 100% more penetration against humans and robots.
     SkillAugmentDescs(8)="HEAT and 20mm munitions both gain 50% more blast radius. Tranq rounds have their accuracy penalty reduced by 2/3rds. Sabot slugs shift from a slight debuff to a slight buff to accuracy."
     SkillAugmentIDs(8)="RifleAltAmmos"
     SkillAugmentAssumed(8)=1
     SkillAugmentLevel(8)=2
     SkillAugmentLevelRequired(8)=2
     SkillAugmentRequired(8)="RifleFocus"
     SkillAugmentSkillRequired(8)=class'SkillWeaponRifle'
     //5.) Reload speed applies to reload anims, 15% fast reload (advanced)
     SkillAugmentNames(9)="Lock 'n Load"
     SkillAugmentDescs(9)="Reload speed bonuses partially apply to the start and end animations of rifle class weapons. Additionally, their reload speed bonuses are increased by 33%."
     SkillAugmentIDs(9)="RifleReload"
     SkillAugmentAssumed(9)=0
     SkillAugmentLevel(9)=2
     SkillAugmentLevelRequired(9)=2
     SkillAugmentRequired(9)="RifleOperation"
     SkillAugmentSkillRequired(9)=class'SkillWeaponRifle'
     
     //DEMOLITIONS
     //1.) No screen blur from tear gas	(trained)
     SkillAugmentNames(10)="Hard Boiled"
     SkillAugmentDescs(10)="Sources of tear gas no longer impair visual clarity."
     SkillAugmentIDs(10)="DemolitionTearGas"
     SkillAugmentAssumed(10)=0
     SkillAugmentLevel(10)=1
     SkillAugmentLevelRequired(10)=1
     SkillAugmentRequired(10)=""
     SkillAugmentSkillRequired(10)=class'SkillDemolition'
     //2.) No EMP'ing self damage (trained)
     SkillAugmentNames(11)="Technical Glitch"
     SkillAugmentDescs(11)="Your own EMP and scrambler grenades will no longer affect you."
     SkillAugmentIDs(11)="DemolitionEMP"
     SkillAugmentAssumed(11)=0
     SkillAugmentLevel(11)=1
     SkillAugmentLevelRequired(11)=1
     SkillAugmentRequired(11)=""
     SkillAugmentSkillRequired(11)=class'SkillDemolition'
     //3.) Ability to place mines (trained)
     SkillAugmentNames(12)="Fumble No More"
     SkillAugmentDescs(12)="Brushed up on your training, you can now emplace grenades upon surfaces as mines much faster. Additionally, they can be placed at any angle, instead of just upon walls."
     SkillAugmentIDs(12)="DemolitionMines"
     SkillAugmentAssumed(12)=0
     SkillAugmentLevel(12)=1
     SkillAugmentLevelRequired(12)=1
     SkillAugmentRequired(12)=""
     SkillAugmentSkillRequired(12)=class'SkillDemolition'
     //4.) Mines to detonate faster and are disarmed more easily.
     SkillAugmentNames(13)="Frequency Tuning"
     SkillAugmentDescs(13)="The detection speed of your mines is boosted, and the detection speed of enemy mines is reduced by 75%. Both these effects scale with skill level."
     SkillAugmentIDs(13)="DemolitionMineHandling"
     SkillAugmentAssumed(13)=1
     SkillAugmentLevel(13)=1
     SkillAugmentLevelRequired(13)=1
     SkillAugmentRequired(13)=""
     SkillAugmentSkillRequired(13)=class'SkillDemolition'
     //5.) Higher grenade capacity
     SkillAugmentNames(14)="Grenade Pouch"
     SkillAugmentDescs(14)="Your grenade max capacity is increased from 5 units to 10."
     SkillAugmentIDs(14)="DemolitionGrenadeMaxAmmo"
     SkillAugmentAssumed(14)=1
     SkillAugmentLevel(14)=1
     SkillAugmentLevelRequired(14)=1
     SkillAugmentRequired(14)=""
     SkillAugmentSkillRequired(14)=class'SkillDemolition'
     //6.) Ability to loot grenades from corpses (advanced)
     SkillAugmentNames(15)="Carrion"
     SkillAugmentDescs(15)="Corpses' tendencies to lay on their grenades no longer limits your grenade looting rates."
     SkillAugmentIDs(15)="DemolitionLooting"
     SkillAugmentAssumed(15)=1
     SkillAugmentLevel(15)=2
     SkillAugmentLevelRequired(15)=2
     SkillAugmentRequired(15)="DemolitionGrenadeMaxAmmo"
     SkillAugmentSkillRequired(15)=class'SkillDemolition'
     
     //HEAVY
     //1.) Increased focus rate (trained)
     SkillAugmentNames(16)="Heavy Focus"
     SkillAugmentDescs(16)="Your heavy class focus rate bonuses are doubled relative to skill level."
     SkillAugmentIDs(16)="HeavyFocus"
     SkillAugmentAssumed(16)=1
     SkillAugmentLevel(16)=1
     SkillAugmentLevelRequired(16)=1
     SkillAugmentRequired(16)=""
     SkillAugmentSkillRequired(16)=class'SkillWeaponHeavy'
     //2.) Reduced move speed penalty with heavy weapons [scaling] (trained)
     SkillAugmentNames(17)="Heavy Posture"
     SkillAugmentDescs(17)="Heavy class weapons have decreased speed penalty relative to skill level."
     SkillAugmentIDs(17)="HeavySpeed"
     SkillAugmentAssumed(17)=1
     SkillAugmentLevel(17)=1
     SkillAugmentLevelRequired(17)=1
     SkillAugmentRequired(17)=""
     SkillAugmentSkillRequired(17)=class'SkillWeaponHeavy'
     //3.) Ability to stop, drop, and roll (trained)
     SkillAugmentNames(18)="Stop, Drop..."
     SkillAugmentDescs(18)="Ducking and strafing side to side can extinguish you if you're on fire. Using fall or tactical rolls also reduces your burn duration."
     SkillAugmentIDs(18)="HeavyDropAndRoll"
     SkillAugmentAssumed(18)=1 //Keeping this for sim purposes
     SkillAugmentLevel(18)=1
     SkillAugmentLevelRequired(18)=1
     SkillAugmentRequired(18)=""
     SkillAugmentSkillRequired(18)=class'SkillWeaponHeavy'
     //4.) Reduced plasma self splash (advanced)
     SkillAugmentNames(19)="Danger Close"
     SkillAugmentDescs(19)="Your own plasma splashes back on you at 35% strength."
     SkillAugmentIDs(19)="HeavyPlasma"
     SkillAugmentAssumed(19)=0
     SkillAugmentLevel(19)=2
     SkillAugmentLevelRequired(19)=2
     SkillAugmentRequired(19)="HeavyProjectileSpeed"
     SkillAugmentSkillRequired(19)=class'SkillWeaponHeavy'
     //5.) Projectile Speed
     SkillAugmentNames(20)="Overclock"
     SkillAugmentDescs(20)="Heavy projectile speeds are increased by 25%, greatly increasing hit reliability, especially when paired with range weapon mods."
     SkillAugmentIDs(20)="HeavyProjectileSpeed"
     SkillAugmentAssumed(20)=1
     SkillAugmentLevel(20)=1
     SkillAugmentLevelRequired(20)=1
     SkillAugmentRequired(20)=""
     SkillAugmentSkillRequired(20)=class'SkillWeaponHeavy'
     //6.) Heavy Swap Speed (advanced)
     SkillAugmentNames(21)="Show-off"
     SkillAugmentDescs(21)="Holstering and drawing heavy weapons becomes 50% faster."
     SkillAugmentIDs(21)="HeavySwapSpeed"
     SkillAugmentAssumed(21)=0
     SkillAugmentLevel(21)=2
     SkillAugmentLevelRequired(21)=2
     SkillAugmentRequired(21)="HeavySpeed"
     SkillAugmentSkillRequired(21)=class'SkillWeaponHeavy'
     
     //MELEE
     //1.) Retrieve projectiles from corpses (trained)
     SkillAugmentNames(22)="Dislodge"
     SkillAugmentDescs(22)="Darts and throwing knives can be retrieved from enemy corpses successfully."
     SkillAugmentIDs(22)="MeleeProjectileLooting"
     SkillAugmentAssumed(22)=1 //Keeping this for sim purposes
     SkillAugmentLevel(22)=1
     SkillAugmentLevelRequired(22)=1
     SkillAugmentRequired(22)=""
     SkillAugmentSkillRequired(22)=class'SkillWeaponLowTech'
     //2.) Headshots with baton (trained)
     SkillAugmentNames(23)="Silent Takedown"
     SkillAugmentDescs(23)="Batons and direct hits from gas caps are now capable of making effective, nonlethal headshots."
     SkillAugmentIDs(23)="MeleeBatonHeadshots"
     SkillAugmentAssumed(23)=0
     SkillAugmentLevel(23)=1
     SkillAugmentLevelRequired(23)=1
     SkillAugmentRequired(23)=""
     SkillAugmentSkillRequired(23)=class'SkillWeaponLowTech'
     //3.) No longer cross-class. Crowbars can defeat 15% or less soft locks.
     SkillAugmentNames(24)="Soft Spot"
     SkillAugmentDescs(24)="Hitting a breakable wood or glass door with <= 15% lockstrength using a crowbar will break its lock integrity."
     SkillAugmentIDs(24)="MeleeDoorCrackingWood"
     SkillAugmentAssumed(24)=1 //Keeping for crowbar utility
     SkillAugmentLevel(24)=1
     SkillAugmentLevelRequired(24)=1
     SkillAugmentRequired(24)=""
     SkillAugmentSkillRequired(24)=class'SkillWeaponLowTech'
     //4.) Swing speed enhanced with melee (+30%) (advanced)
     SkillAugmentNames(25)="Melee Rhythm"
     SkillAugmentDescs(25)="The swing speed of melee weapons is enhanced by 30-40%."
     SkillAugmentIDs(25)="MeleeSwingSpeed"
     SkillAugmentAssumed(25)=0
     SkillAugmentLevel(25)=2
     SkillAugmentLevelRequired(25)=2
     SkillAugmentRequired(25)=""
     SkillAugmentSkillRequired(25)=class'SkillWeaponLowTech'
     //5.) Taser & tear gas longer stun duration (advanced)
     SkillAugmentNames(26)="Low Blow"
     SkillAugmentDescs(26)="The prod and various irritants have doubled effect duration."
     SkillAugmentIDs(26)="MeleeStunDuration"
     SkillAugmentAssumed(26)=0
     SkillAugmentLevel(26)=1
     SkillAugmentLevelRequired(26)=2
     SkillAugmentRequired(26)="MeleeBatonHeadshots"
     SkillAugmentSkillRequired(26)=class'SkillWeaponLowTech'
     //5.) Fast kills = no noise. Don't know why this took me so long.
     SkillAugmentNames(27)="True Assailant"
     SkillAugmentDescs(27)="Any form of takedown on an enemy, so long as it is performed quickly, will produce no audible noise to nearby persons."
     SkillAugmentIDs(27)="MeleeAssassin"
     SkillAugmentAssumed(27)=0
     SkillAugmentLevel(27)=2
     SkillAugmentLevelRequired(27)=2
     SkillAugmentRequired(27)="MeleeBatonHeadshots"
     SkillAugmentSkillRequired(27)=class'SkillWeaponLowTech'
     
     //LOCKPICKING
     //1.) Lock scouting silent, breakable status known (trained)
     SkillAugmentNames(28)="Soft Touch"
     SkillAugmentDescs(28)="Scouting soft material doors' locks no longer generates noise. Additionally, invulnerability status is known automatically and successive weapon hits scout damage thresholds more precisely."
     SkillAugmentIDs(28)="LockpickScoutNoise"
     SkillAugmentAssumed(28)=0
     SkillAugmentLevel(28)=1
     SkillAugmentLevelRequired(28)=1
     SkillAugmentRequired(28)=""
     SkillAugmentSkillRequired(28)=class'SkillLockpicking'
     //2.) Pick pockets (no UI, no failure) (trained)
     SkillAugmentNames(29)="Pickpocket"
     SkillAugmentDescs(29)="Ducking and pressing the 'use' button, while facing the rear end of a low priority human character with empty hands, will fish a random item from their pockets. The pickpocket cooldown is 1 second. This cooldown is reduced by 25% per level of infiltration. Remember not to get caught."
     SkillAugmentIDs(29)="LockpickPickpocket"
     SkillAugmentAssumed(29)=1 //Keeping this for sim purposes
     SkillAugmentLevel(29)=1
     SkillAugmentLevelRequired(29)=1
     SkillAugmentRequired(29)=""
     SkillAugmentSkillRequired(29)=class'SkillLockpicking'
     //3.) Increased food and blood threshold before generating smell 	(trained)
     SkillAugmentNames(30)="Cover-up"
     SkillAugmentDescs(30)="The thresholds for food and blood scents are increased by approximately 15% and 25%, respectively. This bonus is increased by another 15/25%, additive, per each level of Infiltration skill."
     SkillAugmentIDs(30)="LockpickScent"
     SkillAugmentAssumed(30)=0
     SkillAugmentLevel(30)=1
     SkillAugmentLevelRequired(30)=1
     SkillAugmentRequired(30)=""
     SkillAugmentSkillRequired(30)=class'SkillLockpicking'
     //4.) Lockpicking does not emit alert until broken	(advanced)
     SkillAugmentNames(31)="Sleight of Hand"
     SkillAugmentDescs(31)="Initiating lockpicking does not draw outside attention. Additionally, picks broken during a rush have 1/3rd less noise radius, regardless of skill level."
     SkillAugmentIDs(31)="LockpickStartStealth"
     SkillAugmentAssumed(31)=0
     SkillAugmentLevel(31)=2
     SkillAugmentLevelRequired(31)=2
     SkillAugmentRequired(31)="LockpickScoutNoise"
     SkillAugmentSkillRequired(31)=class'SkillLockpicking'
     
     //HACKING!
     //1.) Hack failure does not produce noise (trained)
     SkillAugmentNames(32)="Silent Mode"
     SkillAugmentDescs(32)="Rushed electronic bypassing attempts that fail now draw outside attention substantially less, scaling with skill level. They are also performed about 1/3rd faster."
     SkillAugmentIDs(32)="ElectronicsFailNoise"
     SkillAugmentAssumed(32)=0
     SkillAugmentLevel(32)=1
     SkillAugmentLevelRequired(32)=1
     SkillAugmentRequired(32)=""
     SkillAugmentSkillRequired(32)=class'SkillTech'
     //2.) Faster hack timeline	(trained)
     SkillAugmentNames(33)="Speed Dial"
     SkillAugmentDescs(33)="Non-rushed electronic bypassing progresses 25% faster, although it is no more efficient in output."
     SkillAugmentIDs(33)="ElectronicsSpeed"
     SkillAugmentAssumed(33)=0
     SkillAugmentLevel(33)=1
     SkillAugmentLevelRequired(33)=1
     SkillAugmentRequired(33)=""
     SkillAugmentSkillRequired(33)=class'SkillTech'
     //3.) Better potency vs keypads
     SkillAugmentNames(34)="Codebreaker"
     SkillAugmentDescs(34)="Keypads are bypassed at 35% more strength per tool, relative to the tool's original strength."
     SkillAugmentIDs(34)="ElectronicsKeypads"
     SkillAugmentAssumed(34)=0
     SkillAugmentLevel(34)=2
     SkillAugmentLevelRequired(34)=2
     SkillAugmentRequired(34)=""
     SkillAugmentSkillRequired(34)=class'SkillTech'
     //4.) Hacked turrets change alliance (master)
     SkillAugmentNames(35)="IFF Override"
     SkillAugmentDescs(35)="Turrets bypassed via multitool will attack hostiles instead of being deactivated."
     SkillAugmentIDs(35)="ElectronicsTurrets"
     SkillAugmentAssumed(35)=0
     SkillAugmentLevel(35)=3
     SkillAugmentLevelRequired(35)=2
     SkillAugmentRequired(35)=""
     SkillAugmentSkillRequired(35)=class'SkillTech'
     //5.) Helidrone crafting, to distract us from the otherwise bare state of electronics. RIP.
     SkillAugmentNames(36)="M.E.G.H."
     SkillAugmentDescs(36)="Meet the Modular Electric General-Use Helidrone, or MEGH. It is a small, flying bot. For a fistful of crafting materials, you can craft a MEGH to aid you in combat. You may only own one helidrone at a time, and it may only handle small stature weapons, excluding the prod."
     SkillAugmentIDs(36)="ElectronicsDrones"
     SkillAugmentAssumed(36)=1 //Costs materials, right?
     SkillAugmentLevel(36)=1
     SkillAugmentLevelRequired(36)=1
     SkillAugmentRequired(36)=""
     SkillAugmentSkillRequired(36)=class'SkillTech'
     //6.) Helidrone armor, but at more cost.
     SkillAugmentNames(37)="Reinforced Plating"
     SkillAugmentDescs(37)="The price of crafting a helidrone is increased by 50%. However, its overall health is increased by 200%. This upgrade is applied to existing drones automatically."
     SkillAugmentIDs(37)="ElectronicsDroneArmor"
     SkillAugmentAssumed(37)=0
     SkillAugmentLevel(37)=1
     SkillAugmentLevelRequired(37)=1
     SkillAugmentRequired(37)="ElectronicsDrones"
     SkillAugmentSkillRequired(37)=class'SkillTech'
     //7.) Doubled crafting efficiency.
     SkillAugmentNames(38)="Elbow Grease"
     SkillAugmentDescs(38)="Relative to skill level, your mechanical crafting efficiency bonus is doubled. This bonus also applies to MEGH and SIDD repair costs."
     SkillAugmentIDs(38)="ElectronicsCrafting"
     SkillAugmentAssumed(38)=0
     SkillAugmentLevel(38)=2
     SkillAugmentLevelRequired(38)=2
     SkillAugmentRequired(38)=""
     SkillAugmentSkillRequired(38)=class'SkillTech'
     
     //SWIMMING
     //1.) Enhanced breath regen rate (trained)
     SkillAugmentNames(39)="Aquadynamic"
     SkillAugmentDescs(39)="Swim speed bonuses gain 150% value relative to skill level. Additionally, your breath recovers 4x faster out of water and you take 40% less drowning damage per tick."
     SkillAugmentIDs(39)="SwimmingBreathRegen"
     SkillAugmentAssumed(39)=0 //Denied for sim purposes
     SkillAugmentLevel(39)=1
     SkillAugmentLevelRequired(39)=1
     SkillAugmentRequired(39)=""
     SkillAugmentSkillRequired(39)=class'SkillSwimming'
     //2.) Ability to roll to break falls (trained)
     SkillAugmentNames(40)="Fall Roll"
     SkillAugmentDescs(40)="If moving straight forward with sufficient speed, holding duck while receiving a hard fall will heavily reduce fall damage by transitioning into a roll. This can only be performed once per every 10 seconds, and you need at least 1 health in both legs for any type of roll."
     SkillAugmentIDs(40)="SwimmingFallRoll"
     SkillAugmentAssumed(40)=1 //Keeping this for sim purposes
     SkillAugmentLevel(40)=1
     SkillAugmentLevelRequired(40)=1
     SkillAugmentRequired(40)=""
     SkillAugmentSkillRequired(40)=class'SkillSwimming'
     //3.) Ability to roll freely (advanced)
     SkillAugmentNames(41)="Tactical Roll"
     SkillAugmentDescs(41)="Pressing space quickly after pressing duck lets you perform a sneaky roll. This roll shares a cooldown with fall roll, at 10 seconds."
     SkillAugmentIDs(41)="SwimmingRoll"
     SkillAugmentAssumed(41)=0 //This used to be free, but it's overpowered when combined with jump-duck which is free for QOL reasons.
     SkillAugmentLevel(41)=2
     SkillAugmentLevelRequired(41)=2
     SkillAugmentRequired(41)="SwimmingFallRoll"
     SkillAugmentSkillRequired(41)=class'SkillSwimming'
     //4.) Reduced drowning damage rate (advanced)
     SkillAugmentNames(42)="Deep, Steady"
     SkillAugmentDescs(42)="Underwater breath duration bonuses gain 150% value relative to skill level. All drowning damage taken occurs 4 seconds apart instead of 2. Additionally, taking damage does not reduce oxygen left while in bodies of water. Finally, all speed penalties for using equipment underwater are negated, medkit healing is not impaired underwater, and you gain 15% accuracy while in water."
     SkillAugmentIDs(42)="SwimmingDrowningRate"
     SkillAugmentAssumed(42)=0
     SkillAugmentLevel(42)=2
     SkillAugmentLevelRequired(42)=2
     SkillAugmentRequired(42)="SwimmingBreathRegen"
     SkillAugmentSkillRequired(42)=class'SkillSwimming'
     //5.) Bundle of various improvements
     SkillAugmentNames(43)="Fit as a Fiddle"
     SkillAugmentDescs(43)="You did not skip leg day. Your rolling cooldown is reduced by 25%, you can duck while jumping, and most types of damage taken while rolling is halved."
     SkillAugmentIDs(43)="SwimmingFitness"
     SkillAugmentAssumed(43)=1 //Keeping this for the sake of QOL.
     SkillAugmentLevel(43)=2
     SkillAugmentLevelRequired(43)=2
     SkillAugmentRequired(43)=""
     SkillAugmentSkillRequired(43)=class'SkillSwimming'
     
     //ENVIRO
     //1.) Ability to de-activate pickups (trained)
     SkillAugmentNames(44)="Off Switch"
     SkillAugmentDescs(44)="A quick yank on the power cord lets you deactivate wearable items safely, but at a 15% potential max charge cost."
     SkillAugmentIDs(44)="EnviroDeactivate"
     SkillAugmentAssumed(44)=1 //Keeping this for sim purposes
     SkillAugmentLevel(44)=1
     SkillAugmentLevelRequired(44)=1
     SkillAugmentRequired(44)=""
     SkillAugmentSkillRequired(44)=class'SkillEnviro'
     //2.) Ability to carry multiple of one pickup type (trained)
     SkillAugmentNames(45)="Insulation"
     SkillAugmentDescs(45)="Carrying multiple copies of wearable gear is now possible, with 2 per stack."
     SkillAugmentIDs(45)="EnviroCopies"
     SkillAugmentAssumed(45)=1 //Keeping this because it's vanilla
     SkillAugmentLevel(45)=1
     SkillAugmentLevelRequired(45)=1
     SkillAugmentRequired(45)=""
     SkillAugmentSkillRequired(45)=class'SkillEnviro'
     //3.) Ability to stack carried pickup types (advanced)
     SkillAugmentNames(46)="Advanced Insulation"
     SkillAugmentDescs(46)="With some creative problem solving, you may now store up to 3 of a particular type of wearable gear."
     SkillAugmentIDs(46)="EnviroCopyStacks"
     SkillAugmentAssumed(46)=0
     SkillAugmentLevel(46)=2
     SkillAugmentLevelRequired(46)=2
     SkillAugmentRequired(46)="EnviroCopies"
     SkillAugmentSkillRequired(46)=class'SkillEnviro'
     //4.) Pickup regen while held in hand and inactive (master)
     SkillAugmentNames(47)="Fasten Up"
     SkillAugmentDescs(47)="Wearable items suffer decreased degradation from incoming damage by 25%, such as bullets hitting ballistic vests. Additionally, EMP damage is 50% less degrading to your active tactical gear."
     SkillAugmentIDs(47)="EnviroDurability"
     SkillAugmentAssumed(47)=0
     SkillAugmentLevel(47)=2
     SkillAugmentLevelRequired(47)=2
     SkillAugmentRequired(47)="EnviroDeactivate"
     SkillAugmentSkillRequired(47)=class'SkillEnviro'
     //5.) Can remove charged pickups from enemies.
     SkillAugmentNames(48)="Gentle Touch"
     SkillAugmentDescs(48)="With a practiced hand, you can now remove tactical gear from fallen enemies without a 75% penalty."
     SkillAugmentIDs(48)="EnviroLooting"
     SkillAugmentAssumed(48)=1
     SkillAugmentLevel(48)=2
     SkillAugmentLevelRequired(48)=2
     SkillAugmentRequired(48)=""
     SkillAugmentSkillRequired(48)=class'SkillEnviro'
     
     //MEDICINE
     //1.) Using a medkit restores stress instead of costing stress (trained)
     SkillAugmentNames(49)="Pharmacist"
     SkillAugmentDescs(49)="Your familiarity with medical drugs has never been more relevant. Using a medkit grants a 50% reduction in damage taken from poison ticks, overdosing, and inhalated toxins for 10 seconds. Additionally, using medkits halves the screen blur effects of drugs and poisons."
     SkillAugmentIDs(49)="MedicineStress"
     SkillAugmentAssumed(49)=0 //No longer kept, because it is the fucking stronk.
     SkillAugmentLevel(49)=1
     SkillAugmentLevelRequired(49)=1
     SkillAugmentRequired(49)=""
     SkillAugmentSkillRequired(49)=class'SkillMedicine'
     //2.) Excess healing to a limb wraps around to other body parts (trained)
     SkillAugmentNames(50)="Trained Professional"
     SkillAugmentDescs(50)="When healing a specific region, any excess healing wraps around to other areas via standard healing order. Additionally, excess medbot charge is not wasted. Finally, activating a biocell in-game (while aiming at a medbot in range) will add 75 points to the medbot's remaining healing."
     SkillAugmentIDs(50)="MedicineWraparound"
     SkillAugmentAssumed(50)=1 //Keep this for QOL purposes
     SkillAugmentLevel(50)=1
     SkillAugmentLevelRequired(50)=1
     SkillAugmentRequired(50)=""
     SkillAugmentSkillRequired(50)=class'SkillMedicine'
     //3.) Medkit carrying capacity is increased (+5) (advanced)
     SkillAugmentNames(51)="Walking Closet"
     SkillAugmentDescs(51)="Medkit capacity is increased by 5 units."
     SkillAugmentIDs(51)="MedicineCapacity"
     SkillAugmentAssumed(51)=1 //Nerfed until we spec into medicine, but without skill augments, just make it free.
     SkillAugmentLevel(51)=2
     SkillAugmentLevelRequired(51)=2
     SkillAugmentRequired(51)=""
     SkillAugmentSkillRequired(51)=class'SkillMedicine'
     //4.) Fatal bullet/melee damage will expend 3 medkits once per 2 minutes, instead of dying. Healing is not applied. (master)
     SkillAugmentNames(52)="Vital Coverage"
     SkillAugmentDescs(52)="Once per 2 minutes, fatal damage will be negated at the cost of 3 medkits. This effect only activates when you have more than 15 medkits. Additionally, your medkit capacity is increased by another 5 units."
     SkillAugmentIDs(52)="MedicineRevive"
     SkillAugmentAssumed(52)=0
     SkillAugmentLevel(52)=2
     SkillAugmentLevelRequired(52)=3
     SkillAugmentRequired(52)="MedicineCapacity"
     SkillAugmentSkillRequired(52)=class'SkillMedicine'
     //5.) More efficiency for medicinal crafting. This is, controversially, not cross class.
     SkillAugmentNames(53)="PHD in Chemistry"
     SkillAugmentDescs(53)="Relative to skill level, your chemical crafting efficiency bonus is doubled."
     SkillAugmentIDs(53)="MedicineCrafting"
     SkillAugmentAssumed(53)=0
     SkillAugmentLevel(53)=2
     SkillAugmentLevelRequired(53)=2
     SkillAugmentRequired(53)=""
     SkillAugmentSkillRequired(53)=class'SkillMedicine'
     //6.) Drugs, baby, drugs.
     SkillAugmentNames(71)="Compound 23"
     SkillAugmentDescs(71)="With a little organic chemistry, combat stimulants can now be crafted, although you'll need substantial workspace to do so. When used, the provide a substantial boost to melee and movement speeds, among other things. A little doping never hurt anyone, right?"
     SkillAugmentIDs(71)="MedicineCombatDrugs"
     SkillAugmentAssumed(71)=1
     SkillAugmentLevel(71)=1
     SkillAugmentLevelRequired(71)=1
     SkillAugmentRequired(71)=""
     SkillAugmentSkillRequired(71)=class'SkillMedicine'
     
     //COMPUTERS
     //1.) Time until hacking detected is extended with level (trained)
     SkillAugmentNames(54)="Wiz Kid"
     SkillAugmentDescs(54)="Your actions during hacking have reduced detection time impact, scaling with skill level. Additionally, you may download emails from hacked computers for reading later. This action has no time cost."
     SkillAugmentIDs(54)="ComputerScaling"
     SkillAugmentAssumed(54)=1 //Keeping because it's necessary
     SkillAugmentLevel(54)=1
     SkillAugmentLevelRequired(54)=1
     SkillAugmentRequired(54)=""
     SkillAugmentSkillRequired(54)=class'SkillComputer'
     //2.) Turrets can be set to target only hostiles, vs just everything (trained)
     SkillAugmentNames(55)="IFF Programing"
     SkillAugmentDescs(55)="Instead of disabling IFF on turrets, you can now patch the value to attack new targets, saving ammo and time."
     SkillAugmentIDs(55)="ComputerTurrets"
     SkillAugmentAssumed(55)=1 //Keeping because it's vanilla
     SkillAugmentLevel(55)=2
     SkillAugmentLevelRequired(55)=2
     SkillAugmentRequired(55)=""
     SkillAugmentSkillRequired(55)=class'SkillComputer'
     //3.) Hacked computers can have special options used (trained)
     SkillAugmentNames(56)="Deep Fake"
     SkillAugmentDescs(56)="Your artificial credentials can switch on special options within computers, such as hidden doors or power controls, with zero time cost, greatly increasing their practical value."
     SkillAugmentIDs(56)="ComputerSpecialOptions"
     SkillAugmentAssumed(56)=1 //Keeping because it's vanilla
     SkillAugmentLevel(56)=1
     SkillAugmentLevelRequired(56)=1
     SkillAugmentRequired(56)=""
     SkillAugmentSkillRequired(56)=class'SkillComputer'
     //4.) ATM's target the best possible account when hacked (advanced)
     SkillAugmentNames(57)="Check Sum"
     SkillAugmentDescs(57)="Your familiarity with data structures lets you extract the best possible sum from ATM's, scaling with your skill level."
     SkillAugmentIDs(57)="ComputerATMQuality"
     SkillAugmentAssumed(57)=1 //Keeping because it's vanilla
     SkillAugmentLevel(57)=2
     SkillAugmentLevelRequired(57)=2
     SkillAugmentRequired(57)=""
     SkillAugmentSkillRequired(57)=class'SkillComputer'
     //5.) Computer lockout doesn't eject, doesn't sound alarm, costs bio (master)
     SkillAugmentNames(58)="Digital Phantom"
     SkillAugmentDescs(58)="Your hacking duration length is extended virtually indefinitely, to 300 units of time."
     SkillAugmentIDs(58)="ComputerLockout"
     SkillAugmentAssumed(58)=0
     SkillAugmentLevel(58)=3
     SkillAugmentLevelRequired(58)=3
     SkillAugmentRequired(58)="ComputerScaling"
     SkillAugmentSkillRequired(58)=class'SkillComputer'
     
     //ENVIRO/PISTOL HYBRID!
     //1.) Ability to hide small arms from view (advanced)
     SkillAugmentNames(59)="Low Profile"
     SkillAugmentDescs(59)="Small stature weapons can be palmed, making them unseen to prying authorities. They are also drawn and holstered 50% faster. This criteria includes grenades, all pistol class weapons, combat knives, batons, and the sawed off shotgun."
     SkillAugmentIDs(59)="TagTeamSmallWeapons"
     SkillAugmentAssumed(59)=0
     SkillAugmentLevel(59)=1
     SkillAugmentLevelRequired(59)=1
     SkillAugmentRequired(59)=""
     SkillAugmentSkillRequired(59)=class'SkillEnviro'
     SecondarySkillAugmentLevelRequired(59)=1
     SecondarySkillAugmentRequired(59)=""
     SecondarySkillAugmentSkillRequired(59)=class'SkillWeaponPistol'
     
     //PISTOL/RIFLE HYBRID!
     //1.) Open system no longer needs cleaning
     SkillAugmentNames(60)="Big Kick Magnum"
     SkillAugmentDescs(60)="While muzzle flip itself is not reduced, the rate at which your accuracy decays when shooting 'robust' style guns is decreased by 25%."
     SkillAugmentIDs(60)="TagTeamOpenDecayRate" //TagTeamOpenGrimeproof
     SkillAugmentAssumed(60)=0
     SkillAugmentLevel(60)=1
     SkillAugmentLevelRequired(60)=1
     SkillAugmentRequired(60)=""
     SkillAugmentSkillRequired(60)=class'SkillWeaponRifle'
     SecondarySkillAugmentLevelRequired(60)=1
     SecondarySkillAugmentRequired(60)=""
     SecondarySkillAugmentSkillRequired(60)=class'SkillWeaponPistol'
     //2.) Closed system works underwater
     SkillAugmentNames(61)="'Wet' Operations"
     SkillAugmentDescs(61)="With a little fine tuning, your 'intricate' style guns can operate IN and shortly after BEING in water."
     SkillAugmentIDs(61)="TagTeamClosedWaterproof"
     SkillAugmentAssumed(61)=0
     SkillAugmentLevel(61)=1
     SkillAugmentLevelRequired(61)=1
     SkillAugmentRequired(61)=""
     SkillAugmentSkillRequired(61)=class'SkillWeaponPistol'
     SecondarySkillAugmentLevelRequired(61)=1
     SecondarySkillAugmentRequired(61)=""
     SecondarySkillAugmentSkillRequired(61)=class'SkillWeaponRifle'
     //3.) Open system gets +1 to cap, and +1 to ammo looted
     SkillAugmentNames(62)="Chamber: Check."
     SkillAugmentDescs(62)="In addition to a +1 capacity with all 'robust' style guns, you also loot 'robust' weapons for 1 more round of ammo."
     SkillAugmentIDs(62)="TagTeamOpenChamber"
     SkillAugmentAssumed(62)=0
     SkillAugmentLevel(62)=1
     SkillAugmentLevelRequired(62)=2
     SkillAugmentRequired(62)="TagTeamOpenDecayRate"
     SkillAugmentSkillRequired(62)=class'SkillWeaponRifle'
     SecondarySkillAugmentLevelRequired(62)=1
     SecondarySkillAugmentRequired(62)=""
     SecondarySkillAugmentSkillRequired(62)=class'SkillWeaponPistol'
     //4.) Closed system gains 20% bonus headshot damage
     SkillAugmentNames(63)="Pressurize"
     SkillAugmentDescs(63)="Having tuned things further, your 'intricate' style weapons deal 25% more headshot damage."
     SkillAugmentIDs(63)="TagTeamClosedHeadshot"
     SkillAugmentAssumed(63)=0
     SkillAugmentLevel(63)=1
     SkillAugmentLevelRequired(63)=2
     SkillAugmentRequired(63)="TagTeamClosedWaterproof"
     SkillAugmentSkillRequired(63)=class'SkillWeaponPistol'
     SecondarySkillAugmentLevelRequired(63)=1
     SecondarySkillAugmentRequired(63)=""
     SecondarySkillAugmentSkillRequired(63)=class'SkillWeaponRifle'
     
     //MELEE/LOCKPICKING HYBRID!
     //1.) Break <= 15% locks w/ crowbar
     SkillAugmentNames(64)="Brute Force"
     SkillAugmentDescs(64)="Any type of door below 5/10/15/20% lock strength can be broken with a crowbar, depending on low tech skill level. Wood and glass doors maintain a minimum threshold of 15%."
     SkillAugmentIDs(64)="TagTeamDoorCrackingMetal"
     SkillAugmentAssumed(64)=0 //This is NOT, for being overpowered
     SkillAugmentLevel(64)=1
     SkillAugmentLevelRequired(64)=1
     SkillAugmentRequired(64)="MeleeDoorCrackingWood"
     SkillAugmentSkillRequired(64)=class'SkillWeaponLowTech'
     SecondarySkillAugmentLevelRequired(64)=1
     SecondarySkillAugmentRequired(64)=""
     SecondarySkillAugmentSkillRequired(64)=class'SkillLockpicking'
     
     //PISTOL/ELECTRONICS HYBRID!
     //1.) Build a mini-turret. (advanced)
     SkillAugmentNames(65)="S.I.D.D."
     SkillAugmentDescs(65)="Meet the Static Improvised Defense Device, or SIDD. It is a small turret that uses 7.62 ammo. For slightly more materials than a light MEGH, you can craft a SIDD to help defend areas."
     SkillAugmentIDs(65)="TagTeamMiniTurret"
     SkillAugmentAssumed(65)=1
     SkillAugmentLevel(65)=2
     SkillAugmentLevelRequired(65)=1
     SkillAugmentRequired(65)="ElectronicsDrones"
     SkillAugmentSkillRequired(65)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(65)=1
     SecondarySkillAugmentRequired(65)=""
     SecondarySkillAugmentSkillRequired(65)=class'SkillWeaponPistol'
     
     //LOCKPICKING/ELECTRONICS HYBRID!
     //1.) Lockpick/multitool max count increased (+5) (advanced)
     SkillAugmentNames(66)="Invader's Kit"
     SkillAugmentDescs(66)="Both your lockpick and multitool capacities are doubled, increasing them by 10 units each."
     SkillAugmentIDs(66)="TagTeamInvaderCapacity"
     SkillAugmentAssumed(66)=0
     SkillAugmentLevel(66)=2
     SkillAugmentLevelRequired(66)=1
     SkillAugmentRequired(66)=""
     SkillAugmentSkillRequired(66)=class'SkillLockpicking'
     SecondarySkillAugmentLevelRequired(66)=1
     SecondarySkillAugmentRequired(66)=""
     SecondarySkillAugmentSkillRequired(66)=class'SkillTech'
     
     //DEMOLITIONS/ELECTRONICS HYBRID!
     //1.) Scrambler grenades don't wear off (master)
     SkillAugmentNames(67)="Mega Hertz"
     SkillAugmentDescs(67)="The disorienting effects of scrambler grenades now stick around almost indefinitely. Additionally, EMP grenades deal permanent damage to cameras, turrets, control panels, and lasers, potentially rendering them useless."
     SkillAugmentIDs(67)="TagTeamScrambler"
     SkillAugmentAssumed(67)=0
     SkillAugmentLevel(67)=2
     SkillAugmentLevelRequired(67)=1
     SkillAugmentRequired(67)="DemolitionEMP"
     SkillAugmentSkillRequired(67)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(67)=2
     SecondarySkillAugmentRequired(67)=""
     SecondarySkillAugmentSkillRequired(67)=class'SkillDemolition'
     
     //MEDICINE/ELECTRONICS HYBRID!
     //1.) Can craft med gel, and use it with bots.
     SkillAugmentNames(68)="Medigel Treatment"
     SkillAugmentDescs(68)="For less than the price of crafting a medkit, you can craft syringes of 'Ritegel' medical foam. One container heals for 75 health over about 4 seconds. Given its prevalence in the medical industry, it is immediately compatible with the MEGH drone."
     SkillAugmentIDs(68)="TagTeamMedicalSyringe"
     SkillAugmentAssumed(68)=0
     SkillAugmentLevel(68)=2
     SkillAugmentLevelRequired(68)=1
     SkillAugmentRequired(68)=""
     SkillAugmentSkillRequired(68)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(68)=2
     SecondarySkillAugmentRequired(68)=""
     SecondarySkillAugmentSkillRequired(68)=class'SkillMedicine'
     
     //COMPUTERS/ELECTRONICS HYBRID!
     //1.) Software buff for turret and drone.
     SkillAugmentNames(69)="Experimental Skillware"
     SkillAugmentDescs(69)="MEGH and SIDD drones both gain a 12.5% increase in accuracy. Additionally, MEGH gains a 20% increase in movement speed, and SIDD gains a 400% faster spinup rate."
     SkillAugmentIDs(69)="TagTeamSkillware"
     SkillAugmentAssumed(69)=0
     SkillAugmentLevel(69)=2
     SkillAugmentLevelRequired(69)=2
     SkillAugmentRequired(69)="ElectronicsDrones"
     SkillAugmentSkillRequired(69)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(69)=1
     SecondarySkillAugmentRequired(69)=""
     SecondarySkillAugmentSkillRequired(69)=class'SkillComputer'
     //2.) Drone can do a mini-hack on security consoles.
     SkillAugmentNames(70)="Illegal Modules"
     SkillAugmentDescs(70)="MEGH gains access to 'litehack' software. When ordered to hack into a security console, MEGH will stay behind, and keep all cameras and turrets on the grid suppressed until assigned to another task."
     SkillAugmentIDs(70)="TagTeamLitehack"
     SkillAugmentAssumed(70)=0
     SkillAugmentLevel(70)=1
     SkillAugmentLevelRequired(70)=1
     SkillAugmentRequired(70)="ElectronicsDrones"
     SkillAugmentSkillRequired(70)=class'SkillTech'
     SecondarySkillAugmentLevelRequired(70)=1
     SecondarySkillAugmentRequired(70)=""
     SecondarySkillAugmentSkillRequired(70)=class'SkillComputer'
     
     //ACTUAL LAST USED is 71!
}
