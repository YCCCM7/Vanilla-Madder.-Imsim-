//=============================================================================
// AmmoRocket.
//=============================================================================
class AmmoRocket extends DeusExAmmo;

//MADDERS: Replace old versions with EMP ammo, when appropriate
function ReplaceWithEMP()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
 	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'AmmoRocketEMP',,,Location - TVect, Rotation);
 	Rep.bOwned = bOwned;
	Rep.bSuperOwned = bSuperOwned;
 	
 	//Check for success! If not? Lock us down.
 	if (Rep != None) Destroy();
 	else bCrateSummoned = true;
}

//MADDERS: Do this nonsense for dropping swapped ammos.
function VMDAttemptCrateSwap(int Seed)
{
	local DeusExLevelInfo DXLI;
 	
 	Super.VMDAttemptCrateSwap(Seed);
 	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
 	if (Seed == 4) // || Seed == 7 || Seed == 9
	{
		ReplaceWithEMP();
	}
}

function ProcessVMDChanges()
{
 	local bool bTripped;
	local int Seed, AltSeed[3];
 	local VMDBufferPlayer VMP;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
	VMP = VMDBufferPlayer(GetPlayerPawn());
	if ((VMP != None) && (Owner == None))
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
			AmmoAmount *= 0.5;
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
     bVolatile=True
     
     bShowInfo=True
     AmmoAmount=4
     MaxAmmo=20
     ItemName="Rockets"
     ItemArticle="some"
     PickupViewMesh=LodMesh'DeusExItems.GEPAmmo'
     LandSound=Sound'DeusExSounds.Generic.WoodHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoRockets'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoRockets'
     largeIconWidth=46
     largeIconHeight=36
     Description="A gyroscopically stabilized rocket with limited onboard guidance systems for in-flight course corrections. Engineered for use with the GEP gun."
     beltDescription="ROCKET"
     Mesh=LodMesh'DeusExItems.GEPAmmo'
     CollisionRadius=18.000000
     CollisionHeight=7.800000
     bCollideActors=True
}
