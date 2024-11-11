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
 	local int Seed;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
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
