//=============================================================================
// AugMechMuscle.
//=============================================================================
class AugMechMuscle extends VMDMechAugmentation;

state Active
{
Begin:
}

function Deactivate()
{
	Super.Deactivate();
	
	if (Player != None)
	{
		// check to see if the player is carrying something too heavy for him
		if (Player.CarriedDecoration != None)
		{
			if (!Player.CanBeLifted(Player.CarriedDecoration))
			{
				Player.DropDecoration();
			}
		}
		else if ((VMDPOVDeco(Player.InHand) != None) && (VMDBufferPlayer(Player) != None))
		{
			if (!VMDBufferPlayer(Player).CanPOVBeLifted(VMDPOVDeco(Player.InHand)))
			{
				Player.DropDecoration();
			}
		}
	}
}

simulated function float GetEnergyRate()
{
	return 0.0;
}

function float VMDConfigureDecoPushMult()
{
 	return LevelValues[CurrentLevel]*2;
}

function float VMDConfigureDecoThrowMult()
{
	return (CurrentLevel+2.0) / 2.0;
}

function float VMDConfigureDecoLiftMult()
{
	return LevelValues[CurrentLevel];
}

function string VMDGetAdvancedDescription()
{
	local int i;
	local string Ret;
	
	Ret = AdvancedDescription;
	
	for (i=0; i<= MaxLevel; i++)
	{
		Ret = Ret$"|n|n"$SprintF(AdvancedDescLevels[i], int(((LevelValues[i] - 1.0) * 100) + 0.5));
	}
	
	return Ret;
}

defaultproperties
{
     AdvancedDescription="Cybernetic arm prosthesis that enhances the user's strength to several fold that of a standard human."
     AdvancedDescLevels(0)="TECH ONE: Strength is increased slightly, at %d%% more lifting strength."
     AdvancedDescLevels(1)="TECH TWO: Strength is increased moderately, at %d%% more lifting strength."
     AdvancedDescLevels(2)="TECH THREE: Strength is increased significantly, at %d%% more lifting strength."
     AdvancedDescLevels(3)="TECH FOUR: An agent is inhumanly strong, at %d%% more lifting strength."
     
     ActivateSound=None
     DeActivateSound=None
     bPassive=True
     
     EnergyRate=0.000000
     Icon=Texture'DeusExUI.UserInterface.AugIconMuscle'
     smallIcon=Texture'DeusExUI.UserInterface.AugIconMuscle_Small'
     AugmentationName="Heavy Cyberetic Arms"
     LevelValues(0)=1.500000
     LevelValues(1)=2.000000
     LevelValues(2)=2.500000
     LevelValues(3)=3.000000
     AugmentationLocation=LOC_Arm
     MPConflictSlot=8
}
