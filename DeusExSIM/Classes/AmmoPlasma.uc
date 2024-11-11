//=============================================================================
// AmmoPlasma.
//=============================================================================
class AmmoPlasma extends DeusExAmmo;

//MADDERS: Replace old versions with HEAT ammo, when appropriate
function ReplaceWithPlague()
{
 	local vector TVect;
 	local DeusExAmmo Rep;
 	
 	TVect = vect(0, 0, 20);
 	SetCollision(False, False, False);
 	if (!SetLocation(Location + TVect)) TVect = vect(0,0,0);
 	Rep = Spawn(Class'AmmoPlasmaPlague',,,Location - TVect, Rotation);
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
	//MADDERS: Don't install this incomplete, silly ammo unless we're out of the main campaign.
	if ((Seed == 2 || Seed == 9) && (DXLI != None) && (DXLI.MissionNumber > 15)) //Seed == 4 || 
	{
		ReplaceWithPlague();
	}
}

function ProcessVMDChanges()
{
 	local int Seed;
	local DeusExLevelInfo DXLI;
 	
 	if (bDidSetup) return;
 	if ((Level.TimeSeconds > 5) && (!bCrateSummoned)) return;
 	
 	Super.ProcessVMDChanges();
 	
	forEach AllActors(class'DeusExLevelInfo', DXLI) break;
 	Seed = class'VMDStaticFunctions'.Static.DeriveActorSeed(Self);
 	if ((Owner == None) && (!bCrateSummoned))
	{
		//MADDERS: Don't install this incomplete, silly ammo unless we're out of the main campaign.
		if ((Seed == 2 || Seed == 9) && (DXLI != None) && (DXLI.MissionNumber > 15)) //Seed == 4 || 
		{
			ReplaceWithPlague();
		}
	}
}

defaultproperties
{
     Mass=2.000000
     bShowInfo=True
     AmmoAmount=12
     MaxAmmo=96
     ItemName="Plasma Clip"
     ItemArticle="a"
     PickupViewMesh=LodMesh'DeusExItems.AmmoPlasma'
     LandSound=Sound'DeusExSounds.Generic.PlasticHit2'
     Icon=Texture'DeusExUI.Icons.BeltIconAmmoPlasma'
     largeIconWidth=22
     largeIconHeight=46
     Description="A clip of extruded, magnetically-doped plastic slugs that can be heated and delivered with devastating effect using the plasma gun."
     beltDescription="PMA CLIP"
     Mesh=LodMesh'DeusExItems.AmmoPlasma'
     CollisionRadius=4.300000
     CollisionHeight=8.440000
     bCollideActors=True
}
