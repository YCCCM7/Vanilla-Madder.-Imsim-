//=============================================================================
// AmmoRocketWP.
//=============================================================================
class AmmoRocketWP extends AmmoRocket;

//Oops. Negate crate swapping for WP rockets to EMP rockets.
function VMDAttemptCrateSwap(int Seed)
{
 	Super(DeusExAmmo).VMDAttemptCrateSwap(Seed);
}

function ProcessVMDChanges()
{
	local bool bTripped;
 	local int Seed, AltSeed[3];
	local VMDBufferPlayer VMP;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if (VMP != None)
	{
		AltSeed[0] = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 5, True);
		AltSeed[1] = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 3, True);
		AltSeed[2] = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self, 2, True);
		if (class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Loot Swap") || class'VMDStaticFunctions'.Static.VMDUseDifficultyModifier(VMP, "Loot Deletion"))
		{
			if ((AltSeed[1] == 2) && (VMP.SavedLootSwapSeverity > 0))
			{
				bTripped = true;
			}
			if ((AltSeed[1] == 4) && (VMP.SavedLootSwapSeverity > 1))
			{
				bTripped = true;
			}
			if ((AltSeed[2] == 2) && (VMP.SavedLootSwapSeverity > 2))
			{
				bTripped = true;
			}
		}
		
		//MADDERS, 11/12/24: Lower our ammo count for balancing sake.
		if (bTripped)
		{
			AmmoAmount *= 0.75;
		}
	}
	
 	Super.ProcessVMDChanges();
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
 	if ((Owner == None) && (!bCrateSummoned))
	{
 		if (Seed == 4) // || Seed == 7 || Seed == 9
		{
			ReplaceWithEMP();
		}
	}
}

defaultproperties
{
     Mass=16.000000
     bNameCaseSensitive=True
     bVolatile=True
     
     ItemName="WP Rockets"
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoWPRockets'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoWPRockets'
     largeIconWidth=45
     largeIconHeight=37
     Description="The white-phosphorus rocket, or 'wooly peter,' was designed to expand the mission profile of the GEP gun. While it does minimal damage upon detonation, the explosion will spread a cloud of particularized white phosphorus that ignites immediately upon contact with the air."
     beltDescription="WP ROCKET"
     Skin=Texture'DeusExItems.Skins.GEPAmmoTex2'
}
