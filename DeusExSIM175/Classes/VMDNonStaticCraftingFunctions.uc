//=============================================================================
// VMDStaticCraftingFunctions.
// Note: We exist only to reduce the amount of static class loads.
// Otherwise, this would be in GameInfo.
// ---------------------------------------------------------------
// MADDERS, 5/16/22: We are no longer static. How about that?
//=============================================================================
class VMDNonStaticCraftingFunctions extends VMDFillerActors; // abstract

var class<Inventory> MechanicalItemsGlossary[32], MedicalItemsGlossary[32];

var class<Inventory> MechanicalItems[32], MedicalItems[32];
var int MechanicalItemsPrice[32], MechanicalItemsQuanMade[32], MedicalItemsPrice[32], MedicalItemsQuanMade[32];

var class<Inventory> MechanicalBreakdowns[32], MedicalBreakdowns[32];
var int MechanicalBreakdownsPrice[32], MechanicalBreakdownsQuanNeeded[32], MedicalBreakdownsPrice[32], MedicalBreakdownsQuanNeeded[32];

var class<Inventory> MechanicalItemsItemReqA[32], MechanicalItemsItemReqB[32], MechanicalItemsItemReqC[32], MedicalItemsItemReqA[32], MedicalItemsItemReqB[32], MedicalItemsItemReqC[32];
var int MechanicalItemsQuanReqA[32], MechanicalItemsQuanReqB[32], MechanicalItemsQuanReqC[32], MedicalItemsQuanReqA[32], MedicalItemsQuanReqB[32], MedicalItemsQuanReqC[32];

var byte MechanicalItemsSkillReq[32], MechanicalItemsComplexity[32], MedicalItemsSkillReq[32], MedicalItemsComplexity[32];

//000000000000000000000000
//GLOSSARY!
/*static*/ function class<Inventory> GetMechanicalItemGlossary(int TArray)
{
	return MechanicalItemsGlossary[TArray];
}

/*static*/ function int GetMechanicalItemGlossaryArray(class<Inventory> TestClass)
{
	local int i, Ret;
	
	Ret = -1;
	for (i=0; i<ArrayCount(Default.MechanicalItems); i++)
	{
		if (GetMechanicalItemGlossary(i) == TestClass)
		{
			Ret = i;
			break;
		}
	}
	
	return Ret;
}

/*static*/ function class<Inventory> GetMedicalItemGlossary(int TArray)
{
	return MedicalItemsGlossary[TArray];
}

/*static*/ function int GetMedicalItemGlossaryArray(class<Inventory> TestClass)
{
	local int i, Ret;
	
	Ret = -1;
	for (i=0; i<ArrayCount(Default.MedicalItems); i++)
	{
		if (GetMedicalItemGlossary(i) == TestClass)
		{
			Ret = i;
			break;
		}
	}
	
	return Ret;
}

//111111111111111111111111
//MECHANICAL!
/*static*/ function class<Inventory> GetMechanicalItem(int TArray)
{
	return MechanicalItems[TArray];
}

/*static*/ function int GetMechanicalItemArray(class<Inventory> CheckClass)
{
	local int i;
	
	if (CheckClass == None) return -1;
	
	for(i=0; i<ArrayCount(Default.MechanicalItems); i++)
	{
		if (GetMechanicalItem(i) == CheckClass)
		{
			return i;
		}
	}
	
	return -1;
}

/*static*/ function int GetMechanicalItemPrice(class<Inventory> CheckClass)
{
	local int TArray, Ret;
	
	TArray = GetMechanicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MechanicalItemsPrice[TArray];
}

/*static*/ function int GetMechanicalItemQuanMade(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMechanicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MechanicalItemsQuanMade[TArray];
}

/*static*/ function class<Inventory> GetMechanicalItemItemReq(class<Inventory> CheckClass, int ReqNumber)
{
	local int TArray;
	
	TArray = GetMechanicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return None;
	
	switch(ReqNumber)
	{
		case 0:
			return MechanicalItemsItemReqA[TArray];
		break;
		case 1:
			return MechanicalItemsItemReqB[TArray];
		break;
		case 2:
			return MechanicalItemsItemReqC[TArray];
		break;
	}
	return None;
}

