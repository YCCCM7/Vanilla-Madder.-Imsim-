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
		//76_ZODIAC_EGYPT_ENTRANCE: Add more pathing for MEGH.
		case "76_ZODIAC_EGYPT_ENTRANCE":
			Spawn(class'PathNodeMobile',,, Vect(8880,3725,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8892,4029,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8874,4295,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8900,4431,-2233));
			Spawn(class'PathNodeMobile',,, Vect(9344,4444,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8401,4432,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8403,4829,-2233));
			Spawn(class'PathNodeMobile',,, Vect(9372,4867,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8860,5287,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8433,5815,-2233));
			Spawn(class'PathNodeMobile',,, Vect(8112,5554,-2233));
			Spawn(class'PathNodeMobile',,, Vect(7604,5243,-2233));
			Spawn(class'PathNodeMobile',,, Vect(7212,4934,-2233));
			Spawn(class'PathNodeMobile',,, Vect(7207,4666,-2233));
			Spawn(class'PathNodeMobile',,, Vect(7208,4184,-2233));
			Spawn(class'PathNodeMobile',,, Vect(7036,4178,-2233));
			Spawn(class'PathNodeMobile',,, Vect(7040,3469,-2393));
			Spawn(class'PathNodeMobile',,, Vect(6746,3648,-2393));
			Spawn(class'PathNodeMobile',,, Vect(7012,3919,-2290));
			Spawn(class'PathNodeMobile',,, Vect(3148,2690,127));
			Spawn(class'PathNodeMobile',,, Vect(2902,2697,111));
			Spawn(class'PathNodeMobile',,, Vect(2443,2688,25));
			Spawn(class'PathNodeMobile',,, Vect(2108,2676,15));
			Spawn(class'PathNodeMobile',,, Vect(143,3248,15));
			Spawn(class'PathNodeMobile',,, Vect(583,3246,15));
			Spawn(class'PathNodeMobile',,, Vect(142,-2855,15));
			Spawn(class'PathNodeMobile',,, Vect(134,-3211,15));
			Spawn(class'PathNodeMobile',,, Vect(373,-3236,15));
			Spawn(class'PathNodeMobile',,, Vect(647,-3222,-113));
			Spawn(class'PathNodeMobile',,, Vect(643,-3295,-113));
			Spawn(class'PathNodeMobile',,, Vect(652,-3542,-225));
			Spawn(class'PathNodeMobile',,, Vect(709,-3539,-225));
			Spawn(class'PathNodeMobile',,, Vect(998,-3544,-352));
			VMP.VMDRebuildPaths();
		break;
		//76_ZODIAC_EGYPT_REACTOR: Add more pathing for MEGH.
		case "76_ZODIAC_EGYPT_REACTOR":
			Spawn(class'PathNodeMobile',,, Vect(9879,2556,63));
			Spawn(class'PathNodeMobile',,, Vect(9242,2542,63));
			Spawn(class'PathNodeMobile',,, Vect(9058,1913,63));
			Spawn(class'PathNodeMobile',,, Vect(6057,1224,63));
			Spawn(class'PathNodeMobile',,, Vect(9093,665,63));
			Spawn(class'PathNodeMobile',,, Vect(9197,786,63));
			Spawn(class'PathNodeMobile',,, Vect(9093,887,63));
			Spawn(class'PathNodeMobile',,, Vect(9091,171,63));
			Spawn(class'PathNodeMobile',,, Vect(9076,564,63));
			Spawn(class'PathNodeMobile',,, Vect(9165,483,63));
			Spawn(class'PathNodeMobile',,, Vect(9076,307,63));
			Spawn(class'PathNodeMobile',,, Vect(9143,558,63));
			Spawn(class'PathNodeMobile',,, Vect(988,-3544,-353));
			Spawn(class'PathNodeMobile',,, Vect(-40,-840,-801));
			Spawn(class'PathNodeMobile',,, Vect(105,-873,-801));
			Spawn(class'PathNodeMobile',,, Vect(215,-667,-801));
			Spawn(class'PathNodeMobile',,, Vect(138,-500,-801));
			Spawn(class'PathNodeMobile',,, Vect(143,-14,-801));
			Spawn(class'PathNodeMobile',,, Vect(-994,3,-798));
			Spawn(class'PathNodeMobile',,, Vect(-1444,7,-797));
			Spawn(class'PathNodeMobile',,, Vect(-1954,32,-797));
			Spawn(class'PathNodeMobile',,, Vect(-829,-20,-801));
			Spawn(class'PathNodeMobile',,, Vect(-555,-3,-801));
			Spawn(class'PathNodeMobile',,, Vect(-197,-1,-801));
			Spawn(class'PathNodeMobile',,, Vect(1118,-1022,-12817));
			Spawn(class'PathNodeMobile',,, Vect(1257,-852,-12817));
			Spawn(class'PathNodeMobile',,, Vect(1065,-698,-12817));
			VMP.VMDRebuildPaths();
		break;
		//76_ZODIAC_EGYPT_EBASE: Upgrade Z1 with new shit.
		case "76_ZODIAC_EGYPT_EBASE":
			for(TPawn = Level.PawnList; TPawn != None; TPawn = TPawn.NextPawn)
			{
				//MADDERS, 4/29/25: Z1 is very similar to Anna Navarre, so not much room for creativity.
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
