//=============================================================================
// AugTarget.
//=============================================================================
class AugTarget extends VMDBufferAugmentation;

var float mpAugValue, mpEnergyDrain;

// ----------------------------------------------------------------------------
// Network Replication
// ----------------------------------------------------------------------------

replication
{
   	//Server to client function replication
   	reliable if (Role == ROLE_Authority)
      		SetTargetingAugStatus;
}

state Active
{
	Begin:
   		SetTargetingAugStatus(CurrentLevel, True);
}

function Deactivate()
{
	Super.Deactivate();
	
   	SetTargetingAugStatus(CurrentLevel, False);
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
 	
 	if (!DXW.bHandToHand && (!DXW.bInstantHit || DXW.bPenetrating))
 	{
  		return 1.0-(LevelValues[CurrentLevel]*2.0);
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
			Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(Abs(LevelValues[i]*50)), int((abs(LevelValues[i]) * 200) + 0.5));
		}
		else
		{
			Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], Left(TBarf, InPos), int((abs(LevelValues[i]) * 200) + 0.5));
		}
	}
	
	return Ret;
}

//MADDERS, 6/26/24: Fix for targeting not rebooting after we start.
//Sometimes we're also out of range and in stasis, so tick can't save us. Great to see.
function VMDAugWasPoked()
{
	SetTargetingAugStatus(CurrentLevel, bIsActive);
}

defaultproperties
{
     bBulkAugException=True
     AdvancedDescription="Image-scaling and recognition provided by multiplexing the optic nerve with doped polyacetylene 'quantum wires' not only increases accuracy, but also delivers limited situational info about a target."
     AdvancedDescLevels(0)="TECH ONE: %d%% increase in accuracy, %d%% increase in ranged, non-thrown damage, and general target information."
     AdvancedDescLevels(1)="TECH TWO: %d%% increase in accuracy, %d%% increase in ranged, non-thrown damage, and more target information."
     AdvancedDescLevels(2)="TECH THREE: %d%% increase in accuracy, %d%% increase in ranged, non-thrown damage, and specific target information."
     AdvancedDescLevels(3)="TECH FOUR: %d%% increase in accuracy, %d%% increase in ranged, non-thrown damage, and telescopic vision."
     
     mpAugValue=-0.125000
     mpEnergyDrain=40.000000
     EnergyRate=40.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconTarget'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconTarget_Small'
     AugmentationName="Targeting"
     Description="Image-scaling and recognition provided by multiplexing the optic nerve with doped polyacetylene 'quantum wires' not only increases accuracy, but also delivers limited situational info about a target.|n|nTECH ONE: 2.5% increase in accuracy, 5% increase in damage, and general target information.|n|nTECH TWO: 5% increase in accuracy, 10% increase in damage, and more target information.|n|nTECH THREE: 7.5% increase in accuracy, 15% increase in damage, and specific target information.|n|nTECH FOUR: 10% increase in accuracy, 20% increase in damage, and telescopic vision."
     MPInfo="When active, all weapon skills are effectively increased by one level, and you can see an enemy's health.  The skill increases allow you to effectively surpass skill level 3.  Energy Drain: Moderate"
     LevelValues(0)=-0.050000
     LevelValues(1)=-0.100000
     LevelValues(2)=-0.150000
     LevelValues(3)=-0.200000
     AugmentationLocation=LOC_Eye
     MPConflictSlot=4
}