/*static*/ function int GetMechanicalItemQuanReq(class<Inventory> CheckClass, int ReqNumber)
{
	local int TArray;
	
	TArray = GetMechanicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	switch(ReqNumber)
	{
		case 0:
			return MechanicalItemsQuanReqA[TArray];
		break;
		case 1:
			return MechanicalItemsQuanReqB[TArray];
		break;
		case 2:
			return MechanicalItemsQuanReqC[TArray];
		break;
	}
	return 0;
}

/*static*/ function int GetMechanicalItemSkillReq(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMechanicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MechanicalItemsSkillReq[TArray];
}

/*static*/ function int GetMechanicalItemComplexity(class<Inventory> CheckClass, int SkillLevel)
{
	local int TArray, NeededSkill, Ret;
	
	TArray = GetMechanicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	NeededSkill = MechanicalItemsSkillReq[TArray];
	Ret = MechanicalItemsComplexity[TArray];
	
	if ((Ret == 1) && (NeededSkill == 1) && (SkillLevel > 1))
	{
		Ret = 0;
	}
	else if ((Ret == 2) && (NeededSkill == 2) && (SkillLevel > 2))
	{
		Ret = 1;
	}
	
	return Ret;
}

//222222222222222222222222
//MEDICAL!
/*static*/ function class<Inventory> GetMedicalItem(int TArray)
{
	return MedicalItems[TArray];
}

/*static*/ function int GetMedicalItemArray(class<Inventory> CheckClass)
{
	local int i;
	
	if (CheckClass == None) return -1;
	
	for(i=0; i<ArrayCount(Default.MedicalItems); i++)
	{
		if (GetMedicalItem(i) == CheckClass)
		{
			return i;
		}
	}
	
	return -1;
}

/*static*/ function int GetMedicalItemPrice(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMedicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MedicalItemsPrice[TArray];
}

/*static*/ function int GetMedicalItemQuanMade(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMedicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MedicalItemsQuanMade[TArray];
}

/*static*/ function class<Inventory> GetMedicalItemItemReq(class<Inventory> CheckClass, int ReqNumber)
{
	local int TArray;
	
	TArray = GetMedicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return None;
	
	switch(ReqNumber)
	{
		case 0:
			return MedicalItemsItemReqA[TArray];
		break;
		case 1:
			return MedicalItemsItemReqB[TArray];
		break;
		case 2:
			return MedicalItemsItemReqC[TArray];
		break;
	}
	return None;
}

/*static*/ function int GetMedicalItemQuanReq(class<Inventory> CheckClass, int ReqNumber)
{
	local int TArray;
	
	TArray = GetMedicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	switch(ReqNumber)
	{
		case 0:
			return MedicalItemsQuanReqA[TArray];
		break;
		case 1:
			return MedicalItemsQuanReqB[TArray];
		break;
		case 2:
			return MedicalItemsQuanReqC[TArray];
		break;
	}
	return 0;
}

/*static*/ function int GetMedicalItemSkillReq(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMedicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MedicalItemsSkillReq[TArray];
}

/*static*/ function int GetMedicalItemComplexity(class<Inventory> CheckClass, int SkillLevel)
{
	local int TArray, NeededSkill, Ret;
	
	TArray = GetMedicalItemArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	NeededSkill = MedicalItemsSkillReq[TArray];
	Ret = MedicalItemsComplexity[TArray];
	
	if ((Ret == 1) && (NeededSkill == 1) && (SkillLevel > 1))
	{
		Ret = 0;
	}
	else if ((Ret == 2) && (NeededSkill == 2) && (SkillLevel > 2))
	{
		Ret = 1;
	}
	
	return Ret;
}

//33333333333333333333333
//MECHANICAL BREAKDOWNS!
/*static*/ function class<Inventory> GetMechanicalBreakdown(int TArray)
{
	return MechanicalBreakdowns[TArray];
}

/*static*/ function int GetMechanicalBreakdownArray(class<Inventory> CheckClass)
{
	local int i;
	
	if (CheckClass == None) return -1;
	
	for(i=0; i<ArrayCount(Default.MechanicalBreakdowns); i++)
	{
		if (GetMechanicalBreakdown(i) == CheckClass)
		{
			return i;
		}
	}
	
	return -1;
}

