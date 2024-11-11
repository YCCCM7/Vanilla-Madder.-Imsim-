//=============================================================================
// AugMechTarget.
//=============================================================================
class AugMechTarget extends VMDMechAugmentation;

state Active
{
	Begin:
   		SetTargetingAugStatus(CurrentLevel,True);
}

function Deactivate()
{
	Super.Deactivate();
	
   	SetTargetingAugStatus(CurrentLevel,False);
}

// ----------------------------------------------------------------------
// SetTargetingAugStatus()
// ----------------------------------------------------------------------

simulated function SetTargetingAugStatus(int Level, bool IsActive)
{
	local DeusExRootWindow DXRW;
	
	if (Player != None)
	{
		DXRW = DeusExRootWindow(Player.RootWindow);
		
		if ((DXRW != None) && (DXRW.AugDisplay != None))
		{
			DXRW.AugDisplay.bTargetActive = IsActive;
			DXRW.AugDisplay.targetLevel = Level;
		}
	}
}

function float VMDConfigureWepDamageMult(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 1.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 1.0;
 	
 	if ((!DXW.bHandToHand) && (TSkill != class'SkillWeaponLowTech') && (TSkill != class'SkillDemolition'))
 	{
  		return 1.0-LevelValues[CurrentLevel];
 	}
 	
 	return 1.0;
}

function float VMDConfigureWepAccuracyMod(DeusExWeapon DXW)
{
 	local class<Skill> TSkill;
 	
 	if (DXW == None) return 0.0;
 	TSkill = DXW.GoverningSkill;
 	if (TSkill == None) return 0.0;
 	
 	return LevelValues[CurrentLevel];
}

function string VMDGetAdvancedDescription()
{
	local int i, InPos;
	local string Ret, TBarf;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		TBarf = String(abs(LevelValues[i]) * 50);
		InPos = InStr(TBarf, ".")+2;
		
		if (float(int(abs(LevelValues[i] * 50))) ~= abs(LevelValues[i] * 50))
		{
			Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(Abs(LevelValues[i]*50)), int((abs(LevelValues[i]) * 100) + 0.5));
		}
		else
		{
			Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], Left(TBarf, InPos), int((abs(LevelValues[i]) * 100) + 0.5));
		}
	}
	
	return Ret;
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="A cyber arm prosthesis that stabilizes the aim of the user for better accuracy."
     AdvancedDescLevels(0)="TECH ONE: %d%% increase in accuracy, %d%% increase in damage, and general target information."
     AdvancedDescLevels(1)="TECH TWO: %d%% increase in accuracy, %d%% increase in damage, and more target information."
     MaxLevel=1
     
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconTarget'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconTarget_Small'
     AugmentationName="Aim Stabilizer"
     LevelValues(0)=-0.100000
     LevelValues(1)=-0.200000
     AugmentationLocation=LOC_Arm
}
