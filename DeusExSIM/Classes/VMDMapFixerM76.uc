//=============================================================================
// VMDMapFixerM76.
//=============================================================================
class VMDMapFixerM76 extends VMDMapFixer;

//MADDERS: We got a whole fucking orgy of things to fix. Switch/case to save power like a mother fucker.
function CommitMapFixing(out string MapName, out FlagBase Flags, out VMDBufferPlayer VMP, out class<VMDStaticFunctions> SF)
{
	Super.CommitMapFixing(MapName, Flags, VMP, SF);
	
	switch(MapName)
	{
		//76_ZODIAC_EGYPT_EBASE: Upgrade Z1 with new shit.
		case "76_ZODIAC_EGYPT_EBASE":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				//MADDERS, 4/29/25: Hela is very similar to Anna Navarre, so not much room for creativity.
				VMBP = VMDBufferPawn(TPawn);
				if ((VMBP != None) && (VMBP.IsA('Z1')))
				{
					VMBP.bHasAugmentations = true;
					VMBP.bMechAugs = true;
					VMBP.Energy = 80;
					VMBP.EnergyMax = 80;
					VMBP.AddToInitialInventory(class'BioelectricCell', 6);
					VMBP.AddToInitialInventory(class'VMDMedigel', 5);
					VMBP.VMDWipeAllAugs();
					VMBP.DefaultAugs[0] = class'AugMechCloak';
					VMBP.DefaultAugs[1] = class'AugMechDermal';
					VMBP.DefaultAugs[2] = class'AugMechEnviro';
					VMBP.DefaultAugs[3] = class'AugMechSpeed';
					VMBP.DefaultAugs[4] = class'AugMechTarget';
					VMBP.DefaultAugs[5] = class'AugMechEnergy';
					VMBP.DefaultAugs[6] = class'AugMechEMP';
					VMBP.VMDInitializeSubsystems();
					
					VMBP.HealthHead = 400;
					VMBP.HealthTorso = 400;
					VMBP.HealthArmLeft = 400;
					VMBP.HealthArmRight = 400;
					VMBP.HealthLegLeft = 400;
					VMBP.HealthLegRight = 400;
					VMBP.Health = 400;
					VMBP.StartingHealthValues[0] = VMBP.HealthHead;
					VMBP.StartingHealthValues[1] = VMBP.HealthTorso;
					VMBP.StartingHealthValues[2] = VMBP.HealthArmLeft;
					VMBP.StartingHealthValues[3] = VMBP.HealthArmRight;
					VMBP.StartingHealthValues[4] = VMBP.HealthLegLeft;
					VMBP.StartingHealthValues[5] = VMBP.HealthLegRight;
					VMBP.StartingHealthValues[6] = VMBP.Health;
				}
			}
		break;
	}
}

defaultproperties
{
}