/*static*/ function int GetMechanicalBreakdownPrice(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMechanicalBreakdownArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MechanicalBreakdownsPrice[TArray];
}

/*static*/ function int GetMechanicalBreakdownQuanNeeded(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMechanicalBreakdownArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MechanicalBreakdownsQuanNeeded[TArray];
}

//44444444444444444444444
//MEDICAL BREAKDOWNS
/*static*/ function class<Inventory> GetMedicalBreakdown(int TArray)
{
	return MedicalBreakdowns[TArray];
}

/*static*/ function int GetMedicalBreakdownArray(class<Inventory> CheckClass)
{
	local int i;
	
	if (CheckClass == None) return -1;
	
	for(i=0; i<ArrayCount(Default.MedicalBreakdowns); i++)
	{
		if (GetMedicalBreakdown(i) == CheckClass)
		{
			return i;
		}
	}
	
	return -1;
}

/*static*/ function int GetMedicalBreakdownPrice(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMedicalBreakdownArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MedicalBreakdownsPrice[TArray];
}

/*static*/ function int GetMedicalBreakdownQuanNeeded(class<Inventory> CheckClass)
{
	local int TArray;
	
	TArray = GetMedicalBreakdownArray(CheckClass);
	
	if (CheckClass == None || TArray < 0) return 0;
	
	return MedicalBreakdownsQuanNeeded[TArray];
}

//55555555555555555555555
//SKILL MULTS!
/*static*/ function float GetCraftSkillMult(int SkillLevel, bool bHasTalent)
{
	local int LevelDiff;
	local float TMath, Ret;
	
	SkillLevel += 1;
	if (bHasTalent)
	{
		SkillLevel *= 2;
	}
	
	LevelDiff = 12 - SkillLevel;
	TMath = Sqrt(float(LevelDiff) / 3);
	Ret = 1.0 * TMath;
	
	return Ret;
}

/*static*/ function float GetBreakdownSkillMult(int SkillLevel, bool bHasTalent)
{
	local int LevelDiff;
	local float TMath, Ret;
	
	SkillLevel += 1;
	if (bHasTalent)
	{
		SkillLevel *= 2;
	}
	
	LevelDiff = 12 - SkillLevel;
	TMath = Sqrt(float(LevelDiff) / 3);
	Ret = 1.0 / TMath;
	
	return Ret;
}

//66666666666666666666666
//DEFAULT PROPS!

