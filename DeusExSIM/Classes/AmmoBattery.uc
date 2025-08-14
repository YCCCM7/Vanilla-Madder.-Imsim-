//=============================================================================
// AmmoBattery.
//=============================================================================
class AmmoBattery extends DeusExAmmo;

//MADDERS: Replace old versions with taser ammo, when appropriate.
function ReplaceWithOvercharged()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'AmmoOverchargedBattery',,,Location - TVect, Rotation);
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
	if (Seed == 4 || Seed == 8)
	{
		ReplaceWithOvercharged();
	}
}

function ProcessVMDChanges()
{
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
 	Super.ProcessVMDChanges();
 	
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
 	if ((Owner == None) && (!bCrateSummoned))
	{
		if (Seed == 8 || Seed == 3)
		{
			ReplaceWithOvercharged();
		}
	}
}

defaultproperties
{
     Mass=0.030000
     bShowInfo=True
     AmmoAmount=4
     MaxAmmo=40
     ItemName="Prod Charger"
     ItemArticle="a"
     PickupViewMesh=LodMesh'DeusExItems.AmmoProd'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoProd'
     largeIcon=Texture'DeusExUI.Icons.LargeIconAmmoProd'
     largeIconWidth=17
     largeIconHeight=46
     Description="A portable charging unit for the riot prod."
     beltDescription="CHARGER"
     Mesh=LodMesh'DeusExItems.AmmoProd'
     CollisionRadius=2.100000
     CollisionHeight=5.600000
     bCollideActors=True
}