defaultproperties
{
      MechanicalItemsGlossary(0)=class'VMDToolbox'
      MechanicalItemsGlossary(1)=class'VMDMEGHPickup'
      MechanicalItemsGlossary(2)=class'VMDSIDDPickup'
      MechanicalItemsGlossary(3)=class'WeaponBaton'
      MechanicalItemsGlossary(4)=class'WeaponCombatKnife'
      MechanicalItemsGlossary(5)=class'WeaponShuriken'
      MechanicalItemsGlossary(6)=class'WeaponEMPGrenade'
      MechanicalItemsGlossary(7)=class'VMDEmptyGrenade'
      MechanicalItemsGlossary(8)=class'Lockpick'
      MechanicalItemsGlossary(9)=class'Multitool'
      MechanicalItemsGlossary(10)=class'AmmoBattery'
      MechanicalItemsGlossary(11)=class'AmmoDart'
      MechanicalItemsGlossary(12)=class'Ammo10mm'
      MechanicalItemsGlossary(13)=class'Ammo3006'
      MechanicalItemsGlossary(14)=class'Ammo762mm'
      MechanicalItemsGlossary(15)=class'AmmoShell'
      MechanicalItemsGlossary(16)=class'AmmoRocketEMP'
      MechanicalItemsGlossary(17)=class'Ammo10mmHEAT'
      MechanicalItemsGlossary(18)=class'Ammo3006HEAT'
      MechanicalItemsGlossary(19)=class'AmmoSabot'
      MechanicalItemsGlossary(20)=class'AmmoRocketWP'
      
      MechanicalItems(0)=class'VMDToolbox'
      MechanicalItemsPrice(0)=50
      MechanicalItemsQuanMade(0)=1
      MechanicalItemsSkillReq(0)=1
      MechanicalItemsComplexity(0)=0
      MechanicalBreakdowns(0)=class'VMDToolbox'
      MechanicalBreakdownsPrice(0)=50
      MechanicalBreakdownsQuanNeeded(0)=1
      
      MechanicalItems(1)=class'VMDMEGHPickup'
      MechanicalItemsPrice(1)=300
      MechanicalItemsQuanMade(1)=1
      MechanicalItemsSkillReq(1)=0
      MechanicalItemsComplexity(1)=1
      MechanicalBreakdowns(1)=class'VMDMEGHPickup'
      MechanicalBreakdownsPrice(1)=200
      MechanicalBreakdownsQuanNeeded(1)=1
      
      MechanicalItems(2)=class'VMDSIDDPickup'
      MechanicalItemsPrice(2)=300
      MechanicalItemsQuanMade(2)=1
      MechanicalItemsSkillReq(2)=0
      MechanicalItemsComplexity(2)=1
      MechanicalBreakdowns(2)=class'VMDSIDDPickup'
      MechanicalBreakdownsPrice(2)=300
      MechanicalBreakdownsQuanNeeded(2)=1
      
      MechanicalItems(3)=class'WeaponBaton'
      MechanicalItemsPrice(3)=200
      MechanicalItemsQuanMade(3)=1
      MechanicalItemsSkillReq(3)=1
      MechanicalItemsComplexity(3)=1
      
      MechanicalItems(4)=class'WeaponCombatKnife'
      MechanicalItemsPrice(4)=200
      MechanicalItemsQuanMade(4)=1
      MechanicalItemsSkillReq(4)=1
      MechanicalItemsComplexity(4)=1
      
      MechanicalItems(5)=class'WeaponShuriken'
      MechanicalItemsPrice(5)=100
      MechanicalItemsQuanMade(5)=1
      MechanicalItemsSkillReq(5)=1
      MechanicalItemsComplexity(5)=1
      MechanicalBreakdowns(3)=class'WeaponShuriken'
      MechanicalBreakdownsPrice(3)=100
      MechanicalBreakdownsQuanNeeded(3)=1
      
      MechanicalItems(6)=class'WeaponEMPGrenade'
      MechanicalItemsPrice(6)=200
      MechanicalItemsQuanMade(6)=1
      MechanicalItemsSkillReq(6)=2
      MechanicalItemsComplexity(6)=1
      MechanicalItemsItemReqA(6)=class'VMDEmptyGrenade'
      MechanicalItemsQuanReqA(6)=1
      MechanicalItemsItemReqB(6)=class'AmmoBattery'
      MechanicalItemsQuanReqB(6)=8
      MechanicalBreakdowns(4)=class'WeaponEMPGrenade'
      MechanicalBreakdownsPrice(4)=250
      MechanicalBreakdownsQuanNeeded(4)=1
      
      MechanicalItems(7)=class'VMDEmptyGrenade'
      MechanicalItemsPrice(7)=150
      MechanicalItemsQuanMade(7)=1
      MechanicalItemsSkillReq(7)=1
      MechanicalItemsComplexity(7)=1
      MechanicalBreakdowns(5)=class'VMDEmptyGrenade'
      MechanicalBreakdownsPrice(5)=150
      MechanicalBreakdownsQuanNeeded(5)=1
      
      MechanicalItems(8)=class'Lockpick'
      MechanicalItemsPrice(8)=300
      MechanicalItemsQuanMade(8)=1
      MechanicalItemsSkillReq(8)=2
      MechanicalItemsComplexity(8)=1
      MechanicalBreakdowns(6)=class'Lockpick'
      MechanicalBreakdownsPrice(6)=300
      MechanicalBreakdownsQuanNeeded(6)=1
      
      MechanicalItems(9)=class'Multitool'
      MechanicalItemsPrice(9)=300
      MechanicalItemsQuanMade(9)=1
      MechanicalItemsSkillReq(9)=2
      MechanicalItemsComplexity(9)=1
      MechanicalBreakdowns(7)=class'Multitool'
      MechanicalBreakdownsPrice(7)=300
      MechanicalBreakdownsQuanNeeded(7)=1
      
      MechanicalItems(10)=class'AmmoBattery'
      MechanicalItemsPrice(10)=200
      MechanicalItemsQuanMade(10)=8
      MechanicalItemsSkillReq(10)=2
      MechanicalItemsComplexity(10)=1
      MechanicalBreakdowns(8)=class'AmmoBattery'
      MechanicalBreakdownsPrice(8)=200
      MechanicalBreakdownsQuanNeeded(8)=8
      
      MechanicalItems(11)=class'Ammo10mm'
      MechanicalItemsPrice(11)=200
      MechanicalItemsQuanMade(11)=6
      MechanicalItemsSkillReq(11)=2
      MechanicalItemsComplexity(11)=2
      MechanicalItemsItemReqA(11)=class'AmmoShell'
      MechanicalItemsQuanReqA(11)=8
      MechanicalBreakdowns(9)=class'Ammo10mm'
      MechanicalBreakdownsPrice(9)=100
      MechanicalBreakdownsQuanNeeded(9)=6
      
      MechanicalItems(12)=class'Ammo3006'
      MechanicalItemsPrice(12)=200
      MechanicalItemsQuanMade(12)=6
      MechanicalItemsSkillReq(12)=2
      MechanicalItemsComplexity(12)=2
      MechanicalItemsItemReqA(12)=class'Ammo762mm'
      MechanicalItemsQuanReqA(12)=30
      MechanicalBreakdowns(10)=class'Ammo3006'
      MechanicalBreakdownsPrice(10)=100
      MechanicalBreakdownsQuanNeeded(10)=6
      
      MechanicalItems(13)=class'Ammo762mm'
      MechanicalItemsPrice(13)=200
      MechanicalItemsQuanMade(13)=30
      MechanicalItemsSkillReq(13)=2
      MechanicalItemsComplexity(13)=2
      MechanicalItemsItemReqA(13)=class'Ammo3006'
      MechanicalItemsQuanReqA(13)=6
      MechanicalBreakdowns(11)=class'Ammo762mm'
      MechanicalBreakdownsPrice(11)=100
      MechanicalBreakdownsQuanNeeded(11)=30
      
      MechanicalItems(14)=class'AmmoShell'
      MechanicalItemsPrice(14)=200
      MechanicalItemsQuanMade(14)=8
      MechanicalItemsSkillReq(14)=2
      MechanicalItemsComplexity(14)=2
      MechanicalItemsItemReqA(14)=class'Ammo10mm'
      MechanicalItemsQuanReqA(14)=6
      MechanicalBreakdowns(12)=class'AmmoShell'
      MechanicalBreakdownsPrice(12)=100
      MechanicalBreakdownsQuanNeeded(12)=8
      
      MechanicalItems(15)=class'AmmoRocketEMP'
      MechanicalItemsPrice(15)=200
      MechanicalItemsQuanMade(15)=4
      MechanicalItemsSkillReq(15)=3
      MechanicalItemsComplexity(15)=2
      MechanicalItemsItemReqA(15)=class'AmmoRocket'
      MechanicalItemsQuanReqA(15)=4
      MechanicalItemsItemReqB(15)=class'WeaponEMPGrenade'
      MechanicalItemsQuanReqB(15)=1
      MechanicalBreakdowns(13)=class'AmmoRocketEMP'
      MechanicalBreakdownsPrice(13)=300
      MechanicalBreakdownsQuanNeeded(13)=4
      
      MechanicalItems(16)=class'Ammo10mmHEAT'
      MechanicalItemsPrice(16)=200
      MechanicalItemsQuanMade(16)=12
      MechanicalItemsSkillReq(16)=3
      MechanicalItemsComplexity(16)=2
      MechanicalItemsItemReqA(16)=class'Ammo10mm'
      MechanicalItemsQuanReqA(16)=6
      MechanicalItemsItemReqB(16)=class'AmmoSabot'
      MechanicalItemsQuanReqB(16)=6
      MechanicalItemsItemReqC(16)=class'WeaponLAM'
      MechanicalItemsQuanReqC(16)=1
      MechanicalBreakdowns(14)=class'Ammo10mmHEAT'
      MechanicalBreakdownsPrice(14)=350
      MechanicalBreakdownsQuanNeeded(14)=6
      
      MechanicalItems(17)=class'Ammo3006HEAT'
      MechanicalItemsPrice(17)=200
      MechanicalItemsQuanMade(17)=6
      MechanicalItemsSkillReq(17)=3
      MechanicalItemsComplexity(17)=2
      MechanicalItemsItemReqA(17)=class'Ammo3006'
      MechanicalItemsQuanReqA(17)=6
      MechanicalItemsItemReqB(17)=class'AmmoSabot'
      MechanicalItemsQuanReqB(17)=6
      MechanicalItemsItemReqC(17)=class'WeaponLAM'
      MechanicalItemsQuanReqC(17)=1
      MechanicalBreakdowns(15)=class'Ammo3006HEAT'
      MechanicalBreakdownsPrice(15)=350
      MechanicalBreakdownsQuanNeeded(15)=6
      
      MechanicalItems(18)=class'AmmoSabot'
      MechanicalItemsPrice(18)=200
      MechanicalItemsQuanMade(18)=8
      MechanicalItemsSkillReq(18)=2
      MechanicalItemsComplexity(18)=2
      MechanicalItemsItemReqA(18)=class'AmmoShell'
      MechanicalItemsQuanReqA(18)=8
      MechanicalBreakdowns(16)=class'AmmoSabot'
      MechanicalBreakdownsPrice(16)=250
      MechanicalBreakdownsQuanNeeded(16)=8
      
      MechanicalItems(19)=class'AmmoRocketWP'
      MechanicalItemsPrice(19)=200
      MechanicalItemsQuanMade(19)=4
      MechanicalItemsSkillReq(19)=3
      MechanicalItemsComplexity(19)=2
      MechanicalItemsItemReqA(19)=class'AmmoRocket'
      MechanicalItemsQuanReqA(19)=4
      MechanicalItemsItemReqB(19)=class'AmmoNapalm'
      MechanicalItemsQuanReqB(19)=100
      MechanicalBreakdowns(17)=class'AmmoRocketWP'
      MechanicalBreakdownsPrice(17)=350
      MechanicalBreakdownsQuanNeeded(17)=4
      
      MechanicalItems(20)=class'AmmoDart'
      MechanicalItemsPrice(20)=300
      MechanicalItemsQuanMade(20)=4
      MechanicalItemsSkillReq(20)=1
      MechanicalItemsComplexity(20)=1
      MechanicalBreakdowns(18)=class'AmmoDart'
      MechanicalBreakdownsPrice(18)=350
      MechanicalBreakdownsQuanNeeded(18)=4
      
      MedicalItemsGlossary(0)=class'VMDChemistrySet'
      MedicalItemsGlossary(1)=class'VMDMedigel'
      MedicalItemsGlossary(2)=class'VMDCombatStim'
      MedicalItemsGlossary(3)=class'Flare'
      MedicalItemsGlossary(4)=class'BioelectricCell'
      MedicalItemsGlossary(5)=class'Medkit'
      MedicalItemsGlossary(6)=class'AmmoDartFlare'
      MedicalItemsGlossary(7)=class'AmmoDartPoison'
      MedicalItemsGlossary(8)=class'AmmoPepper'
      MedicalItemsGlossary(9)=class'WeaponGasGrenade'
      MedicalItemsGlossary(10)=class'AmmoNapalm'
      MedicalItemsGlossary(11)=class'Cigarettes'
      MedicalItemsGlossary(12)=class'LiquorBottle'
      MedicalItemsGlossary(13)=class'Liquor40oz'
      MedicalItemsGlossary(14)=class'WineBottle'
      MedicalItemsGlossary(15)=class'FireExtinguisher'
      MedicalItemsGlossary(16)=class'VialCrack'
      MedicalItemsGlossary(17)=class'Ammo10mmGasCap'
      MedicalItemsGlossary(18)=class'Ammo3006Tranq'
      MedicalItemsGlossary(19)=class'AmmoPlasmaPlague'
      
      MedicalItems(0)=class'VMDChemistrySet'
      MedicalItemsPrice(0)=50
      MedicalItemsQuanMade(0)=1
      MedicalItemsSkillReq(0)=1
      MedicalItemsComplexity(0)=0
      MedicalBreakdowns(0)=class'VMDChemistrySet'
      MedicalBreakdownsPrice(0)=50
      MedicalBreakdownsQuanNeeded(0)=1
      
      MedicalItems(1)=class'VMDMedigel'
      MedicalItemsPrice(1)=150
      MedicalItemsQuanMade(1)=1
      MedicalItemsSkillReq(1)=0
      MedicalItemsComplexity(1)=1
      MedicalBreakdowns(1)=class'VMDMedigel'
      MedicalBreakdownsPrice(1)=150
      MedicalBreakdownsQuanNeeded(1)=1
      
      MedicalItems(2)=class'VMDCombatStim'
      MedicalItemsPrice(2)=400
      MedicalItemsQuanMade(2)=1
      MedicalItemsSkillReq(2)=0
      MedicalItemsComplexity(2)=3
      MedicalBreakdowns(2)=class'VMDCombatStim'
      MedicalBreakdownsPrice(2)=400
      MedicalBreakdownsQuanNeeded(2)=1
      
      MedicalItems(3)=class'Flare'
      MedicalItemsPrice(3)=75
      MedicalItemsQuanMade(3)=1
      MedicalItemsSkillReq(3)=1
      MedicalItemsComplexity(3)=1
      MedicalBreakdowns(3)=class'Flare'
      MedicalBreakdownsPrice(3)=75
      MedicalBreakdownsQuanNeeded(3)=1
      
      MedicalItems(4)=class'BioelectricCell'
      MedicalItemsPrice(4)=300
      MedicalItemsQuanMade(4)=1
      MedicalItemsSkillReq(4)=2
      MedicalItemsComplexity(4)=1
      MedicalBreakdowns(4)=class'BioelectricCell'
      MedicalBreakdownsPrice(4)=300
      MedicalBreakdownsQuanNeeded(4)=1
      
      MedicalItems(5)=class'Medkit'
      MedicalItemsPrice(5)=300
      MedicalItemsQuanMade(5)=1
      MedicalItemsSkillReq(5)=1
      MedicalItemsComplexity(5)=1
      MedicalBreakdowns(5)=class'Medkit'
      MedicalBreakdownsPrice(5)=300
      MedicalBreakdownsQuanNeeded(5)=1
      
      MedicalItems(6)=class'AmmoDartFlare'
      MedicalItemsPrice(6)=200
      MedicalItemsQuanMade(6)=4
      MedicalItemsSkillReq(6)=2
      MedicalItemsComplexity(6)=1
      MedicalItemsItemReqA(6)=class'AmmoDart'
      MedicalItemsQuanReqA(6)=4
      MedicalItemsItemReqB(6)=class'Flare'
      MedicalItemsQuanReqB(6)=1
      MedicalBreakdowns(6)=class'AmmoDartFlare'
      MedicalBreakdownsPrice(6)=200
      MedicalBreakdownsQuanNeeded(6)=4
      
      MedicalItems(7)=class'AmmoDartPoison'
      MedicalItemsPrice(7)=200
      MedicalItemsQuanMade(7)=4
      MedicalItemsSkillReq(7)=1
      MedicalItemsComplexity(7)=1
      MedicalItemsItemReqA(7)=class'AmmoDart'
      MedicalItemsQuanReqA(7)=4
      MedicalBreakdowns(7)=class'AmmoDartPoison'
      MedicalBreakdownsPrice(7)=200
      MedicalBreakdownsQuanNeeded(7)=4
      
      MedicalItems(8)=class'AmmoPepper'
      MedicalItemsPrice(8)=200
      MedicalItemsQuanMade(8)=100
      MedicalItemsSkillReq(8)=1
      MedicalItemsComplexity(8)=1
      MedicalBreakdowns(8)=class'AmmoPepper'
      MedicalBreakdownsPrice(8)=200
      MedicalBreakdownsQuanNeeded(8)=100
      
      MedicalItems(9)=class'WeaponGasGrenade'
      MedicalItemsPrice(9)=200
      MedicalItemsQuanMade(9)=1
      MedicalItemsSkillReq(9)=2
      MedicalItemsComplexity(9)=1
      MedicalItemsItemReqA(9)=class'AmmoPepper'
      MedicalItemsQuanReqA(9)=100
      MedicalItemsItemReqB(9)=class'VMDEmptyGrenade'
      MedicalItemsQuanReqB(9)=1
      MedicalBreakdowns(9)=class'WeaponGasGrenade'
      MedicalBreakdownsPrice(9)=250
      MedicalBreakdownsQuanNeeded(9)=1
      
      MedicalItems(10)=class'AmmoNapalm'
      MedicalItemsPrice(10)=200
      MedicalItemsQuanMade(10)=100
      MedicalItemsSkillReq(10)=2
      MedicalItemsComplexity(10)=3
      MedicalItemsItemReqA(10)=class'WeaponGasGrenade'
      MedicalItemsQuanReqA(10)=1
      MedicalBreakdowns(10)=class'AmmoNapalm'
      MedicalBreakdownsPrice(10)=300
      MedicalBreakdownsQuanNeeded(10)=100
      
      MedicalBreakdowns(11)=class'Cigarettes'
      MedicalBreakdownsPrice(11)=50
      MedicalBreakdownsQuanNeeded(11)=1
      MedicalBreakdowns(12)=class'LiquorBottle'
      MedicalBreakdownsPrice(12)=75
      MedicalBreakdownsQuanNeeded(12)=1
      MedicalBreakdowns(13)=class'Liquor40oz'
      MedicalBreakdownsPrice(13)=50
      MedicalBreakdownsQuanNeeded(13)=1
      MedicalBreakdowns(14)=class'WineBottle'
      MedicalBreakdownsPrice(14)=75
      MedicalBreakdownsQuanNeeded(14)=1
      MedicalBreakdowns(15)=class'FireExtinguisher'
      MedicalBreakdownsPrice(15)=150
      MedicalBreakdownsQuanNeeded(15)=1
      
      MedicalItems(11)=class'VialCrack'
      MedicalItemsPrice(11)=400
      MedicalItemsQuanMade(11)=1
      MedicalItemsSkillReq(11)=3
      MedicalItemsComplexity(11)=2
      MedicalBreakdowns(16)=class'VialCrack'
      MedicalBreakdownsPrice(16)=200
      MedicalBreakdownsQuanNeeded(16)=1
      
      MedicalItems(12)=class'Ammo10mmGasCap'
      MedicalItemsPrice(12)=200
      MedicalItemsQuanMade(12)=6
      MedicalItemsSkillReq(12)=2
      MedicalItemsComplexity(12)=3
      MedicalItemsItemReqA(12)=class'Ammo10mm'
      MedicalItemsQuanReqA(12)=6
      MedicalItemsItemReqB(12)=class'AmmoPepper'
      MedicalItemsQuanReqB(12)=50
      MedicalBreakdowns(17)=class'Ammo10mmGasCap'
      MedicalBreakdownsPrice(17)=300
      MedicalBreakdownsQuanNeeded(17)=6
      
      MedicalItems(13)=class'Ammo3006Tranq'
      MedicalItemsPrice(13)=200
      MedicalItemsQuanMade(13)=6
      MedicalItemsSkillReq(13)=2
      MedicalItemsComplexity(13)=3
      MedicalItemsItemReqA(13)=class'Ammo3006'
      MedicalItemsQuanReqA(13)=6
      MedicalItemsItemReqB(13)=class'AmmoDartPoison'
      MedicalItemsQuanReqB(13)=4
      MedicalBreakdowns(18)=class'Ammo3006Tranq'
      MedicalBreakdownsPrice(18)=300
      MedicalBreakdownsQuanNeeded(18)=6
      
      MedicalItems(14)=class'AmmoPlasmaPlague'
      MedicalItemsPrice(14)=200
      MedicalItemsQuanMade(14)=12
      MedicalItemsSkillReq(14)=2
      MedicalItemsComplexity(14)=3
      MedicalItemsItemReqA(14)=class'AmmoPlasma'
      MedicalItemsQuanReqA(14)=12
      MedicalItemsItemReqB(14)=class'BioelectricCell'
      MedicalItemsQuanReqB(14)=2
      MedicalBreakdowns(19)=class'AmmoPlasmaPlague'
      MedicalBreakdownsPrice(19)=300
      MedicalBreakdownsQuanNeeded(19)=12
}